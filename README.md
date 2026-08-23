# Loadstone Mod Manager

A unified, accessible mod manager for game accessibility mods: one signed
manager application instead of one signed installer per mod, driven by
declarative package manifests hosted on each mod's own GitHub releases.

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

Build a `release.json` for a version from your project manifest plus built
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
`release.json`. Attach it and the artifacts to the GitHub release; the manager
fetches it via `.../releases/latest/download/release.json`.

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
loadstone uninstall blindfold --game balatro
```

- Package ids resolve from the `--scope` directories, innermost first; the
  game is auto-detected (Steam today) or passed with `--game-dir`.
- Releases come from the package's `source` repo (`release.json` +
  hash-verified artifact), or locally via `--local-release path/to/release.json`
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
- `--user-data`, `--state-dir`, `--yes`, and `--dir` support
  sandboxed/automated runs.

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
runtime is currently dynamic; release builds will pin it). It resolves its
distribution profile exactly like the CLI — embedded, then a `loadstone.json`
sidecar, then the manager default. Manager mode shows the catalog (everything
visible through the profile's registries, merged with installed state) and a
per-mod page: status, install/update/uninstall buttons, a live settings form
(changes validate in Rust and write to the mod's own storage file), and
declared actions. A single-mod profile opens straight to that mod's page —
the standalone-installer shape. All models cross the cxx bridge as typed
structs; the C++ never parses anything.

Registry fetches run on worker threads and land back on the GUI thread via
`wxTheApp->CallAfter`; every control is a native wx widget with a real label,
so screen readers see a proper list, checkboxes, and buttons.

A headless smoke mode prints what the bridge returned for CI:
`LOADSTONE_SMOKE_OUT=<file>` dumps the profile, installed state, and catalog;
`LOADSTONE_SMOKE_MOD=<id>` additionally dumps that mod's page model.

Known toolchain note: very new MSVC releases (VS 18 preview era) can throw
nondeterministic internal compiler errors building wxWidgets at high
parallelism; building wx with `-- -j 4` and retrying gets past it.

## Not yet built

- Install/update/uninstall and actions from the GUI (the buttons exist and
  explain this; the engine runs on worker threads with progress events next).
- `loadstone link` for development checkouts (the engine already refuses to
  write through them), and `repair`.
- tar.gz artifact extraction (macOS/Linux tool artifacts).
- `loadstone release` — creating/uploading the GitHub release itself (use
  `gh release create` for now).
