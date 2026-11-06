# Review: sony-bravia v2.2.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-sony-bravia](https://github.com/bitfocus/companion-module-sony-bravia) |
| **Scope** | `tag` (changes from v2.1.0 to v2.2.1) |
| **Version** | v2.2.1 ([`c3aa0d2`](https://github.com/bitfocus/companion-module-sony-bravia/commit/c3aa0d260e6431dd0287934d46ec9eac07d3be23)) |
| **Release** | Update — last published v2.1.0 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a user adds an action, Companion fills each option from its `default`. A dropdown with no `default` therefore starts as `undefined` and shows blank, instead of starting on its first choice | How Companion's action creation usually copies `option.default` into the new action. Not visible in the module or in `@companion-module/base` 1.14.1, which only passes the option definitions to the host (its typing marks `default` as required) | [M1](#m1-launch-app-sends-an-empty-launch-request-when-type-is-left-unselected) |
| A2 | Current Companion versions treat a button preset with no `feedbacks` field as having an empty list, so the App presets still load | Companion's preset conversion is not in the base package; base 1.14.1 forwards the raw preset object to the host | [L2](#l2-the-new-app-presets-leave-out-the-feedbacks-list-that-button-presets-require) |
| A3 | The TV accepts, or at worst ignores, `params: [null]` on `appControl/terminateApps`, so the action works and the finding is about consistency only | Sony Bravia REST API behaviour, not checked; trusting the contributor who added and presumably tested the action | [N1](#n1-terminate-all-apps-sends-a-different-request-body-from-every-other-no-argument-command) |
| A4 | With the automated config layout of API 1.14, a static-text field and the text input next to it with the same label may show as two rows both labelled "Update Interval" | Companion 4.2 config-panel rendering, not visible in the module or the base package | [N3](#n3-the-connection-settings-could-hide-the-psk-and-fold-the-interval-help-into-the-field) |

## 📋 Issues

### Blocking

- [ ] [C1: Line endings are not normalised because the .gitattributes file is missing](#c1-line-endings-are-not-normalised-because-the-gitattributes-file-is-missing)
- [ ] [C2: Build output, debug logs and the Yarn cache can be committed because .gitignore lacks three template entries](#c2-build-output-debug-logs-and-the-yarn-cache-can-be-committed-because-gitignore-lacks-three-template-entries)
- [ ] [C3: Prettier checks files the template excludes because .prettierignore is missing](#c3-prettier-checks-files-the-template-excludes-because-prettierignore-is-missing)
- [ ] [C4: Yarn 4 installs ignore the template install settings because .yarnrc.yml is missing](#c4-yarn-4-installs-ignore-the-template-install-settings-because-yarnrcyml-is-missing)
- [ ] [C5: The module entry point sits at the repo root instead of under src](#c5-the-module-entry-point-sits-at-the-repo-root-instead-of-under-src)
- [ ] [C6: package.json does not declare the Node and Yarn versions the module needs](#c6-packagejson-does-not-declare-the-node-and-yarn-versions-the-module-needs)
- [ ] [C7: Installs fall back to Yarn classic because package.json names no package manager](#c7-installs-fall-back-to-yarn-classic-because-packagejson-names-no-package-manager)
- [ ] [C8: The module cannot be packaged with yarn package because the package script is missing](#c8-the-module-cannot-be-packaged-with-yarn-package-because-the-package-script-is-missing)
- [ ] [C9: The release build fails because yarn package cannot run](#c9-the-release-build-fails-because-yarn-package-cannot-run)
- [ ] [H1: CI still tests on Node 18, which the module no longer runs on](#h1-ci-still-tests-on-node-18-which-the-module-no-longer-runs-on)

### Non-blocking

- [ ] [M1: Launch App sends an empty launch request when Type is left unselected](#m1-launch-app-sends-an-empty-launch-request-when-type-is-left-unselected)
- [ ] [L1: The help page does not mention the new app, reboot and web app features](#l1-the-help-page-does-not-mention-the-new-app-reboot-and-web-app-features)
- [ ] [L2: The new App presets leave out the feedbacks list that button presets require](#l2-the-new-app-presets-leave-out-the-feedbacks-list-that-button-presets-require)
- [ ] [L3: Hiding Update Interval when polling is off will stop working on API 2.0](#l3-hiding-update-interval-when-polling-is-off-will-stop-working-on-api-20)
- [ ] [N1: Terminate All Apps sends a different request body from every other no-argument command](#n1-terminate-all-apps-sends-a-different-request-body-from-every-other-no-argument-command)
- [ ] [N2: The Launch App Value field gives no hint, no app list and no variable support](#n2-the-launch-app-value-field-gives-no-hint-no-app-list-and-no-variable-support)
- [ ] [N3: The connection settings could hide the PSK and fold the interval help into the field](#n3-the-connection-settings-could-hide-the-psk-and-fold-the-interval-help-into-the-field)

## 🔴 Critical

### C1: Line endings are not normalised because the .gitattributes file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check required for every release; the file was already missing at v2.1.0)
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor on Windows can commit files with CRLF line endings. Prettier then reports those files as wrongly formatted, and diffs show every line of a file as changed.

**Why it happens:** The template ships a one-line `.gitattributes` that tells git to store every text file with LF endings. This repo has no `.gitattributes`, so git keeps whatever line endings each contributor's editor writes.

**Expected vs found:**

```text
Expected (template): .gitattributes
  * text=auto eol=lf
Found: no .gitattributes file
```

**Fix:** add the template's `.gitattributes` to the repo root.

```text
* text=auto eol=lf
```

### C2: Build output, debug logs and the Yarn cache can be committed because .gitignore lacks three template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check required for every release; the same `.gitignore` was in v2.1.0)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/.gitignore)

**What goes wrong:** After `yarn package`, the packaged `.tgz` (named after the module, for example `sony-bravia-2.2.1.tgz`) shows up as a new file to commit. So do `DEBUG-*` log files and, once the module is on Yarn 4 (see [C7](#c7-installs-fall-back-to-yarn-classic-because-packagejson-names-no-package-manager)), the `.yarn/` folder.

**Why it happens:** `.gitignore` only lists `.DS_Store`, `node_modules/`, `package-lock.json`, `/pkg` and `/pkg.tgz`. The template also ignores `/*.tgz`, `DEBUG-*` and `/.yarn`. The extra `.DS_Store` and `/pkg.tgz` entries are fine to keep.

**Expected vs found:**

```text
Missing template .gitignore entries: /*.tgz, DEBUG-*, /.yarn
```

**Fix:** add the three missing lines to `.gitignore`.

```text
/*.tgz
DEBUG-*
/.yarn
```

### C3: Prettier checks files the template excludes because .prettierignore is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check required for every release; the file was already missing at v2.1.0)
- **File:** `.prettierignore` (missing)

**What goes wrong:** `yarn format` rewrites `package.json`, and the CI step `yarn prettier --check .` checks it too. That file is written by Yarn and dependabot in their own layout, so formatting it creates churn on every dependency bump.

**Why it happens:** The template's `.prettierignore` keeps prettier away from `package.json` and `/LICENSE.md`. This repo has no `.prettierignore`.

**Expected vs found:**

```text
Expected (template): .prettierignore
  package.json
  /LICENSE.md
Found: no .prettierignore file
```

**Fix:** add the template's `.prettierignore` to the repo root.

```text
package.json
/LICENSE.md
```

### C4: Yarn 4 installs ignore the template install settings because .yarnrc.yml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check required for every release; the file was already missing at v2.1.0)
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Once the module runs on Yarn 4 (see [C7](#c7-installs-fall-back-to-yarn-classic-because-packagejson-names-no-package-manager)), Yarn would install with Plug'n'Play instead of a `node_modules` folder, which `companion-module-build` does not support. It would also run dependency install scripts and install freshly published package versions without the template's safety delay.

**Why it happens:** The template's `.yarnrc.yml` sets `nodeLinker: node-modules`, turns off dependency scripts (`enableScripts: false`) and holds back package versions newer than 3 days (`npmMinimalAgeGate: 3d`, with `@companion-module/*` exempt). This repo has no `.yarnrc.yml`, so Yarn uses its own defaults.

**Expected vs found:**

```text
Expected (companion-module-template-js @ 89da037): .yarnrc.yml
Found: no .yarnrc.yml file
```

**Fix:** copy the current template's `.yarnrc.yml` to the repo root.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C5: The module entry point sits at the repo root instead of under src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW (template check required for every release; the root `index.js` was already the entry point at v2.1.0)
- **File:** [`index.js`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/index.js)

**What goes wrong:** Anyone who knows the template looks for the module's main class in `src/main.js` and doesn't find it. The rest of the source lives in `src/`, so the layout differs from every module built from the template, which makes later troubleshooting harder.

**Why it happens:** The module class and `runEntrypoint` call are in `index.js` at the repo root, and `package.json` `main` and the manifest `runtime.entrypoint` (`../index.js`) point at it. The template keeps all source under `src/`, with the entry point at `src/main.js`.

**Expected vs found:**

```text
Expected (template): entry point src/main.js; package.json "main": "src/main.js"; manifest "entrypoint": "../src/main.js"
Found: index.js at the repo root; package.json "main": "index.js"; manifest "entrypoint": "../index.js"
```

**Fix:** move `index.js` to `src/main.js` and update the three places that point at it.

```js
// src/main.js: the requires lose their ./src/ prefix
const UpgradeScripts = require('./upgrades')
const config = require('./config')
const actions = require('./actions')
const feedbacks = require('./feedbacks')
const variables = require('./variables')
const presets = require('./presets')
const api = require('./api')
```

```json
// package.json
"main": "src/main.js",
// companion/manifest.json, runtime
"entrypoint": "../src/main.js"
```

### C6: package.json does not declare the Node and Yarn versions the module needs

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW (template check required for every release; `engines` was already missing at v2.1.0)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/package.json)

**What goes wrong:** A contributor can install and run the module with any Node or Yarn version and gets no warning. This release moved the manifest runtime to `node22`, but nothing in `package.json` says so.

**Why it happens:** The template's `package.json` has an `engines` field (`node` `^22.20`, `yarn` `^4`). This module's `package.json` has none.

**Expected vs found:**

```text
Missing required field 'engines' (present in template)
Expected: "engines": { "node": "^22.20", "yarn": "^4" }
```

**Fix:** add the template's `engines` field to `package.json`.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
},
```

### C7: Installs fall back to Yarn classic because package.json names no package manager

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW (template check required for every release; `packageManager` was already missing at v2.1.0)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/package.json), [`yarn.lock`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/yarn.lock)

**What goes wrong:** The review's install and build ran under Yarn classic 1.22.22, not the Yarn 4 the template uses. Each contributor and CI run gets whichever Yarn happens to be installed globally, so installs aren't reproducible.

**Why it happens:** Corepack picks the Yarn version from the `packageManager` field in `package.json`. The template sets `"packageManager": "yarn@4.12.0"`; this module has no such field, and its `yarn.lock` is still in the Yarn 1 format.

**Expected vs found:**

```text
Missing required field 'packageManager' (present in template)
Expected: "packageManager": "yarn@4.12.0"
Found: no packageManager field; yarn.lock in Yarn v1 format
```

**Fix:** add the `packageManager` field, then run `corepack enable` and `yarn install` so Yarn 4 rewrites `yarn.lock`, and commit the new lockfile. The Node CI workflow will then need its `corepack enable` step back (this release removed it from `.github/workflows/node.yaml`), or CI's global Yarn 1 will refuse to install.

```json
"packageManager": "yarn@4.12.0"
```

### C8: The module cannot be packaged with yarn package because the package script is missing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW (template check required for every release; the script was already missing at v2.1.0)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/package.json)

**What goes wrong:** `yarn package`, the standard command that builds the installable `.tgz` for Companion, fails with `Command "package" not found`. That is the cause of [C9](#c9-the-release-build-fails-because-yarn-package-cannot-run).

**Why it happens:** The template's `package.json` maps `package` to `companion-module-build`. This module's `scripts` only has `format` and `test`.

**Expected vs found:**

```text
Missing required script 'package'
Expected: "package": "companion-module-build"
Found scripts: format, test
```

**Fix:** add the `package` script (keeping `format` and `test`).

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build",
	"test": "jest --silent=false"
},
```

### C9: The release build fails because yarn package cannot run

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW (the build of this release fails; v2.1.0 had the same missing script)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/package.json)

**What goes wrong:** The review could not produce an installable package of v2.2.1. `yarn install --immutable` passed, but `yarn package` stopped at once.

**Why it happens:** There is no `package` script ([C8](#c8-the-module-cannot-be-packaged-with-yarn-package-because-the-package-script-is-missing)), and with no `packageManager` field ([C7](#c7-installs-fall-back-to-yarn-classic-because-packagejson-names-no-package-manager)) the command ran under Yarn classic 1.22.22.

**Expected vs found:**

```text
yarn package (build) failed
error Command "package" not found.
```

**Fix:** fix [C7](#c7-installs-fall-back-to-yarn-classic-because-packagejson-names-no-package-manager) and [C8](#c8-the-module-cannot-be-packaged-with-yarn-package-because-the-package-script-is-missing), then run `yarn install` and `yarn package` locally and check that a `.tgz` is produced.

## 🟠 High

### H1: CI still tests on Node 18, which the module no longer runs on

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW (this release changed the line from `[18.x]` to `[18.x, 22.x]`, keeping Node 18)
- **File:** [`.github/workflows/node.yaml:15`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/.github/workflows/node.yaml#L15)

**What goes wrong:** Every push still runs the whole CI job a second time on Node 18. This release moved the manifest runtime to `node22`, so the module never runs on Node 18 in Companion. A Node 18 failure would block CI for a version nobody uses, and a pass tells you nothing.

**Why it happens:** The API 1 template runs on Node 22. The workflow matrix was extended to `[18.x, 22.x]` instead of being switched to `22.x`.

**Expected vs found:**

```text
.github/workflows/node.yaml line 15
Expected: node-version: 22.x
Found:    node-version: [18.x, 22.x]
```

**Fix:** use Node 22 only. That is the one place left: the manifest runtime is already `node22`, and the missing `engines` field is covered by [C6](#c6-packagejson-does-not-declare-the-node-and-yarn-versions-the-module-needs).

- `.github/workflows/node.yaml` line 15: `node-version: [18.x, 22.x]` → `22.x`

## 🟡 Medium

### M1: Launch App sends an empty launch request when Type is left unselected

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:107-117`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/actions.js#L107-L117), [`src/actions.js:130-142`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/actions.js#L130-L142)

**What goes wrong:** A user adds the new "Launch App" action to a button, types `https://example.com` in "Value", and doesn't touch the "Type" dropdown, which starts out blank because it has no default. When they press the button, the TV is asked to launch `localapp://webappruntime?` with nothing after the `?`, and nothing opens. The connection status stays OK and nothing is logged, so the user can't tell why the button does nothing. The generated "Select app …" presets are not affected, because they set Type to Android Activity.

**Why it happens:** The "Type" dropdown has no `default`, so a new action's Type value is `undefined` until the user picks one. The callback starts the launch address with `localapp://webappruntime?` for any Type other than Android Activity, then adds the value only for the four known Types. An undefined Type matches none of them, so the bare prefix is sent without a warning.

**Evidence:**

```js
// src/actions.js:107-117
			{
				type: 'dropdown',
				label: 'Type',
				id: 'type',
				choices: [
					{ id: 'activity', label: 'Android Activity' },
					{ id: 'url', label: 'URL' },
					{ id: 'manifest', label: 'Manifest' },
					{ id: 'auid', label: 'Application ID' },
				],
			},
// src/actions.js:130-142
			let params = {
				uri: opt.type === 'activity' ? '' : 'localapp://webappruntime?',
			}
			if (opt.type === 'url') {
				params.uri += 'url=' + value
			} else if (opt.type === 'manifest') {
				params.uri += 'manifest=' + value
			} else if (opt.type === 'auid') {
				params.uri += 'auid=' + value
			} else if (opt.type === 'activity') {
				params.uri += rawValue
			}
			self.sendCommand('appControl', 'setActiveApp', params)
```

**Confirm by:** open [`src/actions.js:107-117`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/actions.js#L107-L117): the Type dropdown has no `default:`. Then [`src/actions.js:130-142`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/actions.js#L130-L142): an undefined Type falls through every branch and still calls `sendCommand`.

**Fix:** give the Type dropdown a default, and refuse to send when the Type is unknown.

```js
{
	type: 'dropdown',
	label: 'Type',
	id: 'type',
	default: 'activity',
	choices: [ /* unchanged */ ],
},
```

```js
} else if (opt.type === 'activity') {
	params.uri += rawValue
} else {
	self.log('warn', 'Launch App: unknown type ' + opt.type)
	return
}
```

## 🟢 Low

### L1: The help page does not mention the new app, reboot and web app features

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:16-37`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/companion/HELP.md#L16-L37)

**What goes wrong:** A user who opens the module's help in Companion finds "Available Actions", "Available Feedbacks" and "Available Variables" lists that stop at the v2.1.0 features. Reboot, Launch App, Terminate All Apps, the "TV Web App Status is in X State" feedback, and the "Current Web App State" and "Current Web App URL" variables are missing. Nothing explains what to type into Launch App's "Value" for each Type (Android Activity, URL, Manifest, Application ID).

**Why it happens:** This release adds the actions, feedback and variables in `src/actions.js`, `src/feedbacks.js` and `src/variables.js`, but `companion/HELP.md` was not updated.

**Fix:** add the three actions, the feedback and the two variables to the HELP.md lists, plus a short note on Launch App with one example Value per Type (an Android activity URI as used by the App presets, a full `https://` URL, a manifest URL, and an application ID).

### L2: The new App presets leave out the feedbacks list that button presets require

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:264-285`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/presets.js#L264-L285), [`src/presets.js:287-314`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/presets.js#L287-L314)

**What goes wrong:** Probably nothing visible today: the "Terminate All Apps" preset and each "Select app …" preset in the App category should still appear and work (see A2). But if a Companion version reads a preset's feedbacks without a fallback, the App presets would fail to load. Every other preset in the file, including the new Reboot preset, has `feedbacks: []`.

**Why it happens:** In base 1.14.1 the button-preset type requires a `feedbacks` list (`CompanionButtonPresetDefinition.feedbacks`, `dist/module-api/preset.d.ts:71`). The base passes each preset object to Companion unchanged, so nothing fills the field in.

**Fix:** add `feedbacks: [],` to the `terminate_apps` preset and to the `select_app_${i}` presets, as the other presets already do.

### L3: Hiding Update Interval when polling is off will stop working on API 2.0

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (the base bump in this release made the existing lines deprecated)
- **File:** [`src/config.js:41`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/config.js#L41), [`src/config.js:49`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/config.js#L49)

**What goes wrong:** Nothing changes for users today: the "Update Interval" text and input still hide when "Enable Polling" is unticked. The problem comes when the module moves to API 2.0, where this kind of show/hide rule no longer exists and both fields would always show.

**Why it happens:** Both fields use an `isVisible` function. This release bumps the base from ~1.10.0 to ~1.14.1, past API 1.12, where `isVisible` is deprecated in favour of `isVisibleExpression` ("This will be removed in 2.0.0 of this api", `dist/module-api/input.d.ts:20`). The `config.js` lines themselves did not change.

**Fix:** replace both `isVisible` functions with an expression.

```js
isVisibleExpression: '$(options:polling)',
```

## 💡 Nice to Have

### N1: Terminate All Apps sends a different request body from every other no-argument command

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:146-151`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/actions.js#L146-L151), [`src/api.js:56-60`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/api.js#L56-L60)

**What goes wrong:** Nothing visible has been confirmed (see A3). Every other command with no arguments, such as the new "Reboot" action and the power and web-app status polls, posts `"params":[]`. "Terminate All Apps" posts `"params":[null]`, and the `let params = {}` line just above the call is never used. This is a code-quality and consistency issue.

**Why it happens:** The callback passes `null` to `sendCommand`. `sendCommand` only turns `{}` into an empty list, so `null` is wrapped as `[null]`. The action definition also has no `options` array, unlike every other action in the file.

**Fix:** pass `{}` like the other commands, drop the unused variable, and add `options: []`.

```js
actions.terminate_apps = {
	name: 'Terminate All Apps',
	options: [],
	callback: async function () {
		self.sendCommand('appControl', 'terminateApps', {})
	},
}
```

### N2: The Launch App Value field gives no hint, no app list and no variable support

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:104-125`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/actions.js#L104-L125)

**What goes wrong:** A user adding "Launch App" by hand sees a bare "Value" text box. Nothing says what an Android Activity, Manifest or Application ID value looks like. The TV's app list, which the module already fetches for the App presets, isn't offered to pick from, and variables in the field (for example a URL held in a custom variable) are not resolved.

**Why it happens:** The `app_value` text input has no `description` and no `useVariables`. The app list (`self.CHOICES_APPS`, built in [`src/api.js:179-186`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/api.js#L179-L186)) is used only for presets.

**Fix:** add a `description` to `app_value` that explains the format for each Type (available since API 1.13; the module is now on 1.14), and `useVariables: true` so Companion resolves variables before the callback runs. Optionally, offer `self.CHOICES_APPS` as a dropdown with `allowCustom: true` for the Android Activity type, and call `initActions()` again when the app list arrives.

### N3: The connection settings could hide the PSK and fold the interval help into the field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (made possible by the base bump in this release)
- **File:** [`src/config.js:22-27`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/config.js#L22-L27), [`src/config.js:35-50`](https://github.com/bitfocus/companion-module-sony-bravia/blob/c3aa0d260e6431dd0287934d46ec9eac07d3be23/src/config.js#L35-L50)

**What goes wrong:** Nothing breaks. The "Pre Shared Key (PSK)" is a plain text field, so the key shows in clear text in the connection settings and is included in exported configs. The "Update Interval" explanation is a separate text row with the same label as the input next to it, which may show as two rows both called "Update Interval" (see A4).

**Why it happens:** `secret-text` config fields and the per-field `description` arrived in API 1.13, and the automated config layout in 1.14. This release moves the module to base ~1.14.1, so all of them are now available.

**Fix:** change the `psk` field to `type: 'secret-text'` and replace the `intervalInfo` static text with a `description` on the `interval` field. Moving the PSK into secrets also needs an upgrade script that moves `config.psk` into the connection's secrets, and the code must then read the PSK from there.
