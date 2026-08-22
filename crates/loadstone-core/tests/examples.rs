//! The worked examples in examples/ must always validate cleanly — they are
//! the reference fixtures for the spec.
//!
//! Layout mirrors real repos: each examples/mod-repos/<name>/ is a mod repo
//! whose loadstone-packages/ directory is the innermost scope for its own
//! files; examples/community-registry/ is a registry of links plus
//! registry-hosted packages.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use loadstone_core::types::GameManifest;
use loadstone_core::validate::{validate_value, Severity, ValidationContext};

fn examples_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../../examples")
}

fn load(path: &Path) -> serde_json::Value {
    let text = std::fs::read_to_string(path)
        .unwrap_or_else(|e| panic!("read {}: {e}", path.display()));
    serde_json::from_str(&text).unwrap_or_else(|e| panic!("parse {}: {e}", path.display()))
}

fn json_files(dir: &Path) -> Vec<PathBuf> {
    let mut files: Vec<PathBuf> = std::fs::read_dir(dir)
        .unwrap_or_else(|e| panic!("read dir {}: {e}", dir.display()))
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .filter(|p| p.extension().and_then(|e| e.to_str()) == Some("json"))
        .collect();
    files.sort();
    files
}

/// Innermost scope for a packages directory: its own game packages.
fn scope_of(dir: &Path) -> ValidationContext {
    let mut games = BTreeMap::new();
    for path in json_files(dir) {
        let doc = load(&path);
        if doc.get("kind").and_then(serde_json::Value::as_str) == Some("game") {
            let game: GameManifest = serde_json::from_value(doc).unwrap();
            games.insert(game.id.clone(), game);
        }
    }
    ValidationContext { games }
}

fn assert_no_errors(path: &Path, ctx: &ValidationContext) {
    let result = validate_value(&load(path), ctx);
    let errors: Vec<_> = result
        .diagnostics
        .iter()
        .filter(|d| d.severity == Severity::Error)
        .collect();
    assert!(
        errors.is_empty(),
        "{} has validation errors:\n{}",
        path.display(),
        errors
            .iter()
            .map(|d| format!("  {}: {}", d.location, d.message))
            .collect::<Vec<_>>()
            .join("\n")
    );
}

#[test]
fn all_example_files_validate_without_errors() {
    let mut checked = 0;

    // Each mod repo's packages validate in their own scope.
    let mod_repos = examples_dir().join("mod-repos");
    for repo in std::fs::read_dir(&mod_repos).unwrap() {
        let packages = repo.unwrap().path().join("loadstone-packages");
        let ctx = scope_of(&packages);
        for path in json_files(&packages) {
            assert_no_errors(&path, &ctx);
            checked += 1;
        }
    }

    // The community registry validates in its own scope (links + hosted files).
    let registry = examples_dir().join("community-registry/loadstone-packages");
    let ctx = scope_of(&registry);
    for path in json_files(&registry) {
        assert_no_errors(&path, &ctx);
        checked += 1;
    }

    // The release manifest validates in its mod repo's scope.
    let blindfold_scope =
        scope_of(&examples_dir().join("mod-repos/blindfold/loadstone-packages"));
    let release = examples_dir().join("releases/blindfold.release.json");
    assert_no_errors(&release, &blindfold_scope);
    checked += 1;

    assert!(checked >= 11, "expected to check all example files, found {checked}");
}

#[test]
fn mod_without_game_in_scope_warns_but_passes() {
    // With an empty scope chain, ${game.*} checks are skipped with a warning.
    let ctx = ValidationContext::default();
    let path = examples_dir().join("mod-repos/blindfold/loadstone-packages/blindfold.json");
    let result = validate_value(&load(&path), &ctx);
    assert!(!result.has_errors());
    assert!(result
        .diagnostics
        .iter()
        .any(|d| d.severity == Severity::Warning && d.message.contains("not available")));
}

#[test]
fn broken_manifest_is_rejected() {
    let ctx = ValidationContext::default();
    let doc = serde_json::json!({
        "manifestVersion": 1,
        "id": "Bad Id!",
        "name": "x",
        "game": "nowhere",
        "install": [
            { "step": "extract-archive", "routes": [ { "from": "**", "to": "${bogus}" } ] },
            { "step": "copy-files", "from": "${var.unbound}/a", "to": "${gameDir}" }
        ]
    });
    let result = validate_value(&doc, &ctx);
    let messages: Vec<_> = result.diagnostics.iter().map(|d| d.message.clone()).collect();
    assert!(result.has_errors(), "expected errors, got: {messages:?}");
    assert!(messages.iter().any(|m| m.contains("not a valid id")));
    assert!(messages.iter().any(|m| m.contains("unknown token")));
    assert!(messages.iter().any(|m| m.contains("var.unbound")));
}

#[test]
fn link_files_validate_and_bad_links_fail() {
    let ctx = ValidationContext::default();

    let good = serde_json::json!({
        "kind": "link",
        "source": "github:bradjrenshaw/Blindfold",
        "packages": ["blindfold"]
    });
    assert!(!validate_value(&good, &ctx).has_errors());

    let bad = serde_json::json!({ "kind": "link", "source": "not-a-source" });
    let result = validate_value(&bad, &ctx);
    assert!(result.has_errors());
    assert!(result.diagnostics.iter().any(|d| d.message.contains("github:owner/repo")));
}
