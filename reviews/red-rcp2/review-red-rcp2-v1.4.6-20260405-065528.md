# Module Review: companion-module-red-rcp2 v1.4.6

**Module:** companion-module-red-rcp2
**Version:** v1.4.6
**Previous approved tag:** v1.1.3
**API:** v1.11 (`@companion-module/base: ~1.11.0`, Companion 3.5+)
**Type:** JavaScript ESM
**Date:** 2026-04-05
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Template/Build), Zoe (QA), Simon (Tests)

---

## Fix Summary for Maintainer

The following **14 blocking issues** must be resolved before approval:

1. **C1** — Add upgrade scripts to `upgrade.js` that remap `start_record` → `start_recording`, `stop_record` → `stop_recording`, `toggle_record` → `toggle_recording`, and remove/migrate `websocket_variable` feedbacks. (`upgrade.js`, line 1)
2. **C2** — Restore `scripts` section in `package.json` with at minimum `"package": "companion-module-build"` and `"format": "prettier -w ."`. (`package.json`)
3. **H1** — Change `CAMERA_LUT_ENABLE_SDI_1` → `ENABLE_CAMERA_LUT_SDI_1` and `CAMERA_LUT_ENABLE_SDI_2` → `ENABLE_CAMERA_LUT_SDI_2` in the SUBSCRIBE set. (`main.js`, lines 471–472)
4. **H2** — Move source into `src/` and split `main.js` into `src/actions.js`, `src/feedbacks.js`, `src/upgrades.js`, `src/variables.js`. Update `package.json` `main` to `"src/main.js"` and `manifest.json` `runtime.entrypoint` to `"../src/main.js"`.
5. **M1** — Remove `process.title = 'RED RCP2'` — it renames Companion's entire Node.js process globally. (`main.js`, line 6)
6. **M2** — Restore `this.updateStatus(InstanceStatus.ConnectionFailure, err.toString())` in `ws.on('error')`. (`main.js`, line 341)
7. **M3** — Track staggered `setTimeout` handles on the instance and cancel them in `_clearTimers()`. (`main.js`, lines 437, 529)
8. **M4** — Restore `repository` field in `package.json`.
9. **M5** — Restore `prettier` config field in `package.json`.
10. **M6** — Add missing config files: `.gitattributes` (`* text=auto eol=lf`), `.prettierignore` (`package.json` / `/LICENSE.md`), `.yarnrc.yml` (`nodeLinker: node-modules`).
11. **M7** — Update `LICENSE` copyright line to `Copyright (c) 2022 Bitfocus AS - Open Source`.
12. **M8** — Add missing `.gitignore` entries: `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`.
13. **M9** — Add `"packageManager": "yarn@4.12.0"` and `"engines": { "node": "^22.20", "yarn": "^4" }` to `package.json`.
14. **M10** — Remove `"RED"`, `"RCP"`, and `"RCP2"` from `manifest.json` `keywords` — these duplicate the `manufacturer` and `name` fields.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2 | 0 | 2 |
| 🟠 High | 1 | 1 | 2 |
| 🟡 Medium | 6 | 4 | 10 |
| 🟢 Low | 2 | 0 | 2 |
| 💡 Nice to Have | 0 | 2 | 2 |
| **Total** | **11** | **7** | **18** |

**Blocking:** 14 issues
**Fix complexity:** Medium-High — code restructuring (src/ split) is the largest change; config/manifest fixes are mechanical one-liners
**Health delta:** 11 introduced · 7 pre-existing noted

---

## Verdict

### ❌ Changes Required

Two critical issues (empty upgrade scripts with breaking ID renames, missing `scripts` in `package.json`), one high regression (LUT subscription name mismatch), one structural non-compliance (source not in `src/`, `main.js` not split into module files), three medium issues, and seven Low-severity findings block approval. The upgrade scripts issue is the hard stop — users upgrading from v1.1.3 will have silently dead recording control buttons. The structural refactor (H2) is the most effort-intensive fix.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Empty upgrade scripts with renamed action/feedback IDs](#c1-empty-upgrade-scripts-with-renamed-actionfeedback-ids)
- [ ] [C2: `scripts` section removed from `package.json`](#c2-scripts-section-removed-from-packagejson)
- [ ] [H1: LUT subscription name mismatch causes stale toggle state](#h1-lut-subscription-name-mismatch-causes-stale-toggle-state)
- [ ] [H2: Source code not in `src/` and `main.js` not split into module files](#h2-source-code-not-in-src-and-mainjs-not-split-into-module-files)
- [ ] [M1: `process.title` global mutation at import time](#m1-processtitle-global-mutation-at-import-time)
- [ ] [M2: `ws.on('error')` no longer updates InstanceStatus](#m2-wsonerror-no-longer-updates-instancestatus)
- [ ] [M3: Untracked `setTimeout` chains not canceled by `_clearTimers()`](#m3-untracked-settimeout-chains-not-canceled-by-_cleartimers)
- [ ] [M4: `repository` field removed from `package.json`](#m4-repository-field-removed-from-packagejson)
- [ ] [M5: `prettier` config field removed from `package.json`](#m5-prettier-config-field-removed-from-packagejson)
- [ ] [M6: Missing required config files (`.gitattributes`, `.prettierignore`, `.yarnrc.yml`)](#m6-missing-required-config-files-gitattributes-prettierignore-yarnrcyml)
- [ ] [M7: LICENSE copyright attribution incorrect](#m7-license-copyright-attribution-incorrect)
- [ ] [M8: `.gitignore` missing template entries](#m8-gitignore-missing-template-entries)
- [ ] [M9: `package.json` missing `packageManager` and `engines` fields](#m9-packagejson-missing-packagemanager-and-engines-fields)
- [ ] [M10: `manifest.json` keywords duplicate module name and manufacturer](#m10-manifestjson-keywords-duplicate-module-name-and-manufacturer)

**Non-blocking**
- [ ] [L1: `set_iso` action missing NaN guard](#l1-set_iso-action-missing-nan-guard)
- [ ] [L2: `set_sensor_fps` action missing NaN guard](#l2-set_sensor_fps-action-missing-nan-guard)
- [ ] [N1: `manifest.json` version should be `"0.0.0"`](#n1-manifestjson-version-should-be-000)
- [ ] [N2: `manifest.json` missing `$schema` field](#n2-manifestjson-missing-schema-field)

---

## 🔴 Critical

### C1: Empty upgrade scripts with renamed action/feedback IDs

**Classification:** 🆕 NEW
**File:** `upgrade.js`, line 1
**File:** `main.js`, lines 1255–1268 (new action IDs), lines 1222–1244 (new feedback IDs)
**Found by:** Kaylee, Zoe, Mal

Three action IDs were renamed between v1.1.3 and v1.4.6:

| Old ID (v1.1.3) | New ID (v1.4.6) |
|---|---|
| `start_record` | `start_recording` |
| `stop_record` | `stop_recording` |
| `toggle_record` | `toggle_recording` |

The feedback `websocket_variable` was removed entirely. Two new feedbacks (`recording_state`, `tally_state_active`) were added but do not map 1:1 to the removed feedback.

`upgrade.js` exports `upgradeScripts = []`.

Any Companion page saved against v1.1.3 (or any version up to v1.3.x) that uses `start_record`, `stop_record`, `toggle_record`, or `websocket_variable` will have silently dead buttons after upgrading. The buttons appear in the UI with no error — they just do nothing.

**Fix:** Add an upgrade script that:
1. Renames `start_record` → `start_recording` in `props.actions`
2. Renames `stop_record` → `stop_recording` in `props.actions`
3. Renames `toggle_record` → `toggle_recording` in `props.actions`
4. Removes `websocket_variable` entries from `props.feedbacks`

```js
export const upgradeScripts = [
    function v140_renameRecordingActions(_context, props) {
        const actionMap = {
            start_record: 'start_recording',
            stop_record: 'stop_recording',
            toggle_record: 'toggle_recording',
        }
        for (const action of props.actions) {
            if (actionMap[action.actionId]) {
                action.actionId = actionMap[action.actionId]
            }
        }
        props.feedbacks = props.feedbacks.filter((fb) => fb.feedbackId !== 'websocket_variable')
        return { updatedConfig: null, updatedActions: props.actions, updatedFeedbacks: props.feedbacks }
    },
]
```

---

### C2: `scripts` section removed from `package.json`

**Classification:** 🔙 REGRESSION
**File:** `package.json`
**Found by:** Kaylee

v1.1.3 had a `scripts` section with `format` and `test`. In v1.4.6 the entire `scripts` section was deleted. `yarn package` fails immediately — the module cannot be packaged for Companion distribution.

```
v1.1.3 had:
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "format": "prettier -w ."
  }

v1.4.6: scripts section absent entirely
```

**Fix:** Restore the `scripts` section:
```json
"scripts": {
    "package": "companion-module-build",
    "format": "prettier -w ."
}
```

---

## 🟠 High

### H1: LUT subscription name mismatch causes stale toggle state

**Classification:** 🔙 REGRESSION
**File:** `main.js`, lines 471–472 (SUBSCRIBE set in `_onCameraParameters`)
**File:** `main.js`, lines 893, 902 (`handleUpdate` switch cases)
**File:** `main.js`, lines 1412–1413 (`toggle_lut_sdi1/2` rcp_set)
**Found by:** Zoe

The `_onCameraParameters` SUBSCRIBE set uses `CAMERA_LUT_ENABLE_SDI_1` and `CAMERA_LUT_ENABLE_SDI_2`, but `handleUpdate` cases on `ENABLE_CAMERA_LUT_SDI_1` and `ENABLE_CAMERA_LUT_SDI_2`, and the toggle actions send `rcp_set` to `ENABLE_CAMERA_LUT_SDI_1/2`.

v1.1.3 was consistent: it subscribed to `ENABLE_CAMERA_LUT_SDI_1/2` and handled the same IDs.

The subscription request for the wrong name goes to the camera for a parameter that may not exist under that name. LUT enable state falls back to 30-second polling only, so `this.lutSdi1Enabled` / `this.lutSdi2Enabled` can be stale. The `toggle_lut_sdi1/2` actions read this stale boolean and may flip the wrong direction.

**Fix:** Change lines 471–472 in the SUBSCRIBE set from `CAMERA_LUT_ENABLE_SDI_1` / `CAMERA_LUT_ENABLE_SDI_2` to `ENABLE_CAMERA_LUT_SDI_1` / `ENABLE_CAMERA_LUT_SDI_2`.

---

### H2: Source code not in `src/` and `main.js` not split into module files

**Classification:** ⚠️ PRE-EXISTING
**Files:** `main.js`, `upgrade.js`, `companion/manifest.json`, `package.json`
**Found by:** Kaylee

The template-js places all source files in `src/` and splits concerns across separate files:
- `src/main.js` — module class and lifecycle
- `src/actions.js` — action definitions
- `src/feedbacks.js` — feedback definitions
- `src/upgrades.js` — upgrade scripts
- `src/variables.js` — variable definitions

`companion-module-red-rcp2` places `main.js` and `upgrade.js` directly at the repo root with all actions, feedbacks, variables, and upgrade logic inlined into `main.js`. `package.json` `"main"` points to `"main.js"` and `manifest.json` `runtime.entrypoint` is `"../main.js"`.

**Fix:**
1. Create `src/` and move `main.js` and `upgrade.js` into it (rename `upgrade.js` → `src/upgrades.js` to match template convention)
2. Extract action definitions to `src/actions.js`
3. Extract feedback definitions to `src/feedbacks.js`
4. Extract variable definitions to `src/variables.js`
5. Update `package.json` `"main"` from `"main.js"` to `"src/main.js"`
6. Update `companion/manifest.json` `runtime.entrypoint` from `"../main.js"` to `"../src/main.js"`

---

## 🟡 Medium

### M1: `process.title` global mutation at import time

**Classification:** 🆕 NEW
**File:** `main.js`, line 6
**Found by:** Wash

```js
process.title = 'RED RCP2'
```

This sets the OS process title for the entire Companion Node.js host process at module import time. Companion loads many modules in a single process — this renames the process for all of them simultaneously, breaking process monitoring tools (`ps`, `htop`, systemd unit names). It's a global side effect that fires before `init()` and cannot be undone.

**Fix:** Remove the line. Module identity comes from `manifest.json`.

---

### M2: `ws.on('error')` no longer updates InstanceStatus

**Classification:** 🔙 REGRESSION
**File:** `main.js`, line 341
**Found by:** Wash, Zoe

v1.1.3's error handler called `this.updateStatus(InstanceStatus.ConnectionFailure, err.message)`. v1.4.6 only logs:

```js
this.ws.on('error', (err) => { this.log('error', 'WebSocket error: ' + err.toString()) })
```

Between the `error` event and the immediately-following `close` event, the Companion UI shows the instance as "Connected" when the socket is in an error state. Recovery is correct (close always follows error in `ws`), but the status precision loss can confuse operators on a live show.

**Fix:**
```js
this.ws.on('error', (err) => {
    this.log('error', 'WebSocket error: ' + err.toString())
    this.updateStatus(InstanceStatus.ConnectionFailure, err.toString())
})
```

---

### M3: Untracked `setTimeout` chains not canceled by `_clearTimers()`

**Classification:** 🆕 NEW
**File:** `main.js`, lines 424–440 (`_sendHeartbeat` staggered batch)
**File:** `main.js`, lines 519–532 (`_onCameraParameters` staggered batch)
**Found by:** Wash, Zoe

Both `_sendHeartbeat()` and `_onCameraParameters()` use chained `setTimeout` calls that are not stored on the instance and therefore not canceled by `_clearTimers()`. The `_onCameraParameters` chain runs for up to ~90 seconds.

If the user changes config during the first 90 seconds (e.g., correcting a typo in the IP), the old chain keeps running alongside the new one, doubling parameter traffic on the new socket. The `send()` guard prevents messages to closed sockets, but accumulation over rapid config changes is real and the instance can't be GC'd until chains self-terminate.

**Fix:** Track setTimeout handles in a `Set` on the instance and cancel them in `_clearTimers()`:
```js
// In _clearTimers():
if (this._staggerTimers) { for (const t of this._staggerTimers) clearTimeout(t); this._staggerTimers.clear() }
```

---

### M4: `repository` field removed from `package.json`

**Classification:** 🔙 REGRESSION
**File:** `package.json`
**Found by:** Kaylee

v1.1.3 had `"repository": { "type": "git", "url": "git+https://github.com/bitfocus/companion-module-red-rcp2.git" }`. Removed in v1.4.6. Template requires this field.

**Fix:** Restore the `repository` field.

---

### M5: `prettier` config field removed from `package.json`

**Classification:** 🔙 REGRESSION
**File:** `package.json`
**Found by:** Kaylee

v1.1.3 had `"prettier": "@companion-module/tools/.prettierrc.json"`. Removed in v1.4.6. Template requires this field for consistent code formatting.

**Fix:** Restore the `prettier` field.

---

### M6: Missing required config files (`.gitattributes`, `.prettierignore`, `.yarnrc.yml`)

**Classification:** ⚠️ PRE-EXISTING
**Files:** (absent)
**Found by:** Kaylee

Three files present in the template are absent from the repo:

`.gitattributes`:
```
* text=auto eol=lf
```
Ensures consistent line endings across platforms.

`.prettierignore`:
```
package.json
/LICENSE.md
```
Tells Prettier which files to skip when running `format`.

`.yarnrc.yml`:
```
nodeLinker: node-modules
```
Required for Yarn 4 to use the `node-modules` linker (vs PnP, which is incompatible with `companion-module-build`).

**Fix:** Add all three files to the repo root with the exact contents shown above.

---

### M7: LICENSE copyright attribution incorrect

**Classification:** 🆕 NEW
**File:** `LICENSE`
**Found by:** Kaylee

The module's `LICENSE` file attributes copyright to `"Seth Haberman AS - Open Source"`. The template copyright and the standard for Companion modules hosted under the `bitfocus` GitHub organization reads `"Bitfocus AS - Open Source"`. Maintainer attribution belongs in `manifest.json` `maintainers`, not the copyright line.

Current:
```
Copyright (c) 2025-2026 Seth Haberman AS - Open Source
```

Expected:
```
Copyright (c) 2022 Bitfocus AS - Open Source
```

**Fix:** Update the copyright line in `LICENSE` to match the template.

---

### M8: `.gitignore` missing template entries

**Classification:** ⚠️ PRE-EXISTING
**File:** `.gitignore`
**Found by:** Kaylee

The current `.gitignore` is missing four entries present in the template:
```
/pkg
/*.tgz
DEBUG-*
/.yarn
```

`/pkg` and `/*.tgz` are the build outputs produced by `companion-module-build` when running `yarn package`. Without them, a developer who packages the module locally will accidentally commit the output. `/.yarn` prevents Yarn 4's cache and install state directory from being committed. `DEBUG-*` is the conventional debug output pattern.

**Fix:** Add the four missing lines to `.gitignore`.

---

### M9: `package.json` missing `packageManager` and `engines` fields

**Classification:** ⚠️ PRE-EXISTING
**File:** `package.json`
**Found by:** Kaylee

Template requires:
```json
"engines": {
    "node": "^22.20",
    "yarn": "^4"
},
"packageManager": "yarn@4.12.0"
```

Both are absent from v1.4.6. `packageManager` pins the exact Yarn version for Corepack compatibility — without it, `corepack` may use a different Yarn version and produce inconsistent installs. `engines` communicates minimum Node and Yarn requirements to the build system and CI.

**Fix:** Add both fields to `package.json`.

---

### M10: `manifest.json` keywords duplicate module name and manufacturer

**Classification:** ⚠️ PRE-EXISTING
**File:** `companion/manifest.json`
**Found by:** Kaylee

Keywords should describe what the module *does* or *how it connects* — not repeat information already present in the `name`, `shortname`, or `manufacturer` fields. Companion uses those fields for search and display; duplicating them in `keywords` adds noise without benefit.

The manifest already has `"manufacturer": "RED"` and `"name": "RED RCP2 Camera Control"`. The keywords `"RED"` and `"RCP2"` repeat the manufacturer and product name directly. `"RCP"` is an abbreviation of the product name and has the same problem.

```json
"keywords": ["websocket", "RED", "Raptor", "R3D", "RCP", "RCP2"]
```

**Fix:** Remove `"RED"`, `"RCP"`, and `"RCP2"` from the `keywords` array. The retained keywords should be: `["websocket", "Raptor", "R3D"]`.

---

## 🟢 Low

### L1: `set_iso` action missing NaN guard

**Classification:** 🆕 NEW
**File:** `main.js`, lines 1338–1340
**Found by:** Zoe

```js
const iso = parseInt(await context.parseVariablesInString(action.options.iso), 10)
this.send({ type: 'rcp_set', id: 'ISO', value: iso })
```

No `isNaN(iso)` check before sending. The option is a dropdown so risk is low, but `parseVariablesInString` can resolve a variable to a non-numeric string, sending `value: NaN` to the camera. All other numeric actions in this file check for NaN.

**Fix:** Add `if (isNaN(iso)) return` before the `send()` call.

---

### L2: `set_sensor_fps` action missing NaN guard

**Classification:** 🆕 NEW
**File:** `main.js`, line 1357
**Found by:** Zoe

Same issue as L1. The `parseInt` result is inlined into `send()` without NaN validation.

**Fix:** Extract to a variable, add `if (isNaN(fps)) return`.

---

## 💡 Nice to Have

### N1: `manifest.json` version should be `"0.0.0"`

**Classification:** ⚠️ PRE-EXISTING
**File:** `companion/manifest.json`
**Found by:** Kaylee

Currently `"version": "1.4.6"`. The manifest version is managed by Companion's build tooling at package time. Setting it to a real version is redundant and will drift. Use `"0.0.0"`.

---

### N2: `manifest.json` missing `$schema` field

**Classification:** ⚠️ PRE-EXISTING
**File:** `companion/manifest.json`
**Found by:** Kaylee

Adding `"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"` enables IDE validation of the manifest.

---

## ⚠️ Pre-existing Notes

These issues existed in v1.1.3 and remain unchanged. Per review policy, pre-existing medium and lower issues are **non-blocking**. They are listed for the maintainer's awareness.

| # | Issue | Files |
|---|---|---|
| PE1 | Unused `zx` dependency (~2MB) — not imported anywhere | `package.json` |
| PE2 | `send_command` action sends raw user JSON without `JSON.parse` validation | `main.js`, lines 1519–1520 |

---

## 🧪 Tests

✅ No tests present — not required. (Simon)

---

## ✅ What's Solid

This is a substantial and well-engineered rewrite. Credit where it's due:

- **WebSocket lifecycle fixed** — `destroy()` now correctly closes the WebSocket (leaked in v1.1.3). `connect()` removes listeners before closing the old socket, eliminating the double-reconnect race from v1.1.3.
- **Proxy-based variable batching** — The `setImmediate`-based dirty-flush pattern is clean. `clearImmediate` in `resetAllVariables()` prevents async flushes from overwriting bulk resets.
- **Dynamic parameter discovery** — `_onCameraParameters()` handles camera model differences automatically. No hardcoded per-camera lists.
- **CPU optimizations** — Staggered parameter polling and subscription management keep CPU flat during connect.
- **`send()` guard** — Every outbound message checks `this.ws && this.ws.readyState === WebSocket.OPEN`. Consistent and correct.
- **`scheduleReconnect()` guard** — `if (this.reconnect_timer) return` prevents double-scheduling.
- **`rcp_session` keep-alive** — Correct echo-back implementation for the camera's session heartbeat.
- **Message parsing** — `JSON.parse` wrapped in try/catch with error logging. Defensive against malformed camera data.
- **`shutdown_camera` action** — Requires explicit checkbox confirmation. Good defensive design for a destructive command.
- **HELP.md** — Comprehensive, well-organized documentation covering all actions, variables (grouped with tables), protocol notes, and camera-specific caveats. One of the better HELP.md files reviewed.
- **`@companion-module/base` upgrade** — `~1.2.1` → `~1.11.0` is appropriate.
- **Runtime upgrade** — `node18` → `node22` in manifest.
- **Boolean feedbacks** — Correctly typed with `defaultStyle` and proper return types.
- **`context.parseVariablesInString()`** — Used correctly (not the deprecated `self.parseVariablesInString()`).
- **No `package-lock.json`**, no committed `dist/`.
