//! Self-update for the standalone builds (the manager and branded
//! installers). The release manifest's `installers` list names each
//! platform's asset, its hash, and the Loadstone version it was built from
//! (the legacy `installer` block is the Windows exe); a running build
//! compares that version against its own and, on acceptance, swaps itself
//! out:
//!
//! - Windows: the rename dance on the exe (Windows allows renaming a running
//!   exe, not overwriting it).
//! - macOS: the asset is a zipped `.app`. It is unpacked beside the running
//!   bundle, checked to carry the same bundle id, and swapped in by renaming
//!   (a running bundle can be moved; the process keeps its open files). The
//!   previous bundle waits in a hidden staging folder until the next start.

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

/// This build's platform, as release manifests name it.
fn this_platform() -> &'static str {
    crate::context::current_platform()
}

/// Is a newer build published at `source`? Every failure mode — offline,
/// no releases, no manifest, no `installer` block, unparsable versions —
/// answers `None`: a launch-time check must never nag or error.
pub fn check(source: &str, current_version: &str) -> Option<UpdateInfo> {
    let manifest = crate::source::release_manifest(source, None, None).ok()?;
    let installer = pick_installer(&manifest, this_platform())?;
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

/// This platform's build on a release: an `installers` entry for it, else
/// (Windows only) the legacy `installer` block. Never another platform's.
pub fn pick_installer(
    manifest: &crate::types::ReleaseManifest,
    platform: &str,
) -> Option<crate::types::InstallerInfo> {
    manifest
        .installers
        .iter()
        .find(|i| i.platform() == platform)
        .cloned()
        .or_else(|| manifest.installer.clone().filter(|i| i.platform() == platform))
}

/// Download the offered build, verify its hash, and swap it in for the
/// running one. Returns what the caller relaunches: the exe on Windows, the
/// `.app` bundle on macOS. A failed swap restores the original.
pub fn apply(info: &UpdateInfo, progress: impl FnMut(u32)) -> Result<PathBuf> {
    let exe = std::env::current_exe().context("cannot locate the running executable")?;
    // Refuse before downloading when the bundle can't be replaced anyway.
    let bundle = if cfg!(target_os = "macos") { Some(replaceable_bundle(&exe)?) } else { None };
    let bytes = crate::source::release_asset(&info.source, None, None, &info.file, progress)?;
    let actual = sha256_bytes(&bytes);
    if !actual.eq_ignore_ascii_case(&info.sha256) {
        bail!(
            "the downloaded update failed hash verification (expected {}, got {actual}); \
             not installed",
            info.sha256
        );
    }
    match bundle {
        Some(bundle) => {
            swap_in_bundle(&bundle, &bytes)?;
            Ok(bundle)
        }
        None => {
            swap_in(&exe, &bytes)?;
            Ok(exe)
        }
    }
}

/// The `.app` bundle holding `exe` (`X.app/Contents/MacOS/x`), if it is in one.
pub fn bundle_of(exe: &Path) -> Option<PathBuf> {
    let bundle = exe.parent()?.parent()?.parent()?;
    let is_app = bundle.extension().is_some_and(|e| e.eq_ignore_ascii_case("app"));
    is_app.then(|| bundle.to_path_buf())
}

/// The running bundle, if self-update can replace it; otherwise an error
/// that tells the user what to do instead.
fn replaceable_bundle(exe: &Path) -> Result<PathBuf> {
    let bundle = bundle_of(exe).context("this build is not running from an .app bundle")?;
    // Gatekeeper runs a quarantined app that was never moved from a
    // read-only, randomized copy; nothing there can be replaced.
    if bundle.to_string_lossy().contains("/AppTranslocation/") {
        bail!(
            "macOS is running this app from a temporary read-only copy, so it can't \
             update itself. Move it into your Applications folder, open it from there, \
             and update again."
        );
    }
    Ok(bundle)
}

/// Where a bundle's update is unpacked, and where the previous bundle waits
/// until the next start removes it: a hidden folder beside the bundle, so
/// every move stays on one volume.
fn staging_dir(bundle: &Path) -> Result<PathBuf> {
    let name = bundle.file_name().and_then(|n| n.to_str()).context("bad bundle path")?;
    let parent = bundle.parent().context("bad bundle path")?;
    Ok(parent.join(format!(".{name}.update")))
}

/// Unpack a zipped `.app` beside `bundle`, check it is the same app (same
/// bundle id), and swap it into place. The old bundle moves into the
/// staging folder; if the final move fails it is moved back.
pub fn swap_in_bundle(bundle: &Path, zip_bytes: &[u8]) -> Result<()> {
    let staging = staging_dir(bundle)?;
    let _ = std::fs::remove_dir_all(&staging);
    std::fs::create_dir(&staging).with_context(|| {
        format!(
            "can't write next to {} (no permission?). Download the new version from \
             the release page instead",
            bundle.display()
        )
    })?;
    let unpacked = staging.join("new");
    unzip_bundle(zip_bytes, &unpacked)?;
    let new_bundle = single_app(&unpacked)?;

    let want = bundle_id(bundle)?;
    let got = bundle_id(&new_bundle)?;
    if want != got {
        bail!("the update is a different app ({got}, expected {want}); not installed");
    }

    let previous = staging.join("previous.app");
    std::fs::rename(bundle, &previous).context("could not move the current app aside")?;
    if let Err(e) = std::fs::rename(&new_bundle, bundle) {
        let _ = std::fs::rename(&previous, bundle); // restore
        return Err(e).context("could not move the new app into place");
    }
    let _ = std::fs::remove_dir_all(&unpacked);
    Ok(())
}

/// Extract a zip (as `ditto -c -k` writes it) into `dest`, keeping unix
/// modes and symlinks: a bundle's executable bit and framework links must
/// survive. Entries that would land outside `dest` are refused.
fn unzip_bundle(zip_bytes: &[u8], dest: &Path) -> Result<()> {
    let mut archive = zip::ZipArchive::new(std::io::Cursor::new(zip_bytes))
        .context("the downloaded update is not a zip")?;
    for i in 0..archive.len() {
        let mut entry = archive.by_index(i)?;
        let rel = entry
            .enclosed_name()
            .with_context(|| format!("unsafe path in the update: {}", entry.name()))?;
        // ditto's resource-fork sidecars; nothing in a bundle needs them.
        if rel.components().next().is_some_and(|c| c.as_os_str() == "__MACOSX") {
            continue;
        }
        let out = dest.join(rel);
        let mode = entry.unix_mode().unwrap_or(0);
        if entry.is_dir() {
            std::fs::create_dir_all(&out)?;
            continue;
        }
        if let Some(parent) = out.parent() {
            std::fs::create_dir_all(parent)?;
        }
        let mut contents = Vec::new();
        std::io::Read::read_to_end(&mut entry, &mut contents)?;
        if mode & 0o170000 == 0o120000 {
            let target = String::from_utf8(contents).context("bad symlink in the update")?;
            #[cfg(unix)]
            std::os::unix::fs::symlink(&target, &out)?;
            #[cfg(not(unix))]
            bail!("the update holds a symlink ({target}); only macOS can unpack it");
            continue;
        }
        std::fs::write(&out, &contents)?;
        #[cfg(unix)]
        if mode & 0o777 != 0 {
            use std::os::unix::fs::PermissionsExt;
            std::fs::set_permissions(&out, std::fs::Permissions::from_mode(mode & 0o777))?;
        }
    }
    Ok(())
}

/// The one `.app` directly inside `dir`.
fn single_app(dir: &Path) -> Result<PathBuf> {
    let apps: Vec<PathBuf> = std::fs::read_dir(dir)?
        .filter_map(|e| e.ok().map(|e| e.path()))
        .filter(|p| p.extension().is_some_and(|e| e == "app") && p.is_dir())
        .collect();
    match apps.as_slice() {
        [one] => Ok(one.clone()),
        _ => bail!("the update should hold exactly one .app (found {})", apps.len()),
    }
}

/// CFBundleIdentifier from a bundle's Info.plist. CMake writes XML plists;
/// a binary one is read through plutil.
fn bundle_id(bundle: &Path) -> Result<String> {
    let plist = bundle.join("Contents").join("Info.plist");
    let bytes = std::fs::read(&plist).with_context(|| format!("no {}", plist.display()))?;
    if bytes.starts_with(b"bplist") {
        let out = std::process::Command::new("plutil")
            .args(["-extract", "CFBundleIdentifier", "raw", "-o", "-"])
            .arg(&plist)
            .output()
            .context("failed to run plutil")?;
        let id = String::from_utf8_lossy(&out.stdout).trim().to_string();
        if !out.status.success() || id.is_empty() {
            bail!("{} has no CFBundleIdentifier", plist.display());
        }
        return Ok(id);
    }
    let text = String::from_utf8_lossy(&bytes);
    let after_key = text
        .split("<key>CFBundleIdentifier</key>")
        .nth(1)
        .with_context(|| format!("{} has no CFBundleIdentifier", plist.display()))?;
    let value = after_key
        .trim_start()
        .strip_prefix("<string>")
        .and_then(|v| v.split("</string>").next())
        .with_context(|| format!("{}: CFBundleIdentifier is not a string", plist.display()))?;
    Ok(value.trim().to_string())
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

/// Remove what a previous update left behind: the exe's `<name>.old`, or a
/// bundle's staging folder (with the previous bundle in it). Call once at
/// startup; every failure (still locked, never existed) is ignored.
pub fn cleanup_leftover(exe: &Path) {
    if let Some(name) = exe.file_name().and_then(|n| n.to_str()) {
        let _ = std::fs::remove_file(exe.with_file_name(format!("{name}.old")));
    }
    if let Some(staging) = bundle_of(exe).and_then(|b| staging_dir(&b).ok()) {
        let _ = std::fs::remove_dir_all(staging);
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

    fn plist(id: &str) -> String {
        format!(
            "<?xml version=\"1.0\"?>\n<plist version=\"1.0\">\n<dict>\n\t<key>CFBundleExecutable</key>\n\t<string>App</string>\n\t<key>CFBundleIdentifier</key>\n\t<string>{id}</string>\n</dict>\n</plist>\n"
        )
    }

    /// A zipped bundle shaped like `ditto -c -k --keepParent` output.
    fn zipped_app(name: &str, id: &str, exe_body: &[u8]) -> Vec<u8> {
        let mut buf = std::io::Cursor::new(Vec::new());
        {
            let mut w = zip::ZipWriter::new(&mut buf);
            let dir = zip::write::SimpleFileOptions::default();
            let exec = zip::write::SimpleFileOptions::default().unix_permissions(0o755);
            w.add_directory(format!("{name}/Contents/MacOS/"), dir).unwrap();
            w.start_file(format!("{name}/Contents/Info.plist"), dir).unwrap();
            std::io::Write::write_all(&mut w, plist(id).as_bytes()).unwrap();
            w.start_file(format!("{name}/Contents/MacOS/App"), exec).unwrap();
            std::io::Write::write_all(&mut w, exe_body).unwrap();
            w.add_symlink(format!("{name}/Contents/Current"), "MacOS", dir).unwrap();
            w.start_file("__MACOSX/._junk", dir).unwrap();
            w.finish().unwrap();
        }
        buf.into_inner()
    }

    fn installed_app(root: &Path, id: &str) -> PathBuf {
        let bundle = root.join("My App.app");
        std::fs::create_dir_all(bundle.join("Contents/MacOS")).unwrap();
        std::fs::write(bundle.join("Contents/Info.plist"), plist(id)).unwrap();
        std::fs::write(bundle.join("Contents/MacOS/App"), b"v1").unwrap();
        bundle
    }

    #[test]
    fn bundle_of_finds_the_app() {
        let exe = Path::new("/Applications/My App.app/Contents/MacOS/App");
        assert_eq!(bundle_of(exe).unwrap(), Path::new("/Applications/My App.app"));
        assert!(bundle_of(Path::new("/usr/local/bin/loadstone")).is_none());
    }

    #[cfg(unix)]
    #[test]
    fn bundle_swap_replaces_the_app_and_cleanup_clears_staging() {
        use std::os::unix::fs::PermissionsExt;
        let tmp = tempfile::tempdir().unwrap();
        let bundle = installed_app(tmp.path(), "com.example.app");

        // The zipped bundle's own name doesn't matter; the installed name stays.
        swap_in_bundle(&bundle, &zipped_app("Renamed.app", "com.example.app", b"v2")).unwrap();
        let exe = bundle.join("Contents/MacOS/App");
        assert_eq!(std::fs::read(&exe).unwrap(), b"v2");
        assert_eq!(std::fs::metadata(&exe).unwrap().permissions().mode() & 0o777, 0o755);
        assert!(bundle.join("Contents/Current").is_symlink());
        let staging = tmp.path().join(".My App.app.update");
        assert_eq!(std::fs::read(staging.join("previous.app/Contents/MacOS/App")).unwrap(), b"v1");

        cleanup_leftover(&exe);
        assert!(!staging.exists());
        assert!(exe.exists());
    }

    #[test]
    fn bundle_swap_refuses_a_different_app() {
        let tmp = tempfile::tempdir().unwrap();
        let bundle = installed_app(tmp.path(), "com.example.app");
        let err = swap_in_bundle(&bundle, &zipped_app("Other.app", "com.example.other", b"x"))
            .unwrap_err();
        assert!(err.to_string().contains("different app"), "{err}");
        assert_eq!(std::fs::read(bundle.join("Contents/MacOS/App")).unwrap(), b"v1");
    }

    #[test]
    fn translocated_bundles_are_refused() {
        let exe = Path::new("/private/var/folders/x/AppTranslocation/ABC/d/My App.app/Contents/MacOS/App");
        let err = replaceable_bundle(exe).unwrap_err();
        assert!(err.to_string().contains("Applications"), "{err}");
    }

    #[test]
    fn picks_only_this_platforms_installer() {
        use crate::types::{InstallerInfo, ReleaseManifest};
        let info = |file: &str, platform: Option<&str>| InstallerInfo {
            file: file.into(),
            loadstone_version: "1.0.0".into(),
            sha256: "00".into(),
            platform: platform.map(str::to_string),
        };
        let mut m: ReleaseManifest = serde_json::from_value(serde_json::json!({
            "manifestVersion": 1, "id": "m", "version": "1.0.0", "artifacts": []
        }))
        .unwrap();
        // A legacy release: just the exe.
        m.installer = Some(info("A.exe", None));
        assert_eq!(pick_installer(&m, "windows").unwrap().file, "A.exe");
        assert!(pick_installer(&m, "macos").is_none(), "never an exe on macOS");
        m.installers = vec![info("A.exe", Some("windows")), info("A.app.zip", Some("macos"))];
        assert_eq!(pick_installer(&m, "macos").unwrap().file, "A.app.zip");
        assert!(pick_installer(&m, "linux").is_none());
    }
}
