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
use loadstone_core::track::StateStore;
use loadstone_core::types::{GameManifest, Kind, ProjectManifest, ReleaseManifest};

use crate::load_json;

// ---------------------------------------------------------------------------
// Terminal UI: plain lines, plain questions. Screen-reader-first.

pub struct TerminalUi {
    pub assume_yes: bool,
    last_percent: u32,
}

impl TerminalUi {
    pub fn new(assume_yes: bool) -> Self {
        Self { assume_yes, last_percent: 200 }
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

    fn pick_directory(&mut self, prompt: &str, suggest: Option<&str>) -> Option<PathBuf> {
        if self.assume_yes {
            println!("{prompt} -- cannot prompt with --yes; step fails");
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
// Package resolution from scope directories.

pub struct ScopedPackages {
    /// (dir, id, parsed doc) in scope order — earlier dirs win.
    entries: Vec<(PathBuf, String, serde_json::Value)>,
}

impl ScopedPackages {
    pub fn load(scopes: &[PathBuf]) -> Result<Self> {
        let mut entries = Vec::new();
        for dir in scopes {
            if !dir.is_dir() {
                bail!("scope directory not found: {}", dir.display());
            }
            let mut files: Vec<PathBuf> = std::fs::read_dir(dir)?
                .filter_map(|e| e.ok())
                .map(|e| e.path())
                .filter(|p| p.extension().and_then(|e| e.to_str()) == Some("json"))
                .collect();
            files.sort();
            for file in files {
                let doc = load_json(&file)?;
                let id = doc
                    .get("id")
                    .and_then(serde_json::Value::as_str)
                    .unwrap_or_default()
                    .to_string();
                if !id.is_empty() {
                    entries.push((dir.clone(), id, doc));
                }
            }
        }
        Ok(Self { entries })
    }

    fn find(&self, id: &str) -> Option<&serde_json::Value> {
        self.entries
            .iter()
            .find(|(_, entry_id, _)| entry_id == id)
            .map(|(_, _, doc)| doc)
    }

    pub fn project(&self, id: &str) -> Result<ProjectManifest> {
        let doc = self
            .find(id)
            .with_context(|| format!("package \"{id}\" not found in any --scope directory"))?;
        serde_json::from_value(doc.clone())
            .with_context(|| format!("package \"{id}\" is not a valid project manifest"))
    }

    pub fn game(&self, id: &str) -> Result<GameManifest> {
        let doc = self
            .find(id)
            .with_context(|| format!("game package \"{id}\" not found in any --scope directory"))?;
        serde_json::from_value(doc.clone())
            .with_context(|| format!("\"{id}\" is not a valid game package"))
    }
}

// ---------------------------------------------------------------------------
// install

pub struct InstallArgs {
    pub id: String,
    pub scopes: Vec<PathBuf>,
    pub game_dir: Option<PathBuf>,
    pub user_data: Option<PathBuf>,
    pub state_dir: Option<PathBuf>,
    pub local_release: Option<PathBuf>,
    pub local_artifact: Option<PathBuf>,
    pub no_deps: bool,
    pub assume_yes: bool,
}

pub fn cmd_install(args: &InstallArgs) -> Result<()> {
    let mut ui = TerminalUi::new(args.assume_yes);
    let packages = ScopedPackages::load(&args.scopes)?;
    let manifest = packages.project(&args.id)?;
    if manifest.kind != Kind::Mod {
        bail!("\"{}\" is a {:?}; `install` takes a mod (tools install as dependencies)", args.id, manifest.kind);
    }
    let game_id = manifest.game.clone().context("mod declares no game")?;
    let game = packages.game(&game_id)?;

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

    // Resolve the release: local pair, or fetch from the source repo.
    let (version, install_steps, uninstall_steps, user_data_decl, artifact, expected_sha);
    match &args.local_release {
        Some(release_path) => {
            let release: ReleaseManifest = serde_json::from_value(load_json(release_path)?)
                .with_context(|| format!("{} is not a release manifest", release_path.display()))?;
            let entry = pick_artifact(&ctx, &release.artifacts)?;
            let artifact_path = match &args.local_artifact {
                Some(p) => p.clone(),
                None => release_path
                    .parent()
                    .unwrap_or(Path::new("."))
                    .join(&entry.file),
            };
            ui.log(&format!("Using local artifact {}", artifact_path.display()));
            artifact = std::fs::read(&artifact_path)
                .with_context(|| format!("failed to read {}", artifact_path.display()))?;
            expected_sha = Some(entry.sha256.clone());
            version = release.version.clone();
            install_steps = release.install.clone();
            uninstall_steps = release.uninstall.clone();
            user_data_decl = release.user_data.clone();
        }
        None => {
            let source = manifest
                .source
                .clone()
                .context("no --local-release given and the manifest has no \"source\" repo to fetch from")?;
            ui.log(&format!("Fetching latest release information from {source}..."));
            let release = fetch::fetch_latest_release_manifest(&source)?;
            let entry = pick_artifact(&ctx, &release.artifacts)?;
            let url = fetch::latest_asset_url(&source, &entry.file)?;
            ui.log(&format!("Downloading {}...", entry.file));
            artifact = fetch::download(&url, |p| ui.progress(p))?;
            expected_sha = Some(entry.sha256.clone());
            version = release.version.clone();
            install_steps = release.install.clone();
            uninstall_steps = release.uninstall.clone();
            user_data_decl = release.user_data.clone();
        }
    }

    // Dependencies first, so the mod lands on a working loader.
    if !args.no_deps {
        for dep in &manifest.dependencies {
            install_dependency(&packages, &store, &mut ctx, &game_id, &args.id, &dep.id, &mut ui)?;
        }
    }

    let plan = InstallPlan {
        manifest: &manifest,
        game_id: game_id.clone(),
        version: version.clone(),
        channel: "stable".to_string(),
        install_steps: &install_steps,
        uninstall_steps: &uninstall_steps,
        user_data_decl: &user_data_decl,
        artifact: &artifact,
        expected_sha256: expected_sha.as_deref(),
        keep_existing: false,
        dependent_of: None,
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
    packages: &ScopedPackages,
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

    let tool = packages.project(dep_id)?;
    if tool.kind != Kind::Tool && tool.kind != Kind::Library {
        bail!("dependency \"{dep_id}\" is not a tool or library package");
    }
    let pinned = tool.pinned_release.as_ref().with_context(|| {
        format!("dependency \"{dep_id}\" has no pinnedRelease; other dependency sources are not supported yet")
    })?;
    let source = tool
        .source
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
    };
    engine::install(store, ctx, &plan, ui)?;
    Ok(())
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
