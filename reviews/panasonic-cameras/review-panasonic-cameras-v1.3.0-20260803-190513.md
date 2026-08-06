# Module Review — panasonic-cameras v1.3.0

| | |
|---|---|
| **Module** | `panasonic-cameras` |
| **Review tag** | `v1.3.0` |
| **Previous tag** | `v1.2.0` |
| **Scope** | `tag` — only the `v1.2.0..v1.3.0` diff |
| **Language / API** | JS / `@companion-module/base` `~1.11.2` (v1) |
| **Protocols** | HTTP (CGI), TCP (update notifications) |
| **Reviewed** | 2026-08-03 |

All code findings below are **NEW** or **REGRESSION** relative to `v1.2.0`. Pre-existing issues outside the diff are not surfaced, except where a finding explicitly notes that this release made an existing pattern materially worse or newly reachable.

Build/lint: `yarn lint` passes clean. No `build` script (JS module — expected).

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 5 | 0 | 5 |
| 🟠 High | 4 | 0 | 4 |
| 🟡 Medium | 11 | 0 | 11 |
| 🟢 Low | 10 | 0 | 10 |
| 💡 Nice to Have | 7 | 0 | 7 |
| **Total** | **37** | **0** | **37** |

---

## Verdict: ❌ Changes Required

---

## 📋 Issues

**Blocking**

- [ ] [C1: .gitignore missing required template entries](#c1-gitignore-missing-required-template-entries)
- [ ] [C2: .prettierignore differs from template](#c2-prettierignore-differs-from-template)
- [ ] [C4: package.json missing required engines field](#c4-packagejson-missing-required-engines-field)
- [ ] [C5: Banned manifest keyword Panasonic](#c5-banned-manifest-keyword-panasonic)
- [ ] [C6: destroy() leaves the reconnect timer armed — a deleted instance resurrects itself indefinitely](#c6-destroy-leaves-the-reconnect-timer-armed--a-deleted-instance-resurrects-itself-indefinitely)
- [ ] [H1: getCameraStatusOnce() is an unawaited, uncancellable, unthrottled request burst](#h1-getcamerastatusonce-is-an-unawaited-uncancellable-unthrottled-request-burst)
- [ ] [H2: The retry timer is never cleared on success — transient errors force a full re-init](#h2-the-retry-timer-is-never-cleared-on-success--transient-errors-force-a-full-re-init)
- [ ] [H3: Accepted camera sockets are orphaned on every recovery cycle](#h3-accepted-camera-sockets-are-orphaned-on-every-recovery-cycle)
- [ ] [H4: New parser cases dereference missing fields inside an unguarded socket data handler](#h4-new-parser-cases-dereference-missing-fields-inside-an-unguarded-socket-data-handler)

**Non-blocking**

- [ ] [M1: Preset button generator still hardcodes 100 while the dropdowns are now capability-sliced](#m1-preset-button-generator-still-hardcodes-100-while-the-dropdowns-are-now-capability-sliced)
- [ ] [M2: presetMem op default was corrected with no upgrade script — existing buttons stay broken](#m2-presetmem-op-default-was-corrected-with-no-upgrade-script--existing-buttons-stay-broken)
- [ ] [M3: Unguarded step/set on the four new speed actions produce NaN commands and poison module state](#m3-unguarded-stepset-on-the-four-new-speed-actions-produce-nan-commands-and-poison-module-state)
- [ ] [M4: Duplicate poll loops accumulate across reconnects](#m4-duplicate-poll-loops-accumulate-across-reconnects)
- [ ] [M5: presetClearAll issues up to 100 sequential, unthrottled, uncancellable requests](#m5-presetclearall-issues-up-to-100-sequential-unthrottled-uncancellable-requests)
- [ ] [M6: New variable values are pushed unconditionally while their definitions are capability-gated](#m6-new-variable-values-are-pushed-unconditionally-while-their-definitions-are-capability-gated)
- [ ] [M7: No backoff — the retry interval is shorter than a single failing request](#m7-no-backoff--the-retry-interval-is-shorter-than-a-single-failing-request)
- [ ] [M8: ENOTFOUND and EAI_AGAIN are missing from the recovery set](#m8-enotfound-and-eai_again-are-missing-from-the-recovery-set)
- [ ] [M9: while (self.poll) can spin without ever awaiting](#m9-while-selfpoll-can-spin-without-ever-awaiting)
- [ ] [M10: reInitAll() is invoked from the timer with no .catch()](#m10-reinitall-is-invoked-from-the-timer-with-no-catch)
- [ ] [M11: Audio volume dB-to-raw encoding is unverified for the 3 dB-step models](#m11-audio-volume-db-to-raw-encoding-is-unverified-for-the-3-db-step-models)
- [ ] [L1: The new Disconnected status is dead code, and every failed request logs](#l1-the-new-disconnected-status-is-dead-code-and-every-failed-request-logs)
- [ ] [L2: shootingMode missing from the this.data initialiser](#l2-shootingmode-missing-from-the-thisdata-initialiser)
- [ ] [L3: New action options parse variables via the instance method instead of the callback context](#l3-new-action-options-parse-variables-via-the-instance-method-instead-of-the-callback-context)
- [ ] [L4: parseSetIncDecVariables mutates the cached action instance](#l4-parsesetincdecvariables-mutates-the-cached-action-instance)
- [ ] [L5: Preset variable is 1-based against a 0-based dropdown, with silent clamping](#l5-preset-variable-is-1-based-against-a-0-based-dropdown-with-silent-clamping)
- [ ] [L6: Audio volume variables are published as unit-suffixed strings](#l6-audio-volume-variables-are-published-as-unit-suffixed-strings)
- [ ] [L7: fS/zS speed parsing is unvalidated — NaN reaches the wire and latches the feedback on](#l7-fszs-speed-parsing-is-unvalidated--nan-reaches-the-wire-and-latches-the-feedback-on)
- [ ] [L8: Second setVariableValues() call per update](#l8-second-setvariablevalues-call-per-update)
- [ ] [L9: getAllCameraStatus is dead code that this release extended](#l9-getallcamerastatus-is-dead-code-that-this-release-extended)
- [ ] [L10: camdata.html is now fetched even when the user disabled subscriptions](#l10-camdatahtml-is-now-fetched-even-when-the-user-disabled-subscriptions)
- [ ] [N1: removeAllListeners().then() throws on every Pan/Tilt move with live speed](#n1-removealllistenersthen-throws-on-every-pantilt-move-with-live-speed)
- [ ] [N2: optSetLowerRaise is a verbatim copy of optSetIncDecStep](#n2-optsetlowerraise-is-a-verbatim-copy-of-optsetincdecstep)
- [ ] [N3: New presets do not attach their matching feedbacks](#n3-new-presets-do-not-attach-their-matching-feedbacks)
- [ ] [N4: No focusControl feedback to match zoomControl](#n4-no-focuscontrol-feedback-to-match-zoomcontrol)
- [ ] [N5: speedStep max of 7 is an unexplained magic number](#n5-speedstep-max-of-7-is-an-unexplained-magic-number)
- [ ] [N6: audioVolumeLevel feedback bounds are unvalidated and ignore the model step](#n6-audiovolumelevel-feedback-bounds-are-unvalidated-and-ignore-the-model-step)
- [ ] [N7: The four HTTP helpers are duplicates with no cancellation](#n7-the-four-http-helpers-are-duplicates-with-no-cancellation)

---

## 🔴 Critical

### C1: .gitignore missing required template entries

**File:** `.gitignore`
**Classification:** 🆕 NEW

`.gitignore` is missing template entries `package-lock.json`, `/*.tgz`, and `/.yarn`. Without `package-lock.json` ignored, a contributor running `npm install` can commit a lockfile that conflicts with the Yarn workflow; without `/*.tgz` and `/.yarn`, build artifacts and the Yarn cache can be committed.

**Fix:** add the missing entries so `.gitignore` matches the official `companion-module-template-js-v1` file.

---

### C2: .prettierignore differs from template

**File:** `.prettierignore` (line 2)
**Classification:** 🆕 NEW

`.prettierignore` was added in this release but does not match the template — line 2 is `pkg` where the template has `/LICENSE.md`.

**Fix:** replace `.prettierignore` with the template's copy verbatim. Add module-specific entries (e.g. `Camera_Dumps/`) *below* the template content rather than in place of it.

---

### C4: package.json missing required engines field

**File:** `package.json`
**Classification:** 🆕 NEW

The required `engines` field (present in the template) is absent. Without it, nothing pins the Node version the module is built and run against, and `yarn` will not warn when a contributor uses an unsupported runtime.

**Fix:** add the `engines` block from `companion-module-template-js-v1`, matching the `runtime.type` declared in `companion/manifest.json`.

---

### C5: Banned manifest keyword Panasonic

**File:** `companion/manifest.json`
**Classification:** 🆕 NEW

`keywords` contains `"Panasonic"`. The manufacturer name is already carried by the `manufacturer` field, so repeating it as a keyword adds no search value and is rejected by the module checks.

**Fix:** remove `"Panasonic"` from `keywords`. The remaining entries (`Camera`, `PTZ`, `AW`, `AJ`, `AG`, `AK`, `CX`, `UPX`, `UB`, `POVCAM`) are fine.

---

### C6: destroy() leaves the reconnect timer armed — a deleted instance resurrects itself indefinitely

**File:** `src/index.js:28-39`, `src/index.js:41-55`, `src/index.js:456-482`
**Classification:** 🔙 REGRESSION

`destroy()` awaits `unsubscribeTCPEvents()`, whose `catch` calls `handleConnectionError(err)`. In `v1.2.0` that path only rescheduled on `ETIMEDOUT`; `v1.3.0` widened it to `ECONNABORTED`, `ECONNREFUSED`, `ECONNRESET`, `EHOSTDOWN`, `EHOSTUNREACH` and `ENETUNREACH`. A powered-off or unplugged camera answers the goodbye request with an immediate `ECONNREFUSED`, so `destroy()` now *schedules* `setTimeout(() => this.reInitAll(), timeout + pollDelay)`.

`destroy()` never calls `clearTimeout(this.timeoutID)`. Roughly 1–2 seconds after the user deletes or disables the connection, the module re-initialises itself: it binds a TCP listener again, re-subscribes the camera to update notifications, restarts polling, fails, and re-schedules itself — an unkillable zombie instance that holds a TCP port and keeps generating network traffic and log noise until Companion is restarted.

`configUpdated()` (`src/index.js:447`) *does* clear `this.timeoutID` first, which shows the omission in `destroy()` is an oversight rather than intent.

**Fix:**

```js
async destroy() {
	this.destroyed = true
	this.poll = false
	this.timeoutID = clearTimeout(this.timeoutID)
	...
}
```

and add `if (this.destroyed) return` at the top of `reInitAll()`, `pollCameraStatus()` and `getCameraStatusOnce()`. Separately, teardown paths should not attempt recovery at all — in `unsubscribeTCPEvents()`, log the failure with `this.log('debug', ...)` rather than routing it through `handleConnectionError()`.

---

## 🟠 High

### H1: getCameraStatusOnce() is an unawaited, uncancellable, unthrottled request burst

**File:** `src/polling.js:26-33`, called from `src/index.js:496`
**Classification:** 🆕 NEW

```js
export async function getCameraStatusOnce(self) {
	for (const caps of [self.SERIES.capabilities.pull, self.SERIES.capabilities.poll]) {
		if (!caps) continue
		for (const [key, method] of Object.entries(transports)) {
			for (const cmd of caps[key] || []) await self[method](cmd)
		}
	}
}
```

In `v1.2.0` the equivalent call was commented out (`// getAllCameraStatus(this)`); `v1.3.0` enables it unconditionally as a floating promise — no `await`, no `.catch()`. Unlike `pollCameraStatus()` it has **no `self.poll` check** and **no `sleep(self.config.pollDelay)` between commands**, which is exactly the pacing the poll loop exists to provide. For a UE150-class model that is roughly 30–40 back-to-back HTTP requests on every init and every reconnect, running concurrently with `getCameraStatus()` (camdata.html, which returns much of the same data) and with `pollCameraStatus()`.

Consequences:

- Against an offline camera each request burns a full `config.timeout` (plus `got`'s built-in retries), so one pass can run for minutes while the retry timer keeps firing.
- It keeps running across `configUpdated()` and `destroy()`. After a config change its remaining requests go to the **new** host with the old command list, and their failures schedule re-inits for a connection that may no longer exist.
- A synchronous rejection (e.g. `self.SERIES` undefined) is an unhandled rejection.

**Fix:** `await sleep(self.config.pollDelay)` between commands; check a cancellation flag (`if (!self.poll || self.destroyed) return`) before each request; and either `await` the call in `reInitAll()` or attach `.catch((e) => this.log('error', ...))`. Also consider skipping the commands `camdata.html` already covers when `capabilities.subscription` is true, rather than fetching both.

---

### H2: The retry timer is never cleared on success — transient errors force a full re-init

**File:** `src/index.js:471-474`
**Classification:** 🆕 NEW

Nothing clears `this.timeoutID` when a subsequent request succeeds. With `ECONNRESET` and `ECONNABORTED` now in the recovery set, a single dropped keep-alive — routine with these cameras — schedules a complete `reInitAll()` 1–2 seconds later even though the connection is already healthy.

`reInitAll()` is heavy: it re-queries the model, tears down and rebuilds the TCP subscription, restarts polling, and re-pushes **all** action, feedback, preset and variable definitions (`presets.js` alone builds ~200 buttons). The user sees a status flap (`Ok` → `Connecting` → `Ok`) and a full button redraw for what was a recoverable blip. In `v1.2.0` this only followed a genuine 2-second timeout.

**Fix:** clear the pending timer whenever a request succeeds — e.g. a small helper called alongside `updateStatus(InstanceStatus.Ok)`:

```js
onSuccess() {
	this.timeoutID = clearTimeout(this.timeoutID)
}
```

Alternatively track a `reconnectPending` flag and skip the re-init if any request has succeeded since it was scheduled.

---

### H3: Accepted camera sockets are orphaned on every recovery cycle

**File:** `src/index.js:77-91`, `src/index.js:28-39`
**Classification:** 🔙 REGRESSION (existing pattern, newly amplified)

`init_tcp()` sets `this.clients = []` (line 78) and calls `this.server.close()` (line 88) without destroying the sockets in `this.clients`. `server.close()` only stops accepting new connections — established sockets survive. `destroy()` has the same gap.

This code is unchanged in the diff, but `v1.3.0` turns `reInitAll()` → `init_tcp()` into a routine event (seven error codes instead of one, plus the spurious re-inits in [H2](#h2-the-retry-timer-is-never-cleared-on-success-transient-errors-force-a-full-re-init)). Each reconnect now abandons a live socket whose `'data'` handler still closes over the instance and still calls `parseUpdate()` — so stale camera data can be written into a re-initialised instance, and file descriptors accumulate.

Two related defects in the same block:

- The `'end'` handler does not fire for locally destroyed sockets, so the array is not cleaned up on teardown.
- `this.clients.splice(this.clients.indexOf(socket), 1)` (lines 97, 101) becomes `splice(-1, 1)` when the socket is not found, silently removing an unrelated live socket.

**Fix:**

```js
for (const s of this.clients) s.destroy()
this.clients = []
```

in both `init_tcp()` and `destroy()`; add a `socket.on('close', ...)` handler that removes the socket from the array; and guard the splice with `const i = this.clients.indexOf(socket); if (i !== -1) this.clients.splice(i, 1)`.

---

### H4: New parser cases dereference missing fields inside an unguarded socket data handler

**File:** `src/parser.js:224-232`, `:236-247`, `:271-277`, `:310-321`, `:336-344`; handler at `src/index.js:110-129`
**Classification:** 🆕 NEW

The new cases index positionally without guards, for example:

```js
case 'OSA':
	switch (str[1]) {
		case '87':
			self.data.videoFormat = str[2].replace('0x', '')
			break
		case 'D5':
			self.data.audioVolumeLevels[parseInt(str[2])] = parseInt(str[3], 16) - 0x80
			break
	}
```

`parseUpdate()` runs inside the socket `'data'` callback, which has **no `try`/`catch`** — and the module's own TODO at `src/index.js:111` acknowledges that TCP framing is not handled correctly. A truncated or coalesced notification yields `['OSA', '87']`, so `str[2].replace` throws a `TypeError` out of an event handler: an uncaught exception that takes down the connection. The `D5` variant does not throw but silently writes `audioVolumeLevels['NaN'] = NaN`, which surfaces as `NaN` in the audio variables.

The same exposure applies to the new `OSD:3A`, `OSD:B0`, `OSE:33`, `OSJ:0B`, `OSJ:0C`, `OSG:4D` and `OSJ:10` cases.

**Fix:** use optional chaining with a default in every new case (`str[2]?.replace('0x', '') ?? null`), validate numeric fields before use:

```js
const ch = parseInt(str[2])
if (!Number.isInteger(ch) || ch < 0 || ch > 3) break
```

and wrap the `parseUpdate(this, str.split(':'))` call in the socket handler (and the line loop in `getCameraStatus()`) in `try`/`catch` so one malformed frame from real hardware can never take the process down.

---

## 🟡 Medium

### M1: Preset button generator still hardcodes 100 while the dropdowns are now capability-sliced

**File:** `src/presets.js:2678` vs `src/actions.js:850` and `src/feedbacks.js:14`
**Classification:** 🔙 REGRESSION

This release changed the preset dropdowns to `e.ENUM_PRESET.slice(0, SERIES.capabilities.preset)`, but `presets.js` still generates `for (let i = 0; i < 100; i++)`. For the **AW-HE2** series (`src/models.js:208`, `preset: 9`) that emits 91 preset buttons whose `presetMem.val` and `presetMemory` / `presetSelected` / `presetComplete` option values (`'09'`…`'99'`) are no longer members of the choice list. Those dropdowns render as invalid, and if Companion coerces an out-of-choices dropdown to the field default, all 91 buttons collapse onto Preset 1. In `v1.2.0` the full 100-entry list was offered, so the definitions and the presets were at least self-consistent.

**Fix:** `for (let i = 0; i < SERIES.capabilities.preset; i++)` in `presets.js`. Consider clamping the `presetMemory` variable in `src/variables.js:218-224` for the same reason.

---

### M2: presetMem op default was corrected with no upgrade script — existing buttons stay broken

**File:** `src/actions.js:838`, `src/upgrades.js:28-46`
**Classification:** 🆕 NEW

`presetMem`'s `op` dropdown default was `e.ENUM_PRESET[0].id` (i.e. `'00'`, which was never one of the `R` / `M` / `C` choices) in `v1.2.0` and is now correctly `'R'`. Saved actions where the user never touched the Action dropdown still carry `op: '00'`, producing `getPTZ('00' + val)` — an invalid command — forever. The new `addSetStepSize` upgrade only touches `ptSpeed` / `zoomSpeed` / `focusSpeed` `step`.

(The `step` migration itself is correct and complete — it covers exactly the three actions whose callbacks gained `action.options.op * action.options.step`.)

**Fix:** add to `addSetStepSize`, or as a sibling script in `src/upgrades.js`:

```js
case 'presetMem':
	if (!['R', 'M', 'C'].includes(action.options.op)) action.options.op = 'R'
	result.updatedActions.push(action)
	break
```

---

### M3: Unguarded step/set on the four new speed actions produce NaN commands and poison module state

**File:** `src/actions.js:67-76` (`speedStep`), `:58-66` (`speedControlSetting`), used at `:432-437` and `:469-474`
**Classification:** 🆕 NEW

`speedStep` is declared `required: false` — unlike the `step` field in `optSetIncDecStep`, which is `required: true` — and `speedControlSetting` has no `required` either. `zoomControl`, `focusControl`, `zoomSpeed` and `focusSpeed` use `action.options.op * action.options.step` and `action.options.set` with **no `parseInt` or NaN guard**; these four are the only new numeric actions that bypass `parseSetIncDecVariables()`.

With an empty step field: `action.options.op * undefined` → `NaN` → `getNextValue(v, min, max, NaN)` → `constrainRange(NaN, …)` returns `NaN` (both `NaN > max` and `NaN < min` are false, `src/common.js:49-53`) → `self.data.zoomSpeedValue = NaN` → `cmdSpeed(NaN + 50)` → the module sends `#ZNaN` / `#FNaN`. Worse, `zoomSpeedValue` / `focusSpeedValue` stay `NaN` for the rest of the session, which permanently breaks the new `zoomControl` feedback (see [L7](#l7-fszs-speed-parsing-is-unvalidated-nan-reaches-the-wire-and-latches-the-feedback-on)) and every subsequent relative step. If the empty field arrives as `''` instead, the step silently becomes 0 and the action is a no-op with no log.

**Fix:** set `required: true` on `speedStep` and `speedControlSetting`, and guard in each callback:

```js
const step = parseInt(action.options.step, 10)
if (!Number.isFinite(step)) return
```

---

### M4: Duplicate poll loops accumulate across reconnects

**File:** `src/polling.js:4-22`, `src/index.js:505-508`
**Classification:** 🆕 NEW

`self.poll` is a single boolean shared by every loop. `reInitAll()` sets it `false`, then after `await this.getCam('QID')` sets it back to `true` and starts a **new** `pollCameraStatus()`. If the previous loop is suspended inside `await self[method](cmd)` for longer than that window — an outstanding HTTP request can hold for up to `config.timeout` — it resumes to find `self.poll === true` and keeps running alongside the new loop. Every reconnect cycle can add another loop, doubling polling traffic to the camera with no upper bound.

**Fix:** replace the boolean with a generation counter:

```js
// in reInitAll(): this.pollGeneration = (this.pollGeneration ?? 0) + 1
export async function pollCameraStatus(self) {
	const gen = self.pollGeneration
	while (self.poll && self.pollGeneration === gen) { ... }
}
```

---

### M5: presetClearAll issues up to 100 sequential, unthrottled, uncancellable requests

**File:** `src/actions.js:901-919`
**Classification:** 🆕 NEW

```js
for (let i = 0; i < SERIES.capabilities.preset; i++) {
	await self.getPTZ('C' + i.toString(10).padStart(2, '0'))
}
```

No pacing between commands, no check of `self.poll` / `this.destroyed` / `this.config.host`, and no abort on connection loss. If the camera stops answering mid-way, each request waits `config.timeout`, so a single button press can block for `100 × timeout` — and because each failure calls `handleConnectionError`, it also re-arms the reconnect timer up to 100 times. The loop keeps running after `destroy()`.

The confirmation checkbox on this action is good design; the execution just needs the same throttling as the poll loop.

**Fix:** `await sleep(self.config.pollDelay)` between iterations, `if (self.destroyed || !self.config.host) return` at the top of each iteration, and abort the loop after the first connection error.

---

### M6: New variable values are pushed unconditionally while their definitions are capability-gated

**File:** `src/variables.js:272-341`
**Classification:** 🆕 NEW (pattern pre-existed for `redGain`/`bluePed`; this release adds ~11 more)

`checkVariables()` passes a flat object literal to `self.setVariableValues({...})` containing `presetMemory` (line 272), `chromaPhase` (290), `focusSpeed` (291), `greenGain` (294), `greenPed` (297), `zoomSpeed` (299), `chromaLevel` (309), `dnr` (311), `drs` (312), `shootingMode` (326) and `videoFormat` (335). Their definitions in `setVariables()` are conditional — `greenGain` only when `colorGain.cmd.green` exists (one model), `greenPed` only for three models, `zoomSpeed` / `focusSpeed` only when `capabilities.zoom` / `focus`, `chromaPhase` for one model. On every other model these IDs are set but never declared, so they never appear in the variable picker yet still resolve in `$(label:greenGain)`. The SDK does not validate this, so it fails silently.

**Fix:** build the value object with the same capability guards used in `setVariables()`, or derive both from one shared capability → variable table so definitions and values can't drift.

---

### M7: No backoff — the retry interval is shorter than a single failing request

**File:** `src/index.js:461-475`
**Classification:** 🆕 NEW

The retry delay is a fixed `this.config.timeout + this.config.pollDelay` (~1–2 s by default), while one failing `got` GET can take considerably longer once `got`'s built-in retries are counted. An offline camera therefore produces a continuous, non-decaying request storm with overlapping re-init attempts, and the log fills at the same rate.

**Fix:** apply exponential backoff (e.g. 2 s → 4 s → 8 s, capped at 30–60 s), reset it on the first successful response, and log "camera unreachable" once per outage rather than once per failed request.

---

### M8: ENOTFOUND and EAI_AGAIN are missing from the recovery set

**File:** `src/index.js:461-469`
**Classification:** 🆕 NEW

A camera configured by hostname — or one whose DNS is briefly unavailable while Companion boots — fails with `ENOTFOUND` (or `EAI_AGAIN`), which falls through the `switch` to `ConnectionFailure` with **no** retry scheduled. The connection stays dead until the user manually re-applies the config, which undercuts the automatic recovery this release advertises.

**Fix:** add `ENOTFOUND` and `EAI_AGAIN` to the retried codes.

---

### M9: while (self.poll) can spin without ever awaiting

**File:** `src/polling.js:4-21`
**Classification:** 🆕 NEW

The recursion-to-loop rewrite means `groups` is recomputed each iteration, and **every** `await` sits in the innermost `for`. If a model declares a truthy `poll` (or, with subscription disabled, `pull`) whose `ptz` / `cam` / `web` entries are all `false` or empty, the loop body performs zero awaits and the `while` becomes a tight synchronous spin that pegs a core and blocks the module's event loop — the instance hangs rather than merely idling.

No shipped model hits this today (every truthy `poll` in `src/models.js` has at least one command), so this is latent — but `models.js` is exactly the extension point where a contributor would add `poll: { ptz: false, cam: false, web: false }`, and the previous recursive form did not fail this way.

**Fix:** track whether any command was issued in an iteration and yield unconditionally when none was:

```js
while (self.poll) {
	let sent = false
	// ... set sent = true when a command is issued
	if (!sent) await sleep(self.config.pollDelay)
}
```

---

### M10: reInitAll() is invoked from the timer with no .catch()

**File:** `src/index.js:472-474`
**Classification:** 🆕 NEW

`reInitAll()` is `async` and calls `getAndUpdateSeries()`, which does `MODELS.find(...).series` unguarded (`src/common.js:12`) — an unrecognised model string throws, and a rejection from a bare `setTimeout` callback is unhandled. Under Node 22 an unhandled rejection terminates the process by default.

**Fix:**

```js
this.timeoutID = setTimeout(() => {
	this.reInitAll().catch((e) => this.log('error', 'Re-initialisation failed: ' + String(e)))
}, this.config.timeout + this.config.pollDelay)
```

and make `getAndUpdateSeries()` tolerate an unknown model id.

---

## 🟢 Low

### L2: shootingMode missing from the this.data initialiser

**File:** `src/index.js:344-377`
**Classification:** 🆕 NEW

`src/parser.js:314` writes `self.data.shootingMode` and `src/variables.js:235` reads it, but it is not declared alongside the other unresolved enums added in this release (`chromaLevel`, `dnr`, `drs`, `videoFormat` all were). Until the first `OSJ:0C` arrives it is `undefined`, so `getLabel()` returns `undefined` and `setVariableValues({ shootingMode: undefined })` behaves differently from the `null` convention every other enum uses.

**Fix:** add `shootingMode: null,` to the unresolved-enums block.

---

### L3: New action options parse variables via the instance method instead of the callback context

**File:** `src/actions.js:278`, `:282`, `:874`
**Classification:** 🆕 NEW

All the new variable-driven action options call `self.parseVariablesInString(...)`. The feedback equivalent (`src/feedbacks.js:40`) correctly uses `context.parseVariablesInString(...)`. On `@companion-module/base` 1.11 only the callback `context` resolves action-scoped and local variables, so a `$(local:…)` expression in "Preset # variable", "Speed variable" or "Step size variable" resolves to `$NA` → `parseInt` → `NaN` → the action **silently does nothing** (the `if (isNaN(...)) return` path logs nothing).

**Fix:** change the signatures to `callback: async (action, context) => …` and thread `context` into `parseSetIncDecVariables()` and the `presetMem` resolver. Log at `debug` or `warn` when a variable is unreadable rather than returning silently.

---

### L4: parseSetIncDecVariables mutates the cached action instance

**File:** `src/actions.js:275-289`
**Classification:** 🆕 NEW (pre-existing helper, newly routed through by six more actions)

The helper writes the resolved value back into `action.options.set` / `action.options.step` — the module's cached copy of the action instance — rather than a local. This release routes `chromaPhase`, `pedGreen`, `gainGreen`, `audioVolumeLevel` and `ptSpeed` through it, so the visible number field and the hidden variable field now share state across many more actions.

**Fix:** return `{ set, step }` (or `null` on failure) and pass those into `cmdValue()` instead of writing back to `action.options`.

---

### L5: Preset variable is 1-based against a 0-based dropdown, with silent clamping

**File:** `src/actions.js:874`, `src/feedbacks.js:40`
**Classification:** 🆕 NEW

The dropdown ids are 0-based (`'00'` = Preset 1) but the variable path is 1-based, and out-of-range values are **clamped** rather than rejected: a variable evaluating to `0` silently recalls Preset 1, and one evaluating to `250` silently recalls the highest preset. Anyone feeding a 0-based index from another module gets a silent off-by-one on every button.

**Fix:** reject values outside `1..capabilities.preset` (return without acting and log at `warn`) rather than clamping — or standardise on the 0-based index the dropdown already uses.

---

### L6: Audio volume variables are published as unit-suffixed strings

**File:** `src/variables.js:349`
**Classification:** 🆕 NEW

```js
audioVars[`audioVolumeLevel${ch + 1}`] = self.data.audioVolumeLevels[ch] !== undefined ? `${self.data.audioVolumeLevels[ch]}dB` : null
```

This yields `"-6dB"`, while every other numeric variable in the module (`redGain`, `masterPed`, `chromaPhase`, `zoomSpeed`, …) is published as a bare number — and the variable is already named "… (dB)". The suffix makes the value unusable in expressions and comparisons.

**Fix:** publish the plain number and leave the unit in the variable name, or add a separate `audioVolumeLevel${n}Label` for the formatted form.

---

### L7: fS/zS speed parsing is unvalidated — NaN reaches the wire and latches the feedback on

**File:** `src/parser.js:131-137`, `src/feedbacks.js:251`
**Classification:** 🆕 NEW

`parseInt(str[0].substring(2, 4)) - 50` yields `NaN` for a short or non-numeric notification. `focusSpeedValue` / `zoomSpeedValue` then feed straight back into outbound commands via `cmdSpeed()` (`src/actions.js:301`), producing a literal `NaN` in the PTZ URL (`#FNaN`). The `zoomControl` feedback uses `self.data.zoomSpeedValue != 0`, and `NaN != 0` is `true`, so it stays permanently lit and the `zoomSpeed` variable shows `NaN` until the next good response.

**Fix:** validate before assigning and keep the previous value on a bad frame:

```js
const v = parseInt(str[0].substring(2, 4))
if (Number.isFinite(v)) self.data.zoomSpeedValue = v - 50
```

and use `Number(self.data.zoomSpeedValue) !== 0` in the feedback.

---

### L8: Second setVariableValues() call per update

**File:** `src/variables.js:346-352`
**Classification:** 🆕 NEW

`checkVariables()` runs on every HTTP response and every TCP push. The audio channels are set in a separate second `setVariableValues()` call rather than merged into the object built at line 267.

**Fix:** merge the audio entries into the single call.

---

### L9: getAllCameraStatus is dead code that this release extended

**File:** `src/polling.js:35+`
**Classification:** 🆕 NEW

Its only caller was replaced by `getCameraStatusOnce()`, yet this release added seven new query commands to it (`QCG`, `QSA:87`, `QSA:D5:0-3`, `QSD:3A`, `QSD:B0`, `QSE:33`, `QSJ:0B`). Maintenance effort is being spent on a function nothing calls, and the two command lists will drift.

**Fix:** delete `getAllCameraStatus`, or keep it as an explicit fallback for models that declare no `pull`/`poll` lists and document that.

---

### L10: camdata.html is now fetched even when the user disabled subscriptions

**File:** `src/index.js:498-503`
**Classification:** 🆕 NEW

The condition was split so `getCameraStatus()` runs whenever `capabilities.subscription` is true, regardless of `config.subscriptionEnable`. Combined with the new `getCameraStatusOnce()` and the `pull` branch of the poll loop, a user who deliberately turned subscriptions off now gets noticeably more HTTP traffic at init than in `v1.2.0`.

**Fix:** if intentional, note it in the release notes; if not, restore the original gating.

---

## 💡 Nice to Have

### N1: removeAllListeners().then() throws on every Pan/Tilt move with live speed

**File:** `src/actions.js:351-355`
**Classification:** ⚠️ Pre-existing — flagged because the diff reformatted this exact statement and the new sibling actions got it right

```js
self.speedChangeEmitter.removeAllListeners('ptSpeed').then(
	self.speedChangeEmitter.on('ptSpeed', async () => { ... }),
)
```

`EventEmitter.removeAllListeners()` returns the emitter, which has no `.then` — so this throws `TypeError: ... .then is not a function` out of the async action callback **every time** "Pan/Tilt - Move" runs with "Adjust the velocity on speed change" ticked. The listener does get registered (the `.on()` call is evaluated as the argument before `.then` is dereferenced), so the feature works, but the action always reports an error to Companion. The `zoomControl` and `focusControl` actions added in this release (`src/actions.js:422`, `:459`) already use the correct two-statement form.

**Fix:**

```js
self.speedChangeEmitter.removeAllListeners('ptSpeed')
self.speedChangeEmitter.on('ptSpeed', async () => { ... })
```

---

### N2: optSetLowerRaise is a verbatim copy of optSetIncDecStep

**File:** `src/actions.js:209-273` vs `:143-207`
**Classification:** 🆕 NEW

The two 60-line option builders differ only in two dropdown labels (`Raise`/`Lower` vs `Increase`/`Decrease`). Two copies will drift.

**Fix:** parameterise the labels — `optSetIncDecStep(label, def, min, max, step, incLabel = 'Increase', decLabel = 'Decrease')` — and delete `optSetLowerRaise`.

---

### N3: New presets do not attach their matching feedbacks

**File:** `src/presets.js:1156-1350`
**Classification:** 🆕 NEW

The new `chromaLevel`, `dnr`, `drs` and `shootingMode` presets all declare `feedbacks: []`, so out of the box those buttons show text only — even though matching feedbacks were added in the same release. The `zoomControl` preset does wire its feedback up, so the pattern is established.

**Fix:** attach the matching boolean feedback, with the preset's own dropdown value, to each new preset.

---

### N4: No focusControl feedback to match zoomControl

**File:** `src/feedbacks.js:241`
**Classification:** 🆕 NEW

There is a `zoomControl` feedback but no `focusControl` counterpart, despite `focusControl` (`src/actions.js:469`) and `self.data.focusSpeedValue` being added in the same release.

**Fix:** mirror the `zoomControl` feedback for focus.

---

### N5: speedStep max of 7 is an unexplained magic number

**File:** `src/actions.js:67-76`
**Classification:** 🆕 NEW

`speedStep.max: 7` is unexplained (the speed range it steps through is 0–49), and `required: false` is inconsistent with the `required: true` on the equivalent `step` field in `optSetIncDecStep` / `optSetLowerRaise` — see [M3](#m3-unguarded-stepset-on-the-four-new-speed-actions-produce-nan-commands-and-poison-module-state).

**Fix:** derive the max from `SPEED_MAX - SPEED_MIN`, or add a comment justifying 7.

---

### N6: audioVolumeLevel feedback bounds are unvalidated and ignore the model step

**File:** `src/feedbacks.js:726-742`
**Classification:** 🆕 NEW

The `minLevel` / `maxLevel` number fields ignore `caps.step`, and nothing validates them against each other — a user can set `minLevel > maxLevel` and get a feedback that never triggers, with no hint why.

**Fix:** add `step: caps.step` to both fields and either clamp in the callback or add a tooltip noting that min must be ≤ max.

---

### N7: The four HTTP helpers are duplicates with no cancellation

**File:** `src/index.js:207-299`
**Classification:** 🆕 NEW

`getPTZ` / `getCam` / `getWeb` / `getCameraStatus` are byte-for-byte identical apart from the URL and the response handling, and none of them can be cancelled.

**Fix:** a single `httpGet(url, opts)` wrapper carrying a shared `AbortController` (recreated per `reInitAll()`) would let `destroy()` and `configUpdated()` abort every in-flight request at once, and would close off the "old camera's late response paints the new camera's buttons" class of bug that the fire-and-forget calls in `reInitAll()` currently expose — see [C6](#c6-destroy-leaves-the-reconnect-timer-armed-a-deleted-instance-resurrects-itself-indefinitely) and [H1](#h1-getcamerastatusonce-is-an-unawaited-uncancellable-unthrottled-request-burst).

---

## Verified correct

Noting what was checked and found sound, so the maintainer knows these areas were exercised:

- Command encodings were cross-checked against `Camera_Dumps/AW-UE160_camdata.txt` — `OSA:D5:<ch>:0x80` audio, `OSG:4C/4D/4E:0x800` pedestal, `OSL:36/37/38:0x800` gain, `OSD:B0:0x00` chroma level, `OSD:3A:0x01` DNR, `OSJ:0C:0` shooting mode and `OSA:87:0x11` video format all line up on offsets, hex length and enum ids, including the `':0x'` → `':'` camdata pre-processing and the `parseInt(str[n], 16)` fallback that tolerates an un-stripped `0x` prefix on the TCP push path.
- `ENUM_PRESET` is exactly 100 entries `'00'`…`'99'`, so `(num - 1).toString(10).padStart(2, '0')` in `presetMem` is **not** off-by-one.
- `parseInt(...)` → `constrainRange(...)` → `isNaN(...)` correctly aborts on unreadable variables in `parseSetIncDecVariables`, `presetMem` and `parsePresetIdx` (`NaN` survives `constrainRange` because both comparisons are false).
- The 3-second-hold `presetClearAll` preset uses a valid `CompanionPresetActionsWithOptions` shape (`{ options: { runWhileHeld: true }, actions: [...] }`).
- The `addSetStepSize` upgrade script covers exactly the three actions whose callbacks gained `action.options.op * action.options.step`.
- The `init_variables()` → `init_actions()` → `init_feedbacks()` → `init_presets()` reorder in `reInitAll()` is an improvement — variable definitions now exist before any `setVariableValues()` from the concurrent status requests can run.
- `pollCameraStatus()` itself paces correctly (`await sleep(self.config.pollDelay)` per command) and checks `self.poll` before and after each request — the problems above are in `getCameraStatusOnce()`, which does neither.
- The `net` server has an `'error'` handler with a specific `EADDRINUSE` message, and each accepted socket has an `'error'` handler.
- All HTTP goes through `got` with an explicit per-request `timeout: { request: this.config.timeout }`; no blocking or synchronous network calls.
- `yarn lint` passes clean.
