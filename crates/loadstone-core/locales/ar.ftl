# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = يحتاج هذا التعديل إلى إصدار أحدث من Loadstone. حدّث Loadstone ثم أعد المحاولة.

## Loadstone settings

pref-language = اللغة
pref-language-description = اللغة التي يُعرض بها Loadstone والتعديلات المترجمة.
language-system = الافتراضي للنظام
pref-accounts = الحسابات
pref-accounts-description = حسابات تسجيل الدخول المستخدمة لتنزيل التعديلات من المستودعات الخاصة.
pref-account-rules = قواعد الحسابات
pref-account-rules-description = الحساب الذي يُستخدم لمستودع معيّن أو لمالك معيّن.
pref-try-other-accounts = تجربة حساباتي الأخرى عند رفض التنزيل
pref-try-other-accounts-description = إذا لم يُعثر على المستودع أو رُفض الوصول، تُجرَّب الحسابات الأخرى لهذا الموقع قبل التوقف.
pref-tester-passwords = كلمات مرور المختبِرين
pref-tester-passwords-description = تفتح التعديلات المخصصة للمختبِرين والإصدارات التجريبية، لفهرس كامل أو لتعديلات بعينها. تُضبط من زر كلمة مرور المختبِر.
pref-download-account = حساب التنزيل
pref-download-account-description = الحساب المستخدم لتنزيل هذا التعديل. يستخدم الخيار التلقائي قواعد حساباتك ثم الحساب الافتراضي.
pref-download-account-automatic = تلقائي (قواعد الحسابات، ثم الحساب الافتراضي)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &إعدادات Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = حسابات المستودعات الخاصة، وخيارات Loadstone
gui-menu-exit = &خروج
# Menu bar title.
gui-menu-tools = &أدوات
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = لا تزال هناك عملية قيد التشغيل. قد يؤدي الإغلاق الآن إلى عدم اكتمالها. هل تريد الإغلاق على أي حال؟
gui-close-while-running-title = عملية قيد التنفيذ
# Status bar text while a standalone installer loads its mod.
gui-status-loading = جارٍ التحميل...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = حدثت مشكلة أثناء العملية
gui-button-retry = إعادة ال&محاولة
gui-button-skip = ت&خطي
gui-button-cancel-problem = إ&لغاء
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = خيارات التثبيت

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (النواة { $version })
# Label of the list of mods.
gui-catalog-mods-label = ال&تعديلات:
# Button that opens the selected mod's page.
gui-button-details = التفا&صيل
gui-button-refresh = إعادة ت&حميل
gui-button-loadstone-settings = إ&عدادات Loadstone...
gui-status-fetching-catalog = جارٍ جلب كتالوج التعديلات...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = جارٍ تحميل قائمة التعديلات...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = تعذّر تحميل قائمة التعديلات. اضغط إعادة تحميل للمحاولة مرة أخرى.
gui-status-catalog-failed = تعذّر جلب الكتالوج.
gui-catalog-error-title = تعذّر تحميل كتالوج التعديلات
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }، { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }، { $status }، { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = لا توجد تعديلات متاحة.
gui-status-catalog-loaded = { $count ->
    [zero] تم تحميل الكتالوج: لا توجد تعديلات.
    [one] تم تحميل الكتالوج: تعديل واحد.
    [two] تم تحميل الكتالوج: تعديلان.
    [few] تم تحميل الكتالوج: { $count } تعديلات.
    [many] تم تحميل الكتالوج: { $count } تعديلًا.
   *[other] تم تحميل الكتالوج: { $count } تعديل.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = جارٍ تحميل { $mod_id }...
gui-status-mod-load-failed = تعذّر تحميل صفحة التعديل.
gui-mod-error-title = تعذّر تحميل التعديل
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &نسخة اللعبة المراد إدارتها:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &نسخة { $game } المراد إدارتها:
gui-button-back = ال&رجوع إلى قائمة التعديلات
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }، من إعداد { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = م&جلد اللعبة:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = م&جلد { $game }:
gui-button-browse = استعرا&ض...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = حدّد مجلد اللعبة
gui-browse-game-prompt-named = حدّد مجلد { $game }
gui-description-label = الوصف:
# Label of the log where operations report their progress.
gui-activity-label = سجل النشاط:
gui-button-update = &تحديث
gui-button-install = تث&بيت
gui-select-folder-first = استخدم استعراض لتحديد مجلد اللعبة أولًا.
gui-button-install-from-file = التثبيت من م&لف...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = حدّد ملف loadstone-release.json الخاص بالتعديل
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|ملفات JSON (*.json)|*.json|كل الملفات (*.*)|*.*
gui-button-uninstall = إلغاء التثبي&ت
gui-button-launch = تشغي&ل اللعبة
# Description of the Launch game button, read when it gets focus.
gui-launch-description = يشغّل اللعبة مع تحميل التعديل.
gui-launch-unavailable-description = يتاح بعد تثبيت التعديل هنا.
gui-button-change-options = تغيير خيارات الت&ثبيت...
gui-change-options-description = يطرح أسئلة تثبيت التعديل من جديد ويعيد تثبيت أحدث إصدار وفق إجاباتك.
gui-button-settings = الإعدا&دات...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = جارٍ العمل... { $percent }%
gui-status-fetching-releases = جارٍ جلب قائمة الإصدارات...
# $error is an error message.
gui-release-list-error = تعذّر جلب قائمة الإصدارات: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = هل تريد تثبيت أحدث إصدار بدلًا من ذلك؟
gui-release-list-error-title = قائمة الإصدارات غير متاحة
gui-no-releases = لا توجد إصدارات بعد في مستودع هذا التعديل.
gui-no-releases-title = لا توجد إصدارات
gui-choose-version = حدّد الإصدار المراد تثبيته:
gui-choose-version-title = اختيار الإصدار
gui-confirm-uninstall = هل تريد إلغاء تثبيت التعديل { $name }؟
gui-confirm-uninstall-title = تأكيد إلغاء التثبيت
gui-status-working = جارٍ العمل...
gui-status-op-failed = فشلت العملية.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = تعذّر التشغيل
gui-op-failed-title = فشلت العملية
# Title of the message shown when an operation finished.
gui-op-done-title = تم

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = الإصدار { $version } من { $app } متاح (الإصدار المثبّت لديك { $current }). هل تريد التحديث وإعادة التشغيل الآن؟
gui-self-update-title = يتوفر تحديث
gui-status-downloading-update = جارٍ تنزيل التحديث...
gui-status-update-failed = فشل التحديث.
gui-update-failed-title = فشل التحديث
gui-status-update-installed = تم تثبيت التحديث.
gui-update-installed = تم تثبيت التحديث. ستتم إعادة تشغيل التطبيق الآن.
gui-update-installed-title = تم تثبيت التحديث

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = إعدادات Loadstone غير متاحة: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = إعدادات { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = خيارات التعديل
gui-mod-options-after-install = تتاح خيارات التعديل بعد تثبيته.
gui-status-setting-saved = تم حفظ الإعداد.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = تم حفظ الإعداد. { $note }
gui-setting-not-changed-title = لم يتغير الإعداد
gui-status-no-settings-changed = لم يتغير أي إعداد.

## Loadstone settings dialog

gui-loadstone-settings-title = إعدادات Loadstone
gui-accounts-label = ال&حسابات:
gui-accounts-description = حسابات تسجيل الدخول المستخدمة لتنزيل التعديلات من المستودعات الخاصة.
gui-button-sign-in = تسجيل ال&دخول...
gui-button-add-token = إضافة &رمز مميز...
gui-button-remove-account = إزالة ال&حساب
gui-button-set-default = تعيين ك&افتراضي
# "gh auth token" is a command, keep it.
gui-add-token-description = أضف حسابًا من رمز مميز لديك بالفعل، مثل الرمز الذي يعطيه الأمر gh auth token في GitHub CLI.
gui-rules-label = &قواعد الحسابات:
gui-rules-description = الحساب الذي يُستخدم لمستودع معيّن أو لكل مستودعات مالك معيّن. عند عدم وجود قاعدة، يُستخدم الحساب الافتراضي.
gui-button-add-rule = إضافة &قاعدة...
gui-button-remove-rule = إزالة القا&عدة
gui-button-tester-password = كلمة مرور ال&مختبِر...
gui-tester-password-description = للمختبِرين الخاصين: أدخل كلمة المرور التي أُعطيت لك لرؤية التعديلات المخصصة للمختبِرين والحصول على الإصدارات التجريبية. يمكنك إضافة أكثر من كلمة مرور. اترك الحقل فارغًا لإيقاف الاختبار.
gui-tester-password-prompt-saved = لديك كلمات مرور مختبِرين محفوظة. أدخل كلمة أخرى لإضافتها، أو اترك الحقل فارغًا لنسيانها جميعًا وإيقاف الاختبار.
gui-tester-password-prompt = أدخل كلمة مرور المختبِر التي أُعطيت لك.
gui-tester-password-title = كلمة مرور المختبِر
gui-tester-password-not-saved-title = لم تُحفظ كلمة مرور المختبِر
gui-button-close = إ&غلاق
gui-accounts-unavailable-title = الحسابات غير متاحة
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }، { $username } على { $site }، افتراضي
    [missing] { $account }، { $username } على { $site }، الرمز المميز مفقود (سجّل الدخول مجددًا)
    [default-missing] { $account }، { $username } على { $site }، افتراضي، الرمز المميز مفقود (سجّل الدخول مجددًا)
   *[none] { $account }، { $username } على { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = لا توجد حسابات. استخدم تسجيل الدخول لإضافة حساب.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } يستخدم { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = لا توجد قواعد.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = الصق رمزًا مميزًا من { $site }. سيتم التحقق منه لدى { $site }، ثم يُخزَّن في إدارة بيانات الاعتماد في Windows.
gui-add-token-title = إضافة رمز مميز
gui-status-account-added = تمت إضافة الحساب { $account }.
gui-token-not-added-title = لم تتم إضافة الرمز المميز
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = هل تريد إزالة الحساب { $account }؟ سينسى Loadstone رمزه المميز وكل القواعد التي تستخدمه. لإلغاء وصول Loadstone أيضًا، استخدم Applications في إعدادات { $site }.
gui-remove-account-title = إزالة الحساب
gui-account-not-removed-title = لم تتم إزالة الحساب
gui-default-not-changed-title = لم يتغير الحساب الافتراضي
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = مستودع (github:owner/repo) أو كل مستودعات مالك (github:owner/*):
gui-add-rule-title = إضافة قاعدة حساب
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = أي حساب تريد استخدامه؟
gui-rule-not-added-title = لم تتم إضافة القاعدة
gui-rule-not-removed-title = لم تتم إزالة القاعدة

## Signing in

gui-sign-in-no-sites = لا يوجد موقع يدعم تسجيل الدخول.
gui-sign-in-title = تسجيل الدخول
gui-sign-in-which-site = في أي موقع تريد تسجيل الدخول؟
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = تسجيل الدخول إلى { $site }
gui-sign-in-requesting = جارٍ طلب رمز تسجيل الدخول من { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &رمز تسجيل الدخول:
gui-button-copy-code = &نسخ الرمز
gui-button-open-sign-in-page = &فتح صفحة تسجيل الدخول في { $site }
gui-button-cancel = إلغاء
gui-sign-in-code-copied = تم نسخ الرمز. افتح صفحة تسجيل الدخول والصقه هناك.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = افتح { $url }، وأدخل الرمز أدناه، ثم امنح الإذن لـ Loadstone. ستُغلق هذه النافذة تلقائيًا عند الانتهاء.
gui-sign-in-code-expired = انتهت صلاحية رمز تسجيل الدخول قبل إدخاله. يُرجى البدء من جديد.
# $account is the account's name.
gui-status-signed-in = تم تسجيل الدخول باسم { $account }.
gui-signed-in = تم تسجيل الدخول إلى { $site } باسم { $account }.
gui-signed-in-title = تم تسجيل الدخول
gui-sign-in-failed-title = فشل تسجيل الدخول
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = هل تريد تسجيل الدخول الآن بحساب يمكنه الوصول إليه؟
gui-offer-sign-in-title = سجّل الدخول للمتابعة

## Startup

gui-startup-error-title = خطأ في بدء تشغيل Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = مدير التعديلات Loadstone

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = مثبّت { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = مثبّت { $version } (قناة { $channel })
page-catalog-not-installed = غير مثبّت
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [zero] مثبّت { $version } في { $count } نسخة
    [one] مثبّت { $version } في نسخة واحدة
    [two] مثبّت { $version } في نسختين
    [few] مثبّت { $version } في { $count } نسخ
    [many] مثبّت { $version } في { $count } نسخة
   *[other] مثبّت { $version } في { $count } نسخة
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [zero] مثبّت في { $count } نسخة (الإصدارات مختلفة)
    [one] مثبّت في نسخة واحدة (الإصدارات مختلفة)
    [two] مثبّت في نسختين (الإصدارات مختلفة)
    [few] مثبّت في { $count } نسخ (الإصدارات مختلفة)
    [many] مثبّت في { $count } نسخة (الإصدارات مختلفة)
   *[other] مثبّت في { $count } نسخة (الإصدارات مختلفة)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = مثبّت خارج Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = مثبّت، لكنه لم يعد مدرجًا في الفهارس المكوّنة.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (معاينة للمختبِرين)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = لم يتم تكوين أي فهارس؛ تُعرض التعديلات المثبّتة فقط.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [zero] لا توجد تعديلات مخفية.
    [one] تم إخفاء تعديل واحد غير متاح لهذا الكمبيوتر.
    [two] تم إخفاء تعديلين غير متاحين لهذا الكمبيوتر.
    [few] تم إخفاء { $count } تعديلات غير متاحة لهذا الكمبيوتر.
    [many] تم إخفاء { $count } تعديلًا غير متاح لهذا الكمبيوتر.
   *[other] تم إخفاء { $count } تعديل غير متاح لهذا الكمبيوتر.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = تعذّر تحميل الفهارس: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = غير موجود في الفهارس المكوّنة: { $error }
page-note-no-release-metadata = لا يحتوي أحدث إصدار منشور على بيانات Loadstone الوصفية بعد، لذا تعذّر تحديد أحدث إصدار.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = ملاحظة: تتشارك نسخ { $game } مجلد تعديلات واحدًا. يؤثر تثبيت تعديل أو إلغاء تثبيته في إحدى النسخ على النسخ الأخرى؛ ولا يكون منفصلًا لكل نسخة سوى أداة تحميل التعديلات.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = يتطلب { $name } (يُثبَّت تلقائيًا، الإصدار الحالي { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = يتطلب { $name } (يُثبَّت تلقائيًا).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = مثبّت { $version } (قناة التطوير).
page-status-up-to-date = محدَّث (الإصدار { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = محدَّث (الإصدار { $version }، أحدث من آخر إصدار منشور، { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = يتوفر تحديث: من { $version } إلى { $latest }.
page-status-installed = مثبّت { $version }.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = مثبّت خارج Loadstone (الإصدار غير معروف). ثبّت الإصدار { $latest } ليتمكن Loadstone من إدارة هذه النسخة.
page-status-foreign = مثبّت خارج Loadstone (الإصدار غير معروف). ثبّت التعديل ليتمكن Loadstone من إدارة هذه النسخة.
page-status-ready = جاهز لتثبيت الإصدار { $latest }.
page-status-not-installed = غير مثبّت.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = غير متاح على هذا الكمبيوتر. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = جاهز لتثبيت الإصدار { $latest }. لم يُعثر على مجلد اللعبة؛ استخدم استعراض لتحديده.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = غير مثبّت. لم يُعثر على مجلد اللعبة؛ استخدم استعراض لتحديده.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = استخدم استعراض لتحديد المجلد. غير متاح على هذا الكمبيوتر. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = استخدم استعراض لتحديد المجلد. جاهز لتثبيت الإصدار { $latest }. لم يُعثر على مجلد اللعبة؛ استخدم استعراض لتحديده.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = استخدم استعراض لتحديد المجلد. غير مثبّت. لم يُعثر على مجلد اللعبة؛ استخدم استعراض لتحديده.
# Shown with a mod's settings before it is installed.
page-settings-after-install = تصبح الإعدادات قابلة للتعديل بعد التثبيت.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = نسخة { $distribution }، مثبّت { $version }، { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = نسخة { $distribution }، مثبّت خارج Loadstone، { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = نسخة { $distribution }، غير مثبّت، { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = نسخة في { $folder }، مثبّت { $version }
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = نسخة في { $folder }، مثبّت خارج Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = نسخة في { $folder }، غير مثبّت
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = لم يُعثر على أي نسخة بعد؛ استخدم استعراض لتحديد مجلد اللعبة.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = مجلد آخر...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = مستقلة
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = قناة { $channel } (أحدث إصدار من الفرع { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = قناة { $channel } (إصدار تطوير)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }، { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (إصدار تجريبي)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }، { $title } (إصدار تجريبي)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = اكتمل الإجراء { $action }.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = جارٍ تنزيل { $file }...
page-self-update-installed = تم التحقق من التحديث وتثبيته.
page-tester-passwords-removed = تمت إزالة كلمات مرور المختبِرين. أصبحت التعديلات المخصصة للمختبِرين والإصدارات التجريبية مخفية مجددًا.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } على { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = لم يتم تكوين أي فهارس
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = لا يُعرف مستودع مصدر لـ "{ $id }"
# $id is a mod id.
page-error-not-installed-no-registries = "{ $id }" غير مثبّت ولم يتم تكوين أي فهارس
# $id is a mod id.
page-error-not-installed-unresolved = "{ $id }" غير مثبّت وتعذّر العثور عليه
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = "{ $id }" غير مثبّت وتعذّر العثور عليه: { $error }
page-error-tester-password-wrong = هذه ليست كلمة مرور مختبِر لأي من فهارسك أو تعديلاتها.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = مخزن الحسابات غير متاح
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = "{ $value }" ليس رقمًا
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = ليس رقمًا محدودًا

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = عدم تطابق تجزئة الملف لـ { $id }: المتوقع { $expected }، والفعلي { $actual }. تم رفض التثبيت.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = عدم تطابق تجزئة الملف لـ { $id } ({ $artifact }): المتوقع { $expected }، والفعلي { $actual }. تم رفض التثبيت.
engine-hash-verified = تم التحقق من تجزئة الملف.
engine-hash-none = لا توجد تجزئة للتحقق منها لهذا المصدر (تثبيت محلي أو تثبيت إصدار تطوير).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [zero] جارٍ إزالة الإصدار المثبّت سابقًا { $version } ({ $count } ملف).
    [one] جارٍ إزالة الإصدار المثبّت سابقًا { $version } (ملف واحد).
    [two] جارٍ إزالة الإصدار المثبّت سابقًا { $version } (ملفان).
    [few] جارٍ إزالة الإصدار المثبّت سابقًا { $version } ({ $count } ملفات).
    [many] جارٍ إزالة الإصدار المثبّت سابقًا { $version } ({ $count } ملفًا).
   *[other] جارٍ إزالة الإصدار المثبّت سابقًا { $version } ({ $count } ملف).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = تحذير: { $message }
# { $error } is a system error message.
engine-warning-record-originals = تحذير: تعذّر تسجيل الملفات الأصلية التي لا يزال يجب استعادتها: { $error }
engine-install-failed-rolling-back = فشل التثبيت؛ جارٍ إزالة الملفات التي كُتبت حتى الآن.
# Summary shown when an install or update finishes.
engine-installed = تم تثبيت { $name } { $version }.
# The user answered no to the release notes or development build question.
engine-install-cancelled = تم إلغاء التثبيت.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = "{ $id }" ليس خيار تثبيت لهذا التعديل (الخيارات: { $options })
engine-option-unknown-none = "{ $id }" ليس خيار تثبيت لهذا التعديل (لا توجد خيارات)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = "{ $value }" ليس اختيارًا متاحًا لـ { $option } (الاختيارات: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = تم الإلغاء: لم يتم اختيار شيء

## Mod settings

# { $label } is the setting's name.
engine-setting-default = يبدأ الإعداد "{ $label }" بقيمته الافتراضية؛ يمكنك تغييره لاحقًا بأمر الإعدادات.
# { $path } is the settings file.
engine-settings-written = تمت كتابة الإعدادات في { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = "{ $action }" ليس إجراءً من إجراءات { $id } (المتاح: { $available })
engine-action-unknown-none = "{ $action }" ليس إجراءً من إجراءات { $id } (لا توجد إجراءات متاحة)
# { $label } is the action's name, as on its button.
engine-action-unavailable = الإجراء "{ $label }" غير متاح الآن (شرطه المسبق غير متحقق)
engine-action-running = جارٍ تنفيذ "{ $label }"...
engine-action-finished = انتهى "{ $label }".
engine-no-launch-steps = لا يحدد { $id } أي خطوات تشغيل لهذا النظام الأساسي
# Summary after starting the game with a mod.
engine-launched = تم تشغيل { $id }.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } ارتباط إلى نسخة عمل تطويرية؛ يُرفض تعديل الملفات أو إزالتها من خلاله. أزل الارتباط أولًا إذا كنت تريد حقًا تثبيتًا مُدارًا هنا.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = لن تتم إزالة { $path }: إنه خارج مجلدات التعديل.
engine-legacy-link = لن تتم إزالة { $path }: يتم الوصول إليه عبر ارتباط.
engine-legacy-shared = لن تتم إزالة { $path }: تستخدمه حزمة مثبّتة أخرى.
engine-legacy-removed = تمت إزالة بقايا تثبيت قديم: { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = تحذير: تعذّرت إزالة { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = لم يُعثر على ملف مطلوب: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = أحد متطلبات الخطوة { $step } غير متحقق.
engine-step-skipped = تم تخطي الخطوة { $step }.
engine-cancelled-at-step = تم الإلغاء عند الخطوة { $step }
engine-extracting = جارٍ استخراج الملفات...
engine-placed-files = { $count ->
    [zero] لم يتم وضع أي ملفات.
    [one] تم وضع ملف واحد.
    [two] تم وضع ملفين.
    [few] تم وضع { $count } ملفات.
    [many] تم وضع { $count } ملفًا.
   *[other] تم وضع { $count } ملف.
}
engine-kept-existing = تم الإبقاء على الملف الموجود { $path } (لم يُستبدل؛ قد يكون أحدث).
engine-file-created = تم إنشاء الملف { $path } وتحديثه.
engine-file-updated = تم تحديث الملف { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = تم الإلغاء: لم يتم اختيار مجلد لـ "{ $prompt }"
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = تم النسخ إلى الحافظة: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [zero] لم يتم دمج أي معماريات في { $file }.
    [one] تم دمج معمارية واحدة في { $file }.
    [two] تم دمج معماريتين في { $file }.
    [few] تم دمج { $count } معماريات في { $file }.
    [many] تم دمج { $count } معمارية في { $file }.
   *[other] تم دمج { $count } معمارية في { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = تعذّر التشغيل: { $path } مفقود
engine-program-start-failed = فشل بدء { $path }
engine-program-started = تم بدء { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = فشل فتح { $url }
engine-url-opened = تم فتح { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = لا يزال { $id } مطلوبًا من: { $dependents }. ألغِ تثبيتها أولًا.
engine-removing-files = { $count ->
    [zero] لا توجد ملفات لإزالتها.
    [one] جارٍ إزالة ملف واحد.
    [two] جارٍ إزالة ملفين.
    [few] جارٍ إزالة { $count } ملفات.
    [many] جارٍ إزالة { $count } ملفًا.
   *[other] جارٍ إزالة { $count } ملف.
}
engine-purge-question = هل تريد إزالة الإعدادات والتفضيلات المحفوظة أيضًا؟
engine-purge-done = تمت إزالة الإعدادات المحفوظة.
engine-dependency-unneeded = لم يعد أي تعديل مثبّت يحتاج إلى { $id }؛ يمكنك إلغاء تثبيته أيضًا.
# Summary when an uninstall finishes.
engine-uninstalled = تم إلغاء تثبيت { $id } { $version }.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = يتم استخدام الملف الأصلي المحفوظ مسبقًا في { $path }.
engine-originals-kept = { $count ->
    [zero] لم يتم حفظ نسخ من أي ملفات أصلية للعبة.
    [one] تم حفظ نسخة من ملف أصلي واحد للعبة.
    [two] تم حفظ نسخ من ملفين أصليين للعبة.
    [few] تم حفظ نسخ من { $count } ملفات أصلية للعبة.
    [many] تم حفظ نسخ من { $count } ملفًا أصليًا للعبة.
   *[other] تم حفظ نسخ من { $count } ملف أصلي للعبة.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = تحذير: تعذّرت استعادة الملف الأصلي { $path } الآن ({ $error }). ستتم إعادته عند تحديث هذا التعديل أو إلغاء تثبيته.
engine-original-restored = تمت استعادة الملف الأصلي { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = تحذير: الملف الأصلي لـ { $path } مفقود ({ $backup })؛ سيُترك الملف كما هو.
engine-original-changed = تغيّر { $path } منذ تثبيت هذا التعديل (ربما بسبب تحديث للعبة)؛ سيتم الإبقاء على الملف الأحدث.
engine-originals-restored = { $count ->
    [zero] لم تتم استعادة أي ملفات أصلية للعبة.
    [one] تمت استعادة ملف أصلي واحد للعبة.
    [two] تمت استعادة ملفين أصليين للعبة.
    [few] تمت استعادة { $count } ملفات أصلية للعبة.
    [many] تمت استعادة { $count } ملفًا أصليًا للعبة.
   *[other] تمت استعادة { $count } ملف أصلي للعبة.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [zero] تعذّرت إعادة { $count } ملف أصلي للعبة؛ أغلق اللعبة وأعد المحاولة.
    [one] تعذّرت إعادة ملف أصلي واحد للعبة؛ أغلق اللعبة وأعد المحاولة.
    [two] تعذّرت إعادة ملفين أصليين للعبة؛ أغلق اللعبة وأعد المحاولة.
    [few] تعذّرت إعادة { $count } ملفات أصلية للعبة؛ أغلق اللعبة وأعد المحاولة.
    [many] تعذّرت إعادة { $count } ملفًا أصليًا للعبة؛ أغلق اللعبة وأعد المحاولة.
   *[other] تعذّرت إعادة { $count } ملف أصلي للعبة؛ أغلق اللعبة وأعد المحاولة.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = جارٍ تحديث نسخة { $distribution } في { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = "{ $id }" مثبّت في أكثر من نسخة من { $game }: { $copies }. استخدم --game-dir لتحديد النسخة المراد تحديثها.
engine-many-copies = "{ $id }" مثبّت في أكثر من نسخة من { $game }: { $copies }. استخدم --game-dir لتحديد النسخة.
engine-not-game-folder = لا يبدو أن { $path } مجلد { $game } (لم يُعثر على أي من الملفات المتوقعة)
engine-game-found = تم العثور على { $game } في { $path }
engine-game-not-found = تعذّر العثور على { $game } تلقائيًا.
# Title of the folder picker.
engine-game-where = أين تم تثبيت { $game }؟
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = تعذّر العثور على { $game } تلقائيًا؛ استخدم --game-dir أو اختر مجلدها
# { $path } is a game folder.
engine-not-installed-copy = "{ $id }" غير مثبّت في نسخة { $game } الموجودة في { $path }
engine-not-installed = "{ $id }" غير مثبّت لـ { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = لا يمكن تثبيت { $name } على هذا الكمبيوتر. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = نسخة { $distribution } من { $game } غير مدعومة. { $reason }
engine-distribution-untested = ملاحظة: لم يتم اختبار نسخة { $distribution } من { $game } مع هذا التعديل.
engine-no-matching-artifact = لا يوجد ملف إصدار يطابق هذا النظام الأساسي والمعمارية والمتجر
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = هذا التعديل متاح على { $platform } فقط.
engine-platform-only-two = هذا التعديل متاح على { $first } و{ $second } فقط.
engine-platform-only-three = هذا التعديل متاح على { $first } و{ $second } و{ $third } فقط.
engine-platform-needs-apple-silicon = يحتاج هذا التعديل على { $platform } إلى معالج Apple Silicon.
engine-platform-needs-arm = يحتاج هذا التعديل على { $platform } إلى معالج ARM.
engine-platform-needs-x64 = يحتاج هذا التعديل على { $platform } إلى معالج Intel أو AMD.
engine-game-platform-unsupported = اللعبة { $game } غير مدعومة على { $platform } هنا.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } محدَّث ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } محدَّث ({ $installed } أحدث من آخر إصدار منشور، { $latest }).
engine-installed-newer = الإصدار { $installed } من { $name } مثبّت، وهو أحدث من آخر إصدار متاح لك الآن ({ $latest }). لم يتم تغيير أي شيء. لتثبيت إصدار أقدم، اختر ذلك الإصدار صراحة.
# { $from } and { $to } are versions.
engine-updating = جارٍ تحديث { $name } من { $from } إلى { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    هل تريد تثبيت { $name } من آخر حالة للفرع { $branch } ({ $version })؟

    لا يتم التحقق من إصدارات التطوير بتجزئة ثابتة؛ فأنت تعتمد على المحتوى الحالي للمستودع.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    ملاحظات الإصدار لـ { $name } { $version }:

    { $notes }

    هل تريد التثبيت الآن؟
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = جارٍ جلب معلومات الإصدار { $tag } من { $source }...
engine-fetching-latest = جارٍ جلب معلومات أحدث إصدار من { $source }...
engine-using-local-artifact = يتم استخدام الملف المحلي { $path }
# { $file } is a download's file name.
engine-using-cached = يتم استخدام الملف { $file } الذي نُزِّل مسبقًا.
engine-downloading = جارٍ تنزيل { $file }...
engine-dependency-present = التبعية { $id } { $version } مثبّتة بالفعل.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = جارٍ تثبيت التبعية { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = لم يتم إدخال رمز مميز
core-sign-in-cancelled = تم إلغاء تسجيل الدخول.
core-sign-in-expired = انتهت صلاحية رمز تسجيل الدخول قبل إدخاله. يُرجى البدء من جديد.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = "{ $pattern }" ليس مصدرًا (github:owner/repo) ولا حرف بدل لمالك (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = تعذّر حفظ الرمز المميز في مخزن بيانات الاعتماد في النظام
core-secrets-remove-failed = تعذّرت إزالة الرمز المميز من مخزن بيانات الاعتماد في النظام

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = لا يحتوي الإصدار { $tag } من { $source } على الملف { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = لا يحتوي أحدث إصدار من { $source } على الملف { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = لا يحتوي الإصدار { $tag } على الملف loadstone-release.json (أو يتعذّر الوصول إليه)
core-github-sign-in-cancelled = تم إلغاء تسجيل الدخول على GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = رفض GitHub تسجيل الدخول: { $details }
core-github-sign-in-refused-no-details = رفض GitHub تسجيل الدخول: لم تُقدَّم تفاصيل
core-github-token-rejected = لم يقبل GitHub الرمز المميز

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = لا يدعم { $site } تسجيل الدخول
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = "{ $source }" ليس مصدرًا بالتنسيق { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = لم يُعثر على { $source }. إذا كان مستودعًا خاصًا، فسجّل الدخول بحساب يمكنه رؤيته (من إعدادات Loadstone)، أو اضبط GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = تم رفض الرمز المميز من { $account }؛ ربما انتهت صلاحيته أو أُلغي
core-source-token-unreachable = يتعذّر الوصول إلى { $source } باستخدام الرمز المميز من { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = أعاد تنزيل { $url } رمز HTTP { $status }
core-fetch-request-failed = فشل الطلب: { $url }
core-fetch-download-failed = فشل التنزيل: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = خطأ في القراءة
core-fetch-read-error-download = خطأ في القراءة أثناء التنزيل

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = لا ينطبق أي مسار استخراج على هذا النظام الأساسي والمتجر
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } ارتباط إلى نسخة عمل تطويرية. حدّث نسخة العمل هذه باستخدام git بدلًا من ذلك، أو أزل الارتباط قبل التثبيت.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = لا يحتوي هذا الأرشيف على المحتوى المتوقع (لا يطابق أي عنصر أي مسار استخراج)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = الفهرس "{ $source }" ليس بالتنسيق { $formats } وليس مجلدًا موجودًا
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = لا يحتوي { $source } على المجلد loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = تعذّر تحديث { $source } ({ $error })؛ يتم استخدام النسخة المخزنة مؤقتًا.
core-registry-fetch-failed = فشل جلب الفهرس { $source }
# $id is a mod's id.
core-registry-package-not-found = لم يُعثر على الحزمة "{ $id }" في أي فهرس

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = "{ $key }" قيمة منطقية؛ استخدم true أو false
core-setting-not-number = يحتاج "{ $key }" إلى رقم
core-setting-too-small = يجب ألا تقل قيمة "{ $key }" عن { $min }
core-setting-too-large = يجب ألا تزيد قيمة "{ $key }" عن { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = يجب أن تكون قيمة "{ $key }" إحدى القيم التالية: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = تم فتح وصول المختبِرين لتعديلات أحد الفهارس: تُعرض التعديلات المخصصة للمختبِرين، وتحصل عمليات التثبيت والتحديث على الإصدارات التجريبية.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = تم فتح وصول المختبِرين لتعديلات أحد الفهارس ولـ { $mods }: تُعرض التعديلات المخصصة للمختبِرين، وتحصل عمليات التثبيت والتحديث على الإصدارات التجريبية.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = تم فتح وصول المختبِرين لـ { $mods }: تُعرض التعديلات المخصصة للمختبِرين، وتحصل عمليات التثبيت والتحديث على الإصدارات التجريبية.
core-tester-save-failed = فشل حفظ كلمة مرور المختبِر
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = لا يحتوي الإصدار { $tag } على بيانات Loadstone وصفية صالحة ({ $error })؛ يتم استخدام أحدث إصدار مستقر.
core-tester-beta-lookup-failed = تعذّر البحث عن الإصدارات التجريبية ({ $error })؛ يتم استخدام أحدث إصدار مستقر.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = فشل التحديث الذي تم تنزيله في التحقق من التجزئة (المتوقع { $expected }، والفعلي { $actual })؛ لم يتم تثبيته
core-update-translocated = يشغّل macOS هذا التطبيق من نسخة مؤقتة للقراءة فقط، لذا لا يمكنه تحديث نفسه. انقله إلى مجلد التطبيقات، وافتحه من هناك، ثم حدّثه مرة أخرى.
core-update-on-disk-image = يعمل هذا التطبيق من صورة القرص الخاصة به، لذا لا يمكنه تحديث نفسه. انسخه إلى مجلد التطبيقات، وافتحه من هناك، ثم حدّثه مرة أخرى.
# $path is the folder the app is in.
core-update-no-write = تتعذّر الكتابة بجوار { $path } (ربما لا توجد أذونات)، لذا لا يمكن للتطبيق تحديث نفسه. نزّل الإصدار الجديد من صفحة الإصدار بدلًا من ذلك.
core-update-no-staging = تتعذّر الكتابة بجوار { $path } (ربما لا توجد أذونات). نزّل الإصدار الجديد من صفحة الإصدار بدلًا من ذلك
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = التحديث لتطبيق مختلف ({ $got }، والمتوقع { $expected })؛ لم يتم تثبيته
core-update-move-aside-app = تعذّر نقل التطبيق الحالي جانبًا
core-update-move-in-app = تعذّر نقل التطبيق الجديد إلى مكانه
core-update-move-aside-exe = تعذّر نقل الملف التنفيذي الحالي جانبًا
core-update-move-in-exe = تعذّر نقل الملف التنفيذي الجديد إلى مكانه

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = &موافق
gui-stock-ok-plain = موافق
gui-stock-cancel = إ&لغاء
gui-stock-cancel-plain = إلغاء
gui-stock-yes = &نعم
gui-stock-yes-plain = نعم
gui-stock-no = &لا
gui-stock-no-plain = لا
gui-stock-close = إ&غلاق
gui-stock-close-plain = إغلاق
