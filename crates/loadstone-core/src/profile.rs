//! Distribution profiles: one binary, three shapes.
//!
//! The same client can be a full mod manager, a registry-pinned manager, or
//! a branded single-mod installer. Which one is decided by a small JSON
//! profile resolved at startup, first match wins:
//!
//! 1. a profile embedded at compile time (`LOADSTONE_EMBED_PROFILE`) — a
//!    developer's self-contained branded installer;
//! 2. a `loadstone.json` file next to the executable;
//! 3. the built-in default: full manager.

use std::path::Path;

use anyhow::{Context as _, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum ProfileMode {
    /// Browse and manage everything reachable through the registries.
    #[default]
    Manager,
    /// Present exactly one mod: the standalone-installer experience.
    SingleMod,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Profile {
    #[serde(default)]
    pub mode: ProfileMode,
    /// Window/product title override (e.g. "Blindfold Installer").
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub title: Option<String>,
    /// Registries to resolve packages from, innermost first. Each entry is
    /// `github:owner/repo` or a local directory path.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub registries: Vec<String>,
    /// single-mod mode: the pinned package id.
    #[serde(default, rename = "mod", skip_serializing_if = "Option::is_none")]
    pub mod_id: Option<String>,
    /// When true the user cannot add registries in the UI (a curated build).
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    pub lock_registries: bool,
}

/// The community registry a bare binary points at when no profile says
/// otherwise, so a stock download works out of the box.
pub const DEFAULT_REGISTRY: &str = "github:bradjrenshaw/loadstone-registry";

impl Profile {
    /// Resolve the active profile. `embedded` is the compile-time profile
    /// text (if the binary was built with one); `exe_dir` is where to look
    /// for the sidecar file.
    pub fn load(embedded: Option<&str>, exe_dir: Option<&Path>) -> Result<Profile> {
        if let Some(text) = embedded {
            let trimmed = text.trim();
            if !trimmed.is_empty() && trimmed != "null" {
                return serde_json::from_str(trimmed.trim_start_matches('\u{feff}'))
                    .context("embedded profile does not parse");
            }
        }
        if let Some(dir) = exe_dir {
            let sidecar = dir.join("loadstone.json");
            if sidecar.is_file() {
                let text = std::fs::read_to_string(&sidecar)
                    .with_context(|| format!("failed to read {}", sidecar.display()))?;
                return serde_json::from_str(text.trim_start_matches('\u{feff}'))
                    .with_context(|| format!("{} does not parse", sidecar.display()));
            }
        }
        // No profile anywhere: the stock manager pointed at the community
        // registry. An explicit profile that lists no registries keeps its
        // empty list — curated builds may strip registries on purpose.
        Ok(Profile {
            registries: vec![DEFAULT_REGISTRY.to_string()],
            ..Profile::default()
        })
    }

    pub fn validate(&self) -> Result<()> {
        if self.mode == ProfileMode::SingleMod && self.mod_id.is_none() {
            anyhow::bail!("single-mod profile must name a \"mod\"");
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn embedded_beats_sidecar_beats_default() {
        let tmp = tempfile::tempdir().unwrap();
        std::fs::write(
            tmp.path().join("loadstone.json"),
            r#"{ "mode": "manager", "title": "Sidecar" }"#,
        )
        .unwrap();

        let embedded = r#"{ "mode": "single-mod", "mod": "blindfold", "title": "Embedded" }"#;
        let p = Profile::load(Some(embedded), Some(tmp.path())).unwrap();
        assert_eq!(p.mode, ProfileMode::SingleMod);
        assert_eq!(p.title.as_deref(), Some("Embedded"));
        p.validate().unwrap();

        let p = Profile::load(Some("null"), Some(tmp.path())).unwrap();
        assert_eq!(p.title.as_deref(), Some("Sidecar"));

        // Nothing anywhere: the stock manager with the community registry.
        let empty = tempfile::tempdir().unwrap();
        let p = Profile::load(None, Some(empty.path())).unwrap();
        assert_eq!(p.mode, ProfileMode::Manager);
        assert_eq!(p.registries, vec![DEFAULT_REGISTRY.to_string()]);

        // An explicit profile without registries deliberately has none.
        let p = Profile::load(Some(r#"{ "mode": "manager" }"#), None).unwrap();
        assert!(p.registries.is_empty());
    }

    #[test]
    fn single_mod_requires_mod_id() {
        let p: Profile = serde_json::from_str(r#"{ "mode": "single-mod" }"#).unwrap();
        assert!(p.validate().is_err());
    }
}
