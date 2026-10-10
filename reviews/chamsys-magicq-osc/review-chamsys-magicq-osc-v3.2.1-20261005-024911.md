# Review: chamsys-magicq-osc v3.2.1

| | |
| --- | --- |
| **Module** | `companion-module-chamsys-magicq-osc` ([repo](https://github.com/bitfocus/companion-module-chamsys-magicq-osc)) |
| **Version** | v3.2.1 (`dc4b93d`, 2026-10-01) |
| **Previous tag** | v3.1.1 (`8e99e4e`) |
| **Scope:** | tag (`v3.1.1..v3.2.1`) |
| **Language** | JavaScript (ESM) |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned for API 2.0) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Build** | `yarn install --immutable` and `yarn package` pass |
| **Review date** | 2026-10-05 |

This release moves the module from the Companion module API v1 (a single `index.js`) to API 2.0, split into `src/`. Every finding below is new in this release or a regression caused by it.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a field is switched to expression mode, Companion's show/hide check (`isVisibleExpression`) reads that field's raw expression text or a stale value, not the evaluated result, so a field that depends on it can be shown or hidden wrongly | the warning in base 2.0.4's own typings (`input.d.ts`); Companion's host code not checked | [M3](#m3-dependent-fields-may-show-or-hide-wrongly-when-comparison-method-or-toggle-uses-an-expression) |

## 📋 Issues

### Blocking

- [ ] [C1: The connection settings cannot be opened, and a new connection never starts](#c1-the-connection-settings-cannot-be-opened-and-a-new-connection-never-starts)
- [ ] [H1: Unticking Enable Feedback now removes all feedbacks, variables and OSC forwarding, and the change isn't documented](#h1-unticking-enable-feedback-now-removes-all-feedbacks-variables-and-osc-forwarding-and-the-change-isnt-documented)

### Non-blocking

- [ ] [M1: Saving the connection settings makes execute variables disappear](#m1-saving-the-connection-settings-makes-execute-variables-disappear)
- [ ] [M2: One network error can leave the connection red until the settings are changed](#m2-one-network-error-can-leave-the-connection-red-until-the-settings-are-changed)
- [ ] [M3: Dependent fields may show or hide wrongly when Comparison method or Toggle uses an expression](#m3-dependent-fields-may-show-or-hide-wrongly-when-comparison-method-or-toggle-uses-an-expression)
- [ ] [M4: The Flash, Black Out and Swap Mode choices can be turned into expressions that need hidden number codes](#m4-the-flash-black-out-and-swap-mode-choices-can-be-turned-into-expressions-that-need-hidden-number-codes)
- [ ] [L1: An OSC message without a number sets variables to NaN](#l1-an-osc-message-without-a-number-sets-variables-to-nan)
- [ ] [L2: The connection stays on Connecting forever when the console never replies](#l2-the-connection-stays-on-connecting-forever-when-the-console-never-replies)
- [ ] [L3: Errors while setting up the connection are not caught or shown](#l3-errors-while-setting-up-the-connection-are-not-caught-or-shown)
- [ ] [L4: Every fader move from the console triggers a status update and debug log lines](#l4-every-fader-move-from-the-console-triggers-a-status-update-and-debug-log-lines)
- [ ] [L5: Execute buttons set to Toggle do nothing when the hidden level is blank or not a number](#l5-execute-buttons-set-to-toggle-do-nothing-when-the-hidden-level-is-blank-or-not-a-number)
- [ ] [L6: Execute page numbers are limited differently across actions, feedback and incoming OSC](#l6-execute-page-numbers-are-limited-differently-across-actions-feedback-and-incoming-osc)
- [ ] [N1: An empty RPC Command still sends a message to the console](#n1-an-empty-rpc-command-still-sends-a-message-to-the-console)

---

## 🔴 Critical

### C1: The connection settings cannot be opened, and a new connection never starts

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.js:1`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L1), used at [`src/main.js:342`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L342), [`src/main.js:351`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L351), [`src/main.js:367`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L367), [`src/main.js:388`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L388)

**What goes wrong:** On v3.2.1 the connection's settings can't be opened, so nobody can set or change **Target IP**, **Target Port**, **Feedback Port** or the forwarding settings. How bad that is depends on whether the connection already had saved settings:

- **A new MagicQ connection never starts.** Companion fails to start it, retries every few seconds, and fails again. The settings panel shows only "Connection is not running", so the console address can never be entered.
- **An existing connection upgraded to v3.2.1** keeps running with its saved settings, but its settings panel shows "Failed to load configuration fields", so its IP and ports can't be changed.

**Why it happens:** Companion asks the module for the list of fields on the connection's settings page by calling its `getConfigFields()` function. Four of those fields check their input against `Regex.IP` or `Regex.PORT`, the ready-made patterns from the `@companion-module/base` library. When this release split the old `index.js` into `src/`, the new `src/main.js` stopped importing `Regex` from the library, so the name doesn't exist when `getConfigFields()` runs, and JavaScript throws `ReferenceError: Regex is not defined`. The module is plain JavaScript with no type check, so neither the build nor the lint catches it. The other files that use `Regex` (`src/actions.js` and `src/feedbacks.js`) import it correctly, so actions and feedbacks are not affected.

**Evidence:**

```js
// src/main.js:1-9 (v3.2.1)
import { InstanceBase, InstanceStatus } from '@companion-module/base'
import osc from 'osc'

import UpdateActions from './actions.js'
import UpdateFeedbacks from './feedbacks.js'
import UpdateVariableDefinitions from './variables.js'
import UpgradeScripts from './upgrades.js'

export default class MagicQInstance extends InstanceBase {
// src/main.js:325, 336-352 (v3.2.1)
	getConfigFields() {
...
				type: 'textinput',
				id: 'host',
				label: 'Target IP',
				tooltip: 'The IP of the Chamsys console',
				default: '127.0.0.1',
				width: 6,
				regex: Regex.IP,
			},
			{
				type: 'textinput',
				id: 'port',
				label: 'Target Port',
				tooltip: 'The OSC RX port of the Chamsys console',
				default: '8000',
				width: 4,
				regex: Regex.PORT,
// src/main.js:367, 388 (v3.2.1)
				regex: Regex.PORT,
				regex: Regex.PORT,
```

```js
// git show v3.1.1:index.js:1 (previous tag; Regex was imported before the split)
const { InstanceBase, Regex, runEntrypoint, InstanceStatus, combineRgb } = require('@companion-module/base')
```

Loading `src/main.js` at v3.2.1 under node (base 2.0.4 installed) and calling `getConfigFields()`:

```text
ReferenceError: Regex is not defined
```

Reproduced in Companion 5.1.0 with the v3.2.1 package. A **new** connection shows only "Connection is not running" in its settings panel, and the log repeats every 1–4 seconds:

```text
Instance/ProcessManager: Instance "magicq_review_test" failed to init: ReferenceError: Regex is not defined
    at ji.getConfigFields (file:///.../companion/modules/chamsys-magicq-osc-3.2.1/main.js:25:35717)
    at gu.#getConfigFields (.../@companion-module/host/src/instance.ts:425:36)
    ...
    at gu.init (.../@companion-module/host/src/instance.ts:289:42)
Instance/ProcessManager: Failed to initialize instance "magicq_review_test": Error: Restart forced
```

For a connection that already has saved settings, v3.2.1 starts ("Module initialized successfully" in the connection's own log, from the connection's **⋮** menu, then **View logs**), but opening its settings fails. The panel shows "Failed to load configuration fields", and the connection log shows:

```text
Module: Error getting config fields: ReferenceError: Regex is not defined
    at ji.getConfigFields (file:///.../companion/modules/chamsys-magicq-osc-3.2.1/main.js:25:35717)
    ...
    at nq.requestConfigFields (...)
```

The same connection switched to a v3.2.2 test build with only the `Regex` import added starts normally and shows the full settings form (**Target IP**, **Target Port**, **Enable Feedback**, **Feedback Port**, **Forward OSC messages to Companion**).

**Confirm by:** open [`src/main.js:1`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L1). It imports only `InstanceBase` and `InstanceStatus`, while `getConfigFields()` ([`src/main.js:325-392`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L325-L392)) uses `Regex.IP` / `Regex.PORT` at lines 342, 351, 367 and 388. Nothing else in the file defines `Regex`; the only similar names are the local `pbRegex`, `pbFlashRegex` and `execRegex`.

**Fix:** add `Regex` to the import from the library at the top of `src/main.js`.

```js
import { InstanceBase, InstanceStatus, Regex } from '@companion-module/base'
```

## 🟠 High

### H1: Unticking Enable Feedback now removes all feedbacks, variables and OSC forwarding, and the change isn't documented

- **Source:** 🔎 QA reviewer (raised to High by the review maintainer)
- **Classification:** 🔙 REGRESSION
- **File:** [`src/feedbacks.js:4-9`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/feedbacks.js#L4-L9), [`src/variables.js:4-14`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/variables.js#L4-L14), [`src/main.js:43-44`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L43-L44), [`src/main.js:222`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L222)

**What goes wrong:** In v3.1.1 the **Enable Feedback** checkbox only hid some settings and changed nothing else. In v3.2.1, a user who has it unticked loses three things on upgrade, with no log message or note explaining why:

- every feedback disappears, so buttons using **Playback Level**, **Playback Flash** or **Execute Level** show them as unknown;
- every playback variable (`pb1`…`pb10`, `pb1_flash`…) and execute variable (`exec1_5` and so on) disappears;
- forwarding OSC messages to Companion silently stops, even with **Forward OSC messages to Companion** ticked.

**Why it happens:** The feedback and variable setup now registers an empty list when the checkbox is off, and the forwarding socket is only opened when it is on. In v3.1.1 both lists were always registered and forwarding didn't depend on the checkbox. The change was deliberate (commit [`5f11053`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/commit/5f110531fc4bccbaaead4c09f3665b9c883b3355), shipped in v3.2.0), but it's explained only in the developer-facing description of [PR #29](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/pull/29). Neither the [v3.2.0](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/releases/tag/v3.2.0) nor the [v3.2.1](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/releases/tag/v3.2.1) release notes nor `companion/HELP.md` mention it. That makes it a breaking change users discover only when their buttons stop working.

**Evidence:**

```js
// src/feedbacks.js:4-9
	if (!self.feedbackEnabled()) {
		// Publish an empty set, so turning feedback off clears any
		// previously registered feedbacks rather than leaving them behind.
		self.setFeedbackDefinitions({})
		return
	}
```

```js
// src/variables.js:4-14 (playback variables only when feedback is on)
	if (self.feedbackEnabled()) {
		for (let i = 1; i <= 10; i++) {
			self.variables['pb' + i] = { name: 'Playback ' + i + ' Level' }
	...
	self.setVariableDefinitions(self.variables)
```

```js
// src/main.js:222 (forwarding now also needs feedback on)
		if (feedbackEnabled && this.config.forwardOSC) {
```

**Confirm by:** open [`src/feedbacks.js:4-9`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/feedbacks.js#L4-L9) and compare with `git show v3.1.1:index.js`, where `setFeedbackDefinitions` and `setVariableDefinitions` run unconditionally and forwarding checks only `forwardOSC`. Then search the v3.2.0 and v3.2.1 release notes and `companion/HELP.md` for "Enable Feedback": there's no mention.

**Fix:** keep registering feedbacks and variables whatever the checkbox says, and let only the receive socket depend on it (the feedbacks can still use the state the module tracks from its own actions). If the change is intended, document it as a breaking change: say so in the release notes, in `companion/HELP.md` and in the **Enable Feedback** tooltip, so users know to tick it to keep their feedbacks, variables and forwarding.

---

## 🟡 Medium

### M1: Saving the connection settings makes execute variables disappear

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.js:2`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/variables.js#L2), [`src/main.js:111-125`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L111-L125)

**What goes wrong:** A button showing an execute variable such as `exec1_5` goes blank every time the user saves the connection settings, and stays blank until that execute is used again. Turning **Enable Feedback** on also leaves the playback variables (`pb1` and so on) empty until each fader moves.

**Why it happens:** Execute variables are created on the fly the first time an execute is seen. Saving the settings restarts the module's setup, which starts the variable list from scratch with only the playback variables, so every execute variable found so far is removed. The module still remembers the execute levels internally but doesn't re-publish them. While feedback was off, the module didn't write any variable values at all, so there is nothing to show when it is turned on.

**Fix:** when rebuilding the variable list, add back an `execX_Y` entry for every execute the module already knows about, then push the current playback and execute levels with `setVariableValues()`.

### M2: One network error can leave the connection red until the settings are changed

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:290-293`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L290-L293)

**What goes wrong:** A single malformed packet from any sender, or a one-off send failure during a short network blip, turns the connection status to **Connection Failure**. With **Enable Feedback** off, nothing ever sets it back to OK, so the connection shows red until the user changes the settings, even though buttons still work. If the **Feedback Port** is already taken by another program, the module never tries to open it again.

**Why it happens:** The socket's error handler treats every error the OSC library reports as a lost connection. That includes packets it can't decode and single failed sends (for example "host unreachable"). With feedback off, only the socket opening sets the status to OK.

**Fix:** keep **Connection Failure** for errors where the socket can't be opened (port in use, permission denied), and only log decode and send errors. Optionally retry opening the port after a delay, and set the status back to OK after a successful send when feedback is off.

### M3: Dependent fields may show or hide wrongly when Comparison method or Toggle uses an expression

- **Source:** 🔎 compliance reviewer — verified (downgraded from High)
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:29-52`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/feedbacks.js#L29-L52), [`src/feedbacks.js:132-155`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/feedbacks.js#L132-L155), [`src/actions.js:331-347`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L331-L347)

**What goes wrong:** In the button editor, a user who switches **Comparison method** (on the **Playback Level** or **Execute Level** feedback) or **Toggle?** (on the **Execute** action) to an expression may see the value field next to it shown or hidden at the wrong time. For example, the **Execute Level** field could stay hidden even when the expression works out to "not toggle". Only what the editor displays is affected: the action and feedback still use the right values when they run. Users who leave these fields as normal choices are not affected. Exactly what Companion shows was not checked (see A1).

**Why it happens:** In API 2.0 most option fields have a switch that lets the user type an expression instead of picking a value. A field can be shown or hidden based on another field with `isVisibleExpression`, but the library's own documentation says it may only refer to fields that have that switch turned off (`disableAutoExpression: true`), because an expression's result isn't available to the editor. **Comparison method** and **Toggle?** don't turn it off.

**Evidence:**

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:32-44 (base 2.0.4)
     * A companion expression to check whether this input should be visible, based on the current options selections within the input group
     *
     * This is the same syntax as other expressions written inside of Companion.
     * You can access a value of the current options using `$(options:some_field_id)`.
     * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
     */
    isVisibleExpression?: string;
    ...
    disableAutoExpression?: boolean;
```

```js
// src/feedbacks.js:31-51
					type: 'dropdown',
					label: 'Comparison method',
					id: 'pbComp',
					default: 'equal',
					...
					id: 'pbVal',
					...
					isVisibleExpression: '$(options:pbComp) != "isActive"',
// src/feedbacks.js:135-154
					type: 'dropdown',
					label: 'Comparison method',
					id: 'execComp',
					default: 'equal',
					...
					id: 'execVal',
					...
					isVisibleExpression: '$(options:execComp) != "isActive"',
// src/actions.js:332-346
					type: 'checkbox',
					label: 'Toggle?',
					id: 'exeToggle',
					default: false,
					tooltip: 'If checked, this action will just toggle the execute button',
				},
				{
					type: 'textinput',
					label: 'Execute Level: 0 - 100 %',
					...
					id: 'exeVal',
					...
					isVisibleExpression: '!$(options:exeToggle)',
```

`grep -rn disableAutoExpression src/` finds no matches.

**Confirm by:** open [`src/feedbacks.js:31-51`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/feedbacks.js#L31-L51), [`src/feedbacks.js:135-154`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/feedbacks.js#L135-L154) and [`src/actions.js:332-346`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L332-L346). `pbComp`, `execComp` and `exeToggle` have no `disableAutoExpression: true`, while `pbVal`, `execVal` and `exeVal` use an `isVisibleExpression` that refers to them.

**Fix:** turn off expression mode on the three fields the visibility checks depend on. They are fixed choices that make no sense as expressions anyway.

```js
disableAutoExpression: true,
```

### M4: The Flash, Black Out and Swap Mode choices can be turned into expressions that need hidden number codes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:131-140`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L131-L140), [`src/actions.js:252-261`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L252-L261), [`src/actions.js:288-296`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L288-L296)

**What goes wrong:** The **Action** dropdown on **Flash Playback** and **Desk Black Out DBO**, and the **Swap Mode** dropdown on **Set swap mode**, can be switched to an expression. A user who does that has to know that "Flash On" is `'1'`, "Flash Off" is `'0'` and "Toggle" is `'2'`; nothing in the editor tells them.

**Why it happens:** In API 2.0 every option allows expression mode unless the field turns it off with `disableAutoExpression: true`. These fixed-choice dropdowns don't, and their internal ids are bare numbers.

**Fix:** add `disableAutoExpression: true` to each of the three dropdowns. Switching to readable ids (`'on'`, `'off'`, `'toggle'`) is optional; if you change the ids, add an upgrade script in `src/upgrades.js` that maps the old values.

---

## 🟢 Low

### L1: An OSC message without a number sets variables to NaN

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:149-150`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L149-L150), [`src/main.js:162`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L162), [`src/main.js:172-173`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L172-L173)

**What goes wrong:** If a playback or execute message arrives with no value, or a value that isn't a number, the matching variable shows `NaN` and the module's stored level becomes `NaN`. The next **Execute** toggle on that execute then always sends "on", whatever its real state.

**Why it happens:** The module converts the message's whole argument list to a number instead of its first value, and doesn't check that the result is a real number before storing it.

**Fix:** read `msg.args[0]`, check it with `Number.isFinite()`, and log and ignore the message otherwise.

### L2: The connection stays on Connecting forever when the console never replies

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:260-273`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L260-L273)

**What goes wrong:** With **Enable Feedback** on, if the console never sends anything back (for example because its OSC TX IP isn't set to Companion), the connection shows **Connecting** forever with no hint why. Once it shows OK, it never changes again if the console goes away, and a packet from any sender sets it to OK.

**Why it happens:** The status changes to OK on the first incoming message, from any sender, and there is no timeout or later check.

**Fix:** start a timer after sending the `/feedback/pb+exec` subscription. When it runs out, set a warning status with a message such as "No OSC received from console - check OSC TX IP/port". Restart the timer on each message from the configured **Target IP**, optionally re-send the subscription now and then, and clear the timer when the sockets close.

### L3: Errors while setting up the connection are not caught or shown

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:46`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L46), [`src/main.js:320-323`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L320-L323)

**What goes wrong:** No visible effect today. If anything in the socket setup throws in future, the error escapes as an unhandled rejection instead of showing up as a connection status and log line.

**Why it happens:** `setupOSC()` is declared `async`, but `init()` calls it without `await`, and `configUpdated()` calls `init()` without `await`, so a failure inside either is never caught.

**Fix:** make `setupOSC()` a normal function (it contains no `await`), or `await` both calls.

### L4: Every fader move from the console triggers a status update and debug log lines

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:271-289`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L271-L289)

**What goes wrong:** No visible effect beyond extra work. MagicQ sends a stream of messages while a fader moves, and each one makes the module re-send the OK status to Companion, write two or three debug log lines and re-check feedbacks.

**Why it happens:** The message handler calls `updateStatus(Ok)` on every message, and base 2.0.4 passes each call on to Companion without checking whether the status changed.

**Fix:** remember the last status and only call `updateStatus` when it changes. Drop or throttle the per-message debug logs.

### L5: Execute buttons set to Toggle do nothing when the hidden level is blank or not a number

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.js:350-356`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L350-L356)

**What goes wrong:** An **Execute** button with **Toggle?** ticked does nothing, and only logs "Execute: page, number and level must all be numbers", if its **Execute Level** is empty or set to a variable that isn't a number. In toggle mode that field is hidden and never used, so the user has no way to see why. In v3.1.1 the toggle was still sent.

**Why it happens:** The action checks that the level is a number before it looks at the toggle setting, and stops if it isn't.

**Fix:** only require **Execute Level** to be a number when **Toggle?** is unticked.

### L6: Execute page numbers are limited differently across actions, feedback and incoming OSC

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:350-351`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L350-L351), [`src/actions.js:411-412`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L411-L412), [`src/feedbacks.js:158`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/feedbacks.js#L158), [`src/main.js:169-171`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/main.js#L169-L171)

**What goes wrong:** An **Execute Level** feedback set to page 12 silently shows page 10's state, while an **Execute** action set to page 12 controls page 12. A variable that resolves to `-1` makes the **Execute** action send `/exec/-1/N` to the console.

**Why it happens:** Each code path handles out-of-range page numbers its own way:

| Code path | Page bounds |
| --- | --- |
| **Execute** action | none |
| Incoming OSC | none |
| **Adjust Execute Level** action | clamped to 1–10 (execute number 1–100) |
| **Execute Level** feedback | clamped to 1–10 |

**Fix:** pick one rule and apply it on all four paths: either reject out-of-range values with a warning, or drop the 1–10 clamp everywhere.

---

## 💡 Nice to Have

### N1: An empty RPC Command still sends a message to the console

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:501-508`](https://github.com/bitfocus/companion-module-chamsys-magicq-osc/blob/dc4b93dee049c398955784ad2b73481caf4ddc65/src/actions.js#L501-L508)

**What goes wrong:** An **RPC Command** button with an empty command, or a variable that resolves to nothing, still sends an `/rpc` message with an empty or missing value to the console.

**Why it happens:** The action sends the option's value without checking it.

**Fix:** trim the value and stop with a warning in the log if it is empty.
