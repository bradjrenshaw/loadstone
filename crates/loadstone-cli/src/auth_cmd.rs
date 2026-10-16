//! `loadstone auth …` — accounts for private repositories.

use std::io::Read as _;

use anyhow::{Context, Result};
use clap::Subcommand;

use loadstone_core::auth;

#[derive(Subcommand)]
pub enum AuthCommand {
    /// Sign in through the browser (shows a code to enter on the site).
    Login {
        /// Site to sign in to.
        #[arg(long, default_value = "github")]
        provider: String,
        /// Name for this account (default: the account's user name).
        #[arg(long, default_value = "")]
        label: String,
        /// Don't open the sign-in page in the browser automatically.
        #[arg(long)]
        no_browser: bool,
    },
    /// Add an account from an existing token (e.g. `gh auth token`).
    /// Without --token, the token is read from standard input.
    AddToken {
        #[arg(long, default_value = "github")]
        provider: String,
        #[arg(long, default_value = "")]
        label: String,
        #[arg(long)]
        token: Option<String>,
    },
    /// List accounts and account rules.
    List,
    /// Remove an account (its token and any rules using it).
    Remove { account: String },
    /// Make an account its site's default.
    Default { account: String },
    /// Use an account for a repository (github:owner/repo) or owner (github:owner/*).
    RuleSet { pattern: String, account: String },
    /// Remove the rule for a pattern.
    RuleRemove { pattern: String },
    /// Choose the account a mod downloads with ("auto" for automatic).
    Use { mod_id: String, account: String },
    /// Show which credentials a download from a source would try, in order.
    Which {
        source: String,
        #[arg(long = "mod")]
        mod_id: Option<String>,
    },
}

pub fn run(cmd: AuthCommand) -> Result<()> {
    let profile = crate::load_profile()?;
    loadstone_core::secrets::init_for_profile(&profile)?;
    auth::with_context(|ctx| {
        let ctx = ctx.context("no account context")?;
        match cmd {
            AuthCommand::Login { provider, label, no_browser } => {
                let account = auth::sign_in(
                    ctx,
                    &provider,
                    &label,
                    |ch| {
                        println!("To sign in, open {} and enter this code:", ch.verification_uri);
                        println!("{}", ch.user_code);
                        if !no_browser {
                            open_browser(&ch.verification_uri);
                        }
                        println!("Waiting for you to finish signing in (press Ctrl+C to cancel)...");
                    },
                    || false,
                )?;
                println!("Signed in as {} (account \"{}\").", account.username, account.id);
            }
            AuthCommand::AddToken { provider, label, token } => {
                let token = match token {
                    Some(t) => t,
                    None => {
                        let mut s = String::new();
                        std::io::stdin().read_to_string(&mut s).context("failed to read the token")?;
                        s
                    }
                };
                let account = auth::add_token_account(ctx, &provider, &label, &token)?;
                println!("Added {} (account \"{}\").", account.username, account.id);
            }
            AuthCommand::List => {
                let accounts = auth::accounts(&ctx.prefs)?;
                if accounts.is_empty() {
                    println!("No accounts.");
                }
                for a in &accounts {
                    let default = if a.default { ", default" } else { "" };
                    let token = if ctx.secrets.get(&a.id).is_some() { "" } else { ", token missing" };
                    println!("{}: {} ({} on {}{default}{token})", a.id, a.label, a.username, a.host);
                }
                for r in auth::rules(&ctx.prefs)? {
                    println!("rule: {} uses {}", r.pattern, r.account);
                }
            }
            AuthCommand::Remove { account } => {
                auth::remove_account(ctx, &account)?;
                println!("Removed {account}.");
            }
            AuthCommand::Default { account } => {
                auth::set_default(ctx, &account)?;
                println!("{account} is now the default.");
            }
            AuthCommand::RuleSet { pattern, account } => {
                auth::set_rule(ctx, &pattern, &account)?;
                println!("{pattern} uses {account}.");
            }
            AuthCommand::RuleRemove { pattern } => {
                auth::remove_rule(ctx, &pattern)?;
                println!("Removed the rule for {pattern}.");
            }
            AuthCommand::Use { mod_id, account } => {
                let choice = (account != "auto").then_some(account.as_str());
                auth::set_mod_account(ctx, &mod_id, choice)?;
                println!("{mod_id} downloads with {}.", choice.unwrap_or("automatic account choice"));
            }
            AuthCommand::Which { source, mod_id } => {
                let (provider, _) = loadstone_core::source::parse(&source)?;
                for (i, c) in auth::candidates(provider.scheme(), &source, mod_id.as_deref())
                    .iter()
                    .enumerate()
                {
                    match c {
                        Some(c) => println!("{}. {}{}", i + 1, c.origin, if c.explicit { " (explicit)" } else { "" }),
                        None => println!("{}. no account (anonymous)", i + 1),
                    }
                }
            }
        }
        Ok::<(), anyhow::Error>(())
    })
}

fn open_browser(url: &str) {
    if !url.starts_with("https://") {
        return;
    }
    #[cfg(windows)]
    let result = std::process::Command::new("rundll32").args(["url.dll,FileProtocolHandler", url]).spawn();
    #[cfg(target_os = "macos")]
    let result = std::process::Command::new("open").arg(url).spawn();
    #[cfg(not(any(windows, target_os = "macos")))]
    let result = std::process::Command::new("xdg-open").arg(url).spawn();
    if result.is_err() {
        println!("(Couldn't open the browser; open the address above yourself.)");
    }
}

