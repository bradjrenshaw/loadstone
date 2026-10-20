//! The install engine (SPEC §9–§10): runs step lists against an install
//! context, tracks every write, verifies hashes, and owns uninstall.
//!
//! No printing and no prompting happens here — everything user-facing goes
//! through [`EngineUi`], which the CLI implements over stdin/stdout and the
//! GUI will implement over wx dialogs (marshalled across the cxx bridge).

use std::collections::BTreeMap;
use std::path::PathBuf;

use anyhow::{bail, Context as _, Result};

use crate::archive;
use crate::context::{resolve_steps, InstallContext};
use crate::jsonedit;
use crate::release::sha256_bytes;
use crate::track::{remove_tracked_files, InstalledState, StateStore};
use crate::types::{Kind, ProjectManifest, Step};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RetryChoice {
    Retry,
    Skip,
    Cancel,
}

/// The engine's only channel to a human. Implementations decide how to
/// render each call (terminal lines, wx dialogs, ...).
pub trait EngineUi {
    fn log(&mut self, message: &str);
    fn progress(&mut self, percent: u32);
    fn confirm(&mut self, message: &str) -> bool;
    fn retry_skip_cancel(&mut self, message: &str) -> RetryChoice;
    /// `id` is the pick-directory step's variable id, letting frontends
    /// pre-supply answers (CLI --dir flags, GUI test drivers).
    fn pick_directory(&mut self, id: &str, prompt: &str, suggest: Option<&str>) -> Option<PathBuf>;
    /// Put `text` on the clipboard; false when the frontend has none.
    fn copy_to_clipboard(&mut self, _text: &str) -> bool {
        false
    }
}

/// Everything install() needs, resolved by the caller (CLI or GUI):
/// which steps to run, the artifact bytes, and the expected hash.
pub struct InstallPlan<'a> {
    pub manifest: &'a ProjectManifest,
    pub game_id: String,
    pub version: String,
    pub channel: String,
    pub install_steps: &'a [Step],
    pub uninstall_steps: &'a [Step],
    pub user_data_decl: &'a [String],
    pub artifact: &'a [u8],
    /// The primary artifact's `id`, when it has one, so steps can name it.
    pub artifact_id: Option<&'a str>,
    /// SHA-256 the artifact must match; None only for local/dev sources.
    pub expected_sha256: Option<&'a str>,
    /// Further release artifacts that matched this context and carry an
    /// `id`, for `extract-archive` steps naming them (SPEC 13).
    pub extra_artifacts: &'a [NamedArtifact],
    /// Tool semantics: keep existing untracked destination files (keep-newer).
    pub keep_existing: bool,
    /// When this is a dependency install, the id of the package needing it.
    pub dependent_of: Option<String>,
    /// Settings schema to freeze into state (and initialize on first install).
    pub settings: Option<&'a crate::types::Settings>,
    /// Actions to freeze into state.
    pub actions: &'a [crate::types::Action],
    /// Launch steps to freeze into state.
    pub launch: &'a [Step],
    /// Branch-zipball installs: strip the archive's single top-level folder
    /// before route matching (SPEC §8).
    pub strip_top_level: bool,
}

/// A downloaded, hash-checked secondary artifact addressed by id.
pub struct NamedArtifact {
    pub id: String,
    pub data: Vec<u8>,
    pub expected_sha256: String,
}

/// The artifacts one step list can extract from: the primary (unnamed
/// `extract-archive`) plus any named extras.
#[derive(Default)]
pub struct Artifacts<'a> {
    pub primary: Option<&'a [u8]>,
    pub named: BTreeMap<&'a str, &'a [u8]>,
}

impl<'a> Artifacts<'a> {
    fn get(&self, id: Option<&str>) -> Result<&'a [u8]> {
        match id {
            None => self.primary.context("extract-archive step but no artifact available"),
            Some(id) => self
                .named
                .get(id)
                .copied()
                .with_context(|| format!("extract-archive names artifact \"{id}\", which this release did not provide for this platform")),
        }
    }
}

pub fn install(
    store: &StateStore,
    ctx: &mut InstallContext,
    plan: &InstallPlan,
    ui: &mut dyn EngineUi,
) -> Result<InstalledState> {
    // 1. Verify the artifact before anything touches disk.
    if let Some(expected) = plan.expected_sha256 {
        let actual = sha256_bytes(plan.artifact);
        if !actual.eq_ignore_ascii_case(expected) {
            bail!(
                "artifact hash mismatch for {}: expected {expected}, got {actual}. \
                 Refusing to install.",
                plan.manifest.id
            );
        }
        ui.log("Artifact hash verified.");
    } else {
        ui.log("No hash to verify for this source (local or development install).");
    }
    for extra in plan.extra_artifacts {
        let actual = sha256_bytes(&extra.data);
        if !actual.eq_ignore_ascii_case(&extra.expected_sha256) {
            bail!(
                "artifact hash mismatch for {} ({}): expected {}, got {actual}. \
                 Refusing to install.",
                plan.manifest.id, extra.id, extra.expected_sha256
            );
        }
    }
    let mut artifacts = Artifacts {
        primary: Some(plan.artifact),
        named: plan.extra_artifacts.iter().map(|a| (a.id.as_str(), a.data.as_slice())).collect(),
    };
    if let Some(id) = plan.artifact_id {
        artifacts.named.insert(id, plan.artifact);
    }

    // 2. An older version's tracked files go first, so updates never leave
    //    stale files behind.
    let prior = store.load(&plan.game_id, &plan.manifest.id, &ctx.game_dir)?;
    let prior_dependents = prior.as_ref().map(|p| p.dependents.clone()).unwrap_or_default();
    if let Some(prior) = &prior {
        refuse_links_over(&prior.files, &prior.roots)?;
        ui.log(&format!(
            "Removing previously installed version {} ({} file(s)).",
            prior.version,
            prior.files.len()
        ));
        let errors = remove_tracked_files(&prior.files, &roots_of(ctx));
        for e in &errors {
            ui.log(&format!("Warning: {e}"));
        }
        store.remove(&plan.game_id, &plan.manifest.id, &ctx.game_dir)?;
    }

    // 3. Run the steps, tracking every write; roll back on failure.
    let mut written: Vec<PathBuf> = Vec::new();
    let run = run_steps_inner(
        ctx,
        plan.install_steps,
        &artifacts,
        plan.keep_existing,
        plan.strip_top_level,
        &mut written,
        ui,
    );
    if let Err(e) = run {
        ui.log("Install failed; removing files written so far.");
        let _ = remove_tracked_files(&written, &roots_of(ctx));
        return Err(e);
    }

    // 3b. Settings: freeze the schema; on a fresh install (or a missing
    //     storage file) materialize values, prompting for promptOnInstall
    //     booleans. An existing file is the user's — leave it alone.
    let settings_file = match plan.settings {
        Some(settings) => {
            let path = ctx.resolve_path(&settings.storage.file)?;
            if !path.exists() {
                initialize_settings(ctx, settings, prior.is_none(), &path, ui)?;
            }
            Some(path)
        }
        None => None,
    };

    // 4. Record state, with uninstall data pre-resolved so removal never
    //    needs manifests or token resolution again.
    let state = InstalledState {
        id: plan.manifest.id.clone(),
        kind: match plan.manifest.kind {
            Kind::Tool => "tool",
            Kind::Library => "library",
            _ => "mod",
        }
        .to_string(),
        version: plan.version.clone(),
        channel: plan.channel.clone(),
        game: plan.game_id.clone(),
        files: written,
        uninstall_steps: resolve_steps(ctx, plan.uninstall_steps)?,
        user_data_paths: plan
            .user_data_decl
            .iter()
            .map(|raw| ctx.resolve_path(raw))
            .collect::<Result<Vec<_>>>()?,
        dependencies: plan.manifest.dependencies.iter().map(|d| d.id.clone()).collect(),
        dependents: match &plan.dependent_of {
            Some(d) => {
                let mut deps = prior_dependents;
                if !deps.contains(d) {
                    deps.push(d.clone());
                }
                deps
            }
            None => prior_dependents,
        },
        roots: roots_of(ctx),
        game_dir: ctx.game_dir.clone(),
        user_data: ctx.user_data.clone(),
        distribution: ctx.distribution.clone(),
        game_paths: ctx.game_paths.clone(),
        settings: plan.settings.cloned(),
        settings_file,
        actions: plan.actions.to_vec(),
        launch: plan.launch.to_vec(),
        steam_app_id: ctx.steam_app_id.clone(),
    };
    store.save(&state)?;
    Ok(state)
}

/// Write the settings storage file from schema defaults, asking the user the
/// promptOnInstall booleans on a fresh install. Non-boolean prompts fall back
/// to their defaults with a note (the settings command changes them later).
fn initialize_settings(
    ctx: &InstallContext,
    settings: &crate::types::Settings,
    fresh: bool,
    path: &PathBuf,
    ui: &mut dyn EngineUi,
) -> Result<()> {
    use crate::types::SettingType;
    let mut values = serde_json::Map::new();
    for entry in &settings.entries {
        let mut value = entry.default.clone().unwrap_or(serde_json::Value::Null);
        if fresh && entry.prompt_on_install {
            if entry.entry_type == SettingType::Boolean {
                let mut message = entry.label.clone();
                if let Some(desc) = &entry.description {
                    message.push_str("\n");
                    message.push_str(desc);
                }
                value = serde_json::Value::Bool(ui.confirm(&message));
            } else {
                ui.log(&format!(
                    "Setting \"{}\" starts at its default; change it later with the settings command.",
                    entry.label
                ));
            }
        }
        values.insert(entry.id.clone(), value);
    }
    ctx.check_write_allowed(path)?;
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(path, serde_json::to_string_pretty(&serde_json::Value::Object(values))?)
        .with_context(|| format!("failed to write {}", path.display()))?;
    ui.log(&format!("Wrote settings to {}.", path.display()));
    Ok(())
}

/// Rebuild an install context from recorded state (offline; no manifests).
pub fn context_from_state(state: &InstalledState) -> InstallContext {
    InstallContext {
        platform: crate::context::current_platform().to_string(),
        arch: crate::context::current_arch().to_string(),
        distribution: state.distribution.clone(),
        game_dir: state.game_dir.clone(),
        user_data: state.user_data.clone(),
        game_paths: state.game_paths.clone(),
        vars: Default::default(),
        steam_app_id: state.steam_app_id.clone(),
    }
}

/// Run one of the package's declared actions, tracking any files it writes.
pub fn run_action(
    store: &StateStore,
    state: &InstalledState,
    action_id: &str,
    ui: &mut dyn EngineUi,
) -> Result<()> {
    let action = state
        .actions
        .iter()
        .find(|a| a.id == action_id)
        .with_context(|| {
            let available: Vec<&str> = state.actions.iter().map(|a| a.id.as_str()).collect();
            format!(
                "\"{action_id}\" is not an action of {} (available: {})",
                state.id,
                if available.is_empty() { "none".to_string() } else { available.join(", ") }
            )
        })?;
    let mut ctx = context_from_state(state);
    if let Some(cond) = &action.enabled_when {
        if !ctx.condition_matches(cond)? {
            bail!(
                "\"{}\" is not available right now (its precondition doesn't hold)",
                action.label
            );
        }
    }
    ui.log(&format!("Running \"{}\"...", action.label));
    let mut written = Vec::new();
    let result = run_steps(&mut ctx, &action.steps, &Artifacts::default(), false, &mut written, ui);
    if !written.is_empty() {
        let mut updated = state.clone();
        updated.files.extend(written);
        store.save(&updated)?;
    }
    result?;
    ui.log(&format!("\"{}\" finished.", action.label));
    Ok(())
}

/// Start the game with this package loaded, using the launch steps frozen
/// at install time (SPEC 5). Launch steps write nothing; anything they do
/// write is still tracked so uninstall stays complete.
pub fn launch(store: &StateStore, state: &InstalledState, ui: &mut dyn EngineUi) -> Result<()> {
    if state.launch.is_empty() {
        bail!("{} declares no launch steps for this platform", state.id);
    }
    let mut ctx = context_from_state(state);
    let mut written = Vec::new();
    let result = run_steps(&mut ctx, &state.launch, &Artifacts::default(), false, &mut written, ui);
    if !written.is_empty() {
        let mut updated = state.clone();
        updated.files.extend(written);
        store.save(&updated)?;
    }
    result
}

/// Refuse to delete tracked files that now sit behind a symlink or junction:
/// a deploy-script link means those "files" are really a developer's working
/// copy.
fn refuse_links_over(files: &[PathBuf], roots: &[PathBuf]) -> Result<()> {
    let mut parents: Vec<&std::path::Path> = files.iter().filter_map(|f| f.parent()).collect();
    parents.sort();
    parents.dedup();
    for parent in parents {
        if let Some(link) = crate::context::find_link_ancestor(parent, roots) {
            bail!(
                "{} is a link into a development checkout; refusing to modify or \
                 remove files through it. Remove the link first if you really \
                 want a managed install here.",
                link.display()
            );
        }
    }
    Ok(())
}

fn roots_of(ctx: &InstallContext) -> Vec<PathBuf> {
    let mut roots = vec![ctx.game_dir.clone(), ctx.user_data.clone()];
    roots.extend(ctx.game_paths.values().cloned());
    roots
}

/// Execute one step list. `artifact` feeds extract-archive; `written`
/// accumulates every file created.
pub fn run_steps(
    ctx: &mut InstallContext,
    steps: &[Step],
    artifacts: &Artifacts,
    keep_existing: bool,
    written: &mut Vec<PathBuf>,
    ui: &mut dyn EngineUi,
) -> Result<()> {
    run_steps_inner(ctx, steps, artifacts, keep_existing, false, written, ui)
}

fn run_steps_inner(
    ctx: &mut InstallContext,
    steps: &[Step],
    artifacts: &Artifacts,
    keep_existing: bool,
    strip_top_level: bool,
    written: &mut Vec<PathBuf>,
    ui: &mut dyn EngineUi,
) -> Result<()> {
    'steps: for step in steps {
        // Conditional skip.
        if let Some(cond) = &step.common().when {
            if !ctx.condition_matches(cond)? {
                continue;
            }
        }
        // Retryable precondition.
        if let Some(req) = &step.common().requires {
            loop {
                if ctx.condition_matches(&req.condition)? {
                    break;
                }
                let message = req.on_missing.clone().unwrap_or_else(|| {
                    match &req.condition.file_exists {
                        Some(path) => format!("Required file not found: {path}"),
                        None => format!("A requirement of step {} is not met.", step.name()),
                    }
                });
                if !req.retryable {
                    bail!("{message}");
                }
                match ui.retry_skip_cancel(&message) {
                    RetryChoice::Retry => continue,
                    RetryChoice::Skip => {
                        ui.log(&format!("Skipped step {}.", step.name()));
                        continue 'steps;
                    }
                    RetryChoice::Cancel => bail!("cancelled at step {}", step.name()),
                }
            }
        }

        match step {
            Step::ExtractArchive { routes, artifact, .. } => {
                let data = artifacts.get(artifact.as_deref())?;
                ui.log("Extracting files...");
                let outcome =
                    archive::extract_routed(ctx, data, routes, keep_existing, strip_top_level)?;
                ui.log(&format!("Placed {} file(s).", outcome.written.len()));
                for kept in &outcome.kept_existing {
                    ui.log(&format!(
                        "Kept existing {} (not overwritten; it may be newer).",
                        kept.display()
                    ));
                }
                written.extend(outcome.written);
            }
            Step::CopyFiles { from, to, .. } => {
                let sources = ctx.glob_matches(from)?;
                if sources.is_empty() {
                    bail!("copy-files: nothing matches {from}");
                }
                let wildcard = from.contains('*') || from.contains('?');
                for src in sources {
                    let dest = if wildcard {
                        let dir = ctx.resolve_path(to)?;
                        dir.join(src.file_name().context("source has no file name")?)
                    } else {
                        ctx.resolve_path(to)?
                    };
                    ctx.check_write_allowed(&dest)?;
                    if let Some(parent) = dest.parent() {
                        std::fs::create_dir_all(parent)?;
                    }
                    std::fs::copy(&src, &dest).with_context(|| {
                        format!("failed to copy {} to {}", src.display(), dest.display())
                    })?;
                    written.push(dest);
                }
            }
            Step::EnsureDirs { paths, .. } => {
                for raw in paths {
                    let dir = ctx.resolve_path(raw)?;
                    ctx.check_write_allowed(&dir)?;
                    std::fs::create_dir_all(&dir)
                        .with_context(|| format!("failed to create {}", dir.display()))?;
                }
            }
            Step::EditJson { file, create_if_missing, ops, .. } => {
                let matches = ctx.glob_matches(file)?;
                if matches.is_empty() {
                    let has_wildcard = file.contains('*') || file.contains('?');
                    if *create_if_missing && !has_wildcard {
                        let path = ctx.resolve_path(file)?;
                        ctx.check_write_allowed(&path)?;
                        jsonedit::apply_ops(&path, true, ops)?;
                        ui.log(&format!("Created and updated {}.", path.display()));
                    } else {
                        bail!("edit-json: no file matches {file}");
                    }
                } else {
                    for path in matches {
                        ctx.check_write_allowed(&path)?;
                        jsonedit::apply_ops(&path, *create_if_missing, ops)?;
                        ui.log(&format!("Updated {}.", path.display()));
                    }
                }
            }
            Step::DeleteFiles { paths, .. } => {
                let mut files = Vec::new();
                let mut dirs = Vec::new();
                for raw in paths {
                    for path in ctx.glob_matches(raw)? {
                        if path.is_file() {
                            files.push(path);
                        } else if path.is_dir() {
                            dirs.push(path);
                        }
                    }
                }
                let roots = roots_of(ctx);
                for e in remove_tracked_files(&files, &roots) {
                    ui.log(&format!("Warning: {e}"));
                }
                // A matched directory goes too once it is empty (a loader's
                // bare folder an archive created but no file filled).
                crate::track::prune_empty_dirs(dirs, &roots);
            }
            Step::PickDirectory { id, prompt, suggest, .. } => {
                match ui.pick_directory(id, prompt, suggest.as_deref()) {
                    Some(dir) => {
                        ctx.vars.insert(id.clone(), dir);
                    }
                    None => bail!("cancelled: no directory chosen for \"{prompt}\""),
                }
            }
            Step::Expect { checks, .. } => {
                for check in checks {
                    if !ctx.condition_matches(&check.condition)? {
                        bail!("{}", check.message);
                    }
                }
            }
            Step::Notice { message, clipboard, .. } => {
                // Informational only: a follow-up the user has to do by hand
                // (set Steam launch options, restart the game). It lands in
                // the activity log, which every frontend reads out.
                ui.log(&ctx.substitute(message)?);
                if let Some(text) = clipboard {
                    let text = ctx.substitute(text)?;
                    // Without a clipboard the text still reaches the log, so
                    // the user can copy it by hand.
                    if ui.copy_to_clipboard(&text) {
                        ui.log(&format!("Copied to the clipboard: {text}"));
                    } else {
                        ui.log(&text);
                    }
                }
            }
            Step::MergeUniversalBinary { inputs, output, .. } => {
                let mut blobs = Vec::with_capacity(inputs.len());
                let mut input_paths = Vec::with_capacity(inputs.len());
                for raw in inputs {
                    let path = ctx.resolve_path(raw)?;
                    blobs.push(std::fs::read(&path).with_context(|| {
                        format!("merge-universal-binary: cannot read {}", path.display())
                    })?);
                    input_paths.push(path);
                }
                let dest = ctx.resolve_path(output)?;
                ctx.check_write_allowed(&dest)?;
                let fat = crate::macho::merge(&blobs)?;
                // The thin inputs were only ever intermediates: drop them
                // and their tracking either way.
                for p in &input_paths {
                    let _ = std::fs::remove_file(p);
                    written.retain(|w| w != p);
                }
                // A tool's keep-newer policy applies to the merged output
                // exactly as it does to an extracted file: an untracked
                // copy already in place (another manager's, or newer) is
                // left alone.
                if keep_existing && dest.exists() && !written.contains(&dest) {
                    ui.log(&format!(
                        "Kept existing {} (not overwritten; it may be newer).",
                        dest.display()
                    ));
                } else {
                    std::fs::write(&dest, &fat)
                        .with_context(|| format!("failed to write {}", dest.display()))?;
                    written.push(dest.clone());
                    ui.log(&format!(
                        "Combined {} architectures into {}.",
                        inputs.len(),
                        dest.file_name().unwrap_or_default().to_string_lossy()
                    ));
                }
            }
            Step::Run { program, args, cwd, env, .. } => {
                let exe = ctx.resolve_path(program)?;
                ctx.check_run_allowed(&exe)?;
                if !exe.is_file() {
                    bail!("cannot launch: {} is missing", exe.display());
                }
                let mut cmd = std::process::Command::new(&exe);
                for a in args {
                    cmd.arg(ctx.substitute(a)?);
                }
                cmd.current_dir(match cwd {
                    Some(c) => ctx.resolve_path(c)?,
                    None => exe.parent().map(|p| p.to_path_buf()).unwrap_or_default(),
                });
                for (k, v) in env {
                    cmd.env(k, ctx.substitute(v)?);
                }
                // Detached: the game outlives this process, and a manager
                // window must not hang on it.
                cmd.stdin(std::process::Stdio::null())
                    .stdout(std::process::Stdio::null())
                    .stderr(std::process::Stdio::null());
                cmd.spawn()
                    .with_context(|| format!("failed to start {}", exe.display()))?;
                ui.log(&format!("Started {}.", exe.display()));
            }
            Step::OpenUrl { url, .. } => {
                let url = ctx.substitute(url)?;
                if !is_launcher_url(&url) {
                    bail!(
                        "open-url only accepts store launcher URLs ({}); got {url}",
                        LAUNCH_URL_SCHEMES.join(", ")
                    );
                }
                open_url(&url)?;
                ui.log(&format!("Opened {url}."));
            }
        }
    }
    Ok(())
}

/// URL schemes an `open-url` step may hand to the OS: the store launchers
/// Loadstone knows as distributions (SPEC 3), so a manifest can start the
/// game through whichever store owns it and nothing else.
pub const LAUNCH_URL_SCHEMES: &[&str] = &[
    "steam://",                   // Steam: steam://rungameid/<appId>
    "com.epicgames.launcher://",  // Epic: com.epicgames.launcher://apps/<name>?action=launch&silent=true
    "goggalaxy://",               // GOG Galaxy: goggalaxy://openGameView/<productId>
    "itch://",                    // itch app: itch://library or itch://games/<id>
    "ms-xbl-",                    // Xbox app deep links (Game Pass)
];

pub fn is_launcher_url(url: &str) -> bool {
    LAUNCH_URL_SCHEMES.iter().any(|scheme| url.starts_with(scheme))
}

/// Hand a URL to the OS's default handler without a console window.
fn open_url(url: &str) -> Result<()> {
    #[cfg(target_os = "windows")]
    let mut cmd = {
        let mut c = std::process::Command::new("rundll32");
        c.args(["url.dll,FileProtocolHandler", url]);
        c
    };
    #[cfg(target_os = "macos")]
    let mut cmd = {
        let mut c = std::process::Command::new("open");
        c.arg(url);
        c
    };
    #[cfg(all(not(target_os = "windows"), not(target_os = "macos")))]
    let mut cmd = {
        let mut c = std::process::Command::new("xdg-open");
        c.arg(url);
        c
    };
    cmd.stdin(std::process::Stdio::null())
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null());
    cmd.spawn().with_context(|| format!("failed to open {url}"))?;
    Ok(())
}

/// Uninstall from recorded state alone: tracked files, then the pre-resolved
/// uninstall steps, then (optionally) the user-data purge.
pub fn uninstall(
    store: &StateStore,
    state: &InstalledState,
    purge_user_data: Option<bool>,
    ui: &mut dyn EngineUi,
) -> Result<()> {
    if state.kind == "tool" && !state.dependents.is_empty() {
        bail!(
            "{} is still needed by: {}. Uninstall those first.",
            state.id,
            state.dependents.join(", ")
        );
    }

    refuse_links_over(&state.files, &state.roots)?;
    ui.log(&format!("Removing {} file(s).", state.files.len()));
    let errors = remove_tracked_files(&state.files, &state.roots);
    for e in &errors {
        ui.log(&format!("Warning: {e}"));
    }

    if !state.uninstall_steps.is_empty() {
        // Steps were pre-resolved at install time.
        let mut ctx = context_from_state(state);
        let mut scratch = Vec::new();
        run_steps(&mut ctx, &state.uninstall_steps, &Artifacts::default(), false, &mut scratch, ui)?;
    }

    if !state.user_data_paths.is_empty() {
        let purge = match purge_user_data {
            Some(v) => v,
            None => ui.confirm("Also remove saved settings and preferences?"),
        };
        if purge {
            let mut files = Vec::new();
            for path in &state.user_data_paths {
                if path.is_file() {
                    files.push(path.clone());
                } else if path.is_dir() {
                    let _ = std::fs::remove_dir_all(path);
                }
            }
            for e in remove_tracked_files(&files, &state.roots) {
                ui.log(&format!("Warning: {e}"));
            }
            ui.log("Removed saved settings.");
        }
    }

    store.remove(&state.game, &state.id, &state.game_dir)?;
    Ok(())
}
