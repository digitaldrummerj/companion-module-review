# Review: behringer-wing v2.3.0

| Field | Value |
|-------|-------|
| **Module** | companion-module-behringer-wing |
| **Version** | v2.3.0 |
| **Previous Tag** | v2.3.0-beta.2 |
| **Language** | TypeScript |
| **API** | v1.x (`@companion-module/base ~1.13`) |
| **Protocol** | OSC over UDP (Behringer WING mixer) |
| **Review Date** | 2026-04-10 |
| **Reviewed By** | Mal, Wash, Kaylee, Zoe, Simon |

---

## 🛠️ Fix Summary for Maintainer

This release ships a **critical regression** and multiple **template compliance violations** that block approval. The functional scope of v2.3.0 is small (fader floor guards + version bump), but the `src/index.ts` change accidentally removed the connection error status update, making all OSC socket failures invisible in the Companion UI. Additionally, the floor guard logic is placed incorrectly — it clamps the current value before applying the delta, which means normal negative delta operations still overshoot the floor. These two new issues plus nine pre-existing template compliance gaps all need to be addressed before this release can be approved.

**Fixes required for approval:**

1. **C1 — Restore `updateStatus(InstanceStatus.ConnectionFailure)` in the connection error handler** (`src/index.ts:157`)
2. **C2 — Add `.gitattributes`** with `* text=auto eol=lf`
3. **C3 — Fix `.gitignore`** — replace `/pkg.tgz` with `/*.tgz`, remove `.DS_Store`, add `/.vscode`
4. **C4 — Add `engines` block** to `package.json` (`node: "^22.20"`, `yarn: "^4"`)
5. **C5 — Fix `repository.url`** in `package.json` to `git+https://github.com/bitfocus/companion-module-behringer-wing.git`
6. **C6 — Add `$schema`** to `companion/manifest.json`
7. **C7 — Update `manifest.json` `runtime.type`** from `"node18"` to `"node22"`
8. **C8+C9 — Rename `src/index.ts` → `src/main.ts`** and update `manifest.json` entrypoint to `"../dist/main.js"` and `package.json` `main` to `"dist/main.js"`
9. **C10 — Update `tsconfig.build.json`** extends from `node18` to `node22`
10. **H1 — Move floor guard after delta** in `common.ts` and `matrix.ts` (`targetValue += delta` first, then clamp)

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 9 | 10 |
| 🟠 High | 2 | 1 | 3 |
| 🟡 Medium | 2 | 5 | 7 |
| 🟢 Low | 0 | 6 | 6 |
| 💡 Nice to Have | 0 | 1 | 1 |
| **Total** | **5** | **22** | **27** |

**Blocking:** 13 issues (1 new critical, 2 new high, 9 pre-existing critical, 1 pre-existing high)
**Fix complexity:** Complex — requires file rename (`src/index.ts` → `src/main.ts`), multiple config file changes, and two logic fixes
**Health delta:** 5 introduced · 22 pre-existing surfaced

---

## ✋ Verdict: CHANGES REQUIRED

Ten Critical and three High issues block approval. One Critical is a newly introduced regression (connection error status silently dropped); the remaining nine Criticals are template compliance gaps carried forward from prior releases that must now be resolved. Two High issues are also newly introduced (floor guard misplaced, `JSON.stringify(err)` producing `{}`). The `destroy()` socket leak is a pre-existing High that also blocks.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Connection error no longer updates module status](#c1-connection-error-no-longer-updates-module-status)
- [ ] [C2: `.gitattributes` file missing](#c2-gitattributes-file-missing)
- [ ] [C3: `.gitignore` content deviates from template](#c3-gitignore-content-deviates-from-template)
- [ ] [C4: `engines` field absent from `package.json`](#c4-engines-field-absent-from-packagejson)
- [ ] [C5: `repository.url` incorrect in `package.json`](#c5-repositoryurl-incorrect-in-packagejson)
- [ ] [C6: `manifest.json` missing `$schema` field](#c6-manifestjson-missing-schema-field)
- [ ] [C7: `manifest.json` `runtime.type` is `"node18"` — must be `"node22"`](#c7-manifestjson-runtimetype-is-node18--must-be-node22)
- [ ] [C8: `manifest.json` entrypoint uses `dist/index.js` instead of `dist/main.js`](#c8-manifestjson-entrypoint-uses-distindexjs-instead-of-distmainjs)
- [ ] [C9: Entry point is `src/index.ts` instead of required `src/main.ts`](#c9-entry-point-is-srcindexts-instead-of-required-srcmaints)
- [ ] [C10: `tsconfig.build.json` extends `node18` instead of `node22`](#c10-tsconfigbuildjson-extends-node18-instead-of-node22)
- [ ] [H1: Floor guard misplaced — clamps current value before delta is applied](#h1-floor-guard-misplaced--clamps-current-value-before-delta-is-applied)
- [ ] [H2: `destroy()` does not call `stop()` — sockets and timers leak on module teardown](#h2-destroy-does-not-call-stop--sockets-and-timers-leak-on-module-teardown)
- [ ] [H3: `JSON.stringify(err)` produces `{}` — error message is silently lost](#h3-jsonstringifyerr-produces---error-message-is-silently-lost)

**Non-blocking**
- [ ] [M1: Floor guard condition is strict `< -90` — exact-floor value is not clamped](#m1-floor-guard-condition-is-strict---90--exact-floor-value-is-not-clamped)
- [ ] [M2: Floor guard not applied consistently to all level delta actions](#m2-floor-guard-not-applied-consistently-to-all-level-delta-actions)
- [ ] [M3: `stateHandler` `update` event double-registers actions and feedbacks](#m3-statehandler-update-event-double-registers-actions-and-feedbacks)
- [ ] [M4: Device detector error handler causes unbounded restart loop](#m4-device-detector-error-handler-causes-unbounded-restart-loop)
- [ ] [M5: `OscForwarder.setup()` overwrites constructor-provided logger with `undefined`](#m5-oscforwardersetup-overwrites-constructor-provided-logger-with-undefined)
- [ ] [M6: Old `FeedbackHandler` poll timeout survives `configUpdated()` restart](#m6-old-feedbackhandler-poll-timeout-survives-configupdated-restart)
- [ ] [M7: `package.json` `name` field does not match module ID](#m7-packagejson-name-field-does-not-match-module-id)
- [ ] [L1: Deprecated `isVisible` function form still present in `eq.ts` and `faderbanks.ts`](#l1-deprecated-isvisible-function-form-still-present-in-eqts-and-faderbanksts)
- [ ] [L2: `connected` flag not reset synchronously in `stop()` — race on `configUpdated`](#l2-connected-flag-not-reset-synchronously-in-stop--race-on-configupdated)
- [ ] [L3: `stop()` does not call `stopSubscription()` before `close()`](#l3-stop-does-not-call-stopsubscription-before-close)
- [ ] [L4: Undo delta actions have no floor/ceiling guard](#l4-undo-delta-actions-have-no-floorceiling-guard)
- [ ] [L5: Every OSC command is sent twice over the wire](#l5-every-osc-command-is-sent-twice-over-the-wire)
- [ ] [L6: No reconnect path after unexpected socket close](#l6-no-reconnect-path-after-unexpected-socket-close)
- [ ] [N1: Initial subscription command sent before socket `ready` event](#n1-initial-subscription-command-sent-before-socket-ready-event)

---

## 🔴 Critical

### C1: Connection error no longer updates module status

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW (regression introduced in v2.3.0)
- **File:** `src/index.ts:157–159`
- **Description:** The `connection?.on('error', ...)` handler was changed from calling `this.updateStatus(InstanceStatus.ConnectionFailure, err.message)` to only logging via `this.logger?.error(JSON.stringify(err))`. UDP socket errors (ECONNREFUSED, ENETUNREACH, EADDRINUSE, etc.) now produce zero visible status change in the Companion UI. The module will silently remain `Ok` or `Connecting` indefinitely after a fatal socket error, giving users no indication the connection is broken.
- **Evidence:**
  ```diff
  - this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
  + this.logger?.error(JSON.stringify(err))
  ```
- **Recommendation:** Restore `this.updateStatus(InstanceStatus.ConnectionFailure, err.message)`. If additional logging is also desired, do both:
  ```ts
  this.connection?.on('error', (err: Error) => {
      this.logger?.error(`OSC connection error: ${err.message}`)
      this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
  })
  ```

---

### C2: `.gitattributes` file missing

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `.gitattributes` (absent from repo root)
- **Description:** The template requires `.gitattributes` with `* text=auto eol=lf`. The file is entirely absent. Without it, line-ending normalization is undefined and cross-platform builds can diverge.
- **Template expects:**
  ```
  * text=auto eol=lf
  ```
- **Found:** File does not exist
- **Recommendation:** Add `.gitattributes` with the exact content above.

---

### C3: `.gitignore` content deviates from template

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `.gitignore`
- **Description:** Three deviations from the required TS template:
  1. `/pkg.tgz` instead of `/*.tgz` — only ignores one specific filename, not all tarballs at root
  2. `.DS_Store` present — macOS artifact, not in template
  3. `/.vscode` missing — required by TS template
- **Template expects (TS):**
  ```
  node_modules/
  package-lock.json
  /pkg
  /*.tgz
  DEBUG-*
  /.yarn
  /dist
  /.vscode
  ```
- **Found:**
  ```
  node_modules/
  package-lock.json
  /pkg
  /pkg.tgz
  /dist
  DEBUG-*
  /.yarn
  .DS_Store
  ```
- **Recommendation:** Replace `.gitignore` with the exact template content above.

---

### C4: `engines` field absent from `package.json`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `package.json`
- **Description:** The `engines` field is present but empty (`{}`). Both `engines.node` and `engines.yarn` are required to constrain the execution environment.
- **Template expects:**
  ```json
  "engines": {
    "node": "^22.20",
    "yarn": "^4"
  }
  ```
- **Found:** `"engines": {}`
- **Recommendation:** Add `node` and `yarn` constraint values to the `engines` block.

---

### C5: `repository.url` incorrect in `package.json`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `package.json`
- **Description:** The repository URL references the wrong GitHub slug (`companion-module-wing-companion`) which does not correspond to the actual repository.
- **Template expects:** `"git+https://github.com/bitfocus/companion-module-behringer-wing.git"`
- **Found:** `"git+https://github.com/bitfocus/companion-module-wing-companion.git"`
- **Recommendation:** Update the URL to the canonical `companion-module-behringer-wing` repository.

---

### C6: `manifest.json` missing `$schema` field

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `companion/manifest.json`
- **Description:** The `$schema` field required for manifest validation tooling is absent.
- **Template expects:** `"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"`
- **Found:** Field not present
- **Recommendation:** Add `$schema` as the first key in `companion/manifest.json`.

---

### C7: `manifest.json` `runtime.type` is `"node18"` — must be `"node22"`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `companion/manifest.json`
- **Description:** The runtime target is `"node18"`, which is end-of-life. The Companion module standard requires `"node22"`. This directly controls which Node.js runtime Companion uses to run the module.
- **Template expects:** `"type": "node22"`
- **Found:** `"type": "node18"`
- **Recommendation:** Update `runtime.type` to `"node22"`.

---

### C8: `manifest.json` entrypoint uses `dist/index.js` instead of `dist/main.js`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `companion/manifest.json`
- **Description:** The entrypoint is `"../dist/index.js"`. The TS template convention is `src/main.ts` → `dist/main.js`. This must be fixed together with C9 (source file rename).
- **Template expects:** `"entrypoint": "../dist/main.js"`
- **Found:** `"entrypoint": "../dist/index.js"`
- **Recommendation:** Rename `src/index.ts` → `src/main.ts` (see C9), then update this field to `"../dist/main.js"`. Also update `package.json` `main` from `"dist/index.js"` to `"dist/main.js"`.

---

### C9: Entry point is `src/index.ts` instead of required `src/main.ts`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts`
- **Description:** The TS template standard requires the entry point to be `src/main.ts`. Using `src/index.ts` is a named structural deviation. This affects the manifest entrypoint (C8) and `package.json` `main` field.
- **Template expects:** `src/main.ts` as entry point
- **Found:** `src/index.ts` (no `src/main.ts`)
- **Recommendation:** Rename `src/index.ts` → `src/main.ts` and update `companion/manifest.json` entrypoint and `package.json` `main` field accordingly. Internal imports to `index.ts` do not need to change since this file exports the module class rather than importing it.

---

### C10: `tsconfig.build.json` extends `node18` instead of `node22`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `tsconfig.build.json`
- **Description:** The build config extends `@companion-module/tools/tsconfig/node18/recommended`. This must be `node22` to match the current Companion module standard and align with the `manifest.json` runtime target.
- **Template expects:** `"extends": "@companion-module/tools/tsconfig/node22/recommended"`
- **Found:** `"extends": "@companion-module/tools/tsconfig/node18/recommended"`
- **Recommendation:** Update the `extends` value to `@companion-module/tools/tsconfig/node22/recommended`.

---

## 🟠 High

### H1: Floor guard misplaced — clamps current value before delta is applied

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW (introduced in v2.3.0)
- **File:** `src/actions/common.ts:869–876`, `src/actions/matrix.ts:102–109`
- **Description:** The new `-90 dB` floor guard is placed **before** `targetValue += delta`. It clamps the stored/current value but never the post-delta final value. For the most common use case — a fader at a valid position with a negative delta — the guard never fires and the result still overshoots the floor. For example: current = −85 dB, delta = −10 dB → guard skipped (−85 > −90) → sends **−95 dB** to the mixer. The guard only helps when state already contains a sub-floor value (stale/corrupted data), providing no protection during normal operation.
- **Evidence:**
  ```ts
  state.storeDelta(cmd, delta)
  if (targetValue != undefined) {
      if (!usePercentage && targetValue < -90) {  // clamps CURRENT value only
          targetValue = -90
      }
      targetValue += delta                         // result can still go below -90
      ActionUtil.runTransition(cmd, 'level', event, state, transitions, targetValue, !usePercentage)
  }
  ```
  Scenario: `targetValue = -85`, `delta = -10` → guard skipped → sends **−95**.
- **Recommendation:** Move the guard to after `targetValue += delta`:
  ```ts
  targetValue += delta
  if (!usePercentage && targetValue < -90) {
      targetValue = -90
  }
  ```
  Or use `Math.max(-90, targetValue)` for symmetry with a potential ceiling clamp.

---

### H2: `destroy()` does not call `stop()` — sockets and timers leak on module teardown

- **Severity:** 🟠 High
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts:70–73`
- **Description:** `destroy()` only calls `deviceDetector?.unsubscribe()` and `transitions.stopAll()`. It does not call `this.stop()`, so on module removal or Companion shutdown the OSC UDP socket stays bound (causing EADDRINUSE on next load), the subscription `setInterval` keeps firing, the `OscForwarder` UDP socket remains open if forwarding is enabled, and `variableHandler.destroy()` is never called.
- **Evidence:**
  ```ts
  async destroy(): Promise<void> {
      this.deviceDetector?.unsubscribe(this.id)
      this.transitions.stopAll()
      // ← this.stop() never called
  }
  ```
  `stop()` correctly closes all resources:
  ```ts
  private stop(): void {
      this.connection?.close()
      this.stateHandler?.clearState()
      this.oscForwarder?.close()
      this.oscForwarder = undefined
      this.variableHandler?.destroy()
  }
  ```
- **Recommendation:** Call `this.stop()` from `destroy()`:
  ```ts
  async destroy(): Promise<void> {
      this.stop()
      this.deviceDetector?.unsubscribe(this.id)
      this.transitions.stopAll()
  }
  ```

---

### H3: `JSON.stringify(err)` produces `{}` — error message is silently lost

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW (introduced in v2.3.0 as part of the same C1 change)
- **File:** `src/index.ts:158`
- **Description:** `JSON.stringify` on a native `Error` instance always returns `"{}"` because `message`, `stack`, and `name` are non-enumerable properties. The log replacement introduced in this release — `this.logger?.error(JSON.stringify(err))` — produces an empty object for every error. Every OSC socket error logs as `[module] {}`, providing zero diagnostic value.
- **Evidence:**
  ```ts
  JSON.stringify(new Error('ECONNREFUSED'))  // → '{}'
  ```
- **Recommendation:** Use `err.message` (or `err.stack` for full context):
  ```ts
  this.logger?.error(`OSC connection error: ${err.message}`)
  ```
  This issue is automatically resolved when C1's recommendation is applied.

---

## 🟡 Medium

### M1: Floor guard condition is strict `< -90` — exact-floor value is not clamped

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW (part of the same guard addition in v2.3.0)
- **File:** `src/actions/common.ts:872`, `src/actions/matrix.ts:105`
- **Description:** The condition `targetValue < -90` (strict less-than) means a value exactly at `−90` is not clamped. If the current value is `−90` and a negative delta is applied, the guard does not fire and the result drops below the floor. This compounds H1 but is also independently incorrect once H1's placement is fixed.
- **Evidence:**
  ```ts
  if (!usePercentage && targetValue < -90) {   // −90 itself passes through
      targetValue = -90
  }
  // −90 + (−5) = −95 still escapes after H1 fix if condition stays strict
  ```
- **Recommendation:** After applying the H1 fix (guard post-delta), use `Math.max(-90, targetValue)` which is both placement-correct and boundary-inclusive:
  ```ts
  targetValue += delta
  if (!usePercentage) {
      targetValue = Math.max(-90, targetValue)
  }
  ```

---

### M2: Floor guard not applied consistently to all level delta actions

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW (guard added to some but not all delta actions in this release)
- **File:** `src/actions/common.ts`, `src/actions/matrix.ts`
- **Description:** The `−90 dB` floor guard was added to `DeltaSendFader` (common.ts) and `MatrixDirectInDeltaFader` (matrix.ts) in this release, and `DeltaFader` already had an equivalent guard since before beta.2. However, `DeltaGain`, `DeltaPanorama`, and `DeltaSendPanorama` have no equivalent floor (or ceiling) guard. If `−90` is the effective infinity boundary for all level-type parameters on the WING, the omission should be intentional and documented. If not, the inconsistency is a latent bug.
- **Recommendation:** Audit all delta actions to determine which parameters share the `−90 dB` floor. Apply consistent guards (post-delta, as per H1 fix) across all affected action types, or add a comment to the unguarded actions explaining why they don't need one.

---

### M3: `stateHandler` `update` event double-registers actions and feedbacks

- **Severity:** 🟡 Medium
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts:203–208`
- **Description:** The `'update'` event handler calls `this.updateActions()` and `this.updateFeedbacks()` (which internally call `setActionDefinitions` and `setFeedbackDefinitions`), and then immediately calls both methods again explicitly. Every model state change triggers four redundant Companion API calls, doubling processing overhead.
- **Evidence:**
  ```ts
  this.stateHandler.on('update', () => {
      this.updateActions()                              // → setActionDefinitions(...)
      this.updateFeedbacks()                            // → setFeedbackDefinitions(...)
      this.setPresetDefinitions(GetPresets(this))
      this.setActionDefinitions(createActions(this))    // ← duplicate
      this.setFeedbackDefinitions(GetFeedbacksList(this)) // ← duplicate
      this.checkFeedbacks()
  })
  ```
- **Recommendation:** Remove the explicit `setActionDefinitions` and `setFeedbackDefinitions` calls; the `updateActions()` and `updateFeedbacks()` helpers already cover them.

---

### M4: Device detector error handler causes unbounded restart loop

- **Severity:** 🟡 Medium
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/handlers/device-detector.ts:88–91`
- **Description:** The OSC error handler in the device detector immediately calls `stopListening()` then `startListening()` with no backoff, cooldown, or retry cap. On a persistent error (e.g. port already in use, interface unavailable), this creates a tight restart loop that will spam logs and may peg CPU. The error itself is also discarded (`_err`).
- **Evidence:**
  ```ts
  this.osc.on('error', (_err: Error): void => {
      this.stopListening()
      this.startListening()   // no backoff, no retry cap, error discarded
  })
  ```
- **Recommendation:** Add exponential backoff (or at minimum `setTimeout(() => this.startListening(), 5000)`), log the error, and add a max retry cap.

---

### M5: `OscForwarder.setup()` overwrites constructor-provided logger with `undefined`

- **Severity:** 🟡 Medium
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/handlers/osc-forwarder.ts:16`
- **Description:** `setup()` takes an optional `logger?: ModuleLogger` parameter and assigns `this.logger = logger`. Every call site in `src/index.ts` invokes `setup()` without passing the `logger` argument, unconditionally overwriting the logger injected via the constructor with `undefined`. All subsequent log calls in `OscForwarder` silently do nothing.
- **Evidence:**
  ```ts
  // Constructor correctly receives logger
  constructor(logger?: ModuleLogger) { this.logger = logger }

  // setup() silently kills it
  setup(enabled: boolean | undefined, host?: string, port?: number, logger?: ModuleLogger): void {
      this.close()
      this.logger = logger   // always undefined at call site
  }
  ```
  Call site in `src/index.ts` passes no logger argument.
- **Recommendation:** Remove the `logger` parameter from `setup()`. The logger should only be set via the constructor.

---

### M6: Old `FeedbackHandler` poll timeout survives `configUpdated()` restart

- **Severity:** 🟡 Medium
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts:83–91`, `src/handlers/feedback-handler.ts`
- **Description:** When `stop()` calls `connection?.close()`, the `'close'` event fires synchronously and the handler in `src/index.ts:161` calls `this.feedbackHandler?.startPolling()` on the **still-active old** `FeedbackHandler`. Then `start()` creates a new `FeedbackHandler` and overwrites `this.feedbackHandler`. The old handler's poll timeout fires after `pollInterval` ms, calls `updateStatus(InstanceStatus.Disconnected, 'Connection timed out')` via the closure, potentially right after a successful reconnect has set status to `Ok`.
- **Recommendation:** In `stop()`, call `this.feedbackHandler?.clearPollTimeout()` and null out `this.feedbackHandler` before `start()` creates a new instance. Or skip `startPolling()` in the `'close'` handler when teardown is in progress.

---

### M7: `package.json` `name` field does not match module ID

- **Severity:** 🟡 Medium
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `package.json`
- **Description:** `"name": "wing-companion"` does not match the module's canonical ID in `manifest.json` (`"behringer-wing"`). The build tooling derives the tgz name from the manifest ID so the build output is correct, but the mismatch creates confusion in the npm ecosystem and is inconsistent with the repository name.
- **Recommendation:** Align `package.json` `"name"` with the manifest `"id"`: `"behringer-wing"`.

---

## 🟢 Low

### L1: Deprecated `isVisible` function form still present in `eq.ts` and `faderbanks.ts`

- **Severity:** 🟢 Low
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/choices/eq.ts:54`, `src/choices/faderbanks.ts:210,220,230,240,252`
- **Description:** These files still use `isVisible: (options) => boolean` (deprecated in `@companion-module/base` v1.x) while `src/choices/common.ts` already correctly uses `isVisibleExpression` string expressions throughout. The deprecated form does not work in remote/headless Companion environments that evaluate expressions server-side.
- **Policy note:** In v1.x modules, `isVisible` deprecation is Low/non-blocking. In v2.x, it is removed entirely (Critical).
- **Recommendation:** Migrate `isVisible` callbacks in `eq.ts` and `faderbanks.ts` to `isVisibleExpression` string expressions, consistent with the rest of the codebase.

---

### L2: `connected` flag not reset synchronously in `stop()` — race on `configUpdated`

- **Severity:** 🟢 Low
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts:76–83`
- **Description:** `stop()` closes the `ConnectionHandler` but does not reset `this.connected = false` synchronously. The `'close'` event on the old handler fires asynchronously and does set `connected = false`, but by that point `configUpdated` may have already called `start()` and created a new connection. The async `'close'` event from the old connection can incorrectly reset `connected` on the new connection, preventing the "OSC connection established" logic from firing correctly.
- **Recommendation:** Set `this.connected = false` synchronously inside `stop()` before closing, and ensure old connection event listeners are removed (or `this.connection` nulled out before re-assignment).

---

### L3: `stop()` does not call `stopSubscription()` before `close()`

- **Severity:** 🟢 Low
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts:91–97`
- **Description:** `stop()` calls `connection?.close()`, which triggers the OSC port's async `'close'` event to clear the subscription interval. Between calling `close()` and the event firing, the interval could tick and attempt to send on a closing socket. Explicitly calling `stopSubscription()` before `close()` eliminates this window.
- **Recommendation:** Add `this.connection?.stopSubscription()` before `this.connection?.close()` in `stop()`.

---

### L4: Undo delta actions have no floor/ceiling guard

- **Severity:** 🟢 Low
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/actions/common.ts:488–503`, `src/actions/common.ts:886–903`
- **Description:** `UndoDeltaFader` and `UndoDeltaSendFader` apply `targetValue -= delta` with no floor/ceiling guard. If the stored delta causes an undershoot, an out-of-range value is sent to the mixer. The inconsistency is more visible now that the forward-delta actions have (an attempted) guard.
- **Recommendation:** Apply the same `Math.max(-90, targetValue)` clamp post-subtraction for consistency with the forward-delta actions.

---

### L5: Every OSC command is sent twice over the wire

- **Severity:** 🟢 Low
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/handlers/connection-handler.ts:152–154`
- **Description:** `sendCommand()` always sends the command twice: once with the argument and once immediately after with empty args. The comment notes this is "a bit ugly, but needed." This doubles protocol traffic for every action/variable update.
- **Evidence:**
  ```ts
  this.osc.send(command)
  this.osc.send({ address: cmd, args: [] }) // a bit ugly, but needed to keep desk state up to date
  ```
- **Recommendation:** Investigate whether the second send can be replaced with a targeted GET-style refresh for the specific address. If the double-send is unavoidable, document the protocol requirement more thoroughly.

---

### L6: No reconnect path after unexpected socket close

- **Severity:** 🟢 Low
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts:161–165`
- **Description:** When the `'close'` event fires (for reasons other than explicit teardown), the module sets status to `Disconnected` but never attempts to reopen the socket. OSC/UDP is connectionless, so a mixer rebooting is handled by subscription renewal. However, if the local UDP socket closes unexpectedly, the module sits `Disconnected` indefinitely until a user triggers a config save or module restart.
- **Recommendation:** Add a reconnect attempt on unexpected close. A simple delayed `configUpdated(this.config)` after a short timeout (e.g. 5s) would suffice.

---

## 💡 Nice to Have

### N1: Initial subscription command sent before socket `ready` event

- **Severity:** 💡 Nice to Have
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `src/index.ts:143–145`
- **Description:** `setupConnectionHandler()` calls `connection.open()` then immediately `connection.startSubscription()`. The first `/*S` subscription packet is sent before the UDP socket's `'ready'` event fires and the socket is bound — it is likely dropped. Recovery happens via the periodic subscription renewal interval, but this is an unnecessary silent failure on startup.
- **Recommendation:** Move `startSubscription()` into the `'ready'` event handler, or guard `sendSubscriptionCommand()` with an `isReady` flag inside `ConnectionHandler`.

---

## 🔮 Next Release

- Consider adding tests for state management and command handler logic — the modular handler architecture would support unit testing well.
- The `isVisibleExpression` adoption in `choices/common.ts` is excellent; completing the migration in `eq.ts` and `faderbanks.ts` would align the entire codebase.
- `DeltaGain`, `DeltaPanorama`, and `DeltaSendPanorama` floor/ceiling guard audit (see M2) — confirm whether these parameters share the same `−90 dB` floor or have different boundaries.

---

## ⚠️ Pre-existing Notes

The following pre-existing issues at Medium severity and below are documented here for completeness. They are non-blocking for this release but should be resolved in upcoming work:

| # | Finding | Severity |
|---|---------|----------|
| 1 | M3: Double action/feedback registration on state update | 🟡 Medium |
| 2 | M4: Device detector unbounded restart loop on error | 🟡 Medium |
| 3 | M5: OscForwarder logger overwritten with `undefined` in `setup()` | 🟡 Medium |
| 4 | M6: Old FeedbackHandler poll timeout survives `configUpdated()` | 🟡 Medium |
| 5 | M7: `package.json` name `"wing-companion"` doesn't match manifest ID `"behringer-wing"` | 🟡 Medium |
| 6 | L1: `isVisible` deprecated function form in `eq.ts` / `faderbanks.ts` | 🟢 Low |
| 7 | L2: `connected` flag not reset synchronously in `stop()` | 🟢 Low |
| 8 | L3: `stopSubscription()` not called before `close()` in `stop()` | 🟢 Low |
| 9 | L4: Undo delta actions lack floor/ceiling guards | 🟢 Low |
| 10 | L5: Every OSC command sent twice | 🟢 Low |
| 11 | L6: No reconnect after unexpected socket close | 🟢 Low |
| 12 | N1: First subscription packet sent before socket `ready` | 💡 Nice to Have |

---

## 🧪 Tests

No test framework detected (no jest or vitest dependency, no test files). Absence of tests is **not blocking** per team policy.

The module contains 80 TypeScript files across ~2,228 lines of core logic. The modular handler architecture (`ConnectionHandler`, `StateHandler`, `FeedbackHandler`, `VariableHandler`) would support unit testing well. Priority areas for future test coverage: state management, command handling, action execution (especially the fader delta clamping logic introduced in this release), and feedback evaluation.

---

## ✅ What's Solid

- **Build passes cleanly** — `yarn install && yarn package` produces a valid `behringer-wing-2.3.0.tgz` with no errors
- **Well-modular architecture** — clean separation into `ConnectionHandler`, `StateHandler`, `FeedbackHandler`, `VariableHandler`, and `OscForwarder`; each handler owns its concerns
- **SDK lifecycle correctly structured** — `init` → `configUpdated` → `destroy` pattern followed; `runEntrypoint` used properly with `UpgradeScripts`
- **Upgrade script is substantive** — `upgrades.ts` includes a real migration (RecorderState feedback type conversion) with correct `CompanionStaticUpgradeScript` typing
- **Debounced message batching** — `debounceFn` with `maxWait` is well-tuned for high-frequency OSC state-dump traffic
- **`isVisibleExpression` adoption** in `choices/common.ts` is clean and thorough; helper functions are reusable and minimize expression duplication
- **FeedbackHandler poll health check** — using poll timeouts as a secondary health signal for UDP is a thoughtful defensive pattern
- **`configUpdated` guard flow** — IP regex validation before opening the socket prevents spurious connection attempts on bad config
- **`.prettierignore` and `.yarnrc.yml`** — both match template exactly
- **All required TS scripts present** — `postinstall`, `format`, `package`, `build`, `build:main`, `dev`, `lint:raw`, `lint`
- **`lint-staged` config** — correctly structured for TS/JS and CSS/JSON/MD files
- **`eslint.config.mjs`** — correctly uses `generateEslintConfig({ enableTypescript: true })`
- **`manifest.json` keywords** — empty `[]`, no banned terms
- **`@companion-module/tools` bump** (`^2.1.1` → `^2.6.1`) is a positive modernization step
- **No v2 API patterns backported** — module is clean on `@companion-module/base ~1.13`
