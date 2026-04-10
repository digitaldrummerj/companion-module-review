# Review: companion-module-soundcraft-ui v4.0.0

**Module:** companion-module-soundcraft-ui  
**Version reviewed:** v4.0.0  
**Previous tag:** v3.10.1  
**Review date:** 2026-04-09  
**Reviewers:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪  
**API:** v2.x (`@companion-module/base ~2.0.0`)  
**Language:** TypeScript ESM  

---

## Fix Summary

Two blocking issues must be resolved before this release can be approved, both rooted in `src/index.ts` connection lifecycle logic. First, `firstValueFrom(capabilities$)` in `createVariables` hangs indefinitely when the host is unreachable — v4.0.0 introduced this call inside `updateCompanionBits`, which is invoked unconditionally even after `connect()` fails, permanently stalling the async chain. Second, `subscribeConnectionStatus()` discards its `Subscription` return value, accumulating dangling subscriptions on every reconnect and causing the previous connection's Close event to incorrectly set status to `Disconnected` after a new connection has already succeeded. Both issues can be fixed together in a focused pass on `src/index.ts`.

One new Medium issue is also introduced: all nine `learn` callbacks that read dB fader levels return `-Infinity` (the library's representation of a silenced fader) without applying the `mapInfinityToNumber` conversion already used elsewhere in the module.

**Must fix before merge:**
1. `src/index.ts` — add early `return` after `updateStatus(ConnectionFailure)` in the catch block so `updateCompanionBits` is only called on successful connection
2. `src/index.ts` — store the `status$` subscription and unsubscribe it before each reconnect and in `destroy()`
3. `src/actions.ts` — apply `mapInfinityToNumber` to all nine dB `learn` callback return values

---

## 📊 Scorecard

| Area | Status |
|------|--------|
| `yarn build` | ✅ Clean |
| `yarn dist` | ✅ Clean (produces `soundcraft-ui-4.0.0.tgz`) |
| `yarn lint` | ✅ Clean — zero errors |
| `manifest.apiVersion` | ✅ `"0.0.0"` is standard placeholder — auto-patched to `"2.0.3"` by build tool |
| v2.x API compliance | ✅ No `isVisible` usage; `disableAutoExpression`, `learn`, `checkFeedbacksById` all correct |
| Tests | ⚠️ No tests (consistent with v3.10.1 — non-blocking) |
| Connection lifecycle | ❌ 2 blocking issues in `index.ts` |

| Severity | NEW | PRE-EXISTING |
|----------|-----|--------------|
| 🔴 Critical | 0 | 0 |
| 🟠 High | 2 | 0 |
| 🟡 Medium | 1 | 2 |
| 🟢 Low | 4 | 3 |
| 💡 NTH | 2 | 3 |
| **Blocking total** | **2** | **0** |

---

## ✋ Verdict

**❌ CHANGES REQUIRED — 2 blocking issues (2 High NEW)**

The v4.0.0 migration to `@companion-module/base ~2.0.0` is architecturally well-executed: the v2.x API is adopted correctly throughout (`isVisible` absent, `disableAutoExpression` applied, `learn` callbacks implemented across 25+ actions, typed schema generics, correct `setPresetDefinitions` signature), the new `UiFeedbackStore` targeted-update pattern is a genuine quality improvement over v3.x's broadcast approach, and the `UiVariablesStore` RxJS batching pipeline is well-constructed. The build and lint pipelines are clean.

However, two High-severity lifecycle bugs introduced by the v4.0.0 connection refactor must be fixed before release. The `firstValueFrom(capabilities$)` hang on connection failure is a silent deadlock that affects every user whose mixer is temporarily unreachable at startup. The subscription leak causes incorrect status flickers after config changes and accumulates dangling subscriptions over time. Both are straightforward one-to-three-line fixes in `src/index.ts`.

Fix the three items in the Fix Summary, re-run `yarn build`, `yarn dist`, and `yarn lint` to confirm all pass, and resubmit.

---

## 📋 Issues TOC

**🟠 High**
- [H1 — `firstValueFrom(capabilities$)` hangs indefinitely after connection failure](#h1--firstvaluefromcapabilities-hangs-indefinitely-after-connection-failure)
- [H2 — `status$` subscription never stored or unsubscribed; spurious status updates on reconnect](#h2--status-subscription-never-stored-or-unsubscribed-spurious-status-updates-on-reconnect)

**🟡 Medium**
- [M1 — `learn` callbacks return `-Infinity` for silenced faders](#m1--learn-callbacks-return--infinity-for-silenced-faders)
- [M2 — `void createConnection()` swallows all unhandled errors silently ⚠️ PRE-EXISTING](#m2--void-createconnection-swallows-all-unhandled-errors-silently)
- [M3 — `configUpdated` disconnect not awaited; race condition on host change ⚠️ PRE-EXISTING](#m3--configupdated-disconnect-not-awaited-race-condition-on-host-change)

**🟢 Low**
- [L1 — `mtkplayerstate` default uses wrong enum (`PlayerState` instead of `MtkState`)](#l1--mtkplayerstate-default-uses-wrong-enum-playerstate-instead-of-mtkstate)
- [L2 — Dev dependency versions lag behind `@companion-module/tools@3.0.0` peer requirements](#l2--dev-dependency-versions-lag-behind-companion-moduletools300-peer-requirements)
- [L3 — `patchingsetroute` silently drops USB-A restriction without logging](#l3--patchingsetroute-silently-drops-usb-a-restriction-without-logging)
- [L4 — `patchingroutestate` creates new Observable instance on every callback call](#l4--patchingroutestate-creates-new-observable-instance-on-every-callback-call)

**💡 Nice to Have**
- [NTH1 — `setfxbpm` default omits FX 1](#nth1--setfxbpm-default-omits-fx-1)
- [NTH2 — No tests for a 7 000-line v2.x migration](#nth2--no-tests-for-a-7-000-line-v2x-migration)

**⚠️ Pre-existing Notes**
- [PE1 — `manifest.name` not human-readable](#pe1--manifestname-not-human-readable)
- [PE2 — `package.json` name missing `companion-module-` prefix](#pe2--packagejson-name-missing-companion-module--prefix)
- [PE3 — `manifest.apiVersion: "0.0.0"` — standard placeholder, auto-patched at build time](#pe3--manifestapiversion-000--standard-placeholder-auto-patched-at-build-time)
- [PE4 — `configUpdated` TODO for reliable disconnect unresolved](#pe4--configupdated-todo-for-reliable-disconnect-unresolved)
- [PE5 — `conn.conn.sendMessage` internal API bypass in `patchingsetroute`](#pe5--connconnsendmessage-internal-api-bypass-in-patchingsetroute)
- [PE6 — Stale `.eslintrc.cjs` alongside modern `eslint.config.mjs`](#pe6--stale-eslintrccjs-alongside-modern-eslintconfigmjs)

---

## 🟠 High

### H1 — `firstValueFrom(capabilities$)` hangs indefinitely after connection failure

🆕 **NEW in v4.0.0** · **BLOCKING**

In `createConnection`, when `this.conn.connect()` throws (host unreachable, connection refused, timeout), the error is correctly caught and `InstanceStatus.ConnectionFailure` is set — but execution falls through unconditionally to `await this.updateCompanionBits(config)`:

```typescript
// src/index.ts
try {
    await this.conn.connect()
} catch (e) {
    this.updateStatus(InstanceStatus.ConnectionFailure, JSON.stringify(e))
    // ← no return; falls through
}
await this.updateCompanionBits(config)  // ← called even on failure
```

Inside `updateCompanionBits`, `createVariables` calls:

```typescript
// src/variables.ts
const capabilities = await firstValueFrom(conn.deviceInfo.capabilities$)
```

With a dead (never-connected) `conn`, the `capabilities$` observable never emits. `firstValueFrom` has no default timeout — it waits forever. The `createConnection` coroutine never resolves, permanently leaking the async execution context. Because `init` calls `createConnection` with `void`, the leak is silent.

This code path is **new in v4.0.0** — `createVariables` and the `firstValueFrom(capabilities$)` pattern were introduced in this release.

**Impact:** Every user who launches the module with an unreachable mixer (wrong IP, mixer off) hits a silent deadlock. If they subsequently change the host in `configUpdated`, a second `createConnection` is launched while the first is still hanging, creating two concurrent stale coroutines. Variable definitions, preset definitions, and feedback registration are all blocked for the life of that attempt.

**File:** `src/index.ts` lines 43–56, `src/variables.ts`  
**Fix:** Add an early `return` after `updateStatus(ConnectionFailure)` so `updateCompanionBits` only runs on successful connection:

```typescript
try {
    await this.conn.connect()
} catch (e) {
    this.updateStatus(InstanceStatus.ConnectionFailure, JSON.stringify(e))
    return   // ← ADD THIS
}
await this.updateCompanionBits(config)
```

Alternatively, protect `firstValueFrom(capabilities$)` with a `timeout()` operator and a safe `defaultValue` fallback.

---

### H2 — `status$` subscription never stored or unsubscribed; spurious status updates on reconnect

🆕 **NEW in v4.0.0** · **BLOCKING**

`subscribeConnectionStatus()` calls `this.conn.status$.subscribe(...)` but discards the returned `Subscription`:

```typescript
// src/index.ts
private subscribeConnectionStatus(): void {
    if (!this.conn) return
    this.conn.status$.subscribe((status) => {   // ← Subscription discarded
        switch (status.type) { ... }
    })
}
```

This RxJS subscription pattern is new in v4.0.0 (the reactive status pipeline was introduced as part of the v2.x migration). On every `configUpdated`, a new `SoundcraftUI` connection is created and `subscribeConnectionStatus()` is called again, adding a second subscription while the previous one is still live. The old subscription holds a closure over `this` (the live module instance) and fires `this.updateStatus(InstanceStatus.Disconnected)` when the old connection's socket closes — which happens **after** the new connection has already started connecting.

Additionally, `destroy()` has no cleanup for this subscription; if `status$` doesn't complete when the connection is torn down, the subscription may outlive the module instance.

**Impact:**
- After any config change (IP address, etc.), users see a spurious `Disconnected` flash while the module is actively reconnecting.
- Every `configUpdated` call accumulates one more dangling subscription.

**File:** `src/index.ts` — `subscribeConnectionStatus()`, `destroy()`  
**Fix:** Store the subscription and unsubscribe before replacing it:

```typescript
private statusSubscription?: Subscription  // import Subscription from 'rxjs'

private subscribeConnectionStatus(): void {
    this.statusSubscription?.unsubscribe()
    if (!this.conn) return
    this.statusSubscription = this.conn.status$.subscribe((status) => { ... })
}

async destroy(): Promise<void> {
    this.statusSubscription?.unsubscribe()
    this.feedbackStore.unsubscribeAll()
    this.variablesStore.destroy()
    if (this.conn) await this.conn.disconnect()
}
```

---

## 🟡 Medium

### M1 — `learn` callbacks return `-Infinity` for silenced faders

🆕 **NEW in v4.0.0**

All nine `learn` callbacks that read dB fader levels use `firstValueFrom(c.faderLevelDB$)` directly. The `soundcraft-ui-connection` library represents a fully silenced fader (fader at minimum) as `-Infinity`. When a user triggers Learn with the fader at minimum, the action option stores `-Infinity` — a value below the slider's defined `min: -100`, which Companion may clamp or reject, making the learned value incorrect.

The `variables-store.ts` already handles this correctly by applying `mapInfinityToNumber` before setting variable values. The same conversion is missing from all learn callbacks.

**Affected actions:** `setmastervalue`, `fademaster`, `setmasterchannelvalue`, `fademasterchannel`, `setauxchannelvalue`, `fadeauxchannel`, `setvolumebusvalue`, `setfxchannelvalue`, `fadefxchannel`  
**File:** `src/actions.ts` — lines 138, 159, 268, 298, 447, 477, 579, 652, 682  
**Fix:** Import `mapInfinityToNumber` in `actions.ts` and wrap the `firstValueFrom` result in each affected learn callback:

```typescript
learn: async () => ({
    value: mapInfinityToNumber(await firstValueFrom(conn.master.faderLevelDB$)),
})
```

---

### M2 — `void createConnection()` swallows all unhandled errors silently

⚠️ **PRE-EXISTING** (present in v3.10.1)

Both `init` and `configUpdated` call `void this.createConnection(config)` without attaching a `.catch()`. Any unhandled rejection beyond the `connect()` try/catch — such as an error thrown from `createPresets`, `setFeedbackDefinitions`, or any other async step in `updateCompanionBits` — is silently discarded. Node.js emits an `UnhandledPromiseRejection` warning, but the module's status is never updated and no log entry is created.

**File:** `src/index.ts` lines 35, 120  
**Recommendation:** Attach a `.catch()` handler to propagate errors to the module status and log:

```typescript
void this.createConnection(config).catch((e) => {
    this.log('error', `Connection setup error: ${String(e)}`)
    this.updateStatus(InstanceStatus.UnknownError, String(e))
})
```

---

### M3 — `configUpdated` disconnect not awaited; race condition on host change

⚠️ **PRE-EXISTING** (acknowledged TODO in source)

In `configUpdated`, `this.conn.disconnect()` is fired without `await` before `createConnection` starts. The new WebSocket connection begins opening before the old one finishes closing. Combined with H2 (the unmanaged subscription), the old connection's `Close` event fires `updateStatus(Disconnected)` after the new connection is already showing `Ok`.

```typescript
void this.conn.disconnect()       // ← not awaited
void this.createConnection(config)  // ← starts immediately
```

An existing TODO comment acknowledges that proper await is blocked by the connection library not yet exposing reliable disconnect state. As of v6.0.1, it is worth verifying whether this blocker has been resolved.

**File:** `src/index.ts` lines 101–109  
**Recommendation:** Verify whether `soundcraft-ui-connection` v6.0.1 now supports reliable disconnect state detection. If so, `await this.conn.disconnect()` and remove the TODO.

---

## 🟢 Low

### L1 — `mtkplayerstate` default uses wrong enum (`PlayerState` instead of `MtkState`)

🆕 **NEW in v4.0.0**

The `mtkplayerstate` feedback's dropdown uses `MtkState` values for its choices but `PlayerState.Playing` for the default:

```typescript
choices: [
    { id: MtkState.Stopped, label: 'Stopped' },  // = 0
    { id: MtkState.Playing, label: 'Playing' },  // = 2
    { id: MtkState.Paused,  label: 'Paused' },   // = 1
],
default: PlayerState.Playing,   // ← should be MtkState.Playing
```

Both enums share `Playing = 2`, so there is no functional impact today. However `PlayerState.Paused = 3` while `MtkState.Paused = 1` — if the default were ever changed to Paused, or if library enum values diverge, this would silently produce an incorrect default.

**File:** `src/feedback.ts` line 290  
**Fix:** `default: MtkState.Playing`. Remove the `PlayerState` import if no longer needed elsewhere in the file.

---

### L2 — Dev dependency versions lag behind `@companion-module/tools@3.0.0` peer requirements

🆕 **NEW in v4.0.0**

When `@companion-module/tools` was bumped from `^2.6.1` to `^3.0.0` in this release, the locked dev dependency versions were not updated to match the new peer requirements. `yarn install` reports three `YN0060` warnings:

| Package | Pinned version | Required by tools@3 |
|---------|---------------|---------------------|
| `eslint` | `^9.39.2` | `^9.39.3` |
| `prettier` | `^3.7.4` | `^3.8.1` |
| `typescript-eslint` | `^8.50.0` | `^8.56.1` |

Lint passes cleanly with the current versions, so there is no immediate functional impact.

**File:** `package.json`  
**Fix:** Bump the three packages to satisfy peer requirements. Run `yarn install && yarn lint` to confirm.

---

### L3 — `patchingsetroute` silently drops USB-A restriction without logging

🆕 **NEW in v4.0.0**

When a USB-A → HW OUT or cascade patching restriction is triggered, the action returns silently:

```typescript
if (source.startsWith('ua') && (destination.startsWith('hwout') || destination.startsWith('casc'))) {
    return  // ← no log, no user feedback
}
```

Users who configure a USB-A → HW OUT button see it appear to do nothing without any indication of why.

**File:** `src/actions.ts` lines 1321–1335  
**Fix:** Add a `this.log('warn', ...)` call before the early return to surface the restriction to the user.

---

### L4 — `patchingroutestate` creates new Observable instance on every callback call

🆕 **NEW in v4.0.0**

The `patchingroutestate` feedback constructs a new `feedback$` observable on every callback invocation, even though `ensureSubscription` short-circuits on unchanged `streamId`:

```typescript
callback: (evt) => {
    const feedback$ = conn.store.state$.pipe(map(...))  // ← new allocation every call
    store.ensureSubscription(evt.id, feedback$, streamId)  // early-returns if unchanged
    return store.getState(streamId)
}
```

Functionally correct; creates minor unnecessary GC pressure.

**File:** `src/feedback.ts` lines 366–378  
**Fix:** Move `feedback$` construction inside an options-change guard, or memoize by `streamId`.

---

## 💡 Nice to Have

### NTH1 — `setfxbpm` default omits FX 1

🆕 **NEW in v4.0.0**

The `setfxbpm` action's `multidropdown` default is `[2, 3, 4]`, skipping FX processor 1. New buttons using this action will not affect FX 1 by default.

**File:** `src/actions.ts` lines 726–729  
**Consider:** `default: [1, 2, 3, 4]` for symmetry with other multi-FX actions.

---

### NTH2 — No tests for a 7 000-line v2.x migration

🆕 **NEW in v4.0.0** (no tests added despite large change surface)

No test files are present (confirmed — consistent with v3.10.1). The scale and complexity of the v4.0.0 migration — new upgrade scripts, reworked feedback store, learn callbacks, variables store, percentage action variants — would benefit significantly from unit test coverage.

Key areas for future test coverage:
- `UiFeedbackStore` stream deduplication, multi-subscriber grouping, `unsubscribeAll`
- `upgradeRemoveStateFeedbackOption` v1/v2 dual-format option paths
- `learn` callbacks — verify correct option shapes and `mapInfinityToNumber` application
- Pan/dB value conversion utilities in `src/utils/utils.ts`

Consider adding `vitest` + `@companion-module/tools/vitest` in a follow-up release.

---

## ⚠️ Pre-existing Notes

These issues were present in v3.10.1 and are non-blocking for this review.

---

### PE1 — `manifest.name` not human-readable

⚠️ **PRE-EXISTING**

`manifest.name` is `"soundcraft-ui"` — a slug identifier, not a human-readable display name. Companion shows this field in the module browser and connection labels. Should be `"Soundcraft Ui"` or similar.

**File:** `companion/manifest.json`

---

### PE2 — `package.json` name missing `companion-module-` prefix

⚠️ **PRE-EXISTING**

`package.json` `name` is `"soundcraft-ui"`. Bitfocus convention requires the prefix, making the correct name `"companion-module-soundcraft-ui"`.

**File:** `package.json`

---

### PE3 — `manifest.apiVersion: "0.0.0"` — standard placeholder, auto-patched at build time

⚠️ **PRE-EXISTING** — NOT a regression

For v2.x Companion modules, `"0.0.0"` in `manifest.runtime.apiVersion` is the standard source placeholder. `companion-module-build` (`yarn dist`) automatically overwrites it with the actual `@companion-module/base` version at package time. Verified in the generated `soundcraft-ui-4.0.0.tgz`: `"apiVersion": "2.0.3"`. This is distinct from the rode-rcv regression where valid values were overwritten.

---

### PE4 — `configUpdated` TODO for reliable disconnect unresolved

⚠️ **PRE-EXISTING**

An existing TODO comment acknowledges that the proper connection-state check before calling `disconnect()` has been blocked by the connection library. With `soundcraft-ui-connection` updated to v6.0.1 in this release, it is worth verifying whether the blocker has been resolved upstream.

---

### PE5 — `conn.conn.sendMessage` internal API bypass in `patchingsetroute`

⚠️ **PRE-EXISTING** (introduced in v3.7.0)

`patchingsetroute` calls `conn.conn.sendMessage(...)` directly, bypassing the high-level façade and sending a raw wire-format string. Both `conn.conn` and `sendMessage` are typed `public`, so this is not strictly an encapsulation violation — but it ties the module to the library's internal message format. A dedicated `setPatchRoute` public API in `soundcraft-ui-connection` would be the correct long-term solution.

---

### PE6 — Stale `.eslintrc.cjs` alongside modern `eslint.config.mjs`

⚠️ **PRE-EXISTING**

Both the legacy CJS ESLint config (`.eslintrc.cjs`) and the modern flat config (`eslint.config.mjs`) are present. With ESLint v9 and flat config, `.eslintrc.cjs` is silently ignored. Dead code that may confuse contributors.

**Fix:** Delete `.eslintrc.cjs`.

---

## 🧪 Tests

**Status:** No tests found  
**Framework:** None installed (no Jest, Vitest, or Mocha in `devDependencies`; no test script in `package.json`)  
**Comparison to v3.10.1:** Identical — no tests present in prior version either  
**Policy:** Non-blocking (test absence consistent throughout project history)

---

## ✅ What's Solid

- **Full v2.x API compliance** — No `isVisible` usage anywhere. `disableAutoExpression: true` correctly applied to all enumerated dropdowns. `checkFeedbacksById` (targeted) used instead of global `checkFeedbacks`. `setPresetDefinitions(sections, presets)` v2 two-arg signature correct throughout
- **`learn` callbacks** — Implemented across 25+ applicable set/fade/pan actions. Correctly absent from relative ("change") actions where a read-back value has no meaning. Returns `Partial<options>` preserving expression state in unlearned fields — excellent coverage
- **`UiFeedbackStore` targeted update architecture** — The reworked stream-deduplication + `checkFeedbacksById` pattern is a meaningful performance improvement over v3.x's broadcast `checkFeedbacks()`. Multiple feedback instances sharing the same channel stream correctly share one RxJS subscription, and only the relevant IDs are invalidated per state change
- **`UiVariablesStore` batching pipeline** — `bufferTime(100)` + `reduce` pattern correctly coalesces rapid fader events into a single `setVariableValues` call per 100ms window. Two-Subject cleanup design (`destroyVariableStreams$` / `destroy$`) correctly supports reconnect without full store reconstruction
- **Upgrade script chain** — `upgradeRemoveStateFeedbackOption` dual-format handling (v1 plain boolean + v2 wrapped `{ isExpression, value }`) is thorough and safe. Upgrade index ordering is correct; existing user configs migrating from any prior version are properly handled
- **Typed schema pattern** — `UiSchema` generics drive `CompanionActionDefinitions<UiSchema>` and `CompanionFeedbackDefinitions<UiSchema>` throughout, providing compile-time option key safety
- **Build pipeline** — `yarn build`, `yarn dist`, and `yarn lint` all pass cleanly with zero output noise. `$schema` correctly added to manifest in this release
- **`*pct` percentage action variants** — All nine fader percent counterparts added; division-by-100 and `convertLinearValueToPercent` conversions are mathematically correct throughout
