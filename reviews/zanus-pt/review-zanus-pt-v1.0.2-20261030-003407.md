# Review: companion-module-zanus-pt v1.0.2

| Field | Value |
| --- | --- |
| **Module** | `companion-module-zanus-pt` |
| **Scope** | `tag` |
| **Version** | `v1.0.2` |
| **Release** | New module — never published |
| **API** | 1 (base 1.11.3, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review commit** | [`d8a4edd`](https://github.com/bitfocus/companion-module-zanus-pt/tree/d8a4edd761bb34c7077c937111462b8213d91570) |
| **Reviewed** | 2026-10-30 |

This is the module's first release. The repo has tags `v1.0.0` and `v1.0.1`, but neither was ever published, so there is no previous release to diff against. The whole module was reviewed, and every finding is classified 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Under API 1 (base 1.11), Companion does not resolve variables in `useVariables` text fields before the action callback runs, so the module must call `parseVariablesInString` itself | Auto-parsing of action options is documented for later API versions; Companion's host code was not checked for API 1.11 modules | [H1](#h1-preset-motion-between-two-presets-cannot-be-stopped-and-can-loop-forever) |
| A2 | Companion catches an exception thrown inside an action callback and logs it, rather than crashing the connection | base 1.11 forwards `executeAction` over IPC and returns the result; Companion's host-side handling was not read | [M4](#m4-up-and-down-step-actions-fail-at-the-end-of-their-range-and-the-next-opposite-press-is-lost) |
| A3 | Companion shows a status value outside the `InstanceStatus` enum (`'Connecting'` or `undefined`) as an unknown or grey state, not as Connecting or a red error | base 1.11 `updateStatus` passes the raw value over IPC unchanged (`node_modules/@companion-module/base/dist/module-api/base.js:495-500`); Companion's status mapping was not checked | [L1](#l1-the-module-sends-invalid-connection-status-values-to-companion) |
| A4 | The Zanus head reports `c.1.ae.gainlimit.max` and `c.1.ae.resp.min` / `.max` in its `info.cgi` reply. If it never does, only the stuck 330 upper bound remains | The module parses these XC-protocol keys; the device's real `info.cgi` output was not observed | [M5](#m5-ae-gain-limit-and-ae-response-replies-rebuild-every-action-and-preset-on-every-poll) |

## 📋 Issues

### Blocking

- [ ] [C1: The module can't be packaged because the package script is missing](#c1-the-module-cant-be-packaged-because-the-package-script-is-missing)
- [ ] [C2: The yarn package build fails](#c2-the-yarn-package-build-fails)
- [ ] [C3: Manifest runtime is node18 instead of node22](#c3-manifest-runtime-is-node18-instead-of-node22)
- [ ] [C4: package.json is missing the engines field](#c4-packagejson-is-missing-the-engines-field)
- [ ] [C5: package.json is missing the packageManager field](#c5-packagejson-is-missing-the-packagemanager-field)
- [ ] [C6: package.json is missing the prettier field](#c6-packagejson-is-missing-the-prettier-field)
- [ ] [C7: .gitignore is missing template entries](#c7-gitignore-is-missing-template-entries)
- [ ] [C8: .prettierignore differs from the template](#c8-prettierignore-differs-from-the-template)
- [ ] [H1: Preset Motion Between Two Presets cannot be stopped and can loop forever](#h1-preset-motion-between-two-presets-cannot-be-stopped-and-can-loop-forever)
- [ ] [H2: Custom Trace in Pendulum mode with 2 presets gets stuck on the second preset](#h2-custom-trace-in-pendulum-mode-with-2-presets-gets-stuck-on-the-second-preset)
- [ ] [H3: LICENSE differs from the template](#h3-license-differs-from-the-template)

### Non-blocking

- [ ] [M1: A running Custom Trace keeps moving the head after the connection settings change](#m1-a-running-custom-trace-keeps-moving-the-head-after-the-connection-settings-change)
- [ ] [M2: Clearing the Device IP leaves the status on Connecting and the old 5-minute check running](#m2-clearing-the-device-ip-leaves-the-status-on-connecting-and-the-old-5-minute-check-running)
- [ ] [M3: Status stays Connecting after a settings change while the head is unreachable](#m3-status-stays-connecting-after-a-settings-change-while-the-head-is-unreachable)
- [ ] [M4: Up and Down step actions fail at the end of their range and the next opposite press is lost](#m4-up-and-down-step-actions-fail-at-the-end-of-their-range-and-the-next-opposite-press-is-lost)
- [ ] [M5: AE Gain Limit and AE Response replies rebuild every action and preset on every poll](#m5-ae-gain-limit-and-ae-response-replies-rebuild-every-action-and-preset-on-every-poll)
- [ ] [L1: The module sends invalid connection status values to Companion](#l1-the-module-sends-invalid-connection-status-values-to-companion)
- [ ] [L2: Regular polling never resumes once the head answers again](#l2-regular-polling-never-resumes-once-the-head-answers-again)
- [ ] [L3: Custom Trace Repeat Count counts single preset moves, not passes](#l3-custom-trace-repeat-count-counts-single-preset-moves-not-passes)
- [ ] [L4: The dropdown Preset Recall action is silently replaced by Recall by number](#l4-the-dropdown-preset-recall-action-is-silently-replaced-by-recall-by-number)
- [ ] [L5: Save Preset N button presets do not save Lens Correction](#l5-save-preset-n-button-presets-do-not-save-lens-correction)
- [ ] [L6: Update Interval and HTTP Port accept any text](#l6-update-interval-and-http-port-accept-any-text)
- [ ] [L7: Text fields that accept variables show no variable picker](#l7-text-fields-that-accept-variables-show-no-variable-picker)
- [ ] [L8: Pedestal steps start at +1 and Delete preset sends p=NaN on bad input](#l8-pedestal-steps-start-at-1-and-delete-preset-sends-pnan-on-bad-input)
- [ ] [L9: init and Change Module IP do not await configUpdated](#l9-init-and-change-module-ip-do-not-await-configupdated)
- [ ] [L10: Leftover template file src/main.js and implicit globals](#l10-leftover-template-file-srcmainjs-and-implicit-globals)
- [ ] [L11: Manifest version 1.0.0 does not match the 1.0.2 release](#l11-manifest-version-100-does-not-match-the-102-release)
- [ ] [N1: Placeholder no-op upgrade script shipped in the first release](#n1-placeholder-no-op-upgrade-script-shipped-in-the-first-release)
- [ ] [F1: Consider upgrading companion-module/base beyond 1.11](#f1-consider-upgrading-companion-modulebase-beyond-111)

## 🔴 Critical

### C1: The module can't be packaged because the package script is missing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:5-9`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/package.json#L5-L9)

**What goes wrong:** The Bitfocus build pipeline runs `yarn package` to produce the installable module. This module has no `package` script, so no package can be built and the release can't be installed.

**Why it happens:** The `scripts` block has only `test`, `format` and `format:check`. The template defines `"package": "companion-module-build"`.

**Fix:** add the template's `package` script.

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
}
```

### C2: The yarn package build fails

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json:5-9`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/package.json#L5-L9)

**What goes wrong:** `yarn package` fails, so no `.tgz` is produced. `yarn install --immutable` succeeded.

**Why it happens:** This follows from [C1](#c1-the-module-cant-be-packaged-because-the-package-script-is-missing): there is no `package` script to run.

**Fix:** add the `package` script from C1, then run `yarn package` locally and check that it produces a `.tgz`.

### C3: Manifest runtime is node18 instead of node22

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/companion/manifest.json#L18)

**What goes wrong:** The module asks Companion for Node 18, which is end-of-life. The v1 template targets Node 22.

**Why it happens:** Expected `"type": "node22"`, found `"type": "node18"`.

**Fix:** set `runtime.type` to `node22`.

```json
"runtime": {
	"type": "node22",
```

### C4: package.json is missing the engines field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/package.json)

**What goes wrong:** Nothing pins the Node and Yarn versions the module is built with, so builds can differ from the template's.

**Why it happens:** The template has an `engines` field; this `package.json` has none.

**Fix:** add the template's `engines` block.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
}
```

### C5: package.json is missing the packageManager field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/package.json)

**What goes wrong:** Corepack can't tell which Yarn version to use, so the build may run under a different Yarn than the lockfile was written with.

**Why it happens:** The template has `"packageManager": "yarn@4.12.0"`; this `package.json` has none.

**Fix:** add `"packageManager": "yarn@4.12.0"` (or the Yarn 4 version that wrote `yarn.lock`).

### C6: package.json is missing the prettier field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/package.json)

**What goes wrong:** `yarn format` formats with Prettier's defaults instead of the shared Companion style.

**Why it happens:** The template has `"prettier": "@companion-module/tools/.prettierrc.json"`; this `package.json` has none.

**Fix:** add `"prettier": "@companion-module/tools/.prettierrc.json"`.

### C7: .gitignore is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/.gitignore)

**What goes wrong:** Built packages, debug logs and the local Yarn folder can be committed by accident.

**Why it happens:** The template entries `/*.tgz`, `DEBUG-*` and `/.yarn` are missing.

**Fix:** use the template's `.gitignore`.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C8: .prettierignore differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/.prettierignore)

**What goes wrong:** `yarn format` treats files differently from every other module built on the template.

**Why it happens:** Line 1 is `node_modules`; the template's line 1 is `package.json`.

**Fix:** use the template's `.prettierignore`.

```text
package.json
/LICENSE.md
```

## 🟠 High

### H1: Preset Motion Between Two Presets cannot be stopped and can loop forever

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:2051-2091`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L2051-L2091)

**What goes wrong:** An operator presses a button with "Preset - Motion Between Two Presets" (First Preset 1, Second Preset 2, Time 60, Loops 100). The head swings between presets 1 and 2 for about 3 hours. Nothing stops it: "Pan/Tilt - Stop" and "Trace - Stop Custom Trace Loop" have no effect (the next timer fires and the head moves again), and changing the connection's IP doesn't cancel it either (the moves then go to the new device). Pressing the button twice runs two loops interleaved. If Loops holds non-numeric text such as `abc`, the loop never ends. If Time holds a variable such as `$(internal:x)`, the delay becomes `NaN` (about 1 ms), so the head gets a burst of `p=..&p.ptztime=NaN` recalls.

**Why it happens:** The action builds a chain of `setTimeout` calls (1 s to start, then `time`, then `time` again, recursively) and never keeps their handles, so nothing can cancel them. `stopCustomTrace()`, which the Stop action and the loop itself call, only clears the Custom Trace timer. `destroy()` and `configUpdated()` don't touch these timers either. Loops is compared as a string and never converted to a number: with `abc` the count becomes `NaN`, and `NaN <= 0` is always false. Time is used as typed (`action.options.time * 1000`) without resolving variables (see [A1](#-assumptions-to-confirm)) and without the 2-60 s limit its label promises. Second Preset isn't checked against 1-100 the way First Preset is.

**Evidence:**

```js
// src/actions.js:2051-2090
if (action.options.loops < 1) action.options.loops = 1
if (action.options.loops > 100) action.options.loops = 100

const time = action.options.time * 1000

setTimeout(async () => {
	loopPTZ(preset1, preset2, time, action.options.loops)
}, 1000)

function loopPTZ(preset1, preset2, time, count) {
	if (count <= 0) {
		console.log('DONE!')
		return
	}
	...
	self.stopCustomTrace()
	self.sendCmd(self.controlCommand, cmd)
	...
	setTimeout(() => {
		...
		self.stopCustomTrace()
		self.sendCmd(self.controlCommand, cmd)
		...
		// Call the function again to loop
		setTimeout(() => loopPTZ(preset1, preset2, time, count - 1), time)
	}, time)
}
```

```js
// src/utils.js:80-92
stopCustomTrace: function () {
	...
	self.customTraceLoop = false
	self.customTraceLoopCount = 0
	clearTimeout(self.customTraceLoopInterval)
},
```

```js
// src/index.js:40-49
async destroy() {
	if (this.pollTimer) {
		clearInterval(this.pollTimer)
		this.pollTimer = null
	}

	if (this.pollTimerOnlineStatus) {
		clearInterval(this.pollTimerOnlineStatus)
	}
}
```

```text
// node -e check (Loops option "abc")
"abc"<1 -> false, "abc">100 -> false, "abc"<=0 -> false, ("abc"-1)<=0 -> false  => recursion never terminates
```

**Confirm by:** open [`src/actions.js:2056-2089`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L2056-L2089) and check that none of the three `setTimeout` handles is stored or checked against a flag. Then open [`src/utils.js:80-92`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/utils.js#L80-L92) (`stopCustomTrace` clears only `customTraceLoopInterval`) and [`src/index.js:40-49`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L40-L49): none of them cancel this loop.

**Fix:** keep the pending motion timer on the instance and cancel it from every stop path, and validate the inputs.

```js
// every time the loop is (re)scheduled
self.motionLoopTimer = setTimeout(...)

// in stopCustomTrace() (or a shared stopMotion()), destroy() and configUpdated(),
// and before starting a new motion loop
clearTimeout(self.motionLoopTimer)

// inputs
const loops = Math.min(Math.max(parseInt(action.options.loops) || 1, 1), 100)
let seconds = parseFloat(await self.parseVariablesInString(action.options.time))
seconds = Math.min(Math.max(isNaN(seconds) ? 10 : seconds, 2), 60)
// clamp preset2 to 1-100 the same way as preset1
```

### H2: Custom Trace in Pendulum mode with 2 presets gets stuck on the second preset

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/utils.js:11-19`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/utils.js#L11-L19)

**What goes wrong:** An operator adds "Trace - Custom Trace" with Number of Presets 2 (presets 1 and 2), Loop Until Stopped Manually on, and Loop Mode Pendulum. The head moves to preset 1, then preset 2, then keeps recalling preset 2 on every cycle and never goes back to preset 1. Starting from the Last preset ends the same way after one bounce. Two presets is the default and smallest choice. With 3 or more presets, Pendulum works (1, 2, 3, 2, 1, …).

**Why it happens:** When the trace reaches the last preset, the code turns around by setting the position to `length - 2`. With 2 presets that is 0, and the special case `if (position == 0)` then flips the direction back to forward and sets the position to 1, so the last preset is replayed again and again.

**Evidence:**

```js
// src/utils.js:11-23
} else if (loopMode == 'pendulum') {
	//which bound did we hit, swap direction depending on that
	if (position >= self.customTracePresetArray.length - 1) {
		direction = 'backward'
		position = self.customTracePresetArray.length - 2
		if (position == 0) {
			direction = 'forward'
			position = 1
		}
	} else if (position < 0) {
		direction = 'forward'
		position = 1
	}
```

```js
// src/actions.js:2418-2428 (2 presets is the default and smallest choice)
type: 'dropdown',
label: 'Number of Presets',
id: 'presetCount',
default: 2,
choices: [
	{ id: 2, label: '2' },
```

```text
// the module's own runCustomTrace run through node -e, setTimeout stubbed
len=2 start=0 forward : p=1 p=2 p=2 p=2 p=2 p=2 p=2 p=2 p=2
len=2 start=1 backward: p=2 p=1 p=2 p=2 p=2 p=2 p=2 p=2 p=2
len=3 start=0 forward : p=1 p=2 p=3 p=2 p=1 p=2 p=3 p=2 p=1
```

**Confirm by:** step through [`src/utils.js:13-19`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/utils.js#L13-L19) with `customTracePresetArray.length = 2` and `position = 2`. Line 15 sets the position to 0, then lines 16-18 force it back to 1 going forward, so preset 2 is recalled on every cycle.

**Fix:** remove the `position == 0` override and just bounce at each end.

```js
if (position >= self.customTracePresetArray.length - 1) {
	direction = 'backward'
	position = Math.max(self.customTracePresetArray.length - 2, 0)
} else if (position < 0) {
	direction = 'forward'
	position = Math.min(1, self.customTracePresetArray.length - 1)
}
```

### H3: LICENSE differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/LICENSE#L3)

**What goes wrong:** The module's licence notice doesn't match the one every Bitfocus module ships with.

**Why it happens:** Line 3 is `Copyright (c) 2026 Nikola Todorovic`; the template's line 3 is `Copyright (c) 2022 Bitfocus AS - Open Source`.

**Fix:** use the template's `LICENSE` file unchanged.

## 🟡 Medium

### M1: A running Custom Trace keeps moving the head after the connection settings change

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified (downgraded to Medium)
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:40-49`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L40-L49), [`src/index.js:55-62`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L55-L62)

**What goes wrong:** A user starts "Trace - Custom Trace" (for example 4 presets, Loop on, 10 s each), then changes the Device IP in the connection settings. The trace isn't cancelled: it keeps sending preset moves, now to the new device. Only "Trace - Stop Custom Trace Loop" ends it. The Custom Trace feedback still shows it as running, which is why this is Medium rather than High.

**Why it happens:** The trace re-arms its own timer (`customTraceLoopInterval`) while it is looping. `destroy()` clears only the two poll intervals, and `configUpdated()` never calls `stopCustomTrace()`. Each command builds a new connection from the current settings, so after an IP change the moves go to the new address.

**Fix:** call `this.stopCustomTrace()` in `destroy()` and at the start of `configUpdated()`. It already clears the timer and resets the loop flag.

### M2: Clearing the Device IP leaves the status on Connecting and the old 5-minute check running

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:55-62`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L55-L62), [`src/index.js:218-228`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L218-L228)

**What goes wrong:** A user adds the connection without a Device IP, or empties the field and saves. The status shows Connecting with no hint that the configuration is incomplete. If an IP was set before, the 5-minute online check keeps requesting `http://:80/-wvhttp-01-/info.cgi`; those requests fail and the status flips to Connection Failure, never to a bad-configuration message.

**Why it happens:** `configUpdated()` stops only the regular poll timer. The 5-minute online-check timer is cleared only inside `initPolling()`, which runs only when the host is set. There is no branch that reports a bad configuration when the host is empty.

**Fix:** clear both timers unconditionally in `configUpdated()`, and when the host is empty call `this.updateStatus(InstanceStatus.BadConfig, 'Device IP not set')` and start no polling.

### M3: Status stays Connecting after a settings change while the head is unreachable

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/polling.js:110-123`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/polling.js#L110-L123)

**What goes wrong:** The head is offline and the connection shows Connection Failure. The user edits the connection (for example corrects the IP to another unreachable address) and saves. The status goes to Connecting and stays there, even though every request fails, which hides the failure.

**Why it happens:** Connection Failure is reported only while the error counter is zero. The counter is reset only on a successful reply, and `configUpdated()` resets the status but not the counter, so no later failure updates the status.

**Fix:** set `this.errorCount = 0` in `configUpdated()` before starting the new requests, or report Connection Failure whenever the status isn't already a failure.

### M4: Up and Down step actions fail at the end of their range and the next opposite press is lost

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:446-451`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L446-L451), [`src/actions.js:1012-1017`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1012-L1017), [`src/actions.js:1105-1118`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1105-L1118), [`src/actions.js:1255-1260`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1255-L1260), [`src/actions.js:1378-1383`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1378-L1383), [`src/actions.js:1439-1444`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1439-L1444), [`src/actions.js:1575-1580`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1575-L1580), [`src/actions.js:1635-1640`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1635-L1640), [`src/actions.js:1695-1700`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1695-L1700)

**What goes wrong:** An operator presses "Pan/Tilt - Speed Down" until Speed 01 (Slow), then once more. The action fails with a TypeError in the log (see [A2](#-assumptions-to-confirm)), and the internal position is now one past the end, so the next "Pan/Tilt - Speed Up" press only gets back to Speed 01 instead of Speed 02. The same happens with Exposure Shutter Up, Iris Up (including Steps above 1 near the top), Gain Up, ND Filter Up (after ND 1/64), Pedestal Up (after 50), Kelvin Up, R Gain Up and B Gain Up (after +50).

**Why it happens:** The upper-bound check compares against the list length instead of the last index, so the position can reach `length`, and reading the entry at `length` gives `undefined`. Zoom and focus speed use `length - 1` correctly.

**Fix:** use `if (idx < list.length - 1) idx++` in every Up/Down action and clamp multi-step iris moves with `Math.min(idx + steps, list.length - 1)`. A shared `stepIndex(idx, delta, len)` helper would remove the copy-paste.

### M5: AE Gain Limit and AE Response replies rebuild every action and preset on every poll

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/polling.js:324-393`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/polling.js#L324-L393)

**What goes wrong:** When the head's status reply includes the AE gain-limit or AE response ranges (see [A4](#-assumptions-to-confirm)), the module re-sends the full action list and about 300 button presets to Companion on every poll (every 5 s by default) and after every button press, which adds needless CPU and IPC load. The Value range of "AE Gain Limit Max" also never follows the head's reported maximum; it stays at 330.

**Why it happens:** Unlike the speed and list handlers, these four cases rebuild actions and presets without checking whether the value changed. The case meant for the maximum (`c.1.ae.gainlimit.max.max`) was typed as a second `case 'c.1.ae.gainlimit.max':`, which can never be reached.

**Fix:** rename the second case to `'c.1.ae.gainlimit.max.max'`, and only rebuild when the parsed value differs from the stored one, as the zoom/focus speed handlers already do. The current-value case (`c.1.ae.gainlimit.max`) should just store the value.

## 🟢 Low

### L1: The module sends invalid connection status values to Companion

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:219`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L219), [`src/polling.js:107`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/polling.js#L107), [`src/polling.js:128`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/polling.js#L128), [`src/actions.js:35`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L35)

**What goes wrong:** Right after the settings are saved with a Device IP, the status is set to `'Connecting'` (capital C), which isn't a valid status, so the Connections list may briefly show an unknown state (see [A3](#-assumptions-to-confirm)). On a reply-parsing error or an unexpected send error, the status sent is `undefined` instead of a red error with the message. These error paths are rarely reached.

**Why it happens:** In `@companion-module/base` 1.11 the Connecting value is lowercase `connecting`, and `InstanceStatus` has no `Error` member (only `UnknownError`), so `InstanceStatus.Error` is `undefined`.

**Fix:** use `this.updateStatus(InstanceStatus.Connecting)` in `src/index.js` (import `InstanceStatus`, and use it in the `'connecting'` call at line 56 too), and replace `InstanceStatus.Error` with `InstanceStatus.UnknownError` (or `ConnectionFailure` where it fits) in `src/polling.js` and `src/actions.js`.

### L2: Regular polling never resumes once the head answers again

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/polling.js:117-120`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/polling.js#L117-L120)

**What goes wrong:** Companion starts while the head is still powered off, or the head drops off the network once, with "Continue Polling even in error state" left off (the default). The 5-second poll stops. When the head comes back, the 5-minute online check sets the status to OK, but feedbacks and variables such as pan/tilt position, tally and last used preset now refresh only every 5 minutes (or after an action) until the user re-saves the connection.

**Why it happens:** A failed request stops the regular poll, but the success path only sets the status to OK and never restarts it, even though the comment at `src/polling.js:17` says the 5-minute timer is there to detect that the head came back.

**Fix:** in the success branch, when the regular poll timer isn't running and the interval is above 0, call `this.initPolling()` (or restart only the regular timer).

### L3: Custom Trace Repeat Count counts single preset moves, not passes

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:2591-2604`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L2591-L2604)

**What goes wrong:** With Loop off, Number of Presets 3 and Repeat Count 2, the head goes 1, 2, 3, 1 and stops partway through the second pass. Users who expect "repeat the trace N times" get N preset moves instead. A non-numeric Repeat Count stops after one move.

**Why it happens:** The repeat count stored on the instance is reset to 0 by the `stopCustomTrace()` call a few lines later, and the trace then counts once per preset step.

**Fix:** count completed passes (when the position wraps, or reverses in Pendulum) and compare against Repeat Count × presets. Remove the dead assignment and validate Repeat Count with `parseInt` and a minimum of 1.

### L4: The dropdown Preset Recall action is silently replaced by Recall by number

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:1912`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1912), [`src/actions.js:1950`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L1950)

**What goes wrong:** Only one of the two recall actions appears in the action list. The dropdown "Preset - Recall" never shows up.

**Why it happens:** Both definitions are assigned to `actions.recallPset`, so the second replaces the first.

**Fix:** remove the first definition or give it its own id (for example `recallPsetDropdown`).

### L5: Save Preset N button presets do not save Lens Correction

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:2694-2704`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/presets.js#L2694-L2704)

**What goes wrong:** Pressing a "Save Preset 5" button from the Save Preset category sends `...&lenscorrect=disabled` instead of `all=enabled`, so lens correction isn't stored. A "Preset - Save" action added by hand (all boxes ticked by default) saves everything.

**Why it happens:** The button preset's options leave out `save_lenscorrect`, so it is `undefined`, the "all ticked" check fails, and lens correction is sent as disabled.

**Fix:** add `save_lenscorrect: true` to the preset's options.

### L6: Update Interval and HTTP Port accept any text

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.js:26-32`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/config.js#L26-L32), [`src/config.js:49-61`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/config.js#L49-L61)

**What goes wrong:** Typing `5s` in "Update Interval" quietly turns polling off with no error. Typing `10` polls the head every 10 ms with no limit on overlapping requests, which floods the head and Companion. "HTTP Port" accepts any text as well.

**Why it happens:** Both are free text fields with no validation and numeric defaults (80, 5000). The interval is compared with `> 0` and passed straight to `setInterval`.

**Fix:** make `interval` a `number` field (min 0, with a sensible minimum such as 250 ms when not 0, default 5000) and `httpPort` a `number` field (1-65535, default 80), or keep text fields with string defaults and `Regex.NUMBER` / `Regex.PORT`.

### L7: Text fields that accept variables show no variable picker

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:107-111`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L107-L111), [`src/actions.js:270-277`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L270-L277), [`src/actions.js:523-530`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/actions.js#L523-L530)

**What goes wrong:** In "System - Change Module IP" (Module IP), "Send Custom Command" (Custom Command) and "Lens - Set Zoom Value" (Zoom Value), a user gets no variable picker or autocomplete and no sign that variables work, although they do.

**Why it happens:** The callbacks resolve variables in these options, but the field definitions don't set `useVariables: true`.

**Fix:** add `useVariables: true` to the `host`, `command` and `value` text fields.

### L8: Pedestal steps start at +1 and Delete preset sends p=NaN on bad input

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:196`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L196)

**What goes wrong:** The first "Exposure - Pedestal Up" press sends +2 and the first Down sends 0, because the starting point is 1 rather than 0 (R and B gain start correctly at 0). Separately, "Preset - Delete (by number)" with an empty or non-numeric value sends `preset/set?p=NaN&all=disabled`.

**Why it happens:** `pedestalIndex` starts at 51 on a −50..50 list, where index 50 is 0. The delete action doesn't check the parsed number the way the save action does.

**Fix:** start `pedestalIndex` at 50, and in the delete action log and return when the value isn't a number from 1 to 100.

### L9: init and Change Module IP do not await configUpdated

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.js:51-53`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/index.js#L51-L53)

**What goes wrong:** No visible effect today. If anything in `configUpdated()` ever threw, the error would be an unhandled rejection that could crash the connection instead of being reported by Companion as a failed start.

**Why it happens:** `init()` and the "System - Change Module IP" callback (around `src/actions.js:128`) call the async `configUpdated()` without `await`.

**Fix:** use `await this.configUpdated(config)` in `init()` and `await self.configUpdated(self.config)` in the action.

### L10: Leftover template file src/main.js and implicit globals

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:1-63`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/main.js#L1-L63)

**What goes wrong:** No user-visible effect. `src/main.js` is the stock template and isn't the entrypoint (the manifest points to `src/index.js`); it would crash if run, and a maintainer may edit it by mistake. `delay` (`src/actions.js:2617`) and `variableValues` (`src/variables.js`) are assigned without being declared, which creates globals. The power presets in `src/presets.js:36-140` are never shown, because no supported head reports power state.

**Fix:** delete `src/main.js`, declare `let delay = 0` and `const variableValues = {}`, and optionally remove the unreachable power presets, feedback and variable code.

### L11: Manifest version 1.0.0 does not match the 1.0.2 release

- **Source:** 🔎 template-check rule (manifest version)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:6`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/companion/manifest.json#L6)

**What goes wrong:** Anyone reading the repo sees version 1.0.0 in the manifest while `package.json` and the tag say 1.0.2, which makes it harder to tell which release a bug report refers to.

**Why it happens:** The manifest `version` was set to a real version and not updated. The template keeps `"0.0.0"` there and the build fills in the real version; a committed real version must match `package.json` exactly.

**Fix:** set the manifest `version` to `"0.0.0"` (the template placeholder), or keep it in step with `package.json`.

## 💡 Nice to Have

### N1: Placeholder no-op upgrade script shipped in the first release

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.js:1-9`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/src/upgrades.js#L1-L9)

**What goes wrong:** No visible effect. The script runs once on every connection and changes nothing, but once shipped it can never be removed.

**Why it happens:** A first release has nothing to upgrade from, so the placeholder function has no job.

**Fix:** export an empty array (or keep the template's commented-out example) and add real scripts only when an action, feedback or config id changes.

## 🔮 Next Release

### F1: Consider upgrading companion-module/base beyond 1.11

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:16`](https://github.com/bitfocus/companion-module-zanus-pt/blob/d8a4edd761bb34c7077c937111462b8213d91570/package.json#L16)

**What goes wrong:** No visible effect. The v1 template is on `~1.14.1`. Newer versions add `isVisibleExpression` (1.12), automatic variable parsing and `description` hints (1.13) and the consistent config layout (1.14); API 2.x (Companion 4.3+) adds expressions.

**Fix:** in a later release move to `~1.14`, or to v2 following the v1-to-v2 migration guidance. With 1.12+ replace the `isVisible` functions (`src/config.js:62`, `src/actions.js:1814-2557`) with `isVisibleExpression`; with 1.13+ drop the now-redundant `parseVariablesInString` calls on `useVariables` fields.
