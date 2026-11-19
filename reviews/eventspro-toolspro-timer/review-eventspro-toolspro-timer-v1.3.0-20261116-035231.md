# Review: eventspro-toolspro-timer v1.3.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-eventspro-toolspro-timer` |
| **Scope** | `tag` |
| **Version** | `v1.3.0` |
| **Release** | New module — never published |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Commit** | [`aec3a58`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/commit/aec3a58e28a93c09b19a4802b551b6f3ba111e86) |
| **Date** | 2026-11-16 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [H1: The code is not laid out like the JS template, so actions, feedbacks and variables are hard to find](#h1-the-code-is-not-laid-out-like-the-js-template-so-actions-feedbacks-and-variables-are-hard-to-find)
- [ ] [H2: package.json pins the Companion libraries to exact, older versions instead of the template's ranges](#h2-packagejson-pins-the-companion-libraries-to-exact-older-versions-instead-of-the-templates-ranges)

### Non-blocking

- [ ] [M1: Variables typed into the Send message and Speaker name actions show up as raw variable text on the presenter screen](#m1-variables-typed-into-the-send-message-and-speaker-name-actions-show-up-as-raw-variable-text-on-the-presenter-screen)
- [ ] [L1: Ticking Advanced settings with the Timer on another computer stops all feedback](#l1-ticking-advanced-settings-with-the-timer-on-another-computer-stops-all-feedback)
- [ ] [L2: A fix to the Timer web page can pass the tests yet never reach users, because the page exists in two hand-synced copies](#l2-a-fix-to-the-timer-web-page-can-pass-the-tests-yet-never-reach-users-because-the-page-exists-in-two-hand-synced-copies)
- [ ] [N1: A rejected speaker-slot list is dropped silently, so slot dropdowns and presets never update and nothing is logged](#n1-a-rejected-speaker-slot-list-is-dropped-silently-so-slot-dropdowns-and-presets-never-update-and-nothing-is-logged)
- [ ] [N2: The Timer computer IP and Companion local IP fields don't flag an invalid address while typing](#n2-the-timer-computer-ip-and-companion-local-ip-fields-dont-flag-an-invalid-address-while-typing)
- [ ] [N3: The clock preset is named with a raw variable string instead of a readable name](#n3-the-clock-preset-is-named-with-a-raw-variable-string-instead-of-a-readable-name)
- [ ] [N4: The No Timer feedback status is re-sent to Companion every second while the Timer is offline](#n4-the-no-timer-feedback-status-is-re-sent-to-companion-every-second-while-the-timer-is-offline)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The code is not laid out like the JS template, so actions, feedbacks and variables are hard to find

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:1-2`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/main.js#L1-L2), [`src/module.js:276-705`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L276-L705), [`src/lan-module.cjs:4-5`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/lan-module.cjs#L4-L5), [`src/upgrades.cjs:1-3`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/upgrades.cjs#L1-L3)

**What goes wrong:** Users see no difference: the module works the same. The cost falls on whoever maintains or troubleshoots it. JS modules built from the API 1 template keep their actions in `src/actions.js`, feedbacks in `src/feedbacks.js`, variables in `src/variables.js`, and the main module class in `src/main.js`. Someone looking for the code behind the "Start / resume" action or the "Speaker output visible" feedback finds none of those files here. All 12 variables, about 20 actions, 6 feedbacks and every preset are built inside one 430-line `define()` method in `src/module.js`. `src/main.js` is a two-line file that only wires things up, and the upgrade scripts are in `src/upgrades.cjs` where the template has `src/upgrades.js`. A module laid out differently from its template is harder to troubleshoot and maintain.

**Why it happens:** The class Companion runs is assembled by two "class factories" (functions that return a class): `src/module.js` builds a base class, and `src/lan-module.cjs` returns a class that extends it. Every definition is registered from that base class's single `define()` method instead of from separate files called by the main class, as the template does.

**Evidence:**

```js
// src/main.js:1-2
const base = require('@companion-module/base')
base.runEntrypoint(require('./lan-module.cjs')(base), require('./upgrades.cjs'))
// src/module.js:6-7
module.exports = function ({ InstanceBase, InstanceStatus }) {
	return class ToolsPROTimer extends InstanceBase {
// src/module.js:276-278
		define() {
			this.lastValues = null
			this.setVariableDefinitions(
// src/module.js:465-466
			this.setActionDefinitions(actions)
			this.setFeedbackDefinitions({
// src/module.js:703-705
			this.setPresetDefinitions(presets)
			this.refresh()
		}
// src/lan-module.cjs:4-5
module.exports = (base) =>
	class extends require('./module.js')(base) {
// src/upgrades.cjs:1-3
'use strict'
// No stored-action migrations are needed; identifiers remain compatible.
module.exports = []
```

```js
// companion-module-template-js-v1/src/main.js:1-5
const { InstanceBase, Regex, runEntrypoint, InstanceStatus } = require('@companion-module/base')
const UpgradeScripts = require('./upgrades')
const UpdateActions = require('./actions')
const UpdateFeedbacks = require('./feedbacks')
const UpdateVariableDefinitions = require('./variables')
```

```text
git ls-files src (module @ v1.3.0)
src/icons.cjs  src/lan-module.cjs  src/lan-session.cjs  src/main.js  src/module.js
src/osc.cjs  src/remote.cjs  src/speaker-timer.js  src/upgrades.cjs  src/web-assets.json

git ls-files src (companion-module-template-js-v1)
src/actions.js  src/feedbacks.js  src/main.js  src/upgrades.js  src/variables.js
```

**Confirm by:** open [`src/main.js:1-2`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/main.js#L1-L2) (no module class), then [`src/module.js:276-705`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L276-L705), where the variable, action, feedback and preset definitions all sit in one `define()`. Compare `git ls-files src` with `companion-module-template-js-v1/src`.

**Fix:** follow the JS API 1 template layout. Put a `class ModuleInstance extends InstanceBase` in `src/main.js` with `init`, `destroy`, `configUpdated` and `getConfigFields`, and `runEntrypoint(ModuleInstance, UpgradeScripts)` at the bottom. Move the action definitions to `src/actions.js`, the feedbacks to `src/feedbacks.js` and the variable definitions to `src/variables.js`, and call them from `updateActions()` / `updateFeedbacks()` / `updateVariableDefinitions()` as the template does. Rename `src/upgrades.cjs` to `src/upgrades.js`. The OSC and LAN transport code, presets and helpers can stay in their own helper files.

```js
// src/actions.js
module.exports = function (self) {
	self.setActionDefinitions({
		// ... the action definitions now built in define()
	})
}
```

### H2: package.json pins the Companion libraries to exact, older versions instead of the template's ranges

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:18-24`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/package.json#L18-L24)

**What goes wrong:** Users see nothing different today. The template writes `"@companion-module/base": "~1.14.1"` and `"@companion-module/tools": "^2.6.1"`. This module pins `"1.13.6"` and `"2.8.0"` exactly, so a fresh install never picks up patch fixes of the module API (1.13.x) or of the build tools (2.x), unlike modules built from the template. Its module API (1.13) is also one minor version behind the template's 1.14. Differences from the template make problems harder to troubleshoot, because people end up looking for a cause the template itself doesn't have.

**Why it happens:** The two dependency versions are written without the template's `~` and `^` range prefixes, and `@companion-module/base` sits on an older minor version than the JS API 1 template.

**Evidence:**

```json
// package.json:18-24 (module @ v1.3.0)
	"dependencies": {
		"@companion-module/base": "1.13.6"
	},
	"devDependencies": {
		"@companion-module/tools": "2.8.0",
		"prettier": "^3.7.4"
	},
```

```json
// companion-module-template-js-v1/package.json:18-24 (9e222b4)
	"dependencies": {
		"@companion-module/base": "~1.14.1"
	},
	"devDependencies": {
		"@companion-module/tools": "^2.6.1",
		"prettier": "^3.7.4"
	},
```

**Confirm by:** open [`package.json:19`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/package.json#L19) and [`package.json:22`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/package.json#L22) next to lines 19 and 22 of `companion-module-template-js-v1/package.json`: exact `"1.13.6"` and `"2.8.0"` against `"~1.14.1"` and `"^2.6.1"`.

**Fix:** write the dependencies with the template's range prefixes, then run `yarn install` to refresh `yarn.lock`. If the module deliberately targets an older Companion, `"~1.13.6"` keeps its API level and still uses the template's specifier style. Update the "Module API remains 1.13.6" line in [`README.md:18`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/README.md#L18) to match.

```json
	"dependencies": {
		"@companion-module/base": "~1.14.1"
	},
	"devDependencies": {
		"@companion-module/tools": "^2.8.0",
		"prettier": "^3.7.4"
	},
```

## 🟡 Medium

### M1: Variables typed into the Send message and Speaker name actions show up as raw variable text on the presenter screen

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:361-377`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L361-L377)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** The **Text** field of both actions shows Companion's variable picker, so users are invited to use variables. An operator who adds "Send message" with Text `Next: $(custom:next_speaker)`, or "Speaker name" with `$(custom:speaker)`, and presses the button sees the raw string `Next: $(custom:next_speaker)` on the presenter output and in the `message` / `title` variables, instead of `Next: Maria Lopez`. This happens over both connection types ("Timer in browser over local network" and "Installed Timer (OSC)"). Plain text without variables works.

**Why it happens:** On module API 1 (`@companion-module/base` 1.x), action options reach the callback as typed; the module has to resolve variables itself by calling `context.parseVariablesInString`. The callback receives that context (`ctx`) but never calls it, so the text is sent unresolved. The module's own test builds a `ctx` with `parseVariablesInString`, so variable support was intended.

**Evidence:**

```js
// src/module.js:368-376
						{
							type: 'textinput',
							id: 'value',
							label: this.t('Texto', 'Text'),
							default: '',
							useVariables: true,
						},
					],
					callback: async (e, ctx) => this.send(id, [String(e.options.value).slice(0, id === 'message' ? 160 : 100)]),
```

**Fix:** resolve variables before trimming and sending the text, and add a test whose `ctx.parseVariablesInString` returns a different string, to prove the resolved value is what gets sent.

```js
callback: async (e, ctx) => {
	const text = await ctx.parseVariablesInString(String(e.options.value ?? ''))
	return this.send(id, [text.slice(0, id === 'message' ? 160 : 100)])
},
```

## 🟢 Low

### L1: Ticking Advanced settings with the Timer on another computer stops all feedback

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:63-70`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L63-L70), [`src/module.js:93`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L93)

**What goes wrong:** An operator uses "Installed Timer (OSC)" with **Timer computer IP** = 192.168.1.50, a different machine from Companion, and feedback works. They then tick **Advanced settings** only to change **Feedback receive port** from 9011 to 9021 (say, because another Timer PRO connection already uses 9011). **Companion local IP** appears with its default of 127.0.0.1 and is now used, so the module listens only on the loopback address and replies from 192.168.1.50 never arrive. After 4 seconds the status goes from "Waiting for Timer" to "No Timer feedback", every feedback stays off, and every action is refused with "Timer is disconnected" in the log. Nothing tells the operator that the IP field they never touched is the cause.

**Why it happens:** With **Advanced settings** off, the listen address is derived from the Timer IP (a `127.*` host gives 127.0.0.1, anything else gives 0.0.0.0). With it on, the saved **Companion local IP** is used as-is, and that field's default is always 127.0.0.1, whatever the Timer host is.

**Fix:** change the **Companion local IP** default to `0.0.0.0`; or, when **Advanced settings** is on and the listen IP is a loopback address while the Timer IP is not, fall back to `0.0.0.0` or set a "bad config" status such as "Companion local IP 127.0.0.1 cannot receive from 192.168.1.50". A short field description explaining the value would also help.

### L2: A fix to the Timer web page can pass the tests yet never reach users, because the page exists in two hand-synced copies

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/web-assets.json`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/web-assets.json), [`src/lan-module.cjs:2`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/lan-module.cjs#L2), [`tests/review-regressions.test.cjs:86`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/tests/review-regressions.test.cjs#L86)

**What goes wrong:** Users see no problem today: all 26 files in `web/` currently match their entries in `src/web-assets.json`, and `src/speaker-timer.js` / `src/remote.cjs` match `web/01-speaker-timer.js` / `web/05-timer-remote.js`. But nothing builds one copy from the other. If a maintainer fixes a bug in `web/lan-client.js`, `yarn test` passes because the tests load the `web/` copy, while Companion keeps serving the old copy from `src/web-assets.json`, so users opening `/instance/<connection>/index.html` still get the unfixed page.

**Why it happens:** The module's web server answers every page request from the JSON bundle it loads at startup. The tracked `web/` folder is a separate copy with no generator script in `package.json`, and the tests read `web/` directly.

**Fix:** add a test that checks each `web/<file>` equals its `src/web-assets.json` entry (and that `src/speaker-timer.js` / `src/remote.cjs` equal their `web/` counterparts), or add a separate generator script, e.g. `"build:web": "node scripts/build-web-assets.cjs"`, and run it before packaging. Leave the template's `package` script command unchanged.

## 💡 Nice to Have

### N1: A rejected speaker-slot list is dropped silently, so slot dropdowns and presets never update and nothing is logged

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:178-214`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L178-L214)

**What goes wrong:** In "Installed Timer (OSC)" mode, if one speaker-slot entry from the Timer app fails the module's checks (invalid JSON, an id longer than 100 characters, a name that isn't text), that entry is thrown away without a log line. The received count then no longer matches the announced count, so the whole list is discarded, again without a log line. The "Load named speaker slot" / "Send saved message" dropdowns and the speaker-slot presets keep the old list (or "Connect Timer and save a speaker slot"), the cycle repeats every 10 seconds, and the log never says why.

**Why it happens:** The entry parsing sits in an empty `try { … } catch {}`, the length and type checks skip entries silently, and the final count check rejects the list without calling `this.log`.

**Fix:** log at debug or warn level when an entry is skipped (with its index and reason) and when a list is rejected because of a count or revision mismatch, e.g. ``this.log('warn', `Speaker slot list rejected: received ${p.entries.size} of ${p.count}`)``.

### N2: The Timer computer IP and Companion local IP fields don't flag an invalid address while typing

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:41-46`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L41-L46), [`src/module.js:63-70`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L63-L70)

**What goes wrong:** A user who types "192.168.1" into **Timer computer IP** gets no warning while typing; only after saving does the connection status show "Invalid IP / port". The template's host field highlights a bad address as it is typed.

**Why it happens:** The two IP fields have no `regex`, so the address check only runs after the settings are saved ([`src/module.js:100-107`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L100-L107)).

**Fix:** pass `Regex` into the module factory along with `InstanceBase` / `InstanceStatus`, and add `regex: Regex.IP` to the `host` and `listenIp` config fields. Keep the existing check in `configUpdated`.

### N3: The clock preset is named with a raw variable string instead of a readable name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:622`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L622)
- **Assumption:** [A3](#-assumptions-to-confirm)

**What goes wrong:** In the Presets panel, the large clock button in the "Timer control" category is named `$(<connection label>:time)` rather than something readable such as "Timer display", unlike the other presets ("Countdown", "Record lap").

**Why it happens:** The preset helper uses the button text as the preset name, and for the clock preset that text is the variable string. The other presets overwrite the name afterwards; this one doesn't.

**Fix:** after the `make('time', …)` call, set a readable English name, as is already done for the mode, lap and duration presets.

```js
presets.time.name = 'Timer display'
```

### N4: The No Timer feedback status is re-sent to Companion every second while the Timer is offline

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:132-141`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/aec3a58e28a93c09b19a4802b551b6f3ba111e86/src/module.js#L132-L141)
- **Assumption:** [A2](#-assumptions-to-confirm)

**What goes wrong:** No visible effect is expected; this is code quality. Once the 4-second feedback timeout has passed, the watchdog sends the "No Timer feedback" status and refreshes the variables once per second for as long as the Timer stays offline, which can be hours between shows. Each call is a separate message to Companion.

**Why it happens:** The "last seen" time isn't updated when the timeout fires, so the timeout condition stays true on every tick, and `updateStatus` in base 1.13.6 sends every call to Companion without checking whether the status changed.

**Fix:** keep a flag (e.g. `this.timedOut`): set it the first time the timeout fires and skip the block while it is set, then clear it when a `connected` message arrives. Or remember the last status and message and only call `updateStatus` when they change.

## 📝 Additional Notes

- This is the module's first release: it has never been published (the repo's `v1.2.1` and `v1.2.2` tags were not released), so there is no published version to diff against and the whole module was reviewed.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | For module API 1 modules (base 1.13.6), Companion does not resolve `$(...)` variables in `useVariables` action options before calling the callback; only the module's own `context.parseVariablesInString` call does | base 1.13.6 passes the action options to the callback unchanged and offers `parseVariablesInString` on the context (`dist/internal/actions.js:26-53`); Companion's host handling of API 1 modules was not checked | [M1](#m1-variables-typed-into-the-send-message-and-speaker-name-actions-show-up-as-raw-variable-text-on-the-presenter-screen) |
| A2 | Companion ignores a status identical to the current one, so repeating it every second has no visible effect in the Connections list or the log | base 1.13.6 sends every `updateStatus` call to Companion (checked); what Companion does with identical repeats was not checked | [N4](#n4-the-no-timer-feedback-status-is-re-sent-to-companion-every-second-while-the-timer-is-offline) |
| A3 | Companion shows a preset's `name` in the Presets panel (as its title or tooltip), so a name of `$(<label>:time)` is visible to users | the base typings only say "The name of this preset" (`preset.d.ts:62-63`); the Companion UI was not checked | [N3](#n3-the-clock-preset-is-named-with-a-raw-variable-string-instead-of-a-readable-name) |
