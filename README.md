# modmanager

A unified, accessible mod manager for game accessibility mods: one signed
manager application instead of one signed installer per mod, driven by
declarative package manifests hosted on each mod's own GitHub releases.

- **`SPEC.md`** — the package format specification (start here).
- **`examples/`** — worked manifests for Say the Spire 2, Blindfold, and
  Wrath Access, used as test fixtures.
- **`crates/modman-core`** — manifest types, validation, and release building.
  Shared by the CLI and, later, the manager application. No UI, no network.
- **`crates/modman-cli`** — the `modman` developer CLI.

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
modman validate modmanager-packages
modman validate modmanager-packages/my-mod.json --scope path/to/registry/modmanager-packages
```

A file's own directory is always the innermost scope, so a game package next
to the mod is found automatically; `--scope <dir>` (repeatable) adds outer
scopes for `${game.*}` checks against a registry checkout. When the game
package isn't in scope, those checks are skipped with a warning.

Build a `release.json` for a version from your project manifest plus built
artifacts (with no `--manifest`, the single mod/tool/library file in
`./modmanager-packages` is used):

```
modman package --version v0.5.0 --artifact dist/MyMod.zip
modman package --version v0.5.0 --notes-file changes-latest.md
```

Artifacts can come from the command line (`--artifact`, repeatable) or from a
dev-only `packaging` block in the project manifest, which also lets artifacts
carry platform/store constraints:

```json
"packaging": {
  "artifacts": [
    { "file": "dist/MyMod.zip" },
    { "file": "dist/MyMod-mac.zip", "when": { "platform": "macos" } }
  ]
}
```

`modman package` validates the manifest first and refuses to package on
errors, hashes each artifact with SHA-256, and writes a self-contained
`release.json`. Attach it and the artifacts to the GitHub release; the manager
fetches it via `.../releases/latest/download/release.json`.

CLI output is plain text, one finding per line, with no colors or progress
animations — it reads identically in a terminal and a screen reader.

## Not yet built

- `modman release` — creating/uploading the GitHub release itself (use
  `gh release create` for now).
- `modman link` — linked development checkouts.
- The manager application (install engine + accessible GUI) consuming
  `modman-core`.
