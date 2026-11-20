# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = この MOD には新しいバージョンの Loadstone が必要です。Loadstone を更新してから、もう一度お試しください。

## Loadstone settings

pref-language = 言語
pref-language-description = Loadstone と翻訳済みの MOD の表示に使う言語です。
language-system = システムの既定
pref-accounts = アカウント
pref-accounts-description = プライベートリポジトリから MOD をダウンロードするためのサインインです。
pref-account-rules = アカウントのルール
pref-account-rules-description = リポジトリや所有者ごとに使用するアカウントを指定します。
pref-try-other-accounts = ダウンロードが拒否されたときは他のアカウントを試す
pref-try-other-accounts-description = リポジトリが見つからない場合やアクセスが拒否された場合に、あきらめる前にそのサイトの他のアカウントを試します。
pref-tester-passwords = テスターのパスワード
pref-tester-passwords-description = レジストリ全体または個別の MOD について、テスター限定の MOD とベータ版を利用できるようにします。「テスターのパスワード」ボタンから設定します。
pref-download-account = ダウンロードに使うアカウント
pref-download-account-description = この MOD のダウンロードに使うアカウントです。「自動」では、アカウントのルールと既定のアカウントを使用します。
pref-download-account-automatic = 自動（アカウントのルール、次に既定のアカウント）

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = Loadstone の設定(&L)...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = プライベートリポジトリ用のアカウントと、Loadstone のオプション
gui-menu-exit = 終了(&X)
# Menu bar title.
gui-menu-tools = ツール(&T)
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = 操作がまだ実行中です。今閉じると、操作が完了しないままになる可能性があります。閉じてもよろしいですか？
gui-close-while-running-title = 操作の実行中
# Status bar text while a standalone installer loads its mod.
gui-status-loading = 読み込んでいます...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = 操作中に問題が発生しました
gui-button-retry = 再試行(&R)
gui-button-skip = スキップ(&S)
gui-button-cancel-problem = キャンセル(&C)
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = インストールのオプション

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title }（コア { $version }）
# Label of the list of mods.
gui-catalog-mods-label = MOD(&M):
# Button that opens the selected mod's page.
gui-button-details = 詳細(&D)
gui-button-refresh = 最新の情報に更新(&R)
gui-button-loadstone-settings = Loadstone の設定(&G)...
gui-status-fetching-catalog = MOD カタログを取得しています...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = MOD の一覧を読み込んでいます...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = MOD の一覧を読み込めませんでした。「最新の情報に更新」を押して再試行してください。
gui-status-catalog-failed = カタログを取得できませんでした。
gui-catalog-error-title = MOD カタログを読み込めませんでした
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }、{ $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }、{ $status }、{ $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = 利用できる MOD はありません。
gui-status-catalog-loaded = カタログを読み込みました（MOD { $count } 個）。

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = { $mod_id } を読み込んでいます...
gui-status-mod-load-failed = MOD のページを読み込めませんでした。
gui-mod-error-title = MOD を読み込めませんでした
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = 管理するゲームのコピー(&C):
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = 管理する { $game } のコピー(&C):
gui-button-back = MOD の一覧に戻る(&B)
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }（作者: { $authors }）
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = ゲームのフォルダー(&G):
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = { $game } のフォルダー(&G):
gui-button-browse = 参照(&W)...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = ゲームのフォルダーを選択してください
gui-browse-game-prompt-named = { $game } のフォルダーを選択してください
gui-description-label = 説明:
# Label of the log where operations report their progress.
gui-activity-label = アクティビティ:
gui-button-update = 更新(&U)
gui-button-install = インストール(&I)
gui-select-folder-first = 先に「参照」でゲームのフォルダーを選択してください。
gui-button-install-from-file = ファイルからインストール(&F)...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = MOD の loadstone-release.json を選択してください
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON ファイル (*.json)|*.json|すべてのファイル (*.*)|*.*
gui-button-uninstall = アンインストール(&N)
gui-button-launch = ゲームを起動(&L)
# Description of the Launch game button, read when it gets focus.
gui-launch-description = MOD を読み込んだ状態でゲームを起動します。
gui-launch-unavailable-description = このコピーに MOD をインストールすると使用できます。
gui-button-change-options = インストールのオプションを変更(&O)...
gui-change-options-description = MOD のインストール時の質問をもう一度表示し、その回答で最新バージョンを再インストールします。
gui-button-settings = 設定(&S)...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = 処理中... { $percent }%
gui-status-fetching-releases = リリースの一覧を取得しています...
# $error is an error message.
gui-release-list-error = リリースの一覧を取得できませんでした: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = 代わりに最新のリリースをインストールしますか？
gui-release-list-error-title = リリースの一覧を利用できません
gui-no-releases = この MOD のリポジトリには、まだリリースがありません。
gui-no-releases-title = リリースがありません
gui-choose-version = インストールするバージョンを選択してください:
gui-choose-version-title = バージョンの選択
gui-confirm-uninstall = { $name } をアンインストールしますか？
gui-confirm-uninstall-title = アンインストールの確認
gui-status-working = 処理中...
gui-status-op-failed = 操作に失敗しました。
# Title of the message shown when the game could not be started.
gui-launch-failed-title = 起動できません
gui-op-failed-title = 操作に失敗しました
# Title of the message shown when an operation finished.
gui-op-done-title = 完了

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = { $app } のバージョン { $version } が利用可能です（現在のバージョンは { $current }）。今すぐ更新して再起動しますか？
gui-self-update-title = 更新を利用できます
gui-status-downloading-update = 更新をダウンロードしています...
gui-status-update-failed = 更新に失敗しました。
gui-update-failed-title = 更新に失敗しました
gui-status-update-installed = 更新をインストールしました。
gui-update-installed = 更新をインストールしました。アプリを再起動します。
gui-update-installed-title = 更新のインストール完了

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Loadstone の設定を利用できません: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = { $name } の設定
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = MOD のオプション
gui-mod-options-after-install = MOD のオプションは、インストール後に利用できるようになります。
gui-status-setting-saved = 設定を保存しました。
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = 設定を保存しました。{ $note }
gui-setting-not-changed-title = 設定は変更されませんでした
gui-status-no-settings-changed = 変更された設定はありません。

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone の設定
gui-accounts-label = アカウント(&A):
gui-accounts-description = プライベートリポジトリから MOD をダウンロードするためのサインインです。
gui-button-sign-in = サインイン(&I)...
gui-button-add-token = トークンを追加(&T)...
gui-button-remove-account = アカウントを削除(&R)
gui-button-set-default = 既定に設定(&D)
# "gh auth token" is a command, keep it.
gui-add-token-description = お持ちのトークンからアカウントを追加します。たとえば、GitHub CLI の gh auth token コマンドで取得したトークンを使用できます。
gui-rules-label = アカウントのルール(&U):
gui-rules-description = リポジトリごと、または所有者のすべてのリポジトリに対して使用するアカウントを指定します。ルールがない場合は、既定のアカウントが使用されます。
gui-button-add-rule = ルールを追加(&E)...
gui-button-remove-rule = ルールを削除(&V)
gui-button-tester-password = テスターのパスワード(&P)...
gui-tester-password-description = 限定テスター向け: 受け取ったパスワードを入力すると、テスター限定の MOD が表示され、ベータ版を入手できます。パスワードは複数追加できます。空のままにすると、テストを終了します。
gui-tester-password-prompt-saved = 保存済みのテスターのパスワードがあります。追加するには別のパスワードを入力してください。空のままにすると、すべてのパスワードを削除してテストを終了します。
gui-tester-password-prompt = 受け取ったテスターのパスワードを入力してください。
gui-tester-password-title = テスターのパスワード
gui-tester-password-not-saved-title = テスターのパスワードは保存されませんでした
gui-button-close = 閉じる(&C)
gui-accounts-unavailable-title = アカウントを利用できません
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }、{ $site } の { $username }、既定
    [missing] { $account }、{ $site } の { $username }、トークンがありません（もう一度サインインしてください）
    [default-missing] { $account }、{ $site } の { $username }、既定、トークンがありません（もう一度サインインしてください）
   *[none] { $account }、{ $site } の { $username }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = アカウントがありません。「サインイン」で追加してください。
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } では { $account } を使用
# Placeholder line when there are no account rules.
gui-rules-empty = ルールがありません。
# $site is the site's name, for example GitHub.
gui-add-token-prompt = { $site } のトークンを貼り付けてください。トークンは { $site } で確認された後、Windows の資格情報マネージャーに保存されます。
gui-add-token-title = トークンの追加
gui-status-account-added = アカウント { $account } を追加しました。
gui-token-not-added-title = トークンは追加されませんでした
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = アカウント { $account } を削除しますか？Loadstone は、このアカウントのトークンと、このアカウントを使うルールをすべて削除します。Loadstone のアクセス権も取り消すには、{ $site } の設定にある「Applications」ページを使用してください。
gui-remove-account-title = アカウントの削除
gui-account-not-removed-title = アカウントは削除されませんでした
gui-default-not-changed-title = 既定のアカウントは変更されませんでした
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = リポジトリ（github:owner/repo）、または所有者のすべてのリポジトリ（github:owner/*）:
gui-add-rule-title = アカウントのルールの追加
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account }（{ $username }）
gui-add-rule-account-prompt = どのアカウントを使用しますか？
gui-rule-not-added-title = ルールは追加されませんでした
gui-rule-not-removed-title = ルールは削除されませんでした

## Signing in

gui-sign-in-no-sites = サインインに対応しているサイトがありません。
gui-sign-in-title = サインイン
gui-sign-in-which-site = どのサイトにサインインしますか？
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = { $site } にサインイン
gui-sign-in-requesting = { $site } にサインインコードを要求しています...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = サインインコード(&C):
gui-button-copy-code = コードをコピー(&P)
gui-button-open-sign-in-page = { $site } のサインインページを開く(&O)
gui-button-cancel = キャンセル
gui-sign-in-code-copied = コードをコピーしました。サインインページを開いて、そこに貼り付けてください。
# $url is the web address of the sign-in page.
gui-sign-in-instructions = { $url } を開き、下のコードを入力して Loadstone を承認してください。完了すると、このウィンドウは自動的に閉じます。
gui-sign-in-code-expired = サインインコードが入力される前に有効期限が切れました。もう一度やり直してください。
# $account is the account's name.
gui-status-signed-in = { $account } としてサインインしました。
gui-signed-in = { $site } に { $account } としてサインインしました。
gui-signed-in-title = サインイン完了
gui-sign-in-failed-title = サインインに失敗しました
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = アクセスできるアカウントで今すぐサインインしますか？
gui-offer-sign-in-title = 続行するにはサインインしてください

## Startup

gui-startup-error-title = Loadstone の起動エラー

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone MOD マネージャー

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = インストール済み（{ $version }）
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = インストール済み（{ $version }、{ $channel } チャンネル）
page-catalog-not-installed = 未インストール
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count } 個のコピーにインストール済み（{ $version }）
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count } 個のコピーにインストール済み（バージョンが異なります）
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Loadstone 以外でインストール済み
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = インストール済みですが、設定されたレジストリには掲載されていません。
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name }（テスター向けプレビュー）
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = レジストリが設定されていません。インストール済みの MOD のみを表示しています。
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = このコンピューターで利用できない MOD { $count } 個を非表示にしています。
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = レジストリを読み込めませんでした: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = 設定されたレジストリに見つかりません: { $error }
page-note-no-release-metadata = 公開されている最新のリリースにはまだ Loadstone のメタデータがないため、最新バージョンを判断できませんでした。
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = 注: { $game } のコピーは、1 つの MOD フォルダーを共有しています。1 つのコピーで MOD をインストールまたはアンインストールすると、他のコピーにも影響します。コピーごとに別々なのは MOD ローダーだけです。
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = { $name } が必要です（自動的にインストールされます。現在のバージョンは { $version }）。
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = { $name } が必要です（自動的にインストールされます）。

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = { $version } をインストール済みです（開発チャンネル）。
page-status-up-to-date = 最新の状態です（バージョン { $version }）。
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = 最新の状態です（バージョン { $version }。最新のリリース { $latest } より新しいバージョンです）。
# $version is the installed version, $latest the version an update would install.
page-status-update-available = 更新があります: { $version } から { $latest } へ。
page-status-installed = { $version } をインストール済みです。
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Loadstone 以外でインストールされています（バージョン不明）。バージョン { $latest } をインストールすると、Loadstone でこのコピーを管理できるようになります。
page-status-foreign = Loadstone 以外でインストールされています（バージョン不明）。インストールすると、Loadstone でこのコピーを管理できるようになります。
page-status-ready = バージョン { $latest } をインストールできます。
page-status-not-installed = インストールされていません。
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = このコンピューターでは利用できません。{ $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = バージョン { $latest } をインストールできます。ゲームのフォルダーが見つかりません。「参照」で選択してください。
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = インストールされていません。ゲームのフォルダーが見つかりません。「参照」で選択してください。
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = 「参照」でフォルダーを選択してください。このコンピューターでは利用できません。{ $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = 「参照」でフォルダーを選択してください。バージョン { $latest } をインストールできます。ゲームのフォルダーが見つかりません。「参照」で選択してください。
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = 「参照」でフォルダーを選択してください。インストールされていません。ゲームのフォルダーが見つかりません。「参照」で選択してください。
# Shown with a mod's settings before it is installed.
page-settings-after-install = 設定はインストール後に編集できるようになります。

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = { $distribution } 版、{ $version } をインストール済み、{ $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = { $distribution } 版、Loadstone 以外でインストール済み、{ $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = { $distribution } 版、未インストール、{ $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = { $folder } のコピー、{ $version } をインストール済み
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = { $folder } のコピー、Loadstone 以外でインストール済み
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = { $folder } のコピー、未インストール
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = コピーがまだ見つかりません。「参照」でゲームのフォルダーを選択してください。
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = 別のフォルダー...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = スタンドアロン
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = { $channel } チャンネル（{ $branch } ブランチの最新版）
# A development channel. $channel is the channel id ("dev").
page-channel-development = { $channel } チャンネル（開発ビルド）
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }、{ $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag }（プレリリース）
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }、{ $title }（プレリリース）

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = 「{ $action }」が完了しました。
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = { $file } をダウンロードしています...
page-self-update-installed = 更新を検証してインストールしました。
page-tester-passwords-removed = テスターのパスワードを削除しました。テスター限定の MOD とベータ版は再び非表示になります。

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label }（{ $site } の { $username }）

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = レジストリが設定されていません
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = 「{ $id }」のソースリポジトリが不明です
# $id is a mod id.
page-error-not-installed-no-registries = 「{ $id }」はインストールされておらず、レジストリも設定されていません
# $id is a mod id.
page-error-not-installed-unresolved = 「{ $id }」はインストールされておらず、見つけることもできませんでした
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = 「{ $id }」はインストールされておらず、見つけることもできませんでした: { $error }
page-error-tester-password-wrong = そのパスワードは、どのレジストリや MOD のテスターのパスワードでもありません。
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = アカウントの保存先を利用できません
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = 「{ $value }」は数値ではありません
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = 有限の数値ではありません

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = { $id } のファイルのハッシュが一致しません（期待値: { $expected }、実際の値: { $actual }）。インストールを中止します。
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = { $id }（{ $artifact }）のファイルのハッシュが一致しません（期待値: { $expected }、実際の値: { $actual }）。インストールを中止します。
engine-hash-verified = ファイルのハッシュを検証しました。
engine-hash-none = このソースには検証するハッシュがありません（ローカルまたは開発版のインストール）。

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = 以前にインストールしたバージョン { $version } を削除しています（ファイル { $count } 個）。
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = 警告: { $message }
# { $error } is a system error message.
engine-warning-record-originals = 警告: これから復元する元のファイルを記録できませんでした: { $error }
engine-install-failed-rolling-back = インストールに失敗しました。ここまでに書き込んだファイルを削除しています。
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } をインストールしました。
# The user answered no to the release notes or development build question.
engine-install-cancelled = インストールをキャンセルしました。

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = 「{ $id }」はこの MOD のインストールオプションではありません（オプション: { $options }）
engine-option-unknown-none = 「{ $id }」はこの MOD のインストールオプションではありません（オプション: なし）
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = 「{ $value }」は { $option } の選択肢ではありません（選択肢: { $choices }）
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = キャンセルされました: 選択されていません

## Mod settings

# { $label } is the setting's name.
engine-setting-default = 設定「{ $label }」は既定値で開始します。後で settings コマンドで変更できます。
# { $path } is the settings file.
engine-settings-written = 設定を { $path } に書き込みました。

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = 「{ $action }」は { $id } のアクションではありません（利用可能: { $available }）
engine-action-unknown-none = 「{ $action }」は { $id } のアクションではありません（利用可能: なし）
# { $label } is the action's name, as on its button.
engine-action-unavailable = 「{ $label }」は現在利用できません（前提条件を満たしていません）
engine-action-running = 「{ $label }」を実行しています...
engine-action-finished = 「{ $label }」が完了しました。
engine-no-launch-steps = { $id } には、このプラットフォーム用の起動手順が定義されていません
# Summary after starting the game with a mod.
engine-launched = { $id } を起動しました。

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } は開発用の作業フォルダーへのリンクです。このリンクを経由してファイルを変更または削除することはしません。ここを Loadstone で管理したい場合は、先にリンクを削除してください。

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = { $path } は削除しません: MOD のフォルダーの外にあります。
engine-legacy-link = { $path } は削除しません: リンクを経由した場所にあります。
engine-legacy-shared = { $path } は削除しません: インストール済みの別のパッケージが使用しています。
engine-legacy-removed = 残っていた { $path } を削除しました
# { $error } is a system error message.
engine-legacy-remove-failed = 警告: { $path } を削除できませんでした: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = 必要なファイルが見つかりません: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = ステップ { $step } の要件を満たしていません。
engine-step-skipped = ステップ { $step } をスキップしました。
engine-cancelled-at-step = ステップ { $step } でキャンセルされました
engine-extracting = ファイルを展開しています...
engine-placed-files = { $count } 個のファイルを配置しました。
engine-kept-existing = 既存の { $path } を残しました（こちらが新しい可能性があるため、上書きしていません）。
engine-file-created = { $path } を作成して更新しました。
engine-file-updated = { $path } を更新しました。
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = キャンセルされました: 「{ $prompt }」のフォルダーが選択されていません
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = クリップボードにコピーしました: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count } 個のアーキテクチャを { $file } に統合しました。
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = 起動できません: { $path } が見つかりません
engine-program-start-failed = { $path } を起動できませんでした
engine-program-started = { $path } を起動しました。
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = { $url } を開けませんでした
engine-url-opened = { $url } を開きました。

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } は次の MOD でまだ必要です: { $dependents }。先にそれらをアンインストールしてください。
engine-removing-files = { $count } 個のファイルを削除しています。
engine-purge-question = 保存された設定と環境設定も削除しますか？
engine-purge-done = 保存された設定を削除しました。
engine-dependency-unneeded = { $id } は、インストール済みのどの MOD にも必要なくなりました。これもアンインストールできます。
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } をアンインストールしました。

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = { $path } に保管済みの元のファイルを使用します。
engine-originals-kept = 元のゲームファイル { $count } 個のコピーを保管しました。
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = 警告: 元の { $path } を今は復元できませんでした（{ $error }）。この MOD の更新時またはアンインストール時に元に戻されます。
engine-original-restored = 元の { $path } を復元しました。
# { $backup } is where the kept original should have been.
engine-original-missing = 警告: { $path } の元のファイルが見つかりません（{ $backup }）。ファイルはそのままにします。
engine-original-changed = この MOD のインストール後に { $path } が変更されています（ゲームが更新されたのかもしれません）。新しいほうのファイルを残します。
engine-originals-restored = 元のゲームファイルを { $count } 個復元しました。
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = 元のゲームファイル { $count } 個を元に戻せませんでした。ゲームを閉じてから、もう一度お試しください。

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = { $path } にある { $distribution } 版を更新しています。
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path }（{ $distribution }）
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = 「{ $id }」は { $game } の複数のコピーにインストールされています: { $copies }。更新するコピーを --game-dir で指定してください。
engine-many-copies = 「{ $id }」は { $game } の複数のコピーにインストールされています: { $copies }。対象のコピーを --game-dir で指定してください。
engine-not-game-folder = { $path } は { $game } のフォルダーではないようです（想定されるファイルが見つかりません）
engine-game-found = { $path } に { $game } が見つかりました
engine-game-not-found = { $game } を自動的に見つけられませんでした。
# Title of the folder picker.
engine-game-where = { $game } はどこにインストールされていますか？
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = { $game } を自動的に見つけられませんでした。--game-dir を指定するか、フォルダーを選択してください
# { $path } is a game folder.
engine-not-installed-copy = 「{ $id }」は { $path } にある { $game } のコピーにはインストールされていません
engine-not-installed = 「{ $id }」は { $game } にインストールされていません

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = { $name } はこのコンピューターにはインストールできません。{ $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = { $game } の { $distribution } 版はサポートされていません。{ $reason }
engine-distribution-untested = 注: { $game } の { $distribution } 版では、この MOD はテストされていません。
engine-no-matching-artifact = このプラットフォーム、アーキテクチャ、ストア版に一致するリリースファイルがありません
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = この MOD は { $platform } でのみ利用できます。
engine-platform-only-two = この MOD は { $first } と { $second } でのみ利用できます。
engine-platform-only-three = この MOD は { $first }、{ $second }、{ $third } でのみ利用できます。
engine-platform-needs-apple-silicon = { $platform } でこの MOD を使うには、Apple シリコンのプロセッサが必要です。
engine-platform-needs-arm = { $platform } でこの MOD を使うには、ARM プロセッサが必要です。
engine-platform-needs-x64 = { $platform } でこの MOD を使うには、Intel または AMD のプロセッサが必要です。
engine-game-platform-unsupported = この環境では、{ $platform } の { $game } はサポートされていません。

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } は最新の状態です（{ $version }）。
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } は最新の状態です（{ $installed } は最新のリリース { $latest } より新しいバージョンです）。
engine-installed-newer = インストールされている { $name } { $installed } は、現在利用できる最新のリリース（{ $latest }）より新しいバージョンです。何も変更していません。古いバージョンをインストールするには、そのバージョンを明示的に選択してください。
# { $from } and { $to } are versions.
engine-updating = { $name } を { $from } から { $to } に更新しています。
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    { $name } を { $branch } ブランチの最新の状態（{ $version }）からインストールしますか？

    開発ビルドはハッシュで固定されていません。リポジトリの現在の内容を信頼することになります。
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    { $name } { $version } のリリースノート:

    { $notes }

    今すぐインストールしますか？
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = { $source } からリリース { $tag } の情報を取得しています...
engine-fetching-latest = { $source } から最新のリリースの情報を取得しています...
engine-using-local-artifact = ローカルのファイル { $path } を使用します
# { $file } is a download's file name.
engine-using-cached = ダウンロード済みの { $file } を使用します。
engine-downloading = { $file } をダウンロードしています...
engine-dependency-present = 依存パッケージ { $id } { $version } は既にインストールされています。
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = 依存パッケージ { $name } { $version }（{ $file }）をインストールしています...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = トークンが入力されていません
core-sign-in-cancelled = サインインをキャンセルしました。
core-sign-in-expired = サインインコードが入力される前に有効期限が切れました。もう一度やり直してください。
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = 「{ $pattern }」はソース（github:owner/repo）でも、所有者のワイルドカード（github:owner/*）でもありません
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = システムの資格情報ストアにトークンを保存できませんでした
core-secrets-remove-failed = システムの資格情報ストアからトークンを削除できませんでした

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = { $source } のリリース { $tag } には { $file } ファイルがありません
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = { $source } の最新のリリースには { $file } ファイルがありません
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = リリース { $tag } には loadstone-release.json ファイルがありません（またはアクセスできません）
core-github-sign-in-cancelled = GitHub でサインインがキャンセルされました。
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub がサインインを拒否しました: { $details }
core-github-sign-in-refused-no-details = GitHub がサインインを拒否しました: 詳細はありません
core-github-token-rejected = GitHub がトークンを受け付けませんでした

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } はサインインに対応していません
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = 「{ $source }」は { $format } 形式のソースではありません
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } が見つかりませんでした。プライベートリポジトリの場合は、アクセスできるアカウントでサインインする（Loadstone の設定）か、GH_TOKEN を設定してください
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = { $account } のトークンが拒否されました。有効期限が切れているか、取り消された可能性があります
core-source-token-unreachable = { $account } のトークンでは { $source } にアクセスできません

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = { $url } のダウンロードで HTTP { $status } が返されました
core-fetch-request-failed = 要求に失敗しました: { $url }
core-fetch-download-failed = ダウンロードに失敗しました: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = 読み取りエラー
core-fetch-read-error-download = ダウンロード中の読み取りエラー

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = このプラットフォームとストア版に適用できる展開方法がありません
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } は開発用の作業フォルダーへのリンクです。代わりに git でその作業フォルダーを更新するか、インストールする前にリンクを削除してください。
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = このアーカイブには必要なファイルが含まれていません（どの展開方法にも一致する項目がありません）

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = レジストリ「{ $source }」は、{ $formats } 形式でも既存のフォルダーでもありません
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } には loadstone-packages フォルダーがありません
# $error is the reason the download failed.
core-registry-using-cache = { $source } を更新できませんでした（{ $error }）。キャッシュされたデータを使用します。
core-registry-fetch-failed = レジストリ { $source } を取得できませんでした
# $id is a mod's id.
core-registry-package-not-found = パッケージ「{ $id }」はどのレジストリにも見つかりません

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = 「{ $key }」はブール値です。true または false を使用してください
core-setting-not-number = 「{ $key }」には数値が必要です
core-setting-too-small = 「{ $key }」は { $min } 以上にする必要があります
core-setting-too-large = 「{ $key }」は { $max } 以下にする必要があります
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = 「{ $key }」は次のいずれかにする必要があります: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = レジストリの MOD について、テスターアクセスが有効になりました。テスター限定の MOD が一覧に表示され、インストールと更新ではベータ版が使用されます。
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = レジストリの MOD と { $mods } について、テスターアクセスが有効になりました。テスター限定の MOD が一覧に表示され、インストールと更新ではベータ版が使用されます。
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = { $mods } について、テスターアクセスが有効になりました。テスター限定の MOD が一覧に表示され、インストールと更新ではベータ版が使用されます。
core-tester-save-failed = テスターのパスワードを保存できませんでした
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = リリース { $tag } には使用できる Loadstone のメタデータがありません（{ $error }）。最新の安定版リリースを使用します。
core-tester-beta-lookup-failed = ベータ版を確認できませんでした（{ $error }）。最新の安定版リリースを使用します。

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = ダウンロードした更新はハッシュの検証に失敗しました（期待値: { $expected }、実際の値: { $actual }）。インストールしていません
core-update-translocated = macOS がこのアプリを一時的な読み取り専用のコピーから実行しているため、アプリ自身を更新できません。アプリを「アプリケーション」フォルダーに移動し、そこから開いて、もう一度更新してください。
core-update-on-disk-image = このアプリはディスクイメージから実行されているため、アプリ自身を更新できません。アプリを「アプリケーション」フォルダーにコピーし、そこから開いて、もう一度更新してください。
# $path is the folder the app is in.
core-update-no-write = { $path } に書き込めないため（権限がない可能性があります）、アプリ自身を更新できません。代わりに、リリースページから新しいバージョンをダウンロードしてください。
core-update-no-staging = { $path } に書き込めません（権限がない可能性があります）。代わりに、リリースページから新しいバージョンをダウンロードしてください
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = 更新が別のアプリです（{ $got }、期待値: { $expected }）。インストールしていません
core-update-move-aside-app = 現在のアプリを移動できませんでした
core-update-move-in-app = 新しいアプリを所定の場所に移動できませんでした
core-update-move-aside-exe = 現在の実行ファイルを移動できませんでした
core-update-move-in-exe = 新しい実行ファイルを所定の場所に移動できませんでした

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = OK(&O)
gui-stock-ok-plain = OK
gui-stock-cancel = キャンセル(&C)
gui-stock-cancel-plain = キャンセル
gui-stock-yes = はい(&Y)
gui-stock-yes-plain = はい
gui-stock-no = いいえ(&N)
gui-stock-no-plain = いいえ
gui-stock-close = 閉じる(&C)
gui-stock-close-plain = 閉じる
