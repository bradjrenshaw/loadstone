//! The install context (SPEC §3): platform, architecture, distribution, and
//! the resolved paths every step and token resolves against.

use std::collections::BTreeMap;
use std::path::{Component, Path, PathBuf};

use anyhow::{bail, Context as _, Result};

use crate::t;
use crate::types::{Condition, GameManifest, StringOrList};

#[derive(Debug, Clone)]
pub struct InstallContext {
    pub platform: String,     // "windows" | "macos" | "linux"
    pub arch: String,         // "x64" | "arm64"
    pub distribution: String, // "steam" | ... | "standalone"
    pub game_dir: PathBuf,
    pub user_data: PathBuf,
    /// Resolved absolute paths from the game package's `paths` map.
    pub game_paths: BTreeMap<String, PathBuf>,
    /// Values bound by pick-directory steps (`${var.<id>}`).
    pub vars: BTreeMap<String, PathBuf>,
    /// The game's Steam app id (game package `detect.steam.appId`), for
    /// `${steam.appId}` in launch steps.
    pub steam_app_id: Option<String>,
    /// Install option values chosen for this install (SPEC 11.1), for
    /// `option` conditions.
    pub options: BTreeMap<String, String>,
}

pub fn current_platform() -> &'static str {
    if cfg!(target_os = "windows") {
        "windows"
    } else if cfg!(target_os = "macos") {
        "macos"
    } else {
        "linux"
    }
}

pub fn current_arch() -> &'static str {
    if cfg!(target_arch = "aarch64") {
        "arm64"
    } else {
        "x64"
    }
}

fn platform_name(platform: &str) -> &str {
    match platform {
        "windows" => "Windows",
        "macos" => "macOS",
        "linux" => "Linux",
        other => other,
    }
}

/// Can a mod with these `platforms` (SPEC 5.2) for this game run here?
/// `Err` carries a sentence saying why not, for the frontend to show.
pub fn platform_support(platforms: &[String], game: Option<&GameManifest>) -> Result<(), String> {
    platform_support_on(platforms, game, current_platform(), current_arch())
}

pub fn platform_support_on(
    platforms: &[String],
    game: Option<&GameManifest>,
    platform: &str,
    arch: &str,
) -> Result<(), String> {
    if !platforms.is_empty() {
        let fits = platforms.iter().any(|p| match p.split_once('/') {
            Some((os, a)) => os == platform && a == arch,
            None => p == platform,
        });
        if !fits {
            let narrowed = platforms.iter().any(|p| p.split_once('/').is_some_and(|(os, _)| os == platform));
            let on: Vec<&str> = platforms
                .iter()
                .map(|p| p.split_once('/').map_or(p.as_str(), |(os, _)| os))
                .map(platform_name)
                .collect::<std::collections::BTreeSet<_>>()
                .into_iter()
                .collect();
            return Err(if narrowed {
                // Only the other architecture is ever wanted here (the
                // current one would fit), so this is the first match.
                let wanted = platforms
                    .iter()
                    .filter_map(|p| p.split_once('/'))
                    .find(|(os, _)| *os == platform)
                    .map_or("", |(_, a)| a);
                let name = platform_name(platform);
                match (platform, wanted) {
                    ("macos", "arm64") => t!("engine-platform-needs-apple-silicon", platform = name),
                    (_, "arm64") => t!("engine-platform-needs-arm", platform = name),
                    _ => t!("engine-platform-needs-x64", platform = name),
                }
            } else {
                match on.as_slice() {
                    [one] => t!("engine-platform-only-one", platform = *one),
                    [first, second] => t!("engine-platform-only-two", first = *first, second = *second),
                    [first, second, rest @ ..] => t!(
                        "engine-platform-only-three",
                        first = *first,
                        second = *second,
                        third = rest.join(" and "),
                    ),
                    [] => String::new(),
                }
            });
        }
    }
    if let Some(game) = game {
        if !game.user_data.contains_key(platform) {
            return Err(t!("engine-game-platform-unsupported", game = &game.name, platform = platform_name(platform)));
        }
    }
    Ok(())
}

fn os_dir(name: &str) -> Option<PathBuf> {
    match name {
        "appData" => dirs::config_dir(),
        "localAppData" => dirs::data_local_dir(),
        "localLow" => dirs::home_dir().map(|h| h.join("AppData").join("LocalLow")),
        "documents" => dirs::document_dir(),
        "home" => dirs::home_dir(),
        _ => None,
    }
}

impl InstallContext {
    /// Build a context for a game. `game_dir` must already be chosen/validated;
    /// `user_data_override` skips the game package's userData resolution
    /// (used by tests and the CLI's --user-data flag).
    pub fn build(
        game: &GameManifest,
        game_dir: PathBuf,
        user_data_override: Option<PathBuf>,
        distribution: String,
    ) -> Result<Self> {
        let platform = current_platform().to_string();
        let arch = current_arch().to_string();

        let mut ctx = InstallContext {
            platform,
            arch,
            distribution,
            game_dir,
            user_data: PathBuf::new(),
            game_paths: BTreeMap::new(),
            vars: BTreeMap::new(),
            steam_app_id: None,
            options: BTreeMap::new(),
        };
        ctx.steam_app_id = steam_app_id_of(game, &ctx.game_dir);

        ctx.user_data = match user_data_override {
            Some(p) => p,
            None => {
                let raw = game.user_data.get(&ctx.platform).with_context(|| {
                    format!(
                        "game \"{}\" declares no userData path for platform {}",
                        game.id, ctx.platform
                    )
                })?;
                ctx.resolve_path(raw)?
            }
        };

        // Game paths may reference builtins, ${userData}, and each other.
        // Resolve with a few passes; unresolved names error out.
        let mut pending: BTreeMap<String, String> = game.paths.clone();
        for _ in 0..4 {
            if pending.is_empty() {
                break;
            }
            let mut progressed = false;
            let names: Vec<String> = pending.keys().cloned().collect();
            for name in names {
                let raw = pending.get(&name).unwrap().clone();
                if let Ok(resolved) = self_resolve(&ctx, &raw) {
                    ctx.game_paths.insert(name.clone(), resolved);
                    pending.remove(&name);
                    progressed = true;
                }
            }
            if !progressed {
                break;
            }
        }
        if !pending.is_empty() {
            bail!(
                "could not resolve game path(s): {}",
                pending.keys().cloned().collect::<Vec<_>>().join(", ")
            );
        }
        Ok(ctx)
    }

    /// Resolve a token-bearing path to an absolute path. Fails on unknown
    /// tokens, unbound vars, or any `..` component (SPEC §3: writes are
    /// confined; traversal is rejected at resolution time).
    pub fn resolve_path(&self, raw: &str) -> Result<PathBuf> {
        let resolved = self.substitute(raw)?;
        let path = PathBuf::from(&resolved);
        if path
            .components()
            .any(|c| matches!(c, Component::ParentDir))
        {
            bail!("path \"{raw}\" contains a parent-directory component");
        }
        if !path.is_absolute() {
            bail!("path \"{raw}\" did not resolve to an absolute path ({resolved})");
        }
        Ok(path)
    }

    /// Token substitution producing a string (used for both paths and,
    /// rarely, string values containing `${platform}` etc.).
    pub fn substitute(&self, raw: &str) -> Result<String> {
        let mut out = String::new();
        let mut rest = raw;
        while let Some(start) = rest.find("${") {
            out.push_str(&rest[..start]);
            let after = &rest[start + 2..];
            let Some(end) = after.find('}') else {
                bail!("unterminated token in \"{raw}\"");
            };
            let name = &after[..end];
            out.push_str(&self.token_value(name, raw)?);
            rest = &after[end + 1..];
        }
        out.push_str(rest);
        Ok(out)
    }

    fn token_value(&self, name: &str, raw: &str) -> Result<String> {
        let s = |p: &Path| p.to_string_lossy().into_owned();
        match name {
            "gameDir" => return Ok(s(&self.game_dir)),
            "userData" => return Ok(s(&self.user_data)),
            "platform" => return Ok(self.platform.clone()),
            "arch" => return Ok(self.arch.clone()),
            "distribution" => return Ok(self.distribution.clone()),
            _ => {}
        }
        if let Some(dir) = os_dir(name) {
            return Ok(s(&dir));
        }
        if let Some(game_name) = name.strip_prefix("game.") {
            return match self.game_paths.get(game_name) {
                Some(p) => Ok(s(p)),
                None => bail!("\"{raw}\": game path \"{game_name}\" is not defined"),
            };
        }
        if let Some(var) = name.strip_prefix("var.") {
            return match self.vars.get(var) {
                Some(p) => Ok(s(p)),
                None => bail!("\"{raw}\": ${{var.{var}}} is not bound"),
            };
        }
        if name == "steam.appId" {
            return match &self.steam_app_id {
                Some(id) => Ok(id.clone()),
                None => bail!("\"{raw}\": the game package declares no detect.steam.appId"),
            };
        }
        bail!("\"{raw}\": unknown token ${{{name}}}")
    }

    /// Does a condition hold in this context?
    pub fn condition_matches(&self, cond: &Condition) -> Result<bool> {
        fn hits(list: &StringOrList, value: &str) -> bool {
            list.iter().any(|s| s == value)
        }
        if let Some(d) = &cond.distribution {
            if !hits(d, &self.distribution) {
                return Ok(false);
            }
        }
        if let Some(p) = &cond.platform {
            if !hits(p, &self.platform) {
                return Ok(false);
            }
        }
        if let Some(a) = &cond.arch {
            if !hits(a, &self.arch) {
                return Ok(false);
            }
        }
        if let Some(pattern) = &cond.file_exists {
            if self.glob_exists(pattern)?.is_none() {
                return Ok(false);
            }
        }
        if let Some(names) = &cond.process_running {
            let wanted: Vec<&str> = names.iter().collect();
            if !crate::process::any_running(&wanted)? {
                return Ok(false);
            }
        }
        if let Some(needle) = &cond.steam_launch_options {
            // No app id, no Steam, or nothing set: the options can't contain it.
            let options = self
                .steam_app_id
                .as_deref()
                .and_then(crate::detect::steam_launch_options)
                .unwrap_or_default();
            if !options.contains(needle.as_str()) {
                return Ok(false);
            }
        }
        if let Some(fc) = &cond.file_contains {
            let needle = fc.text.as_bytes();
            let mut found = false;
            for path in self.glob_matches(&fc.file)? {
                if !path.is_file() {
                    continue;
                }
                let data = std::fs::read(&path)
                    .with_context(|| format!("failed to read {}", path.display()))?;
                if !needle.is_empty() && data.windows(needle.len()).any(|w| w == needle) {
                    found = true;
                    break;
                }
            }
            if !found {
                return Ok(false);
            }
        }
        if let Some(jh) = &cond.json_has {
            let file = self.resolve_path(&jh.file)?;
            if !crate::jsonedit::path_exists(&file, &jh.path)? {
                return Ok(false);
            }
        }
        for (id, wanted) in &cond.option {
            match self.options.get(id) {
                Some(value) if hits(wanted, value) => {}
                _ => return Ok(false),
            }
        }
        if let Some(inner) = &cond.not {
            if self.condition_matches(inner)? {
                return Ok(false);
            }
        }
        Ok(true)
    }

    /// Resolve a possibly-globbed path and return the first match, if any.
    pub fn glob_exists(&self, raw: &str) -> Result<Option<PathBuf>> {
        Ok(self.glob_matches(raw)?.into_iter().next())
    }

    /// All filesystem matches for a possibly-globbed token path.
    pub fn glob_matches(&self, raw: &str) -> Result<Vec<PathBuf>> {
        let resolved = self.substitute(raw)?;
        if PathBuf::from(&resolved)
            .components()
            .any(|c| matches!(c, Component::ParentDir))
        {
            bail!("path \"{raw}\" contains a parent-directory component");
        }
        if !resolved.contains('*') && !resolved.contains('?') {
            let p = PathBuf::from(&resolved);
            return Ok(if p.exists() { vec![p] } else { Vec::new() });
        }
        let mut found = Vec::new();
        for entry in glob::glob(&resolved)
            .with_context(|| format!("bad glob pattern \"{resolved}\""))?
        {
            found.push(entry?);
        }
        Ok(found)
    }

    /// A resolved destination must live under one of the allowed roots.
    pub fn check_write_allowed(&self, path: &Path) -> Result<()> {
        if self.is_under_allowed_root(path) {
            Ok(())
        } else {
            bail!(
                "refusing to write outside allowed roots: {}",
                path.display()
            )
        }
    }

    /// A program a `run` step starts must live under the same roots: a
    /// manifest can launch the game it manages, never an arbitrary binary.
    pub fn check_run_allowed(&self, path: &Path) -> Result<()> {
        if self.is_under_allowed_root(path) {
            Ok(())
        } else {
            bail!(
                "refusing to run a program outside the game's folders: {}",
                path.display()
            )
        }
    }

    pub(crate) fn is_under_allowed_root(&self, path: &Path) -> bool {
        let mut roots: Vec<&PathBuf> = vec![&self.game_dir, &self.user_data];
        roots.extend(self.game_paths.values());
        roots.extend(self.vars.values());
        roots.iter().any(|r| path.starts_with(r))
    }
}

/// The Steam app id for a copy of the game: the `detect.steam` entry whose
/// folder name matches `game_dir` (the demo's id for the demo's folder),
/// else the first entry's. Accepts a number or a string.
pub fn steam_app_id_of(game: &GameManifest, game_dir: &Path) -> Option<String> {
    crate::detect::steam_entry_for_dir(game, game_dir)
        .and_then(|e| e.app_id)
        .or_else(|| crate::detect::steam_entries(game).into_iter().find_map(|e| e.app_id))
}

// Free-function wrapper so build() can call resolution mid-construction.
fn self_resolve(ctx: &InstallContext, raw: &str) -> Result<PathBuf> {
    ctx.resolve_path(raw)
}

/// Walk from `path` up toward (but not including) any of `stop_roots`,
/// returning the first ancestor that is a symlink or junction. Writing or
/// deleting through such a link would silently operate on a developer's
/// checkout (deploy-script links), so callers refuse instead.
pub fn find_link_ancestor(path: &Path, stop_roots: &[PathBuf]) -> Option<PathBuf> {
    let mut current = Some(path);
    while let Some(p) = current {
        if stop_roots.iter().any(|r| r == p) {
            return None;
        }
        if let Ok(meta) = std::fs::symlink_metadata(p) {
            if meta.file_type().is_symlink() {
                return Some(p.to_path_buf());
            }
        }
        current = p.parent();
    }
    None
}

/// Resolve every token path inside a step list, returning a copy safe to
/// store in the install state (uninstall then needs no context).
pub fn resolve_steps(ctx: &InstallContext, steps: &[crate::types::Step]) -> Result<Vec<crate::types::Step>> {
    use crate::types::Step;
    let mut out = Vec::with_capacity(steps.len());
    for step in steps {
        let mut s = step.clone();
        match &mut s {
            Step::EditJson { file, .. } | Step::EditIni { file, .. } => *file = ctx.substitute(file)?,
            Step::DeleteFiles { paths, .. } | Step::EnsureDirs { paths, .. } => {
                for p in paths.iter_mut() {
                    *p = ctx.substitute(p)?;
                }
            }
            Step::CopyFiles { from, to, .. } => {
                *from = ctx.substitute(from)?;
                *to = ctx.substitute(to)?;
            }
            Step::Notice { message, clipboard, .. } => {
                *message = message.try_map(|m| ctx.substitute(m))?;
                if let Some(text) = clipboard {
                    *text = ctx.substitute(text)?;
                }
            }
            Step::MergeUniversalBinary { inputs, output, .. } => {
                for p in inputs.iter_mut() {
                    *p = ctx.substitute(p)?;
                }
                *output = ctx.substitute(output)?;
            }
            Step::Run { program, args, cwd, env, .. } => {
                *program = ctx.substitute(program)?;
                for a in args.iter_mut() {
                    *a = ctx.substitute(a)?;
                }
                if let Some(c) = cwd {
                    *c = ctx.substitute(c)?;
                }
                for v in env.values_mut() {
                    *v = ctx.substitute(v)?;
                }
            }
            Step::OpenUrl { url, .. } => *url = ctx.substitute(url)?,
            Step::ExtractArchive { .. } | Step::PickDirectory { .. } | Step::Expect { .. } => {}
        }
        out.push(s);
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::Detect;

    fn game() -> GameManifest {
        GameManifest {
            manifest_version: Some(1),
            kind: None,
            id: "balatro".into(),
            name: "Balatro".into(),
            detect: Detect::default(),
            user_data: BTreeMap::from([(current_platform().to_string(), "${appData}/Balatro".to_string())]),
            paths: BTreeMap::from([("mods".to_string(), "${userData}/Mods".to_string())]),
        }
    }

    #[test]
    fn builds_context_and_resolves_tokens() {
        let tmp = tempfile::tempdir().unwrap();
        let ctx = InstallContext::build(
            &game(),
            tmp.path().to_path_buf(),
            Some(tmp.path().join("userdata")),
            "steam".into(),
        )
        .unwrap();
        assert_eq!(ctx.game_paths["mods"], tmp.path().join("userdata").join("Mods"));
        let p = ctx.resolve_path("${game.mods}/Blindfold").unwrap();
        assert!(p.starts_with(tmp.path()));
        assert!(ctx.resolve_path("${gameDir}/../evil").is_err());
        assert!(ctx.resolve_path("${bogus}/x").is_err());
    }

    #[test]
    fn conditions_match_context() {
        let tmp = tempfile::tempdir().unwrap();
        let ctx = InstallContext::build(
            &game(),
            tmp.path().to_path_buf(),
            Some(tmp.path().join("ud")),
            "steam".into(),
        )
        .unwrap();
        let cond: Condition = serde_json::from_value(serde_json::json!({"distribution": "steam"})).unwrap();
        assert!(ctx.condition_matches(&cond).unwrap());
        let cond: Condition = serde_json::from_value(serde_json::json!({"distribution": "epic"})).unwrap();
        assert!(!ctx.condition_matches(&cond).unwrap());
        let cond: Condition =
            serde_json::from_value(serde_json::json!({"platform": [current_platform(), "linux"]})).unwrap();
        assert!(ctx.condition_matches(&cond).unwrap());
    }

    #[test]
    fn file_contains_and_option_conditions() {
        let tmp = tempfile::tempdir().unwrap();
        let mut ctx = InstallContext::build(
            &game(),
            tmp.path().to_path_buf(),
            Some(tmp.path().join("ud")),
            "steam".into(),
        )
        .unwrap();
        std::fs::write(tmp.path().join("Expansion2.Civ5Pkg"), b"<Sounds>MinorCivSounds_VoxPopuli</Sounds>").unwrap();
        let has = |ctx: &InstallContext, v: serde_json::Value| {
            ctx.condition_matches(&serde_json::from_value::<Condition>(v).unwrap()).unwrap()
        };
        assert!(has(&ctx, serde_json::json!({"fileContains": {"file": "${gameDir}/*.Civ5Pkg", "text": "VoxPopuli"}})));
        assert!(!has(&ctx, serde_json::json!({"fileContains": {"file": "${gameDir}/*.Civ5Pkg", "text": "Lekmod"}})));
        assert!(!has(&ctx, serde_json::json!({"fileContains": {"file": "${gameDir}/absent.txt", "text": "x"}})));

        assert!(!has(&ctx, serde_json::json!({"option": {"state": "vp"}})));
        ctx.options.insert("state".into(), "vp".into());
        assert!(has(&ctx, serde_json::json!({"option": {"state": "vp"}})));
        assert!(has(&ctx, serde_json::json!({"option": {"state": ["vp", "cp"]}})));
        assert!(!has(&ctx, serde_json::json!({"option": {"state": "vanilla"}})));
    }

    #[test]
    fn platform_support_from_mod_and_game() {
        let g = game(); // user data declared for this platform only
        let p = current_platform();
        let list = |v: &[&str]| v.iter().map(|s| s.to_string()).collect::<Vec<_>>();
        assert!(platform_support_on(&[], Some(&g), p, "x64").is_ok());
        assert!(platform_support_on(&[], Some(&g), "plan9", "x64").is_err());
        assert!(platform_support_on(&list(&["windows"]), None, "windows", "x64").is_ok());
        let err = platform_support_on(&list(&["windows"]), None, "macos", "arm64").unwrap_err();
        assert_eq!(err, "This mod is available on Windows only.");
        assert!(platform_support_on(&list(&["windows", "macos/arm64"]), None, "macos", "arm64").is_ok());
        let err = platform_support_on(&list(&["windows", "macos/arm64"]), None, "macos", "x64").unwrap_err();
        assert_eq!(err, "On macOS, this mod needs an Apple Silicon processor.");
    }

    #[test]
    fn write_confinement() {
        let tmp = tempfile::tempdir().unwrap();
        let ctx = InstallContext::build(
            &game(),
            tmp.path().join("game"),
            Some(tmp.path().join("ud")),
            "standalone".into(),
        )
        .unwrap();
        assert!(ctx.check_write_allowed(&tmp.path().join("game").join("a.dll")).is_ok());
        assert!(ctx.check_write_allowed(&tmp.path().join("elsewhere").join("a.dll")).is_err());
    }
}
