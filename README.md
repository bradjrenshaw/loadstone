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
loadstone install blindfold --scope path/to/repo/loadstone-packages --scope path/to/registry/loadstone-packages
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
- `--user-data`, `--state-dir`, and `--yes` support sandboxed/automated runs.

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

## Not yet built

- The C++ wxWidgets GUI described above (the engine API is its backend).
- Branch (dev) channel installs and linked development checkouts.
- Settings, actions, and repair surfaced through the CLI.
- tar.gz artifact extraction (macOS/Linux tool artifacts).
- `loadstone release` — creating/uploading the GitHub release itself (use
  `gh release create` for now).
