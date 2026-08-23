//! Settings values (SPEC §11): reading and writing the mod's own storage
//! file against the schema frozen in installed state. Shared by the CLI's
//! `settings` command and the GUI bridge, so both validate identically.

use std::path::Path;

use anyhow::{bail, Context as _, Result};
use serde_json::{Map, Value};

use crate::types::{SettingEntry, SettingType, Settings};

/// Read the stored values (empty map when the file doesn't exist yet).
pub fn read_values(file: &Path) -> Result<Map<String, Value>> {
    if !file.exists() {
        return Ok(Map::new());
    }
    serde_json::from_str(
        std::fs::read_to_string(file)
            .with_context(|| format!("failed to read {}", file.display()))?
            .trim_start_matches('\u{feff}'),
    )
    .with_context(|| format!("{} is not valid JSON", file.display()))
}

pub fn write_values(file: &Path, values: &Map<String, Value>) -> Result<()> {
    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create {}", parent.display()))?;
    }
    std::fs::write(
        file,
        serde_json::to_string_pretty(&Value::Object(values.clone()))?,
    )
    .with_context(|| format!("failed to write {}", file.display()))
}

/// The current effective value: stored, else the schema default.
pub fn effective<'a>(entry: &'a SettingEntry, values: &'a Map<String, Value>) -> Option<&'a Value> {
    values.get(&entry.id).or(entry.default.as_ref())
}

/// Parse raw user text into a typed value per the entry's declared type,
/// enforcing ranges and choice membership.
pub fn parse_value(entry: &SettingEntry, raw: &str) -> Result<Value> {
    let key = &entry.id;
    Ok(match entry.entry_type {
        SettingType::Boolean => match raw.to_lowercase().as_str() {
            "true" | "yes" | "on" | "1" => Value::Bool(true),
            "false" | "no" | "off" | "0" => Value::Bool(false),
            _ => bail!("\"{key}\" is a boolean; use true or false"),
        },
        SettingType::Number => {
            let n: f64 = raw
                .parse()
                .with_context(|| format!("\"{key}\" needs a number"))?;
            if let Some(min) = entry.min {
                if n < min {
                    bail!("\"{key}\" must be at least {min}");
                }
            }
            if let Some(max) = entry.max {
                if n > max {
                    bail!("\"{key}\" must be at most {max}");
                }
            }
            serde_json::json!(n)
        }
        SettingType::String => Value::String(raw.to_string()),
        SettingType::Choice => {
            let value = Value::String(raw.to_string());
            if !entry.options.iter().any(|o| o.value == value) {
                let options: Vec<String> =
                    entry.options.iter().map(|o| o.value.to_string()).collect();
                bail!("\"{key}\" must be one of: {}", options.join(", "));
            }
            value
        }
    })
}

/// Validate and persist one setting. Returns the schema's note (a message
/// the UI should show after changes, e.g. "takes effect after restart").
pub fn set(settings: &Settings, file: &Path, key: &str, raw: &str) -> Result<Option<String>> {
    let entry = settings
        .entries
        .iter()
        .find(|e| e.id == key)
        .with_context(|| {
            let known: Vec<&str> = settings.entries.iter().map(|e| e.id.as_str()).collect();
            format!("no setting \"{key}\" (known: {})", known.join(", "))
        })?;
    let value = parse_value(entry, raw)?;
    let mut values = read_values(file)?;
    values.insert(key.to_string(), value);
    write_values(file, &values)?;
    Ok(settings.note.clone())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn schema() -> Settings {
        serde_json::from_value(serde_json::json!({
            "storage": { "file": "unused.json" },
            "note": "Restart the game.",
            "entries": [
                { "id": "speech", "type": "boolean", "default": true, "label": "Speech" },
                { "id": "rate", "type": "number", "min": 0.5, "max": 3.0, "default": 1.0, "label": "Rate" },
                { "id": "reader", "type": "choice", "default": "auto", "label": "Reader",
                  "options": [ { "value": "auto", "label": "Automatic" },
                               { "value": "jaws", "label": "JAWS" } ] }
            ]
        }))
        .unwrap()
    }

    #[test]
    fn set_validates_and_persists() {
        let tmp = tempfile::tempdir().unwrap();
        let file = tmp.path().join("cfg").join("settings.json");
        let s = schema();

        let note = set(&s, &file, "speech", "off").unwrap();
        assert_eq!(note.as_deref(), Some("Restart the game."));
        let values = read_values(&file).unwrap();
        assert_eq!(values.get("speech"), Some(&Value::Bool(false)));
        assert_eq!(
            effective(&s.entries[1], &values),
            Some(&serde_json::json!(1.0)),
            "unset falls back to the default"
        );

        assert!(set(&s, &file, "rate", "9").is_err(), "max enforced");
        assert!(set(&s, &file, "reader", "nvda").is_err(), "choice enforced");
        assert!(set(&s, &file, "missing", "1").is_err());
        set(&s, &file, "reader", "jaws").unwrap();
        assert_eq!(
            read_values(&file).unwrap().get("reader"),
            Some(&Value::String("jaws".into()))
        );
    }
}
