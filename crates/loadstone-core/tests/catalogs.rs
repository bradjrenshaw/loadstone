//! Loadstone's own message catalogs (locales/*.ftl) stay in step with the
//! code and with each other:
//!
//! - every message id the code asks for exists in English, and English has
//!   no message nothing asks for;
//! - every other language has exactly English's messages, each using the
//!   same `{ $arguments }` and keeping its `&` shortcut marker.

use std::collections::{BTreeMap, BTreeSet};
use std::path::{Path, PathBuf};

use fluent_syntax::ast;
use fluent_syntax::parser;

fn repo() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../..")
}

fn locales() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("locales")
}

/// A message's arguments and its text with arguments stripped (for the
/// shortcut-marker check).
struct Message {
    args: BTreeSet<String>,
    text: String,
}

fn collect_pattern(pattern: &ast::Pattern<&str>, msg: &mut Message) {
    for element in &pattern.elements {
        match element {
            ast::PatternElement::TextElement { value } => msg.text.push_str(value),
            ast::PatternElement::Placeable { expression } => collect_expression(expression, msg),
        }
    }
}

fn collect_expression(expression: &ast::Expression<&str>, msg: &mut Message) {
    match expression {
        ast::Expression::Select { selector, variants } => {
            collect_inline(selector, msg);
            for variant in variants {
                collect_pattern(&variant.value, msg);
            }
        }
        ast::Expression::Inline(inline) => collect_inline(inline, msg),
    }
}

fn collect_inline(inline: &ast::InlineExpression<&str>, msg: &mut Message) {
    match inline {
        ast::InlineExpression::VariableReference { id } => {
            msg.args.insert(id.name.to_string());
        }
        ast::InlineExpression::Placeable { expression } => collect_expression(expression, msg),
        ast::InlineExpression::FunctionReference { arguments, .. } => {
            for arg in &arguments.positional {
                collect_inline(arg, msg);
            }
        }
        _ => {}
    }
}

fn load_catalog(path: &Path) -> BTreeMap<String, Message> {
    let source = std::fs::read_to_string(path).unwrap();
    let resource = match parser::parse(source.as_str()) {
        Ok(r) => r,
        Err((_, errors)) => panic!("{} does not parse: {errors:?}", path.display()),
    };
    let mut out = BTreeMap::new();
    for entry in &resource.body {
        if let ast::Entry::Message(m) = entry {
            let mut msg = Message { args: BTreeSet::new(), text: String::new() };
            if let Some(value) = &m.value {
                collect_pattern(value, &mut msg);
            }
            assert!(
                out.insert(m.id.name.to_string(), msg).is_none(),
                "{}: \"{}\" is defined twice",
                path.display(),
                m.id.name
            );
        }
    }
    out
}

fn shortcut_markers(text: &str) -> usize {
    text.replace("&&", "").matches('&').count()
}

fn source_files(dir: &Path, out: &mut Vec<PathBuf>) {
    for entry in std::fs::read_dir(dir).unwrap().flatten() {
        let path = entry.path();
        if path.is_dir() {
            source_files(&path, out);
        } else if matches!(path.extension().and_then(|e| e.to_str()), Some("rs" | "cpp" | "h")) {
            out.push(path);
        }
    }
}

/// Every message id the code uses.
fn used_ids() -> BTreeSet<String> {
    // A lookup (`t!("id"`, `T("id"`, `i18n::message("id"`), a preference
    // label, or an id kept in a table: any literal with a catalog prefix.
    let pattern = regex::Regex::new(
        r#"(?:\bt!\(\s*|\bT\(\s*|i18n::message\(\s*|\blabel: |\bdescription: )"([a-z][a-z0-9-]*)"|"((?:gui|page|engine|core|pref|error|language)-[a-z0-9-]+)""#,
    )
    .unwrap();
    let mut files = Vec::new();
    for dir in ["crates/loadstone-core/src", "crates/loadstone-bridge/src", "app/src"] {
        source_files(&repo().join(dir), &mut files);
    }
    let mut ids = BTreeSet::new();
    for file in files {
        let text = std::fs::read_to_string(&file).unwrap();
        // Examples in comments are not uses.
        let code: String = text
            .lines()
            .filter(|l| !l.trim_start().starts_with("//"))
            .collect::<Vec<_>>()
            .join("\n");
        for cap in pattern.captures_iter(&code) {
            let id = cap.get(1).or_else(|| cap.get(2)).unwrap().as_str();
            // `label:` and `description:` match other code too; only
            // catalog-shaped ids (with a dash) count.
            if id.contains('-') {
                ids.insert(id.to_string());
            }
        }
    }
    ids
}

#[test]
fn code_and_english_catalog_agree() {
    let english = load_catalog(&locales().join("en.ftl"));
    let used = used_ids();
    let missing: Vec<&String> = used.iter().filter(|id| !english.contains_key(*id)).collect();
    assert!(missing.is_empty(), "used in code but not in en.ftl: {missing:?}");
    let unused: Vec<&String> = english.keys().filter(|id| !used.contains(*id)).collect();
    assert!(unused.is_empty(), "in en.ftl but never used: {unused:?}");
}

#[test]
fn every_language_matches_english() {
    let english = load_catalog(&locales().join("en.ftl"));
    let mut problems = Vec::new();
    for lang in loadstone_core::i18n::LANGUAGES.iter().skip(1) {
        let path = locales().join(format!("{}.ftl", lang.tag));
        let catalog = load_catalog(&path);
        for (id, en) in &english {
            let Some(msg) = catalog.get(id) else {
                problems.push(format!("{}: missing \"{id}\"", lang.tag));
                continue;
            };
            if msg.args != en.args {
                problems.push(format!(
                    "{}: \"{id}\" uses arguments {:?}, English uses {:?}",
                    lang.tag, msg.args, en.args
                ));
            }
            if shortcut_markers(&msg.text) != shortcut_markers(&en.text) {
                problems.push(format!("{}: \"{id}\" must keep exactly one & shortcut marker", lang.tag));
            }
        }
        for id in catalog.keys() {
            if !english.contains_key(id) {
                problems.push(format!("{}: \"{id}\" is not in English", lang.tag));
            }
        }
    }
    assert!(problems.is_empty(), "{} problems:\n{}", problems.len(), problems.join("\n"));
}
