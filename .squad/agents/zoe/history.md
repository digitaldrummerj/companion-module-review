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

### 2026-04-02: EasyWorship v2.1.0 review — major reliability improvements with one typo

**Module:** companion-module-softouch-easyworship v2.1.0 (upgrade from v2.0.2)
**Protocol:** TCP to EasyWorship presentation software, mDNS discovery via Bonjour
**Key files:** index.js (605 lines), actions.js (307 lines), config.js, feedbacks.js, variables.js

**Verdict:** REJECTED — 1 blocking issue (NEW)

**B-01 (NEW): Undefined method call in reconnect action** — `actions.js:247` calls `this.clearIdleTimer()` which doesn't exist. Will throw TypeError when user presses "Reconnect to EasyWorship" button. Should be removed (redundant with `clearRetry()` and `clearKeepalive()` already called).

**Critical reliability improvement — TCP receive buffer:** v2.0.2 had naive `data.toString().split('\r\n')` with no partial message handling. v2.1.0 adds proper `_receiveBuffer` accumulation (lines 493-508) with `MAX_BUFFER_SIZE = 1MB` DoS protection. Handles TCP stream fragmentation correctly — incomplete lines stay in buffer, complete lines get processed. Drops connection if buffer exceeds 1MB (prevents malicious server from memory-bombing the module).

**Reconnection logic rewrite — exponential backoff:** v2.0.2 used `setInterval` that ran even when connected. v2.1.0 uses `scheduleReconnect()` with exponential backoff (1s → 1.5s → 2.3s → 3.4s → 5s cap) via `setTimeout`. Only schedules next retry after previous attempt completes. Lines 343-375. Fixes reconnection storm where v2.0.2 would hammer the network every 5s regardless of connection state.

**Keepalive mechanism added:** v2.1.0 sends heartbeat every 30s when paired (lines 383-393). If send fails, TCP error handler triggers reconnect. v2.0.2 had no keepalive — relied on EW to send periodic status. Dead sockets could go undetected for minutes. New behavior detects dead sockets within 30s.

**Bonjour lifecycle leak fixed:** v2.0.2 created new `Bonjour()` instance on every `initBonjour()` call, never destroyed old ones. v2.1.0 uses single persistent instance with `if (this.bonjour) return` guard (line 269). Clean teardown in `stopDiscovery()` (lines 166-175). Prevents mDNS listener accumulation on repeated config saves.

**Forward-compatible protocol handling:** v2.1.0 adds `KNOWN_ACTIONS` set (line 29) + debug-level logging for unknown actions (line 534). Still sends heartbeat to keep connection alive even for unrecognized action types. If EW ships protocol update, module won't break.

**Display state isolation between servers:** `resetDisplayState()` (lines 140-164) clears logo/black/clear/livepreview state when switching servers. v2.0.2 had state bleed — Building A's button highlights would persist in Building B's session.

**sendCommand error handling pattern:** Returns `true/false` instead of throwing or calling `destroy()`. Display toggle actions (logo/black/clear) save previous state before optimistic update, revert if `sendCommand()` returns false (lines 89-93, 112-115, 127-129). Prevents button flicker and incorrect highlights when connection is down.

**Pairing request sanitization:** `config.ClientName` is sanitized via `.replace(/[\x00-\x1f]/g, '').slice(0, 64)` before sending to EW (lines 451, 43). v2.0.2 sent raw user input. Prevents control character injection into EW's pairing database.

**Action options cleanup:** v2.0.2 had dummy dropdown `[{ id: '0', label: 'Not used' }]` on every action. v2.1.0 uses `options: []` for actions with no parameters. Cleaner UI.

**Type validation on incoming messages:** Lines 516-520 validate `command.action` is a string before use (`const action = typeof command.action === 'string' ? command.action : null`). v2.0.2 directly accessed `command['action']` with no type guard.

**Note on structural issue (PRE-EXISTING):** Source files at module root, not in `src/`. Existed in v2.0.2, not introduced by this release. Per team decision, this is a structural violation but doesn't block approval (note only).

**Session Closed:** 2026-04-02
**Review file:** `.squad/decisions/inbox/zoe-review-findings.md`


**Orchestration Log:** `.squad/orchestration-log/2026-04-02T041821Z-zoe.md`
**Session Log:** `.squad/log/2026-04-02T041821Z-easyworship-review.md`

---

### 2025-01-03: GlenSound GTM Mobile v1.0.0 review — first release, UDP multicast protocol

**Module:** companion-module-glensound-gtmmobile v1.0.0 (first release)
**Protocol:** UDP command packets + multicast status subscriptions (GlenSound proprietary)
**Key files:** main.js (314 lines), actions.js (166 lines), feedbacks.js (91 lines), variables.js (17 lines)

**Verdict:** REJECTED — 3 blocking issues, 9 notes

**B-01: Channel volume array index mismatch** — `channelVolumes` declared as 14-element array (main.js:77) but volume parsing loop iterates `knob = 2; knob <= 14` (line 288), accessing index 14. Variable definitions loop `k = 2; k <= 14` (variables.js:7) but variable update loop uses `k = 1; k <= 13` (main.js:302). Inconsistent channel range (1-13 vs 2-14) across array init, parsing, variables, actions, and feedbacks. Channel 1 volume never populated but variable defined. Channel 14 may work by JS array expansion but is semantically out-of-bounds. Operators will see "unknown" for channel 1 and inconsistent behavior for channel 14.

**B-02: Floating promise rejection in sendCmd()** — `udpCmd.send()` callback logs errors but doesn't propagate to InstanceStatus (main.js:215-218). Actions (mute/unmute/volume) appear to succeed but silently fail when network unavailable or socket closed. No operator feedback.

**B-03: Race condition in configUpdated()** — `closeSockets()` calls `udpStatus.close()` (async) then immediately starts new socket on same multicast address/port (main.js:98-106). If old socket hasn't fully closed, new bind fails with EADDRINUSE. Module stuck in ConnectionFailure, requires restart.

**N-01: Inconsistent error handling in socket creation** — try/catch blocks around socket creation (lines 150-158, 161-190) don't catch errors in async callbacks (bind, addMembership). If `addMembership()` fails (line 172), error is caught but status socket already bound, leaving socket in inconsistent state. Resource leak on init failure paths.

**N-02: Mute toggle with null state** — `sendToggle()` defaults to unmute when `muteState === null` (line 222). Initial toggle before first status response always unmutes. Not intuitive — should request status first or log warning.

**N-03: Channel volume toggle unsafe on null** — actions.js:154-160 toggles to 100% when `channelVolumes[ch] === null`. First toggle always sets 100% regardless of actual device state. Could cause unexpected audio level changes.

**N-04: Missing error propagation in action callbacks** — All action callbacks marked `async` but never throw or return errors (actions.js:55-161). `sendCmd()` can fail silently (see B-02). Operators have no indication when actions fail. Companion can't provide visual feedback.

**N-05: Comment mismatch in volume formula** — Line 288 comment says "offset = knob + 61" but formula is `knob * 2 + 52` (line 28). For knob 2: `2 * 2 + 52 = 56`, not `2 + 61 = 63`. Formula verified correct, comment wrong.

**N-06: Channel 1 not controllable but listed in feedbacks** — feedbacks.js:52 lists "Channel 1 (stereo)" but actions.js CHANNEL_CHOICES starts at channel 2. Operators can set feedback for channel 1 but have no action to control it. Feedback will always show false/unknown. Either add channel 1 to actions or remove from feedbacks with comment explaining it's read-only.

**N-07: No validation of config.port type** — `parseInt(this.config?.port)` (line 213) works on numbers but is redundant. If port invalid (NaN), falls back to 41161 silently. Low impact (Companion validates via Regex.PORT).

**N-08: 500ms poll rate** — `setInterval(..., 500)` generates 2 packets/second even when idle (line 179). Comment justifies this for physical button latency. Acceptable for single device but worth documenting. Could be configurable (200-2000ms range).

**N-09: Inconsistent whitespace** — feedbacks.js:52-53 has excessive tab indentation before line 53. Cosmetic only.

**Strengths noted:**
- ✅ Proper multicast join with interface auto-detection + manual override fallback (lines 168-173)
- ✅ Connection timeout mechanism (5s) with recovery on next message (lines 226-233)
- ✅ Generation indices used to detect volume changes — only requests report when needed (lines 268-274)
- ✅ Filters status messages by port (41162) and source IP to avoid noise (lines 239-240)
- ✅ Clean packet building with proper buffer allocation and GS_MAGIC header verification
- ✅ Proper socket cleanup in destroy() and configUpdated() (both call closeSockets())
- ✅ Well-structured: separate files for actions/feedbacks/variables

**Critical pattern — generation-based change detection:** Device sends generation indices in Status packet (offsets 0x1a for mute, 0x1c for volume). Module tracks `lastGenMute` and `lastGenVolume`, only requesting detailed Report when generation changes. Avoids unnecessary 100-byte Report multicast when nothing changed. Good bandwidth optimization.

**UDP multicast design validated:** Command socket sends to device unicast, status socket joins multicast group to receive device broadcasts. Auto-detection of correct network interface via subnet mask calculation (lines 56-69) handles multi-NIC systems correctly. Fallback to undefined interface if auto-detect fails (relies on OS default routing).

**Session Closed:** 2025-01-03
**Requested by:** Justin James
**Review file:** `.squad/decisions/inbox/zoe-review-findings.md`
