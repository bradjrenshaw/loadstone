# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Для цього мода потрібна новіша версія Loadstone. Оновіть Loadstone і спробуйте ще раз.

## Loadstone settings

pref-language = Мова
pref-language-description = Мова інтерфейсу Loadstone і перекладених модів.
language-system = Як у системі
pref-accounts = Облікові записи
pref-accounts-description = Облікові записи для завантаження модів із закритих репозиторіїв.
pref-account-rules = Правила облікових записів
pref-account-rules-description = Який обліковий запис використовувати для репозиторію або власника.
pref-try-other-accounts = Пробувати інші мої облікові записи, якщо завантаження відхилено
pref-try-other-accounts-description = Якщо репозиторій не знайдено або доступ заборонено, Loadstone спробує інші облікові записи для цього сайту, перш ніж здатися.
pref-tester-passwords = Паролі тестувальника
pref-tester-passwords-description = Відкривають моди лише для тестувальників і бета-версії для всього реєстру або для окремих модів. Задаються кнопкою «Пароль тестувальника».
pref-download-account = Обліковий запис для завантаження
pref-download-account-description = Обліковий запис, через який завантажується цей мод. В автоматичному режимі використовуються ваші правила облікових записів і обліковий запис за замовчуванням.
pref-download-account-automatic = Автоматично (правила облікових записів, потім обліковий запис за замовчуванням)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Налаштування Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Облікові записи для закритих репозиторіїв і параметри Loadstone
gui-menu-exit = В&ихід
# Menu bar title.
gui-menu-tools = &Інструменти
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Операція ще виконується. Якщо закрити вікно зараз, вона може лишитися незавершеною. Усе одно закрити?
gui-close-while-running-title = Виконується операція
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Завантаження...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Проблема під час операції
gui-button-retry = &Повторити
gui-button-skip = Пр&опустити
gui-button-cancel-problem = &Скасувати
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Параметри встановлення

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (ядро { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Моди:
# Button that opens the selected mod's page.
gui-button-details = &Докладніше
gui-button-refresh = &Оновити
gui-button-loadstone-settings = &Налаштування Loadstone...
gui-status-fetching-catalog = Отримання каталогу модів...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Завантаження списку модів...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Не вдалося завантажити список модів. Натисніть «Оновити», щоб спробувати ще раз.
gui-status-catalog-failed = Не вдалося отримати каталог.
gui-catalog-error-title = Не вдалося завантажити каталог модів
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Немає доступних модів.
gui-status-catalog-loaded = { $count ->
    [one] Каталог завантажено: { $count } мод.
    [few] Каталог завантажено: { $count } моди.
    [many] Каталог завантажено: { $count } модів.
   *[other] Каталог завантажено: { $count } мода.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Завантаження { $mod_id }...
gui-status-mod-load-failed = Не вдалося завантажити сторінку мода.
gui-mod-error-title = Не вдалося завантажити мод
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Копія гри для керування:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Копія гри { $game } для керування:
gui-button-back = &Назад до списку модів
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name } від { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = &Папка гри:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = &Папка гри { $game }:
gui-button-browse = О&гляд...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Виберіть папку гри
gui-browse-game-prompt-named = Виберіть папку гри { $game }
gui-description-label = Опис:
# Label of the log where operations report their progress.
gui-activity-label = Журнал дій:
gui-button-update = Онов&ити
gui-button-install = &Встановити
gui-select-folder-first = Спочатку виберіть папку гри кнопкою «Огляд».
gui-button-install-from-file = Встановити з &файлу...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Виберіть файл loadstone-release.json мода
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|Файли JSON (*.json)|*.json|Усі файли (*.*)|*.*
gui-button-uninstall = Ви&далити
gui-button-launch = &Запустити гру
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Запускає гру із завантаженим модом.
gui-launch-unavailable-description = Стане доступно після встановлення мода в цю копію.
gui-button-change-options = Змінити п&араметри встановлення...
gui-change-options-description = Знову ставить запитання встановлення мода й перевстановлює останню версію з вашими відповідями.
gui-button-settings = Нала&штування...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Виконується... { $percent }%
gui-status-fetching-releases = Отримання списку випусків...
# $error is an error message.
gui-release-list-error = Не вдалося отримати список випусків: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Встановити останній випуск?
gui-release-list-error-title = Список випусків недоступний
gui-no-releases = У репозиторії цього мода ще немає випусків.
gui-no-releases-title = Немає випусків
gui-choose-version = Виберіть версію для встановлення:
gui-choose-version-title = Вибір версії
gui-confirm-uninstall = Видалити мод { $name }?
gui-confirm-uninstall-title = Підтвердження видалення
gui-status-working = Виконується...
gui-status-op-failed = Операцію не виконано.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Не вдається запустити
gui-op-failed-title = Помилка операції
# Title of the message shown when an operation finished.
gui-op-done-title = Готово

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Доступна версія { $version } програми { $app } (у вас встановлено { $current }). Оновити й перезапустити зараз?
gui-self-update-title = Доступне оновлення
gui-status-downloading-update = Завантаження оновлення...
gui-status-update-failed = Не вдалося виконати оновлення.
gui-update-failed-title = Помилка оновлення
gui-status-update-installed = Оновлення встановлено.
gui-update-installed = Оновлення встановлено. Зараз програму буде перезапущено.
gui-update-installed-title = Оновлення встановлено

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Налаштування Loadstone недоступні: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Налаштування: { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Параметри мода
gui-mod-options-after-install = Параметри мода стануть доступні після його встановлення.
gui-status-setting-saved = Налаштування збережено.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Налаштування збережено. { $note }
gui-setting-not-changed-title = Налаштування не змінено
gui-status-no-settings-changed = Жодних налаштувань не змінено.

## Loadstone settings dialog

gui-loadstone-settings-title = Налаштування Loadstone
gui-accounts-label = &Облікові записи:
gui-accounts-description = Облікові записи для завантаження модів із закритих репозиторіїв.
gui-button-sign-in = &Увійти...
gui-button-add-token = Додати &токен...
gui-button-remove-account = &Видалити обліковий запис
gui-button-set-default = Зробити &основним
# "gh auth token" is a command, keep it.
gui-add-token-description = Додавання облікового запису за наявним токеном, наприклад отриманим командою gh auth token з GitHub CLI.
gui-rules-label = &Правила облікових записів:
gui-rules-description = Який обліковий запис використовувати для репозиторію або для всіх репозиторіїв власника. Якщо правила немає, використовується обліковий запис за замовчуванням.
gui-button-add-rule = Додати п&равило...
gui-button-remove-rule = Видали&ти правило
gui-button-tester-password = Па&роль тестувальника...
gui-tester-password-description = Для закритого тестування: введіть наданий вам пароль, щоб бачити моди лише для тестувальників і отримувати бета-версії. Можна додати кілька паролів. Залиште поле порожнім, щоб припинити тестування.
gui-tester-password-prompt-saved = У вас є збережені паролі тестувальника. Введіть ще один, щоб додати його, або залиште поле порожнім, щоб забути їх усі й припинити тестування.
gui-tester-password-prompt = Введіть наданий вам пароль тестувальника.
gui-tester-password-title = Пароль тестувальника
gui-tester-password-not-saved-title = Пароль тестувальника не збережено
gui-button-close = &Закрити
gui-accounts-unavailable-title = Облікові записи недоступні
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } на { $site }, за замовчуванням
    [missing] { $account }, { $username } на { $site }, немає токена (увійдіть знову)
    [default-missing] { $account }, { $username } на { $site }, за замовчуванням, немає токена (увійдіть знову)
   *[none] { $account }, { $username } на { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Немає облікових записів. Щоб додати, натисніть «Увійти».
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern }: обліковий запис { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Немає правил.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Вставте токен { $site }. Його буде перевірено на сайті { $site }, а потім збережено в диспетчері облікових даних Windows.
gui-add-token-title = Додавання токена
gui-status-account-added = Додано обліковий запис { $account }.
gui-token-not-added-title = Токен не додано
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Видалити обліковий запис { $account }? Loadstone забуде його токен і всі правила, що його використовують. Щоб також відкликати доступ Loadstone, відкрийте розділ Applications у налаштуваннях { $site }.
gui-remove-account-title = Видалення облікового запису
gui-account-not-removed-title = Обліковий запис не видалено
gui-default-not-changed-title = Обліковий запис за замовчуванням не змінено
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Репозиторій (github:owner/repo) або всі репозиторії власника (github:owner/*):
gui-add-rule-title = Додавання правила облікового запису
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Який обліковий запис використовувати?
gui-rule-not-added-title = Правило не додано
gui-rule-not-removed-title = Правило не видалено

## Signing in

gui-sign-in-no-sites = Жоден сайт не підтримує вхід.
gui-sign-in-title = Вхід
gui-sign-in-which-site = На якому сайті увійти?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Вхід на { $site }
gui-sign-in-requesting = Запит коду для входу в { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &Код для входу:
gui-button-copy-code = Ск&опіювати код
gui-button-open-sign-in-page = &Відкрити сторінку входу { $site }
gui-button-cancel = Скасувати
gui-sign-in-code-copied = Код скопійовано. Відкрийте сторінку входу та вставте його там.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Відкрийте { $url }, введіть код, наведений нижче, і надайте доступ Loadstone. Це вікно закриється саме, коли все буде готово.
gui-sign-in-code-expired = Термін дії коду для входу минув до того, як його ввели. Почніть знову.
# $account is the account's name.
gui-status-signed-in = Виконано вхід: { $account }.
gui-signed-in = Виконано вхід на { $site } з обліковим записом { $account }.
gui-signed-in-title = Вхід виконано
gui-sign-in-failed-title = Не вдалося увійти
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Увійти зараз з обліковим записом, який має доступ?
gui-offer-sign-in-title = Увійдіть, щоб продовжити

## Startup

gui-startup-error-title = Помилка запуску Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Менеджер модів Loadstone

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Встановлено { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Встановлено { $version } (канал { $channel })
page-catalog-not-installed = Не встановлено
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Встановлено { $version } у { $count } копії
    [few] Встановлено { $version } у { $count } копіях
    [many] Встановлено { $version } у { $count } копіях
   *[other] Встановлено { $version } у { $count } копії
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Встановлено у { $count } копії (версії різняться)
    [few] Встановлено у { $count } копіях (версії різняться)
    [many] Встановлено у { $count } копіях (версії різняться)
   *[other] Встановлено у { $count } копії (версії різняться)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Встановлено не через Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Встановлено, але немає в жодному з налаштованих реєстрів.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (попередня версія для тестувальників)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Реєстри не налаштовано; показано лише встановлені моди.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] Приховано { $count } мод, недоступний для цього комп’ютера.
    [few] Приховано { $count } моди, недоступні для цього комп’ютера.
    [many] Приховано { $count } модів, недоступних для цього комп’ютера.
   *[other] Приховано { $count } мода, недоступних для цього комп’ютера.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Не вдалося завантажити реєстри: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Не знайдено в налаштованих реєстрах: { $error }
page-note-no-release-metadata = Останній опублікований випуск ще не має метаданих Loadstone, тому не вдалося визначити найновішу версію.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Примітка: копії гри { $game } використовують одну спільну папку модів. Встановлення або видалення мода в одній копії впливає на інші; окремим для кожної копії залишається лише завантажувач модів.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Потрібен { $name } (встановлюється автоматично, зараз версія { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Потрібен { $name } (встановлюється автоматично).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Встановлено { $version } (канал розробки).
page-status-up-to-date = Встановлено останню версію ({ $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Встановлено останню версію ({ $version }, новіша за останній випуск { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Доступне оновлення: з { $version } до { $latest }.
page-status-installed = Встановлено { $version }.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Встановлено не через Loadstone (версія невідома). Встановіть версію { $latest }, щоб Loadstone керував цією копією.
page-status-foreign = Встановлено не через Loadstone (версія невідома). Виконайте встановлення, щоб Loadstone керував цією копією.
page-status-ready = Готово до встановлення версії { $latest }.
page-status-not-installed = Не встановлено.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Недоступно на цьому комп’ютері. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Готово до встановлення версії { $latest }. Папку гри не знайдено; виберіть її кнопкою «Огляд».
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Не встановлено. Папку гри не знайдено; виберіть її кнопкою «Огляд».
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Виберіть папку кнопкою «Огляд». Недоступно на цьому комп’ютері. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Виберіть папку кнопкою «Огляд». Готово до встановлення версії { $latest }. Папку гри не знайдено; виберіть її кнопкою «Огляд».
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Виберіть папку кнопкою «Огляд». Не встановлено. Папку гри не знайдено; виберіть її кнопкою «Огляд».
# Shown with a mod's settings before it is installed.
page-settings-after-install = Налаштування можна буде змінити після встановлення.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Копія { $distribution }, встановлено { $version }, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Копія { $distribution }, встановлено не через Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Копія { $distribution }, не встановлено, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Копія в { $folder }, встановлено { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Копія в { $folder }, встановлено не через Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Копія в { $folder }, не встановлено
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Копію ще не знайдено; виберіть папку гри кнопкою «Огляд».
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Інша папка...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Окрема версія
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Канал { $channel } (остання збірка з гілки { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Канал { $channel } (збірка для розробки)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (попередній випуск)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (попередній випуск)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Дію «{ $action }» виконано.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Завантаження { $file }...
page-self-update-installed = Оновлення перевірено й встановлено.
page-tester-passwords-removed = Паролі тестувальника видалено. Моди лише для тестувальників і бета-версії знову приховано.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } на { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = реєстри не налаштовано
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = для «{ $id }» невідомий вихідний репозиторій
# $id is a mod id.
page-error-not-installed-no-registries = «{ $id }» не встановлено, а реєстри не налаштовано
# $id is a mod id.
page-error-not-installed-unresolved = «{ $id }» не встановлено, і його не вдалося знайти
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = «{ $id }» не встановлено, і його не вдалося знайти: { $error }
page-error-tester-password-wrong = Це не пароль тестувальника для жодного з ваших реєстрів або їхніх модів.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = сховище облікових записів недоступне
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = «{ $value }» не є числом
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = значення не є скінченним числом

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = хеш завантаженого файлу для { $id } не збігається: очікувався { $expected }, отримано { $actual }. Встановлення скасовано.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = хеш завантаженого файлу для { $id } ({ $artifact }) не збігається: очікувався { $expected }, отримано { $actual }. Встановлення скасовано.
engine-hash-verified = Хеш файлу перевірено.
engine-hash-none = Для цього джерела немає хешу для перевірки (локальне встановлення або встановлення збірки для розробки).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Видалення раніше встановленої версії { $version } ({ $count } файл).
    [few] Видалення раніше встановленої версії { $version } ({ $count } файли).
    [many] Видалення раніше встановленої версії { $version } ({ $count } файлів).
   *[other] Видалення раніше встановленої версії { $version } ({ $count } файлу).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Попередження: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Попередження: не вдалося записати список оригінальних файлів, які ще треба відновити: { $error }
engine-install-failed-rolling-back = Помилка встановлення; видалення вже записаних файлів.
# Summary shown when an install or update finishes.
engine-installed = Встановлено: { $name } { $version }.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Встановлення скасовано.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = «{ $id }» не є параметром встановлення цього мода (параметри: { $options })
engine-option-unknown-none = «{ $id }» не є параметром встановлення цього мода (параметрів немає)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = «{ $value }» не є допустимим варіантом для { $option } (варіанти: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = скасовано: варіант не вибрано

## Mod settings

# { $label } is the setting's name.
engine-setting-default = Налаштування «{ $label }» має значення за замовчуванням; його можна змінити пізніше командою налаштувань.
# { $path } is the settings file.
engine-settings-written = Налаштування записано в { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = «{ $action }» не є дією { $id } (доступні: { $available })
engine-action-unknown-none = «{ $action }» не є дією { $id } (доступних дій немає)
# { $label } is the action's name, as on its button.
engine-action-unavailable = Дія «{ $label }» зараз недоступна (не виконано її попередньої умови)
engine-action-running = Виконання дії «{ $label }»...
engine-action-finished = Дію «{ $label }» завершено.
engine-no-launch-steps = { $id } не містить кроків запуску для цієї платформи
# Summary after starting the game with a mod.
engine-launched = Запущено: { $id }.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } є посиланням на робочу копію розробника; змінювати або видаляти файли через нього не можна. Якщо ви справді хочете кероване встановлення тут, спочатку видаліть посилання.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = Не видаляється { $path }: розташовано поза папками мода.
engine-legacy-link = Не видаляється { $path }: доступ до нього йде через посилання.
engine-legacy-shared = Не видаляється { $path }: його використовує інший встановлений пакет.
engine-legacy-removed = Видалено залишок старого встановлення: { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Попередження: не вдалося видалити { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Не знайдено потрібний файл: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Не виконано вимогу кроку { $step }.
engine-step-skipped = Крок { $step } пропущено.
engine-cancelled-at-step = скасовано на кроці { $step }
engine-extracting = Видобування файлів...
engine-placed-files = { $count ->
    [one] Розміщено { $count } файл.
    [few] Розміщено { $count } файли.
    [many] Розміщено { $count } файлів.
   *[other] Розміщено { $count } файлу.
}
engine-kept-existing = Залишено наявний файл { $path } (не перезаписано: він може бути новішим).
engine-file-created = Створено й оновлено файл { $path }.
engine-file-updated = Оновлено файл { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = скасовано: не вибрано папку для запиту «{ $prompt }»
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Скопійовано в буфер обміну: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] У { $file } об’єднано { $count } архітектуру.
    [few] У { $file } об’єднано { $count } архітектури.
    [many] У { $file } об’єднано { $count } архітектур.
   *[other] У { $file } об’єднано { $count } архітектури.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = не вдається запустити: { $path } відсутній
engine-program-start-failed = не вдалося запустити { $path }
engine-program-started = Запущено: { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = не вдалося відкрити { $url }
engine-url-opened = Відкрито: { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } досі потрібен для: { $dependents }. Спочатку видаліть їх.
engine-removing-files = { $count ->
    [one] Видалення { $count } файлу.
    [few] Видалення { $count } файлів.
    [many] Видалення { $count } файлів.
   *[other] Видалення { $count } файлу.
}
engine-purge-question = Видалити також збережені налаштування й параметри?
engine-purge-done = Збережені налаштування видалено.
engine-dependency-unneeded = { $id } більше не потрібен жодному встановленому моду; його теж можна видалити.
# Summary when an uninstall finishes.
engine-uninstalled = Видалено: { $id } { $version }.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Використовується оригінал, уже збережений у { $path }.
engine-originals-kept = { $count ->
    [one] Збережено копію { $count } оригінального файлу гри.
    [few] Збережено копії { $count } оригінальних файлів гри.
    [many] Збережено копії { $count } оригінальних файлів гри.
   *[other] Збережено копії { $count } оригінального файлу гри.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Попередження: зараз не вдалося відновити оригінал { $path } ({ $error }). Його буде повернуто під час оновлення або видалення цього мода.
engine-original-restored = Відновлено оригінал { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Попередження: оригінал { $path } відсутній ({ $backup }); файл залишено без змін.
engine-original-changed = Файл { $path } змінився після встановлення цього мода (оновлення гри?); залишено новіший файл.
engine-originals-restored = { $count ->
    [one] Відновлено { $count } оригінальний файл гри.
    [few] Відновлено { $count } оригінальні файли гри.
    [many] Відновлено { $count } оригінальних файлів гри.
   *[other] Відновлено { $count } оригінального файлу гри.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] не вдалося повернути { $count } оригінальний файл гри; закрийте гру й спробуйте ще раз.
    [few] не вдалося повернути { $count } оригінальні файли гри; закрийте гру й спробуйте ще раз.
    [many] не вдалося повернути { $count } оригінальних файлів гри; закрийте гру й спробуйте ще раз.
   *[other] не вдалося повернути { $count } оригінального файлу гри; закрийте гру й спробуйте ще раз.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Оновлення копії { $distribution } у { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = «{ $id }» встановлено в кількох копіях гри { $game }: { $copies }. Вкажіть параметр --game-dir, щоб вибрати копію для оновлення.
engine-many-copies = «{ $id }» встановлено в кількох копіях гри { $game }: { $copies }. Вкажіть параметр --game-dir, щоб вибрати копію.
engine-not-game-folder = Папка { $path } не схожа на папку гри { $game } (не знайдено жодного з очікуваних файлів)
engine-game-found = Гру { $game } знайдено в { $path }
engine-game-not-found = Не вдалося автоматично знайти гру { $game }.
# Title of the folder picker.
engine-game-where = Де встановлено гру { $game }?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = не вдалося автоматично знайти гру { $game }; вкажіть параметр --game-dir або виберіть її папку
# { $path } is a game folder.
engine-not-installed-copy = «{ $id }» не встановлено в копії гри { $game } у { $path }
engine-not-installed = «{ $id }» не встановлено для гри { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = Мод { $name } не можна встановити на цей комп’ютер. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = копія { $distribution } гри { $game } не підтримується. { $reason }
engine-distribution-untested = Примітка: копію { $distribution } гри { $game } не перевіряли з цим модом.
engine-no-matching-artifact = жоден файл випуску не підходить для цієї платформи, архітектури та магазину
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Цей мод доступний лише для { $platform }.
engine-platform-only-two = Цей мод доступний лише для { $first } і { $second }.
engine-platform-only-three = Цей мод доступний лише для { $first }, { $second } і { $third }.
engine-platform-needs-apple-silicon = Для роботи цього мода в { $platform } потрібен процесор Apple Silicon.
engine-platform-needs-arm = Для роботи цього мода в { $platform } потрібен процесор ARM.
engine-platform-needs-x64 = Для роботи цього мода в { $platform } потрібен процесор Intel або AMD.
engine-game-platform-unsupported = Гра { $game } тут не підтримується в { $platform }.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name }: встановлено останню версію ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name }: встановлено останню версію ({ $installed } новіша за останній випуск { $latest }).
engine-installed-newer = Встановлено версію { $installed } мода { $name }, вона новіша за останній доступний вам випуск ({ $latest }). Нічого не змінено. Щоб встановити старішу версію, виберіть її явно.
# { $from } and { $to } are versions.
engine-updating = Оновлення { $name } з версії { $from } до версії { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Встановити { $name } з поточного стану гілки { $branch } ({ $version })?

    Збірки для розробки не захищено перевіркою хешу; ви довіряєте поточному вмісту репозиторію.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Примітки до випуску { $name } { $version }:

    { $notes }

    Встановити зараз?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Отримання відомостей про випуск { $tag } з { $source }...
engine-fetching-latest = Отримання відомостей про останній випуск з { $source }...
engine-using-local-artifact = Використовується локальний файл { $path }
# { $file } is a download's file name.
engine-using-cached = Використовується вже завантажений файл { $file }.
engine-downloading = Завантаження { $file }...
engine-dependency-present = Залежність { $id } { $version } уже встановлено.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Встановлення залежності { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = токен не вказано
core-sign-in-cancelled = Вхід скасовано.
core-sign-in-expired = Термін дії коду для входу минув до того, як його ввели. Почніть знову.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = «{ $pattern }» не є ні джерелом (github:owner/repo), ні шаблоном власника (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = не вдалося зберегти токен у системному сховищі облікових даних
core-secrets-remove-failed = не вдалося видалити токен із системного сховища облікових даних

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = у випуску { $tag } з { $source } немає файлу { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = в останньому випуску з { $source } немає файлу { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = у випуску { $tag } немає файлу loadstone-release.json (або він недоступний)
core-github-sign-in-cancelled = Вхід скасовано на GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub відхилив вхід: { $details }
core-github-sign-in-refused-no-details = GitHub відхилив вхід без пояснення причин
core-github-token-rejected = GitHub не прийняв токен

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } не підтримує вхід
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = «{ $source }» не є джерелом у форматі { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } не знайдено. Якщо це закритий репозиторій, увійдіть з обліковим записом, який має до нього доступ (у налаштуваннях Loadstone), або задайте GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = токен з { $account } відхилено; можливо, термін його дії минув або його відкликано
core-source-token-unreachable = { $source } недоступний з токеном з { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = під час завантаження { $url } отримано відповідь HTTP { $status }
core-fetch-request-failed = помилка запиту: { $url }
core-fetch-download-failed = помилка завантаження: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = помилка читання
core-fetch-read-error-download = помилка читання під час завантаження

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = немає способу видобування для цієї платформи та магазину
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } є посиланням на робочу копію розробника. Оновіть цю робочу копію через git або видаліть посилання перед встановленням.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = у цьому архіві немає очікуваного вмісту (жоден елемент не відповідає жодному способу видобування)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = реєстр «{ $source }» не відповідає формату { $formats } і не є наявною папкою
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = у { $source } немає папки loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = Не вдалося оновити { $source } ({ $error }); використовується збережена копія.
core-registry-fetch-failed = не вдалося отримати реєстр { $source }
# $id is a mod's id.
core-registry-package-not-found = пакет «{ $id }» не знайдено в жодному реєстрі

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = «{ $key }» приймає логічне значення; використовуйте true або false
core-setting-not-number = для «{ $key }» потрібне число
core-setting-too-small = значення «{ $key }» має бути не менше { $min }
core-setting-too-large = значення «{ $key }» має бути не більше { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = значення «{ $key }» має бути одним із таких: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Доступ тестувальника відкрито для модів реєстру: показано моди лише для тестувальників, а під час встановлення й оновлення завантажуються бета-версії.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Доступ тестувальника відкрито для модів реєстру і для { $mods }: показано моди лише для тестувальників, а під час встановлення й оновлення завантажуються бета-версії.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Доступ тестувальника відкрито для { $mods }: показано моди лише для тестувальників, а під час встановлення й оновлення завантажуються бета-версії.
core-tester-save-failed = не вдалося зберегти пароль тестувальника
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = Випуск { $tag } не має придатних метаданих Loadstone ({ $error }); використовується останній стабільний випуск.
core-tester-beta-lookup-failed = Не вдалося знайти бета-версії ({ $error }); використовується останній стабільний випуск.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = завантажене оновлення не пройшло перевірку хешу (очікувався { $expected }, отримано { $actual }); оновлення не встановлено
core-update-translocated = macOS запускає цю програму з тимчасової копії, доступної лише для читання, тому вона не може оновитися сама. Перемістіть її в папку «Програми», відкрийте звідти й оновіть знову.
core-update-on-disk-image = цю програму запущено з образу диска, тому вона не може оновитися сама. Скопіюйте її в папку «Програми», відкрийте звідти й оновіть знову.
# $path is the folder the app is in.
core-update-no-write = не вдається записати файли поруч із { $path } (немає дозволу?), тому програма не може оновитися сама. Завантажте нову версію зі сторінки випуску.
core-update-no-staging = не вдається записати файли поруч із { $path } (немає дозволу?). Завантажте нову версію зі сторінки випуску
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = оновлення належить іншій програмі ({ $got }, очікувалася { $expected }); не встановлено
core-update-move-aside-app = не вдалося перемістити поточну програму
core-update-move-in-app = не вдалося перемістити нову програму на її місце
core-update-move-aside-exe = не вдалося перемістити поточний виконуваний файл
core-update-move-in-exe = не вдалося перемістити новий виконуваний файл на його місце

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = &OK
gui-stock-ok-plain = OK
gui-stock-cancel = &Скасувати
gui-stock-cancel-plain = Скасувати
gui-stock-yes = &Так
gui-stock-yes-plain = Так
gui-stock-no = &Ні
gui-stock-no-plain = Ні
gui-stock-close = &Закрити
gui-stock-close-plain = Закрити
