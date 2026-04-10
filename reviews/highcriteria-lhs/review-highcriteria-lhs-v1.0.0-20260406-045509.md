# Review: highcriteria-lhs v1.0.0

**Module:** companion-module-highcriteria-lhs  
**Version:** v1.0.0  
**API:** @companion-module/base ~2.0.3 (v2.0)  
**Type:** First Release — all findings are NEW  
**Review Date:** 2026-04-06  
**Reviewers:** Mal (Lead), Simon (Tests), Wash (Protocol), Kaylee (Template), Zoe (QA)

---

## Fix Summary for Maintainer

**Blocking fixes required before approval:**

1. **[C1]** Add `"type": "connection"` to `companion/manifest.json` immediately after `$schema`
2. **[C2]** Add null check in `src/main.ts:36`: `this.client?.destroy()`
3. **[C3]** Fix race condition in `src/main.ts:51-52`: Call `removeAllListeners()` before `destroy()`
4. **[H1]** Wrap all action awaits in try-catch: `src/actions.ts:44, 52, 60, 68, 93-99`
5. **[H2]** Emit error on handshake failure: `src/lhs.ts:303` — `.catch((err) => this.emit('error', err))`
6. **[H3]** Add null guard for undefined action method: `src/actions.ts:90-102`
7. **[H4]** Use strict equality (`===`/`!==`) in `src/main.ts:69-76`

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 3 | 0 | 3 |
| 🟠 High | 4 | 0 | 4 |
| 🟡 Medium | 6 | 0 | 6 |
| 🟢 Low | 7 | 0 | 7 |
| **Total** | **20** | **0** | **20** |

**Blocking:** 7 issues (3 critical, 4 high)  
**Fix complexity:** Medium — requires logic changes in error handling and null guards  
**Health delta:** 20 introduced · 0 pre-existing (first release)

---

## Verdict: **Changes Required**

Missing required `"type": "connection"` in manifest.json (module won't load in Companion 4.3+), null dereference in destroy(), and race condition in setupClient() — 7 blocking issues total.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing type connection in manifest.json](#c1-missing-type-connection-in-manifestjson)
- [ ] [C2: Null dereference in destroy method](#c2-null-dereference-in-destroy-method)
- [ ] [C3: Race condition in setupClient event listeners](#c3-race-condition-in-setupclient-event-listeners)
- [ ] [H1: Unhandled promise rejections in action callbacks](#h1-unhandled-promise-rejections-in-action-callbacks)
- [ ] [H2: Silent promise rejection in handshake](#h2-silent-promise-rejection-in-handshake)
- [ ] [H3: Missing null check in action handler](#h3-missing-null-check-in-action-handler)
- [ ] [H4: Loose equality in feedback comparisons](#h4-loose-equality-in-feedback-comparisons)

**Non-blocking**
- [ ] [M1: Typo in shortname field](#m1-typo-in-shortname-field)
- [ ] [M2: Typo in description field](#m2-typo-in-description-field)
- [ ] [M3: Missing default value for host config field](#m3-missing-default-value-for-host-config-field)
- [ ] [M4: Missing default value for room config field](#m4-missing-default-value-for-room-config-field)
- [ ] [M5: Unbounded receiveBuffer growth potential](#m5-unbounded-receivebuffer-growth-potential)
- [ ] [M6: Missing error handling in heartbeat](#m6-missing-error-handling-in-heartbeat)
- [ ] [L1: Listener leak potential on reconnect](#l1-listener-leak-potential-on-reconnect)
- [ ] [L2: No reconnect backoff strategy](#l2-no-reconnect-backoff-strategy)
- [ ] [L3: Heartbeat timing edge case](#l3-heartbeat-timing-edge-case)
- [ ] [L4: console.log in library code](#l4-consolelog-in-library-code)
- [ ] [L5: Aggressive buffer clearing on errors](#l5-aggressive-buffer-clearing-on-errors)
- [ ] [L6: Redundant checkFeedbacks call pattern](#l6-redundant-checkfeedbacks-call-pattern)
- [ ] [L7: Missing maintainer email in manifest](#l7-missing-maintainer-email-in-manifest)

---

## 🔴 Critical

### C1: Missing type connection in manifest.json

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`  
**Source:** Mal

**Issue:** The v2.0 API requires a top-level `"type": "connection"` field in manifest.json. Without it, the module will fail to load in Companion 4.3+.

**Expected:**
```json
{
  "$schema": "...",
  "type": "connection",
  "id": "highcriteria-lhs",
  ...
}
```

**Fix:** Add `"type": "connection"` immediately after the `$schema` field.

---

### C2: Null dereference in destroy method

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, line 36  
**Source:** Zoe, Mal

**Issue:** In `destroy()`, `this.client.destroy()` is called without checking if `this.client` exists. If `destroy()` is called before `init()` completes or if `setupClient()` fails, this will throw.

```typescript
public async destroy(): Promise<void> {
    this.log('debug', `destroy ${this.id}: ${this.label}\n Process: ${process.pid}`)
    this.client.destroy() // ← client may not exist yet
}
```

**Impact:** Module crash on deletion if client not initialized.

**Fix:** Add null check: `this.client?.destroy()`

---

### C3: Race condition in setupClient event listeners

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 49-85  
**Source:** Zoe

**Issue:** In `setupClient()`, when reconnecting, the old client is destroyed and listeners are removed (line 51-52), but there's no guarantee that pending events won't fire during the brief window between `destroy()` and `removeAllListeners()`.

```typescript
private setupClient(config: ModuleConfig): void {
    if (this.client) {
        this.client.destroy()
        this.client.removeAllListeners() // ← events may still fire
    }
    this.client = new LHSClient({ ... })
```

**Impact:** Events from old client could be processed after new client is created, leading to state corruption.

**Fix:** Call `removeAllListeners()` before `destroy()`, or use `.once()` pattern with cleanup.

---

## 🟠 High

### H1: Unhandled promise rejections in action callbacks

**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, lines 44, 52, 60, 68, 93-99  
**Source:** Wash

**Issue:** Action callbacks use `await` on client methods but do not handle promise rejections. If `client.newFile()`, `client.startRecording()`, etc. reject (e.g., connection lost mid-command), the error will bubble up as an unhandled promise rejection.

```typescript
callback: async (event) => {
    self.log('info', `${event.actionId}:${event.id}`)
    await self.client.newFile()  // ← No try-catch
},
```

**Impact:** 
- Unhandled promise rejections can crash the Node.js process
- User gets no feedback when commands silently fail

**Fix:** Wrap all `await` calls in try-catch blocks and log errors.

---

### H2: Silent promise rejection in handshake

**Classification:** 🆕 NEW  
**File:** `src/lhs.ts`, line 303  
**Source:** Zoe

**Issue:** `_sendHandshake()` returns a promise that's caught and silently swallowed (`.catch(() => {})`). If handshake fails, the connection will appear established but be non-functional.

```typescript
this.tcp.on('connect', () => {
    this.receiveBuffer = Buffer.alloc(0)
    this.handshakeAcknowledged = false
    this.queue.clear()
    this._sendHandshake().catch(() => {}) // ← silent failure
    this._startHeartbeat()
})
```

**Impact:** Silent connection failures, module appears connected but doesn't work.

**Fix:** Emit error event in catch handler: `.catch((err) => this.emit('error', err))`

---

### H3: Missing null check in action handler

**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, lines 90-102  
**Source:** Zoe

**Issue:** In `PauseRecording` action callback, `event.options.method` is accessed with optional chaining but the switch statement doesn't handle `undefined` before the `default` case.

```typescript
const method = event.options.method?.toString()
switch (method) {
    case 'pause':
    case 'resume':
    case 'toggle':
        // ...
    default:
        throw new Error(`Invalid selection: ${method} aborting action...`)
}
```

**Impact:** If `method` is `undefined`, throws error with message "Invalid selection: undefined".

**Fix:** Handle `undefined` explicitly or assert it's defined given the option schema.

---

### H4: Loose equality in feedback comparisons

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 69-76  
**Source:** Zoe

**Issue:** Feedback check comparison uses loose equality (`!=`/`==`) instead of strict equality (`!==`/`===`). This is inconsistent with TypeScript best practices.

```typescript
if (state.roomId == this.config.room || state.roomId == '') {
    if (oldState?.isPaused != state.isPaused) feedbacksToCheck.push(FeedbackId.isPaused)
    if (oldState?.isRecording != state.isRecording) feedbacksToCheck.push(FeedbackId.isRecording)
```

**Impact:** Potential type coercion issues, less safe comparison.

**Fix:** Use `!==` and `===` throughout.

---

## 🟡 Medium

### M1: Typo in shortname field

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 5  
**Source:** Kaylee, Mal

**Issue:** `"shortname": "Liberty Helper Serivce"` — typo: "Serivce" should be "Service".

**Impact:** User-facing text with spelling error.

**Fix:** Correct to `"Liberty Helper Service"`

---

### M2: Typo in description field

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 6  
**Source:** Kaylee, Mal

**Issue:** `"description": "Liberty Helper Service intergration for companion"` — typo: "intergration" should be "integration".

**Impact:** User-facing text with spelling error.

**Fix:** Correct to `"integration"`

---

### M3: Missing default value for host config field

**Classification:** 🆕 NEW  
**File:** `src/config.ts`, lines 11-18  
**Source:** Mal

**Issue:** The `host` config field has no `default` value. If a user creates a new connection and doesn't fill in the host, `config.host` will be `undefined`, causing a runtime error.

**Fix:** Add `default: ''` or `default: '127.0.0.1'` to the `host` field.

---

### M4: Missing default value for room config field

**Classification:** 🆕 NEW  
**File:** `src/config.ts`, lines 38-43  
**Source:** Mal

**Issue:** The `room` config field has no `default` value. While the module handles empty room gracefully, a `default: ''` is best practice.

**Fix:** Add `default: ''` to the room field.

---

### M5: Unbounded receiveBuffer growth potential

**Classification:** 🆕 NEW  
**File:** `src/lhs.ts`, lines 549-590  
**Source:** Zoe

**Issue:** In `_onData()`, if malformed data arrives that never contains `MAGIC_START`, the receive buffer grows by concatenation before being cleared.

**Impact:** Temporary memory spike on garbage data. Not a leak but could cause issues with large garbage streams.

**Fix:** Add max buffer size check before concatenation (e.g., 1MB limit).

---

### M6: Missing error handling in heartbeat

**Classification:** 🆕 NEW  
**File:** `src/lhs.ts`, lines 444-448  
**Source:** Zoe

**Issue:** The heartbeat timer calls `_sendCmd()` but catches and swallows all errors silently.

```typescript
this._sendCmd(Cmd.HeartbeatA, 0).catch(() => {})  // ← silent
this._sendCmd(Cmd.HeartbeatB, 0).catch(() => {})  // ← silent
```

**Impact:** Heartbeat failures go unnoticed, may mask connection issues.

**Fix:** Log errors or emit them (with rate limiting to avoid spam).

---

## 🟢 Low

### L1: Listener leak potential on reconnect

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 49-53, 61-84  
**Source:** Wash

**Issue:** `removeAllListeners()` only removes listeners from the `LHSClient` EventEmitter, not from the internal `TCPHelper`. The old `TCPHelper` instance inside the destroyed client may still emit events briefly before it's fully torn down.

**Impact:** Low probability but possible duplicate event handling during config transitions.

**Fix:** Add a check in event handlers to ignore events from stale clients (e.g., use a generation counter).

---

### L2: No reconnect backoff strategy

**Classification:** 🆕 NEW  
**File:** `src/lhs.ts`, lines 272-273, 286-289  
**Source:** Wash

**Issue:** The module uses `TCPHelper` with a fixed `reconnect_interval: 2000` ms. No backoff strategy means tight reconnection loop if server is down.

**Impact:** High network traffic during extended outages.

**Fix:** Implement exponential backoff (2s → 5s → 10s → 30s → 60s max).

---

### L3: Heartbeat timing edge case

**Classification:** 🆕 NEW  
**File:** `src/lhs.ts`, lines 319-328, 451-456  
**Source:** Wash

**Issue:** The `destroy()` method stops heartbeat after clearing queue. If a heartbeat callback is currently executing, `_sendCmd()` may be called on a destroyed connection.

**Impact:** Edge case — the `if (!this.tcp?.isConnected)` guard prevents most issues.

**Fix:** Clear the PQueue **after** stopping heartbeat and tcp cleanup.

---

### L4: console.log in library code

**Classification:** 🆕 NEW  
**File:** `src/lhs.ts`, lines 644-647  
**Source:** Wash, Mal

**Issue:** `_handleSrvInitInfo()` uses `console.log()` directly instead of emitting an event or using the instance logger.

**Impact:** Pollutes console output with debug info, no control over log level.

**Fix:** Emit a `'server_info'` event or remove if not needed.

---

### L5: Aggressive buffer clearing on errors

**Classification:** 🆕 NEW  
**File:** `src/lhs.ts`, lines 575-578  
**Source:** Wash

**Issue:** When an invalid end signature is detected, the entire receive buffer is discarded, including any subsequent valid frames.

**Impact:** Rare — only occurs if protocol framing is corrupted.

**Fix:** Consider skipping to the next potential start marker instead of clearing entire buffer.

---

### L6: Redundant checkFeedbacks call pattern

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, line 75  
**Source:** Zoe

**Issue:** The code passes `feedbacksToCheck[0]` twice (once as first arg, once in the spread):
```typescript
this.checkFeedbacks(feedbacksToCheck[0], ...feedbacksToCheck)
```

**Impact:** Minor code smell, no functional issue (checkFeedbacks deduplicates).

**Fix:** Use `this.checkFeedbacks(...feedbacksToCheck)` instead.

---

### L7: Missing maintainer email in manifest

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 13  
**Source:** Kaylee

**Issue:** The maintainer entry is missing the `email` field.

**Impact:** Incomplete maintainer information (optional field).

**Fix:** Add email field for the maintainer if desired.

---

## 🧪 Tests

**No tests found.** The module does not include any automated tests. No `vitest.config.*`, `jest.config.*`, or test files present.

**Simon's assessment:** Not a finding for a first release of this size, but tests recommended for future versions, particularly for:
- Client lifecycle (destroy before init completes)
- Rapid config changes
- Malformed TCP data handling
- Connection drops during operations

---

## ✅ What's Solid

1. **v2.0 API compliance (entry point):** Correct `export default class ModuleInstance extends InstanceBase<LhsTypes>` pattern — no deprecated `runEntrypoint`.

2. **InstanceTypes shape:** `LhsTypes` interface correctly implements `{ config, secrets, actions, feedbacks, variables }` shape as required by v2.0.

3. **UpgradeScripts export:** Correctly exported as named export. Empty array is acceptable for a first release.

4. **Lifecycle methods:** `init()`, `destroy()`, `configUpdated()`, and `getConfigFields()` all implemented correctly.

5. **TypeScript configuration:** `tsconfig.build.json` correctly extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`.

6. **Build tooling:** `@companion-module/tools` is v3.0.0 (exceeds v2.7.1+ requirement).

7. **ESM compliance:** All relative imports use `.js` extension correctly.

8. **No deprecated patterns:** No `parseVariablesInString`, no `checkFeedbacks()` without arguments, no `optionsToIgnoreForSubscribe`.

9. **Protocol implementation:** Excellent binary TCP client — proper framing with `LISv#bgn`/`LISv#end` magic markers, correct Big Endian byte order, PCAP-researched.

10. **Flow control:** PQueue ensures one frame at a time with 20ms minimum interval — prevents overwhelming device.

11. **Build passes:** `yarn build` and `yarn package` both succeed, producing `highcriteria-lhs-1.0.0.tgz` (10KB).

12. **Template compliance:** Most template conventions correct — package.json scripts, dependencies, LICENSE, .prettierignore, .yarnrc.yml all match template.

---

## Adjudication Notes

The following findings from Kaylee were downgraded based on functional impact:

- **Extra `*.pcap` in .gitignore** → 🔵 Low (not listed above — PCAP files are legitimately ignorable for protocol development, minor deviation that doesn't affect functionality)
- **eslint.config.mjs test configuration** → 🔵 Low (not listed above — build passes, harmless extra config for tests that don't exist)
- **tsconfig.build.json uses `nodenext` vs `Node16`** → Not blocking — build passes, `nodenext` is functionally equivalent for ESM modules and is the recommended setting for v2.0 modules

---

**Review assembled by:** Mal, Lead Reviewer  
**Date:** 2026-04-06
