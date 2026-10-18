# Loadstone Mod Manager

A unified, accessible mod manager for game accessibility mods: one signed
manager application instead of one signed installer per mod, driven by
declarative package manifests hosted on each mod's own GitHub releases.

## Download

Grab `Loadstone.exe` from the
[latest release](https://github.com/bradjrenshaw/loadstone/releases/latest)
and run it from anywhere — there is nothing to install. Windows SmartScreen
may warn about an unrecognized app the first time; choose "More info", then
"Run anyway" (code signing is planned). The app checks for newer builds of
itself at launch and offers to update in place. It currently needs the
Microsoft Visual C++ Redistributable (x64), which most machines with games
installed already have.

- **`SPEC.md`** — the package format specification (start here). Packages live
  in a `loadstone-packages/` directory; the format is open and any conforming
  client can consume it.
- **`examples/`** — worked manifests for Say the Spire 2, Blindfold, and
  Wrath Access, used as test fixtures.
- **`crates/loadstone-core`** — manifest types, validation, and release
  building. Shared by the CLI and the manager application. No UI.
- **`crates/loadstone-cli`** — the `loadstone` developer CLI.

## Architecture

The end-user application is a thin C++ wxWidgets GUI over the Rust core:

- **`loadstone-core` (Rust)** owns everything that touches untrusted input —
  manifest parsing and validation, registry fetching, downloads, SHA-256
  verification, archive extraction with traversal rejection, the install step
  engine, and file tracking. It compiles as a static library.
- **The GUI (C++ + wxWidgets, planned)** links that static library over a
  [`cxx`](https://cxx.rs) bridge and owns only widget construction, dialogs,
  and screen-reader polish. The boundary is coarse and message-shaped: the
  GUI asks for page models as JSON and receives progress events via a
  callback marshalled onto the GUI thread. Everything ships as one statically
  linked, signed executable per platform.

wxWidgets' native Windows controls are the most battle-tested screen-reader
surface available (NVDA's own GUI is wx-based); keeping the memory-unsafe
language confined to widget glue is the point of the split.

## Developer CLI

Build and test:

```
cargo build
cargo test
```

Validate package files (project manifests, game packages, release manifests,
link files — the form is auto-detected; a directory validates every package
file in it):

```
loadstone validate loadstone-packages
loadstone validate loadstone-packages/my-mod.json --scope path/to/registry/loadstone-packages
```

A file's own directory is always the innermost scope, so a game package next
to the mod is found automatically; `--scope <dir>` (repeatable) adds outer
scopes for `${game.*}` checks against a registry checkout. When the game
package isn't in scope, those checks are skipped with a warning.

Build a `loadstone-release.json` for a version from your project manifest plus built
artifacts (with no `--manifest`, the single mod/tool/library file in
`./loadstone-packages` is used):

```
loadstone package --version v0.5.0 --artifact dist/MyMod.zip
loadstone package --version v0.5.0 --notes-file changes-latest.md
```

Artifacts can come from the command line (`--artifact`, repeatable) or from a
dev-only `packaging` block in the project manifest, which also lets artifacts
carry platform/distribution constraints:

```json
"packaging": {
  "artifacts": [
    { "file": "dist/MyMod.zip" },
    { "file": "dist/MyMod-mac.zip", "when": { "platform": "macos" } }
  ]
}
```

`loadstone package` validates the manifest first and refuses to package on
errors, hashes each artifact with SHA-256, and writes a self-contained
`loadstone-release.json`. Attach it and the artifacts to the GitHub release; the manager
fetches it via `.../releases/latest/download/loadstone-release.json`.

CLI output is plain text, one finding per line, with no colors or progress
animations — it reads identically in a terminal and a screen reader.

## Installing mods (the engine, CLI frontend)

The install engine lives in `loadstone-core` (context/detection, the step
interpreter, hash verification, file tracking, dependency installs with
`pinnedRelease`) and is driven from the CLI:

```
loadstone install blindfold --registry github:bradjrenshaw/loadstone-registry
loadstone install blindfold --channel dev --registry github:bradjrenshaw/loadstone-registry
loadstone update blindfold --registry github:bradjrenshaw/loadstone-registry
loadstone settings say-the-spire-2 --game slay-the-spire-2 --set screen_reader=false
loadstone action say-the-spire-2 install-jaws-config --game slay-the-spire-2
loadstone list
loadstone launch blindfold --game balatro
loadstone uninstall blindfold --game balatro
```

- Package ids resolve from the `--scope` directories, innermost first; the
  game is auto-detected (Steam today) or passed with `--game-dir`.
- Releases come from the package's `source` repo (`loadstone-release.json` +
  hash-verified artifact), or locally via `--local-release path/to/loadstone-release.json`
  for offline and pre-publish testing.
- Tool dependencies install first (hash-pinned via `pinnedRelease`), are
  reference-counted per game, and refuse removal while a mod still needs them.
- Updates remove the previous version's tracked files before extracting, so
  stale files never linger; uninstall works purely from recorded state and
  offers to purge declared user data.
- `--channel dev` installs a declared branch channel from the branch's tip
  (`main@<sha>` versions, explicitly not hash-pinned); `update` compares the
  recorded sha against the live tip.
- Settings declared in the manifest are initialized on first install
  (promptOnInstall booleans are asked), listed and changed with the
  `settings` command, and stored where the mod reads them.
- Declared actions run with `action` — pick-directory steps prompt, or take
  `--dir id=path` for automation.
- `launch` starts the game with the mod loaded, from the `launch` steps the
  manifest declares (frozen into state at install time, so it works offline):
  `open-url` through the owning store's launcher (Steam, Epic, GOG Galaxy,
  itch, Xbox), or `run` for a direct start with an injector inserted.
  The manager shows the same thing as a Launch button on the mod's page:
  install or update, then play, from one window.
- Release artifacts can carry an `id`; every matching named artifact is
  downloaded and an `extract-archive` step can pick it with `artifact`. The
  registry's Lovely package uses this on macOS to fetch both upstream slices
  and combine them (`merge-universal-binary`) into one universal injector,
  so the game loads it whether Steam runs it natively or under Rosetta.
- `--user-data`, `--state-dir`, `--yes`, and `--dir` support
  sandboxed/automated runs.

### Private repositories (accounts)

Mods in private repositories install with an account that can see them
(SPEC §15). Accounts are global in the manager and separate per standalone
installer; tokens live in the Windows Credential Manager.

```
loadstone auth login                       # browser sign-in: shows a code to enter on GitHub
gh auth token | loadstone auth add-token   # or reuse an existing token
loadstone auth list
loadstone auth rule-set "github:someone/*" github-myname   # use this account for an owner
loadstone auth use some-mod github-myname  # this mod always downloads with this account
loadstone auth which github:someone/private-mod --mod some-mod   # what would be tried
loadstone auth remove github-myname
```

For CI or one-off runs, `GH_TOKEN` (or `LOADSTONE_GITHUB_TOKEN` /
`GITHUB_TOKEN`) is used ahead of stored accounts. In the GUI, the same is
under Tools > Loadstone settings (Ctrl+,): accounts, account rules, and a
"try my other accounts" option; a mod's Settings dialog has its download
account. Anything that fails because a repository looks private offers to
sign in and retry.

Signing in uses Loadstone's GitHub OAuth App with the `repo` scope, the only
scope that can read private repositories (it also permits writes, which
Loadstone never does). Revoke it any time in GitHub's Settings >
Applications.

## Distribution profiles: one binary, manager or standalone installer

Some users want a mod manager; some want a per-mod standalone installer. The
same binary is both — a **distribution profile** decides its shape, resolved
at startup (first match wins):

1. a profile **embedded at compile time** — a developer's branded,
   self-contained installer;
2. a **`loadstone.json`** file next to the executable;
3. the default: full manager.

```json
{
  "mode": "single-mod",
  "mod": "blindfold",
  "title": "Blindfold Installer",
  "registries": ["github:bradjrenshaw/loadstone-registry"],
  "lockRegistries": true
}
```

- `mode: "manager"` (default) services everything reachable through its
  registries; `"single-mod"` pins one package id — the standalone-installer
  experience, with no id needed on the command line (and, later, a
  single-page GUI titled from the profile).
- `registries` lists `github:owner/repo` sources or local directories,
  innermost first. Remote registries are fetched as repo zipballs (no API
  rate limits), only their `loadstone-packages/*.json` files are kept, and a
  cached copy under the local data directory serves as offline fallback.
  Link files are followed one level, honoring their `packages` allowlists.
- To build a branded installer: `LOADSTONE_EMBED_PROFILE=path\to\profile.json
  cargo build --release` — the profile bakes into the exe, which the mod
  developer then signs as their own artifact. Everyone chooses their slice:
  ship the full manager, a registry-pinned manager, or a single-mod
  installer, all from this one open-source codebase.

## Building the GUI shell

`crates/loadstone-bridge` exposes the core to C++ over [cxx](https://cxx.rs)
as a staticlib; `app/` is the wxWidgets shell. One-time setup: build static
wxWidgets (3.2.x) with the same MSVC toolchain, e.g. into `C:/dev/wx-static`.
Then, from a Visual Studio developer environment:

```
cmake -S app -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=C:/dev/wx-static
cmake --build build
```

`build/loadstone-manager.exe` is a single statically linked binary (the VC
runtime is currently dynamic; release builds will pin it).

On macOS, install wxWidgets and CMake from Homebrew (`brew install cmake
wxwidgets`), then configure without a prefix path; the stock FindwxWidgets
module finds the Homebrew build through `wx-config`:

```
cmake -S app -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

That produces `build/Loadstone.app`, dynamically linked against Homebrew's
wxWidgets: fine for development, but it only runs where Homebrew's wx is
installed. For an app to hand to users, run `scripts/build_macos_app.sh`: it
builds a static, universal wxWidgets 3.2 once (cached under
`~/Library/Caches/loadstone`), a universal bridge, and an ad-hoc-signed
`dist/Loadstone.app` that links only system libraries. `--profile`,
`--name`, and `--bundle-id` make a branded installer instead (Developer ID
signing and notarization are still to do, so Gatekeeper asks on first
open). Zip it with `ditto -c -k --keepParent` and pass the zip to
`loadstone package --installer` (alongside the Windows exe) so macOS builds
can update themselves too (SPEC §13). The app resolves its
distribution profile exactly like the CLI — embedded, then a `loadstone.json`
sidecar, then the manager default. Manager mode shows the catalog (everything
visible through the profile's registries, merged with installed state) and a
per-mod page laid out like the per-mod installers it replaces: a status line
("Ready to install version X.", "Update available: X to Y."), a game-directory
row with an editable path and Browse button (auto-detected, overridable before
install), an always-present activity log, and a bottom button row where the
primary button reads Install or Update per state, next to Uninstall and the
mod's declared actions. Settings render as a live form (changes validate in
Rust and write to the mod's own storage file). A single-mod profile opens straight to that mod's
page — the standalone-installer shape. All models cross the cxx bridge as
typed structs; the C++ never parses anything.

Operations run the shared `loadstone_core::ops` orchestration (the same code
behind the CLI) on a worker thread. The engine's `EngineUi` calls come back
through a `UiCallbacks` object (`crates/loadstone-bridge/include/`): logs and
progress post to the GUI thread via `wxTheApp->CallAfter`; questions —
confirm, retry/skip/cancel, pick-directory, first-install setting prompts —
block the worker on a future until a native dialog answers. A closed window
answers "cancel", which the engine turns into a rollback. Every control is a
native wx widget with a real label, so screen readers see a proper list,
checkboxes, and buttons.

A headless smoke mode prints what the bridge returned for CI:
`LOADSTONE_SMOKE_OUT=<file>` dumps the profile, installed state, and catalog;
`LOADSTONE_SMOKE_MOD=<id>` dumps that mod's page model;
`LOADSTONE_SMOKE_INSTALL=<id>` / `LOADSTONE_SMOKE_UNINSTALL=<game:id>` run
real operations with auto-answered callbacks (`_STATE`, `_GAME_DIR`,
`_RELEASE` override the sandbox).

Known toolchain note: very new MSVC releases (VS 18 preview era) can throw
nondeterministic internal compiler errors building wxWidgets at high
parallelism; building wx with `-- -j 4` and retrying gets past it.

## Not yet built

- `loadstone link` for development checkouts (the engine already refuses to
  write through them), and `repair`.
- `loadstone release` — creating/uploading the GitHub release itself (use
  `gh release create` for now).
