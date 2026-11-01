//! Installed-state tracking (SPEC §10). Every file the engine writes is
//! recorded per package per game; uninstall and updates work from this
//! record, so nothing depends on re-resolving manifests later.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use anyhow::{Context as _, Result};
use serde::{Deserialize, Serialize};

use crate::types::{Action, Settings, Step};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstalledState {
    pub id: String,
    pub kind: String,
    pub version: String,
    pub channel: String,
    pub game: String,
    /// Absolute paths of every file this package's install wrote.
    pub files: Vec<PathBuf>,
    /// Uninstall steps with all token paths pre-resolved at install time.
    #[serde(default)]
    pub uninstall_steps: Vec<Step>,
    /// Absolute user-data paths offered for purge on uninstall.
    #[serde(default)]
    pub user_data_paths: Vec<PathBuf>,
    /// Absolute `cleanupLegacy` paths, deleted again on uninstall.
    #[serde(default)]
    pub cleanup_legacy_paths: Vec<PathBuf>,
    /// Dependency ids this package pulled in (for dependent bookkeeping).
    #[serde(default)]
    pub dependencies: Vec<String>,
    /// For tools: ids of installed packages that depend on this tool here.
    #[serde(default)]
    pub dependents: Vec<String>,
    /// Roots that directory pruning must never remove (game dir, user data,
    /// game paths), captured at install time.
    #[serde(default)]
    pub roots: Vec<PathBuf>,
    pub game_dir: PathBuf,
    pub user_data: PathBuf,
    #[serde(default)]
    pub distribution: String,
    /// Resolved game paths, so actions and settings work offline from state.
    #[serde(default)]
    pub game_paths: BTreeMap<String, PathBuf>,
    /// The settings schema frozen at install time.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub settings: Option<Settings>,
    /// Resolved absolute path of the settings storage file.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub settings_file: Option<PathBuf>,
    /// Actions frozen at install time (paths unresolved; run with context).
    #[serde(default)]
    pub actions: Vec<Action>,
    /// Launch steps frozen at install time (paths unresolved; run with context).
    #[serde(default)]
    pub launch: Vec<Step>,
    /// The game's Steam app id from its game package, for `${steam.appId}`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub steam_app_id: Option<String>,
}

/// Stable identity of one game copy: hash of its canonical directory.
/// Two paths that name the same folder (case, trailing slash, 8.3 names)
/// must produce the same key, so canonicalize when the folder exists.
pub fn copy_key(game_dir: &Path) -> String {
    let canonical = std::fs::canonicalize(game_dir).unwrap_or_else(|_| game_dir.to_path_buf());
    let mut text = canonical.to_string_lossy().into_owned();
    if cfg!(windows) {
        text = text.to_lowercase();
    }
    use sha2::{Digest as _, Sha256};
    let digest = Sha256::digest(text.as_bytes());
    digest[..6].iter().map(|b| format!("{b:02x}")).collect()
}

/// Root of the state store. Overridable for tests/sandboxes.
///
/// Layout: `<root>/<game>/<copy-key>/<id>.json` — one subdirectory per game
/// copy (Steam, Epic, a hand-picked folder), so the same mod can be
/// installed to several copies of one game independently.
pub struct StateStore {
    root: PathBuf,
}

impl StateStore {
    pub fn open(root_override: Option<PathBuf>) -> Result<Self> {
        let root = match root_override {
            Some(r) => r,
            None => dirs::data_local_dir()
                .context("no local data directory on this system")?
                .join("Loadstone")
                .join("installed"),
        };
        let store = Self { root };
        store.migrate_flat_layout();
        Ok(store)
    }

    /// Move pre-copy-aware state files (`<game>/<id>.json`) into the copy
    /// subdirectory their recorded game_dir implies. Best effort: files
    /// that fail to read or parse stay where they are.
    fn migrate_flat_layout(&self) {
        let Ok(games) = std::fs::read_dir(&self.root) else { return };
        for game in games.filter_map(|e| e.ok()) {
            let game_dir = game.path();
            if !game_dir.is_dir() {
                continue;
            }
            let Ok(entries) = std::fs::read_dir(&game_dir) else { continue };
            for entry in entries.filter_map(|e| e.ok()) {
                let path = entry.path();
                if path.extension().and_then(|e| e.to_str()) != Some("json") {
                    continue;
                }
                let Ok(text) = std::fs::read_to_string(&path) else { continue };
                let Ok(state) = serde_json::from_str::<InstalledState>(&text) else { continue };
                let target_dir = game_dir.join(copy_key(&state.game_dir));
                if std::fs::create_dir_all(&target_dir).is_ok() {
                    let target = target_dir.join(format!("{}.json", state.id));
                    let _ = std::fs::rename(&path, &target);
                }
            }
        }
    }

    fn file(&self, game: &str, id: &str, game_dir: &Path) -> PathBuf {
        self.root
            .join(game)
            .join(copy_key(game_dir))
            .join(format!("{id}.json"))
    }

    fn read_state(path: &Path) -> Result<InstalledState> {
        let text = std::fs::read_to_string(path)
            .with_context(|| format!("failed to read {}", path.display()))?;
        serde_json::from_str(&text)
            .with_context(|| format!("{} is not a valid state file", path.display()))
    }

    /// The install of `id` in this specific game copy.
    pub fn load(&self, game: &str, id: &str, game_dir: &Path) -> Result<Option<InstalledState>> {
        let path = self.file(game, id, game_dir);
        if !path.exists() {
            return Ok(None);
        }
        Ok(Some(Self::read_state(&path)?))
    }

    /// Every copy's install of `id` for this game.
    pub fn find_all(&self, game: &str, id: &str) -> Result<Vec<InstalledState>> {
        Ok(self.list(game)?.into_iter().filter(|s| s.id == id).collect())
    }

    pub fn save(&self, state: &InstalledState) -> Result<()> {
        let path = self.file(&state.game, &state.id, &state.game_dir);
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)
                .with_context(|| format!("failed to create {}", parent.display()))?;
        }
        std::fs::write(&path, serde_json::to_string_pretty(state)?)
            .with_context(|| format!("failed to write {}", path.display()))
    }

    pub fn remove(&self, game: &str, id: &str, game_dir: &Path) -> Result<()> {
        let path = self.file(game, id, game_dir);
        if path.exists() {
            std::fs::remove_file(&path)
                .with_context(|| format!("failed to remove {}", path.display()))?;
            // Drop the copy directory once its last record is gone.
            if let Some(parent) = path.parent() {
                let _ = std::fs::remove_dir(parent);
            }
        }
        Ok(())
    }

    /// All installed packages for a game, across every copy (empty if none).
    pub fn list(&self, game: &str) -> Result<Vec<InstalledState>> {
        let dir = self.root.join(game);
        let mut out = Vec::new();
        if !dir.is_dir() {
            return Ok(out);
        }
        for copy in std::fs::read_dir(&dir)? {
            let copy_dir = copy?.path();
            if !copy_dir.is_dir() {
                continue;
            }
            for entry in std::fs::read_dir(&copy_dir)? {
                let path = entry?.path();
                if path.extension().and_then(|e| e.to_str()) == Some("json") {
                    if let Ok(state) = Self::read_state(&path) {
                        out.push(state);
                    }
                }
            }
        }
        out.sort_by(|a: &InstalledState, b: &InstalledState| {
            a.id.cmp(&b.id).then_with(|| a.game_dir.cmp(&b.game_dir))
        });
        Ok(out)
    }

    /// All games with any installed package.
    pub fn games(&self) -> Result<Vec<String>> {
        let mut out = Vec::new();
        if !self.root.is_dir() {
            return Ok(out);
        }
        for entry in std::fs::read_dir(&self.root)? {
            let entry = entry?;
            if entry.path().is_dir() {
                out.push(entry.file_name().to_string_lossy().into_owned());
            }
        }
        out.sort();
        Ok(out)
    }
}

/// Remove tracked files, then prune any directories that became empty (walking
/// up, stopping at the given roots). Missing files are not errors.
pub fn remove_tracked_files(files: &[PathBuf], stop_roots: &[PathBuf]) -> Vec<String> {
    let mut errors = Vec::new();
    let mut parents: Vec<PathBuf> = Vec::new();
    for file in files {
        match std::fs::remove_file(file) {
            Ok(()) => {}
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {}
            Err(e) => errors.push(format!("{}: {e}", file.display())),
        }
        if let Some(p) = file.parent() {
            parents.push(p.to_path_buf());
        }
    }
    parents.sort();
    parents.dedup();
    // Deepest first so nested empties collapse upward.
    parents.sort_by_key(|p| std::cmp::Reverse(p.components().count()));
    for mut dir in parents {
        loop {
            if stop_roots.iter().any(|r| &dir == r) {
                break;
            }
            match std::fs::remove_dir(&dir) {
                Ok(()) => {}
                Err(_) => break, // not empty, missing, or in use — all fine
            }
            match dir.parent() {
                Some(p) => dir = p.to_path_buf(),
                None => break,
            }
        }
    }
    errors
}

fn _assert_is_send(_: &Path) {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn state_roundtrip_and_list() {
        let tmp = tempfile::tempdir().unwrap();
        let store = StateStore::open(Some(tmp.path().to_path_buf())).unwrap();
        let state = InstalledState {
            id: "blindfold".into(),
            kind: "mod".into(),
            version: "1.0.9".into(),
            channel: "stable".into(),
            game: "balatro".into(),
            files: vec![tmp.path().join("a.lua")],
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
        store.save(&state).unwrap();
        let game_dir = state.game_dir.clone();
        let loaded = store.load("balatro", "blindfold", &game_dir).unwrap().unwrap();
        assert_eq!(loaded.version, "1.0.9");
        assert_eq!(store.list("balatro").unwrap().len(), 1);
        assert_eq!(store.games().unwrap(), vec!["balatro".to_string()]);

        // A second copy of the game holds its own independent install.
        let mut second = state.clone();
        second.game_dir = tmp.path().join("game-epic");
        second.version = "1.1.0".into();
        second.distribution = "epic".into();
        store.save(&second).unwrap();
        assert_eq!(store.list("balatro").unwrap().len(), 2);
        assert_eq!(store.find_all("balatro", "blindfold").unwrap().len(), 2);
        assert_eq!(
            store.load("balatro", "blindfold", &game_dir).unwrap().unwrap().version,
            "1.0.9"
        );
        assert_eq!(
            store.load("balatro", "blindfold", &second.game_dir).unwrap().unwrap().version,
            "1.1.0"
        );

        store.remove("balatro", "blindfold", &game_dir).unwrap();
        assert!(store.load("balatro", "blindfold", &game_dir).unwrap().is_none());
        assert_eq!(store.find_all("balatro", "blindfold").unwrap().len(), 1);
        store.remove("balatro", "blindfold", &second.game_dir).unwrap();
    }

    /// Pre-copy-aware state files migrate into copy subdirectories on open.
    #[test]
    fn flat_state_files_migrate_on_open() {
        let tmp = tempfile::tempdir().unwrap();
        let flat = tmp.path().join("balatro").join("blindfold.json");
        std::fs::create_dir_all(flat.parent().unwrap()).unwrap();
        let game_dir = tmp.path().join("game");
        std::fs::create_dir_all(&game_dir).unwrap();
        std::fs::write(
            &flat,
            serde_json::json!({
                "id": "blindfold", "kind": "mod", "version": "1.1.0",
                "channel": "stable", "game": "balatro", "files": [],
                "gameDir": game_dir, "userData": tmp.path().join("ud"),
            })
            .to_string(),
        )
        .unwrap();

        let store = StateStore::open(Some(tmp.path().to_path_buf())).unwrap();
        assert!(!flat.exists(), "flat file moved into the copy subdirectory");
        let loaded = store.load("balatro", "blindfold", &game_dir).unwrap().unwrap();
        assert_eq!(loaded.version, "1.1.0");
        assert_eq!(store.list("balatro").unwrap().len(), 1);
    }

    #[test]
    fn removal_prunes_empty_dirs_but_stops_at_roots() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path().join("Mods");
        let deep = root.join("Blindfold").join("lib");
        std::fs::create_dir_all(&deep).unwrap();
        let f1 = deep.join("prism.dll");
        let f2 = root.join("Blindfold").join("core.lua");
        std::fs::write(&f1, b"x").unwrap();
        std::fs::write(&f2, b"y").unwrap();
        // An untracked neighbor keeps its directory alive.
        let other = root.join("OtherMod");
        std::fs::create_dir_all(&other).unwrap();
        std::fs::write(other.join("keep.lua"), b"z").unwrap();

        let errors = remove_tracked_files(&[f1, f2], &[root.clone()]);
        assert!(errors.is_empty());
        assert!(!root.join("Blindfold").exists(), "emptied dirs are pruned");
        assert!(root.exists(), "stop root survives");
        assert!(other.join("keep.lua").exists());
    }
}
