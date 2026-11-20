# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = 這個模組需要較新版本的 Loadstone。請更新 Loadstone，然後再試一次。

## Loadstone settings

pref-language = 語言
pref-language-description = Loadstone 及已翻譯模組的顯示語言。
language-system = 系統預設
pref-accounts = 帳戶
pref-accounts-description = 用於從私人存放庫下載模組的登入帳戶。
pref-account-rules = 帳戶規則
pref-account-rules-description = 為某個存放庫或擁有者指定要使用的帳戶。
pref-try-other-accounts = 下載遭拒時嘗試我的其他帳戶
pref-try-other-accounts-description = 如果找不到存放庫或存取遭拒，會先嘗試該網站的其他帳戶，然後才放棄。
pref-tester-passwords = 測試人員密碼
pref-tester-passwords-description = 為模組來源或個別模組解鎖僅限測試人員的模組和測試版。請透過「測試人員密碼」按鈕設定。
pref-download-account = 下載帳戶
pref-download-account-description = 用於下載這個模組的帳戶。「自動」會使用您的帳戶規則和預設帳戶。
pref-download-account-automatic = 自動（先依帳戶規則，再使用預設帳戶）

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = Loadstone 設定(&L)...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = 私人存放庫的帳戶及 Loadstone 選項
gui-menu-exit = 結束(&X)
# Menu bar title.
gui-menu-tools = 工具(&T)
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = 仍有作業正在執行。現在關閉可能會使作業無法完成。仍要關閉嗎？
gui-close-while-running-title = 作業進行中
# Status bar text while a standalone installer loads its mod.
gui-status-loading = 正在載入...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = 作業期間發生問題
gui-button-retry = 重試(&R)
gui-button-skip = 略過(&S)
gui-button-cancel-problem = 取消(&C)
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = 安裝選項

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title }（核心 { $version }）
# Label of the list of mods.
gui-catalog-mods-label = 模組(&M)：
# Button that opens the selected mod's page.
gui-button-details = 詳細資料(&D)
gui-button-refresh = 重新整理(&R)
gui-button-loadstone-settings = Loadstone 設定(&G)...
gui-status-fetching-catalog = 正在取得模組目錄...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = 正在載入模組清單...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = 無法載入模組清單。請按「重新整理」再試一次。
gui-status-catalog-failed = 無法取得目錄。
gui-catalog-error-title = 無法載入模組目錄
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }，{ $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }，{ $status }，{ $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = 沒有可用的模組。
gui-status-catalog-loaded = 已載入目錄：{ $count } 個模組。

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = 正在載入 { $mod_id }...
gui-status-mod-load-failed = 無法載入模組頁面。
gui-mod-error-title = 無法載入模組
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = 要管理的遊戲副本(&C)：
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = 要管理的 { $game } 副本(&C)：
gui-button-back = 返回模組清單(&B)
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }，作者：{ $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = 遊戲資料夾(&G)：
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = { $game } 資料夾(&G)：
gui-button-browse = 瀏覽(&W)...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = 選取遊戲資料夾
gui-browse-game-prompt-named = 選取 { $game } 資料夾
gui-description-label = 說明：
# Label of the log where operations report their progress.
gui-activity-label = 活動記錄：
gui-button-update = 更新(&U)
gui-button-install = 安裝(&I)
gui-select-folder-first = 請先使用「瀏覽」選取遊戲資料夾。
gui-button-install-from-file = 從檔案安裝(&F)...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = 選取模組的 loadstone-release.json
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON 檔案 (*.json)|*.json|所有檔案 (*.*)|*.*
gui-button-uninstall = 解除安裝(&N)
gui-button-launch = 啟動遊戲(&L)
# Description of the Launch game button, read when it gets focus.
gui-launch-description = 啟動遊戲並載入模組。
gui-launch-unavailable-description = 在這個副本中安裝模組後即可使用。
gui-button-change-options = 變更安裝選項(&O)...
gui-change-options-description = 重新詢問模組的安裝問題，並依您的回答重新安裝最新版本。
gui-button-settings = 設定(&S)...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = 正在處理... { $percent }%
gui-status-fetching-releases = 正在取得發行版本清單...
# $error is an error message.
gui-release-list-error = 無法取得發行版本清單：{ $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = 要改為安裝最新的發行版本嗎？
gui-release-list-error-title = 無法使用發行版本清單
gui-no-releases = 這個模組的存放庫還沒有任何發行版本。
gui-no-releases-title = 沒有發行版本
gui-choose-version = 選取要安裝的版本：
gui-choose-version-title = 選擇版本
gui-confirm-uninstall = 要解除安裝 { $name } 嗎？
gui-confirm-uninstall-title = 確認解除安裝
gui-status-working = 正在處理...
gui-status-op-failed = 作業失敗。
# Title of the message shown when the game could not be started.
gui-launch-failed-title = 無法啟動
gui-op-failed-title = 作業失敗
# Title of the message shown when an operation finished.
gui-op-done-title = 完成

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = { $app } 有新版本 { $version } 可用（您目前的版本是 { $current }）。要立即更新並重新啟動嗎？
gui-self-update-title = 有可用的更新
gui-status-downloading-update = 正在下載更新...
gui-status-update-failed = 更新失敗。
gui-update-failed-title = 更新失敗
gui-status-update-installed = 已安裝更新。
gui-update-installed = 已安裝更新。應用程式即將重新啟動。
gui-update-installed-title = 已安裝更新

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = 無法使用 Loadstone 設定：{ $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = { $name } 設定
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }：
# Group of the mod's own settings.
gui-mod-options-group = 模組選項
gui-mod-options-after-install = 安裝模組後才能使用其選項。
gui-status-setting-saved = 已儲存設定。
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = 已儲存設定。{ $note }
gui-setting-not-changed-title = 設定未變更
gui-status-no-settings-changed = 沒有變更任何設定。

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone 設定
gui-accounts-label = 帳戶(&A)：
gui-accounts-description = 用於從私人存放庫下載模組的登入帳戶。
gui-button-sign-in = 登入(&I)...
gui-button-add-token = 新增權杖(&T)...
gui-button-remove-account = 移除帳戶(&R)
gui-button-set-default = 設為預設(&D)
# "gh auth token" is a command, keep it.
gui-add-token-description = 使用您已有的權杖新增帳戶，例如透過 GitHub CLI 的 gh auth token 命令取得的權杖。
gui-rules-label = 帳戶規則(&U)：
gui-rules-description = 為某個存放庫或某個擁有者的所有存放庫指定要使用的帳戶。沒有規則時，會使用預設帳戶。
gui-button-add-rule = 新增規則(&E)...
gui-button-remove-rule = 移除規則(&V)
gui-button-tester-password = 測試人員密碼(&P)...
gui-tester-password-description = 供內部測試人員使用：輸入您取得的密碼，即可看到僅限測試人員的模組並取得測試版。可以新增多組密碼。保留空白即可停止測試。
gui-tester-password-prompt-saved = 您已儲存測試人員密碼。輸入另一組密碼即可新增；保留空白則會清除所有密碼並停止測試。
gui-tester-password-prompt = 請輸入您取得的測試人員密碼。
gui-tester-password-title = 測試人員密碼
gui-tester-password-not-saved-title = 未儲存測試人員密碼
gui-button-close = 關閉(&C)
gui-accounts-unavailable-title = 無法使用帳戶
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }，{ $site } 上的 { $username }，預設
    [missing] { $account }，{ $site } 上的 { $username }，缺少權杖（請重新登入）
    [default-missing] { $account }，{ $site } 上的 { $username }，預設，缺少權杖（請重新登入）
   *[none] { $account }，{ $site } 上的 { $username }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = 沒有帳戶。請使用「登入」新增帳戶。
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } 使用 { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = 沒有規則。
# $site is the site's name, for example GitHub.
gui-add-token-prompt = 請貼上 { $site } 權杖。權杖會先經 { $site } 驗證，然後儲存在 Windows 認證管理員中。
gui-add-token-title = 新增權杖
gui-status-account-added = 已新增帳戶 { $account }。
gui-token-not-added-title = 未新增權杖
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = 要移除帳戶 { $account } 嗎？Loadstone 會清除其權杖及所有使用此帳戶的規則。若也要撤銷 Loadstone 的存取權，請使用 { $site } 設定中的 Applications 頁面。
gui-remove-account-title = 移除帳戶
gui-account-not-removed-title = 未移除帳戶
gui-default-not-changed-title = 未變更預設帳戶
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = 存放庫（github:owner/repo）或某個擁有者的所有存放庫（github:owner/*）：
gui-add-rule-title = 新增帳戶規則
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account }（{ $username }）
gui-add-rule-account-prompt = 要使用哪個帳戶？
gui-rule-not-added-title = 未新增規則
gui-rule-not-removed-title = 未移除規則

## Signing in

gui-sign-in-no-sites = 沒有支援登入的網站。
gui-sign-in-title = 登入
gui-sign-in-which-site = 要登入哪個網站？
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = 登入 { $site }
gui-sign-in-requesting = 正在向 { $site } 要求登入代碼...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = 登入代碼(&C)：
gui-button-copy-code = 複製代碼(&P)
gui-button-open-sign-in-page = 開啟 { $site } 登入頁面(&O)
gui-button-cancel = 取消
gui-sign-in-code-copied = 已複製代碼。請開啟登入頁面並在該處貼上。
# $url is the web address of the sign-in page.
gui-sign-in-instructions = 請開啟 { $url }，輸入下方的代碼，然後授權 Loadstone。完成後，此視窗會自動關閉。
gui-sign-in-code-expired = 登入代碼在輸入前已過期。請重新開始。
# $account is the account's name.
gui-status-signed-in = 已使用 { $account } 登入。
gui-signed-in = 已使用 { $account } 登入 { $site }。
gui-signed-in-title = 已登入
gui-sign-in-failed-title = 登入失敗
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = 要立即使用具有存取權的帳戶登入嗎？
gui-offer-sign-in-title = 登入以繼續

## Startup

gui-startup-error-title = Loadstone 啟動錯誤

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone 模組管理員

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = 已安裝 { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = 已安裝 { $version }（{ $channel } 通道）
page-catalog-not-installed = 未安裝
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = 已在 { $count } 個副本中安裝 { $version }
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = 已在 { $count } 個副本中安裝（版本不同）
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = 已在 Loadstone 以外安裝
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = 已安裝，但已設定的模組來源中不再列出此模組。
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name }（測試人員預覽）
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = 尚未設定模組來源；僅顯示已安裝的模組。
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = 已隱藏 { $count } 個不適用於這部電腦的模組。
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = 無法載入模組來源：{ $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = 在已設定的模組來源中找不到：{ $error }
page-note-no-release-metadata = 最新發佈的發行版本尚未包含 Loadstone 中繼資料，因此無法判斷最新版本。
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = 注意：{ $game } 的各個副本共用同一個模組資料夾。為其中一個副本安裝或解除安裝模組，會影響其他副本；只有模組載入器是各副本獨立的。
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = 需要 { $name }（會自動安裝，目前版本為 { $version }）。
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = 需要 { $name }（會自動安裝）。

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = 已安裝 { $version }（開發通道）。
page-status-up-to-date = 已是最新版本（版本 { $version }）。
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = 已是最新版本（版本 { $version }，比最新的發行版本 { $latest } 還新）。
# $version is the installed version, $latest the version an update would install.
page-status-update-available = 有可用的更新：從 { $version } 更新為 { $latest }。
page-status-installed = 已安裝 { $version }。
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = 已在 Loadstone 以外安裝（版本不明）。安裝版本 { $latest } 後，即可由 Loadstone 管理此副本。
page-status-foreign = 已在 Loadstone 以外安裝（版本不明）。安裝後，即可由 Loadstone 管理此副本。
page-status-ready = 已可安裝版本 { $latest }。
page-status-not-installed = 未安裝。
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = 不適用於這部電腦。{ $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = 已可安裝版本 { $latest }。找不到遊戲資料夾；請使用「瀏覽」選取。
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = 未安裝。找不到遊戲資料夾；請使用「瀏覽」選取。
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = 請使用「瀏覽」選取資料夾。不適用於這部電腦。{ $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = 請使用「瀏覽」選取資料夾。已可安裝版本 { $latest }。找不到遊戲資料夾；請使用「瀏覽」選取。
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = 請使用「瀏覽」選取資料夾。未安裝。找不到遊戲資料夾；請使用「瀏覽」選取。
# Shown with a mod's settings before it is installed.
page-settings-after-install = 安裝後才能編輯設定。

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = { $distribution } 副本，已安裝 { $version }，{ $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = { $distribution } 副本，已在 Loadstone 以外安裝，{ $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = { $distribution } 副本，未安裝，{ $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = 位於 { $folder } 的副本，已安裝 { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = 位於 { $folder } 的副本，已在 Loadstone 以外安裝
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = 位於 { $folder } 的副本，未安裝
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = 尚未找到副本；請使用「瀏覽」選取遊戲資料夾。
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = 其他資料夾...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = 獨立版
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = { $channel } 通道（{ $branch } 分支的最新版本）
# A development channel. $channel is the channel id ("dev").
page-channel-development = { $channel } 通道（開發組建）
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }，{ $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag }（預先發行版本）
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }，{ $title }（預先發行版本）

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = 「{ $action }」已完成。
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = 正在下載 { $file }...
page-self-update-installed = 已驗證並安裝更新。
page-tester-passwords-removed = 已移除測試人員密碼。僅限測試人員的模組和測試版會再次隱藏。

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label }（{ $site } 上的 { $username }）

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = 尚未設定模組來源
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = 找不到「{ $id }」的來源存放庫
# $id is a mod id.
page-error-not-installed-no-registries = 「{ $id }」未安裝，且尚未設定模組來源
# $id is a mod id.
page-error-not-installed-unresolved = 「{ $id }」未安裝，且無法找到
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = 「{ $id }」未安裝，且無法找到：{ $error }
page-error-tester-password-wrong = 這不是您任何模組來源或其模組的測試人員密碼。
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = 無法使用帳戶存放區
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = 「{ $value }」不是數字
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = 不是有限的數字

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = { $id } 的檔案雜湊不符：預期為 { $expected }，實際為 { $actual }。拒絕安裝。
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = { $id }（{ $artifact }）的檔案雜湊不符：預期為 { $expected }，實際為 { $actual }。拒絕安裝。
engine-hash-verified = 已驗證檔案雜湊。
engine-hash-none = 此來源沒有可驗證的雜湊（本機或開發版安裝）。

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = 正在移除先前安裝的版本 { $version }（{ $count } 個檔案）。
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = 警告：{ $message }
# { $error } is a system error message.
engine-warning-record-originals = 警告：無法記錄尚待還原的原始檔案：{ $error }
engine-install-failed-rolling-back = 安裝失敗；正在移除目前為止寫入的檔案。
# Summary shown when an install or update finishes.
engine-installed = 已安裝 { $name } { $version }。
# The user answered no to the release notes or development build question.
engine-install-cancelled = 已取消安裝。

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = 「{ $id }」不是這個模組的安裝選項（可用選項：{ $options }）
engine-option-unknown-none = 「{ $id }」不是這個模組的安裝選項（可用選項：無）
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = 「{ $value }」不是 { $option } 的有效選擇（可用的選擇：{ $choices }）
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }：{ $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }：{ $choice }
engine-option-cancelled = 已取消：未做出選擇

## Mod settings

# { $label } is the setting's name.
engine-setting-default = 設定「{ $label }」使用預設值；之後可以使用 settings 命令變更。
# { $path } is the settings file.
engine-settings-written = 已將設定寫入 { $path }。

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = 「{ $action }」不是 { $id } 的動作（可用的動作：{ $available }）
engine-action-unknown-none = 「{ $action }」不是 { $id } 的動作（可用的動作：無）
# { $label } is the action's name, as on its button.
engine-action-unavailable = 「{ $label }」目前無法使用（不符合其前提條件）
engine-action-running = 正在執行「{ $label }」...
engine-action-finished = 「{ $label }」已完成。
engine-no-launch-steps = { $id } 沒有為此平台宣告啟動步驟
# Summary after starting the game with a mod.
engine-launched = 已啟動 { $id }。

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } 是指向開發工作目錄的連結；拒絕透過它修改或移除檔案。如果確實要在這裡使用 Loadstone 管理安裝，請先移除該連結。

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = 不移除 { $path }：它位於模組的資料夾之外。
engine-legacy-link = 不移除 { $path }：它是透過連結存取的。
engine-legacy-shared = 不移除 { $path }：另一個已安裝的套件正在使用它。
engine-legacy-removed = 已移除殘留的 { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = 警告：無法移除 { $path }：{ $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = 找不到必要的檔案：{ $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = 不符合步驟 { $step } 的需求。
engine-step-skipped = 已略過步驟 { $step }。
engine-cancelled-at-step = 在步驟 { $step } 取消
engine-extracting = 正在解壓縮檔案...
engine-placed-files = 已放置 { $count } 個檔案。
engine-kept-existing = 保留現有的 { $path }（未覆寫；它可能較新）。
engine-file-created = 已建立並更新 { $path }。
engine-file-updated = 已更新 { $path }。
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = 已取消：未針對「{ $prompt }」選取資料夾
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = 已複製到剪貼簿：{ $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = 已將 { $count } 個架構合併到 { $file } 中。
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = 無法啟動：找不到 { $path }
engine-program-start-failed = 無法啟動 { $path }
engine-program-started = 已啟動 { $path }。
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = 無法開啟 { $url }
engine-url-opened = 已開啟 { $url }。

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = 下列項目仍需要 { $id }：{ $dependents }。請先將它們解除安裝。
engine-removing-files = 正在移除 { $count } 個檔案。
engine-purge-question = 是否也要移除已儲存的設定和偏好設定？
engine-purge-done = 已移除儲存的設定。
engine-dependency-unneeded = 已安裝的模組都不再需要 { $id }；您也可以將它解除安裝。
# Summary when an uninstall finishes.
engine-uninstalled = 已解除安裝 { $id } { $version }。

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = 使用已保存在 { $path } 的原始檔案。
engine-originals-kept = 已備份 { $count } 個原始遊戲檔案。
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = 警告：目前無法還原原始的 { $path }（{ $error }）。將在更新或解除安裝此模組時還原。
engine-original-restored = 已還原原始的 { $path }。
# { $backup } is where the kept original should have been.
engine-original-missing = 警告：找不到 { $path } 的原始檔案（{ $backup }）；將保留該檔案原狀。
engine-original-changed = 自安裝此模組以來，{ $path } 已有變更（遊戲更新了嗎？）；保留較新的檔案。
engine-originals-restored = 已還原 { $count } 個原始遊戲檔案。
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = 無法還原 { $count } 個原始遊戲檔案；請關閉遊戲後再試一次。

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = 正在更新位於 { $path } 的 { $distribution } 副本。
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path }（{ $distribution }）
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = 「{ $id }」已安裝在 { $game } 的多個副本中：{ $copies }。請使用 --game-dir 指定要更新的副本。
engine-many-copies = 「{ $id }」已安裝在 { $game } 的多個副本中：{ $copies }。請使用 --game-dir 指定副本。
engine-not-game-folder = { $path } 看起來不是 { $game } 資料夾（找不到任何預期的檔案）
engine-game-found = 在 { $path } 找到 { $game }
engine-game-not-found = 無法自動找到 { $game }。
# Title of the folder picker.
engine-game-where = { $game } 安裝在哪裡？
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = 無法自動找到 { $game }；請使用 --game-dir 或選取其資料夾
# { $path } is a game folder.
engine-not-installed-copy = 「{ $id }」未安裝在位於 { $path } 的 { $game } 副本中
engine-not-installed = 「{ $id }」未安裝在 { $game } 中

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = 無法在這部電腦上安裝 { $name }。{ $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = 不支援 { $game } 的 { $distribution } 副本。{ $reason }
engine-distribution-untested = 注意：此模組尚未在 { $game } 的 { $distribution } 副本上測試過。
engine-no-matching-artifact = 沒有符合此平台、架構或商店版本的發行檔案
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = 此模組僅適用於 { $platform }。
engine-platform-only-two = 此模組僅適用於 { $first } 和 { $second }。
engine-platform-only-three = 此模組僅適用於 { $first }、{ $second } 和 { $third }。
engine-platform-needs-apple-silicon = 在 { $platform } 上，此模組需要 Apple 晶片。
engine-platform-needs-arm = 在 { $platform } 上，此模組需要 ARM 處理器。
engine-platform-needs-x64 = 在 { $platform } 上，此模組需要 Intel 或 AMD 處理器。
engine-game-platform-unsupported = 此處不支援 { $platform } 上的 { $game }。

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } 已是最新版本（{ $version }）。
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } 已是最新版本（{ $installed } 比最新的發行版本 { $latest } 還新）。
engine-installed-newer = 已安裝的 { $name } { $installed } 比您目前可取得的最新發行版本（{ $latest }）還新。未做任何變更。若要安裝較舊的版本，請明確選擇該版本。
# { $from } and { $to } are versions.
engine-updating = 正在將 { $name } 從 { $from } 更新為 { $to }。
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    要從 { $branch } 分支的最新提交（{ $version }）安裝 { $name } 嗎？

    開發組建未以雜湊值鎖定；您將信任存放庫目前的內容。
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    { $name } { $version } 的版本資訊：

    { $notes }

    要立即安裝嗎？
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = 正在從 { $source } 取得發行版本 { $tag } 的資訊...
engine-fetching-latest = 正在從 { $source } 取得最新發行版本的資訊...
engine-using-local-artifact = 使用本機檔案 { $path }
# { $file } is a download's file name.
engine-using-cached = 使用已下載的 { $file }。
engine-downloading = 正在下載 { $file }...
engine-dependency-present = 已安裝相依元件 { $id } { $version }。
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = 正在安裝相依元件 { $name } { $version }（{ $file }）...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = 未提供權杖
core-sign-in-cancelled = 已取消登入。
core-sign-in-expired = 登入代碼在輸入前已過期。請重新開始。
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = 「{ $pattern }」不是來源（github:owner/repo）或擁有者萬用字元（github:owner/*）
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = 無法將權杖儲存到系統認證存放區
core-secrets-remove-failed = 無法從系統認證存放區移除權杖

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = { $source } 的發行版本 { $tag } 中沒有 { $file } 檔案
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = { $source } 的最新發行版本中沒有 { $file } 檔案
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = 發行版本 { $tag } 中沒有 loadstone-release.json 檔案（或無法存取）
core-github-sign-in-cancelled = 已在 GitHub 上取消登入。
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub 拒絕了登入：{ $details }
core-github-sign-in-refused-no-details = GitHub 拒絕了登入：未提供詳細資料
core-github-token-rejected = GitHub 不接受此權杖

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } 不支援登入
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = 「{ $source }」不是 { $format } 格式的來源
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = 找不到 { $source }。如果是私人存放庫，請使用具有存取權的帳戶登入（Loadstone 設定），或設定 GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = 來自 { $account } 的權杖遭拒；它可能已過期或遭撤銷
core-source-token-unreachable = 使用來自 { $account } 的權杖無法存取 { $source }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = 下載 { $url } 時傳回 HTTP { $status }
core-fetch-request-failed = 要求失敗：{ $url }
core-fetch-download-failed = 下載失敗：{ $url }
# Reading a server's reply failed partway.
core-fetch-read-error = 讀取錯誤
core-fetch-read-error-download = 下載期間發生讀取錯誤

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = 沒有適用於此平台或商店版本的解壓縮方式
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } 是指向開發工作目錄的連結。請改用 git 更新該工作目錄，或在安裝前移除該連結。
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = 此壓縮檔不包含預期的內容（沒有符合任何解壓縮方式的項目）

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = 模組來源「{ $source }」既不是 { $formats }，也不是現有的資料夾
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } 中沒有 loadstone-packages 資料夾
# $error is the reason the download failed.
core-registry-using-cache = 無法重新整理 { $source }（{ $error }）；改用快取的資料。
core-registry-fetch-failed = 無法取得模組來源 { $source }
# $id is a mod's id.
core-registry-package-not-found = 在任何模組來源中都找不到套件「{ $id }」

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = 「{ $key }」是布林值；請使用 true 或 false
core-setting-not-number = 「{ $key }」需要數字
core-setting-too-small = 「{ $key }」不得小於 { $min }
core-setting-too-large = 「{ $key }」不得大於 { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = 「{ $key }」必須是下列其中之一：{ $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = 已為模組來源中的模組解鎖測試人員存取權：將列出僅限測試人員的模組，安裝和更新時會取得測試版。
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = 已為模組來源中的模組及 { $mods } 解鎖測試人員存取權：將列出僅限測試人員的模組，安裝和更新時會取得測試版。
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = 已為 { $mods } 解鎖測試人員存取權：將列出僅限測試人員的模組，安裝和更新時會取得測試版。
core-tester-save-failed = 無法儲存測試人員密碼
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = 發行版本 { $tag } 沒有可用的 Loadstone 中繼資料（{ $error }）；將使用最新的穩定發行版本。
core-tester-beta-lookup-failed = 無法查詢測試版（{ $error }）；將使用最新的穩定發行版本。

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = 下載的更新未通過雜湊驗證（預期為 { $expected }，實際為 { $actual }）；未安裝
core-update-translocated = macOS 正從暫時的唯讀副本執行此應用程式，因此它無法自行更新。請將它移到「應用程式」資料夾，從該處開啟，然後再更新一次。
core-update-on-disk-image = 此應用程式正從其磁碟映像檔執行，因此無法自行更新。請將它複製到「應用程式」資料夾，從該處開啟，然後再更新一次。
# $path is the folder the app is in.
core-update-no-write = 無法寫入 { $path }（沒有權限？），因此應用程式無法自行更新。請改從發行版本頁面下載新版本。
core-update-no-staging = 無法寫入 { $path }（沒有權限？）。請改從發行版本頁面下載新版本
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = 此更新是不同的應用程式（{ $got }，預期為 { $expected }）；未安裝
core-update-move-aside-app = 無法移開目前的應用程式
core-update-move-in-app = 無法將新的應用程式移到定位
core-update-move-aside-exe = 無法移開目前的執行檔
core-update-move-in-exe = 無法將新的執行檔移到定位

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = 確定(&O)
gui-stock-ok-plain = 確定
gui-stock-cancel = 取消(&C)
gui-stock-cancel-plain = 取消
gui-stock-yes = 是(&Y)
gui-stock-yes-plain = 是
gui-stock-no = 否(&N)
gui-stock-no-plain = 否
gui-stock-close = 關閉(&C)
gui-stock-close-plain = 關閉
