//! High-level operations shared by every frontend: resolve, download, and
//! install a mod (with dependencies), update it, uninstall it. The CLI and
//! the GUI both drive these with their own `EngineUi`; nothing here prints
//! or shows dialogs directly.

use std::cell::RefCell;
use std::path::{Path, PathBuf};
use std::rc::Rc;

use anyhow::{bail, Context as _, Result};

use crate::context::InstallContext;
use crate::detect;
use crate::engine::{self, EngineUi, InstallPlan};
use crate::fetch;
use crate::profile::Profile;
use crate::registry::{HttpFetcher, ResolvedPackage, Resolver};
use crate::track::StateStore;
use crate::types::{Kind, ReleaseManifest};

pub struct InstallOptions {
    /// Package id; None falls back to the profile's pinned mod.
    pub id: Option<String>,
    /// Local package directories (innermost scopes, ahead of registries).
    pub scopes: Vec<PathBuf>,
    /// Extra registries (github:owner/repo or paths), ahead of the profile's.
    pub registries: Vec<String>,
    pub profile: Profile,
    pub game_dir: Option<PathBuf>,
    pub user_data: Option<PathBuf>,
    pub state_dir: Option<PathBuf>,
    pub local_release: Option<PathBuf>,
    pub local_artifact: Option<PathBuf>,
    /// Channel name: "stable" (default) fetches releases; a branch channel
    /// declared by the manifest installs the branch zipball (dev).
    pub channel: String,
    /// A specific release tag to install. Its own loadstone-release.json
    /// and assets are used — never the latest release's. Ignored for
    /// branch channels; an explicitly chosen tag also skips the
    /// already-up-to-date early return (reinstalling it is deliberate).
    pub tag: Option<String>,
    pub no_deps: bool,
    /// Update mode: bail early when the resolved version is already installed.
    pub update_mode: bool,
}

impl Default for InstallOptions {
    fn default() -> Self {
        Self {
            id: None,
            scopes: Vec::new(),
            registries: Vec::new(),
            profile: Profile::default(),
            game_dir: None,
            user_data: None,
            state_dir: None,
            local_release: None,
            local_artifact: None,
            channel: "stable".to_string(),
            tag: None,
            no_deps: false,
            update_mode: false,
        }
    }
}

/// The full registry-source list for an operation: local scope dirs
/// (innermost), then explicit registries, then the profile's.
fn source_chain(opts: &InstallOptions) -> Result<Vec<String>> {
    let mut sources = Vec::new();
    for dir in &opts.scopes {
        if !dir.is_dir() {
            bail!("scope directory not found: {}", dir.display());
        }
        sources.push(dir.to_string_lossy().into_owned());
    }
    sources.extend(opts.registries.iter().cloned());
    sources.extend(opts.profile.registries.iter().cloned());
    if sources.is_empty() {
        bail!("no package sources: pass --scope or --registry, or configure registries in the profile");
    }
    Ok(sources)
}

fn load_json(path: &Path) -> Result<serde_json::Value> {
    let text = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read {}", path.display()))?;
    // Tolerate a UTF-8 BOM, as the spec requires of clients.
    serde_json::from_str(text.trim_start_matches('\u{feff}'))
        .with_context(|| format!("{} is not valid JSON", path.display()))
}

/// Install (or, with `update_mode`, update) a mod. Returns a one-line
/// summary for the frontend to show.
pub fn install(opts: &InstallOptions, ui: &mut dyn EngineUi) -> Result<String> {
    let id = match (&opts.id, &opts.profile.mod_id) {
        (Some(id), _) => id.clone(),
        (None, Some(pinned)) => pinned.clone(),
        (None, None) => bail!("no package id given (and the profile pins no mod)"),
    };

    let sources = source_chain(opts)?;
    let fetch_notes: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    let notes_sink = fetch_notes.clone();
    let mut fetcher = HttpFetcher::new(
        None,
        Box::new(move |msg| notes_sink.borrow_mut().push(msg.to_string())),
    )?;
    let mut resolver = Resolver::from_sources(&sources, &mut fetcher)?;
    let resolved = resolver.resolve_project(&id)?;
    let ResolvedPackage { manifest, scope: mod_scope, release_source } = resolved;
    if manifest.kind != Kind::Mod {
        bail!("\"{id}\" is a {:?}; `install` takes a mod (tools install as dependencies)", manifest.kind);
    }
    let game_id = manifest.game.clone().context("mod declares no game")?;
    let game = resolver.resolve_game(&game_id, &mod_scope)?;
    let base_scopes = resolver.scopes.clone();
    drop(resolver);
    for note in fetch_notes.borrow_mut().drain(..) {
        ui.log(&note);
    }

    let store = StateStore::open(opts.state_dir.clone())?;

    // Locate the game copy: explicit dir, the copy an update is recorded
    // for, store detection, or ask the user.
    let recorded_copy = if opts.update_mode && opts.game_dir.is_none() {
        let records = store.find_all(&game_id, &id)?;
        match records.len() {
            0 => None,
            1 => {
                let r = &records[0];
                ui.log(&format!(
                    "Updating the {} copy at {}.",
                    r.distribution,
                    r.game_dir.display()
                ));
                Some((r.game_dir.clone(), r.distribution.clone()))
            }
            _ => {
                let dirs: Vec<String> = records
                    .iter()
                    .map(|r| format!("{} ({})", r.game_dir.display(), r.distribution))
                    .collect();
                bail!(
                    "\"{id}\" is installed for more than one copy of {}: {}. Pass --game-dir to say which copy to update.",
                    game.name,
                    dirs.join(", ")
                );
            }
        }
    } else {
        None
    };
    let (game_dir, distribution) = match (&opts.game_dir, recorded_copy) {
        (_, Some(copy)) => copy,
        (Some(dir), None) => {
            if !detect::validate_game_dir(&game, dir) {
                bail!(
                    "{} does not look like a {} folder (none of the expected files found)",
                    dir.display(),
                    game.name
                );
            }
            (dir.clone(), detect::infer_distribution(dir))
        }
        (None, None) => match detect::detect(&game)? {
            Some(found) => {
                ui.log(&format!("Found {} at {}", game.name, found.game_dir.display()));
                (found.game_dir, found.distribution)
            }
            None => {
                ui.log(&format!("Could not find {} automatically.", game.name));
                let picked = ui
                    .pick_directory(
                        "gameDir",
                        &format!("Where is {} installed?", game.name),
                        None,
                    )
                    .with_context(|| {
                        format!("could not find {} automatically; pass --game-dir or pick its folder", game.name)
                    })?;
                if !detect::validate_game_dir(&game, &picked) {
                    bail!(
                        "{} does not look like a {} folder (none of the expected files found)",
                        picked.display(),
                        game.name
                    );
                }
                let distribution = detect::infer_distribution(&picked);
                (picked, distribution)
            }
        },
    };

    // Distribution support gate.
    if let Some(support) = manifest.distributions.get(&distribution) {
        use crate::types::SupportLevel;
        match support.level() {
            SupportLevel::Unsupported => {
                let reason = match support {
                    crate::types::DistributionSupport::Detailed { reason: Some(r), .. } => r.clone(),
                    _ => String::new(),
                };
                bail!("the {} copy of {} is not supported. {}", distribution, game.name, reason);
            }
            SupportLevel::Untested => {
                ui.log(&format!(
                    "Note: the {} copy of {} is untested with this mod.",
                    distribution, game.name
                ));
            }
            SupportLevel::Supported => {}
        }
    }

    let mut ctx = InstallContext::build(&game, game_dir, opts.user_data.clone(), distribution)?;

    // Resolve the release: branch zipball (dev channels), a local
    // loadstone-release.json + artifact pair, or the source repo's latest release.
    let (version, install_steps, uninstall_steps, user_data_decl, artifact, expected_sha);
    let (settings, actions, strip_top_level);
    let is_branch_channel = manifest
        .channels
        .get(&opts.channel)
        .map(|c| c.source == crate::types::ChannelSource::Branch)
        .unwrap_or(false);

    if opts.channel != "stable" && !is_branch_channel {
        bail!(
            "\"{}\" declares no \"{}\" branch channel",
            manifest.id,
            opts.channel
        );
    }

    if is_branch_channel {
        let branch = manifest.channels[&opts.channel]
            .branch
            .clone()
            .context("branch channel without a branch name")?;
        let source = release_source
            .clone()
            .context("branch installs need a source repo (install via a registry)")?;
        if manifest.source_install.is_empty() {
            bail!("\"{}\" has no sourceInstall steps; the {} channel cannot install", id, opts.channel);
        }
        let sha = match fetch::branch_tip_sha(&source, &branch) {
            Ok(sha) => sha,
            Err(_) => "unknown".to_string(),
        };
        version = format!("{branch}@{sha}");
        if opts.update_mode {
            if let Some(state) = store.load(&game_id, &id, &ctx.game_dir)? {
                if state.version == version && sha != "unknown" {
                    return Ok(format!("{} is up to date ({version}).", manifest.name));
                }
            }
        }
        ui.log(&format!(
            "Installing {} from the tip of {branch} ({version}). Development installs \
             are not hash-pinned; you are trusting the repository's current contents.",
            manifest.name
        ));
        let url = fetch::branch_zipball_url(&source, &branch)?;
        artifact = fetch::download(&url, |p| ui.progress(p))?;
        expected_sha = None;
        install_steps = manifest.source_install.clone();
        uninstall_steps = manifest.uninstall.clone();
        user_data_decl = manifest.user_data.clone();
        settings = manifest.settings.clone();
        actions = manifest.actions.clone();
        strip_top_level = true;
    } else {
        let release: ReleaseManifest = match &opts.local_release {
            Some(release_path) => serde_json::from_value(load_json(release_path)?)
                .with_context(|| format!("{} is not a release manifest", release_path.display()))?,
            None => {
                let source = release_source
                    .clone()
                    .context("no --local-release given and no source repo is known for this package")?;
                match &opts.tag {
                    Some(tag) => {
                        ui.log(&format!("Fetching release {tag} information from {source}..."));
                        fetch::fetch_release_manifest_for_tag(&source, tag)?
                    }
                    None => {
                        ui.log(&format!("Fetching latest release information from {source}..."));
                        fetch::fetch_latest_release_manifest(&source)?
                    }
                }
            }
        };
        if opts.update_mode && opts.tag.is_none() {
            if let Some(state) = store.load(&game_id, &id, &ctx.game_dir)? {
                let same = crate::release::normalize_version(&release.version)
                    .map(|v| v == state.version)
                    .unwrap_or(release.version == state.version);
                if same {
                    return Ok(format!("{} is up to date ({}).", manifest.name, state.version));
                }
                ui.log(&format!(
                    "Updating {} {} -> {}.",
                    manifest.name, state.version, release.version
                ));
            }
        }
        let entry = pick_artifact(&ctx, &release.artifacts)?;
        match &opts.local_release {
            Some(release_path) => {
                let artifact_path = match &opts.local_artifact {
                    Some(p) => p.clone(),
                    None => release_path.parent().unwrap_or(Path::new(".")).join(&entry.file),
                };
                ui.log(&format!("Using local artifact {}", artifact_path.display()));
                artifact = std::fs::read(&artifact_path)
                    .with_context(|| format!("failed to read {}", artifact_path.display()))?;
            }
            None => {
                let source = release_source.clone().unwrap();
                // Assets come from the same release the manifest did.
                let url = match &opts.tag {
                    Some(tag) => fetch::tagged_asset_url(&source, tag, &entry.file)?,
                    None => fetch::latest_asset_url(&source, &entry.file)?,
                };
                ui.log(&format!("Downloading {}...", entry.file));
                artifact = fetch::download(&url, |p| ui.progress(p))?;
            }
        }
        expected_sha = Some(entry.sha256.clone());
        version = release.version.clone();
        install_steps = release.install.clone();
        uninstall_steps = release.uninstall.clone();
        user_data_decl = release.user_data.clone();
        settings = release.settings.clone();
        actions = release.actions.clone();
        strip_top_level = false;
    }

    // Dependencies first, so the mod lands on a working loader. They resolve
    // through the mod's own chain: its scope innermost, then the registries.
    if !opts.no_deps {
        let mut dep_scopes = vec![mod_scope.clone()];
        dep_scopes.extend(base_scopes.iter().cloned());
        let mut dep_resolver = Resolver { scopes: dep_scopes, fetcher: &mut fetcher };
        for dep in &manifest.dependencies {
            install_dependency(&mut dep_resolver, &store, &mut ctx, &game_id, &id, &dep.id, ui)?;
        }
        for note in fetch_notes.borrow_mut().drain(..) {
            ui.log(&note);
        }
    }

    let plan = InstallPlan {
        manifest: &manifest,
        game_id: game_id.clone(),
        version: version.clone(),
        channel: opts.channel.clone(),
        install_steps: &install_steps,
        uninstall_steps: &uninstall_steps,
        user_data_decl: &user_data_decl,
        artifact: &artifact,
        expected_sha256: expected_sha.as_deref(),
        keep_existing: false,
        dependent_of: None,
        settings: settings.as_ref(),
        actions: &actions,
        strip_top_level,
    };
    engine::install(&store, &mut ctx, &plan, ui)?;
    Ok(format!("{} {} installed.", manifest.name, version))
}

fn pick_artifact<'a>(
    ctx: &InstallContext,
    artifacts: &'a [crate::types::ReleaseArtifact],
) -> Result<&'a crate::types::ReleaseArtifact> {
    for artifact in artifacts {
        match &artifact.when {
            Some(cond) => {
                if ctx.condition_matches(cond)? {
                    return Ok(artifact);
                }
            }
            None => return Ok(artifact),
        }
    }
    bail!("no release artifact matches this platform/architecture/distribution")
}

fn install_dependency(
    resolver: &mut Resolver,
    store: &StateStore,
    ctx: &mut InstallContext,
    game_id: &str,
    dependent: &str,
    dep_id: &str,
    ui: &mut dyn EngineUi,
) -> Result<()> {
    if let Some(mut state) = store.load(game_id, dep_id, &ctx.game_dir)? {
        if !state.dependents.iter().any(|d| d == dependent) {
            state.dependents.push(dependent.to_string());
            store.save(&state)?;
        }
        ui.log(&format!("Dependency {dep_id} {} already installed.", state.version));
        return Ok(());
    }

    let resolved = resolver.resolve_project(dep_id)?;
    let tool = resolved.manifest;
    if tool.kind != Kind::Tool && tool.kind != Kind::Library {
        bail!("dependency \"{dep_id}\" is not a tool or library package");
    }
    let pinned = tool.pinned_release.as_ref().with_context(|| {
        format!("dependency \"{dep_id}\" has no pinnedRelease; other dependency sources are not supported yet")
    })?;
    let source = resolved
        .release_source
        .as_ref()
        .with_context(|| format!("dependency \"{dep_id}\" has no source repo"))?;

    let entry = pick_artifact(ctx, &pinned.artifacts)?;
    let tag = pinned
        .tag
        .clone()
        .unwrap_or_else(|| format!("v{}", pinned.version));
    let url = fetch::tagged_asset_url(source, &tag, &entry.file)?;
    ui.log(&format!("Installing dependency {} {} ({})...", tool.name, pinned.version, entry.file));
    let artifact = fetch::download(&url, |p| ui.progress(p))?;

    let keep_existing = tool.conflict_policy.as_deref() == Some("keep-newer");
    let plan = InstallPlan {
        manifest: &tool,
        game_id: game_id.to_string(),
        version: pinned.version.clone(),
        channel: "pinned".to_string(),
        install_steps: &tool.install,
        uninstall_steps: &tool.uninstall,
        user_data_decl: &tool.user_data,
        artifact: &artifact,
        expected_sha256: Some(&entry.sha256),
        keep_existing,
        dependent_of: Some(dependent.to_string()),
        settings: tool.settings.as_ref(),
        actions: &tool.actions,
        strip_top_level: false,
    };
    engine::install(store, ctx, &plan, ui)?;
    Ok(())
}

/// The install of `id` for `game`, addressed by copy: an explicit game
/// directory names the copy; without one there must be exactly one copy
/// with this package installed.
pub fn find_installed(
    store: &StateStore,
    game: &str,
    id: &str,
    game_dir: Option<&Path>,
) -> Result<crate::track::InstalledState> {
    if let Some(dir) = game_dir {
        return store
            .load(game, id, dir)?
            .with_context(|| format!("\"{id}\" is not installed for the {game} copy at {}", dir.display()));
    }
    let mut records = store.find_all(game, id)?;
    match records.len() {
        0 => bail!("\"{id}\" is not installed for {game}"),
        1 => Ok(records.remove(0)),
        _ => {
            let dirs: Vec<String> = records
                .iter()
                .map(|r| format!("{} ({})", r.game_dir.display(), r.distribution))
                .collect();
            bail!(
                "\"{id}\" is installed for more than one copy of {game}: {}. Pass --game-dir to say which copy.",
                dirs.join(", ")
            );
        }
    }
}

/// Best-effort probe for a copy Loadstone has no record of: do the mod's
/// files already sit in this game directory (placed by hand, or by an
/// older standalone installer)? Judged by the manifest's `expect` checks —
/// the files an install is required to leave behind — so packages declare
/// nothing extra. Every applicable check must pass; a manifest without
/// expect checks, or one whose tokens don't resolve on this machine,
/// answers false and the caller keeps its plain "not installed" wording.
pub fn foreign_install_present(
    game: &crate::types::GameManifest,
    manifest: &crate::types::ProjectManifest,
    game_dir: &Path,
    distribution: &str,
) -> bool {
    let Ok(ctx) = InstallContext::build(
        game,
        game_dir.to_path_buf(),
        None,
        distribution.to_string(),
    ) else {
        return false;
    };
    let mut any = false;
    for step in &manifest.install {
        let crate::types::Step::Expect { checks, common } = step else { continue };
        if let Some(cond) = &common.when {
            if !ctx.condition_matches(cond).unwrap_or(false) {
                continue;
            }
        }
        for check in checks {
            match ctx.glob_exists(&check.file_exists) {
                Ok(Some(_)) => any = true,
                _ => return false,
            }
        }
    }
    any
}

/// Uninstall an installed package, releasing its claims on any tool
/// dependencies. Returns a one-line summary.
pub fn uninstall(
    id: &str,
    game: &str,
    game_dir: Option<&Path>,
    state_dir: Option<PathBuf>,
    purge: Option<bool>,
    ui: &mut dyn EngineUi,
) -> Result<String> {
    let store = StateStore::open(state_dir)?;
    let state = find_installed(&store, game, id, game_dir)?;
    engine::uninstall(&store, &state, purge, ui)?;
    // Release our claim on any tools we pulled in (this copy's).
    for dep_id in &state.dependencies {
        if let Some(mut dep_state) = store.load(game, dep_id, &state.game_dir)? {
            dep_state.dependents.retain(|d| d != id);
            store.save(&dep_state)?;
            if dep_state.dependents.is_empty() {
                ui.log(&format!(
                    "{dep_id} is no longer needed by any installed mod; you can uninstall it too."
                ));
            }
        }
    }
    Ok(format!("{} {} uninstalled.", state.id, state.version))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::{GameManifest, ProjectManifest};

    fn game() -> GameManifest {
        serde_json::from_value(serde_json::json!({
            "manifestVersion": 1,
            "kind": "game",
            "id": "fake-game",
            "name": "Fake Game",
            "detect": { "markers": ["Fake.exe"] },
            "userData": { crate::context::current_platform(): "${localAppData}/FakeGame" }
        }))
        .unwrap()
    }

    fn mod_with_expect() -> ProjectManifest {
        serde_json::from_value(serde_json::json!({
            "manifestVersion": 1,
            "id": "fake-mod",
            "name": "Fake Mod",
            "description": "d",
            "authors": ["a"],
            "game": "fake-game",
            "install": [
                { "step": "extract-archive",
                  "routes": [ { "from": "**", "to": "${gameDir}" } ] },
                { "step": "expect",
                  "checks": [ { "fileExists": "${gameDir}/mods/FakeMod.dll",
                                "message": "missing" } ] },
                // A check gated to a platform that never matches must not
                // veto the probe.
                { "step": "expect",
                  "when": { "platform": "never-a-platform" },
                  "checks": [ { "fileExists": "${gameDir}/not-there",
                                "message": "gated" } ] }
            ]
        }))
        .unwrap()
    }

    #[test]
    fn foreign_install_detected_by_expect_checks() {
        let tmp = tempfile::tempdir().unwrap();
        let game_dir = tmp.path().join("game");
        std::fs::create_dir_all(game_dir.join("mods")).unwrap();
        let game = game();
        let manifest = mod_with_expect();

        assert!(
            !foreign_install_present(&game, &manifest, &game_dir, "steam"),
            "payload absent must read as not installed"
        );

        std::fs::write(game_dir.join("mods").join("FakeMod.dll"), b"x").unwrap();
        assert!(foreign_install_present(&game, &manifest, &game_dir, "steam"));

        // Without any expect checks the probe stays silent: no evidence
        // either way.
        let mut no_expect = manifest.clone();
        no_expect.install.retain(|s| s.name() != "expect");
        assert!(!foreign_install_present(&game, &no_expect, &game_dir, "steam"));
    }
}
