# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Bu mod, Loadstone'un daha yeni bir sürümünü gerektiriyor. Loadstone'u güncelleyip yeniden deneyin.

## Loadstone settings

pref-language = Dil
pref-language-description = Loadstone ve çevrilmiş modların gösterileceği dil.
language-system = Sistem varsayılanı
pref-accounts = Hesaplar
pref-accounts-description = Özel depolardan mod indirmek için kullanılan oturum açma bilgileri.
pref-account-rules = Hesap kuralları
pref-account-rules-description = Bir depo veya sahip için hangi hesabın kullanılacağı.
pref-try-other-accounts = İndirme reddedildiğinde diğer hesaplarımı dene
pref-try-other-accounts-description = Bir depo bulunamazsa veya erişim reddedilirse Loadstone, vazgeçmeden önce o sitedeki diğer hesapları dener.
pref-tester-passwords = Test kullanıcısı parolaları
pref-tester-passwords-description = Bir kayıt defterinin tamamı veya tek tek modlar için yalnızca test kullanıcılarına açık modların ve beta sürümlerin kilidini açar. Test kullanıcısı parolası düğmesiyle ayarlanır.
pref-download-account = İndirme hesabı
pref-download-account-description = Bu modu indirmek için kullanılan hesap. Otomatik seçenek, hesap kurallarınızı ve varsayılan hesabınızı kullanır.
pref-download-account-automatic = Otomatik (önce hesap kuralları, sonra varsayılan hesap)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Loadstone ayarları...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Özel depolar için hesaplar ve Loadstone seçenekleri
gui-menu-exit = Çı&kış
# Menu bar title.
gui-menu-tools = &Araçlar
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Bir işlem hâlâ devam ediyor. Şimdi kapatırsanız işlem yarım kalabilir. Yine de kapatılsın mı?
gui-close-while-running-title = İşlem devam ediyor
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Yükleniyor...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = İşlem sırasında sorun oluştu
gui-button-retry = &Yeniden dene
gui-button-skip = &Atla
gui-button-cancel-problem = İ&ptal
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Yükleme seçenekleri

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (çekirdek { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Modlar:
# Button that opens the selected mod's page.
gui-button-details = &Ayrıntılar
gui-button-refresh = &Yenile
gui-button-loadstone-settings = &Loadstone ayarları...
gui-status-fetching-catalog = Mod kataloğu alınıyor...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Mod listesi yükleniyor...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Mod listesi yüklenemedi. Yeniden denemek için Yenile düğmesine basın.
gui-status-catalog-failed = Katalog alınamadı.
gui-catalog-error-title = Mod kataloğu yüklenemedi
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Kullanılabilir mod yok.
gui-status-catalog-loaded = { $count ->
    [one] Katalog yüklendi: { $count } mod.
   *[other] Katalog yüklendi: { $count } mod.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = { $mod_id } yükleniyor...
gui-status-mod-load-failed = Mod sayfası yüklenemedi.
gui-mod-error-title = Mod yüklenemedi
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Yönetilecek oyun kopyası:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Yönetilecek { $game } kopyası:
gui-button-back = Mod &listesine dön
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }, geliştiren: { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = &Oyun klasörü:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = { $game } &klasörü:
gui-button-browse = &Gözat...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Oyun klasörünü seçin
gui-browse-game-prompt-named = { $game } klasörünü seçin
gui-description-label = Açıklama:
# Label of the log where operations report their progress.
gui-activity-label = Etkinlik günlüğü:
gui-button-update = Gü&ncelle
gui-button-install = &Yükle
gui-select-folder-first = Önce Gözat düğmesiyle oyun klasörünü seçin.
gui-button-install-from-file = &Dosyadan yükle...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Modun loadstone-release.json dosyasını seçin
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|JSON dosyaları (*.json)|*.json|Tüm dosyalar (*.*)|*.*
gui-button-uninstall = Kaldı&r
gui-button-launch = Oyunu &başlat
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Oyunu mod yüklenmiş olarak başlatır.
gui-launch-unavailable-description = Mod bu kopyaya yüklendikten sonra kullanılabilir.
gui-button-change-options = Yükleme &seçeneklerini değiştir...
gui-change-options-description = Modun yükleme sorularını yeniden sorar ve en son sürümü yanıtlarınızla yeniden yükler.
gui-button-settings = A&yarlar...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Çalışıyor... %{ $percent }
gui-status-fetching-releases = Yayın listesi alınıyor...
# $error is an error message.
gui-release-list-error = Yayın listesi alınamadı: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Bunun yerine en son yayın yüklensin mi?
gui-release-list-error-title = Yayın listesi kullanılamıyor
gui-no-releases = Bu modun deposunda henüz yayın yok.
gui-no-releases-title = Yayın yok
gui-choose-version = Yüklenecek sürümü seçin:
gui-choose-version-title = Sürüm seçin
gui-confirm-uninstall = { $name } modu kaldırılsın mı?
gui-confirm-uninstall-title = Kaldırmayı onaylayın
gui-status-working = Çalışıyor...
gui-status-op-failed = İşlem başarısız oldu.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Başlatılamıyor
gui-op-failed-title = İşlem başarısız
# Title of the message shown when an operation finished.
gui-op-done-title = Tamamlandı

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = { $app } için { $version } sürümü kullanılabilir (yüklü sürüm: { $current }). Şimdi güncellenip yeniden başlatılsın mı?
gui-self-update-title = Güncelleme var
gui-status-downloading-update = Güncelleme indiriliyor...
gui-status-update-failed = Güncelleme başarısız oldu.
gui-update-failed-title = Güncelleme başarısız
gui-status-update-installed = Güncelleme yüklendi.
gui-update-installed = Güncelleme yüklendi. Uygulama şimdi yeniden başlatılacak.
gui-update-installed-title = Güncelleme yüklendi

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Loadstone ayarları kullanılamıyor: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = { $name } Ayarları
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Mod seçenekleri
gui-mod-options-after-install = Modun seçenekleri, mod yüklendikten sonra kullanılabilir.
gui-status-setting-saved = Ayar kaydedildi.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Ayar kaydedildi. { $note }
gui-setting-not-changed-title = Ayar değiştirilmedi
gui-status-no-settings-changed = Hiçbir ayar değiştirilmedi.

## Loadstone settings dialog

gui-loadstone-settings-title = Loadstone ayarları
gui-accounts-label = &Hesaplar:
gui-accounts-description = Özel depolardan mod indirmek için kullanılan oturum açma bilgileri.
gui-button-sign-in = &Oturum aç...
gui-button-add-token = &Belirteç ekle...
gui-button-remove-account = Hesabı &kaldır
gui-button-set-default = &Varsayılan yap
# "gh auth token" is a command, keep it.
gui-add-token-description = Elinizdeki bir belirteçle hesap ekleyin; örneğin GitHub CLI aracının gh auth token komutuyla alınan bir belirteçle.
gui-rules-label = Hesap k&uralları:
gui-rules-description = Bir depo veya bir sahibin tüm depoları için hangi hesabın kullanılacağı. Kural yoksa varsayılan hesap kullanılır.
gui-button-add-rule = Kural &ekle...
gui-button-remove-rule = Kuralı ka&ldır
gui-button-tester-password = &Test kullanıcısı parolası...
gui-tester-password-description = Özel test kullanıcıları için: yalnızca test kullanıcılarına açık modları görmek ve beta sürümleri almak için size verilen parolayı girin. Birden fazla parola ekleyebilirsiniz. Testi bırakmak için alanı boş bırakın.
gui-tester-password-prompt-saved = Kaydedilmiş test kullanıcısı parolalarınız var. Eklemek için yeni bir parola girin veya hepsini unutup testi bırakmak için alanı boş bırakın.
gui-tester-password-prompt = Size verilen test kullanıcısı parolasını girin.
gui-tester-password-title = Test kullanıcısı parolası
gui-tester-password-not-saved-title = Test kullanıcısı parolası kaydedilmedi
gui-button-close = Ka&pat
gui-accounts-unavailable-title = Hesaplar kullanılamıyor
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $site } üzerinde { $username }, varsayılan
    [missing] { $account }, { $site } üzerinde { $username }, belirteç eksik (yeniden oturum açın)
    [default-missing] { $account }, { $site } üzerinde { $username }, varsayılan, belirteç eksik (yeniden oturum açın)
   *[none] { $account }, { $site } üzerinde { $username }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Hesap yok. Hesap eklemek için Oturum aç düğmesini kullanın.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } için kullanılan hesap: { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Kural yok.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Bir { $site } belirteci yapıştırın. Belirteç { $site } ile doğrulanır, ardından Windows Kimlik Bilgileri Yöneticisi'nde saklanır.
gui-add-token-title = Belirteç ekle
gui-status-account-added = Hesap eklendi: { $account }.
gui-token-not-added-title = Belirteç eklenmedi
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = { $account } hesabı kaldırılsın mı? Loadstone bu hesabın belirtecini ve onu kullanan tüm kuralları unutur. Loadstone'un erişimini de iptal etmek için { $site } ayarlarınızdaki Applications bölümünü kullanın.
gui-remove-account-title = Hesabı kaldır
gui-account-not-removed-title = Hesap kaldırılmadı
gui-default-not-changed-title = Varsayılan hesap değiştirilmedi
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Depo (github:owner/repo) veya bir sahibin tüm depoları (github:owner/*):
gui-add-rule-title = Hesap kuralı ekle
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Hangi hesap kullanılsın?
gui-rule-not-added-title = Kural eklenmedi
gui-rule-not-removed-title = Kural kaldırılmadı

## Signing in

gui-sign-in-no-sites = Oturum açmayı destekleyen site yok.
gui-sign-in-title = Oturum aç
gui-sign-in-which-site = Hangi sitede oturum açılsın?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Oturum aç: { $site }
gui-sign-in-requesting = { $site } üzerinden oturum açma kodu isteniyor...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = Oturum açma &kodu:
gui-button-copy-code = Kodu k&opyala
gui-button-open-sign-in-page = { $site } oturum açma sayfasını &aç
gui-button-cancel = İptal
gui-sign-in-code-copied = Kod kopyalandı. Oturum açma sayfasını açıp kodu oraya yapıştırın.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = { $url } adresini açın, aşağıdaki kodu girin ve Loadstone uygulamasına izin verin. İşiniz bitince bu pencere kendiliğinden kapanır.
gui-sign-in-code-expired = Oturum açma kodunun süresi, kod girilmeden doldu. Lütfen yeniden başlayın.
# $account is the account's name.
gui-status-signed-in = Oturum açıldı: { $account }.
gui-signed-in = { $site } üzerinde { $account } hesabıyla oturum açıldı.
gui-signed-in-title = Oturum açıldı
gui-sign-in-failed-title = Oturum açılamadı
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Buna erişebilen bir hesapla şimdi oturum açılsın mı?
gui-offer-sign-in-title = Devam etmek için oturum açın

## Startup

gui-startup-error-title = Loadstone başlatma hatası

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Loadstone Mod Yöneticisi

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = { $version } sürümü yüklü
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = { $version } sürümü yüklü ({ $channel } kanalı)
page-catalog-not-installed = Yüklü değil
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] { $version } sürümü { $count } kopyada yüklü
   *[other] { $version } sürümü { $count } kopyada yüklü
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] { $count } kopyada yüklü (sürümler farklı)
   *[other] { $count } kopyada yüklü (sürümler farklı)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Loadstone dışında yüklenmiş
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Yüklü, ancak yapılandırılmış kayıt defterlerinde artık listelenmiyor.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (test kullanıcısı önizlemesi)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Yapılandırılmış kayıt defteri yok; yalnızca yüklü modlar gösteriliyor.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] Bu bilgisayarda kullanılamayan { $count } mod gizlendi.
   *[other] Bu bilgisayarda kullanılamayan { $count } mod gizlendi.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Kayıt defterleri yüklenemedi: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Yapılandırılmış kayıt defterlerinde bulunamadı: { $error }
page-note-no-release-metadata = En son yayımlanan yayında henüz Loadstone meta verileri yok, bu nedenle en yeni sürüm belirlenemedi.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Not: { $game } kopyaları tek bir mod klasörünü paylaşır. Bir kopya için mod yüklemek veya kaldırmak diğerlerini de etkiler; her kopya için ayrı olan yalnızca mod yükleyicisidir.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Gerekli: { $name } (otomatik olarak yüklenir, şu anki sürüm: { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Gerekli: { $name } (otomatik olarak yüklenir).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = { $version } sürümü yüklü (geliştirme kanalı).
page-status-up-to-date = Güncel (sürüm { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Güncel (sürüm { $version }, en son yayın olan { $latest } sürümünden daha yeni).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Güncelleme var: { $version } sürümünden { $latest } sürümüne.
page-status-installed = { $version } sürümü yüklü.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Loadstone dışında yüklenmiş (sürüm bilinmiyor). Bu kopyayı Loadstone ile yönetmek için { $latest } sürümünü yükleyin.
page-status-foreign = Loadstone dışında yüklenmiş (sürüm bilinmiyor). Bu kopyayı Loadstone ile yönetmek için modu yükleyin.
page-status-ready = { $latest } sürümü yüklenmeye hazır.
page-status-not-installed = Yüklü değil.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Bu bilgisayarda kullanılamıyor. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = { $latest } sürümü yüklenmeye hazır. Oyun klasörü bulunamadı; Gözat düğmesiyle seçin.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Yüklü değil. Oyun klasörü bulunamadı; Gözat düğmesiyle seçin.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Klasörü Gözat düğmesiyle seçin. Bu bilgisayarda kullanılamıyor. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Klasörü Gözat düğmesiyle seçin. { $latest } sürümü yüklenmeye hazır. Oyun klasörü bulunamadı; Gözat düğmesiyle seçin.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Klasörü Gözat düğmesiyle seçin. Yüklü değil. Oyun klasörü bulunamadı; Gözat düğmesiyle seçin.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Ayarlar, yükleme sonrasında düzenlenebilir.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = { $distribution } kopyası, { $version } yüklü, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = { $distribution } kopyası, Loadstone dışında yüklenmiş, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = { $distribution } kopyası, yüklü değil, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Konumu { $folder } olan kopya, { $version } yüklü
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Konumu { $folder } olan kopya, Loadstone dışında yüklenmiş
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Konumu { $folder } olan kopya, yüklü değil
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Henüz kopya bulunamadı; oyun klasörünü Gözat düğmesiyle seçin.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Başka bir klasör...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Bağımsız
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = { $channel } kanalı ({ $branch } dalından en son derleme)
# A development channel. $channel is the channel id ("dev").
page-channel-development = { $channel } kanalı (geliştirme derlemesi)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (ön yayın)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (ön yayın)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Tamamlandı: { $action }.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = İndiriliyor: { $file }...
page-self-update-installed = Güncelleme doğrulandı ve yüklendi.
page-tester-passwords-removed = Test kullanıcısı parolaları kaldırıldı. Yalnızca test kullanıcılarına açık modlar ve beta sürümler yeniden gizlendi.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $site } üzerinde { $username })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = yapılandırılmış kayıt defteri yok
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = "{ $id }" için bilinen bir kaynak depo yok
# $id is a mod id.
page-error-not-installed-no-registries = "{ $id }" yüklü değil ve yapılandırılmış kayıt defteri yok
# $id is a mod id.
page-error-not-installed-unresolved = "{ $id }" yüklü değil ve bulunamadı
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = "{ $id }" yüklü değil ve bulunamadı: { $error }
page-error-tester-password-wrong = Bu, kayıt defterlerinizin veya modlarının hiçbiri için geçerli bir test kullanıcısı parolası değil.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = hesap deposu kullanılamıyor
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = "{ $value }" bir sayı değil
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = sonlu bir sayı değil

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = { $id } için dosya karma değeri uyuşmuyor: beklenen { $expected }, alınan { $actual }. Yükleme reddedildi.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = { $id } ({ $artifact }) için dosya karma değeri uyuşmuyor: beklenen { $expected }, alınan { $actual }. Yükleme reddedildi.
engine-hash-verified = Dosya karma değeri doğrulandı.
engine-hash-none = Bu kaynak için doğrulanacak karma değeri yok (yerel veya geliştirme yüklemesi).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Önceden yüklenen { $version } sürümü kaldırılıyor ({ $count } dosya).
   *[other] Önceden yüklenen { $version } sürümü kaldırılıyor ({ $count } dosya).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Uyarı: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Uyarı: geri yüklenmesi gereken orijinal dosyaların kaydı tutulamadı: { $error }
engine-install-failed-rolling-back = Yükleme başarısız oldu; şu ana kadar yazılan dosyalar kaldırılıyor.
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } yüklendi.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Yükleme iptal edildi.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = "{ $id }" bu modun bir yükleme seçeneği değil (seçenekler: { $options })
engine-option-unknown-none = "{ $id }" bu modun bir yükleme seçeneği değil (seçenek yok)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = "{ $value }", { $option } için geçerli bir seçim değil (seçimler: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = iptal edildi: seçim yapılmadı

## Mod settings

# { $label } is the setting's name.
engine-setting-default = "{ $label }" ayarı varsayılan değeriyle başlıyor; daha sonra ayarlar komutuyla değiştirebilirsiniz.
# { $path } is the settings file.
engine-settings-written = Ayarlar şuraya yazıldı: { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = "{ $action }", { $id } için bir eylem değil (kullanılabilir eylemler: { $available })
engine-action-unknown-none = "{ $action }", { $id } için bir eylem değil (kullanılabilir eylem yok)
# { $label } is the action's name, as on its button.
engine-action-unavailable = "{ $label }" şu anda kullanılamıyor (ön koşulu sağlanmıyor)
engine-action-running = Çalıştırılıyor: "{ $label }"...
engine-action-finished = Bitti: "{ $label }".
engine-no-launch-steps = { $id } bu platform için başlatma adımı tanımlamıyor
# Summary after starting the game with a mod.
engine-launched = { $id } başlatıldı.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } bir geliştirme çalışma kopyasına giden bağlantı; bu bağlantı üzerinden dosya değiştirme veya kaldırma reddedildi. Burada gerçekten yönetilen bir yükleme istiyorsanız önce bağlantıyı kaldırın.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = Kaldırılmıyor: { $path } (modun klasörlerinin dışında).
engine-legacy-link = Kaldırılmıyor: { $path } (bir bağlantı üzerinden erişiliyor).
engine-legacy-shared = Kaldırılmıyor: { $path } (yüklü başka bir paket kullanıyor).
engine-legacy-removed = Eski yüklemeden kalan öğe kaldırıldı: { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Uyarı: { $path } kaldırılamadı: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Gerekli dosya bulunamadı: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = { $step } adımının bir gereksinimi karşılanmıyor.
engine-step-skipped = { $step } adımı atlandı.
engine-cancelled-at-step = { $step } adımında iptal edildi
engine-extracting = Dosyalar ayıklanıyor...
engine-placed-files = { $count ->
    [one] { $count } dosya yerleştirildi.
   *[other] { $count } dosya yerleştirildi.
}
engine-kept-existing = Mevcut dosya korundu: { $path } (üzerine yazılmadı; daha yeni olabilir).
engine-file-created = Oluşturuldu ve güncellendi: { $path }.
engine-file-updated = Güncellendi: { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = iptal edildi: "{ $prompt }" için klasör seçilmedi
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Panoya kopyalandı: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] { $count } mimari tek dosyada birleştirildi: { $file }.
   *[other] { $count } mimari tek dosyada birleştirildi: { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = başlatılamıyor: { $path } bulunamadı
engine-program-start-failed = başlatılamadı: { $path }
engine-program-started = Başlatıldı: { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = açılamadı: { $url }
engine-url-opened = Açıldı: { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } şunlar için hâlâ gerekli: { $dependents }. Önce bunları kaldırın.
engine-removing-files = { $count ->
    [one] { $count } dosya kaldırılıyor.
   *[other] { $count } dosya kaldırılıyor.
}
engine-purge-question = Kaydedilmiş ayarlar ve tercihler de kaldırılsın mı?
engine-purge-done = Kaydedilmiş ayarlar kaldırıldı.
engine-dependency-unneeded = { $id } artık yüklü hiçbir mod için gerekli değil; bunu da kaldırabilirsiniz.
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } kaldırıldı.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Daha önce saklanan orijinal kullanılıyor: { $path }.
engine-originals-kept = { $count ->
    [one] { $count } orijinal oyun dosyasının bir kopyası saklandı.
   *[other] { $count } orijinal oyun dosyasının bir kopyası saklandı.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Uyarı: orijinal dosya şu anda geri yüklenemedi: { $path } ({ $error }). Bu mod güncellendiğinde veya kaldırıldığında geri konacak.
engine-original-restored = Orijinal dosya geri yüklendi: { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Uyarı: şu dosyanın orijinali eksik: { $path } ({ $backup }); dosya olduğu gibi bırakılıyor.
engine-original-changed = Şu dosya bu mod yüklendikten sonra değişmiş: { $path } (oyun güncellemesi mi?); daha yeni dosya korunuyor.
engine-originals-restored = { $count ->
    [one] { $count } orijinal oyun dosyası geri yüklendi.
   *[other] { $count } orijinal oyun dosyası geri yüklendi.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] { $count } orijinal oyun dosyası geri konamadı; oyunu kapatıp yeniden deneyin.
   *[other] { $count } orijinal oyun dosyası geri konamadı; oyunu kapatıp yeniden deneyin.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Konumu { $path } olan { $distribution } kopyası güncelleniyor.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = "{ $id }", { $game } oyununun birden fazla kopyasında yüklü: { $copies }. Hangi kopyanın güncelleneceğini belirtmek için --game-dir kullanın.
engine-many-copies = "{ $id }", { $game } oyununun birden fazla kopyasında yüklü: { $copies }. Hangi kopya olduğunu belirtmek için --game-dir kullanın.
engine-not-game-folder = { $path } bir { $game } klasörüne benzemiyor (beklenen dosyaların hiçbiri bulunamadı)
engine-game-found = { $game } bulundu: { $path }
engine-game-not-found = { $game } otomatik olarak bulunamadı.
# Title of the folder picker.
engine-game-where = { $game } nereye yüklü?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = { $game } otomatik olarak bulunamadı; --game-dir kullanın veya oyunun klasörünü seçin
# { $path } is a game folder.
engine-not-installed-copy = "{ $id }", konumu { $path } olan { $game } kopyasında yüklü değil
engine-not-installed = "{ $id }", { $game } için yüklü değil

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = { $name } bu bilgisayara yüklenemiyor. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = { $game } oyununun { $distribution } kopyası desteklenmiyor. { $reason }
engine-distribution-untested = Not: { $game } oyununun { $distribution } kopyası bu modla test edilmedi.
engine-no-matching-artifact = bu platform, mimari ve dağıtımla eşleşen bir yayın dosyası yok
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Bu mod yalnızca { $platform } için kullanılabilir.
engine-platform-only-two = Bu mod yalnızca { $first } ve { $second } için kullanılabilir.
engine-platform-only-three = Bu mod yalnızca { $first }, { $second } ve { $third } için kullanılabilir.
engine-platform-needs-apple-silicon = Bu mod, { $platform } üzerinde Apple Silicon işlemci gerektirir.
engine-platform-needs-arm = Bu mod, { $platform } üzerinde ARM işlemci gerektirir.
engine-platform-needs-x64 = Bu mod, { $platform } üzerinde Intel veya AMD işlemci gerektirir.
engine-game-platform-unsupported = { $game } burada { $platform } üzerinde desteklenmiyor.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } güncel ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } güncel ({ $installed }, en son yayın olan { $latest } sürümünden daha yeni).
engine-installed-newer = { $name } { $installed } yüklü; bu sürüm, şu anda kullanabileceğiniz en son yayından ({ $latest }) daha yeni. Hiçbir şey değiştirilmedi. Daha eski bir sürüm yüklemek için o sürümü açıkça seçin.
# { $from } and { $to } are versions.
engine-updating = { $name } güncelleniyor: { $from } sürümünden { $to } sürümüne.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    { $name }, { $branch } dalının en son hâlinden ({ $version }) yüklensin mi?

    Geliştirme derlemeleri bir karma değeriyle sabitlenmez; deponun şu anki içeriğine güvenmiş olursunuz.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    { $name } { $version } yayın notları:

    { $notes }

    Şimdi yüklensin mi?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = { $source } kaynağından { $tag } yayınının bilgileri alınıyor...
engine-fetching-latest = { $source } kaynağından en son yayının bilgileri alınıyor...
engine-using-local-artifact = Yerel dosya kullanılıyor: { $path }
# { $file } is a download's file name.
engine-using-cached = Daha önce indirilen dosya kullanılıyor: { $file }.
engine-downloading = İndiriliyor: { $file }...
engine-dependency-present = Bağımlılık zaten yüklü: { $id } { $version }.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Bağımlılık yükleniyor: { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = belirteç girilmedi
core-sign-in-cancelled = Oturum açma iptal edildi.
core-sign-in-expired = Oturum açma kodunun süresi, kod girilmeden doldu. Lütfen yeniden başlayın.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = "{ $pattern }" bir kaynak (github:owner/repo) veya sahip joker karakteri (github:owner/*) değil
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = belirteç sistemin kimlik bilgisi deposuna kaydedilemedi
core-secrets-remove-failed = belirteç sistemin kimlik bilgisi deposundan kaldırılamadı

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = { $source } kaynağının { $tag } yayınında { $file } dosyası yok
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = { $source } kaynağının en son yayınında { $file } dosyası yok
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = { $tag } yayınında loadstone-release.json dosyası yok (veya erişilemiyor)
core-github-sign-in-cancelled = Oturum açma GitHub üzerinde iptal edildi.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub oturum açmayı reddetti: { $details }
core-github-sign-in-refused-no-details = GitHub oturum açmayı reddetti: ayrıntı verilmedi
core-github-token-rejected = GitHub belirteci kabul etmedi

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } oturum açmayı desteklemiyor
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = "{ $source }" geçerli bir { $format } kaynağı değil
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } bulunamadı. Özel bir depoysa, depoyu görebilen bir hesapla oturum açın (Loadstone ayarları) veya GH_TOKEN değişkenini ayarlayın
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = { $account } kaynaklı belirteç reddedildi; süresi dolmuş veya iptal edilmiş olabilir
core-source-token-unreachable = { $account } kaynaklı belirteçle { $source } kaynağına erişilemiyor

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = { $url } indirmesi HTTP { $status } döndürdü
core-fetch-request-failed = istek başarısız oldu: { $url }
core-fetch-download-failed = indirme başarısız oldu: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = okuma hatası
core-fetch-read-error-download = indirme sırasında okuma hatası

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = bu platform ve dağıtım için geçerli bir ayıklama yolu yok
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } bir geliştirme çalışma kopyasına giden bağlantı. Bunun yerine o çalışma kopyasını git ile güncelleyin veya yüklemeden önce bağlantıyı kaldırın.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = bu arşiv beklenen içeriği barındırmıyor (hiçbir öğe hiçbir ayıklama yoluyla eşleşmiyor)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = "{ $source }" kayıt defteri ne { $formats } biçiminde ne de var olan bir klasör
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } içinde loadstone-packages klasörü yok
# $error is the reason the download failed.
core-registry-using-cache = { $source } yenilenemedi ({ $error }); önbellekteki kopya kullanılıyor.
core-registry-fetch-failed = kayıt defteri alınamadı: { $source }
# $id is a mod's id.
core-registry-package-not-found = "{ $id }" paketi hiçbir kayıt defterinde bulunamadı

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = "{ $key }" mantıksal bir değer alır; true veya false kullanın
core-setting-not-number = "{ $key }" bir sayı gerektirir
core-setting-too-small = "{ $key }" en az { $min } olmalıdır
core-setting-too-large = "{ $key }" en fazla { $max } olmalıdır
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = "{ $key }" şunlardan biri olmalıdır: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Bir kayıt defterinin modları için test kullanıcısı erişimi açıldı: yalnızca test kullanıcılarına açık modlar listelenir, yükleme ve güncellemelerde beta sürümler alınır.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Bir kayıt defterinin modları ve şunlar için test kullanıcısı erişimi açıldı: { $mods }. Yalnızca test kullanıcılarına açık modlar listelenir, yükleme ve güncellemelerde beta sürümler alınır.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Şunlar için test kullanıcısı erişimi açıldı: { $mods }. Yalnızca test kullanıcılarına açık modlar listelenir, yükleme ve güncellemelerde beta sürümler alınır.
core-tester-save-failed = test kullanıcısı parolası kaydedilemedi
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = { $tag } yayınında kullanılabilir Loadstone meta verisi yok ({ $error }); en son kararlı yayın kullanılıyor.
core-tester-beta-lookup-failed = Beta sürümler aranamadı ({ $error }); en son kararlı yayın kullanılıyor.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = indirilen güncelleme karma doğrulamasından geçemedi (beklenen { $expected }, alınan { $actual }); yüklenmedi
core-update-translocated = macOS bu uygulamayı salt okunur geçici bir kopyadan çalıştırıyor, bu yüzden uygulama kendini güncelleyemiyor. Uygulamayı Uygulamalar klasörünüze taşıyın, oradan açın ve yeniden güncelleyin.
core-update-on-disk-image = bu uygulama kendi disk görüntüsünden çalışıyor, bu yüzden kendini güncelleyemiyor. Uygulamayı Uygulamalar klasörünüze kopyalayın, oradan açın ve yeniden güncelleyin.
# $path is the folder the app is in.
core-update-no-write = { $path } konumuna yazılamıyor (izin yok mu?), bu yüzden uygulama kendini güncelleyemiyor. Bunun yerine yeni sürümü yayın sayfasından indirin.
core-update-no-staging = { $path } konumuna yazılamıyor (izin yok mu?). Bunun yerine yeni sürümü yayın sayfasından indirin
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = güncelleme farklı bir uygulamaya ait ({ $got }, beklenen { $expected }); yüklenmedi
core-update-move-aside-app = mevcut uygulama kenara taşınamadı
core-update-move-in-app = yeni uygulama yerine taşınamadı
core-update-move-aside-exe = mevcut yürütülebilir dosya kenara taşınamadı
core-update-move-in-exe = yeni yürütülebilir dosya yerine taşınamadı
