# Review: uniliga-cg v1.3.0

| | |
| --- | --- |
| **Module** | [companion-module-uniliga-cg](https://github.com/bitfocus/companion-module-uniliga-cg) |
| **Scope** | `tag` |
| **Version** | v1.3.0 (`9468691`) |
| **Release** | Update — last published v1.1.1 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a user renames a connection, Companion sends the new label through the config/label update (the module's `configUpdated()`) and does not restart the module, so presets built in `init()` keep the old label until the next restart | @companion-module/base 1.12.1 `_handleConfigUpdateAndLabel` (`dist/module-api/base.js:148-156`) updates the label and calls `configUpdated()` without re-running `init()`; whether Companion restarts the module on rename was not checked | [L2](#l2-presets-keep-the-old-connection-name-after-the-connection-is-renamed) |
| A2 | Companion does not rewrite the `$(label:...)` references inside the preset definitions a module sent when the connection is renamed; presets dragged onto buttons after a rename use whatever text the module last sent | Preset definitions are static data that only the module sends; Companion's preset-import code was not checked | [L2](#l2-presets-keep-the-old-connection-name-after-the-connection-is-renamed) |

## 📋 Issues

### Blocking

- [ ] [C1: Line endings are not normalised because .gitattributes is missing](#c1-line-endings-are-not-normalised-because-gitattributes-is-missing)
- [ ] [C2: Generated files can be committed because .gitignore lacks template entries](#c2-generated-files-can-be-committed-because-gitignore-lacks-template-entries)
- [ ] [C3: The .prettierignore file does not match the template](#c3-the-prettierignore-file-does-not-match-the-template)
- [ ] [C4: Yarn 4 settings are missing because .yarnrc.yml is missing](#c4-yarn-4-settings-are-missing-because-yarnrcyml-is-missing)
- [ ] [C5: Source file main.js sits at the module root instead of src](#c5-source-file-mainjs-sits-at-the-module-root-instead-of-src)
- [ ] [C6: Source file presets.js sits at the module root instead of src](#c6-source-file-presetsjs-sits-at-the-module-root-instead-of-src)
- [ ] [C7: Source file state.js sits at the module root instead of src](#c7-source-file-statejs-sits-at-the-module-root-instead-of-src)
- [ ] [C8: Source file upgrade.js sits at the module root instead of src](#c8-source-file-upgradejs-sits-at-the-module-root-instead-of-src)
- [ ] [C9: Repository URL in package.json lacks the .git suffix](#c9-repository-url-in-packagejson-lacks-the-git-suffix)
- [ ] [C10: package.json does not declare the supported Node and Yarn versions](#c10-packagejson-does-not-declare-the-supported-node-and-yarn-versions)
- [ ] [C11: package.json pins Yarn 1 instead of Yarn 4](#c11-packagejson-pins-yarn-1-instead-of-yarn-4)
- [ ] [C12: There is no package script, so the module cannot be packaged](#c12-there-is-no-package-script-so-the-module-cannot-be-packaged)
- [ ] [C13: Prettier is not a devDependency, so yarn format relies on a global install](#c13-prettier-is-not-a-devdependency-so-yarn-format-relies-on-a-global-install)
- [ ] [C14: The module runs on Node 18 instead of Node 22](#c14-the-module-runs-on-node-18-instead-of-node-22)
- [ ] [C15: yarn package fails, so no installable package can be built](#c15-yarn-package-fails-so-no-installable-package-can-be-built)

### Non-blocking

- [ ] [L1: Existing Restart Timer buttons keep the old invalid option value](#l1-existing-restart-timer-buttons-keep-the-old-invalid-option-value)
- [ ] [L2: Presets keep the old connection name after the connection is renamed](#l2-presets-keep-the-old-connection-name-after-the-connection-is-renamed)
- [ ] [N1: Graphic choices, preset names and variable names mix German and English](#n1-graphic-choices-preset-names-and-variable-names-mix-german-and-english)

## 🔴 Critical

### C1: Line endings are not normalised because .gitattributes is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Contributors on Windows can commit files with CRLF line endings, which produces noisy diffs and formatting churn that the template is set up to prevent.

**Why it happens:** The template tracks a `.gitattributes` file that forces LF line endings for every text file. This module has no such file.

**Evidence:** expected `.gitattributes` with `* text=auto eol=lf` (template); found: no file.

**Fix:** add `.gitattributes` from the template.

```text
* text=auto eol=lf
```

### C2: Generated files can be committed because .gitignore lacks template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-5`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/.gitignore#L1-L5)

**What goes wrong:** A stray `package-lock.json`, debug logs in subfolders, or the Yarn 4 `.yarn` folder can end up in a commit.

**Why it happens:** The module's `.gitignore` is missing four entries the template ignores.

**Evidence:** missing template `.gitignore` entries: `package-lock.json`, `/*.tgz`, `DEBUG-*`, `/.yarn`.

**Fix:** use the template's `.gitignore`.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C3: The .prettierignore file does not match the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/.prettierignore#L2)

**What goes wrong:** `yarn format` treats files differently from every other module built on the template, because one of the template's ignore entries was replaced.

**Why it happens:** The module replaced the template entry `/LICENSE.md` with `pkg`, so a template entry is missing.

**Evidence:** line 2: found `pkg`, template `/LICENSE.md`. Template: `package.json`, `/LICENSE.md`; found: `package.json`, `pkg`.

**Fix:** restore the template entries (an extra `pkg` line may stay alongside them).

```text
package.json
/LICENSE.md
```

### C4: Yarn 4 settings are missing because .yarnrc.yml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Once the module moves to Yarn 4 (see [C11](#c11-packagejson-pins-yarn-1-instead-of-yarn-4)), Yarn uses Plug'n'Play instead of a `node_modules` folder and runs dependency install scripts, so the Companion build tools do not work as expected.

**Why it happens:** The template ships a `.yarnrc.yml` that sets `nodeLinker: node-modules`, disables install scripts and adds a minimum package age. The module has no such file.

**Evidence:** expected `.yarnrc.yml` (template); found: no file.

**Fix:** copy `.yarnrc.yml` from the template.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C5: Source file main.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`main.js`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/main.js)

**What goes wrong:** The module's layout differs from every template-based module, which makes it harder for other maintainers to find their way around and to troubleshoot.

**Why it happens:** The template keeps all source under `src/`; this module keeps its source files at the repository root.

**Evidence:** expected `src/main.js`; found `main.js` at the root.

**Fix:** move `main.js`, `presets.js`, `state.js` and `upgrade.js` (C5 to C8) into `src/`. Then update both `package.json` `main` (currently `main.js`) and `companion/manifest.json` `runtime.entrypoint` (currently `../main.js`) so they still point at the same file.

```json
"main": "src/main.js"
```

```json
"entrypoint": "../src/main.js"
```

### C6: Source file presets.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`presets.js`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/presets.js)

**What goes wrong:** Same as [C5](#c5-source-file-mainjs-sits-at-the-module-root-instead-of-src): the preset source is outside `src/`.

**Why it happens:** All source must be under `src/` in the template layout.

**Evidence:** expected `src/presets.js`; found `presets.js` at the root.

**Fix:** move it to `src/presets.js` (see C5).

### C7: Source file state.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`state.js`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/state.js)

**What goes wrong:** Same as [C5](#c5-source-file-mainjs-sits-at-the-module-root-instead-of-src): the state source is outside `src/`.

**Why it happens:** All source must be under `src/` in the template layout.

**Evidence:** expected `src/state.js`; found `state.js` at the root.

**Fix:** move it to `src/state.js` (see C5).

### C8: Source file upgrade.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`upgrade.js`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/upgrade.js)

**What goes wrong:** Same as [C5](#c5-source-file-mainjs-sits-at-the-module-root-instead-of-src): the upgrade scripts are outside `src/`.

**Why it happens:** All source must be under `src/` in the template layout.

**Evidence:** expected `src/upgrade.js`; found `upgrade.js` at the root.

**Fix:** move it to `src/upgrade.js` (see C5).

### C9: Repository URL in package.json lacks the .git suffix

- **Source:** 🤖 validate-template (PKG-REPO)
- **Classification:** 🆕 NEW
- **File:** [`package.json:17`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/package.json#L17)

**What goes wrong:** The repository URL in `package.json` does not match the form the template uses (and that `companion/manifest.json` already uses).

**Why it happens:** `repository.url` ends without `.git`.

**Evidence:** found `git+https://github.com/bitfocus/companion-module-uniliga-cg`; expected `git+https://github.com/bitfocus/companion-module-uniliga-cg.git`.

**Fix:** add the `.git` suffix.

```json
"url": "git+https://github.com/bitfocus/companion-module-uniliga-cg.git"
```

### C10: package.json does not declare the supported Node and Yarn versions

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/package.json)

**What goes wrong:** Developers can install and build the module with any Node or Yarn version without a warning.

**Why it happens:** The template's `engines` field is missing.

**Evidence:** missing required field `engines` (present in template).

**Fix:** add the template's `engines` block.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
}
```

### C11: package.json pins Yarn 1 instead of Yarn 4

- **Source:** 🤖 validate-template (PKG-YARN)
- **Classification:** 🆕 NEW
- **File:** [`package.json:23`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/package.json#L23)

**What goes wrong:** Corepack runs the legacy Yarn 1 for this module, while the template and the Companion build tooling expect Yarn 4.

**Why it happens:** `packageManager` names Yarn 1.22.22.

**Evidence:** found `yarn@1.22.22+sha512.a6b2…3137e`; expected a value starting with `yarn@4`.

**Fix:** switch to Yarn 4 (the template uses `yarn@4.12.0`), add `.yarnrc.yml` ([C4](#c4-yarn-4-settings-are-missing-because-yarnrcyml-is-missing)) and regenerate `yarn.lock` with `yarn install`.

```json
"packageManager": "yarn@4.12.0"
```

### C12: There is no package script, so the module cannot be packaged

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-9`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/package.json#L6-L9)

**What goes wrong:** `yarn package` does nothing useful, so neither the maintainer nor the Bitfocus build can produce the installable `.tgz` (see [C15](#c15-yarn-package-fails-so-no-installable-package-can-be-built)).

**Why it happens:** The template's `package` script, which runs `companion-module-build`, is missing.

**Evidence:** missing required script `package`.

**Fix:** add the template's script.

```json
"package": "companion-module-build"
```

### C13: Prettier is not a devDependency, so yarn format relies on a global install

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:19-21`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/package.json#L19-L21)

**What goes wrong:** The `format` script calls `prettier`, but a fresh install does not provide it directly, so formatting depends on whatever happens to be installed.

**Why it happens:** The template lists `prettier` as a devDependency; this module does not.

**Evidence:** missing devDependency `prettier` (present in template).

**Fix:** add Prettier as a devDependency.

```json
"prettier": "^3.7.4"
```

### C14: The module runs on Node 18 instead of Node 22

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/companion/manifest.json#L20)

**What goes wrong:** Companion starts the module on the end-of-life Node 18 runtime instead of Node 22, which the template and current Companion releases use.

**Why it happens:** `runtime.type` in the manifest is `node18`.

**Evidence:** found `node18`; expected `node22`.

**Fix:** set the runtime to Node 22.

```json
"type": "node22"
```

### C15: yarn package fails, so no installable package can be built

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/package.json)

**What goes wrong:** Running `yarn package` fails, so no `.tgz` that Companion can install is produced from this release.

**Why it happens:** It follows from the missing `package` script ([C12](#c12-there-is-no-package-script-so-the-module-cannot-be-packaged)) and the Yarn 1 `packageManager` ([C11](#c11-packagejson-pins-yarn-1-instead-of-yarn-4)).

**Evidence:** `yarn package` (build) failed.

**Fix:** fix C11 and C12 (and C4), run `yarn install`, then confirm `yarn package` produces the package.

## 🟢 Low

### L1: Existing Restart Timer buttons keep the old invalid option value

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:377-389`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/main.js#L377-L389)

**What goes wrong:** Anyone who added a "Restart Timer" action in v1.1.1 got the stored option value `start`, because the old default was `start` while the only choice was "Restart". After upgrading, those buttons still show an Action dropdown value that is not in the list, and still send `companion_timer_state` with data `start`. Only newly added actions get `restart`.

**Why it happens:** This release changes the default from `start` to `restart`, but no upgrade script rewrites the stored value. [`upgrade.js`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/upgrade.js) only adds the index to "Set Graphic State" actions and "Graphic visible" feedbacks.

```js
// main.js:377-388
timer_state: {
	name: 'Restart Timer',
	options: [
		{
			id: 'action',
			label: 'Action',
			type: 'dropdown',
			default: 'restart',
			choices: [{ id: 'restart', label: 'Restart' }],
		},
	],
	callback: (action) => this.sendCommand('companion_timer_state', action.options.action),
```

**Fix:** add an upgrade script that rewrites `start` to `restart` for `timer_state` actions, or drop the option and always send `restart`, since it is the only choice.

```js
props.actions.forEach((action) => {
	if (action.actionId === 'timer_state' && action.options.action === 'start') {
		action.options.action = 'restart'
		result.updatedActions.push(action)
	}
})
```

### L2: Presets keep the old connection name after the connection is renamed

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:77`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/main.js#L77), [`main.js:89-92`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/main.js#L89-L92), [`presets.js:23-24`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/presets.js#L23-L24)

**What goes wrong:** A user adds the connection as "uniliga-cg" and later renames it to "cg". The new presets under Presets > Score / Match / Bugs were built at startup with text such as `$(uniliga-cg:left_short)` and `$(uniliga-cg:caster_0_name)`. A preset such as "Score Links +1" dragged in after the rename shows that literal text or nothing instead of the team short name and score, until the module restarts (disable and enable the connection, or restart Companion).

**Why it happens:** The presets put the connection name into their button text, but the module only builds them once, in `init()`. A rename reaches the module as a config/label update that calls `configUpdated()` (see [A1](#-assumptions-to-confirm)), and `configUpdated()` only reconnects the WebSocket; it never rebuilds the presets.

```js
// main.js:77
this.setPresetDefinitions(presets(this.label))
// main.js:89-92
async configUpdated(config) {
	this.config = config
	this.initWebSocket()
}
```

**Fix:** rebuild the presets in `configUpdated()` so they pick up the new name.

```js
async configUpdated(config) {
	this.config = config
	this.setPresetDefinitions(presets(this.label))
	this.initWebSocket()
}
```

## 💡 Nice to Have

### N1: Graphic choices, preset names and variable names mix German and English

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`state.js:3-15`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/state.js#L3-L15), [`state.js:92-170`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/state.js#L92-L170), [`presets.js`](https://github.com/bitfocus/companion-module-uniliga-cg/blob/9468691d5ec07de411e93efe95b8b8b21f3c86dd/presets.js)

**What goes wrong:** In the "Set Graphic State" action and the "Graphic visible" feedback, the Graphic dropdown mixes "Schedule" and "Roster" with "Tabelle", "TFT Lobbys" and "TFT Leiste". The variable list shows names such as "Aktuelles Match: Uhrzeit" and "Links: Teamkürzel", and the presets appear under "Grafiken" with names such as "Seiten tauschen" and "Nächstes Match". The actions, feedbacks, options, config and HELP.md are in English, so an English-speaking operator sees two languages in one module. Nothing breaks.

**Why it happens:** The new labels in `GRAPHICS`, the variable `name` strings and the preset categories and names were written in German.

**Fix:** pick one language for all user-facing text (English matches the rest of the module). Translate the `GRAPHICS` labels, the variable names in `state.js`, and the preset categories, names and texts in `presets.js`. Variable IDs and option IDs can stay the same, so no upgrade script is needed.
