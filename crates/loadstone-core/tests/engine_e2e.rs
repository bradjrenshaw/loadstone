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
    fn pick_directory(&mut self, _id: &str, _prompt: &str, _suggest: Option<&str>) -> Option<PathBuf> {
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
            cleanup_legacy: &manifest.cleanup_legacy,
            artifact: &zip_v1,
            artifact_id: None,
            expected_sha256: Some(&sha_v1),
            extra_artifacts: &[],
            launch: &[],
            keep_existing: false,
            dependent_of: None,
            settings: None,
            actions: &[],
            strip_top_level: false,
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
            cleanup_legacy: &manifest.cleanup_legacy,
            artifact: &zip_v1,
            artifact_id: None,
            expected_sha256: Some("00000000000000000000000000000000000000000000000000000000deadbeef"),
            extra_artifacts: &[],
            launch: &[],
            keep_existing: false,
            dependent_of: None,
            settings: None,
            actions: &[],
            strip_top_level: false,
        },
        &mut ui,
    );
    assert!(bad.is_err());
    assert!(mods.join("core.lua").exists(), "failed verify must not touch the install");
    assert_eq!(store.load("balatro", "blindfold", &game_dir).unwrap().unwrap().version, "1.0.0");

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
            cleanup_legacy: &manifest.cleanup_legacy,
            artifact: &zip_v2,
            artifact_id: None,
            expected_sha256: Some(&sha_v2),
            extra_artifacts: &[],
            launch: &[],
            keep_existing: false,
            dependent_of: None,
            settings: None,
            actions: &[],
            strip_top_level: false,
        },
        &mut ui,
    )
    .unwrap();
    assert!(!mods.join("old_module.lua").exists(), "stale files removed on update");
    assert_eq!(std::fs::read(mods.join("core.lua")).unwrap(), b"-- v2");

    // --- uninstall with purge ---
    std::fs::write(user_data.join("blindfold_settings.lua"), b"prefs").unwrap();
    let state = store.load("balatro", "blindfold", &game_dir).unwrap().unwrap();
    engine::uninstall(&store, &state, Some(true), &mut ui).unwrap();
    assert!(!mods.exists(), "mod dir pruned");
    assert!(!user_data.join("blindfold_settings.lua").exists(), "settings purged");
    assert!(game_dir.join("Balatro.exe").exists(), "game files untouched");
    assert!(store.load("balatro", "blindfold", &game_dir).unwrap().is_none());
}

/// The deploy-script scenario: Mods/Blindfold is a junction into a git
/// checkout. Installing over it would write into the checkout; the engine
/// must refuse instead. Windows-only (junction creation).
#[cfg(windows)]
#[test]
fn refuses_to_install_over_linked_dev_checkout() {
    let tmp = tempfile::tempdir().unwrap();
    let game_dir = tmp.path().join("game");
    let user_data = tmp.path().join("appdata").join("Balatro");
    let checkout = tmp.path().join("repo").join("src");
    let mods = user_data.join("Mods");
    std::fs::create_dir_all(&game_dir).unwrap();
    std::fs::create_dir_all(&checkout).unwrap();
    std::fs::create_dir_all(&mods).unwrap();
    std::fs::write(checkout.join("lovely.toml"), b"[manifest]").unwrap();

    // mklink /J creates a junction without elevation.
    let link = mods.join("Blindfold");
    let status = std::process::Command::new("cmd")
        .args(["/C", "mklink", "/J"])
        .arg(&link)
        .arg(&checkout)
        .output()
        .unwrap();
    assert!(status.status.success(), "junction creation failed");

    let store = StateStore::open(Some(tmp.path().join("state"))).unwrap();
    let manifest = mod_manifest();
    let zip = make_zip(&[
        ("Blindfold/lovely.toml", b"[manifest]"),
        ("Blindfold/core.lua", b"-- release"),
    ]);
    let sha = sha256_bytes(&zip);
    let mut ctx =
        InstallContext::build(&game(), game_dir, Some(user_data), "steam".into()).unwrap();
    let mut ui = SilentUi;
    let (install_steps, uninstall_steps) = steps_of(&manifest);
    let err = engine::install(
        &store,
        &mut ctx,
        &InstallPlan {
            manifest: &manifest,
            game_id: "balatro".into(),
            version: "1.0.0".into(),
            channel: "stable".into(),
            install_steps,
            uninstall_steps,
            user_data_decl: &[],
            cleanup_legacy: &[],
            artifact: &zip,
            artifact_id: None,
            expected_sha256: Some(&sha),
            extra_artifacts: &[],
            launch: &[],
            keep_existing: false,
            dependent_of: None,
            settings: None,
            actions: &[],
            strip_top_level: false,
        },
        &mut ui,
    )
    .unwrap_err();
    assert!(
        err.to_string().contains("development checkout"),
        "unexpected error: {err}"
    );
    // The checkout is untouched and the link still stands.
    assert!(checkout.join("lovely.toml").exists());
    assert!(!checkout.join("core.lua").exists());
    assert!(std::fs::symlink_metadata(&link).unwrap().file_type().is_symlink());
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
            cleanup_legacy: &[],
            artifact: &zip,
            artifact_id: None,
            expected_sha256: Some(&sha),
            extra_artifacts: &[],
            launch: &[],
            keep_existing: true,
            dependent_of: Some("blindfold".into()),
            settings: None,
            actions: &[],
            strip_top_level: false,
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

/// cleanupLegacy (SPEC §10): pre-manager leftovers go on install and again
/// on uninstall, but a file another installed package tracks is left alone,
/// and a path outside the mod's folders is never touched.
#[test]
fn cleanup_legacy_on_install_and_uninstall() {
    let tmp = tempfile::tempdir().unwrap();
    let game_dir = tmp.path().join("game");
    let user_data = tmp.path().join("appdata").join("Balatro");
    let outside = tmp.path().join("elsewhere.dll");
    std::fs::create_dir_all(game_dir.join("OldMod")).unwrap();
    std::fs::write(game_dir.join("Balatro.exe"), b"fake").unwrap();
    std::fs::write(game_dir.join("Tolk.dll"), b"legacy").unwrap();
    std::fs::write(game_dir.join("OldMod").join("old.lua"), b"legacy").unwrap();
    std::fs::write(game_dir.join("shared.dll"), b"another mod's").unwrap();
    std::fs::write(&outside, b"not ours").unwrap();

    let store = StateStore::open(Some(tmp.path().join("state"))).unwrap();
    let game = game();
    let mut ui = SilentUi;
    let mut ctx = InstallContext::build(&game, game_dir.clone(), Some(user_data.clone()), "steam".into()).unwrap();

    // Another package already tracks shared.dll.
    let other = mod_manifest_with_id("other");
    let zip_other = make_zip(&[("Blindfold/lovely.toml", b"[manifest]")]);
    let mut other_state = engine::install(
        &store,
        &mut ctx,
        &plan(&other, &zip_other, &[]),
        &mut ui,
    )
    .unwrap();
    other_state.files.push(game_dir.join("shared.dll"));
    store.save(&other_state).unwrap();

    let manifest = mod_manifest();
    let cleanup: Vec<String> = vec![
        "${gameDir}/Tolk.dll".into(),
        "${gameDir}/OldMod".into(),
        "${gameDir}/shared.dll".into(),
        "${gameDir}".into(),
        outside.to_string_lossy().into_owned(),
    ];
    let zip = make_zip(&[("Blindfold/lovely.toml", b"[manifest]")]);
    engine::install(&store, &mut ctx, &plan(&manifest, &zip, &cleanup), &mut ui).unwrap();
    assert!(!game_dir.join("Tolk.dll").exists(), "legacy file removed on install");
    assert!(!game_dir.join("OldMod").exists(), "legacy folder removed on install");
    assert!(game_dir.join("shared.dll").exists(), "another package's file kept");
    assert!(game_dir.join("Balatro.exe").exists(), "a root is never removed");
    assert!(outside.exists(), "paths outside the mod's folders are never removed");

    // A legacy installer run again later: uninstall cleans it up too.
    std::fs::write(game_dir.join("Tolk.dll"), b"legacy again").unwrap();
    let state = store.load("balatro", "blindfold", &game_dir).unwrap().unwrap();
    engine::uninstall(&store, &state, Some(false), &mut ui).unwrap();
    assert!(!game_dir.join("Tolk.dll").exists(), "legacy file removed on uninstall");
    assert!(game_dir.join("shared.dll").exists());
}

fn mod_manifest_with_id(id: &str) -> ProjectManifest {
    let mut m = mod_manifest();
    m.id = id.into();
    m
}

fn plan<'a>(manifest: &'a ProjectManifest, zip: &'a [u8], cleanup: &'a [String]) -> InstallPlan<'a> {
    InstallPlan {
        manifest,
        game_id: "balatro".into(),
        version: "1.0.0".into(),
        channel: "stable".into(),
        install_steps: &manifest.install,
        uninstall_steps: &manifest.uninstall,
        user_data_decl: &[],
        cleanup_legacy: cleanup,
        artifact: zip,
        artifact_id: None,
        expected_sha256: None,
        extra_artifacts: &[],
        launch: &[],
        keep_existing: false,
        dependent_of: None,
        settings: None,
        actions: &[],
        strip_top_level: false,
    }
}
