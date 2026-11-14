//! `loadstone testers …` — tester access (SPEC 2.3): one password that
//! unlocks a registry's tester-only mods and every mod's beta releases.

use anyhow::{bail, Result};
use clap::Subcommand;

use loadstone_core::prefs::PrefStore;
use loadstone_core::profile::Profile;
use loadstone_core::testers;

#[derive(Subcommand)]
pub enum TestersCommand {
    /// Save the tester password after checking it with the registries.
    Unlock {
        password: String,
        /// Extra registries to check, ahead of the profile's.
        #[arg(long = "registry")]
        registries: Vec<String>,
    },
    /// Forget the tester password.
    Lock,
    /// Say whether a tester password is saved.
    Status,
    /// Print a testers.json for a registry's loadstone-packages/ directory.
    NewFile { password: String },
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
            if !testers::check_password(&sources, &password)? {
                bail!("that isn't the tester password");
            }
            testers::save_password(&prefs, &password)?;
            println!("Tester access unlocked: tester-only mods and beta versions are available.");
        }
        TestersCommand::Lock => {
            testers::save_password(&prefs, "")?;
            println!("Tester password forgotten.");
        }
        TestersCommand::Status => match testers::saved_password(&prefs) {
            Some(_) => println!("A tester password is saved."),
            None => println!("No tester password is saved."),
        },
        TestersCommand::NewFile { password } => {
            if password.is_empty() {
                bail!("the password must not be empty");
            }
            println!("{}", serde_json::to_string_pretty(&testers::TestersFile::new(&password))?);
        }
    }
    Ok(())
}
