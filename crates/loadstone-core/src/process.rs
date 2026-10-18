//! Is a program running? Backs the `processRunning` condition (SPEC §9),
//! e.g. a launch that needs the Steam client up. Uses the OS's own process
//! lister (ps, tasklist) rather than a dependency, like detect's reg.exe.

use anyhow::{bail, Context as _, Result};

/// Is any process with one of these executable names running?
pub fn any_running(names: &[&str]) -> Result<bool> {
    let wanted: Vec<String> = names.iter().map(|n| normalize(n)).collect();
    Ok(running_names()?.iter().any(|n| wanted.contains(&normalize(n))))
}

/// Lowercase, without a trailing `.exe`: `Steam.exe` and `steam` are one name.
fn normalize(name: &str) -> String {
    let lower = name.trim().to_lowercase();
    lower.strip_suffix(".exe").map(str::to_string).unwrap_or(lower)
}

/// Executable names of every running process.
#[cfg(not(target_os = "windows"))]
fn running_names() -> Result<Vec<String>> {
    // `comm` is the executable path on macOS and the bare name on Linux;
    // keep the last component either way.
    let out = std::process::Command::new("ps")
        .args(["-A", "-o", "comm="])
        .output()
        .context("failed to run ps")?;
    if !out.status.success() {
        bail!("ps failed listing processes");
    }
    Ok(parse_ps(&String::from_utf8_lossy(&out.stdout)))
}

#[cfg(target_os = "windows")]
fn running_names() -> Result<Vec<String>> {
    use std::os::windows::process::CommandExt;
    const CREATE_NO_WINDOW: u32 = 0x0800_0000;
    let out = std::process::Command::new("tasklist")
        .args(["/fo", "csv", "/nh"])
        .creation_flags(CREATE_NO_WINDOW)
        .output()
        .context("failed to run tasklist")?;
    if !out.status.success() {
        bail!("tasklist failed listing processes");
    }
    Ok(parse_tasklist(&String::from_utf8_lossy(&out.stdout)))
}

#[cfg_attr(target_os = "windows", allow(dead_code))]
fn parse_ps(output: &str) -> Vec<String> {
    output
        .lines()
        .map(str::trim)
        .filter(|l| !l.is_empty())
        .map(|l| l.rsplit('/').next().unwrap_or(l).to_string())
        .collect()
}

/// `"steam.exe","1234","Console","1","50,000 K"` — the first quoted field.
#[cfg_attr(not(target_os = "windows"), allow(dead_code))]
fn parse_tasklist(output: &str) -> Vec<String> {
    output
        .lines()
        .filter_map(|l| l.trim().strip_prefix('"')?.split('"').next())
        .filter(|n| !n.is_empty())
        .map(str::to_string)
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ps_output_keeps_executable_names() {
        let out = "/sbin/launchd\n/Users/me/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS/steam_osx\nbash\n";
        assert_eq!(parse_ps(out), ["launchd", "steam_osx", "bash"]);
    }

    #[test]
    fn tasklist_output_keeps_image_names() {
        let out = "\"System Idle Process\",\"0\",\"Services\",\"0\",\"8 K\"\r\n\"steam.exe\",\"4242\",\"Console\",\"1\",\"50,000 K\"\r\n";
        assert_eq!(parse_tasklist(out), ["System Idle Process", "steam.exe"]);
    }

    #[test]
    fn names_ignore_case_and_exe() {
        assert_eq!(normalize("Steam.EXE"), "steam");
        assert_eq!(normalize("steam_osx"), "steam_osx");
    }
}
