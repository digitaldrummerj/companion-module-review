# Protocol Review: companion-module-behringer-wing v2.3.0

**Reviewer:** Wash (Protocol Specialist)  
**Module:** companion-module-behringer-wing  
**Release:** v2.3.0 (from v2.3.0-beta.2)  
**Date:** 2026-04-09  
**Requested by:** Justin James  

---

## Executive Summary

**Verdict:** ✅ **Approved with Notes**

The Behringer Wing module implements a UDP-based OSC protocol for mixer control. The connection lifecycle is well-structured with proper socket management, error handling, and cleanup. The key change in v2.3.0 (PR #197) modifies the error handler behavior from `updateStatus(ConnectionFailure)` to `logger?.error()`, which is a **stability improvement** that prevents spurious connection failures from being displayed to users when the OSC library emits non-critical errors.

However, there are two pre-existing issues that should be addressed in a future release:
1. OSC UDP sockets are not explicitly closed in the main `destroy()` method
2. Device detector's UDP socket has no error event handler

---

## Protocol Implementation Review

### Connection Architecture

The module uses a layered approach:
- **ConnectionHandler** (`src/handlers/connection-handler.ts`): Manages the primary OSC UDP connection
- **OscForwarder** (`src/handlers/osc-forwarder.ts`): Optional forwarding of OSC messages to another destination
- **WingDeviceDetector** (`src/handlers/device-detector.ts`): Broadcasts for device discovery

All three use the `osc` library (v2.4.5) which wraps Node.js's `dgram` for UDP sockets.

### Connection Lifecycle

**Initialization Flow:**
1. `init()` → `configUpdated()` → `start()` (lines 64-105)
2. `setupConnectionHandler()` creates ConnectionHandler with OSC UDP port (line 133)
3. Connection opens to `config.host:2223` using broadcast mode (line 143)
4. Socket events registered: `ready`, `error`, `close`, `message` (lines 147-172)

**Connection State Tracking:**
- `connected` boolean flag maintained (lines 35, 163, 178-179, 229)
- Status transitions: `Connecting` → `Ok` → `Disconnected`/`ConnectionFailure`
- Connection confirmed on first message receipt, not on socket `ready` (lines 176-181)

**Teardown Flow:**
1. `configUpdated()` → `stop()` → `connection?.close()` (lines 92, 99-104)
2. `destroy()` stops transitions and unsubscribes device detector (lines 74-77)

---

## 🆕 Changes in v2.3.0

### Change 1: Error Handler Behavior (🆕 NEW - PR #197)

**File:** `src/index.ts`, line 157-159

**Before (v2.3.0-beta.2):**
```typescript
this.connection?.on('error', (err: Error) => {
    this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
})
```

**After (v2.3.0):**
```typescript
this.connection?.on('error', (err: Error) => {
    this.logger?.error(JSON.stringify(err))
})
```

**Assessment:** ✅ **Correct and Improved**

This change is a **stability improvement**, not a regression. Here's why:

1. **UDP Error Semantics**: The OSC library's `error` event on a UDP socket doesn't necessarily indicate connection failure. Common scenarios include:
   - Transient ICMP "port unreachable" messages when the remote device hasn't responded yet
   - Non-fatal OS-level socket errors
   - Malformed OSC packets that fail parsing (the trigger for PR #197)

2. **Connection State Tracking**: The module correctly tracks connection state through:
   - **Message receipt**: Connection confirmed when first message arrives (line 176-181)
   - **Poll timeout**: Disconnection detected via `poll-connection-timeout` event (line 227-230)
   - **Close event**: Socket closure triggers `Disconnected` status (line 161-166)

3. **User Experience**: The previous behavior would show `ConnectionFailure` on every OSC parsing error, even when the connection was functioning. The new behavior logs the error for debugging while maintaining accurate connection status.

**Comparison with Other Error Handlers:**
- **OscForwarder** (line 32-34): Uses `logger?.warn()` for errors — same pattern
- **DeviceDetector** (line 104-107): Restarts on error — appropriate for discovery broadcast
- **ConnectionHandler** (line 49-52): Logs and emits error — appropriate for library layer

**Verdict:** This change is **protocol-correct**. UDP is connectionless; the presence of error events doesn't mean the "connection" is failed. The module's polling-based liveness detection is the proper way to determine connection health.

### Change 2: Fader Delta Floor Fix (🆕 NEW - PR #201)

**Files:** `src/actions/common.ts` (line 872-875), `src/actions/matrix.ts` (line 105-108)

**Change:** Added floor check for delta fader adjustments to prevent going below -90dB:
```typescript
if (!usePercentage && targetValue < -90) {
    targetValue = -90
}
```

**Assessment:** Not protocol-related (business logic for fader control). No protocol concerns.

---

## ⚠️ Pre-existing Issues (Non-blocking)

These issues existed in v2.3.0-beta.2 and earlier. They do not block this release but should be addressed in a future update.

### Issue 1: Incomplete Socket Cleanup in destroy() (⚠️ PRE-EXISTING)

**File:** `src/index.ts`, lines 74-77

**Issue:** The `destroy()` method does not explicitly close the primary OSC connection or forwarder:

```typescript
async destroy(): Promise<void> {
    this.deviceDetector?.unsubscribe(this.id)
    this.transitions.stopAll()
}
```

**Expected:**
```typescript
async destroy(): Promise<void> {
    this.stop() // or explicitly close connection and forwarder
    this.deviceDetector?.unsubscribe(this.id)
    this.transitions.stopAll()
}
```

**Impact:** 
- When Companion disables/removes the module, `stop()` is not called, only `destroy()`
- If the module is configured, the OSC UDP sockets remain open
- This is a resource leak — sockets should be closed when the module is destroyed

**Why Pre-existing:**
- Same code structure present in v2.3.0-beta.2 and earlier releases
- Not changed in this release

**Recommendation:** Add `this.stop()` or explicit socket cleanup to `destroy()` method.

---

### Issue 2: Device Detector Error Handler Restarts Unconditionally (⚠️ PRE-EXISTING)

**File:** `src/handlers/device-detector.ts`, lines 104-107

**Issue:**
```typescript
this.osc.on('error', (_err: Error): void => {
    this.stopListening()
    this.startListening()
})
```

**Concern:** 
- Errors on broadcast sockets can be frequent (e.g., network changes, ICMP unreachable)
- Restarting immediately without backoff could cause rapid restart loops
- No logging of the error for diagnostics

**Recommendation:**
- Add logging: `this.logger?.warn('Device detector error, restarting:', err.message)`
- Consider adding backoff or rate limiting for restarts

**Why Pre-existing:** Same code structure present in v2.3.0-beta.2 and earlier.

---

## ✅ What's Solid

### 1. Connection Lifecycle Management
- **Status Tracking**: Proper `InstanceStatus` transitions throughout lifecycle
- **Connection Detection**: Smart first-message-based connection confirmation (line 176-181)
- **Liveness Detection**: Poll-based timeout detection via FeedbackHandler (line 227-230)
- **Close Handling**: Proper cleanup on `close` event (line 161-166)

### 2. Socket Hygiene (ConnectionHandler)
- **Explicit Cleanup**: `close()` method properly closes the OSC UDP port (line 116-119)
- **Subscription Timer Cleanup**: Timer cleared on close (line 56-59)
- **Error Handling**: All socket events have handlers (lines 45-68)

### 3. Error Handling Patterns
- **Promise Rejection Handling**: All async `sendCommand()` calls use `.catch(() => {})` (lines 193, 245, 110)
- **Try-Catch on Setup**: OscForwarder setup wrapped in try-catch (line 23-40)
- **Defensive Cleanup**: OscForwarder `close()` uses try-catch (line 51-58)

### 4. OSC Message Parsing
- **Type Checking**: Message arguments validated before use (DeviceDetector line 123-125)
- **Debounced Processing**: Message batching reduces overhead (line 50-61 in index.ts)
- **Error Isolation**: Individual message errors don't crash the module (per PR #197 intent)

### 5. Resource Management
- **Device Detector Subscription**: Properly subscribes/unsubscribes with reference counting (lines 49-65)
- **Timer Cleanup**: All timers (subscription, query, poll, no-device timeout) properly managed
- **Forwarder Cleanup**: OscForwarder closed and set to undefined in `stop()` (line 94-95)

---

## Protocol Specification Compliance

**OSC Protocol:**
- ✅ Uses standard OSC library (`osc` npm package v2.4.5)
- ✅ Proper message formatting (address + typed arguments)
- ✅ Metadata mode enabled for type information
- ✅ UDP broadcast mode for discovery

**Connection Pattern:**
- ✅ Subscription-based updates via `/*S` command (line 110)
- ✅ Periodic subscription renewal (default 9000ms) (line 82-103)
- ✅ Defensive message handling (error parsing doesn't crash module)

---

## Recommendations for Future Releases

1. **High Priority**: Add explicit socket cleanup to `destroy()` method
2. **Medium Priority**: Add error logging and restart backoff to DeviceDetector
3. **Low Priority**: Consider consolidating status update logic (currently split between multiple handlers)

---

## Conclusion

The v2.3.0 release makes a **positive protocol/stability change** by preventing OSC parsing errors from incorrectly marking the connection as failed. The connection lifecycle is robust, with proper liveness detection through polling rather than relying on UDP socket errors.

The two pre-existing issues noted above do not pose immediate stability risks but should be addressed in a future release to prevent resource leaks and improve error recovery.

**Final Verdict:** ✅ **Approved with Notes**

---

**Wash, Protocol Specialist**  
*"The error event on a UDP socket doesn't mean the connection is down — that's what polling is for."*
