# Review — videowalrus-simpleclock v1.4.2

| | |
|---|---|
| **Module** | videowalrus-simpleclock |
| **Version** | v1.4.2 |
| **Scope** | `tag` (first release — no previous tag, so fell back to a full `src/` review; all findings are NEW) |
| **Language / API** | JS / @companion-module/base ~1.14.1 (v1.x) |
| **Protocol** | WebSocket (`ws`) |
| **Reviewed** | 2026-07-01 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 3 | 0 | 3 |
| 🟢 Low | 4 | 0 | 4 |
| 💡 Nice to Have | 1 | 0 | 1 |

## Verdict: Approved

## 📋 Issues

**Blocking**
- [ ] [C1: manifest id does not match name](#c1-manifest-id-does-not-match-name)
- [ ] [H1: closeWebSocket crashes the module when tearing down a still-connecting socket](#h1-closewebsocket-crashes-the-module-when-tearing-down-a-still-connecting-socket)

**Non-blocking**
- [ ] [M1: No connection timeout — instance can hang in Connecting](#m1-no-connection-timeout-instance-can-hang-in-connecting)
- [ ] [M2: Fixed 5s reconnect with no backoff](#m2-fixed-5s-reconnect-with-no-backoff)
- [ ] [M3: Non-numeric speed from server throws in updateVariables and aborts the update](#m3-non-numeric-speed-from-server-throws-in-updatevariables-and-aborts-the-update)
- [ ] [L1: ConnectionFailure status is immediately overwritten by Disconnected](#l1-connectionfailure-status-is-immediately-overwritten-by-disconnected)
- [ ] [L2: sendCommand silently drops commands when disconnected](#l2-sendcommand-silently-drops-commands-when-disconnected)
- [ ] [L3: configUpdated unconditionally tears down and reconnects](#l3-configupdated-unconditionally-tears-down-and-reconnects)
- [ ] [L4: Speed +5% / -5% presets set absolute values, not relative increments](#l4-speed-5-5-presets-set-absolute-values-not-relative-increments)
- [ ] [N1: Config panel has no descriptive help field](#n1-config-panel-has-no-descriptive-help-field)

---

## 🟡 Medium

### M1: No connection timeout — instance can hang in Connecting

**File:** `src/main.js:80-83`
**Classification:** 🆕 NEW

After `updateStatus(Connecting)` and `new WebSocket(url)`, if the peer accepts the TCP connection but never completes the WS handshake (or the host blackholes packets), neither `'open'` nor `'error'` fires promptly and the instance can sit in `Connecting` for the OS-level TCP timeout.

**Suggested fix (maintainer):** Start a `setTimeout` (≈5–10s) when opening; if the socket is not `OPEN` when it fires, call `ws.terminate()` to force the `'close'`→reconnect path. Store and clear it alongside `reconnectTimer` in `closeWebSocket()`.

### M2: Fixed 5s reconnect with no backoff

**File:** `src/main.js:138-144`
**Classification:** 🆕 NEW

`scheduleReconnect()` always retries after exactly 5000ms, so a long-down host is polled forever at a fixed cadence.

**Suggested fix (maintainer):** Apply capped exponential backoff (e.g. 1s → 2s → 4s … capped ~30s), resetting the delay on a successful `'open'`.

### M3: Non-numeric speed from server throws in updateVariables and aborts the update

**File:** `src/main.js:176`
**Classification:** 🆕 NEW

```js
speed: s.speed != null ? s.speed.toFixed(2) : '1.00',
```

`s.speed` comes straight from the merged server state (`this.state = { ...this.state, ...msg.state }`, `main.js:96`). If the server ever sends `speed` as a string (or any non-number), `s.speed.toFixed` is `undefined` and throws a `TypeError`. That throw is caught by the message handler's `try` (`main.js:91-115`) and logged as the misleading `"Failed to parse message"`, so `setVariableValues()` never runs — **all** variables for that message silently fail to update, while feedbacks (already run at line 97) have updated, leaving state inconsistent.

**Suggested fix (maintainer):** Coerce defensively, e.g. `const spd = Number(s.speed); ... Number.isFinite(spd) ? spd.toFixed(2) : '1.00'`. Apply the same guarding to other numeric server fields before stringifying.

---

## 🟢 Low

### L1: ConnectionFailure status is immediately overwritten by Disconnected

**File:** `src/main.js:123-127`
**Classification:** 🆕 NEW

The `'error'` handler sets `InstanceStatus.ConnectionFailure` then calls `this.ws.close()`, which fires the `'close'` handler that immediately sets `InstanceStatus.Disconnected`. Operators therefore never see the more informative "connection failure" state.

**Suggested fix (maintainer):** Don't overwrite `ConnectionFailure` with `Disconnected` when the close was error-triggered, or let the socket close naturally without calling `close()` from the error handler.

### L2: sendCommand silently drops commands when disconnected

**File:** `src/main.js:158-164`
**Classification:** 🆕 NEW

When an action fires while disconnected, `sendCommand` logs a `warn` and returns; the command is lost with no button-level feedback. Acceptable per convention because `InstanceStatus` already reflects the disconnected state — noted for awareness, no change strictly required.

### L3: configUpdated unconditionally tears down and reconnects

**File:** `src/main.js:67-70`
**Classification:** 🆕 NEW

`configUpdated` always calls `initWebSocket()`. Today the only config fields are host/port so this is harmless, but if config grows, every save will drop and reconnect the socket.

**Suggested fix (maintainer):** Compare old vs. new host/port and only reconnect when they change.

### L4: Speed +5% / -5% presets set absolute values, not relative increments

**File:** `src/presets.js` (`speed-plus-5` / `speed-minus-5`)
**Classification:** 🆕 NEW

`speed-plus-5` always sends `set-speed` with `speed: 1.05` and `speed-minus-5` sends `0.95`, regardless of current speed. The "+5%" labels imply a relative nudge that accumulates on repeated presses, but presses do not stack (both are absolute setpoints).

**Suggested fix (maintainer):** Rename to e.g. "Speed 105%" / "Speed 95%", or add a relative `adjustSpeed` command (if the SimpleClock protocol supports it) and drive these presets from it.

---

## 💡 Nice to Have

### N1: Config panel has no descriptive help field

**File:** `src/main.js:46-65`
**Classification:** 🆕 NEW

`getConfigFields()` returns only `host` and `port`. A short `static-text` intro (what the module controls, the expected/default SimpleClock WebSocket port) would improve first-run UX. Purely additive.

---

*No test framework, test files, or `test` script are present. For a module of this size this is acceptable and non-blocking.*
