//! Bridge functions for accounts and Loadstone's own settings.
//!
//! Every function takes the embedded profile: it selects the preference
//! scope (the manager, or a standalone installer's own) and makes sure the
//! account context is installed, so downloads anywhere in the GUI use the
//! stored accounts.

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Once;

use anyhow::{bail, Context as _, Result};
use serde_json::Value;

use loadstone_core::auth;
use loadstone_core::prefs::{PrefStore, PrefType, Scope};
use loadstone_core::profile::Profile;
use loadstone_core::source::{self, SignInChallenge, SignInPoll};

use crate::ffi::{AccountItem, ChoiceItem, RuleItem, SettingItem, SignInStart, SignInStatus};

static AUTH_INIT: Once = Once::new();
static NEEDS_SIGN_IN: AtomicBool = AtomicBool::new(false);

/// Install the account context for this executable's profile, once. Every
/// bridge entry point that loads the profile calls this (via
/// `crate::load_profile`), so the first call of any kind sets it up.
pub(crate) fn ensure_auth(profile: &Profile) {
    AUTH_INIT.call_once(|| {
        let _ = loadstone_core::secrets::init_for_profile(profile);
    });
}

/// Record whether a failing network call could be fixed by signing in.
pub(crate) fn track<T>(result: Result<T>) -> Result<T> {
    NEEDS_SIGN_IN.store(
        matches!(&result, Err(e) if source::is_maybe_private(e)),
        Ordering::SeqCst,
    );
    result
}

pub fn last_error_needs_sign_in() -> bool {
    NEEDS_SIGN_IN.load(Ordering::SeqCst)
}

fn with_ctx<T>(embedded: &str, f: impl FnOnce(&auth::AuthContext) -> Result<T>) -> Result<T> {
    crate::load_profile(embedded)?;
    auth::with_context(|ctx| f(ctx.context("account storage is unavailable")?))
}

pub fn account_list(embedded: &str) -> Result<Vec<AccountItem>> {
    with_ctx(embedded, |ctx| {
        Ok(auth::accounts(&ctx.prefs)?
            .into_iter()
            .map(|a| AccountItem {
                has_token: ctx.secrets.get(&a.id).is_some(),
                provider_name: source::provider(&a.provider)
                    .map(|p| p.display_name().to_string())
                    .unwrap_or_else(|| a.provider.clone()),
                id: a.id,
                label: a.label,
                username: a.username,
                host: a.host,
                provider: a.provider,
                is_default: a.default,
            })
            .collect())
    })
}

pub fn account_rules(embedded: &str) -> Result<Vec<RuleItem>> {
    with_ctx(embedded, |ctx| {
        let accounts = auth::accounts(&ctx.prefs)?;
        Ok(auth::rules(&ctx.prefs)?
            .into_iter()
            .map(|r| RuleItem {
                account_label: accounts
                    .iter()
                    .find(|a| a.id == r.account)
                    .map(|a| a.label.clone())
                    .unwrap_or_default(),
                pattern: r.pattern,
                account: r.account,
            })
            .collect())
    })
}

pub fn sign_in_providers() -> Vec<ChoiceItem> {
    source::sign_in_providers()
        .into_iter()
        .map(|(scheme, name)| ChoiceItem { value: scheme.to_string(), label: name.to_string() })
        .collect()
}

fn provider_for(scheme: &str) -> Result<&'static dyn source::Provider> {
    source::provider(scheme).with_context(|| format!("\"{scheme}\" is not a known site"))
}

pub fn start_sign_in(embedded: &str, provider: &str) -> Result<SignInStart> {
    crate::load_profile(embedded)?;
    let ch = provider_for(provider)?.start_sign_in()?;
    Ok(SignInStart {
        user_code: ch.user_code,
        verification_uri: ch.verification_uri,
        interval_secs: ch.interval_secs,
        expires_in_secs: ch.expires_in_secs,
        device_code: ch.device_code,
    })
}

pub fn poll_sign_in(
    embedded: &str,
    provider: &str,
    label: &str,
    device_code: &str,
    interval_secs: u64,
) -> Result<SignInStatus> {
    let p = provider_for(provider)?;
    let challenge = SignInChallenge {
        user_code: String::new(),
        verification_uri: String::new(),
        interval_secs,
        expires_in_secs: 0,
        device_code: device_code.to_string(),
    };
    match p.poll_sign_in(&challenge)? {
        SignInPoll::Pending => Ok(SignInStatus {
            state: "pending".into(),
            interval_secs,
            account_label: String::new(),
        }),
        SignInPoll::SlowDown(secs) => Ok(SignInStatus {
            state: "slow_down".into(),
            interval_secs: secs,
            account_label: String::new(),
        }),
        SignInPoll::Done(token) => with_ctx(embedded, |ctx| {
            let account = auth::save_signed_in(ctx, provider, label, &token)?;
            Ok(SignInStatus { state: "done".into(), interval_secs, account_label: account.label })
        }),
    }
}

pub fn add_token_account(embedded: &str, provider: &str, label: &str, token: &str) -> Result<String> {
    with_ctx(embedded, |ctx| Ok(auth::add_token_account(ctx, provider, label, token)?.label))
}

pub fn remove_account(embedded: &str, account_id: &str) -> Result<()> {
    with_ctx(embedded, |ctx| auth::remove_account(ctx, account_id))
}

pub fn set_default_account(embedded: &str, account_id: &str) -> Result<()> {
    with_ctx(embedded, |ctx| auth::set_default(ctx, account_id))
}

pub fn set_account_rule(embedded: &str, pattern: &str, account_id: &str) -> Result<()> {
    with_ctx(embedded, |ctx| auth::set_rule(ctx, pattern.trim(), account_id))
}

pub fn remove_account_rule(embedded: &str, pattern: &str) -> Result<()> {
    with_ctx(embedded, |ctx| auth::remove_rule(ctx, pattern))
}

// ── Loadstone settings as generic form items ─────────────────────────

/// Form items for the definitions settable in `scope`, with current values.
fn pref_items(ctx: &auth::AuthContext, scope: &Scope) -> Result<Vec<SettingItem>> {
    let store: &PrefStore = &ctx.prefs;
    let mod_id = match scope {
        Scope::Mod(id) => Some(id.as_str()),
        Scope::Global => None,
    };
    let mut out = Vec::new();
    for def in store.definitions() {
        let settable = match (def.applies, scope) {
            (loadstone_core::prefs::Applies::Global, Scope::Global) => true,
            (loadstone_core::prefs::Applies::Mod, Scope::Mod(_)) => true,
            (loadstone_core::prefs::Applies::GlobalWithModOverride, _) => true,
            _ => false,
        };
        if !settable || def.kind == PrefType::Structured {
            continue;
        }
        let value = store.get(def.key, mod_id)?;
        let (kind, options) = match def.kind {
            PrefType::Bool => ("boolean", Vec::new()),
            PrefType::Number => ("number", Vec::new()),
            PrefType::String => ("string", Vec::new()),
            PrefType::Choice(opts) => (
                "choice",
                opts.iter()
                    .map(|(v, l)| ChoiceItem { value: v.to_string(), label: l.to_string() })
                    .collect(),
            ),
            PrefType::AccountPicker => {
                let mut opts = vec![ChoiceItem {
                    value: String::new(),
                    label: "Automatic (account rules, then the default account)".into(),
                }];
                for a in auth::accounts(store)? {
                    let site = source::provider(&a.provider)
                        .map(|p| p.display_name())
                        .unwrap_or("");
                    opts.push(ChoiceItem {
                        label: format!("{} ({} on {site})", a.label, a.username),
                        value: a.id,
                    });
                }
                ("choice", opts)
            }
            PrefType::Structured => unreachable!(),
        };
        out.push(SettingItem {
            id: def.key.to_string(),
            label: def.label.to_string(),
            description: def.description.to_string(),
            kind: kind.to_string(),
            value: match &value {
                Value::String(s) => s.clone(),
                Value::Null => String::new(),
                other => other.to_string(),
            },
            options,
        });
    }
    Ok(out)
}

fn set_pref(ctx: &auth::AuthContext, scope: &Scope, key: &str, raw: &str) -> Result<()> {
    let def = ctx
        .prefs
        .definition(key)
        .with_context(|| format!("\"{key}\" is not a Loadstone setting"))?;
    let value = match def.kind {
        PrefType::Bool => match raw {
            "true" => Value::Bool(true),
            "false" => Value::Bool(false),
            _ => bail!("\"{raw}\" is not true or false"),
        },
        PrefType::Number => serde_json::Number::from_f64(
            raw.trim().parse::<f64>().with_context(|| format!("\"{raw}\" is not a number"))?,
        )
        .map(Value::Number)
        .context("not a finite number")?,
        PrefType::AccountPicker if raw.is_empty() => return ctx.prefs.unset(scope, key),
        PrefType::String | PrefType::Choice(_) | PrefType::AccountPicker => Value::from(raw),
        PrefType::Structured => bail!("\"{key}\" can't be edited as text"),
    };
    ctx.prefs.set(scope, key, value)
}

pub fn global_prefs(embedded: &str) -> Result<Vec<SettingItem>> {
    with_ctx(embedded, |ctx| pref_items(ctx, &Scope::Global))
}

pub fn set_global_pref(embedded: &str, key: &str, raw_value: &str) -> Result<()> {
    with_ctx(embedded, |ctx| set_pref(ctx, &Scope::Global, key, raw_value))
}

pub fn mod_prefs(embedded: &str, mod_id: &str) -> Result<Vec<SettingItem>> {
    with_ctx(embedded, |ctx| pref_items(ctx, &Scope::Mod(mod_id.to_string())))
}

pub fn set_mod_pref(embedded: &str, mod_id: &str, key: &str, raw_value: &str) -> Result<()> {
    with_ctx(embedded, |ctx| set_pref(ctx, &Scope::Mod(mod_id.to_string()), key, raw_value))
}
