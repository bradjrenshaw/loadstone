//! `loadstone install` / `uninstall` / `list` — the CLI frontend to the
//! install engine. Package resolution from local scope directories; release
//! sources are either a local release.json + artifact or the package's
//! GitHub source repo.

use std::io::Write as _;
use std::path::{Path, PathBuf};

use anyhow::{bail, Context as _, Result};

use loadstone_core::context::InstallContext;
use loadstone_core::detect;
use loadstone_core::engine::{self, EngineUi, InstallPlan, RetryChoice};
use loadstone_core::fetch;
use loadstone_core::profile::Profile;
use loadstone_core::registry::{HttpFetcher, ResolvedPackage, Resolver};
use loadstone_core::track::StateStore;
use loadstone_core::types::{Kind, ReleaseManifest};

use crate::load_json;

// ---------------------------------------------------------------------------
// Terminal UI: plain lines, plain questions. Screen-reader-first.

pub struct TerminalUi {
    pub assume_yes: bool,
    /// Pre-supplied answers for pick-directory steps, by variable id
    /// (from --dir id=path flags).
    pub preset_dirs: std::collections::BTreeMap<String, PathBuf>,
    last_percent: u32,
}

impl TerminalUi {
    pub fn new(assume_yes: bool) -> Self {
        Self { assume_yes, preset_dirs: Default::default(), last_percent: 200 }
    }

    fn ask(&self, prompt: &str) -> String {
        print!("{prompt} ");
        let _ = std::io::stdout().flush();
        let mut line = String::new();
        let _ = std::io::stdin().read_line(&mut line);
        line.trim().to_string()
    }
}

impl EngineUi for TerminalUi {
    fn log(&mut self, message: &str) {
        println!("{message}");
    }

    fn progress(&mut self, percent: u32) {
        // Quiet, discrete announcements — no spinner, no rewriting the line.
        let bucket = percent / 25;
        if bucket != self.last_percent {
            self.last_percent = bucket;
            println!("  {percent}%");
        }
    }

    fn confirm(&mut self, message: &str) -> bool {
        if self.assume_yes {
            println!("{message} -- yes (--yes)");
            return true;
        }
        let answer = self.ask(&format!("{message} [y/N]"));
        matches!(answer.to_lowercase().as_str(), "y" | "yes")
    }

    fn retry_skip_cancel(&mut self, message: &str) -> RetryChoice {
        if self.assume_yes {
            println!("{message} -- skipping (--yes)");
            return RetryChoice::Skip;
        }
        loop {
            let answer = self
                .ask(&format!("{message}\n[r]etry, [s]kip, or [c]ancel?"))
                .to_lowercase();
            match answer.as_str() {
                "r" | "retry" => return RetryChoice::Retry,
                "s" | "skip" => return RetryChoice::Skip,
                "c" | "cancel" | "" => return RetryChoice::Cancel,
                _ => println!("Please answer r, s, or c."),
            }
        }
    }

    fn pick_directory(&mut self, id: &str, prompt: &str, suggest: Option<&str>) -> Option<PathBuf> {
        if let Some(preset) = self.preset_dirs.get(id) {
            println!("{prompt} -- using {} (--dir {id}=...)", preset.display());
            return Some(preset.clone());
        }
        if self.assume_yes {
            println!("{prompt} -- cannot prompt with --yes; step fails (pass --dir {id}=path)");
            return None;
        }
        let hint = suggest.map(|s| format!(" (suggested: {s})")).unwrap_or_default();
        let answer = self.ask(&format!("{prompt}{hint}\nEnter a full path, or leave empty to cancel:"));
        if answer.is_empty() {
            None
        } else {
            Some(PathBuf::from(answer))
        }
    }
}

// ---------------------------------------------------------------------------
// install

pub struct InstallArgs {
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
    pub no_deps: bool,
    pub assume_yes: bool,
    /// Update mode: bail early when the resolved version is already installed.
    pub update_mode: bool,
}

/// The full registry-source list for a command: local --scope dirs
/// (innermost), then --registry flags, then the profile's registries.
fn source_chain(args: &InstallArgs) -> Result<Vec<String>> {
    let mut sources = Vec::new();
    for dir in &args.scopes {
        if !dir.is_dir() {
            bail!("scope directory not found: {}", dir.display());
        }
        sources.push(dir.to_string_lossy().into_owned());
    }
    sources.extend(args.registries.iter().cloned());
    sources.extend(args.profile.registries.iter().cloned());
    if sources.is_empty() {
        bail!("no package sources: pass --scope or --registry, or configure registries in the profile");
    }
    Ok(sources)
}

pub fn cmd_install(args: &InstallArgs) -> Result<()> {
    let mut ui = TerminalUi::new(args.assume_yes);
    let id = match (&args.id, &args.profile.mod_id) {
        (Some(id), _) => id.clone(),
        (None, Some(pinned)) => pinned.clone(),
        (None, None) => bail!("no package id given (and the profile pins no mod)"),
    };

    let sources = source_chain(args)?;
    let mut fetcher = HttpFetcher::new(None, Box::new(|msg| println!("{msg}")))?;
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

    // Locate the game.
    let (game_dir, distribution) = match &args.game_dir {
        Some(dir) => {
            if !detect::validate_game_dir(&game, dir) {
                bail!(
                    "{} does not look like a {} folder (none of the expected files found)",
                    dir.display(),
                    game.name
                );
            }
            (dir.clone(), detect::infer_distribution(dir))
        }
        None => match detect::detect(&game)? {
            Some(found) => {
                ui.log(&format!("Found {} at {}", game.name, found.game_dir.display()));
                (found.game_dir, found.distribution)
            }
            None => bail!(
                "could not find {} automatically; pass --game-dir",
                game.name
            ),
        },
    };

    // Distribution support gate.
    if let Some(support) = manifest.distributions.get(&distribution) {
        use loadstone_core::types::SupportLevel;
        match support.level() {
            SupportLevel::Unsupported => {
                let reason = match support {
                    loadstone_core::types::DistributionSupport::Detailed { reason: Some(r), .. } => r.clone(),
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

    let mut ctx = InstallContext::build(&game, game_dir, args.user_data.clone(), distribution)?;
    let store = StateStore::open(args.state_dir.clone())?;

    // Resolve the release: branch zipball (dev channels), a local
    // release.json + artifact pair, or the source repo's latest release.
    let (version, install_steps, uninstall_steps, user_data_decl, artifact, expected_sha);
    let (settings, actions, strip_top_level);
    let is_branch_channel = manifest
        .channels
        .get(&args.channel)
        .map(|c| c.source == loadstone_core::types::ChannelSource::Branch)
        .unwrap_or(false);

    if args.channel != "stable" && !is_branch_channel {
        bail!(
            "\"{}\" declares no \"{}\" branch channel",
            manifest.id,
            args.channel
        );
    }

    if is_branch_channel {
        let branch = manifest.channels[&args.channel]
            .branch
            .clone()
            .context("branch channel without a branch name")?;
        let source = release_source
            .clone()
            .context("branch installs need a source repo (install via a registry)")?;
        if manifest.source_install.is_empty() {
            bail!("\"{}\" has no sourceInstall steps; the {} channel cannot install", id, args.channel);
        }
        let sha = match fetch::branch_tip_sha(&source, &branch) {
            Ok(sha) => sha,
            Err(_) => "unknown".to_string(),
        };
        version = format!("{branch}@{sha}");
        if args.update_mode {
            if let Some(state) = store.load(&game_id, &id)? {
                if state.version == version && sha != "unknown" {
                    ui.log(&format!("{} is up to date ({version}).", manifest.name));
                    return Ok(());
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
        let release: ReleaseManifest = match &args.local_release {
            Some(release_path) => serde_json::from_value(load_json(release_path)?)
                .with_context(|| format!("{} is not a release manifest", release_path.display()))?,
            None => {
                let source = release_source
                    .clone()
                    .context("no --local-release given and no source repo is known for this package")?;
                ui.log(&format!("Fetching latest release information from {source}..."));
                fetch::fetch_latest_release_manifest(&source)?
            }
        };
        if args.update_mode {
            if let Some(state) = store.load(&game_id, &id)? {
                let same = loadstone_core::release::normalize_version(&release.version)
                    .map(|v| v == state.version)
                    .unwrap_or(release.version == state.version);
                if same {
                    ui.log(&format!("{} is up to date ({}).", manifest.name, state.version));
                    return Ok(());
                }
                ui.log(&format!(
                    "Updating {} {} -> {}.",
                    manifest.name, state.version, release.version
                ));
            }
        }
        let entry = pick_artifact(&ctx, &release.artifacts)?;
        match &args.local_release {
            Some(release_path) => {
                let artifact_path = match &args.local_artifact {
                    Some(p) => p.clone(),
                    None => release_path.parent().unwrap_or(Path::new(".")).join(&entry.file),
                };
                ui.log(&format!("Using local artifact {}", artifact_path.display()));
                artifact = std::fs::read(&artifact_path)
                    .with_context(|| format!("failed to read {}", artifact_path.display()))?;
            }
            None => {
                let source = release_source.clone().unwrap();
                let url = fetch::latest_asset_url(&source, &entry.file)?;
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
    if !args.no_deps {
        let mut dep_scopes = vec![mod_scope.clone()];
        dep_scopes.extend(base_scopes.iter().cloned());
        let mut dep_resolver = Resolver { scopes: dep_scopes, fetcher: &mut fetcher };
        for dep in &manifest.dependencies {
            install_dependency(&mut dep_resolver, &store, &mut ctx, &game_id, &id, &dep.id, &mut ui)?;
        }
    }

    let plan = InstallPlan {
        manifest: &manifest,
        game_id: game_id.clone(),
        version: version.clone(),
        channel: args.channel.clone(),
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
    engine::install(&store, &mut ctx, &plan, &mut ui)?;
    ui.log(&format!("{} {} installed.", manifest.name, version));
    Ok(())
}

fn pick_artifact<'a>(
    ctx: &InstallContext,
    artifacts: &'a [loadstone_core::types::ReleaseArtifact],
) -> Result<&'a loadstone_core::types::ReleaseArtifact> {
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
    ui: &mut TerminalUi,
) -> Result<()> {
    if let Some(mut state) = store.load(game_id, dep_id)? {
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

// ---------------------------------------------------------------------------
// settings / action

pub fn cmd_settings(
    id: &str,
    game: &str,
    state_dir: Option<PathBuf>,
    sets: &[String],
) -> Result<()> {
    use loadstone_core::types::{SettingType, Settings};
    let store = StateStore::open(state_dir)?;
    let state = store
        .load(game, id)?
        .with_context(|| format!("\"{id}\" is not installed for {game}"))?;
    let settings: &Settings = state
        .settings
        .as_ref()
        .with_context(|| format!("\"{id}\" declares no settings"))?;
    let file = state
        .settings_file
        .as_ref()
        .context("no settings storage file recorded")?;

    let mut values: serde_json::Map<String, serde_json::Value> = if file.exists() {
        serde_json::from_str(
            std::fs::read_to_string(file)?.trim_start_matches('\u{feff}'),
        )
        .with_context(|| format!("{} is not valid JSON", file.display()))?
    } else {
        Default::default()
    };

    if sets.is_empty() {
        // List: one setting per line, current value first for quick reading.
        for entry in &settings.entries {
            let current = values
                .get(&entry.id)
                .or(entry.default.as_ref())
                .map(|v| v.to_string())
                .unwrap_or_else(|| "unset".to_string());
            println!("{} = {}  ({})", entry.id, current, entry.label);
            if let Some(desc) = &entry.description {
                println!("    {desc}");
            }
        }
        return Ok(());
    }

    for pair in sets {
        let (key, raw) = pair
            .split_once('=')
            .with_context(|| format!("--set takes id=value, got \"{pair}\""))?;
        let entry = settings
            .entries
            .iter()
            .find(|e| e.id == key)
            .with_context(|| {
                let known: Vec<&str> = settings.entries.iter().map(|e| e.id.as_str()).collect();
                format!("no setting \"{key}\" (known: {})", known.join(", "))
            })?;
        let value = match entry.entry_type {
            SettingType::Boolean => match raw.to_lowercase().as_str() {
                "true" | "yes" | "on" | "1" => serde_json::Value::Bool(true),
                "false" | "no" | "off" | "0" => serde_json::Value::Bool(false),
                _ => bail!("\"{key}\" is a boolean; use true or false"),
            },
            SettingType::Number => {
                let n: f64 = raw.parse().with_context(|| format!("\"{key}\" needs a number"))?;
                if let Some(min) = entry.min {
                    if n < min {
                        bail!("\"{key}\" must be at least {min}");
                    }
                }
                if let Some(max) = entry.max {
                    if n > max {
                        bail!("\"{key}\" must be at most {max}");
                    }
                }
                serde_json::json!(n)
            }
            SettingType::String => serde_json::Value::String(raw.to_string()),
            SettingType::Choice => {
                let value = serde_json::Value::String(raw.to_string());
                if !entry.options.iter().any(|o| o.value == value) {
                    let options: Vec<String> =
                        entry.options.iter().map(|o| o.value.to_string()).collect();
                    bail!("\"{key}\" must be one of: {}", options.join(", "));
                }
                value
            }
        };
        values.insert(key.to_string(), value);
        println!("{key} set.");
    }

    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(file, serde_json::to_string_pretty(&serde_json::Value::Object(values))?)?;
    if let Some(note) = &settings.note {
        println!("{note}");
    }
    Ok(())
}

pub fn cmd_action(
    id: &str,
    action_id: &str,
    game: &str,
    state_dir: Option<PathBuf>,
    dirs: &[String],
    assume_yes: bool,
) -> Result<()> {
    let mut ui = TerminalUi::new(assume_yes);
    for pair in dirs {
        let (var, path) = pair
            .split_once('=')
            .with_context(|| format!("--dir takes id=path, got \"{pair}\""))?;
        ui.preset_dirs.insert(var.to_string(), PathBuf::from(path));
    }
    let store = StateStore::open(state_dir)?;
    let state = store
        .load(game, id)?
        .with_context(|| format!("\"{id}\" is not installed for {game}"))?;
    engine::run_action(&store, &state, action_id, &mut ui)
}

// ---------------------------------------------------------------------------
// uninstall / list

pub fn cmd_uninstall(
    id: &str,
    game: &str,
    state_dir: Option<PathBuf>,
    purge: Option<bool>,
    assume_yes: bool,
) -> Result<()> {
    let mut ui = TerminalUi::new(assume_yes);
    let store = StateStore::open(state_dir)?;
    let state = store
        .load(game, id)?
        .with_context(|| format!("\"{id}\" is not installed for {game}"))?;
    engine::uninstall(&store, &state, purge, &mut ui)?;
    // Release our claim on any tools we pulled in.
    for dep_id in &state.dependencies {
        if let Some(mut dep_state) = store.load(game, dep_id)? {
            dep_state.dependents.retain(|d| d != id);
            store.save(&dep_state)?;
            if dep_state.dependents.is_empty() {
                ui.log(&format!(
                    "{dep_id} is no longer needed by any installed mod; uninstall it with: loadstone uninstall {dep_id} --game {game}"
                ));
            }
        }
    }
    Ok(())
}

pub fn cmd_list(state_dir: Option<PathBuf>) -> Result<()> {
    let store = StateStore::open(state_dir)?;
    let games = store.games()?;
    if games.is_empty() {
        println!("Nothing installed.");
        return Ok(());
    }
    for game in games {
        println!("{game}:");
        for state in store.list(&game)? {
            let extra = if state.kind == "tool" {
                format!(" (tool; needed by: {})", if state.dependents.is_empty() { "nobody".to_string() } else { state.dependents.join(", ") })
            } else {
                String::new()
            };
            println!("  {} {} [{}]{}", state.id, state.version, state.channel, extra);
        }
    }
    Ok(())
}
