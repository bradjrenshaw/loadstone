//! Accounts: stored sign-ins used to reach sources that need credentials
//! (private repositories), and the rules for picking one per download.
//!
//! Accounts and rules are global preferences ([`crate::prefs`]); in a
//! standalone installer "global" is that installer's own scope. Account
//! metadata lives in the preferences file; tokens never do — they go
//! through a [`SecretStore`] (the OS credential store in the apps, an
//! in-memory map in tests).
//!
//! Which credentials a download tries, in order ([`candidates`]):
//! 1. A token from the environment (`LOADSTONE_GITHUB_TOKEN`, `GH_TOKEN`,
//!    `GITHUB_TOKEN` for GitHub) — explicit, nothing else is tried.
//! 2. The mod's own "download account" preference, if set — explicit.
//! 3. The most specific account rule matching the source
//!    (`github:owner/repo` beats `github:owner/*`).
//! 4. The provider's default account.
//! 5. No credentials.
//!
//! When 3–5 were chosen automatically and the request is refused (not
//! found / unauthorized), the provider's other accounts are tried next if
//! the `tryOtherAccounts` preference is on.

use std::sync::RwLock;

use anyhow::{bail, Context as _, Result};
use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::prefs::{PrefStore, Scope};

pub const PREF_ACCOUNTS: &str = "accounts";
pub const PREF_RULES: &str = "accountRules";
pub const PREF_TRY_OTHERS: &str = "tryOtherAccounts";
pub const PREF_MOD_ACCOUNT: &str = "downloadAccount";

/// One stored sign-in. The token itself is in the [`SecretStore`] under
/// [`Account::id`].
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Account {
    pub id: String,
    /// Source scheme it signs in to (`"github"`).
    pub provider: String,
    /// Host within that provider (`"github.com"`).
    pub host: String,
    /// User-chosen name ("Personal", "Testing").
    pub label: String,
    /// The identity the token belongs to, as reported by the provider.
    #[serde(default)]
    pub username: String,
    /// The provider's default account (at most one per provider).
    #[serde(default)]
    pub default: bool,
}

/// "Use this account for sources matching this pattern."
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountRule {
    /// A source (`github:owner/repo`) or an owner wildcard (`github:owner/*`).
    pub pattern: String,
    pub account: String,
}

/// Where tokens are kept.
pub trait SecretStore: Send + Sync {
    fn get(&self, account_id: &str) -> Option<String>;
    fn set(&self, account_id: &str, secret: &str) -> Result<()>;
    fn delete(&self, account_id: &str) -> Result<()>;
}

/// A token to present, and where it came from (for messages).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Credential {
    pub token: String,
    /// "GH_TOKEN", or the account's label.
    pub origin: String,
    /// Chosen explicitly (environment, per-mod preference): don't fall back
    /// to other accounts when it's refused.
    pub explicit: bool,
}

/// Preferences + secrets for the running app. Set once at startup by the
/// CLI/GUI; when unset, only environment tokens apply.
pub struct AuthContext {
    pub prefs: PrefStore,
    pub secrets: Box<dyn SecretStore>,
}

static CONTEXT: RwLock<Option<AuthContext>> = RwLock::new(None);

pub fn init(ctx: AuthContext) {
    *CONTEXT.write().unwrap_or_else(|e| e.into_inner()) = Some(ctx);
}

/// Run `f` with the current context, if any.
pub fn with_context<T>(f: impl FnOnce(Option<&AuthContext>) -> T) -> T {
    let guard = CONTEXT.read().unwrap_or_else(|e| e.into_inner());
    f(guard.as_ref())
}

fn env_names(provider: &str) -> &'static [&'static str] {
    match provider {
        "github" => &["LOADSTONE_GITHUB_TOKEN", "GH_TOKEN", "GITHUB_TOKEN"],
        _ => &[],
    }
}

fn env_token(provider: &str) -> Option<Credential> {
    env_names(provider).iter().find_map(|name| {
        std::env::var(name)
            .ok()
            .filter(|v| !v.trim().is_empty())
            .map(|token| Credential { token: token.trim().to_string(), origin: name.to_string(), explicit: true })
    })
}

// ── Account list and rules (global preferences) ──────────────────────

pub fn accounts(prefs: &PrefStore) -> Result<Vec<Account>> {
    let v = prefs.get(PREF_ACCOUNTS, None)?;
    Ok(serde_json::from_value(v).unwrap_or_default())
}

fn save_accounts(prefs: &PrefStore, list: &[Account]) -> Result<()> {
    prefs.set(&Scope::Global, PREF_ACCOUNTS, serde_json::to_value(list)?)
}

pub fn rules(prefs: &PrefStore) -> Result<Vec<AccountRule>> {
    let v = prefs.get(PREF_RULES, None)?;
    Ok(serde_json::from_value(v).unwrap_or_default())
}

fn save_rules(prefs: &PrefStore, list: &[AccountRule]) -> Result<()> {
    prefs.set(&Scope::Global, PREF_RULES, serde_json::to_value(list)?)
}

/// Store a new account and its token. The first account for a provider
/// becomes its default.
pub fn add_account(ctx: &AuthContext, mut account: Account, token: &str) -> Result<Account> {
    let mut list = accounts(&ctx.prefs)?;
    if list.iter().any(|a| a.id == account.id) {
        bail!("an account with id \"{}\" already exists", account.id);
    }
    account.default = !list.iter().any(|a| a.provider == account.provider);
    ctx.secrets.set(&account.id, token)?;
    list.push(account.clone());
    save_accounts(&ctx.prefs, &list)?;
    Ok(account)
}

/// Store a signed-in token for `provider`: looks up who it belongs to,
/// then either refreshes the existing account for that user or adds a new
/// one (labelled `label`, or the user name when empty).
pub fn save_signed_in(ctx: &AuthContext, provider: &str, label: &str, token: &str) -> Result<Account> {
    let p = crate::source::provider(provider)
        .with_context(|| format!("\"{provider}\" is not a known site"))?;
    let username = p.account_name(token)?;
    let existing = accounts(&ctx.prefs)?.into_iter().find(|a| {
        a.provider == provider && a.host == p.host() && a.username.eq_ignore_ascii_case(&username)
    });
    if let Some(account) = existing {
        ctx.secrets.set(&account.id, token)?;
        return Ok(account);
    }
    let taken: Vec<String> = accounts(&ctx.prefs)?.into_iter().map(|a| a.id).collect();
    let base = format!("{provider}-{}", username.to_ascii_lowercase());
    let id = std::iter::once(base.clone())
        .chain((2..).map(|n| format!("{base}-{n}")))
        .find(|id| !taken.contains(id))
        .expect("an unused id exists");
    let label = if label.trim().is_empty() { username.clone() } else { label.trim().to_string() };
    add_account(
        ctx,
        Account { id, provider: provider.to_string(), host: p.host().to_string(), label, username, default: false },
        token,
    )
}

/// Add an account from a token the user already has (a personal access
/// token, or `gh auth token`). The token is checked with the provider first.
pub fn add_token_account(ctx: &AuthContext, provider: &str, label: &str, token: &str) -> Result<Account> {
    let token = token.trim();
    if token.is_empty() {
        bail!("no token given");
    }
    save_signed_in(ctx, provider, label, token)
}

/// Run a full browser sign-in: start it, hand the challenge to
/// `show_challenge` (to display the code and open the page), then poll
/// until the user finishes, the code expires, or `cancelled()` returns
/// true. Blocking — run it on a worker thread.
pub fn sign_in(
    ctx: &AuthContext,
    provider: &str,
    label: &str,
    show_challenge: impl FnOnce(&crate::source::SignInChallenge),
    cancelled: impl Fn() -> bool,
) -> Result<Account> {
    use crate::source::SignInPoll;
    let p = crate::source::provider(provider)
        .with_context(|| format!("\"{provider}\" is not a known site"))?;
    let challenge = p.start_sign_in()?;
    show_challenge(&challenge);
    let deadline = std::time::Instant::now() + std::time::Duration::from_secs(challenge.expires_in_secs);
    let mut interval = challenge.interval_secs.max(1);
    loop {
        // Sleep in short steps so cancelling is prompt.
        let wake = std::time::Instant::now() + std::time::Duration::from_secs(interval);
        while std::time::Instant::now() < wake {
            if cancelled() {
                bail!("Sign-in cancelled.");
            }
            std::thread::sleep(std::time::Duration::from_millis(200));
        }
        if std::time::Instant::now() > deadline {
            bail!("The sign-in code expired before it was entered. Please start again.");
        }
        match p.poll_sign_in(&challenge)? {
            SignInPoll::Pending => {}
            SignInPoll::SlowDown(secs) => interval = secs.max(interval + 1),
            SignInPoll::Done(token) => return save_signed_in(ctx, provider, label, &token),
        }
    }
}

/// Set a mod's download account (`None` = automatic).
pub fn set_mod_account(ctx: &AuthContext, mod_id: &str, account_id: Option<&str>) -> Result<()> {
    let scope = Scope::Mod(mod_id.to_string());
    match account_id {
        Some(id) => {
            if !accounts(&ctx.prefs)?.iter().any(|a| a.id == id) {
                bail!("no account with id \"{id}\"");
            }
            ctx.prefs.set(&scope, PREF_MOD_ACCOUNT, Value::from(id))
        }
        None => ctx.prefs.unset(&scope, PREF_MOD_ACCOUNT),
    }
}

/// Forget an account: its token, any rules using it, and its default
/// status (the provider's next account becomes the default).
pub fn remove_account(ctx: &AuthContext, id: &str) -> Result<()> {
    let mut list = accounts(&ctx.prefs)?;
    let Some(pos) = list.iter().position(|a| a.id == id) else {
        bail!("no account with id \"{id}\"");
    };
    let removed = list.remove(pos);
    if removed.default {
        if let Some(next) = list.iter_mut().find(|a| a.provider == removed.provider) {
            next.default = true;
        }
    }
    ctx.secrets.delete(id)?;
    save_accounts(&ctx.prefs, &list)?;
    let kept: Vec<AccountRule> = rules(&ctx.prefs)?.into_iter().filter(|r| r.account != id).collect();
    save_rules(&ctx.prefs, &kept)
}

/// Make `id` its provider's default account.
pub fn set_default(ctx: &AuthContext, id: &str) -> Result<()> {
    let mut list = accounts(&ctx.prefs)?;
    let provider = list
        .iter()
        .find(|a| a.id == id)
        .map(|a| a.provider.clone())
        .with_context(|| format!("no account with id \"{id}\""))?;
    for a in list.iter_mut().filter(|a| a.provider == provider) {
        a.default = a.id == id;
    }
    save_accounts(&ctx.prefs, &list)
}

/// Add or replace the rule for `pattern`.
pub fn set_rule(ctx: &AuthContext, pattern: &str, account_id: &str) -> Result<()> {
    if !accounts(&ctx.prefs)?.iter().any(|a| a.id == account_id) {
        bail!("no account with id \"{account_id}\"");
    }
    if pattern_owner_and_repo(pattern).is_none() {
        bail!("\"{pattern}\" is not a source (github:owner/repo) or owner wildcard (github:owner/*)");
    }
    let mut list = rules(&ctx.prefs)?;
    list.retain(|r| r.pattern != pattern);
    list.push(AccountRule { pattern: pattern.to_string(), account: account_id.to_string() });
    save_rules(&ctx.prefs, &list)
}

pub fn remove_rule(ctx: &AuthContext, pattern: &str) -> Result<()> {
    let mut list = rules(&ctx.prefs)?;
    list.retain(|r| r.pattern != pattern);
    save_rules(&ctx.prefs, &list)
}

/// `github:owner/repo` → ("github:owner", Some("repo")), `github:owner/*`
/// → ("github:owner", None).
fn pattern_owner_and_repo(pattern: &str) -> Option<(&str, Option<&str>)> {
    let (owner, repo) = pattern.rsplit_once('/')?;
    if !owner.contains(':') || owner.ends_with(':') || repo.is_empty() {
        return None;
    }
    Some((owner, (repo != "*").then_some(repo)))
}

/// How specifically `pattern` matches `source`: 2 exact, 1 owner wildcard,
/// 0 no match. Comparison is case-insensitive (GitHub names are).
fn rule_specificity(pattern: &str, source: &str) -> u8 {
    let (Some((p_owner, p_repo)), Some((s_owner, Some(s_repo)))) =
        (pattern_owner_and_repo(pattern), pattern_owner_and_repo(source))
    else {
        return 0;
    };
    if !p_owner.eq_ignore_ascii_case(s_owner) {
        return 0;
    }
    match p_repo {
        Some(r) if r.eq_ignore_ascii_case(s_repo) => 2,
        Some(_) => 0,
        None => 1,
    }
}

// ── Choosing credentials for a download ──────────────────────────────

/// The credentials to try for `source` (scheme `provider`), in order.
/// `None` means "anonymous". Never empty.
pub fn candidates(provider: &str, source: &str, mod_id: Option<&str>) -> Vec<Option<Credential>> {
    if let Some(env) = env_token(provider) {
        return vec![Some(env)];
    }
    with_context(|ctx| match ctx {
        Some(ctx) => candidates_in(ctx, provider, source, mod_id).unwrap_or_else(|_| vec![None]),
        None => vec![None],
    })
}

/// [`candidates`] against an explicit context, ignoring the environment.
pub fn candidates_in(
    ctx: &AuthContext,
    provider: &str,
    source: &str,
    mod_id: Option<&str>,
) -> Result<Vec<Option<Credential>>> {
    let list: Vec<Account> = accounts(&ctx.prefs)?
        .into_iter()
        .filter(|a| a.provider == provider)
        .collect();
    let credential = |a: &Account, explicit: bool| {
        ctx.secrets
            .get(&a.id)
            .map(|token| Credential { token, origin: a.label.clone(), explicit })
    };

    // Per-mod choice: explicit, no fallback.
    if let Some(id) = mod_id {
        if let Value::String(chosen) = ctx.prefs.get(PREF_MOD_ACCOUNT, Some(id))? {
            if let Some(a) = list.iter().find(|a| a.id == chosen) {
                if let Some(c) = credential(a, true) {
                    return Ok(vec![Some(c)]);
                }
            }
        }
    }

    // Rule, then default, then anonymous.
    let rule_pick = rules(&ctx.prefs)?
        .into_iter()
        .map(|r| (rule_specificity(&r.pattern, source), r))
        .filter(|(s, _)| *s > 0)
        .max_by_key(|(s, _)| *s)
        .and_then(|(_, r)| list.iter().find(|a| a.id == r.account));
    let primary = rule_pick.or_else(|| list.iter().find(|a| a.default));

    let mut out = vec![primary.and_then(|a| credential(a, false))];
    let try_others = ctx.prefs.get(PREF_TRY_OTHERS, None)?.as_bool().unwrap_or(true);
    if try_others {
        for a in list.iter().filter(|a| Some(a.id.as_str()) != primary.map(|p| p.id.as_str())) {
            if let Some(c) = credential(a, false) {
                out.push(Some(c));
            }
        }
    }
    Ok(out)
}

/// Should a refusal with this credential move on to the next candidate?
pub fn retry_after(status: Option<u16>, used: &Option<Credential>) -> bool {
    matches!(status, Some(401 | 403 | 404)) && !used.as_ref().is_some_and(|c| c.explicit)
}

#[cfg(test)]
pub(crate) mod tests {
    use super::*;
    use std::collections::HashMap;
    use std::sync::Mutex;

    #[derive(Default)]
    pub struct MemorySecrets(pub Mutex<HashMap<String, String>>);

    impl SecretStore for MemorySecrets {
        fn get(&self, id: &str) -> Option<String> {
            self.0.lock().unwrap().get(id).cloned()
        }
        fn set(&self, id: &str, secret: &str) -> Result<()> {
            self.0.lock().unwrap().insert(id.to_string(), secret.to_string());
            Ok(())
        }
        fn delete(&self, id: &str) -> Result<()> {
            self.0.lock().unwrap().remove(id);
            Ok(())
        }
    }

    fn ctx() -> (tempfile::TempDir, AuthContext) {
        let tmp = tempfile::tempdir().unwrap();
        let prefs = PrefStore::with_definitions(tmp.path().to_path_buf(), crate::prefs::DEFINITIONS);
        (tmp, AuthContext { prefs, secrets: Box::new(MemorySecrets::default()) })
    }

    fn acct(id: &str) -> Account {
        Account {
            id: id.into(),
            provider: "github".into(),
            host: "github.com".into(),
            label: id.to_uppercase(),
            username: id.into(),
            default: false,
        }
    }

    fn tokens(c: &[Option<Credential>]) -> Vec<Option<String>> {
        c.iter().map(|c| c.as_ref().map(|c| c.token.clone())).collect()
    }

    const SRC: &str = "github:shaysters/Eliza-Access";

    #[test]
    fn anonymous_without_accounts() {
        let (_t, c) = ctx();
        assert_eq!(tokens(&candidates_in(&c, "github", SRC, None).unwrap()), vec![None]);
    }

    #[test]
    fn default_then_others() {
        let (_t, c) = ctx();
        add_account(&c, acct("a"), "ta").unwrap();
        add_account(&c, acct("b"), "tb").unwrap();
        assert_eq!(
            tokens(&candidates_in(&c, "github", SRC, None).unwrap()),
            vec![Some("ta".into()), Some("tb".into())]
        );
        set_default(&c, "b").unwrap();
        assert_eq!(
            tokens(&candidates_in(&c, "github", SRC, None).unwrap()),
            vec![Some("tb".into()), Some("ta".into())]
        );
        c.prefs.set(&Scope::Global, PREF_TRY_OTHERS, Value::from(false)).unwrap();
        assert_eq!(tokens(&candidates_in(&c, "github", SRC, None).unwrap()), vec![Some("tb".into())]);
    }

    #[test]
    fn rules_pick_most_specific() {
        let (_t, c) = ctx();
        add_account(&c, acct("a"), "ta").unwrap();
        add_account(&c, acct("b"), "tb").unwrap();
        add_account(&c, acct("x"), "tx").unwrap();
        set_rule(&c, "github:shaysters/*", "b").unwrap();
        assert_eq!(tokens(&candidates_in(&c, "github", SRC, None).unwrap())[0], Some("tb".into()));
        set_rule(&c, "github:Shaysters/eliza-access", "x").unwrap();
        assert_eq!(tokens(&candidates_in(&c, "github", SRC, None).unwrap())[0], Some("tx".into()));
        assert_eq!(
            tokens(&candidates_in(&c, "github", "github:someone/else", None).unwrap())[0],
            Some("ta".into())
        );
        assert!(set_rule(&c, "shaysters", "a").is_err());
        assert!(set_rule(&c, "github:shaysters/*", "missing").is_err());
    }

    #[test]
    fn per_mod_choice_is_explicit() {
        let (_t, c) = ctx();
        add_account(&c, acct("a"), "ta").unwrap();
        add_account(&c, acct("b"), "tb").unwrap();
        c.prefs
            .set(&Scope::Mod("eliza-access".into()), PREF_MOD_ACCOUNT, Value::from("b"))
            .unwrap();
        let got = candidates_in(&c, "github", SRC, Some("eliza-access")).unwrap();
        assert_eq!(tokens(&got), vec![Some("tb".into())]);
        assert!(got[0].as_ref().unwrap().explicit);
        // Other mods still use the default chain.
        assert_eq!(tokens(&candidates_in(&c, "github", SRC, Some("other")).unwrap())[0], Some("ta".into()));
    }

    #[test]
    fn removing_an_account_cleans_up() {
        let (_t, c) = ctx();
        add_account(&c, acct("a"), "ta").unwrap();
        add_account(&c, acct("b"), "tb").unwrap();
        set_rule(&c, "github:shaysters/*", "a").unwrap();
        remove_account(&c, "a").unwrap();
        let list = accounts(&c.prefs).unwrap();
        assert_eq!(list.len(), 1);
        assert!(list[0].default, "the remaining account becomes the default");
        assert!(rules(&c.prefs).unwrap().is_empty());
        assert_eq!(c.secrets.get("a"), None);
    }

    #[test]
    fn retry_rules() {
        let auto = Some(Credential { token: "t".into(), origin: "A".into(), explicit: false });
        let explicit = Some(Credential { token: "t".into(), origin: "GH_TOKEN".into(), explicit: true });
        assert!(retry_after(Some(404), &None));
        assert!(retry_after(Some(401), &auto));
        assert!(!retry_after(Some(404), &explicit));
        assert!(!retry_after(Some(500), &auto));
        assert!(!retry_after(None, &auto));
    }
}
