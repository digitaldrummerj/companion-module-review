# Review: panasonic-ak-hrp1000 @ v1.0.0

| Field | Value |
|-------|-------|
| **Module** | `companion-module-panasonic-ak-hrp1000` |
| **Tag** | `v1.0.0` |
| **Commit** | `7cebebe` |
| **Reviewed** | 2026-04-04 |
| **Reviewers** | Mal (Lead), Wash (Protocol), Kaylee (Module Dev), Zoe (QA), Simon (Tests) |
| **Previous tag** | — (first release) |
| **API version** | v2.0 (`@companion-module/base ~2.0.3`) |
| **Module type** | TypeScript / ESM |
| **Build** | ✅ `yarn package` → `panasonic-ak-hrp1000-1.0.0.tgz` |
| **Lint** | ✅ `yarn lint` passes, zero warnings |

---

## Fix Summary for Maintainer

**2 issues require a fix before approval:**

- **C1:** Add `"type": "connection"` to `companion/manifest.json` — one line, required for v2.0 API compliance.
- **H1:** Action callback throws `Error` instead of logging — replace `throw new Error(...)` with `self.log('error', ...)` + `return` in `src/actions.ts`.

All other findings are Low or Nice-to-Have and can be addressed at any time. A fix branch has been created: `fix/v1.0.0-2026-04-04-issues`.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 0 | 1 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 2 | 0 | 2 |
| 💡 Nice to Have | 2 | 0 | 2 |
| **Total** | **7** | **0** | **7** |

**Blocking:** 2 issues (1 new critical, 1 new high)  
**Fix complexity:** Quick — one-line manifest fix + replace throw with log('error', ...)  
**Health delta:** 7 introduced · 0 pre-existing  

---

## Verdict

### ❌ Changes Required

One critical v2.0 API compliance gap and one high-severity runtime issue must be resolved before this module can be approved. Both fixes are straightforward: add `"type": "connection"` to `manifest.json` and replace the `throw` in the action callback with `self.log('error', ...)` + `return`. All other issues are low-severity housekeeping items.

The module is otherwise well-written. The HTTP fire-and-forget pattern with PQueue rate-limiting and AbortController cancellation is clean and appropriate for this device. Build and lint pass cleanly.

---

## 📋 Issues

**Blocking**
- [x] [C1: manifest.json missing "type": "connection" field](#c1-manifestjson-missing-type-connection-field)
- [x] [H1: Action callback throws Error instead of using log('error', ...)](#h1-action-callback-throws-error-instead-of-using-logerror-)

**Non-blocking**
- [ ] [L1: rp150_to_ak-hrp1000.pcap development artifact committed to repo root](#l1-rp150_to_ak-hrp1000pcap-development-artifact-committed-to-repo-root)
- [x] [L2: Commented-out dead code in presets.ts](#l2-commented-out-dead-code-in-presetsts)
- [x] [L3: tsconfig.json extends tools config directly instead of tsconfig.build.json](#l3-tsconfigjson-extends-tools-config-directly-instead-of-tsconfigbuildjson)
- [ ] [N1: No presets defined for the single action](#n1-no-presets-defined-for-the-single-action)
- [x] [N2: HELP.md typo in note text](#n2-helpmd-typo-in-note-text)

---

## 🔴 Critical

### C1: manifest.json missing "type": "connection" field

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`

The manifest does not include the top-level `"type"` field required for v2.0 modules. The v2.0 API compliance checklist classifies this as Critical. The manifest schema in the installed `@companion-module/base` package defines this field with the only permitted value being `"connection"`:

```json
// schema excerpt (node_modules/@companion-module/base/assets/manifest.schema.json)
"type": {
  "type": "string",
  "enum": ["connection"],
  "description": "Type of module. Must be: connection"
}
```

**Context:** The JSON Schema does not currently list `"type"` in its `required` array, so the build succeeds and the module may load in Companion 4.3 without this field. However, the v2.0 API explicitly requires it for proper module classification, and it is expected to become enforced in future Companion releases.

**Fix:**

```json
// companion/manifest.json — add after "id"
{
  "$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json",
  "id": "panasonic-ak-hrp1000",
  "type": "connection",          // ← add this line
  "name": "panasonic-ak-hrp1000",
  ...
}
```

---

## 🟠 High

### H1: Action callback throws Error instead of using log('error', ...)

**Classification:** 🆕 NEW  
**File:** `src/actions.ts`

```typescript
callback: async (event) => {
    const camera = event.options.camera
    if (!Number.isInteger(camera) || camera < 1 || camera > 99)
        throw new Error(`Invalid camera selection: ${camera}`)
    await self.httpGet(`aw_cam?cmd=XPT:${camera}&res=1`)
},
```

Throwing from an action callback is a breaking behaviour — Companion surfaces the unhandled exception as a crash-level error in the UI rather than a graceful log message. Action callbacks must never throw; errors should be logged via `self.log('error', ...)` and the callback should return early:

```typescript
callback: async (event) => {
    const camera = event.options.camera
    if (!Number.isInteger(camera) || camera < 1 || camera > 99) {
        self.log('error', `Invalid camera selection: ${camera} — must be 1-99`)
        return
    }
    await self.httpGet(`aw_cam?cmd=XPT:${camera}&res=1`)
},
```

**Fix:** Replace `throw new Error(...)` with `self.log('error', ...)` + `return`.

---

## 🟢 Low

### L1: rp150_to_ak-hrp1000.pcap development artifact committed to repo root

**Classification:** 🆕 NEW  
**File:** `rp150_to_ak-hrp1000.pcap` (repo root)

A Wireshark packet capture file (13 KB) is committed at the module root. This appears to be a development/reverse-engineering artifact used while building the module.

> **Note for maintainer:** This file may be intentionally kept for reference or future development. If you no longer need it in the repo, you can remove it from git tracking:
>
> ```bash
> git rm rp150_to_ak-hrp1000.pcap
> # optionally add to .gitignore:
> *.pcap
> ```
>
> If the pcap contains sensitive network traffic, a history rewrite (`git filter-repo`) would be needed to fully remove it — out of scope here. No action required if you want to keep it.

---

### L2: Commented-out dead code in presets.ts

**Classification:** 🆕 NEW  
**File:** `src/presets.ts`

```typescript
export function UpdatePresets(_self: ModuleInstance): void {
    //const presets: CompanionPresetDefinitions = {}
    //self.setPresetDefinitions(presets)
}
```

The function body is entirely commented out. `setPresetDefinitions` is never called. The `_self` underscore prefix correctly signals the parameter is unused, but the commented code is noise. Either remove the commented lines (leaving a clean empty function) or remove the function entirely since it's only called from `main.ts` via `this.updatePresets()` which could also be dropped.

**Fix option A — clean up in place:**

```typescript
export function UpdatePresets(_self: ModuleInstance): void {
    // No presets for this module — device does not maintain state
}
```

**Fix option B — remove entirely** from `presets.ts` and remove the `updatePresets()` private method and its call from `main.ts`.

---

### L3: tsconfig.json extends tools config directly instead of tsconfig.build.json

**Classification:** 🆕 NEW  
**File:** `tsconfig.json`

```json
// Found:
{
  "extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json",
  ...
}

// Template expects:
{
  "extends": "./tsconfig.build.json",
  ...
}
```

`tsconfig.json` (used for IDE type-checking) should extend `tsconfig.build.json` so that it inherits `outDir`, `baseUrl`, `paths`, and the test-file exclusion patterns. The current form re-extends the base tools config independently, meaning the dev tsconfig does not include test file exclusions (`src/**/*spec.ts`, `src/**/__tests__/*`, etc.) and does not inherit the `outDir` setting.

In practice for this module — which has no test files and whose `tsconfig.json` is only used for IDE tooling — the functional difference is zero. But the deviation from the template reduces maintainability.

**Fix:**

```json
// tsconfig.json
{
  "extends": "./tsconfig.build.json",
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules/**"],
  "compilerOptions": {
    "types": ["node"]
  }
}
```

---

## 💡 Nice to Have

### N1: No presets defined for the single action

**Classification:** 🆕 NEW  
**File:** `src/presets.ts`

The module has one action — "Select Camera" — but zero presets. A simple bank of presets for cameras 1–9 (or even 1–3) would significantly lower the barrier for users setting up a new stream deck page. Presets don't need to be exhaustive; even a single "Select Camera 1" template gets users started.

**Suggested approach:**

```typescript
// src/presets.ts
import { CompanionPresetDefinitions, combineRgb } from '@companion-module/base'
import { ActionId } from './actions.js'

export function UpdatePresets(self: ModuleInstance): void {
    const presets: CompanionPresetDefinitions = {}
    for (let i = 1; i <= 9; i++) {
        presets[`select_camera_${i}`] = {
            type: 'button',
            category: 'Select Camera',
            name: `Camera ${i}`,
            style: {
                text: `CAM ${i}`,
                size: '18',
                color: combineRgb(255, 255, 255),
                bgcolor: combineRgb(0, 0, 0),
            },
            steps: [{ down: [{ actionId: ActionId.SelectCamera, options: { camera: i } }], up: [] }],
            feedbacks: [],
        }
    }
    self.setPresetDefinitions(presets)
}
```

> Note: In v2.0, `setPresetDefinitions` takes two params `(structure, presets)` — check the API when implementing.

---

### N2: HELP.md typo in note text

**Classification:** 🆕 NEW  
**File:** `companion/HELP.md`

```
"the unit always returns an error even when it successfully recieves and actions a command"
                                                              ^^^^^^^^
```

Should be **receives** (not **recieves**).

---

## 🔮 Next Release

1. **Add a `last_camera` variable** — expose the last-selected camera number as a Companion variable (`$(panasonic-ak-hrp1000:last_camera)`). Update `src/variables.ts` to define it and set it in the action callback after a successful request.

2. **Add presets** — implement the suggestion in N1 above.

3. **Remove unused `priority` parameter from `httpGet`** — the method signature includes `priority: number = 0` and passes it to `queue.add()`, but no call site in the module uses a non-default priority. Either remove the parameter or document when it should be used.

4. **Consider `secret-text` for credentials** — currently the module has no authentication fields. If the device adds auth in a future firmware, use `secret-text` type for password fields (v1.13+ / v2.0 API) rather than plain `textinput`.

---

## 🧪 Tests

**No test files found** (`src/*.test.ts`, `src/*.spec.ts` — none present).

For a module of this scope (single HTTP action, no state, no feedbacks, no variables), the absence of tests is acceptable. The only meaningful unit-testable behavior is:

- The `httpGet` queue-and-cancel logic
- The camera number validation in the action callback

If tests are added in a future release, the `tsconfig.json` already includes comments pointing to Jest (`// "jest"`). Consider Vitest for ESM modules — it integrates cleanly with the v2.0 ESM setup without the Jest + ESM transform overhead.

---

## ✅ What's Solid

- **Clean v2.0 module structure.** Correct `export default class ModuleInstance extends InstanceBase<PanasonicTypes>`, typed `InstanceTypes`-shaped generic, proper `export { UpgradeScripts }` re-export from `main.ts`. All v2.0 critical patterns are in place.

- **Elegant HTTP queue pattern.** The PQueue + AbortController combination — clear queue → abort in-flight → fresh controller → enqueue new request — is exactly the right pattern for "only the last command matters" semantics. The 500 ms interval cap prevents hammering the device.

- **No persistent connection by design, and documented.** HELP.md explicitly calls out that the module doesn't maintain a connection and the device always returns an HTTP error. This is an honest, user-facing explanation of an unusual device behavior, and the code matches: errors are caught and logged at `debug` level, not surfaced as failures.

- **Proper typed action definitions.** `ActionSchema`, `FeedbackSchema`, `VariableSchema` are all exported and wired into the `PanasonicTypes` interface correctly. The `CompanionActionDefinitions<ActionSchema>` return type on `UpdateActions` is idiomatic v2.0 TypeScript.

- **All required template files present with correct content.** `.gitattributes`, `.gitignore`, `.prettierignore`, `.yarnrc.yml`, `eslint.config.mjs`, `.husky/pre-commit`, `tsconfig.build.json`, `tsconfig.json`, `companion/manifest.json`, `companion/HELP.md` — all present and matching template expectations.

- **`yarn package` and `yarn lint` pass cleanly.** Zero build errors, zero lint warnings.

- **Real HELP.md.** Not a stub — includes firmware version requirements, step-by-step setup instructions for the device menu, and an honest note about the device's unusual HTTP behavior.

- **Input validation in action callback.** Even though the field constraints (`min: 1, max: 99, asInteger: true`) provide the first line of defense, the explicit `Number.isInteger` check is good defensive programming.
