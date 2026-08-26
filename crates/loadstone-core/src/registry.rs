//! Registry resolution (SPEC §2): turning registry sources into local
//! directories of package files, and resolving a package id through the
//! scope chain — full package files first, then link files, innermost
//! registry first.
//!
//! Remote registries are fetched as repo zipballs (no API token, no rate
//! limit) and only their `loadstone-packages/*.json` entries are kept, in a
//! per-source cache directory. A fetch failure falls back to the cached
//! copy when one exists.

use std::io::{Cursor, Read};
use std::path::{Path, PathBuf};

use anyhow::{bail, Context as _, Result};

use crate::fetch;
use crate::types::{GameManifest, Kind, LinkEntry, ProjectManifest};

/// One directory of package files plus where it came from.
#[derive(Debug, Clone)]
pub struct Scope {
    pub dir: PathBuf,
    /// `github:owner/repo` when the directory is a fetched checkout of that
    /// repo; None for plain local directories.
    pub source: Option<String>,
}

#[derive(Debug, Clone)]
pub struct ResolvedPackage {
    pub manifest: ProjectManifest,
    /// The scope the package file was found in — the innermost scope for
    /// this package's own references (its game, its dependencies).
    pub scope: Scope,
    /// The repo its releases come from: the manifest's `source` field, or
    /// the scope's source when absent (SPEC §2 default).
    pub release_source: Option<String>,
}

/// Fetches a registry source into a local directory of package files.
/// Injectable so tests can map sources to fixture directories.
pub trait RegistryFetcher {
    fn fetch(&mut self, source: &str) -> Result<PathBuf>;

    /// Fetch just the named packages (and the files they reference) when
    /// the source supports something cheaper than a full checkout.
    /// Defaults to a full fetch.
    fn fetch_packages(&mut self, source: &str, wanted: &[String]) -> Result<PathBuf> {
        let _ = wanted;
        self.fetch(source)
    }
}

/// Package ids double as file names in raw-fetch URLs; only plain slugs
/// may travel there, so a link file cannot steer the request elsewhere.
fn is_plain_id(id: &str) -> bool {
    !id.is_empty()
        && !id.contains("..")
        && id
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_' || c == '.')
}

/// The static per-file URL: raw.githubusercontent.com serves the default
/// branch under HEAD with no API involved and no rate limit.
fn raw_package_url(owner: &str, repo: &str, id: &str) -> String {
    format!("https://raw.githubusercontent.com/{owner}/{repo}/HEAD/loadstone-packages/{id}.json")
}

/// The real fetcher: local paths pass through; `github:` sources download a
/// zipball of the default branch and extract `loadstone-packages/*.json`.
pub struct HttpFetcher {
    cache_root: PathBuf,
    log: Box<dyn FnMut(&str)>,
}

impl HttpFetcher {
    pub fn new(cache_root: Option<PathBuf>, log: Box<dyn FnMut(&str)>) -> Result<Self> {
        let cache_root = match cache_root {
            Some(r) => r,
            None => dirs::data_local_dir()
                .context("no local data directory")?
                .join("Loadstone")
                .join("registries"),
        };
        Ok(Self { cache_root, log })
    }
}

impl RegistryFetcher for HttpFetcher {
    fn fetch(&mut self, source: &str) -> Result<PathBuf> {
        // Local directory registries: use as-is.
        if !source.starts_with("github:") {
            let dir = PathBuf::from(source);
            if dir.is_dir() {
                return Ok(dir);
            }
            bail!("registry \"{source}\" is neither github:owner/repo nor an existing directory");
        }

        let (owner, repo) = fetch::parse_github_source(source)?;
        let cache = self.cache_root.join(format!("{owner}__{repo}"));

        match fetch_packages_zipball(source) {
            Ok(files) => {
                if files.is_empty() {
                    bail!("{source} has no loadstone-packages directory");
                }
                if cache.exists() {
                    std::fs::remove_dir_all(&cache)?;
                }
                std::fs::create_dir_all(&cache)?;
                for (name, data) in files {
                    std::fs::write(cache.join(name), data)?;
                }
                Ok(cache)
            }
            Err(e) => {
                if cache.is_dir() {
                    (self.log)(&format!(
                        "Could not refresh {source} ({e}); using the cached copy."
                    ));
                    Ok(cache)
                } else {
                    Err(e).with_context(|| format!("failed to fetch registry {source}"))
                }
            }
        }
    }

    /// Allowlisted links skip the repo zipball: each named package file
    /// sits at a static raw URL (`loadstone-packages/<id>.json` — file
    /// named by id, the documented convention), so a few KB of JSON no
    /// longer costs a whole-repo download. The mod's game package and any
    /// dependency files hosted alongside come too; ones that 404 are
    /// expected (hosted in an outer scope instead). Any required file
    /// missing or unparsable falls back to the zipball path, so repos
    /// that ignore the naming convention still resolve.
    fn fetch_packages(&mut self, source: &str, wanted: &[String]) -> Result<PathBuf> {
        if !source.starts_with("github:")
            || wanted.is_empty()
            || !wanted.iter().all(|id| is_plain_id(id))
        {
            return self.fetch(source);
        }
        let (owner, repo) = fetch::parse_github_source(source)?;

        let mut files: Vec<(String, Vec<u8>)> = Vec::new();
        let mut seen: std::collections::BTreeSet<String> = Default::default();
        // (id, required): the allowlisted ids must resolve; referenced
        // game/dependency files are best-effort.
        let mut queue: Vec<(String, bool)> =
            wanted.iter().map(|id| (id.clone(), true)).collect();
        let mut complete = true;
        while let Some((id, required)) = queue.pop() {
            if !seen.insert(id.clone()) {
                continue;
            }
            let url = raw_package_url(&owner, &repo, &id);
            let bytes = match fetch::download(&url, |_| {}) {
                Ok(b) => b,
                Err(_) => {
                    if required {
                        complete = false;
                        break;
                    }
                    continue;
                }
            };
            let text = String::from_utf8_lossy(&bytes);
            let Ok(doc) =
                serde_json::from_str::<serde_json::Value>(text.trim_start_matches('\u{feff}'))
            else {
                if required {
                    complete = false;
                    break;
                }
                continue;
            };
            if let Some(game) = doc.get("game").and_then(serde_json::Value::as_str) {
                if is_plain_id(game) {
                    queue.push((game.to_string(), false));
                }
            }
            if let Some(deps) = doc.get("dependencies").and_then(serde_json::Value::as_array) {
                for dep in deps {
                    if let Some(dep_id) = dep.get("id").and_then(serde_json::Value::as_str) {
                        if is_plain_id(dep_id) {
                            queue.push((dep_id.to_string(), false));
                        }
                    }
                }
            }
            files.push((format!("{id}.json"), bytes));
        }
        if !complete || files.is_empty() {
            return self.fetch(source);
        }

        let cache = self.cache_root.join(format!("{owner}__{repo}"));
        if cache.exists() {
            std::fs::remove_dir_all(&cache)?;
        }
        std::fs::create_dir_all(&cache)?;
        for (name, data) in files {
            std::fs::write(cache.join(name), data)?;
        }
        Ok(cache)
    }
}

/// Download the repo zipball and pull out `<top>/loadstone-packages/*.json`.
/// Tries HEAD (default branch), then main, then master — the plain archive
/// endpoints are not rate-limited, unlike the API's zipball endpoint.
fn fetch_packages_zipball(source: &str) -> Result<Vec<(String, Vec<u8>)>> {
    let (owner, repo) = fetch::parse_github_source(source)?;
    let mut last_err = None;
    for git_ref in ["HEAD", "refs/heads/main", "refs/heads/master"] {
        let url = format!("https://github.com/{owner}/{repo}/archive/{git_ref}.zip");
        // GitHub sometimes answers a bad ref with an HTML page and HTTP 200
        // instead of a 404, so a non-zip payload also advances the fallback.
        match fetch::download(&url, |_| {}).and_then(|bytes| extract_packages(&bytes)) {
            Ok(files) => return Ok(files),
            Err(e) => last_err = Some(e),
        }
    }
    Err(last_err.unwrap())
}

fn extract_packages(zip_bytes: &[u8]) -> Result<Vec<(String, Vec<u8>)>> {
    let mut archive =
        zip::ZipArchive::new(Cursor::new(zip_bytes)).context("registry zipball is not a zip")?;
    let mut out = Vec::new();
    for i in 0..archive.len() {
        let mut entry = archive.by_index(i)?;
        let name = entry.name().replace('\\', "/");
        if name.ends_with('/') {
            continue;
        }
        // <repo-ref>/loadstone-packages/<file>.json — exactly one dir deep.
        let mut parts = name.split('/');
        let (_top, dir, file) = (parts.next(), parts.next(), parts.next());
        if dir != Some("loadstone-packages") || parts.next().is_some() {
            continue;
        }
        let Some(file) = file else { continue };
        if !file.ends_with(".json") || file.contains("..") {
            continue;
        }
        let mut data = Vec::new();
        entry.read_to_end(&mut data)?;
        out.push((file.to_string(), data));
    }
    Ok(out)
}

// ---------------------------------------------------------------------------
// Resolution through the scope chain.

pub struct Resolver<'a> {
    pub scopes: Vec<Scope>,
    pub fetcher: &'a mut dyn RegistryFetcher,
}

fn read_docs(dir: &Path) -> Result<Vec<(PathBuf, serde_json::Value)>> {
    let mut out = Vec::new();
    let mut files: Vec<PathBuf> = std::fs::read_dir(dir)
        .with_context(|| format!("failed to read {}", dir.display()))?
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .filter(|p| p.extension().and_then(|e| e.to_str()) == Some("json"))
        .collect();
    files.sort();
    for file in files {
        let text = std::fs::read_to_string(&file)?;
        if let Ok(doc) = serde_json::from_str::<serde_json::Value>(text.trim_start_matches('\u{feff}'))
        {
            out.push((file, doc));
        }
    }
    Ok(out)
}

fn doc_kind(doc: &serde_json::Value) -> &str {
    doc.get("kind").and_then(serde_json::Value::as_str).unwrap_or("mod")
}

fn doc_id(doc: &serde_json::Value) -> &str {
    doc.get("id").and_then(serde_json::Value::as_str).unwrap_or("")
}

impl<'a> Resolver<'a> {
    /// Build scopes from registry sources (profile order = innermost first).
    pub fn from_sources(
        sources: &[String],
        fetcher: &'a mut dyn RegistryFetcher,
    ) -> Result<Self> {
        let mut scopes = Vec::new();
        let mut resolver = Resolver { scopes: Vec::new(), fetcher };
        for source in sources {
            let dir = resolver.fetcher.fetch(source)?;
            let src = source.starts_with("github:").then(|| source.clone());
            scopes.push(Scope { dir, source: src });
        }
        resolver.scopes = scopes;
        Ok(resolver)
    }

    /// Find a project package (mod/tool/library) by id: full files across
    /// all scopes first, then link files — followed by fetching the linked
    /// repo and looking again (one level, per SPEC §2).
    pub fn resolve_project(&mut self, id: &str) -> Result<ResolvedPackage> {
        // Pass 1: full package files.
        for scope in &self.scopes {
            for (_, doc) in read_docs(&scope.dir)? {
                if doc_id(&doc) == id && doc_kind(&doc) != "link" && doc_kind(&doc) != "game" {
                    let manifest: ProjectManifest = serde_json::from_value(doc)
                        .with_context(|| format!("package \"{id}\" is not a valid project manifest"))?;
                    let release_source = manifest.source.clone().or_else(|| scope.source.clone());
                    return Ok(ResolvedPackage { manifest, scope: scope.clone(), release_source });
                }
            }
        }

        // Pass 2: links. Allowlisted links for this id first, then open links.
        let mut candidates: Vec<(usize, LinkEntry)> = Vec::new();
        for (rank, scope) in self.scopes.iter().enumerate() {
            for (_, doc) in read_docs(&scope.dir)? {
                if doc_kind(&doc) == "link" {
                    if let Ok(link) = serde_json::from_value::<LinkEntry>(doc) {
                        let allowlisted = link.packages.iter().any(|p| p == id);
                        let open = link.packages.is_empty();
                        if allowlisted || open {
                            candidates.push((if allowlisted { rank } else { rank + 1000 }, link));
                        }
                    }
                }
            }
        }
        candidates.sort_by_key(|(rank, _)| *rank);
        for (_, link) in candidates {
            let fetched = if link.packages.is_empty() {
                self.fetcher.fetch(&link.source)
            } else {
                self.fetcher.fetch_packages(&link.source, &link.packages)
            };
            let dir = match fetched {
                Ok(d) => d,
                Err(_) => continue,
            };
            for (_, doc) in read_docs(&dir)? {
                if doc_id(&doc) == id && doc_kind(&doc) != "link" && doc_kind(&doc) != "game" {
                    let manifest: ProjectManifest = serde_json::from_value(doc)
                        .with_context(|| format!("package \"{id}\" is not a valid project manifest"))?;
                    let scope = Scope { dir: dir.clone(), source: Some(link.source.clone()) };
                    let release_source = manifest.source.clone().or_else(|| scope.source.clone());
                    return Ok(ResolvedPackage { manifest, scope, release_source });
                }
            }
        }
        bail!("package \"{id}\" not found in any registry")
    }

    /// Resolve a game id through the chain for a package found in
    /// `innermost`: that scope's directory first, then every scope in order.
    pub fn resolve_game(&mut self, id: &str, innermost: &Scope) -> Result<GameManifest> {
        let mut dirs: Vec<PathBuf> = vec![innermost.dir.clone()];
        dirs.extend(self.scopes.iter().map(|s| s.dir.clone()));
        for dir in dirs {
            for (_, doc) in read_docs(&dir)? {
                if doc_id(&doc) == id && doc_kind(&doc) == "game" {
                    return serde_json::from_value(doc)
                        .with_context(|| format!("\"{id}\" is not a valid game package"));
                }
            }
        }
        bail!("game package \"{id}\" not found in the scope chain")
    }

    /// Every mod visible through the chain (for manager-mode browsing):
    /// full mod files plus link targets, deduplicated by id, innermost wins.
    pub fn list_mods(&mut self) -> Result<Vec<ResolvedPackage>> {
        let mut seen = std::collections::BTreeSet::new();
        let mut out = Vec::new();
        // Full files.
        for scope in self.scopes.clone() {
            for (_, doc) in read_docs(&scope.dir)? {
                if doc_kind(&doc) == "mod" && !doc_id(&doc).is_empty() {
                    let id = doc_id(&doc).to_string();
                    if seen.insert(id) {
                        if let Ok(manifest) = serde_json::from_value::<ProjectManifest>(doc) {
                            if manifest.kind == Kind::Mod {
                                let release_source =
                                    manifest.source.clone().or_else(|| scope.source.clone());
                                out.push(ResolvedPackage {
                                    manifest,
                                    scope: scope.clone(),
                                    release_source,
                                });
                            }
                        }
                    }
                }
            }
        }
        // Linked repos.
        let mut links = Vec::new();
        for scope in &self.scopes {
            for (_, doc) in read_docs(&scope.dir)? {
                if doc_kind(&doc) == "link" {
                    if let Ok(link) = serde_json::from_value::<LinkEntry>(doc) {
                        links.push(link);
                    }
                }
            }
        }
        for link in links {
            let fetched = if link.packages.is_empty() {
                self.fetcher.fetch(&link.source)
            } else {
                self.fetcher.fetch_packages(&link.source, &link.packages)
            };
            let Ok(dir) = fetched else { continue };
            for (_, doc) in read_docs(&dir)? {
                if doc_kind(&doc) != "mod" || doc_id(&doc).is_empty() {
                    continue;
                }
                let id = doc_id(&doc).to_string();
                if !link.packages.is_empty() && !link.packages.iter().any(|p| p == &id) {
                    continue;
                }
                if seen.insert(id) {
                    if let Ok(manifest) = serde_json::from_value::<ProjectManifest>(doc) {
                        if manifest.kind == Kind::Mod {
                            let scope = Scope { dir: dir.clone(), source: Some(link.source.clone()) };
                            let release_source =
                                manifest.source.clone().or_else(|| scope.source.clone());
                            out.push(ResolvedPackage { manifest, scope, release_source });
                        }
                    }
                }
            }
        }
        Ok(out)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::BTreeMap;

    /// Maps sources to fixture directories, recording fetch order.
    #[derive(Default)]
    struct FakeFetcher {
        map: BTreeMap<String, PathBuf>,
        fetched: Vec<String>,
        package_fetches: Vec<(String, Vec<String>)>,
    }

    impl RegistryFetcher for FakeFetcher {
        fn fetch(&mut self, source: &str) -> Result<PathBuf> {
            self.fetched.push(source.to_string());
            if !source.starts_with("github:") {
                return Ok(PathBuf::from(source));
            }
            self.map
                .get(source)
                .cloned()
                .with_context(|| format!("unknown source {source}"))
        }

        fn fetch_packages(&mut self, source: &str, wanted: &[String]) -> Result<PathBuf> {
            self.package_fetches.push((source.to_string(), wanted.to_vec()));
            self.fetch(source)
        }
    }

    fn write(dir: &Path, name: &str, doc: serde_json::Value) {
        std::fs::create_dir_all(dir).unwrap();
        std::fs::write(dir.join(name), serde_json::to_string_pretty(&doc).unwrap()).unwrap();
    }

    #[test]
    fn resolves_through_links_with_chain_scoping() {
        let tmp = tempfile::tempdir().unwrap();
        // The community registry: a link to the mod repo, plus its own copy
        // of the game (outer scope).
        let registry = tmp.path().join("registry");
        write(
            &registry,
            "blindfold.json",
            serde_json::json!({ "kind": "link", "source": "github:me/Blindfold", "packages": ["blindfold"] }),
        );
        write(
            &registry,
            "balatro.json",
            serde_json::json!({ "manifestVersion": 1, "kind": "game", "id": "balatro", "name": "Registry Copy",
                                 "userData": { "windows": "${appData}/Balatro" } }),
        );
        // The mod repo: mod + its own game file (innermost — must win).
        let repo = tmp.path().join("repo");
        write(
            &repo,
            "blindfold.json",
            serde_json::json!({ "manifestVersion": 1, "id": "blindfold", "name": "Blindfold",
                                 "description": "d", "authors": ["a"], "game": "balatro",
                                 "install": [ { "step": "extract-archive",
                                                "routes": [ { "from": "**", "to": "${gameDir}" } ] } ] }),
        );
        write(
            &repo,
            "balatro.json",
            serde_json::json!({ "manifestVersion": 1, "kind": "game", "id": "balatro", "name": "Repo Copy",
                                 "userData": { "windows": "${appData}/Balatro" } }),
        );

        let mut fetcher = FakeFetcher {
            map: BTreeMap::from([("github:me/Blindfold".to_string(), repo.clone())]),
            ..Default::default()
        };
        let mut resolver =
            Resolver::from_sources(&[registry.to_string_lossy().into_owned()], &mut fetcher)
                .unwrap();

        let resolved = resolver.resolve_project("blindfold").unwrap();
        assert_eq!(resolved.manifest.id, "blindfold");
        assert_eq!(resolved.release_source.as_deref(), Some("github:me/Blindfold"));

        // Innermost (the mod repo's own game file) wins over the registry's.
        let game = resolver.resolve_game("balatro", &resolved.scope).unwrap();
        assert_eq!(game.name, "Repo Copy");

        // Full files beat link-following: a tool hosted in the registry
        // resolves without any fetch.
        write(
            &registry,
            "lovely-injector.json",
            serde_json::json!({ "manifestVersion": 1, "kind": "tool", "id": "lovely-injector",
                                 "name": "Lovely", "description": "d", "authors": ["a"],
                                 "source": "github:up/stream",
                                 "install": [ { "step": "extract-archive",
                                                "routes": [ { "from": "version.dll", "to": "${gameDir}/version.dll" } ] } ] }),
        );
        let tool = resolver.resolve_project("lovely-injector").unwrap();
        assert_eq!(tool.release_source.as_deref(), Some("github:up/stream"));

        // Allowlists gate link following.
        assert!(resolver.resolve_project("not-listed").is_err());

        // Allowlisted links went through the targeted fetch so an HTTP
        // fetcher can pull single files instead of the repo zipball.
        drop(resolver);
        assert_eq!(
            fetcher.package_fetches.first(),
            Some(&("github:me/Blindfold".to_string(), vec!["blindfold".to_string()]))
        );
    }

    #[test]
    fn plain_ids_only_in_raw_urls() {
        assert!(is_plain_id("say-the-spire-2"));
        assert!(is_plain_id("lovely_injector.v2"));
        assert!(!is_plain_id(""));
        assert!(!is_plain_id("a/b"));
        assert!(!is_plain_id("..") );
        assert!(!is_plain_id("a..b"));
        assert_eq!(
            raw_package_url("me", "Repo", "blindfold"),
            "https://raw.githubusercontent.com/me/Repo/HEAD/loadstone-packages/blindfold.json"
        );
    }

    #[test]
    fn list_mods_dedups_innermost_first() {
        let tmp = tempfile::tempdir().unwrap();
        let inner = tmp.path().join("inner");
        let outer = tmp.path().join("outer");
        let moddoc = |name: &str| {
            serde_json::json!({ "manifestVersion": 1, "id": "blindfold", "name": name,
                                 "description": "d", "authors": ["a"], "game": "balatro",
                                 "install": [ { "step": "extract-archive",
                                                "routes": [ { "from": "**", "to": "${gameDir}" } ] } ] })
        };
        write(&inner, "blindfold.json", moddoc("Inner"));
        write(&outer, "blindfold.json", moddoc("Outer"));
        let mut fetcher = FakeFetcher::default();
        let mut resolver = Resolver::from_sources(
            &[
                inner.to_string_lossy().into_owned(),
                outer.to_string_lossy().into_owned(),
            ],
            &mut fetcher,
        )
        .unwrap();
        let mods = resolver.list_mods().unwrap();
        assert_eq!(mods.len(), 1);
        assert_eq!(mods[0].manifest.name, "Inner");
    }
}
