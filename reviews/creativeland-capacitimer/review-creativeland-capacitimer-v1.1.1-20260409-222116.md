# Review — creativeland-capacitimer v1.1.1

**Date:** 2026-04-09  
**Reviewer Team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧬  
**Prior Approved Version:** v1.0.1  
**Change scope:** Significant update (~1,448 insertions across 12 files) adding Pro license gating, Bonjour/mDNS device discovery, WebSocket port scanning, display management, message overlays, and a unified `timer_color` feedback replacing three separate feedback IDs.

---

## Fix Summary

v1.1.1 introduces a rich feature set cleanly structured and well-documented — but ships with four blocking issues that must be addressed before approval:

**Two categories of blocking problems:**

**Category A — Missing upgrade scripts (2 blocking):** Three feedback IDs used in v1.0.1 (`timer_color_normal`, `timer_color_warning`, `timer_color_critical`) were removed and consolidated into a single `timer_color` feedback with no upgrade migration. Additionally, `set_timer_font` — available to all users in v1.0.1 — is now gated to Pro-only, orphaning saved configs for non-Pro users. Both require entries in `upgrades.js`.

**Category B — WebSocket lifecycle race (2 blocking):** The `close` event on an intentionally closed WebSocket fires asynchronously *after* `destroy()` and `configUpdated()` have completed their cleanup. In both cases the `close` handler schedules a new `initWebSocket()` call that was never cancelled — causing a zombie reconnect after module teardown and a duplicate connection after every config save. Both are fixed by a single `_intentionalClose` flag.

**Required fixes before approval:**

1. **H1** — Add upgrade script to migrate `timer_color_normal` / `timer_color_warning` / `timer_color_critical` → `timer_color` in `upgrades.js`
2. **H2** — Add upgrade script to handle `set_timer_font` actions in saved configs from non-Pro users (or register the action universally and gate its execution rather than its registration)
3. **H3** — Set `this._intentionalClose = true` before `this.ws.close()` in `destroy()` and check it at the top of the `close` handler to prevent post-destroy zombie reconnect
4. **H4** — Set `this._intentionalClose = true` (or equivalent flag) before `this.ws.close()` in `configUpdated()` to prevent double-reconnect 5 seconds after every config save; clear the flag at the start of `connectWebSocket()`

---

## 📊 Scorecard

| Severity | New | Pre-existing |
|----------|-----|--------------|
| 🔴 Critical | 0 | 0 |
| 🟠 High | 4 | 0 |
| 🟡 Medium | 4 | 0 |
| 🟢 Low | 11 | 5 |
| 💡 NTH | 1 | — |

**Tests:** None (non-blocking)  
**Build:** ✅ PASS (`yarn install` + `yarn package` clean)

---

## ✋ Verdict

> ⛔ **CHANGES REQUIRED** — 4 blocking issues (4 High NEW)

---

## 📋 Issues TOC

| # | Sev | File | Title |
|---|-----|------|-------|
| H1 | 🟠 High | `upgrades.js` | Missing upgrade scripts for 3 removed feedback IDs |
| H2 | 🟠 High | `upgrades.js` | `set_timer_font` moved to Pro-only with no saved-config migration |
| H3 | 🟠 High | `main.js` | Post-destroy zombie reconnect via async `close` event |
| H4 | 🟠 High | `main.js` | Double-reconnect on `configUpdated` via async `close` event |
| M1 | 🟡 Medium | `main.js` | Port scan off-by-one: port 3010 never tried |
| M2 | 🟡 Medium | `actions.js` | Font size `\|\| 100` falsy coercion: `0` becomes `100` |
| M3 | 🟡 Medium | `main.js` | Port scan can loop on same port if `close` fires without prior `error` |
| M4 | 🟡 Medium | `actions.js` / `upgrades.js` | `thresholdNormal` option silently discarded from saved `set_color_thresholds` actions |
| L1 | 🟢 Low | `main.js` | Stale device state persists after host change in `configUpdated` |
| L2 | 🟢 Low | `feedbacks.js` | `timer_color` feedback: no hex color format validation |
| L3 | 🟢 Low | `main.js` | `license-update` WebSocket event unhandled — Pro UI won't refresh live |
| L4 | 🟢 Low | `main.js` | `wsScanPort` not reset on `configUpdated` or `destroy()` |
| L5 | 🟢 Low | `main.js` | `manifest.runtime.apiVersion` set to `"1.12.0"` instead of `"0.0.0"` |
| L6 | 🟢 Low | `variables.js` | Removed variables (`threshold_normal`, `timer_font`) not documented in HELP |
| L7 | 🟢 Low | `presets.js:141` | Typo: `"Set Timer to 1 Minutes"` |
| L8 | 🟢 Low (PRE) | `main.js` | No reconnect guard: `reconnectTimer` set without clearing previous |
| L9 | 🟢 Low (PRE) | `main.js` | Fixed 5 s reconnect with no exponential back-off |
| L10 | 🟢 Low (PRE) | `feedbacks.js:1` | `feedbacks.js` exported as `async` function but never awaited |
| L11 | 🟢 Low (PRE) | `main.js` | Bonjour `down` event doesn't clear active `config.discovered` |
| L12 | 🟢 Low (PRE) | `main.js` | No input sanitization on `host` config field |
| NTH1 | 💡 NTH | `package.json` | `eslint` missing from `devDependencies` (peer-dep warning) |

---

## 🟠 High Issues

### H1 🆕 — Missing upgrade scripts for 3 removed feedback IDs

**File:** `upgrades.js` (empty)

Three advanced-color feedbacks present in v1.0.1 saved configs no longer exist in v1.1.1:

| Removed ID | Replaced by |
|------------|------------|
| `timer_color_normal` | `timer_color` |
| `timer_color_warning` | `timer_color` |
| `timer_color_critical` | `timer_color` |

`upgrades.js` remains an empty stub. Any user who had these feedbacks on a Companion button will silently find them orphaned — the button loses its color feedback behavior with no error message.

**Fix:** Add a single upgrade function as the first entry in `upgrades.js`:

```js
function upgradeV110(context, props) {
    const updatedFeedbacks = []
    const oldIds = ['timer_color_normal', 'timer_color_warning', 'timer_color_critical']
    for (const feedback of props.feedbacks) {
        if (oldIds.includes(feedback.feedbackId)) {
            updatedFeedbacks.push({
                ...feedback,
                feedbackId: 'timer_color',
                options: {},
            })
        }
    }
    return { updatedConfig: null, updatedActions: [], updatedFeedbacks }
}

module.exports = [upgradeV110]
```

Note: the new `timer_color` feedback takes no options and applies its color based on the current timer phase automatically — the best-effort migration is to remap all three old IDs to `timer_color` with empty options.

---

### H2 🆕 — `set_timer_font` moved to Pro-only with no saved-config migration

**File:** `main.js` / `actions.js` / `upgrades.js`

In v1.0.1, `set_timer_font` was registered unconditionally (available to all users). In v1.1.1, it is only registered when `this.isPro` is `true`. Non-Pro users who had this action saved in a button config will have it silently become an orphaned unknown action after upgrade.

Two acceptable approaches:

**Option A (recommended):** Always register the action but disable or warn if not Pro:
```js
// In actions.js — always register, gate execution
set_timer_font: {
    name: 'Set Timer Font (Pro)',
    options: [...],
    callback: async (event) => {
        if (!self.isPro) {
            self.log('warn', 'set_timer_font requires a Pro license')
            return
        }
        // ... existing logic
    }
}
```

**Option B:** Add an upgrade script that removes `set_timer_font` actions from saved configs, so they are cleanly absent rather than silently dead (add to the `upgradeV110` function in H1):
```js
const updatedActions = props.actions.filter(a => a.actionId !== 'set_timer_font')
return { updatedConfig: null, updatedActions, updatedFeedbacks }
```

---

### H3 🆕 — Post-destroy zombie reconnect via async `close` event

**File:** `main.js` — `destroy()` and `connectWebSocket()` `close` handler

`destroy()` performs the following sequence:
```js
this.ws.close()            // (1) enqueues async 'close' event
this.ws = null
clearTimeout(this.reconnectTimer)  // (2) clears current timer — but...
// destroy() returns

// ~1 event-loop tick later, old socket fires its 'close' event:
this.ws.on('close', () => {
    this.reconnectTimer = setTimeout(() => {
        this.initWebSocket()   // called on a DESTROYED instance, 5 s later
    }, 5000)
})
```

Step (2) clears the timer that existed *before* `ws.close()` was called. But the `close` handler fires *after* `destroy()` has returned and sets a **brand-new** timer that was never cancelled. Five seconds later `initWebSocket()` opens a new WebSocket on a torn-down instance — a zombie resource leak.

**Fix:** Add a `_destroyed` (or `_intentionalClose`) flag:
```js
// destroy():
this._destroyed = true
this.ws.close()
// ...

// At top of close handler:
if (this._destroyed) return
```

Reset `_destroyed = false` in `init()` / `initWebSocket()`.

---

### H4 🆕 — Double-reconnect on `configUpdated` via async `close` event

**File:** `main.js` — `configUpdated()` and `connectWebSocket()` `close` handler

Same root cause as H3. `configUpdated` performs:
```js
clearTimeout(this.reconnectTimer)   // clears existing timer ✓
this.ws.close()                     // old socket — async close event pending
this.ws = null
this.wsScanPort = null
// ...
this.initWebSocket()                // creates NEW connection immediately ✓

// ~5 s later, old socket's 'close' event fires:
// wsScanPort is null → normal-disconnect branch
this.updateStatus(InstanceStatus.Disconnected)  // spurious status flip ⚠️
this.reconnectTimer = setTimeout(() => {
    this.initWebSocket()            // SECOND connection, orphaning the first ⚠️
}, 5000)
```

Every config save causes: a spurious `Disconnected` status flash after 1 tick, and a second socket creation 5 seconds later that orphans the already-connected first socket. This repeats on every subsequent config save.

**Sub-case:** If `configUpdated` fires mid-scan (`wsScanPort !== null`), the stale close handler enters the scan branch and calls `connectWebSocket(host, wsScanPort)` with the old scan port offset against the new host — a rogue connection attempt.

**Fix:** Same `_intentionalClose` flag as H3. Set it before `this.ws.close()` in `configUpdated()`, clear it at the start of `connectWebSocket()`:
```js
// configUpdated:
this._intentionalClose = true
this.ws.close()
this.ws = null
this.wsScanPort = null
this._intentionalClose = false  // clear immediately (or clear in connectWebSocket)
this.initWebSocket()

// close handler:
if (this._intentionalClose) return
```

---

## 🟡 Medium Issues

### M1 🆕 — Port scan off-by-one: port 3010 never tried

**File:** `main.js` — `connectWebSocket()` `error` handler and `close` handler

The `error` handler increments `wsScanPort` while `wsScanPort < 3010`, capping at 3010. The `close` handler's scan branch calls `connectWebSocket(host, wsScanPort)` only when `wsScanPort < 3010`. When `wsScanPort` reaches 3010, the `close` handler sees `3010 < 3010` = `false` and takes the exhausted branch — port 3010 is never attempted despite the log message advertising "3001–3010".

**Fix:** Change the `close` handler's connect condition to `wsScanPort <= 3010` and the exhaustion check to `wsScanPort > 3010`.

---

### M2 🆕 — Font size `|| 100` falsy coercion: `0` silently becomes `100`

**File:** `actions.js` — `set_timer_font_size` and `set_time_of_day_font_size` callbacks

```js
const fontSize = parseInt(await self.parseVariablesInString(String(event.options.fontSize))) || 100
```

`parseInt("0")` returns `0`, which is falsy. `0 || 100` evaluates to `100`. A user who sets font size to `0` (a valid value to effectively hide an element) silently gets `100` instead with no error or feedback.

**Fix:**
```js
const parsed = parseInt(await self.parseVariablesInString(String(event.options.fontSize)))
const fontSize = isNaN(parsed) ? 100 : parsed
```

---

### M3 🆕 — Port scan can loop on same port if `close` fires without prior `error`

**File:** `main.js` — `connectWebSocket()` `close` handler

`wsScanPort` is only incremented in the `error` handler. If a TCP `close` fires without a preceding `error` event during a scan (e.g., on some platforms a clean RST produces `close` without `error`), the `close` handler retries the same `wsScanPort` indefinitely — an infinite loop on port 3001.

The `ws` library typically emits `error` before `close` on refused connections, making this low-probability in practice. However, the logic should be made defensive.

**Fix:** Also increment `wsScanPort` at the start of the `close` handler's scan path, or move port advancement to a shared helper.

---

### M4 🆕 — `thresholdNormal` option silently discarded from saved `set_color_thresholds` actions

**File:** `actions.js` / `upgrades.js`

The `thresholdNormal` option was present in `set_color_thresholds` in v1.0.1 and has been removed in v1.1.1. Companion silently discards unknown options on load — the action continues to work, but the user's previously configured `thresholdNormal` value is permanently lost without warning.

Technically non-crash, but users upgrading from v1.0.1 silently lose a configured value with no indication. This should be added to the `upgradeV110` function from H1:
```js
for (const action of props.actions) {
    if (action.actionId === 'set_color_thresholds' && action.options.thresholdNormal !== undefined) {
        const { thresholdNormal, ...remainingOptions } = action.options
        updatedActions.push({ ...action, options: remainingOptions })
    }
}
```

---

## 🟢 Low Issues

### L1 🆕 — Stale device state persists after host change in `configUpdated`

**File:** `main.js` — `configUpdated()`

`configUpdated` closes the old WebSocket and opens a new one, but `this.timerState`, `this.settings`, `this.messageState`, and `this.displayState` are never reset. After switching from Device A to Device B, Companion continues displaying Device A's time remaining, running state, and message text until the first WebSocket push from Device B arrives.

**Fix:** Reset state objects to constructor defaults at the start of `configUpdated` (before `initWebSocket`), then call `this.updateVariables()` and `this.checkFeedbacks()` to clear the display immediately.

---

### L2 🆕 — `timer_color` feedback: no hex color format validation

**File:** `feedbacks.js` — `timer_color` callback

```js
const hex = hexColor.replace('#', '')
const r = parseInt(hex.substring(0, 2), 16)
const g = parseInt(hex.substring(2, 4), 16)
const b = parseInt(hex.substring(4, 6), 16)
return { bgcolor: combineRgb(r, g, b) }
```

If the device sends a malformed `hexColor` (empty string, short-form `#RGB`, or non-hex characters), `parseInt` returns `NaN` for one or more channels and `combineRgb(NaN, NaN, NaN)` produces a nonsensical color value.

**Fix:**
```js
const safeColor = /^#[0-9a-fA-F]{6}$/.test(rawHexColor) ? rawHexColor : '#44ff44'
```

---

### L3 🆕 — `license-update` WebSocket event unhandled: Pro UI won't refresh live

**File:** `main.js` — `ws.on('message', ...)` handler

The WS message handler covers `timer-update`, `settings-update`, `message-update`, and `display-state-update`, but has no case for `license-update`. If the operator activates or deactivates a Pro license while Companion is connected, Pro-gated actions, feedbacks, and variables will only refresh after the next reconnect — not in real time.

**Fix:** Add a `license-update` handler that calls `this.fetchLicenseStatus()` (already triggers `updateActions` / `updateFeedbacks` / `updateVariableDefinitions` on license change).

---

### L4 🆕 — `wsScanPort` not reset on `configUpdated` or `destroy()`

**File:** `main.js`

`this.wsScanPort` is reset to `null` only when a connection succeeds or the scan is exhausted. If `configUpdated` fires mid-scan, the old `wsScanPort` value leaks into the next connection cycle, potentially starting the new scan at an incorrect port offset.

**Fix:** Add `this.wsScanPort = null` at the start of `configUpdated()` and `destroy()`.

---

### L5 🆕 — `manifest.runtime.apiVersion` explicitly set to `"1.12.0"`

**File:** `companion/manifest.json`

For v1.x modules, the standard template sets `"apiVersion": "0.0.0"` — `companion-module-build` auto-patches this to the actual base version at package time. Explicitly setting `"1.12.0"` deviates from the template and could cause confusion when reading the source manifest. Build verified clean, so functionally harmless.

**Recommendation:** Change to `"apiVersion": "0.0.0"` to match the standard v1.x template.

---

### L6 🆕 — Removed variables not documented in HELP

**File:** `variables.js` / `companion/HELP.md`

Two variables present in v1.0.1 are gone in v1.1.1:
- `$(capacitimer:threshold_normal)` — removed entirely  
- `$(capacitimer:timer_font)` — moved to Pro-only

Users with these variable references in button text will see them stop resolving silently. The SDK has no upgrade path for variable removal, but HELP.md and README.md should note the change explicitly.

---

### L7 🆕 — Typo in preset name

**File:** `presets.js:141`

`'Set Timer to 1 Minutes'` should be `'Set Timer to 1 Minute'` (singular).

---

### L8 ⚠️ Pre-existing — No reconnect guard in `close` handler

**File:** `main.js` — `connectWebSocket()` `close` handler

`this.reconnectTimer = setTimeout(...)` is called without first clearing any existing timer. If `close` fired twice in quick succession, two simultaneous timers would fire — unlikely in practice but defensive coding is cheap:
```js
clearTimeout(this.reconnectTimer)
this.reconnectTimer = setTimeout(() => {
    this.reconnectTimer = null
    this.initWebSocket()
}, 5000)
```

---

### L9 ⚠️ Pre-existing — Fixed 5 s reconnect with no exponential back-off

**File:** `main.js`

Constant 5-second reconnect delay. If the Capacitimer is offline for an extended period, this produces a steady connection attempt storm. A capped exponential back-off (5s → 10s → 20s → 60s max) would reduce log noise and network chatter.

---

### L10 ⚠️ Pre-existing — `feedbacks.js` exported as `async` function that awaits nothing

**File:** `feedbacks.js:1`

`module.exports = async function (self) { ... }` — the calling site in `main.js` does not `await` the result and nothing inside is awaited. Functionally harmless; `setFeedbackDefinitions()` is synchronous. Remove `async` to avoid confusion.

---

### L11 ⚠️ Pre-existing — Bonjour `down` handler doesn't clear active `config.discovered`

**File:** `main.js` — `bonjourBrowser.on('down', ...)`

When a discovered device goes offline, it is removed from `this.discoveredInstances` and `saveConfig()` is called, but `this.config.discovered` is not cleared if it was the active device. The module continues attempting reconnects to the now-offline host indefinitely.

---

### L12 ⚠️ Pre-existing — No input sanitization on `host` config field

**File:** `main.js`

The `host` value is concatenated directly into HTTP and WebSocket URLs (`http://${host}/api/...`, `ws://${host}:${port}`). No trimming, URL encoding, or character validation. Low practical risk on a local-network-only module but a `Regex.Hostname` validator on the config field would be best practice.

---

## 💡 Nice to Have

### NTH1 — `eslint` missing from `devDependencies`

`@companion-module/tools` requests `eslint` as a peer dependency. `yarn install` emits a `YN0002` warning. Adding `eslint` to `devDependencies` silences the warning and enables linting via `@companion-module/tools`.

---

## 🔮 Next Release Suggestions

- Implement exponential back-off on WebSocket reconnect (see L9)
- Handle `license-update` WebSocket event for live Pro tier switching (see L3)
- Reset device state variables on host change (see L1)
- Consider providing `eslint` config and a `lint` script (see NTH1)

---

## ⚠️ Pre-existing Notes

The following issues existed in v1.0.1 and were not introduced in v1.1.1. They are noted for awareness but are **non-blocking** for this review:

- No reconnect guard in `close` handler (L8)
- Fixed 5 s reconnect, no backoff (L9)
- `feedbacks.js` unnecessary `async` export (L10)
- Bonjour `down` doesn't clear active `config.discovered` (L11)
- No host input sanitization (L12)

---

## 🧪 Tests

**No tests found.** The module contains no test files (`*.test.js`, `*.spec.js`, or similar) and no `test` script in `package.json`.

**Non-blocking** — test coverage is not required for v1.x modules. A future release should introduce at least unit tests for WebSocket message parsing and the port-scan state machine.

**Build result:** `yarn install` + `yarn package` — ✅ PASS (clean, no errors)

---

## ✅ What's Solid

- **Pro feature gating is well-structured** — `isPro` cleanly gates actions, feedbacks, and variables; definitions rebuild correctly when license state changes via `fetchLicenseStatus()`
- **Bonjour/mDNS cleanup is correct** — `stopBonjourDiscovery()` calls both `bonjourBrowser.stop()` and `bonjour.destroy()`; `discoveredInstances` is cleared on `destroy()`; no resource leak on module teardown
- **WebSocket port-scan strategy is clever UX** — fetching `wsPort` from the REST endpoint first, then falling back to scanning 3001–3010, handles the common case and firmware variation cleanly
- **JSON message parsing is safe** — every `JSON.parse()` is wrapped in `try/catch`; malformed messages are logged and discarded without crashing
- **No-host guards are correct** — both `init()` and `configUpdated()` skip WebSocket connection when no host is configured and set `InstanceStatus.Disconnected` with a clear message
- **All action callbacks are void-returning** — `async` callbacks return `undefined` correctly per v1.x API requirement
- **Comprehensive preset library** — covers timer control, set timer (8 presets), adjust timer, display control, and status; Pro-only presets correctly gated
- **API.md is detailed and current** — covers all REST endpoints, WebSocket events, Pro-gated endpoints, and response formats; consistent with the implementation
- **No hardcoded credentials or secrets** found; no `eval` or `new Function` patterns
- **Manifest is clean** — version matches `package.json`, no banned `"companion"` keyword in keywords array
- **`sendCommand` guards the Pro error payload** — `data.success === true` check prevents a `{ success: false, message: "..." }` response from corrupting `this.messageState`
