//! Serde types for the package formats defined in SPEC.md (manifestVersion 1).

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};
use serde_json::Value;

pub const MANIFEST_VERSION: u32 = 1;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Kind {
    #[default]
    Mod,
    Game,
    Tool,
    Library,
    Link,
}

/// A hand-written project manifest (`mod.json`) for a mod, tool, or library.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProjectManifest {
    pub manifest_version: u32,
    #[serde(default)]
    pub kind: Kind,
    pub id: String,
    pub name: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub authors: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub license: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub game: Option<String>,
    /// Repo whose releases carry this package's artifacts, as `github:owner/repo`.
    /// Defaults to the registry repo containing this file.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub source: Option<String>,
    /// Registry-pinned release for packages released outside this format
    /// (SPEC 13.1). Mutually exclusive with `channels`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub pinned_release: Option<PinnedRelease>,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub distributions: BTreeMap<String, DistributionSupport>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub dependencies: Vec<Dependency>,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub channels: BTreeMap<String, Channel>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub install: Vec<Step>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub source_install: Vec<Step>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub uninstall: Vec<Step>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub cleanup_legacy: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub user_data: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub settings: Option<Settings>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub actions: Vec<Action>,
    /// Tools only: how an existing copy installed outside the manager is treated.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub conflict_policy: Option<String>,
    /// Dev-only block consumed by `modman package`; never emitted into release.json.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub packaging: Option<Packaging>,
}

/// A game package: pure data, committed to a registry (or embedded in a mod).
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct GameManifest {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub manifest_version: Option<u32>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub kind: Option<Kind>,
    pub id: String,
    pub name: String,
    #[serde(default)]
    pub detect: Detect,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub user_data: BTreeMap<String, String>,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub paths: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Detect {
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub markers: Vec<String>,
    /// Per-distribution detection data (`steam`, `epic`, `gog`, `itch`, ...),
    /// schema per distribution.
    #[serde(flatten)]
    pub distributions: BTreeMap<String, Value>,
}

/// A generated release manifest (`release.json`), attached to a GitHub release.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ReleaseManifest {
    pub manifest_version: u32,
    pub id: String,
    pub version: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub game: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub release_notes: Option<String>,
    pub artifacts: Vec<ReleaseArtifact>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub dependencies: Vec<Dependency>,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub distributions: BTreeMap<String, DistributionSupport>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub install: Vec<Step>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub uninstall: Vec<Step>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub cleanup_legacy: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub user_data: Vec<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub settings: Option<Settings>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub actions: Vec<Action>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub conflict_policy: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReleaseArtifact {
    pub file: String,
    pub sha256: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub when: Option<Condition>,
}

/// A release pinned in the package file itself, for upstreams that publish no
/// `release.json` (SPEC 13.1).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PinnedRelease {
    pub version: String,
    /// Release tag on the source repo; defaults to `v{version}`.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub tag: Option<String>,
    pub artifacts: Vec<ReleaseArtifact>,
}

/// A link file in a registry's `modmanager-packages/` directory: makes the
/// linked source's packages reachable through this registry (SPEC 2).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LinkEntry {
    pub kind: Kind,
    pub source: String,
    /// Optional allowlist of package ids resolvable through this link.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub packages: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum DistributionSupport {
    Level(SupportLevel),
    Detailed {
        level: SupportLevel,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        reason: Option<String>,
    },
}

impl DistributionSupport {
    pub fn level(&self) -> SupportLevel {
        match self {
            DistributionSupport::Level(l) => *l,
            DistributionSupport::Detailed { level, .. } => *level,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum SupportLevel {
    Supported,
    Untested,
    Unsupported,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Dependency {
    pub id: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub version: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Channel {
    pub source: ChannelSource,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub branch: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub tag: Option<String>,
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    pub include_prereleases: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ChannelSource {
    Release,
    Branch,
}

/// One install/uninstall/action step. The `step` field selects the variant.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "step", rename_all = "kebab-case", rename_all_fields = "camelCase")]
pub enum Step {
    ExtractArchive {
        routes: Vec<Route>,
        #[serde(flatten)]
        common: StepCommon,
    },
    CopyFiles {
        from: String,
        to: String,
        #[serde(flatten)]
        common: StepCommon,
    },
    EnsureDirs {
        paths: Vec<String>,
        #[serde(flatten)]
        common: StepCommon,
    },
    EditJson {
        file: String,
        #[serde(default, skip_serializing_if = "std::ops::Not::not")]
        create_if_missing: bool,
        ops: Vec<JsonOp>,
        #[serde(flatten)]
        common: StepCommon,
    },
    DeleteFiles {
        paths: Vec<String>,
        #[serde(flatten)]
        common: StepCommon,
    },
    PickDirectory {
        id: String,
        prompt: String,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        suggest: Option<String>,
        #[serde(flatten)]
        common: StepCommon,
    },
    Expect {
        checks: Vec<Check>,
        #[serde(flatten)]
        common: StepCommon,
    },
}

impl Step {
    pub fn name(&self) -> &'static str {
        match self {
            Step::ExtractArchive { .. } => "extract-archive",
            Step::CopyFiles { .. } => "copy-files",
            Step::EnsureDirs { .. } => "ensure-dirs",
            Step::EditJson { .. } => "edit-json",
            Step::DeleteFiles { .. } => "delete-files",
            Step::PickDirectory { .. } => "pick-directory",
            Step::Expect { .. } => "expect",
        }
    }

    pub fn common(&self) -> &StepCommon {
        match self {
            Step::ExtractArchive { common, .. }
            | Step::CopyFiles { common, .. }
            | Step::EnsureDirs { common, .. }
            | Step::EditJson { common, .. }
            | Step::DeleteFiles { common, .. }
            | Step::PickDirectory { common, .. }
            | Step::Expect { common, .. } => common,
        }
    }
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct StepCommon {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub when: Option<Condition>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub requires: Option<Requires>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Condition {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub distribution: Option<StringOrList>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub platform: Option<StringOrList>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub arch: Option<StringOrList>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub file_exists: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum StringOrList {
    One(String),
    Many(Vec<String>),
}

impl StringOrList {
    pub fn iter(&self) -> Box<dyn Iterator<Item = &str> + '_> {
        match self {
            StringOrList::One(s) => Box::new(std::iter::once(s.as_str())),
            StringOrList::Many(v) => Box::new(v.iter().map(String::as_str)),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Requires {
    pub file_exists: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub on_missing: Option<String>,
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    pub retryable: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Route {
    pub from: String,
    pub to: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub when: Option<Condition>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Check {
    pub file_exists: String,
    pub message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JsonOp {
    pub op: JsonOpKind,
    pub path: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub value: Option<Value>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum JsonOpKind {
    Set,
    Ensure,
    AppendUnique,
    RemoveValue,
    RemoveKey,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Settings {
    pub storage: SettingsStorage,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub note: Option<String>,
    pub entries: Vec<SettingEntry>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SettingsStorage {
    pub file: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub format: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SettingEntry {
    pub id: String,
    #[serde(rename = "type")]
    pub entry_type: SettingType,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub default: Option<Value>,
    pub label: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    pub prompt_on_install: bool,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub min: Option<f64>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub max: Option<f64>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub options: Vec<ChoiceOption>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum SettingType {
    Boolean,
    String,
    Number,
    Choice,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ChoiceOption {
    pub value: Value,
    pub label: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Action {
    pub id: String,
    pub label: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub enabled_when: Option<Condition>,
    pub steps: Vec<Step>,
}

/// Dev-only packaging configuration read by `modman package`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Packaging {
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub artifacts: Vec<PackagingArtifact>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PackagingArtifact {
    /// Path to the built artifact, relative to the manifest's directory.
    pub file: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub when: Option<Condition>,
}
