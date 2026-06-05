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
| `parseVariablesInString(...)` | Removed — Companion auto-parses variables in `textinput` fields with `useVariables: true` |
| `checkFeedbacks()` (no args) | `checkAllFeedbacks()` |
| `optionsToIgnoreForSubscribe` | Replaced by allowlist `optionsToMonitorForSubscribe` |
| Feedback `subscribe` lifecycle method | Removed — `callback` is the only entry point; `unsubscribe` used for cleanup only |
| `imageBuffer` as raw Buffer | Must be base64 encoded string: `buffer.toString('base64')` |
| `learn` callback returns all options | Should return **only** learned options (returning all overwrites user expressions) |
| Upgrade script options as raw values | Must handle `{ isExpression: boolean, value: X }` shape |
| `setPresetDefinitions([...])` single array | Now takes two params: `setPresetDefinitions(structure, presets)` |
| Absolute delays in presets | Removed — all delays are now relative |

---

## 🟡 Medium (important but not immediately breaking)

- If a module uses `textinput` fields for numbers just to allow variables, consider converting to `number` type fields and using `FixupNumericOrVariablesValueToExpressions` helper in an upgrade script
- Dropdown values should be user-friendly strings — expressions will require the user to type them; cryptic values (`ch1=0`) are painful
- Actions with `subscribe` for connection management should set `optionsToMonitorForSubscribe` to avoid extra calls when unrelated options change

---

## Expression Handling Reference (v2.0)

Companion automatically parses expressions in action/feedback options when:
- Field is `textinput` with `useVariables: true` → variables are parsed
- Field does NOT have `disableAutoExpression: true` → user can toggle to expression mode

When in expression mode, `event.options.myField` receives the computed result, validated against the field type:
- `number` field: clamped to `min`/`max`
- `dropdown` field: must match a valid option (unless `useCustom: true`)
- Set `allowInvalidValues: true` to receive non-standard values

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
