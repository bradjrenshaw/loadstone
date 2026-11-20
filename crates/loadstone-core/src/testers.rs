//! Tester access (SPEC 2.3): one password, kept by a registry as a salted
//! hash, that unlocks the registry's tester-only listings and the
//! prereleases of the mods it lists. A gate for private testing, not
//! encryption: the files stay on public release pages.

use std::collections::BTreeMap;
use std::path::Path;
use std::sync::Mutex;
use std::time::{Duration, Instant};

use anyhow::{Context as _, Result};
use serde::{Deserialize, Serialize};

use crate::prefs::{PrefStore, Scope};
use crate::release::sha256_bytes;
use crate::types::ReleaseManifest;

/// Global preference holding the tester passwords the user entered.
pub const PREF_TESTER_PASSWORD: &str = "testerPassword";

/// Where a package stands on tester access (SPEC 2.3). One password
/// covers a package: its own, from its package file, or else the password
/// of the registry that lists it. Another registry's password never does.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TesterAccess {
    /// Nothing gates the package: it has no password of its own and its
    /// registry has no testers file.
    Open,
    /// A password covers the package and none of the saved ones is it.
    Locked,
    /// The password that covers the package was entered.
    Unlocked,
}

impl TesterAccess {
    /// "Latest" includes beta versions: installs and updates without a
    /// chosen version take the newest release, prerelease or not.
    pub fn betas(self) -> bool {
        self == TesterAccess::Unlocked
    }

    /// Version pickers show prereleases: to testers, and to everyone when
    /// nothing gates them.
    pub fn shows_prereleases(self) -> bool {
        self != TesterAccess::Locked
    }
}

/// A password kept as a salted hash; the password itself is never
/// published.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PasswordHash {
    pub salt: String,
    pub password_sha256: String,
}

impl PasswordHash {
    /// The hash of `password` under a fresh salt.
    pub fn new(password: &str) -> Self {
        static COUNTER: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(0);
        let seed = format!(
            "{:?}{}{}{password}",
            std::time::SystemTime::now(),
            std::process::id(),
            COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed)
        );
        let salt = sha256_bytes(seed.as_bytes())[..16].to_string();
        let password_sha256 = hash(&salt, password);
        PasswordHash { salt, password_sha256 }
    }

    pub fn accepts(&self, password: &str) -> bool {
        !password.is_empty() && hash(&self.salt, password).eq_ignore_ascii_case(&self.password_sha256)
    }
}

/// `loadstone-packages/testers.json` in a registry: the password for the
/// registry's packages. A package's own password lives in its package
/// file instead (`testers` in the project manifest).
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct TestersFile {
    pub kind: String,
    pub salt: String,
    pub password_sha256: String,
}

impl TestersFile {
    /// A file for `password` with a fresh salt.
    pub fn new(password: &str) -> Self {
        let PasswordHash { salt, password_sha256 } = PasswordHash::new(password);
        TestersFile { kind: "testers".into(), salt, password_sha256 }
    }

    /// Whether `password` is the registry's password.
    pub fn accepts(&self, password: &str) -> bool {
        !password.is_empty() && hash(&self.salt, password).eq_ignore_ascii_case(&self.password_sha256)
    }
}

/// What one password unlocks across some registries.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct Unlocks {
    /// It is a registry's password: every package that registry lists
    /// without a password of its own.
    pub registry_wide: bool,
    /// Ids of the packages whose own password it is.
    pub packages: Vec<String>,
}

impl Unlocks {
    pub fn any(&self) -> bool {
        self.registry_wide || !self.packages.is_empty()
    }

    /// One sentence for the user saying what the password gave them.
    pub fn describe(&self) -> String {
        let mods = self.packages.join(", ");
        match (self.registry_wide, self.packages.is_empty()) {
            (true, true) => crate::t!("core-tester-unlocked-registry"),
            (true, false) => crate::t!("core-tester-unlocked-registry-and-mods", mods = mods),
            (false, _) => crate::t!("core-tester-unlocked-mods", mods = mods),
        }
    }
}

/// Tester access to a package for someone who entered `passwords`. `own`
/// is the password in its package file, `registry` the testers file of
/// the registry that lists it. A package with its own password answers to
/// that one only; any other answers to its registry's, and is open when
/// the registry has none.
pub fn access(own: Option<&PasswordHash>, registry: Option<&TestersFile>, passwords: &[String]) -> TesterAccess {
    let unlocked = match (own, registry) {
        (Some(own), _) => passwords.iter().any(|p| own.accepts(p)),
        (None, Some(registry)) => passwords.iter().any(|p| registry.accepts(p)),
        (None, None) => return TesterAccess::Open,
    };
    if unlocked {
        TesterAccess::Unlocked
    } else {
        TesterAccess::Locked
    }
}

pub fn hash(salt: &str, password: &str) -> String {
    sha256_bytes(format!("loadstone-testers:{salt}:{password}").as_bytes())
}

/// The registry directory's testers file, if it has one.
pub fn read(dir: &Path) -> Option<TestersFile> {
    for entry in std::fs::read_dir(dir).ok()?.filter_map(|e| e.ok()) {
        let path = entry.path();
        if path.extension().and_then(|e| e.to_str()) != Some("json") {
            continue;
        }
        let Ok(text) = std::fs::read_to_string(&path) else { continue };
        let Ok(doc) = serde_json::from_str::<serde_json::Value>(text.trim_start_matches('\u{feff}')) else {
            continue;
        };
        if doc.get("kind").and_then(|k| k.as_str()) == Some("testers") {
            return serde_json::from_value(doc).ok();
        }
    }
    None
}

/// The tester passwords saved in these preferences: a tester may hold
/// several, for different registries and mods. A lone string (how one
/// password used to be saved) reads as a list of one.
pub fn saved_passwords(prefs: &PrefStore) -> Vec<String> {
    let value = prefs.get(PREF_TESTER_PASSWORD, None).unwrap_or(serde_json::Value::Null);
    let all: Vec<String> = match value {
        serde_json::Value::String(one) => vec![one],
        serde_json::Value::Array(many) => many.into_iter().filter_map(|v| v.as_str().map(str::to_string)).collect(),
        _ => Vec::new(),
    };
    all.into_iter().filter(|p| !p.is_empty()).collect()
}

/// Save `password` alongside the ones already saved.
pub fn add_password(prefs: &PrefStore, password: &str) -> Result<()> {
    let mut all = saved_passwords(prefs);
    if password.is_empty() || all.iter().any(|p| p == password) {
        return Ok(());
    }
    all.push(password.to_string());
    prefs
        .set(&Scope::Global, PREF_TESTER_PASSWORD, serde_json::json!(all))
        .with_context(|| crate::t!("core-tester-save-failed"))
}

/// Forget every saved tester password.
pub fn forget_passwords(prefs: &PrefStore) -> Result<()> {
    prefs.unset(&Scope::Global, PREF_TESTER_PASSWORD)
}

/// What `password` unlocks through `sources` (registries, as a profile
/// lists them): a registry, or the mods whose own password it is.
pub fn check_password(sources: &[String], password: &str) -> Result<Unlocks> {
    let mut fetcher = crate::registry::HttpFetcher::new(None, Box::new(|_| {}))?;
    let mut resolver = crate::registry::Resolver::from_sources(sources, &mut fetcher)?;
    resolver.unlocks(password)
}

/// How long a looked-up newest tag is reused. Each lookup is a GitHub
/// releases-list call, and unauthenticated clients get 60 an hour.
const NEWEST_TAG_TTL: Duration = Duration::from_secs(5 * 60);

static NEWEST_TAGS: Mutex<BTreeMap<String, (Instant, Option<String>)>> = Mutex::new(BTreeMap::new());

/// Whether a newest-release lookup may reuse a recent answer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Lookup {
    /// Reuse an answer up to a few minutes old: for showing a page, which
    /// happens often and must not use up the rate limit.
    Cached,
    /// Ask now: for installs and updates, which must act on what is
    /// published at this moment (a beta released a minute ago).
    Fresh,
}

/// The newest release of `source` by version number, prereleases
/// included; None when none has a semver tag.
pub fn newest_release_tag(source: &str, mod_id: Option<&str>, lookup: Lookup) -> Result<Option<String>> {
    let key = format!("{source}\n{}", mod_id.unwrap_or(""));
    if lookup == Lookup::Cached {
        if let Some((at, tag)) = NEWEST_TAGS.lock().ok().and_then(|m| m.get(&key).cloned()) {
            if at.elapsed() < NEWEST_TAG_TTL {
                return Ok(tag);
            }
        }
    }
    let releases = crate::source::list_releases(source, mod_id)?;
    let tag = releases
        .into_iter()
        .filter_map(|r| {
            let v = crate::release::parse_version(&r.tag)?;
            Some((v, r.tag))
        })
        .max_by(|a, b| a.0.cmp(&b.0))
        .map(|(_, tag)| tag);
    if let Ok(mut m) = NEWEST_TAGS.lock() {
        m.insert(key, (Instant::now(), tag.clone()));
    }
    Ok(tag)
}

/// The release "latest" means (SPEC 2.3), with its tag when that is not
/// simply the latest stable release. For testers it is the newest release
/// by version number, beta or not; when that can't be determined (the
/// releases list is unreachable or rate-limited, or the newest tag has no
/// loadstone-release.json) it falls back to the latest stable release,
/// telling `note` why, so testers can always install what everyone can.
pub fn latest_release(
    source: &str,
    mod_id: Option<&str>,
    testers: bool,
    lookup: Lookup,
    note: &mut dyn FnMut(&str),
) -> Result<(Option<String>, ReleaseManifest)> {
    if testers {
        match newest_release_tag(source, mod_id, lookup) {
            Ok(Some(tag)) => match crate::source::release_manifest(source, mod_id, Some(&tag)) {
                Ok(release) => return Ok((Some(tag), release)),
                Err(e) => note(&crate::t!(
                    "core-tester-beta-unusable",
                    tag = &tag,
                    error = format!("{e:#}")
                )),
            },
            Ok(None) => {}
            Err(e) => note(&crate::t!("core-tester-beta-lookup-failed", error = format!("{e:#}"))),
        }
    }
    Ok((None, crate::source::release_manifest(source, mod_id, None)?))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hash_checks_and_file_reading() {
        let f = TestersFile::new("swordfish");
        assert!(f.accepts("swordfish"));
        assert!(!f.accepts("Swordfish"));
        assert!(!f.accepts(""));
        assert_ne!(TestersFile::new("swordfish").salt, "", "salted");
        assert_ne!(PasswordHash::new("swordfish").salt, PasswordHash::new("swordfish").salt, "a fresh salt each time");

        let tmp = tempfile::tempdir().unwrap();
        assert!(read(tmp.path()).is_none());
        std::fs::write(tmp.path().join("a-mod.json"), br#"{"kind": "link", "source": "github:a/b"}"#).unwrap();
        std::fs::write(tmp.path().join("testers.json"), serde_json::to_string(&f).unwrap()).unwrap();
        assert!(read(tmp.path()).unwrap().accepts("swordfish"));
    }

    #[test]
    fn passwords_are_saved_together_and_forgotten_together() {
        let tmp = tempfile::tempdir().unwrap();
        let prefs = PrefStore::with_definitions(tmp.path().to_path_buf(), crate::prefs::DEFINITIONS);
        assert!(saved_passwords(&prefs).is_empty());
        add_password(&prefs, "swordfish").unwrap();
        add_password(&prefs, "marlin").unwrap();
        add_password(&prefs, "swordfish").unwrap();
        add_password(&prefs, "").unwrap();
        assert_eq!(saved_passwords(&prefs), vec!["swordfish", "marlin"]);
        forget_passwords(&prefs).unwrap();
        assert!(saved_passwords(&prefs).is_empty());

        // One password saved the old way, as a lone string, still counts.
        prefs.set(&Scope::Global, PREF_TESTER_PASSWORD, serde_json::json!("swordfish")).unwrap();
        assert_eq!(saved_passwords(&prefs), vec!["swordfish"]);
        add_password(&prefs, "marlin").unwrap();
        assert_eq!(saved_passwords(&prefs), vec!["swordfish", "marlin"]);
    }

    #[test]
    fn a_package_with_its_own_password_answers_only_to_it() {
        let pw = |list: &[&str]| list.iter().map(|p| p.to_string()).collect::<Vec<_>>();
        let registry = TestersFile::new("registry");
        let own = PasswordHash::new("mod");
        // The registry's password covers a package without its own.
        assert_eq!(access(None, Some(&registry), &pw(&[])), TesterAccess::Locked);
        assert_eq!(access(None, Some(&registry), &pw(&["registry"])), TesterAccess::Unlocked);
        assert_eq!(access(None, Some(&registry), &pw(&["mod"])), TesterAccess::Locked);
        // A package with its own password is not opened by the registry's.
        assert_eq!(access(Some(&own), Some(&registry), &pw(&["registry"])), TesterAccess::Locked);
        assert_eq!(access(Some(&own), Some(&registry), &pw(&["mod"])), TesterAccess::Unlocked);
        assert_eq!(access(Some(&own), Some(&registry), &pw(&["wrong", "mod"])), TesterAccess::Unlocked);
        // Its own password gates it in a registry that has none.
        assert_eq!(access(Some(&own), None, &pw(&[])), TesterAccess::Locked);
        assert_eq!(access(Some(&own), None, &pw(&["mod"])), TesterAccess::Unlocked);
        // No password anywhere: open.
        assert_eq!(access(None, None, &pw(&["mod"])), TesterAccess::Open);
    }
}
