# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = 이 모드를 사용하려면 최신 버전의 Loadstone이 필요합니다. Loadstone을 업데이트한 후 다시 시도하세요.

## Loadstone settings

pref-language = 언어
pref-language-description = Loadstone과 번역된 모드를 표시할 언어입니다.
language-system = 시스템 기본값
pref-accounts = 계정
pref-accounts-description = 비공개 리포지토리에서 모드를 다운로드할 때 사용하는 로그인 정보입니다.
pref-account-rules = 계정 규칙
pref-account-rules-description = 리포지토리 또는 소유자별로 사용할 계정입니다.
pref-try-other-accounts = 다운로드가 거부되면 내 다른 계정으로 시도
pref-try-other-accounts-description = 리포지토리를 찾을 수 없거나 액세스가 거부되면, 포기하기 전에 해당 사이트의 다른 계정으로 시도합니다.
pref-tester-passwords = 테스터 암호
pref-tester-passwords-description = 레지스트리 전체 또는 개별 모드에 대해 테스터 전용 모드와 베타 버전을 사용할 수 있게 합니다. 테스터 암호 버튼에서 설정합니다.
pref-download-account = 다운로드 계정
pref-download-account-description = 이 모드를 다운로드할 때 사용하는 계정입니다. 자동을 선택하면 계정 규칙과 기본 계정을 사용합니다.
pref-download-account-automatic = 자동(계정 규칙, 그다음 기본 계정)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = Loadstone 설정(&L)...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = 비공개 리포지토리용 계정 및 Loadstone 옵션
gui-menu-exit = 끝내기(&X)
# Menu bar title.
gui-menu-tools = 도구(&T)
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = 작업이 아직 실행 중입니다. 지금 닫으면 작업이 완료되지 않을 수 있습니다. 그래도 닫으시겠습니까?
gui-close-while-running-title = 작업 진행 중
# Status bar text while a standalone installer loads its mod.
gui-status-loading = 불러오는 중...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = 작업 중 문제 발생
gui-button-retry = 다시 시도(&R)
gui-button-skip = 건너뛰기(&S)
gui-button-cancel-problem = 취소(&C)
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = 설치 옵션

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title }(코어 { $version })
# Label of the list of mods.
gui-catalog-mods-label = 모드(&M):
# Button that opens the selected mod's page.
gui-button-details = 자세히(&D)
gui-button-refresh = 새로 고침(&R)
gui-button-loadstone-settings = Loadstone 설정(&G)...
gui-status-fetching-catalog = 모드 카탈로그를 가져오는 중...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = 모드 목록을 불러오는 중...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = 모드 목록을 불러올 수 없습니다. 다시 시도하려면 새로 고침을 누르세요.
gui-status-catalog-failed = 카탈로그를 가져오지 못했습니다.
gui-catalog-error-title = 모드 카탈로그를 불러올 수 없음
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = 사용 가능한 모드가 없습니다.
gui-status-catalog-loaded = 카탈로그를 불러왔습니다. 모드 { $count }개.

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = { $mod_id } 불러오는 중...
gui-status-mod-load-failed = 모드 페이지를 불러올 수 없습니다.
gui-mod-error-title = 모드를 불러올 수 없음
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = 관리할 게임 사본(&C):
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = 관리할 { $game } 사본(&C):
gui-button-back = 모드 목록으로 돌아가기(&B)
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }(제작자: { $authors })
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = 게임 폴더(&G):
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = { $game } 폴더(&G):
gui-button-browse = 찾아보기(&W)...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = 게임 폴더 선택
gui-browse-game-prompt-named = { $game } 폴더 선택
gui-description-label = 설명:
# Label of the log where operations report their progress.
gui-activity-label = 활동:
gui-button-update = 업데이트(&U)
gui-button-install = 설치(&I)
gui-select-folder-first = 먼저 찾아보기를 사용해 게임 폴더를 선택하세요.
gui-button-install-from-file = 파일에서 설치(&F)...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = 모드의 loadstone-release.json 파일 선택
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON 파일 (*.json)|*.json|모든 파일 (*.*)|*.*
gui-button-uninstall = 제거(&N)
gui-button-launch = 게임 실행(&L)
# Description of the Launch game button, read when it gets focus.
gui-launch-description = 모드를 불러온 상태로 게임을 시작합니다.
gui-launch-unavailable-description = 이 사본에 모드를 설치하면 사용할 수 있습니다.
gui-button-change-options = 설치 옵션 변경(&O)...
gui-change-options-description = 모드의 설치 질문을 다시 묻고, 그 답변으로 최신 버전을 다시 설치합니다.
gui-button-settings = 설정(&S)...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = 작업 중... { $percent }%
gui-status-fetching-releases = 릴리스 목록을 가져오는 중...
# $error is an error message.
gui-release-list-error = 릴리스 목록을 가져올 수 없습니다: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = 대신 최신 릴리스를 설치하시겠습니까?
gui-release-list-error-title = 릴리스 목록을 사용할 수 없음
gui-no-releases = 이 모드의 리포지토리에는 아직 릴리스가 없습니다.
gui-no-releases-title = 릴리스 없음
gui-choose-version = 설치할 버전을 선택하세요.
gui-choose-version-title = 버전 선택
gui-confirm-uninstall = { $name } 모드를 제거하시겠습니까?
gui-confirm-uninstall-title = 제거 확인
gui-status-working = 작업 중...
gui-status-op-failed = 작업이 실패했습니다.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = 실행할 수 없음
gui-op-failed-title = 작업 실패
# Title of the message shown when an operation finished.
gui-op-done-title = 완료

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = 새 버전을 사용할 수 있습니다: { $app } { $version }(현재 버전: { $current }). 지금 업데이트하고 다시 시작하시겠습니까?
gui-self-update-title = 업데이트 사용 가능
gui-status-downloading-update = 업데이트를 다운로드하는 중...
gui-status-update-failed = 업데이트에 실패했습니다.
gui-update-failed-title = 업데이트 실패
gui-status-update-installed = 업데이트를 설치했습니다.
gui-update-installed = 업데이트를 설치했습니다. 이제 앱이 다시 시작됩니다.
gui-update-installed-title = 업데이트 설치됨

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Loadstone 설정을 사용할 수 없습니다: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = { $name } 설정
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = 모드 옵션
gui-mod-options-after-install = 모드 옵션은 모드를 설치한 후에 사용할 수 있습니다.
gui-status-setting-saved = 설정을 저장했습니다.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = 설정을 저장했습니다. { $note }
gui-setting-not-changed-title = 설정이 변경되지 않음
gui-status-no-settings-changed = 변경된 설정이 없습니다.

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone 설정
gui-accounts-label = 계정(&A):
gui-accounts-description = 비공개 리포지토리에서 모드를 다운로드할 때 사용하는 로그인 정보입니다.
gui-button-sign-in = 로그인(&I)...
gui-button-add-token = 토큰 추가(&T)...
gui-button-remove-account = 계정 제거(&R)
gui-button-set-default = 기본 계정으로 설정(&D)
# "gh auth token" is a command, keep it.
gui-add-token-description = 이미 가지고 있는 토큰으로 계정을 추가합니다. 예를 들어 GitHub CLI의 gh auth token 명령으로 얻은 토큰을 사용할 수 있습니다.
gui-rules-label = 계정 규칙(&U):
gui-rules-description = 리포지토리별 또는 소유자의 모든 리포지토리에 사용할 계정입니다. 규칙이 없으면 기본 계정을 사용합니다.
gui-button-add-rule = 규칙 추가(&E)...
gui-button-remove-rule = 규칙 제거(&V)
gui-button-tester-password = 테스터 암호(&P)...
gui-tester-password-description = 비공개 테스터용: 받은 암호를 입력하면 테스터 전용 모드가 표시되고 베타 버전을 받을 수 있습니다. 암호는 여러 개 추가할 수 있습니다. 비워 두면 테스트를 중단합니다.
gui-tester-password-prompt-saved = 저장된 테스터 암호가 있습니다. 암호를 추가하려면 다른 암호를 입력하고, 모든 암호를 삭제하고 테스트를 중단하려면 비워 두세요.
gui-tester-password-prompt = 받은 테스터 암호를 입력하세요.
gui-tester-password-title = 테스터 암호
gui-tester-password-not-saved-title = 테스터 암호가 저장되지 않음
gui-button-close = 닫기(&C)
gui-accounts-unavailable-title = 계정을 사용할 수 없음
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $site }의 { $username }, 기본 계정
    [missing] { $account }, { $site }의 { $username }, 토큰 없음(다시 로그인하세요)
    [default-missing] { $account }, { $site }의 { $username }, 기본 계정, 토큰 없음(다시 로그인하세요)
   *[none] { $account }, { $site }의 { $username }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = 계정이 없습니다. 로그인을 사용해 계정을 추가하세요.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern }: { $account } 사용
# Placeholder line when there are no account rules.
gui-rules-empty = 규칙이 없습니다.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = { $site } 토큰을 붙여 넣으세요. 토큰은 { $site }에서 확인한 후 Windows 자격 증명 관리자에 저장됩니다.
gui-add-token-title = 토큰 추가
gui-status-account-added = { $account } 계정을 추가했습니다.
gui-token-not-added-title = 토큰이 추가되지 않음
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = { $account } 계정을 제거하시겠습니까? Loadstone에서 이 계정의 토큰과 이 계정을 사용하는 모든 규칙이 삭제됩니다. Loadstone의 액세스 권한도 취소하려면 { $site } 설정의 Applications 페이지를 이용하세요.
gui-remove-account-title = 계정 제거
gui-account-not-removed-title = 계정이 제거되지 않음
gui-default-not-changed-title = 기본 계정이 변경되지 않음
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = 리포지토리(github:owner/repo) 또는 소유자의 모든 리포지토리(github:owner/*):
gui-add-rule-title = 계정 규칙 추가
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account }({ $username })
gui-add-rule-account-prompt = 어떤 계정을 사용하시겠습니까?
gui-rule-not-added-title = 규칙이 추가되지 않음
gui-rule-not-removed-title = 규칙이 제거되지 않음

## Signing in

gui-sign-in-no-sites = 로그인을 지원하는 사이트가 없습니다.
gui-sign-in-title = 로그인
gui-sign-in-which-site = 어느 사이트에 로그인하시겠습니까?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = { $site }에 로그인
gui-sign-in-requesting = { $site }에 로그인 코드를 요청하는 중...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = 로그인 코드(&C):
gui-button-copy-code = 코드 복사(&P)
gui-button-open-sign-in-page = { $site } 로그인 페이지 열기(&O)
gui-button-cancel = 취소
gui-sign-in-code-copied = 코드를 복사했습니다. 로그인 페이지를 열고 코드를 붙여 넣으세요.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = { $url } 페이지를 열고 아래 코드를 입력한 다음 Loadstone을 승인하세요. 완료되면 이 창은 자동으로 닫힙니다.
gui-sign-in-code-expired = 로그인 코드를 입력하기 전에 만료되었습니다. 처음부터 다시 시작하세요.
# $account is the account's name.
gui-status-signed-in = { $account } 계정으로 로그인했습니다.
gui-signed-in = { $site }에 { $account } 계정으로 로그인했습니다.
gui-signed-in-title = 로그인됨
gui-sign-in-failed-title = 로그인 실패
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = 액세스 권한이 있는 계정으로 지금 로그인하시겠습니까?
gui-offer-sign-in-title = 계속하려면 로그인

## Startup

gui-startup-error-title = Loadstone 시작 오류

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone 모드 관리자

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = { $version } 설치됨
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = { $version } 설치됨({ $channel } 채널)
page-catalog-not-installed = 설치 안 됨
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = 사본 { $count }개에 { $version } 설치됨
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = 사본 { $count }개에 설치됨(버전이 서로 다름)
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Loadstone 외부에서 설치됨
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = 설치되어 있지만, 구성된 레지스트리에 더 이상 등록되어 있지 않습니다.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name }(테스터 미리 보기)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = 구성된 레지스트리가 없습니다. 설치된 모드만 표시합니다.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = 이 컴퓨터에서 사용할 수 없는 모드 { $count }개를 숨겼습니다.
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = 레지스트리를 불러올 수 없습니다: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = 구성된 레지스트리에서 찾을 수 없습니다: { $error }
page-note-no-release-metadata = 최신 공개 릴리스에 아직 Loadstone 메타데이터가 없어서 최신 버전을 확인할 수 없습니다.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = 참고: { $game }의 사본들은 하나의 모드 폴더를 공유합니다. 한 사본에서 모드를 설치하거나 제거하면 다른 사본에도 영향을 줍니다. 사본마다 따로 있는 것은 모드 로더뿐입니다.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = { $name } 필요(자동으로 설치됨, 현재 버전 { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = { $name } 필요(자동으로 설치됨).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = { $version } 설치됨(개발 채널).
page-status-up-to-date = 최신 상태입니다(버전 { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = 최신 상태입니다(버전 { $version }, 최신 릴리스 { $latest }보다 새 버전).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = 업데이트 사용 가능: 현재 { $version }, 최신 { $latest }.
page-status-installed = { $version } 설치됨.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Loadstone 외부에서 설치됨(버전 알 수 없음). Loadstone에서 이 사본을 관리하려면 { $latest } 버전을 설치하세요.
page-status-foreign = Loadstone 외부에서 설치됨(버전 알 수 없음). Loadstone에서 이 사본을 관리하려면 설치하세요.
page-status-ready = { $latest } 버전을 설치할 준비가 되었습니다.
page-status-not-installed = 설치 안 됨.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = 이 컴퓨터에서는 사용할 수 없습니다. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = { $latest } 버전을 설치할 준비가 되었습니다. 게임 폴더를 찾을 수 없습니다. 찾아보기를 사용해 선택하세요.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = 설치 안 됨. 게임 폴더를 찾을 수 없습니다. 찾아보기를 사용해 선택하세요.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = 찾아보기를 사용해 폴더를 선택하세요. 이 컴퓨터에서는 사용할 수 없습니다. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = 찾아보기를 사용해 폴더를 선택하세요. { $latest } 버전을 설치할 준비가 되었습니다. 게임 폴더를 찾을 수 없습니다. 찾아보기를 사용해 선택하세요.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = 찾아보기를 사용해 폴더를 선택하세요. 설치 안 됨. 게임 폴더를 찾을 수 없습니다. 찾아보기를 사용해 선택하세요.
# Shown with a mod's settings before it is installed.
page-settings-after-install = 설정은 설치한 후에 편집할 수 있습니다.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = { $distribution } 사본, { $version } 설치됨, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = { $distribution } 사본, Loadstone 외부에서 설치됨, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = { $distribution } 사본, 설치 안 됨, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = { $folder }의 사본, { $version } 설치됨
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = { $folder }의 사본, Loadstone 외부에서 설치됨
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = { $folder }의 사본, 설치 안 됨
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = 아직 사본을 찾지 못했습니다. 찾아보기를 사용해 게임 폴더를 선택하세요.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = 다른 폴더...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = 독립 실행형
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = { $channel } 채널({ $branch } 브랜치의 최신 버전)
# A development channel. $channel is the channel id ("dev").
page-channel-development = { $channel } 채널(개발 빌드)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag }(사전 릴리스)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title }(사전 릴리스)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = { $action } 작업을 완료했습니다.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = { $file } 다운로드 중...
page-self-update-installed = 업데이트를 확인하고 설치했습니다.
page-tester-passwords-removed = 테스터 암호를 제거했습니다. 테스터 전용 모드와 베타 버전이 다시 숨겨집니다.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label }({ $site }의 { $username })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = 구성된 레지스트리가 없습니다
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = "{ $id }"의 소스 리포지토리를 알 수 없습니다
# $id is a mod id.
page-error-not-installed-no-registries = "{ $id }" 모드가 설치되어 있지 않으며 구성된 레지스트리도 없습니다
# $id is a mod id.
page-error-not-installed-unresolved = "{ $id }" 모드가 설치되어 있지 않으며 찾을 수도 없습니다
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = "{ $id }" 모드가 설치되어 있지 않으며 찾을 수도 없습니다: { $error }
page-error-tester-password-wrong = 이 암호는 어떤 레지스트리나 모드의 테스터 암호도 아닙니다.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = 계정 정보 저장소를 사용할 수 없습니다
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = 숫자가 아닙니다: "{ $value }"
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = 유한한 숫자가 아닙니다

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = { $id }의 파일 해시가 일치하지 않습니다. 예상 값: { $expected }, 실제 값: { $actual }. 설치하지 않습니다.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = { $id }({ $artifact })의 파일 해시가 일치하지 않습니다. 예상 값: { $expected }, 실제 값: { $actual }. 설치하지 않습니다.
engine-hash-verified = 파일 해시를 확인했습니다.
engine-hash-none = 이 소스에는 확인할 해시가 없습니다(로컬 또는 개발 버전 설치).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = 이전에 설치된 { $version } 버전을 제거하는 중입니다(파일 { $count }개).
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = 경고: { $message }
# { $error } is a system error message.
engine-warning-record-originals = 경고: 복원해야 할 원본 파일 목록을 기록할 수 없습니다: { $error }
engine-install-failed-rolling-back = 설치에 실패했습니다. 지금까지 쓴 파일을 제거하는 중입니다.
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } 설치를 완료했습니다.
# The user answered no to the release notes or development build question.
engine-install-cancelled = 설치가 취소되었습니다.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = 이 모드에는 "{ $id }" 설치 옵션이 없습니다(옵션: { $options })
engine-option-unknown-none = 이 모드에는 "{ $id }" 설치 옵션이 없습니다(옵션: 없음)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = { $option }에 "{ $value }" 선택 항목이 없습니다(선택 항목: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = 취소됨: 선택하지 않음

## Mod settings

# { $label } is the setting's name.
engine-setting-default = "{ $label }" 설정은 기본값으로 시작합니다. 나중에 settings 명령으로 변경할 수 있습니다.
# { $path } is the settings file.
engine-settings-written = { $path }에 설정을 저장했습니다.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = { $id }에는 "{ $action }" 작업이 없습니다(사용 가능: { $available })
engine-action-unknown-none = { $id }에는 "{ $action }" 작업이 없습니다(사용 가능: 없음)
# { $label } is the action's name, as on its button.
engine-action-unavailable = "{ $label }" 작업은 지금 사용할 수 없습니다(전제 조건이 충족되지 않음)
engine-action-running = "{ $label }" 실행 중...
engine-action-finished = "{ $label }" 완료.
engine-no-launch-steps = { $id }에는 이 플랫폼용 실행 단계가 없습니다
# Summary after starting the game with a mod.
engine-launched = { $id }: 게임을 실행했습니다.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link }: 개발용 작업 폴더로 연결되는 링크입니다. 이 링크를 통해서는 파일을 수정하거나 제거하지 않습니다. 이곳을 Loadstone으로 관리하려면 먼저 링크를 제거하세요.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = { $path } 항목을 제거하지 않음: 모드 폴더 밖에 있습니다.
engine-legacy-link = { $path } 항목을 제거하지 않음: 링크를 통해 접근하는 위치입니다.
engine-legacy-shared = { $path } 항목을 제거하지 않음: 설치된 다른 패키지가 사용 중입니다.
engine-legacy-removed = 남아 있던 { $path } 항목을 제거했습니다
# { $error } is a system error message.
engine-legacy-remove-failed = 경고: { $path } 항목을 제거할 수 없습니다: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = 필요한 파일을 찾을 수 없습니다: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = { $step } 단계의 요구 사항이 충족되지 않았습니다.
engine-step-skipped = { $step } 단계를 건너뛰었습니다.
engine-cancelled-at-step = { $step } 단계에서 취소됨
engine-extracting = 파일 압축을 푸는 중...
engine-placed-files = 파일 { $count }개를 배치했습니다.
engine-kept-existing = 기존 { $path } 파일을 유지했습니다(더 최신일 수 있어 덮어쓰지 않음).
engine-file-created = { $path } 파일을 만들고 업데이트했습니다.
engine-file-updated = { $path } 파일을 업데이트했습니다.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = 취소됨: "{ $prompt }"에 대한 폴더를 선택하지 않음
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = 클립보드에 복사했습니다: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = 아키텍처 { $count }개를 { $file } 파일 하나로 합쳤습니다.
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = 실행할 수 없음: { $path } 파일이 없습니다
engine-program-start-failed = { $path } 프로그램을 시작하지 못했습니다
engine-program-started = { $path } 프로그램을 시작했습니다.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = { $url } 링크를 열지 못했습니다
engine-url-opened = { $url } 링크를 열었습니다.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = 다음 모드에 아직 { $id } 항목이 필요합니다: { $dependents }. 먼저 해당 모드를 제거하세요.
engine-removing-files = 파일 { $count }개를 제거하는 중입니다.
engine-purge-question = 저장된 설정과 기본 설정도 제거하시겠습니까?
engine-purge-done = 저장된 설정을 제거했습니다.
engine-dependency-unneeded = 설치된 모드 중 더 이상 { $id } 항목이 필요한 모드가 없습니다. 이 항목도 제거할 수 있습니다.
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } 제거를 완료했습니다.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = { $path }에 이미 보관된 원본을 사용합니다.
engine-originals-kept = 원본 게임 파일 { $count }개를 백업했습니다.
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = 경고: 지금은 원본 { $path } 파일을 복원할 수 없습니다({ $error }). 이 모드를 업데이트하거나 제거할 때 복원됩니다.
engine-original-restored = 원본 { $path } 파일을 복원했습니다.
# { $backup } is where the kept original should have been.
engine-original-missing = 경고: { $path }의 원본이 없습니다({ $backup }). 파일을 그대로 둡니다.
engine-original-changed = 이 모드를 설치한 후 { $path } 파일이 변경되었습니다(게임이 업데이트되었을 수 있음). 새 파일을 유지합니다.
engine-originals-restored = 원본 게임 파일 { $count }개를 복원했습니다.
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = 원본 게임 파일 { $count }개를 되돌릴 수 없습니다. 게임을 닫고 다시 시도하세요.

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = { $path }에 있는 { $distribution } 사본을 업데이트하는 중입니다.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path }({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = "{ $id }" 모드가 { $game }의 여러 사본에 설치되어 있습니다: { $copies }. 업데이트할 사본을 --game-dir 옵션으로 지정하세요.
engine-many-copies = "{ $id }" 모드가 { $game }의 여러 사본에 설치되어 있습니다: { $copies }. 대상 사본을 --game-dir 옵션으로 지정하세요.
engine-not-game-folder = { $path } 폴더는 { $game } 폴더가 아닌 것 같습니다(예상한 파일이 하나도 없음)
engine-game-found = { $path }에서 { $game } 게임을 찾았습니다
engine-game-not-found = { $game } 게임을 자동으로 찾을 수 없습니다.
# Title of the folder picker.
engine-game-where = { $game } 게임은 어디에 설치되어 있습니까?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = { $game } 게임을 자동으로 찾을 수 없습니다. --game-dir 옵션을 지정하거나 폴더를 선택하세요
# { $path } is a game folder.
engine-not-installed-copy = "{ $id }" 모드가 { $path }에 있는 { $game } 사본에 설치되어 있지 않습니다
engine-not-installed = "{ $id }" 모드가 { $game } 게임에 설치되어 있지 않습니다

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = 이 컴퓨터에는 { $name } 모드를 설치할 수 없습니다. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = { $game }의 { $distribution } 사본은 지원되지 않습니다. { $reason }
engine-distribution-untested = 참고: { $game }의 { $distribution } 사본에서는 이 모드가 테스트되지 않았습니다.
engine-no-matching-artifact = 이 플랫폼, 아키텍처, 스토어에 맞는 릴리스 파일이 없습니다
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = 이 모드는 { $platform }에서만 사용할 수 있습니다.
engine-platform-only-two = 이 모드는 { $first } 및 { $second }에서만 사용할 수 있습니다.
engine-platform-only-three = 이 모드는 { $first }, { $second }, { $third }에서만 사용할 수 있습니다.
engine-platform-needs-apple-silicon = { $platform }에서 이 모드를 사용하려면 Apple 실리콘 프로세서가 필요합니다.
engine-platform-needs-arm = { $platform }에서 이 모드를 사용하려면 ARM 프로세서가 필요합니다.
engine-platform-needs-x64 = { $platform }에서 이 모드를 사용하려면 Intel 또는 AMD 프로세서가 필요합니다.
engine-game-platform-unsupported = 여기서는 { $platform }의 { $game } 게임이 지원되지 않습니다.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } 모드가 최신 상태입니다({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } 모드가 최신 상태입니다({ $installed } 버전이 최신 릴리스 { $latest }보다 새 버전임).
engine-installed-newer = 설치된 { $name } { $installed } 버전이 현재 사용할 수 있는 최신 릴리스({ $latest })보다 새 버전입니다. 아무것도 변경하지 않았습니다. 이전 버전을 설치하려면 해당 버전을 직접 선택하세요.
# { $from } and { $to } are versions.
engine-updating = { $name } 모드를 업데이트하는 중: { $from }에서 { $to } 버전으로.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    { $branch } 브랜치의 최신 커밋({ $version })에서 { $name } 모드를 설치하시겠습니까?

    개발 빌드는 해시로 고정되지 않으므로 리포지토리의 현재 내용을 신뢰해야 합니다.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    { $name } { $version } 릴리스 정보:

    { $notes }

    지금 설치하시겠습니까?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = { $source }에서 릴리스 { $tag } 정보를 가져오는 중...
engine-fetching-latest = { $source }에서 최신 릴리스 정보를 가져오는 중...
engine-using-local-artifact = 로컬 파일 { $path } 사용
# { $file } is a download's file name.
engine-using-cached = 이미 다운로드한 { $file } 파일을 사용합니다.
engine-downloading = { $file } 다운로드 중...
engine-dependency-present = 종속성 { $id } { $version } 버전이 이미 설치되어 있습니다.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = 종속성 { $name } { $version } 설치 중({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = 토큰을 입력하지 않았습니다
core-sign-in-cancelled = 로그인이 취소되었습니다.
core-sign-in-expired = 로그인 코드를 입력하기 전에 만료되었습니다. 처음부터 다시 시작하세요.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = 올바른 소스(github:owner/repo) 또는 소유자 와일드카드(github:owner/*)가 아닙니다: "{ $pattern }"
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = 시스템 자격 증명 저장소에 토큰을 저장할 수 없습니다
core-secrets-remove-failed = 시스템 자격 증명 저장소에서 토큰을 제거할 수 없습니다

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = { $source }의 릴리스 { $tag }에 { $file } 파일이 없습니다
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = { $source }의 최신 릴리스에 { $file } 파일이 없습니다
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = 릴리스 { $tag }에 loadstone-release.json 파일이 없습니다(또는 접근할 수 없음)
core-github-sign-in-cancelled = GitHub에서 로그인이 취소되었습니다.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub에서 로그인을 거부했습니다: { $details }
core-github-sign-in-refused-no-details = GitHub에서 로그인을 거부했습니다: 자세한 정보 없음
core-github-token-rejected = GitHub에서 토큰을 허용하지 않았습니다

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site }에서는 로그인을 지원하지 않습니다
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = 올바른 { $format } 형식의 소스가 아닙니다: "{ $source }"
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } 항목을 찾을 수 없습니다. 비공개 리포지토리라면 액세스 권한이 있는 계정으로 로그인하거나(Loadstone 설정) GH_TOKEN을 설정하세요
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = { $account }의 토큰이 거부되었습니다. 만료되었거나 취소되었을 수 있습니다
core-source-token-unreachable = { $account }의 토큰으로는 { $source }에 접근할 수 없습니다

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = { $url } 다운로드에서 HTTP { $status } 응답을 받았습니다
core-fetch-request-failed = 요청 실패: { $url }
core-fetch-download-failed = 다운로드 실패: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = 읽기 오류
core-fetch-read-error-download = 다운로드 중 읽기 오류

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = 이 플랫폼과 스토어에 적용되는 압축 해제 방법이 없습니다
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } 폴더는 개발용 작업 폴더로 연결되는 링크입니다. 대신 git으로 해당 작업 폴더를 업데이트하거나, 설치하기 전에 링크를 제거하세요.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = 이 압축 파일에는 필요한 내용이 없습니다(압축 해제 방법과 일치하는 항목이 없음)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = "{ $source }" 레지스트리는 { $formats } 형식도 아니고 기존 폴더도 아닙니다
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source }에 loadstone-packages 폴더가 없습니다
# $error is the reason the download failed.
core-registry-using-cache = { $source } 레지스트리를 새로 고칠 수 없습니다({ $error }). 캐시된 데이터를 사용합니다.
core-registry-fetch-failed = { $source } 레지스트리를 가져오지 못했습니다
# $id is a mod's id.
core-registry-package-not-found = 어느 레지스트리에서도 "{ $id }" 패키지를 찾을 수 없습니다

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = "{ $key }" 설정은 부울 값입니다. true 또는 false를 사용하세요
core-setting-not-number = "{ $key }" 설정에는 숫자가 필요합니다
core-setting-too-small = "{ $key }" 설정은 { $min } 이상이어야 합니다
core-setting-too-large = "{ $key }" 설정은 { $max } 이하여야 합니다
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = "{ $key }" 설정은 다음 중 하나여야 합니다: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = 레지스트리의 모드에 대한 테스터 액세스가 활성화되었습니다. 테스터 전용 모드가 목록에 표시되고, 설치 및 업데이트 시 베타 버전을 받습니다.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = 레지스트리의 모드와 { $mods }에 대한 테스터 액세스가 활성화되었습니다. 테스터 전용 모드가 목록에 표시되고, 설치 및 업데이트 시 베타 버전을 받습니다.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = { $mods }에 대한 테스터 액세스가 활성화되었습니다. 테스터 전용 모드가 목록에 표시되고, 설치 및 업데이트 시 베타 버전을 받습니다.
core-tester-save-failed = 테스터 암호를 저장하지 못했습니다
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = 릴리스 { $tag }에 사용할 수 있는 Loadstone 메타데이터가 없습니다({ $error }). 최신 안정 릴리스를 사용합니다.
core-tester-beta-lookup-failed = 베타 버전을 확인할 수 없습니다({ $error }). 최신 안정 릴리스를 사용합니다.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = 다운로드한 업데이트의 해시 검증에 실패했습니다(예상 값: { $expected }, 실제 값: { $actual }). 설치하지 않았습니다
core-update-translocated = macOS가 이 앱을 임시 읽기 전용 복사본에서 실행하고 있어서 앱이 스스로 업데이트할 수 없습니다. 앱을 응용 프로그램 폴더로 옮긴 다음 그곳에서 열고 다시 업데이트하세요.
core-update-on-disk-image = 이 앱이 디스크 이미지에서 실행되고 있어서 스스로 업데이트할 수 없습니다. 앱을 응용 프로그램 폴더에 복사한 다음 그곳에서 열고 다시 업데이트하세요.
# $path is the folder the app is in.
core-update-no-write = { $path }에 쓸 수 없어서(권한이 없을 수 있음) 앱이 스스로 업데이트할 수 없습니다. 대신 릴리스 페이지에서 새 버전을 다운로드하세요.
core-update-no-staging = { $path }에 쓸 수 없습니다(권한이 없을 수 있음). 대신 릴리스 페이지에서 새 버전을 다운로드하세요
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = 업데이트가 다른 앱입니다({ $got }, 예상 값: { $expected }). 설치하지 않았습니다
core-update-move-aside-app = 현재 앱을 옮길 수 없습니다
core-update-move-in-app = 새 앱을 제자리로 옮길 수 없습니다
core-update-move-aside-exe = 현재 실행 파일을 옮길 수 없습니다
core-update-move-in-exe = 새 실행 파일을 제자리로 옮길 수 없습니다

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = 확인(&O)
gui-stock-ok-plain = 확인
gui-stock-cancel = 취소(&C)
gui-stock-cancel-plain = 취소
gui-stock-yes = 예(&Y)
gui-stock-yes-plain = 예
gui-stock-no = 아니요(&N)
gui-stock-no-plain = 아니요
gui-stock-close = 닫기(&C)
gui-stock-close-plain = 닫기
