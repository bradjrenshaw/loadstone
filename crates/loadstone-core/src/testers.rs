//! Tester access (SPEC 2.3): one password, kept by a registry as a salted
//! hash, that unlocks the registry's tester-only listings and every mod's
//! prereleases. A gate for private testing, not encryption: the files stay
//! on public release pages.

use std::collections::BTreeMap;
use std::path::Path;
use std::sync::Mutex;
use std::time::{Duration, Instant};

use anyhow::{Context as _, Result};
use serde::{Deserialize, Serialize};

use crate::prefs::{PrefStore, Scope};
use crate::release::sha256_bytes;
use crate::types::ReleaseManifest;

/// Global preference holding the tester password the user entered.
pub const PREF_TESTER_PASSWORD: &str = "testerPassword";

/// `loadstone-packages/testers.json` in a registry.
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
        let seed = format!(
            "{:?}{}{password}",
            std::time::SystemTime::now(),
            std::process::id()
        );
        let salt = sha256_bytes(seed.as_bytes())[..16].to_string();
        let password_sha256 = hash(&salt, password);
        TestersFile { kind: "testers".into(), salt, password_sha256 }
    }

    pub fn accepts(&self, password: &str) -> bool {
        !password.is_empty() && hash(&self.salt, password).eq_ignore_ascii_case(&self.password_sha256)
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

/// The tester password saved in these preferences, if any.
pub fn saved_password(prefs: &PrefStore) -> Option<String> {
    prefs
        .get(PREF_TESTER_PASSWORD, None)
        .ok()
        .and_then(|v| v.as_str().map(str::to_string))
        .filter(|p| !p.is_empty())
}

/// Save (or, with an empty password, forget) the tester password.
pub fn save_password(prefs: &PrefStore, password: &str) -> Result<()> {
    if password.is_empty() {
        prefs.unset(&Scope::Global, PREF_TESTER_PASSWORD)
    } else {
        prefs
            .set(&Scope::Global, PREF_TESTER_PASSWORD, serde_json::Value::String(password.to_string()))
            .context("failed to save the tester password")
    }
}

/// Check `password` against the testers files of `sources` (registries,
/// as a profile lists them). Errors when none of them offers tester access.
pub fn check_password(sources: &[String], password: &str) -> Result<bool> {
    let mut fetcher = crate::registry::HttpFetcher::new(None, Box::new(|_| {}))?;
    let mut resolver = crate::registry::Resolver::from_sources(sources, &mut fetcher)?;
    if !resolver.offers_testers() {
        anyhow::bail!("none of the registries has tester access (no testers.json)");
    }
    Ok(resolver.unlock_testers(Some(password)))
}

/// How long a looked-up newest tag is reused. Each lookup is a GitHub
/// releases-list call, and unauthenticated clients get 60 an hour.
const NEWEST_TAG_TTL: Duration = Duration::from_secs(5 * 60);

static NEWEST_TAGS: Mutex<BTreeMap<String, (Instant, Option<String>)>> = Mutex::new(BTreeMap::new());

/// The newest release of `source` by version number, prereleases
/// included; None when none has a semver tag. Answers are reused for a
/// few minutes.
pub fn newest_release_tag(source: &str, mod_id: Option<&str>) -> Result<Option<String>> {
    let key = format!("{source}\n{}", mod_id.unwrap_or(""));
    if let Some((at, tag)) = NEWEST_TAGS.lock().ok().and_then(|m| m.get(&key).cloned()) {
        if at.elapsed() < NEWEST_TAG_TTL {
            return Ok(tag);
        }
    }
    let releases = crate::source::list_releases(source, mod_id)?;
    let tag = releases
        .into_iter()
        .filter_map(|r| {
            let v = semver::Version::parse(r.tag.trim().trim_start_matches(['v', 'V'])).ok()?;
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
    note: &mut dyn FnMut(&str),
) -> Result<(Option<String>, ReleaseManifest)> {
    if testers {
        match newest_release_tag(source, mod_id) {
            Ok(Some(tag)) => match crate::source::release_manifest(source, mod_id, Some(&tag)) {
                Ok(release) => return Ok((Some(tag), release)),
                Err(e) => note(&format!(
                    "Release {tag} has no usable Loadstone metadata ({e:#}); using the latest stable release."
                )),
            },
            Ok(None) => {}
            Err(e) => note(&format!(
                "Could not look up beta versions ({e:#}); using the latest stable release."
            )),
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

        let tmp = tempfile::tempdir().unwrap();
        assert!(read(tmp.path()).is_none());
        std::fs::write(tmp.path().join("a-mod.json"), br#"{"kind": "link", "source": "github:a/b"}"#).unwrap();
        std::fs::write(tmp.path().join("testers.json"), serde_json::to_string(&f).unwrap()).unwrap();
        assert!(read(tmp.path()).unwrap().accepts("swordfish"));
    }

    #[test]
    fn password_is_saved_and_forgotten() {
        let tmp = tempfile::tempdir().unwrap();
        let prefs = PrefStore::with_definitions(tmp.path().to_path_buf(), crate::prefs::DEFINITIONS);
        assert_eq!(saved_password(&prefs), None);
        save_password(&prefs, "swordfish").unwrap();
        assert_eq!(saved_password(&prefs).as_deref(), Some("swordfish"));
        save_password(&prefs, "").unwrap();
        assert_eq!(saved_password(&prefs), None);
    }
}
