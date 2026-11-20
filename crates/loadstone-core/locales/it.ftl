# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Questa mod richiede una versione più recente di Loadstone. Aggiorna Loadstone e riprova.

## Loadstone settings

pref-language = Lingua
pref-language-description = La lingua in cui vengono mostrati Loadstone e le mod tradotte.
language-system = Predefinita di sistema
pref-accounts = Account
pref-accounts-description = Accessi usati per scaricare mod da repository privati.
pref-account-rules = Regole account
pref-account-rules-description = Quale account usare per un repository o un proprietario.
pref-try-other-accounts = Prova i miei altri account quando un download viene rifiutato
pref-try-other-accounts-description = Se un repository non viene trovato o l'accesso viene negato, prova gli altri account per quel sito prima di rinunciare.
pref-tester-passwords = Password tester
pref-tester-passwords-description = Sbloccano le mod riservate ai tester e le versioni beta, per un registro o per singole mod. Si impostano con il pulsante Password tester.
pref-download-account = Account per il download
pref-download-account-description = L'account usato per scaricare questa mod. Automatico usa le tue regole account e l'account predefinito.
pref-download-account-automatic = Automatico (regole account, poi l'account predefinito)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Impostazioni di Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Account per i repository privati e opzioni di Loadstone
gui-menu-exit = &Esci
# Menu bar title.
gui-menu-tools = &Strumenti
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Un'operazione è ancora in corso. Se chiudi ora, potrebbe rimanere incompleta. Chiudere comunque?
gui-close-while-running-title = Operazione in corso
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Caricamento...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problema durante l'operazione
gui-button-retry = &Riprova
gui-button-skip = &Salta
gui-button-cancel-problem = &Annulla
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Opzioni di installazione

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (core { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mod:
# Button that opens the selected mod's page.
gui-button-details = &Dettagli
gui-button-refresh = &Ricarica
gui-button-loadstone-settings = Impostazioni di &Loadstone...
gui-status-fetching-catalog = Recupero del catalogo delle mod...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Caricamento dell'elenco delle mod...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Impossibile caricare l'elenco delle mod. Premi Ricarica per riprovare.
gui-status-catalog-failed = Recupero del catalogo non riuscito.
gui-catalog-error-title = Impossibile caricare il catalogo delle mod
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Nessuna mod disponibile.
gui-status-catalog-loaded = { $count ->
    [one] Catalogo caricato: { $count } mod.
   *[other] Catalogo caricato: { $count } mod.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Caricamento di { $mod_id }...
gui-status-mod-load-failed = Impossibile caricare la pagina della mod.
gui-mod-error-title = Impossibile caricare la mod
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Copia del gioco da gestire:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Copia di { $game } da gestire:
gui-button-back = &Torna all'elenco delle mod
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name } di { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = Cartella del &gioco:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = Ca&rtella di { $game }:
gui-button-browse = &Sfoglia...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Seleziona la cartella del gioco
gui-browse-game-prompt-named = Seleziona la cartella di { $game }
gui-description-label = Descrizione:
# Label of the log where operations report their progress.
gui-activity-label = Attività:
gui-button-update = &Aggiorna
gui-button-install = &Installa
gui-select-folder-first = Prima seleziona la cartella del gioco con Sfoglia.
gui-button-install-from-file = Installa da &file...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Seleziona il file loadstone-release.json della mod
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|File JSON (*.json)|*.json|Tutti i file (*.*)|*.*
gui-button-uninstall = &Disinstalla
gui-button-launch = A&vvia il gioco
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Avvia il gioco con la mod caricata.
gui-launch-unavailable-description = Disponibile dopo aver installato la mod qui.
gui-button-change-options = Modifica &opzioni di installazione...
gui-change-options-description = Ripropone le domande di installazione della mod e reinstalla la versione più recente con le tue risposte.
gui-button-settings = Im&postazioni...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Operazione in corso... { $percent }%
gui-status-fetching-releases = Recupero dell'elenco delle versioni...
# $error is an error message.
gui-release-list-error = Impossibile recuperare l'elenco delle versioni: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Installare invece l'ultima versione pubblicata?
gui-release-list-error-title = Elenco delle versioni non disponibile
gui-no-releases = Il repository di questa mod non ha ancora versioni pubblicate.
gui-no-releases-title = Nessuna versione pubblicata
gui-choose-version = Seleziona la versione da installare:
gui-choose-version-title = Scegli la versione
gui-confirm-uninstall = Disinstallare { $name }?
gui-confirm-uninstall-title = Conferma disinstallazione
gui-status-working = Operazione in corso...
gui-status-op-failed = L'operazione non è riuscita.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Impossibile avviare
gui-op-failed-title = Operazione non riuscita
# Title of the message shown when an operation finished.
gui-op-done-title = Fatto

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = È disponibile la versione { $version } di { $app } (hai la { $current }). Aggiornare e riavviare ora?
gui-self-update-title = Aggiornamento disponibile
gui-status-downloading-update = Download dell'aggiornamento...
gui-status-update-failed = L'aggiornamento non è riuscito.
gui-update-failed-title = Aggiornamento non riuscito
gui-status-update-installed = Aggiornamento installato.
gui-update-installed = L'aggiornamento è stato installato. L'app verrà riavviata.
gui-update-installed-title = Aggiornamento installato

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Impostazioni di Loadstone non disponibili: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Impostazioni di { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Opzioni della mod
gui-mod-options-after-install = Le opzioni della mod saranno disponibili dopo l'installazione.
gui-status-setting-saved = Impostazione salvata.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Impostazione salvata. { $note }
gui-setting-not-changed-title = Impostazione non modificata
gui-status-no-settings-changed = Nessuna impostazione modificata.

## Loadstone settings dialog

gui-loadstone-settings-title = Impostazioni di Loadstone
gui-accounts-label = A&ccount:
gui-accounts-description = Accessi usati per scaricare mod da repository privati.
gui-button-sign-in = &Accedi...
gui-button-add-token = Aggiungi &token...
gui-button-remove-account = &Rimuovi account
gui-button-set-default = Imposta come pre&definito
# "gh auth token" is a command, keep it.
gui-add-token-description = Aggiungi un account da un token che hai già, ad esempio quello ottenuto con il comando gh auth token della CLI di GitHub.
gui-rules-label = Re&gole account:
gui-rules-description = Quale account usare per un repository o per tutti i repository di un proprietario. Senza una regola, viene usato l'account predefinito.
gui-button-add-rule = Aggiungi r&egola...
gui-button-remove-rule = Rimuo&vi regola
gui-button-tester-password = &Password tester...
gui-tester-password-description = Per i tester privati: inserisci la password che ti è stata data per vedere le mod riservate ai tester e ricevere le versioni beta. Puoi aggiungerne più di una. Lascia il campo vuoto per smettere di fare il tester.
gui-tester-password-prompt-saved = Hai delle password tester salvate. Inseriscine un'altra per aggiungerla, oppure lascia il campo vuoto per dimenticarle tutte e smettere di fare il tester.
gui-tester-password-prompt = Inserisci la password tester che ti è stata data.
gui-tester-password-title = Password tester
gui-tester-password-not-saved-title = Password tester non salvata
gui-button-close = C&hiudi
gui-accounts-unavailable-title = Account non disponibili
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } su { $site }, predefinito
    [missing] { $account }, { $username } su { $site }, token mancante (accedi di nuovo)
    [default-missing] { $account }, { $username } su { $site }, predefinito, token mancante (accedi di nuovo)
   *[none] { $account }, { $username } su { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Nessun account. Usa Accedi per aggiungerne uno.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } usa { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Nessuna regola.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Incolla un token di { $site }. Verrà verificato con { $site } e poi salvato in Gestione credenziali di Windows.
gui-add-token-title = Aggiungi token
gui-status-account-added = Account { $account } aggiunto.
gui-token-not-added-title = Token non aggiunto
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Rimuovere l'account { $account }? Loadstone dimenticherà il suo token e tutte le regole che lo usano. Per revocare anche l'accesso di Loadstone, usa Applications nelle impostazioni di { $site }.
gui-remove-account-title = Rimuovi account
gui-account-not-removed-title = Account non rimosso
gui-default-not-changed-title = Account predefinito non modificato
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Repository (github:owner/repo) o tutti i repository di un proprietario (github:owner/*):
gui-add-rule-title = Aggiungi regola account
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Quale account usare?
gui-rule-not-added-title = Regola non aggiunta
gui-rule-not-removed-title = Regola non rimossa

## Signing in

gui-sign-in-no-sites = Nessun sito supporta l'accesso.
gui-sign-in-title = Accedi
gui-sign-in-which-site = A quale sito vuoi accedere?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Accedi a { $site }
gui-sign-in-requesting = Richiesta di un codice di accesso a { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &Codice di accesso:
gui-button-copy-code = Co&pia codice
gui-button-open-sign-in-page = &Apri la pagina di accesso di { $site }
gui-button-cancel = Annulla
gui-sign-in-code-copied = Codice copiato. Apri la pagina di accesso e incollalo lì.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Apri { $url }, inserisci il codice qui sotto e autorizza Loadstone. Questa finestra si chiuderà da sola quando avrai finito.
gui-sign-in-code-expired = Il codice di accesso è scaduto prima di essere inserito. Ricomincia.
# $account is the account's name.
gui-status-signed-in = Accesso effettuato come { $account }.
gui-signed-in = Accesso a { $site } effettuato come { $account }.
gui-signed-in-title = Accesso effettuato
gui-sign-in-failed-title = Accesso non riuscito
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Accedere ora con un account autorizzato?
gui-offer-sign-in-title = Accedi per continuare

## Startup

gui-startup-error-title = Errore di avvio di Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Gestore di mod Loadstone

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Installata: { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Installata: { $version } (canale { $channel })
page-catalog-not-installed = Non installata
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Installata: { $version } su { $count } copia
   *[other] Installata: { $version } su { $count } copie
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Installata su { $count } copia (versioni diverse)
   *[other] Installata su { $count } copie (versioni diverse)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Installata al di fuori di Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Installata, ma non più presente nei registri configurati.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (anteprima per tester)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Nessun registro configurato; vengono mostrate solo le mod installate.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] { $count } mod non disponibile per questo computer è nascosta.
   *[other] { $count } mod non disponibili per questo computer sono nascoste.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Impossibile caricare i registri: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Non trovata nei registri configurati: { $error }
page-note-no-release-metadata = L'ultima versione pubblicata non ha ancora metadati di Loadstone, quindi non è stato possibile determinare la versione più recente.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Nota: le copie di { $game } condividono un'unica cartella delle mod. Installare o disinstallare una mod per una copia ha effetto anche sulle altre; solo il mod loader è separato per ogni copia.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Richiede { $name } (installato automaticamente, versione attuale { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Richiede { $name } (installato automaticamente).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Versione { $version } installata (canale dev).
page-status-up-to-date = Aggiornata (versione { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Aggiornata (versione { $version }, più recente dell'ultima versione pubblicata, { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Aggiornamento disponibile: da { $version } a { $latest }.
page-status-installed = Versione { $version } installata.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Installata al di fuori di Loadstone (versione sconosciuta). Installa la versione { $latest } per far gestire questa copia a Loadstone.
page-status-foreign = Installata al di fuori di Loadstone (versione sconosciuta). Installala per far gestire questa copia a Loadstone.
page-status-ready = Pronta per l'installazione della versione { $latest }.
page-status-not-installed = Non installata.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Non disponibile su questo computer. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Pronta per l'installazione della versione { $latest }. Cartella del gioco non trovata; selezionala con Sfoglia.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Non installata. Cartella del gioco non trovata; selezionala con Sfoglia.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Seleziona la cartella con Sfoglia. Non disponibile su questo computer. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Seleziona la cartella con Sfoglia. Pronta per l'installazione della versione { $latest }. Cartella del gioco non trovata; selezionala con Sfoglia.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Seleziona la cartella con Sfoglia. Non installata. Cartella del gioco non trovata; selezionala con Sfoglia.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Le impostazioni saranno modificabili dopo l'installazione.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Copia { $distribution }, versione { $version } installata, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Copia { $distribution }, mod installata al di fuori di Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Copia { $distribution }, mod non installata, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Copia in { $folder }, versione { $version } installata
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Copia in { $folder }, mod installata al di fuori di Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Copia in { $folder }, mod non installata
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Nessuna copia trovata per ora; seleziona la cartella del gioco con Sfoglia.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Un'altra cartella...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Autonoma
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Canale { $channel } (ultima versione dal ramo { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Canale { $channel } (build di sviluppo)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (versione preliminare)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (versione preliminare)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Azione "{ $action }" completata.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Download di { $file }...
page-self-update-installed = Aggiornamento verificato e installato.
page-tester-passwords-removed = Password tester rimosse. Le mod riservate ai tester e le versioni beta sono di nuovo nascoste.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } su { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = nessun registro configurato
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = nessun repository di origine noto per "{ $id }"
# $id is a mod id.
page-error-not-installed-no-registries = "{ $id }" non è installato e non ci sono registri configurati
# $id is a mod id.
page-error-not-installed-unresolved = "{ $id }" non è installato e non è stato possibile trovarlo
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = "{ $id }" non è installato e non è stato possibile trovarlo: { $error }
page-error-tester-password-wrong = Non è una password tester per nessuno dei tuoi registri o delle loro mod.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = l'archivio degli account non è disponibile
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = "{ $value }" non è un numero
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = non è un numero finito

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = l'hash del file di { $id } non corrisponde: previsto { $expected }, ottenuto { $actual }. Installazione rifiutata.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = l'hash del file di { $id } ({ $artifact }) non corrisponde: previsto { $expected }, ottenuto { $actual }. Installazione rifiutata.
engine-hash-verified = Hash del file verificato.
engine-hash-none = Nessun hash da verificare per questa origine (installazione locale o di sviluppo).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Rimozione della versione { $version } installata in precedenza ({ $count } file).
   *[other] Rimozione della versione { $version } installata in precedenza ({ $count } file).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Avviso: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Avviso: impossibile registrare gli originali ancora da ripristinare: { $error }
engine-install-failed-rolling-back = Installazione non riuscita; rimozione dei file scritti finora.
# Summary shown when an install or update finishes.
engine-installed = Installazione di { $name } { $version } completata.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Installazione annullata.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = "{ $id }" non è un'opzione di installazione di questa mod (opzioni: { $options })
engine-option-unknown-none = "{ $id }" non è un'opzione di installazione di questa mod (opzioni: nessuna)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = "{ $value }" non è una scelta valida per { $option } (scelte: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = annullato: nessuna scelta effettuata

## Mod settings

# { $label } is the setting's name.
engine-setting-default = L'impostazione "{ $label }" parte dal valore predefinito; potrai cambiarla in seguito con il comando delle impostazioni.
# { $path } is the settings file.
engine-settings-written = Impostazioni scritte in { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = "{ $action }" non è un'azione di { $id } (disponibili: { $available })
engine-action-unknown-none = "{ $action }" non è un'azione di { $id } (disponibili: nessuna)
# { $label } is the action's name, as on its button.
engine-action-unavailable = "{ $label }" non è disponibile al momento (la sua condizione preliminare non è soddisfatta)
engine-action-running = Esecuzione di "{ $label }"...
engine-action-finished = Azione "{ $label }" completata.
engine-no-launch-steps = { $id } non dichiara passaggi di avvio per questa piattaforma
# Summary after starting the game with a mod.
engine-launched = { $id }: gioco avviato.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } è un collegamento a una copia di lavoro di sviluppo; Loadstone non modificherà né rimuoverà file attraverso di esso. Rimuovi prima il collegamento se vuoi davvero un'installazione gestita qui.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = { $path } non rimosso: si trova al di fuori delle cartelle della mod.
engine-legacy-link = { $path } non rimosso: vi si accede tramite un collegamento.
engine-legacy-shared = { $path } non rimosso: lo usa un altro pacchetto installato.
engine-legacy-removed = File residuo { $path } rimosso
# { $error } is a system error message.
engine-legacy-remove-failed = Avviso: impossibile rimuovere { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = File necessario non trovato: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Un requisito del passaggio { $step } non è soddisfatto.
engine-step-skipped = Passaggio { $step } saltato.
engine-cancelled-at-step = annullato al passaggio { $step }
engine-extracting = Estrazione dei file...
engine-placed-files = { $count ->
    [one] { $count } file copiato.
   *[other] { $count } file copiati.
}
engine-kept-existing = { $path } esistente mantenuto (non sovrascritto; potrebbe essere più recente).
engine-file-created = { $path } creato e aggiornato.
engine-file-updated = { $path } aggiornato.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = annullato: nessuna cartella scelta per "{ $prompt }"
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Copiato negli appunti: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] { $count } architettura combinata in { $file }.
   *[other] { $count } architetture combinate in { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = impossibile avviare: { $path } non trovato
engine-program-start-failed = impossibile avviare { $path }
engine-program-started = { $path } avviato.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = impossibile aprire { $url }
engine-url-opened = { $url } aperto.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } serve ancora a: { $dependents }. Disinstalla prima questi pacchetti.
engine-removing-files = { $count ->
    [one] Rimozione di { $count } file.
   *[other] Rimozione di { $count } file.
}
engine-purge-question = Rimuovere anche le impostazioni e le preferenze salvate?
engine-purge-done = Impostazioni salvate rimosse.
engine-dependency-unneeded = { $id } non è più necessario a nessuna mod installata; puoi disinstallare anche questo pacchetto.
# Summary when an uninstall finishes.
engine-uninstalled = Disinstallazione di { $id } { $version } completata.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Uso dell'originale già conservato in { $path }.
engine-originals-kept = { $count ->
    [one] Conservata una copia di { $count } file originale del gioco.
   *[other] Conservata una copia di { $count } file originali del gioco.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Avviso: impossibile ripristinare ora l'originale di { $path } ({ $error }). Verrà rimesso al suo posto quando questa mod verrà aggiornata o disinstallata.
engine-original-restored = Originale di { $path } ripristinato.
# { $backup } is where the kept original should have been.
engine-original-missing = Avviso: l'originale di { $path } manca ({ $backup }); il file viene lasciato così com'è.
engine-original-changed = { $path } è cambiato dopo l'installazione di questa mod (un aggiornamento del gioco?); viene mantenuto il file più recente.
engine-originals-restored = { $count ->
    [one] { $count } file originale del gioco ripristinato.
   *[other] { $count } file originali del gioco ripristinati.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] impossibile ripristinare { $count } file originale del gioco; chiudi il gioco e riprova.
   *[other] impossibile ripristinare { $count } file originali del gioco; chiudi il gioco e riprova.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Aggiornamento della copia { $distribution } in { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = "{ $id }" è installato su più di una copia di { $game }: { $copies }. Usa --game-dir per indicare quale copia aggiornare.
engine-many-copies = "{ $id }" è installato su più di una copia di { $game }: { $copies }. Usa --game-dir per indicare quale copia.
engine-not-game-folder = { $path } non sembra una cartella di { $game } (nessuno dei file previsti è stato trovato)
engine-game-found = { $game } trovato in { $path }
engine-game-not-found = Impossibile trovare { $game } automaticamente.
# Title of the folder picker.
engine-game-where = Dove è installato { $game }?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = impossibile trovare { $game } automaticamente; usa --game-dir o seleziona la sua cartella
# { $path } is a game folder.
engine-not-installed-copy = "{ $id }" non è installato sulla copia di { $game } in { $path }
engine-not-installed = "{ $id }" non è installato per { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = Impossibile installare { $name } su questo computer. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = la copia { $distribution } di { $game } non è supportata. { $reason }
engine-distribution-untested = Nota: la copia { $distribution } di { $game } non è stata testata con questa mod.
engine-no-matching-artifact = nessun file della versione pubblicata corrisponde a questa piattaforma, architettura o distribuzione
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Questa mod è disponibile solo su { $platform }.
engine-platform-only-two = Questa mod è disponibile solo su { $first } e { $second }.
engine-platform-only-three = Questa mod è disponibile solo su { $first }, { $second } e { $third }.
engine-platform-needs-apple-silicon = Su { $platform }, questa mod richiede un processore Apple Silicon.
engine-platform-needs-arm = Su { $platform }, questa mod richiede un processore ARM.
engine-platform-needs-x64 = Su { $platform }, questa mod richiede un processore Intel o AMD.
engine-game-platform-unsupported = { $game } non è supportato su { $platform } qui.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = Nessun aggiornamento necessario per { $name } ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = Nessun aggiornamento necessario per { $name } (la versione { $installed } è più recente dell'ultima versione pubblicata, { $latest }).
engine-installed-newer = È installata la versione { $installed } di { $name }, più recente dell'ultima versione pubblicata a cui hai accesso ora ({ $latest }). Non è stato modificato nulla. Per installare una versione precedente, scegli esplicitamente quella versione.
# { $from } and { $to } are versions.
engine-updating = Aggiornamento di { $name } da { $from } a { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Installare { $name } dall'ultimo commit del ramo { $branch } ({ $version })?

    Le build di sviluppo non sono vincolate a un hash; ti stai fidando del contenuto attuale del repository.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Note di rilascio di { $name } { $version }:

    { $notes }

    Installare ora?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Recupero delle informazioni sulla versione { $tag } da { $source }...
engine-fetching-latest = Recupero delle informazioni sull'ultima versione pubblicata da { $source }...
engine-using-local-artifact = Uso del file locale { $path }
# { $file } is a download's file name.
engine-using-cached = Uso di { $file }, già scaricato.
engine-downloading = Download di { $file }...
engine-dependency-present = Dipendenza { $id } { $version } già installata.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Installazione della dipendenza { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = nessun token fornito
core-sign-in-cancelled = Accesso annullato.
core-sign-in-expired = Il codice di accesso è scaduto prima di essere inserito. Ricomincia.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = "{ $pattern }" non è un'origine (github:owner/repo) né un carattere jolly per proprietario (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = impossibile salvare il token nell'archivio credenziali di sistema
core-secrets-remove-failed = impossibile rimuovere il token dall'archivio credenziali di sistema

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = la versione { $tag } di { $source } non contiene il file { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = l'ultima versione di { $source } non contiene il file { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = la versione { $tag } non contiene il file loadstone-release.json (o non è raggiungibile)
core-github-sign-in-cancelled = L'accesso è stato annullato su GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub ha rifiutato l'accesso: { $details }
core-github-sign-in-refused-no-details = GitHub ha rifiutato l'accesso senza fornire dettagli
core-github-token-rejected = GitHub non ha accettato il token

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } non supporta l'accesso
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = "{ $source }" non è un'origine nel formato { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } non trovato. Se è un repository privato, accedi con un account che vi ha accesso (Impostazioni di Loadstone) oppure imposta GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = il token di { $account } è stato rifiutato; potrebbe essere scaduto o revocato
core-source-token-unreachable = { $source } non è raggiungibile con il token di { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = il download di { $url } ha restituito il codice HTTP { $status }
core-fetch-request-failed = richiesta non riuscita: { $url }
core-fetch-download-failed = download non riuscito: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = errore di lettura
core-fetch-read-error-download = errore di lettura durante il download

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = nessun metodo di estrazione valido per questa piattaforma o distribuzione
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } è un collegamento a una copia di lavoro di sviluppo. Aggiorna quella copia con git, oppure rimuovi il collegamento prima di installare.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = questo archivio non contiene i file previsti (nessuna voce corrisponde a un metodo di estrazione)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = il registro "{ $source }" non è nel formato { $formats } né è una cartella esistente
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } non ha una cartella loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = Impossibile aggiornare { $source } ({ $error }); uso della copia nella cache.
core-registry-fetch-failed = impossibile recuperare il registro { $source }
# $id is a mod's id.
core-registry-package-not-found = pacchetto "{ $id }" non trovato in nessun registro

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = "{ $key }" è un valore booleano; usa true o false
core-setting-not-number = "{ $key }" richiede un numero
core-setting-too-small = "{ $key }" deve essere almeno { $min }
core-setting-too-large = "{ $key }" deve essere al massimo { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = "{ $key }" deve essere uno tra: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Accesso tester sbloccato per le mod di un registro: le mod riservate ai tester vengono mostrate e installazioni e aggiornamenti ricevono le versioni beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Accesso tester sbloccato per le mod di un registro e per { $mods }: le mod riservate ai tester vengono mostrate e installazioni e aggiornamenti ricevono le versioni beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Accesso tester sbloccato per { $mods }: le mod riservate ai tester vengono mostrate e installazioni e aggiornamenti ricevono le versioni beta.
core-tester-save-failed = impossibile salvare la password tester
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = La versione { $tag } non ha metadati di Loadstone utilizzabili ({ $error }); uso dell'ultima versione stabile.
core-tester-beta-lookup-failed = Impossibile cercare le versioni beta ({ $error }); uso dell'ultima versione stabile.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = l'aggiornamento scaricato non ha superato la verifica dell'hash (previsto { $expected }, ottenuto { $actual }); non installato
core-update-translocated = macOS sta eseguendo questa app da una copia temporanea di sola lettura, quindi non può aggiornarsi. Spostala nella cartella Applicazioni, aprila da lì e ripeti l'aggiornamento.
core-update-on-disk-image = questa app è in esecuzione dalla sua immagine disco, quindi non può aggiornarsi. Copiala nella cartella Applicazioni, aprila da lì e ripeti l'aggiornamento.
# $path is the folder the app is in.
core-update-no-write = impossibile scrivere accanto a { $path } (permessi mancanti?), quindi l'app non può aggiornarsi. Scarica invece la nuova versione dalla pagina della versione pubblicata.
core-update-no-staging = impossibile scrivere accanto a { $path } (permessi mancanti?). Scarica invece la nuova versione dalla pagina della versione pubblicata
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = l'aggiornamento è un'app diversa ({ $got }, prevista { $expected }); non installato
core-update-move-aside-app = impossibile spostare altrove l'app attuale
core-update-move-in-app = impossibile mettere al suo posto la nuova app
core-update-move-aside-exe = impossibile spostare altrove l'eseguibile attuale
core-update-move-in-exe = impossibile mettere al suo posto il nuovo eseguibile
