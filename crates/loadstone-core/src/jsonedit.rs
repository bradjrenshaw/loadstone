//! The edit-json step (SPEC §9.4). Engine guarantees: UTF-8 BOM tolerated
//! on read and never written, unknown fields preserved verbatim, atomic
//! write (temp file + rename). Paths are dotted keys; a key may carry
//! `[field=value]` selectors that address matching array elements.

use std::path::Path;

use anyhow::{bail, Context as _, Result};
use serde_json::Value;

use crate::types::{JsonOp, JsonOpKind};

pub fn apply_ops(file: &Path, create_if_missing: bool, ops: &[JsonOp]) -> Result<()> {
    let mut root: Value = if file.exists() {
        let raw = std::fs::read_to_string(file)
            .with_context(|| format!("failed to read {}", file.display()))?;
        serde_json::from_str(raw.trim_start_matches('\u{feff}'))
            .with_context(|| format!("{} is not valid JSON", file.display()))?
    } else if create_if_missing {
        Value::Object(serde_json::Map::new())
    } else {
        bail!("{} does not exist", file.display());
    };

    for op in ops {
        apply_one(&mut root, op)?;
    }

    let text = serde_json::to_string_pretty(&root)?;
    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create {}", parent.display()))?;
    }
    let tmp = file.with_extension("loadstone-tmp");
    std::fs::write(&tmp, text.as_bytes())
        .with_context(|| format!("failed to write {}", tmp.display()))?;
    std::fs::rename(&tmp, file)
        .with_context(|| format!("failed to replace {}", file.display()))?;
    Ok(())
}

/// One segment of an op path: an object key, optionally followed by
/// `[field=value]` selectors that pick the matching elements of the array
/// stored under that key (SPEC 9.4).
#[derive(Debug, Clone, PartialEq)]
struct Segment {
    key: String,
    selectors: Vec<(String, String)>,
}

/// Split `a.b[field=value].c` into segments. Dots inside brackets belong to
/// the selector (`[label.id=X]` matches a nested field).
fn parse_path(path: &str) -> Result<Vec<Segment>> {
    let mut segments = Vec::new();
    let mut key = String::new();
    let mut selectors = Vec::new();
    let mut chars = path.chars().peekable();
    let mut after_selector = false;
    while let Some(c) = chars.next() {
        match c {
            '.' => {
                if key.is_empty() {
                    bail!("path \"{path}\": empty segment");
                }
                segments.push(Segment { key: std::mem::take(&mut key), selectors: std::mem::take(&mut selectors) });
                after_selector = false;
            }
            '[' => {
                if key.is_empty() {
                    bail!("path \"{path}\": a selector must follow a key");
                }
                let mut body = String::new();
                let mut closed = false;
                for c in chars.by_ref() {
                    if c == ']' {
                        closed = true;
                        break;
                    }
                    body.push(c);
                }
                if !closed {
                    bail!("path \"{path}\": unclosed \"[\"");
                }
                let (field, value) = body
                    .split_once('=')
                    .with_context(|| format!("path \"{path}\": selector \"[{body}]\" must be [field=value]"))?;
                let field = field.trim();
                if field.is_empty() || field.split('.').any(str::is_empty) {
                    bail!("path \"{path}\": selector \"[{body}]\" has an empty field");
                }
                selectors.push((field.to_string(), value.trim().to_string()));
                after_selector = true;
            }
            ']' => bail!("path \"{path}\": unmatched \"]\""),
            _ => {
                if after_selector {
                    bail!("path \"{path}\": expected \".\" or \"[\" after a selector");
                }
                key.push(c);
            }
        }
    }
    if key.is_empty() {
        bail!("path \"{path}\": empty segment");
    }
    segments.push(Segment { key, selectors });
    if !segments.last().unwrap().selectors.is_empty() {
        bail!("path \"{path}\": must end in a key, not a selector");
    }
    Ok(segments)
}

/// Does an array element satisfy every `[field=value]` selector? Strings
/// compare as text; numbers and booleans by their JSON spelling.
fn element_matches(element: &Value, selectors: &[(String, String)]) -> bool {
    selectors.iter().all(|(field, wanted)| {
        let mut cur = element;
        for part in field.split('.') {
            match cur.get(part) {
                Some(next) => cur = next,
                None => return false,
            }
        }
        match cur {
            Value::String(s) => s == wanted,
            Value::Number(_) | Value::Bool(_) => cur.to_string() == *wanted,
            _ => false,
        }
    })
}

/// Walk `segments` (all but the op's final key) from `cur` and call `leaf`
/// on every object the path reaches. Missing keys are created as objects
/// when `create` is set; selectors never create elements. Returns how many
/// objects were reached.
fn for_each_parent(
    cur: &mut Value,
    segments: &[Segment],
    create: bool,
    path: &str,
    leaf: &mut dyn FnMut(&mut serde_json::Map<String, Value>) -> Result<()>,
) -> Result<usize> {
    let Some((seg, rest)) = segments.split_first() else {
        let obj = cur
            .as_object_mut()
            .with_context(|| format!("path \"{path}\": parent is not an object"))?;
        leaf(obj)?;
        return Ok(1);
    };
    let obj = cur
        .as_object_mut()
        .with_context(|| format!("path \"{path}\": \"{}\" is not inside an object", seg.key))?;
    if !obj.contains_key(&seg.key) {
        if create && seg.selectors.is_empty() {
            obj.insert(seg.key.clone(), Value::Object(serde_json::Map::new()));
        } else {
            bail!("path \"{path}\": \"{}\" not found", seg.key);
        }
    }
    let next = obj.get_mut(&seg.key).unwrap();
    if seg.selectors.is_empty() {
        return for_each_parent(next, rest, create, path, leaf);
    }
    let arr = next
        .as_array_mut()
        .with_context(|| format!("path \"{path}\": \"{}\" is not an array", seg.key))?;
    let mut reached = 0;
    for element in arr.iter_mut().filter(|e| element_matches(e, &seg.selectors)) {
        reached += for_each_parent(element, rest, create, path, leaf)?;
    }
    Ok(reached)
}

/// Run `leaf` on the object(s) holding the op's final key. Fails when a
/// selector matches no element: there is nothing to change and the engine
/// cannot invent one.
fn with_parents(
    root: &mut Value,
    path: &str,
    create: bool,
    leaf: &mut dyn FnMut(&mut serde_json::Map<String, Value>, &str) -> Result<()>,
) -> Result<()> {
    let mut segments = parse_path(path)?;
    let last = segments.pop().unwrap().key;
    let reached = for_each_parent(root, &segments, create, path, &mut |obj| leaf(obj, &last))?;
    if reached == 0 {
        bail!("path \"{path}\": no array element matches its selector");
    }
    Ok(())
}

fn apply_one(root: &mut Value, op: &JsonOp) -> Result<()> {
    match op.op {
        JsonOpKind::Set => {
            let value = op.value.clone().context("set requires a value")?;
            with_parents(root, &op.path, true, &mut |obj, key| {
                obj.insert(key.to_string(), value.clone());
                Ok(())
            })?;
        }
        JsonOpKind::Ensure => {
            let value = op.value.clone().context("ensure requires a value")?;
            with_parents(root, &op.path, true, &mut |obj, key| {
                let wrong_type = obj
                    .get(key)
                    .map(|existing| std::mem::discriminant(existing) != std::mem::discriminant(&value))
                    .unwrap_or(true);
                if wrong_type {
                    obj.insert(key.to_string(), value.clone());
                }
                Ok(())
            })?;
        }
        JsonOpKind::AppendUnique => {
            let value = op.value.clone().context("append-unique requires a value")?;
            let path = op.path.clone();
            with_parents(root, &op.path, true, &mut |obj, key| {
                let entry = obj.entry(key.to_string()).or_insert_with(|| Value::Array(Vec::new()));
                let arr = entry
                    .as_array_mut()
                    .with_context(|| format!("path \"{path}\" is not an array"))?;
                if !arr.contains(&value) {
                    arr.push(value.clone());
                }
                Ok(())
            })?;
        }
        // Removals are best effort: a path that no longer exists means
        // there is nothing left to remove.
        JsonOpKind::RemoveValue => {
            let value = op.value.clone().context("remove-value requires a value")?;
            let _ = with_parents(root, &op.path, false, &mut |obj, key| {
                if let Some(arr) = obj.get_mut(key).and_then(Value::as_array_mut) {
                    arr.retain(|v| v != &value);
                }
                Ok(())
            });
        }
        JsonOpKind::RemoveKey => {
            let _ = with_parents(root, &op.path, false, &mut |obj, key| {
                obj.remove(key);
                Ok(())
            });
        }
    }
    Ok(())
}

/// Check an op path's syntax without a document (for the validator).
pub fn check_path_syntax(path: &str) -> Result<()> {
    parse_path(path).map(|_| ())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ops(v: serde_json::Value) -> Vec<JsonOp> {
        serde_json::from_value(v).unwrap()
    }

    #[test]
    fn set_creates_intermediates_and_preserves_rest() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("settings.save");
        // BOM + unknown fields survive.
        let mut data = vec![0xEF, 0xBB, 0xBF];
        data.extend_from_slice(br#"{"audio": {"volume": 80}}"#);
        std::fs::write(&f, data).unwrap();

        apply_ops(
            &f,
            false,
            &ops(serde_json::json!([
                { "op": "ensure", "path": "mod_settings", "value": {} },
                { "op": "set", "path": "mod_settings.mods_enabled", "value": true }
            ])),
        )
        .unwrap();

        let out: Value = serde_json::from_str(&std::fs::read_to_string(&f).unwrap()).unwrap();
        assert_eq!(out["audio"]["volume"], 80);
        assert_eq!(out["mod_settings"]["mods_enabled"], true);
    }

    #[test]
    fn ensure_replaces_wrong_type_only() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("x.json");
        std::fs::write(&f, br#"{"mod_settings": "corrupted", "keep": {"a": 1}}"#).unwrap();
        apply_ops(
            &f,
            false,
            &ops(serde_json::json!([
                { "op": "ensure", "path": "mod_settings", "value": {} },
                { "op": "ensure", "path": "keep", "value": {} }
            ])),
        )
        .unwrap();
        let out: Value = serde_json::from_str(&std::fs::read_to_string(&f).unwrap()).unwrap();
        assert!(out["mod_settings"].is_object());
        assert_eq!(out["keep"]["a"], 1);
    }

    #[test]
    fn append_unique_and_remove_value_roundtrip() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("mgr.json");
        apply_ops(
            &f,
            true,
            &ops(serde_json::json!([
                { "op": "ensure", "path": "SourceDirectories", "value": [] },
                { "op": "append-unique", "path": "EnabledModifications", "value": "WrathAccess" },
                { "op": "append-unique", "path": "EnabledModifications", "value": "WrathAccess" }
            ])),
        )
        .unwrap();
        let out: Value = serde_json::from_str(&std::fs::read_to_string(&f).unwrap()).unwrap();
        assert_eq!(out["EnabledModifications"], serde_json::json!(["WrathAccess"]));

        apply_ops(
            &f,
            false,
            &ops(serde_json::json!([
                { "op": "remove-value", "path": "EnabledModifications", "value": "WrathAccess" }
            ])),
        )
        .unwrap();
        let out: Value = serde_json::from_str(&std::fs::read_to_string(&f).unwrap()).unwrap();
        assert_eq!(out["EnabledModifications"], serde_json::json!([]));
    }

    #[test]
    fn missing_file_without_create_errors() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("absent.json");
        assert!(apply_ops(&f, false, &ops(serde_json::json!([{ "op": "set", "path": "a", "value": 1 }]))).is_err());
    }

    #[test]
    fn selectors_edit_matching_array_elements_only() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("mods.json");
        std::fs::write(
            &f,
            br#"{"version": 1, "mods": [
                {"label": {"id": "Other"}, "staticID": "Other", "enabled": false},
                {"label": {"id": "OniAccess"}, "staticID": "OniAccess", "enabled": false, "crash_count": 3}
            ], "mod_load_in_progress": true}"#,
        )
        .unwrap();
        apply_ops(
            &f,
            false,
            &ops(serde_json::json!([
                { "op": "set", "path": "mods[staticID=OniAccess].enabled", "value": true },
                { "op": "set", "path": "mods[label.id=OniAccess].crash_count", "value": 0 },
                { "op": "set", "path": "mods[staticID=OniAccess].enabledForDlc", "value": ["", "EXPANSION1_ID"] },
                { "op": "set", "path": "mod_load_in_progress", "value": false }
            ])),
        )
        .unwrap();
        let out: Value = serde_json::from_str(&std::fs::read_to_string(&f).unwrap()).unwrap();
        assert_eq!(out["mods"][0]["enabled"], false);
        assert_eq!(out["mods"][1]["enabled"], true);
        assert_eq!(out["mods"][1]["crash_count"], 0);
        assert_eq!(out["mods"][1]["enabledForDlc"], serde_json::json!(["", "EXPANSION1_ID"]));
        assert_eq!(out["mod_load_in_progress"], false);
        assert!(out.get("mods[staticID=OniAccess]").is_none());
    }

    #[test]
    fn selector_without_a_match_is_an_error_for_writes_only() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("mods.json");
        std::fs::write(&f, br#"{"mods": [{"staticID": "Other"}]}"#).unwrap();
        let err = apply_ops(
            &f,
            false,
            &ops(serde_json::json!([{ "op": "set", "path": "mods[staticID=OniAccess].enabled", "value": true }])),
        )
        .unwrap_err();
        assert!(format!("{err:#}").contains("no array element matches"), "{err:#}");
        apply_ops(
            &f,
            false,
            &ops(serde_json::json!([{ "op": "remove-key", "path": "mods[staticID=OniAccess].enabled" }])),
        )
        .unwrap();
    }

    #[test]
    fn writes_utf8_without_a_bom() {
        let tmp = tempfile::tempdir().unwrap();
        let f = tmp.path().join("mods.json");
        let mut data = vec![0xEF, 0xBB, 0xBF];
        data.extend_from_slice(br#"{"a": 1}"#);
        std::fs::write(&f, data).unwrap();
        apply_ops(&f, false, &ops(serde_json::json!([{ "op": "set", "path": "b", "value": 2 }]))).unwrap();
        assert!(!std::fs::read(&f).unwrap().starts_with(&[0xEF, 0xBB, 0xBF]));
    }

    #[test]
    fn path_syntax_errors() {
        for bad in ["", "a..b", "[x=1].a", "a[x=1]", "a[x].b", "a[=1].b", "a[x=1", "a]b", "a[x=1]b.c"] {
            assert!(check_path_syntax(bad).is_err(), "{bad} should be rejected");
        }
        assert_eq!(
            parse_path("a.b[label.id=X][n=2].c").unwrap(),
            vec![
                Segment { key: "a".into(), selectors: vec![] },
                Segment { key: "b".into(), selectors: vec![("label.id".into(), "X".into()), ("n".into(), "2".into())] },
                Segment { key: "c".into(), selectors: vec![] },
            ]
        );
    }
}
