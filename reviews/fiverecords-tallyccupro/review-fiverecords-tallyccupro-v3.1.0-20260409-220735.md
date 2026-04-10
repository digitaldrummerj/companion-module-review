# Review — fiverecords-tallyccupro v3.1.0

**Date:** 2026-04-09  
**Reviewer Team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧬  
**Release Type:** FIRST RELEASE  
**Prior Version:** N/A  

---

## Fix Summary

This is a solid first release of a Blackmagic camera controller module supporting the TallyCCU Pro device. The dual-channel architecture (HTTP polling + TCP push) is well-conceived and correctly implemented for a v1.x module. No blocking issues were found — the module is approved with notes covering five medium-severity correctness bugs, several low-severity defensive coding gaps, and a few NTH improvements for a future release.

**Priority fixes before next release:**

1. **M2** — `connection.js:122` — HTTP slow-mode sets `pingInterval` to 60 s when the default is 120 s, making retry polls _faster_ under failure; fix to 300 s or higher and add recovery exit logic.
2. **M3** — `tcp.js:133,145,156` — `parseInt` on TCP-sourced camera/preset IDs is never validated for `NaN`; add `isNaN` guard to prevent garbage state keys.
3. **M4** — `main.js:115-134` — `configUpdated` does not refresh `current_*` shortcut variables when `defaultCameraId` changes; re-apply cached state for the new default camera after config update.
4. **M5** — `tcp.js:200,219` — strict `===` used for `cameraId` comparison while `variables.js` uses loose `==`; unify to prevent silent variable update failures on config load.
5. **M1** — `tcp.js:40` — TCP receive buffer has no max-size cap; add a hard limit (e.g., 64 KB) and reconnect if exceeded to defend against firmware bugs or malformed frames.

---

## 📊 Scorecard

| Severity | New | Pre-existing |
|----------|-----|--------------|
| 🔴 Critical | 0 | 0 |
| 🟠 High | 0 | 0 |
| 🟡 Medium | 5 | 0 |
| 🟢 Low | 7 | 0 |
| 💡 NTH | 3 | — |

**Tests:** None (non-blocking for first release)  
**Build:** ✅ PASS (`yarn install` + `yarn package` clean)

---

## ✋ Verdict

> ✅ **APPROVED WITH NOTES** — 0 blocking issues

No Critical or High issues. Five medium-severity bugs should be addressed before the next release. The module is functionally correct for its intended local-network use case.

---

## 📋 Issues TOC

| # | Sev | File | Title |
|---|-----|------|-------|
| M1 | 🟡 Medium | `tcp.js:40` | TCP receive buffer has no max-size cap |
| M2 | 🟡 Medium | `connection.js:119-128` | HTTP slow-mode backoff is backwards and irreversible |
| M3 | 🟡 Medium | `tcp.js:133,145,156` | `parseInt` on TCP IDs never validated for `NaN` |
| M4 | 🟡 Medium | `main.js:115-134` | `configUpdated` does not refresh `current_*` variables on `defaultCameraId` change |
| M5 | 🟡 Medium | `tcp.js:200,219` | Strict `===` vs loose `==` equality mismatch for `defaultCameraId` |
| L1 | 🟢 Low | `tcp.js:86-94` | Fixed 5 s TCP reconnect with no back-off |
| L2 | 🟢 Low | `tcp.js:48` | `close` event reconnect guard is dead code |
| L3 | 🟢 Low | `connection.js:15-18` | `reconnectAttempts` not reset on TCP-only success path |
| L4 | 🟢 Low | `main.js:120` | `configUpdated` does not call `updateVariableDefinitions()` |
| L5 | 🟢 Low | `feedbacks.js:1` | `feedbacks.js` exports an `async` function that awaits nothing |
| L6 | 🟢 Low | `package.json` | `eslint` missing from `devDependencies` |
| L7 | 🟢 Low | `tcp.js:229-255` | `sendCachedState` does not check `socket.writable` per-write |
| NTH1 | 💡 NTH | — | No built-in Companion button presets |
| NTH2 | 💡 NTH | `manifest.json:18` | Redundant double-store in increment/decrement callbacks |
| NTH3 | 💡 Info | `manifest.json:18` | `runtime.apiVersion: "0.0.0"` (auto-patched at build time) |

---

## 🟡 Medium Issues

### M1 🆕 — TCP receive buffer has no max-size cap

**File:** `src/tcp.js:28,40`

```js
// initialised empty
self.tcpBuffer = ''

// data handler — no size limit
self.tcpBuffer += data.toString()
this.processTcpBuffer(self)
```

`self.tcpBuffer` accumulates every received byte until a `\r\n` delimiter is seen. If the TallyCCU Pro sends malformed data or a firmware bug produces a large unframed blob, the buffer grows unbounded for the lifetime of the socket, eventually exhausting process memory.

**Severity justification:** Requires a device-side failure (firmware bug, network injection) on a local LAN — unlikely but possible. Three of five reviewers (Kaylee, Zoe, Mal) did not flag this as blocking. Classified Medium (non-blocking) in context of a trusted local-network device.

**Recommended fix:**
```js
self.tcpBuffer += data.toString()
if (self.tcpBuffer.length > 65536) {
    self.log('error', 'TCP receive buffer overflow — destroying socket')
    self.tcpBuffer = ''
    self.tcpSocket.destroy()
    return
}
this.processTcpBuffer(self)
```

---

### M2 🆕 — HTTP slow-mode backoff is backwards and irreversible

**File:** `src/connection.js:119-128`

```js
// Default: self.pingInterval = 120000 (main.js:38)
if (!connected && self.reconnectAttempts >= self.maxReconnectAttempts) {
    clearInterval(self.connectionTimer)
    self.log('warn', 'Multiple connection failures, increasing check interval')
    self.pingInterval = 60000   // ← 60 s is FASTER than the default 120 s
    self.connectionTimer = setInterval(() => {
        this.checkConnection(self).catch(...)
    }, self.pingInterval)
}
```

Two bugs in the slow-mode logic:

1. **Backwards interval:** The comment says "increasing check interval" but 60 s < 120 s default — the module polls the device *more* frequently after multiple failures, not less.
2. **No recovery exit:** Once the slow-mode timer replaces the normal timer, there is no code path that restores the original interval on successful reconnect. The module stays in the fast 60 s poll for the rest of its lifetime (unless `configUpdated` is called and restarts the monitor).

**Recommended fix:**
```js
if (!connected && self.reconnectAttempts >= self.maxReconnectAttempts) {
    clearInterval(self.connectionTimer)
    self.pingInterval = 300000  // 5 min — genuinely slower
    self.log('warn', `Multiple connection failures, slowing poll to ${self.pingInterval / 1000}s`)
    self.connectionTimer = setInterval(async () => {
        const ok = await this.checkConnection(self).catch(() => false)
        if (ok) {
            // Recover: restart at normal interval
            clearInterval(self.connectionTimer)
            self.pingInterval = 120000
            this.startConnectionMonitor(self)
        }
    }, self.pingInterval)
}
```

---

### M3 🆕 — `parseInt` on TCP-sourced IDs never validated for `NaN`

**File:** `src/tcp.js:133,145,156`

```js
const cameraId = parseInt(parts[0])   // NaN if parts[0] is not a number
const presetId = parseInt(parts[1])   // NaN if parts[1] is not a number
```

A malformed TCP message (e.g., `CCU abc gain_db 0`) produces `cameraId = NaN`. Downstream effects:
- `self.cameraStates[NaN] = {}` — creates an unreachable garbage key in the state map
- `self.paramValues['camNaN_gain_db'] = …` — invisible param key accumulates garbage
- `setVariableValues({ 'camNaN_param_gain_db': … })` — Companion may emit warnings for undefined variable IDs

No crash occurs, but state becomes silently inconsistent.

**Recommended fix:**
```js
const cameraId = parseInt(parts[0])
if (isNaN(cameraId) || cameraId < 1 || cameraId > 8) return

const presetId = parseInt(parts[1])
if (isNaN(presetId)) return
```

---

### M4 🆕 — `configUpdated` does not refresh `current_*` variables on `defaultCameraId` change

**File:** `src/main.js:115-134`

`configUpdated` calls `updateActions()` and `updateFeedbacks()` after saving the new config, but never re-applies `cameraStates[newDefaultCameraId]` to the `current_*` shortcut variables. After the user changes `Default Camera ID` in the Companion UI, `$(module:current_preset_name)`, `$(module:current_preset_id)`, and related variables continue to show the old camera's data until a full module restart or until the TallyCCU Pro sends a fresh TCP push for the new default camera.

**Recommended fix:** After updating `this.config`, call a helper that re-applies `cameraStates[this.config.defaultCameraId]` to the shortcut variables:
```js
this.config = config
// ... existing calls ...
if (this.cameraStates && this.config.defaultCameraId) {
    this.updateVariablesFromParams(
        this.config.defaultCameraId,
        this.cameraStates[this.config.defaultCameraId] || {}
    )
}
```

---

### M5 🆕 — Strict `===` vs loose `==` equality mismatch for `defaultCameraId`

**Files:** `src/tcp.js:200,219` vs `src/variables.js:40,50,82`

```js
// tcp.js — strict ===
if (cameraId === self.config.defaultCameraId) {
    // populate current_preset_name / current_preset_id
}

// variables.js — loose ==
if (cameraId == self.config.defaultCameraId) {
```

`cameraId` from `parseInt(parts[0])` is always a `number`. If Companion's persistence layer ever coerces the saved `number` config field to a `string` (possible across upgrade scripts or initial config migration), then `1 === "1"` evaluates to `false` and the `current_*` shortcut variables will silently stop updating from TCP push events. The `==` path in `variables.js` handles this correctly; `tcp.js` does not.

**Recommended fix:** Change `tcp.js:200,219` to use `==` (or coerce both sides with `Number(...)`).

---

## 🟢 Low Issues

### L1 🆕 — Fixed 5 s TCP reconnect with no back-off

**File:** `src/tcp.js:86-94`

```js
scheduleTcpReconnect(self) {
    self.tcpReconnectTimer = setTimeout(() => {
        this.startTcpConnection(self)
    }, self.tcpReconnectInterval)   // always 5000 ms
}
```

When the device is unreachable, the module attempts a new TCP connection every 5 seconds indefinitely. Consider implementing capped exponential back-off (e.g., 5 s → 10 s → 20 s … → 120 s cap) and resetting on successful connect to reduce log noise and network chatter during extended outages.

---

### L2 🆕 — `close` event reconnect guard is dead code

**File:** `src/tcp.js:48`

```js
self.tcpSocket.on('close', () => {
    self.tcpConnected = false
    this.stopTcpPing(self)
    if (self.tcpSocket === null || !self.tcpSocket.connecting) {  // always true
        this.scheduleTcpReconnect(self)
    }
})
```

When the `close` event fires, `self.tcpSocket` is still the closed socket object (not `null`), and `self.tcpSocket.connecting` is `false` (a closed socket is not connecting). Therefore `!self.tcpSocket.connecting` is always `true`, making the guard effectively unconditional. The intended condition (guarding against reconnect during an active connect attempt) should check `!self.tcpSocket.connecting` alone, but placed on the `connect` event rather than the `close` event. The current guard is dead code — reconnect is always scheduled. Functionally harmless but misleading.

---

### L3 🆕 — `reconnectAttempts` not reset on TCP-only success path

**File:** `src/connection.js:15-18`

```js
if (self.tcpConnected) {
    self.connectionStatus = 'ok'
    self.updateStatus(InstanceStatus.Ok, 'Connected via TCP')
    return true  // ← does NOT reset self.reconnectAttempts
}
```

`reconnectAttempts` is only reset in `checkConnection` when the HTTP probe succeeds (line 52). If TCP reconnects successfully but the HTTP probe is never reached (because of the early return), the counter retains its previous value and the status message continues to display a stale retry count (e.g., `"Connection timeout (3/3)"`), which is misleading to the operator.

**Recommended fix:** Add `self.reconnectAttempts = 0` before the early `return true`.

---

### L4 🆕 — `configUpdated` does not call `updateVariableDefinitions()`

**File:** `src/main.js:120`

`configUpdated` calls `updateActions()` and `updateFeedbacks()` but does not call `updateVariableDefinitions()`. The variable definitions are static (not config-dependent), so this does not cause a crash or visible regression. However, calling `updateVariableDefinitions()` after config updates is standard hygiene per the v1.x module template.

---

### L5 🆕 — `feedbacks.js` exports an `async` function that awaits nothing

**File:** `src/feedbacks.js:1`

```js
module.exports = async function(self) {
    // ... no await expressions
}
```

The `async` keyword is unnecessary here. It causes the function to return a `Promise<void>` rather than `void`, which is harmless because Companion's v1.x API ignores the return value of registration helpers. Cosmetically remove `async` to avoid confusion about whether registration is asynchronous.

---

### L6 🆕 — `eslint` missing from `devDependencies`

**File:** `package.json`

`@companion-module/tools` declares `eslint` as a peer dependency. Since `eslint` is not listed in `devDependencies`, `yarn install` emits a `YN0002` peer-dep warning. No functional impact; add `eslint` to silence the warning:

```json
"devDependencies": {
    "eslint": "^8.0.0"
}
```

---

### L7 🆕 — `sendCachedState` does not check `socket.writable` per-write

**File:** `src/tcp.js:229-255`

```js
sendCachedState(self) {
    if (!self.tcpSocket || !self.tcpConnected) return
    // ... iterates writes
    self.tcpSocket.write(msg)  // no .writable check per iteration
}
```

The function performs a single guard at entry but does not check `self.tcpSocket.writable` before each subsequent `socket.write()` call. In single-threaded Node.js, no other event can fire during synchronous iteration, so this is not a true race condition. However, if the function is ever refactored to include `await` calls (e.g., for throttling), the absence of a per-write guard could become a real issue. Defensive coding: check `self.tcpSocket.writable` before each write, or check it once at function entry.

---

## 💡 Nice to Have

### NTH1 — No built-in Companion button presets

The module registers ~289 actions and 7 feedbacks but defines no built-in Companion button presets via `setPresetDefinitions()`. Providing a starter preset library (e.g., Load Preset, Set Default Tally Brightness, Connect/Disconnect) would significantly improve out-of-the-box UX for new users.

---

### NTH2 — Redundant double-store in increment/decrement action callbacks

**Files:** `src/actions/tally.js` (and other inc/dec actions)

`sendParam()` internally calls `storeParamValue()`. Several increment/decrement callbacks also call `storeParamValue()` directly after `sendParam()`, storing the same value twice. No behavioral impact, but the redundant calls are dead code.

```js
await self.sendParam(cameraId, 'tally_brightness', newValue)  // storeParamValue called here
self.storeParamValue('tally_brightness', newValue, cameraId)  // duplicate
```

---

### NTH3 (Info) — `runtime.apiVersion: "0.0.0"` in manifest

**File:** `companion/manifest.json:18`

`manifest.runtime.apiVersion` is set to `"0.0.0"`. For v1.x modules, `companion-module-build` patches this at package time. Build verified clean — `yarn package` produced `fiverecords-tallyccupro-3.1.0.tgz` without error. No action required; noted for awareness.

---

## 🔮 Next Release Suggestions

- Implement exponential back-off on TCP reconnect (see L1)
- Add built-in preset library for common camera control operations (see NTH1)
- Consider adding `eslint` and a lint script to `package.json` for ongoing code quality

---

## 🧪 Tests

**No tests found.** The module contains no test files (`*.test.js`, `*.spec.js`, or similar).

This is **non-blocking** for a first release — test infrastructure is not required, and many v1.x modules ship without tests. A future release should introduce at minimum unit tests for TCP message parsing (especially the `parseInt` NaN paths flagged in M3).

**Build result:** `yarn install` + `yarn package` — ✅ PASS (clean, no errors)

---

## ✅ What's Solid

- **Dual-channel architecture** — HTTP polling for status/presets plus TCP push for real-time camera state is well-suited to the TallyCCU Pro protocol and correctly implemented
- **v1.x API compliance** — `InstanceBase`, `runEntrypoint`, `InstanceStatus` all imported and used correctly; lifecycle (`init`, `configUpdated`, `destroy`) is complete and correct
- **Comprehensive action library** — ~289 action definitions across 10 category files covering lens, video, audio, output, display, tally, reference, color, PTZ, and presets; clean delegation via `actions/index.js`
- **7 well-designed feedbacks** — cover tally status, recording, connection state, and camera presets with clear visual styles
- **Variable system** — tracks all parameters for up to 8 cameras simultaneously; formatting helpers for arrays and numeric precision are clean
- **Security** — no hardcoded credentials; HTTP parameter values encoded with `encodeURIComponent()`; IP validation in config; connection timeouts (3 s HTTP, 5 s TCP) prevent hangs
- **First-release correctness** — `upgrades.js` returns empty array; no `isVisible` usage; no banned keywords in `manifest.keywords`; manifest version matches `package.json`
- **Socket cleanup** — `removeAllListeners()` before `destroy()` correctly prevents stale close events from re-triggering reconnect; `tcpReconnectTimer` cleared before scheduling prevents timer leak
- **Error handling** — HTTP errors classified and surfaced to Companion status (ECONNREFUSED, ETIMEDOUT, EHOSTUNREACH); TCP errors logged with appropriate severity
