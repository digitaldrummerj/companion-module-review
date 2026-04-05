# Module Review: companion-module-audiostrom-liveprofessor v2.1.1

| Field | Value |
|-------|-------|
| **Module** | `audiostrom-liveprofessor` |
| **Version** | v2.1.1 (tag) / 2.1.0 (package.json) / 2.0.1 (manifest.json) |
| **Previous approved** | v2.0.0 |
| **API** | v1.x (`@companion-module/base ~1.11.2`) |
| **Language** | JavaScript (CJS) |
| **Protocol** | OSC over UDP (`osc` library) |
| **Review date** | 2026-04-05 |
| **Reviewers** | Mal (Lead), Wash (Protocol), Kaylee (Template/Build), Zoe (QA/Logic), Simon (Tests) |

---

## Fix Summary for Maintainer

The following **10 blocking fixes** are required before approval:

1. **`package.json` line 3** — Change `"version": "2.1.0"` → `"2.1.1"` to match the git tag
2. **`companion/manifest.json` line 6** — Change `"version": "2.0.1"` → `"0.0.0"` (let the build system set it)
3. **`LiveProfessor.js` line 1** — Add `InstanceStatus` to the import: `const { InstanceBase, InstanceStatus, Regex, runEntrypoint } = require('@companion-module/base')`
4. **`LiveProfessor.js` line 176** — Replace `BadConfig` with `InstanceStatus.BadConfig`
5. **`LiveProfessor.js` line 186** — Replace `ConnectionFailure` with `InstanceStatus.ConnectionFailure`
6. **`LiveProfessor.js` line 178** — Replace `this.qSocket.removeAllListeners()` with `this.oscUdp.removeAllListeners()` (or remove the ECONNREFUSED branch)
7. **`LiveProfessor.js` line 41** — Implement `destroy()`: close `this.oscUdp` and clear `tempoTimer`
8. **`LiveProfessor.js` lines 44–50** — In `configUpdated()`, close `this.oscUdp` before calling `init_osc()`
9. **`actions.js` lines 81, 113, 145, 175** — Either revert rotary `max` to 4, or expand `rotaryValues`/`rotaryPush` arrays in `init()` to match max
10. **`LiveProfessor.js` lines 300–309** — Remove the three dead stub methods (`updateActions`, `updateFeedbacks`, `updateVariableDefinitions`)
11. **`LiveProfessor.js` lines 182, 187, 192, 200** — Replace `console.log()` calls with Companion instance logger (`this.log()`)

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 0 | 1 |
| 🟠 High | 3 | 4 | 7 |
| 🟡 Medium | 2 | 3 | 5 |
| 🟢 Low | 1 | 5 | 6 |
| 💡 Nice to Have | 0 | 6 | 6 |
| **Total** | **7** | **18** | **25** |

**Blocking:** 10 issues (1 new critical, 3 new high, 4 pre-existing high, 2 new medium)
**Fix complexity:** Medium — import fix, version bumps, ~30 lines of destroy/cleanup code, array expansion
**Health delta:** 6 introduced · 18 pre-existing surfaced

---

## Verdict

**❌ Changes Required**

Ten blocking issues prevent approval. Six are newly introduced in v2.1.1 (version mismatches, undefined `BadConfig`, dead stubs, rotary array bounds, console.log logging). Four are pre-existing high-severity issues that were never caught (undefined `ConnectionFailure`, undefined `qSocket`, empty `destroy()`, socket leak in `configUpdated()`). All must be fixed.

---

## 📋 Issues

**Blocking**
- [ ] [C1: `package.json` version does not match git tag](#c1-packagejson-version-does-not-match-git-tag)
- [ ] [H1: `BadConfig` undefined in OSC error handler](#h1-badconfig-undefined-in-osc-error-handler)
- [ ] [H2: `manifest.json` version mismatch](#h2-manifestjson-version-mismatch)
- [ ] [H3: `ConnectionFailure` undefined in close handler](#h3-connectionfailure-undefined-in-close-handler)
- [ ] [H4: `this.qSocket` undefined — error handler double-fault](#h4-thissocket-undefined-error-handler-double-fault)
- [ ] [H5: `destroy()` empty — socket and timer leak](#h5-destroy-empty-socket-and-timer-leak)
- [ ] [H6: `configUpdated()` leaks old OSC socket](#h6-configupdated-leaks-old-osc-socket)
- [ ] [H7: console.log used instead of Companion instance logger](#h7-consolelog-used-instead-of-companion-instance-logger)
- [ ] [M1: Rotary max expanded to 99 but backing arrays are length 4](#m1-rotary-max-expanded-to-99-but-backing-arrays-are-length-4)
- [ ] [M2: Dead stub methods call undefined globals](#m2-dead-stub-methods-call-undefined-globals)

**Non-blocking**
- [ ] [M3: No null safety in `processMessage()` args access](#m3-no-null-safety-in-processmessage-args-access)
- [ ] [M4: `tempoTimer` module-level variable — multi-instance conflict](#m4-tempotimer-module-level-variable-multi-instance-conflict)
- [ ] [M5: Premature `updateStatus('ok')` before socket ready](#m5-premature-updatestatusok-before-socket-ready)
- [ ] [L1: `checkFeedbacks('Rotary')` and `checkFeedbacks('ping')` — no matching feedback defined](#l1-checkfeedbacksrotary-and-checkfeedbacksping-no-matching-feedback-defined)
- [ ] [L2: Dead `connect()` method using removed API](#l2-dead-connect-method-using-removed-api)
- [ ] [L3: String concatenation precedence bug in GlobalSnapshots/Removed](#l3-string-concatenation-precedence-bug-in-globalsnapshotsremoved)
- [ ] [L4: Dead `data` event handler](#l4-dead-data-event-handler)
- [ ] [L5: `parseVariablesInString()` called on numeric option values](#l5-parsevariablesinstring-called-on-numeric-option-values)
- [ ] [L6: `@companion-module/tools` peer dependency conflict](#l6-companion-moduletools-peer-dependency-conflict)

---

## 🔴 Critical

### C1: `package.json` version does not match git tag

**Classification:** 🆕 NEW
**File:** `package.json`, line 3
**Issue:** `"version": "2.1.0"` but the git tag is `v2.1.1`. The packaged `.tgz` is named `audiostrom-liveprofessor-2.1.0.tgz`, which will not match what users expect for the v2.1.1 release. These must match exactly (tag without `v` prefix = package.json version).

**Fix:** Change `"version": "2.1.0"` → `"2.1.1"`.

---

## 🟠 High

### H1: `BadConfig` undefined in OSC error handler

**Classification:** 🆕 NEW
**File:** `LiveProfessor.js`, line 176
**Issue:** `this.updateStatus(BadConfig, "Can't connect to LiveProfessor")` — `BadConfig` is not imported or defined anywhere. This throws `ReferenceError: BadConfig is not defined` whenever the OSC socket encounters an error (port in use, network failure, etc.). The error handler crashes instead of updating module status, leaving the UI with stale "ok" status during connection failures.

In v2.0.0 this line used `ConnectionFailure` (also undefined), so the underlying class of bug is pre-existing, but `BadConfig` is a new undefined symbol introduced in this diff.

**Fix:** Import `InstanceStatus` from `@companion-module/base` and use `InstanceStatus.BadConfig`:
```js
const { InstanceBase, InstanceStatus, Regex, runEntrypoint } = require('@companion-module/base')
// line 176:
this.updateStatus(InstanceStatus.BadConfig, "Can't connect to LiveProfessor")
```

---

### H2: `manifest.json` version mismatch

**Classification:** 🆕 NEW
**File:** `companion/manifest.json`, line 6
**Issue:** `"version": "2.0.1"` does not match `package.json` (`2.1.0`) or git tag (`v2.1.1`). Three different version numbers across three sources. In v2.0.0, both files had `"2.0.0"`.

**Fix:** Set manifest version to `"0.0.0"` and let the build system populate it, or match package.json exactly.

---

### H3: `ConnectionFailure` undefined in close handler

**Classification:** ⚠️ PRE-EXISTING
**File:** `LiveProfessor.js`, line 186
**Issue:** `this.updateStatus(ConnectionFailure, 'closed')` — `ConnectionFailure` is not imported. Throws `ReferenceError` when the UDP socket closes. Same root cause as H1 — `InstanceStatus` is not in the import destructure.

**Fix:** Use `InstanceStatus.ConnectionFailure` after importing `InstanceStatus` (same import fix as H1).

---

### H4: `this.qSocket` undefined — error handler double-fault

**Classification:** ⚠️ PRE-EXISTING
**File:** `LiveProfessor.js`, line 178
**Issue:** Inside the `ECONNREFUSED` branch of the `error` handler, `this.qSocket.removeAllListeners()` is called — but `this.qSocket` is never defined anywhere in the module. This throws `TypeError: Cannot read properties of undefined`. The error handler itself crashes, masking the original connection error. The intended target is `this.oscUdp`.

**Fix:** Replace `this.qSocket.removeAllListeners()` with `this.oscUdp.removeAllListeners()`, or remove the `ECONNREFUSED` branch entirely (UDP sockets rarely produce this error).

---

### H5: `destroy()` empty — socket and timer leak

**Classification:** ⚠️ PRE-EXISTING
**File:** `LiveProfessor.js`, line 41
**Issue:** `async destroy() {}` does nothing. When the module is deleted or Companion reloads:
- `this.oscUdp` (the UDP socket) stays open, holding the `feedbackPort` (default 8011). The next `init()` will get `EADDRINUSE`.
- `tempoTimer` (the `setInterval` handle) keeps firing, calling `this.tempoTimer()` on a destroyed instance.

**Fix:**
```js
async destroy() {
    if (this.oscUdp) {
        this.oscUdp.close()
        this.oscUdp = null
    }
    clearInterval(tempoTimer)
}
```

---

### H6: `configUpdated()` leaks old OSC socket

**Classification:** ⚠️ PRE-EXISTING
**File:** `LiveProfessor.js`, lines 44–50
**Issue:** `configUpdated()` calls `this.init_osc()` directly without first closing the existing `this.oscUdp`. Each config change creates a new UDP socket on the same port while the old one remains open and bound. Once the previous `ready` event fires (`this.connecting = false`), the `connecting` guard in `init_osc()` won't protect against the duplicate bind — the new socket gets `EADDRINUSE`.

**Fix:** Close the existing socket before reinitializing:
```js
async configUpdated(config) {
    this.config = config
    if (this.oscUdp) {
        this.oscUdp.close()
        this.oscUdp = null
    }
    this.connecting = false
    this.init_osc()
}
```

---

### H7: console.log used instead of Companion instance logger

**Classification:** 🆕 NEW
**File:** `LiveProfessor.js`, lines 182, 187, 192, 200
**Issue:** The module uses `console.log()` for all logging output instead of the Companion instance logger. Raw `console.log` output is invisible to Companion users — it bypasses the logging infrastructure entirely and appears only in the Companion server console, if at all. Companion modules must use `this.log(level, message)` so output is routed through Companion's log viewer.

**Fix:** Replace all four `console.log(level, msg)` calls with `this.log(level, msg)`. The level strings (`'error'`, `'debug'`, `'info'`) are already correct — only the function name needs to change:
```js
// line 182: this.log('error', 'Error: ' + err.message)
// line 187: this.log('error', 'ECONNREFUSED')
// line 192: this.log('debug', 'Connection to LiveProfessor Closed')
// line 200: this.log('info', 'Connected to LiveProfessor:' + this.config.host)
```

**Status:** Fixed in branch `fix/v2.1.1-2026-04-05-issues`

---

## 🟡 Medium

### M1: Rotary max expanded to 99 but backing arrays are length 4

**Classification:** 🆕 NEW
**File:** `actions.js`, lines 81, 113, 145, 175 / `LiveProfessor.js`, lines 24–25
**Issue:** All four rotary actions (`GenericRotaryRight`, `GenericRotaryLeft`, `GenericRotaryPress`, `GenericRotaryRelease`) increased `max` from 4 to 99 in this release. However, the backing state arrays in `init()` are still:
```js
rotaryValues: [0.0, 0.0, 0.0, 0.0],   // length 4
rotaryPush: [false, false, false, false], // length 4
```

For any `rotaryId` from 5 to 99:
- `rotaryPush[id - 1]` is `undefined` → precision check silently skipped
- `rotaryValues[id - 1]` is `undefined` → `undefined += 0.03` = `NaN` → clamped to `0` → sent as OSC float
- Every rotate event sends `0` instead of the accumulated position

**Fix:** Either revert `max` to 4, or expand both arrays to match the maximum allowed value.

---

### M2: Dead stub methods call undefined globals

**Classification:** 🆕 NEW
**File:** `LiveProfessor.js`, lines 300–309
**Issue:** Three methods added in v2.1.1 call functions that don't exist:
```js
updateActions() { return UpdateActions(this) }          // ReferenceError
updateFeedbacks() { return UpdateFeedbacks(this) }      // ReferenceError
updateVariableDefinitions() { return UpdateVariableDefinitions(this) }  // ReferenceError
```
`UpdateActions`, `UpdateFeedbacks`, `UpdateVariableDefinitions` are not imported or defined. These methods are not called by the v1.x SDK or by module code, so they are currently dead code — but they will crash if ever invoked.

**Fix:** Remove the three methods entirely. The module already uses `init_actions()`, `init_feedbacks()`, `init_variables()`.

---

## ⚠️ Pre-existing Notes

The following issues exist unchanged from v2.0.0. Per review policy, pre-existing medium and lower issues are non-blocking but documented for the maintainer's awareness.

| # | Severity | File | Line(s) | Description |
|---|----------|------|---------|-------------|
| M3 | 🟡 Medium | `LiveProfessor.js` | 215–296 | `processMessage()` accesses `args[0].value` / `args[1].value` without null/length checks. Malformed OSC packet crashes handler. |
| M4 | 🟡 Medium | `LiveProfessor.js` | 11 | `tempoTimer` is a module-level `var`. Multiple instances share the same timer — `clearInterval` in one cancels the other's tempo flash. |
| M5 | 🟡 Medium | `LiveProfessor.js` | 37 | `updateStatus('ok')` in `init()` before the socket fires `ready`. Gives a false "connected" status during startup. |
| L1 | 🟢 Low | `LiveProfessor.js` | 254, 279 | `checkFeedbacks('Rotary')` and `checkFeedbacks('ping')` reference feedbacks not defined in `feedbacks.js`. Calls are no-ops. |
| L2 | 🟢 Low | `LiveProfessor.js` | 144–145 | Dead `connect()` method uses `this.status(this.STATUS_UNKNOWN, ...)` — neither exists in `@companion-module/base ~1.11.2`. Never called. |
| L3 | 🟢 Low | `LiveProfessor.js` | 238 | `'Snap ' + args[1].value + 1` — operator precedence: produces `'Snap 51'` instead of `'Snap 6'` for value=5. Needs `(args[1].value + 1)`. |
| L4 | 🟢 Low | `LiveProfessor.js` | 203 | `this.oscUdp.on('data', (data) => {})` — empty handler, serves no purpose. |
| L5 | 🟢 Low | `actions.js` | 85, 116, 149, 178 | `parseVariablesInString()` called on a `type: 'number'` option value — expects string, gets implicit coercion. Works by accident. |
| L6 | 🟢 Low | `package.json` | — | `@companion-module/tools ^2.6.1` peer-requires `@companion-module/base ^1.12.0` but module has `~1.11.2`. Yarn warns; build succeeds. |
| N1 | 💡 | Root | — | Source files at repository root instead of `src/` directory per template. |
| N2 | 💡 | — | — | Missing `.gitattributes` (`* text=auto eol=lf`). |
| N3 | 💡 | — | — | Missing `.prettierignore`. |
| N4 | 💡 | `package.json` | — | Missing `engines` field (`"node": "^22.x", "yarn": "^4"`). |
| N5 | 💡 | `companion/manifest.json` | 18 | `runtime.type: "node18"` — `node22` recommended. |
| N6 | 💡 | `companion/manifest.json` | — | Missing `$schema` field. |

---

## 🧪 Tests

No test files, test runner configuration, or test scripts detected. Per team standards, the absence of tests is not a blocking issue for companion modules.

---

## ✅ What's Solid

- **`runEntrypoint` correctly used** — v1.x module correctly calls `runEntrypoint(LiveProfessorInstance, UpgradeScripts)` at module bottom
- **Lifecycle methods present** — `init()`, `destroy()`, `configUpdated()`, `getConfigFields()` all implemented
- **`UpgradeScripts` exported** — upgrade script array exists and is structurally correct
- **No action/feedback/config IDs changed** — all IDs match v2.0.0; no upgrade script needed for this release
- **OSC `open()` race condition fixed** — event handlers now register before `oscUdp.open()` (was reversed in v2.0.0) ✅
- **`localAddress` changed to `0.0.0.0`** — allows receiving OSC from remote LiveProfessor hosts ✅
- **GenericButton match tightened** — `/Companion/GenericButtons` is a more precise match for the actual OSC path `/Companion/GenericButtons/Button{N}`. `substring(32)` correctly extracts the button number ✅
- **GenericButton feedback `== 1` comparison** — explicit boolean check instead of truthy coercion ✅
- **Build passes** — `yarn install && yarn package` succeeds, produces `.tgz`
- **yarn.lock present** — no `package-lock.json` found
- **HELP.md substantive** — covers configuration, features, links to OSC command reference
- **Maintainer info updated** — full name and email now in manifest
- **CI workflow and issue templates added** — `.github/` now includes checks workflow and bug/feature templates
- **Prettier formatting applied** — consistent code style throughout
- **`format` and `package` scripts added** — both required npm scripts present
- **`packageManager` field added** — `yarn@4.5.3`
