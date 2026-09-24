//! The two features that make Loadstone the launcher on macOS: the
//! `merge-universal-binary` step (one injector for native and Rosetta
//! launches) and the `launch` step list (`run` / `open-url`).

use std::collections::BTreeMap;
use std::path::Path;

use loadstone_core::context::{current_platform, InstallContext};
use loadstone_core::engine::{self, Artifacts, EngineUi, RetryChoice};
use loadstone_core::track::{InstalledState, StateStore};
use loadstone_core::types::{Detect, GameManifest, Step};

struct QuietUi(Vec<String>);

impl EngineUi for QuietUi {
    fn log(&mut self, message: &str) {
        self.0.push(message.to_string());
    }
    fn progress(&mut self, _percent: u32) {}
    fn confirm(&mut self, _message: &str) -> bool {
        true
    }
    fn retry_skip_cancel(&mut self, _message: &str) -> RetryChoice {
        RetryChoice::Cancel
    }
    fn pick_directory(&mut self, _id: &str, _prompt: &str, _suggest: Option<&str>) -> Option<std::path::PathBuf> {
        None
    }
}

fn game() -> GameManifest {
    GameManifest {
        manifest_version: Some(1),
        kind: None,
        id: "g".into(),
        name: "G".into(),
        detect: serde_json::from_value(serde_json::json!({
            "markers": ["Game.app"],
            "steam": { "dirName": "G", "appId": 424242 }
        }))
        .unwrap(),
        user_data: BTreeMap::from([(current_platform().to_string(), "unused".into())]),
        paths: BTreeMap::new(),
    }
}

fn ctx(tmp: &Path) -> InstallContext {
    std::fs::create_dir_all(tmp.join("game")).unwrap();
    InstallContext::build(&game(), tmp.join("game"), Some(tmp.join("ud")), "steam".into()).unwrap()
}

fn steps(v: serde_json::Value) -> Vec<Step> {
    serde_json::from_value(v).unwrap()
}

/// A minimal thin Mach-O header: magic, cputype, cpusubtype, then junk.
fn thin_macho(cputype: u32, body: &[u8]) -> Vec<u8> {
    let mut v = Vec::new();
    v.extend_from_slice(&0xFEED_FACFu32.to_le_bytes());
    v.extend_from_slice(&cputype.to_le_bytes());
    v.extend_from_slice(&0u32.to_le_bytes());
    v.extend_from_slice(body);
    v
}

#[test]
fn merge_step_combines_slices_and_retires_the_inputs() {
    let tmp = tempfile::tempdir().unwrap();
    let mut ctx = ctx(tmp.path());
    let game_dir = tmp.path().join("game");
    std::fs::write(game_dir.join("lib-arm64.dylib"), thin_macho(0x0100_000C, b"arm")).unwrap();
    std::fs::write(game_dir.join("lib-x86_64.dylib"), thin_macho(0x0100_0007, b"intel")).unwrap();

    // As the install engine would see it: both thin files were written by
    // earlier extract steps and are tracked.
    let mut written = vec![game_dir.join("lib-arm64.dylib"), game_dir.join("lib-x86_64.dylib")];
    let mut ui = QuietUi(Vec::new());
    engine::run_steps(
        &mut ctx,
        &steps(serde_json::json!([{
            "step": "merge-universal-binary",
            "inputs": ["${gameDir}/lib-arm64.dylib", "${gameDir}/lib-x86_64.dylib"],
            "output": "${gameDir}/lib.dylib"
        }])),
        &Artifacts::default(),
        false,
        &mut written,
        &mut ui,
    )
    .unwrap();

    let fat = std::fs::read(game_dir.join("lib.dylib")).unwrap();
    assert_eq!(&fat[0..4], &0xCAFE_BABEu32.to_be_bytes());
    let slices = loadstone_core::macho::slices_of(&fat).unwrap();
    assert_eq!(slices.len(), 2);
    assert!(!game_dir.join("lib-arm64.dylib").exists());
    assert!(!game_dir.join("lib-x86_64.dylib").exists());
    // Tracking follows: only the merged file remains to uninstall.
    assert_eq!(written, vec![game_dir.join("lib.dylib")]);
}

#[test]
fn steam_app_id_token_resolves_from_the_game_package() {
    let tmp = tempfile::tempdir().unwrap();
    let ctx = ctx(tmp.path());
    assert_eq!(ctx.substitute("steam://rungameid/${steam.appId}").unwrap(), "steam://rungameid/424242");
}

#[test]
fn run_step_refuses_programs_outside_the_game() {
    let tmp = tempfile::tempdir().unwrap();
    let mut ctx = ctx(tmp.path());
    let mut ui = QuietUi(Vec::new());
    let err = engine::run_steps(
        &mut ctx,
        &steps(serde_json::json!([{ "step": "run", "program": "${home}/anything" }])),
        &Artifacts::default(),
        false,
        &mut Vec::new(),
        &mut ui,
    )
    .unwrap_err();
    assert!(err.to_string().contains("outside the game's folders"), "{err}");
}

#[test]
fn open_url_only_accepts_steam_links() {
    let tmp = tempfile::tempdir().unwrap();
    let mut ctx = ctx(tmp.path());
    let mut ui = QuietUi(Vec::new());
    let err = engine::run_steps(
        &mut ctx,
        &steps(serde_json::json!([{ "step": "open-url", "url": "https://example.com" }])),
        &Artifacts::default(),
        false,
        &mut Vec::new(),
        &mut ui,
    )
    .unwrap_err();
    assert!(err.to_string().contains("steam://"), "{err}");
}

#[cfg(unix)]
#[test]
fn launch_runs_the_frozen_steps_from_state() {
    use std::os::unix::fs::PermissionsExt;
    let tmp = tempfile::tempdir().unwrap();
    let game_dir = tmp.path().join("game");
    std::fs::create_dir_all(&game_dir).unwrap();
    // A stand-in for the game binary: records how it was started.
    let marker = game_dir.join("started.txt");
    let script = game_dir.join("fake-game.sh");
    std::fs::write(
        &script,
        format!("#!/bin/sh\necho \"$1 $INJECT $(pwd)\" > \"{}\"\n", marker.display()),
    )
    .unwrap();
    std::fs::set_permissions(&script, std::fs::Permissions::from_mode(0o755)).unwrap();

    let store = StateStore::open(Some(tmp.path().join("state"))).unwrap();
    let state = InstalledState {
        id: "m".into(),
        kind: "mod".into(),
        version: "1.0.0".into(),
        channel: "stable".into(),
        game: "g".into(),
        files: Vec::new(),
        uninstall_steps: Vec::new(),
        user_data_paths: Vec::new(),
        dependencies: Vec::new(),
        dependents: Vec::new(),
        roots: vec![game_dir.clone()],
        game_dir: game_dir.clone(),
        user_data: tmp.path().join("ud"),
        distribution: "steam".into(),
        game_paths: BTreeMap::new(),
        settings: None,
        settings_file: None,
        actions: Vec::new(),
        launch: steps(serde_json::json!([
            { "step": "run", "program": "${gameDir}/fake-game.sh", "args": ["--modded"],
              "cwd": "${gameDir}", "env": { "INJECT": "${gameDir}/lib.dylib" } },
            { "step": "notice", "message": "Game starting." }
        ])),
        steam_app_id: Some("424242".into()),
    };
    store.save(&state).unwrap();

    let mut ui = QuietUi(Vec::new());
    engine::launch(&store, &state, &mut ui).unwrap();
    // The child is detached; give it a moment.
    for _ in 0..50 {
        if marker.exists() {
            break;
        }
        std::thread::sleep(std::time::Duration::from_millis(20));
    }
    let recorded = std::fs::read_to_string(&marker).unwrap();
    assert!(recorded.starts_with("--modded "), "{recorded}");
    assert!(recorded.contains(&format!("{}/lib.dylib", game_dir.display())), "{recorded}");
    assert!(recorded.trim().ends_with(&game_dir.canonicalize().unwrap().display().to_string()), "{recorded}");
    assert!(ui.0.iter().any(|l| l == "Game starting."));
}

#[test]
fn launch_without_steps_is_an_error() {
    let tmp = tempfile::tempdir().unwrap();
    let store = StateStore::open(Some(tmp.path().join("state"))).unwrap();
    let state = InstalledState {
        id: "m".into(),
        kind: "mod".into(),
        version: "1.0.0".into(),
        channel: "stable".into(),
        game: "g".into(),
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
        settings: None,
        settings_file: None,
        actions: Vec::new(),
        launch: Vec::new(),
        steam_app_id: None,
    };
    let mut ui = QuietUi(Vec::new());
    let err = engine::launch(&store, &state, &mut ui).unwrap_err();
    assert!(err.to_string().contains("no launch steps"), "{err}");
}

#[test]
fn detect_default_still_parses() {
    // Guard: the Detect type keeps deserializing the plain form.
    let d: Detect = serde_json::from_value(serde_json::json!({ "markers": ["x"] })).unwrap();
    assert_eq!(d.markers, vec!["x"]);
}
