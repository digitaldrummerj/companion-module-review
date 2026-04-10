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

### 2026-04-02: Softouch EasyWorship Review (v2.1.0)

**Module:** `companion-module-softouch-easyworship` v2.1.0 (previous: v2.0.2)
**Protocol:** TCP (custom JSON over newline-delimited text) + Bonjour/mDNS (service discovery via `bonjour-service`)
**Key Files:**
- `index.js` — Module class, TCP connection lifecycle, Bonjour discovery, message parsing, keepalive
- `actions.js` — Action definitions with display overlay toggles (logo/black/clear)
- `config.js` — Configuration with dynamic server dropdown populated from Bonjour discovery
- `feedbacks.js`, `variables.js`, `presets.js` — UI layer

**Architecture Pattern:**
- TCPHelper for connection management (Companion SDK abstraction over `net.Socket`)
- Bonjour/mDNS for automatic server discovery on local network (type: 'ezwremote', protocol: 'tcp')
- Dual connection modes: auto-connect to last known server + parallel discovery for address changes
- Persistent Bonjour instance (created once, lives until destroy)
- Exponential backoff reconnection (1s → 5s with 1.5x multiplier, capped at 5s)
- Keepalive heartbeats every 30s to detect dead sockets
- Newline-delimited JSON protocol (`\r\n` terminated messages)
- Pairing flow: `connect` action with UUID → `paired`/`notPaired` response → operational or waiting for user approval
- Optimistic UI updates with revert-on-send-failure pattern

**Connection Lifecycle:**
- `init()` → tries last known server immediately (fast path) + `startDiscovery()` in parallel
- `startDiscovery()` creates ONE persistent Bonjour instance, browser.find() for 'ezwremote' services
- Bonjour 'up' event → auto-connect to matching server (or first discovered if none configured)
- `connectTCP()` → creates TCPHelper, sends pairing request on 'connect'
- `paired` response → starts keepalive interval, sets status 'ok', connected=true
- `notPaired` response → status 'unknown_error', user must approve pairing on EW machine
- 'close' or 'error' → `scheduleReconnect()` with exponential backoff
- `destroy()` → `clearRetry()` + `clearKeepalive()` + `destroySocket()` + `stopDiscovery()`

**TCP Socket Management:**
- `connectTCP()` always calls `clearRetry()`, `clearKeepalive()`, `destroySocket()` before creating new socket
- `destroySocket()` nulls socket, clears flags, clears buffer, updates variables/feedbacks
- Error handler does NOT destroy socket — TCPHelper emits 'close' after 'error' (guaranteed by SDK)
- All `socket.send()` calls have `.catch(err => log)` — no unhandled rejections
- Checks `this.socket?.isConnected` before send — safe if null

**Bonjour/mDNS:**
- `this.bonjour` instance lives on module instance (not local variable) — properly cleaned up in `stopDiscovery()`
- Guard in `startDiscovery()`: `if (this.bonjour) return` — won't create multiple instances
- Browser events: 'up' (discovered server), 'down' (server disappeared), 'error' (discovery failure)
- 'down' event for selected server → `destroySocket()` + `scheduleReconnect()` (don't wait for TCP timeout)
- Server list (`this.ezw` array) updated on 'up'/'down', triggers `updateConfigFields()` to refresh UI dropdown

**Message Parsing:**
- Receive buffer accumulates incoming data, splits on `\r\n`, processes complete lines
- Buffer overflow protection: 1MB limit, drops connection on overflow (DoS defense)
- JSON.parse with try/catch — logs parse errors, continues processing other lines
- Validates `action` field is a string before using
- Handles unknown actions gracefully: logs at debug (not warn), sends heartbeat, continues (forward-compatible)
- Tracks `requestrev` from server (sequence number), echoes in all heartbeats
- `requestrev` type coercion: accepts string or number, converts to string (EW sends both)

**Keepalive Heartbeats:**
- Starts on successful pairing, clears on disconnect/unpair/error
- 30s interval (appropriate for idle connection detection)
- Sends `{ action: 'heartbeat', requestrev: this.requestrev }`
- Guards with `if (this.connected && this.paired)` — won't spam when unpaired

**Reconnection Logic:**
- Exponential backoff: 1s → 1.5s → 2.3s → 3.4s → 5s (capped), formula: `min(1000 * 1.5^attempts, 5000)`
- Verbose logging: every attempt for first 5, then every 20th attempt
- Clears retry counter on successful pairing
- `scheduleReconnect()` is idempotent — early returns if `retryTimeout` already set
- Always calls `startDiscovery()` in retry (ensures discovery is running, won't restart if already up)
- Only calls `connectTCP()` if address/port are known (waits for discovery otherwise)

**Key Improvements from v2.0.2:**
1. ✅ **REGRESSION FIX:** Bonjour instance now on `this` and properly destroyed. v2.0.2 had local `bonjour` variable leaked — unreachable in `destroy()`.
2. ✅ Exponential backoff reconnection (was fixed-interval setInterval in v2.0.2)
3. ✅ Keepalive heartbeats (new — detects dead sockets on idle connections)
4. ✅ Receive buffer overflow protection (new — was unbounded in v2.0.2)
5. ✅ Defensive message parsing (validates action field type, handles unknown actions)
6. ✅ Centralized cleanup methods (`destroySocket()`, `stopDiscovery()`, `clearRetry()`, `clearKeepalive()`)
7. ✅ Bonjour 'down' event handling improved (was calling `initTCP()` directly without backoff in v2.0.2)

**Learnings:**
- **Bonjour instance scoping:** Must live on `this.bonjour`, NOT as a local variable in an init function. Local variables are unreachable in `destroy()` and leak. v2.0.2 had `const bonjour = new Bonjour()` in `initBonjour()`, then referenced undefined `bonjour` in `destroy()`.
- **Bonjour persistence:** Create ONE Bonjour instance and let it run for the module's lifetime. Don't cycle or restart it — mDNS requires stable listeners to receive multicast responses. Guard with `if (this.bonjour) return` in `startDiscovery()`.
- **TCPHelper event sequence:** Companion's TCPHelper emits 'close' after 'error' (guaranteed). Don't destroy socket in error handler or you'll double-destroy when 'close' fires. Only update state in error handler, let close handler do cleanup.
- **Receive buffer overflow defense:** Always enforce a limit on unbounded buffer accumulation (this module: 1MB). Drop connection and reconnect on overflow — correct DoS mitigation.
- **Keepalive pattern for idle connections:** Send periodic heartbeats to detect dead sockets that don't emit 'close' events (network changes, OS bugs). 30s interval is appropriate for this protocol.
- **Reconnect backoff:** Exponential backoff with a cap (this module: 1s → 5s, 1.5x multiplier) prevents retry stampedes on persistent failures.
- **Forward-compatible message parsing:** Handle unknown action types with debug log + heartbeat response, don't crash or disconnect. EW may add new action types in future versions.
- **Optimistic UI updates:** For responsive button feedback, update local state immediately, then revert if send fails. See `buildStatusPayload()` in actions.js — EW requires full state, not just changed fields.

**Findings Written To:** `.squad/decisions/inbox/wash-review-findings.md`

**Session Closed:** 2026-04-02
**Verdict:** ✅ APPROVED — significant improvements to connection reliability and resource cleanup. No blocking issues. 4 notes for next release (connection timeout, requestrev validation, status transition logging, Bonjour restart guard — latter withdrawn on review).

**Release Tag:** v2.1.0
**Comparison Baseline:** v2.0.2
**Build Status:** ✅ `yarn release` succeeded — package created: `softouch-easyworship-2.1.0.tgz`

**Orchestration Log:** `.squad/orchestration-log/2026-04-02T041821Z-wash.md`
**Session Log:** `.squad/log/2026-04-02T041821Z-easyworship-review.md`

### 2026-04-02: GlenSound GTM Mobile Review (v1.0.0)

**Module:** `companion-module-glensound-gtmmobile` v1.0.0
**Protocol:** UDP (dgram) — direct socket management, multicast receive + unicast send
**Review Type:** First release — all code is new
**Key Files:**
- `main.js` — Module class, UDP lifecycle, multicast join, message parsing, timeout detection, polling
- `actions.js` — Action definitions with mute/unmute and mixer channel volume control
- `feedbacks.js` — Feedback definitions for mute state and channel volume
- `variables.js` — Variable definitions for Companion

**Architecture Pattern:**
- Dual UDP socket design: one for command send (unicast), one for status receive (multicast)
- Command socket (`udpCmd`) — ephemeral port, unicast to device IP on port 41161
- Status socket (`udpStatus`) — bound to multicast group 239.254.50.123:6111, receives device broadcasts
- Multicast membership with auto-detected local interface via subnet matching (fallback to no interface hint)
- Polling: GetStatus every 500ms to reflect physical button presses on device
- Timeout detection: 5s without Status message → ConnectionFailure
- Generation counters in Status packet trigger volume Report requests (on-demand polling)

**Connection Lifecycle:**
- `init()` → `start()` — creates both sockets, joins multicast, starts poll timer
- `configUpdated()` → `closeSockets()` → `start()` — full reconnect on config change
- `destroy()` → `closeSockets()` — cleans up both sockets, timers, multicast membership

**UDP Socket Management:**
- `udpCmd` created with `dgram.createSocket('udp4')`, bound to ephemeral port (0)
- `udpStatus` created with `{ type: 'udp4', reuseAddr: true }` (required for multicast)
- Error handlers registered immediately after socket creation (lines 152, 163)
- `closeSockets()` properly cleans up:
  - Clears `pollTimer` and `noResponseTimer`
  - Wraps `udpCmd.close()` in try/catch, nulls socket
  - Calls `dropMembership()` before `udpStatus.close()`, wraps in try/catch, nulls socket
- No socket recreation in error handlers — errors logged, status updated, sockets left for manual reconnect

**Multicast:**
- `bind(STATUS_MULTICAST_PORT, STATUS_MULTICAST_GROUP)` before `addMembership()` — CORRECT order (bind first, then join)
- Auto-detection: `findInterfaceForDevice()` scans local network interfaces, subnet matches device IP (lines 56-69)
- Falls back to no interface hint if auto-detection fails — may work on single-NIC systems, logs warning for multi-NIC
- `dropMembership()` always called in `closeSockets()` regardless of whether `addMembership()` succeeded (caught)

**Message Parsing:**
- Defensive validation: magic byte check, source IP filter, source port filter (lines 239-242)
- Length checks before buffer access (lines 241, 255, 268, 279, 289)
- Opcode dispatch: 1=Status, 10=Report (lines 247-251)
- Bounds checks in volume report parsing: `if (offset >= msg.length) continue` (line 289)

**Timeout Detection:**
- `resetTimeout()` called on every valid Status message (line 243)
- 5s timer → `log('warn', ...)` + `updateStatus(ConnectionFailure)` + variables reset to 'unknown'
- No automatic reconnection — status visible to user, manual intervention required

**Polling Logic:**
- `setInterval(() => this.sendCmd(PKT_GET_STATUS), 500)` starts after successful multicast join (line 179)
- 500ms interval balances responsiveness (physical button presses) with network load
- Cleared in `closeSockets()` to prevent orphaned timers
- Generation counter optimization (lines 268-275): only request volume Report when generation changes in Status packet

**InstanceStatus Transitions:**
- Connecting (line 87) → BadConfig (no host, line 145) / ConnectionFailure (socket errors, lines 156, 184, 189) / Ok (line 174)
- Ok → ConnectionFailure (timeout, line 230)
- Status checked before redundant updates: `if (this.instanceStatus !== InstanceStatus.Ok)` (line 244)

**Protocol Design Quality:**
- Uses multicast for read-only monitoring (efficient) + unicast for commands (reliable targeting)
- Application-level keepalive via GetStatus polling (compensates for UDP's lack of connection state)
- Source IP filtering prevents cross-instance interference in multi-device setups (line 240)
- Generation counters minimize volume Report requests (only when mixer state changes)
- No blocking operations — all I/O is async UDP send/receive

**Findings (Minor):**
1. **NOTE:** Missing error handler on bind operation itself (line 166) — error handler is registered on line 163 (before bind), so this is handled correctly. No issue.
2. **NOTE:** Action callbacks declared as `async` but never use `await` (actions.js lines 55-154) — hygiene issue, not a bug. Should remove `async` keyword.
3. **NOTE:** No automatic reconnection after timeout or socket error — status updated, but user must reload instance. Could improve UX by calling `closeSockets() → start()` in timeout handler.
4. **NOTE:** Potential race condition in `configUpdated()` — `closeSockets()` not awaited before `start()`. Add 100ms delay or make closeSockets return a Promise.
5. **NOTE:** `dropMembership()` called even if `addMembership()` failed (line 202) — throws error, caught by try/catch. Could track `this.multicastJoined` flag.

**Positive Patterns:**
- ✅ Both sockets properly closed in `destroy()`
- ✅ Timers (`pollTimer`, `noResponseTimer`) correctly cleared
- ✅ Multicast membership dropped before socket close
- ✅ All socket operations wrapped in try/catch
- ✅ Error listeners registered on both sockets
- ✅ Send errors handled with callback (line 215-217)
- ✅ InstanceStatus state machine correct (Connecting → BadConfig/ConnectionFailure/Ok)
- ✅ Defensive message parsing (magic bytes, IP filter, length checks)
- ✅ No synchronous/blocking network calls
- ✅ Resource management: null-checks before close, state reset on config change

**Learnings:**
- **Multicast bind order:** Must bind to multicast group address BEFORE calling `addMembership()`. Binding to group address is correct for multicast receive (not 0.0.0.0 or localhost).
- **Multicast interface auto-detection:** Subnet matching is reliable for finding correct interface when device IP is known. Fall back to no interface hint if detection fails — works on single-NIC systems, may fail on multi-NIC without manual config.
- **UDP timeout detection:** Since UDP has no connection state, modules must implement application-level keepalive (GetStatus polling) + timeout detection (no response for N seconds). 5s timeout is appropriate.
- **Source IP filtering in multicast:** When multiple instances share the same multicast group, filter incoming messages by source IP to prevent cross-instance interference.
- **Generation counters for optimization:** Rather than polling Report continuously, track generation counters in Status messages and only request Report when counter changes. Minimizes network traffic.
- **Fire-and-forget vs timeout:** Module uses fire-and-forget UDP sends with no retries. Timeout detection is passive (no response = failure). This is correct for this protocol — device broadcasts Status at ~10 Hz, so missing one packet is tolerable.
- **`async` keyword hygiene:** If callback doesn't use `await`, don't declare it `async`. Unnecessary Promise wrapping, misleads readers.

**Findings Written To:** `.squad/decisions/inbox/wash-review-findings.md`

**Session Closed:** 2026-04-02
**Verdict:** ✅ PASS WITH NOTES — well-engineered UDP implementation, proper socket lifecycle, no blocking issues. 6 notes for minor improvements (async hygiene, auto-reconnect, race condition, multicast join tracking, message bounds validation already correct).

**Release Tag:** v1.0.0 (first release)
**Comparison Baseline:** None (new module)
**Requested by:** Justin James

---

## Learnings

### Session: eventsync-server v0.9.8 Review (2024)

**Context:** WebSocket client module connecting to EventSync Server control protocol. First release review.

**Key Findings:**
- **WebSocket listener cleanup critical:** When calling `ws.close()`, event listeners remain attached to the closed socket object. Must call `ws.removeAllListeners()` before close/null to prevent memory leaks and ghost event handlers.
- **Auth failure must prevent reconnect:** When server sends `authFailed`, the `'close'` event handler will trigger automatic reconnect, creating infinite retry loop. Need flag to distinguish user/auth disconnect (permanent) from network disconnect (auto-retry).
- **Exponential backoff best practice:** Fixed 5-second reconnect interval hammers unreachable servers. Industry standard: 5s → 10s → 20s → 40s → cap at 60s. Reset to 5s on successful connection.
- **Connection timeout needed for ws:** Node.js `ws` library has no built-in timeout on connection attempts. If host unreachable, WebSocket constructor hangs indefinitely. Set manual timeout (10s reasonable) that calls `ws.terminate()` and schedules reconnect.
- **ReadyState check sufficient for stale pings:** If ping interval outlives connection, the `send()` method's `readyState === WebSocket.OPEN` check prevents errors. However, calling `stopPing()` before reconnect is good defensive practice.
- **`'close'` event is catch-all:** WebSocket `'close'` event fires on normal close, auth failure, network error, timeout—any disconnect. Cannot use it alone to decide whether to reconnect. Must track intent (permanent vs temporary failure).

**Good Patterns Observed:**
- Error event handler registered (prevents unhandled error crashes)
- JSON parsing in try-catch (defensive against malformed messages)
- Reconnect timer guard (prevents duplicate timers)
- Module lifecycle properly calls `connection?.disconnect()` in `destroy()`

**Findings Written To:** `.squad/decisions/inbox/wash-review-findings.md`

**Session Closed:** 2024
**Verdict:** ❌ REJECT — 2 blocking issues (listener leak, auth retry loop) + 3 recommended improvements. Core implementation solid but lifecycle management needs fixes before production.

**Release Tag:** v0.9.8 (first release)
**Comparison Baseline:** None (new module)
**Requested by:** Justin James

---

### 2026-04-09: Adder CCS-PRO v0.1.2 Review

**Module:** `companion-module-adder-ccs-pro` v0.1.2
**Protocol:** HTTP polling — Node.js built-in `http` module
**Review Type:** First release — all code is new
**Verdict:** ✅ Approved with Notes

**Key Findings:**
- No blocking issues — clean HTTP lifecycle, proper error handling, no socket leaks
- `init()` missing `InstanceStatus.Connecting` before first poll (Medium)
- `destroy()` missing `updateStatus(InstanceStatus.Disconnected)` (Medium)
- `isVisible` callback on config fields deprecated in v1.12 (Low)
- `password` field should use `secret-text` (Nice to Have, v1.13)
- `.gitignore` and `.prettierignore` deviate from JS template (Nice to Have — flagged for Kaylee)

**HTTP Patterns Observed:**
- Short-lived `http.request()` calls (no persistent connection) — poll timer is the lifecycle unit
- `req.on('timeout', () => req.destroy(new Error(...)))` pattern correctly routes timeout to error handler
- `res.resume()` after non-200 status in `sendCommand` — proper socket drain
- Single request for `switch_all` passes all four peripheral params in one query string

**Learnings:**
- **HTTP polling module lifecycle:** The "connection" is the poll timer, not a socket. `destroy()` only needs `clearInterval`. No socket cleanup required because `http.request` creates short-lived connections.
- **Status gap on init:** Modules that poll on a timer should set `InstanceStatus.Connecting` at the top of `init()` to avoid a status gap before the first poll response.
- **`destroy()` status convention:** Always call `updateStatus(InstanceStatus.Disconnected)` in `destroy()` — even for polling modules with no persistent socket.


### 2026-04-13: noctavoxfilms-tallycomm Review (v1.0.0)

**Module:** `companion-module-noctavoxfilms-tallycomm` v1.0.0
**Protocol:** HTTP — fetch-based POST to `/api/tally`
**Review Type:** First release — no prior tag, all findings eligible to block
**Key File:** `main.js` (single-file module at root)
**Requested by:** Justin James

**Architecture Pattern:**
- Single-file module, no src/ directory
- Fire-and-forget `checkConnection()` on init (intentional, documented in comment)
- `sendTally()` is async with AbortSignal.timeout(5000) and try/catch
- No timers, intervals, or persistent connections — purely request/response fetch
- `_isConnected` drives both connected variable and is_connected feedback

**Key Findings:**
- M1: `init()` sets InstanceStatus.Ok BEFORE checkConnection resolves — flash of false Ok
- M2: `checkConnection()` .then() ignores response.ok — HTTP 4xx/5xx treated as connected
- M3: No AbortController stored on instance — configUpdated() cannot cancel prior in-flight checkConnection; stale response race possible
- L1: `destroy()` cannot cancel in-flight fetches (no AbortController)
- L2: `configUpdated()` doesn't set Connecting before re-checking
- L3: Ping uses real POST to /api/tally with camera:0, bus:ping — no dedicated health endpoint
- N1: sendTally() uses InstanceStatus.UnknownError for HTTP errors — ConnectionFailure is more accurate

**Protocol Learnings:**
- **fetch() floating promise pattern:** A sync function that starts a fetch and chains .then()/.catch() does NOT create a floating Promise at the call site — the function returns undefined. Fire-and-forget is valid here, not a bug.
- **response.ok in checkConnection:** fetch() only rejects on network failure — HTTP error codes resolve normally. Always check response.ok in .then() handlers, not just in try/catch. Missing this check in checkConnection while having it in sendTally is an inconsistency that masks server-side errors.
- **AbortController for config transitions:** When configUpdated() fires, any in-flight request from the prior config can still complete and call state-mutation methods. Store an AbortController and abort() it in configUpdated()/destroy() to prevent stale callbacks.
- **destroy() and in-flight fetch:** With no timers, the only residual risk is in-flight fetch callbacks completing after destroy(). Bounded by the request timeout. Low severity but worth noting for modules using fetch without stored AbortControllers.
- **Fake ping vs health endpoint:** Sending a real tally command with out-of-range values (camera:0, bus:ping) as a connectivity check is pragmatic but fragile. If the server has a /health or /status endpoint, prefer that. Also note: a fake ping that ignores response.ok (M2) provides no real health signal.

**Solid Patterns Observed:**
- sendTally() has complete error handling: try/catch + response.ok + correct status on both success and failure
- AbortSignal.timeout(5000) on all fetch calls prevents stuck requests
- clear_all uses Promise.all() correctly for parallel tally clears
- BadConfig set immediately when room is empty
- _isConnected drives both variables and feedbacks consistently
- set_pgm_auto/set_pvw_auto guard against self-clear (prev !== cam check)

**Findings Written To:** `.squad/decisions/inbox/wash-review-findings.md`
**Session Closed:** 2026-04-13
**Verdict:** APPROVED WITH NOTES — 0 critical, 0 high, 3 medium, 3 low, 2 nice-to-have

### 2026-04-02: FalconPlay Review (v1.0.0)

**Module:** companion-module-wearefalcon-falconplay v1.0.0 (first release)
**Protocol:** HTTP REST (Node.js http module)
**Key Files:**
- main.js — Main module class, HTTP helpers (httpGet/httpPost), polling lifecycle
- actions.js — Action definitions with HTTP POST command callbacks
- feedbacks.js — Boolean feedbacks for connection status, device status, on-air input
- variables.js — Variable definitions for server version, rundown, devices
- src/upgrades.js — Empty upgrade script array (first release)

**Architecture Pattern:**
- Stateless HTTP client — no persistent connections
- Polling model: 2s status poll, 10s list refresh
- Node.js http module with callback-based API wrapped in Promises
- No external HTTP client library (no got, axios, node-fetch)

**Protocol Implementation:**
- httpGet(path) — wraps http.get() in Promise, 5s timeout
- httpPost(path, body) — wraps http.request() in Promise, 5s timeout, JSON payload
- Both methods parse JSON response, reject on network error or invalid JSON
- No HTTP status code validation — relies on JSON parse success
- No explicit timeout event handler — relies on default abort behavior

**Polling Lifecycle:**
- startPolling() always calls stopPolling() first — prevents double-timers
- Two timers: pollStatusTimer (2s), pollListsTimer (10s)
- stopPolling() uses clearInterval() and deletes timer references
- destroy() calls stopPolling() — clean shutdown
- configUpdated() stops/restarts polling — no orphaned intervals

**Status Transitions:**
- Ok when /api/status returns { ok: true }
- ConnectionFailure when HTTP request fails (network error, timeout)
- UnknownError when /api/status returns { ok: false, error: ... }
- No BadConfig status (config validation via Regex in getConfigFields)

**Findings:**
1. Blocking: Source files not in src/ directory — violates team decision 2026-04-02T02:54:42Z
2. High: No explicit req.destroy() on error/timeout — potential resource leak
3. High: No timeout event handler — socket may linger on timeout
4. High: UnknownError status message could be clearer (server reachable but error)
5. Medium: No backoff on poll failures — 300 failed requests in 10 minutes if offline
6. Medium: JSON parse errors lose response data — hard to debug API issues
7. Medium: No HTTP status code checking — 404/500 treated as JSON parse errors
8. Low: No HTTPS support — module always uses http://
9. Low: No connection test on init — status shows Ok until first poll completes

**What's Solid:**
- All action callbacks use try/catch — no unhandled promise rejections
- Polling lifecycle is clean — no double-timers, proper cleanup in destroy()
- Promise.allSettled() in refreshLists() — one failed API call doesn't crash others
- Status transitions correct for all code paths
- No persistent socket — no connection lifecycle to manage
- Feedbacks checked after every status update

**Session Closed:** 2026-04-02
**Verdict:** APPROVED WITH NOTES (after fixing B1 — source files structure)
Findings: .squad/decisions/inbox/wash-review-findings.md
1 blocking issue (source files not in src/), 3 high-priority notes, 3 medium-priority notes, 2 low-priority notes

## behringer-wing v2.3.0 (2026-04-10)
- OSC over UDP: subscription renewal interval doubles as reconnect for mixer reboots, but not for local socket failures
- When `destroy()` doesn't call `stop()`, expect socket leaks and EADDRINUSE on next module load
- `OscForwarder.setup()` parameter logger overwriting constructor logger is a recurring antipattern — check all handler `setup()` methods
- `JSON.stringify(err)` → `{}` is a known JS gotcha; always use `err.message` for Error logging


## noctavoxfilms-tallycomm v1.0.0 (2026-04-09)
- POST-based health checks can cause phantom server-side tally entries — always flag as High when bus value is undocumented
- checkConnection() must check response.ok — .then() fires on any HTTP response including 4xx/5xx
- _isConnected must be reset to false in sendTally() on both HTTP errors AND network errors
- Fallback phantom room names (e.g. 'companion-check') in health checks are server-polluting — always flag
