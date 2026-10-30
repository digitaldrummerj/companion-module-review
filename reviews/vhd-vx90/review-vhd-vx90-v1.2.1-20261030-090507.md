# Review: companion-module-vhd-vx90 v1.2.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-vhd-vx90](https://github.com/bitfocus/companion-module-vhd-vx90) |
| **Scope** | `tag` (first release: there is no previous tag to diff against, so the whole module was reviewed) |
| **Version** | v1.2.1 |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`07f04db`](https://github.com/bitfocus/companion-module-vhd-vx90/tree/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A new connection of this module gets the default label `vx90` (from the manifest `shortname`), so its variables are named `$(vx90:...)` | Companion host behaviour for default connection labels; not checked in the module or base | [L1](#l1-the-connection-status-variable-keeps-old-text-when-the-camera-ip-is-cleared), [L2](#l2-colour-matrix-variables-change-even-when-the-camera-never-received-the-command) |

## 📋 Issues

### Blocking

- [ ] [C1: Line endings are not normalised because `.gitattributes` is missing](#c1-line-endings-are-not-normalised-because-gitattributes-is-missing)
- [ ] [C2: `.gitignore` does not match the template, so Yarn and debug files can be committed](#c2-gitignore-does-not-match-the-template-so-yarn-and-debug-files-can-be-committed)
- [ ] [C3: Prettier would reformat `package.json` because `.prettierignore` is missing](#c3-prettier-would-reformat-packagejson-because-prettierignore-is-missing)
- [ ] [C4: Yarn's safety settings are not applied because `.yarnrc.yml` is missing](#c4-yarns-safety-settings-are-not-applied-because-yarnrcyml-is-missing)
- [ ] [C5: `actions.js` is at the module root instead of `src/`](#c5-actionsjs-is-at-the-module-root-instead-of-src)
- [ ] [C6: `feedbacks.js` is at the module root instead of `src/`](#c6-feedbacksjs-is-at-the-module-root-instead-of-src)
- [ ] [C7: `main.js` is at the module root instead of `src/`](#c7-mainjs-is-at-the-module-root-instead-of-src)
- [ ] [C8: `presets.js` is at the module root instead of `src/`](#c8-presetsjs-is-at-the-module-root-instead-of-src)
- [ ] [C9: `upgrades.js` is at the module root instead of `src/`](#c9-upgradesjs-is-at-the-module-root-instead-of-src)
- [ ] [C10: `visca.js` is at the module root instead of `src/`](#c10-viscajs-is-at-the-module-root-instead-of-src)
- [ ] [C11: `package.json` has no `engines` field, so the Node and Yarn versions are not declared](#c11-packagejson-has-no-engines-field-so-the-node-and-yarn-versions-are-not-declared)
- [ ] [C12: `package.json` has no `prettier` field, so formatting doesn't use the Companion style](#c12-packagejson-has-no-prettier-field-so-formatting-doesnt-use-the-companion-style)
- [ ] [C13: `package.json` has no `packageManager`, so Yarn falls back to classic 1.22](#c13-packagejson-has-no-packagemanager-so-yarn-falls-back-to-classic-122)
- [ ] [C14: `package.json` has no `format` script](#c14-packagejson-has-no-format-script)
- [ ] [C15: `package.json` has no `package` script, so the module cannot be packaged](#c15-packagejson-has-no-package-script-so-the-module-cannot-be-packaged)
- [ ] [C16: `prettier` is not a devDependency](#c16-prettier-is-not-a-devdependency)
- [ ] [C17: Packaging the module fails](#c17-packaging-the-module-fails)
- [ ] [H1: The LICENSE copyright line differs from the template](#h1-the-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [L1: The connection status variable keeps old text when the camera IP is cleared](#l1-the-connection-status-variable-keeps-old-text-when-the-camera-ip-is-cleared)
- [ ] [L2: Colour matrix variables change even when the camera never received the command](#l2-colour-matrix-variables-change-even-when-the-camera-never-received-the-command)
- [ ] [L3: The fan speed action hides its "Manual speed" field with a deprecated option](#l3-the-fan-speed-action-hides-its-manual-speed-field-with-a-deprecated-option)
- [ ] [N1: Unused speed choices helper in the actions file](#n1-unused-speed-choices-helper-in-the-actions-file)
- [ ] [F1: Plan the move to Companion module API 2](#f1-plan-the-move-to-companion-module-api-2)

## 🔴 Critical

### C1: Line endings are not normalised because `.gitattributes` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor on Windows can commit files with CRLF line endings, so later diffs show whole files as changed and formatting checks disagree between machines.

**Why it happens:** The template ships a `.gitattributes` that tells Git to store every text file with LF endings. The module doesn't have the file.

**Evidence:** template `companion-module-template-js-v1/.gitattributes` contains `* text=auto eol=lf`; the module has no `.gitattributes`.

**Fix:** add the template's `.gitattributes` unchanged.

```text
* text=auto eol=lf
```

### C2: `.gitignore` does not match the template, so Yarn and debug files can be committed

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/.gitignore)

**What goes wrong:** Once the module moves to Yarn 4 (see [C13](#c13-packagejson-has-no-packagemanager-so-yarn-falls-back-to-classic-122)), the `.yarn/` folder and any `DEBUG-*` log files show up as untracked files and can be committed by accident.

**Why it happens:** The module's `.gitignore` lists `node_modules/`, `pkg/`, `*.tgz` and `package-lock.json`. The template's entries `/pkg`, `/*.tgz`, `DEBUG-*` and `/.yarn` are missing.

**Evidence:** expected (template) `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`; found `node_modules/`, `pkg/`, `*.tgz`, `package-lock.json`.

**Fix:** replace `.gitignore` with the template's version.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C3: Prettier would reformat `package.json` because `.prettierignore` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore` (missing)

**What goes wrong:** Running the template's `format` script (see [C14](#c14-packagejson-has-no-format-script)) rewrites `package.json`, which the template deliberately leaves alone.

**Why it happens:** The template ships a `.prettierignore` that excludes `package.json` and `/LICENSE.md` from formatting. The module doesn't have the file.

**Evidence:** template `companion-module-template-js-v1/.prettierignore` contains `package.json` and `/LICENSE.md`; the module has no `.prettierignore`.

**Fix:** add the template's `.prettierignore` unchanged.

```text
package.json
/LICENSE.md
```

### C4: Yarn's safety settings are not applied because `.yarnrc.yml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Installing the module's dependencies can run package install scripts, and can pull a package version published minutes earlier, which is how supply-chain attacks spread. Yarn 4 would also install into Plug'n'Play mode instead of `node_modules`.

**Why it happens:** The template's `.yarnrc.yml` turns off install scripts, sets a 3-day minimum package age and uses the `node-modules` linker. The module has no `.yarnrc.yml`.

**Evidence:** template `companion-module-template-js/.yarnrc.yml` (main @ `76d25b2`); the module has no `.yarnrc.yml`.

**Fix:** add the template's `.yarnrc.yml` unchanged.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C5: `actions.js` is at the module root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`actions.js`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/actions.js)

**What goes wrong:** The module's layout differs from every other module built on the template, so tooling and other maintainers look for the source in `src/` and don't find it.

**Why it happens:** The template keeps all source under `src/` (its `package.json` `main` is `src/main.js`). This module keeps its source files at the repository root.

**Evidence:** expected `src/actions.js`; found `actions.js` at the root.

**Fix:** move all six source files (`actions.js`, `feedbacks.js`, `main.js`, `presets.js`, `upgrades.js`, `visca.js`, [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src) to [C10](#c10-viscajs-is-at-the-module-root-instead-of-src)) into `src/`. Then set `"main": "src/main.js"` in `package.json` and `"entrypoint": "../src/main.js"` in [`companion/manifest.json`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/companion/manifest.json). The relative `require('./...')` paths between the files stay the same.

### C6: `feedbacks.js` is at the module root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`feedbacks.js`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/feedbacks.js)

**What goes wrong:** Same as [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src): the source is not where the template puts it.

**Why it happens:** The template keeps all source under `src/`.

**Evidence:** expected `src/feedbacks.js`; found `feedbacks.js` at the root.

**Fix:** move it to `src/feedbacks.js` (see the [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src) fix).

### C7: `main.js` is at the module root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`main.js`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/main.js)

**What goes wrong:** Same as [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src): the source is not where the template puts it.

**Why it happens:** The template keeps all source under `src/`, and its entrypoint is `src/main.js`.

**Evidence:** expected `src/main.js`; found `main.js` at the root (`package.json` `"main": "main.js"`, manifest `"entrypoint": "../main.js"`).

**Fix:** move it to `src/main.js` and update `package.json` `main` and the manifest `entrypoint` (see the [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src) fix).

### C8: `presets.js` is at the module root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`presets.js`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/presets.js)

**What goes wrong:** Same as [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src): the source is not where the template puts it.

**Why it happens:** The template keeps all source under `src/`.

**Evidence:** expected `src/presets.js`; found `presets.js` at the root.

**Fix:** move it to `src/presets.js` (see the [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src) fix).

### C9: `upgrades.js` is at the module root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`upgrades.js`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/upgrades.js)

**What goes wrong:** Same as [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src): the source is not where the template puts it.

**Why it happens:** The template keeps all source under `src/`.

**Evidence:** expected `src/upgrades.js`; found `upgrades.js` at the root.

**Fix:** move it to `src/upgrades.js` (see the [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src) fix).

### C10: `visca.js` is at the module root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`visca.js`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/visca.js)

**What goes wrong:** Same as [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src): the source is not where the template puts it.

**Why it happens:** The template keeps all source under `src/`.

**Evidence:** expected `src/visca.js`; found `visca.js` at the root.

**Fix:** move it to `src/visca.js` (see the [C5](#c5-actionsjs-is-at-the-module-root-instead-of-src) fix).

### C11: `package.json` has no `engines` field, so the Node and Yarn versions are not declared

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json:1-16`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L1-L16)

**What goes wrong:** Nothing stops a contributor or the build from using a Node or Yarn version the module was never meant to run on.

**Why it happens:** The template declares the supported Node and Yarn versions in `engines`. The module's `package.json` has no `engines` field.

**Evidence:** expected (template) `"engines": { "node": "^22.20", "yarn": "^4" }`; found no `engines` field.

**Fix:** add the template's `engines` block.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
},
```

### C12: `package.json` has no `prettier` field, so formatting doesn't use the Companion style

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json:1-16`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L1-L16)

**What goes wrong:** Formatting the code applies Prettier's defaults instead of the shared Companion style (tabs, no semicolons, single quotes), so a format run would rewrite most of the module.

**Why it happens:** The template points Prettier at the shared config in `@companion-module/tools` through the `prettier` field. The module's `package.json` has no such field.

**Evidence:** expected (template) `"prettier": "@companion-module/tools/.prettierrc.json"`; found no `prettier` field.

**Fix:** add the field.

```json
"prettier": "@companion-module/tools/.prettierrc.json",
```

### C13: `package.json` has no `packageManager`, so Yarn falls back to classic 1.22

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json:1-16`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L1-L16)

**What goes wrong:** Running `yarn` in the module uses Yarn classic 1.22.22 instead of Yarn 4, so the lockfile format, install behaviour and the `.yarnrc.yml` settings (see [C4](#c4-yarns-safety-settings-are-not-applied-because-yarnrcyml-is-missing)) don't match the template.

**Why it happens:** Corepack picks the Yarn version from the `packageManager` field. The module's `package.json` has none.

**Evidence:** expected (template) `"packageManager": "yarn@4.12.0"`; found no `packageManager` field (the module's yarn resolved to classic 1.22.22 during validation).

**Fix:** add the field, then run `yarn install` with Yarn 4 to regenerate `yarn.lock` and commit it.

```json
"packageManager": "yarn@4.12.0"
```

### C14: `package.json` has no `format` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:13-15`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L13-L15)

**What goes wrong:** Contributors have no `yarn format` command to format the code the way every other template-based module does.

**Why it happens:** The module's `scripts` only contains a placeholder `test` script.

**Evidence:** expected (template) `"format": "prettier -w ."`; found `"scripts": { "test": "echo \"no tests yet\"" }`.

**Fix:** add the script (together with [C15](#c15-packagejson-has-no-package-script-so-the-module-cannot-be-packaged)).

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
},
```

### C15: `package.json` has no `package` script, so the module cannot be packaged

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:13-15`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L13-L15)

**What goes wrong:** `yarn package` fails, so the module can't be built into the `.tgz` package that Companion installs (see [C17](#c17-packaging-the-module-fails)).

**Why it happens:** The template's `package` script runs `companion-module-build`. The module's `scripts` has no `package` entry.

**Evidence:** expected (template) `"package": "companion-module-build"`; found `"scripts": { "test": "echo \"no tests yet\"" }`.

**Fix:** add `"package": "companion-module-build"` to `scripts` (see the [C14](#c14-packagejson-has-no-format-script) fix).

### C16: `prettier` is not a devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:10-12`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L10-L12)

**What goes wrong:** The `format` script (see [C14](#c14-packagejson-has-no-format-script)) can't run, because Prettier isn't installed with the module.

**Why it happens:** The template lists `prettier` in `devDependencies`. The module only lists `@companion-module/tools`.

**Evidence:** expected (template) `"prettier": "^3.7.4"` in `devDependencies`; found only `"@companion-module/tools": "^2.6.1"`.

**Fix:** add Prettier as a devDependency.

```json
"devDependencies": {
	"@companion-module/tools": "^2.6.1",
	"prettier": "^3.7.4"
},
```

### C17: Packaging the module fails

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json:13-15`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L13-L15)

**What goes wrong:** The release build can't produce the module package, so this version can't be published to Companion users.

**Why it happens:** The build runs `yarn package`, and the module's `package.json` has no `package` script ([C15](#c15-packagejson-has-no-package-script-so-the-module-cannot-be-packaged)). The install step (`yarn install --immutable`) passed.

**Evidence:**

```text
$ yarn package
error Command "package" not found.
```

**Fix:** add the `package` script from [C15](#c15-packagejson-has-no-package-script-so-the-module-cannot-be-packaged), then run `yarn package` and confirm it produces a `.tgz`.

## 🟠 High

### H1: The LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/LICENSE#L3)

**What goes wrong:** The module's licence text doesn't match the one every Bitfocus-hosted module ships with.

**Why it happens:** Line 3 of `LICENSE` was changed from the template's copyright holder to the maintainer's company.

**Evidence:** expected (template) `Copyright (c) 2022 Bitfocus AS - Open Source`; found `Copyright (c) 2026 AP Audiovisuele Producties`.

**Confirm by:** open [`LICENSE:3`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/LICENSE#L3).

**Fix:** use the template's `LICENSE` unchanged.

## 🟢 Low

### L1: The connection status variable keeps old text when the camera IP is cleared

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:165-170`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/main.js#L165-L170), [`main.js:46-56`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/main.js#L46-L56), [`main.js:58-68`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/main.js#L58-L68)

**What goes wrong:** A user puts the "Connection status" preset on a button (it shows `$(vx90:connection_status)`). If they clear "Camera IP address" in the connection settings, the connection status correctly changes to Bad Config ("No camera IP configured"), but the button keeps saying "Connected". A brand-new connection with no IP set shows "Connecting" forever in the same way. The green "Camera connected" feedback turns off correctly, so only the text is wrong.

**Why it happens:** When no IP is set, the module reports Bad Config but never updates the `connection_status` variable, so the variable keeps whatever it held before. Saving the settings tears the old connection down after removing its event handlers, so the "close" handler that would have written "Disconnected" never runs.

**Fix:** set the variable in the same branch that reports Bad Config, and optionally set it back to "Connecting" whenever a new connection attempt starts.

```js
if (!this.config?.host) {
	this.badConfig = true
	this.setConnected(false)
	this.updateStatus(InstanceStatus.BadConfig, 'No camera IP configured')
	this.setVariableValues({ connection_status: 'No camera IP configured' })
	return
}
```

### L2: Colour matrix variables change even when the camera never received the command

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:601-607`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/actions.js#L601-L607), [`main.js:238-242`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/main.js#L238-L242)

**What goes wrong:** With firmware "V8.1.97 and newer" selected and the camera offline, each press of a "[V8.1.97+] Colour Matrix: step hue up/down" button (Axis Red, Up, step 1) still moves `$(vx90:cmatrix_red)` from 32 to 33, 34 and so on. The camera never got those commands. After it reconnects, the next step sends the drifted value (for example 36 instead of 33), so the colour jumps.

**Why it happens:** The step action remembers the last hue per axis and always sends an absolute value. It updates that remembered value and the variable before knowing whether the command went out. When the camera is not connected the send function only logs a warning and drops the command, without telling the caller.

**Fix:** make `sendBuffer()` return `true` when it sent and `false` when it dropped the command, and only update the remembered hue and the variable after a successful send.

```js
const setColorMatrix = (axisId, value) => {
	const v = clamp(value, COLOR_MATRIX_MIN, COLOR_MATRIX_MAX)
	if (!send([0x0a, 0x89, parseInt(axisId, 16), v & 0xff])) return instance.colorMatrixHue[axisId]
	instance.colorMatrixHue[axisId] = v
	if (axisVarId[axisId]) instance.setVariableValues({ [axisVarId[axisId]]: v })
	return v
}
```

### L3: The fan speed action hides its "Manual speed" field with a deprecated option

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:582`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/actions.js#L582)

**What goes wrong:** Nothing visible today: in "[V8.1.97+] Fan: set speed / auto", "Manual speed (% PWM)" correctly shows only when Mode is "Manual (set % below)". When the module moves to API 2, that way of hiding the field no longer exists, so the field would always show.

**Why it happens:** The option uses `isVisible`, a JavaScript function that `@companion-module/base` 1.14.1 marks as deprecated ("This will be removed in 2.0.0 of this api"). Its replacement, `isVisibleExpression`, is a Companion expression string and is already available in the installed base version.

**Fix:** replace the function with the expression.

```js
{ id: 'pwm', type: 'number', label: 'Manual speed (% PWM)', min: 0, max: 100, default: 50, isVisibleExpression: "$(options:mode) == 'manual'" },
```

## 💡 Nice to Have

### N1: Unused speed choices helper in the actions file

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:72-73`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/actions.js#L72-L73)

**What goes wrong:** No visible effect. The `speedChoices` helper is defined but never used, so it is dead code.

**Why it happens:** It is probably left over from an earlier version that offered speeds as dropdowns.

**Fix:** remove `speedChoices`.

## 🔮 Next Release

### F1: Plan the move to Companion module API 2

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-9`](https://github.com/bitfocus/companion-module-vhd-vx90/blob/07f04db2360b03bd6ba8856e3e9f3b5c0c2333d5/package.json#L7-L9)

**What goes wrong:** No visible effect now. The module runs on API 1.14 (installed 1.14.1, declared `^1.11.0`). API 2 (Companion 4.3+ / 5.0+) adds expression support in options and removes deprecated API 1 patterns such as the `isVisible` function in [L3](#l3-the-fan-speed-action-hides-its-manual-speed-field-with-a-deprecated-option).

**Why it happens:** The module was written against the API 1 template.

**Fix:** in a future release, migrate to `@companion-module/base` v2 using the Companion v1-to-v2 migration guide. Until then, raise the declared range to match the template (`~1.14.1`), since 1.14 is the version actually installed and tested.
