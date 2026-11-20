# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Для этого мода нужна более новая версия Loadstone. Обновите Loadstone и повторите попытку.

## Loadstone settings

pref-language = Язык
pref-language-description = Язык интерфейса Loadstone и переведённых модов.
language-system = Как в системе
pref-accounts = Учётные записи
pref-accounts-description = Учётные записи для загрузки модов из закрытых репозиториев.
pref-account-rules = Правила учётных записей
pref-account-rules-description = Какую учётную запись использовать для репозитория или владельца.
pref-try-other-accounts = Пробовать другие мои учётные записи, если загрузка отклонена
pref-try-other-accounts-description = Если репозиторий не найден или доступ запрещён, Loadstone попробует другие учётные записи для этого сайта, прежде чем сдаться.
pref-tester-passwords = Пароли тестировщика
pref-tester-passwords-description = Открывают моды только для тестировщиков и бета-версии для всего реестра или для отдельных модов. Задаются кнопкой «Пароль тестировщика».
pref-download-account = Учётная запись для загрузки
pref-download-account-description = Учётная запись, через которую загружается этот мод. При автоматическом выборе используются ваши правила учётных записей и учётная запись по умолчанию.
pref-download-account-automatic = Автоматически (правила учётных записей, затем учётная запись по умолчанию)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Настройки Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Учётные записи для закрытых репозиториев и параметры Loadstone
gui-menu-exit = В&ыход
# Menu bar title.
gui-menu-tools = &Сервис
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Операция ещё выполняется. Если закрыть окно сейчас, она может остаться незавершённой. Всё равно закрыть?
gui-close-while-running-title = Выполняется операция
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Загрузка...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Проблема во время операции
gui-button-retry = &Повторить
gui-button-skip = П&ропустить
gui-button-cancel-problem = &Отмена
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Параметры установки

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (ядро { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Моды:
# Button that opens the selected mod's page.
gui-button-details = &Подробнее
gui-button-refresh = &Обновить
gui-button-loadstone-settings = &Настройки Loadstone...
gui-status-fetching-catalog = Получение каталога модов...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Загрузка списка модов...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Не удалось загрузить список модов. Нажмите «Обновить», чтобы повторить попытку.
gui-status-catalog-failed = Не удалось получить каталог.
gui-catalog-error-title = Не удалось загрузить каталог модов
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Нет доступных модов.
gui-status-catalog-loaded = { $count ->
    [one] Каталог загружен: { $count } мод.
    [few] Каталог загружен: { $count } мода.
    [many] Каталог загружен: { $count } модов.
   *[other] Каталог загружен: { $count } мода.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Загрузка { $mod_id }...
gui-status-mod-load-failed = Не удалось загрузить страницу мода.
gui-mod-error-title = Не удалось загрузить мод
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Копия игры для управления:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Копия игры { $game } для управления:
gui-button-back = Наза&д к списку модов
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name } от { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = &Папка игры:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = &Папка игры { $game }:
gui-button-browse = О&бзор...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Выберите папку игры
gui-browse-game-prompt-named = Выберите папку игры { $game }
gui-description-label = Описание:
# Label of the log where operations report their progress.
gui-activity-label = Журнал действий:
gui-button-update = Обно&вить
gui-button-install = &Установить
gui-select-folder-first = Сначала выберите папку игры кнопкой «Обзор».
gui-button-install-from-file = Установить из &файла...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Выберите файл loadstone-release.json мода
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|Файлы JSON (*.json)|*.json|Все файлы (*.*)|*.*
gui-button-uninstall = Уд&алить
gui-button-launch = &Запустить игру
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Запускает игру с загруженным модом.
gui-launch-unavailable-description = Станет доступно после установки мода в эту копию.
gui-button-change-options = &Изменить параметры установки...
gui-change-options-description = Заново задаёт вопросы установки мода и переустанавливает последнюю версию с вашими ответами.
gui-button-settings = Нас&тройки...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Выполняется... { $percent }%
gui-status-fetching-releases = Получение списка выпусков...
# $error is an error message.
gui-release-list-error = Не удалось получить список выпусков: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Установить последний выпуск?
gui-release-list-error-title = Список выпусков недоступен
gui-no-releases = В репозитории этого мода пока нет выпусков.
gui-no-releases-title = Нет выпусков
gui-choose-version = Выберите версию для установки:
gui-choose-version-title = Выбор версии
gui-confirm-uninstall = Удалить мод { $name }?
gui-confirm-uninstall-title = Подтверждение удаления
gui-status-working = Выполняется...
gui-status-op-failed = Операция не выполнена.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Не удаётся запустить
gui-op-failed-title = Ошибка операции
# Title of the message shown when an operation finished.
gui-op-done-title = Готово

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Доступна версия { $version } программы { $app } (у вас установлена { $current }). Обновить и перезапустить сейчас?
gui-self-update-title = Доступно обновление
gui-status-downloading-update = Загрузка обновления...
gui-status-update-failed = Не удалось выполнить обновление.
gui-update-failed-title = Ошибка обновления
gui-status-update-installed = Обновление установлено.
gui-update-installed = Обновление установлено. Сейчас программа будет перезапущена.
gui-update-installed-title = Обновление установлено

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Настройки Loadstone недоступны: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Настройки: { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Параметры мода
gui-mod-options-after-install = Параметры мода станут доступны после его установки.
gui-status-setting-saved = Настройка сохранена.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Настройка сохранена. { $note }
gui-setting-not-changed-title = Настройка не изменена
gui-status-no-settings-changed = Настройки не изменены.

## Loadstone settings dialog

gui-loadstone-settings-title = Настройки Loadstone
gui-accounts-label = &Учётные записи:
gui-accounts-description = Учётные записи для загрузки модов из закрытых репозиториев.
gui-button-sign-in = &Войти...
gui-button-add-token = Добавить &токен...
gui-button-remove-account = Уд&алить учётную запись
gui-button-set-default = &Сделать по умолчанию
# "gh auth token" is a command, keep it.
gui-add-token-description = Добавление учётной записи по уже имеющемуся токену, например полученному командой gh auth token из GitHub CLI.
gui-rules-label = &Правила учётных записей:
gui-rules-description = Какую учётную запись использовать для репозитория или для всех репозиториев владельца. Если правила нет, используется учётная запись по умолчанию.
gui-button-add-rule = Добавить п&равило...
gui-button-remove-rule = Удали&ть правило
gui-button-tester-password = Пар&оль тестировщика...
gui-tester-password-description = Для закрытого тестирования: введите выданный вам пароль, чтобы видеть моды только для тестировщиков и получать бета-версии. Можно добавить несколько паролей. Оставьте поле пустым, чтобы прекратить тестирование.
gui-tester-password-prompt-saved = У вас есть сохранённые пароли тестировщика. Введите ещё один, чтобы добавить его, или оставьте поле пустым, чтобы удалить их все и прекратить тестирование.
gui-tester-password-prompt = Введите выданный вам пароль тестировщика.
gui-tester-password-title = Пароль тестировщика
gui-tester-password-not-saved-title = Пароль тестировщика не сохранён
gui-button-close = &Закрыть
gui-accounts-unavailable-title = Учётные записи недоступны
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } на { $site }, по умолчанию
    [missing] { $account }, { $username } на { $site }, нет токена (войдите снова)
    [default-missing] { $account }, { $username } на { $site }, по умолчанию, нет токена (войдите снова)
   *[none] { $account }, { $username } на { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Нет учётных записей. Чтобы добавить, нажмите «Войти».
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern }: учётная запись { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Нет правил.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Вставьте токен { $site }. Он будет проверен на сайте { $site }, а затем сохранён в диспетчере учётных данных Windows.
gui-add-token-title = Добавление токена
gui-status-account-added = Добавлена учётная запись { $account }.
gui-token-not-added-title = Токен не добавлен
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Удалить учётную запись { $account }? Loadstone забудет её токен и все правила, которые её используют. Чтобы также отозвать доступ Loadstone, откройте раздел Applications в настройках { $site }.
gui-remove-account-title = Удаление учётной записи
gui-account-not-removed-title = Учётная запись не удалена
gui-default-not-changed-title = Учётная запись по умолчанию не изменена
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Репозиторий (github:owner/repo) или все репозитории владельца (github:owner/*):
gui-add-rule-title = Добавление правила учётной записи
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Какую учётную запись использовать?
gui-rule-not-added-title = Правило не добавлено
gui-rule-not-removed-title = Правило не удалено

## Signing in

gui-sign-in-no-sites = Ни один сайт не поддерживает вход.
gui-sign-in-title = Вход
gui-sign-in-which-site = На каком сайте войти?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Вход на { $site }
gui-sign-in-requesting = Запрос кода для входа у { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &Код для входа:
gui-button-copy-code = &Скопировать код
gui-button-open-sign-in-page = &Открыть страницу входа { $site }
gui-button-cancel = Отмена
gui-sign-in-code-copied = Код скопирован. Откройте страницу входа и вставьте его туда.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Откройте { $url }, введите код, указанный ниже, и разрешите доступ Loadstone. Это окно закроется само, когда всё будет готово.
gui-sign-in-code-expired = Срок действия кода для входа истёк до того, как его ввели. Начните заново.
# $account is the account's name.
gui-status-signed-in = Выполнен вход: { $account }.
gui-signed-in = Выполнен вход на { $site } с учётной записью { $account }.
gui-signed-in-title = Вход выполнен
gui-sign-in-failed-title = Не удалось войти
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Войти сейчас с учётной записью, у которой есть доступ?
gui-offer-sign-in-title = Войдите, чтобы продолжить

## Startup

gui-startup-error-title = Ошибка запуска Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Менеджер модов Loadstone

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Установлен { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Установлен { $version } (канал { $channel })
page-catalog-not-installed = Не установлен
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Установлен { $version } в { $count } копии
    [few] Установлен { $version } в { $count } копиях
    [many] Установлен { $version } в { $count } копиях
   *[other] Установлен { $version } в { $count } копии
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Установлен в { $count } копии (версии различаются)
    [few] Установлен в { $count } копиях (версии различаются)
    [many] Установлен в { $count } копиях (версии различаются)
   *[other] Установлен в { $count } копии (версии различаются)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Установлен не через Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Установлен, но больше не указан в настроенных реестрах.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (предварительная версия для тестировщиков)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Реестры не настроены; показаны только установленные моды.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] Скрыт { $count } мод, недоступный для этого компьютера.
    [few] Скрыто { $count } мода, недоступных для этого компьютера.
    [many] Скрыто { $count } модов, недоступных для этого компьютера.
   *[other] Скрыто { $count } мода, недоступных для этого компьютера.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Не удалось загрузить реестры: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Не найден в настроенных реестрах: { $error }
page-note-no-release-metadata = У последнего опубликованного выпуска пока нет метаданных Loadstone, поэтому не удалось определить новейшую версию.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Примечание: копии игры { $game } используют одну общую папку модов. Установка или удаление мода в одной копии затрагивает остальные; отдельным для каждой копии остаётся только загрузчик модов.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Требуется { $name } (устанавливается автоматически, сейчас версия { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Требуется { $name } (устанавливается автоматически).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Установлен { $version } (канал разработки).
page-status-up-to-date = Установлена последняя версия ({ $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Установлена последняя версия ({ $version }, новее последнего выпуска { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Доступно обновление: с { $version } до { $latest }.
page-status-installed = Установлен { $version }.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Установлен не через Loadstone (версия неизвестна). Установите версию { $latest }, чтобы Loadstone управлял этой копией.
page-status-foreign = Установлен не через Loadstone (версия неизвестна). Выполните установку, чтобы Loadstone управлял этой копией.
page-status-ready = Готово к установке версии { $latest }.
page-status-not-installed = Не установлен.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Недоступен на этом компьютере. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Готово к установке версии { $latest }. Папка игры не найдена; выберите её кнопкой «Обзор».
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Не установлен. Папка игры не найдена; выберите её кнопкой «Обзор».
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Выберите папку кнопкой «Обзор». Недоступен на этом компьютере. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Выберите папку кнопкой «Обзор». Готово к установке версии { $latest }. Папка игры не найдена; выберите её кнопкой «Обзор».
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Выберите папку кнопкой «Обзор». Не установлен. Папка игры не найдена; выберите её кнопкой «Обзор».
# Shown with a mod's settings before it is installed.
page-settings-after-install = Настройки можно будет изменить после установки.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Копия { $distribution }, установлен { $version }, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Копия { $distribution }, установлен не через Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Копия { $distribution }, не установлен, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Копия в { $folder }, установлен { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Копия в { $folder }, установлен не через Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Копия в { $folder }, не установлен
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Копия пока не найдена; выберите папку игры кнопкой «Обзор».
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Другая папка...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Отдельная версия
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Канал { $channel } (последняя сборка из ветки { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Канал { $channel } (сборка для разработки)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (предварительный выпуск)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (предварительный выпуск)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Действие «{ $action }» выполнено.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Загрузка { $file }...
page-self-update-installed = Обновление проверено и установлено.
page-tester-passwords-removed = Пароли тестировщика удалены. Моды только для тестировщиков и бета-версии снова скрыты.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } на { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = реестры не настроены
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = для «{ $id }» не известен исходный репозиторий
# $id is a mod id.
page-error-not-installed-no-registries = «{ $id }» не установлен, а реестры не настроены
# $id is a mod id.
page-error-not-installed-unresolved = «{ $id }» не установлен, и его не удалось найти
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = «{ $id }» не установлен, и его не удалось найти: { $error }
page-error-tester-password-wrong = Это не пароль тестировщика ни для одного из ваших реестров или их модов.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = хранилище учётных записей недоступно
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = «{ $value }» не является числом
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = значение не является конечным числом

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = хеш загруженного файла для { $id } не совпадает: ожидался { $expected }, получен { $actual }. Установка отменена.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = хеш загруженного файла для { $id } ({ $artifact }) не совпадает: ожидался { $expected }, получен { $actual }. Установка отменена.
engine-hash-verified = Хеш файла проверен.
engine-hash-none = Для этого источника нет хеша для проверки (локальная установка или установка сборки для разработки).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Удаление ранее установленной версии { $version } ({ $count } файл).
    [few] Удаление ранее установленной версии { $version } ({ $count } файла).
    [many] Удаление ранее установленной версии { $version } ({ $count } файлов).
   *[other] Удаление ранее установленной версии { $version } ({ $count } файла).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Предупреждение: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Предупреждение: не удалось записать список оригинальных файлов, которые ещё нужно восстановить: { $error }
engine-install-failed-rolling-back = Ошибка установки; удаление уже записанных файлов.
# Summary shown when an install or update finishes.
engine-installed = Установлено: { $name } { $version }.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Установка отменена.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = «{ $id }» не является параметром установки этого мода (параметры: { $options })
engine-option-unknown-none = «{ $id }» не является параметром установки этого мода (параметров нет)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = «{ $value }» не является допустимым вариантом для { $option } (варианты: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = отменено: вариант не выбран

## Mod settings

# { $label } is the setting's name.
engine-setting-default = Настройка «{ $label }» пока имеет значение по умолчанию; изменить её можно позже командой настроек.
# { $path } is the settings file.
engine-settings-written = Настройки записаны в { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = «{ $action }» не является действием { $id } (доступны: { $available })
engine-action-unknown-none = «{ $action }» не является действием { $id } (доступных действий нет)
# { $label } is the action's name, as on its button.
engine-action-unavailable = Действие «{ $label }» сейчас недоступно (не выполнено его предварительное условие)
engine-action-running = Выполнение действия «{ $label }»...
engine-action-finished = Действие «{ $label }» завершено.
engine-no-launch-steps = { $id } не содержит шагов запуска для этой платформы
# Summary after starting the game with a mod.
engine-launched = Запущено: { $id }.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } является ссылкой на рабочую копию разработчика; изменять или удалять файлы через неё нельзя. Если вы действительно хотите управляемую установку здесь, сначала удалите ссылку.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = Не удаляется { $path }: находится вне папок мода.
engine-legacy-link = Не удаляется { $path }: доступ к нему идёт через ссылку.
engine-legacy-shared = Не удаляется { $path }: его использует другой установленный пакет.
engine-legacy-removed = Удалён остаток старой установки: { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Предупреждение: не удалось удалить { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Не найден необходимый файл: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Не выполнено требование шага { $step }.
engine-step-skipped = Шаг { $step } пропущен.
engine-cancelled-at-step = отменено на шаге { $step }
engine-extracting = Извлечение файлов...
engine-placed-files = { $count ->
    [one] Размещён { $count } файл.
    [few] Размещено { $count } файла.
    [many] Размещено { $count } файлов.
   *[other] Размещено { $count } файла.
}
engine-kept-existing = Оставлен существующий файл { $path } (не перезаписан: он может быть новее).
engine-file-created = Создан и обновлён файл { $path }.
engine-file-updated = Обновлён файл { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = отменено: не выбрана папка для запроса «{ $prompt }»
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Скопировано в буфер обмена: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] В { $file } объединена { $count } архитектура.
    [few] В { $file } объединены { $count } архитектуры.
    [many] В { $file } объединено { $count } архитектур.
   *[other] В { $file } объединено { $count } архитектуры.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = не удаётся запустить: { $path } отсутствует
engine-program-start-failed = не удалось запустить { $path }
engine-program-started = Запущено: { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = не удалось открыть { $url }
engine-url-opened = Открыто: { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } по-прежнему нужен для: { $dependents }. Сначала удалите их.
engine-removing-files = { $count ->
    [one] Удаление { $count } файла.
    [few] Удаление { $count } файлов.
    [many] Удаление { $count } файлов.
   *[other] Удаление { $count } файла.
}
engine-purge-question = Удалить также сохранённые настройки и параметры?
engine-purge-done = Сохранённые настройки удалены.
engine-dependency-unneeded = { $id } больше не нужен ни одному установленному моду; его тоже можно удалить.
# Summary when an uninstall finishes.
engine-uninstalled = Удалено: { $id } { $version }.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Используется оригинал, уже сохранённый в { $path }.
engine-originals-kept = { $count ->
    [one] Сохранена копия { $count } оригинального файла игры.
    [few] Сохранены копии { $count } оригинальных файлов игры.
    [many] Сохранены копии { $count } оригинальных файлов игры.
   *[other] Сохранены копии { $count } оригинального файла игры.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Предупреждение: сейчас не удалось восстановить оригинал { $path } ({ $error }). Он будет возвращён при обновлении или удалении этого мода.
engine-original-restored = Восстановлен оригинал { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Предупреждение: оригинал { $path } отсутствует ({ $backup }); файл оставлен без изменений.
engine-original-changed = Файл { $path } изменился после установки этого мода (обновление игры?); оставлен более новый файл.
engine-originals-restored = { $count ->
    [one] Восстановлен { $count } оригинальный файл игры.
    [few] Восстановлено { $count } оригинальных файла игры.
    [many] Восстановлено { $count } оригинальных файлов игры.
   *[other] Восстановлено { $count } оригинального файла игры.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] не удалось вернуть { $count } оригинальный файл игры; закройте игру и повторите попытку.
    [few] не удалось вернуть { $count } оригинальных файла игры; закройте игру и повторите попытку.
    [many] не удалось вернуть { $count } оригинальных файлов игры; закройте игру и повторите попытку.
   *[other] не удалось вернуть { $count } оригинального файла игры; закройте игру и повторите попытку.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Обновление копии { $distribution } в { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = «{ $id }» установлен в нескольких копиях игры { $game }: { $copies }. Укажите параметр --game-dir, чтобы выбрать копию для обновления.
engine-many-copies = «{ $id }» установлен в нескольких копиях игры { $game }: { $copies }. Укажите параметр --game-dir, чтобы выбрать копию.
engine-not-game-folder = Папка { $path } не похожа на папку игры { $game } (не найден ни один из ожидаемых файлов)
engine-game-found = Игра { $game } найдена в { $path }
engine-game-not-found = Не удалось автоматически найти игру { $game }.
# Title of the folder picker.
engine-game-where = Где установлена игра { $game }?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = не удалось автоматически найти игру { $game }; укажите параметр --game-dir или выберите её папку
# { $path } is a game folder.
engine-not-installed-copy = «{ $id }» не установлен в копии игры { $game } в { $path }
engine-not-installed = «{ $id }» не установлен для игры { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = Мод { $name } нельзя установить на этот компьютер. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = копия { $distribution } игры { $game } не поддерживается. { $reason }
engine-distribution-untested = Примечание: копия { $distribution } игры { $game } не проверялась с этим модом.
engine-no-matching-artifact = ни один файл выпуска не подходит для этой платформы, архитектуры и магазина
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Этот мод доступен только для { $platform }.
engine-platform-only-two = Этот мод доступен только для { $first } и { $second }.
engine-platform-only-three = Этот мод доступен только для { $first }, { $second } и { $third }.
engine-platform-needs-apple-silicon = Для работы этого мода в { $platform } нужен процессор Apple Silicon.
engine-platform-needs-arm = Для работы этого мода в { $platform } нужен процессор ARM.
engine-platform-needs-x64 = Для работы этого мода в { $platform } нужен процессор Intel или AMD.
engine-game-platform-unsupported = Игра { $game } здесь не поддерживается в { $platform }.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name }: установлена последняя версия ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name }: установлена последняя версия ({ $installed } новее последнего выпуска { $latest }).
engine-installed-newer = Установлена версия { $installed } мода { $name }, она новее последнего доступного вам выпуска ({ $latest }). Ничего не изменено. Чтобы установить более старую версию, выберите её явно.
# { $from } and { $to } are versions.
engine-updating = Обновление { $name } с версии { $from } до версии { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Установить { $name } из текущего состояния ветки { $branch } ({ $version })?

    Сборки для разработки не защищены проверкой хеша; вы доверяете текущему содержимому репозитория.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Примечания к выпуску { $name } { $version }:

    { $notes }

    Установить сейчас?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Получение сведений о выпуске { $tag } из { $source }...
engine-fetching-latest = Получение сведений о последнем выпуске из { $source }...
engine-using-local-artifact = Используется локальный файл { $path }
# { $file } is a download's file name.
engine-using-cached = Используется уже загруженный файл { $file }.
engine-downloading = Загрузка { $file }...
engine-dependency-present = Зависимость { $id } { $version } уже установлена.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Установка зависимости { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = токен не указан
core-sign-in-cancelled = Вход отменён.
core-sign-in-expired = Срок действия кода для входа истёк до того, как его ввели. Начните заново.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = «{ $pattern }» не является ни источником (github:owner/repo), ни шаблоном владельца (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = не удалось сохранить токен в системном хранилище учётных данных
core-secrets-remove-failed = не удалось удалить токен из системного хранилища учётных данных

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = в выпуске { $tag } из { $source } нет файла { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = в последнем выпуске из { $source } нет файла { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = в выпуске { $tag } нет файла loadstone-release.json (или он недоступен)
core-github-sign-in-cancelled = Вход отменён на GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub отклонил вход: { $details }
core-github-sign-in-refused-no-details = GitHub отклонил вход без объяснения причин
core-github-token-rejected = GitHub не принял токен

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } не поддерживает вход
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = «{ $source }» не является источником в формате { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } не найден. Если это закрытый репозиторий, войдите с учётной записью, у которой есть к нему доступ (в настройках Loadstone), или задайте GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = токен из { $account } отклонён; возможно, срок его действия истёк или он отозван
core-source-token-unreachable = { $source } недоступен с токеном из { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = при загрузке { $url } получен ответ HTTP { $status }
core-fetch-request-failed = ошибка запроса: { $url }
core-fetch-download-failed = ошибка загрузки: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = ошибка чтения
core-fetch-read-error-download = ошибка чтения во время загрузки

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = нет способа извлечения для этой платформы и магазина
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } является ссылкой на рабочую копию разработчика. Обновите эту рабочую копию через git или удалите ссылку перед установкой.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = в этом архиве нет ожидаемого содержимого (ни один элемент не подходит ни под один способ извлечения)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = реестр «{ $source }» не соответствует формату { $formats } и не является существующей папкой
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = в { $source } нет папки loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = Не удалось обновить { $source } ({ $error }); используется сохранённая копия.
core-registry-fetch-failed = не удалось получить реестр { $source }
# $id is a mod's id.
core-registry-package-not-found = пакет «{ $id }» не найден ни в одном реестре

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = «{ $key }» принимает логическое значение; используйте true или false
core-setting-not-number = для «{ $key }» требуется число
core-setting-too-small = значение «{ $key }» должно быть не меньше { $min }
core-setting-too-large = значение «{ $key }» должно быть не больше { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = значение «{ $key }» должно быть одним из следующих: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Доступ тестировщика открыт для модов реестра: показаны моды только для тестировщиков, а при установке и обновлении загружаются бета-версии.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Доступ тестировщика открыт для модов реестра и для { $mods }: показаны моды только для тестировщиков, а при установке и обновлении загружаются бета-версии.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Доступ тестировщика открыт для { $mods }: показаны моды только для тестировщиков, а при установке и обновлении загружаются бета-версии.
core-tester-save-failed = не удалось сохранить пароль тестировщика
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = У выпуска { $tag } нет пригодных метаданных Loadstone ({ $error }); используется последний стабильный выпуск.
core-tester-beta-lookup-failed = Не удалось найти бета-версии ({ $error }); используется последний стабильный выпуск.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = загруженное обновление не прошло проверку хеша (ожидался { $expected }, получен { $actual }); обновление не установлено
core-update-translocated = macOS запускает эту программу из временной копии, доступной только для чтения, поэтому она не может обновиться сама. Переместите её в папку «Программы», откройте оттуда и обновите снова.
core-update-on-disk-image = эта программа запущена из образа диска, поэтому она не может обновиться сама. Скопируйте её в папку «Программы», откройте оттуда и обновите снова.
# $path is the folder the app is in.
core-update-no-write = не удаётся записать файлы рядом с { $path } (нет прав?), поэтому программа не может обновиться сама. Загрузите новую версию со страницы выпуска.
core-update-no-staging = не удаётся записать файлы рядом с { $path } (нет прав?). Загрузите новую версию со страницы выпуска
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = обновление относится к другой программе ({ $got }, ожидалась { $expected }); не установлено
core-update-move-aside-app = не удалось переместить текущую программу
core-update-move-in-app = не удалось переместить новую программу на её место
core-update-move-aside-exe = не удалось переместить текущий исполняемый файл
core-update-move-in-exe = не удалось переместить новый исполняемый файл на его место
