//! Translated package text (SPEC 18): parsing, picking a language, and
//! what validation says about translations.

use loadstone_core::i18n::with_language;
use loadstone_core::release::{build_release_manifest, ArtifactInput, ReleaseOptions};
use loadstone_core::types::{LocalizedText, ProjectManifest, Step, MANIFEST_VERSION};
use loadstone_core::validate::{validate_value, Diagnostic, Severity};
use serde_json::{json, Value};

fn project(version: u32, option_label: Value, notice: Value) -> Value {
    json!({
        "manifestVersion": version,
        "id": "demo-mod",
        "name": "Demo Mod",
        "description": { "en": "Speaks the menus.", "fr": "Lit les menus." },
        "authors": ["Someone"],
        "kind": "tool",
        "install": [
            { "step": "notice", "message": notice }
        ],
        "options": [
            { "id": "profile", "label": option_label,
              "choices": [
                { "value": "blind", "label": { "en": "A blind player", "fr": "Un joueur aveugle" } },
                { "value": "sighted", "label": { "en": "A sighted partner", "fr": "Un partenaire voyant" } }
              ] }
        ]
    })
}

fn diagnostics(doc: &Value) -> Vec<Diagnostic> {
    validate_value(doc, &Default::default()).diagnostics
}

fn errors(doc: &Value) -> Vec<String> {
    diagnostics(doc)
        .into_iter()
        .filter(|d| d.severity == Severity::Error)
        .map(|d| format!("{}: {}", d.location, d.message))
        .collect()
}

fn warnings(doc: &Value) -> Vec<String> {
    diagnostics(doc)
        .into_iter()
        .filter(|d| d.severity == Severity::Warning)
        .map(|d| format!("{}: {}", d.location, d.message))
        .collect()
}

#[test]
fn translated_manifest_validates_and_reads_in_the_users_language() {
    let doc = project(
        2,
        json!({ "en": "Who will play?", "fr": "Qui va jouer ?" }),
        json!({ "en": "Done. Files are in ${gameDir}.", "fr": "Terminé. Les fichiers sont dans ${gameDir}." }),
    );
    assert!(errors(&doc).is_empty(), "{:?}", errors(&doc));
    assert!(warnings(&doc).is_empty(), "{:?}", warnings(&doc));

    let manifest: ProjectManifest = serde_json::from_value(doc).unwrap();
    let label = &manifest.options[0].label;
    with_language("fr", || assert_eq!(label.get(), "Qui va jouer ?"));
    with_language("de", || assert_eq!(label.get(), "Who will play?"));
    // Plain text is the same in every language.
    with_language("fr", || assert_eq!(manifest.name.get(), "Demo Mod"));
    let Step::Notice { message, .. } = &manifest.install[0] else { panic!() };
    with_language("fr-CA", || assert!(message.get().starts_with("Terminé")));
}

#[test]
fn translated_text_needs_manifest_version_2() {
    let doc = project(1, json!({ "en": "Who?", "fr": "Qui ?" }), json!({ "en": "Hi", "fr": "Salut" }));
    let errors = errors(&doc);
    assert!(errors.iter().any(|e| e.starts_with("manifestVersion:") && e.contains("needs")), "{errors:?}");
}

#[test]
fn untranslated_and_missing_languages_are_warned_about() {
    let doc = project(2, json!("Who will play?"), json!({ "en": "Hi" }));
    let warnings = warnings(&doc);
    assert!(
        warnings.iter().any(|w| w.starts_with("options/0/label:") && w.contains("not translated")),
        "{warnings:?}"
    );
    assert!(
        warnings.iter().any(|w| w.starts_with("install/0/message:") && w.contains("no translation for fr")),
        "{warnings:?}"
    );
    // A name is often the same everywhere: no warning for it.
    assert!(!warnings.iter().any(|w| w.starts_with("name:")), "{warnings:?}");
}

#[test]
fn translations_must_keep_tokens_and_use_real_tags() {
    let doc = project(
        2,
        json!({ "en": "Who?", "french": "Qui ?" }),
        json!({ "en": "Files are in ${gameDir}.", "fr": "Les fichiers sont dans le jeu." }),
    );
    let errors = errors(&doc);
    assert!(errors.iter().any(|e| e.starts_with("options/0/label/french:")), "{errors:?}");
    assert!(
        errors.iter().any(|e| e.starts_with("install/0/message/fr:") && e.contains("tokens")),
        "{errors:?}"
    );
}

#[test]
fn edit_json_values_are_data_not_text() {
    let mut doc = project(2, json!({ "en": "Who?", "fr": "Qui ?" }), json!({ "en": "Hi", "fr": "Salut" }));
    doc["install"].as_array_mut().unwrap().push(json!({
        "step": "edit-json", "file": "${gameDir}/config.json", "createIfMissing": true,
        "ops": [ { "op": "set", "path": "label", "value": { "message": "not package text" } } ]
    }));
    assert!(warnings(&doc).is_empty(), "{:?}", warnings(&doc));
}

#[test]
fn translated_release_notes_make_a_version_2_release() {
    let manifest: ProjectManifest =
        serde_json::from_value(project(1, json!("Who?"), json!("Hi"))).unwrap();
    let notes = LocalizedText::Translated(vec![
        ("en".into(), "Fixes.".into()),
        ("fr".into(), "Corrections.".into()),
    ]);
    let dir = tempfile::tempdir().unwrap();
    let zip = dir.path().join("Demo.zip");
    std::fs::write(&zip, b"zip").unwrap();
    let options = |release_notes| ReleaseOptions {
        version: "1.0.0".into(),
        artifacts: vec![ArtifactInput { path: zip.clone(), id: None, when: None }],
        release_notes,
        installers: vec![],
    };
    let plain = build_release_manifest(&manifest, &options(Some("Fixes.".into()))).unwrap();
    assert_eq!(plain.manifest_version, 1);
    let translated = build_release_manifest(&manifest, &options(Some(notes))).unwrap();
    assert_eq!(translated.manifest_version, 2);
    let doc = serde_json::to_value(&translated).unwrap();
    assert_eq!(doc["releaseNotes"]["fr"], "Corrections.");
}

#[test]
fn newer_manifests_are_refused_with_an_update_message() {
    let doc = json!({ "manifestVersion": MANIFEST_VERSION + 1, "id": "x" });
    let err = loadstone_core::types::check_manifest_version(&doc).unwrap_err();
    assert!(err.to_string().contains("newer version of Loadstone"), "{err}");
}
