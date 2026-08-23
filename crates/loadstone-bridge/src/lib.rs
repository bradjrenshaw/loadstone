//! The C++ boundary (SPEC-adjacent: the GUI backend). Coarse and
//! message-shaped by design: the GUI asks for JSON models and receives
//! strings; all parsing, network, and filesystem work stays in Rust.
//!
//! Errors cross the bridge as C++ exceptions (`rust::Error`); the GUI shows
//! their message text.

use anyhow::{Context as _, Result};

#[cxx::bridge(namespace = "loadstone")]
mod ffi {
    extern "Rust" {
        /// Core library version (for the about line and smoke tests).
        fn core_version() -> String;

        /// Resolve the distribution profile: `embedded` is the compile-time
        /// profile JSON or "null"; the sidecar file and defaults are handled
        /// inside. Returns the resolved profile as JSON.
        fn resolve_profile(embedded: &str) -> Result<String>;

        /// Every installed package across all games, as a JSON array of
        /// { game, id, version, channel, kind }. `state_dir` overrides the
        /// state location ("" = default), mirroring the CLI flag.
        fn installed_json(state_dir: &str) -> Result<String>;

        /// Window/product title per the resolved profile.
        fn profile_title(embedded: &str) -> Result<String>;
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

pub fn resolve_profile(embedded: &str) -> Result<String> {
    let profile =
        loadstone_core::profile::Profile::load(Some(embedded), exe_dir().as_deref())?;
    profile.validate()?;
    serde_json::to_string(&profile).context("profile serialization")
}

pub fn profile_title(embedded: &str) -> Result<String> {
    let profile =
        loadstone_core::profile::Profile::load(Some(embedded), exe_dir().as_deref())?;
    Ok(profile
        .title
        .unwrap_or_else(|| "Loadstone Mod Manager".to_string()))
}

pub fn installed_json(state_dir: &str) -> Result<String> {
    let root = if state_dir.is_empty() {
        None
    } else {
        Some(std::path::PathBuf::from(state_dir))
    };
    let store = loadstone_core::track::StateStore::open(root)?;
    let mut out = Vec::new();
    for game in store.games()? {
        for state in store.list(&game)? {
            out.push(serde_json::json!({
                "game": state.game,
                "id": state.id,
                "version": state.version,
                "channel": state.channel,
                "kind": state.kind,
            }));
        }
    }
    serde_json::to_string(&out).context("state serialization")
}
