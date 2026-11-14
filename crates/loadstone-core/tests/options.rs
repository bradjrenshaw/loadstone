//! Install options (SPEC 11.1) through the full install path: options pick
//! artifacts and steps, later installs keep the answers, "change options"
//! asks again, and bad values are refused.

use std::io::{Cursor, Write};
use std::path::{Path, PathBuf};

use loadstone_core::engine::{EngineUi, RetryChoice};
use loadstone_core::ops::{self, InstallOptions};
use loadstone_core::release::sha256_bytes;
use loadstone_core::track::StateStore;

#[derive(Default)]
struct ChoosingUi {
    /// Index answered to every choose() call; None cancels.
    answer: Option<usize>,
    asked: Vec<(String, usize)>,
}

impl EngineUi for ChoosingUi {
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
    fn choose(&mut self, id: &str, _prompt: &str, choices: &[String], default: usize) -> Option<usize> {
        assert_eq!(choices.len(), 2);
        self.asked.push((id.to_string(), default));
        self.answer
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

struct Fixture {
    _tmp: tempfile::TempDir,
    scope: PathBuf,
    release: PathBuf,
    game_dir: PathBuf,
    user_data: PathBuf,
    state_dir: PathBuf,
}

fn write_json(path: &Path, value: serde_json::Value) {
    std::fs::write(path, serde_json::to_string_pretty(&value).unwrap()).unwrap();
}

fn fixture() -> Fixture {
    let tmp = tempfile::tempdir().unwrap();
    let scope = tmp.path().join("loadstone-packages");
    let releases = tmp.path().join("releases");
    let game_dir = tmp.path().join("game");
    for d in [&scope, &releases, &game_dir] {
        std::fs::create_dir_all(d).unwrap();
    }
    std::fs::write(game_dir.join("CivilizationV.exe"), b"exe").unwrap();

    write_json(&scope.join("civ5.json"), serde_json::json!({
        "manifestVersion": 1, "kind": "game", "id": "civ5", "name": "Civilization V",
        "detect": { "markers": ["CivilizationV.exe"] },
        "userData": { "windows": "${documents}/civ5", "macos": "${home}/civ5", "linux": "${home}/civ5" }
    }));
    let options = serde_json::json!([
        { "id": "profile", "label": "Who is playing?", "default": "blind",
          "choices": [ { "value": "blind", "label": "A blind player" },
                       { "value": "sighted", "label": "A sighted partner" } ] }
    ]);
    let install = serde_json::json!([
        { "step": "extract-archive", "routes": [ { "from": "**", "to": "${gameDir}" } ] },
        { "step": "extract-archive", "artifact": "profile-pack", "routes": [ { "from": "**", "to": "${gameDir}" } ] },
        { "step": "ensure-dirs", "when": { "option": { "profile": "blind" } }, "paths": ["${gameDir}/blind-only-dir"] }
    ]);
    write_json(&scope.join("civ-v-access.json"), serde_json::json!({
        "manifestVersion": 1, "id": "civ-v-access", "name": "Civ V Access", "description": "t",
        "authors": ["t"], "game": "civ5", "options": options, "install": install
    }));

    let zips = [
        ("base.zip", make_zip(&[("base.txt", b"base")])),
        ("blind.zip", make_zip(&[("profile-blind.txt", b"blind")])),
        ("sighted.zip", make_zip(&[("profile-sighted.txt", b"sighted")])),
    ];
    for (name, data) in &zips {
        std::fs::write(releases.join(name), data).unwrap();
    }
    let sha = |i: usize| sha256_bytes(&zips[i].1);
    let release = releases.join("loadstone-release.json");
    write_json(&release, serde_json::json!({
        "manifestVersion": 1, "id": "civ-v-access", "version": "2.4.0", "game": "civ5",
        "artifacts": [
            { "file": "base.zip", "sha256": sha(0) },
            { "file": "blind.zip", "sha256": sha(1), "id": "profile-pack", "when": { "option": { "profile": "blind" } } },
            { "file": "sighted.zip", "sha256": sha(2), "id": "profile-pack", "when": { "option": { "profile": "sighted" } } }
        ],
        "options": options,
        "install": install
    }));
    let user_data = tmp.path().join("ud");
    let state_dir = tmp.path().join("state");
    Fixture { scope, release, game_dir, user_data, state_dir, _tmp: tmp }
}

fn opts(fx: &Fixture) -> InstallOptions {
    InstallOptions {
        id: Some("civ-v-access".into()),
        scopes: vec![fx.scope.clone()],
        game_dir: Some(fx.game_dir.clone()),
        user_data: Some(fx.user_data.clone()),
        state_dir: Some(fx.state_dir.clone()),
        local_release: Some(fx.release.clone()),
        ..Default::default()
    }
}

fn recorded_profile(fx: &Fixture) -> String {
    let store = StateStore::open(Some(fx.state_dir.clone())).unwrap();
    let state = store.load("civ5", "civ-v-access", &fx.game_dir).unwrap().unwrap();
    state.options["profile"].clone()
}

#[test]
fn options_choose_artifacts_and_steps_and_are_remembered() {
    let fx = fixture();

    // First install asks; answering index 1 picks the sighted pack.
    let mut ui = ChoosingUi { answer: Some(1), ..Default::default() };
    ops::install(&opts(&fx), &mut ui).unwrap();
    assert_eq!(ui.asked, vec![("profile".to_string(), 0)], "asked once, default preselected");
    assert!(fx.game_dir.join("base.txt").exists());
    assert!(fx.game_dir.join("profile-sighted.txt").exists());
    assert!(!fx.game_dir.join("profile-blind.txt").exists());
    assert!(!fx.game_dir.join("blind-only-dir").exists());
    assert_eq!(recorded_profile(&fx), "sighted");

    // Reinstalling keeps the answer without asking.
    let mut ui = ChoosingUi::default();
    ops::install(&opts(&fx), &mut ui).unwrap();
    assert!(ui.asked.is_empty());
    assert!(fx.game_dir.join("profile-sighted.txt").exists());

    // Changing options asks again with the current answer preselected.
    let mut ui = ChoosingUi { answer: Some(0), ..Default::default() };
    ops::install(&InstallOptions { ask_options: true, ..opts(&fx) }, &mut ui).unwrap();
    assert_eq!(ui.asked, vec![("profile".to_string(), 1)]);
    assert!(fx.game_dir.join("profile-blind.txt").exists());
    assert!(!fx.game_dir.join("profile-sighted.txt").exists(), "the other pack's files are gone");
    assert!(fx.game_dir.join("blind-only-dir").is_dir());
    assert_eq!(recorded_profile(&fx), "blind");
}

#[test]
fn explicit_values_skip_the_question_and_bad_ones_are_refused() {
    let fx = fixture();
    let mut ui = ChoosingUi::default();
    let mut o = opts(&fx);
    o.option_values.insert("profile".into(), "sighted".into());
    ops::install(&o, &mut ui).unwrap();
    assert!(ui.asked.is_empty());
    assert_eq!(recorded_profile(&fx), "sighted");

    let mut bad = opts(&fx);
    bad.option_values.insert("profile".into(), "pirate".into());
    let err = ops::install(&bad, &mut ChoosingUi::default()).unwrap_err();
    assert!(format!("{err:#}").contains("not a choice"), "{err:#}");

    let mut unknown = opts(&fx);
    unknown.option_values.insert("state".into(), "vp".into());
    let err = ops::install(&unknown, &mut ChoosingUi::default()).unwrap_err();
    assert!(format!("{err:#}").contains("not an install option"), "{err:#}");
}

#[test]
fn cancelling_the_question_cancels_the_install() {
    let fx = fixture();
    let mut ui = ChoosingUi { answer: None, ..Default::default() };
    assert!(ops::install(&opts(&fx), &mut ui).is_err());
    assert!(!fx.game_dir.join("base.txt").exists());
}

#[test]
fn the_validator_checks_options_and_their_uses() {
    use loadstone_core::validate::{validate_value, ValidationContext};
    let doc = serde_json::json!({
        "manifestVersion": 1, "kind": "tool", "id": "t", "name": "T", "description": "d", "authors": ["a"],
        "options": [
            { "id": "state", "label": "State", "default": "nope",
              "choices": [ { "value": "vp", "label": "VP" }, { "value": "vp", "label": "again" } ] }
        ],
        "install": [
            { "step": "ensure-dirs", "paths": ["${gameDir}/x"], "when": { "option": { "state": "cp" } } },
            { "step": "ensure-dirs", "paths": ["${gameDir}/y"], "when": { "not": { "option": { "mode": "a" } } } }
        ]
    });
    let result = validate_value(&doc, &ValidationContext::default());
    let errors: Vec<String> = result
        .diagnostics
        .iter()
        .filter(|d| d.severity == loadstone_core::validate::Severity::Error)
        .map(|d| d.message.clone())
        .collect();
    let joined = errors.join("\n");
    assert!(joined.contains("duplicate value \"vp\""), "{joined}");
    assert!(joined.contains("\"nope\" is not one of the choices"), "{joined}");
    assert!(joined.contains("\"cp\" is not a choice of option \"state\""), "{joined}");
    assert!(joined.contains("\"mode\" is not a declared install option"), "{joined}");
}
