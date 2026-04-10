# Review: companion-module-generic-snmp v3.0.1

**Module:** companion-module-generic-snmp  
**Version reviewed:** v3.0.1  
**Previous approved tag:** v2.3.0  
**Review date:** 2026-04-09  
**Reviewers:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪  
**API:** v2.x (`@companion-module/base ~2.0.3`)  
**Language:** TypeScript ESM (rewritten from JavaScript in this release)  

---

## Fix Summary

Three blocking issues require fixes before this release can be approved, all in `src/index.ts`. First, `pollOids()` has no error handling around `getOid()` — any SNMP timeout or network failure silently terminates the poll chain permanently while the module status remains `Ok`, leaving users with stale data and no indication of the problem. Second, `createListener()` can leak a permanently-pending promise when `configUpdated()` fires twice rapidly with traps enabled — the second call's `closeListener()` strips the event handlers off the socket still binding in the first call, causing that `createListener` promise to never resolve or reject. Third, `snmp.createSession()` and `snmp.createV3Session()` are called without a try/catch — both can throw synchronously on certain malformed inputs (bad engineID, key validation failures), leaving the module at `Ok` status with an undefined session reference.

All three fixes are straightforward additions to `src/index.ts`. The rest of the module is genuinely excellent: 329 tests all pass, the v2.x API migration is clean, secrets are properly isolated, the `pollGeneration` race-condition guard is well-implemented, and the overall TypeScript architecture is a significant step up from the v2.3.0 JavaScript codebase.

**Must fix before merge:**
1. `src/index.ts` `pollOids()` — wrap `await this.getOid(...oids)` in try/catch; log the error, update status to `ConnectionFailure`, then continue scheduling the next poll
2. `src/index.ts` `createListener()` — add a generation guard check after `await this.createListener()` returns so a cancelled in-flight bind can abort cleanly
3. `src/index.ts` `connectAgent()` — wrap `snmp.createSession()` and `snmp.createV3Session()` in try/catch with proper `ConnectionFailure` status update

---

## 📊 Scorecard

| Area | Status |
|------|--------|
| `yarn build` | ✅ Clean |
| `yarn lint` | ✅ Clean |
| `yarn test` | ✅ 329/329 passed (8 test files, 249ms) |
| v2.x API compliance | ✅ No `isVisible`; `isVisibleExpression` used throughout |
| Secrets isolation | ✅ `authKey`/`privKey` in `ModuleSecrets`, never logged |
| `manifest.apiVersion` | ✅ `"0.0.0"` is standard v2.x placeholder — auto-patched by build tool |
| Upgrade scripts | ✅ `v230` secrets migration + `v300` action/feedback ID coverage |
| Connection lifecycle | ❌ 3 blocking issues in `index.ts` |

| Severity | NEW | PRE-EXISTING |
|----------|-----|--------------|
| 🔴 Critical | 0 | 0 |
| 🟠 High | 3 | 0 |
| 🟡 Medium | 8 | 0 |
| 🟢 Low | 8 | 0 |
| 💡 NTH | 2 | 3 |
| **Blocking total** | **3** | **0** |

---

## ✋ Verdict

**❌ CHANGES REQUIRED — 3 blocking issues (3 High NEW)**

The v3.0.1 rewrite is a substantial quality improvement over the v2.3.0 JavaScript codebase. The TypeScript migration is thorough, the test suite is impressive (329 tests across every major module), the v2.x API is correctly adopted throughout, SNMPv3 secrets are properly isolated, and the `pollGeneration` counter elegantly solves the concurrent-poll-chain problem. The PQueue with priority levels, the `throttledFeedbackIdCheck` batching, and the `subscribe`-callback pattern for immediate OID registration on action creation are all well-engineered patterns.

However, three High-severity lifecycle bugs in `src/index.ts` must be addressed before release. The poll-death-on-error issue is the most impactful: any transient SNMP timeout silently stops all polling with no user feedback. The `createListener` promise leak is a narrower race condition but can cause a permanent async deadlock when traps are configured and the user changes settings quickly. The unguarded `createSession` call is a defensive hardening gap that could produce confusing behavior for users who misconfigure SNMPv3 parameters.

Fix the three items in the Fix Summary, re-run `yarn build`, `yarn lint`, and `yarn test` to confirm all pass, and resubmit.

---

## 📋 Issues TOC

**🟠 High**
- [H1 — `pollOids()` silently terminates poll chain on any SNMP error](#h1--polloids-silently-terminates-poll-chain-on-any-snmp-error)
- [H2 — `createListener` promise never settles on rapid `configUpdated`](#h2--createlistener-promise-never-settles-on-rapid-configupdated)
- [H3 — No try/catch in `connectAgent`; synchronous throws from `net-snmp` are unhandled](#h3--no-trycatch-in-connectagent-synchronous-throws-from-net-snmp-are-unhandled)

**🟡 Medium**
- [M1 — `SharedUdpSocket.bind()` called with remote device IP as local bind address](#m1--sharedudpsocketbind-called-with-remote-device-ip-as-local-bind-address)
- [M2 — SNMPv3 trap receiver always passes all auth/priv fields regardless of security level](#m2--snmpv3-trap-receiver-always-passes-all-authpriv-fields-regardless-of-security-level)
- [M3 — `getOID` feedback missing `subscribe` callback; OID tracking deferred until first evaluation](#m3--getoid-feedback-missing-subscribe-callback-oid-tracking-deferred-until-first-evaluation)
- [M4 — `configUpdated` does not clear `oidValues` cache on device change](#m4--configupdated-does-not-clear-oidvalues-cache-on-device-change)
- [M5 — `isVisibleExpression` bakes `config.version` as a literal boolean at definition time](#m5--isvisibleexpression-bakes-configversion-as-a-literal-boolean-at-definition-time)
- [M6 — SNMPv3 auth/priv keys have no minimum-length validation](#m6--snmpv3-authpriv-keys-have-no-minimum-length-validation)
- [M7 — `configUpdated` does not cancel throttled/debounced callbacks](#m7--configupdated-does-not-cancel-throttleddebounced-callbacks)
- [M8 — `FeedbackOidTracker.clear()` does not clear `oidsToPoll`](#m8--feedbackoidtrackerclear-does-not-clear-oidstopoll)

**🟢 Low**
- [L1 — Double `removeFromPollGroup` call in feedback `unsubscribe`](#l1--double-removefrompolllgroup-call-in-feedback-unsubscribe)
- [L2 — `Buffer.slice` deprecated; use `Buffer.subarray`](#l2--bufferslice-deprecated-use-buffersubarray)
- [L3 — Dead code: `getFeedbacksForOid` defined but never called](#l3--dead-code-getfeedbacksforoid-defined-but-never-called)
- [L4 — Redundant `oid.length == 0` guard alongside `isValidSnmpOid`](#l4--redundant-oidlength--0-guard-alongside-isvalidsnmpoid)
- [L5 — `SetOpaque` action missing `learn` callback](#l5--setopaque-action-missing-learn-callback)
- [L6 — Silent `127.0.0.1` fallback for `agentAddress` on DNS failure](#l6--silent-127001-fallback-for-agentaddress-on-dns-failure)
- [L7 — Multiple typos in log strings, comments, and variable names](#l7--multiple-typos-in-log-strings-comments-and-variable-names)
- [L8 — `vi.mock()` calls not at top level in `config.test.ts`](#l8--vimock-calls-not-at-top-level-in-configtestts)

**💡 Nice to Have**
- [NTH1 — `pre200` upgrade script is an empty placeholder](#nth1--pre200-upgrade-script-is-an-empty-placeholder)
- [NTH2 — `getOidsToPoll` getter uses `get` prefix (redundant for a getter)](#nth2--getoidstopoll-getter-uses-get-prefix-redundant-for-a-getter)

**⚠️ Pre-existing Notes**
- [PE1 — `package.json` name missing `companion-module-` prefix](#pe1--packagejson-name-missing-companion-module--prefix)
- [PE2 — `manifest.name` is a slug, not human-readable](#pe2--manifestname-is-a-slug-not-human-readable)
- [PE3 — `manifest.apiVersion: "0.0.0"` — standard placeholder, auto-patched at build time](#pe3--manifestapiversion-000--standard-placeholder-auto-patched-at-build-time)

---

## 🟠 High

### H1 — `pollOids()` silently terminates poll chain on any SNMP error

🆕 **NEW in v3.0.1** · **BLOCKING**

`pollOids()` calls `getOid()` without any error handling. When `getOid()` rejects — on SNMP timeout, network failure, session error — the exception propagates out of `pollOids()` and is swallowed by the `.catch(() => {})` at the call site. The `pollTimer` is never scheduled, the poll chain stops permanently, and the module status remains `Ok`. Users see stale data with no indication that polling has stopped.

```typescript
// src/index.ts — pollOids()
private async pollOids(): Promise<void> {
    const generation = this.pollGeneration
    const oids = this.oidTracker.getOidsToPoll
    if (oids.length > 0) await this.getOid(...oids)  // ← throws on any SNMP error
    // execution never reaches here if getOid throws
    if (generation !== this.pollGeneration) return
    if (this.config.interval > 0) {
        this.pollTimer = setTimeout(() => {
            this.pollOids().catch(() => {})  // ← outer catch silently swallows the whole chain failure
        }, this.config.interval * 1000)
    }
}
```

`getOid()` does not log errors internally — it simply rejects. Combined with the outer `.catch(() => {})`, errors are 100% silent.

**Impact:** Any transient SNMP timeout, brief network interruption, or session error permanently stops all polling. The instance remains at `Ok` status while all OID-based feedbacks and actions silently return stale values.

**File:** `src/index.ts` — `pollOids()`  
**Fix:** Wrap `getOid` in try/catch to survive transient errors and keep the chain alive:

```typescript
private async pollOids(): Promise<void> {
    const generation = this.pollGeneration
    const oids = this.oidTracker.getOidsToPoll
    if (oids.length > 0) {
        try {
            await this.getOid(...oids)
        } catch (err) {
            this.log('warn', `Poll failed: ${err instanceof Error ? err.message : String(err)}`)
            this.statusManager.updateStatus(InstanceStatus.ConnectionFailure, 'Poll error')
        }
    }
    if (generation !== this.pollGeneration) return
    if (this.config.interval > 0) {
        this.pollTimer = setTimeout(() => {
            this.pollOids().catch(() => {})
        }, this.config.interval * 1000)
    }
}
```

---

### H2 — `createListener` promise never settles on rapid `configUpdated`

🆕 **NEW in v3.0.1** · **BLOCKING**

When `configUpdated` is called twice rapidly while traps are enabled, the second invocation's `closeListener()` calls `this.listeningSocket.removeAllListeners()` on the socket still mid-bind from the first call. This strips the `'listening'` and `'error'` handlers registered inside the first call's `createListener`. Those handlers are the only paths that call `resolve()` or `reject()` on the first call's promise — which can now never settle.

```typescript
// configUpdated (index.ts:70–71)
this.closeListener()               // ← removes ALL listeners on listeningSocket
...
await this.initializeConnection()  // ← starts a new createListener (async)

// createListener (index.ts:287–295)
this.listeningSocket.addListener('error', errorHandler)     // may already be removed!
this.listeningSocket.addListener('listening', () => { ...resolve() })  // same
this.listeningSocket.bind(...)
```

**Reproduction:**
1. Enable traps in config and save — triggers `configUpdated` → `createListener` awaits `'listening'`
2. Before binding completes, save config again — second `configUpdated` fires, `closeListener()` strips all listeners from the socket still binding in Call 1
3. Call 1's promise never settles; Call 1's `configUpdated` coroutine leaks as a permanently pending async call

**Impact:** After rapid config changes with traps enabled, one `configUpdated` call hangs forever. Accumulated leaked coroutines hold references to the module instance. On the next config change, a third `configUpdated` begins with two stale ones already pending.

**File:** `src/index.ts` — `createListener()`, `configUpdated()`  
**Fix:** Add a generation guard immediately after `await this.createListener()` so a cancelled bind aborts cleanly:

```typescript
if (this.config.traps) {
    try {
        await this.createListener()
    } catch (err) {
        this.log('warn', `Trap listener failed: ${String(err)}`)
    }
    if (generation !== this.pollGeneration) return  // ← ADD THIS CHECK
}
```

Alternatively, emit a synthetic `'error'` event from `closeListener()` before calling `removeAllListeners()` so any pending `createListener` promise rejects immediately.

---

### H3 — No try/catch in `connectAgent`; synchronous throws from `net-snmp` are unhandled

🆕 **NEW in v3.0.1** · **BLOCKING**

`snmp.createSession()` and `snmp.createV3Session()` are both called without a surrounding try/catch. The `net-snmp` library throws synchronously on certain invalid inputs — malformed `engineID` values, keys that fail internal validation, or option combinations that violate library constraints. Because `connectAgent` is called from `initializeConnection` → `configUpdated` / `init`, a synchronous throw propagates as an unhandled exception, potentially crashing the module process or leaving `this.session` undefined while `statusManager` still shows `Ok`.

```typescript
// src/index.ts:247–248 — no try/catch
this.session = snmp.createV3Session(this.config.ip, user, options)
this.statusManager.updateStatus(InstanceStatus.Ok)   // ← only reached if no throw
```

**Impact:** A user who enters an `engineID` that passes the hex regex but is semantically rejected by `net-snmp` internals will see their module enter an undefined state at `Ok` status with no `this.session` and no error feedback.

**File:** `src/index.ts` — `connectAgent()`  
**Fix:** Wrap both session creation calls in try/catch:

```typescript
try {
    this.session = snmp.createV3Session(this.config.ip, user, options)
    this.statusManager.updateStatus(InstanceStatus.Ok)
} catch (err) {
    this.log('error', `Failed to create SNMPv3 session: ${err instanceof Error ? err.message : String(err)}`)
    this.statusManager.updateStatus(InstanceStatus.ConnectionFailure, 'Session creation failed')
}
```

Apply the same pattern to `snmp.createSession()`.

---

## 🟡 Medium

### M1 — `SharedUdpSocket.bind()` called with remote device IP as local bind address

🆕 **NEW in v3.0.1**

`createListener` passes `this.config.ip` — the remote SNMP agent's IP address — as the second argument to `this.listeningSocket.bind()`:

```typescript
// src/index.ts:261
this.listeningSocket.bind(this.config.portBind || 162, this.config.ip)
```

In Node.js's `dgram` API (and Companion's `SharedUdpSocket` wrapper), the second argument to `bind(port, address)` is the **local interface address** to bind to. Passing the remote device's IP as the local bind address will fail on any Companion host where that IP does not exist as a local interface — which is virtually all real deployments.

Source-address filtering for received traps is already correctly handled separately inside `SharedUDPSocketWrapper.messageHandler` via `allowedAddress`. The bind call itself should use `0.0.0.0` or no address argument at all.

**File:** `src/index.ts` line 261  
**Fix:** Remove the IP argument from the bind call:

```typescript
this.listeningSocket.bind(this.config.portBind || 162)
```

Leave IP filtering to the existing `SharedUDPSocketWrapper.allowedAddress` mechanism, which is correct.

---

### M2 — SNMPv3 trap receiver always passes all auth/priv fields regardless of security level

🆕 **NEW in v3.0.1**

In `createListener()`, the SNMPv3 trap receiver's `addUser()` is always called with all six fields populated — including `authProtocol`, `authKey`, `privProtocol`, and `privKey` — regardless of the configured security level:

```typescript
this.receiver.getAuthorizer().addUser({
    name: this.config.username,
    level: snmp.SecurityLevel[this.config.securityLevel],
    authProtocol: snmp.AuthProtocols[this.config.authProtocol],  // always set
    authKey: this.secrets.authKey,                                // empty string for noAuthNoPriv
    privProtocol: snmp.PrivProtocols[this.config.privProtocol],  // always set
    privKey: this.secrets.privKey,                                // empty string for authNoPriv
})
```

This differs from the conditional logic used in `connectAgent()`, which correctly skips auth/priv fields when not applicable to the security level. Passing empty-string keys and always-set protocol fields to `net-snmp`'s receiver authorizer may cause mishandled v3 traps at `noAuthNoPriv` or `authNoPriv` security levels.

**File:** `src/index.ts` — `createListener()` `listening` handler  
**Fix:** Mirror the session creation logic — only include `authProtocol`/`authKey` when `securityLevel !== 'noAuthNoPriv'`, and only include `privProtocol`/`privKey` when `securityLevel === 'authPriv'`.

---

### M3 — `getOID` feedback missing `subscribe` callback; OID tracking deferred until first evaluation

🆕 **NEW in v3.0.1**

The `FeedbackId.GetOID` feedback definition has no `subscribe` callback. OID registration with `oidTracker.updateFeedback()` only happens inside the `callback` function — meaning an OID is not registered for polling until the first time Companion evaluates the feedback instance.

All seven action definitions correctly implement `subscribe` to register OIDs immediately when the action is added. The feedback should follow the same pattern. If `initializeConnection()` starts the poll loop before Companion's first feedback evaluation, that OID is silently missed on the first poll cycles.

**File:** `src/feedbacks.ts` lines 29–75  
**Fix:** Add a `subscribe` callback that calls `self.oidTracker.updateFeedback(feedback.id, oid, feedback.options.update)` and `self.getOid(oid)`, mirroring the action `subscribe` pattern.

---

### M4 — `configUpdated` does not clear `oidValues` cache on device change

🆕 **NEW in v3.0.1**

`configUpdated` increments `pollGeneration`, clears the SNMP queue, and reconnects to the new device. However, `this.oidValues` (the OID value cache) is never cleared. If the user changes `config.ip` to a different SNMP device, stale OID values from the old device persist in the cache. Feedbacks and the `GetOID` action will return the old device's values until the next successful poll overwrites them.

**File:** `src/index.ts` — `configUpdated()`  
**Fix:** Add `this.oidValues.clear()` (and optionally `this.oidTracker.clear()`) inside `configUpdated()` before calling `initializeConnection()`.

---

### M5 — `isVisibleExpression` bakes `config.version` as a literal boolean at definition time

🆕 **NEW in v3.0.1**

In `src/actions.ts`, an `isVisibleExpression` embeds `self.config.version` as a JavaScript evaluated value at the moment `updateActions()` is called:

```typescript
// src/actions.ts:512
isVisibleExpression: `$(options:messageType) == 'inform' && ${self.config.version == 'v1'}`,
```

`self.config.version == 'v1'` is evaluated immediately in JS and injected as the literal string `"true"` or `"false"`. While `configUpdated()` calls `updateActions()` to regenerate the expression, a user who has the action editor open during a config change may see stale visibility until the editor refreshes.

**File:** `src/actions.ts` line 512  
**Recommendation:** If the expression language cannot reference config fields directly, add a comment explaining the intentional pattern so future maintainers understand why the expression contains a literal boolean. The `configs.ts:176` instance (`${!hasLegacyProviders}`) is acceptable since `hasLegacyProviders` is a process-level constant.

---

### M6 — SNMPv3 auth/priv keys have no minimum-length validation

🆕 **NEW in v3.0.1**

RFC 3414 requires USM authentication keys to be at least 8 characters. Neither the config field (`type: 'secret-text'`) nor `connectAgent` enforces a minimum length. An empty or very short key passes the `undefined || ''` check and is sent directly to `net-snmp`. Depending on the library version, this may throw synchronously (compounding H3) or produce silently broken authentication.

**Files:** `src/configs.ts:157–184`, `src/index.ts` — `connectAgent()`  
**Fix:** Add `minLength: 8` to the `authKey` and `privKey` config fields, or add an explicit length guard in `connectAgent` before session creation.

---

### M7 — `configUpdated` does not cancel throttled/debounced callbacks

🆕 **NEW in v3.0.1**

`destroy()` correctly calls `this.throttledFeedbackIdCheck.cancel()` and `this.debouncedUpdateDefinitions.cancel()`. `configUpdated()` does not. If either callback has a pending invocation when `configUpdated` fires, it will execute after the new config is applied. In practice, `debouncedUpdateDefinitions` re-running is benign (it re-calls `updateActions()`/`updateFeedbacks()` which `configUpdated` already called), and `throttledFeedbackIdCheck` firing with stale IDs is handled gracefully. Low practical impact, but the pattern is inconsistent with `destroy()`.

**File:** `src/index.ts` — `configUpdated()`  
**Fix:**
```typescript
this.throttledFeedbackIdCheck.cancel()
this.debouncedUpdateDefinitions.cancel()
```
at the top of `configUpdated()`, matching `destroy()`.

---

### M8 — `FeedbackOidTracker.clear()` does not clear `oidsToPoll`

🆕 **NEW in v3.0.1**

`clear()` resets `oidToFeedbacks` and `feedbackToOid` but leaves `oidsToPoll` intact:

```typescript
// src/oidtracker.ts:144–148
clear(): void {
    this.oidToFeedbacks.clear()
    this.feedbackToOid.clear()
    // BUG: this.oidsToPoll.clear() is missing
}
```

If `clear()` is ever invoked (e.g., after implementing the fix for M4 above), stale OIDs would continue to be polled with no associated feedback, generating unnecessary SNMP traffic indefinitely.

**File:** `src/oidtracker.ts` line 144  
**Fix:** Add `this.oidsToPoll.clear()` to the `clear()` method.

---

## 🟢 Low

### L1 — Double `removeFromPollGroup` call in feedback `unsubscribe`

`src/feedbacks.ts:58–61` — `removeFeedback()` already calls `removeFromPollGroup` internally (oidtracker.ts:72–77). The explicit second call is redundant and misleading. No functional impact today, but fragile if the internal implementation changes.

**Fix:** Remove the second explicit `removeFromPollGroup` call from `unsubscribe`.

---

### L2 — `Buffer.slice` deprecated; use `Buffer.subarray`

`src/oidUtils.ts:40` — `Buffer.prototype.slice` is deprecated since Node.js 17 in favour of `Buffer.prototype.subarray`. This generates deprecation warnings in newer runtimes.

**Fix:** `buffer.subarray(start, end)`

---

### L3 — Dead code: `getFeedbacksForOid` defined but never called

`src/oidtracker.ts:87–89` — `getFeedbacksForOid(oid)` returns `Readonly<Set<string>>` but is never referenced anywhere in the codebase. `getFeedbackIdsForOid()` (which returns `string[]`) is used instead.

**Fix:** Remove `getFeedbacksForOid`, or explicitly mark it `@internal` / `@deprecated` if it is intended as a public API.

---

### L4 — Redundant `oid.length == 0` guard alongside `isValidSnmpOid`

`src/index.ts:405, 434` — `isValidSnmpOid` already returns `false` for empty strings (the pattern `/^(0|1|2)(\.(0|[1-9]\d*))+$/u` requires at least two numeric components). The `oid.length == 0` check is unreachable dead code.

**Fix:** Remove the redundant `|| oid.length == 0` conditions.

---

### L5 — `SetOpaque` action missing `learn` callback

`src/actions.ts` — All other `Set*` and `Get*` actions (`SetString`, `SetNumber`, `SetBoolean`, `SetIpAddress`, `SetOID`, `GetOID`, `TrapOrInform`) implement `learn` callbacks. `SetOpaque` does not. Users cannot learn the current OID value for opaque type data.

**Fix:** Implement a `learn` callback for `SetOpaque` consistent with the other `Set*` actions.

---

### L6 — Silent `127.0.0.1` fallback for `agentAddress` on DNS failure

`src/index.ts` — `setAgentAddress()` — DNS lookup failures are silently swallowed. SNMPv1 traps will carry `127.0.0.1` as the agent address in virtually all failure scenarios, with no log warning to alert the operator.

**Fix:**
```typescript
if (err) {
    this.log('warn', `Could not resolve local hostname for agentAddress, defaulting to 127.0.0.1: ${err.message}`)
    resolve()
    return
}
```

---

### L7 — Multiple typos in log strings, comments, and variable names

| File | Location | Found | Should be |
|------|----------|-------|-----------|
| `src/wrapper.ts:~47` | constructor log | `"initalized"` | `"initialized"` |
| `src/wrapper.ts:~55` | debug log | `"Recieved"` | `"Received"` |
| `src/wrapper.ts:~114` | debug log | `"messagee"` | `"message"` |
| `src/configs.ts:104` | field description | `"seperated"` | `"separated"` |
| `src/configs.ts:37` | label (×2) | `"localiztaion"` | `"localization"` |
| `src/actions.ts:549` | variable name | `retunedOptions` | `returnedOptions` |

---

### L8 — `vi.mock()` calls not at top level in `config.test.ts`

`src/config.test.ts` — Two `vi.mock()` calls are inside `describe` blocks rather than at module top level. Vitest currently hoists them silently but logs a warning that this will become an error in a future vitest version. All 329 tests pass today.

**Fix:** Move both `vi.mock("@companion-module/base")` and `vi.mock("./oidUtils.js")` to module top level.

---

## 💡 Nice to Have

### NTH1 — `pre200` upgrade script is an empty placeholder

`src/upgrades.ts:46–55` — The `pre200` function returns an empty result object with no migrations and no comment. It runs on every pre-2.0.0 upgrade path without doing anything. Either document why it is intentionally empty, or remove it (shifting subsequent script indices accordingly).

---

### NTH2 — `getOidsToPoll` getter uses `get` prefix (redundant for a getter)

`src/oidtracker.ts:149` — `get getOidsToPoll(): string[]` — the `get` prefix is redundant for a property getter. Call sites read as `this.oidTracker.getOidsToPoll` (no parentheses), making `get` in the name confusing.

**Consider:** Rename to `get oidsToPoll()` and update the single call site in `index.ts`.

---

## ⚠️ Pre-existing Notes

These issues were present in v2.3.0 (or earlier) and are non-blocking for this review.

---

### PE1 — `package.json` name missing `companion-module-` prefix

⚠️ **PRE-EXISTING**

`package.json` `name` is `"generic-snmp"`. Bitfocus convention requires the `companion-module-` prefix, making the correct name `"companion-module-generic-snmp"`. The GitHub repository already follows this convention. Present since at least v2.3.0.

**File:** `package.json:2`

---

### PE2 — `manifest.name` is a slug, not human-readable

⚠️ **PRE-EXISTING**

`manifest.name: "generic-snmp"` is an identifier slug, not a display name. The `id` field already carries `"generic-snmp"`. Companion shows `name` in the module browser and connection labels.

**Suggested value:** `"Generic SNMP"`  
**File:** `companion/manifest.json:4`

---

### PE3 — `manifest.apiVersion: "0.0.0"` — standard placeholder, auto-patched at build time

⚠️ **PRE-EXISTING** — NOT a regression

`"0.0.0"` in `manifest.runtime.apiVersion` is the standard source placeholder for v2.x Companion modules. `companion-module-build` (`yarn package`) automatically overwrites it with the actual `@companion-module/base` version at package time. Not an issue.

---

## 🧪 Tests

**Status:** ✅ Comprehensive test suite  
**Framework:** vitest v4.1.2  
**Results:** 329 / 329 tests passed in 249ms — zero failures, zero skipped  

| Test File | Tests |
|-----------|-------|
| `src/oidUtils.test.ts` | 72 |
| `src/oidtracker.test.ts` | 46 |
| `src/actions.test.ts` | 60 |
| `src/index.test.ts` | 40 |
| `src/wrapper.test.ts` | 34 |
| `src/config.test.ts` | 33 |
| `src/status.test.ts` | 22 |
| `src/feedbacks.test.ts` | 22 |

**Note:** Two `vi.mock()` calls in `config.test.ts` are inside `describe` blocks rather than at module top level. Vitest warns these will become errors in a future version (see L8).

---

## ✅ What's Solid

- **329/329 tests passing** across 8 test files — the most comprehensive test suite in this review batch. Every major module has unit coverage
- **Full v2.x API compliance** — No `isVisible` anywhere. `isVisibleExpression` applied throughout all action and feedback definitions. `checkFeedbacksById` (targeted) used for feedback invalidation instead of broadcast `checkFeedbacks`
- **Secrets properly isolated** — `authKey` and `privKey` in `ModuleSecrets` (`secret-text` fields) since the v2.3.0→v3.0.0 upgrade. Neither key is ever logged or exposed in the config object
- **`learn` callbacks** — Implemented on all applicable actions (`SetString`, `SetNumber`, `SetBoolean`, `SetIpAddress`, `SetOID`, `GetOID`, `TrapOrInform`). Absent only from `SetOpaque` (see L5) and send-only trap/inform actions where a read-back value makes no sense
- **`subscribe` callbacks** — All seven set/get actions register their OID immediately on feedback/action creation, priming the poll cache before the first evaluation
- **`pollGeneration` race-condition guard** — Correctly guards both the walk loop and the poll chain. Incremented before all async work in `configUpdated`/`destroy`, checked after every `await`. No stale poll results can apply to a new connection
- **`PQueue` with priority levels** — SNMP operations serialized (concurrency: 1) with priorities: set=1, get/walk=0, inform=2, trap=3. Appropriate for UDP-based SNMP; prevents race conditions on the shared session
- **Upgrade scripts** — `v230` correctly migrates `authKey`/`privKey` from config to `ModuleSecrets` using `updatedSecrets`. `v300` covers all renamed action and feedback IDs. Upgrade chain is intact for all prior versions
- **DES legacy provider guard** — Correctly detects `--openssl-legacy-provider` in `process.execArgv` and the `insecure-algorithms` manifest permission before allowing DES. Clear `InsufficientPermissions` status with a descriptive message if not available
- **Throttled/debounced UI updates** — `throttledFeedbackIdCheck` (30ms trailing) and `debouncedUpdateDefinitions` (1s) correctly batch Companion UI updates to avoid flooding during rapid SNMP data events
- **`SharedUDPSocketWrapper` IP filtering** — Source-address validation for received traps is correctly implemented via `allowedAddress`, cleanly separating transport concerns from application concerns
- **No `"companion"` keyword in manifest** — Keywords are `["Protocol", "Generic"]` — clean
- **Clean TypeScript architecture** — Typed `ActionSchema`/`FeedbackSchema`, `ModuleTypes`, `InstanceBaseExt`, and `satisfies` on options constants provide compile-time option-key safety throughout
