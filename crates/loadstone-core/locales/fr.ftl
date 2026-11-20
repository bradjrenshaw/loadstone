# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Ce mod nécessite une version plus récente de Loadstone. Mettez Loadstone à jour, puis réessayez.

## Loadstone settings

pref-language = Langue
pref-language-description = La langue d'affichage de Loadstone et des mods traduits.
language-system = Langue du système
pref-accounts = Comptes
pref-accounts-description = Connexions utilisées pour télécharger des mods depuis des dépôts privés.
pref-account-rules = Règles de compte
pref-account-rules-description = Le compte à utiliser pour un dépôt ou un propriétaire.
pref-try-other-accounts = Essayer mes autres comptes quand un téléchargement est refusé
pref-try-other-accounts-description = Si un dépôt est introuvable ou que l'accès est refusé, essayer les autres comptes de ce site avant d'abandonner.
pref-tester-passwords = Mots de passe testeur
pref-tester-passwords-description = Débloquent les mods réservés aux testeurs et les versions bêta, pour un registre ou pour certains mods. À définir avec le bouton Mot de passe testeur.
pref-download-account = Compte de téléchargement
pref-download-account-description = Le compte utilisé pour télécharger ce mod. Automatique applique vos règles de compte, puis votre compte par défaut.
pref-download-account-automatic = Automatique (règles de compte, puis compte par défaut)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Paramètres de Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Comptes pour les dépôts privés et options de Loadstone
gui-menu-exit = &Quitter
# Menu bar title.
gui-menu-tools = &Outils
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Une opération est toujours en cours. Fermer maintenant risque de l'interrompre. Fermer quand même ?
gui-close-while-running-title = Opération en cours
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Chargement...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problème pendant l'opération
gui-button-retry = &Réessayer
gui-button-skip = &Ignorer
gui-button-cancel-problem = &Annuler
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Options d'installation

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (noyau { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mods :
# Button that opens the selected mod's page.
gui-button-details = &Détails
gui-button-refresh = &Actualiser
gui-button-loadstone-settings = Paramètres de &Loadstone...
gui-status-fetching-catalog = Récupération du catalogue de mods...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Chargement de la liste des mods...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Impossible de charger la liste des mods. Appuyez sur Actualiser pour réessayer.
gui-status-catalog-failed = Échec de la récupération du catalogue.
gui-catalog-error-title = Impossible de charger le catalogue de mods
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Aucun mod disponible.
gui-status-catalog-loaded = { $count ->
    [one] Catalogue chargé : { $count } mod.
   *[other] Catalogue chargé : { $count } mods.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Chargement de { $mod_id }...
gui-status-mod-load-failed = Impossible de charger la page du mod.
gui-mod-error-title = Impossible de charger le mod
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Copie du jeu à gérer :
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Copie de { $game } à gérer :
gui-button-back = &Retour à la liste des mods
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name } par { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = Dossier du &jeu :
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = Dossi&er de { $game } :
gui-button-browse = &Parcourir...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Sélectionnez le dossier du jeu
gui-browse-game-prompt-named = Sélectionnez le dossier de { $game }
gui-description-label = Description :
# Label of the log where operations report their progress.
gui-activity-label = Activité :
gui-button-update = &Mettre à jour
gui-button-install = &Installer
gui-select-folder-first = Sélectionnez d'abord le dossier du jeu avec Parcourir.
gui-button-install-from-file = Installer depuis un &fichier...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Sélectionnez le fichier loadstone-release.json du mod
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|Fichiers JSON (*.json)|*.json|Tous les fichiers (*.*)|*.*
gui-button-uninstall = &Désinstaller
gui-button-launch = &Lancer le jeu
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Lance le jeu avec le mod chargé.
gui-launch-unavailable-description = Disponible une fois le mod installé ici.
gui-button-change-options = Modifier les &options d'installation...
gui-change-options-description = Repose les questions d'installation du mod et réinstalle la dernière version avec vos réponses.
gui-button-settings = Paramè&tres...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Opération en cours... { $percent } %
gui-status-fetching-releases = Récupération de la liste des versions publiées...
# $error is an error message.
gui-release-list-error = Impossible de récupérer la liste des versions publiées : { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Installer plutôt la dernière version publiée ?
gui-release-list-error-title = Liste des versions indisponible
gui-no-releases = Le dépôt de ce mod n'a encore publié aucune version.
gui-no-releases-title = Aucune version publiée
gui-choose-version = Sélectionnez la version à installer :
gui-choose-version-title = Choisir la version
gui-confirm-uninstall = Désinstaller { $name } ?
gui-confirm-uninstall-title = Confirmer la désinstallation
gui-status-working = Opération en cours...
gui-status-op-failed = L'opération a échoué.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Lancement impossible
gui-op-failed-title = Échec de l'opération
# Title of the message shown when an operation finished.
gui-op-done-title = Terminé

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = La version { $version } de { $app } est disponible (vous avez la version { $current }). Mettre à jour et redémarrer maintenant ?
gui-self-update-title = Mise à jour disponible
gui-status-downloading-update = Téléchargement de la mise à jour...
gui-status-update-failed = La mise à jour a échoué.
gui-update-failed-title = Échec de la mise à jour
gui-status-update-installed = Mise à jour installée.
gui-update-installed = La mise à jour est installée. L'application va maintenant redémarrer.
gui-update-installed-title = Mise à jour installée

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Paramètres de Loadstone indisponibles : { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Paramètres de { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label } :
# Group of the mod's own settings.
gui-mod-options-group = Options du mod
gui-mod-options-after-install = Les options du mod seront disponibles une fois celui-ci installé.
gui-status-setting-saved = Paramètre enregistré.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Paramètre enregistré. { $note }
gui-setting-not-changed-title = Paramètre non modifié
gui-status-no-settings-changed = Aucun paramètre modifié.

## Loadstone settings dialog

gui-loadstone-settings-title = Paramètres de Loadstone
gui-accounts-label = &Comptes :
gui-accounts-description = Connexions utilisées pour télécharger des mods depuis des dépôts privés.
gui-button-sign-in = Se co&nnecter...
gui-button-add-token = Ajouter un &jeton...
gui-button-remove-account = &Supprimer le compte
gui-button-set-default = Définir par &défaut
# "gh auth token" is a command, keep it.
gui-add-token-description = Ajoutez un compte à partir d'un jeton que vous possédez déjà, par exemple obtenu avec la commande gh auth token de GitHub CLI.
gui-rules-label = &Règles de compte :
gui-rules-description = Le compte à utiliser pour un dépôt, ou pour tous les dépôts d'un propriétaire. Sans règle, le compte par défaut est utilisé.
gui-button-add-rule = &Ajouter une règle...
gui-button-remove-rule = Suppr&imer la règle
gui-button-tester-password = &Mot de passe testeur...
gui-tester-password-description = Pour les testeurs privés : saisissez le mot de passe qui vous a été fourni pour voir les mods réservés aux testeurs et obtenir les versions bêta. Vous pouvez en ajouter plusieurs. Laissez le champ vide pour arrêter les tests.
gui-tester-password-prompt-saved = Vous avez des mots de passe testeur enregistrés. Saisissez-en un autre pour l'ajouter, ou laissez ce champ vide pour tous les oublier et arrêter les tests.
gui-tester-password-prompt = Saisissez le mot de passe testeur qui vous a été fourni.
gui-tester-password-title = Mot de passe testeur
gui-tester-password-not-saved-title = Mot de passe testeur non enregistré
gui-button-close = &Fermer
gui-accounts-unavailable-title = Comptes indisponibles
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } sur { $site }, par défaut
    [missing] { $account }, { $username } sur { $site }, jeton manquant (reconnectez-vous)
    [default-missing] { $account }, { $username } sur { $site }, par défaut, jeton manquant (reconnectez-vous)
   *[none] { $account }, { $username } sur { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Aucun compte. Utilisez Se connecter pour en ajouter un.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } utilise { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Aucune règle.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Collez un jeton { $site }. Il sera vérifié auprès de { $site }, puis enregistré dans le Gestionnaire d'identification Windows.
gui-add-token-title = Ajouter un jeton
gui-status-account-added = Compte { $account } ajouté.
gui-token-not-added-title = Jeton non ajouté
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Supprimer le compte { $account } ? Loadstone oubliera son jeton et toutes les règles qui l'utilisent. Pour révoquer aussi l'accès de Loadstone, utilisez la page Applications des paramètres de { $site }.
gui-remove-account-title = Supprimer le compte
gui-account-not-removed-title = Compte non supprimé
gui-default-not-changed-title = Compte par défaut non modifié
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Dépôt (github:owner/repo) ou tous les dépôts d'un propriétaire (github:owner/*) :
gui-add-rule-title = Ajouter une règle de compte
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Quel compte utiliser ?
gui-rule-not-added-title = Règle non ajoutée
gui-rule-not-removed-title = Règle non supprimée

## Signing in

gui-sign-in-no-sites = Aucun site ne prend en charge la connexion.
gui-sign-in-title = Connexion
gui-sign-in-which-site = Se connecter à quel site ?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Connexion à { $site }
gui-sign-in-requesting = Demande d'un code de connexion à { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &Code de connexion :
gui-button-copy-code = Co&pier le code
gui-button-open-sign-in-page = &Ouvrir la page de connexion de { $site }
gui-button-cancel = Annuler
gui-sign-in-code-copied = Code copié. Ouvrez la page de connexion et collez-le.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Ouvrez { $url }, saisissez le code ci-dessous et autorisez Loadstone. Cette fenêtre se fermera d'elle-même quand vous aurez terminé.
gui-sign-in-code-expired = Le code de connexion a expiré avant d'être saisi. Veuillez recommencer.
# $account is the account's name.
gui-status-signed-in = Connecté en tant que { $account }.
gui-signed-in = Connecté à { $site } en tant que { $account }.
gui-signed-in-title = Connecté
gui-sign-in-failed-title = Échec de la connexion
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Se connecter maintenant avec un compte qui y a accès ?
gui-offer-sign-in-title = Connectez-vous pour continuer

## Startup

gui-startup-error-title = Erreur au démarrage de Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Gestionnaire de mods Loadstone

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Installé, version { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Installé, version { $version } (canal { $channel })
page-catalog-not-installed = Non installé
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Installé, version { $version }, sur { $count } copie
   *[other] Installé, version { $version }, sur { $count } copies
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Installé sur { $count } copie (versions différentes)
   *[other] Installé sur { $count } copies (versions différentes)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Installé hors de Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Installé, mais absent des registres configurés.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (aperçu testeur)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Aucun registre n'est configuré ; seuls les mods installés sont affichés.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] { $count } mod non disponible pour cet ordinateur est masqué.
   *[other] { $count } mods non disponibles pour cet ordinateur sont masqués.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Impossible de charger les registres : { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Introuvable dans les registres configurés : { $error }
page-note-no-release-metadata = La dernière version publiée n'a pas encore de métadonnées Loadstone ; impossible de déterminer la version la plus récente.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Remarque : les copies de { $game } partagent un même dossier de mods. Installer ou désinstaller un mod pour une copie affecte les autres ; seul le chargeur de mods est propre à chaque copie.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Nécessite { $name } (installé automatiquement, actuellement en version { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Nécessite { $name } (installé automatiquement).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Version { $version } installée (canal dev).
page-status-up-to-date = À jour (version { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = À jour (version { $version }, plus récente que la dernière version publiée, { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Mise à jour disponible : de { $version } vers { $latest }.
page-status-installed = Version { $version } installée.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Installé hors de Loadstone (version inconnue). Installez la version { $latest } pour que Loadstone gère cette copie.
page-status-foreign = Installé hors de Loadstone (version inconnue). Installez-le pour que Loadstone gère cette copie.
page-status-ready = Prêt à installer la version { $latest }.
page-status-not-installed = Non installé.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Non disponible sur cet ordinateur. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Prêt à installer la version { $latest }. Dossier du jeu introuvable ; sélectionnez-le avec Parcourir.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Non installé. Dossier du jeu introuvable ; sélectionnez-le avec Parcourir.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Sélectionnez le dossier avec Parcourir. Non disponible sur cet ordinateur. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Sélectionnez le dossier avec Parcourir. Prêt à installer la version { $latest }. Dossier du jeu introuvable ; sélectionnez-le avec Parcourir.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Sélectionnez le dossier avec Parcourir. Non installé. Dossier du jeu introuvable ; sélectionnez-le avec Parcourir.
# Shown with a mod's settings before it is installed.
page-settings-after-install = Les paramètres seront modifiables après l'installation.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Copie { $distribution }, version { $version } installée, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Copie { $distribution }, mod installé hors de Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Copie { $distribution }, mod non installé, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Copie dans { $folder }, version { $version } installée
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Copie dans { $folder }, mod installé hors de Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Copie dans { $folder }, mod non installé
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Aucune copie trouvée pour l'instant ; sélectionnez le dossier du jeu avec Parcourir.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Autre dossier...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Autonome
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Canal { $channel } (dernière version de la branche { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Canal { $channel } (version de développement)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (préversion)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (préversion)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Action « { $action } » terminée.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Téléchargement de { $file }...
page-self-update-installed = Mise à jour vérifiée et installée.
page-tester-passwords-removed = Mots de passe testeur supprimés. Les mods réservés aux testeurs et les versions bêta sont de nouveau masqués.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } sur { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = aucun registre n'est configuré
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = aucun dépôt source n'est connu pour « { $id } »
# $id is a mod id.
page-error-not-installed-no-registries = « { $id } » n'est pas installé et aucun registre n'est configuré
# $id is a mod id.
page-error-not-installed-unresolved = « { $id } » n'est pas installé et n'a pas pu être trouvé
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = « { $id } » n'est pas installé et n'a pas pu être trouvé : { $error }
page-error-tester-password-wrong = Ce mot de passe testeur ne correspond à aucun de vos registres ni à leurs mods.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = le stockage des comptes est indisponible
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = « { $value } » n'est pas un nombre
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = ce n'est pas un nombre fini

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = l'empreinte du fichier de { $id } ne correspond pas : attendu { $expected }, obtenu { $actual }. Installation refusée.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = l'empreinte du fichier de { $id } ({ $artifact }) ne correspond pas : attendu { $expected }, obtenu { $actual }. Installation refusée.
engine-hash-verified = Empreinte du fichier vérifiée.
engine-hash-none = Aucune empreinte à vérifier pour cette source (installation locale ou de développement).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Suppression de la version { $version } précédemment installée ({ $count } fichier).
   *[other] Suppression de la version { $version } précédemment installée ({ $count } fichiers).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Avertissement : { $message }
# { $error } is a system error message.
engine-warning-record-originals = Avertissement : impossible d'enregistrer les fichiers originaux restant à restaurer : { $error }
engine-install-failed-rolling-back = Échec de l'installation ; suppression des fichiers déjà écrits.
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } installé.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Installation annulée.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = « { $id } » n'est pas une option d'installation de ce mod (options : { $options })
engine-option-unknown-none = « { $id } » n'est pas une option d'installation de ce mod (options : aucune)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = « { $value } » n'est pas un choix possible pour { $option } (choix : { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label } : { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option } : { $choice }
engine-option-cancelled = annulé : aucun choix effectué

## Mod settings

# { $label } is the setting's name.
engine-setting-default = Le paramètre « { $label } » prend sa valeur par défaut ; vous pourrez le modifier plus tard avec la commande des paramètres.
# { $path } is the settings file.
engine-settings-written = Paramètres enregistrés dans { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = « { $action } » n'est pas une action de { $id } (disponibles : { $available })
engine-action-unknown-none = « { $action } » n'est pas une action de { $id } (disponibles : aucune)
# { $label } is the action's name, as on its button.
engine-action-unavailable = « { $label } » n'est pas disponible pour le moment (sa condition préalable n'est pas remplie)
engine-action-running = Exécution de « { $label } »...
engine-action-finished = Action « { $label } » terminée.
engine-no-launch-steps = { $id } ne déclare aucune étape de lancement pour cette plateforme
# Summary after starting the game with a mod.
engine-launched = { $id } lancé.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } est un lien vers une copie de travail de développement ; Loadstone ne modifiera ni ne supprimera aucun fichier à travers ce lien. Supprimez d'abord le lien si vous voulez vraiment une installation gérée ici.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = { $path } n'est pas supprimé : il se trouve hors des dossiers du mod.
engine-legacy-link = { $path } n'est pas supprimé : il est accessible par un lien.
engine-legacy-shared = { $path } n'est pas supprimé : un autre paquet installé l'utilise.
engine-legacy-removed = Fichier résiduel { $path } supprimé
# { $error } is a system error message.
engine-legacy-remove-failed = Avertissement : impossible de supprimer { $path } : { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Fichier requis introuvable : { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Une condition de l'étape { $step } n'est pas remplie.
engine-step-skipped = Étape { $step } ignorée.
engine-cancelled-at-step = annulé à l'étape { $step }
engine-extracting = Extraction des fichiers...
engine-placed-files = { $count ->
    [one] { $count } fichier mis en place.
   *[other] { $count } fichiers mis en place.
}
engine-kept-existing = { $path } existant conservé (non écrasé ; il est peut-être plus récent).
engine-file-created = { $path } créé et mis à jour.
engine-file-updated = { $path } mis à jour.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = annulé : aucun dossier choisi pour « { $prompt } »
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Copié dans le presse-papiers : { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] { $count } architecture combinée dans { $file }.
   *[other] { $count } architectures combinées dans { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = lancement impossible : { $path } est introuvable
engine-program-start-failed = impossible de démarrer { $path }
engine-program-started = { $path } démarré.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = impossible d'ouvrir { $url }
engine-url-opened = { $url } ouvert.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } est encore nécessaire pour : { $dependents }. Désinstallez-les d'abord.
engine-removing-files = { $count ->
    [one] Suppression de { $count } fichier.
   *[other] Suppression de { $count } fichiers.
}
engine-purge-question = Supprimer aussi les paramètres et préférences enregistrés ?
engine-purge-done = Paramètres enregistrés supprimés.
engine-dependency-unneeded = { $id } n'est plus nécessaire à aucun mod installé ; vous pouvez aussi le désinstaller.
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } désinstallé.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Utilisation de l'original déjà conservé dans { $path }.
engine-originals-kept = { $count ->
    [one] Copie de { $count } fichier original du jeu conservée.
   *[other] Copie de { $count } fichiers originaux du jeu conservée.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Avertissement : impossible de restaurer l'original de { $path } pour le moment ({ $error }). Il sera remis en place lors de la mise à jour ou de la désinstallation de ce mod.
engine-original-restored = Original de { $path } restauré.
# { $backup } is where the kept original should have been.
engine-original-missing = Avertissement : l'original de { $path } est manquant ({ $backup }) ; le fichier est laissé tel quel.
engine-original-changed = { $path } a été modifié depuis l'installation de ce mod (mise à jour du jeu ?) ; le fichier le plus récent est conservé.
engine-originals-restored = { $count ->
    [one] { $count } fichier original du jeu restauré.
   *[other] { $count } fichiers originaux du jeu restaurés.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] impossible de remettre en place { $count } fichier original du jeu ; fermez le jeu et réessayez.
   *[other] impossible de remettre en place { $count } fichiers originaux du jeu ; fermez le jeu et réessayez.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Mise à jour de la copie { $distribution } dans { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = « { $id } » est installé sur plusieurs copies de { $game } : { $copies }. Indiquez avec --game-dir la copie à mettre à jour.
engine-many-copies = « { $id } » est installé sur plusieurs copies de { $game } : { $copies }. Indiquez la copie avec --game-dir.
engine-not-game-folder = { $path } ne semble pas être un dossier de { $game } (aucun des fichiers attendus n'a été trouvé)
engine-game-found = { $game } trouvé dans { $path }
engine-game-not-found = Impossible de trouver { $game } automatiquement.
# Title of the folder picker.
engine-game-where = Où { $game } est-il installé ?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = impossible de trouver { $game } automatiquement ; utilisez --game-dir ou sélectionnez son dossier
# { $path } is a game folder.
engine-not-installed-copy = « { $id } » n'est pas installé sur la copie de { $game } dans { $path }
engine-not-installed = « { $id } » n'est pas installé pour { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = { $name } ne peut pas être installé sur cet ordinateur. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = la copie { $distribution } de { $game } n'est pas prise en charge. { $reason }
engine-distribution-untested = Remarque : la copie { $distribution } de { $game } n'a pas été testée avec ce mod.
engine-no-matching-artifact = aucun fichier de la version publiée ne correspond à cette plateforme, architecture ou distribution
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Ce mod est disponible uniquement sur { $platform }.
engine-platform-only-two = Ce mod est disponible uniquement sur { $first } et { $second }.
engine-platform-only-three = Ce mod est disponible uniquement sur { $first }, { $second } et { $third }.
engine-platform-needs-apple-silicon = Sur { $platform }, ce mod nécessite un processeur Apple Silicon.
engine-platform-needs-arm = Sur { $platform }, ce mod nécessite un processeur ARM.
engine-platform-needs-x64 = Sur { $platform }, ce mod nécessite un processeur Intel ou AMD.
engine-game-platform-unsupported = { $game } n'est pas pris en charge sur { $platform } ici.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } est à jour ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } est à jour (la version { $installed } est plus récente que la dernière version publiée, { $latest }).
engine-installed-newer = { $name } { $installed } est installé ; cette version est plus récente que la dernière version publiée à laquelle vous avez accès ({ $latest }). Rien n'a été modifié. Pour installer une version plus ancienne, choisissez explicitement cette version.
# { $from } and { $to } are versions.
engine-updating = Mise à jour de { $name } de { $from } vers { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Installer { $name } depuis le dernier commit de la branche { $branch } ({ $version }) ?

    Les versions de développement ne sont pas vérifiées par empreinte ; vous faites confiance au contenu actuel du dépôt. = 
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Notes de version de { $name } { $version } :

    { $notes }

    Installer maintenant ? = 
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Récupération des informations de la version { $tag } depuis { $source }...
engine-fetching-latest = Récupération des informations de la dernière version publiée depuis { $source }...
engine-using-local-artifact = Utilisation du fichier local { $path }
# { $file } is a download's file name.
engine-using-cached = Utilisation de { $file }, déjà téléchargé.
engine-downloading = Téléchargement de { $file }...
engine-dependency-present = Dépendance { $id } { $version } déjà installée.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Installation de la dépendance { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = aucun jeton fourni
core-sign-in-cancelled = Connexion annulée.
core-sign-in-expired = Le code de connexion a expiré avant d'être saisi. Veuillez recommencer.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = « { $pattern } » n'est ni une source (github:owner/repo) ni un modèle de propriétaire (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = impossible d'enregistrer le jeton dans le magasin d'identifiants du système
core-secrets-remove-failed = impossible de supprimer le jeton du magasin d'identifiants du système

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = la version { $tag } de { $source } ne contient pas le fichier { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = la dernière version de { $source } ne contient pas le fichier { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = la version { $tag } ne contient pas de fichier loadstone-release.json (ou il est inaccessible)
core-github-sign-in-cancelled = La connexion a été annulée sur GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = GitHub a refusé la connexion : { $details }
core-github-sign-in-refused-no-details = GitHub a refusé la connexion : aucun détail fourni
core-github-token-rejected = GitHub n'a pas accepté le jeton

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } ne prend pas en charge la connexion
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = « { $source } » n'est pas une source au format { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } est introuvable. S'il s'agit d'un dépôt privé, connectez-vous avec un compte qui y a accès (Paramètres de Loadstone) ou définissez GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = le jeton de { $account } a été refusé ; il a peut-être expiré ou été révoqué
core-source-token-unreachable = { $source } est inaccessible avec le jeton de { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = le téléchargement de { $url } a renvoyé le code HTTP { $status }
core-fetch-request-failed = échec de la requête : { $url }
core-fetch-download-failed = échec du téléchargement : { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = erreur de lecture
core-fetch-read-error-download = erreur de lecture pendant le téléchargement

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = aucune méthode d'extraction ne s'applique à cette plateforme ou distribution
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } est un lien vers une copie de travail de développement. Mettez plutôt cette copie à jour avec git, ou supprimez le lien avant d'installer.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = cette archive ne contient pas les fichiers attendus (aucune entrée ne correspond à une méthode d'extraction)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = le registre « { $source } » n'est ni au format { $formats } ni un dossier existant
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } n'a pas de dossier loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = Impossible d'actualiser { $source } ({ $error }) ; utilisation de la copie en cache.
core-registry-fetch-failed = impossible de récupérer le registre { $source }
# $id is a mod's id.
core-registry-package-not-found = paquet « { $id } » introuvable dans les registres

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = « { $key } » est un booléen ; utilisez true ou false
core-setting-not-number = « { $key } » doit être un nombre
core-setting-too-small = « { $key } » doit être au moins égal à { $min }
core-setting-too-large = « { $key } » doit être au plus égal à { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = « { $key } » doit avoir l'une de ces valeurs : { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Accès testeur débloqué pour les mods d'un registre : les mods réservés aux testeurs sont affichés, et les installations et mises à jour obtiennent les versions bêta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Accès testeur débloqué pour les mods d'un registre et pour { $mods } : les mods réservés aux testeurs sont affichés, et les installations et mises à jour obtiennent les versions bêta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Accès testeur débloqué pour { $mods } : les mods réservés aux testeurs sont affichés, et les installations et mises à jour obtiennent les versions bêta.
core-tester-save-failed = impossible d'enregistrer le mot de passe testeur
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = La version { $tag } n'a pas de métadonnées Loadstone utilisables ({ $error }) ; utilisation de la dernière version stable.
core-tester-beta-lookup-failed = Impossible de rechercher les versions bêta ({ $error }) ; utilisation de la dernière version stable.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = la vérification de l'empreinte de la mise à jour téléchargée a échoué (attendu { $expected }, obtenu { $actual }) ; non installée
core-update-translocated = macOS exécute cette application depuis une copie temporaire en lecture seule ; elle ne peut donc pas se mettre à jour. Déplacez-la dans votre dossier Applications, ouvrez-la depuis cet emplacement, puis relancez la mise à jour.
core-update-on-disk-image = cette application s'exécute depuis son image disque ; elle ne peut donc pas se mettre à jour. Copiez-la dans votre dossier Applications, ouvrez-la depuis cet emplacement, puis relancez la mise à jour.
# $path is the folder the app is in.
core-update-no-write = impossible d'écrire à côté de { $path } (autorisation manquante ?) ; l'application ne peut donc pas se mettre à jour. Téléchargez plutôt la nouvelle version depuis la page de la version publiée.
core-update-no-staging = impossible d'écrire à côté de { $path } (autorisation manquante ?). Téléchargez plutôt la nouvelle version depuis la page de la version publiée
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = la mise à jour est une autre application ({ $got } au lieu de { $expected }) ; non installée
core-update-move-aside-app = impossible de déplacer l'application actuelle
core-update-move-in-app = impossible de mettre la nouvelle application en place
core-update-move-aside-exe = impossible de déplacer l'exécutable actuel
core-update-move-in-exe = impossible de mettre le nouvel exécutable en place

## Standard buttons

# Buttons wxWidgets draws itself (dialog OK and Cancel, message box
# Yes and No). The plain forms are the same words without the shortcut.
gui-stock-ok = &OK
gui-stock-ok-plain = OK
gui-stock-cancel = &Annuler
gui-stock-cancel-plain = Annuler
gui-stock-yes = &Oui
gui-stock-yes-plain = Oui
gui-stock-no = &Non
gui-stock-no-plain = Non
gui-stock-close = &Fermer
gui-stock-close-plain = Fermer
