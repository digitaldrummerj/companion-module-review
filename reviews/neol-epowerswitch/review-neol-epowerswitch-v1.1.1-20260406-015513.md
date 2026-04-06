# Module Review: companion-module-neol-epowerswitch

| Field | Value |
|---|---|
| **Module** | companion-module-neol-epowerswitch |
| **Version** | 1.1.1 |
| **Previous Approved** | *(none — first release)* |
| **API Version** | v1.x (`@companion-module/base ~1.11.3`) |
| **Review Date** | 2026-04-06 |
| **Reviewed By** | Justin James (Firefly crew: Mal, Wash, Kaylee, Zoe, Simon) |

---

## Verdict: 🔴 CHANGES REQUIRED

Two critical blockers prevent approval: the `yarn package` build script is missing (build fails entirely) and upgrade scripts were copied from an unrelated module and reference actions and config fields that have never existed in this codebase. Additionally, there are several High/Medium template compliance items that must be addressed before resubmission. The underlying module logic — polling, actions, feedbacks, variables — is solid and well-structured.

---

## Findings

### 🔴 Critical

#### C1 — Upgrade scripts reference non-existent actions and config fields from another module

**File:** `src/upgrade.js`, lines 1–36  

The two upgrade scripts in this file were copied from a different module (likely `companion-module-generic-http` or similar) and reference action IDs and config fields that have never existed in this module at any version:

- `v1_1_4` (lines 2–20): checks for action IDs `post`, `put`, `patch` with a `contenttype` option. This module has exactly **one** action: `toggle_outlet_hidden` (see `src/actions.js`). These action IDs do not exist and never have.
- `v1_1_6` (lines 22–35): attempts to set `config.rejectUnauthorized = true`. This config field does not exist in this module. Config fields are: `prefix`, `hiddenPath`, `statusPollInterval` only (see `src/config.js`).

This is additionally a **first release** — there are no prior saved user configurations to migrate. Upgrade scripts are not required.

**Required fix:** Replace the entire contents of `src/upgrade.js` with:

```js
export const upgradeScripts = []
```

---

#### C2 — `yarn package` fails: missing `package` script

**File:** `package.json`, lines 17–20  

The module defines `"build"` and `"lint"` scripts but is missing the required `"package"` script. Running `yarn package` fails. The BitFocus build pipeline uses `yarn package` — without it, the module cannot be built or distributed.

```json
// Found:
"scripts": {
  "build": "companion-module-build",
  "lint": "companion-module-lint"
}

// Required:
"scripts": {
  "format": "prettier -w .",
  "package": "companion-module-build"
}
```

**Required fix:** Replace `build` and `lint` with `format` and `package` to match the template. The `lint` script is not part of the JS template.

---

### 🟠 High

#### H1 — Manufacturer and product names present in `manifest.json` keywords

**File:** `companion/manifest.json`, lines 27–37  

The `keywords` array contains `"neol"` (manufacturer name) and `"epowerswitch"` (product name). These values are already captured in the `manufacturer` and `products` fields of the manifest and should not be duplicated in keywords.

```json
// Found:
"keywords": ["power", "pdu", "relay", "outlet", "http", "neol", "epowerswitch", "power-switch", "remote-power"]
//                                                            ^^^^              ^^^^^^^^^^^^^
```

**Required fix:** Remove `"neol"` and `"epowerswitch"` from the keywords array. The remaining descriptive terms (`"power"`, `"pdu"`, `"relay"`, `"outlet"`, `"http"`, `"power-switch"`, `"remote-power"`) are appropriate.

---

#### H2 — `engines.node` excludes Node 22; manifest runtime is `node18`

**Files:** `package.json` line 15, `companion/manifest.json` line 18  

The `engines.node` field is `">=18 <21"`, which explicitly excludes Node 22. The `@companion-module/base ~1.11.3` SDK supports Node 22, and the current template specifies `"node": "^22.20"`. The manifest runtime type is correspondingly `"node18"` instead of `"node22"`.

These two fields must change together:

```json
// package.json — Required:
"engines": { "node": "^22.20", "yarn": "^4" }

// companion/manifest.json — Required:
"runtime": { "type": "node22", ... }
```

Note: `engines.yarn: "^4"` is also missing from the current `engines` block (see M1 below).

---

#### H3 — Non-standard entry point: root `index.js` wrapper

**Files:** `package.json` line 4, `companion/manifest.json` line 21  

The module uses a root-level `index.js` wrapper file that only imports `./src/index.js`. The template pattern is for the entry point to be `src/main.js` directly with no wrapper.

```
// Found:
package.json:      "main": "index.js"
manifest.json:     "entrypoint": "../index.js"
root index.js:     import './src/index.js'   // ← wrapper only, no logic

// Required (template pattern):
package.json:      "main": "src/main.js"
manifest.json:     "entrypoint": "../src/main.js"
```

**Required fix:** Rename `src/index.js` → `src/main.js`, update both `main` and `entrypoint` fields, and remove the root `index.js` wrapper.

---

### 🟡 Medium

#### M1 — Wrong prettier config path in `package.json`

**File:** `package.json`, line 29  

```json
// Found:
"prettier": "@companion-module/tools/prettier"

// Required:
"prettier": "@companion-module/tools/.prettierrc.json"
```

---

#### M2 — Repository URL missing `git+` prefix

**File:** `package.json`, line 9  

```json
// Found:
"url": "https://github.com/bitfocus/companion-module-neol-epowerswitch.git"

// Required:
"url": "git+https://github.com/bitfocus/companion-module-neol-epowerswitch.git"
```

---

#### M3 — `.prettierignore` content does not match template

**File:** `.prettierignore`, lines 1–6  

The file contains gitignore-style entries (`node_modules/`, `.yarn/`, `dist/`, etc.) that belong in `.gitignore`, not `.prettierignore`.

```
// Required (2 lines only):
package.json
/LICENSE.md
```

---

#### M4 — `InstanceStatus.Ok` set before device connectivity is verified

**Files:** `src/index.js` lines 25, 43  

Both `init()` and `configUpdated()` call `this.updateStatus(InstanceStatus.Ok)` immediately before any HTTP request. The module appears green even when the device is unreachable. The first poll's error is silently swallowed via `.catch(() => {})`, so the incorrect status may persist for an entire poll interval before correcting.

The expected pattern is to start in `InstanceStatus.Connecting` and transition to `Ok` only on the first successful poll response.

---

#### M5 — `hiddenPath` without leading slash produces a malformed URL

**File:** `src/polling.js`, lines 34–36  

`buildHiddenBaseUrl` guards against double slashes (both base ends with `/` and path starts with `/`) but does not guard against a missing leading slash on `path`:

```
prefix = "http://10.0.0.1"
hiddenPath = "hidden.htm"   // no leading slash
→ url = "http://10.0.0.1hidden.htm"   // MALFORMED
```

The config default and tooltip show `/hidden.htm` correctly, but the runtime lacks a guard. The fix is to normalise `path` to always have a leading slash before concatenation.

---

### 🟢 Low

#### L1 — README title does not match package name

**File:** `README.md`, line 1  

```
// Found:   # companion-module-epowerswitch4
// Expected: # companion-module-neol-epowerswitch
```

---

#### L2 — `.gitignore` uses `.yarn/` instead of `/.yarn`

**File:** `.gitignore`, line 6  

Template specifies `/.yarn` (rooted); the module has `.yarn/` (unrooted). Minor but is a deviation from the template.

---

#### L3 — Network errors use `InstanceStatus.UnknownError` instead of `ConnectionFailure`

**File:** `src/polling.js`, lines 73, 92, 132  

`InstanceStatus.ConnectionFailure` exists specifically for network-level failures (ECONNREFUSED, ETIMEDOUT, etc.). Using `UnknownError` for all failure types makes it harder to distinguish "device offline" from "unexpected device response" in operator dashboards. Not blocking, but worth improving.

---

#### L4 — `init()` and `configUpdated()` are nearly identical (code duplication)

**File:** `src/index.js`, lines 17–51  

The two methods perform exactly the same operations in the same order with no behavioral differences. The standard pattern is `init(config) { this.configUpdated(config) }` to delegate to a single implementation. Carries a maintenance risk if one is updated without the other.

---

#### L5 — Toggle defaults to `ON` when outlet state is unknown

**File:** `src/polling.js`, line 53  

`self.outletStates?.[outlet] ? 'OFF' : 'ON'` — if the module has not yet successfully polled (device offline at startup), `outletStates` is `{}` and toggle always sends `ON`. If the outlet was already on, this is a silent no-op instead of an actual toggle. The current behavior is arguably safe but worth documenting or handling explicitly.

---

### 💡 Nice to Have

#### N1 — `dist/` not listed in `.gitignore`

**File:** `.gitignore`  

`dist/` is not currently committed (verified), but it is not listed in `.gitignore` either. The template includes it. Worth adding as a safety net.

---

#### N2 — Git release tag omits `v` prefix

**Observed:** Git tag is `1.1.1`; the standard pattern across the ecosystem is `v1.1.1`. No functional impact, but consistency helps tooling.

---

## ✅ What's Solid

**Architecture & SDK compliance**
- `runEntrypoint(EPowerSwitchInstance, upgradeScripts)` correctly called at bottom of `src/index.js`
- All required lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- `destroy()` correctly clears the polling timer — no leaks
- Clean modular structure: actions, feedbacks, variables, presets, polling each in their own file
- All relative imports use `.js` extensions (ESM compliant)

**HTTP protocol & connection handling**
- All `got` calls wrapped in try/catch with proper error logging and status updates — no unhandled rejections
- `timeout: { request: 5000 }` correctly used per `got` v14 API
- `throwHttpErrors: false` used appropriately to allow manual response code inspection
- `startPolling()` always calls `stopPolling()` first — idempotent, no timer leaks
- Early `pollStatus()` after `sendOutletCommand()` gives operators fast feedback

**Response parsing**
- Regex `/M0:O([1-4])=(On|Off)/g` is efficient and defensive
- Validates that at least one outlet was parsed before updating state
- Sets `UnknownError` if device returns unexpected response format

**Null/undefined safety**
- Consistent use of optional chaining and nullish coalescing throughout: `self.config?.prefix`, `action.options.outlet ?? 1`, `self.outletStates?.[outlet]`

**Actions, feedbacks, presets, variables**
- Single action (`toggle_outlet_hidden`) is well-structured with clear description
- Boolean feedback (`outletStateFromHidden`) correctly returns boolean type
- Presets are well-categorised and integrate feedbacks
- Variables are appropriately named and documented

**Package & config**
- No `package-lock.json` (yarn-only, as required)
- `dist/` not committed
- `companion/HELP.md` is well-written and complete (not a stub)
- `.gitattributes` and `.yarnrc.yml` match template exactly
- Maintainer info correctly filled in (not placeholder)

**Tests**
- No tests present. Not required for this module type.

---

## Summary

| Severity | Count | Blocking |
|---|---|---|
| 🔴 Critical | 2 | Yes |
| 🟠 High | 3 | Yes |
| 🟡 Medium | 5 | Yes (M1–M3); No (M4–M5) |
| 🟢 Low | 5 | No |
| 💡 Nice to Have | 2 | No |

The fix surface is well-defined. The module logic itself is clean — once the template compliance issues and the orphaned upgrade scripts are corrected and the build passes, this should be ready for re-review.
