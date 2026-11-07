# Review: sennheiser-evolutionwireless v2.0.0

| Field | Value |
| --- | --- |
| **Module** | [bitfocus/companion-module-sennheiser-evolutionwireless](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless) |
| **Scope** | `tag` |
| **Version** | `v2.0.0` @ [`4ab0529`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/commit/4ab05292d9a8596054b5273588babcc687668a57) |
| **Release** | New module — never published |
| **API** | 1 (base 1.11.0, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion passes text-field (`textinput`) config values to the module as text, including the Target Port default `'53212'`, and never turns them into numbers | `ModuleConfig.port: string`, the field's `type: 'textinput'` with `default: '53212'`, and the base 1.11.0 typing `default?: string`; Companion's host code wasn't checked, and a hand-edited or imported config holding a numeric port wasn't ruled out | [M1](#m1-disabling-or-deleting-the-connection-doesnt-close-the-udp-socket-or-stop-the-60-second-push-timer) |
| A2 | Companion's shared UDP socket delivers every packet that arrives on a port to every connection that joined that port, whatever the sender, and keeps delivering to a joined socket until the module closes it or its process stops | the module's own comment at [`src/api.ts:58`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L58), and base 1.11.0, which hands incoming packets to every socket still in its handler list and removes a socket only on `close()` or a fatal error; Companion's host side wasn't checked | [H1](#h1-saving-the-connection-settings-doesnt-refresh-the-actions-and-variables-and-leaves-the-old-udp-socket-running), [M1](#m1-disabling-or-deleting-the-connection-doesnt-close-the-udp-socket-or-stop-the-60-second-push-timer), [M4](#m4-the-log-fills-with-ignoring-udp-message-from-unknown-source-when-several-ew-units-share-the-port) |
| A3 | Companion starts a newly added connection (`init()`) before the user's first Save and applies that Save through `configUpdated()`, so the Device Type picked in the very first Save already misses the refresh | the general Companion 3/4 connection lifecycle (base `_handleInit` / `_handleConfigUpdateAndLabel`); not checked in Companion's host code | [H1](#h1-saving-the-connection-settings-doesnt-refresh-the-actions-and-variables-and-leaves-the-old-udp-socket-running) |
| A4 | v2.0.0 is the module's first release for current Companion: the module store has no approved version, and the repo's 2022 tags v1.0.0–v1.0.2 are Companion 2.x bundled-module releases that don't count as a baseline | the Bitfocus versions API (no approved version); v1.0.2 uses the Companion 2.x layout (`api_version` in package.json, no `companion/manifest.json`) and already has the same Mute Toggle logic and no feedbacks. If an earlier store release exists, H2 becomes pre-existing and H3 loses the first-release rule | [H2](#h2-the-mute-actions-toggle-option-never-unmutes-an-em-receiver), [H3](#h3-buttons-cant-show-the-devices-state-because-the-module-has-no-feedbacks) |
| A5 | When an action callback throws, Companion logs the error for that connection and doesn't crash the module | base 1.11.0 awaits the action callback inside its IPC handler and sends the rejection back to Companion; how Companion shows it wasn't checked | [M2](#m2-pressing-a-button-while-not-connected-logs-a-raw-typeerror-instead-of-a-clear-message) |
| A6 | Companion treats a text port number (`'53212'`) in a shared-socket join request the same as the number 53212 | base 1.11.0 passes the `bind()` argument through to Companion unchanged; Companion's host code wasn't available | [L1](#l1-the-udp-socket-is-opened-with-a-text-port-and-the-untyped-socket-field-hides-it) |
| A7 | The module's v1.0.x releases ran in Companion 2.x, and Companion 3+ keeps the 2.x upgrade-script count when it imports such a connection, so an upgrade script added later at position 0 would be skipped for those connections | the repo's v1.0.0–v1.0.2 tags with `src/upgrade/MuteToggleUpgrade.ts`; Companion's 2.x import wasn't checked | [L4](#l4-the-companion-2x-mute-upgrade-script-was-dropped-so-old-mute-buttons-can-break) |

## 📋 Issues

### Blocking

- [ ] [C1: Windows line endings can slip into commits: `.gitattributes` is missing](#c1-windows-line-endings-can-slip-into-commits-gitattributes-is-missing)
- [ ] [C2: The packaged module can be committed by accident: `.gitignore` is missing template entries](#c2-the-packaged-module-can-be-committed-by-accident-gitignore-is-missing-template-entries)
- [ ] [C3: Lint and formatting don't run before each commit: `.husky/pre-commit` is missing](#c3-lint-and-formatting-dont-run-before-each-commit-huskypre-commit-is-missing)
- [ ] [C4: Installs don't use the template's safe Yarn settings: `.yarnrc.yml` is missing](#c4-installs-dont-use-the-templates-safe-yarn-settings-yarnrcyml-is-missing)
- [ ] [C5: The required Node and Yarn versions aren't declared: `engines` is missing from `package.json`](#c5-the-required-node-and-yarn-versions-arent-declared-engines-is-missing-from-packagejson)
- [ ] [C6: Builds don't pin a Yarn version: `packageManager` is missing from `package.json`](#c6-builds-dont-pin-a-yarn-version-packagemanager-is-missing-from-packagejson)
- [ ] [C7: Node type definitions aren't pinned to Node 22: the `@types/node` devDependency is missing](#c7-node-type-definitions-arent-pinned-to-node-22-the-typesnode-devdependency-is-missing)
- [ ] [C8: The module still targets Node 18, while the template runs on Node 22](#c8-the-module-still-targets-node-18-while-the-template-runs-on-node-22)
- [ ] [H1: Saving the connection settings doesn't refresh the actions and variables, and leaves the old UDP socket running](#h1-saving-the-connection-settings-doesnt-refresh-the-actions-and-variables-and-leaves-the-old-udp-socket-running)
- [ ] [H2: The Mute action's Toggle option never unmutes an EM receiver](#h2-the-mute-actions-toggle-option-never-unmutes-an-em-receiver)
- [ ] [H3: Buttons can't show the device's state because the module has no feedbacks](#h3-buttons-cant-show-the-devices-state-because-the-module-has-no-feedbacks)
- [ ] [H4: The CI workflow differs from the template's](#h4-the-ci-workflow-differs-from-the-templates)

### Non-blocking

- [ ] [M1: Disabling or deleting the connection doesn't close the UDP socket or stop the 60-second Push timer](#m1-disabling-or-deleting-the-connection-doesnt-close-the-udp-socket-or-stop-the-60-second-push-timer)
- [ ] [M2: Pressing a button while not connected logs a raw TypeError instead of a clear message](#m2-pressing-a-button-while-not-connected-logs-a-raw-typeerror-instead-of-a-clear-message)
- [ ] [M3: If the UDP socket fails, the module process crashes within 60 seconds](#m3-if-the-udp-socket-fails-the-module-process-crashes-within-60-seconds)
- [ ] [M4: The log fills with "Ignoring UDP message from unknown source" when several EW units share the port](#m4-the-log-fills-with-ignoring-udp-message-from-unknown-source-when-several-ew-units-share-the-port)
- [ ] [L1: The UDP socket is opened with a text port, and the untyped socket field hides it](#l1-the-udp-socket-is-opened-with-a-text-port-and-the-untyped-socket-field-hides-it)
- [ ] [L2: Status and variable updates are sent to Companion on every packet, even when nothing changed](#l2-status-and-variable-updates-are-sent-to-companion-on-every-packet-even-when-nothing-changed)
- [ ] [L3: The Firmware Revision variable is missing for EM receivers](#l3-the-firmware-revision-variable-is-missing-for-em-receivers)
- [ ] [L4: The Companion 2.x Mute upgrade script was dropped, so old Mute buttons can break](#l4-the-companion-2x-mute-upgrade-script-was-dropped-so-old-mute-buttons-can-break)
- [ ] [L5: The help page leaves out most variables and the Verbose logging setting](#l5-the-help-page-leaves-out-most-variables-and-the-verbose-logging-setting)
- [ ] [N1: A socket listener that never fires writes to the console](#n1-a-socket-listener-that-never-fires-writes-to-the-console)
- [ ] [N2: No presets, so every button has to be built by hand](#n2-no-presets-so-every-button-has-to-be-built-by-hand)
- [ ] [N3: Some labels are lowercase ("device type", "up"/"down")](#n3-some-labels-are-lowercase-device-type-updown)
- [ ] [NR1: Plan the move off `@companion-module/base` 1.11](#nr1-plan-the-move-off-companion-modulebase-111)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Windows line endings can slip into commits: `.gitattributes` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor working on Windows can commit files with CRLF line endings. Those files then show up as whole-file changes in diffs and can trip the Prettier and lint checks.

**Why it happens:** The template ships a `.gitattributes` that tells git to store text files with LF line endings. The module doesn't have the file.

**Evidence:**

```text
Expected (template): .gitattributes
* text=auto eol=lf
Found: file missing
```

**Fix:** add `.gitattributes` with the template's content.

```text
* text=auto eol=lf
```

### C2: The packaged module can be committed by accident: `.gitignore` is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/.gitignore)

**What goes wrong:** `yarn package` writes `sennheiser-evolutionwireless-2.0.0.tgz` to the repo root, and git lists it as a new file to commit (it did during this review's build). A local `.yarn/` folder (Yarn 4's cache) and VS Code's `.vscode/` settings aren't ignored either.

**Why it happens:** The template's `.gitignore` has `/*.tgz`, `/.yarn` and `/.vscode`. The module's file has `/pkg.tgz` and `.yarn/install-state.gz` in place of the first two, which don't match what the build and Yarn 4 produce, and has no `.vscode` entry.

**Evidence:**

```text
Missing template .gitignore entries: /*.tgz, /.yarn, /.vscode
Found instead: /pkg.tgz, .yarn/install-state.gz
```

**Fix:** copy the template's `.gitignore`: replace `/pkg.tgz` with `/*.tgz` and `.yarn/install-state.gz` with `/.yarn`, and add `/.vscode`.

### C3: Lint and formatting don't run before each commit: `.husky/pre-commit` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Code that fails lint or isn't formatted can be committed without any warning. The problems only show up later, in CI.

**Why it happens:** `package.json` already installs husky (`"postinstall": "husky"`) and has a `lint-staged` block, but the hook file that runs lint-staged, `.husky/pre-commit`, isn't in the repo, so git never calls it.

**Evidence:**

```text
Expected (template): .husky/pre-commit
lint-staged
Found: file missing
```

**Fix:** add `.husky/pre-commit` with the template's content.

```text
lint-staged
```

### C4: Installs don't use the template's safe Yarn settings: `.yarnrc.yml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Once the module moves to Yarn 4 ([C6](#c6-builds-dont-pin-a-yarn-version-packagemanager-is-missing-from-packagejson)), installs without this file use Yarn's defaults: Plug'n'Play instead of the `node_modules` folder the template uses, dependency install scripts allowed to run, and newly published package versions installed straight away, with no 3-day wait that guards against a compromised release.

**Why it happens:** The template's `.yarnrc.yml` sets those four options. The module has no `.yarnrc.yml`.

**Evidence:**

```yaml
# Expected (companion-module-template-ts main @ e0d42b7): .yarnrc.yml
enableScripts: false
nodeLinker: node-modules
npmMinimalAgeGate: 3d
npmPreapprovedPackages: ["@companion-module/*"]
# Found: file missing
```

**Fix:** copy `.yarnrc.yml` from the template.

### C5: The required Node and Yarn versions aren't declared: `engines` is missing from `package.json`

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/package.json)

**What goes wrong:** Nothing tells a contributor, or Yarn, which Node and Yarn versions the module is built for, so it can be installed and built on an unsupported version without a warning.

**Why it happens:** The template's `package.json` has an `engines` field. The module's doesn't.

**Evidence:**

```json
// Expected (template)
"engines": { "node": "^22.20", "yarn": "^4" }
// Found: no "engines" field
```

**Fix:** add the template's `engines` field to `package.json`.

### C6: Builds don't pin a Yarn version: `packageManager` is missing from `package.json`

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/package.json)

**What goes wrong:** Corepack, which the CI workflow enables, can't tell which Yarn to use, so every machine builds with whatever Yarn it has. The committed `yarn.lock` is a Yarn Classic (v1) lockfile, while the template builds with Yarn 4.12.0.

**Why it happens:** The template's `package.json` names the Yarn version in `packageManager`. The module's doesn't.

**Evidence:**

```json
// Expected (template)
"packageManager": "yarn@4.12.0"
// Found: no "packageManager" field; yarn.lock starts with "# yarn lockfile v1"
```

**Fix:** add `"packageManager": "yarn@4.12.0"`, then run `yarn install` with Yarn 4 (together with the `.yarnrc.yml` from [C4](#c4-installs-dont-use-the-templates-safe-yarn-settings-yarnrcyml-is-missing)) and commit the regenerated `yarn.lock`.

### C7: Node type definitions aren't pinned to Node 22: the `@types/node` devDependency is missing

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/package.json)

**What goes wrong:** The module doesn't choose the Node.js type definitions that TypeScript checks it against. Today a dependency happens to pull in `@types/node` 22.7.5, and a dependency update can swap that for another version without notice, changing the types of Node APIs the module uses (such as `NodeJS.Timeout` in [`src/index.ts:18`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/index.ts#L18)).

**Why it happens:** The template lists `@types/node` in `devDependencies`. The module doesn't.

**Evidence:**

```json
// Expected (template), devDependencies
"@types/node": "^22.19.3"
// Found: missing
```

**Fix:** add `"@types/node": "^22.19.3"` to `devDependencies`.

### C8: The module still targets Node 18, while the template runs on Node 22

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:25`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/companion/manifest.json#L25)

**What goes wrong:** Companion runs this module on Node 18, which is past its end of life, while the API 1 template runs on Node 22. CI also builds and lints on Node 18, so it doesn't check the module on the Node version the template uses.

**Why it happens:** The Node version is named in several places, and all of them still say 18.

**Evidence:**

```text
companion/manifest.json:25              runtime.type "node18"                                         (template "node22")
tsconfig.build.json:2                   extends "@companion-module/tools/tsconfig/node18/recommended" (template node22)
.github/workflows/node.yaml:21          - name: Use Node.js 18.x                                      (template 22.x)
.github/workflows/node.yaml:25          node-version: 18.x                                            (template 22.x)
.github/workflows/node.yaml:55, 58      same two lines in the commented-out test job
```

**Fix:** change every place to Node 22.

- [ ] [`companion/manifest.json`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/companion/manifest.json#L25): `"runtime": { "type": "node22" }`
- [ ] [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/tsconfig.build.json#L2): `"extends": "@companion-module/tools/tsconfig/node22/recommended"`
- [ ] [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/.github/workflows/node.yaml#L21-L25): `- name: Use Node.js 22.x` (line 21) and `node-version: 22.x` (line 25), and in the commented-out `test:` job too (lines 55 and 58)

`engines.node` and `@types/node` are missing entirely; they're covered by [C5](#c5-the-required-node-and-yarn-versions-arent-declared-engines-is-missing-from-packagejson) and [C7](#c7-node-type-definitions-arent-pinned-to-node-22-the-typesnode-devdependency-is-missing).

## 🟠 High

### H1: Saving the connection settings doesn't refresh the actions and variables, and leaves the old UDP socket running

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:43-47`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/index.ts#L43-L47)

**What goes wrong:** Two things go wrong when a user changes a connection setting and clicks Save:

- Changing Device Type from "SR (Transmitter, IEM)" to "EM (Receiver, Mic)", or back, doesn't change the actions or variables. An EM user keeps seeing the SR-only actions (Nudge Sensitivity, Sensitivity, Equalizer, Mode) and SR variables, and the EM actions (Nudge AfOut, Level) don't appear until Companion restarts or the connection is disabled and enabled again. This happens today.
- Every Save opens another UDP socket next to the old one, and the old one keeps receiving. After 3 saves, each packet from the unit is processed 4 times (repeated variable updates, and repeated log lines with Verbose logging on). If the new settings are invalid (Target IP cleared, a bad port), the old socket stays open and the old 60-second Push timer keeps running.

**Why it happens:** `configUpdated()` stores the new settings and calls `initConnection()` again, and nothing else. It doesn't rebuild the action and variable lists, which `init()` built from the Device Type in place at start-up. `initConnection()` then creates a new socket over the old one without closing it first. The base package keeps every joined socket in its list until `close()` is called, so the old socket keeps receiving packets and running its message handler. The old Push timer is only cleared when a new socket reaches "listening", so with invalid new settings it's never cleared.

**Evidence:**

```ts
// src/index.ts:29-47
	async init(config: ModuleConfig): Promise<void> {
		this.config = config

		this.updateActions() // export actions
		this.updateFeedbacks() // export feedbacks
		this.updateVariableDefinitions() // export variable definitions

		this.initConnection()
	}
	// When module gets deleted
	async destroy(): Promise<void> {
		this.log('debug', 'destroy')
	}

	async configUpdated(config: ModuleConfig): Promise<void> {
		this.config = config

		this.initConnection()
	}
```

```ts
// src/actions.ts:112
	if (self.config.deviceType === 'SR') {
// src/actions.ts:261
	} else if (self.config.deviceType === 'EM') {
// src/variables.ts:11
	if (self.config.deviceType === 'SR') {
```

```ts
// src/api.ts:44-45
			self._socket = self.createSharedUdpSocket('udp4', (msg, rinfo) => checkMessage(self, msg, rinfo))
			self._socket.bind(self.config.port)
// src/api.ts:89-95
	if (self._pushInterval) {
		clearInterval(self._pushInterval)
	}

	self._pushInterval = setInterval(() => {
		sendCommand(self, `Push 60 ${self.config.updateRate} 3`)
	}, 60000)
```

```js
// node_modules/@companion-module/base/dist/module-api/shared-udp-socket.js:57-60 (base 1.11.0)
            .then((handleId) => {
            this.#state = { portNumber: port, handleId };
            this.#moduleUdpSockets.set(handleId, this);
            this.emit('listening');
```

**Confirm by:** open [`src/index.ts:43-47`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/index.ts#L43-L47). `configUpdated()` calls neither `updateActions()` nor `updateVariableDefinitions()`. Then check that [`src/api.ts:20-71`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L20-L71) never closes `self._socket` or clears `self._pushInterval` before line 44 replaces `self._socket`.

**Fix:** in `configUpdated()`, close the old connection first, then rebuild the definitions and reconnect. A small helper can do the cleanup for `configUpdated()` and for `destroy()` ([M1](#m1-disabling-or-deleting-the-connection-doesnt-close-the-udp-socket-or-stop-the-60-second-push-timer)). The `try`/`catch` is needed because the base's `close()` throws "Socket is not open" if the bind hasn't finished.

```ts
// src/api.ts
export function closeConnection(self: evolutionInstance): void {
	if (self._pushInterval) {
		clearInterval(self._pushInterval)
		self._pushInterval = undefined
	}
	if (self._socket) {
		self._socket.removeAllListeners()
		try {
			self._socket.close()
		} catch {
			// not bound yet
		}
		self._socket = undefined
	}
}

// src/index.ts
	async configUpdated(config: ModuleConfig): Promise<void> {
		this.config = config
		closeConnection(this)
		this.updateActions()
		this.updateVariableDefinitions()
		this.initConnection()
	}
```

### H2: The Mute action's Toggle option never unmutes an EM receiver

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:31-36`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/actions.ts#L31-L36)

**What goes wrong:** An EM (Receiver, Mic) user adds the Mute action to a button and leaves "Mute state" at its default, Toggle. The first press sends `Mute 1`, and every later press sends `Mute 1` again, so the button can never unmute the receiver. The help page lists Mute as a shared action ("Set the AF Mute for EM or the RF Mute for SR units"). SR users aren't affected, and the explicit Mute and Unmute choices still work on EM.

**Why it happens:** Toggle sends the opposite of the mute state the module last read from the unit. That state is only read from the SR unit's `States` reply. The EM branch of the reply parser is an empty `//todo`, so for EM the stored state stays "unmuted" forever and Toggle always sends `Mute 1`.

**Evidence:**

```ts
// src/actions.ts:12-41
			{
				type: 'dropdown',
				label: 'Mute state',
				id: 'mute',
				default: 'toggle',
...
			} else if (args.options.mute === 'toggle') {
				if (self._muteState) {
					wantedState = '0'
				} else {
					wantedState = '1'
				}
			} else {
				throw new Error(`Unrecognized value for action mute: ${args.options.mute}`)
			}

			sendCommand(self, `Mute ${wantedState}`)
```

```ts
// src/index.ts:12, 23
	public _muteState: boolean
		this._muteState = false
// src/api.ts:156-166
		if (self.config.deviceType === 'SR') {
			if (line.startsWith('AF')) {
...
			} else if (line.startsWith('States')) {
				variableObj['rf_mute'] = lineSplit[1] === '1' ? 'on' : 'off'
				variableObj['rf_mute_flags'] = lineSplit[2]

				self._muteState = lineSplit[1] === '1'
// src/api.ts:191-193
		} else if (self.config.deviceType === 'EM') {
			//todo
		}
```

```markdown
<!-- companion/HELP.md:20 -->
| Mute            | Set the AF Mute for EM or the RF Mute for SR units |
```

`grep -rn _muteState src` returns only `src/index.ts:12`, `src/index.ts:23`, `src/api.ts:166` and `src/actions.ts:32`. Nothing else writes the field.

**Confirm by:** open [`src/api.ts:156-193`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L156-L193). The only write to `_muteState` ([`src/api.ts:166`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L166)) is inside the `deviceType === 'SR'` branch, and the EM branch at lines 191-193 is `//todo`.

**Fix:** read the EM unit's mute state into `_muteState` in the EM branch of the reply parser. Until that exists, either hide the Toggle choice for EM, or flip `_muteState` after each Mute send so that Toggle alternates.

### H3: Buttons can't show the device's state because the module has no feedbacks

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:4-8`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/feedbacks.ts#L4-L8)

**What goes wrong:** A user who wants a button that turns red while the SR transmitter is RF-muted, or lights up on AF Peak, finds nothing under Feedbacks for this connection. Buttons can send commands but can't show the device's state, even though the module already reads RF mute, AF peak, Mono/Stereo mode and Equalizer on/off from the unit. This is the module's first release, and a first release needs feedbacks for the device's state.

**Why it happens:** The module registers an empty list of feedback definitions, and nothing ever asks Companion to re-check feedbacks (`checkFeedbacks()`).

**Evidence:**

```ts
// src/feedbacks.ts:1-8
import { CompanionFeedbackDefinitions } from '@companion-module/base'
import type { evolutionInstance } from './index.js'

export function UpdateFeedbacks(self: evolutionInstance): void {
	const feedbacks: CompanionFeedbackDefinitions = {}

	self.setFeedbackDefinitions(feedbacks)
}
```

```ts
// src/api.ts:156-174
		if (self.config.deviceType === 'SR') {
			if (line.startsWith('AF')) {
				variableObj['af_peak_1'] = lineSplit[1]
				...
			} else if (line.startsWith('States')) {
				variableObj['rf_mute'] = lineSplit[1] === '1' ? 'on' : 'off'
				variableObj['rf_mute_flags'] = lineSplit[2]

				self._muteState = lineSplit[1] === '1'
			...
			} else if (line.startsWith('Mode')) {
				self._deviceConfig.mode = lineSplit[1].trim() === '1' ? 'stereo' : 'mono'
```

```text
$ grep -rn -i "preset\|feedback\|checkFeedbacks" src   (only hits)
src/feedbacks.ts:1, 4, 5, 7
src/upgrades.ts:13:	// 		updatedFeedbacks: [],
src/index.ts:6, 33, 58, 59
```

**Confirm by:** open [`src/feedbacks.ts:4-8`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/feedbacks.ts#L4-L8) and check that `feedbacks` is `{}`. `grep -rn checkFeedbacks src` returns nothing, and [`src/api.ts:156-190`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L156-L190) shows the RF mute, AF, Mode and Equalizer state the module already parses.

**Fix:** add boolean feedbacks for the device state the module already parses, each with a sensible `defaultStyle`, and call `self.checkFeedbacks(...)` in `processData` after those values change. For example: "RF Mute is on" (`_muteState`), "AF Peak" (`af_peak` from the `Msg` line), "Mode is Stereo/Mono" (`_deviceConfig.mode`) and "Equalizer enabled" (`_deviceConfig.equalizer.enabled`).

### H4: The CI workflow differs from the template's

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/.github/workflows/node.yaml#L18-L23)

**What goes wrong:** The module's CI workflow no longer matches the template's. Updates to the template's workflow can't be copied over cleanly, and anyone troubleshooting a CI run has to work out which differences are deliberate.

**Why it happens:** Several steps were changed by hand. The Node version lines are covered by [C8](#c8-the-module-still-targets-node-18-while-the-template-runs-on-node-22) and left out here.

**Evidence:**

- [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/.github/workflows/node.yaml#L18): `- uses: actions/checkout@v7` (template `@v4`)
- [`.github/workflows/node.yaml:19-20`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/.github/workflows/node.yaml#L19-L20): adds `with: persist-credentials: false`
- [`.github/workflows/node.yaml:23`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/.github/workflows/node.yaml#L23): `uses: actions/setup-node@v6` (template `@v4`)
- The template's `Prepare Environment (For template repository)` step, guarded by `if: ${{ contains(github.repository, 'companion-module-template-') }}`, was removed.

**Confirm by:** diff the file against `companion-module-template-ts-v1/.github/workflows/node.yaml` @ `42609d8`.

**Fix:** copy the template's `node.yaml`, with Node 22 as in [C8](#c8-the-module-still-targets-node-18-while-the-template-runs-on-node-22). The commented-out `test:` job differs from the template too, but that's comment-only and not part of this finding.

## 🟡 Medium

### M1: Disabling or deleting the connection doesn't close the UDP socket or stop the 60-second Push timer

- **Source:** 🔎 protocol reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:39-41`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/index.ts#L39-L41)

**What goes wrong:** When a user disables or deletes the connection, the module doesn't leave the shared UDP port or stop the 60-second timer that re-sends `Push 60 …` to the unit. It relies on Companion stopping its process afterwards.

**Why it happens:** `destroy()` is where a module releases what it started. This one only writes a debug log: there is no `clearInterval` for the Push timer and no `close()` for the socket.

**Fix:** call the `closeConnection()` helper from [H1](#h1-saving-the-connection-settings-doesnt-refresh-the-actions-and-variables-and-leaves-the-old-udp-socket-running) in `destroy()`.

```ts
	async destroy(): Promise<void> {
		closeConnection(this)
	}
```

### M2: Pressing a button while not connected logs a raw TypeError instead of a clear message

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:73-79`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L73-L79)

**What goes wrong:** Pressing a button with any of the module's actions (Mute, Name, Frequency, Nudge frequency, …) while the connection is in Bad Configuration logs the raw error "Cannot read properties of undefined (reading 'send')" instead of a clear "not connected" message. That happens with an empty Target IP or a bad port. Pressing while the socket is still opening logs "Socket is not open".

**Why it happens:** `sendCommand()` uses the socket without checking that one exists and has finished opening. The socket field is untyped (`any`), so TypeScript can't flag the missing case.

**Fix:** in `sendCommand()`, log a warning and return when there is no open socket (for example, set a flag in the socket's `listening` handler), and wrap the `send()` in `try`/`catch` so a failure is logged with a readable message.

### M3: If the UDP socket fails, the module process crashes within 60 seconds

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:47-50`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L47-L50), [`src/api.ts:93-95`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L93-L95)

**What goes wrong:** If Companion reports a fatal error on the connection's UDP socket after it was working, the status correctly turns to Connection Failure, but the 60-second Push timer keeps running. On its next tick it sends on the dead socket, the send throws inside the timer, and the connection's process crashes; Companion then restarts it.

**Why it happens:** The socket's `error` handler only updates the status and logs. It doesn't stop the Push timer. The base package's `send()` throws "Socket is not open" straight away on a failed socket, and nothing catches an error thrown inside the timer (the base installs no handler for uncaught errors).

**Fix:** stop the Push timer in the `error` handler, and wrap the timer's send (or `sendCommand()` itself) in `try`/`catch` that sets Connection Failure.

### M4: The log fills with "Ignoring UDP message from unknown source" when several EW units share the port

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:11-14`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L11-L14)

**What goes wrong:** Take a rack of 4 IEM transmitters, each with its own connection, all on Target Port 53212 with Update Rate Fast (200 ms). Every connection receives the other units' status pushes and logs an info line for each one, such as "Ignoring UDP message from unknown source: 192.168.33.87:53212". That's about 15 lines a second per connection, about 60 a second in all, even with Verbose logging off, and it buries useful log entries.

**Why it happens:** Packets from other units are expected on a shared port, and the module filters them out correctly. But it logs every ignored packet at `info` level, whatever the Verbose logging setting.

**Fix:** ignore packets from other units silently, or log them at `debug` level only when Verbose logging is on.

## 🟢 Low

### L1: The UDP socket is opened with a text port, and the untyped socket field hides it

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:45`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L45), [`src/index.ts:13-16`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/index.ts#L13-L16)

**What goes wrong:** Nothing visible is known. The socket is opened with the port as text (`'53212'`), where the base package's `bind()` expects a number, and that text is passed on to Companion unchanged. How Companion handles it is not known ([A6](#-assumptions-to-confirm)). Because the socket and device-config fields are typed `any`, TypeScript didn't catch the text port, the missing-socket case in `sendCommand()` ([M2](#m2-pressing-a-button-while-not-connected-logs-a-raw-typeerror-instead-of-a-clear-message)), or the listener for an event the socket never emits ([N1](#n1-a-socket-listener-that-never-fires-writes-to-the-console)).

**Why it happens:** `public _socket: any` and `public _deviceConfig: any` turn off type checking for everything that uses them. The base package declares `bind(port: number, ...)`.

**Fix:** type `_socket` as `SharedUdpSocket | undefined` (exported by `@companion-module/base`), give `_deviceConfig` a small interface, pass the port to `bind()` as a number, and fix whatever the compiler then reports.

### L2: Status and variable updates are sent to Companion on every packet, even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:196-200`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L196-L200)

**What goes wrong:** No direct visible effect. At Update Rate Fast, each connection sends Companion a status "OK" message and a variable update about 5 times a second, even when nothing changed or the packet held no known lines. With many units this is avoidable load on Companion. The code's own TODO says as much.

**Why it happens:** The status is set to OK whenever any value was parsed, and the base package doesn't skip repeats. The variable update is sent even when no value was parsed.

**Fix:** remember the last status and only send it when it changes, and skip `setVariableValues()` when `variableObj` is empty.

### L3: The Firmware Revision variable is missing for EM receivers

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:11-28`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/variables.ts#L11-L28)

**What goes wrong:** With Device Type "EM (Receiver, Mic)", the connection's variable list shows only Messages, Name and Frequency. Firmware Revision isn't listed, so the user can't pick it from the variable picker, even though the module fills it in from the unit's reply for both device types.

**Why it happens:** The `firmware_revision` variable is defined only inside the SR block, but the reply parser sets it for any device type ([`src/api.ts:123-125`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L123-L125)).

**Fix:** move `variables.push({ variableId: 'firmware_revision', name: 'Firmware Revision' })` above the `if (self.config.deviceType === 'SR')` block, next to `msg`, `name` and `frequency`.

### L4: The Companion 2.x Mute upgrade script was dropped, so old Mute buttons can break

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:4-16`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/upgrades.ts#L4-L16)

**What goes wrong:** The module's Companion 2.x releases (v1.0.0–v1.0.2) shipped one upgrade script, which turned the old Mute checkbox (`true`/`false`) into "mute"/"unmute". v2.0.0 ships none. A user who imports an old Companion 2.x config whose Mute buttons were never converted gets "Unrecognized value for action mute: true" when pressing them. And if Companion carries over how many upgrade scripts a 2.x connection has already run ([A7](#-assumptions-to-confirm)), those imported connections may skip the first upgrade script this module adds in future.

**Why it happens:** The 2.x script (`src/upgrade/MuteToggleUpgrade.ts` in v1.0.2) wasn't carried over into `UpgradeScripts`. The action and option ids are otherwise unchanged from 2.x, so no other migration is needed.

**Fix:** port `MuteToggleUpgrade` into `src/upgrades.ts` as the first entry, in the v1 `CompanionStaticUpgradeScript` form: for each action in `props.actions` whose `options.mute` is `true` or `false`, set it to `'mute'` or `'unmute'` and return it in `updatedActions`.

### L5: The help page leaves out most variables and the Verbose logging setting

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:5-52`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/companion/HELP.md#L5-L52)

**What goes wrong:** A user looking for the available variables in the module's help finds only Messages and the AF/RF ones. Name, Frequency, Firmware Revision, Analog Input Sensitivity, Mode and the six Equalizer variables aren't documented, and neither is the Verbose logging checkbox in the configuration table. There's also a typo: "frequecy".

**Fix:** add the missing variables (`name`, `frequency`, `firmware_revision`, `sensitivity`, `mode`, `equalizer_state`, `equalizer_low`, `equalizer_low_mid`, `equalizer_mid`, `equalizer_mid_high`, `equalizer_high`) and a Verbose logging row, and fix "frequecy".

## 💡 Nice to Have

### N1: A socket listener that never fires writes to the console

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:64-66`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L64-L66)

**What goes wrong:** No visible effect. The shared UDP socket only emits `error`, `listening`, `close` and `message`, so the `status_change` handler never runs. It also writes with `console.log` instead of the module's log.

**Why it happens:** Leftover code from the earlier socket wrapper.

**Fix:** remove the `self._socket.on('status_change', ...)` block, and the commented-out `message` handler at [`src/api.ts:58-62`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/api.ts#L58-L62).

### N2: No presets, so every button has to be built by hand

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:29-37`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/index.ts#L29-L37)

**What goes wrong:** The Presets tab for this connection is empty, so users build buttons such as "RF Mute toggle" or "Frequency up/down" themselves. Presets are optional, so this doesn't block the release.

**Fix:** add presets with `setPresetDefinitions()`, for example Mute toggle (with the RF Mute feedback from [H3](#h3-buttons-cant-show-the-devices-state-because-the-module-has-no-feedbacks)), Frequency nudge up/down and the Sensitivity steps, and call it from `init()` and `configUpdated()`.

### N3: Some labels are lowercase ("device type", "up"/"down")

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:45`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/config.ts#L45)

**What goes wrong:** The connection settings show "device type" in lowercase next to "Target IP" and "Update Rate", and the Direction dropdowns in Nudge frequency, Nudge Sensitivity and Nudge AfOut offer "up"/"down". Cosmetic only.

**Fix:** use Title Case: label `'Device Type'` in [`src/config.ts:45`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/config.ts#L45), and choice labels `'Up'`/`'Down'` in [`src/actions.ts:73-74`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/actions.ts#L73-L74), [`src/actions.ts:123-124`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/actions.ts#L123-L124) and [`src/actions.ts:272-273`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/src/actions.ts#L272-L273). Only the labels change; the ids stay the same, so saved buttons aren't affected.

## 🔮 Next Release

### NR1: Plan the move off `@companion-module/base` 1.11

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:41`](https://github.com/bitfocus/companion-module-sennheiser-evolutionwireless/blob/4ab05292d9a8596054b5273588babcc687668a57/package.json#L41)

**What goes wrong:** No visible effect today. On base 1.11 the module misses newer API features: `isVisibleExpression`, the 1.12 permissions model, auto-parsed `useVariables` fields and `secret-text` in 1.13, and the automatic config layout in 1.14.

**Fix:** in the next release, update to the latest 1.x base (the v1 template uses `~1.14.1`), or migrate to API 2.x (Companion 4.3+/5.0+, Node 22) following the Companion v1-to-v2 migration guide.

## 📝 Additional Notes

- First release: Companion's module store has no approved version of this module, so the whole module was reviewed at v2.0.0 instead of a diff. The repo's 2022 tags v1.0.0–v1.0.2 (Companion 2.x bundled-module era, 57 commits before v2.0.0) weren't used as a baseline.
