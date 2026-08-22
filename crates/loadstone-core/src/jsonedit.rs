//! The edit-json step (SPEC §9.4). Engine guarantees: UTF-8 BOM tolerated,
//! unknown fields preserved verbatim, atomic write (temp file + rename).

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

/// Walk a dotted path, creating intermediate objects when `create` is set.
fn descend<'a>(root: &'a mut Value, path: &str, create: bool) -> Result<(&'a mut Value, String)> {
    let mut parts: Vec<&str> = path.split('.').collect();
    let last = parts.pop().context("empty path")?.to_string();
    let mut cur = root;
    for part in parts {
        if !cur.is_object() {
            bail!("path \"{path}\": \"{part}\" is not an object");
        }
        let obj = cur.as_object_mut().unwrap();
        if !obj.contains_key(part) {
            if create {
                obj.insert(part.to_string(), Value::Object(serde_json::Map::new()));
            } else {
                bail!("path \"{path}\": \"{part}\" not found");
            }
        }
        cur = obj.get_mut(part).unwrap();
    }
    if !cur.is_object() {
        bail!("path \"{path}\": parent is not an object");
    }
    Ok((cur, last))
}

fn apply_one(root: &mut Value, op: &JsonOp) -> Result<()> {
    match op.op {
        JsonOpKind::Set => {
            let value = op.value.clone().context("set requires a value")?;
            let (parent, key) = descend(root, &op.path, true)?;
            parent.as_object_mut().unwrap().insert(key, value);
        }
        JsonOpKind::Ensure => {
            let value = op.value.clone().context("ensure requires a value")?;
            let (parent, key) = descend(root, &op.path, true)?;
            let obj = parent.as_object_mut().unwrap();
            let wrong_type = obj
                .get(&key)
                .map(|existing| std::mem::discriminant(existing) != std::mem::discriminant(&value))
                .unwrap_or(true);
            if wrong_type {
                obj.insert(key, value);
            }
        }
        JsonOpKind::AppendUnique => {
            let value = op.value.clone().context("append-unique requires a value")?;
            let (parent, key) = descend(root, &op.path, true)?;
            let obj = parent.as_object_mut().unwrap();
            let entry = obj.entry(key).or_insert_with(|| Value::Array(Vec::new()));
            let arr = entry
                .as_array_mut()
                .with_context(|| format!("path \"{}\" is not an array", op.path))?;
            if !arr.contains(&value) {
                arr.push(value);
            }
        }
        JsonOpKind::RemoveValue => {
            let value = op.value.clone().context("remove-value requires a value")?;
            if let Ok((parent, key)) = descend(root, &op.path, false) {
                if let Some(arr) = parent.as_object_mut().unwrap().get_mut(&key).and_then(Value::as_array_mut) {
                    arr.retain(|v| v != &value);
                }
            }
        }
        JsonOpKind::RemoveKey => {
            if let Ok((parent, key)) = descend(root, &op.path, false) {
                parent.as_object_mut().unwrap().remove(&key);
            }
        }
    }
    Ok(())
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
}
