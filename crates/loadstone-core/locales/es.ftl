# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Este mod necesita una versión más reciente de Loadstone. Actualiza Loadstone y vuelve a intentarlo.

## Loadstone settings

pref-language = Idioma
pref-language-description = El idioma en el que se muestran Loadstone y los mods traducidos.
language-system = Predeterminado del sistema
pref-accounts = Cuentas
pref-accounts-description = Inicios de sesión usados para descargar mods de repositorios privados.
pref-account-rules = Reglas de cuenta
pref-account-rules-description = Qué cuenta usar para un repositorio o un propietario.
pref-try-other-accounts = Probar mis otras cuentas cuando se rechace una descarga
pref-try-other-accounts-description = Si no se encuentra un repositorio o se deniega el acceso, probar las otras cuentas de ese sitio antes de desistir.
pref-tester-passwords = Contraseñas de tester
pref-tester-passwords-description = Desbloquean los mods exclusivos para testers y las versiones beta, para un registro o para mods concretos. Se configuran con el botón Contraseña de tester.
pref-download-account = Cuenta de descarga
pref-download-account-description = La cuenta usada para descargar este mod. Automática usa tus reglas de cuenta y tu cuenta predeterminada.
pref-download-account-automatic = Automática (reglas de cuenta y, después, la cuenta predeterminada)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Configuración de Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Cuentas para repositorios privados y opciones de Loadstone
gui-menu-exit = &Salir
# Menu bar title.
gui-menu-tools = &Herramientas
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Todavía hay una operación en curso. Si cierras ahora, puede quedar sin terminar. ¿Cerrar de todos modos?
gui-close-while-running-title = Operación en curso
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Cargando...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problema durante la operación
gui-button-retry = &Reintentar
gui-button-skip = &Omitir
gui-button-cancel-problem = &Cancelar
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Opciones de instalación

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (núcleo { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mods:
# Button that opens the selected mod's page.
gui-button-details = &Detalles
gui-button-refresh = &Recargar
gui-button-loadstone-settings = Configuración de &Loadstone...
gui-status-fetching-catalog = Obteniendo el catálogo de mods...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Cargando la lista de mods...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = No se pudo cargar la lista de mods. Pulsa Recargar para volver a intentarlo.
gui-status-catalog-failed = No se pudo obtener el catálogo.
gui-catalog-error-title = No se pudo cargar el catálogo de mods
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = No hay mods disponibles.
gui-status-catalog-loaded = { $count ->
    [one] Catálogo cargado: { $count } mod.
   *[other] Catálogo cargado: { $count } mods.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Cargando { $mod_id }...
gui-status-mod-load-failed = No se pudo cargar la página del mod.
gui-mod-error-title = No se pudo cargar el mod
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Copia del juego que quieres administrar:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Copia de { $game } que quieres administrar:
gui-button-back = &Volver a la lista de mods
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }, de { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = Carpeta del &juego:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = Ca&rpeta de { $game }:
gui-button-browse = E&xaminar...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Selecciona la carpeta del juego
gui-browse-game-prompt-named = Selecciona la carpeta de { $game }
gui-description-label = Descripción:
# Label of the log where operations report their progress.
gui-activity-label = Actividad:
gui-button-update = &Actualizar
gui-button-install = &Instalar
gui-select-folder-first = Primero usa Examinar para seleccionar la carpeta del juego.
gui-button-install-from-file = Instalar desde arc&hivo...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Selecciona el archivo loadstone-release.json del mod
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|Archivos JSON (*.json)|*.json|Todos los archivos (*.*)|*.*
gui-button-uninstall = &Desinstalar
gui-button-launch = I&niciar el juego
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Inicia el juego con el mod cargado.
gui-launch-unavailable-description = Disponible cuando el mod esté instalado aquí.
gui-button-change-options = Cambiar &opciones de instalación...
gui-change-options-description = Vuelve a hacer las preguntas de instalación del mod y reinstala la versión más reciente con tus respuestas.
gui-button-settings = Con&figuración...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Procesando... { $percent } %
gui-status-fetching-releases = Obteniendo la lista de versiones...
# $error is an error message.
gui-release-list-error = No se pudo obtener la lista de versiones: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = ¿Instalar la última versión publicada en su lugar?
gui-release-list-error-title = Lista de versiones no disponible
gui-no-releases = El repositorio de este mod todavía no tiene versiones publicadas.
gui-no-releases-title = No hay versiones publicadas
gui-choose-version = Selecciona la versión que quieres instalar:
gui-choose-version-title = Elegir versión
gui-confirm-uninstall = ¿Desinstalar { $name }?
gui-confirm-uninstall-title = Confirmar desinstalación
gui-status-working = Procesando...
gui-status-op-failed = La operación falló.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = No se puede iniciar
gui-op-failed-title = Error en la operación
# Title of the message shown when an operation finished.
gui-op-done-title = Listo

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = Está disponible la versión { $version } de { $app } (tienes la { $current }). ¿Actualizar y reiniciar ahora?
gui-self-update-title = Actualización disponible
gui-status-downloading-update = Descargando la actualización...
gui-status-update-failed = La actualización falló.
gui-update-failed-title = Error en la actualización
gui-status-update-installed = Actualización instalada.
gui-update-installed = La actualización está instalada. La aplicación se reiniciará ahora.
gui-update-installed-title = Actualización instalada

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Configuración de Loadstone no disponible: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Configuración de { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Opciones del mod
gui-mod-options-after-install = Las opciones del mod estarán disponibles cuando esté instalado.
gui-status-setting-saved = Ajuste guardado.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Ajuste guardado. { $note }
gui-setting-not-changed-title = Ajuste sin cambios
gui-status-no-settings-changed = No se cambió ningún ajuste.

## Loadstone settings dialog

gui-loadstone-settings-title = Configuración de Loadstone
gui-accounts-label = &Cuentas:
gui-accounts-description = Inicios de sesión usados para descargar mods de repositorios privados.
gui-button-sign-in = &Iniciar sesión...
gui-button-add-token = Agregar &token...
gui-button-remove-account = &Quitar cuenta
gui-button-set-default = Establecer como &predeterminada
# "gh auth token" is a command, keep it.
gui-add-token-description = Agrega una cuenta a partir de un token que ya tengas, por ejemplo uno obtenido con el comando gh auth token de la CLI de GitHub.
gui-rules-label = &Reglas de cuenta:
gui-rules-description = Qué cuenta usar para un repositorio o para todos los repositorios de un propietario. Si no hay ninguna regla, se usa la cuenta predeterminada.
gui-button-add-rule = Agregar r&egla...
gui-button-remove-rule = Q&uitar regla
gui-button-tester-password = Contra&seña de tester...
gui-tester-password-description = Para testers privados: escribe la contraseña que te dieron para ver los mods exclusivos para testers y recibir versiones beta. Puedes agregar más de una. Déjala vacía para dejar de participar en las pruebas.
gui-tester-password-prompt-saved = Tienes contraseñas de tester guardadas. Escribe otra para agregarla o deja este campo vacío para olvidarlas todas y dejar de participar en las pruebas.
gui-tester-password-prompt = Escribe la contraseña de tester que te dieron.
gui-tester-password-title = Contraseña de tester
gui-tester-password-not-saved-title = Contraseña de tester no guardada
gui-button-close = Cerr&ar
gui-accounts-unavailable-title = Cuentas no disponibles
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } en { $site }, predeterminada
    [missing] { $account }, { $username } en { $site }, falta el token (vuelve a iniciar sesión)
    [default-missing] { $account }, { $username } en { $site }, predeterminada, falta el token (vuelve a iniciar sesión)
   *[none] { $account }, { $username } en { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = No hay cuentas. Usa Iniciar sesión para agregar una.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } usa { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = No hay reglas.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Pega un token de { $site }. Se verificará con { $site } y después se guardará en el Administrador de credenciales de Windows.
gui-add-token-title = Agregar token
gui-status-account-added = Cuenta { $account } agregada.
gui-token-not-added-title = Token no agregado
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = ¿Quitar la cuenta { $account }? Loadstone olvidará su token y las reglas que la usen. Para revocar también el acceso de Loadstone, usa Applications en la configuración de { $site }.
gui-remove-account-title = Quitar cuenta
gui-account-not-removed-title = Cuenta no quitada
gui-default-not-changed-title = Cuenta predeterminada sin cambios
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Repositorio (github:owner/repo) o todos los repositorios de un propietario (github:owner/*):
gui-add-rule-title = Agregar regla de cuenta
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = ¿Qué cuenta quieres usar?
gui-rule-not-added-title = Regla no agregada
gui-rule-not-removed-title = Regla no quitada

## Signing in

gui-sign-in-no-sites = Ningún sitio admite el inicio de sesión.
gui-sign-in-title = Iniciar sesión
gui-sign-in-which-site = ¿En qué sitio quieres iniciar sesión?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Iniciar sesión en { $site }
gui-sign-in-requesting = Solicitando un código de inicio de sesión a { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &Código de inicio de sesión:
gui-button-copy-code = Co&piar código
gui-button-open-sign-in-page = &Abrir la página de inicio de sesión de { $site }
gui-button-cancel = Cancelar
gui-sign-in-code-copied = Código copiado. Abre la página de inicio de sesión y pégalo allí.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Abre { $url }, escribe el código que aparece abajo y autoriza a Loadstone. Esta ventana se cerrará sola cuando termines.
gui-sign-in-code-expired = El código de inicio de sesión caducó antes de introducirse. Vuelve a empezar.
# $account is the account's name.
gui-status-signed-in = Sesión iniciada como { $account }.
gui-signed-in = Sesión iniciada en { $site } como { $account }.
gui-signed-in-title = Sesión iniciada
gui-sign-in-failed-title = Error al iniciar sesión
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = ¿Iniciar sesión ahora con una cuenta que tenga acceso?
gui-offer-sign-in-title = Inicia sesión para continuar

## Startup

gui-startup-error-title = Error al iniciar Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Administrador de mods Loadstone

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Instalado: { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Instalado: { $version } (canal { $channel })
page-catalog-not-installed = No instalado
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Instalado: { $version } en { $count } copia
   *[other] Instalado: { $version } en { $count } copias
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Instalado en { $count } copia (con versiones distintas)
   *[other] Instalado en { $count } copias (con versiones distintas)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Instalado fuera de Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Instalado, pero no aparece en los registros configurados.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (vista previa para testers)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = No hay registros configurados; solo se muestran los mods instalados.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] Se oculta { $count } mod no disponible para este equipo.
   *[other] Se ocultan { $count } mods no disponibles para este equipo.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = No se pudieron cargar los registros: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = No se encontró en los registros configurados: { $error }
page-note-no-release-metadata = La última versión publicada todavía no tiene metadatos de Loadstone, así que no se pudo determinar cuál es la versión más reciente.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Nota: las copias de { $game } comparten una misma carpeta de mods. Instalar o desinstalar un mod en una copia afecta a las demás; solo el cargador de mods es independiente en cada copia.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Requiere { $name } (se instala automáticamente; versión actual: { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Requiere { $name } (se instala automáticamente).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Versión { $version } instalada (canal dev).
page-status-up-to-date = Actualizado (versión { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Actualizado (versión { $version }, más reciente que la última versión publicada, { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Actualización disponible: de { $version } a { $latest }.
page-status-installed = Versión { $version } instalada.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Instalado fuera de Loadstone (versión desconocida). Instala la versión { $latest } para que Loadstone administre esta copia.
page-status-foreign = Instalado fuera de Loadstone (versión desconocida). Instálalo para que Loadstone administre esta copia.
page-status-ready = Listo para instalar la versión { $latest }.
page-status-not-installed = No instalado.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = No disponible en este equipo. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Listo para instalar la versión { $latest }. No se encontró la carpeta del juego; usa Examinar para seleccionarla.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = No instalado. No se encontró la carpeta del juego; usa Examinar para seleccionarla.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Usa Examinar para seleccionar la carpeta. No disponible en este equipo. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Usa Examinar para seleccionar la carpeta. Listo para instalar la versión { $latest }. No se encontró la carpeta del juego; usa Examinar para seleccionarla.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Usa Examinar para seleccionar la carpeta. No instalado. No se encontró la carpeta del juego; usa Examinar para seleccionarla.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Los ajustes se podrán editar después de la instalación.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Copia de { $distribution }, versión { $version } instalada, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Copia de { $distribution }, mod instalado fuera de Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Copia de { $distribution }, mod no instalado, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Copia en { $folder }, versión { $version } instalada
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Copia en { $folder }, mod instalado fuera de Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Copia en { $folder }, mod no instalado
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Todavía no se encontró ninguna copia; usa Examinar para seleccionar la carpeta del juego.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Otra carpeta...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Independiente
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Canal { $channel } (lo último de la rama { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Canal { $channel } (compilación de desarrollo)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (versión preliminar)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (versión preliminar)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Acción "{ $action }" completada.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Descargando { $file }...
page-self-update-installed = Actualización verificada e instalada.
page-tester-passwords-removed = Contraseñas de tester eliminadas. Los mods exclusivos para testers y las versiones beta vuelven a estar ocultos.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } en { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = no hay registros configurados
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = no se conoce ningún repositorio de origen para "{ $id }"
# $id is a mod id.
page-error-not-installed-no-registries = "{ $id }" no está instalado y no hay registros configurados
# $id is a mod id.
page-error-not-installed-unresolved = "{ $id }" no está instalado y no se pudo localizar
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = "{ $id }" no está instalado y no se pudo localizar: { $error }
page-error-tester-password-wrong = Esa no es una contraseña de tester de ninguno de tus registros ni de sus mods.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = el almacenamiento de cuentas no está disponible
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = "{ $value }" no es un número
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = no es un número finito

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = el hash del archivo de { $id } no coincide: se esperaba { $expected } y se obtuvo { $actual }. No se instalará.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = el hash del archivo de { $id } ({ $artifact }) no coincide: se esperaba { $expected } y se obtuvo { $actual }. No se instalará.
engine-hash-verified = Hash del archivo verificado.
engine-hash-none = No hay hash que verificar para este origen (instalación local o de desarrollo).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Quitando la versión { $version } instalada anteriormente ({ $count } archivo).
   *[other] Quitando la versión { $version } instalada anteriormente ({ $count } archivos).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Advertencia: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Advertencia: no se pudieron registrar los originales pendientes de restaurar: { $error }
engine-install-failed-rolling-back = La instalación falló; quitando los archivos escritos hasta ahora.
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } instalado.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Instalación cancelada.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = "{ $id }" no es una opción de instalación de este mod (opciones: { $options })
engine-option-unknown-none = "{ $id }" no es una opción de instalación de este mod (opciones: ninguna)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = "{ $value }" no es una opción válida para { $option } (opciones: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = cancelado: no se eligió ninguna opción

## Mod settings

# { $label } is the setting's name.
engine-setting-default = El ajuste "{ $label }" empieza con su valor predeterminado; puedes cambiarlo más adelante con el comando de configuración.
# { $path } is the settings file.
engine-settings-written = Configuración guardada en { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = "{ $action }" no es una acción de { $id } (disponibles: { $available })
engine-action-unknown-none = "{ $action }" no es una acción de { $id } (disponibles: ninguna)
# { $label } is the action's name, as on its button.
engine-action-unavailable = "{ $label }" no está disponible en este momento (no se cumple su condición previa)
engine-action-running = Ejecutando "{ $label }"...
engine-action-finished = Acción "{ $label }" completada.
engine-no-launch-steps = { $id } no declara pasos de inicio para esta plataforma
# Summary after starting the game with a mod.
engine-launched = { $id } iniciado.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } es un vínculo a una copia de trabajo de desarrollo; no se modificarán ni quitarán archivos a través de él. Quita primero el vínculo si de verdad quieres una instalación administrada aquí.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = No se quita { $path }: está fuera de las carpetas del mod.
engine-legacy-link = No se quita { $path }: se llega a él a través de un vínculo.
engine-legacy-shared = No se quita { $path }: lo usa otro paquete instalado.
engine-legacy-removed = Se quitó el archivo sobrante { $path }
# { $error } is a system error message.
engine-legacy-remove-failed = Advertencia: no se pudo quitar { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = No se encontró un archivo necesario: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = No se cumple un requisito del paso { $step }.
engine-step-skipped = Se omitió el paso { $step }.
engine-cancelled-at-step = cancelado en el paso { $step }
engine-extracting = Extrayendo archivos...
engine-placed-files = { $count ->
    [one] Se colocó { $count } archivo.
   *[other] Se colocaron { $count } archivos.
}
engine-kept-existing = Se conservó el archivo existente { $path } (no se sobrescribió; puede que sea más reciente).
engine-file-created = Se creó y actualizó { $path }.
engine-file-updated = Se actualizó { $path }.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = cancelado: no se eligió ninguna carpeta para "{ $prompt }"
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Copiado al portapapeles: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] Se combinó { $count } arquitectura en { $file }.
   *[other] Se combinaron { $count } arquitecturas en { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = no se puede iniciar: falta { $path }
engine-program-start-failed = no se pudo iniciar { $path }
engine-program-started = Se inició { $path }.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = no se pudo abrir { $url }
engine-url-opened = Se abrió { $url }.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = Estos paquetes todavía necesitan { $id }: { $dependents }. Desinstálalos primero.
engine-removing-files = { $count ->
    [one] Quitando { $count } archivo.
   *[other] Quitando { $count } archivos.
}
engine-purge-question = ¿Quitar también la configuración y las preferencias guardadas?
engine-purge-done = Se quitó la configuración guardada.
engine-dependency-unneeded = Ningún mod instalado necesita ya { $id }; también puedes desinstalarlo.
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } desinstalado.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Usando el original ya guardado en { $path }.
engine-originals-kept = { $count ->
    [one] Se guardó una copia de { $count } archivo original del juego.
   *[other] Se guardó una copia de { $count } archivos originales del juego.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Advertencia: no se pudo restaurar el original de { $path } ahora ({ $error }). Se restaurará cuando este mod se actualice o se desinstale.
engine-original-restored = Se restauró el original de { $path }.
# { $backup } is where the kept original should have been.
engine-original-missing = Advertencia: falta el original de { $path } ({ $backup }); el archivo se deja como está.
engine-original-changed = { $path } cambió desde que se instaló este mod (¿una actualización del juego?); se conserva el archivo más reciente.
engine-originals-restored = { $count ->
    [one] Se restauró { $count } archivo original del juego.
   *[other] Se restauraron { $count } archivos originales del juego.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] no se pudo restaurar { $count } archivo original del juego; cierra el juego y vuelve a intentarlo.
   *[other] no se pudieron restaurar { $count } archivos originales del juego; cierra el juego y vuelve a intentarlo.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Actualizando la copia de { $distribution } en { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = "{ $id }" está instalado en más de una copia de { $game }: { $copies }. Usa --game-dir para indicar qué copia actualizar.
engine-many-copies = "{ $id }" está instalado en más de una copia de { $game }: { $copies }. Usa --game-dir para indicar qué copia.
engine-not-game-folder = { $path } no parece una carpeta de { $game } (no se encontró ninguno de los archivos esperados)
engine-game-found = Se encontró { $game } en { $path }
engine-game-not-found = No se pudo encontrar { $game } automáticamente.
# Title of the folder picker.
engine-game-where = ¿Dónde está instalado { $game }?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = no se pudo encontrar { $game } automáticamente; usa --game-dir o elige su carpeta
# { $path } is a game folder.
engine-not-installed-copy = "{ $id }" no está instalado en la copia de { $game } ubicada en { $path }
engine-not-installed = "{ $id }" no está instalado para { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = { $name } no se puede instalar en este equipo. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = la copia de { $distribution } de { $game } no es compatible. { $reason }
engine-distribution-untested = Nota: la copia de { $distribution } de { $game } no se ha probado con este mod.
engine-no-matching-artifact = ningún archivo de la versión publicada corresponde a esta plataforma, arquitectura o distribución
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Este mod solo está disponible en { $platform }.
engine-platform-only-two = Este mod solo está disponible en { $first } y { $second }.
engine-platform-only-three = Este mod solo está disponible en { $first }, { $second } y { $third }.
engine-platform-needs-apple-silicon = En { $platform }, este mod necesita un procesador Apple Silicon.
engine-platform-needs-arm = En { $platform }, este mod necesita un procesador ARM.
engine-platform-needs-x64 = En { $platform }, este mod necesita un procesador Intel o AMD.
engine-game-platform-unsupported = { $game } no es compatible con { $platform } aquí.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } está actualizado ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } está actualizado (la versión { $installed } es más reciente que la última versión publicada, { $latest }).
engine-installed-newer = Está instalado { $name } { $installed }, una versión más reciente que la última publicada a la que tienes acceso ahora ({ $latest }). No se cambió nada. Para instalar una versión anterior, elige esa versión explícitamente.
# { $from } and { $to } are versions.
engine-updating = Actualizando { $name } de { $from } a { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    ¿Instalar { $name } desde lo último de la rama { $branch } ({ $version })?

    Las compilaciones de desarrollo no tienen un hash fijado; estás confiando en el contenido actual del repositorio.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Notas de la versión de { $name } { $version }:

    { $notes }

    ¿Instalar ahora?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Obteniendo la información de la versión { $tag } de { $source }...
engine-fetching-latest = Obteniendo la información de la última versión publicada de { $source }...
engine-using-local-artifact = Usando el archivo local { $path }
# { $file } is a download's file name.
engine-using-cached = Usando { $file }, ya descargado.
engine-downloading = Descargando { $file }...
engine-dependency-present = La dependencia { $id } { $version } ya está instalada.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Instalando la dependencia { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = no se proporcionó ningún token
core-sign-in-cancelled = Inicio de sesión cancelado.
core-sign-in-expired = El código de inicio de sesión caducó antes de introducirse. Vuelve a empezar.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = "{ $pattern }" no es un origen (github:owner/repo) ni un comodín de propietario (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = no se pudo guardar el token en el almacén de credenciales del sistema
core-secrets-remove-failed = no se pudo quitar el token del almacén de credenciales del sistema

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = la versión { $tag } de { $source } no incluye el archivo { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = la última versión de { $source } no incluye el archivo { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = la versión { $tag } no incluye el archivo loadstone-release.json (o no se puede acceder a él)
core-github-sign-in-cancelled = Se canceló el inicio de sesión en GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub rechazó el inicio de sesión: { $details }
core-github-sign-in-refused-no-details = GitHub rechazó el inicio de sesión sin dar detalles
core-github-token-rejected = GitHub no aceptó el token

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } no admite el inicio de sesión
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = "{ $source }" no es un origen con el formato { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = No se encontró { $source }. Si es un repositorio privado, inicia sesión con una cuenta que tenga acceso (Configuración de Loadstone) o define GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = se rechazó el token de { $account }; puede que haya caducado o se haya revocado
core-source-token-unreachable = no se puede acceder a { $source } con el token de { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = la descarga de { $url } devolvió el código HTTP { $status }
core-fetch-request-failed = error en la solicitud: { $url }
core-fetch-download-failed = error en la descarga: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = error de lectura
core-fetch-read-error-download = error de lectura durante la descarga

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = no hay ninguna forma de extracción para esta plataforma o distribución
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } es un vínculo a una copia de trabajo de desarrollo. Actualiza esa copia con git o quita el vínculo antes de instalar.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = este archivo comprimido no contiene los archivos esperados (ninguna entrada corresponde a una forma de extracción)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = el registro "{ $source }" no tiene el formato { $formats } ni es una carpeta existente
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } no tiene una carpeta loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = No se pudo actualizar { $source } ({ $error }); se usará la copia en caché.
core-registry-fetch-failed = no se pudo obtener el registro { $source }
# $id is a mod's id.
core-registry-package-not-found = no se encontró el paquete "{ $id }" en ningún registro

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = "{ $key }" es un valor booleano; usa true o false
core-setting-not-number = "{ $key }" necesita un número
core-setting-too-small = "{ $key }" debe ser como mínimo { $min }
core-setting-too-large = "{ $key }" debe ser como máximo { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = "{ $key }" debe ser uno de estos valores: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Acceso de tester desbloqueado para los mods de un registro: se muestran los mods exclusivos para testers, y las instalaciones y actualizaciones reciben versiones beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Acceso de tester desbloqueado para los mods de un registro y para { $mods }: se muestran los mods exclusivos para testers, y las instalaciones y actualizaciones reciben versiones beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Acceso de tester desbloqueado para { $mods }: se muestran los mods exclusivos para testers, y las instalaciones y actualizaciones reciben versiones beta.
core-tester-save-failed = no se pudo guardar la contraseña de tester
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = La versión { $tag } no tiene metadatos de Loadstone válidos ({ $error }); se usará la última versión estable.
core-tester-beta-lookup-failed = No se pudieron buscar versiones beta ({ $error }); se usará la última versión estable.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = la actualización descargada no superó la verificación del hash (se esperaba { $expected } y se obtuvo { $actual }); no se instaló
core-update-translocated = macOS está ejecutando esta aplicación desde una copia temporal de solo lectura, así que no puede actualizarse. Muévela a tu carpeta Aplicaciones, ábrela desde allí y vuelve a actualizar.
core-update-on-disk-image = esta aplicación se está ejecutando desde su imagen de disco, así que no puede actualizarse. Cópiala a tu carpeta Aplicaciones, ábrela desde allí y vuelve a actualizar.
# $path is the folder the app is in.
core-update-no-write = no se puede escribir junto a { $path } (¿falta de permisos?), así que la aplicación no puede actualizarse. Descarga la nueva versión desde la página de la versión publicada.
core-update-no-staging = no se puede escribir junto a { $path } (¿falta de permisos?). Descarga la nueva versión desde la página de la versión publicada
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = la actualización es de otra aplicación ({ $got }, se esperaba { $expected }); no se instaló
core-update-move-aside-app = no se pudo apartar la aplicación actual
core-update-move-in-app = no se pudo colocar la nueva aplicación en su lugar
core-update-move-aside-exe = no se pudo apartar el ejecutable actual
core-update-move-in-exe = no se pudo colocar el nuevo ejecutable en su lugar
