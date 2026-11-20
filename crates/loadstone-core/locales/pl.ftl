# Loadstone's interface text, Polish.
# Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Ten mod wymaga nowszej wersji programu Loadstone. Zaktualizuj Loadstone i spróbuj ponownie.

## Loadstone settings

pref-language = Język
pref-language-description = Język, w którym wyświetlane są Loadstone i przetłumaczone mody.
language-system = Domyślny język systemu
pref-accounts = Konta
pref-accounts-description = Konta używane do pobierania modów z prywatnych repozytoriów.
pref-account-rules = Reguły kont
pref-account-rules-description = Które konto ma być używane dla danego repozytorium lub właściciela.
pref-try-other-accounts = Próbuj innych moich kont, gdy pobieranie zostanie odrzucone
pref-try-other-accounts-description = Jeśli repozytorium nie zostanie znalezione lub dostęp zostanie odmówiony, przed rezygnacją zostaną wypróbowane inne konta dla tego serwisu.
pref-tester-passwords = Hasła testera
pref-tester-passwords-description = Odblokowują mody tylko dla testerów i wersje beta, dla całego rejestru lub dla pojedynczych modów. Ustawiane przyciskiem Hasło testera.
pref-download-account = Konto pobierania
pref-download-account-description = Konto używane do pobierania tego moda. Opcja Automatycznie korzysta z reguł kont i konta domyślnego.
pref-download-account-automatic = Automatycznie (reguły kont, a potem konto domyślne)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Ustawienia Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Konta dla prywatnych repozytoriów i opcje programu Loadstone
gui-menu-exit = Za&kończ
# Menu bar title.
gui-menu-tools = &Narzędzia
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Operacja nadal trwa. Zamknięcie programu teraz może pozostawić ją niedokończoną. Czy mimo to zamknąć?
gui-close-while-running-title = Operacja w toku
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Wczytywanie...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problem podczas operacji
gui-button-retry = Spróbuj &ponownie
gui-button-skip = Po&miń
gui-button-cancel-problem = &Anuluj
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Opcje instalacji

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (rdzeń { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mody:
# Button that opens the selected mod's page.
gui-button-details = &Szczegóły
gui-button-refresh = &Odśwież
gui-button-loadstone-settings = Ustawienia &Loadstone...
gui-status-fetching-catalog = Pobieranie katalogu modów...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Wczytywanie listy modów...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Nie udało się wczytać listy modów. Naciśnij Odśwież, aby spróbować ponownie.
gui-status-catalog-failed = Nie udało się pobrać katalogu.
gui-catalog-error-title = Nie udało się wczytać katalogu modów
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Brak dostępnych modów.
gui-status-catalog-loaded = { $count ->
    [one] Wczytano katalog: { $count } mod.
    [few] Wczytano katalog: { $count } mody.
    [many] Wczytano katalog: { $count } modów.
   *[other] Wczytano katalog: { $count } moda.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Wczytywanie: { $mod_id }...
gui-status-mod-load-failed = Nie udało się wczytać strony moda.
gui-mod-error-title = Nie udało się wczytać moda
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Kopia gry do zarządzania:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Kopia gry { $game } do zarządzania:
gui-button-back = &Wróć do listy modów
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }, autorstwo: { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = Folder &gry:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = Folder &gry { $game }:
gui-button-browse = &Przeglądaj...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Wybierz folder gry
gui-browse-game-prompt-named = Wybierz folder gry { $game }
gui-description-label = Opis:
# Label of the log where operations report their progress.
gui-activity-label = Aktywność:
gui-button-update = &Aktualizuj
gui-button-install = &Zainstaluj
gui-select-folder-first = Najpierw wybierz folder gry przyciskiem Przeglądaj.
gui-button-install-from-file = Zainstaluj z p&liku...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Wybierz plik loadstone-release.json moda
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|Pliki JSON (*.json)|*.json|Wszystkie pliki (*.*)|*.*
gui-button-uninstall = O&dinstaluj
gui-button-launch = Uruchom g&rę
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Uruchamia grę z wczytanym modem.
gui-launch-unavailable-description = Dostępne po zainstalowaniu moda w tym miejscu.
gui-button-change-options = Zmień &opcje instalacji...
gui-change-options-description = Ponownie zadaje pytania instalacyjne moda i instaluje od nowa najnowszą wersję z Twoimi odpowiedziami.
gui-button-settings = &Ustawienia...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Przetwarzanie... { $percent }%
gui-status-fetching-releases = Pobieranie listy wydań...
# $error is an error message.
gui-release-list-error = Nie udało się pobrać listy wydań: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Czy zamiast tego zainstalować najnowsze wydanie?
gui-release-list-error-title = Lista wydań niedostępna
gui-no-releases = Repozytorium tego moda nie ma jeszcze żadnych wydań.
gui-no-releases-title = Brak wydań
gui-choose-version = Wybierz wersję do zainstalowania:
gui-choose-version-title = Wybierz wersję
gui-confirm-uninstall = Czy odinstalować mod { $name }?
gui-confirm-uninstall-title = Potwierdź odinstalowanie
gui-status-working = Przetwarzanie...
gui-status-op-failed = Operacja nie powiodła się.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Nie można uruchomić
gui-op-failed-title = Operacja nie powiodła się
# Title of the message shown when an operation finished.
gui-op-done-title = Gotowe

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Dostępna jest wersja { $version } programu { $app } (masz wersję { $current }). Czy zaktualizować i uruchomić ponownie teraz?
gui-self-update-title = Dostępna aktualizacja
gui-status-downloading-update = Pobieranie aktualizacji...
gui-status-update-failed = Aktualizacja nie powiodła się.
gui-update-failed-title = Aktualizacja nie powiodła się
gui-status-update-installed = Zainstalowano aktualizację.
gui-update-installed = Aktualizacja została zainstalowana. Program zostanie teraz uruchomiony ponownie.
gui-update-installed-title = Zainstalowano aktualizację

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Ustawienia Loadstone są niedostępne: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Ustawienia: { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Opcje moda
gui-mod-options-after-install = Opcje moda będą dostępne po jego zainstalowaniu.
gui-status-setting-saved = Zapisano ustawienie.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Zapisano ustawienie. { $note }
gui-setting-not-changed-title = Nie zmieniono ustawienia
gui-status-no-settings-changed = Nie zmieniono żadnych ustawień.

## Loadstone settings dialog

gui-loadstone-settings-title = Ustawienia Loadstone
gui-accounts-label = &Konta:
gui-accounts-description = Konta używane do pobierania modów z prywatnych repozytoriów.
gui-button-sign-in = &Zaloguj się...
gui-button-add-token = Dodaj &token...
gui-button-remove-account = &Usuń konto
gui-button-set-default = Ustaw jako &domyślne
# "gh auth token" is a command, keep it.
gui-add-token-description = Dodaj konto z tokenu, który już masz, na przykład z polecenia gh auth token w GitHub CLI.
gui-rules-label = &Reguły kont:
gui-rules-description = Które konto ma być używane dla repozytorium lub dla wszystkich repozytoriów właściciela. Gdy nie ma reguły, używane jest konto domyślne.
gui-button-add-rule = Dodaj r&egułę...
gui-button-remove-rule = Usuń re&gułę
gui-button-tester-password = &Hasło testera...
gui-tester-password-description = Dla prywatnych testerów: wpisz otrzymane hasło, aby widzieć mody tylko dla testerów i otrzymywać wersje beta. Możesz dodać więcej niż jedno. Pozostaw puste, aby zakończyć testowanie.
gui-tester-password-prompt-saved = Masz zapisane hasła testera. Wpisz kolejne, aby je dodać, lub pozostaw to pole puste, aby zapomnieć wszystkie i zakończyć testowanie.
gui-tester-password-prompt = Wpisz otrzymane hasło testera.
gui-tester-password-title = Hasło testera
gui-tester-password-not-saved-title = Nie zapisano hasła testera
gui-button-close = Za&mknij
gui-accounts-unavailable-title = Konta niedostępne
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } w serwisie { $site }, domyślne
    [missing] { $account }, { $username } w serwisie { $site }, brak tokenu (zaloguj się ponownie)
    [default-missing] { $account }, { $username } w serwisie { $site }, domyślne, brak tokenu (zaloguj się ponownie)
   *[none] { $account }, { $username } w serwisie { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Brak kont. Użyj przycisku Zaloguj się, aby dodać konto.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } używa konta { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Brak reguł.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Wklej token z serwisu { $site }. Zostanie sprawdzony w serwisie { $site }, a następnie zapisany w Menedżerze poświadczeń systemu Windows.
gui-add-token-title = Dodaj token
gui-status-account-added = Dodano konto { $account }.
gui-token-not-added-title = Nie dodano tokenu
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Czy usunąć konto { $account }? Loadstone zapomni jego token i wszystkie reguły, które go używają. Aby również cofnąć dostęp programu Loadstone, użyj strony Applications w ustawieniach serwisu { $site }.
gui-remove-account-title = Usuń konto
gui-account-not-removed-title = Nie usunięto konta
gui-default-not-changed-title = Nie zmieniono konta domyślnego
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Repozytorium (github:owner/repo) lub wszystkie repozytoria właściciela (github:owner/*):
gui-add-rule-title = Dodaj regułę konta
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Którego konta użyć?
gui-rule-not-added-title = Nie dodano reguły
gui-rule-not-removed-title = Nie usunięto reguły

## Signing in

gui-sign-in-no-sites = Żaden serwis nie obsługuje logowania.
gui-sign-in-title = Zaloguj się
gui-sign-in-which-site = Do którego serwisu się zalogować?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Logowanie do serwisu { $site }
gui-sign-in-requesting = Pobieranie kodu logowania z serwisu { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &Kod logowania:
gui-button-copy-code = Ko&piuj kod
gui-button-open-sign-in-page = &Otwórz stronę logowania serwisu { $site }
gui-button-cancel = Anuluj
gui-sign-in-code-copied = Skopiowano kod. Otwórz stronę logowania i wklej go tam.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Otwórz stronę { $url }, wpisz poniższy kod i zatwierdź dostęp dla Loadstone. To okno zamknie się samo, gdy skończysz.
gui-sign-in-code-expired = Kod logowania wygasł, zanim został wpisany. Zacznij od nowa.
# $account is the account's name.
gui-status-signed-in = Zalogowano jako { $account }.
gui-signed-in = Zalogowano do serwisu { $site } jako { $account }.
gui-signed-in-title = Zalogowano
gui-sign-in-failed-title = Logowanie nie powiodło się
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Czy zalogować się teraz na konto, które ma do tego dostęp?
gui-offer-sign-in-title = Zaloguj się, aby kontynuować

## Startup

gui-startup-error-title = Błąd uruchamiania programu Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone – menedżer modów

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Zainstalowano { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Zainstalowano { $version } (kanał { $channel })
page-catalog-not-installed = Nie zainstalowano
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Zainstalowano { $version } w { $count } kopii
    [few] Zainstalowano { $version } w { $count } kopiach
    [many] Zainstalowano { $version } w { $count } kopiach
   *[other] Zainstalowano { $version } w { $count } kopii
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Zainstalowano w { $count } kopii (różne wersje)
    [few] Zainstalowano w { $count } kopiach (różne wersje)
    [many] Zainstalowano w { $count } kopiach (różne wersje)
   *[other] Zainstalowano w { $count } kopii (różne wersje)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Zainstalowano poza programem Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Zainstalowany, ale nie występuje w żadnym ze skonfigurowanych rejestrów.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (podgląd dla testerów)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Nie skonfigurowano żadnych rejestrów; wyświetlane są tylko zainstalowane mody.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] Ukryto { $count } mod niedostępny na tym komputerze.
    [few] Ukryto { $count } mody niedostępne na tym komputerze.
    [many] Ukryto { $count } modów niedostępnych na tym komputerze.
   *[other] Ukryto { $count } moda niedostępnego na tym komputerze.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Nie udało się wczytać rejestrów: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Nie znaleziono w skonfigurowanych rejestrach: { $error }
page-note-no-release-metadata = Najnowsze opublikowane wydanie nie ma jeszcze metadanych Loadstone, więc nie udało się ustalić najnowszej wersji.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Uwaga: kopie gry { $game } korzystają ze wspólnego folderu modów. Zainstalowanie lub odinstalowanie moda w jednej kopii wpływa na pozostałe; osobny dla każdej kopii jest tylko loader modów.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Wymaga pakietu { $name } (instalowany automatycznie, obecnie { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Wymaga pakietu { $name } (instalowany automatycznie).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Zainstalowano { $version } (kanał deweloperski).
page-status-up-to-date = Aktualny (wersja { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Aktualny (wersja { $version }, nowsza niż najnowsze wydanie, { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Dostępna aktualizacja: z { $version } do { $latest }.
page-status-installed = Zainstalowano { $version }.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Zainstalowano poza programem Loadstone (wersja nieznana). Zainstaluj wersję { $latest }, aby Loadstone mógł zarządzać tą kopią.
page-status-foreign = Zainstalowano poza programem Loadstone (wersja nieznana). Zainstaluj mod, aby Loadstone mógł zarządzać tą kopią.
page-status-ready = Gotowy do zainstalowania wersji { $latest }.
page-status-not-installed = Nie zainstalowano.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Niedostępny na tym komputerze. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Gotowy do zainstalowania wersji { $latest }. Nie znaleziono folderu gry; wybierz go przyciskiem Przeglądaj.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Nie zainstalowano. Nie znaleziono folderu gry; wybierz go przyciskiem Przeglądaj.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Wybierz folder przyciskiem Przeglądaj. Niedostępny na tym komputerze. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Wybierz folder przyciskiem Przeglądaj. Gotowy do zainstalowania wersji { $latest }. Nie znaleziono folderu gry; wybierz go przyciskiem Przeglądaj.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Wybierz folder przyciskiem Przeglądaj. Nie zainstalowano. Nie znaleziono folderu gry; wybierz go przyciskiem Przeglądaj.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Ustawienia można edytować po zainstalowaniu.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Kopia { $distribution }, zainstalowano { $version }, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Kopia { $distribution }, zainstalowano poza programem Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Kopia { $distribution }, nie zainstalowano, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Kopia w { $folder }, zainstalowano { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Kopia w { $folder }, zainstalowano poza programem Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Kopia w { $folder }, nie zainstalowano
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Nie znaleziono jeszcze żadnej kopii; wybierz folder gry przyciskiem Przeglądaj.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Inny folder...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = samodzielna
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Kanał { $channel } (najnowszy stan gałęzi { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Kanał { $channel } (wersja deweloperska)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (wersja przedpremierowa)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (wersja przedpremierowa)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Zakończono: { $action }.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Pobieranie pliku { $file }...
page-self-update-installed = Aktualizacja została zweryfikowana i zainstalowana.
page-tester-passwords-removed = Usunięto hasła testera. Mody tylko dla testerów i wersje beta są znowu ukryte.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } w serwisie { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = nie skonfigurowano żadnych rejestrów
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = nie jest znane repozytorium źródłowe dla „{ $id }”
# $id is a mod id.
page-error-not-installed-no-registries = „{ $id }” nie jest zainstalowany i nie skonfigurowano żadnych rejestrów
# $id is a mod id.
page-error-not-installed-unresolved = „{ $id }” nie jest zainstalowany i nie udało się go odnaleźć
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = „{ $id }” nie jest zainstalowany i nie udało się go odnaleźć: { $error }
page-error-tester-password-wrong = To nie jest hasło testera dla żadnego z Twoich rejestrów ani ich modów.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = magazyn kont jest niedostępny
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = „{ $value }” nie jest liczbą
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = to nie jest skończona liczba

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = niezgodność skrótu artefaktu dla { $id }: oczekiwano { $expected }, otrzymano { $actual }. Odmowa instalacji.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = niezgodność skrótu artefaktu dla { $id } ({ $artifact }): oczekiwano { $expected }, otrzymano { $actual }. Odmowa instalacji.
engine-hash-verified = Zweryfikowano skrót artefaktu.
engine-hash-none = Brak skrótu do zweryfikowania dla tego źródła (instalacja lokalna lub deweloperska).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Usuwanie wcześniej zainstalowanej wersji { $version } ({ $count } plik).
    [few] Usuwanie wcześniej zainstalowanej wersji { $version } ({ $count } pliki).
    [many] Usuwanie wcześniej zainstalowanej wersji { $version } ({ $count } plików).
   *[other] Usuwanie wcześniej zainstalowanej wersji { $version } ({ $count } pliku).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Ostrzeżenie: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Ostrzeżenie: nie udało się zapisać listy oryginałów, które trzeba jeszcze przywrócić: { $error }
engine-install-failed-rolling-back = Instalacja nie powiodła się; usuwanie zapisanych dotąd plików.
# Summary shown when an install or update finishes.
engine-installed = Zainstalowano: { $name } { $version }.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Anulowano instalację.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = „{ $id }” nie jest opcją instalacji tego moda (opcje: { $options })
engine-option-unknown-none = „{ $id }” nie jest opcją instalacji tego moda (opcje: brak)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = „{ $value }” nie jest dozwolonym wyborem dla opcji { $option } (możliwości: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = anulowano: nic nie wybrano

## Mod settings

# { $label } is the setting's name.
engine-setting-default = Ustawienie „{ $label }” ma na początek wartość domyślną; możesz je później zmienić poleceniem settings.
# { $path } is the settings file.
engine-settings-written = Zapisano ustawienia w pliku { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = „{ $action }” nie jest akcją pakietu { $id } (dostępne: { $available })
engine-action-unknown-none = „{ $action }” nie jest akcją pakietu { $id } (dostępne: brak)
# { $label } is the action's name, as on its button.
engine-action-unavailable = Akcja „{ $label }” jest teraz niedostępna (jej warunek nie jest spełniony)
engine-action-running = Wykonywanie akcji „{ $label }”...
engine-action-finished = Zakończono akcję „{ $label }”.
engine-no-launch-steps = pakiet { $id } nie określa kroków uruchamiania dla tej platformy
# Summary after starting the game with a mod.
engine-launched = Uruchomiono: { $id }.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } jest dowiązaniem do roboczej kopii deweloperskiej; pliki nie zostaną przez nie zmienione ani usunięte. Jeśli naprawdę chcesz tu instalacji zarządzanej przez Loadstone, najpierw usuń dowiązanie.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = Nie usunięto { $path }: znajduje się poza folderami moda.
engine-legacy-link = Nie usunięto { $path }: dostęp do niego prowadzi przez dowiązanie.
engine-legacy-shared = Nie usunięto { $path }: używa go inny zainstalowany pakiet.
engine-legacy-removed = Usunięto pozostałość { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Ostrzeżenie: nie udało się usunąć { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Nie znaleziono wymaganego pliku: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Wymaganie kroku { $step } nie jest spełnione.
engine-step-skipped = Pominięto krok { $step }.
engine-cancelled-at-step = anulowano na kroku { $step }
engine-extracting = Wypakowywanie plików...
engine-placed-files = { $count ->
    [one] Umieszczono { $count } plik.
    [few] Umieszczono { $count } pliki.
    [many] Umieszczono { $count } plików.
   *[other] Umieszczono { $count } pliku.
}
engine-kept-existing = Zachowano istniejący plik { $path } (nie nadpisano; może być nowszy).
engine-file-created = Utworzono i zaktualizowano { $path }.
engine-file-updated = Zaktualizowano { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = anulowano: nie wybrano folderu dla pytania „{ $prompt }”
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Skopiowano do schowka: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] Połączono { $count } architekturę w pliku { $file }.
    [few] Połączono { $count } architektury w pliku { $file }.
    [many] Połączono { $count } architektur w pliku { $file }.
   *[other] Połączono { $count } architektury w pliku { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = nie można uruchomić: brak { $path }
engine-program-start-failed = nie udało się uruchomić { $path }
engine-program-started = Uruchomiono { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = nie udało się otworzyć { $url }
engine-url-opened = Otwarto { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = Pakiet { $id } jest nadal wymagany przez: { $dependents }. Najpierw je odinstaluj.
engine-removing-files = { $count ->
    [one] Usuwanie { $count } pliku.
    [few] Usuwanie { $count } plików.
    [many] Usuwanie { $count } plików.
   *[other] Usuwanie { $count } pliku.
}
engine-purge-question = Czy usunąć również zapisane ustawienia i preferencje?
engine-purge-done = Usunięto zapisane ustawienia.
engine-dependency-unneeded = Pakiet { $id } nie jest już potrzebny żadnemu zainstalowanemu modowi; możesz go również odinstalować.
# Summary when an uninstall finishes.
engine-uninstalled = Odinstalowano: { $id } { $version }.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Używanie oryginału zachowanego już w { $path }.
engine-originals-kept = { $count ->
    [one] Zachowano kopię { $count } oryginalnego pliku gry.
    [few] Zachowano kopię { $count } oryginalnych plików gry.
    [many] Zachowano kopię { $count } oryginalnych plików gry.
   *[other] Zachowano kopię { $count } oryginalnego pliku gry.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Ostrzeżenie: nie udało się teraz przywrócić oryginału { $path } ({ $error }). Zostanie przywrócony przy aktualizacji lub odinstalowaniu tego moda.
engine-original-restored = Przywrócono oryginał { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Ostrzeżenie: brak oryginału { $path } ({ $backup }); plik pozostaje bez zmian.
engine-original-changed = Plik { $path } zmienił się od zainstalowania tego moda (aktualizacja gry?); zachowano nowszy plik.
engine-originals-restored = { $count ->
    [one] Przywrócono { $count } oryginalny plik gry.
    [few] Przywrócono { $count } oryginalne pliki gry.
    [many] Przywrócono { $count } oryginalnych plików gry.
   *[other] Przywrócono { $count } oryginalnego pliku gry.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] nie udało się przywrócić { $count } oryginalnego pliku gry; zamknij grę i spróbuj ponownie.
    [few] nie udało się przywrócić { $count } oryginalnych plików gry; zamknij grę i spróbuj ponownie.
    [many] nie udało się przywrócić { $count } oryginalnych plików gry; zamknij grę i spróbuj ponownie.
   *[other] nie udało się przywrócić { $count } oryginalnego pliku gry; zamknij grę i spróbuj ponownie.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Aktualizowanie kopii { $distribution } w { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = „{ $id }” jest zainstalowany w więcej niż jednej kopii gry { $game }: { $copies }. Użyj opcji --game-dir, aby wskazać, którą kopię zaktualizować.
engine-many-copies = „{ $id }” jest zainstalowany w więcej niż jednej kopii gry { $game }: { $copies }. Użyj opcji --game-dir, aby wskazać kopię.
engine-not-game-folder = { $path } nie wygląda na folder gry { $game } (nie znaleziono żadnego z oczekiwanych plików)
engine-game-found = Znaleziono grę { $game } w { $path }
engine-game-not-found = Nie udało się automatycznie znaleźć gry { $game }.
# Title of the folder picker.
engine-game-where = Gdzie jest zainstalowana gra { $game }?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = nie udało się automatycznie znaleźć gry { $game }; użyj opcji --game-dir lub wybierz jej folder
# { $path } is a game folder.
engine-not-installed-copy = „{ $id }” nie jest zainstalowany w kopii gry { $game } w { $path }
engine-not-installed = „{ $id }” nie jest zainstalowany dla gry { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = Nie można zainstalować moda { $name } na tym komputerze. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = kopia { $distribution } gry { $game } nie jest obsługiwana. { $reason }
engine-distribution-untested = Uwaga: kopia { $distribution } gry { $game } nie była testowana z tym modem.
engine-no-matching-artifact = żaden artefakt wydania nie pasuje do tej platformy/architektury/dystrybucji
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Ten mod jest dostępny tylko w systemie { $platform }.
engine-platform-only-two = Ten mod jest dostępny tylko w systemach { $first } i { $second }.
engine-platform-only-three = Ten mod jest dostępny tylko w systemach { $first }, { $second } i { $third }.
engine-platform-needs-apple-silicon = W systemie { $platform } ten mod wymaga procesora Apple Silicon.
engine-platform-needs-arm = W systemie { $platform } ten mod wymaga procesora ARM.
engine-platform-needs-x64 = W systemie { $platform } ten mod wymaga procesora Intel lub AMD.
engine-game-platform-unsupported = Gra { $game } nie jest tutaj obsługiwana w systemie { $platform }.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } jest aktualny ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } jest aktualny (wersja { $installed } jest nowsza niż najnowsze wydanie, { $latest }).
engine-installed-newer = Zainstalowana wersja { $name } { $installed } jest nowsza niż najnowsze dostępne teraz dla Ciebie wydanie ({ $latest }). Niczego nie zmieniono. Aby zainstalować starszą wersję, wybierz ją wprost.
# { $from } and { $to } are versions.
engine-updating = Aktualizowanie moda { $name }: { $from } -> { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Czy zainstalować mod { $name } z najnowszego stanu gałęzi { $branch } ({ $version })?

    Wersje deweloperskie nie są zabezpieczone skrótem; ufasz bieżącej zawartości repozytorium.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Informacje o wydaniu: { $name } { $version }

    { $notes }

    Czy zainstalować teraz?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Pobieranie informacji o wydaniu { $tag } z { $source }...
engine-fetching-latest = Pobieranie informacji o najnowszym wydaniu z { $source }...
engine-using-local-artifact = Używanie lokalnego artefaktu { $path }
# { $file } is a download's file name.
engine-using-cached = Używanie pobranego już pliku { $file }.
engine-downloading = Pobieranie pliku { $file }...
engine-dependency-present = Zależność { $id } { $version } jest już zainstalowana.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Instalowanie zależności { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = nie podano tokenu
core-sign-in-cancelled = Anulowano logowanie.
core-sign-in-expired = Kod logowania wygasł, zanim został wpisany. Zacznij od nowa.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = „{ $pattern }” nie jest źródłem (github:owner/repo) ani wzorcem właściciela (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = nie udało się zapisać tokenu w systemowym magazynie poświadczeń
core-secrets-remove-failed = nie udało się usunąć tokenu z systemowego magazynu poświadczeń

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = wydanie { $tag } z { $source } nie zawiera pliku { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = najnowsze wydanie z { $source } nie zawiera pliku { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = wydanie { $tag } nie zawiera pliku loadstone-release.json (lub jest on nieosiągalny)
core-github-sign-in-cancelled = Logowanie zostało anulowane w serwisie GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub odrzucił logowanie: { $details }
core-github-sign-in-refused-no-details = GitHub odrzucił logowanie: nie podano szczegółów
core-github-token-rejected = GitHub nie zaakceptował tokenu

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = serwis { $site } nie obsługuje logowania
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = „{ $source }” nie jest źródłem w formacie { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = Nie znaleziono { $source }. Jeśli to prywatne repozytorium, zaloguj się na konto, które ma do niego dostęp (Ustawienia Loadstone), lub ustaw GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = token z { $account } został odrzucony; mógł wygasnąć lub zostać unieważniony
core-source-token-unreachable = źródło { $source } jest nieosiągalne z tokenem z { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = pobieranie { $url } zwróciło kod HTTP { $status }
core-fetch-request-failed = żądanie nie powiodło się: { $url }
core-fetch-download-failed = pobieranie nie powiodło się: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = błąd odczytu
core-fetch-read-error-download = błąd odczytu podczas pobierania

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = żadna ścieżka wypakowywania nie dotyczy tej platformy/dystrybucji
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } jest dowiązaniem do roboczej kopii deweloperskiej. Zamiast tego zaktualizuj tę kopię za pomocą git lub usuń dowiązanie przed instalacją.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = to archiwum nie zawiera oczekiwanej zawartości (żaden wpis nie pasuje do żadnej ścieżki)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = rejestr „{ $source }” nie jest ani w formacie { $formats }, ani istniejącym folderem
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } nie zawiera folderu loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = Nie udało się odświeżyć { $source } ({ $error }); używana jest kopia z pamięci podręcznej.
core-registry-fetch-failed = nie udało się pobrać rejestru { $source }
# $id is a mod's id.
core-registry-package-not-found = nie znaleziono pakietu „{ $id }” w żadnym rejestrze

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = „{ $key }” jest wartością logiczną; użyj true lub false
core-setting-not-number = „{ $key }” wymaga liczby
core-setting-too-small = „{ $key }” musi wynosić co najmniej { $min }
core-setting-too-large = „{ $key }” może wynosić co najwyżej { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = „{ $key }” musi mieć jedną z wartości: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Odblokowano dostęp testera do modów z rejestru: mody tylko dla testerów są widoczne, a instalacje i aktualizacje pobierają wersje beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Odblokowano dostęp testera do modów z rejestru oraz do: { $mods }. Mody tylko dla testerów są widoczne, a instalacje i aktualizacje pobierają wersje beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Odblokowano dostęp testera do: { $mods }. Mody tylko dla testerów są widoczne, a instalacje i aktualizacje pobierają wersje beta.
core-tester-save-failed = nie udało się zapisać hasła testera
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = Wydanie { $tag } nie ma użytecznych metadanych Loadstone ({ $error }); używane jest najnowsze stabilne wydanie.
core-tester-beta-lookup-failed = Nie udało się wyszukać wersji beta ({ $error }); używane jest najnowsze stabilne wydanie.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = pobrana aktualizacja nie przeszła weryfikacji skrótu (oczekiwano { $expected }, otrzymano { $actual }); nie zainstalowano
core-update-translocated = macOS uruchamia ten program z tymczasowej kopii tylko do odczytu, więc nie może on zaktualizować się sam. Przenieś go do folderu Aplikacje, otwórz go stamtąd i ponów aktualizację.
core-update-on-disk-image = ten program działa z obrazu dysku, więc nie może zaktualizować się sam. Skopiuj go do folderu Aplikacje, otwórz go stamtąd i ponów aktualizację.
# $path is the folder the app is in.
core-update-no-write = nie można zapisywać obok { $path } (brak uprawnień?), więc program nie może zaktualizować się sam. Zamiast tego pobierz nową wersję ze strony wydania.
core-update-no-staging = nie można zapisywać obok { $path } (brak uprawnień?). Zamiast tego pobierz nową wersję ze strony wydania
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = aktualizacja to inny program ({ $got }, oczekiwano { $expected }); nie zainstalowano
core-update-move-aside-app = nie udało się przenieść bieżącego programu na bok
core-update-move-in-app = nie udało się przenieść nowego programu na miejsce
core-update-move-aside-exe = nie udało się przenieść bieżącego pliku wykonywalnego na bok
core-update-move-in-exe = nie udało się przenieść nowego pliku wykonywalnego na miejsce

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = &OK
gui-stock-ok-plain = OK
gui-stock-cancel = &Anuluj
gui-stock-cancel-plain = Anuluj
gui-stock-yes = &Tak
gui-stock-yes-plain = Tak
gui-stock-no = &Nie
gui-stock-no-plain = Nie
gui-stock-close = &Zamknij
gui-stock-close-plain = Zamknij
