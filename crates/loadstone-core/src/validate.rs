//! Semantic validation of package files against SPEC.md.
//!
//! `validate_value` accepts any parsed JSON document, detects which package
//! form it is (project manifest, game package, release manifest, registry
//! entry), and returns diagnostics. Clients decide how to render them; the
//! output is designed to be screen-reader-friendly plain text.

use std::collections::{BTreeMap, BTreeSet};

use serde_json::Value;

use crate::tokens::{self, Token};
use crate::types::*;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Severity {
    Error,
    Warning,
}

#[derive(Debug, Clone)]
pub struct Diagnostic {
    pub severity: Severity,
    /// Where in the document, as a slash path like `install/2/routes/0/to`.
    pub location: String,
    pub message: String,
}

impl Diagnostic {
    fn error(location: impl Into<String>, message: impl Into<String>) -> Self {
        Self { severity: Severity::Error, location: location.into(), message: message.into() }
    }
    fn warning(location: impl Into<String>, message: impl Into<String>) -> Self {
        Self { severity: Severity::Warning, location: location.into(), message: message.into() }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PackageForm {
    Project,
    Game,
    Release,
    Link,
}

/// Extra context for cross-file checks: game packages visible from the
/// validated file's scope chain (its own `loadstone-packages/` directory
/// innermost, then outer registries), already flattened innermost-first.
#[derive(Default)]
pub struct ValidationContext {
    pub games: BTreeMap<String, GameManifest>,
}

pub struct ValidationResult {
    pub form: PackageForm,
    pub diagnostics: Vec<Diagnostic>,
}

impl ValidationResult {
    pub fn has_errors(&self) -> bool {
        self.diagnostics.iter().any(|d| d.severity == Severity::Error)
    }
}

/// Detect the package form of a JSON document.
pub fn detect_form(doc: &Value) -> PackageForm {
    let obj = match doc.as_object() {
        Some(o) => o,
        None => return PackageForm::Project,
    };
    match obj.get("kind").and_then(Value::as_str) {
        Some("game") => return PackageForm::Game,
        Some("link") => return PackageForm::Link,
        _ => {}
    }
    if obj.contains_key("artifacts") && obj.contains_key("version") {
        return PackageForm::Release;
    }
    PackageForm::Project
}

pub fn validate_value(doc: &Value, ctx: &ValidationContext) -> ValidationResult {
    let form = detect_form(doc);
    let mut diags = Vec::new();
    match form {
        PackageForm::Project => validate_project(doc, ctx, &mut diags),
        PackageForm::Game => validate_game_doc(doc, &mut diags),
        PackageForm::Release => validate_release(doc, ctx, &mut diags),
        PackageForm::Link => validate_link(doc, &mut diags),
    }
    ValidationResult { form, diagnostics: diags }
}

// ---------------------------------------------------------------------------
// Shared helpers

const PROJECT_KEYS: &[&str] = &[
    "manifestVersion", "kind", "id", "name", "description", "authors", "license",
    "game", "source", "pinnedRelease", "distributions", "dependencies", "channels", "install",
    "sourceInstall", "uninstall", "cleanupLegacy", "userData", "settings",
    "actions", "launch", "conflictPolicy", "packaging",
];

const GAME_KEYS: &[&str] =
    &["manifestVersion", "kind", "id", "name", "detect", "userData", "paths"];

const RELEASE_KEYS: &[&str] = &[
    "manifestVersion", "id", "version", "game", "releaseNotes",
    "artifacts", "dependencies", "distributions", "install", "uninstall", "cleanupLegacy",
    "userData", "settings", "actions", "launch", "conflictPolicy", "installer",
    "installers",
];

const LINK_KEYS: &[&str] = &["kind", "source", "packages"];

const KNOWN_DISTRIBUTIONS: &[&str] =
    &["steam", "epic", "gog", "gamepass", "itch", "standalone"];

fn warn_unknown_keys(doc: &Value, known: &[&str], diags: &mut Vec<Diagnostic>) {
    if let Some(obj) = doc.as_object() {
        for key in obj.keys() {
            if !known.contains(&key.as_str()) {
                diags.push(Diagnostic::warning(
                    key.clone(),
                    format!("unknown field \"{key}\" (clients ignore it; check for a typo)"),
                ));
            }
        }
    }
}

fn check_manifest_version(doc: &Value, required: bool, diags: &mut Vec<Diagnostic>) {
    match doc.get("manifestVersion").and_then(Value::as_u64) {
        Some(v) if v as u32 == MANIFEST_VERSION => {}
        Some(v) => diags.push(Diagnostic::error(
            "manifestVersion",
            format!("unsupported manifestVersion {v}; this tool understands {MANIFEST_VERSION}"),
        )),
        None if required => {
            diags.push(Diagnostic::error("manifestVersion", "missing required field"))
        }
        None => {}
    }
}

fn check_id(id: &str, location: &str, diags: &mut Vec<Diagnostic>) {
    let valid = !id.is_empty()
        && id.chars().all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
        && !id.starts_with('-')
        && !id.ends_with('-');
    if !valid {
        diags.push(Diagnostic::error(
            location,
            format!("\"{id}\" is not a valid id: use lowercase letters, digits, and hyphens"),
        ));
    }
}

/// Variable ids name `${var.<id>}` tokens, so they follow identifier rules
/// (letters and digits, starting with a letter), not package-id rules.
fn check_var_id(id: &str, location: &str, diags: &mut Vec<Diagnostic>) {
    let mut chars = id.chars();
    let valid = chars.next().is_some_and(|c| c.is_ascii_alphabetic())
        && chars.all(|c| c.is_ascii_alphanumeric() || c == '_');
    if !valid {
        diags.push(Diagnostic::error(
            location,
            format!("\"{id}\" is not a valid variable id: letters, digits, and underscores, starting with a letter"),
        ));
    }
}

/// Validate every `${...}` token in a path string.
struct TokenScope<'a> {
    /// Names allowed after `game.`; None means "unknown, skip that check".
    game_paths: Option<&'a BTreeSet<String>>,
    /// Ids bound by earlier pick-directory steps.
    vars: &'a BTreeSet<String>,
    /// Whether `${game.*}` / `${var.*}` are allowed at all.
    allow_namespaced: bool,
}

fn check_path(path: &str, location: &str, scope: &TokenScope, diags: &mut Vec<Diagnostic>) {
    let tokens = match tokens::extract(path) {
        Ok(t) => t,
        Err(msg) => {
            diags.push(Diagnostic::error(location, msg));
            return;
        }
    };
    for token in tokens {
        match token {
            Token::Builtin(_) => {}
            Token::GamePath(name) => {
                if !scope.allow_namespaced {
                    diags.push(Diagnostic::error(
                        location,
                        format!("${{game.{name}}} is not allowed here"),
                    ));
                } else if let Some(known) = scope.game_paths {
                    if !known.contains(&name) {
                        diags.push(Diagnostic::error(
                            location,
                            format!(
                                "${{game.{name}}} is not defined by the game package (defined: {})",
                                if known.is_empty() {
                                    "none".to_string()
                                } else {
                                    known.iter().cloned().collect::<Vec<_>>().join(", ")
                                }
                            ),
                        ));
                    }
                }
            }
            Token::Var(id) => {
                if !scope.allow_namespaced {
                    diags.push(Diagnostic::error(
                        location,
                        format!("${{var.{id}}} is not allowed here"),
                    ));
                } else if !scope.vars.contains(&id) {
                    diags.push(Diagnostic::error(
                        location,
                        format!(
                            "${{var.{id}}} is not bound by an earlier pick-directory step in this step list"
                        ),
                    ));
                }
            }
            Token::Unknown(name) => diags.push(Diagnostic::error(
                location,
                format!("unknown token ${{{name}}}"),
            )),
        }
    }
}

// ---------------------------------------------------------------------------
// Project manifests

fn validate_project(doc: &Value, ctx: &ValidationContext, diags: &mut Vec<Diagnostic>) {
    check_manifest_version(doc, true, diags);
    warn_unknown_keys(doc, PROJECT_KEYS, diags);

    let manifest: ProjectManifest = match serde_json::from_value(doc.clone()) {
        Ok(m) => m,
        Err(e) => {
            diags.push(Diagnostic::error("", format!("does not parse as a project manifest: {e}")));
            return;
        }
    };

    check_id(&manifest.id, "id", diags);
    if manifest.name.trim().is_empty() {
        diags.push(Diagnostic::error("name", "must not be empty"));
    }
    if manifest.authors.is_empty() {
        diags.push(Diagnostic::warning("authors", "no authors listed"));
    }
    if manifest.description.as_deref().unwrap_or("").trim().is_empty() {
        diags.push(Diagnostic::warning("description", "missing description"));
    }

    // Resolve the game package for ${game.*} checks from the scope chain.
    let game_paths: Option<BTreeSet<String>> = match manifest.kind {
        Kind::Mod => {
            if manifest.game.is_none() {
                diags.push(Diagnostic::error("game", "mods must reference a game (\"game\")"));
            }
            match manifest.game.as_ref().and_then(|id| ctx.games.get(id)) {
                Some(g) => Some(game_path_names(g)),
                None => {
                    diags.push(Diagnostic::warning(
                        "game",
                        format!(
                            "game package \"{}\" not available in scope; ${{game.*}} tokens are not checked (put it in the same loadstone-packages directory or pass --scope)",
                            manifest.game.as_deref().unwrap_or("?")
                        ),
                    ));
                    None
                }
            }
        }
        _ => Some(BTreeSet::new()),
    };

    if let Some(source) = &manifest.source {
        check_source(source, "source", diags);
    }

    if let Some(pinned) = &manifest.pinned_release {
        validate_pinned_release(pinned, diags);
        if !manifest.channels.is_empty() {
            diags.push(Diagnostic::error(
                "pinnedRelease",
                "pinnedRelease and channels are mutually exclusive (SPEC §13.1)",
            ));
        }
    }

    if manifest.kind == Kind::Mod && manifest.install.is_empty() {
        diags.push(Diagnostic::error("install", "mods must declare install steps"));
    }

    // Channels.
    for (name, channel) in &manifest.channels {
        let loc = format!("channels/{name}");
        match channel.source {
            ChannelSource::Branch => {
                if channel.branch.is_none() {
                    diags.push(Diagnostic::error(&loc, "branch channels must name a \"branch\""));
                }
                if manifest.source_install.is_empty() {
                    diags.push(Diagnostic::error(
                        &loc,
                        "branch channels install from the source tree, which requires \"sourceInstall\" steps",
                    ));
                }
                if channel.tag.is_some() {
                    diags.push(Diagnostic::warning(&loc, "\"tag\" is ignored for branch channels"));
                }
            }
            ChannelSource::Release => {
                if channel.branch.is_some() {
                    diags.push(Diagnostic::warning(&loc, "\"branch\" is ignored for release channels"));
                }
            }
        }
    }
    if !manifest.source_install.is_empty()
        && !manifest.channels.values().any(|c| c.source == ChannelSource::Branch)
    {
        diags.push(Diagnostic::warning(
            "sourceInstall",
            "sourceInstall is declared but no branch channel uses it (it still serves linked dev checkouts)",
        ));
    }

    // Dependencies.
    for (i, dep) in manifest.dependencies.iter().enumerate() {
        let loc = format!("dependencies/{i}");
        check_id(&dep.id, &loc, diags);
        if let Some(req) = &dep.version {
            if semver::VersionReq::parse(req).is_err() {
                diags.push(Diagnostic::error(
                    format!("{loc}/version"),
                    format!("\"{req}\" is not a valid semver range"),
                ));
            }
        }
    }

    // Distributions.
    for distribution in manifest.distributions.keys() {
        if !KNOWN_DISTRIBUTIONS.contains(&distribution.as_str()) {
            diags.push(Diagnostic::warning(
                format!("distributions/{distribution}"),
                format!(
                    "\"{distribution}\" is not a known distribution ({})",
                    KNOWN_DISTRIBUTIONS.join(", ")
                ),
            ));
        }
    }

    // Step lists.
    let game_paths_ref = game_paths.as_ref();
    validate_steps(&manifest.install, "install", game_paths_ref, diags);
    validate_steps(&manifest.source_install, "sourceInstall", game_paths_ref, diags);
    validate_steps(&manifest.uninstall, "uninstall", game_paths_ref, diags);
    validate_launch(&manifest.launch, "launch", game_paths_ref, diags);
    // A step can only name an artifact the release actually lists; a
    // project manifest knows its artifacts only when the release is pinned.
    if let Some(pinned) = &manifest.pinned_release {
        check_artifact_refs(&manifest.install, "install", &pinned.artifacts, diags);
    }

    // Plain path lists.
    let scope = TokenScope {
        game_paths: game_paths_ref,
        vars: &BTreeSet::new(),
        allow_namespaced: true,
    };
    for (i, p) in manifest.cleanup_legacy.iter().enumerate() {
        check_path(p, &format!("cleanupLegacy/{i}"), &scope, diags);
    }
    for (i, p) in manifest.user_data.iter().enumerate() {
        check_path(p, &format!("userData/{i}"), &scope, diags);
    }

    // Settings.
    if let Some(settings) = &manifest.settings {
        validate_settings(settings, game_paths_ref, diags);
    }

    // Actions.
    let mut action_ids = BTreeSet::new();
    for (i, action) in manifest.actions.iter().enumerate() {
        let loc = format!("actions/{i}");
        check_id(&action.id, &format!("{loc}/id"), diags);
        if !action_ids.insert(action.id.clone()) {
            diags.push(Diagnostic::error(&loc, format!("duplicate action id \"{}\"", action.id)));
        }
        if action.label.trim().is_empty() {
            diags.push(Diagnostic::error(format!("{loc}/label"), "must not be empty"));
        }
        if action.steps.is_empty() {
            diags.push(Diagnostic::error(format!("{loc}/steps"), "actions must have steps"));
        }
        if let Some(cond) = &action.enabled_when {
            validate_condition(cond, &format!("{loc}/enabledWhen"), game_paths_ref, diags);
        }
        validate_steps(&action.steps, &format!("{loc}/steps"), game_paths_ref, diags);
    }

    if manifest.conflict_policy.is_some() && manifest.kind != Kind::Tool {
        diags.push(Diagnostic::warning(
            "conflictPolicy",
            "conflictPolicy only applies to tool packages",
        ));
    }

    // Packaging (dev-only).
    if let Some(packaging) = &manifest.packaging {
        for (i, artifact) in packaging.artifacts.iter().enumerate() {
            if artifact.file.trim().is_empty() {
                diags.push(Diagnostic::error(
                    format!("packaging/artifacts/{i}/file"),
                    "must not be empty",
                ));
            }
        }
    }
}

fn game_path_names(game: &GameManifest) -> BTreeSet<String> {
    game.paths.keys().cloned().collect()
}

fn validate_steps(
    steps: &[Step],
    location: &str,
    game_paths: Option<&BTreeSet<String>>,
    diags: &mut Vec<Diagnostic>,
) {
    // pick-directory bindings become visible to later steps only.
    let mut vars: BTreeSet<String> = BTreeSet::new();

    for (i, step) in steps.iter().enumerate() {
        let loc = format!("{location}/{i}");
        let scope = TokenScope { game_paths, vars: &vars, allow_namespaced: true };

        if let Some(cond) = &step.common().when {
            validate_condition(cond, &format!("{loc}/when"), game_paths, diags);
        }
        if let Some(req) = &step.common().requires {
            validate_condition_in(&req.condition, &format!("{loc}/requires"), &scope, diags);
            if req.retryable && req.on_missing.is_none() {
                diags.push(Diagnostic::warning(
                    format!("{loc}/requires"),
                    "retryable preconditions should include an \"onMissing\" message for the user",
                ));
            }
        }

        match step {
            Step::Notice { message, .. } => {
                if message.trim().is_empty() {
                    diags.push(Diagnostic::error(format!("{loc}/message"), "must not be empty"));
                } else {
                    check_path(message, &format!("{loc}/message"), &scope, diags);
                }
            }
            Step::MergeUniversalBinary { inputs, output, .. } => {
                if inputs.len() < 2 {
                    diags.push(Diagnostic::error(
                        format!("{loc}/inputs"),
                        "a universal binary needs at least two inputs",
                    ));
                }
                for (n, input) in inputs.iter().enumerate() {
                    check_path(input, &format!("{loc}/inputs/{n}"), &scope, diags);
                }
                check_path(output, &format!("{loc}/output"), &scope, diags);
                if step.common().when.as_ref().and_then(|w| w.platform.as_ref()).is_none() {
                    diags.push(Diagnostic::warning(
                        &loc,
                        "merge-universal-binary is a macOS concept; scope it with \"when\": {\"platform\": \"macos\"}",
                    ));
                }
            }
            Step::Run { program, args, cwd, env, .. } => {
                check_path(program, &format!("{loc}/program"), &scope, diags);
                for (n, a) in args.iter().enumerate() {
                    check_path(a, &format!("{loc}/args/{n}"), &scope, diags);
                }
                if let Some(c) = cwd {
                    check_path(c, &format!("{loc}/cwd"), &scope, diags);
                }
                for (k, v) in env {
                    if k.trim().is_empty() || k.contains('=') {
                        diags.push(Diagnostic::error(format!("{loc}/env"), format!("bad variable name \"{k}\"")));
                    }
                    check_path(v, &format!("{loc}/env/{k}"), &scope, diags);
                }
            }
            Step::OpenUrl { url, .. } => {
                if !crate::engine::is_launcher_url(url) {
                    diags.push(Diagnostic::error(
                        format!("{loc}/url"),
                        format!(
                            "open-url only accepts store launcher URLs ({})",
                            crate::engine::LAUNCH_URL_SCHEMES.join(", ")
                        ),
                    ));
                }
                check_path(url, &format!("{loc}/url"), &scope, diags);
            }
            Step::ExtractArchive { routes, .. } => {
                if routes.is_empty() {
                    diags.push(Diagnostic::error(format!("{loc}/routes"), "must not be empty"));
                }
                for (r, route) in routes.iter().enumerate() {
                    let rloc = format!("{loc}/routes/{r}");
                    if route.from.trim().is_empty() {
                        diags.push(Diagnostic::error(format!("{rloc}/from"), "must not be empty"));
                    }
                    if let Ok(tokens) = tokens::extract(&route.from) {
                        if !tokens.is_empty() {
                            diags.push(Diagnostic::error(
                                format!("{rloc}/from"),
                                "\"from\" matches archive entries and cannot contain tokens",
                            ));
                        }
                    }
                    check_path(&route.to, &format!("{rloc}/to"), &scope, diags);
                    if let Some(cond) = &route.when {
                        validate_condition(cond, &format!("{rloc}/when"), game_paths, diags);
                    }
                }
            }
            Step::CopyFiles { from, to, .. } => {
                check_path(from, &format!("{loc}/from"), &scope, diags);
                check_path(to, &format!("{loc}/to"), &scope, diags);
            }
            Step::EnsureDirs { paths, .. } | Step::DeleteFiles { paths, .. } => {
                if paths.is_empty() {
                    diags.push(Diagnostic::error(format!("{loc}/paths"), "must not be empty"));
                }
                for (p, path) in paths.iter().enumerate() {
                    check_path(path, &format!("{loc}/paths/{p}"), &scope, diags);
                }
            }
            Step::EditJson { file, ops, .. } => {
                check_path(file, &format!("{loc}/file"), &scope, diags);
                if ops.is_empty() {
                    diags.push(Diagnostic::error(format!("{loc}/ops"), "must not be empty"));
                }
                for (o, op) in ops.iter().enumerate() {
                    let oloc = format!("{loc}/ops/{o}");
                    if op.path.trim().is_empty() {
                        diags.push(Diagnostic::error(format!("{oloc}/path"), "must not be empty"));
                    }
                    let needs_value = !matches!(op.op, JsonOpKind::RemoveKey);
                    if needs_value && op.value.is_none() {
                        diags.push(Diagnostic::error(
                            &oloc,
                            format!("op \"{:?}\" requires a \"value\"", op.op),
                        ));
                    }
                }
            }
            Step::PickDirectory { id, prompt, .. } => {
                check_var_id(id, &format!("{loc}/id"), diags);
                if prompt.trim().is_empty() {
                    diags.push(Diagnostic::error(format!("{loc}/prompt"), "must not be empty"));
                }
                vars.insert(id.clone());
            }
            Step::Expect { checks, .. } => {
                if checks.is_empty() {
                    diags.push(Diagnostic::error(format!("{loc}/checks"), "must not be empty"));
                }
                for (c, check) in checks.iter().enumerate() {
                    let cloc = format!("{loc}/checks/{c}");
                    validate_condition_in(&check.condition, &cloc, &scope, diags);
                    if check.message.trim().is_empty() {
                        diags.push(Diagnostic::error(
                            format!("{cloc}/message"),
                            "expect checks must carry a user-facing message",
                        ));
                    }
                }
            }
        }
    }
}

fn validate_condition(
    cond: &Condition,
    location: &str,
    game_paths: Option<&BTreeSet<String>>,
    diags: &mut Vec<Diagnostic>,
) {
    let scope = TokenScope { game_paths, vars: &BTreeSet::new(), allow_namespaced: true };
    validate_condition_in(cond, location, &scope, diags);
}

/// `validate_condition` with an explicit token scope: a step's `requires`
/// may use `${var.*}` bound by earlier pick-directory steps.
fn validate_condition_in(
    cond: &Condition,
    location: &str,
    scope: &TokenScope,
    diags: &mut Vec<Diagnostic>,
) {
    if cond.distribution.is_none()
        && cond.platform.is_none()
        && cond.arch.is_none()
        && cond.file_exists.is_none()
        && cond.process_running.is_none()
        && cond.steam_launch_options.is_none()
        && cond.not.is_none()
    {
        diags.push(Diagnostic::warning(location, "empty condition always matches"));
    }
    if let Some(distributions) = &cond.distribution {
        for d in distributions.iter() {
            if !KNOWN_DISTRIBUTIONS.contains(&d) {
                diags.push(Diagnostic::warning(
                    location,
                    format!("\"{d}\" is not a known distribution"),
                ));
            }
        }
    }
    if let Some(platforms) = &cond.platform {
        for p in platforms.iter() {
            if !["windows", "macos", "linux"].contains(&p) {
                diags.push(Diagnostic::error(
                    location,
                    format!("\"{p}\" is not a platform (windows, macos, linux)"),
                ));
            }
        }
    }
    if let Some(arches) = &cond.arch {
        for a in arches.iter() {
            if !["x64", "arm64"].contains(&a) {
                diags.push(Diagnostic::error(
                    location,
                    format!("\"{a}\" is not an architecture (x64, arm64)"),
                ));
            }
        }
    }
    if let Some(path) = &cond.file_exists {
        check_path(path, &format!("{location}/fileExists"), scope, diags);
    }
    if let Some(names) = &cond.process_running {
        if names.iter().next().is_none() || names.iter().any(|n| n.trim().is_empty()) {
            diags.push(Diagnostic::error(
                format!("{location}/processRunning"),
                "needs one or more non-empty process names",
            ));
        }
    }
    if let Some(text) = &cond.steam_launch_options {
        if text.trim().is_empty() {
            diags.push(Diagnostic::error(
                format!("{location}/steamLaunchOptions"),
                "must not be empty",
            ));
        }
    }
    if let Some(inner) = &cond.not {
        validate_condition_in(inner, &format!("{location}/not"), scope, diags);
    }
}

fn validate_settings(
    settings: &Settings,
    game_paths: Option<&BTreeSet<String>>,
    diags: &mut Vec<Diagnostic>,
) {
    let scope = TokenScope { game_paths, vars: &BTreeSet::new(), allow_namespaced: true };
    check_path(&settings.storage.file, "settings/storage/file", &scope, diags);
    if let Some(format) = &settings.storage.format {
        if format != "json" {
            diags.push(Diagnostic::error(
                "settings/storage/format",
                format!("\"{format}\" is not supported in manifestVersion 1 (only \"json\")"),
            ));
        }
    }
    if settings.entries.is_empty() {
        diags.push(Diagnostic::warning("settings/entries", "settings declared but no entries"));
    }
    let mut ids = BTreeSet::new();
    for (i, entry) in settings.entries.iter().enumerate() {
        let loc = format!("settings/entries/{i}");
        if entry.id.trim().is_empty() {
            diags.push(Diagnostic::error(format!("{loc}/id"), "must not be empty"));
        }
        if !ids.insert(entry.id.clone()) {
            diags.push(Diagnostic::error(&loc, format!("duplicate setting id \"{}\"", entry.id)));
        }
        if entry.label.trim().is_empty() {
            diags.push(Diagnostic::error(format!("{loc}/label"), "must not be empty"));
        }
        match entry.entry_type {
            SettingType::Boolean => {
                if let Some(d) = &entry.default {
                    if !d.is_boolean() {
                        diags.push(Diagnostic::error(
                            format!("{loc}/default"),
                            "default for a boolean setting must be true or false",
                        ));
                    }
                }
            }
            SettingType::Number => {
                if let Some(d) = &entry.default {
                    if !d.is_number() {
                        diags.push(Diagnostic::error(
                            format!("{loc}/default"),
                            "default for a number setting must be a number",
                        ));
                    }
                }
            }
            SettingType::String => {
                if let Some(d) = &entry.default {
                    if !d.is_string() {
                        diags.push(Diagnostic::error(
                            format!("{loc}/default"),
                            "default for a string setting must be a string",
                        ));
                    }
                }
            }
            SettingType::Choice => {
                if entry.options.is_empty() {
                    diags.push(Diagnostic::error(
                        format!("{loc}/options"),
                        "choice settings must list options",
                    ));
                } else if let Some(d) = &entry.default {
                    if !entry.options.iter().any(|o| &o.value == d) {
                        diags.push(Diagnostic::error(
                            format!("{loc}/default"),
                            "default must be one of the declared option values",
                        ));
                    }
                }
            }
        }
        if entry.default.is_none() {
            diags.push(Diagnostic::warning(format!("{loc}/default"), "no default declared"));
        }
    }
}

fn validate_artifacts(
    artifacts: &[ReleaseArtifact],
    location: &str,
    diags: &mut Vec<Diagnostic>,
) {
    if artifacts.is_empty() {
        diags.push(Diagnostic::error(location, "must list at least one artifact"));
    }
    let mut ids: BTreeSet<String> = BTreeSet::new();
    for (i, artifact) in artifacts.iter().enumerate() {
        let loc = format!("{location}/{i}");
        if artifact.file.trim().is_empty() {
            diags.push(Diagnostic::error(format!("{loc}/file"), "must not be empty"));
        }
        let hash_ok = artifact.sha256.len() == 64
            && artifact.sha256.chars().all(|c| c.is_ascii_hexdigit());
        if !hash_ok {
            diags.push(Diagnostic::error(
                format!("{loc}/sha256"),
                "must be a 64-character hex SHA-256",
            ));
        }
        if let Some(cond) = &artifact.when {
            validate_condition(cond, &format!("{loc}/when"), None, diags);
        }
        if let Some(id) = &artifact.id {
            check_id(id, &format!("{loc}/id"), diags);
            if !ids.insert(id.clone()) {
                diags.push(Diagnostic::error(format!("{loc}/id"), format!("duplicate artifact id \"{id}\"")));
            }
        }
    }
}

fn validate_pinned_release(pinned: &PinnedRelease, diags: &mut Vec<Diagnostic>) {
    if let Err(e) = semver::Version::parse(pinned.version.trim_start_matches(['v', 'V'])) {
        diags.push(Diagnostic::error(
            "pinnedRelease/version",
            format!("\"{}\" is not a semver version: {e}", pinned.version),
        ));
    }
    validate_artifacts(&pinned.artifacts, "pinnedRelease/artifacts", diags);
}

// ---------------------------------------------------------------------------
// Game packages

fn validate_game_doc(doc: &Value, diags: &mut Vec<Diagnostic>) {
    check_manifest_version(doc, true, diags);
    warn_unknown_keys(doc, GAME_KEYS, diags);
    let game: GameManifest = match serde_json::from_value(doc.clone()) {
        Ok(g) => g,
        Err(e) => {
            diags.push(Diagnostic::error("", format!("does not parse as a game package: {e}")));
            return;
        }
    };
    validate_game(&game, "", true, diags);
}

fn validate_game(game: &GameManifest, prefix: &str, _standalone: bool, diags: &mut Vec<Diagnostic>) {
    let at = |field: &str| {
        if prefix.is_empty() { field.to_string() } else { format!("{prefix}/{field}") }
    };
    check_id(&game.id, &at("id"), diags);
    if game.name.trim().is_empty() {
        diags.push(Diagnostic::error(at("name"), "must not be empty"));
    }
    if game.detect.markers.is_empty() {
        diags.push(Diagnostic::warning(
            at("detect/markers"),
            "no validation markers: hand-picked game folders cannot be sanity-checked",
        ));
    }
    for distribution in game.detect.distributions.keys() {
        if !KNOWN_DISTRIBUTIONS.contains(&distribution.as_str()) {
            diags.push(Diagnostic::warning(
                at(&format!("detect/{distribution}")),
                format!("\"{distribution}\" is not a known distribution"),
            ));
        }
    }
    if game.user_data.is_empty() {
        diags.push(Diagnostic::warning(
            at("userData"),
            "no userData paths declared; ${userData} will not resolve for this game",
        ));
    }
    for (platform, path) in &game.user_data {
        if !["windows", "macos", "linux"].contains(&platform.as_str()) {
            diags.push(Diagnostic::error(
                at(&format!("userData/{platform}")),
                format!("\"{platform}\" is not a platform (windows, macos, linux)"),
            ));
        }
        // userData may use OS tokens but not game paths (it *defines* the game's data root).
        let scope = TokenScope { game_paths: None, vars: &BTreeSet::new(), allow_namespaced: false };
        check_path(path, &at(&format!("userData/{platform}")), &scope, diags);
    }
    // Named paths may reference builtins and each other's names via ${game.*}.
    let names = game_path_names(game);
    for (name, path) in &game.paths {
        let scope = TokenScope {
            game_paths: Some(&names),
            vars: &BTreeSet::new(),
            allow_namespaced: true,
        };
        check_path(path, &at(&format!("paths/{name}")), &scope, diags);
        if crate::tokens::BUILTIN_TOKENS.contains(&name.as_str()) {
            diags.push(Diagnostic::error(
                at(&format!("paths/{name}")),
                format!("path name \"{name}\" shadows a builtin token"),
            ));
        }
    }
}

// ---------------------------------------------------------------------------
// Release manifests

fn validate_release(doc: &Value, ctx: &ValidationContext, diags: &mut Vec<Diagnostic>) {
    check_manifest_version(doc, true, diags);
    warn_unknown_keys(doc, RELEASE_KEYS, diags);

    let release: ReleaseManifest = match serde_json::from_value(doc.clone()) {
        Ok(r) => r,
        Err(e) => {
            diags.push(Diagnostic::error("", format!("does not parse as a release manifest: {e}")));
            return;
        }
    };

    check_id(&release.id, "id", diags);
    if let Err(e) = semver::Version::parse(release.version.trim_start_matches(['v', 'V'])) {
        diags.push(Diagnostic::error(
            "version",
            format!("\"{}\" is not a semver version: {e}", release.version),
        ));
    }
    validate_artifacts(&release.artifacts, "artifacts", diags);
    let mut seen_platforms = BTreeSet::new();
    for (i, info) in release.installers.iter().enumerate() {
        let loc = format!("installers/{i}");
        match info.platform.as_deref() {
            Some(p @ ("windows" | "macos")) => {
                if !seen_platforms.insert(p) {
                    diags.push(Diagnostic::error(&loc, format!("a second {p} installer")));
                }
            }
            Some(p) => diags.push(Diagnostic::error(
                format!("{loc}/platform"),
                format!("\"{p}\" is not an installer platform (windows, macos)"),
            )),
            None => diags.push(Diagnostic::error(
                format!("{loc}/platform"),
                "installers entries must name their platform",
            )),
        }
    }

    let game_paths: Option<BTreeSet<String>> = release
        .game
        .as_ref()
        .and_then(|id| ctx.games.get(id))
        .map(game_path_names);
    if game_paths.is_none() && release.game.is_some() {
        diags.push(Diagnostic::warning(
            "game",
            "game package not available in scope; ${game.*} tokens are not checked",
        ));
    }
    let game_paths_ref = game_paths.as_ref();

    if release.install.is_empty() {
        diags.push(Diagnostic::warning("install", "release has no install steps"));
    }
    validate_steps(&release.install, "install", game_paths_ref, diags);
    validate_steps(&release.uninstall, "uninstall", game_paths_ref, diags);
    if let Some(settings) = &release.settings {
        validate_settings(settings, game_paths_ref, diags);
    }
    for (i, action) in release.actions.iter().enumerate() {
        validate_steps(&action.steps, &format!("actions/{i}/steps"), game_paths_ref, diags);
    }
    validate_launch(&release.launch, "launch", game_paths_ref, diags);
    check_artifact_refs(&release.install, "install", &release.artifacts, diags);
}

/// Launch lists start the game; they must not carry install-type steps.
fn validate_launch(
    steps: &[Step],
    location: &str,
    game_paths: Option<&BTreeSet<String>>,
    diags: &mut Vec<Diagnostic>,
) {
    validate_steps(steps, location, game_paths, diags);
    for (i, step) in steps.iter().enumerate() {
        if !matches!(
            step,
            Step::Run { .. } | Step::OpenUrl { .. } | Step::Notice { .. } | Step::Expect { .. }
        ) {
            diags.push(Diagnostic::error(
                format!("{location}/{i}"),
                format!(
                    "\"{}\" is not a launch step (use run, open-url, notice, or expect)",
                    step.name()
                ),
            ));
        }
    }
    let starts_something = steps.iter().any(|s| matches!(s, Step::Run { .. } | Step::OpenUrl { .. }));
    if !steps.is_empty() && !starts_something {
        diags.push(Diagnostic::error(location, "launch must contain a run or open-url step"));
    }
}

/// `extract-archive` steps may only name artifacts the release lists.
fn check_artifact_refs(
    steps: &[Step],
    location: &str,
    artifacts: &[ReleaseArtifact],
    diags: &mut Vec<Diagnostic>,
) {
    let ids: BTreeSet<&str> = artifacts.iter().filter_map(|a| a.id.as_deref()).collect();
    for (i, step) in steps.iter().enumerate() {
        if let Step::ExtractArchive { artifact: Some(id), .. } = step {
            if !ids.contains(id.as_str()) {
                diags.push(Diagnostic::error(
                    format!("{location}/{i}/artifact"),
                    format!("no artifact has id \"{id}\""),
                ));
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Link files

fn check_source(source: &str, location: &str, diags: &mut Vec<Diagnostic>) {
    if !crate::source::is_valid(source) {
        diags.push(Diagnostic::error(
            location,
            format!(
                "\"{source}\" is not a valid source (expected {})",
                crate::source::formats()
            ),
        ));
    }
}

fn validate_link(doc: &Value, diags: &mut Vec<Diagnostic>) {
    warn_unknown_keys(doc, LINK_KEYS, diags);
    let link: LinkEntry = match serde_json::from_value(doc.clone()) {
        Ok(l) => l,
        Err(e) => {
            diags.push(Diagnostic::error("", format!("does not parse as a link file: {e}")));
            return;
        }
    };
    check_source(&link.source, "source", diags);
    for (i, id) in link.packages.iter().enumerate() {
        check_id(id, &format!("packages/{i}"), diags);
    }
}
