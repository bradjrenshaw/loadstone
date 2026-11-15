//! `loadstone testers …` — tester access (SPEC 2.3): passwords that unlock
//! tester-only mods and beta releases. A registry has one in its
//! testers.json; a mod can have its own in its package file.

use anyhow::{bail, Result};
use clap::Subcommand;

use loadstone_core::prefs::PrefStore;
use loadstone_core::profile::Profile;
use loadstone_core::testers;

#[derive(Subcommand)]
pub enum TestersCommand {
    /// Save a tester password, alongside any already saved, after checking
    /// it with the registries.
    Unlock {
        password: String,
        /// Extra registries to check, ahead of the profile's.
        #[arg(long = "registry")]
        registries: Vec<String>,
    },
    /// Forget every saved tester password.
    Lock,
    /// Say how many tester passwords are saved.
    Status,
    /// Print a testers.json for a registry's loadstone-packages/ directory:
    /// one password for every mod the registry lists.
    NewFile { password: String },
    /// Print the "testers" entry for one mod's own package file
    /// (loadstone-packages/<id>.json). The mod then answers to this
    /// password only, not to the registry's.
    ModPassword { password: String },
}

pub fn run(command: TestersCommand, profile: &Profile) -> Result<()> {
    let prefs = PrefStore::open(profile, None)?;
    match command {
        TestersCommand::Unlock { password, registries } => {
            let mut sources = registries;
            sources.extend(profile.registries.iter().cloned());
            if sources.is_empty() {
                bail!("no registries to check the password with (pass --registry)");
            }
            let unlocks = testers::check_password(&sources, &password)?;
            if !unlocks.any() {
                bail!("that isn't a tester password for any of these registries or their mods");
            }
            testers::add_password(&prefs, &password)?;
            println!("{}", unlocks.describe());
        }
        TestersCommand::Lock => {
            testers::forget_passwords(&prefs)?;
            println!("Tester passwords forgotten.");
        }
        TestersCommand::Status => match testers::saved_passwords(&prefs).len() {
            0 => println!("No tester password is saved."),
            1 => println!("1 tester password is saved."),
            n => println!("{n} tester passwords are saved."),
        },
        TestersCommand::NewFile { password } => {
            if password.is_empty() {
                bail!("the password must not be empty");
            }
            println!("{}", serde_json::to_string_pretty(&testers::TestersFile::new(&password))?);
        }
        TestersCommand::ModPassword { password } => {
            if password.is_empty() {
                bail!("the password must not be empty");
            }
            // One line to paste among the package file's fields.
            println!("\"testers\": {}", serde_json::to_string(&testers::PasswordHash::new(&password))?);
        }
    }
    Ok(())
}
