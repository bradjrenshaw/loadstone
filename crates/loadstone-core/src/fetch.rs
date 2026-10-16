//! Plain HTTP downloads. Blocking reqwest on the caller's (worker) thread —
//! no async runtime. Which URLs to fetch for a given source (and whether to
//! authenticate) is the business of [`crate::source`]; this module only
//! moves bytes.

use anyhow::{Context as _, Result};

const USER_AGENT: &str = concat!("Loadstone/", env!("CARGO_PKG_VERSION"));

/// A non-success HTTP status, kept typed so callers can tell "not found"
/// and "not allowed" (try another account) from other failures.
#[derive(Debug)]
pub struct HttpError {
    pub url: String,
    pub status: u16,
}

impl std::fmt::Display for HttpError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "download of {} returned HTTP {}", self.url, self.status)
    }
}

impl std::error::Error for HttpError {}

/// The HTTP status behind an error, if it came from [`HttpError`].
pub fn http_status(err: &anyhow::Error) -> Option<u16> {
    err.chain().find_map(|c| c.downcast_ref::<HttpError>()).map(|e| e.status)
}

fn client() -> Result<reqwest::blocking::Client> {
    // reqwest's default redirect policy drops Authorization when a
    // redirect leaves the original host (API asset downloads redirect to
    // a storage host), so tokens never follow a redirect off api.github.com.
    reqwest::blocking::Client::builder()
        .user_agent(USER_AGENT)
        .timeout(std::time::Duration::from_secs(300))
        .build()
        .context("failed to create HTTP client")
}

/// Download a URL into memory, reporting percentage progress when the size
/// is known.
pub fn download(url: &str, progress: impl FnMut(u32)) -> Result<Vec<u8>> {
    get(url, &[], progress)
}

/// [`download`] with extra request headers (auth, `Accept`).
pub fn get(url: &str, headers: &[(&str, &str)], mut progress: impl FnMut(u32)) -> Result<Vec<u8>> {
    let mut request = client()?.get(url);
    for (name, value) in headers {
        request = request.header(*name, *value);
    }
    let resp = request.send().with_context(|| format!("download failed: {url}"))?;
    if !resp.status().is_success() {
        return Err(HttpError { url: url.to_string(), status: resp.status().as_u16() }.into());
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
