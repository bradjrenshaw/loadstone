//! Loadstone's own preferences ("Loadstone settings"), as distinct from a
//! mod's declared settings form (`settings.rs`, SPEC §11), which writes the
//! mod's own config file.
//!
//! Two scopes:
//! - **Global** — Loadstone-wide. In a standalone single-mod installer,
//!   "global" means *that installer*: its preferences (and accounts) are
//!   its own and never shared with the manager or other installers.
//! - **Mod** — Loadstone's preferences about one mod, keyed by mod id
//!   (ids are unique, so not per installed copy).
//!
//! Every preference is declared once in [`DEFINITIONS`] with its type,
//! default, label and where it may be set. Lookup for a mod: the mod's own
//! value (if the definition allows one), then the global value (if
//! allowed), then the default. UIs render forms from the definitions, so a
//! new preference is one table entry.
//!
//! Layout under the scope root (see [`PrefStore::root_for`]):
//! `settings.json` for global values, `mods/<id>/settings.json` per mod.
//! Unknown keys are preserved on write (a newer Loadstone's preferences
//! survive an older one), and a stored value of the wrong type is ignored
//! so lookup falls through to the next layer.

use std::path::{Path, PathBuf};

use anyhow::{bail, Context as _, Result};
use serde_json::{Map, Value};

use crate::profile::{Profile, ProfileMode};

/// Where a preference may be set.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Applies {
    /// Only Loadstone-wide.
    Global,
    /// Only per mod.
    Mod,
    /// Loadstone-wide, and each mod may override it.
    GlobalWithModOverride,
}

/// A preference's value type.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PrefType {
    Bool,
    String,
    Number,
    /// One of a fixed set of string values: `(value, label)`.
    Choice(&'static [(&'static str, &'static str)]),
    /// An account id, or empty for "automatic".
    AccountPicker,
    /// Structured JSON (lists, maps) edited by a dedicated UI — never
    /// rendered by a generic form.
    Structured,
}

/// One declared preference.
#[derive(Debug, Clone, Copy)]
pub struct PrefDef {
    pub key: &'static str,
    pub kind: PrefType,
    /// Default as JSON text, parsed on use (`"true"`, `"\"\""`, `"[]"`).
    pub default: &'static str,
    pub label: &'static str,
    pub description: &'static str,
    pub applies: Applies,
}

impl PrefDef {
    pub fn default_value(&self) -> Value {
        serde_json::from_str(self.default).unwrap_or(Value::Null)
    }

    fn allows(&self, scope: &Scope) -> bool {
        matches!(
            (self.applies, scope),
            (Applies::Global | Applies::GlobalWithModOverride, Scope::Global)
                | (Applies::Mod | Applies::GlobalWithModOverride, Scope::Mod(_))
        )
    }

    fn accepts(&self, value: &Value) -> bool {
        match self.kind {
            PrefType::Bool => value.is_boolean(),
            PrefType::String | PrefType::AccountPicker => value.is_string(),
            PrefType::Number => value.is_number(),
            PrefType::Choice(options) => value
                .as_str()
                .is_some_and(|v| options.iter().any(|(o, _)| *o == v)),
            PrefType::Structured => true,
        }
    }
}

/// Every Loadstone preference.
pub static DEFINITIONS: &[PrefDef] = &[
    PrefDef {
        key: crate::auth::PREF_ACCOUNTS,
        kind: PrefType::Structured,
        default: "[]",
        label: "Accounts",
        description: "Sign-ins used to download mods from private repositories.",
        applies: Applies::Global,
    },
    PrefDef {
        key: crate::auth::PREF_RULES,
        kind: PrefType::Structured,
        default: "[]",
        label: "Account rules",
        description: "Which account to use for a repository or owner.",
        applies: Applies::Global,
    },
    PrefDef {
        key: crate::auth::PREF_TRY_OTHERS,
        kind: PrefType::Bool,
        default: "true",
        label: "Try my other accounts when a download is refused",
        description: "If a repository isn't found or access is refused, try the other accounts \
                      for that site before giving up.",
        applies: Applies::Global,
    },
    PrefDef {
        key: crate::auth::PREF_MOD_ACCOUNT,
        kind: PrefType::AccountPicker,
        default: "\"\"",
        label: "Download account",
        description: "The account used to download this mod. Automatic uses your account rules \
                      and default account.",
        applies: Applies::Mod,
    },
];

/// Which file a value lives in.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Scope {
    Global,
    Mod(String),
}

pub struct PrefStore {
    root: PathBuf,
    defs: &'static [PrefDef],
}

impl PrefStore {
    /// The scope root for a profile: `%LOCALAPPDATA%/Loadstone` for the
    /// manager, `%LOCALAPPDATA%/Loadstone/installers/<mod-id>` for a
    /// standalone installer.
    pub fn root_for(profile: &Profile) -> Result<PathBuf> {
        let base = dirs::data_local_dir()
            .context("no local data directory on this system")?
            .join("Loadstone");
        Ok(match (&profile.mode, &profile.mod_id) {
            (ProfileMode::SingleMod, Some(id)) => {
                check_id(id)?;
                base.join("installers").join(id)
            }
            _ => base,
        })
    }

    /// Open the store for `profile`, or at `root_override` (tests, sandboxes).
    pub fn open(profile: &Profile, root_override: Option<PathBuf>) -> Result<Self> {
        let root = match root_override {
            Some(r) => r,
            None => Self::root_for(profile)?,
        };
        Ok(Self { root, defs: DEFINITIONS })
    }

    /// A store over custom definitions (tests).
    pub fn with_definitions(root: PathBuf, defs: &'static [PrefDef]) -> Self {
        Self { root, defs }
    }

    pub fn definitions(&self) -> &'static [PrefDef] {
        self.defs
    }

    pub fn definition(&self, key: &str) -> Option<&'static PrefDef> {
        self.defs.iter().find(|d| d.key == key)
    }

    fn file(&self, scope: &Scope) -> Result<PathBuf> {
        Ok(match scope {
            Scope::Global => self.root.join("settings.json"),
            Scope::Mod(id) => {
                check_id(id)?;
                self.root.join("mods").join(id).join("settings.json")
            }
        })
    }

    fn read(&self, scope: &Scope) -> Result<Map<String, Value>> {
        let path = self.file(scope)?;
        if !path.exists() {
            return Ok(Map::new());
        }
        let text = std::fs::read_to_string(&path)
            .with_context(|| format!("failed to read {}", path.display()))?;
        match serde_json::from_str::<Value>(text.trim_start_matches('\u{feff}')) {
            Ok(Value::Object(map)) => Ok(map),
            _ => bail!("{} is not a JSON object", path.display()),
        }
    }

    fn write(&self, scope: &Scope, map: &Map<String, Value>) -> Result<()> {
        write_atomic(&self.file(scope)?, &serde_json::to_string_pretty(map)?)
    }

    /// The value stored in exactly `scope`, if any and well-typed.
    pub fn get_in(&self, scope: &Scope, key: &str) -> Result<Option<Value>> {
        let def = self.def_or_err(key)?;
        Ok(self.read(scope)?.remove(key).filter(|v| def.accepts(v)))
    }

    /// The effective value: for a mod (when `mod_id` is given) its own
    /// value first, then the global value, then the default — each layer
    /// only if the definition allows it.
    pub fn get(&self, key: &str, mod_id: Option<&str>) -> Result<Value> {
        let def = self.def_or_err(key)?;
        if let Some(id) = mod_id {
            let scope = Scope::Mod(id.to_string());
            if def.allows(&scope) {
                if let Some(v) = self.get_in(&scope, key)? {
                    return Ok(v);
                }
            }
        }
        if def.allows(&Scope::Global) {
            if let Some(v) = self.get_in(&Scope::Global, key)? {
                return Ok(v);
            }
        }
        Ok(def.default_value())
    }

    /// Store a value in `scope`, after checking the definition allows that
    /// scope and the value's type.
    pub fn set(&self, scope: &Scope, key: &str, value: Value) -> Result<()> {
        let def = self.def_or_err(key)?;
        if !def.allows(scope) {
            bail!("\"{key}\" can't be set {}", scope_phrase(scope));
        }
        if !def.accepts(&value) {
            bail!("{value} is not a valid value for \"{key}\"");
        }
        let mut map = self.read(scope)?;
        map.insert(key.to_string(), value);
        self.write(scope, &map)
    }

    /// Remove a stored value, so lookup falls back to the next layer.
    pub fn unset(&self, scope: &Scope, key: &str) -> Result<()> {
        self.def_or_err(key)?;
        let mut map = self.read(scope)?;
        if map.remove(key).is_some() {
            self.write(scope, &map)?;
        }
        Ok(())
    }

    fn def_or_err(&self, key: &str) -> Result<&'static PrefDef> {
        self.definition(key)
            .with_context(|| format!("\"{key}\" is not a Loadstone setting"))
    }
}

fn scope_phrase(scope: &Scope) -> &'static str {
    match scope {
        Scope::Global => "globally",
        Scope::Mod(_) => "per mod",
    }
}

/// Mod ids become directory names, so only plain ids are allowed.
fn check_id(id: &str) -> Result<()> {
    let ok = !id.is_empty()
        && id
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-');
    if !ok {
        bail!("\"{id}\" is not a valid mod id");
    }
    Ok(())
}

fn write_atomic(path: &Path, text: &str) -> Result<()> {
    let dir = path.parent().context("settings path has no parent")?;
    std::fs::create_dir_all(dir).with_context(|| format!("failed to create {}", dir.display()))?;
    let tmp = path.with_extension("json.tmp");
    std::fs::write(&tmp, text).with_context(|| format!("failed to write {}", tmp.display()))?;
    std::fs::rename(&tmp, path).with_context(|| format!("failed to replace {}", path.display()))
}

#[cfg(test)]
mod tests {
    use super::*;

    static TEST_DEFS: &[PrefDef] = &[
        PrefDef {
            key: "global.flag",
            kind: PrefType::Bool,
            default: "true",
            label: "Flag",
            description: "",
            applies: Applies::Global,
        },
        PrefDef {
            key: "mod.only",
            kind: PrefType::String,
            default: "\"\"",
            label: "Mod only",
            description: "",
            applies: Applies::Mod,
        },
        PrefDef {
            key: "both",
            kind: PrefType::Choice(&[("a", "A"), ("b", "B")]),
            default: "\"a\"",
            label: "Both",
            description: "",
            applies: Applies::GlobalWithModOverride,
        },
    ];

    fn store() -> (tempfile::TempDir, PrefStore) {
        let tmp = tempfile::tempdir().unwrap();
        let store = PrefStore::with_definitions(tmp.path().to_path_buf(), TEST_DEFS);
        (tmp, store)
    }

    fn m(id: &str) -> Scope {
        Scope::Mod(id.to_string())
    }

    #[test]
    fn defaults_then_layers() {
        let (_t, s) = store();
        assert_eq!(s.get("both", Some("x")).unwrap(), Value::from("a"));
        s.set(&Scope::Global, "both", Value::from("b")).unwrap();
        assert_eq!(s.get("both", Some("x")).unwrap(), Value::from("b"));
        s.set(&m("x"), "both", Value::from("a")).unwrap();
        assert_eq!(s.get("both", Some("x")).unwrap(), Value::from("a"));
        assert_eq!(s.get("both", Some("y")).unwrap(), Value::from("b"));
        assert_eq!(s.get("both", None).unwrap(), Value::from("b"));
        s.unset(&m("x"), "both").unwrap();
        assert_eq!(s.get("both", Some("x")).unwrap(), Value::from("b"));
    }

    #[test]
    fn scope_and_type_rules() {
        let (_t, s) = store();
        assert!(s.set(&m("x"), "global.flag", Value::from(false)).is_err());
        assert!(s.set(&Scope::Global, "mod.only", Value::from("v")).is_err());
        assert!(s.set(&Scope::Global, "global.flag", Value::from("yes")).is_err());
        assert!(s.set(&Scope::Global, "both", Value::from("c")).is_err());
        assert!(s.set(&Scope::Global, "nope", Value::from(1)).is_err());
        assert!(s.set(&m("../evil"), "mod.only", Value::from("v")).is_err());
        s.set(&m("x"), "mod.only", Value::from("v")).unwrap();
        assert_eq!(s.get("mod.only", Some("x")).unwrap(), Value::from("v"));
        // A mod-only preference has no global layer.
        assert_eq!(s.get("mod.only", None).unwrap(), Value::from(""));
    }

    #[test]
    fn keeps_unknown_keys_and_skips_bad_values() {
        let (t, s) = store();
        let file = t.path().join("settings.json");
        std::fs::write(&file, r#"{"future.key": 1, "global.flag": "not a bool"}"#).unwrap();
        // Wrong-typed stored value falls back to the default.
        assert_eq!(s.get("global.flag", None).unwrap(), Value::from(true));
        s.set(&Scope::Global, "global.flag", Value::from(false)).unwrap();
        let saved: Value = serde_json::from_str(&std::fs::read_to_string(&file).unwrap()).unwrap();
        assert_eq!(saved["future.key"], Value::from(1));
        assert_eq!(saved["global.flag"], Value::from(false));
    }

    #[test]
    fn installer_profiles_get_their_own_root() {
        let manager = Profile::default();
        let installer = Profile {
            mode: ProfileMode::SingleMod,
            mod_id: Some("eliza-access".into()),
            ..Profile::default()
        };
        let m = PrefStore::root_for(&manager).unwrap();
        let i = PrefStore::root_for(&installer).unwrap();
        assert!(m.ends_with("Loadstone"));
        assert!(i.ends_with(Path::new("Loadstone").join("installers").join("eliza-access")));
    }
}
