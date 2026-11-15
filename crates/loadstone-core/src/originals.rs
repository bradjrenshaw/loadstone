//! Preserved originals (SPEC 10.1): game files a package replaces are kept
//! before its steps run and put back when it is updated or uninstalled.
//!
//! The life of one preserved file:
//!
//! 1. [`back_up`] runs before the install steps. Each existing file the
//!    package's `preserve` list names is copied to a backup — in the state
//!    store, or to the entry's `as` path when the mod itself needs the
//!    original under another name (a proxy DLL loading the real one). When
//!    the backup's place already holds a different file, that file *is* the
//!    original (left by an earlier installer, or by an install that failed
//!    and could not put it back) and is adopted instead of overwritten.
//! 2. [`settle`] runs after the steps succeed. A preserved file the steps
//!    replaced or deleted is recorded as an [`Original`], with the hash of
//!    what the package left there. One the steps didn't touch needs nothing:
//!    its copy is dropped (or, if adopted, the original goes back, since the
//!    file in place was an earlier installer's). `settle` itself changes
//!    nothing on disk; that cleanup waits for [`Settled::finish`], which the
//!    engine calls only once the install's state is saved. Until then any
//!    failure can still [`roll_back`] with every backup intact.
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
    /// The backup was already in place with other content (an `as` path
    /// an earlier installer filled, or a backup a failed install left), so
    /// the file at `path` is not the original.
    pub adopted: bool,
    /// SHA-256 of the file at `path` before the steps ran.
    pub before_sha256: String,
}

/// What [`settle`] decided, applied in two parts: `originals` and `files`
/// go into the install's state, and [`Settled::finish`] drops the backups
/// nobody needs once that state is saved.
#[derive(Debug)]
pub struct Settled {
    pub originals: Vec<Original>,
    /// The steps' writes minus the preserved paths: their originals, not
    /// plain deletion, undo them.
    pub files: Vec<PathBuf>,
    untouched: Vec<Pending>,
}

/// Whether `a` and `b` name the same file. Archive entries and manifest
/// paths can differ in case (`lua51_win32.dll` against `lua51_Win32.dll`),
/// which a case-insensitive file system treats as one file.
pub fn same_file(a: &Path, b: &Path) -> bool {
    if a == b {
        return true;
    }
    #[cfg(windows)]
    {
        let key = |p: &Path| -> Vec<String> {
            p.components().map(|c| c.as_os_str().to_string_lossy().to_lowercase()).collect()
        };
        key(a) == key(b)
    }
    #[cfg(unix)]
    {
        use std::os::unix::fs::MetadataExt as _;
        match (std::fs::metadata(a), std::fs::metadata(b)) {
            (Ok(x), Ok(y)) => x.dev() == y.dev() && x.ino() == y.ino(),
            _ => false,
        }
    }
    #[cfg(not(any(windows, unix)))]
    {
        false
    }
}

fn written_holds(written: &[PathBuf], path: &Path) -> bool {
    written.iter().any(|w| same_file(w, path))
}

/// Whether the steps replaced or deleted a preserved file: it is gone, a
/// step wrote it (under any spelling), or its content changed.
fn was_replaced(p: &Pending, written: &[PathBuf]) -> Result<bool> {
    if !p.path.is_file() || written_holds(written, &p.path) {
        return Ok(true);
    }
    Ok(!sha256_file(&p.path)?.eq_ignore_ascii_case(&p.before_sha256))
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

/// The backup file name for a preserved path: the same for the same path
/// on every attempt, so a backup that outlived a failed install is found
/// again rather than sitting beside a fresh, wrong one.
fn backup_name(path: &Path) -> Result<String> {
    let name = path.file_name().context("preserved path has no file name")?;
    let key = path.to_string_lossy();
    #[cfg(windows)]
    let key = key.to_lowercase();
    let hash = crate::release::sha256_bytes(key.as_bytes());
    Ok(format!("{}-{}", &hash[..16], name.to_string_lossy()))
}

/// Step 1: back up every existing file the `preserve` list names.
/// `backup_dir` holds backups for entries without an `as` path.
///
/// A backup that is already there is never overwritten. An install's
/// backups are gone once it is updated or uninstalled, so one found here
/// outlived an install that failed and could not put it back (the game
/// held the file open), or that never finished. It holds the real
/// original, and the file in place may be the mod's: copying that over the
/// backup would lose the original for good. It is adopted instead.
pub fn back_up(
    ctx: &InstallContext,
    entries: &[PreserveEntry],
    backup_dir: &Path,
    ui: &mut dyn EngineUi,
) -> Result<Vec<Pending>> {
    // Which entries apply, and the `as` paths they keep originals at: a
    // glob in another entry may match such a copy, which is not a game file.
    let mut active: Vec<(&PreserveEntry, Option<PathBuf>)> = Vec::new();
    for entry in entries {
        if let Some(cond) = entry.when() {
            if !ctx.condition_matches(cond)? {
                continue;
            }
        }
        let keep_as = match entry.keep_as() {
            Some(raw) => Some(ctx.resolve_path(raw)?),
            None => None,
        };
        active.push((entry, keep_as));
    }
    let kept_copies: Vec<&PathBuf> = active.iter().filter_map(|(_, keep_as)| keep_as.as_ref()).collect();

    let mut pending: Vec<Pending> = Vec::new();
    for (entry, keep_as) in &active {
        for path in ctx.glob_matches(entry.path())? {
            if !path.is_file()
                || pending.iter().any(|p| same_file(&p.path, &path))
                || kept_copies.iter().any(|kept| same_file(kept, &path))
            {
                continue;
            }
            ctx.check_write_allowed(&path)?;
            let before_sha256 = sha256_file(&path)?;
            let backup = match keep_as {
                Some(backup) => {
                    ctx.check_write_allowed(backup)?;
                    backup.clone()
                }
                None => backup_dir.join(backup_name(&path)?),
            };
            // An existing copy with the same content is no different from
            // a fresh one; anything else is an original to adopt.
            let adopted = backup.is_file() && !sha256_file(&backup)?.eq_ignore_ascii_case(&before_sha256);
            if adopted {
                ui.log(&format!("Using the original already kept at {}.", backup.display()));
            } else if !backup.is_file() {
                copy_over(&path, &backup)?;
            }
            pending.push(Pending { path, backup, adopted, before_sha256 });
        }
    }
    if !pending.is_empty() {
        ui.log(&format!("Kept a copy of {} original game file(s).", pending.len()));
    }
    Ok(pending)
}

/// Step 2, after the steps succeeded: decide each backup's fate without
/// touching disk, so a failure here or before the state is saved still
/// rolls back with every backup in place.
pub fn settle(pending: &[Pending], written: &[PathBuf]) -> Result<Settled> {
    let mut originals = Vec::new();
    let mut untouched = Vec::new();
    for p in pending {
        if was_replaced(p, written)? {
            let installed_sha256 = if p.path.is_file() { sha256_file(&p.path)? } else { String::new() };
            originals.push(Original { path: p.path.clone(), backup: p.backup.clone(), installed_sha256 });
        } else {
            untouched.push(p.clone());
        }
    }
    let files = written
        .iter()
        .filter(|w| !pending.iter().any(|p| same_file(w, &p.path)))
        .cloned()
        .collect();
    Ok(Settled { originals, files, untouched })
}

impl Settled {
    /// After the state is saved: drop the copies of files the steps left
    /// alone, putting adopted originals back (the file in place was an
    /// earlier installer's, or a failed install's).
    ///
    /// Returns the adopted originals that could not be put back now (the
    /// game holds the file open). The caller adds them to the install's
    /// state, so an update or uninstall puts them back instead of the
    /// original being forgotten beside a file nobody tracks.
    #[must_use]
    pub fn finish(self, roots: &[PathBuf], ui: &mut dyn EngineUi) -> Vec<Original> {
        let mut deferred = Vec::new();
        for p in &self.untouched {
            if p.adopted {
                if let Err(e) = copy_over(&p.backup, &p.path) {
                    ui.log(&format!(
                        "Warning: could not restore the original {} now ({e:#}). \
                         It will be put back when this mod is updated or uninstalled.",
                        p.path.display()
                    ));
                    deferred.push(Original {
                        path: p.path.clone(),
                        backup: p.backup.clone(),
                        installed_sha256: p.before_sha256.clone(),
                    });
                    continue;
                }
                ui.log(&format!("Restored the original {}.", p.path.display()));
            }
            if let Err(e) = remove_backup(&p.backup) {
                ui.log(&format!("Warning: {e:#}"));
            }
            prune_parent(&p.backup, roots);
        }
        deferred
    }
}

/// Failed install: put back every original whose file the steps already
/// replaced, and drop the rest of the backups. Best effort.
pub fn roll_back(pending: &[Pending], written: &[PathBuf], roots: &[PathBuf]) {
    for p in pending {
        // When in doubt (an unreadable file), treat it as replaced: the
        // original goes back, or its backup is kept.
        let replaced = was_replaced(p, written).unwrap_or(true);
        if replaced && copy_over(&p.backup, &p.path).is_err() {
            continue; // keep the backup rather than lose the original
        }
        if !p.adopted || replaced {
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
