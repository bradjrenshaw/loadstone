//! `github:owner/repo` sources.
//!
//! Anonymous requests use the plain github.com download endpoints
//! (redirects, no API, no rate limit). With a credential, everything goes
//! through the REST API on api.github.com instead — the plain endpoints
//! don't accept tokens for private repositories:
//! - release assets: look the release up (latest or by tag), find the asset
//!   by name, download its API URL with `Accept: application/octet-stream`
//!   (a redirect to storage; reqwest drops the token when it leaves the host);
//! - archives: `/zipball[/<branch>]`;
//! - single files: `/contents/<path>` as raw.
//!
//! The token is only ever sent to api.github.com. The release list and
//! branch-tip lookups always use the API (60 requests/hour anonymously,
//! 5,000 signed in).

use anyhow::{Context as _, Result};

use super::{ArchiveRef, Provider, ReleaseInfo, Repo};
use crate::auth::Credential;
use crate::fetch::get;
use crate::types::ReleaseManifest;

pub struct GitHub;

const API: &str = "https://api.github.com";
const API_VERSION: (&str, &str) = ("X-GitHub-Api-Version", "2022-11-28");

fn owner_repo(repo: &Repo) -> (&str, &str) {
    (&repo.segments[0], &repo.segments[1])
}

/// Download URL of an asset on the latest release, or on release `tag`.
fn asset_url(repo: &Repo, tag: Option<&str>, file: &str) -> String {
    let (owner, name) = owner_repo(repo);
    match tag {
        Some(tag) => format!("https://github.com/{owner}/{name}/releases/download/{tag}/{file}"),
        None => format!("https://github.com/{owner}/{name}/releases/latest/download/{file}"),
    }
}

/// Archive URL. The default branch is served under `HEAD`.
fn archive_url(repo: &Repo, rev: ArchiveRef<'_>) -> String {
    let (owner, name) = owner_repo(repo);
    match rev {
        ArchiveRef::DefaultBranch => format!("https://github.com/{owner}/{name}/archive/HEAD.zip"),
        ArchiveRef::Branch(branch) => {
            format!("https://github.com/{owner}/{name}/archive/refs/heads/{branch}.zip")
        }
    }
}

/// raw.githubusercontent.com serves the default branch under HEAD with no
/// API involved and no rate limit.
fn raw_url(repo: &Repo, path: &str) -> String {
    let (owner, name) = owner_repo(repo);
    format!("https://raw.githubusercontent.com/{owner}/{name}/HEAD/{path}")
}

fn api_url(repo: &Repo, rest: &str) -> String {
    let (owner, name) = owner_repo(repo);
    format!("{API}/repos/{owner}/{name}{rest}")
}

/// GET from the API, with the token when there is one.
fn api_get(
    url: &str,
    cred: Option<&Credential>,
    accept: &str,
    progress: &mut dyn FnMut(u32),
) -> Result<Vec<u8>> {
    let auth = cred.map(|c| format!("Bearer {}", c.token));
    let mut headers = vec![("Accept", accept), API_VERSION];
    if let Some(auth) = &auth {
        headers.push(("Authorization", auth.as_str()));
    }
    get(url, &headers, progress)
}

fn api_json(url: &str, cred: Option<&Credential>) -> Result<serde_json::Value> {
    let bytes = api_get(url, cred, "application/vnd.github+json", &mut |_| {})?;
    serde_json::from_slice(&bytes).with_context(|| format!("{url} returned unparsable JSON"))
}

/// Download a release asset through the API (authenticated path).
fn api_release_asset(
    repo: &Repo,
    cred: &Credential,
    tag: Option<&str>,
    file: &str,
    progress: &mut dyn FnMut(u32),
) -> Result<Vec<u8>> {
    let release_url = match tag {
        Some(tag) => api_url(repo, &format!("/releases/tags/{tag}")),
        None => api_url(repo, "/releases/latest"),
    };
    let release = api_json(&release_url, Some(cred))?;
    let asset_url = release
        .get("assets")
        .and_then(serde_json::Value::as_array)
        .and_then(|assets| {
            assets.iter().find(|a| a.get("name").and_then(serde_json::Value::as_str) == Some(file))
        })
        .and_then(|a| a.get("url"))
        .and_then(serde_json::Value::as_str)
        .with_context(|| {
            format!(
                "release {} of {} has no {file} asset",
                tag.unwrap_or("latest"),
                repo.source
            )
        })?
        .to_string();
    api_get(&asset_url, Some(cred), "application/octet-stream", progress)
}

impl Provider for GitHub {
    fn scheme(&self) -> &'static str {
        "github"
    }

    fn format(&self) -> &'static str {
        "github:owner/repo"
    }

    fn parse_location(&self, location: &str) -> Option<Vec<String>> {
        let mut parts = location.split('/');
        match (parts.next(), parts.next(), parts.next()) {
            (Some(owner), Some(name), None) if !owner.is_empty() && !name.is_empty() => {
                Some(vec![owner.to_string(), name.to_string()])
            }
            _ => None,
        }
    }

    fn cache_key(&self, repo: &Repo) -> String {
        let (owner, name) = owner_repo(repo);
        format!("{owner}__{name}")
    }

    fn release_manifest(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        tag: Option<&str>,
    ) -> Result<ReleaseManifest> {
        let bytes = self.release_asset(repo, cred, tag, "loadstone-release.json", &mut |_| {});
        let bytes = match tag {
            Some(tag) => bytes.with_context(|| {
                format!("release {tag} has no loadstone-release.json asset (or it is unreachable)")
            })?,
            None => bytes?,
        };
        super::parse_release_manifest(bytes, &repo.source)
    }

    fn release_asset(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        tag: Option<&str>,
        file: &str,
        progress: &mut dyn FnMut(u32),
    ) -> Result<Vec<u8>> {
        match cred {
            Some(cred) => api_release_asset(repo, cred, tag, file, progress),
            None => get(&asset_url(repo, tag, file), &[], progress),
        }
    }

    fn list_releases(&self, repo: &Repo, cred: Option<&Credential>) -> Result<Vec<ReleaseInfo>> {
        let doc = api_json(&api_url(repo, "/releases"), cred)
            .context("release list API response does not parse")?;
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

    fn branch_tip(&self, repo: &Repo, cred: Option<&Credential>, branch: &str) -> Result<String> {
        let doc = api_json(&api_url(repo, &format!("/commits/{branch}")), cred)
            .context("commit API response")?;
        let sha = doc
            .get("sha")
            .and_then(serde_json::Value::as_str)
            .context("commit API response has no sha")?;
        Ok(sha.chars().take(7).collect())
    }

    fn archive(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        rev: ArchiveRef<'_>,
        progress: &mut dyn FnMut(u32),
    ) -> Result<Vec<u8>> {
        match cred {
            Some(cred) => {
                let rest = match rev {
                    ArchiveRef::DefaultBranch => "/zipball".to_string(),
                    ArchiveRef::Branch(branch) => format!("/zipball/{branch}"),
                };
                api_get(&api_url(repo, &rest), Some(cred), "application/vnd.github+json", progress)
            }
            None => get(&archive_url(repo, rev), &[], progress),
        }
    }

    fn default_branch_file(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        path: &str,
    ) -> Result<Vec<u8>> {
        match cred {
            Some(cred) => api_get(
                &api_url(repo, &format!("/contents/{path}")),
                Some(cred),
                "application/vnd.github.raw+json",
                &mut |_| {},
            ),
            None => get(&raw_url(repo, path), &[], &mut |_| {}),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn repo(source: &str) -> Repo {
        super::super::parse(source).unwrap().1
    }

    #[test]
    fn asset_urls() {
        let r = repo("github:ethangreen-dev/lovely-injector");
        assert_eq!(
            asset_url(&r, Some("v0.9.0"), "lovely-x86_64-pc-windows-msvc.zip"),
            "https://github.com/ethangreen-dev/lovely-injector/releases/download/v0.9.0/lovely-x86_64-pc-windows-msvc.zip"
        );
        assert_eq!(
            asset_url(&r, None, "loadstone-release.json"),
            "https://github.com/ethangreen-dev/lovely-injector/releases/latest/download/loadstone-release.json"
        );
    }

    #[test]
    fn archive_raw_and_api_urls() {
        let r = repo("github:me/Repo");
        assert_eq!(archive_url(&r, ArchiveRef::DefaultBranch), "https://github.com/me/Repo/archive/HEAD.zip");
        assert_eq!(
            archive_url(&r, ArchiveRef::Branch("main")),
            "https://github.com/me/Repo/archive/refs/heads/main.zip"
        );
        assert_eq!(
            raw_url(&r, "loadstone-packages/blindfold.json"),
            "https://raw.githubusercontent.com/me/Repo/HEAD/loadstone-packages/blindfold.json"
        );
        assert_eq!(api_url(&r, "/releases/latest"), "https://api.github.com/repos/me/Repo/releases/latest");
        assert_eq!(GitHub.cache_key(&r), "me__Repo");
    }
}
