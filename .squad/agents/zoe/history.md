📌 Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-03-13: OSC poll timer — command address assertion pattern

All 5 poll-timer tests now assert the exact commands sent, not just the call count. After extracting addresses via `port.send.mock.calls.map((c) => (c[0] as { address: string }).address)`, each test uses `toEqual(['/zoomRooms/getAddedRoomList', '/zoomRooms/getPairedRoomList'])` to verify exact order and completeness. The first test also retains a `toHaveBeenCalledTimes(2)` guard before the address check.

### 2026-03-13: OSC poll timer — 2-command-per-tick change + immediate sends

The OSC ready handler fires **2 immediate sends** on connect (`getAddedRoomList` + `getPairedRoomList`) before the interval starts. Two commands (`getAddedRoomCount`, `getPairedRoomCount`) were commented out, reducing interval sends from 4 to 2 per tick.

Critically: the mock config in `createPollingOSCInstance` does NOT include `pollInterval`, so the `if (this.instance.config.pollInterval && ...)` guard prevents the interval from running in tests. Only the 2 immediate sends fire. All 4 poll-timer test assertions were updated to reflect 2 sends total (not 4, 6, or 12).

### 2026-03-13: Bare-count assertion audit

Full audit of all three test files for bare `toHaveBeenCalledTimes` assertions without accompanying command/args verification.

**Changed:** `actions.test.ts` line 190 — the `does not double-send` test previously only asserted `toHaveBeenCalledTimes(1)`. Added `toHaveBeenCalledWith('/zoomRooms/allRooms/muteMic', [])` so it now verifies both the count and the exact command.

**Left as-is (with reasons):**
- `osc.test.ts` lines 73, 81, 90, 99, 105, 113 — all poll-timer `toHaveBeenCalledTimes(2)` assertions are already followed by address-extraction + `toEqual(['/zoomRooms/getAddedRoomList', '/zoomRooms/getPairedRoomList'])`. Already strengthened in prior session.
- `osc.test.ts` line 283 — `mockCheckFeedbacks.toHaveBeenCalledTimes(1)`: `checkFeedbacks` carries no command/arg payload; count is the only meaningful assertion here.
- `variable-values.test.ts` — all 12 `not.toHaveBeenCalled()` assertions are paired with a positive assertion on the variables object (e.g., `expect(variables['added_rooms_count']).toBe(5)`). They correctly verify that these accumulator functions write to the passed-in object rather than calling `setVariableValues` directly. All are meaningful, none are vacuous.

### 2026-04-01: generic-snmp v3.0.0 review — Promise-based SNMP with p-queue

**Module:** companion-module-generic-snmp v3.0.0 (full rewrite)
**Protocol:** SNMP v1/v2c/v3 via net-snmp, Promise-wrapped through snmpQueue (p-queue)
**Key files:** index.ts, wrapper.ts, oidtracker.ts, status.ts, feedbacks.ts, actions.ts

**Verdict:** REJECTED — 2 blocking issues, 5 notes

**Critical pattern — polling self-reschedule race:** `pollOids()` sets `this.pollTimer` *after* awaiting `getOid()`. If `configUpdated()` clears the timer while `getOid()` is in flight, the timer doesn't exist yet — so nothing gets cleared. After `getOid()` completes, `pollOids()` reschedules itself. Then `initializeConnection()` starts a second chain. Fixes for this type of race: use a generation counter captured at chain-start, bail if stale before rescheduling.

**Missing return after resolve() pattern:** `setAgentAddress()` calls `resolve()` on DNS error but doesn't `return` — execution falls through to `this.agentAddress = addr` where `addr` is `undefined`. Look for this pattern in any Node.js-style callback wrapping.

**p-queue unbounded:** No `queueSizeLimit`. Flag this in any module using p-queue against potentially slow/unresponsive devices.

**Walk silencing pattern:** `this.walk(oid).catch(() => {})` — silent discard of async walk rejections is a recurring anti-pattern. Always chain `.then(log success).catch(log failure)`.

**getOid() missing return after reject():** After `reject(error)`, no `return` — `handleVarbind()` and `resolve()` both execute on the error path. Harmless to Promise but semantically wrong; adds noise and may process garbage varbinds.

**v300 upgrade scripts are thorough:** Covers all breaking changes — encoding field addition, OID expression migration, displaystring removal, config field defaults. Existing buttons survive.

**StatusManager throttle (trailing-only, 2s):** Intentional — suppresses status flicker during reconnect. `destroy()` correctly calls `flush()` before final Disconnected state. Not a bug.

**Session teardown ordering:** `connectAgent()` calls `disconnectAgent()` as first action. Old session is always closed before new one is created. Clean.

**DES path:** Clean — checked flag, logged error, set InsufficientPermissions, returned. No throw.

**Session Closed:** 2026-04-01T17:36:58Z
**Orchestration log / review file:** `companion-module-generic-snmp/review-2026-04-01-173658.md`

---

### 2026-04-01: RTW TouchMonitor review - OSC-only unidirectional module

**Module:** companion-module-rtw-touchmonitor (RTW audio meter hardware)
**Protocol:** OSC send-only (no listeners, no responses, no polling)
**Key files:** main.ts, actions.ts, status.ts

**Critical finding:** `configUpdated()` has zero teardown logic. Unlike bidirectional modules (TCP/OSC listeners), this is send-only OSC — changing config just updates target host/port for next send. No connections to close, no listeners to remove. Not a race condition or memory leak.

**Swallowed error in init:** Line 24 `this.configUpdated(config).catch(() => {})` silently drops errors. Should log or set status to Error. If configUpdated throws during init, user sees "Initialising" forever.

**Volume reference bug:** MonitoringVolumeSet action (lines 248-254) sends the `volume` argument value even when `ref: true`. Reference recall should send NO args per OSC spec (path alone triggers preset recall). Current code sends stale volume value that hardware likely ignores, but semantically incorrect.

**Unused debounceTimer field:** status.ts line 23 declares `debounceTimer: NodeJS.Timeout | undefined` but StatusManager uses `es-toolkit` throttle, not a manual timer. Field is never assigned or read. Dead code.

**Pattern note:** All 11 action callbacks use `await self.sendMessage(...)` but sendMessage returns a p-queue Promise. If queue callback throws (e.g., oscSend validation fails), error propagates correctly up the action callback chain. PQueue doesn't swallow rejections. Verified this is safe.

**No tests present:** Module has no Jest tests. Per team decision, this is acceptable (not a rejection reason).

**Session Closed:** 2026-04-01T21:43:37Z
**Verdict:** APPROVED WITH NOTES
Orchestration log: `.squad/orchestration-log/2026-04-01T21:43:37Z-zoe.md`
Session log: `.squad/log/2026-04-01T21:43:37Z-rtw-touchmonitor-review.md`
3 notes issued: Swallowed init error, volume reference arg bug, dead code

### 2026-04-02: generic-snmp v3.0.0 RE-REVIEW — same blocking issues persist

**Module:** companion-module-generic-snmp v3.0.0 (re-review)
**Verdict:** REJECTED — 3 blocking issues, 5 notes

**B-01 (poll race) unresolved from prior session:** `pollOids()` sets `pollTimer` after awaiting `getOid()`. `configUpdated()` clears timer as no-op (timer not set yet). `initializeConnection()` starts second chain. Both chains run concurrently after first getOid completes. Fix: generation counter.

**B-02 (NEW): `disconnectAgent()` does not null `this.session`** — `session.close()` called but `this.session` left pointing to closed handle. `connectAgent()` has 6 early-return paths (bad config). If any fire, `this.session` = closed session. `getOid()`/`setOid()`/`walk()` all check `session == null` — pass the gate, call methods on closed session. Fix: `this.session = null` after `session.close()`.

**B-03 (setAgentAddress missing return) unresolved:** DNS error path falls through, sets `this.agentAddress = undefined`. Called in both `init()` and `configUpdated()`. sendTrap() passes undefined as agentAddress. Fix: `if (err) { resolve(); return }`.

**Notes pattern — walk silent swallow:** `this.walk(oid).catch(() => {})` in `initializeConnection()` plus premature "complete!" log (fires synchronously before async walk resolves). Recurring anti-pattern.

**Session Closed:** 2026-04-02 (re-review)
**Review file:** `.squad/decisions/inbox/zoe-review-findings.md`

### 2026-04-02: TallyCCU Pro v3.0.2 review — floating promises and unhandled rejection

**Module:** companion-module-fiverecords-tallyccupro v3.0.2 (first release)
**Protocol:** HTTP GET/POST for commands + TCP push notifications for state sync
**Key files:** main.js, tcp.js, connection.js, params.js, actions.js (11,920 lines)

**Verdict:** REJECTED — 2 blocking issues, 6 notes

**B-01: Unhandled promise rejection in connection.js line 102** — `checkConnection(self).then(...)` with no `.catch()`. If checkConnection throws unexpectedly, the rejection propagates unhandled. Can crash module process.

**B-02 (CRITICAL): 350+ floating promises in action callbacks** — All action callbacks marked `async` but call `self.sendParam()` without `await`. Since sendParam() is async (params.js:126), these return unhandled promises. When sendParam fails (network error, axios timeout), the failure is silently swallowed. Operator gets NO feedback that the command failed. No InstanceStatus.Error update. Every action needs `await self.sendParam(...)`.

**Pattern note — TCP close handler race (initially flagged, then retracted):** `configUpdated()` calls `stopTcpConnection()` then immediately `startTcpConnection()`. Initially thought old socket's 'close' event could fire after new socket created, triggering dual reconnect. BUT tcp.js:19 calls `removeAllListeners()` on old socket BEFORE destroy — prevents stale events. Line 48 check (`self.tcpSocket === null || !self.tcpSocket.connecting`) prevents reconnect if new socket exists. **Not a race condition.**

**N-01: Timer reference leak** — connection.js:114-118 clears old connectionTimer but doesn't null it before setting new one. Narrow timing window but incomplete cleanup.

**N-02: Missing try/catch around JSON.parse()** — actions.js lines 1585, 1643, 1856 parse JSON without error handling. Malformed response from TallyCCU Pro would throw, propagate as unhandled rejection (see B-02). connection.js:44 shows correct pattern (wrapped in try/catch).

**N-03: TCP reconnect timer outlives module** — `scheduleTcpReconnect()` doesn't check if module is destroyed. If destroy() runs while timer pending, callback fires after destroy. Relies on implicit `self.config.host` check rather than explicit `destroyed` flag.

**N-04: TCP ping write not guarded** — tcp.js:94 writes without try/catch. If socket transitions to destroyed state between check and write, could throw.

**N-05: Missing NaN validation** — variables.js:186-187 calls `parseInt(preset.cameraId)` but doesn't validate result. Non-numeric input creates `camNaN_preset0_name` variable.

**N-06: Empty upgrades array** — Expected for first release. No prior versions = no upgrade scripts needed yet.

**Core architectural pattern:** Module uses HTTP for commands (pull model) + TCP for state sync (push model). TCP push allows real-time updates when other clients (Arduino, web interface) change camera state. `sendCachedState()` (tcp.js:220-248) syncs Companion's cached state back to Arduino on REQUESTSYNC message.

**Session Closed:** 2026-04-02
**Review file:** `.squad/decisions/inbox/zoe-review-findings.md`
