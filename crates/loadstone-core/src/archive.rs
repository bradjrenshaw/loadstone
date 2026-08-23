//! Routed archive extraction (SPEC §9.1). Zip today; tar.gz is a planned
//! addition (upstream tools ship it for macOS/Linux).

use std::io::{Cursor, Read};
use std::path::{Component, PathBuf};

use anyhow::{bail, Context as _, Result};

use crate::context::InstallContext;
use crate::types::Route;

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

    let cursor = Cursor::new(data);
    let mut archive = zip::ZipArchive::new(cursor).context("failed to open archive as zip")?;

    let effective_name = |raw: &str| -> Result<Option<String>> {
        let name = sanitize(raw)?;
        if !strip_top_level {
            return Ok(Some(name));
        }
        // "<repo-ref>/rest..." -> "rest..."; entries at the root are dropped.
        Ok(name.split_once('/').map(|(_, rest)| rest.to_string()).filter(|r| !r.is_empty()))
    };

    // Preflight: the archive must contain at least one routed entry.
    let mut any_match = false;
    for i in 0..archive.len() {
        let entry = archive.by_index(i)?;
        let Some(name) = effective_name(entry.name())? else { continue };
        if !name.ends_with('/') {
            if let Target::File(_) = route_entry(ctx, &resolved, &name) {
                any_match = true;
                break;
            }
        }
    }
    if !any_match {
        bail!("this archive doesn't contain the expected payload (no entry matches any route)");
    }

    let mut outcome = ExtractOutcome { written: Vec::new(), kept_existing: Vec::new() };
    for i in 0..archive.len() {
        let mut entry = archive.by_index(i)?;
        let Some(name) = effective_name(entry.name())? else { continue };
        if name.ends_with('/') {
            continue;
        }
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
        let mut contents = Vec::new();
        entry
            .read_to_end(&mut contents)
            .with_context(|| format!("failed to read {name} from archive"))?;
        std::fs::write(&dest, &contents)
            .with_context(|| format!("failed to write {}", dest.display()))?;
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
