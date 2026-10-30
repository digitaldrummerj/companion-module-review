# Review: companion-module-videopathe-qplayer v1.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-videopathe-qplayer` |
| **Scope** | `tag` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`080c8b5`](https://github.com/bitfocus/companion-module-videopathe-qplayer/tree/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 4.x stores the value of a `secret-text` connection field only in the secrets store and passes it to the module as the separate `secrets` argument, never inside `config` | the base 1.14.1 typing note on `secret-text` ("the value for this will be in the secrets store, not the config store") and base's own split of `secret-*` defaults into `newSecrets`; Companion's host code not checked | [H1](#h1-the-api-pin-entered-in-the-connection-settings-is-never-sent-so-a-pin-protected-qplayer-on-another-machine-refuses-every-request) |
| A2 | A QPlayer with a PIN enabled rejects requests from another machine that carry no `X-QPlayer-Pin` header or `pin` query parameter | the module's own API PIN tooltip in `src/config.ts`; the device was not tested | [H1](#h1-the-api-pin-entered-in-the-connection-settings-is-never-sent-so-a-pin-protected-qplayer-on-another-machine-refuses-every-request) |
| A3 | Companion handles every full `setVariableValues` / `checkFeedbacks()` call from an API 1 module over IPC at a measurable host cost, even if it skips redrawing buttons whose values did not change | base 1.14.1 sends every value with no comparison (`module-api/base.js:305-337`, `internal/feedback.js:123-190`); host-side cost not measured | [M1](#m1-every-variable-and-feedback-is-re-sent-four-times-a-second-even-when-nothing-is-playing-or-the-connection-is-down) |

## 📋 Issues

### Blocking

- [ ] [C1: ESLint config passes an extra ignores option the template does not have](#c1-eslint-config-passes-an-extra-ignores-option-the-template-does-not-have)
- [ ] [C2: Missing postinstall script, so the git pre-commit hook is never installed](#c2-missing-postinstall-script-so-the-git-pre-commit-hook-is-never-installed)
- [ ] [C3: Missing husky devDependency](#c3-missing-husky-devdependency)
- [ ] [C4: Missing lint-staged devDependency](#c4-missing-lint-staged-devdependency)
- [ ] [C5: Missing lint-staged section in package.json](#c5-missing-lint-staged-section-in-packagejson)
- [ ] [H1: The API PIN entered in the connection settings is never sent, so a PIN-protected QPlayer on another machine refuses every request](#h1-the-api-pin-entered-in-the-connection-settings-is-never-sent-so-a-pin-protected-qplayer-on-another-machine-refuses-every-request)

### Non-blocking

- [ ] [M1: Every variable and feedback is re-sent four times a second, even when nothing is playing or the connection is down](#m1-every-variable-and-feedback-is-re-sent-four-times-a-second-even-when-nothing-is-playing-or-the-connection-is-down)
- [ ] [M2: Choosing No target playlist in Set end-of-playlist action still sends the active playlist as the target](#m2-choosing-no-target-playlist-in-set-end-of-playlist-action-still-sends-the-active-playlist-as-the-target)
- [ ] [M3: Variables in text options are resolved a second time through a deprecated API](#m3-variables-in-text-options-are-resolved-a-second-time-through-a-deprecated-api)
- [ ] [M4: GitHub workflow pins a different checkout action version than the template](#m4-github-workflow-pins-a-different-checkout-action-version-than-the-template)
- [ ] [L1: A rejected command, such as an unknown media ID, turns the connection red as if QPlayer were unreachable](#l1-a-rejected-command-such-as-an-unknown-media-id-turns-the-connection-red-as-if-qplayer-were-unreachable)
- [ ] [L2: An unexpected reply during a poll or repaint crashes the whole module process](#l2-an-unexpected-reply-during-a-poll-or-repaint-crashes-the-whole-module-process)
- [ ] [L3: A host typed as a URL or with a port shows Bad Configuration with no explanation](#l3-a-host-typed-as-a-url-or-with-a-port-shows-bad-configuration-with-no-explanation)
- [ ] [L4: Some options will stop hiding correctly after a future API upgrade because they use the deprecated isVisible function](#l4-some-options-will-stop-hiding-correctly-after-a-future-api-upgrade-because-they-use-the-deprecated-isvisible-function)
- [ ] [L5: The Open monitor window preset toggles the window, so a second press closes it](#l5-the-open-monitor-window-preset-toggles-the-window-so-a-second-press-closes-it)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: ESLint config passes an extra ignores option the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:3-6`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/eslint.config.mjs#L3-L6)

**What goes wrong:** The module's lint setup no longer matches the official template, so anyone troubleshooting lint results later is comparing against a configuration that differs from every other module built on this template.

**Why it happens:** The template calls `generateEslintConfig` with only `enableTypescript: true`. The module adds `ignores: ['**/._*']` (macOS resource-fork files). Changed options in `eslint.config.mjs` are not an accepted deviation.

**Evidence:**

```text
Module (line 5):   ignores: ['**/._*'],
Template (line 5): })
```

**Fix:** remove the extra option so the file matches the template exactly.

```js
import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'

export default generateEslintConfig({
	enableTypescript: true,
})
```

### C2: Missing postinstall script, so the git pre-commit hook is never installed

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:19-27`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/package.json#L19-L27)

**What goes wrong:** The module ships a `.husky/pre-commit` hook that runs `lint-staged`, but a fresh `yarn install` never installs it, so commits are not formatted or linted before they land.

**Why it happens:** The template's `"postinstall": "husky"` script is what wires the `.husky/` hooks into git. The module's `scripts` block has no `postinstall` entry.

**Evidence:**

```text
Missing required script 'postinstall' (template: "postinstall": "husky")
```

**Fix:** add the template's script.

```json
"postinstall": "husky",
```

### C3: Missing husky devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:32-41`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/package.json#L32-L41)

**What goes wrong:** Without `husky` installed, the `postinstall` script from C2 has nothing to run, and the module's `.husky/pre-commit` hook stays inactive.

**Why it happens:** The template lists `husky` in `devDependencies`; the module does not.

**Evidence:**

```text
Missing devDependency 'husky' (present in template: "husky": "^9.1.7")
```

**Fix:** add the template's devDependency.

```json
"husky": "^9.1.7",
```

### C4: Missing lint-staged devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:32-41`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/package.json#L32-L41)

**What goes wrong:** The module's pre-commit hook calls `lint-staged`, which is not installed, so the hook would fail as soon as it is activated.

**Why it happens:** The template lists `lint-staged` in `devDependencies`; the module does not.

**Evidence:**

```text
Missing devDependency 'lint-staged' (present in template: "lint-staged": "^16.2.7")
```

**Fix:** add the template's devDependency.

```json
"lint-staged": "^16.2.7",
```

### C5: Missing lint-staged section in package.json

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/package.json)

**What goes wrong:** Even with `lint-staged` installed, it has no configuration telling it which staged files to format and lint, so the pre-commit hook would do nothing useful.

**Why it happens:** The template's `package.json` has a top-level `lint-staged` section; the module's does not.

**Evidence:**

```text
Missing 'lint-staged' section (present in template)
```

**Fix:** copy the template's section into `package.json`.

```json
"lint-staged": {
	"*.{css,json,md,scss}": [
		"prettier --write"
	],
	"*.{ts,tsx,js,jsx}": [
		"yarn lint:raw --fix"
	]
},
```

## 🟠 High

### H1: The API PIN entered in the connection settings is never sent, so a PIN-protected QPlayer on another machine refuses every request

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:339-342`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L339-L342), [`src/main.ts:772-774`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L772-L774), [`src/config.ts:43-50`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/config.ts#L43-L50)

**What goes wrong:** A user runs QPlayer on a different computer with a PIN turned on in Settings > Security. They type the PIN (for example `4821`) into the **API PIN** field of the connection settings and save. The module still sends every HTTP request and the WebSocket connection without a PIN. QPlayer rejects them, the connection shows **Connection Failure** (for example "HTTP 401 ..."), and no action, feedback or variable works. Re-entering the PIN changes nothing. Setups where QPlayer runs on the same machine, or has no PIN, are not affected.

**Why it happens:** The **API PIN** field is a `secret-text` field. Since @companion-module/base 1.13, Companion keeps secret-text values out of the normal connection config and hands them to the module separately, as the extra `secrets` argument of `init()` and `configUpdated()`. The module ignores that argument and reads the PIN from `this.config.apiPin`, which is always empty. So no PIN header is added to HTTP requests and no `pin` parameter is added to the WebSocket URL.

**Evidence:**

```ts
// src/config.ts:43-50
		{
			type: 'secret-text',
			id: 'apiPin',
			label: 'API PIN',
			width: 6,
			default: '',
			regex: '/^([0-9]{4,8})?$/',
// src/main.ts:106
export class ModuleInstance extends InstanceBase<ModuleConfig> {
// src/main.ts:186-187
	async init(config: ModuleConfig): Promise<void> {
		this.config = config
// src/main.ts:209-214
	async configUpdated(config: ModuleConfig): Promise<void> {
		...
		this.config = config
// src/main.ts:339-342
	private getAuthHeaders(): Record<string, string> {
		const pin = safeString(this.config.apiPin).trim()
		return pin ? { 'X-QPlayer-Pin': pin } : {}
	}
// src/main.ts:772-774
		const wsParams = new URLSearchParams({ client: 'companion-module' })
		const apiPin = safeString(this.config.apiPin).trim()
		if (apiPin) wsParams.set('pin', apiPin)
```

```js
// node_modules/@companion-module/base/dist/module-api/base.js:93-126 (base 1.14.1)
            this.#lastConfig = msg.config;
            this.#lastSecrets = msg.secrets;
            ...
                    if ('default' in field) {
                        if (field.type.startsWith('secret')) {
                            newSecrets[field.id] = field.default;
                        }
                        else {
                            newConfig[field.id] = field.default;
                        }
            ...
                await this.init(this.#lastConfig, !!msg.isFirstInit, this.#lastSecrets);
// base.js:157-159
            this.#lastConfig = msg.config;
            this.#lastSecrets = msg.secrets;
            await this.configUpdated(this.#lastConfig, this.#lastSecrets);
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:361-363
 * A text input field for secret values
 *
 * Available for config. Note: the value for this will be in the secrets store, not the config store.
```

A search of `src/` for "secret" finds only `src/config.ts:44`; the `secrets` argument is never read.

**Confirm by:** open [`src/main.ts:186`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L186) and [`src/main.ts:209`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L209): `init` and `configUpdated` take no `secrets` argument. Then open [`src/main.ts:340`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L340) and [`src/main.ts:773`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L773), which read the PIN from `this.config.apiPin`. As a live check, set a PIN in a remote QPlayer and confirm requests are rejected with 401.

**Fix:** declare a secrets type, store the `secrets` argument, and read the PIN from it.

```ts
interface ModuleSecrets {
	apiPin?: string
}

export class ModuleInstance extends InstanceBase<ModuleConfig, ModuleSecrets> {
	private secrets: ModuleSecrets | undefined

	async init(config: ModuleConfig, _isFirstInit: boolean, secrets: ModuleSecrets): Promise<void> {
		this.config = config
		this.secrets = secrets
		// ...
	}

	async configUpdated(config: ModuleConfig, secrets: ModuleSecrets): Promise<void> {
		this.config = config
		this.secrets = secrets
		// ...
	}
}
```

Then use `this.secrets?.apiPin` in `getAuthHeaders()` and `connectWebSocket()`, and remove `apiPin` from `ModuleConfig`. Changing the field to `textinput` would also work, but would show the PIN in exported configs.

## 🟡 Medium

### M1: Every variable and feedback is re-sent four times a second, even when nothing is playing or the connection is down

- **Source:** 🔎 QA reviewer + compliance reviewer + protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:696-705`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L696-L705), [`src/main.ts:715-730`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L715-L730), [`src/main.ts:984-1041`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L984-L1041)

**What goes wrong:** Every QPlayer connection repaints every 250 ms for as long as it exists, including when QPlayer is idle, unreachable, or no host has been entered yet (status **Bad Configuration**). Each repaint sends about 330 variable values (connection, unprefixed player, and the `p1_`/`p2_` sets), roughly 1,300 variable updates per second per connection, and re-runs every placed feedback. Feedbacks with variables in their text (for example **Window media name matches** with a `$(...)` in **Media name**) also make an extra variable-parsing round trip each time. Nothing visible changes on the buttons, but the constant CPU and IPC load grows with every button and every extra QPlayer connection, which matters on low-power hosts such as a Raspberry Pi.

**Why it happens:** `startReadoutTicker()` starts a 250 ms `setInterval` from `init()` / `configUpdated()` that calls `repaint()` with no condition other than a minimum gap. `repaint()` always pushes the full variable set with `setVariableValues` and calls `checkFeedbacks()` with no ids, which re-checks every feedback type. The base package (1.14.1) does not compare values with the previous ones before sending them to Companion.

**Fix:** only repaint from the ticker when something is actually counting: the connection is up and at least one window is playing (or a program offset countdown is active). Keep the last values sent and pass only changed variables to `setVariableValues`, and on a tick call `checkFeedbacks('remaining_time_compare', 'elapsed_percent_compare', 'remaining_time_dynamic', 'program_offset_countdown_active')` instead of re-checking every feedback.

### M2: Choosing No target playlist in Set end-of-playlist action still sends the active playlist as the target

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:136-148`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/actions.ts#L136-L148), [`src/actions.ts:1076-1117`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/actions.ts#L1076-L1117)

**What goes wrong:** An operator adds **Playlist: Set end-of-playlist action** with **End action** = "Jump to another playlist" (or "Stop") and leaves **Target playlist** on the default "No target playlist". On press, the module sends the currently active playlist's ID (for example `pl-main`) as the target, so the playlist jumps back to itself, or a stored target the operator meant to clear is overwritten. Choosing "No target playlist" also never clears an existing target media.

**Why it happens:** "No target playlist" is stored as an empty string, and `resolvePlaylistId()` treats an empty selection the same as the separate "Active playlist" choice and returns the active playlist's ID. An empty media choice becomes `undefined` and is dropped from the JSON body, so nothing is cleared.

**Fix:** check for the empty choice before resolving, and send an explicit empty value (whichever QPlayer accepts, `null` or `''`) to clear a stored target.

```ts
const targetPlaylistId =
	manualTarget ||
	(event.options.targetPlaylistChoice === '' ? '' : resolvePlaylistId(self, event.options.targetPlaylistChoice, ''))
```

### M3: Variables in text options are resolved a second time through a deprecated API

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/optionVariables.ts:1-26`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/optionVariables.ts#L1-L26), [`src/actions.ts:298-300`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/actions.ts#L298-L300), [`src/feedbacks.ts:118-127`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/feedbacks.ts#L118-L127)

**What goes wrong:** In normal use nothing looks different: a text option such as **Playlist ID override**, or the **Media name** text of a feedback, that contains `$(...)` is already resolved by Companion before the callback runs. The module then resolves it a second time. If a variable's value itself contains `$(` (for example a media comment), it gets substituted again, which is not what the user typed. The code comment "API 1.x suggests variables in fields but does not resolve them automatically" is wrong for base 1.14.1 and will mislead later maintainers.

**Why it happens:** Companion resolves variables in `textinput` fields that set `useVariables` before calling an action or feedback callback. Both player-targeting wrappers still call `resolveVariableOptions()`, which runs `context.parseVariablesInString()` on every such field; base 1.14.1 marks that method `@deprecated Companion now handles this for you`.

**Fix:** delete `src/optionVariables.ts`, remove the `variableOptionIds` / `resolveVariableOptions` calls from the `applyPlayerTargeting` wrappers in `actions.ts` and `feedbacks.ts`, and pass `event` straight to the inner callback. The feedback wrapper can then stay synchronous.

### M4: GitHub workflow pins a different checkout action version than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/.github/workflows/node.yaml#L18)

**What goes wrong:** The CI workflow no longer matches the template, so it drifts from every other module's CI when the template is updated.

**Why it happens:** Line 18 uses `actions/checkout@v7`; the template uses `actions/checkout@v4`. Only the action version pin differs.

**Fix:** copy the template's workflow file.

```yaml
      - uses: actions/checkout@v4
```

## 🟢 Low

### L1: A rejected command, such as an unknown media ID, turns the connection red as if QPlayer were unreachable

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:576-586`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L576-L586)

**What goes wrong:** An operator presses a **Player: Play playlist media** button whose **Media ID override** points to a deleted clip, and QPlayer answers HTTP 404 or 400. The connection switches to **Connection Failure: HTTP 404 Not Found: …**, `connection_status` becomes `connection_failure`, and every preset button turns dark red (the presets carry an inverted "Connection is ok" feedback) until the next poll about a second later. It looks like a network drop when the real problem is a bad action option.

**Why it happens:** `postCommandForResult` handles every error from the request the same way: it marks the connection as down and sets **Connection Failure**, whether the error was a network failure or a normal HTTP 4xx from a reachable QPlayer.

**Fix:** throw a typed error (for example `HttpStatusError` with `.status`) for non-OK responses in `fetchJson`. In `postCommandForResult`, only mark the connection failed for network errors or timeouts; for 4xx/5xx, log a warning with the action path and server message and rethrow, leaving the connection status unchanged.

### L2: An unexpected reply during a poll or repaint crashes the whole module process

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:405-538`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L405-L538), [`src/main.ts:698-704`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L698-L704)

**What goes wrong:** If QPlayer (or another server on the configured port) returns a 200 response whose JSON body is `null`, or any other state that makes the state-processing code throw, the module process crashes. Companion restarts it, the next poll crashes it again, and the user sees the connection repeatedly restarting instead of a clear **Connection Failure** with a message.

**Why it happens:** `refreshAllState()` wraps its body in `try { … } finally { … }` with no `catch`, and its callers (the poll timer, the WebSocket `open` handler and `postCommandForResult`) call it with `void`. A throw after the status fetch, or inside `refreshDynamicDefinitions()` / `repaint()`, becomes an unhandled promise rejection. The readout `setInterval` callback calls `repaint()` with no try/catch. Base 1.14.1 registers no `unhandledRejection` handler, so Node 22 terminates the process.

**Fix:** add `catch (error) { if (!isStale()) this.handlePollFailure(error) }` to the outer try in `refreshAllState()`, wrap the readout interval callback in try/catch and log failures with `this.log('error', …)`, and check that the `/api/status` response is a non-null object before using it.

### L3: A host typed as a URL or with a port shows Bad Configuration with no explanation

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:621-647`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/main.ts#L621-L647)

**What goes wrong:** A user enters the QPlayer host as `http://192.168.1.20` or `192.168.1.20:2224`, both common ways to type it. The connection goes to **Bad Configuration** with no message and nothing in the log, so the operator cannot tell which field is wrong.

**Why it happens:** `buildBaseUrl` wraps any host containing `:` in IPv6 brackets, producing `http://[http://192.168.1.20]:2224`, which `new URL()` rejects. `startPolling()` then sets **Bad Configuration** without a message.

**Fix:** pass a reason with the status, for example `setStatus(InstanceStatus.BadConfig, 'Enter a host name or IP address only, without http:// or :port')`, and log it once. Optionally strip a leading `http://` and a trailing `:port` before validating.

### L4: Some options will stop hiding correctly after a future API upgrade because they use the deprecated isVisible function

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:479`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/feedbacks.ts#L479), [`src/feedbacks.ts:488`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/feedbacks.ts#L488), [`src/actions.ts:1738`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/actions.ts#L1738)

**What goes wrong:** Nothing is wrong today: **Warn threshold (s)** and **Alert threshold (s)** in the **Window remaining time dynamic style** feedback, and **Fullscreen (when opening)** in the **Monitor: Open, close or toggle the monitor window** action, show and hide correctly. `isVisible` functions are removed in API 2.0, so these fields would always show (or break) after a future upgrade.

**Why it happens:** Base 1.14.1 marks `isVisible` "@deprecated This will be removed in 2.0.0 of this api. Use `isVisibleExpression` instead."

**Fix:** replace each function with an expression.

```ts
isVisibleExpression: "$(options:source) == 'custom'", // feedbacks.ts:479 and :488
isVisibleExpression: "$(options:action) != 'close'", // actions.ts:1738
```

### L5: The Open monitor window preset toggles the window, so a second press closes it

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:675-691`](https://github.com/bitfocus/companion-module-videopathe-qplayer/blob/080c8b53b1fc2c2b8b1ed7e3046cc4599d4d7206/src/presets.ts#L675-L691)

**What goes wrong:** A user drags the Services preset **Open monitor window** (button text "MON OPEN") onto a button. The first press opens the monitor window; a second press, for example an operator making sure it is open, closes it, even though the button says OPEN.

**Why it happens:** The preset passes only `{ fullscreen: 'on' }` to the monitor action and never sets its **action** option, which defaults to "toggle".

**Fix:** set the action explicitly in the preset, or rename the preset to "Toggle monitor window" if toggling is intended.

```ts
{ action: 'open', fullscreen: 'on' },
```

## 📝 Additional Notes

- First release: there is no previous tag to diff against, so the whole module was reviewed and every finding is classified 🆕 NEW.
- `yarn install --immutable`, `yarn package` and `yarn lint` all pass, and `videopathe-qplayer-1.0.0.tgz` is produced.
