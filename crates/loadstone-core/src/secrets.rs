//! Account tokens in the OS credential store (Windows Credential Manager,
//! macOS Keychain) via the `keyring` crate.
//!
//! Entries use the service name "Loadstone" and a user name that keeps
//! scopes apart: `manager/<account-id>` for the manager,
//! `installer/<mod-id>/<account-id>` for a standalone installer — so an
//! installer's sign-ins never mix with the manager's.

use anyhow::{Context as _, Result};

use crate::auth::{AuthContext, SecretStore};
use crate::prefs::PrefStore;
use crate::profile::{Profile, ProfileMode};

const SERVICE: &str = "Loadstone";

pub struct KeyringSecrets {
    prefix: String,
}

impl KeyringSecrets {
    pub fn for_profile(profile: &Profile) -> Self {
        let prefix = match (&profile.mode, &profile.mod_id) {
            (ProfileMode::SingleMod, Some(id)) => format!("installer/{id}"),
            _ => "manager".to_string(),
        };
        Self { prefix }
    }

    fn entry(&self, account_id: &str) -> keyring::Result<keyring::Entry> {
        keyring::Entry::new(SERVICE, &format!("{}/{account_id}", self.prefix))
    }
}

impl SecretStore for KeyringSecrets {
    fn get(&self, account_id: &str) -> Option<String> {
        self.entry(account_id).ok()?.get_password().ok()
    }

    fn set(&self, account_id: &str, secret: &str) -> Result<()> {
        self.entry(account_id)
            .and_then(|e| e.set_password(secret))
            .context("couldn't save the token in the system credential store")
    }

    fn delete(&self, account_id: &str) -> Result<()> {
        match self.entry(account_id).and_then(|e| e.delete_credential()) {
            Ok(()) | Err(keyring::Error::NoEntry) => Ok(()),
            Err(e) => Err(e).context("couldn't remove the token from the system credential store"),
        }
    }
}

/// Install the account context for `profile`: its preference scope and the
/// OS credential store. Call once at startup (CLI and GUI).
pub fn init_for_profile(profile: &Profile) -> Result<()> {
    let prefs = PrefStore::open(profile, None)?;
    crate::auth::init(AuthContext { prefs, secrets: Box::new(KeyringSecrets::for_profile(profile)) });
    Ok(())
}
