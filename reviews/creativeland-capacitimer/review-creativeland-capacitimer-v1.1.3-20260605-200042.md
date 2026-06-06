# Review: creativeland-capacitimer v1.1.3

**Module:** `companion-module-creativeland-capacitimer`  
**Release tag:** v1.1.3  
**Previous release:** v1.0.1  
**API:** `@companion-module/base` ~1.12.1 (v1.x)  
**Language:** JavaScript (CommonJS)  
**Reviewed:** 2026-06-05  
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Module Dev), Zoe (QA), Simon (Tests)

---

## Fix Summary for Maintainer

**5 blocking issues must be resolved before this release can be approved:**

1. **`package.json` `main` field** — Change from `"index.js"` to `"src/main.js"` and delete the root `index.js` shim file. (`package.json:4`, `index.js`)
2. **`.gitignore` modified** — Restore `.gitignore` to match the template exactly; remove the `API.md` entry on line 8. (`.gitignore:7-8`)
3. **Unhandled promise rejections in WebSocket `open` handler** — Wrap the three `await` calls to `fetchLicenseStatus()`, `fetchFonts()`, and `fetchDisplays()` in a `try/catch` block. (`src/main.js:313-315`)
4. **Off-by-one in port scan range** — Change `if (this.wsScanPort < 3010)` to `if (this.wsScanPort <= 3010)` so port 3010 is actually tried. (`src/main.js:361`)
5. **Race condition on rapid config change** — Add `this.wsScanPort = null` after closing the WebSocket in `configUpdated()` to cancel any in-progress port scan. (`src/main.js:~125`)

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 3 | 0 | 3 |
| 🟠 High | 2 | 0 | 2 |
| 🟡 Medium | 1 | 1 | 2 |
| 🟢 Low | 3 | 3 | 6 |
| 💡 Nice to Have | 2 | 0 | 2 |
| **Total** | **11** | **4** | **15** |

**Blocking:** 5 issues (3 new/regression critical, 2 new high)  
**Fix complexity:** Medium — template fixes are simple file edits; the 3 QA bugs require targeted logic changes (~20 lines total)  
**Health delta:** 11 introduced · 4 pre-existing noted

---

## Verdict

**❌ Changes Required** — The v1.1.3 release introduces solid new functionality (WebSocket port auto-discovery, license-gated Pro features, display/font enumeration) and the core architecture is sound. However, the migration to a `src/` layout was done incompletely — leaving a root `index.js` shim and a modified `.gitignore` — and the new port-scanning feature has three QA bugs (unhandled rejection, off-by-one, race condition). All five are quick to fix. Once addressed, this module will be in good shape.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Root-level `index.js` shim and incorrect `package.json` main field](#c1-root-level-indexjs-shim-and-incorrect-packagejson-main-field)
- [ ] [C2: `.gitignore` modified — `API.md` entry added](#c2-gitignore-modified--apimd-entry-added)
- [ ] [C3: Unhandled promise rejections in WebSocket `open` handler](#c3-unhandled-promise-rejections-in-websocket-open-handler)
- [ ] [H1: Off-by-one error in WebSocket port scan range](#h1-off-by-one-error-in-websocket-port-scan-range)
- [ ] [H2: Race condition between `configUpdated()` and port scanning](#h2-race-condition-between-configupdated-and-port-scanning)

**Non-blocking**
- [ ] [M1: Deprecated `parseVariablesInString()` on 13 action callbacks](#m1-deprecated-parsevariablesinstring-on-13-action-callbacks)
- [ ] [M2: Malformed hex color can break feedback rendering](#m2-malformed-hex-color-can-break-feedback-rendering)
- [ ] [L1: `feedbacks.js` exported as `async` with no `await`](#l1-feedbacksjs-exported-as-async-with-no-await)
- [ ] [L2: Duplicated Bonjour host-resolution logic](#l2-duplicated-bonjour-host-resolution-logic)
- [ ] [L3: WebSocket port scan may leave old sockets unclosed](#l3-websocket-port-scan-may-leave-old-sockets-unclosed)
- [ ] [L4: No timeout on `fetch()` requests](#l4-no-timeout-on-fetch-requests)
- [ ] [L5: No `InstanceStatus.Error` update on command failures](#l5-no-instancestatuserror-update-on-command-failures)
- [ ] [N1: Use Companion's `bonjour-device` config field instead of running bonjour-service in the module](#n1-use-companions-bonjour-device-config-field-instead-of-running-bonjour-service-in-the-module)
- [ ] [N2: Declare Bonjour service type in `manifest.json`](#n2-declare-bonjour-service-type-in-manifestjson)

---

## 🔴 Critical

### C1: Root-level `index.js` shim and incorrect `package.json` main field

**File:** `package.json:4`, `index.js:1`  
**Classification:** 🔙 REGRESSION (introduced in v1.1.0 during `src/` migration)

The module moved source to `src/main.js` in v1.1.0, but instead of updating `package.json` `main` directly, it added a root-level shim (`module.exports = require('./src/main')`) and points `main` to it. The template requires no root-level source files and `main` pointing directly to the entry point.

**What's wrong:**
- `package.json:4` — `"main": "index.js"` (should be `"src/main.js"`)
- `index.js:1` — shim file present at module root (must not exist)
- `companion/manifest.json:20` — `"entrypoint": "../src/main.js"` ✅ (already correct)

**Required fix:**
1. Delete `/index.js`
2. Update `package.json` line 4: `"main": "src/main.js"`

---

### C2: `.gitignore` modified — `API.md` entry added

**File:** `.gitignore:7-8`  
**Classification:** 🔙 REGRESSION (introduced in v1.1.0; v1.0.1 matched template)

Config files (`.gitignore`, `.gitattributes`, `.prettierignore`, `.yarnrc.yml`) must match the template **exactly**. The module added a blank line and `API.md` entry that are not in the template.

**Found:**
```
/.yarn

API.md
```

**Template expects:**
```
/.yarn
```

**Required fix:** Restore `.gitignore` to match the template (remove lines 7-8):
```
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

If `API.md` is a generated artifact that should be excluded from packaging, handle it in the build script, not `.gitignore`.

---

### C3: Unhandled promise rejections in WebSocket `open` handler

**File:** `src/main.js:301-315`  
**Classification:** 🆕 NEW (introduced in v1.1.3)

The `'open'` event handler is `async` and awaits three fetch calls with no error handling. If any of these fail (DNS error, server down, malformed JSON), the resulting unhandled promise rejection can crash the module process.

**Affected code:**
```javascript
this.ws.on('open', async () => {
    // ... status/timer setup ...
    await this.fetchLicenseStatus()  // line 313
    await this.fetchFonts()          // line 314
    await this.fetchDisplays()       // line 315
})
```

**Required fix:**
```javascript
this.ws.on('open', async () => {
    this.log('info', `WebSocket connected on port ${port}`)
    this.updateStatus(InstanceStatus.Ok)
    this.wsScanPort = null
    if (this.reconnectTimer) {
        clearTimeout(this.reconnectTimer)
        this.reconnectTimer = null
    }
    try {
        await this.fetchLicenseStatus()
        await this.fetchFonts()
        await this.fetchDisplays()
    } catch (err) {
        this.log('error', `Failed to fetch initial state: ${err.message}`)
    }
})
```

---

## 🟠 High

### H1: Off-by-one error in WebSocket port scan range

**File:** `src/main.js:361`  
**Classification:** 🆕 NEW (introduced in v1.1.3)

The port scanner promises to try ports 3001–3010 but never tries port 3010. When `wsScanPort` reaches 3010, the outer check `<= 3010` is true, but the inner check `< 3010` is false, so the scan terminates without attempting the last port.

**Affected code:**
```javascript
if (this.wsScanPort !== null && this.wsScanPort <= 3010) {
    if (this.wsScanPort < 3010) {  // ← off-by-one: should be <= 3010
        this.connectWebSocket(host, this.wsScanPort)
    } else {
        // scan exhausted
    }
}
```

**Required fix:** Change line 361 from `< 3010` to `<= 3010`.

---

### H2: Race condition between `configUpdated()` and port scanning

**File:** `src/main.js:109-136`  
**Classification:** 🆕 NEW (introduced in v1.1.3 with port scanning)

If `configUpdated()` is called while a port scan is in progress, both the old and new scan share the same `this.wsScanPort` counter. The old WebSocket's `close` handler fires after `configUpdated()` resets the state, and both code paths race to increment and read the shared counter. This can cause connections to wrong ports, premature scan termination, or indefinite scan loops.

**Required fix:** Reset `this.wsScanPort = null` after closing the WebSocket in `configUpdated()`:

```javascript
async configUpdated(config) {
    this.config = config
    if (this.reconnectTimer) {
        clearTimeout(this.reconnectTimer)
        this.reconnectTimer = null
    }
    if (this.pollInterval) {
        clearInterval(this.pollInterval)
        this.pollInterval = null
    }
    if (this.ws) {
        this.ws.close()
        this.ws = null
    }
    this.wsScanPort = null  // ← add this line to cancel in-progress scan
    
    const host = this.config.host || this.config.discovered
    // ... rest of method
}
```

---

## 🟡 Medium

### M1: Deprecated `parseVariablesInString()` on 13 action callbacks

**File:** `src/actions.js:127-128, 129, 155, 241, 264, 301-303, 347-348, 374, 457`  
**Classification:** ⚠️ PRE-EXISTING (present in v1.0.1; non-blocking at v1.12)

The module calls `self.parseVariablesInString()` on `textinput` options that already declare `useVariables: true`. As of API v1.13, Companion auto-parses variables in these fields before the callback runs, making these calls no-ops. The module is on v1.12 where this still works, but the calls will become dead code on the next API upgrade.

**Affected actions:** `set_timer` (hours, minutes, seconds), `adjust_timer`, `set_timer_font_size`, `set_time_of_day_font_size`, `set_timer_colors` (3 fields), `set_color_thresholds` (2 fields), `set_time_of_day_color`, `set_message_text` (Pro).

**Required fix for v1.13+ upgrade:** Remove all `await self.parseVariablesInString()` calls on `textinput useVariables` fields — the pre-parsed value is already in `event.options.*`.

---

### M2: Malformed hex color can break feedback rendering

**File:** `src/feedbacks.js:145-149`  
**Classification:** 🆕 NEW (feedback logic updated in v1.1.3)

The `timer_color` feedback parses `this.settings.colorNormal/Warning/Critical` directly into RGB with no input validation. If the Capacitimer server sends an empty string, `undefined`, or a non-hex value in a `settings-update` WebSocket message, the `parseInt(hex.substring(...), 16)` calls produce `NaN`, which `combineRgb()` may pass through silently — resulting in a black or invisible button color.

**Required fix:** Validate the hex string before parsing:
```javascript
if (!hexColor || !/^#?[0-9A-Fa-f]{6}$/.test(hexColor)) {
    hexColor = '#44ff44'  // safe fallback
}
```

---

## 🟢 Low

### L1: `feedbacks.js` exported as `async` with no `await`

**File:** `src/feedbacks.js:3`; caller `src/main.js:549`  
**Classification:** ⚠️ PRE-EXISTING

`module.exports = async function (self) {` — the function is marked `async` but contains no `await`, and the caller does not await the returned promise. Harmless today; dangerous if async logic is ever added without updating the call site.

**Recommendation:** Remove the `async` keyword from the export.

---

### L2: Duplicated Bonjour host-resolution logic

**File:** `src/main.js:166-207` vs `218-238`  
**Classification:** ⚠️ PRE-EXISTING

The IP address resolution block (`addresses` → `referer.address` → `host` → `fqdn`) is copy-pasted between the Bonjour `up` and `down` event handlers. Extract into a small helper to keep both paths in sync.

---

### L3: WebSocket port scan may leave old sockets unclosed

**File:** `src/main.js:297-368`  
**Classification:** 🆕 NEW

During port scanning, each failed connection has `this.ws` overwritten by the next `connectWebSocket()` call before the old socket is explicitly closed. The socket is already in a closed state when overwritten (it fired `close` before the handler ran), so GC will collect it — but the pattern is fragile if timing changes.

**Recommendation (next release):** Before calling `connectWebSocket()` in the scan loop, call `this.ws.removeAllListeners(); this.ws.close()` to make the cleanup explicit.

---

### L4: No timeout on `fetch()` requests

**File:** `src/main.js:276, 389, 410, 428, 458, 490`  
**Classification:** 🆕 NEW

None of the six `fetch()` call sites set a timeout. If the Capacitimer server hangs mid-connection without closing the TCP socket, `sendCommand()` can block for 2+ minutes (OS TCP timeout). Use `AbortController` with a 5–10 second timeout on all calls.

---

### L5: No `InstanceStatus.Error` update on command failures

**File:** `src/actions.js` — all action callbacks  
**Classification:** 🆕 NEW

Action `catch` blocks log the error but leave the instance status as `Ok`. Operators pressing buttons during a server-down condition will see a green module with no visual indication that commands are failing.

**Recommendation:** Call `self.updateStatus(InstanceStatus.Error, err.message)` on persistent send failures, or at minimum on the first failure after a successful connection.

---

## 💡 Nice to Have

### N1: Use Companion's `bonjour-device` config field instead of running bonjour-service in the module

**File:** `src/main.js` (Bonjour discovery code), `companion/manifest.json`  
Since API v1.7, Companion provides a `bonjour-device` config field type that performs Bonjour discovery natively, shared across the app. Adopting it would eliminate the `bonjour-service` dependency, remove the `startBonjourDiscovery()`/`stopBonjourDiscovery()` lifecycle code, and simplify `init()` and `destroy()`.

---

### N2: Declare Bonjour service type in `manifest.json`

**File:** `companion/manifest.json`  
Even without switching to the `bonjour-device` config field, declaring the Bonjour query type in the manifest gives Companion's UI a head start on discovery before the connection initializes.

---

## 🔮 Next Release

- **Upgrade `@companion-module/base` to `~1.13.x`** — removes the need for 13 `parseVariablesInString()` calls (they become no-ops once auto-parsing is active). Also unlocks `secret-text` config fields and value-type feedbacks.
- **Upgrade to `~1.14.x`** — automated config layout, Companion 4.2+ compatibility.

---

## ⚠️ Pre-existing Notes

These items existed in v1.0.1 unchanged. Per severity policy, pre-existing Low findings are non-blocking and noted here for future cleanup.

| ID | File | Issue |
|----|------|-------|
| L1 | `src/feedbacks.js:3` | `async` export with no `await`; caller does not await the return |
| L2 | `src/main.js:166-207` vs `218-238` | Bonjour host-resolution block copy-pasted between `up` and `down` handlers |
| Wash-Note3 | `src/main.js:442-448` | Polling interval started once and never stopped after WebSocket connects; `if` guard prevents real HTTP calls but wastes a tick per second |

---

## 🧪 Tests

No tests present — none required. Absence does not affect approval.

---

## ✅ What's Solid

- **Architecture is correct.** `src/main.js` extends `InstanceBase`, all four lifecycle methods implemented (`init`, `destroy`, `configUpdated`, `getConfigFields`), `runEntrypoint(ModuleInstance, UpgradeScripts)` called at bottom of file.
- **Upgrade scripts cover the breaking changes.** `upgradeV110` in `src/upgrades.js` migrates the renamed `timer_color_*` feedback IDs and removes the dropped `set_timer_font` action — existing user buttons will survive the upgrade.
- **`destroy()` cleans up everything it owns.** WebSocket closed, `reconnectTimer` cleared, `pollInterval` cleared, Bonjour browser stopped and instance destroyed. No resource leaks on shutdown.
- **`configUpdated()` pattern is correct.** Clears timers, closes existing socket, reconnects only when a valid host is configured.
- **Bonjour implementation is thorough.** Filters by service name prefix, resolves IPv4 preference, handles `up`/`down` events, refreshes config panel dynamically.
- **HELP.md is excellent.** Comprehensive, operator-focused documentation covering mDNS discovery, WebSocket port detection, Pro feature visibility, and upgrade notes from v1.0.x. A model HELP.md.
- **Pro/free feature split is clean.** Actions, feedbacks, and variables dynamically update on license status change via `fetchLicenseStatus()` — no stale UI.
- **Actions, feedbacks, presets, and variables are well-designed.** Meaningful labels, grouped logically, `useVariables: true` on dynamic text fields, state-reflecting presets with feedback-driven styling, stable variable IDs.
- **`yarn.lock` present, `package-lock.json` absent, `dist/` not committed.**
- **`manifest.json` is current.** Runtime `node22`, correct `entrypoint`, clean keywords, real maintainer data.
