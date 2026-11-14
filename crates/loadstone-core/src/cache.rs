//! The download cache (SPEC 2.2): release artifacts a package installed,
//! kept by SHA-256 so an update, a repair, or a change of install options
//! downloads only what changed. Mods with large components (a 140 MB mod
//! pack that changes once a year) would otherwise fetch everything again on
//! every update.
//!
//! Layout: `<cache root>/<package id>/<sha256>`. A package's entries live
//! until a later install no longer lists them, or the package is
//! uninstalled from its last game copy.

use std::path::{Path, PathBuf};

use anyhow::{Context as _, Result};

use crate::release::sha256_bytes;

pub struct ArtifactCache {
    dir: PathBuf,
}

impl ArtifactCache {
    /// The cache beside a state store root (`Loadstone/installed` ->
    /// `Loadstone/cache`), for one package.
    pub fn for_package(store_root: &Path, id: &str) -> Self {
        let base = store_root.parent().map(Path::to_path_buf).unwrap_or_else(|| store_root.to_path_buf());
        Self { dir: base.join("cache").join(id) }
    }

    fn entry(&self, sha256: &str) -> Option<PathBuf> {
        let sha = sha256.to_ascii_lowercase();
        // Hex only: the hash names a file.
        (sha.len() == 64 && sha.bytes().all(|b| b.is_ascii_hexdigit())).then(|| self.dir.join(sha))
    }

    /// The cached bytes for `sha256`, when present and intact.
    pub fn get(&self, sha256: &str) -> Option<Vec<u8>> {
        let path = self.entry(sha256)?;
        let data = std::fs::read(&path).ok()?;
        if sha256_bytes(&data).eq_ignore_ascii_case(sha256) {
            Some(data)
        } else {
            let _ = std::fs::remove_file(&path); // damaged: fetch again
            None
        }
    }

    /// Keep `data` if it really hashes to `sha256`; best effort.
    pub fn put(&self, sha256: &str, data: &[u8]) {
        let Some(path) = self.entry(sha256) else { return };
        if !sha256_bytes(data).eq_ignore_ascii_case(sha256) || std::fs::create_dir_all(&self.dir).is_err() {
            return;
        }
        let tmp = path.with_extension("partial");
        if std::fs::write(&tmp, data).is_ok() && std::fs::rename(&tmp, &path).is_err() {
            let _ = std::fs::remove_file(&tmp);
        }
    }

    /// Drop every entry not named in `keep` (the current release's hashes).
    pub fn retain(&self, keep: &[&str]) -> Result<()> {
        let Ok(entries) = std::fs::read_dir(&self.dir) else { return Ok(()) };
        for entry in entries.filter_map(|e| e.ok()) {
            let name = entry.file_name().to_string_lossy().to_ascii_lowercase();
            if !keep.iter().any(|k| k.eq_ignore_ascii_case(&name)) {
                std::fs::remove_file(entry.path())
                    .with_context(|| format!("failed to remove {}", entry.path().display()))?;
            }
        }
        Ok(())
    }

    /// Remove the package's cache entirely.
    pub fn clear(&self) {
        let _ = std::fs::remove_dir_all(&self.dir);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn get_put_retain_clear() {
        let tmp = tempfile::tempdir().unwrap();
        let cache = ArtifactCache::for_package(&tmp.path().join("installed"), "civ-v-access");
        let (a, b) = (b"engine zip".to_vec(), b"modpack zip".to_vec());
        let (sa, sb) = (sha256_bytes(&a), sha256_bytes(&b));
        assert!(cache.get(&sa).is_none());
        cache.put(&sa, &a);
        cache.put(&sb, &b);
        cache.put(&sa, b"not the bytes the hash names"); // ignored
        assert_eq!(cache.get(&sa).as_deref(), Some(a.as_slice()));
        assert!(tmp.path().join("cache").join("civ-v-access").join(&sa).is_file());

        // A damaged entry is dropped, not served.
        std::fs::write(tmp.path().join("cache/civ-v-access").join(&sb), b"bit rot").unwrap();
        assert!(cache.get(&sb).is_none());
        cache.put(&sb, &b);

        cache.retain(&[&sb]).unwrap();
        assert!(cache.get(&sa).is_none());
        assert!(cache.get(&sb).is_some());
        assert!(cache.get("../../etc/passwd").is_none());

        cache.clear();
        assert!(!tmp.path().join("cache").join("civ-v-access").exists());
    }
}
