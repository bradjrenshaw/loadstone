//! Preserved originals (SPEC 10.1): game files a package replaces are kept
//! before its steps run and put back when it is updated or uninstalled.
//!
//! The life of one preserved file:
//!
//! 1. [`back_up`] runs before the install steps. Each existing file the
//!    package's `preserve` list names is copied to a backup — in the state
//!    store, or to the entry's `as` path when the mod itself needs the
//!    original under another name (a proxy DLL loading the real one). When an
//!    `as` path already holds a file, that file *is* the original (left by an
//!    earlier installer) and is adopted instead of overwritten.
//! 2. [`settle`] runs after the steps succeed. A preserved file the steps
//!    replaced or deleted is recorded as an [`Original`], with the hash of
//!    what the package left there. One the steps didn't touch needs nothing:
//!    its copy is dropped (or, if adopted, the original goes back, since the
//!    file in place was an earlier installer's).
//! 3. [`restore`] runs on update and uninstall. Where the package's version
//!    is still in place (same hash) or the file is gone, the original comes
//!    back. Where something else replaced it since (a game update), that
//!    newer file is kept and the stale backup dropped.

use std::path::{Path, PathBuf};

use anyhow::{Context as _, Result};
use serde::{Deserialize, Serialize};

use crate::context::InstallContext;
use crate::engine::EngineUi;
use crate::release::sha256_file;
use crate::track::{make_writable, prune_empty_dirs};
use crate::types::PreserveEntry;

/// A replaced file and where its original waits (SPEC 10.1).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Original {
    pub path: PathBuf,
    pub backup: PathBuf,
    /// SHA-256 of the file the package left at `path`; empty when the
    /// package deleted it.
    pub installed_sha256: String,
}

/// A backup taken before the steps ran, not yet known to be needed.
#[derive(Debug, Clone)]
pub struct Pending {
    pub path: PathBuf,
    pub backup: PathBuf,
    /// The backup was already in place (an `as` path an earlier installer
    /// filled), so the file at `path` is not the original.
    pub adopted: bool,
}

/// Copy `from` over `to`, replacing a read-only destination.
fn copy_over(from: &Path, to: &Path) -> Result<()> {
    if let Some(parent) = to.parent() {
        std::fs::create_dir_all(parent)
            .with_context(|| format!("failed to create {}", parent.display()))?;
    }
    make_writable(to).with_context(|| format!("failed to make {} writable", to.display()))?;
    std::fs::copy(from, to)
        .with_context(|| format!("failed to copy {} to {}", from.display(), to.display()))?;
    Ok(())
}

fn remove_backup(backup: &Path) -> Result<()> {
    make_writable(backup).ok();
    match std::fs::remove_file(backup) {
        Ok(()) => Ok(()),
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok(()),
        Err(e) => Err(e).with_context(|| format!("failed to remove {}", backup.display())),
    }
}

/// Step 1: back up every existing file the `preserve` list names.
/// `backup_dir` holds backups for entries without an `as` path.
pub fn back_up(
    ctx: &InstallContext,
    entries: &[PreserveEntry],
    backup_dir: &Path,
    ui: &mut dyn EngineUi,
) -> Result<Vec<Pending>> {
    let mut pending: Vec<Pending> = Vec::new();
    for entry in entries {
        if let Some(cond) = entry.when() {
            if !ctx.condition_matches(cond)? {
                continue;
            }
        }
        for path in ctx.glob_matches(entry.path())? {
            if !path.is_file() || pending.iter().any(|p| p.path == path) {
                continue;
            }
            ctx.check_write_allowed(&path)?;
            match entry.keep_as() {
                Some(raw) => {
                    let backup = ctx.resolve_path(raw)?;
                    ctx.check_write_allowed(&backup)?;
                    if backup.is_file() {
                        ui.log(&format!(
                            "Using the original already kept at {}.",
                            backup.display()
                        ));
                        pending.push(Pending { path, backup, adopted: true });
                    } else {
                        copy_over(&path, &backup)?;
                        pending.push(Pending { path, backup, adopted: false });
                    }
                }
                None => {
                    let name = path.file_name().context("preserved path has no file name")?;
                    let backup =
                        backup_dir.join(format!("{}-{}", pending.len(), name.to_string_lossy()));
                    copy_over(&path, &backup)?;
                    pending.push(Pending { path, backup, adopted: false });
                }
            }
        }
    }
    if !pending.is_empty() {
        ui.log(&format!("Kept a copy of {} original game file(s).", pending.len()));
    }
    Ok(pending)
}

/// Step 2, after the steps succeeded: decide each backup's fate. Preserved
/// paths leave `written` — their originals, not plain deletion, undo them.
pub fn settle(
    pending: &[Pending],
    written: &mut Vec<PathBuf>,
    roots: &[PathBuf],
    ui: &mut dyn EngineUi,
) -> Result<Vec<Original>> {
    let mut originals = Vec::new();
    for p in pending {
        let replaced = written.contains(&p.path);
        written.retain(|w| w != &p.path);
        if replaced || !p.path.exists() {
            let installed_sha256 = if p.path.is_file() { sha256_file(&p.path)? } else { String::new() };
            originals.push(Original { path: p.path.clone(), backup: p.backup.clone(), installed_sha256 });
        } else if p.adopted {
            // This install left the file alone, so what an earlier
            // installer put there would stay forever: put the original back.
            copy_over(&p.backup, &p.path)?;
            remove_backup(&p.backup)?;
            prune_parent(&p.backup, roots);
            ui.log(&format!("Restored the original {}.", p.path.display()));
        } else {
            remove_backup(&p.backup)?;
            prune_parent(&p.backup, roots);
        }
    }
    Ok(originals)
}

/// Failed install: put back every original whose file the steps already
/// replaced, and drop the rest of the backups. Best effort.
pub fn roll_back(pending: &[Pending], written: &[PathBuf], roots: &[PathBuf]) {
    for p in pending {
        if (written.contains(&p.path) || !p.path.exists()) && copy_over(&p.backup, &p.path).is_err() {
            continue; // keep the backup rather than lose the original
        }
        if !p.adopted || written.contains(&p.path) {
            let _ = remove_backup(&p.backup);
            prune_parent(&p.backup, roots);
        }
    }
}

/// Step 3, on update and uninstall: bring originals back. Returns the ones
/// that could not be restored (their backups are kept) with the reasons.
pub fn restore(
    originals: &[Original],
    roots: &[PathBuf],
    ui: &mut dyn EngineUi,
) -> Vec<(Original, String)> {
    let mut failed = Vec::new();
    for o in originals {
        if !o.backup.is_file() {
            ui.log(&format!(
                "Warning: the original of {} is missing ({}); leaving the file as it is.",
                o.path.display(),
                o.backup.display()
            ));
            continue;
        }
        let ours = match o.path.is_file() {
            false => true,
            true => match sha256_file(&o.path) {
                Ok(hash) => !o.installed_sha256.is_empty() && hash.eq_ignore_ascii_case(&o.installed_sha256),
                Err(e) => {
                    failed.push((o.clone(), format!("{}: {e:#}", o.path.display())));
                    continue;
                }
            },
        };
        if ours {
            if let Err(e) = copy_over(&o.backup, &o.path) {
                failed.push((o.clone(), format!("{e:#}")));
                continue;
            }
        } else {
            ui.log(&format!(
                "{} changed since this mod was installed (a game update?); keeping the newer file.",
                o.path.display()
            ));
        }
        if let Err(e) = remove_backup(&o.backup) {
            ui.log(&format!("Warning: {e:#}"));
        }
        prune_parent(&o.backup, roots);
    }
    if !originals.is_empty() && failed.is_empty() {
        ui.log(&format!("Restored {} original game file(s).", originals.len()));
    }
    failed
}

fn prune_parent(backup: &Path, roots: &[PathBuf]) {
    if let Some(parent) = backup.parent() {
        prune_empty_dirs(vec![parent.to_path_buf()], roots);
    }
}
