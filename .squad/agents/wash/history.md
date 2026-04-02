📌 Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-04-01: RTW TouchMonitor Review

**Module:** `companion-module-rtw-touchmonitor` v1.0.1
**Protocol:** OSC (UDP) via Companion base class `oscSend()`
**Key Files:**
- `src/main.ts` - Main module class, connection lifecycle, OSC send queue
- `src/api.ts` - OSC path definitions for RTW device commands
- `src/actions.ts` - Action definitions with OSC message construction
- `src/utils.ts` - OSC argument type validation helpers
- `src/status.ts` - StatusManager utility with throttling
- `src/config.ts` - Module configuration (host, port, verbose)

**Architecture Pattern:**
- Uses Companion SDK's built-in `oscSend()` method (no direct socket management)
- `p-queue` for message queueing (concurrency: 1, rate limit: 1 msg per 10ms)
- StatusManager utility with throttled status updates (2s throttle)
- No incoming OSC messages (transmit-only module)

**Protocol Implementation:**
- No direct socket creation - delegates to Companion SDK
- SDK handles UDP socket lifecycle internally
- Module provides host/port config, SDK creates/manages socket
- No socket cleanup needed in `destroy()` since module doesn't own sockets

**OSC Message Handling:**
- Defensive type checking via `assertOSCMetaArgument()` in utils.ts
- Proper OSC type tags: 'i' (int), 'f' (float), 's' (string), 'b' (blob)
- Validates type/value pairs before sending

**Status Transitions:**
- Initializing → Ok (when host configured)
- Initializing → BadConfig (when no host)
- Destroyed → Disconnected (in StatusManager.destroy())
- No network error transitions (transmit-only, no feedback)

**Findings:**
- Clean pattern for OSC transmit-only modules
- No socket leaks possible (SDK owns lifecycle)
- No error handling on `oscSend()` - SDK method doesn't return Promise/throw
- Queue is cleared in `destroy()` - prevents orphaned messages

**Session Closed:** 2026-04-01T21:43:37Z
**Verdict:** APPROVED WITH NOTES
Orchestration log: `.squad/orchestration-log/2026-04-01T21:43:37Z-wash.md`
Session log: `.squad/log/2026-04-01T21:43:37Z-rtw-touchmonitor-review.md`
4 notes issued for future release (oscSend error handling, no retry logic, status transitions, swallowed init error)

### 2026-04-02: Generic SNMP Review (v3.0.0)

**Module:** `companion-module-generic-snmp` v3.0.0
**Protocol:** SNMP over UDP (`net-snmp` library, `SharedUdpSocket` for trap listener)
**Key Files:**
- `src/index.ts` — Main module class, session lifecycle, socket lifecycle, queue, polling, walk
- `src/wrapper.ts` — `SharedUDPSocketWrapper` — wraps Companion's SharedUdpSocket to look like a dgram.Socket for net-snmp; filters messages by source IP
- `src/oidtracker.ts` — `FeedbackOidTracker` — bidirectional map of OIDs ↔ feedback IDs, poll group management
- `src/status.ts` — `StatusManager` — throttled status updater
- `src/upgrades.ts` — Upgrade scripts pre-200 through v300

**Architecture Pattern:**
- Companion `createSharedUdpSocket()` for trap listener — shared OS socket across instances
- `SharedUDPSocketWrapper` provides dgram-like interface to net-snmp `createReceiver()`; filters by source IP in software
- `p-queue` with `concurrency: 1, interval: 10, intervalCap: 1` for all SNMP operations (get/set/walk/trap/inform)
- Polling via `setTimeout` chain — self-throttles (only reschedules after previous poll completes)
- Fire-and-forget OID walks on init (queued in snmpQueue, not awaited)
- Priority levels in queue: inform=2, trap=3, set=1, get/walk=0

**Known Bugs Found:**
1. `disconnectAgent()` does not null `this.session` — closed session stays reachable; bad-config early returns leave stale closed session pointer
2. `setAgentAddress()` missing `return` after error-path `resolve()` — `this.agentAddress` overwritten with `undefined` on DNS failure
3. `listeningSocket.bind(port, config.ip)` — uses remote agent IP as local bind address (semantically wrong; filtering is correct in software via wrapper)
4. No persistent 'error' handler on `listeningSocket` after 'listening' fires
5. `InstanceStatus` never transitions to Error/ConnectionFailure on SNMP operation failure

**Session Patterns:**
- `connectAgent()` always calls `disconnectAgent()` first (via close but no null)
- `configUpdated()` clears queue, closes listener, then calls `initializeConnection()` → `connectAgent()`
- `destroy()` calls `statusManager.destroy()` BEFORE `disconnectAgent()` — status guard prevents double-update crash
- `closeListener()` safely handles uninitialized `listeningSocket`/`socketWrapper` via `if` checks

**Status Transitions in this module:**
- Connecting (init) → BadConfig (invalid config fields) → Ok (session created) — no Error transition exists
- destroy() → Disconnected (via statusManager.destroy())

**Session Closed:** 2026-04-02T00:37:03Z
**Verdict:** APPROVED WITH NOTES
Review file: `companion-module-generic-snmp/review-2026-04-02-003703.md`
Findings: `.squad/decisions/inbox/wash-snmp-review-findings.md`
2 High, 3 Medium, 3 Low, 2 Nice-to-Have issued

### 2026-04-02: Generic SNMP Re-Review (v3.0.0 + post-tag commits)

**Module:** `companion-module-generic-snmp` (HEAD 119f854)
**Review type:** Re-review following new process rules (yarn install first)
**Findings written to:** `.squad/decisions/inbox/wash-review-findings.md`

**What changed since v3.0.0 tag:**
- Logger (`createModuleLogger`) now injected into `SharedUDPSocketWrapper` — positive
- 34 new unit tests for `wrapper.ts` added and passing (329 total, all pass)
- Dependency bumps only (picomatch, flatted, tar)

**Bugs still unresolved from prior review:**
- H1: `setAgentAddress()` missing `return` after error-path `resolve()` — agentAddress becomes `undefined` on DNS failure
- M1: `disconnectAgent()` does not null `this.session` after close
- M2: No persistent `'error'` handler on `listeningSocket` post-bind
- L1: `listeningSocket.bind(portBind, config.ip)` uses remote agent IP as local bind address
- L2: InstanceStatus never transitions to Error on SNMP operation failure

**New note:**
- `createModuleLogger('UDP Socket Wrapper')` is not instance-scoped — in multi-instance setups, wrapper logs won't carry the instance ID/label prefix

**Session Closed:** 2026-04-02T01:42:24Z
**Verdict:** APPROVED WITH NOTES

### 2026-04-02: FiveRecords TallyCCU Pro Review (v3.0.2)

**Module:** `companion-module-fiverecords-tallyccupro` v3.0.2
**Protocol:** TCP (net) for push notifications + HTTP (axios) for control
**Review Type:** First release — all code is new, all findings can block
**Key Files:**
- `main.js` — Module class, initialization, destroy() lifecycle
- `tcp.js` — TCP socket management, message parsing, reconnect, ping keepalive
- `connection.js` — HTTP connection monitoring via axios, preset loading
- `params.js` — HTTP parameter sending via axios
- `actions.js` — Action definitions (camera control)
- `variables.js` — Variable definitions for Companion

**Architecture Pattern:**
- Dual-protocol design: HTTP for commands + connection monitoring, TCP for push sync
- TCP connection to port 8098 for real-time camera parameter updates from TallyCCU Pro
- HTTP GET requests to `http://{host}/?cameraId={id}&{param}={value}` for control
- HTTP GET to `http://{host}/?listPresets` for connection verification and preset discovery
- TCP message format: newline-delimited text protocol (`CCU {camId} {param} {value}`, `PRESET {camId} {presetId} {name}`, etc.)
- TCP ping keepalive every 30s (`PING\r\n`)
- HTTP polling every 120s for connection status
- Automatic TCP reconnect on disconnect (5s fixed interval, no backoff)

**Connection Lifecycle:**
- `init()` → `startConnectionMonitor()` (HTTP polling) + `startTcpConnection()` (TCP push)
- `configUpdated()` → stops/restarts both if IP changed
- `destroy()` → `stopConnectionMonitor()` + `stopTcpConnection()` — clears all timers, destroys socket
- TCP reconnect: `'close'` event → `scheduleTcpReconnect()` → 5s timer → `startTcpConnection()`

**TCP Socket Management:**
- `startTcpConnection()` defensively closes existing socket before creating new one (lines 17-23)
- Socket event handlers: 'connect', 'data', 'close', 'error', 'timeout'
- Connect timeout: 5s via `socket.setTimeout(5000)` before connect, cleared on 'connect'
- Buffer handling: accumulates data until `\r\n` or `\n`, splits into lines, processes each
- Cleanup: `removeAllListeners()` + `destroy()` + null reference in `stopTcpConnection()`

**Critical Bugs Found (Blocking):**
1. **C1:** Unhandled promise rejection in `connection.js:102` — initial connection check `.then()` without `.catch()`
2. **C2:** TCP 'error' handler does not remove listeners or destroy socket — causes listener accumulation on repeated failures

**High Priority Bugs:**
1. **H1:** TCP socket destroy not wrapped in try/finally — edge case where exception could leave socket non-null
2. **H2:** TCP `write()` calls lack error handling — inline exceptions possible if socket closes mid-write

**Medium Priority:**
1. **M1:** TCP reconnect has no exponential backoff — fixed 5s interval indefinitely
2. **M2:** HTTP connection monitor creates new interval with unhandled promise after max retries (line 118)
3. **M3:** `InstanceStatus` not updated on TCP state changes — users can't see TCP disconnect until next HTTP poll

**Low Priority:**
1. **L2:** TCP buffer has no size limit — unbounded growth possible with malformed messages
2. **L3:** No validation of parsed TCP message fields — `parseInt()` can return `NaN`, used as cameraId
3. **L4:** `sendCachedState()` sends 400+ messages in tight loop without backpressure handling

**Positive Patterns:**
- Proper cleanup in `destroy()` — clears all timers, removes listeners, destroys sockets
- Defensive socket restart — closes existing before creating new
- All axios calls have `timeout: 3000` and try/catch error handling
- TCP message framing handles partial messages correctly (newline-delimited)
- Ping keepalive for long-lived TCP connections

**Learnings:**
- **Fire-and-forget Promises in init:** Always add `.catch()` to promises in initialization paths — uncaught rejections can crash or warn
- **TCP error vs close:** Error events don't always trigger close events immediately — must clean up listeners in error handler OR force destroy()
- **Dual-protocol modules:** When using both HTTP and TCP, decide which is authoritative for status and ensure status updates reflect both
- **TCP backpressure:** Bulk writes should check `write()` return value and wait for 'drain' event
- **Message parsing validation:** Always validate parsed numeric fields (check `isNaN()`, range) before using as keys or IDs

**Session Closed:** 2026-04-02
**Verdict:** REJECTED — 2 critical blocking issues (C1, C2) must be fixed before release
**Findings File:** `.squad/decisions/inbox/wash-review-findings.md`
