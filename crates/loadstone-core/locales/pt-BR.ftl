# Loadstone's interface text, English (the fallback for every other
# language). Ids are grouped by where the text appears. Arguments are
# { $snake_case }; keep every argument and every "&" (a keyboard shortcut
# marker in button and menu labels) when translating.

## Package files

error-manifest-too-new = Este mod precisa de uma versão mais recente do Loadstone. Atualize o Loadstone e tente novamente.

## Loadstone settings

pref-language = Idioma
pref-language-description = O idioma em que o Loadstone e os mods traduzidos são exibidos.
language-system = Padrão do sistema
pref-accounts = Contas
pref-accounts-description = Logins usados para baixar mods de repositórios privados.
pref-account-rules = Regras de conta
pref-account-rules-description = Qual conta usar para um repositório ou proprietário.
pref-try-other-accounts = Tentar minhas outras contas quando um download for recusado
pref-try-other-accounts-description = Se um repositório não for encontrado ou o acesso for recusado, tentar as outras contas desse site antes de desistir.
pref-tester-passwords = Senhas de testador
pref-tester-passwords-description = Desbloqueiam mods exclusivos para testadores e versões beta, para um registro ou para mods específicos. Defina pelo botão Senha de testador.
pref-download-account = Conta de download
pref-download-account-description = A conta usada para baixar este mod. Automática usa suas regras de conta e a conta padrão.
pref-download-account-automatic = Automática (regras de conta e, depois, a conta padrão)

### Window (app/src/main.cpp)

## Main window: menu bar and closing

# Tools menu item; the keyboard shortcut (Ctrl+,) is added by the program.
gui-menu-loadstone-settings = &Configurações do Loadstone...
# Help text for the Loadstone settings menu item.
gui-menu-loadstone-settings-help = Contas para repositórios privados e opções do Loadstone
gui-menu-exit = &Sair
# Menu bar title.
gui-menu-tools = &Ferramentas
# Asked when the window is closed while an install or other operation runs.
gui-close-while-running = Uma operação ainda está em andamento. Se você fechar agora, ela pode ficar incompleta. Fechar mesmo assim?
gui-close-while-running-title = Operação em andamento
# Status bar text while a standalone installer loads its mod.
gui-status-loading = Carregando...

## Questions asked during an operation

# Title of the dialog shown when a step of an install fails; the buttons below retry it, skip it, or cancel the operation.
gui-problem-title = Problema durante a operação
gui-button-retry = &Tentar novamente
gui-button-skip = &Pular
gui-button-cancel-problem = &Cancelar
# Title of the dialog that asks one of a mod's own install questions.
gui-install-options-title = Opções de instalação

## Mod list (catalog)

# Heading above the mod list. $title is the app name; $version is the version of Loadstone's core.
gui-catalog-heading = { $title } (núcleo { $version })
# Label of the list of mods.
gui-catalog-mods-label = &Mods:
# Button that opens the selected mod's page.
gui-button-details = &Detalhes
gui-button-refresh = &Recarregar
gui-button-loadstone-settings = Configurações do &Loadstone...
gui-status-fetching-catalog = Obtendo o catálogo de mods...
# Placeholder line in the mod list while it loads.
gui-catalog-loading = Carregando a lista de mods...
# Placeholder line in the mod list when loading failed.
gui-catalog-load-failed = Não foi possível carregar a lista de mods. Pressione Recarregar para tentar novamente.
gui-status-catalog-failed = Falha ao obter o catálogo.
gui-catalog-error-title = Não foi possível carregar o catálogo de mods
# One line of the mod list. $status is already translated, for example "Installed".
gui-catalog-entry = { $name }, { $status }
# One line of the mod list, with the mod's one-line summary.
gui-catalog-entry-with-summary = { $name }, { $status }, { $summary }
# Placeholder line when the list has no mods.
gui-catalog-empty = Nenhum mod disponível.
gui-status-catalog-loaded = { $count ->
    [one] Catálogo carregado: { $count } mod.
   *[other] Catálogo carregado: { $count } mods.
}

## Mod page

# Status bar text; $mod_id is the mod's id, for example "my-mod".
gui-status-loading-mod = Carregando { $mod_id }...
gui-status-mod-load-failed = Não foi possível carregar a página do mod.
gui-mod-error-title = Não foi possível carregar o mod
# Label of the list of game copies (Steam, Epic...), when the game's name is unknown.
gui-copies-label = &Cópia do jogo a gerenciar:
# Label of the list of game copies; $game is the game's name.
gui-copies-label-named = &Cópia de { $game } a gerenciar:
gui-button-back = &Voltar à lista de mods
# Mod page heading; $authors is a list of names.
gui-mod-heading-by = { $name }, por { $authors }
# Label of the game folder text field, when the game's name is unknown.
gui-game-dir-label = Pasta do &jogo:
# Label of the game folder text field; $game is the game's name.
gui-game-dir-label-named = &Pasta de { $game }:
gui-button-browse = P&rocurar...
# Title of the folder picker opened by Browse.
gui-browse-game-prompt = Selecione a pasta do jogo
gui-browse-game-prompt-named = Selecione a pasta de { $game }
gui-description-label = Descrição:
# Label of the log where operations report their progress.
gui-activity-label = Atividade:
gui-button-update = &Atualizar
gui-button-install = &Instalar
gui-select-folder-first = Primeiro, use Procurar para selecionar a pasta do jogo.
gui-button-install-from-file = Instalar de ar&quivo...
# Title of the file picker; loadstone-release.json is a file name, keep it.
gui-release-file-prompt = Selecione o arquivo loadstone-release.json do mod
# File type filter for the file picker: pairs of description|pattern separated by |. Translate only "JSON files" and "All files"; keep every | and pattern.
gui-release-file-wildcard = loadstone-release.json|loadstone-release.json|Arquivos JSON (*.json)|*.json|Todos os arquivos (*.*)|*.*
gui-button-uninstall = &Desinstalar
gui-button-launch = I&niciar o jogo
# Description of the Launch game button, read when it gets focus.
gui-launch-description = Inicia o jogo com o mod carregado.
gui-launch-unavailable-description = Disponível depois que o mod for instalado aqui.
gui-button-change-options = Alterar &opções de instalação...
gui-change-options-description = Faz novamente as perguntas de instalação do mod e reinstala a versão mais recente com suas respostas.
gui-button-settings = Confi&gurações...

## Operations

# Status bar text; $percent is a number from 0 to 100.
gui-status-working-percent = Processando... { $percent }%
gui-status-fetching-releases = Obtendo a lista de versões...
# $error is an error message.
gui-release-list-error = Não foi possível obter a lista de versões: { $error }
# Asked after gui-release-list-error, in the same message box.
gui-release-list-install-latest = Instalar a versão publicada mais recente em vez disso?
gui-release-list-error-title = Lista de versões indisponível
gui-no-releases = O repositório deste mod ainda não tem versões publicadas.
gui-no-releases-title = Nenhuma versão publicada
gui-choose-version = Selecione a versão a instalar:
gui-choose-version-title = Escolher versão
gui-confirm-uninstall = Desinstalar { $name }?
gui-confirm-uninstall-title = Confirmar desinstalação
gui-status-working = Processando...
gui-status-op-failed = A operação falhou.
# Title of the message shown when the game could not be started.
gui-launch-failed-title = Não foi possível iniciar
gui-op-failed-title = Falha na operação
# Title of the message shown when an operation finished.
gui-op-done-title = Concluído

## Updating Loadstone itself

# $version is the new version, $app the app's name, $current the version installed now.
gui-self-update-offer = A versão { $version } do { $app } está disponível (você tem a { $current }). Atualizar e reiniciar agora?
gui-self-update-title = Atualização disponível
gui-status-downloading-update = Baixando a atualização...
gui-status-update-failed = A atualização falhou.
gui-update-failed-title = Falha na atualização
gui-status-update-installed = Atualização instalada.
gui-update-installed = A atualização foi instalada. O aplicativo será reiniciado agora.
gui-update-installed-title = Atualização instalada

## A mod's settings dialog

# $error is an error message.
gui-status-loadstone-settings-unavailable = Configurações do Loadstone indisponíveis: { $error }
# Dialog title; $name is the mod's name.
gui-mod-settings-title = Configurações de { $name }
# Label in front of a setting's list or text field; $label is the setting's name.
gui-setting-label = { $label }:
# Group of the mod's own settings.
gui-mod-options-group = Opções do mod
gui-mod-options-after-install = As opções do mod ficam disponíveis depois que ele for instalado.
gui-status-setting-saved = Configuração salva.
# $note is an extra message from the mod about the change.
gui-status-setting-saved-note = Configuração salva. { $note }
gui-setting-not-changed-title = Configuração não alterada
gui-status-no-settings-changed = Nenhuma configuração foi alterada.

## Loadstone settings dialog

gui-loadstone-settings-title = Configurações do Loadstone
gui-accounts-label = &Contas:
gui-accounts-description = Logins usados para baixar mods de repositórios privados.
gui-button-sign-in = &Entrar...
gui-button-add-token = Adicionar &token...
gui-button-remove-account = &Remover conta
gui-button-set-default = Definir como &padrão
# "gh auth token" is a command, keep it.
gui-add-token-description = Adicione uma conta a partir de um token que você já tem, por exemplo, obtido com o comando gh auth token da CLI do GitHub.
gui-rules-label = Re&gras de conta:
gui-rules-description = Qual conta usar para um repositório ou para todos os repositórios de um proprietário. Sem uma regra, a conta padrão é usada.
gui-button-add-rule = A&dicionar regra...
gui-button-remove-rule = Re&mover regra
gui-button-tester-password = &Senha de testador...
gui-tester-password-description = Para testadores privados: digite a senha que você recebeu para ver mods exclusivos para testadores e receber versões beta. Você pode adicionar mais de uma. Deixe em branco para parar de testar.
gui-tester-password-prompt-saved = Você tem senhas de testador salvas. Digite outra para adicioná-la ou deixe em branco para esquecer todas e parar de testar.
gui-tester-password-prompt = Digite a senha de testador que você recebeu.
gui-tester-password-title = Senha de testador
gui-tester-password-not-saved-title = Senha de testador não salva
gui-button-close = &Fechar
gui-accounts-unavailable-title = Contas indisponíveis
# One line of the accounts list. $account is the account's name, $username the user name on the site, $site the site (for example GitHub). $flags says whether it is the default account and whether its token is missing.
gui-account-line = { $flags ->
    [default] { $account }, { $username } no { $site }, padrão
    [missing] { $account }, { $username } no { $site }, token ausente (entre novamente)
    [default-missing] { $account }, { $username } no { $site }, padrão, token ausente (entre novamente)
   *[none] { $account }, { $username } no { $site }
}
# Placeholder line when there are no accounts; "Sign in" is the button's name.
gui-accounts-empty = Nenhuma conta. Use Entrar para adicionar uma.
# One line of the account rules list; $pattern is a repository or owner, for example github:owner/repo.
gui-rule-line = { $pattern } usa { $account }
# Placeholder line when there are no account rules.
gui-rules-empty = Nenhuma regra.
# $site is the site's name, for example GitHub.
gui-add-token-prompt = Cole um token do { $site }. Ele será verificado com o { $site } e, depois, guardado no Gerenciador de Credenciais do Windows.
gui-add-token-title = Adicionar token
gui-status-account-added = Conta { $account } adicionada.
gui-token-not-added-title = Token não adicionado
# $account is the account's name; $site is the site's name, for example GitHub. "Applications" is the name of a page in the site's settings.
gui-remove-account-prompt = Remover a conta { $account }? O Loadstone esquecerá o token dela e todas as regras que a usam. Para revogar também o acesso do Loadstone, use Applications nas configurações do { $site }.
gui-remove-account-title = Remover conta
gui-account-not-removed-title = Conta não removida
gui-default-not-changed-title = Conta padrão não alterada
# Keep github:owner/repo and github:owner/* as written; they are the format to type.
gui-add-rule-pattern-prompt = Repositório (github:owner/repo) ou todos os repositórios de um proprietário (github:owner/*):
gui-add-rule-title = Adicionar regra de conta
# One choice in the list of accounts for a new rule.
gui-account-choice = { $account } ({ $username })
gui-add-rule-account-prompt = Qual conta usar?
gui-rule-not-added-title = Regra não adicionada
gui-rule-not-removed-title = Regra não removida

## Signing in

gui-sign-in-no-sites = Nenhum site permite entrar com uma conta.
gui-sign-in-title = Entrar
gui-sign-in-which-site = Entrar em qual site?
# $site is the site's name, for example GitHub.
gui-sign-in-dialog-title = Entrar no { $site }
gui-sign-in-requesting = Solicitando um código de login ao { $site }...
# Label of the field holding the code to enter on the site.
gui-sign-in-code-label = &Código de login:
gui-button-copy-code = Co&piar código
gui-button-open-sign-in-page = &Abrir a página de login do { $site }
gui-button-cancel = Cancelar
gui-sign-in-code-copied = Código copiado. Abra a página de login e cole-o lá.
# $url is the web address of the sign-in page.
gui-sign-in-instructions = Abra { $url }, digite o código abaixo e autorize o Loadstone. Esta janela fecha sozinha quando você terminar.
gui-sign-in-code-expired = O código de login expirou antes de ser digitado. Comece novamente.
# $account is the account's name.
gui-status-signed-in = Conectado como { $account }.
gui-signed-in = Conectado ao { $site } como { $account }.
gui-signed-in-title = Conectado
gui-sign-in-failed-title = Falha no login
# Asked below an error saying a mod or registry could not be reached.
gui-offer-sign-in = Entrar agora com uma conta que tenha acesso?
gui-offer-sign-in-title = Entre para continuar

## Startup

gui-startup-error-title = Erro ao iniciar o Loadstone

### Mod pages and catalog (bridge)

## Window

# Window title when the build does not set its own.
page-default-title = Gerenciador de mods Loadstone

## Mod list (catalog)

# Status column of the mod list. $version is a mod version ("1.0.9").
page-catalog-installed = Instalado: { $version }
# $channel is a channel id from the mod's manifest ("dev", "beta").
page-catalog-installed-channel = Instalado: { $version } (canal { $channel })
page-catalog-not-installed = Não instalado
# The mod is installed in several copies of the game (Steam, Epic...), all at one version. $count is at least 2.
page-catalog-installed-copies = { $count ->
    [one] Instalado: { $version } em { $count } cópia
   *[other] Instalado: { $version } em { $count } cópias
}
# The mod is installed in several copies of the game at different versions. $count is at least 2.
page-catalog-installed-copies-differ = { $count ->
    [one] Instalado em { $count } cópia (versões diferentes)
   *[other] Instalado em { $count } cópias (versões diferentes)
}
# The mod's files are in the game, but Loadstone did not install them (placed by hand or by an old installer).
page-catalog-installed-outside = Instalado fora do Loadstone
# Summary line for an installed mod that no registry (mod list source) lists any more.
page-catalog-unlisted-summary = Instalado, mas não aparece nos registros configurados.
# Mod name in the list when the mod is only visible to testers. $name is the mod's name.
page-catalog-tester-preview = { $name } (prévia para testadores)
# Note above the mod list. Registries are the online lists of mods Loadstone reads.
page-catalog-no-registries = Nenhum registro configurado; mostrando apenas os mods instalados.
# Note above the mod list: mods that cannot run on this operating system or processor are left out.
page-catalog-hidden-mods = { $count ->
    [one] { $count } mod indisponível para este computador está oculto.
   *[other] { $count } mods indisponíveis para este computador estão ocultos.
}
# Note shown when the mod lists could not be read. $error is the underlying error text.
page-registries-failed = Não foi possível carregar os registros: { $error }

## Mod page notes

# $error is the underlying error text.
page-note-not-found = Não encontrado nos registros configurados: { $error }
page-note-no-release-metadata = A versão publicada mais recente ainda não tem metadados do Loadstone, por isso não foi possível determinar a versão mais nova.
# $game is the game's name. Some games keep mods in the user's data folder, which every copy of the game (Steam, Epic...) shares.
page-note-shared-mods-folder = Observação: as cópias de { $game } compartilham uma única pasta de mods. Instalar ou desinstalar um mod em uma cópia afeta as outras; só o carregador de mods é separado em cada cópia.
# The mod depends on another package. $name is that package's name, $version its installed version.
page-note-requires-installed = Requer { $name } (instalado automaticamente; versão atual: { $version }).
# The mod depends on another package, not installed yet. $name is that package's name.
page-note-requires = Requer { $name } (instalado automaticamente).

## Mod page status line, one game copy

# $version is the installed version. "dev channel" means it was built from the latest development code.
page-status-dev = Versão { $version } instalada (canal dev).
page-status-up-to-date = Atualizado (versão { $version }).
# The installed version (a beta) is newer than the newest release. $latest is that release's version.
page-status-newer-than-latest = Atualizado (versão { $version }, mais recente que a última versão publicada, { $latest }).
# $version is the installed version, $latest the version an update would install.
page-status-update-available = Atualização disponível: de { $version } para { $latest }.
page-status-installed = Versão { $version } instalada.
# The mod's files are in this copy, but Loadstone did not install them. $latest is the newest version.
page-status-foreign-latest = Instalado fora do Loadstone (versão desconhecida). Instale a versão { $latest } para que o Loadstone gerencie esta cópia.
page-status-foreign = Instalado fora do Loadstone (versão desconhecida). Instale-o para que o Loadstone gerencie esta cópia.
page-status-ready = Pronto para instalar a versão { $latest }.
page-status-not-installed = Não instalado.
# The mod cannot run on this computer. $reason is a sentence saying why (for example which systems it supports).
page-status-unavailable = Indisponível neste computador. { $reason }
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-ready-no-folder = Pronto para instalar a versão { $latest }. Pasta do jogo não encontrada; use Procurar para selecioná-la.
# No game folder was found. "Browse" is the name of the button that picks a folder.
page-status-not-installed-no-folder = Não instalado. Pasta do jogo não encontrada; use Procurar para selecioná-la.
# Status of the "Another folder..." entry, for installing into a game copy that was not found automatically. $reason is a sentence saying why the mod cannot run here.
page-status-another-folder-unavailable = Use Procurar para selecionar a pasta. Indisponível neste computador. { $reason }
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-ready = Use Procurar para selecionar a pasta. Pronto para instalar a versão { $latest }. Pasta do jogo não encontrada; use Procurar para selecioná-la.
# Status of the "Another folder..." entry. "Browse" is the name of the button that picks a folder.
page-status-another-folder-not-installed = Use Procurar para selecionar a pasta. Não instalado. Pasta do jogo não encontrada; use Procurar para selecioná-la.
# Shown with a mod's settings before it is installed.
page-settings-after-install = As configurações poderão ser editadas depois da instalação.

## Mod page list of game copies

# One entry in the list of game copies. $distribution is the store the copy came from (Steam, Epic, GOG, itch.io, Standalone...), $version the installed version, $folder the game folder's path.
page-copy-installed = Cópia { $distribution }, versão { $version } instalada, { $folder }
# The mod's files are in this copy, but Loadstone did not install them. $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-foreign = Cópia { $distribution }, mod instalado fora do Loadstone, { $folder }
# $distribution is the store (Steam, Epic...), $folder the game folder's path.
page-copy-not-installed = Cópia { $distribution }, mod não instalado, { $folder }
# A copy whose store is unknown. $folder is the game folder's path, $version the installed version.
page-copy-at-installed = Cópia em { $folder }, versão { $version } instalada
# A copy whose store is unknown, holding mod files Loadstone did not install. $folder is the game folder's path.
page-copy-at-foreign = Cópia em { $folder }, mod instalado fora do Loadstone
# A copy whose store is unknown. $folder is the game folder's path.
page-copy-at-not-installed = Cópia em { $folder }, mod não instalado
# The only entry when no game copy was found. "Browse" is the name of the button that picks a folder.
page-copy-none-found = Nenhuma cópia encontrada ainda; use Procurar para selecionar a pasta do jogo.
# Last entry in the list of game copies: pick a folder by hand.
page-copy-another-folder = Outra pasta...
# A game copy not bought from a store (downloaded directly from the developer), used as $distribution in the copy entries.
page-distribution-standalone = Independente
# A second app a game ships on a store, used as $distribution in the copy entries ("Steam demo copy, ..."). $distribution is the store, $app the app's name from the game's package ("demo").
page-distribution-app = { $distribution } { $app }

## Version picker

# A development channel. $channel is the channel id ("dev"), $branch the source code branch it is built from ("main").
page-channel-branch = Canal { $channel } (o mais recente do branch { $branch })
# A development channel. $channel is the channel id ("dev").
page-channel-development = Canal { $channel } (build de desenvolvimento)
# A release in the version list. $tag is the release tag ("v1.0.9"), $title the release's title.
page-release-named = { $tag }, { $title }
# A test release in the version list. $tag is the release tag ("v1.1.0-beta").
page-release-prerelease = { $tag } (pré-lançamento)
# A test release in the version list. $tag is the release tag, $title the release's title.
page-release-named-prerelease = { $tag }, { $title } (pré-lançamento)

## Results of operations

# Shown after one of a mod's own actions finishes. $action is the action's name from the mod ("Repair").
page-action-completed = Ação "{ $action }" concluída.
# Progress log line while Loadstone updates itself. $file is the download's file name.
page-self-update-downloading = Baixando { $file }...
page-self-update-installed = Atualização verificada e instalada.
page-tester-passwords-removed = Senhas de testador removidas. Os mods exclusivos para testadores e as versões beta voltaram a ficar ocultos.

## Accounts

# Choice in the download account setting. $label is the account's name, $username the user name on the site, $site the site's name ("GitHub").
page-account-choice = { $label } ({ $username } no { $site })

## Errors

# Registries are the lists of mods Loadstone reads.
page-error-no-registries = nenhum registro configurado
# $id is a mod id. A source repo is where the mod's releases are published.
page-error-no-source-repo = nenhum repositório de origem conhecido para "{ $id }"
# $id is a mod id.
page-error-not-installed-no-registries = "{ $id }" não está instalado e nenhum registro está configurado
# $id is a mod id.
page-error-not-installed-unresolved = "{ $id }" não está instalado e não foi possível localizá-lo
# $id is a mod id, $error the underlying error text.
page-error-not-installed-unresolved-detail = "{ $id }" não está instalado e não foi possível localizá-lo: { $error }
page-error-tester-password-wrong = Essa não é uma senha de testador de nenhum dos seus registros nem dos mods deles.
# The system's password or credential store, where sign-ins are kept, could not be used.
page-error-account-storage = o armazenamento de contas está indisponível
# A setting that takes a number was given something else. $value is what was typed.
page-error-not-a-number = "{ $value }" não é um número
# A setting that takes a number was given infinity or "not a number".
page-error-not-finite = não é um número finito

### Install, update, uninstall, actions, launch

## Install, update and uninstall: the activity log, questions and errors
## (read aloud by screen readers). { $name } and { $game } are a mod's or
## game's display name; { $id } is a package id such as "blindfold";
## { $distribution } is a store id such as "steam" or "epic", shown as is;
## { $version } is a version such as "1.2.0".

## Checking downloads

# { $expected } and { $actual } are SHA-256 hashes (long hexadecimal strings).
engine-hash-mismatch = o hash do arquivo de { $id } não confere: esperado { $expected }, obtido { $actual }. A instalação foi recusada.
# Same as engine-hash-mismatch, for one of several downloaded files; { $artifact } is that file's id.
engine-hash-mismatch-named = o hash do arquivo de { $id } ({ $artifact }) não confere: esperado { $expected }, obtido { $actual }. A instalação foi recusada.
engine-hash-verified = Hash do arquivo verificado.
engine-hash-none = Nenhum hash a verificar para esta origem (instalação local ou de desenvolvimento).

## Installing

# Logged on update before the old version's files are deleted.
engine-removing-previous = { $count ->
    [one] Removendo a versão { $version } instalada anteriormente ({ $count } arquivo).
   *[other] Removendo a versão { $version } instalada anteriormente ({ $count } arquivos).
}
# A problem that did not stop the operation; { $message } is the detail (often a file path and a system error, in English).
engine-warning = Aviso: { $message }
# { $error } is a system error message.
engine-warning-record-originals = Aviso: não foi possível registrar os originais que ainda precisam ser restaurados: { $error }
engine-install-failed-rolling-back = A instalação falhou; removendo os arquivos gravados até agora.
# Summary shown when an install or update finishes.
engine-installed = { $name } { $version } instalado.
# The user answered no to the release notes or development build question.
engine-install-cancelled = Instalação cancelada.

## Install options (choices a mod asks for at install time)

# { $options } is a comma-separated list of option ids.
engine-option-unknown = "{ $id }" não é uma opção de instalação deste mod (opções: { $options })
engine-option-unknown-none = "{ $id }" não é uma opção de instalação deste mod (opções: nenhuma)
# { $value } is the value given; { $option } is the option's id; { $choices } is a comma-separated list of allowed values.
engine-option-bad-choice = "{ $value }" não é uma escolha válida para { $option } (escolhas: { $choices })
# One entry in the list of choices: the choice's name and its description, both written by the mod's author.
engine-option-choice-described = { $label }: { $description }
# Logged after the user picks: the option's name and the chosen choice's name.
engine-option-chosen = { $option }: { $choice }
engine-option-cancelled = cancelado: nenhuma escolha feita

## Mod settings

# { $label } is the setting's name.
engine-setting-default = A configuração "{ $label }" começa com o valor padrão; altere-a depois com o comando de configurações.
# { $path } is the settings file.
engine-settings-written = Configurações gravadas em { $path }.

## Mod actions and launching the game

# { $action } is the action id asked for; { $available } is a comma-separated list of the mod's action ids.
engine-action-unknown = "{ $action }" não é uma ação de { $id } (disponíveis: { $available })
engine-action-unknown-none = "{ $action }" não é uma ação de { $id } (disponíveis: nenhuma)
# { $label } is the action's name, as on its button.
engine-action-unavailable = "{ $label }" não está disponível agora (a condição prévia não foi atendida)
engine-action-running = Executando "{ $label }"...
engine-action-finished = Ação "{ $label }" concluída.
engine-no-launch-steps = { $id } não declara etapas de inicialização para esta plataforma
# Summary after starting the game with a mod.
engine-launched = { $id } iniciado.

## Files Loadstone will not touch

# { $link } is a folder that is a symbolic link or junction, as made by a mod developer's deploy script.
engine-link-refused = { $link } é um link para uma cópia de trabalho de desenvolvimento; arquivos não serão modificados nem removidos por meio dele. Remova o link primeiro se você realmente quiser uma instalação gerenciada aqui.

## Leftovers from older installers (files a mod's previous, non-Loadstone installer left behind)

engine-legacy-outside = { $path } não foi removido: está fora das pastas do mod.
engine-legacy-link = { $path } não foi removido: é acessado por meio de um link.
engine-legacy-shared = { $path } não foi removido: outro pacote instalado o usa.
engine-legacy-removed = Arquivo remanescente { $path } removido
# { $error } is a system error message.
engine-legacy-remove-failed = Aviso: não foi possível remover { $path }: { $error }

## Install steps

# { $path } is a file the mod needs, sometimes with wildcards.
engine-required-file-missing = Arquivo necessário não encontrado: { $path }
# { $step } is the step's type, an untranslated id such as "extract-archive".
engine-requirement-not-met = Um requisito da etapa { $step } não foi atendido.
engine-step-skipped = Etapa { $step } ignorada.
engine-cancelled-at-step = cancelado na etapa { $step }
engine-extracting = Extraindo arquivos...
engine-placed-files = { $count ->
    [one] { $count } arquivo colocado.
   *[other] { $count } arquivos colocados.
}
engine-kept-existing = { $path } existente mantido (não foi substituído; pode ser mais recente).
engine-file-created = { $path } criado e atualizado.
engine-file-updated = { $path } atualizado.
# The user cancelled a folder picker; { $prompt } is the picker's question, written by the mod's author.
engine-directory-cancelled = cancelado: nenhuma pasta escolhida para "{ $prompt }"
# { $text } is text a mod put on the clipboard for the user to paste (for example Steam launch options).
engine-copied-to-clipboard = Copiado para a área de transferência: { $text }
# macOS: separate builds of a library for Intel and Apple Silicon were joined into one file; { $file } is its file name.
engine-merged-architectures = { $count ->
    [one] { $count } arquitetura combinada em { $file }.
   *[other] { $count } arquiteturas combinadas em { $file }.
}
# { $path } is the program a launch step starts (usually the game).
engine-program-missing = não é possível iniciar: { $path } não existe
engine-program-start-failed = falha ao iniciar { $path }
engine-program-started = { $path } iniciado.
# { $url } is a store launcher link such as steam://rungameid/646570.
engine-url-open-failed = falha ao abrir { $url }
engine-url-opened = { $url } aberto.

## Uninstalling

# A tool (such as a mod loader) other mods depend on; { $dependents } is a comma-separated list of their ids.
engine-still-needed = { $id } ainda é necessário para: { $dependents }. Desinstale-os primeiro.
engine-removing-files = { $count ->
    [one] Removendo { $count } arquivo.
   *[other] Removendo { $count } arquivos.
}
engine-purge-question = Remover também as configurações e preferências salvas?
engine-purge-done = Configurações salvas removidas.
engine-dependency-unneeded = { $id } não é mais necessário para nenhum mod instalado; você também pode desinstalá-lo.
# Summary when an uninstall finishes.
engine-uninstalled = { $id } { $version } desinstalado.

## Original game files a mod replaces (kept, and put back on update and uninstall)

engine-original-adopted = Usando o original já guardado em { $path }.
engine-originals-kept = { $count ->
    [one] Guardada uma cópia de { $count } arquivo original do jogo.
   *[other] Guardada uma cópia de { $count } arquivos originais do jogo.
}
# The game probably has the file open; { $error } is a system error message.
engine-original-restore-deferred = Aviso: não foi possível restaurar o original de { $path } agora ({ $error }). Ele será restaurado quando este mod for atualizado ou desinstalado.
engine-original-restored = Original de { $path } restaurado.
# { $backup } is where the kept original should have been.
engine-original-missing = Aviso: o original de { $path } não foi encontrado ({ $backup }); o arquivo será mantido como está.
engine-original-changed = { $path } mudou desde que este mod foi instalado (uma atualização do jogo?); o arquivo mais recente será mantido.
engine-originals-restored = { $count ->
    [one] { $count } arquivo original do jogo restaurado.
   *[other] { $count } arquivos originais do jogo restaurados.
}
# An error; the reasons (file paths and system errors) follow on separate lines.
engine-restore-failed = { $count ->
    [one] não foi possível restaurar { $count } arquivo original do jogo; feche o jogo e tente novamente.
   *[other] não foi possível restaurar { $count } arquivos originais do jogo; feche o jogo e tente novamente.
}

## Finding the game and the installed copy

# { $path } is a game folder; { $distribution } is the store id of that copy.
engine-updating-copy = Atualizando a cópia { $distribution } em { $path }.
# One item in a comma-separated list of game copies.
engine-copy-entry = { $path } ({ $distribution })
# { $copies } is a list of engine-copy-entry items. --game-dir is a command-line option; keep it as is.
engine-update-many-copies = "{ $id }" está instalado em mais de uma cópia de { $game }: { $copies }. Use --game-dir para indicar qual cópia atualizar.
engine-many-copies = "{ $id }" está instalado em mais de uma cópia de { $game }: { $copies }. Use --game-dir para indicar qual cópia.
engine-not-game-folder = { $path } não parece ser uma pasta de { $game } (nenhum dos arquivos esperados foi encontrado)
engine-game-found = { $game } encontrado em { $path }
engine-game-not-found = Não foi possível encontrar { $game } automaticamente.
# Title of the folder picker.
engine-game-where = Onde { $game } está instalado?
# The user closed the folder picker. --game-dir is a command-line option; keep it as is.
engine-game-not-picked = não foi possível encontrar { $game } automaticamente; use --game-dir ou escolha a pasta do jogo
# { $path } is a game folder.
engine-not-installed-copy = "{ $id }" não está instalado na cópia de { $game } em { $path }
engine-not-installed = "{ $id }" não está instalado para { $game }

## Whether a mod can be installed here

# { $reason } is one of the engine-platform- messages below, or engine-game-platform-unsupported.
engine-cannot-install-here = { $name } não pode ser instalado neste computador. { $reason }
# { $reason } is the mod author's explanation, possibly empty.
engine-distribution-unsupported = a cópia { $distribution } de { $game } não é compatível. { $reason }
engine-distribution-untested = Observação: a cópia { $distribution } de { $game } não foi testada com este mod.
engine-no-matching-artifact = nenhum arquivo da versão publicada corresponde a esta plataforma, arquitetura ou distribuição
# { $platform }, { $first }, { $second } and { $third } are operating system names: Windows, macOS or Linux.
engine-platform-only-one = Este mod está disponível apenas para { $platform }.
engine-platform-only-two = Este mod está disponível apenas para { $first } e { $second }.
engine-platform-only-three = Este mod está disponível apenas para { $first }, { $second } e { $third }.
engine-platform-needs-apple-silicon = No { $platform }, este mod precisa de um processador Apple Silicon.
engine-platform-needs-arm = No { $platform }, este mod precisa de um processador ARM.
engine-platform-needs-x64 = No { $platform }, este mod precisa de um processador Intel ou AMD.
engine-game-platform-unsupported = { $game } não é compatível com { $platform } aqui.

## Updates and releases

# Summary: nothing to update.
engine-up-to-date = { $name } está atualizado ({ $version }).
# { $installed } is a beta version kept because it is newer than { $latest }.
engine-up-to-date-newer = { $name } está atualizado (a versão { $installed } é mais recente que a última versão publicada, { $latest }).
engine-installed-newer = { $name } { $installed } está instalado, uma versão mais recente que a última publicada disponível para você agora ({ $latest }). Nada foi alterado. Para instalar uma versão anterior, escolha essa versão explicitamente.
# { $from } and { $to } are versions.
engine-updating = Atualizando { $name } de { $from } para { $to }.
# A yes/no question. { $branch } is a source branch name such as "main"; { $version } is the branch and commit, such as main@1a2b3c4.
engine-branch-confirm =
    Instalar { $name } a partir do último commit do branch { $branch } ({ $version })?

    Builds de desenvolvimento não têm hash fixado; você está confiando no conteúdo atual do repositório.
# A yes/no question. { $notes } is the release notes, written by the mod's author.
engine-release-notes-confirm =
    Notas da versão de { $name } { $version }:

    { $notes }

    Instalar agora?
# { $source } is a repository such as github:owner/repo; { $tag } is a release tag such as v1.2.0.
engine-fetching-release = Obtendo informações da versão { $tag } de { $source }...
engine-fetching-latest = Obtendo informações da versão publicada mais recente de { $source }...
engine-using-local-artifact = Usando o arquivo local { $path }
# { $file } is a download's file name.
engine-using-cached = Usando { $file }, já baixado.
engine-downloading = Baixando { $file }...
engine-dependency-present = Dependência { $id } { $version } já instalada.
# { $name } is the dependency's name (such as a mod loader); { $file } is the file being downloaded.
engine-installing-dependency = Instalando a dependência { $name } { $version } ({ $file })...

### Downloads, accounts, testers, self-update, settings

## Signing in to an account

# Shown when the user adds an account from a token but the token field is empty.
core-sign-in-no-token = nenhum token informado
core-sign-in-cancelled = Login cancelado.
core-sign-in-expired = O código de login expirou antes de ser digitado. Comece novamente.
# An account rule's pattern was mistyped. "github:owner/repo" and
# "github:owner/*" are the literal formats to type; keep them unchanged.
core-account-rule-bad-pattern = "{ $pattern }" não é uma origem (github:owner/repo) nem um curinga de proprietário (github:owner/*)
# The token could not be stored in the operating system's password store
# (Windows Credential Manager, macOS Keychain).
core-secrets-save-failed = não foi possível salvar o token no armazenamento de credenciais do sistema
core-secrets-remove-failed = não foi possível remover o token do armazenamento de credenciais do sistema

## GitHub

# $tag is a release's version tag, $file the name of a file attached to it.
core-github-no-asset = a versão { $tag } de { $source } não tem o arquivo { $file }
# Like the message above, for the newest release; "latest" stands where the
# release tag would be.
core-github-no-asset-latest = a versão mais recente de { $source } não tem o arquivo { $file }
# loadstone-release.json is a file name; keep it unchanged.
core-github-no-release-manifest = a versão { $tag } não tem o arquivo loadstone-release.json (ou ele está inacessível)
core-github-sign-in-cancelled = O login foi cancelado no GitHub.
# $details is GitHub's own explanation, in English.
core-github-sign-in-refused = O GitHub recusou o login: { $details }
core-github-sign-in-refused-no-details = O GitHub recusou o login sem dar detalhes
core-github-token-rejected = O GitHub não aceitou o token

## Sources (where registries and mods are downloaded from)

# $site is a site name such as "GitHub".
core-source-no-sign-in = { $site } não permite login
# $format is the accepted form of a source, such as "github:owner/repo".
core-source-bad-format = "{ $source }" não é uma origem no formato { $format }
# GH_TOKEN is the name of an environment variable; keep it unchanged.
core-source-maybe-private = { $source } não foi encontrado. Se for um repositório privado, entre com uma conta que tenha acesso (Configurações do Loadstone) ou defina GH_TOKEN
# $account is the name of a saved account, or of the environment variable
# the token came from (such as GH_TOKEN).
core-source-token-refused = o token de { $account } foi recusado; ele pode ter expirado ou sido revogado
core-source-token-unreachable = { $source } não está acessível com o token de { $account }

## Downloads

# $status is an HTTP status number, such as 404.
core-fetch-http-status = o download de { $url } retornou HTTP { $status }
core-fetch-request-failed = falha na solicitação: { $url }
core-fetch-download-failed = falha no download: { $url }
# Reading a server's reply failed partway.
core-fetch-read-error = erro de leitura
core-fetch-read-error-download = erro de leitura durante o download

## Installing a mod's files

# The mod has nothing to install for this operating system or store
# version of the game (Steam, GOG...).
core-archive-no-route = nenhuma forma de extração se aplica a esta plataforma ou distribuição
# $path is a folder that is a link to a developer's working copy of a mod.
core-archive-dev-link = { $path } é um link para uma cópia de trabalho de desenvolvimento. Atualize essa cópia com git ou remova o link antes de instalar.
# The downloaded archive has none of the files the mod says it installs.
core-archive-no-payload = este arquivo compactado não contém os arquivos esperados (nenhuma entrada corresponde a uma forma de extração)

## Registries (lists of mods)

# $formats is the accepted form of a remote registry, such as "github:owner/repo".
core-registry-not-found = o registro "{ $source }" não está no formato { $formats } nem é uma pasta existente
# loadstone-packages is a folder name; keep it unchanged.
core-registry-no-packages = { $source } não tem uma pasta loadstone-packages
# $error is the reason the download failed.
core-registry-using-cache = Não foi possível atualizar { $source } ({ $error }); usando a cópia em cache.
core-registry-fetch-failed = falha ao obter o registro { $source }
# $id is a mod's id.
core-registry-package-not-found = pacote "{ $id }" não encontrado em nenhum registro

## Mod settings values

# $key is the setting's id. "true" and "false" are the values to type;
# keep them unchanged.
core-setting-not-boolean = "{ $key }" é um valor booleano; use true ou false
core-setting-not-number = "{ $key }" precisa de um número
core-setting-too-small = "{ $key }" deve ser no mínimo { $min }
core-setting-too-large = "{ $key }" deve ser no máximo { $max }
# $options is a comma-separated list of the allowed values.
core-setting-not-an-option = "{ $key }" deve ser um destes valores: { $options }

## Tester passwords

# Shown after a tester password is accepted; it unlocked every mod of a
# registry (a list of mods).
core-tester-unlocked-registry = Acesso de testador desbloqueado para os mods de um registro: mods exclusivos para testadores aparecem na lista, e instalações e atualizações recebem versões beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-registry-and-mods = Acesso de testador desbloqueado para os mods de um registro e para { $mods }: mods exclusivos para testadores aparecem na lista, e instalações e atualizações recebem versões beta.
# $mods is a comma-separated list of mod ids.
core-tester-unlocked-mods = Acesso de testador desbloqueado para { $mods }: mods exclusivos para testadores aparecem na lista, e instalações e atualizações recebem versões beta.
core-tester-save-failed = falha ao salvar a senha de testador
# $tag is a release's version tag, $error the reason.
core-tester-beta-unusable = A versão { $tag } não tem metadados do Loadstone utilizáveis ({ $error }); usando a última versão estável.
core-tester-beta-lookup-failed = Não foi possível procurar versões beta ({ $error }); usando a última versão estável.

## Updating Loadstone itself

# $expected and $actual are file checksums.
core-update-hash-mismatch = a atualização baixada falhou na verificação de hash (esperado { $expected }, obtido { $actual }); não instalada
core-update-translocated = O macOS está executando este aplicativo a partir de uma cópia temporária somente leitura, por isso ele não consegue se atualizar. Mova-o para a pasta Aplicativos, abra-o de lá e atualize novamente.
core-update-on-disk-image = este aplicativo está sendo executado a partir da imagem de disco, por isso não consegue se atualizar. Copie-o para a pasta Aplicativos, abra-o de lá e atualize novamente.
# $path is the folder the app is in.
core-update-no-write = não é possível gravar ao lado de { $path } (sem permissão?), por isso o aplicativo não consegue se atualizar. Baixe a nova versão na página da versão publicada.
core-update-no-staging = não é possível gravar ao lado de { $path } (sem permissão?). Baixe a nova versão na página da versão publicada
# $got and $expected are app identifiers such as com.example.app.
core-update-wrong-app = a atualização é de outro aplicativo ({ $got }, esperado { $expected }); não instalada
core-update-move-aside-app = não foi possível mover o aplicativo atual para outro local
core-update-move-in-app = não foi possível colocar o novo aplicativo no lugar
core-update-move-aside-exe = não foi possível mover o executável atual para outro local
core-update-move-in-exe = não foi possível colocar o novo executável no lugar
