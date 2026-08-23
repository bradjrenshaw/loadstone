# Worked examples

These manifests round-trip what the three existing standalone installers
(SayTheSpire2, Blindfold, wotr-access) do today. Paths, routes, legacy file
lists, settings, and error messages were taken directly from the installers'
Rust sources. Where a manifest deliberately *differs* from the current
installer behavior, it's noted below.

## Layout

The directories mirror real repos (SPEC §2): every registry — including each
mod's own repo — is a source with a `loadstone-packages/` directory.

- `mod-repos/<name>/loadstone-packages/` — what each mod repo carries: the
  mod's project manifest and the game package it targets, side by side. The
  mod's `"game"` reference resolves to the sibling game file (innermost
  scope).
- `community-registry/loadstone-packages/` — a community registry: one
  reviewed link file per listed mod repo (the one-time PR), plus
  `lovely-injector.json`, a tool package hosted by the registry itself with a
  `source` field naming the repo its artifacts come from.
- `releases/` — an example generated `loadstone-release.json` (what the dev CLI attaches
  to a GitHub release; the sha256 here is a placeholder)

## Say the Spire 2 (`mods/say-the-spire-2.mod.json`)

Maps 1:1 to the current installer:

- Release zip extracts as-is into the game root (`**` → `${gameDir}`).
- The `settings.save` edit (`mod_settings.mods_enabled = true` across every
  `steam/<id>/settings.save`) becomes an `edit-json` step with a retryable
  precondition — the "launch the game once, then retry" dialog is now generated
  by the manager.
- The first-install options dialog (screen reader support, disable Godot UIA)
  becomes two `promptOnInstall` settings stored in
  `${userData}/mods/SayTheSpire2/installation.json`; the Modify button becomes
  the standard settings section.
- The JAWS button becomes an action, now with a suggested destination
  (`jaws-user-settings`) instead of a bare directory picker.
- The legacy `accessibility.json` cleanup moves to `cleanupLegacy`.
- **Differences:** uninstall no longer needs a hardcoded file list (the manager
  tracks what it wrote); the "also remove settings?" prompt is driven by
  `userData`. The version file in appdata disappears — the manager owns version
  tracking.

## Blindfold (`mods/blindfold.mod.json`)

- Release routing (`Blindfold/**` → Mods folder) and the dev channel (main
  branch zipball, `src/**` → Mods folder, version shown as `main@<sha>`) map to
  `install` vs. `sourceInstall` plus the `dev` channel.
- The save-directory user files (settings, keybinds, log) are declared in
  `userData` for the uninstall purge prompt.
- **Differences:** `version.dll` is no longer bundled/routed by the mod — the
  Lovely injector is a `tool` dependency (`tools/lovely-injector.json`). Its
  `keep-newer` conflict policy replaces the installer's "never overwrite an
  existing version.dll" special case, and refcounting means it isn't removed
  while another Lovely mod needs it. The reparse-point (deploy.ps1 link) guard
  becomes the manager's "linked development install" state.

## Wrath Access (`mods/wrath-access.mod.json`)

- Both layouts (release: `WrathAccess/**` + `game/**`; repo: manifest files,
  `deploy/Assemblies`, `deploy/docs`, `assets`, `vendor/prism.dll`) map to
  `install` / `sourceInstall`.
- Recreating `Assemblies`/`Bundles`/`Blueprints` is `ensure-dirs`.
- Registration in `OwlcatModificationManagerSettings.json` is `edit-json` with
  `append-unique` on install and `remove-value` on uninstall — BOM tolerance
  and preservation of other mods' entries are engine guarantees.
- The Tolk-era DLLs in the game root are `cleanupLegacy`.
- The "repo may be mid-build" check is an `expect`.
- **Differences:** "close the game if it's running" error hints are replaced by
  the manager's pre-install running-process check.

## Open items

- Steam `appId`s are omitted from the game packages (detection currently works
  by library dir name, as the installers do). Adding appIds enables faster
  detection via appmanifest files — fill in when convenient.
- Epic/GOG detection data for these games is absent because none of the three
  mods support those distributions yet; the schema has room when they do.
- The lovely-injector package uses a `pinnedRelease` (SPEC §13.1) because
  upstream publishes no `loadstone-release.json`. Asset names are verified against its
  v0.9.0 release; the sha256 values are placeholders and must be computed from
  the real assets before the file is used. The Linux artifact
  (`lovely-x86_64-unknown-linux-gnu.tar.gz`) is omitted until someone tests
  Balatro modding under Linux/Proton.
