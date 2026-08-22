//! Game-directory detection (SPEC §3/§4). Detection LOGIC lives here once;
//! detection DATA comes from the game package.

use std::path::{Path, PathBuf};

use anyhow::Result;

use crate::types::GameManifest;

/// Outcome of detection: where the game is and how that copy is distributed.
#[derive(Debug, Clone)]
pub struct DetectedGame {
    pub game_dir: PathBuf,
    pub distribution: String,
}

/// At least one declared marker must exist in the candidate folder.
pub fn validate_game_dir(game: &GameManifest, dir: &Path) -> bool {
    let markers = &game.detect.markers;
    if markers.is_empty() {
        return dir.is_dir();
    }
    markers.iter().any(|m| dir.join(m).exists())
}

/// Infer the distribution of a hand-picked folder from disk evidence,
/// falling back to `standalone` (SPEC §3: there is no "unknown").
pub fn infer_distribution(dir: &Path) -> String {
    if dir.join("steam_api64.dll").exists()
        || dir.join("steam_api.dll").exists()
        || dir.to_string_lossy().to_lowercase().contains("steamapps")
    {
        return "steam".to_string();
    }
    if dir.join(".egstore").exists() {
        return "epic".to_string();
    }
    if std::fs::read_dir(dir)
        .map(|entries| {
            entries.filter_map(|e| e.ok()).any(|e| {
                let n = e.file_name().to_string_lossy().to_lowercase();
                n.starts_with("goggame-") && n.ends_with(".info")
            })
        })
        .unwrap_or(false)
    {
        return "gog".to_string();
    }
    "standalone".to_string()
}

/// Try to auto-detect the game. Currently implements Steam (the only
/// distribution the existing installers detect); other distributions
/// resolve via the user browsing to the folder.
pub fn detect(game: &GameManifest) -> Result<Option<DetectedGame>> {
    if let Some(steam) = game.detect.distributions.get("steam") {
        let dir_name = steam.get("dirName").and_then(|v| v.as_str());
        if let Some(dir_name) = dir_name {
            for steam_root in steam_roots() {
                // Library folders listed in libraryfolders.vdf, then the root itself.
                let vdf = steam_root.join("steamapps").join("libraryfolders.vdf");
                let mut libraries: Vec<PathBuf> = Vec::new();
                if let Ok(content) = std::fs::read_to_string(&vdf) {
                    libraries.extend(parse_vdf_library_paths(&content));
                }
                libraries.push(steam_root.clone());
                for lib in libraries {
                    let candidate = lib.join("steamapps").join("common").join(dir_name);
                    if candidate.is_dir() && validate_game_dir(game, &candidate) {
                        return Ok(Some(DetectedGame {
                            game_dir: candidate,
                            distribution: "steam".to_string(),
                        }));
                    }
                }
            }
        }
    }
    Ok(None)
}

/// Steam install roots to probe, best first: the registry-configured path,
/// then stock locations per platform.
fn steam_roots() -> Vec<PathBuf> {
    let mut roots = Vec::new();
    #[cfg(target_os = "windows")]
    if let Some(reg) = steam_registry_path() {
        roots.push(reg);
    }
    #[cfg(target_os = "windows")]
    roots.push(PathBuf::from("C:\\Program Files (x86)\\Steam"));
    #[cfg(target_os = "macos")]
    if let Some(home) = dirs::home_dir() {
        roots.push(home.join("Library").join("Application Support").join("Steam"));
    }
    #[cfg(target_os = "linux")]
    if let Some(home) = dirs::home_dir() {
        roots.push(home.join(".steam").join("steam"));
        roots.push(home.join(".local").join("share").join("Steam"));
    }
    roots.dedup();
    roots
}

/// HKCU\Software\Valve\Steam\SteamPath via reg.exe (no extra dependency,
/// no console window).
#[cfg(target_os = "windows")]
fn steam_registry_path() -> Option<PathBuf> {
    use std::os::windows::process::CommandExt;
    const CREATE_NO_WINDOW: u32 = 0x0800_0000;
    let out = std::process::Command::new("reg")
        .args(["query", r"HKCU\Software\Valve\Steam", "/v", "SteamPath"])
        .creation_flags(CREATE_NO_WINDOW)
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let text = String::from_utf8_lossy(&out.stdout);
    parse_reg_sz(&text).map(|v| PathBuf::from(v.replace('/', "\\")))
}

#[cfg(target_os = "windows")]
fn parse_reg_sz(output: &str) -> Option<String> {
    for line in output.lines() {
        let line = line.trim();
        if let Some(idx) = line.find("REG_SZ") {
            let val = line[idx + "REG_SZ".len()..].trim();
            if !val.is_empty() {
                return Some(val.to_string());
            }
        }
    }
    None
}

pub fn parse_vdf_library_paths(content: &str) -> Vec<PathBuf> {
    // "path"		"C:\\Program Files (x86)\\Steam"
    let mut out = Vec::new();
    for line in content.lines() {
        let line = line.trim();
        let Some(rest) = line.strip_prefix("\"path\"") else {
            continue;
        };
        let rest = rest.trim();
        if rest.len() >= 2 && rest.starts_with('"') && rest.ends_with('"') {
            let raw = &rest[1..rest.len() - 1];
            out.push(PathBuf::from(raw.replace("\\\\", "\\")));
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn vdf_paths_parse() {
        let content = "\"libraryfolders\"\n{\n\t\"0\"\n\t{\n\t\t\"path\"\t\t\"C:\\\\Program Files (x86)\\\\Steam\"\n\t}\n\t\"1\"\n\t{\n\t\t\"path\"\t\t\"D:\\\\SteamLibrary\"\n\t}\n}\n";
        let paths = parse_vdf_library_paths(content);
        assert_eq!(paths.len(), 2);
        assert_eq!(paths[1], PathBuf::from("D:\\SteamLibrary"));
    }

    #[test]
    fn distribution_inference() {
        let tmp = tempfile::tempdir().unwrap();
        assert_eq!(infer_distribution(tmp.path()), "standalone");
        std::fs::write(tmp.path().join("steam_api64.dll"), b"x").unwrap();
        assert_eq!(infer_distribution(tmp.path()), "steam");
    }
}
