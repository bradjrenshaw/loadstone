//! Remote sources: where package registries and release artifacts live.
//!
//! A source string is `<scheme>:<location>` — today only
//! `github:owner/repo`. Each scheme has a [`Provider`] that knows how to
//! reach it: release manifests and assets, release lists, branch archives,
//! and single files from the default branch. Everything outside this module
//! talks to sources only through these functions, so adding a host (or
//! authenticated access to one) is a change here, not across the crate.
//!
//! Anything that isn't a known scheme — notably a local directory path,
//! including Windows paths like `C:\mods` — is not a remote source.

use anyhow::{Context as _, Result};

use crate::auth::Credential;
use crate::types::ReleaseManifest;

mod github;

/// A parsed remote source.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Repo {
    /// The source string as written (`github:owner/repo`).
    pub source: String,
    /// Provider-specific location segments (`["owner", "repo"]`).
    pub segments: Vec<String>,
}

/// Which revision of a repository to archive.
#[derive(Debug, Clone, Copy)]
pub enum ArchiveRef<'a> {
    /// Whatever the host serves as the default branch.
    DefaultBranch,
    /// A named branch.
    Branch(&'a str),
}

/// One published release, for version pickers.
#[derive(Debug, Clone)]
pub struct ReleaseInfo {
    pub tag: String,
    pub name: String,
    pub prerelease: bool,
}

/// One kind of remote source.
pub trait Provider: Sync {
    /// The scheme before the colon (`"github"`).
    fn scheme(&self) -> &'static str;
    /// The accepted format, for error messages (`"github:owner/repo"`).
    fn format(&self) -> &'static str;
    /// Split the part after `scheme:` into segments; `None` if malformed.
    fn parse_location(&self, location: &str) -> Option<Vec<String>>;
    /// A filesystem-safe name for caching this repo locally.
    fn cache_key(&self, repo: &Repo) -> String;

    /// The release's `loadstone-release.json`: the latest release, or the
    /// release with `tag`.
    fn release_manifest(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        tag: Option<&str>,
    ) -> Result<ReleaseManifest>;
    /// A named asset of the latest release, or of the release with `tag`.
    fn release_asset(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        tag: Option<&str>,
        file: &str,
        progress: &mut dyn FnMut(u32),
    ) -> Result<Vec<u8>>;
    /// Published releases, newest first, drafts excluded.
    fn list_releases(&self, repo: &Repo, cred: Option<&Credential>) -> Result<Vec<ReleaseInfo>>;
    /// Short id of the newest commit on `branch`.
    fn branch_tip(&self, repo: &Repo, cred: Option<&Credential>, branch: &str) -> Result<String>;
    /// A zip archive of the repository at `rev`.
    fn archive(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        rev: ArchiveRef<'_>,
        progress: &mut dyn FnMut(u32),
    ) -> Result<Vec<u8>>;
    /// One file (repo-relative `path`) from the default branch.
    fn default_branch_file(
        &self,
        repo: &Repo,
        cred: Option<&Credential>,
        path: &str,
    ) -> Result<Vec<u8>>;

    // ── Signing in ────────────────────────────────────────────────────
    // Providers that don't support accounts keep these defaults.

    /// Display name of the site, for sign-in UI ("GitHub").
    fn display_name(&self) -> &'static str {
        self.scheme()
    }
    /// The host accounts belong to ("github.com").
    fn host(&self) -> &'static str {
        ""
    }
    /// Begin a browser sign-in: the user visits `verification_uri` and
    /// enters `user_code`.
    fn start_sign_in(&self) -> Result<SignInChallenge> {
        anyhow::bail!("{} doesn't support signing in", self.display_name())
    }
    /// Check once whether the user has finished signing in.
    fn poll_sign_in(&self, _challenge: &SignInChallenge) -> Result<SignInPoll> {
        anyhow::bail!("{} doesn't support signing in", self.display_name())
    }
    /// The account name a token belongs to; fails if the token is refused.
    fn account_name(&self, _token: &str) -> Result<String> {
        anyhow::bail!("{} doesn't support signing in", self.display_name())
    }
}

/// An in-progress browser sign-in (OAuth device flow).
#[derive(Debug, Clone)]
pub struct SignInChallenge {
    /// The short code the user types on the sign-in page.
    pub user_code: String,
    /// The page to open.
    pub verification_uri: String,
    /// Seconds to wait between polls.
    pub interval_secs: u64,
    /// Seconds until the code expires.
    pub expires_in_secs: u64,
    /// The provider's opaque handle for polling.
    pub device_code: String,
}

/// One poll of an in-progress sign-in.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SignInPoll {
    /// Not finished yet; poll again after the interval.
    Pending,
    /// Polling too fast: wait this many seconds between polls from now on.
    SlowDown(u64),
    /// Finished: the access token.
    Done(String),
}

static PROVIDERS: &[&dyn Provider] = &[&github::GitHub];

/// The provider for a scheme ("github").
pub fn provider(scheme: &str) -> Option<&'static dyn Provider> {
    PROVIDERS.iter().copied().find(|p| p.scheme() == scheme)
}

/// Every provider that supports signing in, as (scheme, display name).
pub fn sign_in_providers() -> Vec<(&'static str, &'static str)> {
    PROVIDERS
        .iter()
        .filter(|p| !p.host().is_empty())
        .map(|p| (p.scheme(), p.display_name()))
        .collect()
}

fn provider_for(source: &str) -> Option<(&'static dyn Provider, &str)> {
    let (scheme, location) = source.split_once(':')?;
    PROVIDERS
        .iter()
        .copied()
        .find(|p| p.scheme() == scheme)
        .map(|p| (p, location))
}

/// True if `source` names a remote source (a known scheme), as opposed to
/// a local path.
pub fn is_remote(source: &str) -> bool {
    provider_for(source).is_some()
}

/// The accepted remote source formats, for messages
/// (`"github:owner/repo"`).
pub fn formats() -> String {
    PROVIDERS.iter().map(|p| p.format()).collect::<Vec<_>>().join(" or ")
}

/// Resolve a source string to its provider and parsed location.
pub fn parse(source: &str) -> Result<(&'static dyn Provider, Repo)> {
    let (provider, location) = provider_for(source)
        .with_context(|| format!("\"{source}\" is not a {} source", formats()))?;
    let segments = provider
        .parse_location(location)
        .with_context(|| format!("\"{source}\" is not a {} source", provider.format()))?;
    Ok((provider, Repo { source: source.to_string(), segments }))
}

/// Is `source` a well-formed remote source?
pub fn is_valid(source: &str) -> bool {
    parse(source).is_ok()
}

// ── Convenience wrappers: parse, pick credentials, ask the provider ──
//
// Each wrapper tries the candidate credentials from `auth::candidates` in
// order, moving on when a candidate is refused (401/403/404) and wasn't
// chosen explicitly. `mod_id` lets a mod's own account preference apply;
// registry fetches pass `None`.

/// The hint attached when an anonymous request is answered "not found":
/// on GitHub that is also what a private repository looks like.
#[derive(Debug)]
pub struct MaybePrivate {
    pub source: String,
}

impl std::fmt::Display for MaybePrivate {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{} wasn't found. If it's a private repository, sign in with an account that can \
             see it (Loadstone settings), or set GH_TOKEN",
            self.source
        )
    }
}

impl std::error::Error for MaybePrivate {}

/// True if `err` is (or wraps) the [`MaybePrivate`] hint — the GUI offers
/// to sign in.
pub fn is_maybe_private(err: &anyhow::Error) -> bool {
    err.chain().any(|c| c.downcast_ref::<MaybePrivate>().is_some())
}

fn with_credentials<T>(
    source: &str,
    mod_id: Option<&str>,
    mut op: impl FnMut(&'static dyn Provider, &Repo, Option<&Credential>) -> Result<T>,
) -> Result<T> {
    let (provider, repo) = parse(source)?;
    let candidates = crate::auth::candidates(provider.scheme(), source, mod_id);
    let mut last: Option<(anyhow::Error, Option<Credential>)> = None;
    for cred in candidates {
        match op(provider, &repo, cred.as_ref()) {
            Ok(v) => return Ok(v),
            Err(e) => {
                let retry = crate::auth::retry_after(crate::fetch::http_status(&e), &cred);
                last = Some((e, cred));
                if !retry {
                    break;
                }
            }
        }
    }
    let (err, used) = last.expect("candidates is never empty");
    Err(match (crate::fetch::http_status(&err), &used) {
        (Some(404), None) => err.context(MaybePrivate { source: source.to_string() }),
        (Some(401), Some(c)) => err.context(format!(
            "the token from {} was refused; it may have expired or been revoked",
            c.origin
        )),
        (Some(403 | 404), Some(c)) => {
            err.context(format!("{source} isn't reachable with the token from {}", c.origin))
        }
        _ => err,
    })
}

/// The latest release's manifest, or the manifest of release `tag`.
pub fn release_manifest(source: &str, mod_id: Option<&str>, tag: Option<&str>) -> Result<ReleaseManifest> {
    with_credentials(source, mod_id, |p, r, c| p.release_manifest(r, c, tag))
}

/// An asset of the latest release, or of release `tag`.
pub fn release_asset(
    source: &str,
    mod_id: Option<&str>,
    tag: Option<&str>,
    file: &str,
    mut progress: impl FnMut(u32),
) -> Result<Vec<u8>> {
    with_credentials(source, mod_id, |p, r, c| p.release_asset(r, c, tag, file, &mut progress))
}

/// Published releases, newest first.
pub fn list_releases(source: &str, mod_id: Option<&str>) -> Result<Vec<ReleaseInfo>> {
    with_credentials(source, mod_id, |p, r, c| p.list_releases(r, c))
}

/// Short id of the newest commit on `branch`.
pub fn branch_tip(source: &str, mod_id: Option<&str>, branch: &str) -> Result<String> {
    with_credentials(source, mod_id, |p, r, c| p.branch_tip(r, c, branch))
}

/// A zip archive of the repository at `rev`.
pub fn archive(
    source: &str,
    mod_id: Option<&str>,
    rev: ArchiveRef<'_>,
    mut progress: impl FnMut(u32),
) -> Result<Vec<u8>> {
    with_credentials(source, mod_id, |p, r, c| p.archive(r, c, rev, &mut progress))
}

/// One file from the default branch.
pub fn default_branch_file(source: &str, path: &str) -> Result<Vec<u8>> {
    with_credentials(source, None, |p, r, c| p.default_branch_file(r, c, path))
}

/// Parse release-manifest bytes downloaded from `source`.
pub(crate) fn parse_release_manifest(bytes: Vec<u8>, source: &str) -> Result<ReleaseManifest> {
    let text = String::from_utf8(bytes).context("loadstone-release.json is not UTF-8")?;
    serde_json::from_str(text.trim_start_matches('\u{feff}'))
        .with_context(|| format!("loadstone-release.json from {source} does not parse"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_github_sources() {
        let (provider, repo) = parse("github:bradjrenshaw/Blindfold").unwrap();
        assert_eq!(provider.scheme(), "github");
        assert_eq!(repo.segments, vec!["bradjrenshaw".to_string(), "Blindfold".to_string()]);
        assert!(parse("gitlab:x/y").is_err());
        assert!(parse("github:only-owner").is_err());
        assert!(parse("github:a/b/c").is_err());
    }

    #[test]
    fn local_paths_are_not_remote() {
        assert!(is_remote("github:o/r"));
        assert!(!is_remote("C:\\mods\\registry"));
        assert!(!is_remote("./packages"));
        assert!(!is_remote("gitlab:o/r"));
    }
}
