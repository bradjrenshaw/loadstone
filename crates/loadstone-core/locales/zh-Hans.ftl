# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = 此模组需要更新版本的 Loadstone。请先更新 Loadstone，然后重试。

## Loadstone settings

pref-language = 语言
pref-language-description = Loadstone 及已翻译模组的显示语言。
language-system = 系统默认
pref-accounts = 帐户
pref-accounts-description = 用于从私有仓库下载模组的登录帐户。
pref-account-rules = 帐户规则
pref-account-rules-description = 为某个仓库或所有者指定使用哪个帐户。
pref-try-other-accounts = 下载被拒绝时尝试我的其他帐户
pref-try-other-accounts-description = 如果找不到仓库或访问被拒绝，先尝试该网站的其他帐户，然后再放弃。
pref-tester-passwords = 测试人员密码
pref-tester-passwords-description = 为某个模组源或单个模组解锁仅限测试人员的模组和测试版。可通过“测试人员密码”按钮设置。
pref-download-account = 下载帐户
pref-download-account-description = 用于下载此模组的帐户。“自动”会使用你的帐户规则和默认帐户。
pref-download-account-automatic = 自动（先按帐户规则，再使用默认帐户）

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = Loadstone 设置(&L)...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = 私有仓库的帐户及 Loadstone 选项
gui-menu-exit = 退出(&X)
# Menu bar title.
gui-menu-tools = 工具(&T)
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = 仍有操作正在进行。现在关闭可能导致操作无法完成。仍要关闭吗？
gui-close-while-running-title = 操作正在进行
# Status bar text while a standalone installer loads its mod.
gui-status-loading = 正在加载...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = 操作过程中出现问题
gui-button-retry = 重试(&R)
gui-button-skip = 跳过(&S)
gui-button-cancel-problem = 取消(&C)
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = 安装选项

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title }（核心 { $version }）
# Label of the list of mods.
gui-catalog-mods-label = 模组(&M)：
# Button that opens the selected mod's page.
gui-button-details = 详细信息(&D)
gui-button-refresh = 刷新(&R)
gui-button-loadstone-settings = Loadstone 设置(&G)...
gui-status-fetching-catalog = 正在获取模组目录...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = 正在加载模组列表...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = 无法加载模组列表。请按“刷新”重试。
gui-status-catalog-failed = 获取目录失败。
gui-catalog-error-title = 无法加载模组目录
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }，{ $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }，{ $status }，{ $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = 没有可用的模组。
gui-status-catalog-loaded = 目录已加载：{ $count } 个模组。

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = 正在加载 { $mod_id }...
gui-status-mod-load-failed = 无法加载模组页面。
gui-mod-error-title = 无法加载模组
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = 要管理的游戏副本(&C)：
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = 要管理的 { $game } 副本(&C)：
gui-button-back = 返回模组列表(&B)
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }，作者：{ $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = 游戏文件夹(&G)：
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = { $game } 文件夹(&G)：
gui-button-browse = 浏览(&W)...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = 选择游戏文件夹
gui-browse-game-prompt-named = 选择 { $game } 文件夹
gui-description-label = 说明：
# Label of the log where operations report their progress.
gui-activity-label = 活动记录：
gui-button-update = 更新(&U)
gui-button-install = 安装(&I)
gui-select-folder-first = 请先使用“浏览”选择游戏文件夹。
gui-button-install-from-file = 从文件安装(&F)...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = 选择模组的 loadstone-release.json
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON 文件 (*.json)|*.json|所有文件 (*.*)|*.*
gui-button-uninstall = 卸载(&N)
gui-button-launch = 启动游戏(&L)
# Description of the Launch game button, read when it gets focus.
gui-launch-description = 启动游戏并加载模组。
gui-launch-unavailable-description = 在此副本中安装模组后可用。
gui-button-change-options = 更改安装选项(&O)...
gui-change-options-description = 重新询问模组的安装问题，并按你的回答重新安装最新版本。
gui-button-settings = 设置(&S)...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = 正在处理... { $percent }%
gui-status-fetching-releases = 正在获取发行版列表...
# $error is an error message.
gui-release-list-error = 无法获取发行版列表：{ $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = 是否改为安装最新发行版？
gui-release-list-error-title = 发行版列表不可用
gui-no-releases = 此模组的仓库尚无发行版。
gui-no-releases-title = 没有发行版
gui-choose-version = 选择要安装的版本：
gui-choose-version-title = 选择版本
gui-confirm-uninstall = 要卸载 { $name } 吗？
gui-confirm-uninstall-title = 确认卸载
gui-status-working = 正在处理...
gui-status-op-failed = 操作失败。
# Title of the message shown when the game could not be started.
gui-launch-failed-title = 无法启动
gui-op-failed-title = 操作失败
# Title of the message shown when an operation finished.
gui-op-done-title = 完成

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = { $app } 有新版本 { $version } 可用（当前版本为 { $current }）。要立即更新并重新启动吗？
gui-self-update-title = 有可用更新
gui-status-downloading-update = 正在下载更新...
gui-status-update-failed = 更新失败。
gui-update-failed-title = 更新失败
gui-status-update-installed = 更新已安装。
gui-update-installed = 更新已安装。应用即将重新启动。
gui-update-installed-title = 更新已安装

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Loadstone 设置不可用：{ $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = { $name } 设置
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }：
# Group of the mod's own settings.
gui-mod-options-group = 模组选项
gui-mod-options-after-install = 安装模组后才能使用其选项。
gui-status-setting-saved = 设置已保存。
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = 设置已保存。{ $note }
gui-setting-not-changed-title = 设置未更改
gui-status-no-settings-changed = 没有更改任何设置。

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone 设置
gui-accounts-label = 帐户(&A)：
gui-accounts-description = 用于从私有仓库下载模组的登录帐户。
gui-button-sign-in = 登录(&I)...
gui-button-add-token = 添加令牌(&T)...
gui-button-remove-account = 删除帐户(&R)
gui-button-set-default = 设为默认(&D)
# "gh auth token" is a command, keep it.
gui-add-token-description = 使用你已有的令牌添加帐户，例如通过 GitHub CLI 的 gh auth token 命令获取的令牌。
gui-rules-label = 帐户规则(&U)：
gui-rules-description = 为某个仓库或某个所有者的所有仓库指定使用哪个帐户。没有规则时，使用默认帐户。
gui-button-add-rule = 添加规则(&E)...
gui-button-remove-rule = 删除规则(&V)
gui-button-tester-password = 测试人员密码(&P)...
gui-tester-password-description = 供内部测试人员使用：输入你获得的密码，即可看到仅限测试人员的模组并获取测试版。可以添加多个密码。留空则停止测试。
gui-tester-password-prompt-saved = 你已保存了测试人员密码。输入另一个密码可添加它；留空则清除所有密码并停止测试。
gui-tester-password-prompt = 输入你获得的测试人员密码。
gui-tester-password-title = 测试人员密码
gui-tester-password-not-saved-title = 测试人员密码未保存
gui-button-close = 关闭(&C)
gui-accounts-unavailable-title = 帐户不可用
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }，{ $site } 上的 { $username }，默认
    [missing] { $account }，{ $site } 上的 { $username }，缺少令牌（请重新登录）
    [default-missing] { $account }，{ $site } 上的 { $username }，默认，缺少令牌（请重新登录）
   *[none] { $account }，{ $site } 上的 { $username }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = 没有帐户。请使用“登录”添加帐户。
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } 使用 { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = 没有规则。
# $site is the site's name, for example GitHub.
gui-add-token-prompt = 粘贴 { $site } 令牌。令牌将先由 { $site } 验证，然后存储在 Windows 凭据管理器中。
gui-add-token-title = 添加令牌
gui-status-account-added = 已添加帐户 { $account }。
gui-token-not-added-title = 令牌未添加
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = 要删除帐户 { $account } 吗？Loadstone 将清除其令牌以及所有使用该帐户的规则。若还要撤销 Loadstone 的访问权限，请在 { $site } 设置中使用 Applications 页面。
gui-remove-account-title = 删除帐户
gui-account-not-removed-title = 帐户未删除
gui-default-not-changed-title = 默认帐户未更改
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = 仓库（github:owner/repo）或某个所有者的所有仓库（github:owner/*）：
gui-add-rule-title = 添加帐户规则
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account }（{ $username }）
gui-add-rule-account-prompt = 使用哪个帐户？
gui-rule-not-added-title = 规则未添加
gui-rule-not-removed-title = 规则未删除

## Signing in

gui-sign-in-no-sites = 没有支持登录的网站。
gui-sign-in-title = 登录
gui-sign-in-which-site = 要登录哪个网站？
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = 登录到 { $site }
gui-sign-in-requesting = 正在向 { $site } 请求登录代码...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = 登录代码(&C)：
gui-button-copy-code = 复制代码(&P)
gui-button-open-sign-in-page = 打开 { $site } 登录页面(&O)
gui-button-cancel = 取消
gui-sign-in-code-copied = 代码已复制。请打开登录页面并将代码粘贴到那里。
# $url is the web address of the sign-in page.
gui-sign-in-instructions = 打开 { $url }，输入下方的代码，然后授权 Loadstone。完成后，此窗口将自动关闭。
gui-sign-in-code-expired = 登录代码在输入前已过期。请重新开始。
# $account is the account's name.
gui-status-signed-in = 已使用 { $account } 登录。
gui-signed-in = 已使用 { $account } 登录到 { $site }。
gui-signed-in-title = 已登录
gui-sign-in-failed-title = 登录失败
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = 要立即使用有权访问的帐户登录吗？
gui-offer-sign-in-title = 登录以继续

## Startup

gui-startup-error-title = Loadstone 启动错误

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone 模组管理器

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = 已安装 { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = 已安装 { $version }（{ $channel } 渠道）
page-catalog-not-installed = 未安装
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = 已在 { $count } 个副本中安装 { $version }
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = 已在 { $count } 个副本中安装（版本不同）
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = 已在 Loadstone 之外安装
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = 已安装，但已配置的模组源中不再列出此模组。
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name }（测试人员预览）
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = 未配置模组源；仅显示已安装的模组。
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = 已隐藏 { $count } 个不适用于这台电脑的模组。
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = 无法加载模组源：{ $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = 在已配置的模组源中未找到：{ $error }
page-note-no-release-metadata = 最新发布的发行版尚无 Loadstone 元数据，因此无法确定最新版本。
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = 注意：{ $game } 的各个副本共用一个模组文件夹。为一个副本安装或卸载模组会影响其他副本；只有模组加载器是每个副本各自独立的。
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = 需要 { $name }（自动安装，当前版本为 { $version }）。
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = 需要 { $name }（自动安装）。

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = 已安装 { $version }（开发渠道）。
page-status-up-to-date = 已是最新（版本 { $version }）。
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = 已是最新（版本 { $version }，比最新发行版 { $latest } 更新）。
# $version is the installed version, $latest the version an update would install.
page-status-update-available = 有可用更新：从 { $version } 更新到 { $latest }。
page-status-installed = 已安装 { $version }。
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = 已在 Loadstone 之外安装（版本未知）。安装版本 { $latest } 后，即可由 Loadstone 管理此副本。
page-status-foreign = 已在 Loadstone 之外安装（版本未知）。安装后，即可由 Loadstone 管理此副本。
page-status-ready = 可以安装版本 { $latest }。
page-status-not-installed = 未安装。
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = 不适用于这台电脑。{ $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = 可以安装版本 { $latest }。未找到游戏文件夹；请使用“浏览”选择。
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = 未安装。未找到游戏文件夹；请使用“浏览”选择。
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = 请使用“浏览”选择文件夹。不适用于这台电脑。{ $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = 请使用“浏览”选择文件夹。可以安装版本 { $latest }。未找到游戏文件夹；请使用“浏览”选择。
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = 请使用“浏览”选择文件夹。未安装。未找到游戏文件夹；请使用“浏览”选择。
# Shown with a mod's settings before it is installed.
page-settings-after-install = 安装后才能编辑设置。

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = { $distribution } 副本，已安装 { $version }，{ $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = { $distribution } 副本，已在 Loadstone 之外安装，{ $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = { $distribution } 副本，未安装，{ $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = 位于 { $folder } 的副本，已安装 { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = 位于 { $folder } 的副本，已在 Loadstone 之外安装
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = 位于 { $folder } 的副本，未安装
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = 尚未找到副本；请使用“浏览”选择游戏文件夹。
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = 其他文件夹...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = 独立版
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = { $channel } 渠道（{ $branch } 分支的最新版本）
# A development channel. $channel is the channel id ("dev").
page-channel-development = { $channel } 渠道（开发版本）
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }，{ $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag }（预发行版）
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }，{ $title }（预发行版）

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = “{ $action }”已完成。
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = 正在下载 { $file }...
page-self-update-installed = 更新已验证并安装。
page-tester-passwords-removed = 测试人员密码已删除。仅限测试人员的模组和测试版将再次隐藏。

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label }（{ $site } 上的 { $username }）

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = 未配置模组源
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = 找不到“{ $id }”的来源仓库
# $id is a mod id.
page-error-not-installed-no-registries = “{ $id }”未安装，且未配置模组源
# $id is a mod id.
page-error-not-installed-unresolved = “{ $id }”未安装，且无法找到
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = “{ $id }”未安装，且无法找到：{ $error }
page-error-tester-password-wrong = 这不是你的任何模组源或其模组的测试人员密码。
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = 帐户存储不可用
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = “{ $value }”不是数字
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = 不是有限数字

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = { $id } 的文件哈希不匹配：应为 { $expected }，实际为 { $actual }。拒绝安装。
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = { $id }（{ $artifact }）的文件哈希不匹配：应为 { $expected }，实际为 { $actual }。拒绝安装。
engine-hash-verified = 文件哈希已验证。
engine-hash-none = 此来源没有可验证的哈希（本地或开发版安装）。

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = 正在删除先前安装的版本 { $version }（{ $count } 个文件）。
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = 警告：{ $message }
# { $error } is a system error message.
engine-warning-record-originals = 警告：无法记录尚待恢复的原始文件：{ $error }
engine-install-failed-rolling-back = 安装失败；正在删除已写入的文件。
# Summary shown when an install or update finishes.
engine-installed = 已安装 { $name } { $version }。
# The user answered no to the release notes or development build question.
engine-install-cancelled = 安装已取消。

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = “{ $id }”不是此模组的安装选项（可用选项：{ $options }）
engine-option-unknown-none = “{ $id }”不是此模组的安装选项（可用选项：无）
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = “{ $value }”不是 { $option } 的可选值（可选值：{ $choices }）
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }：{ $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }：{ $choice }
engine-option-cancelled = 已取消：未做选择

## Mod settings

# { $label } is the setting's name.
engine-setting-default = 设置“{ $label }”使用默认值；之后可以用 settings 命令更改。
# { $path } is the settings file.
engine-settings-written = 已将设置写入 { $path }。

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = “{ $action }”不是 { $id } 的操作（可用操作：{ $available }）
engine-action-unknown-none = “{ $action }”不是 { $id } 的操作（可用操作：无）
# { $label } is the action's name, as on its button.
engine-action-unavailable = “{ $label }”目前不可用（未满足其前提条件）
engine-action-running = 正在运行“{ $label }”...
engine-action-finished = “{ $label }”已完成。
engine-no-launch-steps = { $id } 没有为此平台声明启动步骤
# Summary after starting the game with a mod.
engine-launched = 已启动 { $id }。

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } 是指向开发工作目录的链接；拒绝通过它修改或删除文件。如果确实要在此处使用 Loadstone 管理安装，请先删除该链接。

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = 不删除 { $path }：它位于模组的文件夹之外。
engine-legacy-link = 不删除 { $path }：它是通过链接访问的。
engine-legacy-shared = 不删除 { $path }：另一个已安装的软件包正在使用它。
engine-legacy-removed = 已删除残留的 { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = 警告：无法删除 { $path }：{ $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = 未找到必需的文件：{ $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = 未满足步骤 { $step } 的要求。
engine-step-skipped = 已跳过步骤 { $step }。
engine-cancelled-at-step = 在步骤 { $step } 处取消
engine-extracting = 正在解压文件...
engine-placed-files = 已放置 { $count } 个文件。
engine-kept-existing = 保留了现有的 { $path }（未覆盖，它可能更新）。
engine-file-created = 已创建并更新 { $path }。
engine-file-updated = 已更新 { $path }。
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = 已取消：未为“{ $prompt }”选择文件夹
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = 已复制到剪贴板：{ $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = 已将 { $count } 个架构合并到 { $file } 中。
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = 无法启动：缺少 { $path }
engine-program-start-failed = 无法启动 { $path }
engine-program-started = 已启动 { $path }。
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = 无法打开 { $url }
engine-url-opened = 已打开 { $url }。

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = 以下模组仍需要 { $id }：{ $dependents }。请先卸载它们。
engine-removing-files = 正在删除 { $count } 个文件。
engine-purge-question = 是否同时删除已保存的设置和首选项？
engine-purge-done = 已删除保存的设置。
engine-dependency-unneeded = 已安装的模组都不再需要 { $id }；你也可以将其卸载。
# Summary when an uninstall finishes.
engine-uninstalled = 已卸载 { $id } { $version }。

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = 使用已保存在 { $path } 的原始文件。
engine-originals-kept = 已备份 { $count } 个原始游戏文件。
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = 警告：目前无法恢复原始的 { $path }（{ $error }）。将在更新或卸载此模组时恢复。
engine-original-restored = 已恢复原始的 { $path }。
# { $backup } is where the kept original should have been.
engine-original-missing = 警告：{ $path } 的原始文件缺失（{ $backup }）；保持该文件不变。
engine-original-changed = 自安装此模组以来，{ $path } 已更改（游戏更新了吗？）；保留较新的文件。
engine-originals-restored = 已恢复 { $count } 个原始游戏文件。
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = 无法恢复 { $count } 个原始游戏文件；请关闭游戏后重试。

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = 正在更新位于 { $path } 的 { $distribution } 副本。
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path }（{ $distribution }）
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = “{ $id }”安装在 { $game } 的多个副本中：{ $copies }。请使用 --game-dir 指定要更新的副本。
engine-many-copies = “{ $id }”安装在 { $game } 的多个副本中：{ $copies }。请使用 --game-dir 指定副本。
engine-not-game-folder = { $path } 看起来不是 { $game } 文件夹（未找到任何预期的文件）
engine-game-found = 在 { $path } 找到了 { $game }
engine-game-not-found = 无法自动找到 { $game }。
# Title of the folder picker.
engine-game-where = { $game } 安装在哪里？
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = 无法自动找到 { $game }；请使用 --game-dir 或选择其文件夹
# { $path } is a game folder.
engine-not-installed-copy = “{ $id }”未安装在位于 { $path } 的 { $game } 副本中
engine-not-installed = “{ $id }”未安装在 { $game } 中

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = 无法在这台电脑上安装 { $name }。{ $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = 不支持 { $game } 的 { $distribution } 副本。{ $reason }
engine-distribution-untested = 注意：此模组尚未在 { $game } 的 { $distribution } 副本上测试过。
engine-no-matching-artifact = 没有与此平台、架构或商店版本匹配的发行版文件
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = 此模组仅适用于 { $platform }。
engine-platform-only-two = 此模组仅适用于 { $first } 和 { $second }。
engine-platform-only-three = 此模组仅适用于 { $first }、{ $second } 和 { $third }。
engine-platform-needs-apple-silicon = 在 { $platform } 上，此模组需要 Apple 芯片。
engine-platform-needs-arm = 在 { $platform } 上，此模组需要 ARM 处理器。
engine-platform-needs-x64 = 在 { $platform } 上，此模组需要 Intel 或 AMD 处理器。
engine-game-platform-unsupported = 此处不支持 { $platform } 上的 { $game }。

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } 已是最新（{ $version }）。
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } 已是最新（{ $installed } 比最新发行版 { $latest } 更新）。
engine-installed-newer = 已安装的 { $name } { $installed } 比你当前可用的最新发行版（{ $latest }）更新。未做任何更改。若要安装旧版本，请明确选择该版本。
# { $from } and { $to } are versions.
engine-updating = 正在将 { $name } 从 { $from } 更新到 { $to }。
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    要从 { $branch } 分支的最新提交（{ $version }）安装 { $name } 吗？

    开发版本未经哈希锁定；你将信任该仓库的当前内容。
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    { $name } { $version } 的发行说明：

    { $notes }

    要立即安装吗？
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = 正在从 { $source } 获取发行版 { $tag } 的信息...
engine-fetching-latest = 正在从 { $source } 获取最新发行版的信息...
engine-using-local-artifact = 使用本地文件 { $path }
# { $file } is a download's file name.
engine-using-cached = 使用已下载的 { $file }。
engine-downloading = 正在下载 { $file }...
engine-dependency-present = 依赖项 { $id } { $version } 已安装。
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = 正在安装依赖项 { $name } { $version }（{ $file }）...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = 未提供令牌
core-sign-in-cancelled = 登录已取消。
core-sign-in-expired = 登录代码在输入前已过期。请重新开始。
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = “{ $pattern }”不是来源（github:owner/repo）或所有者通配符（github:owner/*）
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = 无法将令牌保存到系统凭据存储
core-secrets-remove-failed = 无法从系统凭据存储中删除令牌

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = { $source } 的发行版 { $tag } 中没有 { $file } 文件
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = { $source } 的最新发行版中没有 { $file } 文件
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = 发行版 { $tag } 中没有 loadstone-release.json 文件（或无法访问）
core-github-sign-in-cancelled = 已在 GitHub 上取消登录。
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub 拒绝了登录：{ $details }
core-github-sign-in-refused-no-details = GitHub 拒绝了登录：未提供详细信息
core-github-token-rejected = GitHub 不接受此令牌

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } 不支持登录
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = “{ $source }”不是 { $format } 格式的来源
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = 未找到 { $source }。如果是私有仓库，请使用有权访问的帐户登录（Loadstone 设置），或设置 GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = 来自 { $account } 的令牌被拒绝；它可能已过期或被撤销
core-source-token-unreachable = 使用来自 { $account } 的令牌无法访问 { $source }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = 下载 { $url } 时返回 HTTP { $status }
core-fetch-request-failed = 请求失败：{ $url }
core-fetch-download-failed = 下载失败：{ $url }
# Reading a server's reply failed partway.
core-fetch-read-error = 读取错误
core-fetch-read-error-download = 下载过程中出现读取错误

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = 没有适用于此平台或商店版本的解压方式
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } 是指向开发工作目录的链接。请改用 git 更新该工作目录，或在安装前删除该链接。
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = 此压缩包不包含预期的内容（没有与任何解压方式匹配的条目）

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = 模组源“{ $source }”既不是 { $formats }，也不是现有的文件夹
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } 中没有 loadstone-packages 文件夹
# $error is the reason the download failed.
core-registry-using-cache = 无法刷新 { $source }（{ $error }）；正在使用缓存的数据。
core-registry-fetch-failed = 无法获取模组源 { $source }
# $id is a mod's id.
core-registry-package-not-found = 在任何模组源中都未找到软件包“{ $id }”

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = “{ $key }”是布尔值；请使用 true 或 false
core-setting-not-number = “{ $key }”需要一个数字
core-setting-too-small = “{ $key }”不能小于 { $min }
core-setting-too-large = “{ $key }”不能大于 { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = “{ $key }”必须是以下值之一：{ $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = 已为某个模组源的模组解锁测试人员权限：将列出仅限测试人员的模组，安装和更新时将获取测试版。
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = 已为某个模组源的模组及 { $mods } 解锁测试人员权限：将列出仅限测试人员的模组，安装和更新时将获取测试版。
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = 已为 { $mods } 解锁测试人员权限：将列出仅限测试人员的模组，安装和更新时将获取测试版。
core-tester-save-failed = 无法保存测试人员密码
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = 发行版 { $tag } 没有可用的 Loadstone 元数据（{ $error }）；将使用最新的稳定发行版。
core-tester-beta-lookup-failed = 无法查询测试版（{ $error }）；将使用最新的稳定发行版。

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = 下载的更新未通过哈希验证（应为 { $expected }，实际为 { $actual }）；未安装
core-update-translocated = macOS 正在从临时的只读副本运行此应用，因此它无法自行更新。请将其移到“应用程序”文件夹，从那里打开，然后再次更新。
core-update-on-disk-image = 此应用正在从其磁盘映像运行，因此无法自行更新。请将其复制到“应用程序”文件夹，从那里打开，然后再次更新。
# $path is the folder the app is in.
core-update-no-write = 无法在 { $path } 中写入（没有权限？），因此应用无法自行更新。请改为从发行版页面下载新版本。
core-update-no-staging = 无法在 { $path } 中写入（没有权限？）。请改为从发行版页面下载新版本
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = 此更新属于其他应用（{ $got }，应为 { $expected }）；未安装
core-update-move-aside-app = 无法移开当前应用
core-update-move-in-app = 无法将新应用移到位
core-update-move-aside-exe = 无法移开当前可执行文件
core-update-move-in-exe = 无法将新可执行文件移到位

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = 确定(&O)
gui-stock-ok-plain = 确定
gui-stock-cancel = 取消(&C)
gui-stock-cancel-plain = 取消
gui-stock-yes = 是(&Y)
gui-stock-yes-plain = 是
gui-stock-no = 否(&N)
gui-stock-no-plain = 否
gui-stock-close = 关闭(&C)
gui-stock-close-plain = 关闭
