//! Preserved originals (SPEC 10.1) end to end: a Civilization V-shaped mod
//! that replaces game files, through install, update, a game update, and
//! uninstall; adoption of an earlier installer's backup; and rollback.

use std::io::{Cursor, Write};
use std::path::{Path, PathBuf};

use anyhow::Result;
use loadstone_core::context::InstallContext;
use loadstone_core::engine::{self, EngineUi, InstallPlan, RetryChoice};
use loadstone_core::release::sha256_bytes;
use loadstone_core::track::{InstalledState, StateStore};
use loadstone_core::types::{GameManifest, ProjectManifest};

struct SilentUi;

impl EngineUi for SilentUi {
    fn log(&mut self, _message: &str) {}
    fn progress(&mut self, _percent: u32) {}
    fn confirm(&mut self, _message: &str) -> bool {
        false
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
        let mut writer = zip::ZipWriter::new(Cursor::new(&mut buf));
        for (name, data) in entries {
            writer.start_file(name.to_string(), zip::write::SimpleFileOptions::default()).unwrap();
            writer.write_all(data).unwrap();
        }
        writer.finish().unwrap();
    }
    buf
}

fn game() -> GameManifest {
    serde_json::from_value(serde_json::json!({
        "manifestVersion": 1, "kind": "game", "id": "civ5", "name": "Civilization V",
        "detect": { "markers": ["CivilizationV.exe"] },
        "userData": { loadstone_core::context::current_platform(): "unused" }
    }))
    .unwrap()
}

fn civ_mod(extra_install: serde_json::Value) -> ProjectManifest {
    let mut install = vec![serde_json::json!({ "step": "extract-archive", "routes": [ { "from": "**", "to": "${gameDir}" } ] })];
    if let serde_json::Value::Array(more) = extra_install {
        install.extend(more);
    }
    serde_json::from_value(serde_json::json!({
        "manifestVersion": 1, "id": "civ-v-access", "name": "Civ V Access", "game": "civ5",
        "preserve": [
            { "path": "${gameDir}/lua51_Win32.dll", "as": "${gameDir}/lua51_original.dll" },
            "${gameDir}/Assets/DLC/Expansion2/CvGameCore_Expansion2.dll",
            "${gameDir}/Assets/DLC/Expansion2/Movies/*.bik"
        ],
        "install": install
    }))
    .unwrap()
}

struct Fixture {
    _tmp: tempfile::TempDir,
    game_dir: PathBuf,
    user_data: PathBuf,
    store: StateStore,
    state_root: PathBuf,
}

fn fixture() -> Fixture {
    let tmp = tempfile::tempdir().unwrap();
    let game_dir = tmp.path().join("Civilization V");
    let exp2 = game_dir.join("Assets").join("DLC").join("Expansion2");
    std::fs::create_dir_all(exp2.join("Movies")).unwrap();
    std::fs::write(game_dir.join("CivilizationV.exe"), b"exe").unwrap();
    std::fs::write(game_dir.join("lua51_Win32.dll"), b"stock lua").unwrap();
    std::fs::write(exp2.join("CvGameCore_Expansion2.dll"), b"stock core").unwrap();
    std::fs::write(exp2.join("Movies").join("intro.bik"), b"stock movie").unwrap();
    let state_root = tmp.path().join("state");
    let store = StateStore::open(Some(state_root.clone())).unwrap();
    let user_data = tmp.path().join("docs");
    Fixture { game_dir, user_data, store, state_root, _tmp: tmp }
}

fn install(fx: &Fixture, manifest: &ProjectManifest, version: &str, zip: &[u8]) -> Result<InstalledState> {
    let mut ctx = InstallContext::build(&game(), fx.game_dir.clone(), Some(fx.user_data.clone()), "steam".into())?;
    let sha = sha256_bytes(zip);
    engine::install(
        &fx.store,
        &mut ctx,
        &InstallPlan {
            manifest,
            game_id: "civ5".into(),
            version: version.into(),
            channel: "stable".into(),
            install_steps: &manifest.install,
            uninstall_steps: &manifest.uninstall,
            user_data_decl: &[],
            artifact: zip,
            artifact_id: None,
            expected_sha256: Some(&sha),
            extra_artifacts: &[],
            preserve: &manifest.preserve,
            keep_existing: false,
            dependent_of: None,
            settings: None,
            actions: &[],
            launch: &[],
            strip_top_level: false,
            cleanup_legacy: &[],
        },
        &mut SilentUi,
    )
}

fn read(path: &Path) -> String {
    String::from_utf8(std::fs::read(path).unwrap()).unwrap()
}

fn core(fx: &Fixture) -> PathBuf {
    fx.game_dir.join("Assets/DLC/Expansion2/CvGameCore_Expansion2.dll")
}

fn backups_dir(fx: &Fixture) -> PathBuf {
    fx.store.originals_dir("civ5", "civ-v-access", &fx.game_dir)
}

#[test]
fn replaced_files_come_back_and_game_updates_win() {
    let fx = fixture();
    let manifest = civ_mod(serde_json::json!([]));
    let v1 = make_zip(&[
        ("lua51_Win32.dll", b"proxy v1"),
        ("Assets/DLC/Expansion2/CvGameCore_Expansion2.dll", b"fork v1"),
        ("Assets/DLC/DLC_CivVAccess/CivVAccess.Civ5Pkg", b"payload"),
    ]);
    let state = install(&fx, &manifest, "1.0.0", &v1).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "proxy v1");
    assert_eq!(read(&fx.game_dir.join("lua51_original.dll")), "stock lua");
    assert_eq!(read(&core(&fx)), "fork v1");
    assert_eq!(state.originals.len(), 2, "the untouched movie needs no original");
    assert_eq!(state.files.len(), 1, "replaced game files are not plain tracked files");
    assert_eq!(std::fs::read_dir(backups_dir(&fx)).unwrap().count(), 1);
    assert_eq!(read(&fx.game_dir.join("Assets/DLC/Expansion2/Movies/intro.bik")), "stock movie");

    // An update restores, then replaces again: the originals stay stock.
    let v2 = make_zip(&[
        ("lua51_Win32.dll", b"proxy v2"),
        ("Assets/DLC/Expansion2/CvGameCore_Expansion2.dll", b"fork v2"),
        ("Assets/DLC/DLC_CivVAccess/CivVAccess.Civ5Pkg", b"payload"),
    ]);
    let state = install(&fx, &manifest, "2.0.0", &v2).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "proxy v2");
    assert_eq!(read(&fx.game_dir.join("lua51_original.dll")), "stock lua");
    assert_eq!(state.originals.len(), 2);

    // A game update replaces the engine DLL behind the mod's back.
    std::fs::write(core(&fx), b"stock core, patched").unwrap();

    engine::uninstall(&fx.store, &state, Some(false), &mut SilentUi).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert!(!fx.game_dir.join("lua51_original.dll").exists());
    assert_eq!(read(&core(&fx)), "stock core, patched", "a newer game file is kept");
    assert!(!fx.game_dir.join("Assets/DLC/DLC_CivVAccess").exists());
    assert!(!backups_dir(&fx).exists());
    assert!(fx.state_root.exists(), "pruning stops at the state store");
}

#[test]
fn switching_to_a_layout_that_leaves_a_file_alone_restores_it() {
    let fx = fixture();
    let manifest = civ_mod(serde_json::json!([]));
    let vanilla = make_zip(&[
        ("lua51_Win32.dll", b"proxy"),
        ("Assets/DLC/Expansion2/CvGameCore_Expansion2.dll", b"fork"),
    ]);
    install(&fx, &manifest, "1.0.0", &vanilla).unwrap();
    // Reinstall with a payload that brings no engine DLL (Vox Populi ships
    // its own): the stock DLL is back and nothing is recorded for it.
    let vp = make_zip(&[("lua51_Win32.dll", b"proxy")]);
    let state = install(&fx, &manifest, "1.0.0", &vp).unwrap();
    assert_eq!(read(&core(&fx)), "stock core");
    assert_eq!(state.originals.len(), 1);
}

#[test]
fn an_earlier_installers_kept_original_is_adopted() {
    let fx = fixture();
    // The old installer renamed the stock DLL and left its proxy in place.
    std::fs::write(fx.game_dir.join("lua51_original.dll"), b"stock lua").unwrap();
    std::fs::write(fx.game_dir.join("lua51_Win32.dll"), b"old installer proxy").unwrap();
    let manifest = civ_mod(serde_json::json!([]));
    let state = install(&fx, &manifest, "1.0.0", &make_zip(&[("lua51_Win32.dll", b"proxy")])).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_original.dll")), "stock lua", "not overwritten by the old proxy");
    engine::uninstall(&fx.store, &state, Some(false), &mut SilentUi).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert!(!fx.game_dir.join("lua51_original.dll").exists());

    // Adopted but not replaced this time: the old proxy goes, stock returns.
    std::fs::write(fx.game_dir.join("lua51_original.dll"), b"stock lua").unwrap();
    std::fs::write(fx.game_dir.join("lua51_Win32.dll"), b"old installer proxy").unwrap();
    let state = install(&fx, &manifest, "1.0.0", &make_zip(&[("Other/file.txt", b"x")])).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert!(!fx.game_dir.join("lua51_original.dll").exists());
    assert!(state.originals.is_empty());
}

#[test]
fn a_failed_install_puts_originals_back() {
    let fx = fixture();
    let manifest = civ_mod(serde_json::json!([
        { "step": "expect", "checks": [ { "fileExists": "${gameDir}/never.txt", "message": "boom" } ] }
    ]));
    let zip = make_zip(&[
        ("lua51_Win32.dll", b"proxy"),
        ("Assets/DLC/Expansion2/CvGameCore_Expansion2.dll", b"fork"),
    ]);
    let err = install(&fx, &manifest, "1.0.0", &zip).unwrap_err();
    assert!(format!("{err:#}").contains("boom"));
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert!(!fx.game_dir.join("lua51_original.dll").exists());
    assert_eq!(read(&core(&fx)), "stock core");
    assert!(!backups_dir(&fx).exists());
}

#[test]
fn a_deleted_game_file_is_restored_on_uninstall() {
    let fx = fixture();
    let manifest = civ_mod(serde_json::json!([
        { "step": "delete-files", "paths": ["${gameDir}/Assets/DLC/Expansion2/Movies/intro.bik"] }
    ]));
    let state = install(&fx, &manifest, "1.0.0", &make_zip(&[("Other/file.txt", b"x")])).unwrap();
    assert!(!fx.game_dir.join("Assets/DLC/Expansion2/Movies/intro.bik").exists());
    engine::uninstall(&fx.store, &state, Some(false), &mut SilentUi).unwrap();
    assert_eq!(read(&fx.game_dir.join("Assets/DLC/Expansion2/Movies/intro.bik")), "stock movie");
}

fn case_insensitive(dir: &Path) -> bool {
    dir.join("LUA51_WIN32.DLL").exists()
}

#[test]
fn an_archive_entry_differing_only_in_case_still_counts_as_replacing() {
    let fx = fixture();
    if !case_insensitive(&fx.game_dir) {
        return; // a case-sensitive file system keeps the two names apart
    }
    let manifest = civ_mod(serde_json::json!([]));
    let zip = make_zip(&[
        ("lua51_win32.dll", b"proxy"),
        ("assets/dlc/expansion2/cvgamecore_expansion2.dll", b"fork"),
    ]);
    let state = install(&fx, &manifest, "1.0.0", &zip).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "proxy");
    assert_eq!(read(&fx.game_dir.join("lua51_original.dll")), "stock lua");
    assert_eq!(read(&core(&fx)), "fork");
    assert_eq!(state.originals.len(), 2);
    assert!(state.files.is_empty(), "the replaced files are not tracked for plain deletion: {:?}", state.files);

    engine::uninstall(&fx.store, &state, Some(false), &mut SilentUi).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert!(!fx.game_dir.join("lua51_original.dll").exists());
    assert_eq!(read(&core(&fx)), "stock core");
}

#[cfg(unix)]
#[test]
fn a_settle_failure_on_the_second_file_rolls_back_both() {
    use loadstone_core::originals::{roll_back, settle, Pending};
    use loadstone_core::release::sha256_file;
    use std::os::unix::fs::PermissionsExt as _;

    let fx = fixture();
    let lua = fx.game_dir.join("lua51_Win32.dll");
    let kept = fx.game_dir.join("lua51_original.dll");
    let core_backup = backups_dir(&fx).join("1-CvGameCore_Expansion2.dll");
    std::fs::create_dir_all(backups_dir(&fx)).unwrap();
    let pending = vec![
        Pending { path: lua.clone(), backup: kept.clone(), adopted: false, before_sha256: sha256_file(&lua).unwrap() },
        Pending { path: core(&fx), backup: core_backup.clone(), adopted: false, before_sha256: sha256_file(&core(&fx)).unwrap() },
    ];
    std::fs::copy(&lua, &kept).unwrap();
    std::fs::copy(core(&fx), &core_backup).unwrap();
    // The steps replaced both; the second can't be read (antivirus, say).
    std::fs::write(&lua, b"proxy").unwrap();
    std::fs::write(core(&fx), b"fork").unwrap();
    std::fs::set_permissions(core(&fx), std::fs::Permissions::from_mode(0o000)).unwrap();
    if std::fs::read(core(&fx)).is_ok() {
        return; // running as root: permissions can't make the file unreadable
    }
    let written = vec![lua.clone(), core(&fx)];

    assert!(settle(&pending, &written).is_err());
    assert!(kept.is_file() && core_backup.is_file(), "settle removes nothing");

    std::fs::set_permissions(core(&fx), std::fs::Permissions::from_mode(0o644)).unwrap();
    roll_back(&pending, &written, &[fx.game_dir.clone(), fx.state_root.clone()]);
    assert_eq!(read(&lua), "stock lua");
    assert_eq!(read(&core(&fx)), "stock core");
    assert!(!kept.exists());
    assert!(!backups_dir(&fx).exists());
}

#[cfg(unix)]
#[test]
fn a_failed_state_save_rolls_back_and_a_retry_keeps_the_real_originals() {
    use std::os::unix::fs::PermissionsExt as _;

    let fx = fixture();
    let manifest = civ_mod(serde_json::json!([]));
    let zip = make_zip(&[
        ("lua51_Win32.dll", b"proxy"),
        ("Assets/DLC/Expansion2/CvGameCore_Expansion2.dll", b"fork"),
    ]);
    // Backups can still be written, but the state record can't be.
    let copy_dir = backups_dir(&fx).parent().unwrap().to_path_buf();
    std::fs::create_dir_all(backups_dir(&fx)).unwrap();
    std::fs::set_permissions(&copy_dir, std::fs::Permissions::from_mode(0o555)).unwrap();
    let failed = install(&fx, &manifest, "1.0.0", &zip);
    std::fs::set_permissions(&copy_dir, std::fs::Permissions::from_mode(0o755)).unwrap();
    if failed.is_ok() {
        return; // running as root: permissions don't stop the save
    }
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert_eq!(read(&core(&fx)), "stock core");
    assert!(!fx.game_dir.join("lua51_original.dll").exists());
    assert_eq!(std::fs::read_dir(backups_dir(&fx)).unwrap().count(), 0, "no stale backups left");
    assert!(fx.store.load("civ5", "civ-v-access", &fx.game_dir).unwrap().is_none());

    let state = install(&fx, &manifest, "1.0.0", &zip).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_original.dll")), "stock lua");
    engine::uninstall(&fx.store, &state, Some(false), &mut SilentUi).unwrap();
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert_eq!(read(&core(&fx)), "stock core");
}

#[test]
fn a_failure_after_the_steps_rolls_back() {
    let fx = fixture();
    let mut manifest = civ_mod(serde_json::json!([]));
    manifest.uninstall = serde_json::from_value(serde_json::json!([
        { "step": "delete-files", "paths": ["${noSuchToken}/x.txt"] }
    ]))
    .unwrap();
    let zip = make_zip(&[("lua51_Win32.dll", b"proxy"), ("Other/file.txt", b"x")]);
    assert!(install(&fx, &manifest, "1.0.0", &zip).is_err());
    assert_eq!(read(&fx.game_dir.join("lua51_Win32.dll")), "stock lua");
    assert!(!fx.game_dir.join("lua51_original.dll").exists());
    assert!(!fx.game_dir.join("Other").exists());
    assert!(fx.store.load("civ5", "civ-v-access", &fx.game_dir).unwrap().is_none());
}
