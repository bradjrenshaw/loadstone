# Loadstone's interface text, Hungarian.
# Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Ehhez a modhoz a Loadstone újabb verziója szükséges. Frissítse a Loadstone-t, majd próbálja újra.

## Loadstone settings

pref-language = Nyelv
pref-language-description = A Loadstone és a lefordított modok megjelenítési nyelve.
language-system = A rendszer alapértelmezése
pref-accounts = Fiókok
pref-accounts-description = Bejelentkezések, amelyekkel a Loadstone privát tárolókból tölt le modokat.
pref-account-rules = Fiókszabályok
pref-account-rules-description = Melyik fiókot használja a program egy tárolóhoz vagy tulajdonoshoz.
pref-try-other-accounts = A többi fiókom kipróbálása, ha egy letöltést elutasítanak
pref-try-other-accounts-description = Ha egy tároló nem található, vagy a hozzáférést elutasítják, a program a feladás előtt kipróbálja az adott webhelyhez tartozó többi fiókot.
pref-tester-passwords = Tesztelői jelszavak
pref-tester-passwords-description = Feloldja a csak tesztelőknek szóló modokat és a bétaverziókat egy teljes jegyzékhez vagy egyes modokhoz. A Tesztelői jelszó gombbal állítható be.
pref-download-account = Letöltési fiók
pref-download-account-description = A mod letöltéséhez használt fiók. Az Automatikus beállítás a fiókszabályokat és az alapértelmezett fiókot használja.
pref-download-account-automatic = Automatikus (fiókszabályok, majd az alapértelmezett fiók)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Loadstone beállításai...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Fiókok privát tárolókhoz és a Loadstone beállításai
gui-menu-exit = &Kilépés
# Menu bar title.
gui-menu-tools = &Eszközök
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Egy művelet még folyamatban van. Ha most bezárja az ablakot, a művelet befejezetlen maradhat. Mindenképp bezárja?
gui-close-while-running-title = Művelet folyamatban
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Betöltés...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Probléma a művelet közben
gui-button-retry = Ú&jra
gui-button-skip = &Kihagyás
gui-button-cancel-problem = &Mégse
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Telepítési opciók

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (mag: { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Modok:
# Button that opens the selected mod's page.
gui-button-details = &Részletek
gui-button-refresh = Újra&töltés
gui-button-loadstone-settings = Loadstone &beállításai...
gui-status-fetching-catalog = A modkatalógus lekérése...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = A modlista betöltése...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Nem sikerült betölteni a modlistát. Az újrapróbálkozáshoz nyomja meg az Újratöltés gombot.
gui-status-catalog-failed = Nem sikerült lekérni a katalógust.
gui-catalog-error-title = Nem sikerült betölteni a modkatalógust
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Nincs elérhető mod.
gui-status-catalog-loaded = { $count ->
    [one] Katalógus betöltve: { $count } mod.
   *[other] Katalógus betöltve: { $count } mod.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Betöltés: { $mod_id }...
gui-status-mod-load-failed = Nem sikerült betölteni a mod oldalát.
gui-mod-error-title = Nem sikerült betölteni a modot
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = Kezelendő &játékpéldány:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = { $game } kezelendő &példánya:
gui-button-back = &Vissza a modlistához
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }, készítette: { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = Játék&mappa:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = { $game } &mappája:
gui-button-browse = Ta&llózás...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Válassza ki a játék mappáját
gui-browse-game-prompt-named = Válassza ki a(z) { $game } játék mappáját
gui-description-label = Leírás:
# Label of the log where operations report their progress.
gui-activity-label = Tevékenység:
gui-button-update = F&rissítés
gui-button-install = &Telepítés
gui-select-folder-first = Először válassza ki a játék mappáját a Tallózás gombbal.
gui-button-install-from-file = Telepítés &fájlból...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Válassza ki a mod loadstone-release.json fájlját
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON-fájlok (*.json)|*.json|Minden fájl (*.*)|*.*
gui-button-uninstall = &Eltávolítás
gui-button-launch = Játék &indítása
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Elindítja a játékot a moddal együtt.
gui-launch-unavailable-description = Akkor érhető el, ha a mod ide már telepítve van.
gui-button-change-options = Telepítési &opciók módosítása...
gui-change-options-description = Újra felteszi a mod telepítési kérdéseit, és az Ön válaszaival újratelepíti a legújabb verziót.
gui-button-settings = &Beállítások...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Feldolgozás... { $percent }%
gui-status-fetching-releases = A kiadások listájának lekérése...
# $error is an error message.
gui-release-list-error = Nem sikerült lekérni a kiadások listáját: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Telepíti helyette a legújabb kiadást?
gui-release-list-error-title = A kiadások listája nem érhető el
gui-no-releases = Ennek a modnak a tárolójában még nincs kiadás.
gui-no-releases-title = Nincs kiadás
gui-choose-version = Válassza ki a telepítendő verziót:
gui-choose-version-title = Verzió kiválasztása
gui-confirm-uninstall = Eltávolítja a(z) { $name } modot?
gui-confirm-uninstall-title = Eltávolítás megerősítése
gui-status-working = Feldolgozás...
gui-status-op-failed = A művelet nem sikerült.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Nem indítható
gui-op-failed-title = A művelet nem sikerült
# Title of the message shown when an operation finished.
gui-op-done-title = Kész

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Elérhető a(z) { $app } { $version } verziója (a jelenlegi verzió: { $current }). Frissíti és újraindítja most?
gui-self-update-title = Frissítés érhető el
gui-status-downloading-update = A frissítés letöltése...
gui-status-update-failed = A frissítés nem sikerült.
gui-update-failed-title = A frissítés nem sikerült
gui-status-update-installed = Frissítés telepítve.
gui-update-installed = A frissítés telepítve. Az alkalmazás most újraindul.
gui-update-installed-title = Frissítés telepítve

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = A Loadstone beállításai nem érhetők el: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Beállítások: { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = A mod opciói
gui-mod-options-after-install = A mod opciói a telepítése után érhetők el.
gui-status-setting-saved = Beállítás mentve.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Beállítás mentve. { $note }
gui-setting-not-changed-title = A beállítás nem változott
gui-status-no-settings-changed = Egyik beállítás sem változott.

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone beállításai
gui-accounts-label = &Fiókok:
gui-accounts-description = Bejelentkezések, amelyekkel a Loadstone privát tárolókból tölt le modokat.
gui-button-sign-in = &Bejelentkezés...
gui-button-add-token = &Token hozzáadása...
gui-button-remove-account = Fiók &eltávolítása
gui-button-set-default = Beállítás &alapértelmezettként
# "gh auth token" is a command, keep it.
gui-add-token-description = Fiók hozzáadása egy már meglévő tokennel, például a GitHub CLI gh auth token parancsából.
gui-rules-label = Fiók&szabályok:
gui-rules-description = Melyik fiókot használja a program egy tárolóhoz vagy egy tulajdonos összes tárolójához. Ha nincs szabály, az alapértelmezett fiókot használja.
gui-button-add-rule = S&zabály hozzáadása...
gui-button-remove-rule = Szabály e&ltávolítása
gui-button-tester-password = Tesztelői &jelszó...
gui-tester-password-description = Privát tesztelőknek: adja meg a kapott jelszót, hogy lássa a csak tesztelőknek szóló modokat, és bétaverziókat kapjon. Több jelszót is megadhat. A tesztelés befejezéséhez hagyja üresen a mezőt.
gui-tester-password-prompt-saved = Vannak mentett tesztelői jelszavai. Újabb jelszó hozzáadásához írja be azt, vagy hagyja üresen a mezőt, ha mindet el szeretné felejteni, és befejezné a tesztelést.
gui-tester-password-prompt = Adja meg a kapott tesztelői jelszót.
gui-tester-password-title = Tesztelői jelszó
gui-tester-password-not-saved-title = A tesztelői jelszó nincs mentve
gui-button-close = Bezá&rás
gui-accounts-unavailable-title = A fiókok nem érhetők el
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } ({ $site }), alapértelmezett
    [missing] { $account }, { $username } ({ $site }), hiányzik a token (jelentkezzen be újra)
    [default-missing] { $account }, { $username } ({ $site }), alapértelmezett, hiányzik a token (jelentkezzen be újra)
   *[none] { $account }, { $username } ({ $site })
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Nincsenek fiókok. Fiókot a Bejelentkezés gombbal adhat hozzá.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern }: a(z) { $account } fiókot használja
# Placeholder line when there are no account rules.
gui-rules-empty = Nincsenek szabályok.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Illesszen be egy { $site }-tokent. A program ellenőrzi a(z) { $site } webhelyen, majd a Windows Hitelesítőadat-kezelőben tárolja.
gui-add-token-title = Token hozzáadása
gui-status-account-added = Fiók hozzáadva: { $account }.
gui-token-not-added-title = A token nincs hozzáadva
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Eltávolítja a(z) { $account } fiókot? A Loadstone elfelejti a fiók tokenjét és az azt használó szabályokat. Ha a Loadstone hozzáférését is vissza szeretné vonni, használja az Applications oldalt a(z) { $site } beállításai között.
gui-remove-account-title = Fiók eltávolítása
gui-account-not-removed-title = A fiók nincs eltávolítva
gui-default-not-changed-title = Az alapértelmezett fiók nem változott
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Tároló (github:owner/repo) vagy egy tulajdonos összes tárolója (github:owner/*):
gui-add-rule-title = Fiókszabály hozzáadása
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Melyik fiókot használja?
gui-rule-not-added-title = A szabály nincs hozzáadva
gui-rule-not-removed-title = A szabály nincs eltávolítva

## Signing in

gui-sign-in-no-sites = Egyik webhely sem támogatja a bejelentkezést.
gui-sign-in-title = Bejelentkezés
gui-sign-in-which-site = Melyik webhelyre szeretne bejelentkezni?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Bejelentkezés: { $site }
gui-sign-in-requesting = Bejelentkezési kód kérése a(z) { $site } webhelytől...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = Bejelentkezési &kód:
gui-button-copy-code = Kód má&solása
gui-button-open-sign-in-page = A(z) { $site } bejelentkezési oldalának &megnyitása
gui-button-cancel = Mégse
gui-sign-in-code-copied = A kód a vágólapra került. Nyissa meg a bejelentkezési oldalt, és illessze be ott.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Nyissa meg ezt a címet: { $url }, írja be az alábbi kódot, és engedélyezze a Loadstone hozzáférését. Ez az ablak magától bezárul, amikor végzett.
gui-sign-in-code-expired = A bejelentkezési kód lejárt, mielőtt beírta volna. Kezdje újra.
# $account is the account's name.
gui-status-signed-in = Bejelentkezve: { $account }.
gui-signed-in = Bejelentkezve ide: { $site }, fiók: { $account }.
gui-signed-in-title = Bejelentkezve
gui-sign-in-failed-title = A bejelentkezés nem sikerült
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Bejelentkezik most egy olyan fiókkal, amely hozzáfér?
gui-offer-sign-in-title = Jelentkezzen be a folytatáshoz

## Startup

gui-startup-error-title = Hiba a Loadstone indításakor

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone modkezelő

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Telepítve: { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Telepítve: { $version } ({ $channel } csatorna)
page-catalog-not-installed = Nincs telepítve
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Telepítve: { $version }, { $count } példányon
   *[other] Telepítve: { $version }, { $count } példányon
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Telepítve { $count } példányon (eltérő verziók)
   *[other] Telepítve { $count } példányon (eltérő verziók)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = A Loadstone-on kívül telepítve
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Telepítve, de a beállított jegyzékek egyike sem tartalmazza.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (tesztelői előzetes)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Nincs beállítva jegyzék; csak a telepített modok láthatók.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] { $count } mod rejtve van, mert ezen a számítógépen nem érhető el.
   *[other] { $count } mod rejtve van, mert ezen a számítógépen nem érhető el.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Nem sikerült betölteni a jegyzékeket: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Nem található a beállított jegyzékekben: { $error }
page-note-no-release-metadata = A legutóbb közzétett kiadás még nem tartalmaz Loadstone-metaadatokat, ezért nem állapítható meg a legújabb verzió.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Megjegyzés: a(z) { $game } példányai közös modmappát használnak. Ha az egyik példányra telepít vagy onnan eltávolít egy modot, az a többire is hatással van; csak a modbetöltő külön példányonként.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Szükséges hozzá: { $name } (automatikusan települ, jelenleg { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Szükséges hozzá: { $name } (automatikusan települ).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Telepítve: { $version } (fejlesztői csatorna).
page-status-up-to-date = Naprakész (verzió: { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Naprakész (verzió: { $version }, újabb, mint a legújabb kiadás: { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Frissítés érhető el: { $version } verzióról { $latest } verzióra.
page-status-installed = Telepítve: { $version }.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = A Loadstone-on kívül telepítve (ismeretlen verzió). Telepítse a(z) { $latest } verziót, hogy a Loadstone kezelhesse ezt a példányt.
page-status-foreign = A Loadstone-on kívül telepítve (ismeretlen verzió). Telepítse a modot, hogy a Loadstone kezelhesse ezt a példányt.
page-status-ready = Készen áll a(z) { $latest } verzió telepítésére.
page-status-not-installed = Nincs telepítve.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Ezen a számítógépen nem érhető el. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Készen áll a(z) { $latest } verzió telepítésére. A játék mappája nem található; válassza ki a Tallózás gombbal.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Nincs telepítve. A játék mappája nem található; válassza ki a Tallózás gombbal.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Válassza ki a mappát a Tallózás gombbal. Ezen a számítógépen nem érhető el. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Válassza ki a mappát a Tallózás gombbal. Készen áll a(z) { $latest } verzió telepítésére. A játék mappája nem található; válassza ki a Tallózás gombbal.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Válassza ki a mappát a Tallózás gombbal. Nincs telepítve. A játék mappája nem található; válassza ki a Tallózás gombbal.
# Shown with a mod's settings before it is installed.
page-settings-after-install = A beállítások a telepítés után szerkeszthetők.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = { $distribution } példány, telepítve: { $version }, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = { $distribution } példány, a Loadstone-on kívül telepítve, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = { $distribution } példány, nincs telepítve, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Példány itt: { $folder }, telepítve: { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Példány itt: { $folder }, a Loadstone-on kívül telepítve
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Példány itt: { $folder }, nincs telepítve
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Még nem található példány; válassza ki a játék mappáját a Tallózás gombbal.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Másik mappa...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Önálló
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = { $channel } csatorna (a legfrissebb állapot a(z) { $branch } ágból)
# A development channel. $channel is the channel id ("dev").
page-channel-development = { $channel } csatorna (fejlesztői build)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (előzetes kiadás)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (előzetes kiadás)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Befejeződött: { $action }.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Letöltés: { $file }...
page-self-update-installed = A frissítés ellenőrizve és telepítve.
page-tester-passwords-removed = A tesztelői jelszavak eltávolítva. A csak tesztelőknek szóló modok és a bétaverziók ismét rejtve vannak.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username }, { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = nincs beállítva jegyzék
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = a(z) „{ $id }” modhoz nem ismert forrástároló
# $id is a mod id.
page-error-not-installed-no-registries = a(z) „{ $id }” nincs telepítve, és nincs beállítva jegyzék
# $id is a mod id.
page-error-not-installed-unresolved = a(z) „{ $id }” nincs telepítve, és nem sikerült megtalálni
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = a(z) „{ $id }” nincs telepítve, és nem sikerült megtalálni: { $error }
page-error-tester-password-wrong = Ez nem tesztelői jelszó egyik jegyzékéhez és azok egyik modjához sem.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = a fióktároló nem érhető el
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = „{ $value }” nem szám
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = nem véges szám

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = hash-eltérés a(z) { $id } artefaktumánál: várt érték { $expected }, kapott érték { $actual }. A telepítés megtagadva.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = hash-eltérés a(z) { $id } artefaktumánál ({ $artifact }): várt érték { $expected }, kapott érték { $actual }. A telepítés megtagadva.
engine-hash-verified = Az artefaktum hash-értéke ellenőrizve.
engine-hash-none = Ehhez a forráshoz nincs ellenőrizhető hash-érték (helyi vagy fejlesztői telepítés).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] A korábban telepített { $version } verzió eltávolítása ({ $count } fájl).
   *[other] A korábban telepített { $version } verzió eltávolítása ({ $count } fájl).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Figyelmeztetés: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Figyelmeztetés: nem sikerült rögzíteni a még visszaállítandó eredeti fájlokat: { $error }
engine-install-failed-rolling-back = A telepítés nem sikerült; az eddig kiírt fájlok eltávolítása.
# Summary shown when an install or update finishes.
engine-installed = Telepítve: { $name } { $version }.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Telepítés megszakítva.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = „{ $id }” nem telepítési opciója ennek a modnak (opciók: { $options })
engine-option-unknown-none = „{ $id }” nem telepítési opciója ennek a modnak (opciók: nincsenek)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = „{ $value }” nem választható a(z) { $option } opciónál (lehetőségek: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = megszakítva: nem történt választás

## Mod settings

# { $label } is the setting's name.
engine-setting-default = A(z) „{ $label }” beállítás az alapértékkel indul; később a settings paranccsal módosíthatja.
# { $path } is the settings file.
engine-settings-written = Beállítások kiírva ide: { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = „{ $action }” nem művelete a(z) { $id } csomagnak (elérhetők: { $available })
engine-action-unknown-none = „{ $action }” nem művelete a(z) { $id } csomagnak (elérhetők: nincsenek)
# { $label } is the action's name, as on its button.
engine-action-unavailable = A(z) „{ $label }” művelet most nem érhető el (nem teljesül az előfeltétele)
engine-action-running = A(z) „{ $label }” művelet futtatása...
engine-action-finished = A(z) „{ $label }” művelet befejeződött.
engine-no-launch-steps = a(z) { $id } csomag nem ad meg indítási lépéseket ehhez a platformhoz
# Summary after starting the game with a mod.
engine-launched = Elindítva: { $id }.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } egy fejlesztői munkakönyvtárba mutató hivatkozás; a program ezen keresztül nem módosít és nem töröl fájlokat. Ha valóban kezelt telepítést szeretne ide, először távolítsa el a hivatkozást.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = Nem lesz eltávolítva: { $path } – a mod mappáin kívül található.
engine-legacy-link = Nem lesz eltávolítva: { $path } – hivatkozáson keresztül érhető el.
engine-legacy-shared = Nem lesz eltávolítva: { $path } – egy másik telepített csomag használja.
engine-legacy-removed = Visszamaradt fájl eltávolítva: { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Figyelmeztetés: nem sikerült eltávolítani: { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = A szükséges fájl nem található: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = A(z) { $step } lépés egyik feltétele nem teljesül.
engine-step-skipped = A(z) { $step } lépés kihagyva.
engine-cancelled-at-step = megszakítva a(z) { $step } lépésnél
engine-extracting = Fájlok kibontása...
engine-placed-files = { $count ->
    [one] { $count } fájl elhelyezve.
   *[other] { $count } fájl elhelyezve.
}
engine-kept-existing = A meglévő fájl megtartva: { $path } (nincs felülírva; lehet, hogy újabb).
engine-file-created = Létrehozva és frissítve: { $path }.
engine-file-updated = Frissítve: { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = megszakítva: nincs kiválasztott mappa ehhez: „{ $prompt }”
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Vágólapra másolva: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] { $count } architektúra egyesítve ebben a fájlban: { $file }.
   *[other] { $count } architektúra egyesítve ebben a fájlban: { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = nem indítható: hiányzik a következő: { $path }
engine-program-start-failed = nem sikerült elindítani: { $path }
engine-program-started = Elindítva: { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = nem sikerült megnyitni: { $url }
engine-url-opened = Megnyitva: { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = A(z) { $id } csomagra még ezeknek van szükségük: { $dependents }. Először ezeket távolítsa el.
engine-removing-files = { $count ->
    [one] { $count } fájl eltávolítása.
   *[other] { $count } fájl eltávolítása.
}
engine-purge-question = A mentett beállításokat és preferenciákat is eltávolítja?
engine-purge-done = A mentett beállítások eltávolítva.
engine-dependency-unneeded = A(z) { $id } csomagra már egyik telepített modnak sincs szüksége; azt is eltávolíthatja.
# Summary when an uninstall finishes.
engine-uninstalled = Eltávolítva: { $id } { $version }.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = A már megőrzött eredeti fájl használata: { $path }.
engine-originals-kept = { $count ->
    [one] { $count } eredeti játékfájl másolata megőrizve.
   *[other] { $count } eredeti játékfájl másolata megőrizve.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Figyelmeztetés: az eredeti fájl most nem állítható vissza: { $path } ({ $error }). A mod frissítésekor vagy eltávolításakor kerül vissza.
engine-original-restored = Az eredeti fájl visszaállítva: { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Figyelmeztetés: hiányzik az eredeti fájl ehhez: { $path } ({ $backup }); a fájl változatlan marad.
engine-original-changed = { $path } megváltozott a mod telepítése óta (játékfrissítés?); az újabb fájl megtartva.
engine-originals-restored = { $count ->
    [one] { $count } eredeti játékfájl visszaállítva.
   *[other] { $count } eredeti játékfájl visszaállítva.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] nem sikerült visszahelyezni { $count } eredeti játékfájlt; zárja be a játékot, és próbálja újra.
   *[other] nem sikerült visszahelyezni { $count } eredeti játékfájlt; zárja be a játékot, és próbálja újra.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = A(z) { $distribution } példány frissítése itt: { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = A(z) „{ $id }” a(z) { $game } játék több példányára is telepítve van: { $copies }. A --game-dir kapcsolóval adja meg, melyik példányt kell frissíteni.
engine-many-copies = A(z) „{ $id }” a(z) { $game } játék több példányára is telepítve van: { $copies }. A --game-dir kapcsolóval adja meg, melyik példányról van szó.
engine-not-game-folder = { $path } nem tűnik a(z) { $game } játék mappájának (egyik várt fájl sem található)
engine-game-found = A(z) { $game } játék megtalálva itt: { $path }
engine-game-not-found = A(z) { $game } játék nem található automatikusan.
# Title of the folder picker.
engine-game-where = Hol van telepítve a(z) { $game } játék?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = a(z) { $game } játék nem található automatikusan; adja meg a --game-dir kapcsolót, vagy válassza ki a játék mappáját
# { $path } is a game folder.
engine-not-installed-copy = a(z) „{ $id }” nincs telepítve a(z) { $game } játék itt található példányára: { $path }
engine-not-installed = a(z) „{ $id }” nincs telepítve a(z) { $game } játékhoz

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = A(z) { $name } mod nem telepíthető erre a számítógépre. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = a(z) { $game } játék { $distribution } példánya nem támogatott. { $reason }
engine-distribution-untested = Megjegyzés: a(z) { $game } játék { $distribution } példányát nem tesztelték ezzel a moddal.
engine-no-matching-artifact = egyetlen kiadási artefaktum sem felel meg ennek a platformnak/architektúrának/disztribúciónak
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Ez a mod csak { $platform } rendszeren érhető el.
engine-platform-only-two = Ez a mod csak { $first } és { $second } rendszeren érhető el.
engine-platform-only-three = Ez a mod csak { $first }, { $second } és { $third } rendszeren érhető el.
engine-platform-needs-apple-silicon = { $platform } rendszeren ehhez a modhoz Apple Silicon processzor szükséges.
engine-platform-needs-arm = { $platform } rendszeren ehhez a modhoz ARM processzor szükséges.
engine-platform-needs-x64 = { $platform } rendszeren ehhez a modhoz Intel vagy AMD processzor szükséges.
engine-game-platform-unsupported = A(z) { $game } játék itt nem támogatott { $platform } rendszeren.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = A(z) { $name } mod naprakész ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = A(z) { $name } mod naprakész (a(z) { $installed } verzió újabb, mint a legújabb kiadás: { $latest }).
engine-installed-newer = A(z) { $name } mod { $installed } verziója van telepítve, amely újabb, mint az Ön számára most elérhető legújabb kiadás ({ $latest }). Semmi sem változott. Régebbi verzió telepítéséhez kifejezetten azt a verziót válassza ki.
# { $from } and { $to } are versions.
engine-updating = A(z) { $name } mod frissítése: { $from } -> { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Telepíti a(z) { $name } modot a(z) { $branch } ág legfrissebb állapotából ({ $version })?

    A fejlesztői buildek nincsenek hash-értékhez kötve; a tároló jelenlegi tartalmában kell megbíznia.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Kiadási megjegyzések: { $name } { $version }

    { $notes }

    Telepíti most?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = A(z) { $tag } kiadás adatainak lekérése innen: { $source }...
engine-fetching-latest = A legújabb kiadás adatainak lekérése innen: { $source }...
engine-using-local-artifact = Helyi artefaktum használata: { $path }
# { $file } is a download's file name.
engine-using-cached = A már letöltött fájl használata: { $file }.
engine-downloading = Letöltés: { $file }...
engine-dependency-present = A(z) { $id } { $version } függőség már telepítve van.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = A(z) { $name } { $version } függőség telepítése ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = nincs megadva token
core-sign-in-cancelled = Bejelentkezés megszakítva.
core-sign-in-expired = A bejelentkezési kód lejárt, mielőtt beírta volna. Kezdje újra.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = „{ $pattern }” nem forrás (github:owner/repo) és nem tulajdonosi helyettesítő minta (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = nem sikerült menteni a tokent a rendszer hitelesítőadat-tárolójába
core-secrets-remove-failed = nem sikerült eltávolítani a tokent a rendszer hitelesítőadat-tárolójából

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = a(z) { $source } forrás { $tag } kiadása nem tartalmaz { $file } fájlt
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = a(z) { $source } forrás legújabb kiadása nem tartalmaz { $file } fájlt
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = a(z) { $tag } kiadás nem tartalmaz loadstone-release.json fájlt (vagy az nem érhető el)
core-github-sign-in-cancelled = A bejelentkezést megszakították a GitHubon.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = A GitHub elutasította a bejelentkezést: { $details }
core-github-sign-in-refused-no-details = A GitHub elutasította a bejelentkezést, részletek nélkül
core-github-token-rejected = A GitHub nem fogadta el a tokent

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = a(z) { $site } webhely nem támogatja a bejelentkezést
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = „{ $source }” nem { $format } formátumú forrás
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = Nem található: { $source }. Ha privát tárolóról van szó, jelentkezzen be egy olyan fiókkal, amely hozzáfér (Loadstone beállításai), vagy állítsa be a GH_TOKEN változót
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = a(z) { $account } forrásból származó tokent elutasították; lehet, hogy lejárt, vagy visszavonták
core-source-token-unreachable = a(z) { $source } nem érhető el a(z) { $account } forrásból származó tokennel

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = a letöltés HTTP { $status } választ adott: { $url }
core-fetch-request-failed = a kérés nem sikerült: { $url }
core-fetch-download-failed = a letöltés nem sikerült: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = olvasási hiba
core-fetch-read-error-download = olvasási hiba letöltés közben

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = ehhez a platformhoz/disztribúcióhoz nem tartozik kibontási útvonal
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } egy fejlesztői munkakönyvtárba mutató hivatkozás. Inkább frissítse azt a munkakönyvtárat a git segítségével, vagy telepítés előtt távolítsa el a hivatkozást.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = ez az archívum nem tartalmazza a várt tartalmat (egyik bejegyzés sem illeszkedik egyik útvonalra sem)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = a(z) „{ $source }” jegyzék sem nem { $formats } formátumú, sem nem létező mappa
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = a(z) { $source } nem tartalmaz loadstone-packages mappát
# $error is the reason the download failed.
core-registry-using-cache = Nem sikerült frissíteni: { $source } ({ $error }); a gyorsítótárban tárolt másolat lesz használva.
core-registry-fetch-failed = nem sikerült lekérni a jegyzéket: { $source }
# $id is a mod's id.
core-registry-package-not-found = a(z) „{ $id }” csomag egyik jegyzékben sem található

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = „{ $key }” logikai érték; használja a true vagy a false értéket
core-setting-not-number = „{ $key }” értékének számnak kell lennie
core-setting-too-small = „{ $key }” értéke nem lehet kisebb ennél: { $min }
core-setting-too-large = „{ $key }” értéke nem lehet nagyobb ennél: { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = „{ $key }” értéke csak a következők egyike lehet: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Tesztelői hozzáférés feloldva egy jegyzék modjaihoz: a csak tesztelőknek szóló modok megjelennek, a telepítések és frissítések pedig bétaverziókat kapnak.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Tesztelői hozzáférés feloldva egy jegyzék modjaihoz és a következőkhöz: { $mods }. A csak tesztelőknek szóló modok megjelennek, a telepítések és frissítések pedig bétaverziókat kapnak.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Tesztelői hozzáférés feloldva a következőkhöz: { $mods }. A csak tesztelőknek szóló modok megjelennek, a telepítések és frissítések pedig bétaverziókat kapnak.
core-tester-save-failed = nem sikerült menteni a tesztelői jelszót
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = A(z) { $tag } kiadás nem tartalmaz használható Loadstone-metaadatokat ({ $error }); a legújabb stabil kiadás lesz használva.
core-tester-beta-lookup-failed = Nem sikerült lekérdezni a bétaverziókat ({ $error }); a legújabb stabil kiadás lesz használva.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = a letöltött frissítés nem ment át a hash-ellenőrzésen (várt érték { $expected }, kapott érték { $actual }); nincs telepítve
core-update-translocated = A macOS ezt az alkalmazást egy ideiglenes, írásvédett másolatból futtatja, ezért az nem tudja frissíteni magát. Helyezze át az Alkalmazások mappába, nyissa meg onnan, és frissítsen újra.
core-update-on-disk-image = ez az alkalmazás a lemezképéről fut, ezért nem tudja frissíteni magát. Másolja az Alkalmazások mappába, nyissa meg onnan, és frissítsen újra.
# $path is the folder the app is in.
core-update-no-write = nem lehet írni a(z) { $path } mellé (nincs jogosultság?), ezért az alkalmazás nem tudja frissíteni magát. Inkább töltse le az új verziót a kiadási oldalról.
core-update-no-staging = nem lehet írni a(z) { $path } mellé (nincs jogosultság?). Inkább töltse le az új verziót a kiadási oldalról
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = a frissítés egy másik alkalmazás ({ $got }, várt érték { $expected }); nincs telepítve
core-update-move-aside-app = nem sikerült félretenni a jelenlegi alkalmazást
core-update-move-in-app = nem sikerült a helyére tenni az új alkalmazást
core-update-move-aside-exe = nem sikerült félretenni a jelenlegi futtatható fájlt
core-update-move-in-exe = nem sikerült a helyére tenni az új futtatható fájlt
