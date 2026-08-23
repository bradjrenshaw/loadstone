//! `loadstone install` / `uninstall` / `list` — the CLI frontend to the
//! install engine. The orchestration itself lives in `loadstone_core::ops`
//! (shared with the GUI); this module owns only argument shapes and the
//! terminal implementation of `EngineUi`.

use std::io::Write as _;
use std::path::PathBuf;

use anyhow::{Context as _, Result};

use loadstone_core::engine::{self, EngineUi, RetryChoice};
use loadstone_core::ops;
use loadstone_core::profile::Profile;
use loadstone_core::track::StateStore;

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
// install / update

pub struct InstallArgs {
    pub id: Option<String>,
    pub scopes: Vec<PathBuf>,
    pub registries: Vec<String>,
    pub profile: Profile,
    pub game_dir: Option<PathBuf>,
    pub user_data: Option<PathBuf>,
    pub state_dir: Option<PathBuf>,
    pub local_release: Option<PathBuf>,
    pub local_artifact: Option<PathBuf>,
    pub channel: String,
    pub no_deps: bool,
    pub assume_yes: bool,
    pub update_mode: bool,
}

pub fn cmd_install(args: &InstallArgs) -> Result<()> {
    let mut ui = TerminalUi::new(args.assume_yes);
    let opts = ops::InstallOptions {
        id: args.id.clone(),
        scopes: args.scopes.clone(),
        registries: args.registries.clone(),
        profile: args.profile.clone(),
        game_dir: args.game_dir.clone(),
        user_data: args.user_data.clone(),
        state_dir: args.state_dir.clone(),
        local_release: args.local_release.clone(),
        local_artifact: args.local_artifact.clone(),
        channel: args.channel.clone(),
        no_deps: args.no_deps,
        update_mode: args.update_mode,
    };
    let summary = ops::install(&opts, &mut ui)?;
    println!("{summary}");
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
    use loadstone_core::settings as core_settings;
    use loadstone_core::types::Settings;
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

    if sets.is_empty() {
        // List: one setting per line, current value first for quick reading.
        let values = core_settings::read_values(file)?;
        for entry in &settings.entries {
            let current = core_settings::effective(entry, &values)
                .map(|v| v.to_string())
                .unwrap_or_else(|| "unset".to_string());
            println!("{} = {}  ({})", entry.id, current, entry.label);
            if let Some(desc) = &entry.description {
                println!("    {desc}");
            }
        }
        return Ok(());
    }

    let mut note = None;
    for pair in sets {
        let (key, raw) = pair
            .split_once('=')
            .with_context(|| format!("--set takes id=value, got \"{pair}\""))?;
        note = core_settings::set(settings, file, key, raw)?;
        println!("{key} set.");
    }
    if let Some(note) = note {
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
    let summary = ops::uninstall(id, game, state_dir, purge, &mut ui)?;
    println!("{summary}");
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
