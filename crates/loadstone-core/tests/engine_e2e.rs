//! Offline end-to-end engine test: a fake game, a fabricated release zip,
//! install → update → uninstall, all through the public engine API.
//! Mirrors the flow the CLI drives, minus the network.

use std::collections::BTreeMap;
use std::io::{Cursor, Write};
use std::path::PathBuf;

use loadstone_core::context::InstallContext;
use loadstone_core::engine::{self, EngineUi, InstallPlan, RetryChoice};
use loadstone_core::release::sha256_bytes;
use loadstone_core::track::StateStore;
use loadstone_core::types::{GameManifest, ProjectManifest, Step};

struct SilentUi;

impl EngineUi for SilentUi {
    fn log(&mut self, _message: &str) {}
    fn progress(&mut self, _percent: u32) {}
    fn confirm(&mut self, _message: &str) -> bool {
        true
    }
    fn retry_skip_cancel(&mut self, _message: &str) -> RetryChoice {
        RetryChoice::Cancel
    }
    fn pick_directory(&mut self, _prompt: &str, _suggest: Option<&str>) -> Option<PathBuf> {
        None
    }
}

fn make_zip(entries: &[(&str, &[u8])]) -> Vec<u8> {
    let mut buf = Vec::new();
    {
        let cursor = Cursor::new(&mut buf);
        let mut writer = zip::ZipWriter::new(cursor);
        let options = zip::write::SimpleFileOptions::default();
        for (name, data) in entries {
            writer.start_file(name.to_string(), options).unwrap();
            writer.write_all(data).unwrap();
        }
        writer.finish().unwrap();
    }
    buf
}

fn game() -> GameManifest {
    serde_json::from_value(serde_json::json!({
        "manifestVersion": 1,
        "kind": "game",
        "id": "balatro",
        "name": "Balatro",
        "detect": { "markers": ["Balatro.exe"] },
        "userData": { loadstone_core::context::current_platform(): "unused-when-overridden" },
        "paths": { "mods": "${userData}/Mods" }
    }))
    .unwrap()
}

fn mod_manifest() -> ProjectManifest {
    serde_json::from_value(serde_json::json!({
        "manifestVersion": 1,
        "id": "blindfold",
        "name": "Blindfold",
        "description": "test",
        "authors": ["t"],
        "game": "balatro",
        "install": [
            { "step": "extract-archive",
              "routes": [ { "from": "Blindfold/**", "to": "${game.mods}/Blindfold" } ] },
            { "step": "expect",
              "checks": [ { "fileExists": "${game.mods}/Blindfold/lovely.toml",
                            "message": "payload missing" } ] }
        ],
        "userData": ["${userData}/blindfold_settings.lua"]
    }))
    .unwrap()
}

fn steps_of(manifest: &ProjectManifest) -> (&[Step], &[Step]) {
    (&manifest.install, &manifest.uninstall)
}

#[test]
fn install_update_uninstall_roundtrip() {
    let tmp = tempfile::tempdir().unwrap();
    let game_dir = tmp.path().join("game");
    let user_data = tmp.path().join("appdata").join("Balatro");
    std::fs::create_dir_all(&game_dir).unwrap();
    std::fs::write(game_dir.join("Balatro.exe"), b"fake").unwrap();

    let store = StateStore::open(Some(tmp.path().join("state"))).unwrap();
    let game = game();
    let manifest = mod_manifest();
    let mut ui = SilentUi;

    // --- v1 install ---
    let zip_v1 = make_zip(&[
        ("Blindfold/lovely.toml", b"[manifest]"),
        ("Blindfold/core.lua", b"-- v1"),
        ("Blindfold/old_module.lua", b"-- removed in v2"),
        ("version.dll", b"ignored by routing"),
    ]);
    let sha_v1 = sha256_bytes(&zip_v1);
    let mut ctx = InstallContext::build(&game, game_dir.clone(), Some(user_data.clone()), "steam".into()).unwrap();
    let (install_steps, uninstall_steps) = steps_of(&manifest);
    let state = engine::install(
        &store,
        &mut ctx,
        &InstallPlan {
            manifest: &manifest,
            game_id: "balatro".into(),
            version: "1.0.0".into(),
            channel: "stable".into(),
            install_steps,
            uninstall_steps,
            user_data_decl: &manifest.user_data,
            artifact: &zip_v1,
            expected_sha256: Some(&sha_v1),
            keep_existing: false,
            dependent_of: None,
        },
        &mut ui,
    )
    .unwrap();
    assert_eq!(state.files.len(), 3);
    let mods = user_data.join("Mods").join("Blindfold");
    assert!(mods.join("old_module.lua").exists());
    assert!(!game_dir.join("version.dll").exists(), "unrouted entries are skipped");

    // A wrong hash refuses to install and leaves the previous version alone.
    let bad = engine::install(
        &store,
        &mut ctx,
        &InstallPlan {
            manifest: &manifest,
            game_id: "balatro".into(),
            version: "9.9.9".into(),
            channel: "stable".into(),
            install_steps,
            uninstall_steps,
            user_data_decl: &manifest.user_data,
            artifact: &zip_v1,
            expected_sha256: Some("00000000000000000000000000000000000000000000000000000000deadbeef"),
            keep_existing: false,
            dependent_of: None,
        },
        &mut ui,
    );
    assert!(bad.is_err());
    assert!(mods.join("core.lua").exists(), "failed verify must not touch the install");
    assert_eq!(store.load("balatro", "blindfold").unwrap().unwrap().version, "1.0.0");

    // --- v2 update drops old_module.lua; stale file must disappear ---
    let zip_v2 = make_zip(&[
        ("Blindfold/lovely.toml", b"[manifest]"),
        ("Blindfold/core.lua", b"-- v2"),
    ]);
    let sha_v2 = sha256_bytes(&zip_v2);
    engine::install(
        &store,
        &mut ctx,
        &InstallPlan {
            manifest: &manifest,
            game_id: "balatro".into(),
            version: "2.0.0".into(),
            channel: "stable".into(),
            install_steps,
            uninstall_steps,
            user_data_decl: &manifest.user_data,
            artifact: &zip_v2,
            expected_sha256: Some(&sha_v2),
            keep_existing: false,
            dependent_of: None,
        },
        &mut ui,
    )
    .unwrap();
    assert!(!mods.join("old_module.lua").exists(), "stale files removed on update");
    assert_eq!(std::fs::read(mods.join("core.lua")).unwrap(), b"-- v2");

    // --- uninstall with purge ---
    std::fs::write(user_data.join("blindfold_settings.lua"), b"prefs").unwrap();
    let state = store.load("balatro", "blindfold").unwrap().unwrap();
    engine::uninstall(&store, &state, Some(true), &mut ui).unwrap();
    assert!(!mods.exists(), "mod dir pruned");
    assert!(!user_data.join("blindfold_settings.lua").exists(), "settings purged");
    assert!(game_dir.join("Balatro.exe").exists(), "game files untouched");
    assert!(store.load("balatro", "blindfold").unwrap().is_none());
}

#[test]
fn tool_refuses_uninstall_while_needed() {
    let tmp = tempfile::tempdir().unwrap();
    let game_dir = tmp.path().join("game");
    std::fs::create_dir_all(&game_dir).unwrap();
    let store = StateStore::open(Some(tmp.path().join("state"))).unwrap();

    let tool: ProjectManifest = serde_json::from_value(serde_json::json!({
        "manifestVersion": 1,
        "kind": "tool",
        "id": "lovely-injector",
        "name": "Lovely",
        "description": "t",
        "authors": ["t"],
        "conflictPolicy": "keep-newer",
        "install": [
            { "step": "extract-archive",
              "routes": [ { "from": "version.dll", "to": "${gameDir}/version.dll" } ] }
        ]
    }))
    .unwrap();

    let zip = make_zip(&[("version.dll", b"lovely")]);
    let sha = sha256_bytes(&zip);
    let mut ctx = InstallContext::build(&game(), game_dir.clone(), Some(tmp.path().join("ud")), "steam".into()).unwrap();
    let mut ui = SilentUi;
    let state = engine::install(
        &store,
        &mut ctx,
        &InstallPlan {
            manifest: &tool,
            game_id: "balatro".into(),
            version: "0.9.0".into(),
            channel: "pinned".into(),
            install_steps: &tool.install,
            uninstall_steps: &tool.uninstall,
            user_data_decl: &[],
            artifact: &zip,
            expected_sha256: Some(&sha),
            keep_existing: true,
            dependent_of: Some("blindfold".into()),
        },
        &mut ui,
    )
    .unwrap();
    assert_eq!(state.dependents, vec!["blindfold".to_string()]);
    assert!(engine::uninstall(&store, &state, Some(false), &mut ui).is_err());

    // After the dependent releases its claim, removal works.
    let mut freed = state.clone();
    freed.dependents.clear();
    store.save(&freed).unwrap();
    engine::uninstall(&store, &freed, Some(false), &mut ui).unwrap();
    assert!(!game_dir.join("version.dll").exists());
}
