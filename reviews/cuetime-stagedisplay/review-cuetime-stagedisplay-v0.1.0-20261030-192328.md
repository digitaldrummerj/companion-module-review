# Review: companion-module-cuetime-stagedisplay v0.1.0

| | |
| --- | --- |
| **Module** | [companion-module-cuetime-stagedisplay](https://github.com/bitfocus/companion-module-cuetime-stagedisplay) |
| **Scope** | `tag` |
| **Version** | `v0.1.0` (commit [`e2b2356`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/tree/e2b23561eb9c902d9c90d731041f5bfa72a7c050)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | none — first release, so there is no diff and the whole module was reviewed |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` all pass |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion sends the module the "Discovered CueTime Displays" choice as `<address>:<port>` (for example `192.168.1.50:8081`), not as a bare host name | The installed Companion 5.1.1 web UI bundle (`webui.zip`, `assets/index-*.js`) builds each choice id as `${address}:${port}`. The `@companion-module/base` 2.1.3 typings don't document the value format, and the module was not run live | [H2](#h2-choosing-a-discovered-cuetime-display-in-the-connection-settings-never-connects) |
| A2 | Companion re-runs an advanced feedback's callback only when the module calls `checkFeedbacks`/`checkAllFeedbacks`, when the feedback's options change, or when a variable the callback parsed changes; never on a timer | The documented `checkFeedbacks`/`checkAllFeedbacks` API in `@companion-module/base/dist/module-api/base.d.ts:135-142`; the host code was not checked | [H3](#h3-session-progress-bar-feedback-is-drawn-once-and-never-updates) |
| A3 | Companion evaluates `$(cuetime-display:cuetime-display)` in a config field's visibility expression as a variable of a (nonexistent) connection labelled `cuetime-display`, not as the config field; whether the manual fields then always show or never show depends on how Companion compares an unknown variable with `null` | `@companion-module/base` `input.d.ts:35` documents `$(options:<field_id>)` as the syntax; the expression was not evaluated in a running Companion | [M3](#m3-manual-target-ip-and-target-port-fields-do-not-follow-the-discovered-display-choice) |

## 📋 Issues

### Blocking

- [ ] [C1: `.gitignore` is missing template entries](#c1-gitignore-is-missing-template-entries)
- [ ] [C2: `.husky/pre-commit` is missing](#c2-huskypre-commit-is-missing)
- [ ] [C3: `.yarnrc.yml` is missing template keys](#c3-yarnrcyml-is-missing-template-keys)
- [ ] [C4: `.yarnrc.yml` sets `yarnPath`, which the template does not](#c4-yarnrcyml-sets-yarnpath-which-the-template-does-not)
- [ ] [C5: Yarn binary is committed to the repository](#c5-yarn-binary-is-committed-to-the-repository)
- [ ] [C6: `package.json` scripts, devDependencies and lint-staged do not match the template](#c6-packagejson-scripts-devdependencies-and-lint-staged-do-not-match-the-template)
- [ ] [H1: Module checks workflow differs from the template](#h1-module-checks-workflow-differs-from-the-template)
- [ ] [H2: Choosing a discovered CueTime display in the connection settings never connects](#h2-choosing-a-discovered-cuetime-display-in-the-connection-settings-never-connects)
- [ ] [H3: Session Progress Bar feedback is drawn once and never updates](#h3-session-progress-bar-feedback-is-drawn-once-and-never-updates)
- [ ] [H4: Toggle Playback does nothing when the display is idle](#h4-toggle-playback-does-nothing-when-the-display-is-idle)
- [ ] [H5: The Node type definitions are for Node 25, but the module and the API 2.1 template use Node 26](#h5-the-node-type-definitions-are-for-node-25-but-the-module-and-the-api-21-template-use-node-26)

### Non-blocking

- [ ] [M1: `.github/workflows/node.yaml` is missing](#m1-githubworkflowsnodeyaml-is-missing)
- [ ] [M2: `.github/workflows/release.yaml` is missing](#m2-githubworkflowsreleaseyaml-is-missing)
- [ ] [M3: Manual Target IP and Target Port fields do not follow the discovered-display choice](#m3-manual-target-ip-and-target-port-fields-do-not-follow-the-discovered-display-choice)
- [ ] [M4: Blackout Mode Active feedback overrides the button style even when blackout is off](#m4-blackout-mode-active-feedback-overrides-the-button-style-even-when-blackout-is-off)
- [ ] [M5: Action and feedback options are untyped, so option id typos are not caught at build time](#m5-action-and-feedback-options-are-untyped-so-option-id-typos-are-not-caught-at-build-time)
- [ ] [L1: A new connection with no address shows Connection Failure and logs an error on every retry](#l1-a-new-connection-with-no-address-shows-connection-failure-and-logs-an-error-on-every-retry)
- [ ] [L2: Variables typed into free-text action fields are sent as literal text](#l2-variables-typed-into-free-text-action-fields-are-sent-as-literal-text)
- [ ] [L3: Every preset sits in its own section, so the preset list is long and ungrouped](#l3-every-preset-sits-in-its-own-section-so-the-preset-list-is-long-and-ungrouped)
- [ ] [L4: Enable, Disable and Toggle dropdowns can be switched to expression mode](#l4-enable-disable-and-toggle-dropdowns-can-be-switched-to-expression-mode)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.gitignore` is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.gitignore)

**What goes wrong:** The repository does not ignore everything the template ignores, so build and editor files can end up committed (the Yarn binary already has, see [C5](#c5-yarn-binary-is-committed-to-the-repository)).

**Why it happens:** Validator: `.gitignore`: Missing template .gitignore entries: DEBUG-\*, /.yarn, /.vscode. The module has `DEBUG-*/` (not `DEBUG-*`), ignores individual `/.yarn/*` subpaths instead of `/.yarn`, and has no `/.vscode`.

**Evidence:** expected (template) `DEBUG-*`, `/.yarn`, `/.vscode`; found `DEBUG-*/`, `/.yarn/cache`, `/.yarn/install-state.gz`, … and no `/.vscode`.

**Confirm by:** compare [`.gitignore`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.gitignore) with the template's `.gitignore`.

**Fix:** add the template's three entries. The module's extra entries can stay.

```text
DEBUG-*
/.yarn
/.vscode
```

### C2: `.husky/pre-commit` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit`

**What goes wrong:** Commits are not formatted and linted before they are made, as every module built from the template does.

**Why it happens:** Validator: `.husky/pre-commit`: Required file is missing (tracked by the template).

**Evidence:** the template tracks `.husky/pre-commit` (content: `lint-staged`); the module has no `.husky/` directory.

**Confirm by:** check that `.husky/pre-commit` does not exist at the review commit.

**Fix:** copy the template's `.husky/pre-commit` (it runs `lint-staged`). It also needs the `husky`/`lint-staged` setup from [C6](#c6-packagejson-scripts-devdependencies-and-lint-staged-do-not-match-the-template).

### C3: `.yarnrc.yml` is missing template keys

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.yarnrc.yml)

**What goes wrong:** Installs run without the template's supply-chain protections: dependency install scripts are allowed to run, and freshly published packages are installed with no age gate.

**Why it happens:** Validator: `.yarnrc.yml`: Missing template keys: enableScripts, npmMinimalAgeGate, npmPreapprovedPackages. The file contains only `nodeLinker: node-modules` and `yarnPath: .yarn/releases/yarn-4.12.0.cjs`.

**Evidence:** expected (template) `enableScripts: false`, `npmMinimalAgeGate: 3d`, `npmPreapprovedPackages: ["@companion-module/*"]`; found none of them.

**Confirm by:** open [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.yarnrc.yml).

**Fix:** replace the file with the template's `.yarnrc.yml`.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C4: `.yarnrc.yml` sets `yarnPath`, which the template does not

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:3`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.yarnrc.yml#L3)

**What goes wrong:** Yarn runs from a binary committed to the repo instead of the version selected by `packageManager` through corepack, as in every other template-based module.

**Why it happens:** Validator: `.yarnrc.yml`: Extra keys not in template: yarnPath.

**Evidence:** found `yarnPath: .yarn/releases/yarn-4.12.0.cjs`; the template has no `yarnPath`.

**Confirm by:** open [`.yarnrc.yml:3`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.yarnrc.yml#L3).

**Fix:** remove `yarnPath` (copying the template's file for [C3](#c3-yarnrcyml-is-missing-template-keys) does this).

### C5: Yarn binary is committed to the repository

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW
- **File:** [`.yarn/releases/yarn-4.12.0.cjs`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.yarn/releases/yarn-4.12.0.cjs)

**What goes wrong:** A multi-megabyte Yarn release is tracked in the module's git history.

**Why it happens:** Validator: `.yarn/releases/yarn-4.12.0.cjs`: Committed but template .gitignore excludes it (pattern '/.yarn').

**Evidence:** the file is tracked at the review commit; the template's `.gitignore` excludes `/.yarn`.

**Confirm by:** `git ls-files .yarn` at the review commit lists the file.

**Fix:** once `/.yarn` is ignored ([C1](#c1-gitignore-is-missing-template-entries)) and `yarnPath` is removed ([C4](#c4-yarnrcyml-sets-yarnpath-which-the-template-does-not)), untrack it.

```bash
git rm --cached .yarn/releases/yarn-4.12.0.cjs
```

### C6: `package.json` scripts, devDependencies and lint-staged do not match the template

- **Source:** 🤖 validate-template (PKG-SCRIPT, PKG-DEVDEP, PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-16`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/package.json#L6-L16)

**What goes wrong:** The module's build and tooling commands differ from the template, so the standard `yarn dev`, `yarn build:main` and `yarn lint:raw` commands don't exist and the pre-commit hook has nothing to run.

**Why it happens:** The module defines its own scripts (and a custom `scripts/clean.mjs` in place of `rimraf`). The validator reports:

- `package.json`: Missing required script 'postinstall'.
- `package.json`: Missing required script 'build:main'.
- `package.json`: Missing required script 'dev'.
- `package.json`: Missing required script 'lint:raw'.
- `package.json`: Missing devDependency 'husky' (present in template).
- `package.json`: Missing devDependency 'lint-staged' (present in template).
- `package.json`: Missing devDependency 'rimraf' (present in template).
- `package.json`: Missing 'lint-staged' section (present in template).

**Evidence:** template scripts are `postinstall: husky`, `build: rimraf dist && run build:main`, `build:main: tsc -p tsconfig.build.json`, `dev: tsc -p tsconfig.build.json --watch`, `lint:raw: eslint`, `lint: run lint:raw .`; the module has none of `postinstall`, `build:main`, `dev`, `lint:raw`.

**Confirm by:** compare [`package.json:6-16`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/package.json#L6-L16) with the template's `package.json`.

**Fix:** add the template's scripts, devDependencies and `lint-staged` section. The module's icon and protocol generation steps can stay in `build`/`package` alongside them.

```json
"scripts": {
	"postinstall": "husky",
	"build": "node scripts/generate-icons.mjs && yarn generate-protocol && rimraf dist && run build:main",
	"build:main": "tsc -p tsconfig.build.json",
	"dev": "tsc -p tsconfig.build.json --watch",
	"lint:raw": "eslint",
	"lint": "run lint:raw ."
},
"lint-staged": {
	"*.{css,json,md,scss}": ["prettier --write"],
	"*.{ts,tsx,js,jsx}": ["yarn lint:raw --fix"]
}
```

## 🟠 High

### H1: Module checks workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:19-62`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.github/workflows/companion-module-checks.yaml#L19-L62)

**What goes wrong:** The file the template tracks for Bitfocus's standard module checks has extra jobs in it, so it no longer matches what every other module runs and gets harder to update from the template.

**Why it happens:** Validator: `.github/workflows/companion-module-checks.yaml`: Differs from template (line 11: found 'protocol-drift:', template '\<missing\>'). Lines 19-45 add a `protocol-drift` job (regenerates `src/protocol/generated.ts` and fails on drift) and lines 47-62 add a `lint` job; the template's `check` job (lines 7-17) is unchanged.

**Evidence:** found the extra jobs `protocol-drift` and `lint`; the template has only `check`.

**Confirm by:** diff [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/.github/workflows/companion-module-checks.yaml) against the template's `companion-module-checks.yaml`.

**Fix:** restore the template's file, and move the `protocol-drift` and `lint` jobs into a separate workflow file that the template does not track (for example `.github/workflows/protocol.yaml`).

### H2: Choosing a discovered CueTime display in the connection settings never connects

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/logic.ts:8-18`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/logic.ts#L8-L18)

**What goes wrong:** A user opens the connection settings and picks their display from "Discovered CueTime Displays", for example "CueTime Lobby (192.168.1.50:8081)". The connection never opens. The status shows Connection Failure with "Invalid URL: ws://192.168.1.50:8081:8081", the log gets a new "WebSocket error: Invalid URL …" line every 1 to 30 seconds, and no action, feedback or variable works. The only workaround is to choose "Manual" and type the IP address, which defeats the discovery feature that HELP.md recommends first. Users who enter the IP manually are not affected.

**Why it happens:** Companion stores the discovered-device choice as the text `192.168.1.50:8081` (address and port together, see [A1](#-assumptions-to-confirm)). The module uses that whole text as the host name and then adds the port from the hidden manual "Target Port" field (default `8081`) a second time, giving `ws://192.168.1.50:8081:8081`. That address is invalid, so the WebSocket library throws, and the module's error handler schedules another attempt that fails the same way, forever. The unit test at [`src/logic.test.ts:57`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/logic.test.ts#L57) uses `display.local` as the discovered value, which is not what Companion sends, so the tests pass anyway.

**Evidence:**

```ts
// src/logic.ts:8-18
export function getEffectiveHost(config: Pick<Config, 'host' | 'cuetime-display'>): string {
	if (config['cuetime-display']) {
		return config['cuetime-display']
	}
	return config.host || ''
}

/** The WebSocket transport lives on port 8081 (HTTP is 8080 and unused here). */
export function getEffectivePort(config: Pick<Config, 'port'>): string {
	return config.port || '8081'
}
```

```ts
// src/main.ts:99-104
	private connect(): void {
		this.client?.stop()

		const host = this.resolveHost()
		const port = Number(this.resolvePort())
```

```ts
// src/protocol/client.ts:209-219
	private connect(): void {
		const url = `ws://${this.host}:${this.port}`
		this.log('debug', `Connecting to ${url}`)

		let ws: WebSocketLike
		try {
			ws = this.socketFactory(url)
		} catch (error) {
			this.handleError(error as Error)
			return
		}
```

```js
// Companion 5.1.1 webui.zip assets/index-*.js (bonjour-device choices)
for(let n of t.addresses||[]){let r=`${n}:${t.port}`;e.push({id:r,label:`${t.name} (${r})`})}
```

```text
// node -e "new URL('ws://192.168.1.50:8081:8081')"
Invalid URL
```

**Confirm by:** open [`src/logic.ts:8-13`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/logic.ts#L8-L13): the discovered value (`ip:port`) is returned unchanged as the host. Then open [`src/protocol/client.ts:210`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/protocol/client.ts#L210), where the port is added again.

**Fix:** when a discovered display is selected, split its value into host and port (on the last `:`, allowing for a bracketed IPv6 address) and use the discovered port instead of the hidden manual port. Update the tests in [`src/logic.test.ts:57`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/logic.test.ts#L57) to use a real Companion value such as `192.168.1.50:8081`.

```ts
function splitHostPort(value: string): { host: string; port: string } {
	const i = value.lastIndexOf(':')
	if (i <= 0 || value.endsWith(']')) return { host: value, port: '' }
	return { host: value.slice(0, i).replace(/^\[|\]$/g, ''), port: value.slice(i + 1) }
}

export function getEffectiveEndpoint(config: Config): { host: string; port: string } {
	if (config['cuetime-display']) {
		const { host, port } = splitHostPort(config['cuetime-display'])
		return { host, port: port || '8081' }
	}
	return { host: config.host || '', port: config.port || '8081' }
}
```

### H3: Session Progress Bar feedback is drawn once and never updates

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:47-62`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/main.ts#L47-L62), [`src/main.ts:143-146`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/main.ts#L143-L146)

**What goes wrong:** A user adds the "Session Progress Bar" feedback to a button so it shows how much of a 5-minute countdown is left. The bar is drawn once when the button is set up (often empty, before the module has received the display's state) and then stays frozen. It doesn't shrink while the countdown runs, and it doesn't change when a new session starts. The `progress_bar` variable keeps updating; only the feedback is stuck.

**Why it happens:** Companion only re-draws a feedback when the module asks it to (see [A2](#-assumptions-to-confirm)). On every state change the module asks Companion to re-check a fixed list of feedback types, and the "Session Progress Bar" feedback (`progress_bar`) is missing from that list. Nothing else in the module asks for a re-check, and the feedback reads the module's state directly instead of a variable, so Companion never re-runs it.

**Evidence:**

```ts
// src/main.ts:46-62
/** Every feedback this module defines; refreshed in one pass whenever state changes. */
const FEEDBACK_IDS = [
	'is_connected',
	'is_playing',
	'is_paused',
	'is_idle',
	'is_glowing',
	'is_blackout',
	'is_flashing',
	'has_previous_session',
	'no_previous_session',
	'has_next_session',
	'no_next_session',
	'message_showing',
	'is_time_up_display',
	'is_time_up_flashing',
] as const
```

```ts
// src/main.ts:143-146
	private refreshFromState(): void {
		this.setVariableValues(extractVariableValues(this.state))
		this.checkFeedbacks(...FEEDBACK_IDS)
	}
```

```ts
// src/feedbacks.ts:178-182, 222-223
		progress_bar: {
			name: 'Session Progress Bar',
			...
			type: 'advanced',
			...
			callback: (feedback): CompanionAdvancedFeedbackResult => {
				const percent = progressPercent(self.state)
```

```text
// grep -rn "checkAll\|FeedbacksById\|FEEDBACK_IDS" src/
src/main.ts:47:const FEEDBACK_IDS = [
src/main.ts:145:		this.checkFeedbacks(...FEEDBACK_IDS)
```

**Confirm by:** open [`src/main.ts:47-62`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/main.ts#L47-L62) and see that `'progress_bar'` is not in the list; [`src/main.ts:145`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/main.ts#L145) is the only re-check in `src/`, and the callback at [`src/feedbacks.ts:222`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/feedbacks.ts#L222) reads `self.state` directly.

**Fix:** add the progress bar to the list of feedbacks re-checked on every state change. Better still, build the list from the feedback definitions so a new feedback can't be left out again.

```ts
const FEEDBACK_IDS = [
	// ...existing ids
	'is_time_up_flashing',
	'progress_bar',
] as const
```

### H4: Toggle Playback does nothing when the display is idle

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:82-94`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L82-L94)

**What goes wrong:** An operator loads a program; the display is idle (no current session). They press the "Toggle Playback" preset (the play/pause icon) and nothing happens on the display. The only trace is a log warning "CueTime rejected 'start_session': INVALID_COMMAND — No active session to start". HELP.md says Toggle Playback "starts a paused or idle one", and "Start / Resume Session" does start the first session from idle, so the two play buttons behave differently.

**Why it happens:** When the timer is not running, "Toggle Playback" sends a plain "start session" command with no session named. The module's own protocol notes say the display rejects that command when no session is current. "Start / Resume Session" avoids this by naming the first session when the display is idle, but "Toggle Playback" doesn't use that logic.

**Evidence:**

```ts
// src/actions.ts:82-106
		toggle_playback: {
			name: 'Toggle Playback',
			options: [],
			callback: async () => {
				if (skipForTimeOfDay(self, 'Toggle playback')) return
				// `timer_run_state` distinguishes paused from idle, which `is_playing` could not.
				if (self.state.controlCenter?.timer_run_state === 'running') {
					self.sendCommand('pause_session')
				} else {
					self.sendCommand('start_session')
				}
			},
		},
		start_session: {
			name: 'Start / Resume Session',
			options: [],
			callback: async () => {
				// From idle this names the first session, so Play actually starts the show.
				const built = buildStartSession(self.state)
				...
				self.sendCommand('start_session', built.payload)
```

```ts
// src/payloads.ts:366-382
 * Bare `start_session` acts on the current session, and vc146 rejects it outright when
 * there is none — `INVALID_COMMAND`, "No active session to start". Naming the first
 * session instead makes one command load *and* start it, which is what a Play button
 * should do from an idle display. Verified on firmware 1.1.2.27: idle -> running in a
 * single command.
 */
export function buildStartSession(state: ProtocolState): Built<CommandPayloads['start_session']> {
	if (!isIdle(state)) return { ok: true, payload: {} }
	const first = firstSessionId(state)
	...
	return { ok: true, payload: { session_id: first } }
}
```

```markdown
// companion/HELP.md:43
- **Toggle Playback** — Pauses a running timer, starts a paused or idle one.
```

**Confirm by:** open [`src/actions.ts:88-92`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L88-L92): the toggle sends `start_session` with no payload. Compare it with "Start / Resume Session" at [`src/actions.ts:98-105`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L98-L105) and the comment at [`src/payloads.ts:366-373`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/payloads.ts#L366-L373).

**Fix:** make the toggle build its start command the same way "Start / Resume Session" does, and add a test for toggling from idle.

```ts
} else {
	const built = buildStartSession(self.state)
	if (!built.ok) {
		self.log('debug', `Toggle playback: ${built.reason}; nothing sent`)
		return
	}
	self.sendCommand('start_session', built.payload)
}
```

### H5: The Node type definitions are for Node 25, but the module and the API 2.1 template use Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`package.json:36`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/package.json#L36)

**What goes wrong:** The module runs on Node 26 (manifest `runtime.type` is `node26`, as in the API 2.1 template), but its TypeScript type definitions are for Node 25. Type-checking then uses a different Node API surface than the one Companion runs, and the dependency no longer matches the template, which makes later troubleshooting harder.

**Why it happens:** Moving a module to another Node version means changing every place the version is named: the manifest runtime, `engines.node`, `@types/node`, the TypeScript preset and the CI workflows. These places still name a different Node version than the API 2.1 template.

**Evidence:**

```text
package.json devDependencies @types/node '^25.9.3' -> '^26.6.4'
```

**Confirm by:** open each file above and compare it with the template's copy.

**Fix:** update every place to Node 26, as the template does:

- [ ] [`package.json:36`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/package.json#L36): `"@types/node": "^26.6.4"` in `devDependencies`

## 🟡 Medium

### M1: `.github/workflows/node.yaml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml`

**What goes wrong:** The template's standard Node CI workflow doesn't run on pushes and pull requests.

**Why it happens:** Validator: `.github/workflows/node.yaml`: Required file is missing (tracked by the template).

**Fix:** copy the template's `.github/workflows/node.yaml`.

### M2: `.github/workflows/release.yaml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml`

**What goes wrong:** The template's release workflow doesn't run when a version tag is pushed.

**Why it happens:** Validator: `.github/workflows/release.yaml`: Required file is missing (tracked by the template).

**Fix:** copy the template's `.github/workflows/release.yaml`.

### M3: Manual Target IP and Target Port fields do not follow the discovered-display choice

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:222-238`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/main.ts#L222-L238)

**What goes wrong:** In the connection settings, "Target IP (manual)" and "Target Port (manual)" should appear only when "Discovered CueTime Displays" is set to Manual. Instead they ignore that dropdown (see [A3](#-assumptions-to-confirm)): either they always show, so a user can type an IP that is silently ignored while a discovered display is selected, or they never show, so a user without mDNS can't enter an address at all.

**Why it happens:** Both visibility expressions use `$(cuetime-display:cuetime-display)`, which refers to a variable of a connection labelled "cuetime-display", not to the config field. The base typings (`input.d.ts:35`) say a field of the same form is read with `$(options:<field_id>)`.

**Fix:** point both expressions at the config field, then check in Companion that the fields hide when a discovered display is selected.

```ts
isVisibleExpression: '$(options:cuetime-display) == null',
```

### M4: Blackout Mode Active feedback overrides the button style even when blackout is off

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:77-97`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/feedbacks.ts#L77-L97)

**What goes wrong:** A user adds the "Blackout Mode Active" feedback to a button they styled themselves, for example a blue "BLACKOUT" button. With blackout off, the button is still forced to a black background, white text and the bar-eye icon, so their own style never shows. Users also can't pick the "active" colour, as they can with every other on/off feedback in the module.

**Why it happens:** The feedback is an advanced feedback that returns a full style whether blackout is on or off, instead of a boolean feedback that only applies its style when true. API 2.1 discourages new advanced feedbacks in favour of boolean and value feedbacks.

**Fix:** make it a boolean feedback that returns whether blackout is active, with the red "eye" look as its default style, and leave the off look to the button or preset style (the Blackout preset already uses the bar-eye icon on black). This is a first release, so no upgrade script is needed.

```ts
is_blackout: {
	name: 'Blackout Mode Active',
	type: 'boolean',
	defaultStyle: { bgcolor: combineRgb(255, 0, 0), color: combineRgb(255, 255, 255), png64: icon_eye },
	options: [],
	callback: () => checkIsBlackout(self.state),
},
```

### M5: Action and feedback options are untyped, so option id typos are not caught at build time

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:22-27`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L22-L27)

**What goes wrong:** Users see no effect today. If a later edit misspells an option id (for example `event.options.secconds`), the build still passes and the action silently sends nothing.

**Why it happens:** The module's type declaration only describes the connection config, so action and feedback options fall back to a generic "any key, any value" type. Action callbacks read options through a hand-written `ActionEvent = { options: Record<string, any> }`, and feedback callbacks coerce values (`Number(feedback.options.bar_color ?? 0)`).

**Fix:** declare the `actions` and `feedbacks` option schemas in the module's `ModuleInstanceTypes` (for example `add_time: { options: { seconds: number } }`), drop the `ActionEvent` alias so callbacks get typed options, and remove the `Number(...)`/`String(...)` coercions the schema makes unnecessary.

## 🟢 Low

### L1: A new connection with no address shows Connection Failure and logs an error on every retry

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:75-85`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/main.ts#L75-L85), [`src/main.ts:99-122`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/main.ts#L99-L122)

**What goes wrong:** A user adds the connection and hasn't yet picked a discovered display or typed an IP. The status shows Connection Failure "Invalid URL: ws://:8081" instead of a configuration hint, and the log fills with "WebSocket error: Invalid URL: ws://:8081" every 1 to 30 seconds until an address is saved. Nothing is broken, but the message points at a network problem when the real issue is a missing setting.

**Why it happens:** Startup and every settings save always start a connection attempt, even when no address is set. With an empty host the WebSocket library throws, and the error handler schedules another attempt that fails the same way.

**Fix:** in `connect()`, check the resolved host first; if it is empty, stop any existing client, report a configuration problem and return.

```ts
if (!host) {
	this.client?.stop()
	this.client = null
	this.updateStatus(InstanceStatus.BadConfig, 'Select a discovered display or enter an IP address')
	return
}
```

### L2: Variables typed into free-text action fields are sent as literal text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:178-221`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L178-L221), [`src/actions.ts:459-464`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L459-L464), [`src/actions.ts:562-567`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L562-L567), [`src/actions.ts:665-671`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L665-L671)

**What goes wrong:** A user types `Next up: $(cuetime:next_session_name)` into "Show Message" > "Message text" (or into "Add Session" > "Session name" / "Presenter name"). The display shows the literal `$(cuetime:next_session_name)` instead of the session name. It only works if the user knows to switch the field to expression mode.

**Why it happens:** None of the text fields set `useVariables: true`, which is what tells Companion to replace `$(…)` variables in normal (non-expression) text before the action runs.

**Fix:** add `useVariables: true` to the user-facing text fields: the message text/content fields of "Show Message", "Add Message" and "Update Message", and the name, presenter name and notes fields of "Add Session" and "Update Session".

### L3: Every preset sits in its own section, so the preset list is long and ungrouped

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:521-542`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/presets.ts#L521-L542)

**What goes wrong:** In the Presets tab users get 20 separate sections with one button each ("Navigate to Next Session", "Pause Timer", …) instead of a few groups such as Transport, Time, Sessions, Messages and Effects, which HELP.md already describes.

**Why it happens:** The preset structure is generated with one section per preset id.

**Fix:** build the section list by hand with sections that match HELP.md (Navigation, Timer Control, Time Display, Session Info, Message, Effects), each listing its preset ids. Every preset id must still appear in one section.

### L4: Enable, Disable and Toggle dropdowns can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:580-590`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L580-L590), [`src/actions.ts:603-613`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L603-L613), [`src/actions.ts:629-639`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L629-L639), [`src/actions.ts:746-755`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/e2b23561eb9c902d9c90d731041f5bfa72a7c050/src/actions.ts#L746-L755)

**What goes wrong:** In the Blackout, Set Glow, Set Flash and Set Time-is-Up Display actions, users can flip the on/off choice into expression mode. If the expression produces anything other than the exact choice ids (for example `1` instead of `true`), Companion skips the action.

**Why it happens:** The dropdowns don't set `disableAutoExpression: true`, which the API 2.x guidance recommends for on/off/toggle choices.

**Fix:** add `disableAutoExpression: true` to those four dropdowns. This is a first release, so no stored expressions can break.

## 📝 Additional Notes

- `tsconfig.build.json` extends `./tsconfig.json` instead of the template's `@companion-module/tools/tsconfig/node26/recommended.json` (and excludes tests and `src/protocol/fixtures.ts`). Fine as long as the module builds — no change required.
- `tsconfig.json` does not extend `./tsconfig.build.json` as the template does; it defines its own full `compilerOptions` (ES2025, nodenext, strict, outDir `./dist`, rootDir `./src`). Fine as long as the module builds — no change required.
