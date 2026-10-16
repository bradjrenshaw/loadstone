//! Self-update for the standalone executables (the manager and branded
//! installers). The release manifest's `installer` block names the exe
//! asset, its hash, and the Loadstone version it was built from; a running
//! binary compares that version against its own and, on acceptance,
//! swaps itself out via the rename dance (Windows allows renaming a
//! running exe, not overwriting it).

use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};

use crate::release::{normalize_version, sha256_bytes};

/// A newer build offered by the update source.
#[derive(Debug, Clone)]
pub struct UpdateInfo {
    /// Normalized Loadstone version of the offered exe.
    pub version: String,
    /// Release asset name of the exe.
    pub file: String,
    pub sha256: String,
    /// `github:owner/repo` the offer came from (and the download will use).
    pub source: String,
}

/// Is a newer build published at `source`? Every failure mode — offline,
/// no releases, no manifest, no `installer` block, unparsable versions —
/// answers `None`: a launch-time check must never nag or error.
pub fn check(source: &str, current_version: &str) -> Option<UpdateInfo> {
    let manifest = crate::source::release_manifest(source, None, None).ok()?;
    let installer = manifest.installer?;
    let offered = normalize_version(&installer.loadstone_version).ok()?;
    let current = normalize_version(current_version).ok()?;
    let newer = semver::Version::parse(&offered).ok()?
        > semver::Version::parse(&current).ok()?;
    if !newer {
        return None;
    }
    Some(UpdateInfo {
        version: offered,
        file: installer.file,
        sha256: installer.sha256,
        source: source.to_string(),
    })
}

/// Download the offered exe, verify its hash, and swap it in for the
/// running executable. Returns the executable's path for the caller to
/// relaunch. A failed swap restores the original.
pub fn apply(info: &UpdateInfo, progress: impl FnMut(u32)) -> Result<PathBuf> {
    let bytes = crate::source::release_asset(&info.source, None, None, &info.file, progress)?;
    let actual = sha256_bytes(&bytes);
    if !actual.eq_ignore_ascii_case(&info.sha256) {
        bail!(
            "the downloaded update failed hash verification (expected {}, got {actual}); \
             not installed",
            info.sha256
        );
    }
    let exe = std::env::current_exe().context("cannot locate the running executable")?;
    swap_in(&exe, &bytes)?;
    Ok(exe)
}

/// The rename dance: stage the new bytes next to the exe, move the (still
/// running) exe aside as `<name>.old`, move the staged file into place.
/// If the final move fails the original is moved back.
pub fn swap_in(exe: &Path, new_bytes: &[u8]) -> Result<()> {
    let name = exe
        .file_name()
        .and_then(|n| n.to_str())
        .context("bad executable path")?;
    let staged = exe.with_file_name(format!("{name}.new"));
    let old = exe.with_file_name(format!("{name}.old"));
    std::fs::write(&staged, new_bytes)
        .with_context(|| format!("could not write {}", staged.display()))?;
    let _ = std::fs::remove_file(&old);
    std::fs::rename(exe, &old)
        .context("could not move the current executable aside")?;
    if let Err(e) = std::fs::rename(&staged, exe) {
        let _ = std::fs::rename(&old, exe); // restore
        let _ = std::fs::remove_file(&staged);
        return Err(e).context("could not move the new executable into place");
    }
    Ok(())
}

/// Remove the `<name>.old` left behind by a previous update. Call once at
/// startup; every failure (still locked, never existed) is ignored.
pub fn cleanup_leftover(exe: &Path) {
    if let Some(name) = exe.file_name().and_then(|n| n.to_str()) {
        let _ = std::fs::remove_file(exe.with_file_name(format!("{name}.old")));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn swap_replaces_and_keeps_the_old_copy() {
        let tmp = tempfile::tempdir().unwrap();
        let exe = tmp.path().join("tool.exe");
        std::fs::write(&exe, b"v1").unwrap();

        swap_in(&exe, b"v2").unwrap();
        assert_eq!(std::fs::read(&exe).unwrap(), b"v2");
        assert_eq!(std::fs::read(tmp.path().join("tool.exe.old")).unwrap(), b"v1");
        assert!(!tmp.path().join("tool.exe.new").exists());

        // A second update replaces the leftover .old.
        swap_in(&exe, b"v3").unwrap();
        assert_eq!(std::fs::read(&exe).unwrap(), b"v3");
        assert_eq!(std::fs::read(tmp.path().join("tool.exe.old")).unwrap(), b"v2");

        cleanup_leftover(&exe);
        assert!(!tmp.path().join("tool.exe.old").exists());
    }
}
