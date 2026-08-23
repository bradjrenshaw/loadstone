//! Network access: artifact downloads and release-manifest fetching.
//! Blocking reqwest on the caller's (worker) thread — no async runtime.

use anyhow::{bail, Context as _, Result};

const USER_AGENT: &str = concat!("Loadstone/", env!("CARGO_PKG_VERSION"));

fn client() -> Result<reqwest::blocking::Client> {
    reqwest::blocking::Client::builder()
        .user_agent(USER_AGENT)
        .timeout(std::time::Duration::from_secs(300))
        .build()
        .context("failed to create HTTP client")
}

/// `github:owner/repo` -> (owner, repo)
pub fn parse_github_source(source: &str) -> Result<(String, String)> {
    let rest = source
        .strip_prefix("github:")
        .with_context(|| format!("\"{source}\" is not a github:owner/repo source"))?;
    let mut parts = rest.split('/');
    match (parts.next(), parts.next(), parts.next()) {
        (Some(owner), Some(repo), None) if !owner.is_empty() && !repo.is_empty() => {
            Ok((owner.to_string(), repo.to_string()))
        }
        _ => bail!("\"{source}\" is not a github:owner/repo source"),
    }
}

/// URL of an asset on the latest release (plain redirect, no API/rate limit).
pub fn latest_asset_url(source: &str, file: &str) -> Result<String> {
    let (owner, repo) = parse_github_source(source)?;
    Ok(format!(
        "https://github.com/{owner}/{repo}/releases/latest/download/{file}"
    ))
}

/// URL of an asset on a specific tagged release.
pub fn tagged_asset_url(source: &str, tag: &str, file: &str) -> Result<String> {
    let (owner, repo) = parse_github_source(source)?;
    Ok(format!(
        "https://github.com/{owner}/{repo}/releases/download/{tag}/{file}"
    ))
}

/// Download a URL into memory, reporting percentage progress when the size
/// is known.
pub fn download(url: &str, mut progress: impl FnMut(u32)) -> Result<Vec<u8>> {
    let resp = client()?
        .get(url)
        .send()
        .with_context(|| format!("download failed: {url}"))?;
    if !resp.status().is_success() {
        bail!("download of {url} returned HTTP {}", resp.status());
    }
    let total = resp.content_length().unwrap_or(0);
    let mut reader = resp;
    let mut buffer = Vec::new();
    let mut chunk = [0u8; 65536];
    let mut done: u64 = 0;
    use std::io::Read;
    loop {
        let n = reader.read(&mut chunk).context("read error during download")?;
        if n == 0 {
            break;
        }
        buffer.extend_from_slice(&chunk[..n]);
        done += n as u64;
        if total > 0 {
            progress(((done * 100) / total) as u32);
        }
    }
    Ok(buffer)
}

/// URL of a branch's zipball (plain archive endpoint, not rate-limited).
pub fn branch_zipball_url(source: &str, branch: &str) -> Result<String> {
    let (owner, repo) = parse_github_source(source)?;
    Ok(format!(
        "https://github.com/{owner}/{repo}/archive/refs/heads/{branch}.zip"
    ))
}

/// Short sha of the tip of a branch, via the GitHub API (rate-limited to 60
/// unauthenticated requests/hour — callers treat failures as best-effort).
pub fn branch_tip_sha(source: &str, branch: &str) -> Result<String> {
    let (owner, repo) = parse_github_source(source)?;
    let url = format!("https://api.github.com/repos/{owner}/{repo}/commits/{branch}");
    let bytes = download(&url, |_| {})?;
    let doc: serde_json::Value = serde_json::from_slice(&bytes).context("commit API response")?;
    let sha = doc
        .get("sha")
        .and_then(serde_json::Value::as_str)
        .context("commit API response has no sha")?;
    Ok(sha.chars().take(7).collect())
}

fn parse_release_manifest(bytes: Vec<u8>, source: &str) -> Result<crate::types::ReleaseManifest> {
    let text = String::from_utf8(bytes).context("loadstone-release.json is not UTF-8")?;
    serde_json::from_str(text.trim_start_matches('\u{feff}'))
        .with_context(|| format!("loadstone-release.json from {source} does not parse"))
}

/// Fetch and parse the latest loadstone-release.json for a source repo.
pub fn fetch_latest_release_manifest(source: &str) -> Result<crate::types::ReleaseManifest> {
    let url = latest_asset_url(source, "loadstone-release.json")?;
    let bytes = download(&url, |_| {})?;
    parse_release_manifest(bytes, source)
}

/// Fetch and parse the loadstone-release.json attached to one specific
/// release, by tag — version pickers install exactly what was chosen.
pub fn fetch_release_manifest_for_tag(
    source: &str,
    tag: &str,
) -> Result<crate::types::ReleaseManifest> {
    let url = tagged_asset_url(source, tag, "loadstone-release.json")?;
    let bytes = download(&url, |_| {}).with_context(|| {
        format!("release {tag} has no loadstone-release.json asset (or it is unreachable)")
    })?;
    parse_release_manifest(bytes, source)
}

/// One GitHub release, for version pickers.
#[derive(Debug, Clone)]
pub struct ReleaseInfo {
    pub tag: String,
    pub name: String,
    pub prerelease: bool,
}

/// List a repo's releases, newest first, via the GitHub API (rate-limited
/// to 60 unauthenticated requests/hour — call only on explicit user
/// action). Drafts are skipped.
pub fn list_releases(source: &str) -> Result<Vec<ReleaseInfo>> {
    let (owner, repo) = parse_github_source(source)?;
    let url = format!("https://api.github.com/repos/{owner}/{repo}/releases");
    let bytes = download(&url, |_| {})?;
    let doc: serde_json::Value =
        serde_json::from_slice(&bytes).context("release list API response does not parse")?;
    let list = doc.as_array().context("release list API response is not a list")?;
    let mut out = Vec::new();
    for entry in list {
        if entry.get("draft").and_then(serde_json::Value::as_bool).unwrap_or(false) {
            continue;
        }
        let Some(tag) = entry.get("tag_name").and_then(serde_json::Value::as_str) else {
            continue;
        };
        out.push(ReleaseInfo {
            tag: tag.to_string(),
            name: entry
                .get("name")
                .and_then(serde_json::Value::as_str)
                .unwrap_or("")
                .to_string(),
            prerelease: entry
                .get("prerelease")
                .and_then(serde_json::Value::as_bool)
                .unwrap_or(false),
        });
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn github_source_parsing() {
        assert_eq!(
            parse_github_source("github:bradjrenshaw/Blindfold").unwrap(),
            ("bradjrenshaw".to_string(), "Blindfold".to_string())
        );
        assert!(parse_github_source("gitlab:x/y").is_err());
        assert!(parse_github_source("github:only-owner").is_err());
    }

    #[test]
    fn asset_urls() {
        assert_eq!(
            tagged_asset_url("github:ethangreen-dev/lovely-injector", "v0.9.0", "lovely-x86_64-pc-windows-msvc.zip").unwrap(),
            "https://github.com/ethangreen-dev/lovely-injector/releases/download/v0.9.0/lovely-x86_64-pc-windows-msvc.zip"
        );
    }
}
