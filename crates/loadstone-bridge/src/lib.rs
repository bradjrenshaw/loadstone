//! The C++ boundary (SPEC-adjacent: the GUI backend). Coarse and
//! message-shaped by design: the GUI asks for whole page models and receives
//! plain shared structs; all parsing, network, and filesystem work stays in
//! Rust. The blocking fetch functions are called from GUI worker threads.
//!
//! Errors cross the bridge as C++ exceptions (`rust::Error`); the GUI shows
//! their message text.

use anyhow::{Context as _, Result};

mod accounts;
pub use accounts::*;
use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

use loadstone_core::profile::{Profile, ProfileMode};
use loadstone_core::registry::{HttpFetcher, ResolvedPackage, Resolver};
use loadstone_core::settings as core_settings;
use loadstone_core::track::{InstalledState, StateStore};
use loadstone_core::types::SettingType;

use crate::ffi::{
    ActionItem, Catalog, CatalogEntry, ChannelEntry, ChoiceItem, CopyPage, ModPage, ReleaseEntry,
    SettingItem, UiProfile,
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
        /// Non-empty when a registry was unreachable in a way signing in
        /// may fix (a private repo): the message to show with the offer.
        sign_in_hint: String,
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

    /// One GitHub release, for the version picker.
    struct ReleaseEntry {
        tag: String,
        /// Display text: tag, optional release title, pre-release marker.
        label: String,
        prerelease: bool,
    }

    /// One known copy of the game (Steam, Epic, a hand-picked folder) with
    /// this mod's state in it. The page shows one copy at a time; a list of
    /// labels lets the user switch when there is more than one.
    struct CopyPage {
        /// List text: "Steam copy, installed 1.1.0, C:\\...\\Balatro".
        label: String,
        distribution: String,
        /// The copy's game folder: recorded at install time, else detected,
        /// else empty (the user browses for it).
        game_dir: String,
        /// Empty when not installed in this copy.
        installed_version: String,
        channel: String,
        /// One-line summary for the top of the page ("Ready to install
        /// version 1.0.9.", "Update available: 1.0.8 to 1.0.9.", ...).
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
        /// The mod is installed here and declares launch steps for this
        /// platform: the page shows a Launch button.
        can_launch: bool,
    }

    /// A branch ("development") channel the mod declares, for the version
    /// picker. Release channels need no entry: releases are listed
    /// directly.
    struct ChannelEntry {
        id: String,
        /// Ready-to-show picker line, e.g.
        /// "dev channel (latest from the main branch)".
        label: String,
    }

    /// A newer build of this executable offered by its update source.
    struct SelfUpdate {
        available: bool,
        /// Offered Loadstone version ("0.2.0"); empty when unavailable.
        version: String,
        /// Release asset name of the exe.
        file: String,
        sha256: String,
        /// `github:owner/repo` the offer came from.
        source: String,
    }

    struct ModPage {
        id: String,
        name: String,
        description: String,
        authors: String,
        game: String,
        /// Display name of the game ("Balatro"), for labels.
        game_name: String,
        /// Empty when unknown (no release manifest reachable).
        latest_version: String,
        /// Index into `copies` the page should open on.
        selected_copy: usize,
        /// Never empty: at least one (possibly empty-dir) copy.
        copies: Vec<CopyPage>,
        /// Branch channels for the version picker (often empty).
        channels: Vec<ChannelEntry>,
        /// Informational lines for the bottom of the page.
        notes: Vec<String>,
    }

    /// One stored sign-in, for the Loadstone settings dialog.
    struct AccountItem {
        id: String,
        label: String,
        username: String,
        host: String,
        /// Scheme ("github").
        provider: String,
        /// Site display name ("GitHub").
        provider_name: String,
        is_default: bool,
        /// False when the token is missing from the credential store.
        has_token: bool,
    }

    /// "Use this account for this repository or owner."
    struct RuleItem {
        pattern: String,
        account: String,
        /// The account's label ("" when the account no longer exists).
        account_label: String,
    }

    /// A started browser sign-in: show `user_code`, open `verification_uri`.
    struct SignInStart {
        user_code: String,
        verification_uri: String,
        interval_secs: u64,
        expires_in_secs: u64,
        /// Opaque handle passed back to `poll_sign_in`.
        device_code: String,
    }

    /// One poll of a sign-in.
    struct SignInStatus {
        /// "pending" (poll again), "slow_down" (use `interval_secs` from
        /// now on), or "done" (the account is saved).
        state: String,
        interval_secs: u64,
        /// done: the saved account's label.
        account_label: String,
    }

    extern "Rust" {
        /// Core library version (for the about line and smoke tests).
        fn core_version() -> String;

        // ── Accounts and Loadstone settings ───────────────────────────
        // All take the embedded profile: it picks the scope (the manager,
        // or this standalone installer's own).

        /// Stored accounts.
        fn account_list(embedded: &str) -> Result<Vec<AccountItem>>;
        /// Account rules.
        fn account_rules(embedded: &str) -> Result<Vec<RuleItem>>;
        /// Sites that support signing in, as (scheme, display name).
        fn sign_in_providers() -> Vec<ChoiceItem>;
        /// Begin a browser sign-in. Blocking (network) — worker thread.
        fn start_sign_in(embedded: &str, provider: &str) -> Result<SignInStart>;
        /// Check once whether the user finished; on "done" the account is
        /// saved. Blocking (network) — worker thread.
        fn poll_sign_in(
            embedded: &str,
            provider: &str,
            label: &str,
            device_code: &str,
            interval_secs: u64,
        ) -> Result<SignInStatus>;
        /// Add an account from an existing token (checked with the site
        /// first). Returns the account's label. Blocking (network).
        fn add_token_account(
            embedded: &str,
            provider: &str,
            label: &str,
            token: &str,
        ) -> Result<String>;
        fn remove_account(embedded: &str, account_id: &str) -> Result<()>;
        fn set_default_account(embedded: &str, account_id: &str) -> Result<()>;
        fn set_account_rule(embedded: &str, pattern: &str, account_id: &str) -> Result<()>;
        fn remove_account_rule(embedded: &str, pattern: &str) -> Result<()>;
        /// Loadstone-wide settings shown as a generic form (structured
        /// ones like the account list are excluded).
        fn global_prefs(embedded: &str) -> Result<Vec<SettingItem>>;
        fn set_global_pref(embedded: &str, key: &str, raw_value: &str) -> Result<()>;
        /// Loadstone's settings for one mod (e.g. its download account).
        fn mod_prefs(embedded: &str, mod_id: &str) -> Result<Vec<SettingItem>>;
        fn set_mod_pref(embedded: &str, mod_id: &str, key: &str, raw_value: &str) -> Result<()>;
        /// True when the most recent catalog / page / release-list /
        /// install call failed in a way signing in might fix (an anonymous
        /// "not found" from a site that supports accounts). Read it on the
        /// worker thread right after the failing call.
        fn last_error_needs_sign_in() -> bool;

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

        /// Validate and persist one setting for an installed mod. `game_dir`
        /// names the copy ("" = the only copy it is installed in). Returns
        /// the schema's note ("" when none) for the UI to show.
        fn apply_setting(
            state_dir: &str,
            game: &str,
            game_dir: &str,
            mod_id: &str,
            setting_id: &str,
            raw_value: &str,
        ) -> Result<String>;

        /// Install (or with `update` = true, update) a mod through the
        /// profile's registries. Blocking (network + disk) — call from a
        /// worker thread; the engine talks back through `ui`. `channel` ""
        /// means stable; `tag` "" means the latest release (a named tag
        /// installs exactly that release, from its own
        /// loadstone-release.json); `game_dir` overrides detection;
        /// `local_release` names a local loadstone-release.json for
        /// offline/from-file installs ("" = none). Returns a summary.
        fn run_install(
            embedded: &str,
            state_dir: &str,
            mod_id: &str,
            channel: &str,
            update: bool,
            tag: &str,
            game_dir: &str,
            local_release: &str,
            ui: Pin<&mut UiCallbacks>,
        ) -> Result<String>;

        /// Check the profile's update source for a newer build of this
        /// executable. Blocking (network) — worker thread. Offline, no
        /// releases, or no installer metadata all answer available =
        /// false; launch must never nag or error.
        fn check_self_update(embedded: &str) -> Result<SelfUpdate>;

        /// Download the offered build, verify its hash, and swap it in
        /// for the running one (the running exe, or on macOS the .app
        /// bundle, is moved aside). Returns what to relaunch: the exe, or
        /// the bundle on macOS. Blocking — worker thread.
        fn apply_self_update(
            update: &SelfUpdate,
            ui: Pin<&mut UiCallbacks>,
        ) -> Result<String>;

        /// Delete the ".old" file a previous self-update left beside the
        /// exe. Call once at startup.
        fn cleanup_self_update();

        /// List the mod's source repo's releases, newest first, for the
        /// version picker. Blocking (GitHub API) — worker thread only, and
        /// only on explicit user action (the API is rate-limited).
        fn list_mod_releases(embedded: &str, mod_id: &str) -> Result<Vec<ReleaseEntry>>;

        /// Uninstall an installed package from one game copy (`game_dir`,
        /// "" = the only copy it is installed in). The engine asks about
        /// purging user data through `ui.confirm`. Blocking — worker thread.
        fn run_uninstall(
            state_dir: &str,
            game: &str,
            game_dir: &str,
            mod_id: &str,
            ui: Pin<&mut UiCallbacks>,
        ) -> Result<String>;

        /// Run one of an installed mod's declared actions in one game copy
        /// (`game_dir`, "" = the only copy it is installed in). Blocking —
        /// worker thread (pick-directory steps prompt through `ui`).
        fn run_mod_action(
            state_dir: &str,
            game: &str,
            game_dir: &str,
            mod_id: &str,
            action_id: &str,
            ui: Pin<&mut UiCallbacks>,
        ) -> Result<String>;

        /// Start the game with an installed mod loaded, via the launch
        /// steps frozen at install time. Returns once the game process has
        /// been started (it is not waited for).
        fn run_launch(
            state_dir: &str,
            game: &str,
            game_dir: &str,
            mod_id: &str,
            ui: Pin<&mut UiCallbacks>,
        ) -> Result<String>;
    }

    unsafe extern "C++" {
        include!("loadstone-bridge/include/ui_callbacks.h");

        /// Implemented by the frontend (see include/ui_callbacks.h); the
        /// engine's EngineUi calls arrive through these methods on the
        /// worker thread.
        type UiCallbacks;

        fn log(self: Pin<&mut UiCallbacks>, message: &str);
        fn progress(self: Pin<&mut UiCallbacks>, percent: u32);
        fn confirm(self: Pin<&mut UiCallbacks>, message: &str) -> bool;
        fn retry_skip_cancel(self: Pin<&mut UiCallbacks>, message: &str) -> u8;
        fn pick_directory(
            self: Pin<&mut UiCallbacks>,
            id: &str,
            prompt: &str,
            suggest: &str,
        ) -> String;
    }
}

// ---------------------------------------------------------------------------
// EngineUi adapter over the C++ callback object.

struct GuiUi<'a>(std::pin::Pin<&'a mut ffi::UiCallbacks>);

impl loadstone_core::engine::EngineUi for GuiUi<'_> {
    fn log(&mut self, message: &str) {
        self.0.as_mut().log(message);
    }

    fn progress(&mut self, percent: u32) {
        self.0.as_mut().progress(percent);
    }

    fn confirm(&mut self, message: &str) -> bool {
        self.0.as_mut().confirm(message)
    }

    fn retry_skip_cancel(&mut self, message: &str) -> loadstone_core::engine::RetryChoice {
        use loadstone_core::engine::RetryChoice;
        match self.0.as_mut().retry_skip_cancel(message) {
            0 => RetryChoice::Retry,
            1 => RetryChoice::Skip,
            _ => RetryChoice::Cancel,
        }
    }

    fn pick_directory(&mut self, id: &str, prompt: &str, suggest: Option<&str>) -> Option<PathBuf> {
        let answer = self
            .0
            .as_mut()
            .pick_directory(id, prompt, suggest.unwrap_or(""));
        if answer.is_empty() {
            None
        } else {
            Some(PathBuf::from(answer.to_string()))
        }
    }
}

fn opt_path(s: &str) -> Option<PathBuf> {
    if s.is_empty() {
        None
    } else {
        Some(PathBuf::from(s))
    }
}

pub fn run_install(
    embedded: &str,
    state_dir: &str,
    mod_id: &str,
    channel: &str,
    update: bool,
    tag: &str,
    game_dir: &str,
    local_release: &str,
    ui: std::pin::Pin<&mut ffi::UiCallbacks>,
) -> Result<String> {
    let profile = load_profile(embedded)?;
    let opts = loadstone_core::ops::InstallOptions {
        id: Some(mod_id.to_string()),
        profile,
        state_dir: opt_path(state_dir),
        game_dir: opt_path(game_dir),
        local_release: opt_path(local_release),
        channel: if channel.is_empty() { "stable".to_string() } else { channel.to_string() },
        tag: if tag.is_empty() { None } else { Some(tag.to_string()) },
        update_mode: update,
        ..Default::default()
    };
    accounts::track(loadstone_core::ops::install(&opts, &mut GuiUi(ui)))
}

pub fn list_mod_releases(embedded: &str, mod_id: &str) -> Result<Vec<ReleaseEntry>> {
    accounts::track(list_mod_releases_inner(embedded, mod_id))
}

fn list_mod_releases_inner(embedded: &str, mod_id: &str) -> Result<Vec<ReleaseEntry>> {
    let profile = load_profile(embedded)?;
    if profile.registries.is_empty() {
        anyhow::bail!("no registries are configured");
    }
    let notes = Rc::new(RefCell::new(Vec::new()));
    let (mut fetcher, sources) = build_resolver(&profile.registries, notes)?;
    let resolved = Resolver::from_sources(&sources, &mut fetcher)?.resolve_project(mod_id)?;
    let source = resolved
        .release_source
        .with_context(|| format!("no source repo is known for \"{mod_id}\""))?;
    let releases = loadstone_core::source::list_releases(&source, Some(mod_id))?;
    Ok(releases
        .into_iter()
        .map(|r| {
            let mut label = r.tag.clone();
            if !r.name.is_empty() && r.name != r.tag {
                label.push_str(", ");
                label.push_str(&r.name);
            }
            if r.prerelease {
                label.push_str(" (pre-release)");
            }
            ReleaseEntry { tag: r.tag, label, prerelease: r.prerelease }
        })
        .collect())
}

/// Where this build checks for newer versions of itself: the profile's
/// explicit source, else the Loadstone repo (manager builds) or the
/// pinned mod's release source (single-mod builds).
fn update_source_for(profile: &Profile) -> Option<String> {
    if let Some(source) = &profile.update_source {
        return Some(source.clone());
    }
    match profile.mode {
        ProfileMode::Manager => {
            Some(loadstone_core::profile::DEFAULT_UPDATE_SOURCE.to_string())
        }
        ProfileMode::SingleMod => {
            let id = profile.mod_id.clone()?;
            if profile.registries.is_empty() {
                return None;
            }
            let notes = Rc::new(RefCell::new(Vec::new()));
            let (mut fetcher, sources) = build_resolver(&profile.registries, notes).ok()?;
            let mut resolver = Resolver::from_sources(&sources, &mut fetcher).ok()?;
            resolver.resolve_project(&id).ok()?.release_source
        }
    }
}

pub fn check_self_update(embedded: &str) -> Result<ffi::SelfUpdate> {
    let none = ffi::SelfUpdate {
        available: false,
        version: String::new(),
        file: String::new(),
        sha256: String::new(),
        source: String::new(),
    };
    let profile = load_profile(embedded)?;
    let Some(source) = update_source_for(&profile) else {
        return Ok(none);
    };
    match loadstone_core::selfupdate::check(&source, env!("CARGO_PKG_VERSION")) {
        Some(info) => Ok(ffi::SelfUpdate {
            available: true,
            version: info.version,
            file: info.file,
            sha256: info.sha256,
            source: info.source,
        }),
        None => Ok(none),
    }
}

pub fn apply_self_update(
    update: &ffi::SelfUpdate,
    ui: std::pin::Pin<&mut ffi::UiCallbacks>,
) -> Result<String> {
    use loadstone_core::engine::EngineUi as _;
    let info = loadstone_core::selfupdate::UpdateInfo {
        version: update.version.clone(),
        file: update.file.clone(),
        sha256: update.sha256.clone(),
        source: update.source.clone(),
    };
    let mut gui = GuiUi(ui);
    gui.log(&format!("Downloading {}...", info.file));
    let exe = loadstone_core::selfupdate::apply(&info, |p| gui.progress(p))?;
    gui.log("Update verified and installed.");
    Ok(exe.display().to_string())
}

pub fn cleanup_self_update() {
    if let Ok(exe) = std::env::current_exe() {
        loadstone_core::selfupdate::cleanup_leftover(&exe);
    }
}

pub fn run_uninstall(
    state_dir: &str,
    game: &str,
    game_dir: &str,
    mod_id: &str,
    ui: std::pin::Pin<&mut ffi::UiCallbacks>,
) -> Result<String> {
    loadstone_core::ops::uninstall(
        mod_id,
        game,
        opt_path(game_dir).as_deref(),
        opt_path(state_dir),
        None,
        &mut GuiUi(ui),
    )
}

pub fn run_mod_action(
    state_dir: &str,
    game: &str,
    game_dir: &str,
    mod_id: &str,
    action_id: &str,
    ui: std::pin::Pin<&mut ffi::UiCallbacks>,
) -> Result<String> {
    let store = open_store(state_dir)?;
    let state =
        loadstone_core::ops::find_installed(&store, game, mod_id, opt_path(game_dir).as_deref())?;
    let label = state
        .actions
        .iter()
        .find(|a| a.id == action_id)
        .map(|a| a.label.clone())
        .unwrap_or_else(|| action_id.to_string());
    loadstone_core::engine::run_action(&store, &state, action_id, &mut GuiUi(ui))?;
    Ok(format!("{label} completed."))
}

pub fn run_launch(
    state_dir: &str,
    game: &str,
    game_dir: &str,
    mod_id: &str,
    ui: std::pin::Pin<&mut ffi::UiCallbacks>,
) -> Result<String> {
    loadstone_core::ops::launch(
        mod_id,
        game,
        opt_path(game_dir).as_deref(),
        opt_path(state_dir),
        &mut GuiUi(ui),
    )
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
    accounts::ensure_auth(&profile);
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

/// Catalog status across every game copy a mod is installed in.
fn aggregate_status(states: &[&InstalledState]) -> String {
    match states {
        [] => "Not installed".to_string(),
        [one] => installed_status(one),
        many => {
            let first = &many[0].version;
            if many.iter().all(|s| &s.version == first) {
                format!("Installed {} for {} copies", first, many.len())
            } else {
                format!("Installed for {} copies (versions differ)", many.len())
            }
        }
    }
}

/// Human title for a distribution id ("steam" -> "Steam").
fn distribution_title(distribution: &str) -> String {
    match distribution {
        "steam" => "Steam".to_string(),
        "epic" => "Epic".to_string(),
        "gog" => "GOG".to_string(),
        "gamepass" => "Game Pass".to_string(),
        "itch" => "itch.io".to_string(),
        "standalone" => "Standalone".to_string(),
        other => {
            let mut chars = other.chars();
            match chars.next() {
                Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
                None => String::new(),
            }
        }
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

/// A registry load failed during the catalog fetch: note it, and if
/// signing in might help, say so — the catalog still lists installed mods,
/// and the GUI offers to sign in on top.
fn registry_failed(e: &anyhow::Error, notes: &Rc<RefCell<Vec<String>>>, hint: &mut String) {
    let text = format!("Could not load registries: {e:#}");
    if loadstone_core::source::is_maybe_private(e) {
        *hint = text.clone();
    }
    notes.borrow_mut().push(text);
}

pub fn fetch_catalog(embedded: &str, state_dir: &str) -> Result<Catalog> {
    accounts::track(fetch_catalog_inner(embedded, state_dir))
}

fn fetch_catalog_inner(embedded: &str, state_dir: &str) -> Result<Catalog> {
    let profile = load_profile(embedded)?;
    let store = open_store(state_dir)?;
    let installed = all_installed(&store)?;
    let notes = Rc::new(RefCell::new(Vec::new()));

    let mut mods: Vec<ResolvedPackage> = Vec::new();
    // Mods with no state record whose files are nonetheless present in a
    // detected game copy — installed by hand or by an old standalone
    // installer.
    let mut foreign_ids: Vec<String> = Vec::new();
    let mut sign_in_hint = String::new();
    if profile.registries.is_empty() {
        notes
            .borrow_mut()
            .push("No registries are configured; showing installed mods only.".to_string());
    } else {
        let (mut fetcher, sources) = build_resolver(&profile.registries, notes.clone())?;
        match Resolver::from_sources(&sources, &mut fetcher) {
            Ok(mut r) => match r.list_mods() {
                Ok(list) => {
                    for m in &list {
                        if installed.iter().any(|s| s.id == m.manifest.id) {
                            continue;
                        }
                        let Some(game_id) = &m.manifest.game else { continue };
                        let Ok(g) = r.resolve_game(game_id, &m.scope) else { continue };
                        let present = loadstone_core::detect::detect_all(&g)
                            .unwrap_or_default()
                            .into_iter()
                            .any(|found| {
                                loadstone_core::ops::foreign_install_present(
                                    &g,
                                    &m.manifest,
                                    &found.game_dir,
                                    &found.distribution,
                                )
                            });
                        if present {
                            foreign_ids.push(m.manifest.id.clone());
                        }
                    }
                    mods = list;
                }
                Err(e) => registry_failed(&e, &notes, &mut sign_in_hint),
            },
            Err(e) => registry_failed(&e, &notes, &mut sign_in_hint),
        }
    }

    let mut entries = Vec::new();
    for m in &mods {
        let installs: Vec<&InstalledState> =
            installed.iter().filter(|s| s.id == m.manifest.id).collect();
        entries.push(CatalogEntry {
            id: m.manifest.id.clone(),
            name: m.manifest.name.clone(),
            summary: first_line(&m.manifest.description),
            game: installs
                .first()
                .map(|s| s.game.clone())
                .or_else(|| m.manifest.game.clone())
                .unwrap_or_default(),
            installed_version: installs.first().map(|s| s.version.clone()).unwrap_or_default(),
            status: if installs.is_empty() && foreign_ids.contains(&m.manifest.id) {
                "Installed outside Loadstone".to_string()
            } else {
                aggregate_status(&installs)
            },
        });
    }
    // Installed mods that no configured registry lists still appear, so
    // nothing the user must manage is invisible. Tools and libraries are
    // excluded: the manager installs, updates, and removes those
    // automatically as dependencies, so listing them alongside mods
    // misreads. Dependent mod pages name them; `loadstone list` shows
    // them with their dependents.
    for state in &installed {
        if state.kind == "tool" || state.kind == "library" {
            continue;
        }
        if entries.iter().any(|e| e.id == state.id) {
            continue;
        }
        let copies: Vec<&InstalledState> =
            installed.iter().filter(|s| s.id == state.id).collect();
        entries.push(CatalogEntry {
            id: state.id.clone(),
            name: state.id.clone(),
            summary: "Installed, but not listed by the configured registries.".to_string(),
            game: state.game.clone(),
            installed_version: state.version.clone(),
            status: aggregate_status(&copies),
        });
    }
    entries.sort_by(|a, b| a.name.to_lowercase().cmp(&b.name.to_lowercase()));

    let notes = notes.borrow().clone();
    Ok(Catalog { entries, notes, sign_in_hint })
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
    accounts::track(fetch_mod_page_inner(embedded, state_dir, mod_id))
}

fn fetch_mod_page_inner(embedded: &str, state_dir: &str, mod_id: &str) -> Result<ModPage> {
    let profile = load_profile(embedded)?;
    let store = open_store(state_dir)?;
    let installed = all_installed(&store)?;
    // Every copy's install of this mod; the page shows one copy at a time.
    let records: Vec<&InstalledState> = installed.iter().filter(|s| s.id == mod_id).collect();
    let any_state = records.first().copied();
    let notes = Rc::new(RefCell::new(Vec::new()));

    // Resolve the manifest (and its game package, for detection) through
    // the registries; an installed mod still gets a page when resolution
    // fails (offline, delisted).
    let mut resolved: Option<ResolvedPackage> = None;
    let mut game_manifest: Option<loadstone_core::types::GameManifest> = None;
    // Dependencies (id, display name) for the "Requires ..." note. Installed
    // state's recorded ids win (what actually got pulled in); a fresh
    // manifest supplies them pre-install.
    let mut dep_infos: Vec<(String, String)> = Vec::new();
    let mut resolve_err: Option<anyhow::Error> = None;
    if !profile.registries.is_empty() {
        let (mut fetcher, sources) = build_resolver(&profile.registries, notes.clone())?;
        match Resolver::from_sources(&sources, &mut fetcher) {
            Ok(mut r) => match r.resolve_project(mod_id) {
                Ok(res) => {
                    if let Some(game_id) = &res.manifest.game {
                        game_manifest = r.resolve_game(game_id, &res.scope).ok();
                    }
                    let dep_ids: Vec<String> = match any_state {
                        Some(s) => s.dependencies.clone(),
                        None => res
                            .manifest
                            .dependencies
                            .iter()
                            .map(|d| d.id.clone())
                            .collect(),
                    };
                    for id in dep_ids {
                        let name = r
                            .resolve_project(&id)
                            .map(|d| d.manifest.name.clone())
                            .unwrap_or_else(|_| id.clone());
                        dep_infos.push((id, name));
                    }
                    resolved = Some(res);
                }
                Err(e) => {
                    notes
                        .borrow_mut()
                        .push(format!("Not found in the configured registries: {e:#}"));
                    resolve_err = Some(e);
                }
            },
            Err(e) => {
                notes.borrow_mut().push(format!("Could not load registries: {e:#}"));
                resolve_err = Some(e);
            }
        }
    } else if records.is_empty() {
        anyhow::bail!("\"{mod_id}\" is not installed and no registries are configured");
    }
    if resolved.is_none() && records.is_empty() {
        // Keep the underlying error in the chain: if it says the registry
        // may be private, the GUI offers to sign in and retry.
        return Err(match resolve_err {
            Some(e) => {
                let msg = format!("\"{mod_id}\" is not installed and could not be resolved: {e:#}");
                e.context(msg)
            }
            None => anyhow::anyhow!("\"{mod_id}\" is not installed and could not be resolved"),
        });
    }

    // Latest released version, when a release manifest is reachable. The
    // fetch is skipped only when every installed copy runs the dev channel
    // (per-copy statuses already say "(dev channel)").
    let mut latest_version = String::new();
    let all_dev = !records.is_empty() && records.iter().all(|s| s.channel == "dev");
    if let Some(r) = &resolved {
        if !all_dev {
            if let Some(source) = &r.release_source {
                match loadstone_core::source::release_manifest(source, Some(mod_id), None) {
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
    }

    let game_name = game_manifest
        .as_ref()
        .map(|g| g.name.clone())
        .or_else(|| any_state.map(|s| s.game.clone()))
        .unwrap_or_default();

    // One CopyPage per known game copy, in the installers' familiar voice.
    let build_copy = |state: Option<&InstalledState>,
                      distribution: String,
                      game_dir: String|
     -> CopyPage {
        let installed_version = state.map(|s| s.version.clone()).unwrap_or_default();
        let can_install = state.is_none() && resolved.is_some();
        // Installed copies keep an enabled Update button whenever the mod
        // resolves: the version picker also serves reinstalls, downgrades,
        // and channel switches, exactly like the old installers' always-on
        // install button. The status line still says whether an update
        // actually exists.
        let can_update = state.is_some() && resolved.is_some();

        // A copy Loadstone never installed may still hold the mod's files
        // (placed by hand, or by the mod's old standalone installer). Say
        // so rather than claiming the copy is clean; installing through
        // Loadstone adopts it.
        let foreign = state.is_none()
            && !game_dir.is_empty()
            && match (&resolved, &game_manifest) {
                (Some(r), Some(g)) => loadstone_core::ops::foreign_install_present(
                    g,
                    &r.manifest,
                    std::path::Path::new(&game_dir),
                    &distribution,
                ),
                _ => false,
            };

        let mut status = match state {
            Some(s) if s.channel == "dev" => {
                format!("Installed {} (dev channel).", s.version)
            }
            Some(s) if !latest_version.is_empty() && latest_version == s.version => {
                format!("Up to date (version {}).", s.version)
            }
            Some(s) if !latest_version.is_empty() => {
                format!("Update available: {} to {}.", s.version, latest_version)
            }
            Some(s) => format!("Installed {}.", s.version),
            None if foreign && !latest_version.is_empty() => format!(
                "Installed outside Loadstone (version unknown). Install version \
                 {latest_version} to let Loadstone manage this copy."
            ),
            None if foreign => "Installed outside Loadstone (version unknown). Install to \
                                let Loadstone manage this copy."
                .to_string(),
            None if !latest_version.is_empty() => {
                format!("Ready to install version {latest_version}.")
            }
            None => "Not installed.".to_string(),
        };
        if game_dir.is_empty() && state.is_none() {
            status.push_str(" Game directory not found; use Browse to select it.");
        }

        // Settings: the schema frozen in state when installed (editable),
        // else the manifest's defaults as a preview.
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

        // The list line: which copy, its state, where it lives.
        let short = if !installed_version.is_empty() {
            format!("installed {installed_version}")
        } else if foreign {
            "installed outside Loadstone".to_string()
        } else {
            "not installed".to_string()
        };
        // A game that also ships as a second Steam app (a demo) names it:
        // "Steam demo copy".
        let mut dist_title = distribution_title(&distribution);
        if distribution == "steam" && !game_dir.is_empty() {
            if let Some(name) = game_manifest
                .as_ref()
                .and_then(|g| loadstone_core::detect::steam_entry_for_dir(g, std::path::Path::new(&game_dir)))
                .and_then(|e| e.name)
            {
                dist_title = format!("{dist_title} {name}");
            }
        }
        let label = if game_dir.is_empty() {
            "No copy found yet; use Browse to select the game folder.".to_string()
        } else if dist_title.is_empty() {
            format!("Copy at {game_dir}, {short}")
        } else {
            format!("{dist_title} copy, {short}, {game_dir}")
        };

        CopyPage {
            label,
            distribution,
            game_dir,
            installed_version,
            channel: state.map(|s| s.channel.clone()).unwrap_or_default(),
            status,
            can_install,
            can_update,
            can_uninstall: state.is_some(),
            settings_editable,
            settings_note,
            settings,
            actions_available: state.is_some(),
            actions,
            can_launch: state.is_some_and(|s| !s.launch.is_empty()),
        }
    };

    // Installed copies first, then detected copies not already recorded,
    // then (if nothing at all) one empty slot the user can Browse into.
    let mut copies: Vec<CopyPage> = Vec::new();
    let mut seen_keys: Vec<String> = Vec::new();
    for s in &records {
        seen_keys.push(loadstone_core::track::copy_key(&s.game_dir));
        copies.push(build_copy(
            Some(s),
            s.distribution.clone(),
            s.game_dir.display().to_string(),
        ));
    }
    if let Some(g) = &game_manifest {
        for found in loadstone_core::detect::detect_all(g).unwrap_or_default() {
            let key = loadstone_core::track::copy_key(&found.game_dir);
            if seen_keys.contains(&key) {
                continue;
            }
            seen_keys.push(key);
            copies.push(build_copy(
                None,
                found.distribution,
                found.game_dir.display().to_string(),
            ));
        }
    }
    // Then one empty slot the user can Browse into: the only entry when
    // nothing was found, otherwise "Another folder..." so a mod can go into
    // a copy detection missed (a demo switched for the full game, another
    // library) even once some copy is installed.
    let any_found = !copies.is_empty();
    let mut slot = build_copy(None, String::new(), String::new());
    if any_found {
        slot.label = "Another folder...".to_string();
        slot.status = format!("Use Browse to select the folder. {}", slot.status);
    }
    copies.push(slot);
    let selected_copy = copies
        .iter()
        .position(|c| !c.installed_version.is_empty())
        .unwrap_or(0);

    // When copies share one mods folder (the mods path lives in user data,
    // not the game folder), per-copy management is partly an illusion —
    // say so rather than letting an uninstall surprise the other copy.
    if copies.len() > 1 {
        if let Some(g) = &game_manifest {
            if g.paths.values().any(|p| p.contains("${userData}")) {
                notes.borrow_mut().push(format!(
                    "Note: copies of {} share one mods folder. Installing or \
                     uninstalling a mod for one copy affects the others; only the \
                     mod loader is separate per copy.",
                    g.name
                ));
            }
        }
    }

    let (name, description, authors, game) = match &resolved {
        Some(r) => (
            r.manifest.name.clone(),
            r.manifest.description.clone().unwrap_or_default(),
            r.manifest.authors.join(", "),
            r.manifest.game.clone().unwrap_or_default(),
        ),
        None => {
            let s = any_state.unwrap();
            (s.id.clone(), String::new(), String::new(), s.game.clone())
        }
    };

    // Offline / unresolved: the recorded dependency ids still get a note,
    // just without pretty names.
    if dep_infos.is_empty() {
        if let Some(s) = any_state {
            dep_infos = s.dependencies.iter().map(|d| (d.clone(), d.clone())).collect();
        }
    }
    let page_game = any_state.map(|s| s.game.clone()).unwrap_or_else(|| game.clone());
    for (id, dep_name) in &dep_infos {
        let dep_state = installed
            .iter()
            .find(|d| d.id == *id && (page_game.is_empty() || d.game == page_game));
        notes.borrow_mut().push(match dep_state {
            Some(d) => format!(
                "Requires {dep_name} (installed automatically, currently {}).",
                d.version
            ),
            None => format!("Requires {dep_name} (installed automatically)."),
        });
    }

    // Branch channels for the version picker (release channels are the
    // release list itself).
    let mut channels: Vec<ChannelEntry> = Vec::new();
    if let Some(r) = &resolved {
        for (cid, decl) in &r.manifest.channels {
            if decl.source == loadstone_core::types::ChannelSource::Branch {
                let label = match &decl.branch {
                    Some(branch) => {
                        format!("{cid} channel (latest from the {branch} branch)")
                    }
                    None => format!("{cid} channel (development build)"),
                };
                channels.push(ChannelEntry { id: cid.clone(), label });
            }
        }
    }

    let notes = notes.borrow().clone();
    Ok(ModPage {
        id: mod_id.to_string(),
        name,
        description,
        authors,
        game: page_game,
        game_name,
        latest_version,
        selected_copy,
        copies,
        channels,
        notes,
    })
}

pub fn apply_setting(
    state_dir: &str,
    game: &str,
    game_dir: &str,
    mod_id: &str,
    setting_id: &str,
    raw_value: &str,
) -> Result<String> {
    let store = open_store(state_dir)?;
    let state =
        loadstone_core::ops::find_installed(&store, game, mod_id, opt_path(game_dir).as_deref())?;
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
                cleanup_legacy_paths: Vec::new(),
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
                launch: Vec::new(),
                steam_app_id: None,
            })
            .unwrap();
        let state_dir = state_dir.to_string_lossy().into_owned();

        let page = fetch_mod_page(r#"{"mode":"manager"}"#, &state_dir, "fake-mod").unwrap();
        assert_eq!(page.name, "fake-mod");
        assert_eq!(page.game_name, "fake-game");
        // The installed copy, then the "Another folder..." slot.
        assert_eq!(page.copies.len(), 2);
        assert_eq!(page.copies[1].label, "Another folder...");
        assert!(page.copies[1].game_dir.is_empty() && !page.copies[1].can_uninstall);
        assert_eq!(page.selected_copy, 0);
        let copy = &page.copies[0];
        assert_eq!(copy.status, "Installed 1.2.3.");
        assert_eq!(copy.game_dir, tmp.path().join("game").display().to_string());
        assert!(copy.can_uninstall && !copy.can_install && !copy.can_update);
        assert!(copy.settings_editable);
        assert_eq!(copy.settings_note, "Restart the game.");
        assert_eq!(copy.settings.len(), 2);
        assert_eq!(copy.settings[0].value, "true", "default shown when unset");
        assert_eq!(copy.settings[1].options.len(), 2);
        assert_eq!(copy.actions.len(), 1);
        assert!(copy.actions_available);

        let note =
            apply_setting(&state_dir, "fake-game", "", "fake-mod", "reader", "jaws").unwrap();
        assert_eq!(note, "Restart the game.");
        assert!(apply_setting(&state_dir, "fake-game", "", "fake-mod", "reader", "nvda").is_err());
        let page = fetch_mod_page(r#"{"mode":"manager"}"#, &state_dir, "fake-mod").unwrap();
        assert_eq!(page.copies[0].settings[1].value, "jaws");

        // The catalog surfaces the installed mod even with no registries.
        let catalog = fetch_catalog(r#"{"mode":"manager"}"#, &state_dir).unwrap();
        assert_eq!(catalog.entries.len(), 1);
        assert_eq!(catalog.entries[0].status, "Installed 1.2.3");
    }

    /// Dependency tools never appear in the catalog as peer mods; the
    /// dependent mod's page names them in a note instead.
    #[test]
    fn tools_hidden_from_catalog_but_named_on_mod_page() {
        let tmp = tempfile::tempdir().unwrap();
        let state_dir = tmp.path().join("state");
        let store = StateStore::open(Some(state_dir.clone())).unwrap();
        let base = InstalledState {
            id: String::new(),
            kind: String::new(),
            version: String::new(),
            channel: "stable".into(),
            game: "fake-game".into(),
            files: Vec::new(),
            uninstall_steps: Vec::new(),
            user_data_paths: Vec::new(),
            cleanup_legacy_paths: Vec::new(),
            dependencies: Vec::new(),
            dependents: Vec::new(),
            roots: Vec::new(),
            game_dir: tmp.path().join("game"),
            user_data: tmp.path().join("ud"),
            distribution: "steam".into(),
            game_paths: BTreeMap::new(),
            settings: None,
            settings_file: None,
            actions: Vec::new(),
            launch: Vec::new(),
            steam_app_id: None,
        };
        store
            .save(&InstalledState {
                id: "fake-mod".into(),
                kind: "mod".into(),
                version: "1.2.3".into(),
                dependencies: vec!["fake-tool".into()],
                ..base.clone()
            })
            .unwrap();
        store
            .save(&InstalledState {
                id: "fake-tool".into(),
                kind: "tool".into(),
                version: "0.9.0".into(),
                dependents: vec!["fake-mod".into()],
                ..base
            })
            .unwrap();
        let state_dir = state_dir.to_string_lossy().into_owned();

        let catalog = fetch_catalog(r#"{"mode":"manager"}"#, &state_dir).unwrap();
        assert_eq!(catalog.entries.len(), 1, "tool must not be listed as a mod");
        assert_eq!(catalog.entries[0].id, "fake-mod");

        let page = fetch_mod_page(r#"{"mode":"manager"}"#, &state_dir, "fake-mod").unwrap();
        assert!(
            page.notes.iter().any(
                |n| n == "Requires fake-tool (installed automatically, currently 0.9.0)."
            ),
            "expected a dependency note, got: {:?}",
            page.notes
        );
    }

    /// A mod installed to two copies of one game: the page lists both
    /// copies with their own state, and the catalog aggregates.
    #[test]
    fn two_copies_of_one_game() {
        let tmp = tempfile::tempdir().unwrap();
        let state_dir = tmp.path().join("state");
        let store = StateStore::open(Some(state_dir.clone())).unwrap();
        let base = InstalledState {
            id: "fake-mod".into(),
            kind: "mod".into(),
            version: "1.0.0".into(),
            channel: "stable".into(),
            game: "fake-game".into(),
            files: Vec::new(),
            uninstall_steps: Vec::new(),
            user_data_paths: Vec::new(),
            cleanup_legacy_paths: Vec::new(),
            dependencies: Vec::new(),
            dependents: Vec::new(),
            roots: Vec::new(),
            game_dir: tmp.path().join("steam-copy"),
            user_data: tmp.path().join("ud"),
            distribution: "steam".into(),
            game_paths: BTreeMap::new(),
            settings: None,
            settings_file: None,
            actions: Vec::new(),
            launch: Vec::new(),
            steam_app_id: None,
        };
        store.save(&base).unwrap();
        store
            .save(&InstalledState {
                version: "1.1.0".into(),
                game_dir: tmp.path().join("epic-copy"),
                distribution: "epic".into(),
                ..base.clone()
            })
            .unwrap();
        let state_dir = state_dir.to_string_lossy().into_owned();

        let page = fetch_mod_page(r#"{"mode":"manager"}"#, &state_dir, "fake-mod").unwrap();
        assert_eq!(page.copies.len(), 3);
        let steam = page.copies.iter().find(|c| c.distribution == "steam").unwrap();
        let epic = page.copies.iter().find(|c| c.distribution == "epic").unwrap();
        assert_eq!(steam.installed_version, "1.0.0");
        assert_eq!(epic.installed_version, "1.1.0");
        assert!(steam.label.starts_with("Steam copy, installed 1.0.0,"), "{}", steam.label);
        assert!(epic.label.starts_with("Epic copy, installed 1.1.0,"), "{}", epic.label);

        let catalog = fetch_catalog(r#"{"mode":"manager"}"#, &state_dir).unwrap();
        assert_eq!(catalog.entries.len(), 1);
        assert_eq!(catalog.entries[0].status, "Installed for 2 copies (versions differ)");

        // Copy-addressed operations need the dir once there are two.
        assert!(apply_setting(&state_dir, "fake-game", "", "fake-mod", "x", "y").is_err());
    }

    /// Branch channels declared in the manifest surface on the page for
    /// the GUI's version picker; release channels do not (releases are
    /// listed directly).
    #[test]
    fn branch_channels_listed_on_mod_page() {
        let tmp = tempfile::tempdir().unwrap();
        let packages = tmp.path().join("packages");
        std::fs::create_dir_all(&packages).unwrap();
        std::fs::write(
            packages.join("fake-game.json"),
            serde_json::json!({
                "manifestVersion": 1, "kind": "game", "id": "fake-game", "name": "Fake Game",
                "detect": { "markers": ["Fake.exe"] },
                "userData": { loadstone_core::context::current_platform(): "${localAppData}/FakeGame" }
            })
            .to_string(),
        )
        .unwrap();
        std::fs::write(
            packages.join("fake-mod.json"),
            serde_json::json!({
                "manifestVersion": 1, "id": "fake-mod", "name": "Fake Mod",
                "description": "d", "authors": ["a"], "game": "fake-game",
                "channels": {
                    "stable": { "source": "release" },
                    "dev": { "source": "branch", "branch": "main" }
                },
                "install": [ { "step": "extract-archive",
                               "routes": [ { "from": "**", "to": "${gameDir}" } ] } ]
            })
            .to_string(),
        )
        .unwrap();
        let profile = serde_json::json!({
            "mode": "manager",
            "registries": [packages.to_string_lossy()]
        })
        .to_string();
        let state_dir = tmp.path().join("state").to_string_lossy().into_owned();

        let page = fetch_mod_page(&profile, &state_dir, "fake-mod").unwrap();
        assert_eq!(page.channels.len(), 1, "only branch channels are listed");
        assert_eq!(page.channels[0].id, "dev");
        assert!(
            page.channels[0].label.contains("main"),
            "label names the branch: {}",
            page.channels[0].label
        );
    }
}
