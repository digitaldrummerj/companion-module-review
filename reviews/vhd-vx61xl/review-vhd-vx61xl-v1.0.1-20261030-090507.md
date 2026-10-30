# Review: companion-module-vhd-vx61xl v1.0.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-vhd-vx61xl](https://github.com/bitfocus/companion-module-vhd-vx61xl) |
| **Scope** | `tag` |
| **Version** | `v1.0.1` (commit [`29ebd57`](https://github.com/bitfocus/companion-module-vhd-vx61xl/commit/29ebd57ab71aeacabbe34e8339e898676bd3d494)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review basis** | First release: there is no previous published tag to diff against, so the whole module was reviewed |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion names a new connection after the manifest `shortname` (`vx61xl`), not the module id (`vhd-vx61xl`), so a variable typed as `$(vhd-vx61xl:connection_status)` does not resolve unless the user renames the connection | Companion host behaviour as the reviewers know it; not verifiable from the module or the base package | [M1](#m1-the-connection-status-preset-shows-na-instead-of-the-connection-state), [L3](#l3-the-help-page-gives-a-variable-name-that-does-not-match-a-new-connection) |
| A2 | Companion does **not** rewrite the hard-coded `$(vhd-vx61xl:…)` prefix in preset button text to the connection's real label when the preset is placed on a button. The reviewers disagree: the QA reviewer assumes no rewrite (so the preset shows `$NA`); the compliance reviewer assumes Companion does rewrite it (so the preset works) | Companion's preset handling; not verifiable from the module or the base package | [M1](#m1-the-connection-status-preset-shows-na-instead-of-the-connection-state) |
| A3 | A VISCA error reply from this camera has the standard `y0 6z … FF` form | The standard VISCA protocol; the module does not parse replies, so the VHD reply format could not be checked in code | [N1](#n1-commands-the-camera-rejects-look-successful) |

## 📋 Issues

### Blocking

- [ ] [C1: The module cannot be packaged, so it cannot be built for release](#c1-the-module-cannot-be-packaged-so-it-cannot-be-built-for-release)
- [ ] [C2: package.json has no package script](#c2-packagejson-has-no-package-script)
- [ ] [C3: Source file main.js sits at the module root instead of src](#c3-source-file-mainjs-sits-at-the-module-root-instead-of-src)
- [ ] [C4: Source file actions.js sits at the module root instead of src](#c4-source-file-actionsjs-sits-at-the-module-root-instead-of-src)
- [ ] [C5: Source file feedbacks.js sits at the module root instead of src](#c5-source-file-feedbacksjs-sits-at-the-module-root-instead-of-src)
- [ ] [C6: Source file presets.js sits at the module root instead of src](#c6-source-file-presetsjs-sits-at-the-module-root-instead-of-src)
- [ ] [C7: Source file upgrades.js sits at the module root instead of src](#c7-source-file-upgradesjs-sits-at-the-module-root-instead-of-src)
- [ ] [C8: Source file visca.js sits at the module root instead of src](#c8-source-file-viscajs-sits-at-the-module-root-instead-of-src)
- [ ] [C9: package.json has no engines field](#c9-packagejson-has-no-engines-field)
- [ ] [C10: package.json has no packageManager field](#c10-packagejson-has-no-packagemanager-field)
- [ ] [C11: package.json has no prettier field](#c11-packagejson-has-no-prettier-field)
- [ ] [C12: package.json has no format script](#c12-packagejson-has-no-format-script)
- [ ] [C13: prettier is missing from devDependencies](#c13-prettier-is-missing-from-devdependencies)
- [ ] [C14: Missing .yarnrc.yml file](#c14-missing-yarnrcyml-file)
- [ ] [C15: Missing .gitattributes file](#c15-missing-gitattributes-file)
- [ ] [C16: Missing .prettierignore file](#c16-missing-prettierignore-file)
- [ ] [C17: The .gitignore file misses the template's Yarn and debug entries](#c17-the-gitignore-file-misses-the-templates-yarn-and-debug-entries)
- [ ] [H1: LICENSE copyright line differs from the template](#h1-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [M1: The Connection status preset shows $NA instead of the connection state](#m1-the-connection-status-preset-shows-na-instead-of-the-connection-state)
- [ ] [L1: The Connection status variable keeps showing Connected after the camera IP is cleared](#l1-the-connection-status-variable-keeps-showing-connected-after-the-camera-ip-is-cleared)
- [ ] [L2: Action names and value labels contain developer notes and raw hex](#l2-action-names-and-value-labels-contain-developer-notes-and-raw-hex)
- [ ] [L3: The help page gives a variable name that does not match a new connection](#l3-the-help-page-gives-a-variable-name-that-does-not-match-a-new-connection)
- [ ] [N1: Commands the camera rejects look successful](#n1-commands-the-camera-rejects-look-successful)
- [ ] [N2: Buttons can only show whether the camera is connected](#n2-buttons-can-only-show-whether-the-camera-is-connected)
- [ ] [R1: Plan the move to the v2 Companion module API](#r1-plan-the-move-to-the-v2-companion-module-api)

## 🔴 Critical

### C1: The module cannot be packaged, so it cannot be built for release

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json)

**What goes wrong:** Bitfocus builds every release by running `yarn package`, which produces the `.tgz` that Companion installs. For this module the command fails, so no installable package can be built and the release cannot be published.

**Why it happens:** `yarn install --immutable` succeeds, but `package.json` has no `package` script (its `scripts` holds only `test`), so `yarn package` has nothing to run. See [C2](#c2-packagejson-has-no-package-script).

**Evidence:** expected `yarn package` to succeed; found the command fails because the script does not exist.

**Fix:** add the template's `package` script (C2); once the source is under `src/` (C3–C8) the build should pass. Run `yarn package` locally to confirm.

### C2: package.json has no package script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:13-15`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json#L13-L15)

**What goes wrong:** Without this script the release build fails (C1).

**Why it happens:** The template's `scripts` block defines `"package": "companion-module-build"`; the module's only script is `test`.

**Evidence:** template `"package": "companion-module-build"`; module has none.

**Fix:** add the script.

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
}
```

### C3: Source file main.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`main.js`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/main.js)

**What goes wrong:** The module does not follow the template's layout, where all source lives under `src/`. The build tooling and anyone maintaining the module later expect that layout.

**Why it happens:** All six source files sit at the repository root.

**Evidence:** template has `src/main.js`; module has `main.js` at the root.

**Fix:** move all six source files (`main.js`, `actions.js`, `feedbacks.js`, `presets.js`, `upgrades.js`, `visca.js`) into `src/`. Then point both entry references at the new location: `package.json` `main` (now `main.js`, see [`package.json:4`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json#L4)) and the manifest `runtime.entrypoint` (now `../main.js`, see [`companion/manifest.json:22`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/companion/manifest.json#L22)).

```jsonc
// package.json
"main": "src/main.js",
// companion/manifest.json
"entrypoint": "../src/main.js"
```

### C4: Source file actions.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`actions.js`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/actions.js)

**What goes wrong:** Same as [C3](#c3-source-file-mainjs-sits-at-the-module-root-instead-of-src): all source must be under `src/`.

**Fix:** move it to `src/actions.js` (see C3).

### C5: Source file feedbacks.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`feedbacks.js`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/feedbacks.js)

**What goes wrong:** Same as [C3](#c3-source-file-mainjs-sits-at-the-module-root-instead-of-src): all source must be under `src/`.

**Fix:** move it to `src/feedbacks.js` (see C3).

### C6: Source file presets.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`presets.js`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/presets.js)

**What goes wrong:** Same as [C3](#c3-source-file-mainjs-sits-at-the-module-root-instead-of-src): all source must be under `src/`.

**Fix:** move it to `src/presets.js` (see C3).

### C7: Source file upgrades.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`upgrades.js`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/upgrades.js)

**What goes wrong:** Same as [C3](#c3-source-file-mainjs-sits-at-the-module-root-instead-of-src): all source must be under `src/`.

**Fix:** move it to `src/upgrades.js` (see C3).

### C8: Source file visca.js sits at the module root instead of src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`visca.js`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/visca.js)

**What goes wrong:** Same as [C3](#c3-source-file-mainjs-sits-at-the-module-root-instead-of-src): all source must be under `src/`.

**Fix:** move it to `src/visca.js` (see C3).

### C9: package.json has no engines field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json)

**What goes wrong:** Nothing pins the Node and Yarn versions the module is built with, so a build can run on a version the template does not support.

**Evidence:** template has `"engines": { "node": "^22.20", "yarn": "^4" }`; module has no `engines` field.

**Fix:** add the template's field.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
}
```

### C10: package.json has no packageManager field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json)

**What goes wrong:** Corepack cannot select the Yarn version the template uses, so contributors and the build can use a different package manager version.

**Evidence:** template has `"packageManager": "yarn@4.12.0"`; module has none.

**Fix:** add `"packageManager": "yarn@4.12.0"`.

### C11: package.json has no prettier field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json)

**What goes wrong:** Formatting does not use the shared Companion Prettier config.

**Evidence:** template has `"prettier": "@companion-module/tools/.prettierrc.json"`; module has none.

**Fix:** add `"prettier": "@companion-module/tools/.prettierrc.json"`.

### C12: package.json has no format script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:13-15`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json#L13-L15)

**What goes wrong:** There is no `yarn format` command to apply the shared code style.

**Evidence:** template has `"format": "prettier -w ."`; module has none.

**Fix:** add the script (see the block in C2).

### C13: prettier is missing from devDependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:10-12`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json#L10-L12)

**What goes wrong:** The `format` script (C12) cannot run without Prettier installed.

**Evidence:** template has `"prettier": "^3.7.4"` in `devDependencies`; module has only `@companion-module/tools`.

**Fix:** `yarn add -D prettier@^3.7.4`.

### C14: Missing .yarnrc.yml file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Yarn 4 runs without the template's settings: install scripts are not disabled, packages are not installed into `node_modules`, and the minimum package age gate is not applied.

**Evidence:** template has `.yarnrc.yml`; module has none.

**Fix:** copy the file from `companion-module-template-js`.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C15: Missing .gitattributes file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Line endings are not normalised, so a checkout on Windows can commit CRLF line endings.

**Evidence:** template has `.gitattributes` with `* text=auto eol=lf`; module has none.

**Fix:** add `.gitattributes` containing `* text=auto eol=lf`.

### C16: Missing .prettierignore file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore` (missing)

**What goes wrong:** Once Prettier is added (C12, C13), `yarn format` would also rewrite `package.json` and the license file.

**Evidence:** template has `.prettierignore` listing `package.json` and `/LICENSE.md`; module has none.

**Fix:** copy `.prettierignore` from the template.

```text
package.json
/LICENSE.md
```

### C17: The .gitignore file misses the template's Yarn and debug entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/.gitignore)

**What goes wrong:** Yarn's local `.yarn` folder and `DEBUG-*` files can be committed by accident.

**Evidence:** template entries missing: `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`. The module has `node_modules/`, `pkg/`, `*.tgz` and `package-lock.json`.

**Fix:** replace the file with the template's `.gitignore`.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

## 🟠 High

### H1: LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/LICENSE#L3)

**What goes wrong:** The license file does not match the one Bitfocus modules ship with.

**Evidence:** line 3 found `Copyright (c) 2026 AP Audiovisuele Producties`; template `Copyright (c) 2022 Bitfocus AS - Open Source`.

**Fix:** use the template's `LICENSE` file unchanged.

## 🟡 Medium

### M1: The Connection status preset shows $NA instead of the connection state

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`presets.js:62`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/presets.js#L62)

**What goes wrong:** A user adds the connection, drags the "Status > Connection status" preset onto a button and expects "VX61XL / Connected". The button shows "VX61XL / $NA" instead; only the green background from the "Camera connected" feedback works. Depends on [A1](#-assumptions-to-confirm) and [A2](#-assumptions-to-confirm).

**Why it happens:** The preset text names the variable with a fixed prefix, `vhd-vx61xl`. Companion prefixes variables with the connection's label, which defaults to the manifest shortname `vx61xl` and can be renamed by the user (for example `cam1`), so the fixed name matches no variable.

**Fix:** build the text from the connection's label, which `getPresetDefinitions(instance)` already receives, and re-send the presets in `configUpdated()` so they follow a renamed connection.

```js
style: { ...basicStyle, text: `VX61XL\\n$(${instance.label}:connection_status)` },
```

## 🟢 Low

### L1: The Connection status variable keeps showing Connected after the camera IP is cleared

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:107-112`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/main.js#L107-L112), [`main.js:170-177`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/main.js#L170-L177)

**What goes wrong:** A user shows the "Connection status" variable on a button. They clear "Camera IP address" in the connection settings and save. The connection status in Companion correctly turns to Bad Configuration ("No camera IP configured") and the "Camera connected" feedback turns off, but the button text still reads "Connected". On a new connection added with no IP, it stays at "Connecting".

**Why it happens:** The no-IP branch of `initConnection()` updates the status and the feedback but never sets the variable. `destroyConnection()` does not reset it either, and `destroySocket()` removes the old socket's listeners before closing it, so the "close" handler that would set "Disconnected" never runs.

**Fix:** set the variable in the no-IP branch.

```js
if (!this.config?.host) {
	this.badConfig = true
	this.setConnected(false)
	this.updateStatus(InstanceStatus.BadConfig, 'No camera IP configured')
	this.setVariableValues({ connection_status: 'No camera IP configured' })
	return
}
```

### L2: Action names and value labels contain developer notes and raw hex

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:37-51`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/actions.js#L37-L51), [`actions.js:74`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/actions.js#L74), [`actions.js:158`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/actions.js#L158), [`actions.js:163`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/actions.js#L163), [`actions.js:207`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/actions.js#L207), [`actions.js:222-230`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/actions.js#L222-L230)

**What goes wrong:** In the action picker users see names like "Gain (0-255, finer table on this model)", "Exposure: Compensation (0-255, raw pq)", "Color Temperature (raw index, 0-255, mapping not documented for this model)" and "Address Set (broadcast, 88 30 01 FF)". The value field inside each action repeats that whole sentence as its label. Nothing breaks; the UI is just hard to scan.

**Why it happens:** The `numberAction`, `byteAction` and `choiceAction` helpers reuse the full action name as the option label, and the names carry encoding notes that belong in comments or help text.

**Fix:** use short names ("Gain", "Exposure Compensation", "Color Temperature", "Address Set (broadcast)"), give the option a short label such as "Value", and move range and encoding notes into the option's `description` or into HELP.md.

### L3: The help page gives a variable name that does not match a new connection

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:14-15`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/companion/HELP.md#L14-L15)

**What goes wrong:** HELP.md tells users the status is available as `$(vhd-vx61xl:connection_status)`. A user who copies that onto a button gets an unknown variable, because a new connection is named `vx61xl` by default (or whatever the user renames it to). Depends on [A1](#-assumptions-to-confirm).

**Why it happens:** The help text uses the module id where Companion uses the connection's label.

**Fix:** write it as `$(<connection label>:connection_status)` and add that the label is the name shown in the Connections list, `vx61xl` by default.

## 💡 Nice to Have

### N1: Commands the camera rejects look successful

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:154-157`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/main.js#L154-L157)

**What goes wrong:** A user presses a button with, for example, "Tracking: Mode" on a camera model that does not support it. The camera answers with a VISCA error (for example `90 60 02 FF`, syntax error), but Companion shows nothing at the default log level and the status stays OK, so the user can't tell why the camera did not react. Depends on [A3](#-assumptions-to-confirm).

**Why it happens:** The socket's data handler only logs each reply as hex at debug level and never reads it; the code comment says reply parsing is planned for later.

**Fix:** scan incoming data for VISCA error replies (second byte `0x60`–`0x6F`) and log them at `warn` with the error code (02 syntax error, 03 buffer full, 04 cancelled, 05 no socket, 41 not executable). Keep ACK and completion replies at debug.

### N2: Buttons can only show whether the camera is connected

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`feedbacks.js:3-16`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/feedbacks.js#L3-L16)

**What goes wrong:** The only feedback is "Camera connected". A user cannot light a button to show the last recalled preset, tally colour, power or tracking state. HELP.md lists this as a known limitation, and the first-release requirement of at least one feedback is met.

**Why it happens:** The module sends no VISCA inquiries and keeps no device state that feedbacks could read.

**Fix:** in a future release, track the state the module sets itself (last recalled preset, tally colour, tracking on/off) and expose it as boolean feedbacks and variables; where the camera supports inquiries, parse the replies.

## 🔮 Next Release

### R1: Plan the move to the v2 Companion module API

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-9`](https://github.com/bitfocus/companion-module-vhd-vx61xl/blob/29ebd57ab71aeacabbe34e8339e898676bd3d494/package.json#L7-L9)

**What goes wrong:** Nothing breaks today; the module uses base 1.14.1, the latest v1. New API features (expressions among them) land in `@companion-module/base` v2 (Companion 4.3+ / 5.0+).

**Why it happens:** The module declares the v1 range `"@companion-module/base": "^1.11.0"`.

**Fix:** in a future release, migrate to `@companion-module/base` v2. Until then, consider the template's range `~1.14.1` so it matches the locked version.
