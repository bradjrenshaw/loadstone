# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = This mod needs a newer version of Loadstone. Update Loadstone, then try again.

## Loadstone settings

pref-language = Language
pref-language-description = The language Loadstone and translated mods are shown in.
language-system = System default
pref-accounts = Accounts
pref-accounts-description = Sign-ins used to download mods from private repositories.
pref-account-rules = Account rules
pref-account-rules-description = Which account to use for a repository or owner.
pref-try-other-accounts = Try my other accounts when a download is refused
pref-try-other-accounts-description = If a repository isn't found or access is refused, try the other accounts for that site before giving up.
pref-tester-passwords = Tester passwords
pref-tester-passwords-description = Unlock tester-only mods and beta versions, for a registry or for single mods. Set from the tester password button.
pref-download-account = Download account
pref-download-account-description = The account used to download this mod. Automatic uses your account rules and default account.
pref-download-account-automatic = Automatic (account rules, then the default account)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Loadstone settings...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Accounts for private repositories, and Loadstone options
gui-menu-exit = E&xit
# Menu bar title.
gui-menu-tools = &Tools
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = An operation is still running. Closing now may leave it unfinished. Close anyway?
gui-close-while-running-title = Operation in progress
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Loading...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problem during the operation
gui-button-retry = &Retry
gui-button-skip = &Skip
gui-button-cancel-problem = &Cancel
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Install options

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (core { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mods:
# Button that opens the selected mod's page.
gui-button-details = &Details
gui-button-refresh = &Refresh
gui-button-loadstone-settings = Loadstone settin&gs...
gui-status-fetching-catalog = Fetching the mod catalog...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Loading mod list...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Could not load the mod list. Press Refresh to retry.
gui-status-catalog-failed = Catalog fetch failed.
gui-catalog-error-title = Could not load the mod catalog
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = No mods available.
gui-status-catalog-loaded = { $count ->
    [one] Catalog loaded: { $count } mod.
   *[other] Catalog loaded: { $count } mods.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Loading { $mod_id }...
gui-status-mod-load-failed = Could not load the mod page.
gui-mod-error-title = Could not load mod
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Copy of the game to manage:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Copy of { $game } to manage:
gui-button-back = &Back to mod list
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name } by { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = &Game directory:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = &{ $game } directory:
gui-button-browse = Bro&wse...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Select the game folder
gui-browse-game-prompt-named = Select the { $game } folder
gui-description-label = Description:
# Label of the log where operations report their progress.
gui-activity-label = Activity:
gui-button-update = &Update
gui-button-install = &Install
gui-select-folder-first = Use Browse to select the game folder first.
gui-button-install-from-file = Install from &file...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Select the mod's loadstone-release.json
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON files (*.json)|*.json|All files (*.*)|*.*
gui-button-uninstall = U&ninstall
gui-button-launch = &Launch game
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Starts the game with the mod loaded.
gui-launch-unavailable-description = Available once the mod is installed here.
gui-button-change-options = Change install &options...
gui-change-options-description = Asks the mod's install questions again and reinstalls the latest version with your answers.
gui-button-settings = &Settings...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Working... { $percent }%
gui-status-fetching-releases = Fetching the release list...
# $error is an error message.
gui-release-list-error = Could not fetch the release list: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Install the latest release instead?
gui-release-list-error-title = Release list unavailable
gui-no-releases = This mod's repository has no releases yet.
gui-no-releases-title = No releases
gui-choose-version = Select the version to install:
gui-choose-version-title = Choose version
gui-confirm-uninstall = Uninstall { $name }?
gui-confirm-uninstall-title = Confirm uninstall
gui-status-working = Working...
gui-status-op-failed = The operation failed.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Can't launch
gui-op-failed-title = Operation failed
# Title of the message shown when an operation finished.
gui-op-done-title = Done

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Version { $version } of { $app } is available (you have { $current }). Update and restart now?
gui-self-update-title = Update available
gui-status-downloading-update = Downloading the update...
gui-status-update-failed = The update failed.
gui-update-failed-title = Update failed
gui-status-update-installed = Update installed.
gui-update-installed = The update is installed. The app will now restart.
gui-update-installed-title = Update installed

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Loadstone settings unavailable: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = { $name } Settings
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Mod options
gui-mod-options-after-install = The mod's options become available after it is installed.
gui-status-setting-saved = Setting saved.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Setting saved. { $note }
gui-setting-not-changed-title = Setting not changed
gui-status-no-settings-changed = No settings changed.

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone settings
gui-accounts-label = &Accounts:
gui-accounts-description = Sign-ins used to download mods from private repositories.
gui-button-sign-in = Sign &in...
gui-button-add-token = Add &token...
gui-button-remove-account = &Remove account
gui-button-set-default = Set as &default
# "gh auth token" is a command, keep it.
gui-add-token-description = Add an account from a token you already have, for example from the GitHub CLI's gh auth token command.
gui-rules-label = Account r&ules:
gui-rules-description = Which account to use for a repository or for all of an owner's repositories. Without a rule, the default account is used.
gui-button-add-rule = Add rul&e...
gui-button-remove-rule = Remo&ve rule
gui-button-tester-password = Tester &password...
gui-tester-password-description = For private testers: enter a password you were given to see tester-only mods and get beta versions. You can add more than one. Leave it empty to stop testing.
gui-tester-password-prompt-saved = You have saved tester passwords. Enter another one to add it, or leave this empty to forget them all and stop testing.
gui-tester-password-prompt = Enter the tester password you were given.
gui-tester-password-title = Tester password
gui-tester-password-not-saved-title = Tester password not saved
gui-button-close = &Close
gui-accounts-unavailable-title = Accounts unavailable
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } on { $site }, default
    [missing] { $account }, { $username } on { $site }, token missing (sign in again)
    [default-missing] { $account }, { $username } on { $site }, default, token missing (sign in again)
   *[none] { $account }, { $username } on { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = No accounts. Use Sign in to add one.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } uses { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = No rules.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Paste a { $site } token. It is checked with { $site }, then stored in the Windows Credential Manager.
gui-add-token-title = Add token
gui-status-account-added = Added account { $account }.
gui-token-not-added-title = Token not added
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Remove the account { $account }? Loadstone forgets its token and any rules that use it. To also revoke Loadstone's access, use Applications in your { $site } settings.
gui-remove-account-title = Remove account
gui-account-not-removed-title = Account not removed
gui-default-not-changed-title = Default not changed
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Repository (github:owner/repo) or every repository of an owner (github:owner/*):
gui-add-rule-title = Add account rule
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Use which account?
gui-rule-not-added-title = Rule not added
gui-rule-not-removed-title = Rule not removed

## Signing in

gui-sign-in-no-sites = No site supports signing in.
gui-sign-in-title = Sign in
gui-sign-in-which-site = Sign in to which site?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Sign in to { $site }
gui-sign-in-requesting = Requesting a sign-in code from { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = Sign-in &code:
gui-button-copy-code = Co&py code
gui-button-open-sign-in-page = &Open { $site } sign-in page
gui-button-cancel = Cancel
gui-sign-in-code-copied = Code copied. Open the sign-in page and paste it there.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Open { $url }, enter the code below, and approve Loadstone. This window closes by itself when you're done.
gui-sign-in-code-expired = The sign-in code expired before it was entered. Please start again.
# $account is the account's name.
gui-status-signed-in = Signed in as { $account }.
gui-signed-in = Signed in to { $site } as { $account }.
gui-signed-in-title = Signed in
gui-sign-in-failed-title = Sign-in failed
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Sign in now with an account that can see it?
gui-offer-sign-in-title = Sign in to continue

## Startup

gui-startup-error-title = Loadstone startup error

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone Mod Manager

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Installed { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Installed { $version } ({ $channel } channel)
page-catalog-not-installed = Not installed
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Installed { $version } for { $count } copy
   *[other] Installed { $version } for { $count } copies
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Installed for { $count } copy (versions differ)
   *[other] Installed for { $count } copies (versions differ)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Installed outside Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Installed, but not listed by the configured registries.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (tester preview)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = No registries are configured; showing installed mods only.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] { $count } mod not available for this computer is hidden.
   *[other] { $count } mods not available for this computer are hidden.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Could not load registries: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Not found in the configured registries: { $error }
page-note-no-release-metadata = The latest published release has no Loadstone metadata yet, so the newest version could not be determined.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Note: copies of { $game } share one mods folder. Installing or uninstalling a mod for one copy affects the others; only the mod loader is separate per copy.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Requires { $name } (installed automatically, currently { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Requires { $name } (installed automatically).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Installed { $version } (dev channel).
page-status-up-to-date = Up to date (version { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Up to date (version { $version }, newer than the latest release, { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Update available: { $version } to { $latest }.
page-status-installed = Installed { $version }.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Installed outside Loadstone (version unknown). Install version { $latest } to let Loadstone manage this copy.
page-status-foreign = Installed outside Loadstone (version unknown). Install to let Loadstone manage this copy.
page-status-ready = Ready to install version { $latest }.
page-status-not-installed = Not installed.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Not available on this computer. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Ready to install version { $latest }. Game directory not found; use Browse to select it.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Not installed. Game directory not found; use Browse to select it.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Use Browse to select the folder. Not available on this computer. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Use Browse to select the folder. Ready to install version { $latest }. Game directory not found; use Browse to select it.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Use Browse to select the folder. Not installed. Game directory not found; use Browse to select it.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Settings become editable after install.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = { $distribution } copy, installed { $version }, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = { $distribution } copy, installed outside Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = { $distribution } copy, not installed, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Copy at { $folder }, installed { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Copy at { $folder }, installed outside Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Copy at { $folder }, not installed
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = No copy found yet; use Browse to select the game folder.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Another folder...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Standalone
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = { $channel } channel (latest from the { $branch } branch)
# A development channel. $channel is the channel id ("dev").
page-channel-development = { $channel } channel (development build)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (pre-release)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (pre-release)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = { $action } completed.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Downloading { $file }...
page-self-update-installed = Update verified and installed.
page-tester-passwords-removed = Tester passwords removed. Tester-only mods and beta versions are hidden again.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } on { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = no registries are configured
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = no source repo is known for "{ $id }"
# $id is a mod id.
page-error-not-installed-no-registries = "{ $id }" is not installed and no registries are configured
# $id is a mod id.
page-error-not-installed-unresolved = "{ $id }" is not installed and could not be resolved
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = "{ $id }" is not installed and could not be resolved: { $error }
page-error-tester-password-wrong = That isn't a tester password for any of your registries or their mods.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = account storage is unavailable
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = "{ $value }" is not a number
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = not a finite number

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = artifact hash mismatch for { $id }: expected { $expected }, got { $actual }. Refusing to install.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = artifact hash mismatch for { $id } ({ $artifact }): expected { $expected }, got { $actual }. Refusing to install.
engine-hash-verified = Artifact hash verified.
engine-hash-none = No hash to verify for this source (local or development install).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Removing previously installed version { $version } ({ $count } file).
   *[other] Removing previously installed version { $version } ({ $count } files).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Warning: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Warning: could not record the originals still to restore: { $error }
engine-install-failed-rolling-back = Install failed; removing files written so far.
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } installed.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Install cancelled.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = "{ $id }" is not an install option of this mod (options: { $options })
engine-option-unknown-none = "{ $id }" is not an install option of this mod (options: none)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = "{ $value }" is not a choice for { $option } (choices: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = cancelled: no choice made

## Mod settings

# { $label } is the setting's name.
engine-setting-default = Setting "{ $label }" starts at its default; change it later with the settings command.
# { $path } is the settings file.
engine-settings-written = Wrote settings to { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = "{ $action }" is not an action of { $id } (available: { $available })
engine-action-unknown-none = "{ $action }" is not an action of { $id } (available: none)
# { $label } is the action's name, as on its button.
engine-action-unavailable = "{ $label }" is not available right now (its precondition doesn't hold)
engine-action-running = Running "{ $label }"...
engine-action-finished = "{ $label }" finished.
engine-no-launch-steps = { $id } declares no launch steps for this platform
# Summary after starting the game with a mod.
engine-launched = { $id } launched.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } is a link into a development checkout; refusing to modify or remove files through it. Remove the link first if you really want a managed install here.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = Not removing { $path }: outside the mod's folders.
engine-legacy-link = Not removing { $path }: it is reached through a link.
engine-legacy-shared = Not removing { $path }: another installed package uses it.
engine-legacy-removed = Removed leftover { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Warning: could not remove { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Required file not found: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = A requirement of step { $step } is not met.
engine-step-skipped = Skipped step { $step }.
engine-cancelled-at-step = cancelled at step { $step }
engine-extracting = Extracting files...
engine-placed-files = { $count ->
    [one] Placed { $count } file.
   *[other] Placed { $count } files.
}
engine-kept-existing = Kept existing { $path } (not overwritten; it may be newer).
engine-file-created = Created and updated { $path }.
engine-file-updated = Updated { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = cancelled: no directory chosen for "{ $prompt }"
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Copied to the clipboard: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] Combined { $count } architecture into { $file }.
   *[other] Combined { $count } architectures into { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = cannot launch: { $path } is missing
engine-program-start-failed = failed to start { $path }
engine-program-started = Started { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = failed to open { $url }
engine-url-opened = Opened { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } is still needed by: { $dependents }. Uninstall those first.
engine-removing-files = { $count ->
    [one] Removing { $count } file.
   *[other] Removing { $count } files.
}
engine-purge-question = Also remove saved settings and preferences?
engine-purge-done = Removed saved settings.
engine-dependency-unneeded = { $id } is no longer needed by any installed mod; you can uninstall it too.
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } uninstalled.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Using the original already kept at { $path }.
engine-originals-kept = { $count ->
    [one] Kept a copy of { $count } original game file.
   *[other] Kept a copy of { $count } original game files.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Warning: could not restore the original { $path } now ({ $error }). It will be put back when this mod is updated or uninstalled.
engine-original-restored = Restored the original { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Warning: the original of { $path } is missing ({ $backup }); leaving the file as it is.
engine-original-changed = { $path } changed since this mod was installed (a game update?); keeping the newer file.
engine-originals-restored = { $count ->
    [one] Restored { $count } original game file.
   *[other] Restored { $count } original game files.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] could not put back { $count } original game file; close the game and try again.
   *[other] could not put back { $count } original game files; close the game and try again.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Updating the { $distribution } copy at { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = "{ $id }" is installed for more than one copy of { $game }: { $copies }. Pass --game-dir to say which copy to update.
engine-many-copies = "{ $id }" is installed for more than one copy of { $game }: { $copies }. Pass --game-dir to say which copy.
engine-not-game-folder = { $path } does not look like a { $game } folder (none of the expected files found)
engine-game-found = Found { $game } at { $path }
engine-game-not-found = Could not find { $game } automatically.
# Title of the folder picker.
engine-game-where = Where is { $game } installed?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = could not find { $game } automatically; pass --game-dir or pick its folder
# { $path } is a game folder.
engine-not-installed-copy = "{ $id }" is not installed for the { $game } copy at { $path }
engine-not-installed = "{ $id }" is not installed for { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = { $name } can't be installed on this computer. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = the { $distribution } copy of { $game } is not supported. { $reason }
engine-distribution-untested = Note: the { $distribution } copy of { $game } is untested with this mod.
engine-no-matching-artifact = no release artifact matches this platform/architecture/distribution
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = This mod is available on { $platform } only.
engine-platform-only-two = This mod is available on { $first } and { $second } only.
engine-platform-only-three = This mod is available on { $first } and { $second } and { $third } only.
engine-platform-needs-apple-silicon = On { $platform }, this mod needs an Apple Silicon processor.
engine-platform-needs-arm = On { $platform }, this mod needs an ARM processor.
engine-platform-needs-x64 = On { $platform }, this mod needs an Intel or AMD processor.
engine-game-platform-unsupported = { $game } isn't supported on { $platform } here.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } is up to date ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } is up to date ({ $installed } is newer than the latest release, { $latest }).
engine-installed-newer = { $name } { $installed } is installed, which is newer than the latest release available to you now ({ $latest }). Nothing was changed. To install an older version, choose that version explicitly.
# { $from } and { $to } are versions.
engine-updating = Updating { $name } { $from } -> { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Install { $name } from the tip of the { $branch } branch ({ $version })?

    Development builds are not hash-pinned; you are trusting the repository's current contents.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Release notes for { $name } { $version }:

    { $notes }

    Install now?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Fetching release { $tag } information from { $source }...
engine-fetching-latest = Fetching latest release information from { $source }...
engine-using-local-artifact = Using local artifact { $path }
# { $file } is a download's file name.
engine-using-cached = Using the already downloaded { $file }.
engine-downloading = Downloading { $file }...
engine-dependency-present = Dependency { $id } { $version } already installed.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Installing dependency { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = no token given
core-sign-in-cancelled = Sign-in cancelled.
core-sign-in-expired = The sign-in code expired before it was entered. Please start again.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = "{ $pattern }" is not a source (github:owner/repo) or owner wildcard (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = couldn't save the token in the system credential store
core-secrets-remove-failed = couldn't remove the token from the system credential store

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = release { $tag } of { $source } has no { $file } asset
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = release latest of { $source } has no { $file } asset
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = release { $tag } has no loadstone-release.json asset (or it is unreachable)
core-github-sign-in-cancelled = Sign-in was cancelled on GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub refused the sign-in: { $details }
core-github-sign-in-refused-no-details = GitHub refused the sign-in: no details given
core-github-token-rejected = GitHub didn't accept the token

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } doesn't support signing in
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = "{ $source }" is not a { $format } source
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } wasn't found. If it's a private repository, sign in with an account that can see it (Loadstone settings), or set GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = the token from { $account } was refused; it may have expired or been revoked
core-source-token-unreachable = { $source } isn't reachable with the token from { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = download of { $url } returned HTTP { $status }
core-fetch-request-failed = request failed: { $url }
core-fetch-download-failed = download failed: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = read error
core-fetch-read-error-download = read error during download

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = no extraction route applies on this platform/distribution
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } is a link into a development checkout. Update that checkout with git instead, or remove the link before installing.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = this archive doesn't contain the expected payload (no entry matches any route)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = registry "{ $source }" is neither { $formats } nor an existing directory
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } has no loadstone-packages directory
# $error is the reason the download failed.
core-registry-using-cache = Could not refresh { $source } ({ $error }); using the cached copy.
core-registry-fetch-failed = failed to fetch registry { $source }
# $id is a mod's id.
core-registry-package-not-found = package "{ $id }" not found in any registry

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = "{ $key }" is a boolean; use true or false
core-setting-not-number = "{ $key }" needs a number
core-setting-too-small = "{ $key }" must be at least { $min }
core-setting-too-large = "{ $key }" must be at most { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = "{ $key }" must be one of: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Tester access unlocked for a registry's mods: tester-only mods are listed, and installs and updates get beta versions.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Tester access unlocked for a registry's mods and { $mods }: tester-only mods are listed, and installs and updates get beta versions.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Tester access unlocked for { $mods }: tester-only mods are listed, and installs and updates get beta versions.
core-tester-save-failed = failed to save the tester password
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = Release { $tag } has no usable Loadstone metadata ({ $error }); using the latest stable release.
core-tester-beta-lookup-failed = Could not look up beta versions ({ $error }); using the latest stable release.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = the downloaded update failed hash verification (expected { $expected }, got { $actual }); not installed
core-update-translocated = macOS is running this app from a temporary read-only copy, so it can't update itself. Move it into your Applications folder, open it from there, and update again.
core-update-on-disk-image = this app is running from its disk image, so it can't update itself. Copy it into your Applications folder, open it from there, and update again.
# $path is the folder the app is in.
core-update-no-write = can't write next to { $path } (no permission?), so the app can't update itself. Download the new version from the release page instead.
core-update-no-staging = can't write next to { $path } (no permission?). Download the new version from the release page instead
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = the update is a different app ({ $got }, expected { $expected }); not installed
core-update-move-aside-app = could not move the current app aside
core-update-move-in-app = could not move the new app into place
core-update-move-aside-exe = could not move the current executable aside
core-update-move-in-exe = could not move the new executable into place
