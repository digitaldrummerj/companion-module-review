# Module Review: companion-module-noctavoxfilms-tallycomm v1.0.0

**Review date:** 2026-04-09
**Reviewer team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪
**Module version:** v1.0.0 (first release — no previous tag)
**Language:** JavaScript (CommonJS)
**API version:** v1.x (`@companion-module/base ^1.12.1`)
**Protocol:** HTTP POST to TallyComm cloud/self-hosted API (`/api/tally`)
**Source entry:** `main.js` at repo root (template non-compliant — should be `src/main.js`)

---

## Fix Summary

This is a first release of a single-file tally relay module for the TallyComm service. The functional logic is thoughtful — six well-designed actions including smart auto-clear variants, three boolean feedbacks, four variables, and clean SDK usage throughout. However, the module was submitted without any of the required template scaffolding, making it a **build failure** out of the box. Separately, the connection health-check design has a phantom tally risk and the status lifecycle has a false-positive `Ok` on init. All findings are 🆕 NEW (first release).

**Critical blocking work (must fix before merge):**
- Move `main.js` → `src/main.js` and update entrypoint references in `manifest.json` and `package.json`
- Add 7 missing required files: `.gitattributes`, `.gitignore`, `.prettierignore`, `.yarnrc.yml`, `LICENSE`, `yarn.lock`, `companion/HELP.md`
- Complete `package.json`: add `scripts`, `engines`, `prettier`, `packageManager`, `devDependencies`, fix `repository.url` scheme
- Fix `manifest.json`: add `$schema`, fix `repository` URL scheme
- Resolve phantom tally risk in `checkConnection()` — POST with `bus: 'ping'` is not a safe health probe
- Fix premature `InstanceStatus.Ok` on init (use `Connecting` first)
- Fix `_isConnected` not reset to `false` on `sendTally()` HTTP error responses
- Fix `sendTally()` swallowing errors — action callbacks update local state unconditionally on failure
- Fix `checkConnection()` not checking `response.ok` — any HTTP response resolves as connected

---

## 📊 Scorecard

| Category | New | Existing | Total |
|----------|-----|----------|-------|
| 🔴 Critical | 16 | 0 | **16** |
| 🟠 High | 6 | 0 | **6** |
| 🟡 Medium | 7 | 0 | **7** |
| 🟢 Low | 4 | 0 | **4** |
| 💡 Nice to Have | 1 | 0 | **1** |
| **Total** | **34** | **0** | **34** |

**Blocking findings:** 22 (16 Critical + 6 High)
**Non-blocking findings:** 12 (7 Medium + 4 Low + 1 NTH)
**Build status:** ❌ FAIL (`yarn package` — `Command "package" not found`)
**Test coverage:** None (non-blocking for first release)
**Health delta:** N/A (first release)

---

## ✋ Verdict

> ### 🔴 CHANGES REQUIRED
>
> **22 blocking issues** (16 Critical template violations + 6 High logic/protocol issues).
>
> The module is not ready for merge. `yarn package` fails outright due to missing `scripts` block. The source layout, all required config files, all required `package.json` fields, and two key `manifest.json` fields are non-compliant with the module template. These must be corrected as part of a proper module submission.
>
> Beyond template compliance, three High-severity protocol issues require attention before the module can be trusted in a live broadcast environment: the connection health check sends a real POST to a live tally endpoint (phantom tally risk), `checkConnection()` treats any HTTP response (including 5xx) as connected, and action callbacks silently update local state even when the HTTP send failed — meaning the module's internal state can permanently diverge from the server after a single network failure.

---

## 📋 Issues TOC

### 🔴 Critical
- [C-1: Source file at repository root — not in `src/`](#c-1-source-file-at-repository-root--not-in-src)
- [C-2: Missing required files (7)](#c-2-missing-required-files-7)
- [C-3: `package.json` — No `scripts` block (build fails)](#c-3-packagejson--no-scripts-block-build-fails)
- [C-4: `package.json` — `engines` is empty `{}`](#c-4-packagejson--engines-is-empty-)
- [C-5: `package.json` — Missing `prettier` config reference](#c-5-packagejson--missing-prettier-config-reference)
- [C-6: `package.json` — Missing `packageManager` field](#c-6-packagejson--missing-packagemanager-field)
- [C-7: `package.json` — Missing `devDependencies`](#c-7-packagejson--missing-devdependencies)
- [C-8: `package.json` — `repository.url` missing `git+` prefix](#c-8-packagejson--repositoryurl-missing-git-prefix)
- [C-9: `manifest.json` — Missing `$schema` field](#c-9-manifestjson--missing-schema-field)
- [C-10: `manifest.json` — `runtime.entrypoint` wrong path](#c-10-manifestjson--runtimeentrypoint-wrong-path)
- [C-11: `manifest.json` — `repository` missing `git+` prefix](#c-11-manifestjson--repository-missing-git-prefix)

### 🟠 High
- [H-1: `init()` sets `InstanceStatus.Ok` before connection is verified](#h-1-init-sets-instancestatusok-before-connection-is-verified)
- [H-2: `checkConnection()` sends a real tally POST — phantom tally risk](#h-2-checkconnection-sends-a-real-tally-post--phantom-tally-risk)
- [H-3: `checkConnection()` ignores `response.ok` — any HTTP response marks as connected](#h-3-checkconnection-ignores-responseok--any-http-response-marks-as-connected)
- [H-4: `sendTally()` swallows errors — action callbacks update local state unconditionally](#h-4-sendtally-swallows-errors--action-callbacks-update-local-state-unconditionally)
- [H-5: `_isConnected` not reset on `sendTally()` HTTP error — feedback goes stale](#h-5-_isconnected-not-reset-on-sendtally-http-error--feedback-goes-stale)
- [H-6: `destroy()` is a no-op — in-flight requests not cancelled, state not reset](#h-6-destroy-is-a-no-op--in-flight-requests-not-cancelled-state-not-reset)

### 🟡 Medium
- [M-1: No reconnect logic — `ConnectionFailure` is permanent until next user action](#m-1-no-reconnect-logic--connectionfailure-is-permanent-until-next-user-action)
- [M-2: Room not validated in `init()` — false `Ok` status before first action](#m-2-room-not-validated-in-init--false-ok-status-before-first-action)
- [M-3: Spanish UI strings throughout — inconsistent with English-first Companion ecosystem](#m-3-spanish-ui-strings-throughout--inconsistent-with-english-first-companion-ecosystem)
- [M-4: `camChoices` array duplicated in `initActions()` and `initFeedbacks()`](#m-4-camchoices-array-duplicated-in-initactions-and-initfeedbacks)
- [M-5: `clear_all` reliability depends on tracked state accuracy](#m-5-clear_all-reliability-depends-on-tracked-state-accuracy)
- [M-6: `legacyIds` contains `"tallycomm"` on a first release](#m-6-legacyids-contains-tallycomm-on-a-first-release)
- [M-7: `@companion-module/base` version outdated](#m-7-companion-modulebase-version-outdated)

### 🟢 Low
- [L-1: `set_pgm_auto` / `set_pvw_auto` proceed if preceding `clear` fails](#l-1-set_pgm_auto--set_pvw_auto-proceed-if-preceding-clear-fails)
- [L-2: `MAX_CAMS = 6` hardcoded — no user-configurable camera count](#l-2-max_cams--6-hardcoded--no-user-configurable-camera-count)
- [L-3: `README.md` issues link points to wrong GitHub org](#l-3-readmemd-issues-link-points-to-wrong-github-org)
- [L-4: Room validation inconsistency between `sendTally()` and `checkConnection()`](#l-4-room-validation-inconsistency-between-sendtally-and-checkconnection)

### 💡 Nice to Have
- [N-1: `manifest.json` `name` field is a slug, not a human-readable label](#n-1-manifestjson-name-field-is-a-slug-not-a-human-readable-label)

---

## 🔴 Critical

### C-1: Source file at repository root — not in `src/`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **Files:** `main.js` (root), `companion/manifest.json:12`, `package.json`

All Companion JS modules must place source under `src/main.js`. This module places `main.js` at the repository root with no `src/` directory present. The `manifest.json` entrypoint correctly reflects the actual location (`"../main.js"`), but both the file location and entrypoint reference are non-compliant.

**Evidence:**
```
/main.js                           ← at root, no src/ directory exists
package.json: "main": "main.js"   ← should be "src/main.js"
manifest.json: "entrypoint": "../main.js"  ← should be "../src/main.js"
```

**Recommendation:** Move `main.js` → `src/main.js`. Update `package.json` `"main"` to `"src/main.js"`. Update `manifest.json` `"entrypoint"` to `"../src/main.js"`.

---

### C-2: Missing required files (7)

- **Severity:** 🔴 Critical (×7)
- **Classification:** 🆕 NEW — Template Compliance
- **Location:** Repository root / `companion/`

The following files required by the Companion module template are entirely absent:

| File | Expected content |
|------|-----------------|
| `.gitattributes` | `* text=auto eol=lf` |
| `.gitignore` | `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn` |
| `.prettierignore` | `package.json` and `/LICENSE.md` |
| `.yarnrc.yml` | `nodeLinker: node-modules` |
| `LICENSE` | MIT license text — `package.json` declares `"license": "MIT"` but no file exists |
| `yarn.lock` | Generated by `yarn install` with Yarn v4 — currently absent; running `yarn install` used Yarn Classic v1.22 due to missing `.yarnrc.yml` and `packageManager` |
| `companion/HELP.md` | Real user-facing documentation — not a stub |

**Recommendation:** Copy all seven files from the official JS module template. For `companion/HELP.md`, adapt content from the existing `README.md` which already contains thorough documentation.

**Note:** During build validation, running `yarn install` without `.yarnrc.yml` or `packageManager` caused Yarn Classic v1.22 to run instead of the required Yarn v4 Berry, generating an incompatible lockfile format.

---

### C-3: `package.json` — No `scripts` block (build fails)

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `scripts` block is entirely absent. `yarn package` is required to build the module for distribution; without it, the module cannot be submitted. The `format` script is required for automated formatting checks.

**Build result:**
```
$ yarn package
error Command "package" not found.
```

**Template expects:**
```json
"scripts": {
  "format": "prettier -w .",
  "package": "companion-module-build"
}
```

---

### C-4: `package.json` — `engines` is empty `{}`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `engines` key exists but is an empty object. Both `node` and `yarn` version constraints are required.

**Found:** `"engines": {}`
**Template expects:**
```json
"engines": {
  "node": "^22.20",
  "yarn": "^4"
}
```

---

### C-5: `package.json` — Missing `prettier` config reference

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `prettier` field is absent. Without it, Prettier will not pick up the shared config from `@companion-module/tools`, meaning formatting will not match the Companion standard.

**Template expects:** `"prettier": "@companion-module/tools/.prettierrc.json"`

---

### C-6: `package.json` — Missing `packageManager` field

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

`packageManager` is absent. This caused `yarn install` to fall back to Yarn Classic v1.22 during review instead of the required Yarn v4 Berry.

**Template expects:** `"packageManager": "yarn@4.x.x"` (e.g. `"yarn@4.12.0"`)

---

### C-7: `package.json` — Missing `devDependencies`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `devDependencies` block is entirely absent. Both `@companion-module/tools` (provides `companion-module-build` for the `package` script and the shared Prettier config) and `prettier` are required.

**Template expects:**
```json
"devDependencies": {
  "@companion-module/tools": "^2.6.1",
  "prettier": "^3.7.4"
}
```

---

### C-8: `package.json` — `repository.url` missing `git+` prefix

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The npm/Yarn toolchain expects the `git+https://` URL scheme for repository entries.

**Found:** `"url": "https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`
**Expected:** `"url": "git+https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`

---

### C-9: `manifest.json` — Missing `$schema` field

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `companion/manifest.json`

The `$schema` field is entirely absent. It is required for IDE validation and checked by the automated module-checks workflow.

**Template expects** (as first field):
```json
"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"
```

---

### C-10: `manifest.json` — `runtime.entrypoint` wrong path

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `companion/manifest.json`

The entrypoint matches the current (non-compliant) source location at root. Once C-1 is resolved and source is moved to `src/`, this must be updated.

**Found:** `"entrypoint": "../main.js"`
**Expected:** `"entrypoint": "../src/main.js"`

*This finding is directly coupled to C-1.*

---

### C-11: `manifest.json` — `repository` missing `git+` prefix

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `companion/manifest.json`

The `repository` URL in the manifest also uses the plain `https://` scheme.

**Found:** `"repository": "https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`
**Expected:** `"repository": "git+https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`

---

## 🟠 High

### H-1: `init()` sets `InstanceStatus.Ok` before connection is verified

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `main.js:18`

`updateStatus(InstanceStatus.Ok)` is called synchronously at the top of `init()`, before `checkConnection()` has resolved. Because `checkConnection()` is intentionally not awaited and times out after 5 seconds, the Companion UI displays a green "OK" indicator for the full timeout window even when the server is unreachable. Operators relying on the `is_connected` feedback or `connected` variable will see a false-positive "online" state — and if the server never responds, permanently.

**Evidence:**
```js
async init(config) {
    // ...
    this.updateStatus(InstanceStatus.Ok)   // ← immediate Ok, before check
    this.initActions()
    this.initFeedbacks()
    this.initVariables()
    this.updateVariables()
    this.checkConnection()                 // ← async, not awaited
}
```

**Recommendation:** Set `InstanceStatus.Connecting` on init; let `checkConnection()` transition to `Ok` or `ConnectionFailure`:
```js
this.updateStatus(InstanceStatus.Connecting)
// ... init actions/feedbacks/variables ...
this.checkConnection()
```

---

### H-2: `checkConnection()` sends a real tally POST — phantom tally risk

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `main.js` — `checkConnection()`

The health check fires a real `POST /api/tally` with `camera: 0, bus: 'ping', room: this.room || 'companion-check'`. This is not an idempotent probe — it is a full tally write request. The TallyComm server has no obligation to treat `bus: 'ping'` or `camera: 0` as no-ops; it may broadcast or store this as a legitimate tally event and light up camera 0 on every connected smartphone in the room. This fires on every `init()` and every `configUpdated()`.

When room is not configured, the fallback `'companion-check'` creates or touches a real room on the TallyComm server on every module start — polluting server-side room state with phantom entries.

**Evidence:**
```js
body: JSON.stringify({ camera: 0, bus: 'ping', room: this.room || 'companion-check' }),
```

**Recommendation:** Use a dedicated, documented health endpoint (`GET /api/health` or `GET /api/status`) if one exists. If none exists, coordinate with the TallyComm server team to define `bus: 'ping'` as an explicit no-op and document it. In the interim, suppress `checkConnection()` entirely when room is not configured rather than substituting a phantom room name.

---

### H-3: `checkConnection()` ignores `response.ok` — any HTTP response marks as connected

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `main.js` — `checkConnection()`

The `.then()` handler fires for **any** resolved `fetch()` promise, including `4xx` and `5xx` HTTP responses. A `404`, `500`, or `401` from the server will set `_isConnected = true` and `InstanceStatus.Ok`. The module will appear fully connected and healthy even when the server is actively returning errors. This is inconsistent with `sendTally()`, which correctly checks `response.ok`.

**Evidence:**
```js
fetch(this.serverUrl + '/api/tally', { ... })
    .then(() => {                         // ← no response parameter used
        this._isConnected = true          // ← true even on HTTP 500
        this.updateStatus(InstanceStatus.Ok)
        // ...
    })
```

**Recommendation:** Inspect `response.ok` in the `.then()` handler (or refactor to `async/await`) and throw on non-ok status — matching the pattern already used in `sendTally()`.

---

### H-4: `sendTally()` swallows errors — action callbacks update local state unconditionally

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `main.js` — `sendTally()` + all 6 action callbacks

`sendTally()` catches all errors internally and never re-throws. All six action callbacks (`set_pgm`, `set_pvw`, `clear_cam`, `set_pgm_auto`, `set_pvw_auto`, `clear_all`) await `sendTally()` and then unconditionally update `currentPgm`/`currentPvw`, call `updateVariables()`, and call `checkFeedbacks()`. Because `sendTally()` never throws, the caller cannot distinguish a successful send from a failed one. After a single network failure, the module's internal tally state permanently diverges from the server, with no recovery path.

**Evidence:**
```js
// sendTally() — catches internally, never re-throws:
} catch (err) {
    this.log('error', 'Error connecting to TallyComm: ' + err.message)
    this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
    // ← no throw; callers see normal resolution
}

// All callbacks — state updated unconditionally:
await this.sendTally(cam, 'program')
this.currentPgm = cam      // ← runs even if send failed
this.updateVariables()
this.checkFeedbacks('cam_pgm', 'cam_pvw')
```

**Recommendation:** Have `sendTally()` return a boolean success flag (or re-throw), and gate all state updates in callbacks on it:
```js
const ok = await this.sendTally(cam, 'program')
if (ok) {
    this.currentPgm = cam
    this.updateVariables()
    this.checkFeedbacks('cam_pgm', 'cam_pvw')
}
```

---

### H-5: `_isConnected` not reset on `sendTally()` HTTP error — `is_connected` feedback goes stale

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `main.js` — `sendTally()`

`sendTally()` correctly sets `InstanceStatus.UnknownError` on HTTP non-ok responses, but **never sets `_isConnected = false`**. Once the module connects successfully, `_isConnected` remains `true` indefinitely even if subsequent tallies are rejected with `4xx`/`5xx`. The `is_connected` feedback will show green/online on operator panels while every tally is silently failing. The `connected` variable likewise stays `'online'`. `_isConnected` is only reset to `false` inside `checkConnection().catch()` — which only fires on network-level errors, not HTTP error responses.

**Evidence:**
```js
if (!response.ok) {
    this.log('error', 'TallyComm HTTP ' + response.status)
    this.updateStatus(InstanceStatus.UnknownError, 'HTTP ' + response.status)
    return   // ← _isConnected still true
}
```

**Recommendation:** Add `this._isConnected = false`, `this.updateVariables()`, and `this.checkFeedbacks('is_connected')` in the `!response.ok` branch of `sendTally()`, mirroring the pattern already used in `checkConnection().catch()`.

---

### H-6: `destroy()` is a no-op — in-flight requests not cancelled, state not reset

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `main.js:27–29`

`destroy()` only logs a debug message. Any in-flight `fetch()` from `checkConnection()` or `sendTally()` will continue running and may resolve or reject after destruction, calling `this.updateStatus()`, `this.log()`, and `this.updateVariables()` on a destroyed instance. Additionally, `_isConnected`, `currentPgm`, and `currentPvw` are never reset, which affects re-init sequences. `AbortSignal.timeout(5000)` bounds hangs but does not cancel on destroy.

**Evidence:**
```js
async destroy() {
    this.log('debug', 'TallyComm destroyed')
    // no abort, no state reset, no timer clearance
}
```

**Recommendation:**
```js
async destroy() {
    this._abortController?.abort()
    this._isConnected = false
    this.currentPgm = 0
    this.currentPvw = 0
    this.log('debug', 'TallyComm destroyed')
}
```
Store an `AbortController` as `this._abortController` and pass its signal to all `fetch()` calls. If the reconnect timer from M-1 is added, clear it here too.

---

## 🟡 Medium

### M-1: No reconnect logic — `ConnectionFailure` is permanent until next user action

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `main.js` — module-wide

Once `checkConnection()` fails (network outage, server restart), the module enters `ConnectionFailure` and stays there indefinitely. There is no periodic re-check timer. Recovery requires either triggering an action or manually saving config. In a live broadcast environment, a brief network hiccup could leave the module silently degraded for the entire show.

**Recommendation:** Add a reconnect interval (e.g., 30 seconds), active only when `_isConnected === false`, using `setInterval` in `init()` cleared in `destroy()`.

---

### M-2: Room not validated in `init()` — false `Ok` status before first action

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `main.js:18` / `main.js:155`

Room is only validated inside `sendTally()`. If no room is configured, `init()` sets `InstanceStatus.Ok`, `checkConnection()` fires a ping using the phantom `'companion-check'` room (see H-2), and the module shows green. The first real action then flips status to `BadConfig`. This deferred-validation UX misleads operators who trust the green status indicator.

**Recommendation:** Check `this.room` in both `init()` and `configUpdated()`. Set `InstanceStatus.BadConfig` immediately if empty and skip `checkConnection()`.

---

### M-3: Spanish UI strings throughout — inconsistent with English-first Companion ecosystem

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `main.js` (throughout)

Config labels, action/feedback descriptions, log messages, and status strings are written in Spanish. Action/feedback `name` fields, code comments, and variable names are in English. Companion's UI is English-first and used internationally; mixed-language strings produce a confusing experience for non-Spanish-speaking operators and make community support harder.

**Evidence (sample):**
```js
label: 'Sala / Evento'
tooltip: 'Nombre exacto de la sala. Debe coincidir con el que usan los camarógrafos.'
description: 'Pone la cámara en Program (rojo)'
this.log('warn', 'Sala no configurada — configura el nombre de sala en la conexión')
this.updateStatus(InstanceStatus.BadConfig, 'Sala no configurada')
```

**Recommendation:** Translate all user-visible strings to English. The README can acknowledge TallyComm's Latin American origins; the runtime UI should be English.

---

### M-4: `camChoices` array duplicated in `initActions()` and `initFeedbacks()`

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `main.js:67–70` / `main.js:170–173`

An identical `for` loop building `camChoices` appears in both `initActions()` and `initFeedbacks()`. Any future change (configurable `MAX_CAMS`, different label format) must be made in two places.

**Evidence:**
```js
// initActions() and initFeedbacks() both contain:
const camChoices = []
for (let i = 1; i <= MAX_CAMS; i++) {
    camChoices.push({ id: String(i), label: 'Camera ' + i })
}
```

**Recommendation:** Extract to a class helper method or a module-level function.

---

### M-5: `clear_all` reliability depends on tracked state accuracy

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `main.js` — `clear_all` callback

`clear_all` only sends `clear` for cameras listed in `currentPgm` and `currentPvw`. If those values have drifted from server reality (due to H-4 — sendTally silently failing), `clear_all` will miss cameras that are live on the server. This is a cascading consequence of H-4 and is fully resolved once that root-cause bug is fixed.

**Recommendation:** Once H-4 is fixed (state only updates on confirmed success), this becomes reliable. As an additional safety measure, consider a "force clear all" mode that iterates all `MAX_CAMS` cameras.

---

### M-6: `legacyIds` contains `"tallycomm"` on a first release

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `companion/manifest.json`

`legacyIds` is set to `["tallycomm"]` on what is presented as a first release. `legacyIds` is used to migrate user configs from a prior module ID. If no prior module with ID `"tallycomm"` was ever shipped, this field should be `[]`.

**Recommendation:** Confirm whether a prior module with ID `"tallycomm"` was ever shipped through the official Bitfocus channel. If not, set `"legacyIds": []`.

---

### M-7: `@companion-module/base` version outdated

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `package.json`

The module pins `^1.12.1`. The current JS template baseline is `~1.14.1`.

**Recommendation:** Update to `"@companion-module/base": "~1.14.1"` to align with the current template.

---

## 🟢 Low

### L-1: `set_pgm_auto` / `set_pvw_auto` proceed if preceding `clear` fails

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `main.js` — `set_pgm_auto` / `set_pvw_auto` callbacks

Both auto-clear actions await `sendTally(prev, 'clear')` before sending the new PGM/PVW. If the `clear` send fails (network error), `sendTally()` sets `ConnectionFailure` status but the function continues and sends the new tally anyway. The previous camera may remain live on the server while the module reports it cleared. This is a minor edge case but can cause double-tally events in a live broadcast.

**Recommendation:** Check the return value or thrown error of the `clear` send before proceeding with the new tally send. At minimum, log a warning when a clear fails so operators can diagnose stuck tally state.

---

### L-2: `MAX_CAMS = 6` hardcoded — no user-configurable camera count

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `main.js:4`

Productions with 7+ cameras cannot use this module without a code change. A simple numeric config field would make the module broadly applicable.

**Recommendation:** Add a `maxCams` config field (default 6, max ~20). Call `initActions()` and `initFeedbacks()` inside `configUpdated()` when the camera count changes to rebuild dropdowns dynamically.

---

### L-3: `README.md` issues link points to wrong GitHub org

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `README.md`

The issues link at the bottom of README points to the developer's personal org, not the Bitfocus fork where the module lives.

**Found:** `https://github.com/noctavoxfilms/companion-module-tallycomm/issues`
**Expected:** `https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm/issues`

---

### L-4: Room validation inconsistency between `sendTally()` and `checkConnection()`

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `main.js`

`sendTally()` correctly returns early with `BadConfig` when `room` is empty. `checkConnection()` silently substitutes `'companion-check'` when `room` is empty. During `configUpdated()`, both paths can fire on the same save event, and a successful `checkConnection()` ping can immediately overwrite a `BadConfig` status set by a prior `sendTally()` failure with a false `Ok`. This inconsistency is partially addressed by M-2 (validating room in `init()` / `configUpdated()`).

---

## 💡 Nice to Have

### N-1: `manifest.json` `name` field is a slug, not a human-readable label

- **Severity:** 💡 Nice to Have
- **Classification:** 🆕 NEW
- **File:** `companion/manifest.json:3`

The `name` field is `"noctavoxfilms-tallycomm"` — the package slug — while `shortname` correctly uses `"TallyComm"`. The `name` field appears in the Companion module store listing.

**Recommendation:** Set `name` to `"TallyComm"` or `"Noctavox Films TallyComm"`.

---

## 🔮 Next Release

- Configurable `maxCams` per M-2 (Low) — required to unlock 7+ camera deployments
- Periodic reconnect polling per M-1 — improves resilience in live broadcast environments
- Presets for common tally workflows (PGM/PVW set, auto-clear) would reduce setup friction

---

## 🧪 Tests

No test files found (`*.test.js`, `*.spec.js`, `__tests__/`). No test framework (Jest/Vitest) configured. No `test` script in `package.json`.

**Status: ✅ Non-blocking.** Absence of tests is expected for a first-release single-file module. The logic is simple enough to be well-covered by manual integration testing against a live TallyComm instance.

---

## ✅ What's Solid

Despite the extensive template compliance failures and protocol lifecycle issues, the **functional module logic is genuinely well-designed**:

- **Actions (6):** `set_pgm`, `set_pvw`, `clear_cam`, `clear_all`, `set_pgm_auto`, `set_pvw_auto` — all structurally correct with proper async `callback` signatures. The "auto-clear previous" variants (`set_pgm_auto`, `set_pvw_auto`) are thoughtful ergonomic additions that reduce required action count for switcher integrations
- **Feedbacks (3):** `cam_pgm`, `cam_pvw`, `is_connected` — correctly typed as `type: 'boolean'` with appropriate `defaultStyle` color values. `is_connected` feedback is a practical addition for panel-based status indication
- **Variables (4):** `pgm`, `pvw`, `room`, `connected` — well-named, appropriate scope, correctly registered and updated
- **`clear_all` edge case:** Correctly handles the `currentPgm === currentPvw` overlap — only one `clear` sent, no duplicate requests
- **`AbortSignal.timeout(5000)`** used consistently in both `sendTally()` and `checkConnection()` — no indefinitely-hanging requests
- **`sendTally()` `response.ok` check** is correct — non-ok HTTP responses are properly surfaced as errors (the same pattern just needs to be applied in `checkConnection()`)
- **URL trailing-slash normalization** (`replace(/\/$/, '')`) is a small but correct defensive touch that prevents malformed API URLs
- **`configUpdated()` triggers `checkConnection()`** — re-verifying connectivity on config save is correct behavior
- **`runEntrypoint(TallyCommInstance, [])`** — empty upgrade scripts array is correctly supplied for a first release
- **`README.md`** is thorough and well-structured with a practical ATEM switcher integration example — this content can be directly adapted for `companion/HELP.md`
- **`.github/workflows/companion-module-checks.yaml`** — CI workflow is wired up correctly
