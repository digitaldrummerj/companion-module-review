# Module Review: leolabs-ableset v1.8.1

| | |
|---|---|
| **Module** | companion-module-leolabs-ableset |
| **Version** | v1.8.1 |
| **Scope** | `tag` (diff `v1.7.3..v1.8.1`) |
| **API** | @companion-module/base ~1.12.1 (v1.x) |
| **Language** | TypeScript |
| **Protocols** | OSC, TCP, HTTP |
| **Build / Lint** | ✅ Pass / ✅ Pass |
| **Review Date** | 2026-06-14 |

> Note: a prior review of **v1.8.0** (delivered ✅) flagged a missing UpgradeScript and a removed variable. The previous approved tag is **v1.7.3**, so this `tag` diff (`v1.7.3..v1.8.1`) spans both the v1.8.0 and v1.8.1 changes. The maintainer applied the template/packaging fixes from that review (engines, packageManager, `@types/node`, `tsconfig.build.json`, build scripts), but the two breaking-removal blockers remain.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 4 | 0 | 4 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 1 | 0 | 1 |
| **Total** | **6** | **0** | **6** |

**Blocking:** 5 (5 Critical + 1 High)

---

## Verdict

❌ **Changes Required**

---

## 📋 Issues

**Blocking**

- [ ] [C1: Missing UpgradeScript for removed SetAutoLoopCurrentSection action](#c1-missing-upgradescript-for-removed-setautoloopcurrentsection-action)
- [ ] [C2: Removed variable autoLoopCurrentSection without migration](#c2-removed-variable-autoloopcurrentsection-without-migration)
- [ ] [C3: tsconfig.json diverges from template](#c3-tsconfigjson-diverges-from-template)
- [ ] [C4: tsconfig.build.json diverges from template](#c4-tsconfigbuildjson-diverges-from-template)
- [ ] [H1: countInDuration and jumpMode wrongly added to BOOLEAN_SETTINGS](#h1-countinduration-and-jumpmode-wrongly-added-to-boolean_settings)

**Non-blocking**

- [ ] [L1: Dead enum entry SetAutoLoopCurrentSection](#l1-dead-enum-entry-setautoloopcurrentsection)

---

## 🔴 Critical

### C1: Missing UpgradeScript for removed SetAutoLoopCurrentSection action

**Classification:** 🆕 NEW
**File:** `src/main.ts:1806` (`runEntrypoint(ModuleInstance, [])`)

The `SetAutoLoopCurrentSection` action (OSC `/settings/autoLoopCurrentSection`) was removed in this release, but `runEntrypoint(ModuleInstance, [])` still passes an empty UpgradeScripts array. Any user who saved a button bound to this action ID will be left with an orphaned action that silently fails to load after upgrading — removing a persisted action ID is a breaking change to saved data and requires an upgrade script.

**Fix Required:** Add a `CompanionStaticUpgradeScript<Config>` (e.g. in `src/upgrades.ts`) that detects saved actions with `actionId === 'setAutoLoopCurrentSection'` and removes them (or remaps them to a supported equivalent), then register it: `runEntrypoint(ModuleInstance, [upgradeRemoveAutoLoopCurrentSection])`.

---

### C2: Removed variable autoLoopCurrentSection without migration

**Classification:** 🆕 NEW
**File:** `src/variables.ts` (removed definition) / `src/main.ts:577` (removed `/settings/autoLoopCurrentSection` OSC handler)

The `autoLoopCurrentSection` variable definition and its server handler were removed. Any user button or text expression referencing `$(AbleSet:autoLoopCurrentSection)` now resolves to an empty/undefined value with no warning. This is a breaking change to saved data.

**Fix Required:** Variable references in user text cannot be auto-migrated by an upgrade script, so document the removal prominently (HELP.md + changelog) so users can update their expressions. If AbleSet still exposes the underlying setting, consider restoring the variable instead. (Removal is consistent with the upstream AbleSet feature being dropped — the requirement is that it be communicated, not silent.)

---

### C3: tsconfig.json diverges from template

**Classification:** 🆕 NEW (changed this release)
**File:** `tsconfig.json:4`
**Deterministic check:** `CONFIG-DIFF`

`tsconfig.json` was restructured this release to extend `./tsconfig.build.json`, but its `exclude` array no longer matches the template. The validator reports:

> line 4: found `"exclude": ["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"]`, template `"exclude": ["node_modules/**"]`

The template keeps the test-file excludes in `tsconfig.build.json` and leaves `tsconfig.json`'s `exclude` as `["node_modules/**"]`. Build and lint pass, so this is a template-alignment (not functional) issue.

**Fix Required:** Align `tsconfig.json` to the template structure — keep `exclude: ["node_modules/**"]` here and move the test-file excludes into `tsconfig.build.json`. (See the official `companion-module-template-ts-v1` `tsconfig.json` / `tsconfig.build.json` pair.)

---

### C4: tsconfig.build.json diverges from template

**Classification:** 🆕 NEW (added this release)
**File:** `tsconfig.build.json:3`
**Deterministic check:** `CONFIG-DIFF`

The new `tsconfig.build.json` correctly extends `@companion-module/tools/tsconfig/node22/recommended` (resolving the prior review's C9), but its body differs from the template. Template:

```jsonc
{
 "extends": "@companion-module/tools/tsconfig/node22/recommended",
 "include": ["src/**/*.ts"],
 "exclude": ["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"],
 "compilerOptions": {
  "outDir": "./dist",
  "baseUrl": "./",
  "paths": { "*": ["./node_modules/*"] },
  "module": "Node16",
  "moduleResolution": "Node16"
 }
}
```

Module:

```jsonc
{
 "extends": "@companion-module/tools/tsconfig/node22/recommended",
 "compilerOptions": { "outDir": "dist", "rootDir": "src" },
 "include": ["src/**/*"]
}
```

Build and lint pass (the dropped `module`/`moduleResolution`/`baseUrl`/`paths` are inherited from the extended `node22/recommended` base), so this is a template-alignment issue rather than functional breakage.

**Fix Required:** Match the template's `tsconfig.build.json` (`include: ["src/**/*.ts"]`, the standard `exclude` array, and the template `compilerOptions`). If the maintainer intends a deliberate, simpler structure, confirm with the reviewer that it satisfies the template-compliance requirement.

---

## 🟠 High

### H1: countInDuration and jumpMode wrongly added to BOOLEAN_SETTINGS

**Classification:** 🆕 NEW
**File:** `src/constants.ts:15-16`

`countInDuration` and `jumpMode` were added to the `BOOLEAN_SETTINGS` array, but neither is a boolean:

- `countInDuration` is a numeric enum (1/2/4 bars), stored via `setVariableValues({ countInDuration: Number(value) })` (`main.ts:586`).
- `jumpMode` is a string enum (`quantized` / `end-of-section` / … / `manual`), stored via `String(value)` (`main.ts:590`).

`BOOLEAN_SETTINGS` drives both the auto-generated "Toggle Setting" presets (`presets.ts:1047-1069`) and the `ToggleSetting` action (`main.ts:948-951`):

```ts
const setting = this.getVariableValue(String(options.setting)) ?? false
this.sendOsc([`/settings/${options.setting}`, Number(!setting)])
```

For `countInDuration` (e.g. current value `2`): `!2 → false → Number(false) = 0`, sending `/settings/countInDuration 0` — an invalid duration. For `jumpMode` (e.g. `"quantized"`): `!"quantized" → false → 0`, sending an invalid jump mode. The generated `SettingEqualsValue` feedback compares against `'true'`, so it never matches these values and the buttons never show their "on" state. Pressing the auto-generated button therefore corrupts the setting on the device.

This is also redundant: dedicated presets (`countInDurationSettingsPresets`, `jumpModeSettingsPresets`) and actions (`SetCountInDuration` at `main.ts:1036`, `SetJumpMode` at `main.ts:1049`) already handle these correctly.

**Fix Required:** Remove `countInDuration` and `jumpMode` from `BOOLEAN_SETTINGS` (`src/constants.ts:15-16`). Keep them only in their dedicated value-based preset/action generators and in the `SettingEqualsValue` dropdown choices (where the multi-value comparison is legitimate).

---

## 🟢 Low

### L1: Dead enum entry SetAutoLoopCurrentSection

**Classification:** 🆕 NEW (consequence of this release's removal)
**File:** `src/enums.ts:63`

`SetAutoLoopCurrentSection = 'setAutoLoopCurrentSection'` is now a dead enum member — this release removed its action definition, callback, OSC handler, variable, and dropdown entry, leaving nothing that references it. The enum line itself was not edited in the diff, but it was orphaned by the in-diff removal.

**Fix:** Delete the unused enum member once the C1 upgrade script handles existing saved references.

---
