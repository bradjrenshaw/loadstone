# Loadstone's interface text, German.
# Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Diese Mod benötigt eine neuere Version von Loadstone. Aktualisieren Sie Loadstone und versuchen Sie es dann erneut.

## Loadstone settings

pref-language = Sprache
pref-language-description = Die Sprache, in der Loadstone und übersetzte Mods angezeigt werden.
language-system = Systemstandard
pref-accounts = Konten
pref-accounts-description = Anmeldungen, mit denen Mods aus privaten Repositorys heruntergeladen werden.
pref-account-rules = Kontoregeln
pref-account-rules-description = Welches Konto für ein Repository oder einen Besitzer verwendet wird.
pref-try-other-accounts = Meine anderen Konten versuchen, wenn ein Download abgelehnt wird
pref-try-other-accounts-description = Wenn ein Repository nicht gefunden oder der Zugriff verweigert wird, werden die anderen Konten für diese Website versucht, bevor aufgegeben wird.
pref-tester-passwords = Tester-Passwörter
pref-tester-passwords-description = Schaltet Mods nur für Tester und Betaversionen frei, für eine ganze Registry oder für einzelne Mods. Wird über die Schaltfläche „Tester-Passwort“ festgelegt.
pref-download-account = Download-Konto
pref-download-account-description = Das Konto, mit dem diese Mod heruntergeladen wird. „Automatisch“ verwendet Ihre Kontoregeln und das Standardkonto.
pref-download-account-automatic = Automatisch (Kontoregeln, dann das Standardkonto)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Loadstone-Einstellungen...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Konten für private Repositorys und Optionen von Loadstone
gui-menu-exit = &Beenden
# Menu bar title.
gui-menu-tools = E&xtras
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Ein Vorgang wird noch ausgeführt. Wenn Sie jetzt schließen, bleibt er möglicherweise unvollständig. Trotzdem schließen?
gui-close-while-running-title = Vorgang läuft
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Wird geladen...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problem während des Vorgangs
gui-button-retry = &Wiederholen
gui-button-skip = Ü&berspringen
gui-button-cancel-problem = &Abbrechen
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Installationsoptionen

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (Kern { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mods:
# Button that opens the selected mod's page.
gui-button-details = &Details
gui-button-refresh = &Neu laden
gui-button-loadstone-settings = Loadstone-&Einstellungen...
gui-status-fetching-catalog = Mod-Katalog wird abgerufen...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Mod-Liste wird geladen...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Die Mod-Liste konnte nicht geladen werden. Drücken Sie „Neu laden“, um es erneut zu versuchen.
gui-status-catalog-failed = Abrufen des Katalogs fehlgeschlagen.
gui-catalog-error-title = Der Mod-Katalog konnte nicht geladen werden
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Keine Mods verfügbar.
gui-status-catalog-loaded = { $count ->
    [one] Katalog geladen: { $count } Mod.
   *[other] Katalog geladen: { $count } Mods.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = { $mod_id } wird geladen...
gui-status-mod-load-failed = Die Mod-Seite konnte nicht geladen werden.
gui-mod-error-title = Mod konnte nicht geladen werden
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = Zu verwaltende &Kopie des Spiels:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = Zu verwaltende &Kopie von { $game }:
gui-button-back = &Zurück zur Mod-Liste
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name } von { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = S&pielordner:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = O&rdner von { $game }:
gui-button-browse = Durch&suchen...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Spielordner auswählen
gui-browse-game-prompt-named = Ordner von { $game } auswählen
gui-description-label = Beschreibung:
# Label of the log where operations report their progress.
gui-activity-label = Aktivität:
gui-button-update = &Aktualisieren
gui-button-install = &Installieren
gui-select-folder-first = Wählen Sie zuerst mit „Durchsuchen“ den Spielordner aus.
gui-button-install-from-file = Aus &Datei installieren...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = loadstone-release.json der Mod auswählen
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON-Dateien (*.json)|*.json|Alle Dateien (*.*)|*.*
gui-button-uninstall = Dei&nstallieren
gui-button-launch = Spiel s&tarten
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Startet das Spiel mit geladener Mod.
gui-launch-unavailable-description = Verfügbar, sobald die Mod hier installiert ist.
gui-button-change-options = Installations&optionen ändern...
gui-change-options-description = Stellt die Installationsfragen der Mod erneut und installiert die neueste Version mit Ihren Antworten neu.
gui-button-settings = &Einstellungen...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Wird ausgeführt... { $percent } %
gui-status-fetching-releases = Release-Liste wird abgerufen...
# $error is an error message.
gui-release-list-error = Die Release-Liste konnte nicht abgerufen werden: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Stattdessen das neueste Release installieren?
gui-release-list-error-title = Release-Liste nicht verfügbar
gui-no-releases = Das Repository dieser Mod hat noch keine Releases.
gui-no-releases-title = Keine Releases
gui-choose-version = Wählen Sie die zu installierende Version aus:
gui-choose-version-title = Version auswählen
gui-confirm-uninstall = Die Mod { $name } deinstallieren?
gui-confirm-uninstall-title = Deinstallation bestätigen
gui-status-working = Wird ausgeführt...
gui-status-op-failed = Der Vorgang ist fehlgeschlagen.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Start nicht möglich
gui-op-failed-title = Vorgang fehlgeschlagen
# Title of the message shown when an operation finished.
gui-op-done-title = Fertig

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Version { $version } von { $app } ist verfügbar (installiert ist { $current }). Jetzt aktualisieren und neu starten?
gui-self-update-title = Update verfügbar
gui-status-downloading-update = Update wird heruntergeladen...
gui-status-update-failed = Das Update ist fehlgeschlagen.
gui-update-failed-title = Update fehlgeschlagen
gui-status-update-installed = Update installiert.
gui-update-installed = Das Update ist installiert. Die App wird jetzt neu gestartet.
gui-update-installed-title = Update installiert

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Loadstone-Einstellungen nicht verfügbar: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Einstellungen: { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Mod-Optionen
gui-mod-options-after-install = Die Optionen der Mod sind nach der Installation verfügbar.
gui-status-setting-saved = Einstellung gespeichert.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Einstellung gespeichert. { $note }
gui-setting-not-changed-title = Einstellung nicht geändert
gui-status-no-settings-changed = Keine Einstellungen geändert.

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone-Einstellungen
gui-accounts-label = &Konten:
gui-accounts-description = Anmeldungen, mit denen Mods aus privaten Repositorys heruntergeladen werden.
gui-button-sign-in = &Anmelden...
gui-button-add-token = &Token hinzufügen...
gui-button-remove-account = Konto &entfernen
gui-button-set-default = Als &Standard festlegen
# "gh auth token" is a command, keep it.
gui-add-token-description = Fügt ein Konto aus einem bereits vorhandenen Token hinzu, zum Beispiel aus dem Befehl gh auth token der GitHub CLI.
gui-rules-label = Konto&regeln:
gui-rules-description = Welches Konto für ein Repository oder für alle Repositorys eines Besitzers verwendet wird. Ohne Regel wird das Standardkonto verwendet.
gui-button-add-rule = Rege&l hinzufügen...
gui-button-remove-rule = Regel ent&fernen
gui-button-tester-password = Tester-&Passwort...
gui-tester-password-description = Für private Tester: Geben Sie ein Passwort ein, das Sie erhalten haben, um Mods nur für Tester zu sehen und Betaversionen zu erhalten. Sie können mehrere hinzufügen. Lassen Sie das Feld leer, um das Testen zu beenden.
gui-tester-password-prompt-saved = Sie haben gespeicherte Tester-Passwörter. Geben Sie ein weiteres ein, um es hinzuzufügen, oder lassen Sie das Feld leer, um alle zu vergessen und das Testen zu beenden.
gui-tester-password-prompt = Geben Sie das Tester-Passwort ein, das Sie erhalten haben.
gui-tester-password-title = Tester-Passwort
gui-tester-password-not-saved-title = Tester-Passwort nicht gespeichert
gui-button-close = Schl&ießen
gui-accounts-unavailable-title = Konten nicht verfügbar
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } auf { $site }, Standard
    [missing] { $account }, { $username } auf { $site }, Token fehlt (erneut anmelden)
    [default-missing] { $account }, { $username } auf { $site }, Standard, Token fehlt (erneut anmelden)
   *[none] { $account }, { $username } auf { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Keine Konten. Fügen Sie mit „Anmelden“ eines hinzu.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } verwendet { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Keine Regeln.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Fügen Sie ein Token von { $site } ein. Es wird bei { $site } geprüft und dann in der Windows-Anmeldeinformationsverwaltung gespeichert.
gui-add-token-title = Token hinzufügen
gui-status-account-added = Konto { $account } hinzugefügt.
gui-token-not-added-title = Token nicht hinzugefügt
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Das Konto { $account } entfernen? Loadstone vergisst sein Token und alle Regeln, die es verwenden. Um auch den Zugriff von Loadstone zu widerrufen, verwenden Sie „Applications“ in Ihren Einstellungen bei { $site }.
gui-remove-account-title = Konto entfernen
gui-account-not-removed-title = Konto nicht entfernt
gui-default-not-changed-title = Standard nicht geändert
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Repository (github:owner/repo) oder alle Repositorys eines Besitzers (github:owner/*):
gui-add-rule-title = Kontoregel hinzufügen
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Welches Konto soll verwendet werden?
gui-rule-not-added-title = Regel nicht hinzugefügt
gui-rule-not-removed-title = Regel nicht entfernt

## Signing in

gui-sign-in-no-sites = Keine Website unterstützt die Anmeldung.
gui-sign-in-title = Anmelden
gui-sign-in-which-site = Bei welcher Website anmelden?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Bei { $site } anmelden
gui-sign-in-requesting = Anmeldecode wird bei { $site } angefordert...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = Anmelde&code:
gui-button-copy-code = Code &kopieren
gui-button-open-sign-in-page = Anmeldeseite von { $site } ö&ffnen
gui-button-cancel = Abbrechen
gui-sign-in-code-copied = Code kopiert. Öffnen Sie die Anmeldeseite und fügen Sie ihn dort ein.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Öffnen Sie { $url }, geben Sie den unten stehenden Code ein und genehmigen Sie Loadstone. Dieses Fenster schließt sich automatisch, wenn Sie fertig sind.
gui-sign-in-code-expired = Der Anmeldecode ist abgelaufen, bevor er eingegeben wurde. Bitte beginnen Sie erneut.
# $account is the account's name.
gui-status-signed-in = Angemeldet als { $account }.
gui-signed-in = Bei { $site } angemeldet als { $account }.
gui-signed-in-title = Angemeldet
gui-sign-in-failed-title = Anmeldung fehlgeschlagen
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Jetzt mit einem Konto anmelden, das darauf zugreifen kann?
gui-offer-sign-in-title = Zum Fortfahren anmelden

## Startup

gui-startup-error-title = Fehler beim Start von Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone Mod Manager

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = { $version } installiert
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = { $version } installiert (Kanal { $channel })
page-catalog-not-installed = Nicht installiert
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] { $version } installiert für { $count } Kopie
   *[other] { $version } installiert für { $count } Kopien
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Installiert für { $count } Kopie (unterschiedliche Versionen)
   *[other] Installiert für { $count } Kopien (unterschiedliche Versionen)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Außerhalb von Loadstone installiert
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Installiert, aber in keiner der konfigurierten Registries aufgeführt.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (Vorschau für Tester)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Keine Registries konfiguriert; es werden nur installierte Mods angezeigt.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] { $count } Mod, die auf diesem Computer nicht verfügbar ist, wird ausgeblendet.
   *[other] { $count } Mods, die auf diesem Computer nicht verfügbar sind, werden ausgeblendet.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Registries konnten nicht geladen werden: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = In den konfigurierten Registries nicht gefunden: { $error }
page-note-no-release-metadata = Das neueste veröffentlichte Release hat noch keine Loadstone-Metadaten, daher konnte die neueste Version nicht ermittelt werden.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Hinweis: Die Kopien von { $game } teilen sich einen Mod-Ordner. Wenn Sie eine Mod für eine Kopie installieren oder deinstallieren, wirkt sich das auch auf die anderen aus; nur der Mod-Loader ist für jede Kopie getrennt.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Benötigt { $name } (wird automatisch installiert, derzeit { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Benötigt { $name } (wird automatisch installiert).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = { $version } installiert (Entwicklungskanal).
page-status-up-to-date = Aktuell (Version { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Aktuell (Version { $version }, neuer als das neueste Release { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Update verfügbar: { $version } auf { $latest }.
page-status-installed = { $version } installiert.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Außerhalb von Loadstone installiert (Version unbekannt). Installieren Sie Version { $latest }, damit Loadstone diese Kopie verwalten kann.
page-status-foreign = Außerhalb von Loadstone installiert (Version unbekannt). Installieren Sie die Mod, damit Loadstone diese Kopie verwalten kann.
page-status-ready = Bereit zur Installation von Version { $latest }.
page-status-not-installed = Nicht installiert.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Auf diesem Computer nicht verfügbar. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Bereit zur Installation von Version { $latest }. Spielordner nicht gefunden; wählen Sie ihn mit „Durchsuchen“ aus.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Nicht installiert. Spielordner nicht gefunden; wählen Sie ihn mit „Durchsuchen“ aus.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Wählen Sie den Ordner mit „Durchsuchen“ aus. Auf diesem Computer nicht verfügbar. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Wählen Sie den Ordner mit „Durchsuchen“ aus. Bereit zur Installation von Version { $latest }. Spielordner nicht gefunden; wählen Sie ihn mit „Durchsuchen“ aus.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Wählen Sie den Ordner mit „Durchsuchen“ aus. Nicht installiert. Spielordner nicht gefunden; wählen Sie ihn mit „Durchsuchen“ aus.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Die Einstellungen können nach der Installation bearbeitet werden.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Kopie ({ $distribution }), { $version } installiert, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Kopie ({ $distribution }), außerhalb von Loadstone installiert, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Kopie ({ $distribution }), nicht installiert, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Kopie in { $folder }, { $version } installiert
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Kopie in { $folder }, außerhalb von Loadstone installiert
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Kopie in { $folder }, nicht installiert
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Noch keine Kopie gefunden; wählen Sie den Spielordner mit „Durchsuchen“ aus.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Anderer Ordner...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Eigenständig
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Kanal { $channel } (neuester Stand des Branches { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Kanal { $channel } (Entwicklungsbuild)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (Vorabversion)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (Vorabversion)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = { $action } abgeschlossen.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = { $file } wird heruntergeladen...
page-self-update-installed = Update überprüft und installiert.
page-tester-passwords-removed = Tester-Passwörter entfernt. Mods nur für Tester und Betaversionen sind wieder ausgeblendet.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } auf { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = es sind keine Registries konfiguriert
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = für „{ $id }“ ist kein Quell-Repository bekannt
# $id is a mod id.
page-error-not-installed-no-registries = „{ $id }“ ist nicht installiert und es sind keine Registries konfiguriert
# $id is a mod id.
page-error-not-installed-unresolved = „{ $id }“ ist nicht installiert und konnte nicht aufgelöst werden
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = „{ $id }“ ist nicht installiert und konnte nicht aufgelöst werden: { $error }
page-error-tester-password-wrong = Das ist kein Tester-Passwort für eine Ihrer Registries oder deren Mods.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = der Kontospeicher ist nicht verfügbar
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = „{ $value }“ ist keine Zahl
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = keine endliche Zahl

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = Hash-Abweichung beim Artefakt für { $id }: erwartet { $expected }, erhalten { $actual }. Installation wird verweigert.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = Hash-Abweichung beim Artefakt für { $id } ({ $artifact }): erwartet { $expected }, erhalten { $actual }. Installation wird verweigert.
engine-hash-verified = Hash des Artefakts überprüft.
engine-hash-none = Für diese Quelle gibt es keinen Hash zum Überprüfen (lokale oder Entwicklungsinstallation).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Zuvor installierte Version { $version } wird entfernt ({ $count } Datei).
   *[other] Zuvor installierte Version { $version } wird entfernt ({ $count } Dateien).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Warnung: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Warnung: Die noch wiederherzustellenden Originaldateien konnten nicht erfasst werden: { $error }
engine-install-failed-rolling-back = Installation fehlgeschlagen; bisher geschriebene Dateien werden entfernt.
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } wurde installiert.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Installation abgebrochen.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = „{ $id }“ ist keine Installationsoption dieser Mod (Optionen: { $options })
engine-option-unknown-none = „{ $id }“ ist keine Installationsoption dieser Mod (Optionen: keine)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = „{ $value }“ ist keine Auswahl für { $option } (Auswahlmöglichkeiten: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = abgebrochen: keine Auswahl getroffen

## Mod settings

# { $label } is the setting's name.
engine-setting-default = Die Einstellung „{ $label }“ beginnt mit ihrem Standardwert; Sie können sie später mit dem Befehl „settings“ ändern.
# { $path } is the settings file.
engine-settings-written = Einstellungen in { $path } geschrieben.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = „{ $action }“ ist keine Aktion von { $id } (verfügbar: { $available })
engine-action-unknown-none = „{ $action }“ ist keine Aktion von { $id } (verfügbar: keine)
# { $label } is the action's name, as on its button.
engine-action-unavailable = „{ $label }“ ist derzeit nicht verfügbar (die Voraussetzung ist nicht erfüllt)
engine-action-running = „{ $label }“ wird ausgeführt...
engine-action-finished = „{ $label }“ abgeschlossen.
engine-no-launch-steps = { $id } legt für diese Plattform keine Startschritte fest
# Summary after starting the game with a mod.
engine-launched = { $id } gestartet.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } ist eine Verknüpfung in einen Entwicklungs-Checkout; über sie werden keine Dateien geändert oder entfernt. Entfernen Sie zuerst die Verknüpfung, wenn Sie hier wirklich eine verwaltete Installation möchten.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = { $path } wird nicht entfernt: außerhalb der Ordner der Mod.
engine-legacy-link = { $path } wird nicht entfernt: Der Pfad führt über eine Verknüpfung.
engine-legacy-shared = { $path } wird nicht entfernt: Ein anderes installiertes Paket verwendet die Datei.
engine-legacy-removed = Überbleibsel { $path } entfernt
# { $error } is a system error message.
engine-legacy-remove-failed = Warnung: { $path } konnte nicht entfernt werden: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Erforderliche Datei nicht gefunden: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Eine Voraussetzung des Schritts { $step } ist nicht erfüllt.
engine-step-skipped = Schritt { $step } übersprungen.
engine-cancelled-at-step = abgebrochen bei Schritt { $step }
engine-extracting = Dateien werden entpackt...
engine-placed-files = { $count ->
    [one] { $count } Datei abgelegt.
   *[other] { $count } Dateien abgelegt.
}
engine-kept-existing = Vorhandene Datei { $path } beibehalten (nicht überschrieben; sie ist möglicherweise neuer).
engine-file-created = { $path } erstellt und aktualisiert.
engine-file-updated = { $path } aktualisiert.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = abgebrochen: kein Ordner gewählt für „{ $prompt }“
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = In die Zwischenablage kopiert: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] { $count } Architektur in { $file } zusammengeführt.
   *[other] { $count } Architekturen in { $file } zusammengeführt.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = Start nicht möglich: { $path } fehlt
engine-program-start-failed = { $path } konnte nicht gestartet werden
engine-program-started = { $path } gestartet.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = { $url } konnte nicht geöffnet werden
engine-url-opened = { $url } geöffnet.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } wird noch benötigt von: { $dependents }. Deinstallieren Sie diese zuerst.
engine-removing-files = { $count ->
    [one] { $count } Datei wird entfernt.
   *[other] { $count } Dateien werden entfernt.
}
engine-purge-question = Auch gespeicherte Einstellungen entfernen?
engine-purge-done = Gespeicherte Einstellungen entfernt.
engine-dependency-unneeded = { $id } wird von keiner installierten Mod mehr benötigt; Sie können es ebenfalls deinstallieren.
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } wurde deinstalliert.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Das bereits in { $path } aufbewahrte Original wird verwendet.
engine-originals-kept = { $count ->
    [one] Kopie von { $count } Original-Spieldatei aufbewahrt.
   *[other] Kopie von { $count } Original-Spieldateien aufbewahrt.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Warnung: Das Original von { $path } konnte jetzt nicht wiederhergestellt werden ({ $error }). Es wird zurückgelegt, wenn diese Mod aktualisiert oder deinstalliert wird.
engine-original-restored = Original von { $path } wiederhergestellt.
# { $backup } is where the kept original should have been.
engine-original-missing = Warnung: Das Original von { $path } fehlt ({ $backup }); die Datei bleibt unverändert.
engine-original-changed = { $path } wurde seit der Installation dieser Mod geändert (ein Spielupdate?); die neuere Datei wird beibehalten.
engine-originals-restored = { $count ->
    [one] { $count } Original-Spieldatei wiederhergestellt.
   *[other] { $count } Original-Spieldateien wiederhergestellt.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] { $count } Original-Spieldatei konnte nicht zurückgelegt werden; schließen Sie das Spiel und versuchen Sie es erneut.
   *[other] { $count } Original-Spieldateien konnten nicht zurückgelegt werden; schließen Sie das Spiel und versuchen Sie es erneut.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Die { $distribution }-Kopie in { $path } wird aktualisiert.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = „{ $id }“ ist für mehr als eine Kopie von { $game } installiert: { $copies }. Geben Sie mit --game-dir an, welche Kopie aktualisiert werden soll.
engine-many-copies = „{ $id }“ ist für mehr als eine Kopie von { $game } installiert: { $copies }. Geben Sie mit --game-dir an, welche Kopie gemeint ist.
engine-not-game-folder = { $path } sieht nicht wie ein Ordner von { $game } aus (keine der erwarteten Dateien gefunden)
engine-game-found = { $game } gefunden in { $path }
engine-game-not-found = { $game } konnte nicht automatisch gefunden werden.
# Title of the folder picker.
engine-game-where = Wo ist { $game } installiert?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = { $game } konnte nicht automatisch gefunden werden; geben Sie --game-dir an oder wählen Sie den Ordner aus
# { $path } is a game folder.
engine-not-installed-copy = „{ $id }“ ist für die Kopie von { $game } in { $path } nicht installiert
engine-not-installed = „{ $id }“ ist für { $game } nicht installiert

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = { $name } kann auf diesem Computer nicht installiert werden. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = die { $distribution }-Kopie von { $game } wird nicht unterstützt. { $reason }
engine-distribution-untested = Hinweis: Die { $distribution }-Kopie von { $game } ist mit dieser Mod nicht getestet.
engine-no-matching-artifact = kein Release-Artefakt passt zu dieser Plattform/Architektur/Distribution
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Diese Mod ist nur für { $platform } verfügbar.
engine-platform-only-two = Diese Mod ist nur für { $first } und { $second } verfügbar.
engine-platform-only-three = Diese Mod ist nur für { $first }, { $second } und { $third } verfügbar.
engine-platform-needs-apple-silicon = Unter { $platform } benötigt diese Mod einen Apple-Silicon-Prozessor.
engine-platform-needs-arm = Unter { $platform } benötigt diese Mod einen ARM-Prozessor.
engine-platform-needs-x64 = Unter { $platform } benötigt diese Mod einen Intel- oder AMD-Prozessor.
engine-game-platform-unsupported = { $game } wird hier unter { $platform } nicht unterstützt.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } ist aktuell ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } ist aktuell ({ $installed } ist neuer als das neueste Release { $latest }).
engine-installed-newer = { $name } { $installed } ist installiert und damit neuer als das neueste Release, das Ihnen derzeit zur Verfügung steht ({ $latest }). Es wurde nichts geändert. Um eine ältere Version zu installieren, wählen Sie diese Version ausdrücklich aus.
# { $from } and { $to } are versions.
engine-updating = { $name } wird aktualisiert: { $from } -> { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    { $name } vom neuesten Stand des Branches { $branch } ({ $version }) installieren?

    Entwicklungsbuilds sind nicht per Hash gesichert; Sie vertrauen dem aktuellen Inhalt des Repositorys.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Versionshinweise für { $name } { $version }:

    { $notes }

    Jetzt installieren?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Informationen zum Release { $tag } werden von { $source } abgerufen...
engine-fetching-latest = Informationen zum neuesten Release werden von { $source } abgerufen...
engine-using-local-artifact = Lokales Artefakt { $path } wird verwendet
# { $file } is a download's file name.
engine-using-cached = Die bereits heruntergeladene Datei { $file } wird verwendet.
engine-downloading = { $file } wird heruntergeladen...
engine-dependency-present = Abhängigkeit { $id } { $version } ist bereits installiert.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Abhängigkeit { $name } { $version } wird installiert ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = kein Token angegeben
core-sign-in-cancelled = Anmeldung abgebrochen.
core-sign-in-expired = Der Anmeldecode ist abgelaufen, bevor er eingegeben wurde. Bitte beginnen Sie erneut.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = „{ $pattern }“ ist weder eine Quelle (github:owner/repo) noch ein Besitzer-Platzhalter (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = das Token konnte nicht im Anmeldeinformationsspeicher des Systems gespeichert werden
core-secrets-remove-failed = das Token konnte nicht aus dem Anmeldeinformationsspeicher des Systems entfernt werden

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = Release { $tag } von { $source } hat keine Datei { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = das neueste Release von { $source } hat keine Datei { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = Release { $tag } hat keine Datei loadstone-release.json (oder sie ist nicht erreichbar)
core-github-sign-in-cancelled = Die Anmeldung wurde auf GitHub abgebrochen.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub hat die Anmeldung abgelehnt: { $details }
core-github-sign-in-refused-no-details = GitHub hat die Anmeldung abgelehnt: keine Details angegeben
core-github-token-rejected = GitHub hat das Token nicht akzeptiert

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } unterstützt keine Anmeldung
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = „{ $source }“ ist keine Quelle im Format { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } wurde nicht gefunden. Wenn es ein privates Repository ist, melden Sie sich mit einem Konto an, das darauf zugreifen kann (Loadstone-Einstellungen), oder setzen Sie GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = das Token von { $account } wurde abgelehnt; es ist möglicherweise abgelaufen oder wurde widerrufen
core-source-token-unreachable = { $source } ist mit dem Token von { $account } nicht erreichbar

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = Download von { $url } lieferte HTTP { $status }
core-fetch-request-failed = Anfrage fehlgeschlagen: { $url }
core-fetch-download-failed = Download fehlgeschlagen: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = Lesefehler
core-fetch-read-error-download = Lesefehler beim Download

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = für diese Plattform/Distribution gilt kein Entpackweg
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } ist eine Verknüpfung in einen Entwicklungs-Checkout. Aktualisieren Sie diesen Checkout stattdessen mit git, oder entfernen Sie die Verknüpfung vor der Installation.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = dieses Archiv enthält nicht den erwarteten Inhalt (kein Eintrag passt zu einem Entpackweg)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = die Registry „{ $source }“ ist weder { $formats } noch ein vorhandener Ordner
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } hat keinen Ordner loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = { $source } konnte nicht aktualisiert werden ({ $error }); die zwischengespeicherte Kopie wird verwendet.
core-registry-fetch-failed = die Registry { $source } konnte nicht abgerufen werden
# $id is a mod's id.
core-registry-package-not-found = das Paket „{ $id }“ wurde in keiner Registry gefunden

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = „{ $key }“ ist ein Wahrheitswert; verwenden Sie true oder false
core-setting-not-number = „{ $key }“ erfordert eine Zahl
core-setting-too-small = „{ $key }“ muss mindestens { $min } sein
core-setting-too-large = „{ $key }“ darf höchstens { $max } sein
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = „{ $key }“ muss einer der folgenden Werte sein: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Testerzugang für die Mods einer Registry freigeschaltet: Mods nur für Tester werden angezeigt, und Installationen und Updates erhalten Betaversionen.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Testerzugang für die Mods einer Registry und für { $mods } freigeschaltet: Mods nur für Tester werden angezeigt, und Installationen und Updates erhalten Betaversionen.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Testerzugang für { $mods } freigeschaltet: Mods nur für Tester werden angezeigt, und Installationen und Updates erhalten Betaversionen.
core-tester-save-failed = das Tester-Passwort konnte nicht gespeichert werden
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = Release { $tag } hat keine verwendbaren Loadstone-Metadaten ({ $error }); das neueste stabile Release wird verwendet.
core-tester-beta-lookup-failed = Betaversionen konnten nicht abgefragt werden ({ $error }); das neueste stabile Release wird verwendet.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = das heruntergeladene Update hat die Hash-Prüfung nicht bestanden (erwartet { $expected }, erhalten { $actual }); nicht installiert
core-update-translocated = macOS führt diese App aus einer temporären, schreibgeschützten Kopie aus, daher kann sie sich nicht selbst aktualisieren. Verschieben Sie sie in Ihren Ordner „Programme“, öffnen Sie sie von dort und aktualisieren Sie erneut.
core-update-on-disk-image = diese App wird von ihrem Disk-Image ausgeführt, daher kann sie sich nicht selbst aktualisieren. Kopieren Sie sie in Ihren Ordner „Programme“, öffnen Sie sie von dort und aktualisieren Sie erneut.
# $path is the folder the app is in.
core-update-no-write = neben { $path } kann nicht geschrieben werden (fehlende Berechtigung?), daher kann sich die App nicht selbst aktualisieren. Laden Sie die neue Version stattdessen von der Release-Seite herunter.
core-update-no-staging = neben { $path } kann nicht geschrieben werden (fehlende Berechtigung?). Laden Sie die neue Version stattdessen von der Release-Seite herunter
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = das Update ist eine andere App ({ $got }, erwartet { $expected }); nicht installiert
core-update-move-aside-app = die aktuelle App konnte nicht beiseitegeschoben werden
core-update-move-in-app = die neue App konnte nicht an ihren Platz verschoben werden
core-update-move-aside-exe = die aktuelle ausführbare Datei konnte nicht beiseitegeschoben werden
core-update-move-in-exe = die neue ausführbare Datei konnte nicht an ihren Platz verschoben werden

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = &OK
gui-stock-ok-plain = OK
gui-stock-cancel = &Abbrechen
gui-stock-cancel-plain = Abbrechen
gui-stock-yes = &Ja
gui-stock-yes-plain = Ja
gui-stock-no = &Nein
gui-stock-no-plain = Nein
gui-stock-close = &Schließen
gui-stock-close-plain = Schließen
