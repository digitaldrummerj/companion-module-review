# Module Review: companion-module-talktome-intercom v0.1.7

**Review date:** 2026-04-09
**Reviewer team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪
**Module version:** v0.1.7 (first release — no previous tag)
**Language:** TypeScript (ESM — `"type": "module"`)
**API version:** v1.x (`@companion-module/base ~1.14.1`)
**Protocol:** HTTP REST (axios) + WebSocket (socket.io-client) — dual authentication modes (API key or user login)
**Source layout:** Multi-file — `src/main.ts` (1682 lines), `src/actions.ts` (271), `src/feedbacks.ts` (639), `src/presets.ts` (460), `src/variables.ts` (34), `src/config.ts` (82), `src/types.ts` (105), `src/upgrades.ts` (4)

---

## Fix Summary

A sophisticated, feature-rich first release with dual authentication, dynamic preset generation, real-time WebSocket state streaming, and thorough TypeScript typing throughout. The module ships with proper template scaffolding, Bitfocus repository URLs, correct `apiVersion`, and a build that passes cleanly. The quality bar is high.

One template compliance blocker requires immediate resolution: the `"companion"` keyword in `manifest.json` is explicitly banned. Four functional bugs also block merge: `refreshDefinitions()` is called on every real-time user-state event (including rapid PTT press/release) causing unnecessary definition rebuilds at intercom speeds; self-signed certificate support is silently broken for the socket.io polling transport fallback; entity ID `0` is silently rejected throughout actions and feedbacks due to a falsy `!id` check; and server-initiated socket disconnections (reason `'io server disconnect'`) are not handled, leaving the module permanently disconnected with no recovery path.

**Critical blocking work (must fix before merge):**
- Remove `"companion"` from `manifest.json` keywords
- Call `refreshDefinitions()` only on roster changes, not on every user-state event
- Fix socket.io self-signed TLS — pass `https.Agent` via `options.agent`, not `rejectUnauthorized` at root
- Replace all `if (!userId)` / `if (!conferenceId)` falsy checks with `=== null` after `resolveChoiceId`
- Handle `reason === 'io server disconnect'` in socket `'disconnect'` handler with explicit reconnect

---

## 📊 Scorecard

| Category | New | Existing | Total |
|----------|-----|----------|-------|
| 🔴 Critical | 1 | 0 | **1** |
| 🟠 High | 4 | 0 | **4** |
| 🟡 Medium | 12 | 0 | **12** |
| 🟢 Low | 9 | 0 | **9** |
| 💡 Nice to Have | 2 | 0 | **2** |
| **Total** | **28** | **0** | **28** |

**Blocking findings:** 5 (1 Critical + 4 High)
**Non-blocking findings:** 23 (12 Medium + 9 Low + 2 NTH)
**Build status:** ✅ PASS — `yarn install && yarn package` → `talktome-0.1.7.tgz`
**Test coverage:** No unit tests; substantive `scripts/smoke-test.cjs` integration test present (non-blocking)

---

## ✋ Verdict

> ### 🔴 CHANGES REQUIRED
>
> **5 blocking issues** (1 Critical template violation + 4 High functional bugs).
>
> The module is well-engineered and close to merge-ready. The blocking issues are targeted and fixable without architectural rework: remove the banned keyword, guard `refreshDefinitions()` calls behind a roster-change check, pass an `https.Agent` for TLS, fix the falsy ID check to `=== null`, and handle server-initiated disconnects. All other findings are non-blocking and can be addressed in a follow-up release.

---

## 📋 Issues TOC

### 🔴 Critical
- [C-1: Banned `"companion"` keyword in `manifest.json`](#c-1-banned-companion-keyword-in-manifestjson)

### 🟠 High
- [H-1: `refreshDefinitions()` called on every user-state WebSocket event — prohibitive at intercom speeds](#h-1-refreshdefinitions-called-on-every-user-state-websocket-event--prohibitive-at-intercom-speeds)
- [H-2: Socket TLS — `rejectUnauthorized` at root level silently broken for polling transport](#h-2-socket-tls--rejectunauthorized-at-root-level-silently-broken-for-polling-transport)
- [H-3: `resolveChoiceId` returns `0` but all callers use `!id` falsy check — entity ID 0 silently rejected](#h-3-resolvechoiceid-returns-0-but-all-callers-use-id-falsy-check--entity-id-0-silently-rejected)
- [H-4: `'io server disconnect'` not handled — permanent silent disconnection with no recovery](#h-4-io-server-disconnect-not-handled--permanent-silent-disconnection-with-no-recovery)

### 🟡 Medium
- [M-1: `ensureRealtimeConnection` swallows auth exception — no log, no status, socket stays dead](#m-1-ensurerealtimeconnection-swallows-auth-exception--no-log-no-status-socket-stays-dead)
- [M-2: Poller starts unconditionally after auth failure — uncapped 10-second retry loop](#m-2-poller-starts-unconditionally-after-auth-failure--uncapped-10-second-retry-loop)
- [M-3: `connect_error` reauth + `reconnection: true` create overlapping unbounded reconnect paths](#m-3-connect_error-reauth--reconnection-true-create-overlapping-unbounded-reconnect-paths)
- [M-4: `manifest.json` `name` field not human-readable](#m-4-manifestjson-name-field-not-human-readable)
- [M-5: `mergeUserState` destructive bool merge — partial event silently marks user offline](#m-5-mergeuserstate-destructive-bool-merge--partial-event-silently-marks-user-offline)
- [M-6: `keepState: true` + `resetAuthContext()` flashes empty dropdowns during reconnect](#m-6-keepstate-true--resetauthcontext-flashes-empty-dropdowns-during-reconnect)
- [M-7: `destroy()` doesn't reset `lastCommand` — `last_command_failed` feedback persists across lifecycle](#m-7-destroy-doesnt-reset-lastcommand--last_command_failed-feedback-persists-across-lifecycle)
- [M-8: HTTP 403 not treated as `authFailure` — sets wrong `ConnectionFailure` status](#m-8-http-403-not-treated-as-authfailure--sets-wrong-connectionfailure-status)
- [M-9: `password` declared in both `ModuleConfig` and `ModuleSecrets` — plain-config fallback undermines secret isolation](#m-9-password-declared-in-both-moduleconfig-and-modulesecrets--plain-config-fallback-undermines-secret-isolation)
- [M-10: 7 feedbacks use raw numeric `targetId` input — inconsistent with action dropdowns](#m-10-7-feedbacks-use-raw-numeric-targetid-input--inconsistent-with-action-dropdowns)
- [M-11: `executeTallyCommand` status-check block is dead code — `apiRequest` already throws](#m-11-executetallycommand-status-check-block-is-dead-code--apirequest-already-throws)
- [M-12: `executeTalkCommand` silently omits `targetId` for `reply` type — undocumented implicit contract](#m-12-executetalkcommand-silently-omits-targetid-for-reply-type--undocumented-implicit-contract)

### 🟢 Low
- [L-1: `clampUnitInterval` duplicated in `main.ts` and `feedbacks.ts`](#l-1-clampunitinterval-duplicated-in-maints-and-feedbacksts)
- [L-2: Auth detection in action error handler uses `'auth'` substring match](#l-2-auth-detection-in-action-error-handler-uses-auth-substring-match)
- [L-3: `definitions` array untyped (`never[]`) in `variables.ts`](#l-3-definitions-array-untyped-never-in-variablests)
- [L-4: `executeTallyCommand` uses unversioned `/cut-camera` API path](#l-4-executetallycommand-uses-unversioned-cut-camera-api-path)
- [L-5: `resetAuthContext()` called redundantly in `reconnect()` after `cleanup()` already calls it](#l-5-resetauthcontext-called-redundantly-in-reconnect-after-cleanup-already-calls-it)
- [L-6: `user_cut_camera` feedback uses name-based match — fragile if user name changes](#l-6-user_cut_camera-feedback-uses-name-based-match--fragile-if-user-name-changes)
- [L-7: 16 of 18 feedbacks missing `description` field](#l-7-16-of-18-feedbacks-missing-description-field)
- [L-8: `asString` imported but unused in `variables.ts`](#l-8-asstring-imported-but-unused-in-variablests)
- [L-9: Smoke test has significant coverage gaps and environment dependencies](#l-9-smoke-test-has-significant-coverage-gaps-and-environment-dependencies)

### 💡 Nice to Have
- [N-1: `manifest.json` `name` and `shortname` — set human-readable label after metadata fix](#n-1-manifestjson-name-and-shortname--set-human-readable-label-after-metadata-fix)
- [N-2: Extract transport, state, and command logic from 1682-line God class](#n-2-extract-transport-state-and-command-logic-from-1682-line-god-class)

---

## 🔴 Critical

### C-1: Banned `"companion"` keyword in `manifest.json`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `companion/manifest.json`

The keyword `"companion"` is explicitly banned by Companion module submission guidelines. Every Companion module is by definition a Companion module; including the keyword pollutes the module browser search index.

**Found:**
```json
"keywords": ["intercom", "ptt", "companion", "talktome"]
```

**Recommendation:** Remove `"companion"` from the keywords array:
```json
"keywords": ["intercom", "ptt", "talktome"]
```

---

## 🟠 High

### H-1: `refreshDefinitions()` called on every user-state WebSocket event — prohibitive at intercom speeds

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `src/main.ts` — `applyUserState()` (~line 933)

`applyUserState()` calls `refreshDefinitions()` on every `user-state` WebSocket event. `refreshDefinitions()` in turn calls all four Companion SDK definition-set methods: `setVariableDefinitions()`, `setActionDefinitions()`, `setFeedbackDefinitions()`, `setPresetDefinitions()`. In a real-time intercom, `user-state` events fire on every PTT press, release, volume change, and talk-lock toggle — potentially many times per second per connected user.

**Evidence:**
```typescript
applyUserState(rawState: unknown): void {
    // ...
    this.refreshChoiceCaches()
    this.refreshDefinitions()           // ← rebuilds ALL 4 definition sets on every event
    this.updateVariableValuesFromState()
    this.checkFeedbacks(...)
}
```

Definitions (actions, feedbacks, presets, variables) only need to be rebuilt when the **roster changes** — a user comes online/offline, conferences are added/removed, or feed assignments change. Runtime state changes (who's talking, mute state, locked) should only trigger `updateVariableValuesFromState()` and `checkFeedbacks()`.

**Impact:** Sustained PTT activity (press+hold by multiple operators) causes continuous action/feedback/preset re-registration, which can interrupt open button-configuration dialogs in the Companion UI and causes measurable CPU overhead during active sessions.

**Recommendation:** Track whether `refreshChoiceCaches()` detected an actual roster change (new/removed entries), and only call `refreshDefinitions()` when a structural change occurred:
```typescript
const rosterChanged = this.refreshChoiceCaches()   // returns boolean
if (rosterChanged) this.refreshDefinitions()
this.updateVariableValuesFromState()
this.checkFeedbacks(...)
```

---

### H-2: Socket TLS — `rejectUnauthorized` at root level silently broken for polling transport

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `src/main.ts` (~line 638–651), `src/types.ts:638`

The `allowSelfSigned` config option uses `rejectUnauthorized: false` placed at the root of the socket.io options object:

```typescript
const options: Record<string, unknown> = {
    transports: ['websocket', 'polling'],
    // ...
}
if (this.config.allowSelfSigned) {
    options.rejectUnauthorized = false    // ← root-level, NOT in an https.Agent
}
this.socket = io(socketUrl, options)
```

For the **WebSocket** transport, `ws` reads `rejectUnauthorized` from root options and this works. For the **HTTP polling** fallback transport, socket.io-client constructs HTTPS requests via Node's `https` module and does **not** pick up `rejectUnauthorized` from root-level options without an explicit `agent`. This stands in direct contrast to the axios client, which correctly uses `httpsAgent: new https.Agent({ rejectUnauthorized: ... })`.

Additionally, the options object is typed as `Record<string, unknown>` instead of `Partial<ManagerOptions & SocketOptions>`, bypassing TypeScript's type safety for socket.io option validation.

**Impact:** When the WebSocket upgrade fails (firewalled networks, some proxies) and polling becomes the active transport, connections to servers with self-signed certificates fail with a TLS error even when `allowSelfSigned: true` is configured. The module appears to work normally (WebSocket succeeds) in most environments but silently breaks in fallback scenarios that are common on private intercom infrastructure.

**Recommendation:** Mirror the axios approach — create an `https.Agent` and pass it via `options.agent`, and use the correct TypeScript type:
```typescript
const socketOptions: Partial<ManagerOptions & SocketOptions> = {
    transports: ['websocket', 'polling'],
    timeout: FIXED_HTTP_TIMEOUT_MS,
    auth: socketAuth,
    extraHeaders: requestAuthHeaders,
    reconnection: true,
    reconnectionDelayMax: 5000,
    agent: new https.Agent({ rejectUnauthorized: !this.config.allowSelfSigned }),
}
```

---

### H-3: `resolveChoiceId` returns `0` but all callers use `!id` falsy check — entity ID 0 silently rejected

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:1401–1411`, `src/feedbacks.ts` (multiple)

`resolveChoiceId` returns `0` for a numeric ID of `0` — the guard only rejects negatives:
```typescript
resolveChoiceId(rawValue: unknown): number | null {
    const id = Number(rawValue)
    if (!Number.isFinite(id) || id < 0) return null
    return id    // ← correctly returns 0 for input 0
}
```

Every single call-site uses a falsy check that treats `0` identically to `null`:
```typescript
const userId = this.resolveChoiceId(options.userId)
if (!userId) {                    // !0 === true — silently rejects entity ID 0
    throw new Error('Invalid user')
}
```

This pattern appears throughout: `executeTalkCommand`, `executeTargetAudioCommand`, `executeTallyCommand`, and multiple feedback callbacks in `feedbacks.ts`. The `PLACEHOLDER_*` IDs are all `-1` (correctly rejected by `id < 0`), but a server entity with ID `0` — valid per the current guard logic — will be silently rejected everywhere.

**Recommendation:** Replace all `if (!userId)` / `if (!conferenceId)` / `if (!targetId)` guards with explicit null checks:
```typescript
if (userId === null) {
    throw new Error('Invalid user')
}
```
Apply consistently across all call-sites in `main.ts` and `feedbacks.ts`.

---

### H-4: `'io server disconnect'` not handled — permanent silent disconnection with no recovery

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `src/main.ts` — `disconnect` handler (~line 661)

Per the socket.io specification, when `reason === 'io server disconnect'` (the server explicitly terminates the socket — e.g., on auth revocation, token expiry, or session invalidation), **socket.io will NOT auto-reconnect**. The module's `disconnect` handler does not inspect the reason:

```typescript
this.socket.on('disconnect', (reason) => {
    this.connectionState = 'disconnected'
    this.updateStatus(InstanceStatus.Disconnected, reason || 'Socket disconnected')
    // No reconnect attempt — relies solely on socket.io auto-reconnect
    // ← socket.io does NOT auto-reconnect when reason === 'io server disconnect'
})
```

When the server terminates the socket intentionally (auth revocation, server-side session cleanup), the module remains permanently in `'disconnected'` state until the operator manually changes config or restarts Companion. The poller's `refreshSnapshot` path could theoretically recover via `ensureRealtimeConnection()` — but only if the snapshot succeeds, which requires a valid auth token; for `'io server disconnect'` due to token revocation, the entire chain fails silently.

**Recommendation:** Check `reason` in the `disconnect` handler and schedule an explicit reconnect for server-initiated disconnects:
```typescript
this.socket.on('disconnect', (reason) => {
    this.connectionState = 'disconnected'
    this.updateStatus(InstanceStatus.Disconnected, reason || 'Socket disconnected')
    if (reason === 'io server disconnect') {
        this.log('warn', 'Server closed the socket — scheduling reconnect')
        setTimeout(() => this.reconnect(), 5000)
    }
})
```

---

## 🟡 Medium

### M-1: `ensureRealtimeConnection` swallows auth exception — no log, no status, socket stays dead

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:586–591`

When `applySocketAuthContext()` throws (because `authToken` is empty in credential mode), the catch block silently returns:

```typescript
try {
    this.applySocketAuthContext()
} catch (_error) {
    return    // ← no log, no status update, socket never connected
}
```

Additionally, in the `!this.socket` branch, `connectRealtime()` is called without a try-catch — if `getAuthHeaders()` throws synchronously, the exception propagates uncaught to any async caller (e.g., the `.then()` chain in the `connect_error` handler), potentially causing an unhandled rejection.

From the operator's perspective, the module appears stuck with no diagnostic information.

**Recommendation:** Log and update status in both failure paths:
```typescript
try {
    this.applySocketAuthContext()
} catch (error) {
    this.log('warn', `Socket auth context unavailable: ${(error as Error).message}`)
    this.updateStatus(InstanceStatus.AuthenticationFailure, 'Socket auth context unavailable')
    return
}
```

---

### M-2: Poller starts unconditionally after auth failure — uncapped 10-second retry loop

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:395–419`

`startPoller()` is always called at the end of `reconnect()` even when `connectionState` is `'auth_failure'`. The poller fires every 10 seconds, calls `refreshSnapshot('poll')`, which calls `refreshCredentialSession()`, which calls `authenticateWithCredentials()`. This generates one failed auth attempt every 10 seconds indefinitely with no backoff or stop condition.

**Impact:** On a production intercom system with misconfigured credentials, this produces sustained server-side load and risks triggering credential lockout mechanisms.

**Recommendation:** Skip `refreshSnapshot('startup')` immediately after auth failure (the initial attempt already failed and logged the error), and add a guard in the poll callback to skip re-authentication when already in `'auth_failure'` state.

---

### M-3: `connect_error` reauth + `reconnection: true` create overlapping unbounded reconnect paths

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:668–690`

When a `connect_error` containing "auth" fires, the handler calls `refreshCredentialSession()` then `ensureRealtimeConnection()` — triggering a manual `socket.connect()`. Meanwhile, socket.io's `reconnection: true` (no `reconnectionAttempts` limit — defaults to `Infinity`) also schedules its own reconnect with `reconnectionDelayMax: 5000`. Both paths fire simultaneously.

The `reauthPromise` guard prevents concurrent reauth requests but not sequential ones. Under sustained failures, each new `connect_error` event spawns a fresh sequential reauth + reconnect, producing a reauth attempt at least every 5 seconds indefinitely.

**Recommendation:** Either add a `reconnectionAttempts` cap (e.g., `20`) to socket.io options, or avoid calling `ensureRealtimeConnection()` after manual reauth when socket.io's own reconnection manager is already active.

---

### M-4: `manifest.json` `name` field not human-readable

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `companion/manifest.json`

`"name": "talktome"` renders in the Companion module browser as the primary label. It gives no indication of what the module does (intercom control). The `shortname` is identical to `name` (8 chars), providing no added value as a short label.

**Found:** `"name": "talktome"`, `"shortname": "talktome"`
**Recommendation:** Set `"name": "talktome Intercom"`. After that change, `"shortname": "talktome"` serves its intended purpose as the abbreviated label and needs no change.

---

### M-5: `mergeUserState` destructive bool merge — partial event silently marks user offline

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:977`

`mergeUserState` uses `Boolean(raw.field)` for all boolean fields without checking field presence:

```typescript
target.online = Boolean(raw.online)       // Boolean(undefined) === false
target.talking = Boolean(raw.talking)     // same
target.talkLocked = Boolean(raw.talkLocked)  // same
```

If the server sends a partial `user-state` event (e.g., only updating `talking` or audio states), missing boolean fields are coerced to `false`, destructively overwriting previously `true` values. A user who was `online: true` would appear as `online: false` after any partial update, disabling all associated `user_online`, `user_talking`, and audio feedbacks.

**Recommendation:** Guard each boolean assignment with a field-presence check:
```typescript
if ('online' in raw) target.online = Boolean(raw.online)
if ('talking' in raw) target.talking = Boolean(raw.talking)
if ('talkLocked' in raw) target.talkLocked = Boolean(raw.talkLocked)
```

---

### M-6: `keepState: true` + `resetAuthContext()` flashes empty dropdowns during reconnect

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:374–378`

During `reconnect()`:
```typescript
await this.cleanup({ keepState: true })   // preserves this.users, conferences, feeds
this.resetAuthContext()                    // sets scopeUserId = null, scopeMode = 'self'
this.refreshChoiceCaches()                 // getScopedUsers() returns [] — scopeUserId is null!
this.refreshDefinitions()                  // rebuilds all UI with EMPTY choices
```

`resetAuthContext()` sets `scopeUserId = null`. `getScopedUsers()` in `'self'` mode with no `scopeUserId` returns `[]`. The definitions are immediately rebuilt with empty user/conference/feed choices — overwriting the preserved `this.users` data. Every Companion button shows placeholder text until re-auth completes and `applyScope()` restores `scopeUserId`. This flash can persist for several seconds.

**Recommendation:** Call `refreshChoiceCaches()` and `refreshDefinitions()` after auth is restored (inside `applyScope()`), not immediately after `resetAuthContext()`.

---

### M-7: `destroy()` doesn't reset `lastCommand` — `last_command_failed` feedback persists across lifecycle

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:181–187`

`cleanup({ keepState: false })` clears users, conferences, feeds, and targets — but `this.lastCommand` is never reset. If `lastCommand.status === 'failed'` when the module is destroyed and immediately re-initialized, the `last_command_failed` feedback fires `true` from the very first frame of the new instance. This is stale state from the previous lifecycle.

**Recommendation:** Add `this.lastCommand = null` (or a neutral initial value) in `cleanup()`.

---

### M-8: HTTP 403 not treated as `authFailure` — sets wrong `ConnectionFailure` status

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:494–537`

In `apiRequest`, HTTP `401` is specially handled as an auth failure (triggering credential re-auth and setting `error.authFailure = true`). HTTP `403 Forbidden` falls through to the generic handler with `authFailure` unset. Callers like `refreshSnapshot` check `companionError.authFailure` to distinguish auth failures from connection failures — a `403` (semantically: authenticated but not authorized) is treated as `ConnectionFailure` instead of `AuthenticationFailure`.

This matters for the API key auth path, where a wrong or revoked API key may return `403`. Operators see "Connection failure" instead of "Authentication failure", providing the wrong diagnostic direction.

**Recommendation:** Set `error.authFailure = true` for `403` responses in `apiRequest`, alongside `401`.

---

### M-9: `password` declared in both `ModuleConfig` and `ModuleSecrets` — plain-config fallback undermines secret isolation

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **Files:** `src/types.ts`, `src/main.ts:209`

`password` is declared in both `ModuleConfig` (plain, serialised to disk) and `ModuleSecrets` (encrypted store), with a runtime fallback reading from plain config:

```typescript
password: asString(safeSecrets.password || safeConfig.password),
```

A password configured via the plain-config path is persisted with the same security as other unencrypted config fields, bypassing the purpose of the `ModuleSecrets` subsystem.

**Recommendation:** If the `safeConfig.password` fallback is needed for migration from pre-secrets configs, document it explicitly with a comment and consider a `UpgradeScripts` entry to migrate stored passwords to the secrets store. Long-term, remove `password` from `ModuleConfig` entirely.

---

### M-10: 7 feedbacks use raw numeric `targetId` input — inconsistent with action dropdowns

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/feedbacks.ts` — `user_talking_target`, `target_muted`, `target_volume_bar`, `target_online`, `target_offline`, `target_addressed_now`, `last_target_offline`

Seven feedbacks expose `targetId` as a raw `number` input (`min: 1, max: 100000`), requiring operators to know and manually enter internal numeric server IDs. The corresponding actions (`send_talk_command`, `change_target_volume`, `mute_target`) use dynamically-populated `targetConferenceId` and `targetUserId` dropdowns. This creates an inconsistent and operator-hostile UX for the same underlying concept.

**Recommendation:** Replace the `targetId: number` field pattern in affected feedbacks with `targetType`-conditional dropdowns (`targetConferenceId` / `targetUserId`) using `isVisibleExpression`, matching the action definition pattern.

---

### M-11: `executeTallyCommand` status-check block is dead code — `apiRequest` already throws

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:1620–1626`

`apiRequest` already throws a `CompanionError` for any non-2xx HTTP response. The following block in `executeTallyCommand` is therefore unreachable:

```typescript
if (response.status < 200 || response.status >= 300) {   // UNREACHABLE
    // ...
    throw error
}
```

This creates a false impression that non-2xx responses are handled at the call-site level, and is a future maintenance hazard — if `apiRequest`'s throw behaviour is ever changed, this block could start double-throwing.

**Recommendation:** Remove the dead code block. Add a comment if future behaviour might differ.

---

### M-12: `executeTalkCommand` silently omits `targetId` for `reply` type — undocumented implicit contract

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:1428–1440`

The action definition exposes `'reply'` as a valid `targetType`. In `executeTalkCommand`, there is no branch for `'reply'`, so `payload.targetId` is never set for reply targets:

```typescript
if (targetType === 'conference') {
    payload.targetId = conferenceId
} else if (targetType === 'user') {
    payload.targetId = targetUserId
}
// 'reply' falls through — payload.targetId is undefined
```

The command is sent with no `targetId`, relying on the server to resolve the reply target from session context. This appears intentional (confirmed by preset generation), but there is no comment, no validation, and no guard. If the server's reply resolution semantics change, these commands fail silently with no client-side indication.

**Recommendation:** Add an explicit comment for the `reply` case explaining the intentional omission:
```typescript
// 'reply' target is resolved server-side from the active reply source; no targetId sent
```

---

## 🟢 Low

### L-1: `clampUnitInterval` duplicated in `main.ts` and `feedbacks.ts`

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **Files:** `src/main.ts:79`, `src/feedbacks.ts:15`

The two functions are byte-for-byte identical. This is a symptom of pure utility functions being defined in `main.ts` and injected into sub-modules as deps (to avoid circular imports), forcing `feedbacks.ts` to duplicate the helper it cannot directly import.

**Recommendation:** Extract `clampUnitInterval`, `asString`, `truncateLabel`, `clampNumber`, `asObject`, and `toCompanionError` into a shared `src/utils.ts`. Import directly in all consuming files to eliminate both the duplication and the DI-passing of non-instance-specific functions.

---

### L-2: Auth detection in action error handler uses `'auth'` substring match

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/actions.ts:30–33`

```typescript
if (message.toLowerCase().includes('auth')) {
    self.connectionState = 'auth_failure'
    self.updateStatus(InstanceStatus.AuthenticationFailure, message)
}
```

Auth-failure classification uses a string heuristic inconsistent with the rest of the codebase, which propagates `error.authFailure = true` as a typed boolean. An unrelated error containing "auth" (e.g., `"Cannot authorize feed change"`) incorrectly triggers `AuthenticationFailure` status.

**Recommendation:** Replace with the typed flag check used elsewhere: `if ((rawError as CompanionError).authFailure === true)`

---

### L-3: `definitions` array untyped (`never[]`) in `variables.ts`

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/variables.ts:9`

```typescript
const definitions = []    // TypeScript infers never[] in strict mode
```

TypeScript widens this to `never[]` (strict) or `any[]` (loose), giving no type safety on the subsequent `push`. A misspelled or missing field would be a silent runtime issue.

**Recommendation:**
```typescript
import type { CompanionVariableDefinition } from '@companion-module/base'
const definitions: CompanionVariableDefinition[] = []
```

---

### L-4: `executeTallyCommand` uses unversioned `/cut-camera` API path

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:1613`

Every other API call uses `/api/v1/companion/...`. The tally command hits `/cut-camera` at the root, bypassing the versioned API hierarchy. If this is intentional (separate legacy subsystem), it should be documented with a comment. Future server-side API versioning could break this silently.

**Recommendation:** Add an inline comment explaining why this endpoint differs from the versioned API paths.

---

### L-5: `resetAuthContext()` called redundantly in `reconnect()` after `cleanup()` already calls it

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/main.ts:375–377`

`cleanup()` calls `this.resetAuthContext()` internally. The explicit `this.resetAuthContext()` call on the next line in `reconnect()` is harmless but misleading, implying `cleanup()` does not handle it.

**Recommendation:** Remove the redundant call and add a comment to `cleanup()` documenting that it resets auth context.

---

### L-6: `user_cut_camera` feedback uses name-based match — fragile if user name changes

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/feedbacks.ts:617–622`

```typescript
return Boolean(user?.name && self.cutCameraUser && user.name === self.cutCameraUser)
```

`cutCameraUser` is set from the server's `/cut-camera` response. If a user's display name is changed on the server between when the tally was set and when the feedback is evaluated, the name no longer matches and the feedback silently returns `false`. An ID-based comparison would be more reliable — though this may be a constraint of the `/cut-camera` API.

**Recommendation:** Add an inline comment noting this is a server-API constraint. If the tally response includes a user ID, prefer ID-based comparison.

---

### L-7: 16 of 18 feedbacks missing `description` field

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/feedbacks.ts`

Only 2 of the 18 feedback definitions include a `description` field. Descriptions appear as tooltips in the Companion feedback picker and significantly improve discoverability for operators unfamiliar with the module.

**Recommendation:** Add a brief `description` to each feedback definition describing when it activates.

---

### L-8: `asString` imported but unused in `variables.ts`

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `src/variables.ts`

`asString` is imported from `deps` but never called in the function body. This should be caught by the ESLint `no-unused-vars` rule.

**Recommendation:** Remove the unused `asString` import from the destructured deps parameter.

---

### L-9: Smoke test has significant coverage gaps and environment dependencies

- **Severity:** 🟢 Low
- **Classification:** 🆕 NEW
- **File:** `scripts/smoke-test.cjs`

The smoke test is well-structured and covers auth, scoping, and socket event round-trips. However, several high-value paths are untested:

| Gap | Risk |
|-----|------|
| Successful talk command (press → release) | Core PTT flow never validated end-to-end |
| Credential re-auth flow (token expiry → refresh → retry) | One of the most complex code paths |
| `'io server disconnect'` handling | H-4 (permanent disconnect bug) would go undetected |
| `last_command_failed` state transition | `lastCommand` state management not covered |
| `disconnect` + auto-reconnect | Reconnect path not simulated |
| Mute-toggle + state reflection | `target_muted` feedback not validated |
| `send_tally` clear action | Tally clear path untested |

The test also requires the talktome server repo to be co-located on disk and `better-sqlite3` to be compatible with the running node binary. Both prerequisites fail silently in isolated CI environments without `TALKTOME_REPO_ROOT` set.

---

## 💡 Nice to Have

### N-1: `manifest.json` `name` and `shortname` — set human-readable label after metadata fix

- **Severity:** 💡 Nice to Have
- **File:** `companion/manifest.json`

After M-4 is resolved: set `"name": "talktome Intercom"`. `"shortname": "talktome"` then correctly serves as the abbreviated label with no additional change needed.

---

### N-2: Extract transport, state, and command logic from 1682-line God class

- **Severity:** 💡 Nice to Have
- **File:** `src/main.ts`

`TalkToMeCompanionInstance` directly owns transport/auth (~200 lines), state normalisation (~120 lines), query helpers (~190 lines), command execution (~240 lines), and Companion bridge logic — all in 1682 lines. This makes unit testing impossible without a full `InstanceBase` mock.

**Suggested decomposition for a future release:**
1. `TalkToMeApiClient` — HTTP requests + auth (no Companion deps, unit-testable)
2. `src/state.ts` — pure normalisation/query functions (no Companion deps, no side-effects)
3. `TalkToMeCompanionInstance` — thin orchestrator wiring the two together

---

## 🔮 Next Release

- Implement unit tests for `resolveChoiceId`, `mergeUserState`, and command executor logic (now impossible without mocking `InstanceBase` — follow N-2 first)
- Add `description` to all feedback definitions (see L-7)
- Replace raw `targetId` number inputs in feedbacks with dropdowns (see M-10)
- Extract shared utilities to `src/utils.ts` to eliminate duplication (see L-1, N-2)
- Consider a `reconnectionAttempts` cap in socket.io config to bound retry behavior (see M-3)

---

## 🧪 Tests

**Unit tests:** None found (`*.test.ts`, `*.spec.ts`, `__tests__/`). No `test` script in `package.json`.

**Smoke test:** `scripts/smoke-test.cjs` — substantive integration test covering auth (API key, admin, operator with scoped access), WebSocket event round-trips, user/conference management, and target assignment validation. Requires a co-located talktome server instance.

**Status: ✅ Non-blocking.** For a first-release module of this complexity the smoke test demonstrates genuine integration coverage. See L-9 for gaps to address in a future release.

---

## ✅ What's Solid

- **Dual authentication model** — API key and user login with dynamic scoping is a sophisticated and well-implemented feature; the `reauthPromise` deduplication guard correctly prevents concurrent re-auth races
- **TypeScript throughout** — well-typed interfaces (`ModuleConfig`, `ModuleSecrets`, `UserState`, `CompanionError`), typed error propagation via `CompanionError.authFailure`, and strong use of generics
- **`cleanup()` correctly calls `socket.removeAllListeners()`** before nulling the socket — no event handler memory leaks
- **`Promise.allSettled`-style resilience** — `refreshTargetsForUsers` handles per-user fetch failures without aborting the entire roster refresh
- **Substantive presets** — dynamic per-user folders with REPLY, PTT, and Audio rotary presets; rotary volume control with visual bar is polished and user-friendly
- **`AbortSignal.timeout`-equivalent** — axios `timeout: FIXED_HTTP_TIMEOUT_MS` on every request ensures no indefinitely-hanging HTTP calls
- **`reauthPromise` dedup** — concurrent credential re-auth requests are correctly collapsed into one; subsequent callers await the same promise
- **`applyCommandResult`** correctly handles the socket `command-result` event to close the command feedback loop
- **Error propagation is typed** — `toCompanionError` normalises axios errors into a typed `CompanionError` structure with `statusCode`, `authFailure`, and `responseData`, enabling callers to branch cleanly
- **`UpgradeScripts = []` correctly wired** for first release
- **`legacyIds: ["talktome-intercom"]`** — demonstrates awareness of module ID migration conventions; existing installations will upgrade cleanly
- **`HELP.md` is comprehensive** — covers connection, actions, presets, feedbacks, and variables in detail
- **`eslint.config.mjs` configured** — active linting with `typescript-eslint`; code quality enforcement is in place
