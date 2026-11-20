# Module Review: etcaudiovisuel-onlyview v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-etcaudiovisuel-onlyview` |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.0.2 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Scope** | `tag` (v1.0.2..v2.0.0) |
| **Commit** | [`4a4f1a1`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/commit/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8) |
| **Reviewed** | 2026-11-19 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: Line endings are not forced to LF: `.gitattributes` is missing](#c1-line-endings-are-not-forced-to-lf-gitattributes-is-missing)
- [ ] [C2: Yarn's install files can end up in git: `.gitignore` is missing `/.yarn`](#c2-yarns-install-files-can-end-up-in-git-gitignore-is-missing-yarn)
- [ ] [C3: Yarn 4 install settings are missing: no `.yarnrc.yml`](#c3-yarn-4-install-settings-are-missing-no-yarnrcyml)
- [ ] [C4: The Yarn version is not pinned: `package.json` has no `packageManager` field](#c4-the-yarn-version-is-not-pinned-packagejson-has-no-packagemanager-field)
- [ ] [C5: Module source files sit at the repository root instead of `src/`](#c5-module-source-files-sit-at-the-repository-root-instead-of-src)
- [ ] [H1: Existing Board grand master buttons lose their Board Id after the upgrade and stop controlling the board](#h1-existing-board-grand-master-buttons-lose-their-board-id-after-the-upgrade-and-stop-controlling-the-board)
- [ ] [H2: Contributors with the wrong Yarn get no warning: `engines` in `package.json` has no `yarn` entry](#h2-contributors-with-the-wrong-yarn-get-no-warning-engines-in-packagejson-has-no-yarn-entry)

### Non-blocking

- [ ] [M1: Display status is feedback never matches a status name typed in expression mode](#m1-display-status-is-feedback-never-matches-a-status-name-typed-in-expression-mode)
- [ ] [L1: While Producer is unreachable, every feedback is re-checked about twice a second for no reason](#l1-while-producer-is-unreachable-every-feedback-is-re-checked-about-twice-a-second-for-no-reason)

## 🔴 Critical

### C1: Line endings are not forced to LF: `.gitattributes` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Nothing tells git to keep the module's text files in LF line endings. A contributor on Windows can check the files out and commit them back with CRLF endings, which turns every touched line into a diff and fights the Prettier formatting.

**Why it happens:** The API 2.0 template tracks a `.gitattributes` file that forces LF for every text file. The module has never had one (it was already missing at v1.0.2), but this release moves the module to API 2.0, so it is now checked against the 2.0 template.

**Evidence:**

```text
Template (companion-module-template-js-v2.0.4/.gitattributes):
* text=auto eol=lf

Module: no .gitattributes file
```

**Fix:** add `.gitattributes` at the repository root with the template's single line.

```text
* text=auto eol=lf
```

### C2: Yarn's install files can end up in git: `.gitignore` is missing `/.yarn`

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-5`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/.gitignore#L1-L5)

**What goes wrong:** Once the module uses Yarn 4 (see [C3](#c3-yarn-4-install-settings-are-missing-no-yarnrcyml) and [C4](#c4-the-yarn-version-is-not-pinned-packagejson-has-no-packagemanager-field)), Yarn writes its install state and cache into a `.yarn/` folder. Without an ignore rule, a `git add .` commits that folder into the repository.

**Why it happens:** The template `.gitignore` ends with `/.yarn`. This release edited `.gitignore` (it added `/*.tgz` and `DEBUG-*`) but did not add `/.yarn`.

**Evidence:**

```text
Template: node_modules/, package-lock.json, /pkg, /*.tgz, DEBUG-*, /.yarn
Module:   node_modules/, package-lock.json, /pkg, /*.tgz, DEBUG-*
Missing:  /.yarn
```

**Fix:** add `/.yarn` as the last line of `.gitignore`.

### C3: Yarn 4 install settings are missing: no `.yarnrc.yml`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Without this file, a Yarn 4 install of the module does not get the template's settings. Yarn 4 then installs dependencies in its Plug'n'Play mode with no `node_modules` folder, runs the install scripts of every dependency, and accepts packages published minutes ago. The template's settings switch off dependency install scripts and refuse brand-new package versions to protect against supply-chain attacks.

**Why it happens:** The template tracks a `.yarnrc.yml`. The module has never had one (it was already missing at v1.0.2). This release moves the module to API 2.0, so it is now checked against the template, and the file is compared against the `main` template @ `89da037`.

**Evidence:**

```yaml
# Expected (companion-module-template-js/.yarnrc.yml @ 89da037)
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

```text
Module: no .yarnrc.yml file
```

**Fix:** copy the template's `.yarnrc.yml` to the repository root unchanged. Fix it together with [C4](#c4-the-yarn-version-is-not-pinned-packagejson-has-no-packagemanager-field) and [H2](#h2-contributors-with-the-wrong-yarn-get-no-warning-engines-in-packagejson-has-no-yarn-entry).

### C4: The Yarn version is not pinned: `package.json` has no `packageManager` field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/package.json)

**What goes wrong:** Every contributor builds the module with whatever Yarn they have installed globally, so installs are not reproducible. This review's build ran with Yarn 1.22.22 for that reason, and the committed `yarn.lock` is a Yarn 1 lockfile.

**Why it happens:** The API 2.0 template sets `"packageManager": "yarn@4.17.0"`, which makes Corepack use that exact Yarn version. The field was already missing at v1.0.2, but this release moves the module to API 2.0, so it is now checked against the 2.0 template.

**Evidence:**

```text
Template (companion-module-template-js-v2.0.4/package.json): "packageManager": "yarn@4.17.0"
Module (package.json): no packageManager field
Module (yarn.lock:2): # yarn lockfile v1
```

**Fix:** add the field, then regenerate the lockfile with Yarn 4 and commit it.

```json
"packageManager": "yarn@4.17.0"
```

```bash
corepack enable
yarn install
```

Commit the new `yarn.lock` together with [C3](#c3-yarn-4-install-settings-are-missing-no-yarnrcyml)'s `.yarnrc.yml` and [H2](#h2-contributors-with-the-wrong-yarn-get-no-warning-engines-in-packagejson-has-no-yarn-entry)'s `engines` entry.

### C5: Module source files sit at the repository root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** eight files at the repository root (list below)

**What goes wrong:** The module's code does not follow the template's layout, where all source lives under `src/`. That makes the module harder to maintain and troubleshoot alongside every other module built from the template.

**Why it happens:** The source files have been at the root since v1.0.2 (`actions.js`, `feedbacks.js`, `main.js`, `upgrades.js`, `variables.js`), and this release added three more there (`presets.js`, `state.js`, `timecode.js`). This release moves the module to API 2.0, so it is now checked against the 2.0 template, which keeps them in `src/`.

**Evidence:** files to move:

- [ ] [`actions.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/actions.js)
- [ ] [`feedbacks.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/feedbacks.js)
- [ ] [`main.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/main.js)
- [ ] [`presets.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/presets.js)
- [ ] [`state.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/state.js)
- [ ] [`timecode.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/timecode.js)
- [ ] [`upgrades.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/upgrades.js)
- [ ] [`variables.js`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/variables.js)

**Fix:** move every source file into `src/` as the template does (`src/main.js`, `src/actions.js`, …), then point the entry points at the new location:

- [`package.json:7`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/package.json#L7): `"main": "src/main.js"`
- [`companion/manifest.json:26`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/companion/manifest.json#L26): `"entrypoint": "../src/main.js"`
- the imports in `test/*.test.js` (`'../main.js'` → `'../src/main.js'`, and so on) and in `test/helpers/fake-context.js` (`'../../main.js'` → `'../../src/main.js'`)

## 🟠 High

### H1: Existing Board grand master buttons lose their Board Id after the upgrade and stop controlling the board

- **Source:** 🔎 QA reviewer, compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`upgrades.js:84-104`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/upgrades.js#L84-L104), [`actions.js:617-631`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/actions.js#L617-L631)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** A user built buttons in v1.0.2 with the "Board grand master" action, for example Board Id 3, Grand master value 0 and a 2 s fade, to fade board 3 to black. After the update to 2.0.0 the button still holds the action, but its Board Id is gone. When the operator presses it, board 3 does not fade: nothing is sent to Producer and the connection log only shows "Board grand master: invalid Board Id, set it again in the button". If Companion instead fills the empty option with its default, the button fades board 1. Either way, every Board grand master button in every page and trigger has to be found and its Board Id typed in again by hand, and during a show nobody notices until the button is pressed. Buttons created with 2.0.0 are not affected.

**Why it happens:** In v1.0.2 the action's Board Id option was saved under the misspelled id `baoardId`. This release renames the option to `boardId` (commit `f766d82`: "Rename baoardId to boardId in board grand master. No upgrade script."). Renaming an option id needs an upgrade script, a function Companion runs once on saved buttons to move old values to the new ids. Neither of this release's two upgrade scripts does that: the first converts `baoardId` to the 2.0 value format but leaves it under the old id, and the second only touches the six on/off/solo state actions. So the action reads an empty `boardId`.

**Evidence:**

```js
// git show v1.0.2:actions.js (lines 336-347)
        boardGrandMasterAction: {
            name: 'Board grand master',
            options: [
                numberOption('baoardId', 'Board Id', 1, 99, 1),
...
                const str = 'setBoardGrandMaster*' + action.options.baoardId + '*' +
```

```js
// actions.js:617-631 (v2.0.0)
		boardGrandMasterAction: {
			name: 'Board grand master',
			options: [
				idOption('boardId', 'Board Id', 99),
				{ ...numberOption('value', 'Grand master value', 0, 100, 100), clampValues: true },
				numberOption('fadeTime', 'Fade time (seconds)', 0, 99, 0),
			],
			callback: async (action) => {
				// Buttons saved before the baoardId rename have no boardId.
				const boardId = Number(action.options.boardId)
				if (!Number.isInteger(boardId) || boardId < 1) {
					self.log('warn', 'Board grand master: invalid Board Id, set it again in the button')
					return
				}
```

```js
// upgrades.js:84-104 (v2.0.0)
function upgradeStateToMode(_context, props) {
	const updatedActions = []

	for (const action of props.actions) {
		if (!STATE_ACTION_IDS.includes(action.actionId)) continue
...
// Once a script has been added it cannot be removed.
export const UpgradeScripts = [upgradeToExpressions, upgradeStateToMode]
```

```text
// git show f766d82 (inside v1.0.2..v2.0.0)
fix: action option ids and limits

Rename baoardId to boardId in board grand master. No upgrade script.
```

```text
// Both UpgradeScripts run with node on a saved v1.0.2 Board grand master action (reviewer's own check)
{"baoardId":{"isExpression":false,"value":4},"value":{"isExpression":false,"value":50},"fadeTime":{"isExpression":false,"value":2}}
```

**Confirm by:** open [`upgrades.js:41-104`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/upgrades.js#L41-L104): no script copies `options.baoardId` to `options.boardId`. Then compare [`actions.js:620`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/actions.js#L620) (`boardId`) with `git show v1.0.2:actions.js` line 339 (`baoardId`).

**Fix:** add a third upgrade script that moves the saved Board Id to the new option id. It runs after `upgradeToExpressions`, so the value moves over already in the 2.0 format. Both existing scripts are new in this release (v1.0.2 registered none), so folding the rename into `upgradeToExpressions` also works.

```js
// boardGrandMasterAction used `baoardId` up to v1.0.2.
function renameBaoardId(_context, props) {
	const updatedActions = []
	for (const action of props.actions) {
		if (action.actionId !== 'boardGrandMasterAction' || action.options.baoardId === undefined) continue
		if (action.options.boardId === undefined) action.options.boardId = action.options.baoardId
		delete action.options.baoardId
		updatedActions.push(action)
	}
	return { updatedConfig: null, updatedActions, updatedFeedbacks: [] }
}

export const UpgradeScripts = [upgradeToExpressions, upgradeStateToMode, renameBaoardId]
```

Keep the guard in the action callback. Replace the case in [`test/upgrades.test.js:41`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/test/upgrades.test.js#L41) that asserts `baoardId` survives with one that asserts it becomes `boardId`, and update the comment at [`actions.js:625`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/actions.js#L625).

### H2: Contributors with the wrong Yarn get no warning: `engines` in `package.json` has no `yarn` entry

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:19-21`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/package.json#L19-L21)

**What goes wrong:** Companion users see nothing. Maintainers and contributors do: a contributor who installs the module with Yarn 1 or npm gets no engine warning, and the module's `package.json` differs from its template, which makes it harder to maintain and troubleshoot.

**Why it happens:** This release adds an `engines` block (v1.0.2 had none) but copies only the `node` entry from the API 2.0 template and leaves out `"yarn": "^4"`. The validator reports the missing `packageManager` field ([C4](#c4-the-yarn-version-is-not-pinned-packagejson-has-no-packagemanager-field)) but not this one.

**Evidence:**

```json
// package.json:19-21 (module at v2.0.0)
    "engines": {
        "node": "^22.20"
    },
```

```json
// companion-module-template-js-v2.0.4/package.json:14-17 (template)
	"engines": {
		"node": "^22.20",
		"yarn": "^4"
	},
```

```text
// yarn.lock:1-2 (module)
# THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.
# yarn lockfile v1
```

**Confirm by:** open [`package.json:19-21`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/package.json#L19-L21): `engines` has only `"node": "^22.20"`, while `companion-module-template-js-v2.0.4/package.json:14-17` also has `"yarn": "^4"`.

**Fix:** add the template's `yarn` entry, together with [C3](#c3-yarn-4-install-settings-are-missing-no-yarnrcyml) and [C4](#c4-the-yarn-version-is-not-pinned-packagejson-has-no-packagemanager-field).

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
},
```

## 🟡 Medium

### M1: Display status is feedback never matches a status name typed in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`feedbacks.js:283-306`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/feedbacks.js#L283-L306)
- **Assumption:** [A3](#-assumptions-to-confirm)

**What goes wrong:** A user switches the Status option of the new "Display status is" feedback to expression mode and enters `$(onlyview:display_1_status)`, or the text `Connected`. HELP says the feedback matches that variable, but its text is not one of the dropdown's choice ids, so Companion rejects the value and the button never changes colour. Only the undocumented numbers 0-4 (Connected is `3`, Offline is `1`, …) work in expression mode.

**Why it happens:** The dropdown's choice ids are Onlyview's internal screen status numbers (`ScreenStatus` in [`state.js:30`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/state.js#L30)), not readable names. In API 2.0 users can switch any dropdown to expression mode, so the choice ids are what they have to type.

**Fix:** the feedback is new in this release, so the ids can change now without an upgrade script. Use string ids that match the variable's text (`'connected'`, `'offline'`, `'error'`, `'connecting'`, `'idle'`) and map them back to `ScreenStatus` in the callback. Update the preset feedbacks in [`presets.js:194-205`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/presets.js#L194-L205) to the same ids, and optionally add `expressionDescription: 'connected, offline, error, connecting or idle'`.

## 🟢 Low

### L1: While Producer is unreachable, every feedback is re-checked about twice a second for no reason

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:210-215`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/main.js#L210-L215), [`main.js:330-333`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/main.js#L330-L333), [`state.js:71-74`](https://github.com/bitfocus/companion-module-etcaudiovisuel-onlyview/blob/4a4f1a1276b476d3c2e6a1e4410d2ae2fd6d55a8/state.js#L71-L74)
- **Assumption:** [A2](#-assumptions-to-confirm)

**What goes wrong:** Nothing changes on screen, but while the Producer PC is off or unreachable, Companion re-checks all 16 of the module's feedback types on every button that uses this connection, about twice a second, and schedules a rebuild of the action and preset definitions each time. The reviewer measured 199 feedback-type checks in 6.5 s against a closed port. On a large page this is a small, constant CPU cost while the show computer is down.

**Why it happens:** The TCP connection retries every 2 s, and each failed retry reports the lost connection about three times (status change to error, the error itself, status change to connecting). Each report clears the show state, which is already empty, and clearing always marks every kind of state as changed. The module then re-checks every feedback and schedules a definitions rebuild.

**Fix:** report a clear only when there was something to clear. For example, in `OnlyviewState.clear()` skip marking the changes when the state is not subscribed and every map is already empty, or in `onDisconnected()` call `clearState()` only when the state was subscribed or holds data. The connection change is already reported on its own, so the "Producer connection is alive" feedback still updates.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a saved action has no value for an option its definition now has (`boardId`), Companion 4.3+ either passes it to the callback as empty (the module logs a warning and sends nothing) or fills in the option's default (1, so the command goes to board 1). The saved Board Id is lost either way; only what the user sees differs | the module's own comment at `actions.js:625` assumes empty, while its test harness (`test/helpers/fake-context.js`) merges in defaults; the companion-v1-to-v2-migrate-definitions skill says Companion does not guarantee to back-fill defaults; the Companion host source was not checked | [H1](#h1-existing-board-grand-master-buttons-lose-their-board-id-after-the-upgrade-and-stop-controlling-the-board) |
| A2 | Companion redraws a button only when a feedback's result actually changes, so the extra re-checks that return the same value cost CPU but cause no flicker | general knowledge of how Companion 4.x handles feedback values; this happens in the host, outside the base package | [L1](#l1-while-producer-is-unreachable-every-feedback-is-re-checked-about-twice-a-second-for-no-reason) |
| A3 | In API 2.0, Companion checks a dropdown's expression result against its choice ids (when `allowCustom` is not set) and skips the feedback when the result doesn't match | the companion-v2-api-compliance `references/v2.0.md` "Expression validation" row; not checked against the Companion host source | [M1](#m1-display-status-is-feedback-never-matches-a-status-name-typed-in-expression-mode) |
