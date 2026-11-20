# Loadstone's interface text, Czech.
# Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Tento mod vyžaduje novější verzi aplikace Loadstone. Aktualizujte Loadstone a zkuste to znovu.

## Loadstone settings

pref-language = Jazyk
pref-language-description = Jazyk, ve kterém se zobrazuje Loadstone a přeložené mody.
language-system = Výchozí jazyk systému
pref-accounts = Účty
pref-accounts-description = Přihlášení, která se používají ke stahování modů ze soukromých repozitářů.
pref-account-rules = Pravidla účtů
pref-account-rules-description = Který účet se má použít pro repozitář nebo vlastníka.
pref-try-other-accounts = Při odmítnutí stahování zkusit moje další účty
pref-try-other-accounts-description = Pokud se repozitář nenajde nebo je přístup odepřen, vyzkouší se před vzdáním ostatní účty pro tento web.
pref-tester-passwords = Hesla testera
pref-tester-passwords-description = Odemykají mody jen pro testery a beta verze, pro celý registr nebo pro jednotlivé mody. Nastavují se tlačítkem Heslo testera.
pref-download-account = Účet pro stahování
pref-download-account-description = Účet, kterým se tento mod stahuje. Možnost Automaticky použije vaše pravidla účtů a výchozí účet.
pref-download-account-automatic = Automaticky (pravidla účtů, potom výchozí účet)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Nastavení Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Účty pro soukromé repozitáře a možnosti aplikace Loadstone
gui-menu-exit = &Konec
# Menu bar title.
gui-menu-tools = Nás&troje
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Operace stále probíhá. Pokud aplikaci teď zavřete, nemusí se dokončit. Přesto zavřít?
gui-close-while-running-title = Probíhá operace
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Načítání...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problém během operace
gui-button-retry = &Opakovat
gui-button-skip = &Přeskočit
gui-button-cancel-problem = &Zrušit
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Možnosti instalace

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (jádro { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mody:
# Button that opens the selected mod's page.
gui-button-details = &Podrobnosti
gui-button-refresh = &Obnovit
gui-button-loadstone-settings = Nastavení &Loadstone...
gui-status-fetching-catalog = Načítání katalogu modů...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Načítání seznamu modů...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Seznam modů se nepodařilo načíst. Stiskněte Obnovit a zkuste to znovu.
gui-status-catalog-failed = Načtení katalogu se nezdařilo.
gui-catalog-error-title = Katalog modů se nepodařilo načíst
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Nejsou k dispozici žádné mody.
gui-status-catalog-loaded = { $count ->
    [one] Katalog načten: { $count } mod.
    [few] Katalog načten: { $count } mody.
    [many] Katalog načten: { $count } modu.
   *[other] Katalog načten: { $count } modů.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Načítání: { $mod_id }...
gui-status-mod-load-failed = Stránku modu se nepodařilo načíst.
gui-mod-error-title = Mod se nepodařilo načíst
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Kopie hry ke správě:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Kopie hry { $game } ke správě:
gui-button-back = &Zpět na seznam modů
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }, autor: { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = Složka &hry:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = Složka &hry { $game }:
gui-button-browse = &Procházet...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Vyberte složku hry
gui-browse-game-prompt-named = Vyberte složku hry { $game }
gui-description-label = Popis:
# Label of the log where operations report their progress.
gui-activity-label = Aktivita:
gui-button-update = &Aktualizovat
gui-button-install = &Nainstalovat
gui-select-folder-first = Nejprve vyberte složku hry tlačítkem Procházet.
gui-button-install-from-file = Nainstalovat ze &souboru...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Vyberte soubor loadstone-release.json modu
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|Soubory JSON (*.json)|*.json|Všechny soubory (*.*)|*.*
gui-button-uninstall = &Odinstalovat
gui-button-launch = Sp&ustit hru
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Spustí hru s načteným modem.
gui-launch-unavailable-description = K dispozici, jakmile bude mod nainstalován sem.
gui-button-change-options = Změnit &možnosti instalace...
gui-change-options-description = Znovu položí instalační otázky modu a přeinstaluje nejnovější verzi s vašimi odpověďmi.
gui-button-settings = Nas&tavení...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Probíhá zpracování... { $percent } %
gui-status-fetching-releases = Načítání seznamu vydání...
# $error is an error message.
gui-release-list-error = Seznam vydání se nepodařilo načíst: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Chcete místo toho nainstalovat nejnovější vydání?
gui-release-list-error-title = Seznam vydání není k dispozici
gui-no-releases = Repozitář tohoto modu zatím nemá žádná vydání.
gui-no-releases-title = Žádná vydání
gui-choose-version = Vyberte verzi, kterou chcete nainstalovat:
gui-choose-version-title = Výběr verze
gui-confirm-uninstall = Chcete odinstalovat mod { $name }?
gui-confirm-uninstall-title = Potvrzení odinstalace
gui-status-working = Probíhá zpracování...
gui-status-op-failed = Operace se nezdařila.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Nelze spustit
gui-op-failed-title = Operace se nezdařila
# Title of the message shown when an operation finished.
gui-op-done-title = Hotovo

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Je k dispozici verze { $version } aplikace { $app } (máte verzi { $current }). Chcete ji teď aktualizovat a restartovat?
gui-self-update-title = Je k dispozici aktualizace
gui-status-downloading-update = Stahování aktualizace...
gui-status-update-failed = Aktualizace se nezdařila.
gui-update-failed-title = Aktualizace se nezdařila
gui-status-update-installed = Aktualizace nainstalována.
gui-update-installed = Aktualizace je nainstalována. Aplikace se nyní restartuje.
gui-update-installed-title = Aktualizace nainstalována

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Nastavení Loadstone není k dispozici: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Nastavení: { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Možnosti modu
gui-mod-options-after-install = Možnosti modu budou k dispozici po jeho instalaci.
gui-status-setting-saved = Nastavení uloženo.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Nastavení uloženo. { $note }
gui-setting-not-changed-title = Nastavení nebylo změněno
gui-status-no-settings-changed = Žádná nastavení nebyla změněna.

## Loadstone settings dialog

gui-loadstone-settings-title = Nastavení Loadstone
gui-accounts-label = Úč&ty:
gui-accounts-description = Přihlášení, která se používají ke stahování modů ze soukromých repozitářů.
gui-button-sign-in = &Přihlásit se...
gui-button-add-token = Přidat t&oken...
gui-button-remove-account = Odeb&rat účet
gui-button-set-default = Nastavit jako &výchozí
# "gh auth token" is a command, keep it.
gui-add-token-description = Přidá účet z tokenu, který již máte, například z příkazu gh auth token nástroje GitHub CLI.
gui-rules-label = Pr&avidla účtů:
gui-rules-description = Který účet se má použít pro repozitář nebo pro všechny repozitáře vlastníka. Bez pravidla se použije výchozí účet.
gui-button-add-rule = Přidat pravid&lo...
gui-button-remove-rule = O&debrat pravidlo
gui-button-tester-password = &Heslo testera...
gui-tester-password-description = Pro soukromé testery: zadejte heslo, které jste dostali, abyste viděli mody jen pro testery a dostávali beta verze. Můžete jich přidat více. Ponechte pole prázdné, chcete-li testování ukončit.
gui-tester-password-prompt-saved = Máte uložená hesla testera. Zadejte další heslo, které chcete přidat, nebo ponechte pole prázdné, chcete-li je všechna zapomenout a ukončit testování.
gui-tester-password-prompt = Zadejte heslo testera, které jste dostali.
gui-tester-password-title = Heslo testera
gui-tester-password-not-saved-title = Heslo testera nebylo uloženo
gui-button-close = &Zavřít
gui-accounts-unavailable-title = Účty nejsou k dispozici
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } na webu { $site }, výchozí
    [missing] { $account }, { $username } na webu { $site }, chybí token (přihlaste se znovu)
    [default-missing] { $account }, { $username } na webu { $site }, výchozí, chybí token (přihlaste se znovu)
   *[none] { $account }, { $username } na webu { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Žádné účty. Přidejte účet tlačítkem Přihlásit se.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } používá účet { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Žádná pravidla.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Vložte token z webu { $site }. Bude ověřen na webu { $site } a poté uložen do Správce pověření systému Windows.
gui-add-token-title = Přidat token
gui-status-account-added = Přidán účet { $account }.
gui-token-not-added-title = Token nebyl přidán
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Chcete odebrat účet { $account }? Loadstone zapomene jeho token a všechna pravidla, která ho používají. Chcete-li Loadstone odebrat i přístup, použijte stránku Applications v nastavení webu { $site }.
gui-remove-account-title = Odebrat účet
gui-account-not-removed-title = Účet nebyl odebrán
gui-default-not-changed-title = Výchozí účet nebyl změněn
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Repozitář (github:owner/repo) nebo všechny repozitáře vlastníka (github:owner/*):
gui-add-rule-title = Přidat pravidlo účtu
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Který účet použít?
gui-rule-not-added-title = Pravidlo nebylo přidáno
gui-rule-not-removed-title = Pravidlo nebylo odebráno

## Signing in

gui-sign-in-no-sites = Žádný web nepodporuje přihlášení.
gui-sign-in-title = Přihlásit se
gui-sign-in-which-site = Ke kterému webu se chcete přihlásit?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Přihlášení k webu { $site }
gui-sign-in-requesting = Vyžadování přihlašovacího kódu z webu { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = Přihlašovací &kód:
gui-button-copy-code = Zkop&írovat kód
gui-button-open-sign-in-page = &Otevřít přihlašovací stránku webu { $site }
gui-button-cancel = Zrušit
gui-sign-in-code-copied = Kód zkopírován. Otevřete přihlašovací stránku a vložte ho tam.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Otevřete stránku { $url }, zadejte níže uvedený kód a schvalte přístup pro Loadstone. Až budete hotovi, toto okno se samo zavře.
gui-sign-in-code-expired = Platnost přihlašovacího kódu vypršela dříve, než byl zadán. Začněte prosím znovu.
# $account is the account's name.
gui-status-signed-in = Přihlášeno jako { $account }.
gui-signed-in = Přihlášeno k webu { $site } jako { $account }.
gui-signed-in-title = Přihlášeno
gui-sign-in-failed-title = Přihlášení se nezdařilo
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Chcete se teď přihlásit účtem, který k tomu má přístup?
gui-offer-sign-in-title = Pro pokračování se přihlaste

## Startup

gui-startup-error-title = Chyba při spuštění Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone – správce modů

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Nainstalováno { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Nainstalováno { $version } (kanál { $channel })
page-catalog-not-installed = Nenainstalováno
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Nainstalováno { $version } pro { $count } kopii
    [few] Nainstalováno { $version } pro { $count } kopie
    [many] Nainstalováno { $version } pro { $count } kopie
   *[other] Nainstalováno { $version } pro { $count } kopií
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Nainstalováno pro { $count } kopii (různé verze)
    [few] Nainstalováno pro { $count } kopie (různé verze)
    [many] Nainstalováno pro { $count } kopie (různé verze)
   *[other] Nainstalováno pro { $count } kopií (různé verze)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Nainstalováno mimo Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Nainstalováno, ale není uvedeno v žádném z nastavených registrů.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (náhled pro testery)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Nejsou nastaveny žádné registry; zobrazují se jen nainstalované mody.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] { $count } mod, který není pro tento počítač k dispozici, je skrytý.
    [few] { $count } mody, které nejsou pro tento počítač k dispozici, jsou skryté.
    [many] { $count } modu, které nejsou pro tento počítač k dispozici, je skryto.
   *[other] { $count } modů, které nejsou pro tento počítač k dispozici, je skryto.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Registry se nepodařilo načíst: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Nenalezeno v nastavených registrech: { $error }
page-note-no-release-metadata = Nejnovější zveřejněné vydání zatím nemá metadata Loadstone, takže nebylo možné zjistit nejnovější verzi.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Poznámka: kopie hry { $game } sdílejí jednu složku modů. Instalace nebo odinstalace modu v jedné kopii ovlivní i ostatní; pro každou kopii je samostatný jen zavaděč modů.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Vyžaduje balíček { $name } (instaluje se automaticky, nyní verze { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Vyžaduje balíček { $name } (instaluje se automaticky).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Nainstalováno { $version } (vývojový kanál).
page-status-up-to-date = Aktuální (verze { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Aktuální (verze { $version }, novější než nejnovější vydání { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = K dispozici je aktualizace: z { $version } na { $latest }.
page-status-installed = Nainstalováno { $version }.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Nainstalováno mimo Loadstone (verze neznámá). Nainstalujte verzi { $latest }, aby Loadstone mohl tuto kopii spravovat.
page-status-foreign = Nainstalováno mimo Loadstone (verze neznámá). Nainstalujte mod, aby Loadstone mohl tuto kopii spravovat.
page-status-ready = Připraveno k instalaci verze { $latest }.
page-status-not-installed = Nenainstalováno.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Na tomto počítači není k dispozici. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Připraveno k instalaci verze { $latest }. Složka hry nebyla nalezena; vyberte ji tlačítkem Procházet.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Nenainstalováno. Složka hry nebyla nalezena; vyberte ji tlačítkem Procházet.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Vyberte složku tlačítkem Procházet. Na tomto počítači není k dispozici. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Vyberte složku tlačítkem Procházet. Připraveno k instalaci verze { $latest }. Složka hry nebyla nalezena; vyberte ji tlačítkem Procházet.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Vyberte složku tlačítkem Procházet. Nenainstalováno. Složka hry nebyla nalezena; vyberte ji tlačítkem Procházet.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Nastavení bude možné upravit po instalaci.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Kopie ({ $distribution }), nainstalováno { $version }, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Kopie ({ $distribution }), nainstalováno mimo Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Kopie ({ $distribution }), nenainstalováno, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Kopie v umístění { $folder }, nainstalováno { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Kopie v umístění { $folder }, nainstalováno mimo Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Kopie v umístění { $folder }, nenainstalováno
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Zatím nebyla nalezena žádná kopie; vyberte složku hry tlačítkem Procházet.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Jiná složka...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = samostatná
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Kanál { $channel } (nejnovější stav větve { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Kanál { $channel } (vývojové sestavení)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (předběžné vydání)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (předběžné vydání)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Dokončeno: { $action }.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Stahování souboru { $file }...
page-self-update-installed = Aktualizace byla ověřena a nainstalována.
page-tester-passwords-removed = Hesla testera byla odebrána. Mody jen pro testery a beta verze jsou opět skryté.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } na webu { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = nejsou nastaveny žádné registry
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = pro „{ $id }“ není znám žádný zdrojový repozitář
# $id is a mod id.
page-error-not-installed-no-registries = „{ $id }“ není nainstalován a nejsou nastaveny žádné registry
# $id is a mod id.
page-error-not-installed-unresolved = „{ $id }“ není nainstalován a nepodařilo se ho dohledat
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = „{ $id }“ není nainstalován a nepodařilo se ho dohledat: { $error }
page-error-tester-password-wrong = Toto není heslo testera pro žádný z vašich registrů ani jejich mody.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = úložiště účtů není k dispozici
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = „{ $value }“ není číslo
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = není konečné číslo

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = neshoda hashe artefaktu pro { $id }: očekáváno { $expected }, obdrženo { $actual }. Instalace odmítnuta.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = neshoda hashe artefaktu pro { $id } ({ $artifact }): očekáváno { $expected }, obdrženo { $actual }. Instalace odmítnuta.
engine-hash-verified = Hash artefaktu ověřen.
engine-hash-none = Pro tento zdroj není k dispozici hash k ověření (místní nebo vývojová instalace).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Odstraňuje se dříve nainstalovaná verze { $version } ({ $count } soubor).
    [few] Odstraňuje se dříve nainstalovaná verze { $version } ({ $count } soubory).
    [many] Odstraňuje se dříve nainstalovaná verze { $version } ({ $count } souboru).
   *[other] Odstraňuje se dříve nainstalovaná verze { $version } ({ $count } souborů).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Upozornění: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Upozornění: nepodařilo se zaznamenat originály, které je ještě třeba obnovit: { $error }
engine-install-failed-rolling-back = Instalace se nezdařila; odstraňují se dosud zapsané soubory.
# Summary shown when an install or update finishes.
engine-installed = Nainstalováno: { $name } { $version }.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Instalace zrušena.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = „{ $id }“ není možnost instalace tohoto modu (možnosti: { $options })
engine-option-unknown-none = „{ $id }“ není možnost instalace tohoto modu (možnosti: žádné)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = „{ $value }“ není platná volba pro { $option } (volby: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = zrušeno: nebyla vybrána žádná volba

## Mod settings

# { $label } is the setting's name.
engine-setting-default = Nastavení „{ $label }“ začíná na výchozí hodnotě; později ho můžete změnit příkazem settings.
# { $path } is the settings file.
engine-settings-written = Nastavení zapsáno do souboru { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = „{ $action }“ není akce balíčku { $id } (k dispozici: { $available })
engine-action-unknown-none = „{ $action }“ není akce balíčku { $id } (k dispozici: žádné)
# { $label } is the action's name, as on its button.
engine-action-unavailable = Akce „{ $label }“ teď není k dispozici (není splněna její podmínka)
engine-action-running = Spouští se akce „{ $label }“...
engine-action-finished = Akce „{ $label }“ dokončena.
engine-no-launch-steps = balíček { $id } nedefinuje pro tuto platformu žádné kroky spuštění
# Summary after starting the game with a mod.
engine-launched = Spuštěno: { $id }.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } je odkaz do vývojové pracovní kopie; soubory přes něj nebudou změněny ani odstraněny. Pokud zde opravdu chcete spravovanou instalaci, nejprve odkaz odstraňte.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = Položka { $path } nebude odstraněna: je mimo složky modu.
engine-legacy-link = Položka { $path } nebude odstraněna: přístup k ní vede přes odkaz.
engine-legacy-shared = Položka { $path } nebude odstraněna: používá ji jiný nainstalovaný balíček.
engine-legacy-removed = Odstraněn pozůstatek: { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Upozornění: { $path } se nepodařilo odstranit: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Požadovaný soubor nebyl nalezen: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Požadavek kroku { $step } není splněn.
engine-step-skipped = Krok { $step } přeskočen.
engine-cancelled-at-step = zrušeno v kroku { $step }
engine-extracting = Rozbalování souborů...
engine-placed-files = { $count ->
    [one] Umístěn { $count } soubor.
    [few] Umístěny { $count } soubory.
    [many] Umístěno { $count } souboru.
   *[other] Umístěno { $count } souborů.
}
engine-kept-existing = Ponechán stávající soubor { $path } (nepřepsán; může být novější).
engine-file-created = Vytvořen a aktualizován soubor { $path }.
engine-file-updated = Aktualizován soubor { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = zrušeno: nebyla vybrána složka pro „{ $prompt }“
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Zkopírováno do schránky: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] Do souboru { $file } sloučena { $count } architektura.
    [few] Do souboru { $file } sloučeny { $count } architektury.
    [many] Do souboru { $file } sloučeno { $count } architektury.
   *[other] Do souboru { $file } sloučeno { $count } architektur.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = nelze spustit: { $path } chybí
engine-program-start-failed = { $path } se nepodařilo spustit
engine-program-started = Spuštěno: { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = { $url } se nepodařilo otevřít
engine-url-opened = Otevřeno: { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = Balíček { $id } stále potřebují: { $dependents }. Nejprve je odinstalujte.
engine-removing-files = { $count ->
    [one] Odstraňuje se { $count } soubor.
    [few] Odstraňují se { $count } soubory.
    [many] Odstraňuje se { $count } souboru.
   *[other] Odstraňuje se { $count } souborů.
}
engine-purge-question = Odstranit také uložená nastavení a předvolby?
engine-purge-done = Uložená nastavení odstraněna.
engine-dependency-unneeded = Balíček { $id } už nepotřebuje žádný nainstalovaný mod; můžete ho také odinstalovat.
# Summary when an uninstall finishes.
engine-uninstalled = Odinstalováno: { $id } { $version }.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Používá se originál, který je již uložen v umístění { $path }.
engine-originals-kept = { $count ->
    [one] Uložena kopie { $count } původního herního souboru.
    [few] Uložena kopie { $count } původních herních souborů.
    [many] Uložena kopie { $count } původního herního souboru.
   *[other] Uložena kopie { $count } původních herních souborů.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Upozornění: originál souboru { $path } teď nelze obnovit ({ $error }). Bude vrácen při aktualizaci nebo odinstalaci tohoto modu.
engine-original-restored = Obnoven originál souboru { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Upozornění: originál souboru { $path } chybí ({ $backup }); soubor zůstává beze změny.
engine-original-changed = Soubor { $path } se od instalace tohoto modu změnil (aktualizace hry?); ponechává se novější soubor.
engine-originals-restored = { $count ->
    [one] Obnoven { $count } původní herní soubor.
    [few] Obnoveny { $count } původní herní soubory.
    [many] Obnoveno { $count } původního herního souboru.
   *[other] Obnoveno { $count } původních herních souborů.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] nepodařilo se vrátit { $count } původní herní soubor; zavřete hru a zkuste to znovu.
    [few] nepodařilo se vrátit { $count } původní herní soubory; zavřete hru a zkuste to znovu.
    [many] nepodařilo se vrátit { $count } původního herního souboru; zavřete hru a zkuste to znovu.
   *[other] nepodařilo se vrátit { $count } původních herních souborů; zavřete hru a zkuste to znovu.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Aktualizuje se kopie { $distribution } v umístění { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = „{ $id }“ je nainstalován pro více než jednu kopii hry { $game }: { $copies }. Pomocí --game-dir určete, kterou kopii aktualizovat.
engine-many-copies = „{ $id }“ je nainstalován pro více než jednu kopii hry { $game }: { $copies }. Pomocí --game-dir určete, o kterou kopii jde.
engine-not-game-folder = { $path } nevypadá jako složka hry { $game } (nebyl nalezen žádný z očekávaných souborů)
engine-game-found = Hra { $game } nalezena v umístění { $path }
engine-game-not-found = Hru { $game } se nepodařilo automaticky najít.
# Title of the folder picker.
engine-game-where = Kde je nainstalována hra { $game }?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = hru { $game } se nepodařilo automaticky najít; použijte --game-dir nebo vyberte její složku
# { $path } is a game folder.
engine-not-installed-copy = „{ $id }“ není nainstalován pro kopii hry { $game } v umístění { $path }
engine-not-installed = „{ $id }“ není nainstalován pro hru { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = Mod { $name } nelze na tento počítač nainstalovat. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = kopie { $distribution } hry { $game } není podporována. { $reason }
engine-distribution-untested = Poznámka: kopie { $distribution } hry { $game } nebyla s tímto modem testována.
engine-no-matching-artifact = žádný artefakt vydání neodpovídá této platformě/architektuře/distribuci
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Tento mod je k dispozici jen pro systém { $platform }.
engine-platform-only-two = Tento mod je k dispozici jen pro systémy { $first } a { $second }.
engine-platform-only-three = Tento mod je k dispozici jen pro systémy { $first }, { $second } a { $third }.
engine-platform-needs-apple-silicon = V systému { $platform } tento mod vyžaduje procesor Apple Silicon.
engine-platform-needs-arm = V systému { $platform } tento mod vyžaduje procesor ARM.
engine-platform-needs-x64 = V systému { $platform } tento mod vyžaduje procesor Intel nebo AMD.
engine-game-platform-unsupported = Hra { $game } zde není v systému { $platform } podporována.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = Mod { $name } je aktuální ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = Mod { $name } je aktuální (verze { $installed } je novější než nejnovější vydání { $latest }).
engine-installed-newer = Je nainstalován mod { $name } { $installed }, který je novější než nejnovější vydání, které máte teď k dispozici ({ $latest }). Nic nebylo změněno. Chcete-li nainstalovat starší verzi, vyberte ji výslovně.
# { $from } and { $to } are versions.
engine-updating = Aktualizuje se mod { $name }: { $from } -> { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Nainstalovat mod { $name } z nejnovějšího stavu větve { $branch } ({ $version })?

    Vývojová sestavení nejsou zajištěna hashem; spoléháte na aktuální obsah repozitáře.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Poznámky k vydání: { $name } { $version }

    { $notes }

    Nainstalovat nyní?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Načítání informací o vydání { $tag } ze zdroje { $source }...
engine-fetching-latest = Načítání informací o nejnovějším vydání ze zdroje { $source }...
engine-using-local-artifact = Používá se místní artefakt { $path }
# { $file } is a download's file name.
engine-using-cached = Používá se již stažený soubor { $file }.
engine-downloading = Stahování souboru { $file }...
engine-dependency-present = Závislost { $id } { $version } je již nainstalována.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Instaluje se závislost { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = nebyl zadán žádný token
core-sign-in-cancelled = Přihlášení zrušeno.
core-sign-in-expired = Platnost přihlašovacího kódu vypršela dříve, než byl zadán. Začněte prosím znovu.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = „{ $pattern }“ není zdroj (github:owner/repo) ani zástupný vzor vlastníka (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = token se nepodařilo uložit do systémového úložiště pověření
core-secrets-remove-failed = token se nepodařilo odebrat ze systémového úložiště pověření

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = vydání { $tag } ze zdroje { $source } neobsahuje soubor { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = nejnovější vydání ze zdroje { $source } neobsahuje soubor { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = vydání { $tag } neobsahuje soubor loadstone-release.json (nebo není dostupný)
core-github-sign-in-cancelled = Přihlášení bylo na GitHubu zrušeno.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub přihlášení odmítl: { $details }
core-github-sign-in-refused-no-details = GitHub přihlášení odmítl: bez podrobností
core-github-token-rejected = GitHub token nepřijal

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = web { $site } nepodporuje přihlášení
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = „{ $source }“ není zdroj ve formátu { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = Zdroj { $source } nebyl nalezen. Pokud jde o soukromý repozitář, přihlaste se účtem, který k němu má přístup (Nastavení Loadstone), nebo nastavte GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = token z { $account } byl odmítnut; možná vypršel nebo byl odvolán
core-source-token-unreachable = zdroj { $source } není s tokenem z { $account } dostupný

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = stahování { $url } vrátilo HTTP { $status }
core-fetch-request-failed = požadavek se nezdařil: { $url }
core-fetch-download-failed = stahování se nezdařilo: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = chyba čtení
core-fetch-read-error-download = chyba čtení během stahování

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = pro tuto platformu/distribuci neplatí žádný způsob rozbalení
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } je odkaz do vývojové pracovní kopie. Aktualizujte místo toho tuto pracovní kopii pomocí git, nebo před instalací odkaz odstraňte.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = tento archiv neobsahuje očekávaný obsah (žádná položka neodpovídá žádnému způsobu rozbalení)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = registr „{ $source }“ není ve formátu { $formats } ani existující složka
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } nemá složku loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = { $source } se nepodařilo obnovit ({ $error }); používá se kopie z mezipaměti.
core-registry-fetch-failed = registr { $source } se nepodařilo načíst
# $id is a mod's id.
core-registry-package-not-found = balíček „{ $id }“ nebyl nalezen v žádném registru

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = „{ $key }“ je logická hodnota; použijte true nebo false
core-setting-not-number = „{ $key }“ vyžaduje číslo
core-setting-too-small = „{ $key }“ musí být alespoň { $min }
core-setting-too-large = „{ $key }“ může být nejvýše { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = „{ $key }“ musí mít jednu z hodnot: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Přístup testera odemčen pro mody registru: zobrazují se mody jen pro testery a instalace a aktualizace dostávají beta verze.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Přístup testera odemčen pro mody registru a pro: { $mods }. Zobrazují se mody jen pro testery a instalace a aktualizace dostávají beta verze.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Přístup testera odemčen pro: { $mods }. Zobrazují se mody jen pro testery a instalace a aktualizace dostávají beta verze.
core-tester-save-failed = heslo testera se nepodařilo uložit
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = Vydání { $tag } nemá použitelná metadata Loadstone ({ $error }); používá se nejnovější stabilní vydání.
core-tester-beta-lookup-failed = Beta verze se nepodařilo vyhledat ({ $error }); používá se nejnovější stabilní vydání.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = stažená aktualizace neprošla ověřením hashe (očekáváno { $expected }, obdrženo { $actual }); nenainstalováno
core-update-translocated = macOS spouští tuto aplikaci z dočasné kopie jen pro čtení, takže se nemůže sama aktualizovat. Přesuňte ji do složky Aplikace, otevřete ji odtud a aktualizujte znovu.
core-update-on-disk-image = tato aplikace běží ze svého obrazu disku, takže se nemůže sama aktualizovat. Zkopírujte ji do složky Aplikace, otevřete ji odtud a aktualizujte znovu.
# $path is the folder the app is in.
core-update-no-write = vedle { $path } nelze zapisovat (chybí oprávnění?), takže se aplikace nemůže sama aktualizovat. Stáhněte místo toho novou verzi ze stránky vydání.
core-update-no-staging = vedle { $path } nelze zapisovat (chybí oprávnění?). Stáhněte místo toho novou verzi ze stránky vydání
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = aktualizace je jiná aplikace ({ $got }, očekáváno { $expected }); nenainstalováno
core-update-move-aside-app = současnou aplikaci se nepodařilo odsunout stranou
core-update-move-in-app = novou aplikaci se nepodařilo přesunout na místo
core-update-move-aside-exe = současný spustitelný soubor se nepodařilo odsunout stranou
core-update-move-in-exe = nový spustitelný soubor se nepodařilo přesunout na místo

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = &OK
gui-stock-ok-plain = OK
gui-stock-cancel = &Zrušit
gui-stock-cancel-plain = Zrušit
gui-stock-yes = &Ano
gui-stock-yes-plain = Ano
gui-stock-no = &Ne
gui-stock-no-plain = Ne
gui-stock-close = &Zavřít
gui-stock-close-plain = Zavřít
