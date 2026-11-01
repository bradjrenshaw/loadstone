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

/// Try to auto-detect the game's first-found copy.
/// One Steam app a game package can be installed as. `detect.steam` is
/// either a single entry or a list, for games that also ship as a
/// separate Steam app (a demo, a playtest) a mod supports equally:
///
/// ```json
/// "steam": [ { "appId": 1, "dirName": "Game" },
///            { "appId": 2, "dirName": "Game Demo", "name": "demo" } ]
/// ```
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SteamEntry {
    pub app_id: Option<String>,
    pub dir_name: Option<String>,
    /// Shown in the copy's label ("Steam demo copy"); none for the main app.
    pub name: Option<String>,
}

pub fn steam_entries(game: &GameManifest) -> Vec<SteamEntry> {
    let entry = |v: &serde_json::Value| SteamEntry {
        app_id: match v.get("appId") {
            Some(serde_json::Value::String(s)) if !s.trim().is_empty() => Some(s.trim().to_string()),
            Some(serde_json::Value::Number(n)) => Some(n.to_string()),
            _ => None,
        },
        dir_name: v.get("dirName").and_then(|d| d.as_str()).map(str::to_string),
        name: v
            .get("name")
            .and_then(|d| d.as_str())
            .map(str::trim)
            .filter(|n| !n.is_empty())
            .map(str::to_string),
    };
    match game.detect.distributions.get("steam") {
        Some(serde_json::Value::Array(items)) => items.iter().filter(|v| v.is_object()).map(entry).collect(),
        Some(v) if v.is_object() => vec![entry(v)],
        _ => Vec::new(),
    }
}

/// The Steam entry a folder belongs to, matched by its folder name (Steam
/// installs each app under `steamapps/common/<dirName>`). None when the
/// folder matches no entry, e.g. a hand-picked copy elsewhere.
pub fn steam_entry_for_dir(game: &GameManifest, dir: &Path) -> Option<SteamEntry> {
    let folder = dir.file_name()?.to_string_lossy().to_lowercase();
    steam_entries(game)
        .into_iter()
        .find(|e| e.dir_name.as_deref().is_some_and(|d| d.to_lowercase() == folder))
}

pub fn detect(game: &GameManifest) -> Result<Option<DetectedGame>> {
    Ok(detect_all(game)?.into_iter().next())
}

/// Every copy of the game detection can find. Currently implements Steam
/// (the only distribution the existing installers detect, though several
/// Steam libraries can each hold a copy); other distributions resolve via
/// the user browsing to the folder.
pub fn detect_all(game: &GameManifest) -> Result<Vec<DetectedGame>> {
    let mut found: Vec<DetectedGame> = Vec::new();
    let mut seen: Vec<PathBuf> = Vec::new();
    for steam in steam_entries(game) {
        if let Some(dir_name) = steam.dir_name.as_deref() {
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
                        let canonical =
                            std::fs::canonicalize(&candidate).unwrap_or(candidate.clone());
                        if !seen.contains(&canonical) {
                            seen.push(canonical);
                            found.push(DetectedGame {
                                game_dir: candidate,
                                distribution: "steam".to_string(),
                            });
                        }
                    }
                }
            }
        }
    }
    Ok(found)
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

/// The Launch Options the most recent Steam user set for `app_id`, if Steam,
/// that user, and an entry for the game can be found. Backs the
/// `steamLaunchOptions` condition. Steam saves this file itself, so a change
/// made while Steam runs may not be on disk yet.
pub fn steam_launch_options(app_id: &str) -> Option<String> {
    steam_roots().into_iter().find_map(|root| {
        let account = most_recent_account(&root)?;
        let path = root.join("userdata").join(account).join("config").join("localconfig.vdf");
        let tree = parse_vdf(&std::fs::read_to_string(path).ok()?)?;
        tree.get_path(&["UserLocalConfigStore", "Software", "Valve", "Steam", "apps", app_id, "LaunchOptions"])?
            .as_str()
            .map(str::to_string)
    })
}

/// The userdata folder name (32-bit account id) of the user who signed in
/// last: the one marked MostRecent, else the newest timestamp.
fn most_recent_account(steam_root: &Path) -> Option<String> {
    const STEAM_ID64_BASE: u64 = 76_561_197_960_265_728;
    let text = std::fs::read_to_string(steam_root.join("config").join("loginusers.vdf")).ok()?;
    let tree = parse_vdf(&text)?;
    let users = tree.get_path(&["users"])?.as_map()?;
    let field = |v: &Vdf, key: &str| v.get_path(&[key]).and_then(Vdf::as_str).map(str::to_string);
    let (id64, _) = users
        .iter()
        .max_by_key(|(_, u)| {
            let recent = field(u, "MostRecent").as_deref() == Some("1");
            let stamp: u64 = field(u, "timestamp").and_then(|t| t.parse().ok()).unwrap_or(0);
            (recent, stamp)
        })?;
    let account = id64.parse::<u64>().ok()?.checked_sub(STEAM_ID64_BASE)?;
    Some(account.to_string())
}

/// A Valve KeyValues (text VDF) node.
#[derive(Debug, Clone, PartialEq)]
pub enum Vdf {
    Str(String),
    Map(Vec<(String, Vdf)>),
}

impl Vdf {
    pub fn as_str(&self) -> Option<&str> {
        match self {
            Vdf::Str(s) => Some(s),
            Vdf::Map(_) => None,
        }
    }

    pub fn as_map(&self) -> Option<&[(String, Vdf)]> {
        match self {
            Vdf::Map(m) => Some(m),
            Vdf::Str(_) => None,
        }
    }

    /// Follow keys down from this node. Steam is inconsistent about key case
    /// ("apps" vs "Apps"), so keys match case-insensitively.
    pub fn get_path(&self, keys: &[&str]) -> Option<&Vdf> {
        keys.iter().try_fold(self, |node, key| {
            node.as_map()?.iter().find(|(k, _)| k.eq_ignore_ascii_case(key)).map(|(_, v)| v)
        })
    }
}

/// Parse text VDF into a root map. Quoted keys and values with `\\` escapes,
/// unquoted tokens, `//` comments, and `[$CONDITION]` suffixes (skipped).
pub fn parse_vdf(text: &str) -> Option<Vdf> {
    let mut chars = text.chars().peekable();
    let root = parse_vdf_map(&mut chars, true)?;
    Some(Vdf::Map(root))
}

fn parse_vdf_map(
    chars: &mut std::iter::Peekable<std::str::Chars<'_>>,
    top: bool,
) -> Option<Vec<(String, Vdf)>> {
    let mut entries = Vec::new();
    loop {
        match next_vdf_token(chars)? {
            VdfToken::End if top => return Some(entries),
            VdfToken::Close if !top => return Some(entries),
            VdfToken::Text(key) => {
                let value = match next_vdf_token(chars)? {
                    VdfToken::Text(v) => Vdf::Str(v),
                    VdfToken::Open => Vdf::Map(parse_vdf_map(chars, false)?),
                    _ => return None,
                };
                entries.push((key, value));
            }
            _ => return None,
        }
    }
}

enum VdfToken {
    Text(String),
    Open,
    Close,
    End,
}

fn next_vdf_token(chars: &mut std::iter::Peekable<std::str::Chars<'_>>) -> Option<VdfToken> {
    loop {
        match chars.peek().copied() {
            None => return Some(VdfToken::End),
            Some(c) if c.is_whitespace() => {
                chars.next();
            }
            Some('/') => {
                chars.next();
                if chars.peek() != Some(&'/') {
                    return None;
                }
                for c in chars.by_ref() {
                    if c == '\n' {
                        break;
                    }
                }
            }
            Some('[') => {
                for c in chars.by_ref() {
                    if c == ']' {
                        break;
                    }
                }
            }
            Some('{') => {
                chars.next();
                return Some(VdfToken::Open);
            }
            Some('}') => {
                chars.next();
                return Some(VdfToken::Close);
            }
            Some('"') => {
                chars.next();
                let mut out = String::new();
                loop {
                    match chars.next()? {
                        '"' => return Some(VdfToken::Text(out)),
                        '\\' => match chars.next()? {
                            'n' => out.push('\n'),
                            't' => out.push('\t'),
                            other => out.push(other),
                        },
                        c => out.push(c),
                    }
                }
            }
            Some(_) => {
                let mut out = String::new();
                while let Some(&c) = chars.peek() {
                    if c.is_whitespace() || matches!(c, '"' | '{' | '}') {
                        break;
                    }
                    out.push(c);
                    chars.next();
                }
                return Some(VdfToken::Text(out));
            }
        }
    }
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
    fn steam_list_matches_each_copy_to_its_app() {
        let game: GameManifest = serde_json::from_value(serde_json::json!({
            "manifestVersion": 1, "kind": "game", "id": "g", "name": "G",
            "detect": { "steam": [
                { "appId": 100, "dirName": "Game" },
                { "appId": "200", "dirName": "Game Demo", "name": "demo" }
            ] }
        }))
        .unwrap();
        let entries = steam_entries(&game);
        assert_eq!(entries.len(), 2);
        let demo = steam_entry_for_dir(&game, Path::new("/lib/steamapps/common/game demo")).unwrap();
        assert_eq!(demo.app_id.as_deref(), Some("200"));
        assert_eq!(demo.name.as_deref(), Some("demo"));
        let full = Path::new("/lib/steamapps/common/Game");
        assert_eq!(steam_entry_for_dir(&game, full).unwrap().name, None);
        assert_eq!(crate::context::steam_app_id_of(&game, full).as_deref(), Some("100"));
        // A folder matching no entry gets the main app's id.
        let elsewhere = Path::new("/somewhere/else");
        assert!(steam_entry_for_dir(&game, elsewhere).is_none());
        assert_eq!(crate::context::steam_app_id_of(&game, elsewhere).as_deref(), Some("100"));

        // The single-object form still works.
        let single: GameManifest = serde_json::from_value(serde_json::json!({
            "manifestVersion": 1, "kind": "game", "id": "g", "name": "G",
            "detect": { "steam": { "appId": 7, "dirName": "Game" } }
        }))
        .unwrap();
        assert_eq!(steam_entries(&single).len(), 1);
        assert_eq!(crate::context::steam_app_id_of(&single, elsewhere).as_deref(), Some("7"));
    }

    #[test]
    fn distribution_inference() {
        let tmp = tempfile::tempdir().unwrap();
        assert_eq!(infer_distribution(tmp.path()), "standalone");
        std::fs::write(tmp.path().join("steam_api64.dll"), b"x").unwrap();
        assert_eq!(infer_distribution(tmp.path()), "steam");
    }

    #[test]
    fn vdf_tree_parses_launch_options() {
        let text = r#"
"UserLocalConfigStore"
{
	"Software"
	{
		"Valve"
		{
			"Steam"
			{
				"Apps"
				{
					"2379780"
					{
						"LaunchOptions"		"\"/Users/me/Balatro/steam_lovely_macos.sh\" %command%"
						"cloud"	{ "last_sync_state"	"synchronized" }
					}
				}
			}
		}
	}
}
"#;
        let tree = parse_vdf(text).unwrap();
        let opts = tree
            .get_path(&["UserLocalConfigStore", "Software", "Valve", "Steam", "apps", "2379780", "LaunchOptions"])
            .and_then(Vdf::as_str);
        assert_eq!(opts, Some(r#""/Users/me/Balatro/steam_lovely_macos.sh" %command%"#));
    }

    #[test]
    fn vdf_rejects_unbalanced_input() {
        assert!(parse_vdf("\"a\" { \"b\" \"c\"").is_none());
        assert!(parse_vdf("\"a\" }").is_none());
    }

    #[test]
    fn most_recent_account_prefers_marked_then_newest() {
        let tmp = tempfile::tempdir().unwrap();
        std::fs::create_dir_all(tmp.path().join("config")).unwrap();
        let write = |body: &str| std::fs::write(tmp.path().join("config/loginusers.vdf"), body).unwrap();
        write(r#""users" { "76561198000000001" { "timestamp" "5" } "76561198000000002" { "timestamp" "9" } }"#);
        assert_eq!(most_recent_account(tmp.path()).as_deref(), Some("39734274"));
        write(r#""users" { "76561198000000001" { "timestamp" "5" "MostRecent" "1" } "76561198000000002" { "timestamp" "9" } }"#);
        assert_eq!(most_recent_account(tmp.path()).as_deref(), Some("39734273"));
    }
}
