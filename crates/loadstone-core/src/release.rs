//! Building a `release.json` from a project manifest plus built artifacts.

use std::fs;
use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};
use sha2::{Digest, Sha256};

use crate::types::*;

pub struct ArtifactInput {
    pub path: PathBuf,
    pub when: Option<Condition>,
}

pub struct ReleaseOptions {
    /// Version as given (leading `v`/`V` tolerated); normalized before use.
    pub version: String,
    pub artifacts: Vec<ArtifactInput>,
    pub release_notes: Option<String>,
}

/// Assemble the release manifest: hash the artifacts and freeze the project
/// manifest's install-relevant blocks. Dev-only blocks (`packaging`,
/// `channels`, `sourceInstall`) are not carried over.
pub fn build_release_manifest(
    project: &ProjectManifest,
    options: &ReleaseOptions,
) -> Result<ReleaseManifest> {
    let version = normalize_version(&options.version)?;

    if options.artifacts.is_empty() {
        bail!("no artifacts: pass --artifact or add a \"packaging\" block to the manifest");
    }

    let mut artifacts = Vec::new();
    for input in &options.artifacts {
        let file_name = input
            .path
            .file_name()
            .and_then(|n| n.to_str())
            .with_context(|| format!("bad artifact path: {}", input.path.display()))?
            .to_string();
        let sha256 = sha256_file(&input.path)
            .with_context(|| format!("failed to hash {}", input.path.display()))?;
        artifacts.push(ReleaseArtifact { file: file_name, sha256, when: input.when.clone() });
    }

    Ok(ReleaseManifest {
        manifest_version: MANIFEST_VERSION,
        id: project.id.clone(),
        version,
        game: project.game.clone(),
        release_notes: options.release_notes.clone(),
        artifacts,
        dependencies: project.dependencies.clone(),
        distributions: project.distributions.clone(),
        install: project.install.clone(),
        uninstall: project.uninstall.clone(),
        cleanup_legacy: project.cleanup_legacy.clone(),
        user_data: project.user_data.clone(),
        settings: project.settings.clone(),
        actions: project.actions.clone(),
        conflict_policy: project.conflict_policy.clone(),
    })
}

/// Resolve the artifact list for `loadstone package`: explicit CLI paths win;
/// otherwise the manifest's `packaging.artifacts`, relative to the manifest dir.
pub fn resolve_artifacts(
    project: &ProjectManifest,
    manifest_dir: &Path,
    cli_paths: &[PathBuf],
) -> Vec<ArtifactInput> {
    if !cli_paths.is_empty() {
        return cli_paths
            .iter()
            .map(|p| ArtifactInput { path: p.clone(), when: None })
            .collect();
    }
    project
        .packaging
        .as_ref()
        .map(|p| {
            p.artifacts
                .iter()
                .map(|a| ArtifactInput {
                    path: manifest_dir.join(&a.file),
                    when: a.when.clone(),
                })
                .collect()
        })
        .unwrap_or_default()
}

pub fn normalize_version(version: &str) -> Result<String> {
    let trimmed = version.trim().trim_start_matches(['v', 'V']);
    let parsed = semver::Version::parse(trimmed)
        .with_context(|| format!("\"{version}\" is not a semver version"))?;
    Ok(parsed.to_string())
}

pub fn sha256_file(path: &Path) -> Result<String> {
    let data = fs::read(path)?;
    let mut hasher = Sha256::new();
    hasher.update(&data);
    let digest = hasher.finalize();
    let mut out = String::with_capacity(64);
    for byte in digest {
        out.push_str(&format!("{byte:02x}"));
    }
    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalize_strips_v_prefix() {
        assert_eq!(normalize_version("v0.4.2").unwrap(), "0.4.2");
        assert_eq!(normalize_version("1.0.0").unwrap(), "1.0.0");
        assert!(normalize_version("not-a-version").is_err());
    }

    #[test]
    fn sha256_of_known_content() {
        let dir = tempfile::tempdir().unwrap();
        let file = dir.path().join("a.txt");
        std::fs::write(&file, b"abc").unwrap();
        assert_eq!(
            sha256_file(&file).unwrap(),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        );
    }
}
