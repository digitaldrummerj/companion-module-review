---
name: companion-v2-api-compliance
description: Compliance checks for Companion modules on @companion-module/base v2.x (Companion 4.3+) — class-based export, removed runEntrypoint/parseVariablesInString, setVariableDefinitions object form, checkAllFeedbacks, manifest type connection. Use only when package.json resolves @companion-module/base to ^2.x. For 1.x modules use companion-v1-api-compliance instead.
---

# Skill: Companion Module API v2.0 Compliance

## Purpose

Reference checklist for reviewing BitFocus Companion modules against the v2.0 API
(`@companion-module/base` >= 2.0, Companion 4.3+).

**First:** Read `package.json` — check `@companion-module/base` version:
- `^2.x` or `2.0.x` or higher → apply v2.0 rules (this skill)
- `^1.x` → v1.x rules apply (see notes at end)

---

## 🔴 Critical (module won't load or data loss risk)

| Check | Expected in v2.0 |
|---|---|
| Main file entry point | `export default class ModuleInstance extends InstanceBase<InstanceTypesShape> {}` |
| UpgradeScripts | `export const UpgradeScripts = [...]` or `export { UpgradeScripts }` |
| No `runEntrypoint()` | Must NOT be called — it is removed in v2.0 |
| `isVisible` function on option fields | **Removed in v2.x** — `isVisible: (options) => boolean` no longer works; must migrate to `isVisibleExpression` — flag as 🔴 Critical / **blocking** |
| `manifest.json` type | Must have `"type": "connection"` |
| `manifest.json` runtime | Must be `"type": "node22"` — `"node18"` is dropped |
| `@companion-module/tools` | Must be v2.7.1 or later (v3.0.0 is a drop-in replacement) |
| TypeScript tsconfig | Must use `"moduleResolution": "nodenext"` or extend `@companion-module/tools/tsconfig/node22/recommended-esm` |
| `InstanceBase<T>` generic | Must use `InstanceTypes`-shaped interface: `{ config, secrets?, actions, feedbacks, variables }` |

---

## 🟠 High (breaking API changes — flag all violations)

| Removed / Changed API | v2.0 Replacement |
|---|---|
| `setVariableDefinitions([...])` array form | Object form: `{ varId: { name: '...' } }` |
| `parseVariablesInString(...)` | Removed — Companion auto-parses variables in **any input field** with `useVariables: true` (v2 — not just `textinput`) |
| `checkFeedbacks()` (no args) | `checkAllFeedbacks()` |
| `optionsToIgnoreForSubscribe` | Replaced by allowlist `optionsToMonitorForSubscribe` |
| Feedback `subscribe` lifecycle method | Removed — `callback` is the only entry point; `unsubscribe` used for cleanup only |
| `imageBuffer` as raw Buffer | Must be base64 encoded string: `buffer.toString('base64')` |
| `learn` callback returns all options | Should return **only** learned options (returning all overwrites user expressions) |
| Upgrade script options as raw values | Must handle `{ isExpression: boolean, value: X }` shape |
| `setPresetDefinitions([...])` single array | Two params now: `setPresetDefinitions(structure, presets)` — see **Presets (v2)** below |
| Absolute delays in presets | Removed — all delays are now relative |

---

## Presets (v2)

v2 presets differ from v1 in three ways reviewers frequently get **backwards**. Do not apply
v1 preset rules to a v2 module.

**Registration — two arguments:**
```js
this.setPresetDefinitions(structure, presets)
```
- `presets` — a flat object keyed by preset id: `{ myPresetId: { ... } }`.
- `structure` — an array of **sections** that arrange those presets in the UI.

**Preset shape** (`CompanionSimplePresetDefinition`):
```js
presets.my_preset = {
  type: 'simple',          // the ONLY valid v2 type — NOT 'button' (that's v1)
  name: 'My Preset',       // shown as a tooltip
  style: { text: 'Go', size: 'auto', color: 0xffffff, bgcolor: 0x000000 },
  steps: [{ down: [{ actionId: 'my_action', options: {} }], up: [] }],
  feedbacks: [],
  // NO `category` field in v2 — grouping is done by `structure` (below).
  // optional: keywords?, previewStyle?, options?, localVariables?
}
```

**Structure — grouping/sections** (replaces v1's per-preset `category`):
```js
const structure = [
  { id: 'main', name: 'Main', definitions: ['my_preset', 'other_preset'] },
]
```
`definitions` is an array of preset ids (or of groups). **Every preset id in `presets` must
be referenced somewhere in `structure`**, or Companion warns *"preset definitions exist in
presets but are not referenced by structure."*

**⚠️ Common reviewer mistake — do NOT flag these on a v2 module:**

| | v1 (base `^1.x`) | **v2 (base `^2.x`)** |
|---|---|---|
| call | `setPresetDefinitions(presets)` | `setPresetDefinitions(structure, presets)` |
| `type` | `'button'` (and `'text'`) | **`'simple'`** |
| grouping | `category: '<string>'` per preset | `structure` sections array — **no `category`** |

A v2 preset using `type: 'simple'`, no `category`, and a two-arg
`setPresetDefinitions(structure, presets)` is **correct**. Never tell the maintainer to
switch to `'button'`, add a `category`, or collapse to a single argument — those are v1.

---

## 🟡 Medium (important but not immediately breaking)

- In v2 a `number` field can carry `useVariables: true` directly, so a `textinput` field is no longer *required* to allow variables on a numeric option. If a module still uses `textinput` for numbers purely for variable support, converting to a properly-typed `number` field (with `useVariables: true`) is a hygiene improvement — use the `FixupNumericOrVariablesValueToExpressions` helper in an upgrade script to migrate existing values. This is optional cleanup, not a prerequisite for variables to work.
- Dropdown values should be user-friendly strings — expressions will require the user to type them; cryptic values (`ch1=0`) are painful
- Actions with `subscribe` for connection management should set `optionsToMonitorForSubscribe` to avoid extra calls when unrelated options change

---

## Expression Handling Reference (v2.0)

Companion automatically parses expressions in action/feedback options when:
- Field declares `useVariables: true` → variables are parsed (any input field type, not only `textinput`)
- Field does NOT have `disableAutoExpression: true` → user can toggle to expression mode

When in expression mode, `event.options.myField` receives the computed result, validated against the field type:
- `number` field: clamped to `min`/`max`
- `dropdown` field: must match a valid option (unless `useCustom: true`)
- Set `allowInvalidValues: true` to receive non-standard values

**⚠️ Common reviewer mistake — `useVariables` is NOT `textinput`-only in v2:**

In v2, `useVariables: true` is a valid option on **all** input field types — `number`, `dropdown`,
`checkbox`, `colorpicker`, `multidropdown`, etc. — not just `textinput`. It is **not** a dead or
ignored property on a `number` field; it enables the auto-expression toggle, and the callback reads
the resolved `event.options.*`.

| | v1 (base `^1.x`) | **v2 (base `^2.x`)** |
|---|---|---|
| `useVariables` valid on | `textinput` only | **any input field** (`number`, `dropdown`, `checkbox`, …) |

Do **not** flag `useVariables: true` on a non-`textinput` field, and do **not** advise the maintainer
to drop it. The finding *"`useVariables: true` on a `number` field is ignored / a dead property"* is a
**v1-only** finding — it is wrong for a v2 (`^2.x`) module.

Upgrade scripts in v2.0 receive options as:
```ts
{ isExpression: false, value: 1 }   // was just: 1
{ isExpression: true, value: "$(local:x) + 1" }  // expression set by user
```

---

## v1.x API Quick Reference (legacy modules — still supported, not deprecated)

| Check | v1.x Expected |
|---|---|
| Entry point | `runEntrypoint(ModuleInstance, UpgradeScripts)` at bottom of main file |
| `setVariableDefinitions` | Array format `[{ variableId: '...', name: '...' }]` is correct |
| `parseVariablesInString` | Available and valid to use |
| `checkFeedbacks()` (no args) | Valid — triggers check of all feedbacks |
| manifest type | `"type"` field not required |
| manifest runtime | `"node18"` or `"node22"` both acceptable |

---

## References

- [v2.0 API Changes](https://companion.free/for-developers/module-development/api-changes/v2.0)
- [All API Changes](https://companion.free/for-developers/module-development/api-changes/)
- [Presets](https://companion.free/for-developers/module-development/connection-basics/presets)
