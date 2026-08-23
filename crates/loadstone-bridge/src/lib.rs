//! The C++ boundary (SPEC-adjacent: the GUI backend). Coarse and
//! message-shaped by design: the GUI asks for whole page models and receives
//! plain shared structs; all parsing, network, and filesystem work stays in
//! Rust. The blocking fetch functions are called from GUI worker threads.
//!
//! Errors cross the bridge as C++ exceptions (`rust::Error`); the GUI shows
//! their message text.

use anyhow::{Context as _, Result};
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

use loadstone_core::profile::{Profile, ProfileMode};
use loadstone_core::registry::{HttpFetcher, ResolvedPackage, Resolver};
use loadstone_core::settings as core_settings;
use loadstone_core::track::{InstalledState, StateStore};
use loadstone_core::types::SettingType;

use crate::ffi::{
    ActionItem, Catalog, CatalogEntry, ChoiceItem, ModPage, SettingItem, UiProfile,
};

#[cxx::bridge(namespace = "loadstone")]
mod ffi {
    /// The resolved distribution profile, flattened for widget code.
    struct UiProfile {
        /// "manager" or "single-mod".
        mode: String,
        title: String,
        /// single-mod: the pinned package id (empty in manager mode).
        mod_id: String,
        lock_registries: bool,
        registries: Vec<String>,
    }

    struct CatalogEntry {
        id: String,
        name: String,
        /// First line of the description, for the list.
        summary: String,
        game: String,
        /// Empty when not installed.
        installed_version: String,
        /// Display text: "Not installed", "Installed 1.0.9", ...
        status: String,
    }

    struct Catalog {
        entries: Vec<CatalogEntry>,
        /// Warnings worth showing (cache fallbacks, unreachable registries).
        notes: Vec<String>,
    }

    struct ChoiceItem {
        value: String,
        label: String,
    }

    struct SettingItem {
        id: String,
        label: String,
        description: String,
        /// "boolean" | "string" | "number" | "choice".
        kind: String,
        /// Current effective value as text ("true", "1.5", "jaws"; "" unset).
        value: String,
        /// choice only.
        options: Vec<ChoiceItem>,
    }

    struct ActionItem {
        id: String,
        label: String,
        description: String,
    }

    struct ModPage {
        id: String,
        name: String,
        description: String,
        authors: String,
        game: String,
        /// Empty when not installed.
        installed_version: String,
        /// The game the install is recorded under (for settings calls).
        installed_game: String,
        channel: String,
        /// Empty when unknown (no release manifest reachable).
        latest_version: String,
        /// One-line summary for the top of the page.
        status: String,
        can_install: bool,
        can_update: bool,
        can_uninstall: bool,
        /// Settings are editable (installed, storage file known).
        settings_editable: bool,
        /// Schema note shown with the settings group (e.g. restart hint).
        settings_note: String,
        settings: Vec<SettingItem>,
        /// Actions run only when installed.
        actions_available: bool,
        actions: Vec<ActionItem>,
        /// Informational lines for the bottom of the page.
        notes: Vec<String>,
    }

    extern "Rust" {
        /// Core library version (for the about line and smoke tests).
        fn core_version() -> String;

        /// Resolved profile as JSON (smoke tests); `embedded` is the
        /// compile-time profile JSON or "null".
        fn resolve_profile(embedded: &str) -> Result<String>;

        /// Every installed package across all games, as a JSON array of
        /// { game, id, version, channel, kind }. `state_dir` overrides the
        /// state location ("" = default), mirroring the CLI flag.
        fn installed_json(state_dir: &str) -> Result<String>;

        /// Window/product title per the resolved profile.
        fn profile_title(embedded: &str) -> Result<String>;

        /// The resolved profile as a typed struct.
        fn ui_profile(embedded: &str) -> Result<UiProfile>;

        /// The mod list for manager mode: everything visible through the
        /// profile's registries merged with installed state. Blocking
        /// (network) — call from a worker thread.
        fn fetch_catalog(embedded: &str, state_dir: &str) -> Result<Catalog>;

        /// The full page model for one mod. Blocking (network) — call from
        /// a worker thread.
        fn fetch_mod_page(embedded: &str, state_dir: &str, mod_id: &str) -> Result<ModPage>;

        /// Validate and persist one setting for an installed mod. Returns
        /// the schema's note ("" when none) for the UI to show.
        fn apply_setting(
            state_dir: &str,
            game: &str,
            mod_id: &str,
            setting_id: &str,
            raw_value: &str,
        ) -> Result<String>;
    }
}

pub fn core_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

fn exe_dir() -> Option<std::path::PathBuf> {
    std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(std::path::Path::to_path_buf))
}

fn load_profile(embedded: &str) -> Result<Profile> {
    let profile = Profile::load(Some(embedded), exe_dir().as_deref())?;
    profile.validate()?;
    Ok(profile)
}

fn open_store(state_dir: &str) -> Result<StateStore> {
    let root = if state_dir.is_empty() {
        None
    } else {
        Some(PathBuf::from(state_dir))
    };
    StateStore::open(root)
}

fn all_installed(store: &StateStore) -> Result<Vec<InstalledState>> {
    let mut out = Vec::new();
    for game in store.games()? {
        out.extend(store.list(&game)?);
    }
    Ok(out)
}

pub fn resolve_profile(embedded: &str) -> Result<String> {
    serde_json::to_string(&load_profile(embedded)?).context("profile serialization")
}

pub fn profile_title(embedded: &str) -> Result<String> {
    Ok(load_profile(embedded)?
        .title
        .unwrap_or_else(|| "Loadstone Mod Manager".to_string()))
}

pub fn ui_profile(embedded: &str) -> Result<UiProfile> {
    let p = load_profile(embedded)?;
    Ok(UiProfile {
        mode: match p.mode {
            ProfileMode::Manager => "manager".to_string(),
            ProfileMode::SingleMod => "single-mod".to_string(),
        },
        title: p
            .title
            .unwrap_or_else(|| "Loadstone Mod Manager".to_string()),
        mod_id: p.mod_id.unwrap_or_default(),
        lock_registries: p.lock_registries,
        registries: p.registries,
    })
}

pub fn installed_json(state_dir: &str) -> Result<String> {
    let store = open_store(state_dir)?;
    let mut out = Vec::new();
    for state in all_installed(&store)? {
        out.push(serde_json::json!({
            "game": state.game,
            "id": state.id,
            "version": state.version,
            "channel": state.channel,
            "kind": state.kind,
        }));
    }
    serde_json::to_string(&out).context("state serialization")
}

// ---------------------------------------------------------------------------
// Catalog and mod page models.

fn installed_status(state: &InstalledState) -> String {
    if state.channel == "stable" {
        format!("Installed {}", state.version)
    } else {
        format!("Installed {} ({} channel)", state.version, state.channel)
    }
}

fn first_line(text: &Option<String>) -> String {
    text.as_deref()
        .unwrap_or("")
        .lines()
        .next()
        .unwrap_or("")
        .trim()
        .to_string()
}

/// Build a resolver over the profile's registries, collecting fetcher log
/// lines (cache fallbacks) as user-visible notes.
fn build_resolver(
    registries: &[String],
    notes: Rc<RefCell<Vec<String>>>,
) -> Result<(HttpFetcher, Vec<String>)> {
    let log_notes = notes;
    let fetcher = HttpFetcher::new(
        None,
        Box::new(move |line: &str| log_notes.borrow_mut().push(line.to_string())),
    )?;
    Ok((fetcher, registries.to_vec()))
}

pub fn fetch_catalog(embedded: &str, state_dir: &str) -> Result<Catalog> {
    let profile = load_profile(embedded)?;
    let store = open_store(state_dir)?;
    let installed = all_installed(&store)?;
    let notes = Rc::new(RefCell::new(Vec::new()));

    let mut mods: Vec<ResolvedPackage> = Vec::new();
    if profile.registries.is_empty() {
        notes
            .borrow_mut()
            .push("No registries are configured; showing installed mods only.".to_string());
    } else {
        let (mut fetcher, sources) = build_resolver(&profile.registries, notes.clone())?;
        match Resolver::from_sources(&sources, &mut fetcher)
            .and_then(|mut r| r.list_mods())
        {
            Ok(list) => mods = list,
            Err(e) => notes
                .borrow_mut()
                .push(format!("Could not load registries: {e:#}")),
        }
    }

    let mut entries = Vec::new();
    for m in &mods {
        let install = installed.iter().find(|s| s.id == m.manifest.id);
        entries.push(CatalogEntry {
            id: m.manifest.id.clone(),
            name: m.manifest.name.clone(),
            summary: first_line(&m.manifest.description),
            game: install
                .map(|s| s.game.clone())
                .or_else(|| m.manifest.game.clone())
                .unwrap_or_default(),
            installed_version: install.map(|s| s.version.clone()).unwrap_or_default(),
            status: install
                .map(installed_status)
                .unwrap_or_else(|| "Not installed".to_string()),
        });
    }
    // Installed packages that no configured registry lists (including tools
    // pulled in as dependencies) still appear, so nothing is invisible.
    for state in &installed {
        if entries.iter().any(|e| e.id == state.id) {
            continue;
        }
        let summary = if state.kind == "tool" {
            "Tool, installed as a dependency.".to_string()
        } else {
            "Installed, but not listed by the configured registries.".to_string()
        };
        entries.push(CatalogEntry {
            id: state.id.clone(),
            name: state.id.clone(),
            summary,
            game: state.game.clone(),
            installed_version: state.version.clone(),
            status: installed_status(state),
        });
    }
    entries.sort_by(|a, b| a.name.to_lowercase().cmp(&b.name.to_lowercase()));

    let notes = notes.borrow().clone();
    Ok(Catalog { entries, notes })
}

fn setting_items(
    settings: &loadstone_core::types::Settings,
    values: &serde_json::Map<String, serde_json::Value>,
) -> Vec<SettingItem> {
    settings
        .entries
        .iter()
        .map(|entry| {
            let value = core_settings::effective(entry, values)
                .map(|v| match v {
                    serde_json::Value::String(s) => s.clone(),
                    other => other.to_string(),
                })
                .unwrap_or_default();
            SettingItem {
                id: entry.id.clone(),
                label: entry.label.clone(),
                description: entry.description.clone().unwrap_or_default(),
                kind: match entry.entry_type {
                    SettingType::Boolean => "boolean",
                    SettingType::String => "string",
                    SettingType::Number => "number",
                    SettingType::Choice => "choice",
                }
                .to_string(),
                value,
                options: entry
                    .options
                    .iter()
                    .map(|o| ChoiceItem {
                        value: match &o.value {
                            serde_json::Value::String(s) => s.clone(),
                            other => other.to_string(),
                        },
                        label: o.label.clone(),
                    })
                    .collect(),
            }
        })
        .collect()
}

fn action_items(actions: &[loadstone_core::types::Action]) -> Vec<ActionItem> {
    actions
        .iter()
        .map(|a| ActionItem {
            id: a.id.clone(),
            label: a.label.clone(),
            description: a.description.clone().unwrap_or_default(),
        })
        .collect()
}

pub fn fetch_mod_page(embedded: &str, state_dir: &str, mod_id: &str) -> Result<ModPage> {
    let profile = load_profile(embedded)?;
    let store = open_store(state_dir)?;
    let installed = all_installed(&store)?;
    let state = installed.iter().find(|s| s.id == mod_id);
    let notes = Rc::new(RefCell::new(Vec::new()));

    // Resolve the manifest through the registries; an installed mod still
    // gets a page when resolution fails (offline, delisted).
    let mut resolved: Option<ResolvedPackage> = None;
    if !profile.registries.is_empty() {
        let (mut fetcher, sources) = build_resolver(&profile.registries, notes.clone())?;
        match Resolver::from_sources(&sources, &mut fetcher)
            .and_then(|mut r| r.resolve_project(mod_id))
        {
            Ok(r) => resolved = Some(r),
            Err(e) => notes
                .borrow_mut()
                .push(format!("Not found in the configured registries: {e:#}")),
        }
    } else if state.is_none() {
        anyhow::bail!("\"{mod_id}\" is not installed and no registries are configured");
    }
    if resolved.is_none() && state.is_none() {
        anyhow::bail!("\"{mod_id}\" is not installed and could not be resolved");
    }

    // Latest released version, when a release manifest is reachable.
    let mut latest_version = String::new();
    let is_dev_channel = state.map(|s| s.channel == "dev").unwrap_or(false);
    if let Some(r) = &resolved {
        if is_dev_channel {
            if let Some(s) = state {
                notes.borrow_mut().push(format!(
                    "Installed from the development branch ({}).",
                    s.version
                ));
            }
        } else if let Some(source) = &r.release_source {
            match loadstone_core::fetch::fetch_latest_release_manifest(source) {
                Ok(release) => {
                    latest_version =
                        loadstone_core::release::normalize_version(&release.version)
                            .unwrap_or(release.version);
                }
                Err(_) => notes.borrow_mut().push(
                    "The latest published release has no Loadstone metadata yet, so the \
                     newest version could not be determined."
                        .to_string(),
                ),
            }
        }
    }

    let installed_version = state.map(|s| s.version.clone()).unwrap_or_default();
    let can_install = state.is_none() && resolved.is_some();
    let can_update = state.is_some()
        && resolved.is_some()
        && (is_dev_channel || (!latest_version.is_empty() && latest_version != installed_version));
    let status = match state {
        Some(s) => format!("{} for {}", installed_status(s), s.game),
        None => "Not installed".to_string(),
    };

    // Settings: the schema frozen in state when installed (editable), else
    // the manifest's defaults as a preview.
    let mut settings_editable = false;
    let mut settings_note = String::new();
    let mut settings = Vec::new();
    if let Some(s) = state {
        if let (Some(schema), Some(file)) = (&s.settings, &s.settings_file) {
            let values = core_settings::read_values(file).unwrap_or_default();
            settings = setting_items(schema, &values);
            settings_editable = true;
            settings_note = schema.note.clone().unwrap_or_default();
        }
    } else if let Some(r) = &resolved {
        if let Some(schema) = &r.manifest.settings {
            settings = setting_items(schema, &serde_json::Map::new());
            settings_note = "Settings become editable after install.".to_string();
        }
    }

    let actions = match state {
        Some(s) => action_items(&s.actions),
        None => resolved
            .as_ref()
            .map(|r| action_items(&r.manifest.actions))
            .unwrap_or_default(),
    };

    let (name, description, authors, game) = match &resolved {
        Some(r) => (
            r.manifest.name.clone(),
            r.manifest.description.clone().unwrap_or_default(),
            r.manifest.authors.join(", "),
            r.manifest.game.clone().unwrap_or_default(),
        ),
        None => {
            let s = state.unwrap();
            (s.id.clone(), String::new(), String::new(), s.game.clone())
        }
    };

    let notes = notes.borrow().clone();
    Ok(ModPage {
        id: mod_id.to_string(),
        name,
        description,
        authors,
        game: state.map(|s| s.game.clone()).unwrap_or(game),
        installed_version,
        installed_game: state.map(|s| s.game.clone()).unwrap_or_default(),
        channel: state.map(|s| s.channel.clone()).unwrap_or_default(),
        latest_version,
        status,
        can_install,
        can_update,
        can_uninstall: state.is_some(),
        settings_editable,
        settings_note,
        settings,
        actions_available: state.is_some(),
        actions,
        notes,
    })
}

pub fn apply_setting(
    state_dir: &str,
    game: &str,
    mod_id: &str,
    setting_id: &str,
    raw_value: &str,
) -> Result<String> {
    let store = open_store(state_dir)?;
    let state = store
        .load(game, mod_id)?
        .with_context(|| format!("\"{mod_id}\" is not installed for {game}"))?;
    let schema = state
        .settings
        .as_ref()
        .with_context(|| format!("\"{mod_id}\" declares no settings"))?;
    let file = state
        .settings_file
        .as_ref()
        .context("no settings storage file recorded")?;
    Ok(core_settings::set(schema, file, setting_id, raw_value)?.unwrap_or_default())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeMap;

    /// An installed mod with settings gets a full page model from state
    /// alone (no registries), and apply_setting round-trips through it.
    #[test]
    fn mod_page_from_state_with_settings_roundtrip() {
        let tmp = tempfile::tempdir().unwrap();
        let state_dir = tmp.path().join("state");
        let settings_file = tmp.path().join("cfg").join("settings.save");
        let schema: loadstone_core::types::Settings = serde_json::from_value(serde_json::json!({
            "storage": { "file": "unused" },
            "note": "Restart the game.",
            "entries": [
                { "id": "speech", "type": "boolean", "default": true, "label": "Speech" },
                { "id": "reader", "type": "choice", "default": "auto", "label": "Reader",
                  "options": [ { "value": "auto", "label": "Automatic" },
                               { "value": "jaws", "label": "JAWS" } ] }
            ]
        }))
        .unwrap();
        let store = StateStore::open(Some(state_dir.clone())).unwrap();
        store
            .save(&InstalledState {
                id: "fake-mod".into(),
                kind: "mod".into(),
                version: "1.2.3".into(),
                channel: "stable".into(),
                game: "fake-game".into(),
                files: Vec::new(),
                uninstall_steps: Vec::new(),
                user_data_paths: Vec::new(),
                dependencies: Vec::new(),
                dependents: Vec::new(),
                roots: Vec::new(),
                game_dir: tmp.path().join("game"),
                user_data: tmp.path().join("ud"),
                distribution: "steam".into(),
                game_paths: BTreeMap::new(),
                settings: Some(schema),
                settings_file: Some(settings_file),
                actions: serde_json::from_value(serde_json::json!([
                    { "id": "repair", "label": "Repair", "steps": [] }
                ]))
                .unwrap(),
            })
            .unwrap();
        let state_dir = state_dir.to_string_lossy().into_owned();

        let page = fetch_mod_page(r#"{"mode":"manager"}"#, &state_dir, "fake-mod").unwrap();
        assert_eq!(page.name, "fake-mod");
        assert_eq!(page.status, "Installed 1.2.3 for fake-game");
        assert!(page.can_uninstall && !page.can_install && !page.can_update);
        assert!(page.settings_editable);
        assert_eq!(page.settings_note, "Restart the game.");
        assert_eq!(page.settings.len(), 2);
        assert_eq!(page.settings[0].value, "true", "default shown when unset");
        assert_eq!(page.settings[1].options.len(), 2);
        assert_eq!(page.actions.len(), 1);
        assert!(page.actions_available);

        let note = apply_setting(&state_dir, "fake-game", "fake-mod", "reader", "jaws").unwrap();
        assert_eq!(note, "Restart the game.");
        assert!(apply_setting(&state_dir, "fake-game", "fake-mod", "reader", "nvda").is_err());
        let page = fetch_mod_page(r#"{"mode":"manager"}"#, &state_dir, "fake-mod").unwrap();
        assert_eq!(page.settings[1].value, "jaws");

        // The catalog surfaces the installed mod even with no registries.
        let catalog = fetch_catalog(r#"{"mode":"manager"}"#, &state_dir).unwrap();
        assert_eq!(catalog.entries.len(), 1);
        assert_eq!(catalog.entries[0].status, "Installed 1.2.3");
    }
}
