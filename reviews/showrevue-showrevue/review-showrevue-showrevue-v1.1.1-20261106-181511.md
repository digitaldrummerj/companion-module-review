# Review: ShowRevue (`companion-module-showrevue-showrevue`) v1.1.1

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-showrevue-showrevue`](https://github.com/bitfocus/companion-module-showrevue-showrevue) |
| **Scope** | `tag` |
| **Version** | v1.1.1 ([`b645008`](https://github.com/bitfocus/companion-module-showrevue-showrevue/commit/b6450083bf3cf0f167a9fdc837084d807cb8eb48)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Reviewed** | 2026-11-06 |

This is the module's first release. It has never been published, so there is no earlier release to diff against and the whole module was reviewed. The repository also has a `v1.1.0` tag, which was never published either.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When an action callback fails, Companion logs the error and the module keeps running; the button press just does nothing. If the module process crashed instead, H1 would be Critical | General Companion behaviour. The action dispatch runs in Companion's host, not in `@companion-module/base` 2.1.3, so it was not read. The failure itself was reproduced with Node | [H1](#h1-overlay-widget-set-colour-action-and-its-two-presets-never-send-anything-to-showrevue) |
| A2 | Companion 5 does not substitute variables into connection config text fields, even with `useVariables: true`, so the module receives the raw `$(...)` text in `init()` and `configUpdated()` | base 2.1.3 typings (`module-api/config.d.ts`, `module-api/input.d.ts`) allow `useVariables` on config text fields but document no config-time substitution. Companion's host code was not checked | [L2](#l2-target-host-offers-variables-but-a-variable-there-is-sent-as-a-literal-hostname) |
| A3 | Companion lets a user save the connection with "Feedback listen port" blank or invalid; the `Regex.PORT` check only warns | base 2.1.3 typings say regex "values may not conform to this, you should validate the value in your code". Whether Companion's config editor blocks Save was not checked (one reviewer assumed it does, which would make N1 unreachable) | [N1](#n1-clearing-feedback-listen-port-keeps-listening-on-the-old-port) |
| A4 | For a CommonJS entrypoint, Companion's v2 host reads upgrade scripts only from a named `UpgradeScripts` export (`module.exports.UpgradeScripts`), not from a separate file | the API 2.1 JS template's `export { UpgradeScripts }` and the v2 compliance checklist. Companion's module loader is not in the module's `node_modules`, so it was not read | [L5](#l5-upgrade-scripts-added-later-would-never-run-because-the-upgrade-list-is-not-exported) |

## 📋 Issues

### Blocking

- [ ] [C1: Module is set to run on Node 22, but API 2.1 modules run on Node 26](#c1-module-is-set-to-run-on-node-22-but-api-21-modules-run-on-node-26)
- [ ] [H1: Overlay widget Set colour action and its two presets never send anything to ShowRevue](#h1-overlay-widget-set-colour-action-and-its-two-presets-never-send-anything-to-showrevue)
- [ ] [H2: Manifest lists a legacy module id although ShowRevue has never been published](#h2-manifest-lists-a-legacy-module-id-although-showrevue-has-never-been-published)

### Non-blocking

- [ ] [M1: Connection stays green when the feedback port is already in use, and feedbacks and variables never update](#m1-connection-stays-green-when-the-feedback-port-is-already-in-use-and-feedbacks-and-variables-never-update)
- [ ] [L1: Source problem feedback glows amber before ShowRevue has reported anything](#l1-source-problem-feedback-glows-amber-before-showrevue-has-reported-anything)
- [ ] [L2: Target host offers variables, but a variable there is sent as a literal hostname](#l2-target-host-offers-variables-but-a-variable-there-is-sent-as-a-literal-hostname)
- [ ] [L3: Feedback help text never appears in the feedback picker](#l3-feedback-help-text-never-appears-in-the-feedback-picker)
- [ ] [L4: Help page lists an HTTP polling port 8000 that the module never uses](#l4-help-page-lists-an-http-polling-port-8000-that-the-module-never-uses)
- [ ] [L5: Upgrade scripts added later would never run, because the upgrade list is not exported](#l5-upgrade-scripts-added-later-would-never-run-because-the-upgrade-list-is-not-exported)
- [ ] [L6: Fixed-choice dropdowns can be switched to expression mode](#l6-fixed-choice-dropdowns-can-be-switched-to-expression-mode)
- [ ] [N1: Clearing Feedback listen port keeps listening on the old port](#n1-clearing-feedback-listen-port-keeps-listening-on-the-old-port)
- [ ] [N2: Every incoming state message rewrites all variables and re-checks every feedback](#n2-every-incoming-state-message-rewrites-all-variables-and-re-checks-every-feedback)

## 🔴 Critical

### C1: Module is set to run on Node 22, but API 2.1 modules run on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/companion/manifest.json#L20), [`package.json:18`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/package.json#L18), [`.github/workflows/node.yaml:21-25`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/.github/workflows/node.yaml#L21-L25), [`.github/workflows/node.yaml:62-65`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/.github/workflows/node.yaml#L62-L65)

**What goes wrong:** Companion starts each module on the Node.js version its manifest asks for. This module asks for Node 22, while the API 2.1 template, and the tooling that builds and tests 2.1 modules, target Node 26. Users would run ShowRevue on a different runtime from every other 2.1 module, and CI checks it on Node 22 as well, so a problem that only shows up on one runtime is hard to reproduce and troubleshoot later.

**Why it happens:** The module was set up with the Node 22 values from an older template. Every place that names a Node version has to match the template for the module's API level, and four places here still say 22.

**Evidence:** expected (template) vs found (module):

```text
companion/manifest.json:20       found "type": "node22"         expected "type": "node26"
package.json:18                  found "node": "^22.20"         expected "node": "^26"
.github/workflows/node.yaml:21   found Use Node.js 22.x         expected Use Node.js 26.x
.github/workflows/node.yaml:25   found node-version: 22.x       expected node-version: 26.x
.github/workflows/node.yaml:62   found Use Node.js 22.x         expected Use Node.js 26.x   (commented-out test job)
.github/workflows/node.yaml:65   found node-version: 22.x       expected node-version: 26.x (commented-out test job)
```

**Confirm by:** open [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/companion/manifest.json#L20) and [`package.json:18`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/package.json#L18); both name Node 22.

**Fix:** move every Node version reference to 26, as in the template:

- [ ] `companion/manifest.json` (line 20): `"runtime": { "type": "node26" }`
- [ ] `package.json` (line 18): `"engines": { "node": "^26" }` (keep `"yarn": "^4"`)
- [ ] `.github/workflows/node.yaml`: `- name: Use Node.js 26.x` (lines 21 and 62) and `node-version: 26.x` (lines 25 and 65, including the commented-out `test:` job)

## 🟠 High

### H1: Overlay widget Set colour action and its two presets never send anything to ShowRevue

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:388-393`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/actions.js#L388-L393), [`src/osc.js:23-33`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/osc.js#L23-L33), [`src/main.js:271-276`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L271-L276)

**What goes wrong:** A user adds the "Overlay widget: Set colour" action with Widget = Cue Number and Colour = #ff4545, or drags the "Widget colour: Cue Number red" or "Widget colour: Cue Number reset" preset from the Overlay Widgets group. Pressing the button does nothing in ShowRevue: the cue-number widget never changes colour and never resets. No OSC message leaves Companion, `$(showrevue:last_command)` doesn't change, and the connection stays green, so the user can't tell why. The only trace is an action error in the Companion log, "Unsupported OSC argument type for /showrevue/widget/cueNumber/color". This happens on every press, for every widget and colour, although the help page says widgets can be recoloured.

**Why it happens:** The module builds its own OSC messages. Its message builder (`buildOscPacket` in `src/osc.js`) accepts only plain strings, numbers and true/false values, and throws an error for anything else. The Set colour action passes the colour wrapped in an object, `{ type: 's', value: '#ff4545' }`, instead of the plain string `'#ff4545'`, so the builder throws. That happens in `sendCommand()` before the message is sent and outside its error handler, so the action fails before anything goes out. Every other action passes plain values; this is the only one that passes an object.

**Evidence:**

```js
// src/actions.js:388-393
		callback: async (event) => {
			const kind = String(event.options.kind || '').trim()
			const color = String(event.options.color || '').trim() || 'none'
			if (!kind) return
			await self.sendCommand(`/showrevue/widget/${kind}/color`, [{ type: 's', value: color }], `Widget ${kind} colour ${color}`)
		},
```

```js
// src/osc.js:23-33
	for (const arg of args) {
		if (typeof arg === 'string') {
			typeTags.push('s')
		} else if (typeof arg === 'number') {
			typeTags.push(Number.isInteger(arg) ? 'i' : 'f')
		} else if (typeof arg === 'boolean') {
			typeTags.push(arg ? 'T' : 'F')
		} else {
			throw new Error(`Unsupported OSC argument type for ${address}`)
		}
	}
```

```js
// src/main.js:271-276
		this.ensureSocket()

		const packet = buildOscPacket(address, args)
		this.log('debug', `SEND ${address} ${args.map((arg) => JSON.stringify(arg)).join(' ')}`.trim())

		await new Promise((resolve, reject) => {
```

```js
// src/presets.js:313-320
	widgetEntries.push([
		'widget_cueNumber_red',
		buildButtonPreset('Widget colour: Cue Number red', 'CUE\nRED', '#ff4545', 'widget_color', { kind: 'cueNumber', color: '#ff4545' }),
	])
	widgetEntries.push([
		'widget_cueNumber_reset',
		buildButtonPreset('Widget colour: Cue Number reset', 'CUE\nRESET', '#6b7280', 'widget_color', { kind: 'cueNumber', color: 'none' }),
	])
```

```text
$ node -e "const {buildOscPacket}=require('./src/osc.js'); buildOscPacket('/showrevue/widget/cueNumber/color',[{type:'s',value:'#ff4545'}])"
THROW Unsupported OSC argument type for /showrevue/widget/cueNumber/color
```

**Confirm by:** open [`src/actions.js:392`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/actions.js#L392) and look for the object argument `{ type: 's', value: color }`. Then open [`src/osc.js:23-33`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/osc.js#L23-L33), where anything that is not a string, number or boolean reaches the `throw`, which runs at [`src/main.js:273`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L273), before the send and outside its `.catch`.

**Fix:** pass the colour as a plain string, the same way every other action passes its values. The builder already sends a string with type tag `s`.

```js
await self.sendCommand(`/showrevue/widget/${kind}/color`, [color], `Widget ${kind} colour ${color}`)
```

Optionally, also move the `buildOscPacket(address, args)` call in `sendCommand()` into a `try`/`catch`, so a message that can't be built is logged as `Failed to send OSC command "..."` instead of failing the action. The same path also fails on an integer outside the 32-bit range, for example a message duration of 5000000000.

### H2: Manifest lists a legacy module id although ShowRevue has never been published

- **Source:** 🤖 validate-template (MAN-LEGACYIDS)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:25-27`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/companion/manifest.json#L25-L27)

**What goes wrong:** The manifest's `legacyIds` list tells Companion which older module ids this module replaces: when Companion finds a connection or an imported configuration that uses one of those ids, it moves it onto this module. ShowRevue has never been published, so it replaces nothing. The entry `revueshow-revueshow` claims an id that was never released, and a new module must ship with an empty list.

**Why it happens:** The template ships `"legacyIds": []`. This manifest adds one id to it.

**Evidence:** expected (template) vs found (module):

```text
companion/manifest.json:25-27   found "legacyIds": [ "revueshow-revueshow" ]   expected "legacyIds": []
```

**Confirm by:** open [`companion/manifest.json:25-27`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/companion/manifest.json#L25-L27).

**Fix:** empty the list, as in the template.

```json
"legacyIds": [],
```

## 🟡 Medium

### M1: Connection stays green when the feedback port is already in use, and feedbacks and variables never update

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:187-209`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L187-L209)

**What goes wrong:** A user adds a second ShowRevue connection (for a second ShowRevue Mac) and both keep the default "Feedback listen port" of 8002. Or ShowRevue runs on the Companion machine and the feedback port is set to the target port 8001, which the help page warns about. Or another app already uses 8002. The module can't open the port, yet the connection shows a green OK status and actions still work. The Recording, Monitor Only, Source problem and show phase feedbacks never light, and variables such as `$(showrevue:timecode)` and `$(showrevue:cue_number)` never update. The only clue is a "Feedback listener error: bind EADDRINUSE" line in the log. A related case: after a failed change to a new port, changing back to the port that worked before is ignored, so nothing listens at all, still with a green status.

**Why it happens:** The feedback listener's error handler only writes to the log; it never changes the connection status. `refreshStatus()`, which runs right after the listener is started, and every successful send set the status to OK based on the target host and port alone. The module also records the port it listens on only when opening it succeeds, and doesn't clear that record when it closes the old listener. After a failed open it still holds the previous port, so changing back to that port matches the "already listening on this port" check and nothing is reopened. Both reviewers reproduced the failed open: the second listener gets only an `EADDRINUSE` error, and the status stays OK.

**Fix:** when the listener fails, close it, clear its saved state and show the problem in the connection status. Clear the saved port when the old listener is closed too, and keep `refreshStatus()` and `sendCommand()` from overwriting the warning with OK while the listener is down.

```js
sock.on('error', (error) => {
	this.log('error', `Feedback listener error: ${error.message}`)
	try {
		sock.close()
	} catch {
		// ignore
	}
	if (this.listenSocket === sock) {
		this.listenSocket = null
		this.listenPort = null
	}
	this.listenError = `Feedback port ${port} unavailable: ${error.message}`
	this.updateStatus(InstanceStatus.UnknownWarning, this.listenError)
})
```

## 🟢 Low

### L1: Source problem feedback glows amber before ShowRevue has reported anything

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:22`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L22), [`src/feedbacks.js:29-32`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/feedbacks.js#L29-L32)

**What goes wrong:** A user adds the "Status: Source health" preset, or any button with the "Source problem" feedback, before turning on "Send feedback to Companion" in ShowRevue, or while ShowRevue isn't running. The button shows "SRC off" and glows amber as if the camera had failed, although the module has never heard from ShowRevue.

**Why it happens:** The module's stored source health starts as `'off'`, which is also one of the real problem states. The feedback's "is there a value yet" check (`h !== undefined`) is meant to keep a missing value from lighting the button, but the value is never undefined, so the check never applies.

**Fix:** start `source_health` as an empty string and have the feedback return false while it is empty.

```js
return !!h && h !== 'ok'
```

### L2: Target host offers variables, but a variable there is sent as a literal hostname

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:83-89`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L83-L89)

**What goes wrong:** The "Target host" connection field is marked as accepting variables, so a user may enter `$(custom:showrevue_ip)` instead of an IP address. The module sends to that text unchanged, so every button press fails with a DNS error such as "getaddrinfo ENOTFOUND $(custom:showrevue_ip)", the connection turns red (Connection failure), and `$(showrevue:target_host)` shows the raw `$(custom:...)` text. If Companion doesn't offer variables in connection config at all, the flag simply does nothing ([A2](#-assumptions-to-confirm)).

**Why it happens:** `useVariables: true` on the field invites a variable, but `refreshStatus()` and `sendCommand()` read the host text directly and nothing in the module substitutes variables. API v2 has no `parseVariablesInString` to do it.

**Fix:** remove `useVariables: true` from the `host` field at [`src/main.js:88`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L88). If a variable host is really wanted, make it an action option instead, which Companion resolves before the action runs.

### L3: Feedback help text never appears in the feedback picker

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:10`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/feedbacks.js#L10) (also lines 23, 39, 51, 63, 93, 105, 117, 129, 157, 184, 209 and 221)

**What goes wrong:** When a user adds a feedback such as "Recording" or "Disk space low", the help text written for it ("When ShowRevue is recording", "When free space on the recording volume is below N GB") never shows. The feedbacks themselves work normally.

**Why it happens:** All 13 feedback definitions put their help text in a `label` key. A feedback definition in `@companion-module/base` 2.1.3 has `name`, `description`, `options` and so on, but no `label`, so Companion ignores it. Plain JavaScript doesn't flag the unknown key.

**Fix:** rename `label:` to `description:` on the 13 feedback definitions in `src/feedbacks.js` (not on their option or choice labels).

### L4: Help page lists an HTTP polling port 8000 that the module never uses

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:23`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/companion/HELP.md#L23), [`README.md:5`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/README.md#L5)

**What goes wrong:** The "Ports at a glance" table on the connection's help page says port 8000 carries "optional variable polling over HTTP" from Companion to ShowRevue. The module never opens an HTTP connection; all live state arrives over OSC on the feedback port. A user troubleshooting missing variables may set up or open port 8000 for nothing. Separately, the README intro still says "Version 1.0.0 covers the OSC control surface in `ShowRevue/ShowRevue/Managers/OSCManager.swift`", an internal app source path, while the module is 1.1.1.

**Why it happens:** The help page and README describe more than this module does, and the README intro wasn't updated for later versions.

**Fix:** remove the 8000/HTTP row from the help page's port table, or say clearly that it is not used by this module. Reword the README intro without the version number and the internal source path.

### L5: Upgrade scripts added later would never run, because the upgrade list is not exported

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:299`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L299), [`src/upgrades.js:1`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/upgrades.js#L1)

**What goes wrong:** Nothing is visible today, because the upgrade list is empty. When an action or option is later renamed and a migration is added to `src/upgrades.js`, Companion won't see it, so users' existing buttons won't be migrated and actions with renamed options stop working until they are re-entered.

**Why it happens:** Upgrade scripts are small functions that convert saved buttons when a new module version changes an action. A v2 module hands them to Companion as a named `UpgradeScripts` export from its entrypoint; the template does `import { UpgradeScripts } from './upgrades.js'` and `export { UpgradeScripts }`. Here `src/upgrades.js` is never loaded, and the entrypoint exports only the class (`module.exports = ModuleInstance`) ([A4](#-assumptions-to-confirm)).

**Fix:** load the upgrade list in `src/main.js` and export it next to the class.

```js
const UpgradeScripts = require('./upgrades')
// ...
module.exports = ModuleInstance
module.exports.UpgradeScripts = UpgradeScripts
```

Alternatively, convert the module to ES modules like the 2.1 JS template (`"type": "module"`, `export default class ModuleInstance …`, `export { UpgradeScripts }`).

### L6: Fixed-choice dropdowns can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:352-361`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/actions.js#L352-L361), [`src/actions.js:592-602`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/actions.js#L592-L602), [`src/actions.js:611-622`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/actions.js#L611-L622), [`src/actions.js:689-699`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/actions.js#L689-L699), [`src/actions.js:709-719`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/actions.js#L709-L719)

**What goes wrong:** In the action editor, users can switch "Action" (Show / Hide / Toggle) on "Overlay widget: Show / Hide / Toggle", "Source" on "NDI: Set Output Source", and "State" on "Safety: Monitor Only (kill switch)", "Safety: Arm outputs (fireback)" and "Record When Timecode Runs (arm)" into expression mode. An expression whose result doesn't match one of the choices makes Companion skip the action. Users who leave the fields as plain dropdowns are not affected.

**Why it happens:** In API v2 every option can be toggled to expression mode unless the field sets `disableAutoExpression: true`. For a fixed list such as On / Off / Toggle, an expression adds nothing but a way to break the action.

**Fix:** add `disableAutoExpression: true` to these five dropdowns: the `mode` option of `widget_visibility`, `source` of `ndi_source`, and `state` of `monitor_only`, `arm_outputs` and `tc_trigger`.

## 💡 Nice to Have

### N1: Clearing Feedback listen port keeps listening on the old port

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:188-189`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L188-L189)

**What goes wrong:** A user clears the "Feedback listen port" field, for example to turn feedback off, and saves. The module keeps listening on the previous port (8002) and keeps updating feedbacks, so it doesn't do what the user asked ([A3](#-assumptions-to-confirm)). Nothing leaks: the listener is still closed when the connection is removed.

**Why it happens:** `ensureListenSocket()` returns early when the new port is blank or invalid, before the code that closes the existing listener.

**Fix:** when the new port is blank or invalid, close the existing listener and clear `listenSocket` and `listenPort` before returning. You could also note on the help page that a blank port turns feedback off.

### N2: Every incoming state message rewrites all variables and re-checks every feedback

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:238-239`](https://github.com/bitfocus/companion-module-showrevue-showrevue/blob/b6450083bf3cf0f167a9fdc837084d807cb8eb48/src/main.js#L238-L239)

**What goes wrong:** Users see no difference. When ShowRevue sends frequent updates (timecode, time since cue, curtain countdown), each single-value message makes the module resend all of its ~31 variables and re-check all 13 feedback types. "Navigation: Step frames while held" at 30 frames per second also rewrites every variable on each step. That is extra work for Companion on busy systems.

**Why it happens:** `handleStateMessage()` always calls `refreshVariables()`, which sends the whole variable set, and then `checkFeedbacks()` with every feedback id, whatever value changed.

**Fix:** set only the variable for the value that changed (`this.setVariableValues({ [key]: ... })`), and only re-check the feedbacks that depend on it.
