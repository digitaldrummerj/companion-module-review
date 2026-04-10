# Module Review: companion-module-wearefalcon-falconplay v1.0.0

**Review date:** 2026-04-09
**Reviewer team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪
**Module version:** v1.0.0 (first release — no previous tag)
**Language:** JavaScript (CommonJS — no `"type"` field)
**API version:** v1.x (`@companion-module/base ~1.12.1`)
**Protocol:** HTTP REST polling — `GET /api/status` every 2s, list refresh every 10s
**Source layout:** Multi-file — `src/main.js`, `src/actions.js`, `src/feedbacks.js`, `src/variables.js`, `src/upgrades.js`

---

## Fix Summary

A well-structured first release with a clean multi-file layout, sensible polling architecture, and a meaningful feature set (13 actions, 3 feedbacks, 9 variables). Template scaffolding is largely in place — all required files are present. However, the module ships with its identity metadata pointing entirely at the author's personal GitHub repository instead of the Bitfocus fork, and several manifest fields are wrong or missing. Two functional bugs need resolution before merge: the `onAirInput` feedback is permanently unusable (its dropdown choices are populated from an empty list and never refreshed), and both HTTP helpers skip the `response.ok` check before parsing JSON (causing confusing `SyntaxError` messages on server error responses).

**Critical blocking work (must fix before merge):**
- Update `manifest.json` `id` and `package.json` `name` to `wearefalcon-falconplay` / `companion-module-wearefalcon-falconplay`
- Update `manifest.json` `repository`, `bugs`, and `package.json` `repository.url` from personal repo to Bitfocus repo
- Add `manifest.json` `$schema` field
- Fix `manifest.json` `runtime.apiVersion` from `"0.0.0"` to actual version (`"1.12.1"`)
- Fix `onAirInput` feedback — call `updateFeedbacks()` in `refreshLists()` alongside `updateActions()`
- Add `response.ok` check in `httpGet()` and `httpPost()` before calling `.json()`

---

## 📊 Scorecard

| Category | New | Existing | Total |
|----------|-----|----------|-------|
| 🔴 Critical | 7 | 0 | **7** |
| 🟠 High | 2 | 0 | **2** |
| 🟡 Medium | 8 | 0 | **8** |
| 🟢 Low | 6 | 0 | **6** |
| 💡 Nice to Have | 2 | 0 | **2** |
| **Total** | **25** | **0** | **25** |

**Blocking findings:** 9 (7 Critical + 2 High)
**Non-blocking findings:** 16 (8 Medium + 6 Low + 2 NTH)
**Build status:** ✅ PASS (`yarn install && yarn package` succeeds — outputs `falcon-play-1.0.0.tgz` under wrong name due to wrong `id`)
**Test coverage:** None (non-blocking for first release)
**Health delta:** N/A (first release)

---

## ✋ Verdict

> ### 🔴 CHANGES REQUIRED
>
> **9 blocking issues** (7 Critical metadata/manifest violations + 2 High functional bugs).
>
> The module builds successfully but ships with its identity entirely pointing at the author's personal GitHub repo — the manifest `id`, both repository URLs, the bugs URL, and the package name all need updating to match the canonical Bitfocus repository. These are not cosmetic issues: the wrong `id` causes the built package to be named `falcon-play-1.0.0.tgz` and would cause install and upgrade mismatches in Companion.
>
> Two functional bugs also block merge: the `onAirInput` feedback has a permanently empty dropdown (never re-populated after the initial empty state), and both HTTP helpers throw confusing `SyntaxError` messages on server error responses instead of surfacing meaningful HTTP status codes.

---

## 📋 Issues TOC

### 🔴 Critical
- [C-1: `manifest.json` `id` and `package.json` `name` — wrong module identity](#c-1-manifestjson-id-and-packagejson-name--wrong-module-identity)
- [C-2: `manifest.json` + `package.json` repository URLs point to personal GitHub repo](#c-2-manifestjson--packagejson-repository-urls-point-to-personal-github-repo)
- [C-3: `manifest.json` `bugs` URL points to personal GitHub repo](#c-3-manifestjson-bugs-url-points-to-personal-github-repo)
- [C-4: `manifest.json` missing `$schema` field](#c-4-manifestjson-missing-schema-field)
- [C-5: `manifest.json` `runtime.apiVersion` is `"0.0.0"`](#c-5-manifestjson-runtimeapiversion-is-000)

### 🟠 High
- [H-1: `onAirInput` feedback dropdown permanently empty — `updateFeedbacks()` never re-called](#h-1-onairiinput-feedback-dropdown-permanently-empty--updatefeedbacks-never-re-called)
- [H-2: `httpGet()` / `httpPost()` skip `response.ok` — SyntaxError on server error pages](#h-2-httpget--httppost-skip-responseok--syntaxerror-on-server-error-pages)

### 🟡 Medium
- [M-1: `init()` sets no status before polling — up to 5-second unknown state window](#m-1-init-sets-no-status-before-polling--up-to-5-second-unknown-state-window)
- [M-2: `configUpdated()` doesn't call `updateFeedbacks()` or clear stale server state](#m-2-configupdated-doesnt-call-updatefeedbacks-or-clear-stale-server-state)
- [M-3: `pollStatus()` doesn't call `checkFeedbacks()` on `data.ok === false` branch](#m-3-pollstatus-doesnt-call-checkfeedbacks-on-dataok--false-branch)
- [M-4: `refreshLists()` re-registers all actions on every cycle — no change detection](#m-4-reflishlists-re-registers-all-actions-on-every-cycle--no-change-detection)
- [M-5: Polling concurrency — `setInterval` + 5-second timeout allows up to 3 concurrent polls](#m-5-polling-concurrency--setinterval--5-second-timeout-allows-up-to-3-concurrent-polls)
- [M-6: `refreshLists()` failures are fully silent — stale list data with no warning](#m-6-reflishlists-failures-are-fully-silent--stale-list-data-with-no-warning)
- [M-7: `?? 0` / `?? ''` default type mismatch — saved action IDs orphaned on late list load](#m-7--0----default-type-mismatch--saved-action-ids-orphaned-on-late-list-load)
- [M-8: Keywords include partial manufacturer name and third-party system name](#m-8-keywords-include-partial-manufacturer-name-and-third-party-system-name)

### 🟢 Low
- [L-1: `destroy()` doesn't cancel in-flight requests](#l-1-destroy-doesnt-cancel-in-flight-requests)
- [L-2: Variables undefined until first successful poll](#l-2-variables-undefined-until-first-successful-poll)
- [L-3: `companion/HELP.md` missing 4 of 13 actions](#l-3-companionhelpmd-missing-4-of-13-actions)
- [L-4: `pollStatus()` `catch {}` discards all error context](#l-4-pollstatus-catch--discards-all-error-context)
- [L-5: Action callbacks log `"Action failed: undefined"` on unexpected JSON shape](#l-5-action-callbacks-log-action-failed-undefined-on-unexpected-json-shape)
- [L-6: `.gitignore` and `.prettierignore` minor deviations from template](#l-6-gitignore-and-prettierignore-minor-deviations-from-template)

### 💡 Nice to Have
- [N-1: `manifest.json` `name` field should be human-readable](#n-1-manifestjson-name-field-should-be-human-readable)
- [N-2: No presets defined](#n-2-no-presets-defined)

---

## 🔴 Critical

### C-1: `manifest.json` `id` and `package.json` `name` — wrong module identity

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance / Identity
- **Files:** `companion/manifest.json`, `package.json`

The manifest `id` and package `name` both use `"falcon-play"` / `"companion-module-falcon-play"` — derived from the author's personal repo name — rather than the canonical Bitfocus repository slug. Companion uses the manifest `id` to identify, install, and upgrade modules; a mismatch causes upgrade detection failures. The built package is named `falcon-play-1.0.0.tgz` instead of `wearefalcon-falconplay-1.0.0.tgz`.

**Evidence:**
```json
// companion/manifest.json
"id": "falcon-play"                              // ← should be "wearefalcon-falconplay"

// package.json
"name": "companion-module-falcon-play"           // ← should be "companion-module-wearefalcon-falconplay"
```

**Recommendation:**
- `manifest.json`: `"id": "wearefalcon-falconplay"`
- `package.json`: `"name": "companion-module-wearefalcon-falconplay"`

---

### C-2: `manifest.json` + `package.json` repository URLs point to personal GitHub repo

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance / Identity
- **Files:** `companion/manifest.json`, `package.json`

Both repository URL fields point to `MoodyJerup/companion-falconplay` — the author's personal fork — rather than the Bitfocus repository where the module will be maintained and reviewed. Bitfocus CI checks, update resolution, and community issue tracking all depend on these pointing to the correct location.

**Evidence:**
```json
// companion/manifest.json
"repository": "git+https://github.com/MoodyJerup/companion-falconplay.git"

// package.json
"repository": { "url": "git+https://github.com/MoodyJerup/companion-falconplay.git" }
```

**Recommendation:**
- `manifest.json`: `"repository": "git+https://github.com/bitfocus/companion-module-wearefalcon-falconplay.git"`
- `package.json`: `"url": "git+https://github.com/bitfocus/companion-module-wearefalcon-falconplay.git"`

---

### C-3: `manifest.json` `bugs` URL points to personal GitHub repo

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance / Identity
- **File:** `companion/manifest.json`

The `bugs` field links users to the author's personal repo issue tracker. Bug reports filed there will not reach the Bitfocus maintainer workflow.

**Found:** `"bugs": "https://github.com/MoodyJerup/companion-falconplay/issues"`
**Expected:** `"bugs": "https://github.com/bitfocus/companion-module-wearefalcon-falconplay/issues"`

---

### C-4: `manifest.json` missing `$schema` field

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `companion/manifest.json`

The `$schema` field is absent. It is required for IDE validation and checked by the Bitfocus automated module-checks workflow.

**Template expects** (as first field):
```json
"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"
```

---

### C-5: `manifest.json` `runtime.apiVersion` is `"0.0.0"`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `companion/manifest.json`

`"apiVersion": "0.0.0"` is a placeholder that was never updated. Companion uses this field to verify API compatibility. The correct value should match the declared `@companion-module/base` dependency.

**Found:** `"apiVersion": "0.0.0"`
**Expected:** `"apiVersion": "1.12.1"` (matching `@companion-module/base ~1.12.1`)

---

## 🟠 High

### H-1: `onAirInput` feedback dropdown permanently empty — `updateFeedbacks()` never re-called

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **Files:** `src/feedbacks.js:54`, `src/main.js`

The `onAirInput` feedback builds its `choices` array from `self.inputs` at definition time:

```js
choices: self.inputs.map((inp) => ({ id: inp.input, label: inp.name })),
```

`updateFeedbacks()` is called exactly once — in `init()` when `self.inputs = []` (empty array, freshly constructed). The `refreshLists()` method later populates `self.inputs` but only calls `this.updateActions()` — `this.updateFeedbacks()` is never called again. `configUpdated()` also only calls `updateActions()`. The `onAirInput` dropdown is frozen at empty for the entire lifetime of the module instance.

**Evidence (confirmed):**
```js
// main.js — init()
this.updateFeedbacks()    // ← only call; self.inputs = [] at this point

// main.js — refreshLists() — after populating self.inputs:
if (listsChanged) {
    this.updateActions()  // ← called; updateFeedbacks() NOT called
}

// main.js — configUpdated():
this.updateActions()      // ← called; updateFeedbacks() NOT called
```

**Impact:** The `onAirInput` feedback is completely unusable. Users adding it to a button see an empty dropdown and cannot select any input.

**Recommendation:** Add `this.updateFeedbacks()` wherever `this.updateActions()` is called after list data changes — in `refreshLists()` and `configUpdated()`:
```js
if (listsChanged) {
    this.updateActions()
    this.updateFeedbacks()   // ← add this
}
```

---

### H-2: `httpGet()` / `httpPost()` skip `response.ok` — SyntaxError on server error pages

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `src/main.js:70–85`

Both HTTP helpers call `res.json()` unconditionally without checking `response.ok`. When the server returns a `4xx`/`5xx` with a non-JSON body (nginx error page, proxy gateway page, plain text), `res.json()` throws `SyntaxError: Unexpected token '<'`. The HTTP status code is entirely invisible to callers.

**Evidence:**
```js
async httpGet(path) {
    const res = await fetch(`${this.getBaseUrl()}${path}`, { signal: AbortSignal.timeout(5000) })
    return res.json()   // ← throws SyntaxError on HTML error pages
}
```

**Failure path breakdown:**

| Caller | Impact |
|--------|--------|
| `pollStatus()` `catch {}` | Sets `ConnectionFailure` with "Cannot reach Falcon Play" — wrong: server IS reachable but returned an error |
| Action callbacks `catch (err)` | Logs `"Switch Input error: Unexpected token '<'..."` — deeply confusing to operators |
| `refreshLists()` via `Promise.allSettled` | `rejected` result silently skipped — stale list data, no warning |

**Recommendation:** Add `response.ok` check in both helpers:
```js
async httpGet(path) {
    const res = await fetch(`${this.getBaseUrl()}${path}`, { signal: AbortSignal.timeout(5000) })
    if (!res.ok) throw new Error(`HTTP ${res.status} ${res.statusText}`)
    return res.json()
}
```
Apply the same pattern to `httpPost()`.

---

## 🟡 Medium

### M-1: `init()` sets no status before polling — up to 5-second unknown state window

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.js:21–29`

`init()` calls `startPolling()` without first calling `updateStatus()`. The first `pollStatus()` fires immediately but is async and takes up to the 5-second `AbortSignal` timeout on an unresponsive server. During this window the module shows `InstanceStatus.Unknown` (grey, unlabelled) in Companion.

**Recommendation:** Add `this.updateStatus(InstanceStatus.Connecting)` at the top of `init()`.

---

### M-2: `configUpdated()` doesn't call `updateFeedbacks()` or clear stale server state

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.js:36–41`

When the user changes the host IP/port, `configUpdated()` does not:
1. Clear `this.serverStatus` — until the new host's first poll completes, `connectionStatus` feedback returns `true` and device variables still show the old server's state
2. Clear `this.inputs`/`this.functions`/`this.scenes`/`this.videos` — action dropdowns show stale choices from the old server for up to 10 seconds
3. Call `this.updateFeedbacks()` — the `onAirInput` feedback never gets refreshed (compounds H-1)
4. Set `InstanceStatus.Connecting` — no visual indication that reconnection is in progress

**Recommendation:** At the start of `configUpdated()`, clear stale state and set Connecting status:
```js
async configUpdated(config) {
    this.config = config
    this.serverStatus = null
    this.inputs = []; this.functions = []; this.scenes = []; this.videos = []
    this.updateStatus(InstanceStatus.Connecting)
    this.stopPolling()
    this.updateActions()
    this.updateFeedbacks()
    this.startPolling()
}
```

---

### M-3: `pollStatus()` doesn't call `checkFeedbacks()` on `data.ok === false` branch

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.js` — `pollStatus()`

When the server responds with `{ ok: false }`, the `else` branch calls `updateStatus()` but not `checkFeedbacks()`. The `connectionStatus` and `deviceStatus` feedbacks remain stale at their last good state rather than reflecting the error condition.

**Evidence:**
```js
} else {
    this.updateStatus(InstanceStatus.UnknownError, data.error || 'Unknown error')
    // ← checkFeedbacks() not called
}
```

**Recommendation:** Add `this.checkFeedbacks('connectionStatus', 'deviceStatus', 'onAirInput')` in the `else` branch.

---

### M-4: `refreshLists()` re-registers all 13 actions on every 10-second cycle — no change detection

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.js:117–143`

`listsChanged` is set to `true` whenever any of the four API calls succeeds — with no comparison to previously stored values. On a healthy server, all four requests succeed every 10 seconds, meaning `updateActions()` (re-registering all 13 actions and their dropdowns) fires on every single refresh cycle regardless of whether anything changed. Re-registering action definitions can interrupt open action-configuration dialogs in the Companion UI.

**Evidence:**
```js
if (results[0].status === 'fulfilled' && results[0].value.ok) {
    this.inputs = results[0].value.inputs || []
    listsChanged = true   // ← set on EVERY successful response, no diff check
}
```

**Recommendation:** Compare new data to existing before marking as changed — e.g., `JSON.stringify(newInputs) !== JSON.stringify(this.inputs)`. Apply the same pattern to all four lists.

---

### M-5: Polling concurrency — `setInterval` + 5-second timeout allows up to 3 concurrent polls

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.js`

`setInterval` fires every 2 seconds regardless of whether the previous `pollStatus()` call has resolved. With `AbortSignal.timeout(5000)`, up to 3 concurrent `pollStatus()` calls can be in-flight simultaneously on a slow-responding server. Out-of-order completions can overwrite newer `serverStatus` snapshots with older ones, causing feedback thrash and stale variable updates.

The same risk applies to `refreshLists()` (10-second interval, lower but nonzero risk of concurrent calls).

**Recommendation:** Add an in-flight guard flag, or switch to a recursive `setTimeout` approach that reschedules only after the previous call completes:
```js
async pollStatus() {
    if (this._pollingStatus) return
    this._pollingStatus = true
    try { /* existing logic */ } finally { this._pollingStatus = false }
}
```

---

### M-6: `refreshLists()` failures are fully silent — stale list data with no warning

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.js`

When a list endpoint returns an error, `Promise.allSettled` correctly absorbs the rejection — but the failure is completely silent. No log message is emitted, no status indicator changes, and `this.inputs`/`this.functions` etc. are left at their last known values indefinitely. The operator has no indication that action dropdowns may be showing stale or invalid choices.

**Recommendation:** Add `warn`-level log entries for rejected results:
```js
if (results[0].status === 'rejected') {
    this.log('warn', `Failed to refresh inputs: ${results[0].reason?.message}`)
}
```

---

### M-7: `?? 0` / `?? ''` default type mismatch — saved action IDs orphaned on late list load

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **Files:** `src/actions.js`, `src/feedbacks.js`

When action/feedback definitions are built while lists are empty, defaults fall back to inconsistent types:
- `switchInput` → `default: inputChoices[0]?.id ?? 0` (number `0`)
- `onAirInput` feedback → `default: self.inputs[0]?.input ?? 0` (number `0`)
- `runFunction`, `playScene`, `playVideo`, others → `default: ... ?? ''` (empty string)

If a user configures a `switchInput` action or `onAirInput` feedback before the server is reachable, the stored option value becomes `0` (a number). When lists later populate with string IDs (e.g., `"CAM1"`), `0` will never match any real ID. The stored button remains permanently orphaned — the action fires with `input: 0` (likely rejected by the server), and the feedback never triggers.

The type inconsistency also means `activeItem.input === feedback.options.input` in the `onAirInput` callback uses strict `===` comparison between a potential number and a string, which always fails silently.

**Recommendation:** Use `''` (empty string) as the universal fallback for all dropdown defaults. Coerce both sides to `String` in the `onAirInput` callback comparison.

---

### M-8: Keywords include partial manufacturer name and third-party system reference

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `companion/manifest.json`

Current keywords: `["falcon", "play", "casparcg", "playout", "vision mixer", "graphics"]`

Two concerns:
1. **`"falcon"`** — `"Falcon Play"` is the manufacturer. While not the full manufacturer name, `"falcon"` is the distinctive component of that name. It functions as a partial manufacturer name keyword, which should be avoided per Companion guidelines.
2. **`"casparcg"`** — CasparCG is a separate open-source playout system that Falcon Play Server controls internally. This module controls Falcon Play Server; it does not directly control CasparCG. Including `"casparcg"` as a keyword implies a direct CasparCG integration that doesn't exist at the Companion API level, and will mislead users searching for a CasparCG module.

`"play"`, `"playout"`, `"vision mixer"`, `"graphics"` are all generic descriptors that are acceptable.

**Recommendation:** Remove `"falcon"` and `"casparcg"` from keywords.

---

## 🟢 Low

### L-1: `destroy()` doesn't cancel in-flight requests

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/main.js:22–25`

`stopPolling()` cancels interval timers but any `pollStatus()` or `refreshLists()` calls already in-flight continue running. When they resolve (up to 5 seconds later), they call `this.updateStatus()`, `this.setVariableValues()`, `this.checkFeedbacks()`, and `this.updateActions()` on a destroyed instance.

**Recommendation:** Store a module-level `AbortController`, pass its signal to all `fetch()` calls, and call `controller.abort()` in `stopPolling()`. Create a fresh controller in `startPolling()`.

---

### L-2: Variables undefined until first successful poll

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/main.js`

`updateVariableDefinitions()` is called in `init()` but `setVariableValues()` is not. For the first poll cycle, all 9 variables display as `undefined` in Companion buttons and expressions.

**Recommendation:** After `updateVariableDefinitions()`, call `setVariableValues()` with empty placeholder values (empty strings for text vars, `'No'` for device connection vars).

---

### L-3: `companion/HELP.md` missing 4 of 13 actions

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `companion/HELP.md`

`HELP.md` documents 8 actions but the module implements 13. The four graphic stop/clear actions are documented in `README.md` but absent from `HELP.md` (which is what Companion shows in the module help panel):

Missing: `stopGraphic`, `clearGraphic`, `stopGraphicAll`, `clearGraphicAll`

**Recommendation:** Add the four missing actions to the HELP.md actions table.

---

### L-4: `pollStatus()` `catch {}` discards all error context

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/main.js`

`catch {}` (optional catch binding, valid ES2019+) silently discards the actual error. All failure modes — `ECONNREFUSED`, `AbortError` (timeout), `SyntaxError` (bad JSON body), DNS failure — produce the same "Cannot reach Falcon Play" message with zero diagnostic information logged. This makes field-debugging impossible.

**Recommendation:** Capture the error and log at `debug` level: `catch (err) { this.log('debug', \`pollStatus error: ${err?.message || err}\`) ... }`

---

### L-5: Action callbacks log `"Action failed: undefined"` on unexpected JSON shape

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/actions.js` (all 13 callbacks)

All action callbacks check `if (!result.ok)` and log `result.error`. If the server returns JSON that lacks an `ok` or `error` field, both are `undefined` — the log emits `"Action failed: undefined"`. This provides no useful diagnostic.

**Recommendation:** Use a fallback: `self.log('error', \`Action failed: ${result.error || result.message || JSON.stringify(result)}\`)`

---

### L-6: `.gitignore` and `.prettierignore` minor deviations from template

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **Files:** `.gitignore`, `.prettierignore`

Two minor deviations from the JS template:
- `.gitignore` has an extra `.DS_Store` line (macOS artifact not in template — harmless but inconsistent)
- `.prettierignore` has `/LICENSE` (module's actual filename) where the template specifies `/LICENSE.md`

Both are harmless in practice. The `.prettierignore` deviation is arguably more correct for this module (the license file has no extension). Flag for awareness.

---

## 💡 Nice to Have

### N-1: `manifest.json` `name` field should be human-readable

- **Severity:** 💡 Nice to Have
- **Classification:** 🆕 NEW
- **File:** `companion/manifest.json`

`"name": "falcon-play"` is the kebab-case id slug. Once C-1 is fixed (`id` updated), the `name` field should be set to a human-readable label that appears in the Companion module browser.

**Recommendation:** Set `"name": "Falcon Play"` (or `"Falcon Play Server"`).

---

### N-2: No presets defined

- **Severity:** 💡 Nice to Have
- **Classification:** 🆕 NEW

No presets are defined. For a first release this is acceptable, but presets for common operations (Take Next, Switch Input to CAM1) would significantly improve out-of-box usability.

---

## 🔮 Next Release

- Add presets for common broadcast workflows (Take Next, Switch PGM input, connection status button)
- Consider polling backoff when server is persistently down (fixed 30 req/min at 2s is noisy on a dead endpoint)
- Update `@companion-module/base` to `~1.14.1`, `@companion-module/tools` to `^2.6.1`

---

## 🧪 Tests

No test files found (`*.test.js`, `*.spec.js`, `__tests__/`). No test framework configured. No `test` script in `package.json`.

**Status: ✅ Non-blocking.** Expected for a first-release module. The polling and HTTP helpers would be good candidates for unit testing in a future release.

---

## ✅ What's Solid

- **Multi-file structure is clean and well-organized.** Splitting actions, feedbacks, variables, and upgrades into separate files is the correct pattern for a module of this scope
- **`Promise.allSettled` in `refreshLists()`** — each of the four list endpoints can fail independently without blocking the others; correct resilient design
- **`AbortSignal.timeout(5000)` on every HTTP call** — no indefinitely-hanging requests
- **`stopPolling()` correctly guards against double-clear** — `if (this.pollStatusTimer)` checks prevent errors on repeated calls
- **`destroy()` calls `stopPolling()`** — timer cleanup is handled correctly
- **All 13 action callbacks have `try/catch`** — no unhandled rejections from action execution
- **`pollStatus()` correctly sets `InstanceStatus.ConnectionFailure` and clears `serverStatus` on catch** — connection failure state is correct
- **`switchInput` transition options** are well thought out — cut/mix/dip/wipe/sting with configurable duration covers standard broadcast transitions
- **`graphicChannelChoices` A–Z generated programmatically** — avoids 26 copy-pasted entries; good code hygiene
- **9 variables** cover the most useful runtime state (version, rundown, on-air, cued, all device connections, file server)
- **`runEntrypoint` with `UpgradeScripts = []`** correctly wired for first release
- **`companion/HELP.md`** is real, substantive content (not a stub) — covers configuration, actions, feedbacks, and variables
