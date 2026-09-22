//! Routed archive extraction (SPEC §9.1): zip and tar.gz (upstream tools
//! ship the latter for macOS/Linux). The format is sniffed from the bytes,
//! not the file name, so a mislabelled asset still extracts.

use std::io::{Cursor, Read};
use std::path::{Component, PathBuf};

use anyhow::{bail, Context as _, Result};

use crate::context::InstallContext;
use crate::types::Route;

/// One file pulled out of an archive, format-agnostic.
struct Entry {
    /// Entry name with `\` normalized to `/`; directories are never listed.
    name: String,
    contents: Vec<u8>,
    /// Unix permission bits when the archive recorded them.
    mode: Option<u32>,
}

#[derive(Debug, PartialEq)]
enum Format {
    Zip,
    TarGz,
}

fn sniff_format(data: &[u8]) -> Result<Format> {
    if data.starts_with(b"PK\x03\x04") || data.starts_with(b"PK\x05\x06") {
        Ok(Format::Zip)
    } else if data.starts_with(&[0x1f, 0x8b]) {
        Ok(Format::TarGz)
    } else {
        bail!("unrecognized archive format (expected a .zip or .tar.gz)")
    }
}

/// Read every regular file out of the archive. Entry names are sanitized;
/// a traversal or absolute path anywhere in the archive is a hard error.
fn read_entries(data: &[u8]) -> Result<Vec<Entry>> {
    match sniff_format(data)? {
        Format::Zip => {
            let mut archive =
                zip::ZipArchive::new(Cursor::new(data)).context("failed to open archive as zip")?;
            let mut entries = Vec::with_capacity(archive.len());
            for i in 0..archive.len() {
                let mut entry = archive.by_index(i)?;
                let name = sanitize(entry.name())?;
                if name.ends_with('/') || entry.is_dir() {
                    continue;
                }
                let mut contents = Vec::new();
                entry
                    .read_to_end(&mut contents)
                    .with_context(|| format!("failed to read {name} from archive"))?;
                entries.push(Entry { name, contents, mode: entry.unix_mode() });
            }
            Ok(entries)
        }
        Format::TarGz => {
            let gz = flate2::read::GzDecoder::new(Cursor::new(data));
            let mut archive = tar::Archive::new(gz);
            let mut entries = Vec::new();
            for entry in archive.entries().context("failed to open archive as tar.gz")? {
                let mut entry = entry.context("failed to read tar entry")?;
                let raw = entry.path().context("tar entry has an unreadable path")?;
                let name = sanitize(&raw.to_string_lossy())?;
                let kind = entry.header().entry_type();
                if !(kind.is_file() || kind == tar::EntryType::Continuous) {
                    continue; // directories, symlinks, and metadata entries
                }
                let mut contents = Vec::new();
                entry
                    .read_to_end(&mut contents)
                    .with_context(|| format!("failed to read {name} from archive"))?;
                let mode = entry.header().mode().ok();
                entries.push(Entry { name, contents, mode });
            }
            Ok(entries)
        }
    }
}

/// Zip entries written on Windows carry no unix mode, and tar entries carry
/// whatever upstream set. Either way a launch wrapper or helper script has
/// to end up executable, or Steam (and the user) cannot run it.
#[cfg(unix)]
fn apply_mode(dest: &std::path::Path, mode: Option<u32>) -> Result<()> {
    use std::os::unix::fs::PermissionsExt;
    let recorded_exec = mode.is_some_and(|m| m & 0o111 != 0);
    let is_script = dest.extension().is_some_and(|e| e == "sh");
    if recorded_exec || is_script {
        std::fs::set_permissions(dest, std::fs::Permissions::from_mode(0o755))
            .with_context(|| format!("failed to mark {} executable", dest.display()))?;
    }
    Ok(())
}

#[cfg(not(unix))]
fn apply_mode(_dest: &std::path::Path, _mode: Option<u32>) -> Result<()> {
    Ok(())
}

/// Where one archive entry goes, per the routing rules.
enum Target {
    File(PathBuf),
    Skip,
}

/// Match an entry name (normalized to `/`) against a route's `from`.
/// Returns the destination path when it matches.
fn route_entry(ctx: &InstallContext, routes: &[(String, PathBuf)], name: &str) -> Target {
    for (from, to) in routes {
        if let Some(prefix) = from.strip_suffix("**") {
            // Prefix glob: "Blindfold/**" or "**" (prefix "").
            if let Some(rest) = name.strip_prefix(prefix) {
                let rest = rest.trim_start_matches('/');
                if rest.is_empty() {
                    return Target::Skip; // the directory entry itself
                }
                return Target::File(to.join(rest));
            }
        } else if name == from {
            // Single-file route: `to` IS the destination file path.
            return Target::File(to.clone());
        }
    }
    let _ = ctx;
    Target::Skip
}

/// Sanitize an archive entry name: reject absolute paths and traversal.
fn sanitize(name: &str) -> Result<String> {
    let normalized = name.replace('\\', "/");
    let p = PathBuf::from(&normalized);
    if p.components()
        .any(|c| !matches!(c, Component::Normal(_)))
    {
        bail!("unsafe path in archive: {name}");
    }
    Ok(normalized)
}

#[derive(Debug)]
pub struct ExtractOutcome {
    /// Absolute paths of every file written.
    pub written: Vec<PathBuf>,
    /// Entries deliberately skipped because an existing untracked file was
    /// kept (conflictPolicy keep-newer).
    pub kept_existing: Vec<PathBuf>,
}

/// Extract `data` through `routes`. Routes with a non-matching `when` are
/// dropped before extraction. `keep_existing` implements a tool's
/// `keep-newer` conflict policy: an already-present destination file that we
/// did not track is left untouched. `strip_top_level` drops the single
/// leading folder of branch zipballs before route matching.
pub fn extract_routed(
    ctx: &InstallContext,
    data: &[u8],
    routes: &[Route],
    keep_existing: bool,
    strip_top_level: bool,
) -> Result<ExtractOutcome> {
    // Resolve route destinations once, dropping routes whose `when` misses.
    let mut resolved: Vec<(String, PathBuf)> = Vec::new();
    for route in routes {
        if let Some(cond) = &route.when {
            if !ctx.condition_matches(cond)? {
                continue;
            }
        }
        let from = route.from.replace('\\', "/");
        let to = ctx.resolve_path(&route.to)?;
        resolved.push((from, to));
    }
    if resolved.is_empty() {
        bail!("no extraction route applies on this platform/distribution");
    }

    // A destination inside a linked development checkout must never be
    // written through (SPEC §8: linked installs are managed externally).
    let roots: Vec<PathBuf> = {
        let mut r = vec![ctx.game_dir.clone(), ctx.user_data.clone()];
        r.extend(ctx.game_paths.values().cloned());
        r.extend(ctx.vars.values().cloned());
        r
    };
    for (_, to) in &resolved {
        if let Some(link) = crate::context::find_link_ancestor(to, &roots) {
            bail!(
                "{} is a link into a development checkout. Update that checkout with \
                 git instead, or remove the link before installing.",
                link.display()
            );
        }
    }

    let entries = read_entries(data)?;

    let effective_name = |name: &str| -> Option<String> {
        if !strip_top_level {
            return Some(name.to_string());
        }
        // "<repo-ref>/rest..." -> "rest..."; entries at the root are dropped.
        name.split_once('/').map(|(_, rest)| rest.to_string()).filter(|r| !r.is_empty())
    };

    // Preflight: the archive must contain at least one routed entry.
    let any_match = entries.iter().any(|e| {
        effective_name(&e.name)
            .is_some_and(|name| matches!(route_entry(ctx, &resolved, &name), Target::File(_)))
    });
    if !any_match {
        bail!("this archive doesn't contain the expected payload (no entry matches any route)");
    }

    let mut outcome = ExtractOutcome { written: Vec::new(), kept_existing: Vec::new() };
    for entry in &entries {
        let Some(name) = effective_name(&entry.name) else { continue };
        let dest = match route_entry(ctx, &resolved, &name) {
            Target::File(d) => d,
            Target::Skip => continue,
        };
        ctx.check_write_allowed(&dest)?;
        if keep_existing && dest.exists() {
            outcome.kept_existing.push(dest);
            continue;
        }
        if let Some(parent) = dest.parent() {
            std::fs::create_dir_all(parent)
                .with_context(|| format!("failed to create {}", parent.display()))?;
        }
        std::fs::write(&dest, &entry.contents)
            .with_context(|| format!("failed to write {}", dest.display()))?;
        apply_mode(&dest, entry.mode)?;
        outcome.written.push(dest);
    }
    Ok(outcome)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeMap;
    use std::io::Write;

    use crate::context::current_platform;
    use crate::types::{Detect, GameManifest};

    fn make_zip(entries: &[(&str, &[u8])]) -> Vec<u8> {
        let mut buf = Vec::new();
        {
            let cursor = Cursor::new(&mut buf);
            let mut writer = zip::ZipWriter::new(cursor);
            let options = zip::write::SimpleFileOptions::default();
            for (name, data) in entries {
                writer.start_file(name.to_string(), options).unwrap();
                writer.write_all(data).unwrap();
            }
            writer.finish().unwrap();
        }
        buf
    }

    fn ctx(tmp: &std::path::Path) -> InstallContext {
        let game = GameManifest {
            manifest_version: Some(1),
            kind: None,
            id: "g".into(),
            name: "G".into(),
            detect: Detect::default(),
            user_data: BTreeMap::from([(current_platform().to_string(), "unused".into())]),
            paths: BTreeMap::from([("mods".to_string(), "${userData}/Mods".to_string())]),
        };
        InstallContext::build(&game, tmp.join("game"), Some(tmp.join("ud")), "steam".into()).unwrap()
    }

    fn routes(v: serde_json::Value) -> Vec<Route> {
        serde_json::from_value(v).unwrap()
    }

    #[test]
    fn routes_payload_and_skips_unrouted() {
        let tmp = tempfile::tempdir().unwrap();
        let ctx = ctx(tmp.path());
        let zip = make_zip(&[
            ("version.dll", b"lovely"),
            ("README.md", b"readme"),
            ("Blindfold/core.lua", b"-- core"),
            ("Blindfold\\lib\\prism.dll", b"prism"), // backslash entries normalize
        ]);
        let out = extract_routed(
            &ctx,
            &zip,
            &routes(serde_json::json!([{ "from": "Blindfold/**", "to": "${game.mods}/Blindfold" }])),
            false,
            false,
        )
        .unwrap();
        assert_eq!(out.written.len(), 2);
        let mods = tmp.path().join("ud").join("Mods").join("Blindfold");
        assert!(mods.join("core.lua").exists());
        assert!(mods.join("lib").join("prism.dll").exists());
        assert!(!tmp.path().join("game").join("version.dll").exists());
    }

    #[test]
    fn single_file_route_and_keep_existing() {
        let tmp = tempfile::tempdir().unwrap();
        let ctx = ctx(tmp.path());
        std::fs::create_dir_all(tmp.path().join("game")).unwrap();
        std::fs::write(tmp.path().join("game").join("version.dll"), b"newer").unwrap();
        let zip = make_zip(&[("version.dll", b"bundled")]);
        let out = extract_routed(
            &ctx,
            &zip,
            &routes(serde_json::json!([{ "from": "version.dll", "to": "${gameDir}/version.dll" }])),
            true,
            false,
        )
        .unwrap();
        assert!(out.written.is_empty());
        assert_eq!(out.kept_existing.len(), 1);
        assert_eq!(std::fs::read(tmp.path().join("game").join("version.dll")).unwrap(), b"newer");
    }

    fn make_tar_gz(entries: &[(&str, &[u8], u32)]) -> Vec<u8> {
        let mut buf = Vec::new();
        {
            let gz = flate2::write::GzEncoder::new(&mut buf, flate2::Compression::default());
            let mut builder = tar::Builder::new(gz);
            for (name, data, mode) in entries {
                let mut header = tar::Header::new_gnu();
                header.set_size(data.len() as u64);
                header.set_mode(*mode);
                header.set_cksum();
                builder.append_data(&mut header, name, *data).unwrap();
            }
            builder.into_inner().unwrap().finish().unwrap();
        }
        buf
    }

    #[test]
    fn extracts_tar_gz_like_upstream_lovely() {
        // Upstream Lovely's macOS asset: liblovely.dylib and a launch script
        // at the tar root, the dylib routed into the game folder.
        let tmp = tempfile::tempdir().unwrap();
        let ctx = ctx(tmp.path());
        let tgz = make_tar_gz(&[
            ("liblovely.dylib", b"lovely", 0o644),
            ("run_lovely_macos.sh", b"#!/bin/bash", 0o755),
        ]);
        let out = extract_routed(
            &ctx,
            &tgz,
            &routes(serde_json::json!([
                { "from": "liblovely.dylib", "to": "${gameDir}/liblovely.dylib" }
            ])),
            false,
            false,
        )
        .unwrap();
        assert_eq!(out.written.len(), 1);
        assert_eq!(std::fs::read(tmp.path().join("game").join("liblovely.dylib")).unwrap(), b"lovely");
        assert!(!tmp.path().join("game").join("run_lovely_macos.sh").exists());
    }

    #[cfg(unix)]
    #[test]
    fn scripts_and_recorded_exec_bits_come_out_executable() {
        use std::os::unix::fs::PermissionsExt;
        let tmp = tempfile::tempdir().unwrap();
        let ctx = ctx(tmp.path());
        // Zip from a Windows build: no unix mode at all, so the .sh name is
        // the only signal. The tar entry carries an explicit exec bit.
        let zip = make_zip(&[("Mod/steam_lovely_macos.sh", b"#!/bin/bash"), ("Mod/core.lua", b"--")]);
        let tgz = make_tar_gz(&[("tool", b"\x7fELF", 0o755), ("notes.txt", b"hi", 0o644)]);
        let r = routes(serde_json::json!([{ "from": "**", "to": "${game.mods}/X" }]));
        extract_routed(&ctx, &zip, &r, false, false).unwrap();
        extract_routed(&ctx, &tgz, &r, false, false).unwrap();
        let x = tmp.path().join("ud").join("Mods").join("X");
        let mode = |p: &str| std::fs::metadata(x.join(p)).unwrap().permissions().mode() & 0o111;
        assert_ne!(mode("Mod/steam_lovely_macos.sh"), 0);
        assert_eq!(mode("Mod/core.lua"), 0);
        assert_ne!(mode("tool"), 0);
        assert_eq!(mode("notes.txt"), 0);
    }

    #[test]
    fn unknown_format_is_rejected() {
        let tmp = tempfile::tempdir().unwrap();
        let ctx = ctx(tmp.path());
        let r = routes(serde_json::json!([{ "from": "**", "to": "${game.mods}/X" }]));
        let err = extract_routed(&ctx, b"<html>not an archive</html>", &r, false, false).unwrap_err();
        assert!(err.to_string().contains("unrecognized archive format"), "{err}");
    }

    #[test]
    fn rejects_traversal_and_wrong_archives() {
        let tmp = tempfile::tempdir().unwrap();
        let ctx = ctx(tmp.path());
        let evil = make_zip(&[("../evil.dll", b"x"), ("Blindfold/a.lua", b"y")]);
        let r = routes(serde_json::json!([{ "from": "Blindfold/**", "to": "${game.mods}/Blindfold" }]));
        assert!(extract_routed(&ctx, &evil, &r, false, false).is_err());

        let unrelated = make_zip(&[("Other/readme.txt", b"z")]);
        let err = extract_routed(&ctx, &unrelated, &r, false, false).unwrap_err();
        assert!(err.to_string().contains("expected payload"));
    }
}
