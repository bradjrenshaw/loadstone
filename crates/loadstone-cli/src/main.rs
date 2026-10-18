//! `loadstone` — developer CLI for the Loadstone Mod Manager package format.
//!
//! Output is deliberately plain text, one finding per line, no colors or
//! progress animations: it reads identically in a terminal and a screen reader.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

use anyhow::{bail, Context, Result};
use clap::{Parser, Subcommand};

use loadstone_core::release::{build_release_manifest, resolve_artifacts, ReleaseOptions};
use loadstone_core::types::{GameManifest, ProjectManifest};
use loadstone_core::validate::{validate_value, Severity, ValidationContext};

mod auth_cmd;
mod manage;

/// Compile-time distribution profile ("null" unless the binary was built
/// with LOADSTONE_EMBED_PROFILE=<file> — see loadstone-core::profile).
const EMBEDDED_PROFILE: &str = include_str!(concat!(env!("OUT_DIR"), "/embedded_profile.json"));

fn load_profile() -> Result<loadstone_core::profile::Profile> {
    let exe_dir = std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(std::path::Path::to_path_buf));
    let profile =
        loadstone_core::profile::Profile::load(Some(EMBEDDED_PROFILE), exe_dir.as_deref())?;
    profile.validate()?;
    // Accounts and their tokens, so downloads can reach private
    // repositories. Best effort: without it only GH_TOKEN-style
    // environment tokens apply.
    let _ = loadstone_core::secrets::init_for_profile(&profile);
    Ok(profile)
}

#[derive(Parser)]
#[command(
    name = "loadstone",
    version,
    about = "Loadstone Mod Manager developer tools"
)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Validate package files: project manifests, game packages, loadstone-release.json, links.
    Validate {
        /// Files to validate, or directories of package files.
        #[arg(required = true)]
        paths: Vec<PathBuf>,
        /// Outer-scope directories of package files (innermost first), for
        /// checking ${game.*} tokens. The file's own directory is always the
        /// innermost scope.
        #[arg(long = "scope")]
        scopes: Vec<PathBuf>,
    },
    /// Build loadstone-release.json from a project manifest and built artifacts.
    Package {
        /// Path to the project manifest. Defaults to the single mod/tool/library
        /// package file in ./loadstone-packages.
        #[arg(long)]
        manifest: Option<PathBuf>,
        /// The release version (leading "v" is fine).
        #[arg(long)]
        version: String,
        /// Built artifact file(s). Overrides the manifest's "packaging" block.
        #[arg(long = "artifact")]
        artifacts: Vec<PathBuf>,
        /// An installer/manager build shipped with this release: a Windows
        /// .exe or a macOS .app in a .zip (repeat for both). Stamps its name,
        /// hash and Loadstone version so running builds can self-update.
        #[arg(long = "installer")]
        installers: Vec<PathBuf>,
        /// Where to write the release manifest.
        #[arg(long, default_value = "loadstone-release.json")]
        out: PathBuf,
        /// Release notes text.
        #[arg(long, conflicts_with = "notes_file")]
        notes: Option<String>,
        /// Read release notes from a file.
        #[arg(long)]
        notes_file: Option<PathBuf>,
        /// Outer-scope directories of package files, for checking ${game.*} tokens.
        #[arg(long = "scope")]
        scopes: Vec<PathBuf>,
    },
    /// Install a mod (and its tool dependencies) into a game.
    Install {
        /// Package id of the mod (optional when the profile pins one).
        id: Option<String>,
        /// Local directories of package files (innermost scopes).
        #[arg(long = "scope")]
        scopes: Vec<PathBuf>,
        /// Registries to resolve from: github:owner/repo or a directory.
        /// Listed ahead of the profile's registries.
        #[arg(long = "registry")]
        registries: Vec<String>,
        /// Game folder; skips auto-detection.
        #[arg(long)]
        game_dir: Option<PathBuf>,
        /// Override the game's user-data folder (mainly for testing).
        #[arg(long)]
        user_data: Option<PathBuf>,
        /// Override the installed-state directory (mainly for testing).
        #[arg(long)]
        state_dir: Option<PathBuf>,
        /// Install from a local loadstone-release.json instead of fetching from GitHub.
        #[arg(long)]
        local_release: Option<PathBuf>,
        /// Artifact file for --local-release (default: named file next to it).
        #[arg(long, requires = "local_release")]
        local_artifact: Option<PathBuf>,
        /// Channel: "stable" (releases) or a branch channel the mod declares
        /// (development builds from that branch's tip, not hash-pinned).
        #[arg(long, default_value = "stable")]
        channel: String,
        /// Install a specific release by tag (uses that release's own
        /// loadstone-release.json and assets).
        #[arg(long)]
        tag: Option<String>,
        /// Skip dependency installation.
        #[arg(long)]
        no_deps: bool,
        /// Answer prompts automatically (confirms yes, skips retryable steps).
        #[arg(long)]
        yes: bool,
    },
    /// Update an installed mod to the latest version on its channel.
    Update {
        /// Package id (optional when the profile pins one).
        id: Option<String>,
        #[arg(long = "scope")]
        scopes: Vec<PathBuf>,
        #[arg(long = "registry")]
        registries: Vec<String>,
        #[arg(long)]
        game_dir: Option<PathBuf>,
        #[arg(long)]
        user_data: Option<PathBuf>,
        #[arg(long)]
        state_dir: Option<PathBuf>,
        #[arg(long, default_value = "stable")]
        channel: String,
        /// Update to a specific release by tag instead of the latest.
        #[arg(long)]
        tag: Option<String>,
        #[arg(long)]
        yes: bool,
    },
    /// Show or change an installed mod's settings.
    Settings {
        /// Package id.
        id: String,
        /// Game id the package is installed for.
        #[arg(long)]
        game: String,
        /// Which copy of the game (needed when the mod is installed for
        /// more than one).
        #[arg(long)]
        game_dir: Option<PathBuf>,
        #[arg(long)]
        state_dir: Option<PathBuf>,
        /// Change a setting: --set id=value (repeatable). Without it, lists all.
        #[arg(long = "set")]
        sets: Vec<String>,
    },
    /// Run one of an installed mod's actions.
    Action {
        /// Package id.
        id: String,
        /// Action id (as declared in the manifest).
        action: String,
        /// Game id the package is installed for.
        #[arg(long)]
        game: String,
        /// Which copy of the game (needed when the mod is installed for
        /// more than one).
        #[arg(long)]
        game_dir: Option<PathBuf>,
        #[arg(long)]
        state_dir: Option<PathBuf>,
        /// Pre-answer a pick-directory step: --dir id=path (repeatable).
        #[arg(long = "dir")]
        dirs: Vec<String>,
        #[arg(long)]
        yes: bool,
    },
    /// Start the game with an installed mod loaded (its declared launch steps).
    Launch {
        /// Package id.
        id: String,
        /// Game id the package is installed for.
        #[arg(long)]
        game: String,
        /// Which copy of the game (needed when the mod is installed for
        /// more than one).
        #[arg(long)]
        game_dir: Option<PathBuf>,
        #[arg(long)]
        state_dir: Option<PathBuf>,
    },
    /// Uninstall a previously installed package.
    Uninstall {
        /// Package id.
        id: String,
        /// Game id the package was installed for.
        #[arg(long)]
        game: String,
        /// Which copy of the game (needed when the mod is installed for
        /// more than one).
        #[arg(long)]
        game_dir: Option<PathBuf>,
        /// Override the installed-state directory (mainly for testing).
        #[arg(long)]
        state_dir: Option<PathBuf>,
        /// Also remove saved settings/preferences without asking.
        #[arg(long, conflicts_with = "keep_settings")]
        purge: bool,
        /// Keep saved settings/preferences without asking.
        #[arg(long)]
        keep_settings: bool,
        /// Answer prompts automatically.
        #[arg(long)]
        yes: bool,
    },
    /// Manage accounts used to download from private repositories.
    Auth {
        #[command(subcommand)]
        command: auth_cmd::AuthCommand,
    },
    /// List installed packages per game.
    List {
        /// Override the installed-state directory (mainly for testing).
        #[arg(long)]
        state_dir: Option<PathBuf>,
    },
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    let result = match cli.command {
        Command::Validate { paths, scopes } => cmd_validate(&paths, &scopes),
        Command::Package { manifest, version, artifacts, installers, out, notes, notes_file, scopes } => {
            cmd_package(
                manifest.as_deref(), &version, &artifacts, installers, &out, notes, notes_file,
                &scopes,
            )
        }
        Command::Install {
            id, scopes, registries, game_dir, user_data, state_dir, local_release, local_artifact,
            channel, tag, no_deps, yes,
        } => load_profile().and_then(|profile| {
            manage::cmd_install(&manage::InstallArgs {
                id,
                scopes,
                registries,
                profile,
                game_dir,
                user_data,
                state_dir,
                local_release,
                local_artifact,
                channel,
                tag,
                no_deps,
                assume_yes: yes,
                update_mode: false,
            })
            .map(|()| true)
        }),
        Command::Update {
            id, scopes, registries, game_dir, user_data, state_dir, channel, tag, yes,
        } => {
            load_profile().and_then(|profile| {
                manage::cmd_install(&manage::InstallArgs {
                    id,
                    scopes,
                    registries,
                    profile,
                    game_dir,
                    user_data,
                    state_dir,
                    local_release: None,
                    local_artifact: None,
                    channel,
                    tag,
                    no_deps: false,
                    assume_yes: yes,
                    update_mode: true,
                })
                .map(|()| true)
            })
        }
        Command::Settings { id, game, game_dir, state_dir, sets } => {
            manage::cmd_settings(&id, &game, game_dir, state_dir, &sets).map(|()| true)
        }
        Command::Action { id, action, game, game_dir, state_dir, dirs, yes } => {
            manage::cmd_action(&id, &action, &game, game_dir, state_dir, &dirs, yes).map(|()| true)
        }
        Command::Launch { id, game, game_dir, state_dir } => {
            manage::cmd_launch(&id, &game, game_dir, state_dir).map(|()| true)
        }
        Command::Uninstall { id, game, game_dir, state_dir, purge, keep_settings, yes } => {
            let purge_choice = if purge {
                Some(true)
            } else if keep_settings {
                Some(false)
            } else {
                None
            };
            manage::cmd_uninstall(&id, &game, game_dir, state_dir, purge_choice, yes).map(|()| true)
        }
        Command::List { state_dir } => manage::cmd_list(state_dir).map(|()| true),
        Command::Auth { command } => auth_cmd::run(command).map(|()| true),
    };
    match result {
        Ok(ok) => {
            if ok {
                ExitCode::SUCCESS
            } else {
                ExitCode::FAILURE
            }
        }
        Err(e) => {
            eprintln!("error: {e:#}");
            ExitCode::FAILURE
        }
    }
}

pub(crate) fn load_json(path: &Path) -> Result<serde_json::Value> {
    let text = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read {}", path.display()))?;
    // Tolerate a UTF-8 BOM, as the spec requires of clients.
    serde_json::from_str(text.trim_start_matches('\u{feff}'))
        .with_context(|| format!("{} is not valid JSON", path.display()))
}

/// Collect the game packages (`"kind": "game"`) from a directory of package
/// files; non-game files are skipped silently.
fn games_in_dir(dir: &Path) -> Result<Vec<GameManifest>> {
    let mut games = Vec::new();
    let entries = std::fs::read_dir(dir)
        .with_context(|| format!("failed to read scope directory {}", dir.display()))?;
    for entry in entries {
        let path = entry?.path();
        if path.extension().and_then(|e| e.to_str()) != Some("json") {
            continue;
        }
        let doc = load_json(&path)?;
        if doc.get("kind").and_then(serde_json::Value::as_str) != Some("game") {
            continue;
        }
        let game: GameManifest = serde_json::from_value(doc)
            .with_context(|| format!("{} is not a valid game package", path.display()))?;
        games.push(game);
    }
    Ok(games)
}

/// Build the scope chain for a file: its own directory (innermost), then the
/// given outer scopes in order. Innermost wins on id collisions.
fn build_context(innermost: Option<&Path>, scopes: &[PathBuf]) -> Result<ValidationContext> {
    let mut games: BTreeMap<String, GameManifest> = BTreeMap::new();
    let mut dirs: Vec<&Path> = Vec::new();
    if let Some(dir) = innermost {
        dirs.push(dir);
    }
    dirs.extend(scopes.iter().map(PathBuf::as_path));
    // Insert outermost first so inner scopes overwrite.
    for dir in dirs.iter().rev() {
        if dir.is_dir() {
            for game in games_in_dir(dir)? {
                games.insert(game.id.clone(), game);
            }
        }
    }
    Ok(ValidationContext { games })
}

/// Validate one document, printing findings. Returns (errors, warnings).
fn report(label: &str, doc: &serde_json::Value, ctx: &ValidationContext) -> (usize, usize) {
    let result = validate_value(doc, ctx);
    let mut errors = 0;
    let mut warnings = 0;
    for d in &result.diagnostics {
        let severity = match d.severity {
            Severity::Error => {
                errors += 1;
                "error"
            }
            Severity::Warning => {
                warnings += 1;
                "warning"
            }
        };
        if d.location.is_empty() {
            println!("{label}: {severity}: {}", d.message);
        } else {
            println!("{label}: {severity} at {}: {}", d.location, d.message);
        }
    }
    (errors, warnings)
}

fn cmd_validate(paths: &[PathBuf], scopes: &[PathBuf]) -> Result<bool> {
    // Directories expand to the package files inside them.
    let mut files: Vec<PathBuf> = Vec::new();
    for path in paths {
        if path.is_dir() {
            let mut in_dir: Vec<PathBuf> = std::fs::read_dir(path)
                .with_context(|| format!("failed to read {}", path.display()))?
                .filter_map(|e| e.ok())
                .map(|e| e.path())
                .filter(|p| p.extension().and_then(|e| e.to_str()) == Some("json"))
                .collect();
            in_dir.sort();
            files.extend(in_dir);
        } else {
            files.push(path.clone());
        }
    }

    let mut total_errors = 0;
    let mut total_warnings = 0;
    for path in &files {
        let label = path.display().to_string();
        let doc = load_json(path)?;
        let form = loadstone_core::validate::detect_form(&doc);
        let ctx = build_context(path.parent(), scopes)?;
        let (errors, warnings) = report(&label, &doc, &ctx);
        total_errors += errors;
        total_warnings += warnings;
        if errors == 0 {
            println!("{label}: OK ({form:?}, {warnings} warning(s))");
        }
    }
    println!(
        "Checked {} file(s): {} error(s), {} warning(s).",
        files.len(),
        total_errors,
        total_warnings
    );
    Ok(total_errors == 0)
}

/// Find the project manifest when --manifest is not given: the single
/// mod/tool/library package file in ./loadstone-packages.
fn discover_manifest() -> Result<PathBuf> {
    let dir = Path::new("loadstone-packages");
    if !dir.is_dir() {
        bail!("no loadstone-packages directory here; pass --manifest");
    }
    let mut candidates = Vec::new();
    for entry in std::fs::read_dir(dir)? {
        let path = entry?.path();
        if path.extension().and_then(|e| e.to_str()) != Some("json") {
            continue;
        }
        let doc = load_json(&path)?;
        let kind = doc.get("kind").and_then(serde_json::Value::as_str).unwrap_or("mod");
        if matches!(kind, "mod" | "tool" | "library") {
            candidates.push(path);
        }
    }
    match candidates.len() {
        0 => bail!("no project manifest found in loadstone-packages; pass --manifest"),
        1 => Ok(candidates.remove(0)),
        _ => bail!(
            "multiple project manifests in loadstone-packages ({}); pass --manifest",
            candidates
                .iter()
                .map(|p| p.display().to_string())
                .collect::<Vec<_>>()
                .join(", ")
        ),
    }
}

#[allow(clippy::too_many_arguments)]
fn cmd_package(
    manifest_arg: Option<&Path>,
    version: &str,
    artifact_paths: &[PathBuf],
    installers: Vec<PathBuf>,
    out: &Path,
    notes: Option<String>,
    notes_file: Option<PathBuf>,
    scopes: &[PathBuf],
) -> Result<bool> {
    let manifest_path = match manifest_arg {
        Some(p) => p.to_path_buf(),
        None => discover_manifest()?,
    };
    let manifest_path = manifest_path.as_path();
    let doc = load_json(manifest_path)?;

    // Refuse to package a manifest that doesn't validate.
    let ctx = build_context(manifest_path.parent(), scopes)?;
    let label = manifest_path.display().to_string();
    let (errors, _) = report(&label, &doc, &ctx);
    if errors > 0 {
        bail!("{} has {} validation error(s); fix them before packaging", label, errors);
    }

    let project: ProjectManifest = serde_json::from_value(doc)
        .with_context(|| format!("{} is not a project manifest", label))?;

    let manifest_dir = manifest_path.parent().unwrap_or(Path::new("."));
    let artifacts = resolve_artifacts(&project, manifest_dir, artifact_paths);
    for artifact in &artifacts {
        if !artifact.path.is_file() {
            bail!("artifact not found: {}", artifact.path.display());
        }
    }

    let release_notes = match (notes, notes_file) {
        (Some(text), _) => Some(text),
        (None, Some(file)) => Some(
            std::fs::read_to_string(&file)
                .with_context(|| format!("failed to read {}", file.display()))?
                .trim_end()
                .to_string(),
        ),
        (None, None) => None,
    };

    for path in &installers {
        if !path.is_file() {
            bail!("installer not found: {}", path.display());
        }
    }
    let release = build_release_manifest(
        &project,
        &ReleaseOptions { version: version.to_string(), artifacts, release_notes, installers },
    )?;

    let json = serde_json::to_string_pretty(&release)?;
    std::fs::write(out, json.as_bytes() )
        .with_context(|| format!("failed to write {}", out.display()))?;

    println!("Wrote {} for {} version {}.", out.display(), release.id, release.version);
    for artifact in &release.artifacts {
        println!("  {}  sha256 {}", artifact.file, artifact.sha256);
    }
    for info in &release.installers {
        println!(
            "  {}  sha256 {}  ({} installer, Loadstone {})",
            info.file,
            info.sha256,
            info.platform(),
            info.loadstone_version
        );
    }
    println!("Attach {} and the artifact(s) above to the GitHub release.", out.display());
    Ok(true)
}
