# Module Review — panasonic-cameras v2.0.0

| | |
| --- | --- |
| **Module** | `panasonic-cameras` |
| **Review tag** | `v2.0.0` |
| **Previous tag** | `v1.2.0` (last approved release) |
| **Scope** | `tag` — only the `v1.2.0..v2.0.0` diff |
| **Language / API** | JS / `@companion-module/base` `~2.0.4` (**v2**) |
| **Protocols** | HTTP (CGI), TCP (update notifications) |
| **Reviewed** | 2026-08-06 |

This release is a full rewrite plus the **v1 → v2 API migration** (`c99aa5b`), so the `v1.2.0..v2.0.0` diff covers essentially all of `src/` (10,957 insertions / 8,238 deletions across 42 files). Every code finding below is therefore **NEW** or **REGRESSION** relative to `v1.2.0`. The intermediate `v1.3.0` release was reviewed but never approved; its findings are inside this diff, so each one was re-checked against the current code — a fix-verification table is at the end of the report.

Build/lint/tests: `yarn lint` clean; `yarn test` — **465 tests across 9 files, all passing**. No `build` script (JS module — expected).

## Verdict: ❌ Changes Required

---

## 📋 Issues

**Blocking**

- [ ] [C1: .gitignore missing required template entries](#c1-gitignore-missing-required-template-entries)
- [ ] [C3: Banned manifest keyword Panasonic](#c3-banned-manifest-keyword-panasonic)
- [ ] [C5: Upgrade scripts write bare option values where 2.0 requires the isExpression value wrapper](#c5-upgrade-scripts-write-bare-option-values-where-20-requires-the-isexpression-value-wrapper)
- [ ] [H1: LICENSE differs from the template copyright line](#h1-license-differs-from-the-template-copyright-line)
- [ ] [H4: The retry timer is never cleared on success — one dropped keep-alive forces a full re-init](#h4-the-retry-timer-is-never-cleared-on-success--one-dropped-keep-alive-forces-a-full-re-init)
- [ ] [H5: Upgrade scripts resolve the camera model from props.config, which is frequently null](#h5-upgrade-scripts-resolve-the-camera-model-from-propsconfig-which-is-frequently-null)

**Non-blocking**

- [ ] [M7: fS/zS speeds are parsed without validation and latch the zoom feedback on](#m7-fszs-speeds-are-parsed-without-validation-and-latch-the-zoom-feedback-on)
- [ ] [M8: EADDRINUSE leaves this.server set but not listening](#m8-eaddrinuse-leaves-thisserver-set-but-not-listening)
- [ ] [M9: A parser bug on the HTTP path is reported to the operator as a camera fault](#m9-a-parser-bug-on-the-http-path-is-reported-to-the-operator-as-a-camera-fault)
- [ ] [M10: AK-UB300 Master Pedestal step actions are a silent no-op](#m10-ak-ub300-master-pedestal-step-actions-are-a-silent-no-op)
- [ ] [L12: getAndUpdateSeries() re-scans the model tables on every camera response](#l12-getandupdateseries-re-scans-the-model-tables-on-every-camera-response)

---

## 🔴 Critical

### C1: .gitignore missing required template entries

**File:** `.gitignore`
**Classification:** 🆕 NEW

Missing template entries: `package-lock.json`, `/*.tgz`, `/.yarn`.

**Fix:** add the three missing lines so the file matches `companion-module-template-js`.

---

### C3: Banned manifest keyword Panasonic

**File:** `companion/manifest.json`
**Classification:** 🆕 NEW

`Panasonic` is a banned/low-value keyword — the manufacturer name is already carried by the module's name and `manufacturer` field, so it adds nothing to search.

**Fix:** remove `Panasonic` from `keywords`; keep only terms that describe what the module does (e.g. `PTZ`, `camera`, `AW-UE`).

---

### C5: Upgrade scripts write bare option values where 2.0 requires the isExpression value wrapper

**Files:** `src/upgrades.js:40` (`fillOmittedOptions`), `src/upgrades.js:136` (`addSetStepSize`)
**Classification:** 🆕 NEW

```js
for (const id of omitted) entity.options[id] = spec.defaults[id]        // upgrades.js:40
action.options.step = action.options.step === undefined ? 1 : action.options.step   // upgrades.js:136
```

`spec.defaults[id]` comes straight from the definition's `default:` field (`common.js:115-130`), so it is a raw value (`'0'`, `25`, `0`). But in 2.0 an upgrade script's options are typed:

```ts
// @companion-module/base@2.0.4 — dist/module-api/upgrade.d.ts:58
export type CompanionMigrationOptionValues = {
    [key: string]: ExpressionOrValue<JsonValue | undefined> | undefined
}
```

Note the deliberate asymmetry against **preset** option values, which are typed `T | ExpressionOrValue<T>` (raw allowed). Migration values are not. A raw write therefore produces an option Companion reads as `.value === undefined` — exactly the "undefined is not in the dropdown choices, and takes the whole action down" failure the script's own header comment (`upgrades.js:9-11`) says it exists to prevent.

The sibling script `dropUseVarToggles` in the same file gets this right (it routes through `FixupNumericOrVariablesValueToExpressions`, which returns the wrapper), which is what makes this look like an oversight rather than a decision. The tests can't catch it because the two suites use different shapes: `src/__tests__/upgrades.test.js:15` / `:35` assert the raw shape, while `:91-92` builds `const val = (value) => ({ isExpression: false, value })` for the other script.

**Fix:**

```js
for (const id of omitted) entity.options[id] = { isExpression: false, value: spec.defaults[id] }
```

and in `addSetStepSize`:

```js
if (action.options.step === undefined) action.options.step = { isExpression: false, value: 1 }
```

Update the fixtures/assertions in `upgrades.test.js` to the 2.0 shape so the suite actually covers it, and verify against a real Companion 4.3 upgrade of a `v1.2.0`-saved config before shipping — this is the one thing in the release every existing user hits exactly once, unrecoverably.

---

## 🟠 High

### H1: LICENSE differs from the template copyright line

**File:** `LICENSE`
**Classification:** 🆕 NEW

Line 3 reads `Copyright (c) 2018 Bitfocus AS`; the template is `Copyright (c) 2022 Bitfocus AS - Open Source`.

**Fix:** replace `LICENSE` with the current template copy.

### H4: The retry timer is never cleared on success — one dropped keep-alive forces a full re-init

**Files:** `src/index.js:539-548` (`scheduleReInit`), success paths at `src/index.js:321, 353, 397`
**Classification:** 🆕 NEW (prior H2, unfixed)

`this.timeoutID` is cleared only in `teardown()` and in `scheduleReInit()` itself — nothing cancels a pending re-init when a later request succeeds. `ECONNRESET`/`ECONNABORTED` are both in `REACHABILITY_ERRORS`, so a single dropped connection — routine with these cameras — sets `poll = false` and `pollImage = false`, flips the status to `ConnectionFailure`, and 2.1 s later runs a complete `reInitAll()`: teardown, re-query the model, tear down and rebuild the TCP subscription, re-pull the whole status, and re-publish every action, feedback, variable and the ~200 presets (`presets.js` is 1587 lines of generator). The operator sees `Ok → ConnectionFailure → Connecting → Ok` and a full button redraw for a blip that had already recovered, and polling is stopped in the meantime. In `v1.2.0` only a genuine `ETIMEDOUT` did this; the code now retries eight error classes.

**Fix:** clear the pending retry whenever a request succeeds, and require N consecutive failures (2–3) before declaring the connection lost:

```js
onRequestSucceeded() {
    this.failures = 0
    this.timeoutID = clearTimeout(this.timeoutID)
    this.updateStatus(InstanceStatus.Ok)
}
```

called in place of each bare `updateStatus(InstanceStatus.Ok)`.

---

### H5: Upgrade scripts resolve the camera model from props.config, which is frequently null

**Files:** `src/upgrades.js:21` (`fillOmittedOptions`), `src/upgrades.js:81` (`presetCount`)
**Classification:** 🆕 NEW

Both scripts build their model context from `props.config ?? { model: 'Other' }`. But `CompanionStaticUpgradeProps.config` is typed `TConfig | null` — it is populated only when the *connection* itself is being upgraded. `CompanionUpgradeContext.currentConfig` is the field documented as "Current configuration of the module", and it is exactly why the context parameter exists; both scripts currently discard it as `_context`.

When `props.config` is null:

- `fillOmittedOptions` reconciles a UE160's stored buttons against the generic `Other` action set, so a filled dropdown default can be a value the real model's choices don't contain — reintroducing the drop-the-entity failure it is meant to repair.
- `presetCount` returns 100 for an AW-HE2 that has 9 slots, so `toPresetIndex` clamps literals to the wrong ceiling (`'99'` instead of `'08'`).

The tests never exercise it: `src/__tests__/upgrades.test.js:157-162` passes `config` explicitly, and the `survives no config at all` cases (`:76-84`, `:202-209`) only assert `not.toThrow()`.

**Fix:**

```js
function fillOmittedOptions(context, props) {
    const config = context?.currentConfig ?? props.config ?? { model: 'Other' }
```

and add a test asserting the AW-HE2 clamp still lands on `'08'` when `props.config` is null but the context carries the model.

---

## 🟡 Medium

### M7: fS/zS speeds are parsed without validation and latch the zoom feedback on

**Files:** `src/parser.js:142-148`, `src/feedbacks.js:188`
**Classification:** ⚠️ Prior finding L7 — still present

`parseInt(str[0].substring(2, 4)) - 50` yields `NaN` on a short or non-numeric notification. Three consequences: `zoomSpeed`/`focusSpeed` publish `NaN`; the `zoomControl` feedback tests `!= 0`, which `NaN` satisfies, so the button stays permanently lit; and the value feeds back out through `lensAxis.control` → `cmdSpeed(NaN + 50)` → a literal `#ZNaN` on the wire.

**Fix:**

```js
const v = parseInt(str[0].substring(2, 4), 10)
if (Number.isFinite(v)) self.data.zoomSpeedValue = v - 50
```

and use `Number(self.data.zoomSpeedValue) !== 0` in the feedback.

---

### M8: EADDRINUSE leaves this.server set but not listening

**File:** `src/index.js:222-233`
**Classification:** 🆕 NEW

The handler logs and sets status but never clears `this.server`. Consequences: (a) the next `teardown()` sees `this.server` truthy and sends an unsubscribe goodbye for a port that was never subscribed; (b) `this.server.close()` on a server that never listened emits `ERR_SERVER_NOT_RUNNING` on the same `'error'` handler, logging a spurious "TCP server error" on every teardown for the rest of the session. `unsubscribeTCPEvents(tcpPortSelected)` at `:229` is likewise a stop for a subscription that was never started.

**Fix:** in the `EADDRINUSE` branch, `this.server.close(); delete this.server` and drop the unsubscribe call.

---

### M9: A parser bug on the HTTP path is reported to the operator as a camera fault

**Files:** `src/index.js:275-294` (`camdata.html` line loop), `src/index.js:520-536` (`handleConnectionError`)
**Classification:** 🆕 NEW

The `for (let line of lines)` loop calls `parseUpdate` inside the request `try`. Per H2 that can throw, and the `catch` hands the `TypeError` to `handleConnectionError`, where `err.code` is `undefined` → it falls through to `updateStatus(InstanceStatus.UnknownError, describeError(err))` with **no retry scheduled**. Outcome: line 12 of the bulk dump poisons lines 13–400, and the connection reports `UnknownError: Cannot read properties of undefined (reading 'replace')` — a module bug presented to the operator as a network fault, with the connection permanently deadened.

**Fix:** the same per-line `try`/`catch` as H2, so parse failures never enter the connection-error path; and branch in `handleConnectionError` on the absence of `err.code` (or `err instanceof TypeError`) to log it as an internal error rather than a camera fault.

---

### M10: AK-UB300 Master Pedestal step actions are a silent no-op

**File:** `src/models.js:414`
**Classification:** ⚠️ Pre-existing data defect, new failure mode this release

```js
pedestal: { cmd: 'OSG:4A', offset: 0x80, limit: 99 }
```

No `step`, no `hexlen`. `optSetStepped()` therefore emits a Step size number field with `default: undefined` and `min: undefined` (`actions.js:170-181`), `fillOmittedOptions` skips it (it only fills ids that *have* a default), and `resolveSetStep()` (`actions.js:221`) gets `parseInt(undefined)` → `NaN` → returns `false` → the action returns with no command and **no log**. (In `v1.2.0` the same gap produced a `NAN` command instead — visible, at least.)

**Fix:** `pedestal: { cmd: 'OSG:4A', offset: 0x80, limit: 99, step: 1, hexlen: 2 }`, and make `optSetStepped` throw or assert on a missing `step`/`hexlen` so the next model cannot ship the same hole. A `definitions.test.js` assertion that every `levelAction` capability carries `step` and `hexlen` would have caught this.

---

## 🟢 Low

### L12: getAndUpdateSeries() re-scans the model tables on every camera response

**Files:** `src/variables.js:125`, `src/actions.js:249`, `src/feedbacks.js:72` · 🆕 NEW

`checkVariables()` runs after every HTTP response and every TCP batch, and each call does two `Array.find` scans over `MODELS`/`SERIES_SPECS` *and mutates* `self.data.model`/`self.data.series` on a hot path. **Fix:** `this.SERIES` is already computed once in `reInitAll()` (`index.js:564`) — read it everywhere else.

---
