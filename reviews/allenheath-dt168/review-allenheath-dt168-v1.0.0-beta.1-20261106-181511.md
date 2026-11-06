# Review: allenheath-dt168 v1.0.0-beta.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-allenheath-dt168` |
| **Repository** | [bitfocus/companion-module-allenheath-dt168](https://github.com/bitfocus/companion-module-allenheath-dt168) |
| **Scope** | `tag` |
| **Version** | v1.0.0-beta.1 (commit [`112c9e1`](https://github.com/bitfocus/companion-module-allenheath-dt168/commit/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Compared against** | Nothing: this is the first release, so there is no published diff and the whole module was reviewed |
| **Build** | `yarn install --immutable` and `yarn package` pass (`allenheath-dt168-1.0.0-beta.1.tgz` built) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not deduplicate repeated identical `updateStatus`, `setVariableValues` and `checkAllFeedbacks` calls, so it does a little work for each one, but setting the same status again adds no log entry and changes nothing on screen | `@companion-module/base` 2.1.3 `dist/module-api/base.js:167-168` forwards every call straight to the host with no diffing; Companion's host code was not checked | [N1](#n1-every-2-second-status-poll-re-sends-all-66-variables-re-checks-every-feedback-and-re-sets-the-status-to-ok-even-when-nothing-changed) |
| A2 | When a user aborts a button's running actions, Companion 5 aborts `context.signal` for every action callback that is still pending, and it does not wait for one press's callback to finish before starting the next | the base 2.1.3 `action.d.ts` doc comment on `CompanionActionCallbackContext.signal` ("aborts when the result of this execution is no longer needed (eg the user aborted the running actions)"); how the host schedules callbacks was not checked | [M1](#m1-aborting-a-buttons-running-actions-does-not-stop-queued-gain-pad-and-phantom-changes) |
| A3 | The Bitfocus developer-portal build runs the module's own `yarn package` script, so `--prerelease` is carried into every portal build | a local `yarn package` wrote `"isPrerelease": true` into `pkg/allenheath-dt168/companion/manifest.json`; how the portal invokes `companion-module-build` was not checked (the finding holds for local builds either way) | [L2](#l2-yarn-package-always-marks-the-build-as-a-prerelease-and-packagejson-differs-from-the-template) |

## 📋 Issues

### Blocking

- [ ] [C1: `.gitignore` is missing five template entries, so lock files and debug logs can be committed](#c1-gitignore-is-missing-five-template-entries-so-lock-files-and-debug-logs-can-be-committed)
- [ ] [C2: `.prettierignore` does not match the template](#c2-prettierignore-does-not-match-the-template)
- [ ] [C3: `.yarnrc.yml` is missing the template's supply-chain protection settings](#c3-yarnrcyml-is-missing-the-templates-supply-chain-protection-settings)
- [ ] [C4: `.yarnrc.yml` adds `enableGlobalCache`, which changes how every build installs packages](#c4-yarnrcyml-adds-enableglobalcache-which-changes-how-every-build-installs-packages)
- [ ] [C5: `package.json` does not use the shared Companion Prettier config](#c5-packagejson-does-not-use-the-shared-companion-prettier-config)
- [ ] [C6: Module targets Node 22 where the API 2.1 template runs on Node 26](#c6-module-targets-node-22-where-the-api-21-template-runs-on-node-26)

### Non-blocking

- [ ] [M1: Aborting a button's running actions does not stop queued gain, pad and phantom changes](#m1-aborting-a-buttons-running-actions-does-not-stop-queued-gain-pad-and-phantom-changes)
- [ ] [M2: Module is laid out differently from the JS template (CommonJS `main.js` behind an `entry.mjs` shim)](#m2-module-is-laid-out-differently-from-the-js-template-commonjs-mainjs-behind-an-entrymjs-shim)
- [ ] [L1: Pressing Refresh all preamp states while disconnected logs a confusing error, or nothing at all](#l1-pressing-refresh-all-preamp-states-while-disconnected-logs-a-confusing-error-or-nothing-at-all)
- [ ] [L2: `yarn package` always marks the build as a prerelease, and `package.json` differs from the template](#l2-yarn-package-always-marks-the-build-as-a-prerelease-and-packagejson-differs-from-the-template)
- [ ] [L3: README still says the Bitfocus repository is not yet allocated](#l3-readme-still-says-the-bitfocus-repository-is-not-yet-allocated)
- [ ] [L4: Upgrade scripts and all definitions are inline in `main.js` instead of the template's separate files](#l4-upgrade-scripts-and-all-definitions-are-inline-in-mainjs-instead-of-the-templates-separate-files)
- [ ] [L5: Leftover v1 preset `category` is set and then deleted](#l5-leftover-v1-preset-category-is-set-and-then-deleted)
- [ ] [N1: Every 2-second status poll re-sends all 66 variables, re-checks every feedback and re-sets the status to Ok, even when nothing changed](#n1-every-2-second-status-poll-re-sends-all-66-variables-re-checks-every-feedback-and-re-sets-the-status-to-ok-even-when-nothing-changed)
- [ ] [N2: The Pad and 48 V State option can be switched to expression mode](#n2-the-pad-and-48-v-state-option-can-be-switched-to-expression-mode)

## 🔴 Critical

### C1: `.gitignore` is missing five template entries, so lock files and debug logs can be committed

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-7`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.gitignore#L1-L7)

**What goes wrong:** A contributor who runs `npm install` by mistake, or who turns on Companion's debug logging, can commit a `package-lock.json` or a `DEBUG-*` file, because nothing ignores them. The validator reports: "Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, DEBUG-*, /.yarn".

**Why it happens:** Every module must carry the template's `.gitignore` entries exactly as the template writes them. Two entries are missing outright (`package-lock.json`, `DEBUG-*`). Three are present only in an unanchored form (`.yarn/`, `pkg/`, `*.tgz` instead of `/.yarn`, `/pkg`, `/*.tgz`), which also ignores same-named files deeper in the tree. The extra entries (`coverage/`, `*.log`, `.DS_Store`) are allowed.

**Evidence:**

```text
module   .gitignore:1-7  node_modules/  .yarn/  pkg/  *.tgz  coverage/  *.log  .DS_Store
template .gitignore      node_modules/  package-lock.json  /pkg  /*.tgz  DEBUG-*  /.yarn
```

**Confirm by:** `diff <(sort .gitignore) <(sort companion-module-template-js/.gitignore)` shows no template line missing.

**Fix:** add every template entry exactly as the template writes it. The extra entries can stay.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
coverage/
*.log
.DS_Store
```

### C2: `.prettierignore` does not match the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-5`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.prettierignore#L1-L5)

**What goes wrong:** Running Prettier over the repo reformats `package.json` and `LICENSE.md`, which the template keeps out of formatting. The validator reports: "Differs from template (line 1: found 'node_modules', template 'package.json')".

**Why it happens:** The module replaced the template's two entries with its own list. Adding generated-file entries on top of the template is fine, but both template entries are missing here.

**Evidence:**

```text
module   .prettierignore:1-5  node_modules  .yarn  pkg  yarn.lock  *.tgz
template .prettierignore      package.json  /LICENSE.md
```

**Confirm by:** [`.prettierignore`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.prettierignore) contains the template's two lines.

**Fix:** copy the template's `.prettierignore`.

```text
package.json
/LICENSE.md
```

### C3: `.yarnrc.yml` is missing the template's supply-chain protection settings

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1-3`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.yarnrc.yml#L1-L3)

**What goes wrong:** When the maintainer updates dependencies, Yarn will install a package version published minutes ago, so a freshly published malicious release could reach the module before anyone notices it. The validator reports: "Missing template keys: npmMinimalAgeGate, npmPreapprovedPackages".

**Why it happens:** The template's `.yarnrc.yml` tells Yarn to accept only package versions that are at least 3 days old (`npmMinimalAgeGate: 3d`), with an exception for `@companion-module/*` (`npmPreapprovedPackages`). The module's file has neither setting.

**Evidence:**

```yaml
# module .yarnrc.yml:1-3
nodeLinker: node-modules
enableGlobalCache: false
enableScripts: false
```

```yaml
# template .yarnrc.yml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

**Confirm by:** [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.yarnrc.yml) contains `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages` with `"@companion-module/*"`.

**Fix:** copy the template's `.yarnrc.yml` (shown above). That also fixes [C4](#c4-yarnrcyml-adds-enableglobalcache-which-changes-how-every-build-installs-packages).

### C4: `.yarnrc.yml` adds `enableGlobalCache`, which changes how every build installs packages

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:2`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.yarnrc.yml#L2)

**What goes wrong:** Everyone who builds the module, including the Bitfocus build, gets a per-repo package cache instead of Yarn's default shared cache. The validator reports: "Extra keys not in template: enableGlobalCache".

**Why it happens:** `enableGlobalCache: false` is not in the template's `.yarnrc.yml`. A setting that changes install behaviour for every build has to match the template so all modules build the same way.

**Evidence:**

```yaml
# .yarnrc.yml:2
enableGlobalCache: false
```

**Confirm by:** `grep enableGlobalCache .yarnrc.yml` returns nothing.

**Fix:** remove the key. Copying the template's `.yarnrc.yml` (see [C3](#c3-yarnrcyml-is-missing-the-templates-supply-chain-protection-settings)) fixes both findings together.

### C5: `package.json` does not use the shared Companion Prettier config

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/package.json), [`.prettierrc.json`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.prettierrc.json)

**What goes wrong:** The module is formatted with its own rules instead of the shared Companion style, so its code style can drift from every other module, and changes to the shared style never reach it. The validator reports: "Missing required field 'prettier' (present in template)".

**Why it happens:** The template points Prettier at the shared config through a `prettier` key in `package.json`. The module has no `prettier` key and ships its own root `.prettierrc.json` instead.

**Evidence:**

```json
// template package.json:26
"prettier": "@companion-module/tools/.prettierrc.json",
```

```json
// module .prettierrc.json
{"singleQuote":true,"semi":false,"useTabs":true,"trailingComma":"all","printWidth":120}
```

**Confirm by:** `node -p "require('./package.json').prettier"` prints `@companion-module/tools/.prettierrc.json`.

**Fix:** add the shared config to `package.json` and delete the custom `.prettierrc.json`, so the shared config applies.

```json
"prettier": "@companion-module/tools/.prettierrc.json",
```

### C6: Module targets Node 22 where the API 2.1 template runs on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:17`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/companion/manifest.json#L17), [`package.json:16`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/package.json#L16), [`.github/workflows/test.yaml:17`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/.github/workflows/test.yaml#L17)

**What goes wrong:** Companion runs the module on Node 22 while every other API 2.1 module built from the template runs on Node 26. When a problem shows up, the different runtime is one more thing to rule out. The validator reports: "The API 2.1 template runs on Node 26; update every place still on another version: companion/manifest.json runtime.type 'node22' -> 'node26'; package.json engines.node '^22.20 || ^26.5' -> '^26'; .github/workflows/test.yaml line 17 node-version 22.x -> 26.x".

**Why it happens:** The manifest's `runtime.type` picks the Node version Companion starts the module with. The module asks for Node 22, and its `engines` and CI workflow follow that.

**Evidence:**

```json
// companion/manifest.json:17
"type": "node22",
// package.json:16
"node": "^22.20 || ^26.5"
```

```yaml
# .github/workflows/test.yaml:17
node-version: 22.x
```

**Confirm by:** re-running the validator reports no NODE-VERSION finding.

**Fix:** update every place to Node 26, as the template does:

- [ ] `companion/manifest.json`: `"runtime": { "type": "node26" }`
- [ ] `package.json`: `"engines": { "node": "^26" }`
- [ ] `.github/workflows/test.yaml`: `node-version: 26.x` (line 17)

The README's "Build and test" section ([`README.md:19`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/README.md#L19)) also tells contributors to use Node 22; update it at the same time.

## 🟡 Medium

### M1: Aborting a button's running actions does not stop queued gain, pad and phantom changes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:118-124`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L118-L124), [`src/client.js:101-120`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/client.js#L101-L120)

**What goes wrong:** Say a user presses the "Input 3 gain +1 dB" preset 8 times quickly, or triggers "Set analogue gain (before pad)", and then uses Companion 5's option to abort the button's running actions. The module still works through every queued change, so the preamp keeps stepping up (for example from 25 dB to 33 dB) after the user tried to stop it. Each queued change reads the state first and then waits for the device to confirm, so a queue of presses can keep running for a while.

**Why it happens:** On API 2.1 every action callback gets a second argument, the action context, and its `context.signal` fires when the result is no longer needed, for example when the user aborts the running actions. The module's `wrap` helper passes only the options on and drops the context. The client's `change()` queues each request behind the previous one and never checks for an abort before sending.

**Evidence:**

```js
// src/main.js:118-124
		const wrap = (fn) => async (event) => {
			try {
				await fn(event.options)
			} catch (e) {
				this.log('error', e.message)
			}
		}
```

```js
// src/client.js:101-104
	change(channel, mutate) {
		const action = async () => {
			if (!Number.isInteger(channel) || channel < 1 || channel > 16) throw Error('Channel must be 1–16')
			await this.refresh()
```

**Confirm by:** open [`src/main.js:118-124`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L118-L124): the callback ignores its second argument and never reads `context.signal`. Then open [`src/client.js:101-120`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/client.js#L101-L120): there is no abort check before the `p.set()` send.

**Fix:** pass the abort signal from the action callback down to the client, and skip a queued change once it has fired. Companion ignores an error thrown after an abort, so no extra logging is needed. See the companion-v2-actions skill (abort signals, 2.1+).

```js
const wrap = (fn) => async (event, context) => {
	try {
		await fn(event.options, context.signal)
	} catch (e) {
		if (!context.signal.aborted) this.log('error', e.message)
	}
}
// in DTClient.change(channel, mutate, signal): check before refresh() and again before p.set()
if (signal?.aborted) throw Error('Aborted')
```

Optionally, also make `waitPacket()` reject when the signal fires.

### M2: Module is laid out differently from the JS template (CommonJS `main.js` behind an `entry.mjs` shim)

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:5-6`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/package.json#L5-L6), [`src/entry.mjs:1-3`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/entry.mjs#L1-L3), [`src/main.js:257`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L257)

**What goes wrong:** Users see nothing different: the module loads (the built `pkg/allenheath-dt168/main.js` exports the DT168 class as default, plus `UpgradeScripts`). The cost comes later, for whoever troubleshoots or maintains it. Anyone comparing the module with the template, or chasing an import/export problem, first has to work out an extra layer the template doesn't have.

**Why it happens:** The API 2.1 JS template is an ES module: `"type": "module"`, `main` is `src/main.js`, which uses `export default class ModuleInstance` and re-exports `UpgradeScripts` from `./upgrades.js`. This module instead declares `"type": "commonjs"`, builds a hand-made `{ default, UpgradeScripts }` object with `module.exports`, and points the manifest entrypoint at a 3-line ESM shim (`src/entry.mjs`) that re-exports it. Base 2.1.3 accepts both formats, so this is a template mismatch, not an API error.

**Evidence:**

```js
// package.json:5-6
	"type": "commonjs",
	"main": "src/entry.mjs",
// src/entry.mjs:1-3
import entry from './main.js'
export default entry.default
export const UpgradeScripts = entry.UpgradeScripts
// src/main.js:257
module.exports = { default: DT168Instance, UpgradeScripts: [] }
```

**Confirm by:** open [`package.json:5-6`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/package.json#L5-L6) and [`src/entry.mjs`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/entry.mjs), then compare them with `companion-module-template-js/package.json` (`"type": "module"`, `"main": "src/main.js"`) and its `src/main.js` (`export default class ModuleInstance`).

**Fix:** switch the module to the template's ES-module layout.

- Set `"type": "module"` and `"main": "src/main.js"` in `package.json`, and point the manifest's `runtime.entrypoint` at `"../src/main.js"`.
- Convert `src/main.js`, `src/client.js` and `src/protocol.js` to ESM: `import { InstanceBase, ... } from '@companion-module/base'`, relative imports with the `.js` extension, and `export default class DT168Instance extends InstanceBase`.
- Delete `src/entry.mjs`.
- Rename `test/protocol.test.cjs` to an ESM test, or keep it `.cjs` and load the code with dynamic `import()`.

See the companion-v2-module-scaffold skill.

## 🟢 Low

### L1: Pressing Refresh all preamp states while disconnected logs a confusing error, or nothing at all

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:174`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L174)

**What goes wrong:** Say an operator presses a button with the "Refresh all preamp states" action while the connection shows "Connection failure: No confirmed reply from DT168". The Companion log shows `error: Connection closed` instead of the clear `DT168 is not connected` that every other action gives. If the IP address or interface was never set (status "Bad Configuration"), the press does nothing and logs nothing. The device state is never wrong.

**Why it happens:** Every other action goes through the module's `act()` helper ([`src/main.js:113-116`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L113-L116)), which checks the connection first and queues the work behind earlier changes. The refresh action calls the client directly. With no IP set there is no client, so the call silently does nothing ([`src/main.js:51-56`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L51-L56)). After a failed connection attempt the module keeps the closed client ([`src/main.js:83-92`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L83-L92)), which throws "Connection closed". Each press also adds its own reply listener ([`src/client.js:97-98`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/client.js#L97-L98)); they are removed on timeout, so nothing leaks.

**Fix:** give the refresh action the same connection check `act()` uses.

```js
refresh: {
	name: 'Refresh all preamp states',
	options: [],
	callback: wrap(async () => {
		if (!this.online || !this.client) throw Error('DT168 is not connected')
		await this.client.refresh()
	}),
},
```

Optionally, make `DTClient.refresh()` return a refresh that is already in flight (or chain it on `this.tail`), so repeated presses don't stack listeners.

### L2: `yarn package` always marks the build as a prerelease, and `package.json` differs from the template

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:8`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/package.json#L8), [`package.json:15-23`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/package.json#L15-L23)

**What goes wrong:** Users of the current beta see nothing different. Later, three things go wrong. A stable 1.0.0 built with `yarn package` is still labelled a prerelease (the built manifest has `"isPrerelease": true`) unless the maintainer remembers to edit the script. `yarn up` and dependency bots never pick up patch releases of `@companion-module/base` (2.1.x), `@companion-module/tools` (3.x) or Prettier, because every version is pinned exactly. And nothing declares Yarn 4, which the template does.

**Why it happens:** The template uses `"package": "companion-module-build"`, `"engines": { "node": "^26", "yarn": "^4" }`, `"@companion-module/base": "~2.1.3"`, `"@companion-module/tools": "^3.1.1"` and `"prettier": "^3.9.9"`. The module hardcodes `--prerelease`, leaves out `engines.yarn`, and pins `2.1.3`, `3.1.1` and `3.9.9` exactly. The `engines.node` value is covered by [C6](#c6-module-targets-node-22-where-the-api-21-template-runs-on-node-26).

**Fix:** use the template's script, engines and version ranges. The README already says the portal's **Is Prerelease** checkbox marks the beta, and the committed `yarn.lock` still pins the exact versions that get built.

```json
"package": "companion-module-build",
"engines": { "node": "^26", "yarn": "^4" },
"dependencies": { "@companion-module/base": "~2.1.3" },
"devDependencies": { "@companion-module/tools": "^3.1.1", "prettier": "^3.9.9" }
```

### L3: README still says the Bitfocus repository is not yet allocated

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:5`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/README.md#L5)

**What goes wrong:** Someone reading the README on GitHub sees "Repository allocation and Bitfocus review are pending. The planned Bitfocus repository links in the manifest must be confirmed after allocation." The repository already exists at bitfocus/companion-module-allenheath-dt168 and the manifest links point to it, so the text is out of date and makes the published module look unfinished.

**Fix:** remove those two sentences from line 5, or replace them with the current release status.

### L4: Upgrade scripts and all definitions are inline in `main.js` instead of the template's separate files

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:117-257`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L117-L257)

**What goes wrong:** Users see nothing different. When a later release renames an action option and needs its first upgrade script, there is no `src/upgrades.js` to add it to. A maintainer or reviewer used to the template has to hunt for the actions, feedbacks, variables and presets, which the template keeps in their own files.

**Why it happens:** The empty upgrade-script list is part of the export object at the bottom of `main.js` (line 257), and one `define()` method (lines 117-255) builds every action, feedback, variable and preset.

**Fix:** create `src/upgrades.js` with `export const UpgradeScripts = []` and re-export it from `main.js`, as the template does. Optionally, move the action, feedback, variable and preset builders into `src/actions.js`, `src/feedbacks.js`, `src/variables.js` and `src/presets.js`, called from `main.js`. See the companion-v2-upgrades and companion-v2-action-file-pattern skills.

### L5: Leftover v1 preset `category` is set and then deleted

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:223`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L223), [`src/main.js:235`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L235), [`src/main.js:248`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L248)

**What goes wrong:** No visible effect: the presets are grouped correctly as "Input 1" to "Input 16". But the code adds a v1-style category to all 64 presets and then strips it again in a separate loop. That is dead code, and it suggests to a reader that v1 categories still matter.

**Why it happens:** In API 2.x, preset grouping comes only from the structure passed to `setPresetDefinitions(structure, presets)`. Each preset literal still sets `category`, and a loop deletes it before the call.

**Fix:** remove `category: ...` from both preset literals (lines 223 and 235) and delete the loop on line 248. The structure at lines 249-253 already supplies the grouping.

## 💡 Nice to Have

### N1: Every 2-second status poll re-sends all 66 variables, re-checks every feedback and re-sets the status to Ok, even when nothing changed

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:66-71`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L66-L71), [`src/main.js:100-112`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L100-L112)

**What goes wrong:** Nothing a user can see. While a DT168 is connected, the module polls it every 2 seconds, and every reply pushes all 66 variables, re-checks every "Pad is on", "48 V is on" and "DT168 is connected" feedback, and sets the connection status to OK again. That happens even when every preamp is unchanged, for example Input 1 sitting at 25 dB with the pad off for hours. The cost is a little extra work every 2 seconds per connection; this is code quality, not a bug.

**Why it happens:** The client reports a state update for every decoded packet, including each periodic poll reply ([`src/client.js:35-38`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/client.js#L35-L38), [`src/client.js:62-65`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/client.js#L62-L65)). The module's handler always sets the status to OK and calls `publish()`, which sends every value and calls `checkAllFeedbacks()` without comparing against what it sent last time.

**Fix:** only publish what changed. Keep the last published values (or compare the incoming channel states with `this.states` before overwriting them in [`src/client.js:33`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/client.js#L33)), and call `setVariableValues` and `checkFeedbacks('pad', 'phantom')` only for channels whose gain or flags changed. Call `updateStatus(InstanceStatus.Ok)` and `checkFeedbacks('connected')` only when the connection goes from offline to online.

### N2: The Pad and 48 V State option can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:125-135`](https://github.com/bitfocus/companion-module-allenheath-dt168/blob/112c9e10e0bd24c7f92ac89a97eb804bbb53e2f3/src/main.js#L125-L135)

**What goes wrong:** In the "Pad: on / off / toggle" and "48 V phantom: on / off / toggle" actions, the "State" dropdown shows the expression toggle. If a user switches it to an expression whose result isn't exactly `toggle`, `on` or `off` (for example `ON` or `1`), Companion skips the action as if it were disabled, and the pad or phantom power doesn't change. This is an edge case.

**Why it happens:** The dropdown doesn't set `disableAutoExpression: true`, which the v2 guidance recommends for on/off/toggle choices that make little sense as expressions. A first release is the safe time to add it: base 2.1.3 warns that setting it later breaks expressions users have already saved.

**Fix:** add `disableAutoExpression: true` to the `mode` dropdown, or keep expression mode and add an `expressionDescription` such as "Must evaluate to 'toggle', 'on' or 'off'".
