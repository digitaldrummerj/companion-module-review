# Review: companion-module-rundown-studio v2.3.1

| Field | Value |
| --- | --- |
| **Module** | [bitfocus/companion-module-rundown-studio](https://github.com/bitfocus/companion-module-rundown-studio) |
| **Scope** | `tag` (v2.3.0..v2.3.1) |
| **Version** | v2.3.1 (commit `f662227`) |
| **Release** | Update — last published v2.3.0 |
| **API** | 1 (base 1.15.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not replace variables in dropdown options that allow custom values (the Cue option of "Jump to cue", the sub-timer options) before the action runs, so the module's own `parseVariablesInString` calls on those options are still needed | base 1.15.1 typings: a v1 dropdown has no `useVariables` property to opt in with; Companion's host code not checked | [M1](#m1-output-message-set-expands-variables-in-its-text-a-second-time) |
| A2 | A `secret-text` config value is kept in Companion's secrets store and left out of configuration exports | base 1.15.1 `input.d.ts` ("the value for this will be in the secrets store, not the config store"); how exports treat it is Companion host behaviour, not checked | [N1](#n1-the-api-token-is-stored-and-exported-as-plain-text) |
| A3 | With module API 1.14 or later, Companion lays out the connection settings automatically and may not keep the width-4 / width-8 side-by-side placement of the help-text fields | the API 1.14 notes and base's `disableNewConfigLayout` option; the actual rendering is Companion UI behaviour, not checked | [N2](#n2-help-texts-in-the-connection-settings-may-not-sit-next-to-their-settings-anymore) |
| A4 | Companion only loads a v1 module whose API version (1.15.1 here, taken from the base package because the manifest says `0.0.0`) is not newer than the v1 API that Companion release supports | general knowledge of Companion's module compatibility check; not determinable from the module or the base package | [📝 Additional Notes](#-additional-notes) |

## 📋 Issues

### Blocking

- [ ] [C1: Missing `.gitattributes` file, so line endings are not kept consistent](#c1-missing-gitattributes-file-so-line-endings-are-not-kept-consistent)
- [ ] [C2: `.gitignore` lets built packages, debug logs and the Yarn folder be committed](#c2-gitignore-lets-built-packages-debug-logs-and-the-yarn-folder-be-committed)
- [ ] [C3: Missing `.yarnrc.yml`, so installs run without the template's Yarn safety settings](#c3-missing-yarnrcyml-so-installs-run-without-the-templates-yarn-safety-settings)
- [ ] [C4: Yarn's machine-specific install state is committed in `.yarn/install-state.gz`](#c4-yarns-machine-specific-install-state-is-committed-in-yarninstall-stategz)
- [ ] [C5: The module's main file `main.js` sits at the repository root instead of in `src/`](#c5-the-modules-main-file-mainjs-sits-at-the-repository-root-instead-of-in-src)
- [ ] [C6: `package.json` doesn't say which Node and Yarn versions the module needs](#c6-packagejson-doesnt-say-which-node-and-yarn-versions-the-module-needs)
- [ ] [C7: `package.json` doesn't pin which Yarn version to use](#c7-packagejson-doesnt-pin-which-yarn-version-to-use)
- [ ] [C8: There is no `package` script, so `yarn package` can't build the module](#c8-there-is-no-package-script-so-yarn-package-cant-build-the-module)
- [ ] [C9: Building the module package with `yarn package` fails](#c9-building-the-module-package-with-yarn-package-fails)

### Non-blocking

- [ ] [M1: Output Message: Set expands variables in its Text a second time](#m1-output-message-set-expands-variables-in-its-text-a-second-time)
- [ ] [L1: The advanced connection settings use a show/hide rule that API 2.0 removes](#l1-the-advanced-connection-settings-use-a-showhide-rule-that-api-20-removes)
- [ ] [N1: The API Token is stored and exported as plain text](#n1-the-api-token-is-stored-and-exported-as-plain-text)
- [ ] [N2: Help texts in the connection settings may not sit next to their settings anymore](#n2-help-texts-in-the-connection-settings-may-not-sit-next-to-their-settings-anymore)
- [ ] [NR1: Plan the move to Companion module API 2.x](#nr1-plan-the-move-to-companion-module-api-2x)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Missing `.gitattributes` file, so line endings are not kept consistent

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** `.gitattributes` (missing)

**What goes wrong:** When someone works on the module on Windows, or with a Git client that converts line endings, files can be committed with Windows (CRLF) line endings. The module's formatter (`yarn format`, Prettier) writes Unix (LF) line endings, so the next format run rewrites every line of those files and the diff shows whole files as changed.

**Why it happens:** The template ships a one-line `.gitattributes` that tells Git to store and check out every text file with LF line endings, whatever the machine's own settings are. This repository has no `.gitattributes`.

**Evidence:** validator: `.gitattributes`: Required file is missing (tracked by the template).

```text
# expected (companion-module-template-js-v1/.gitattributes)
* text=auto eol=lf

# found
(no .gitattributes in the repository)
```

**Fix:** add a `.gitattributes` file at the repository root with the template's line.

```text
* text=auto eol=lf
```

### C2: `.gitignore` lets built packages, debug logs and the Yarn folder be committed

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** [`.gitignore:1-5`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/.gitignore#L1-L5)

**What goes wrong:** Building the module (`yarn package`, once [C8](#c8-there-is-no-package-script-so-yarn-package-cant-build-the-module) is fixed) writes `rundown-studio-2.3.1.tgz` to the repository root. The `.gitignore` only ignores `/pkg.tgz`, the old output name, so a `git add .` commits the package file. The same goes for `DEBUG-*` debug output files and everything Yarn writes into the `.yarn/` folder. That is how `.yarn/install-state.gz` ended up in the repository ([C4](#c4-yarns-machine-specific-install-state-is-committed-in-yarninstall-stategz)).

**Why it happens:** The template's `.gitignore` ignores `/*.tgz`, `DEBUG-*` and `/.yarn`. The module's `.gitignore` is an older list without those three entries. `@companion-module/tools` names the package `<manifest id>-<version>.tgz`, which `/pkg.tgz` doesn't match.

**Evidence:** validator: `.gitignore`: Missing template .gitignore entries: /*.tgz, DEBUG-*, /.yarn

```text
# expected (companion-module-template-js-v1/.gitignore)
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn

# found (.gitignore:1-5)
node_modules/
package-lock.json
/pkg
/pkg.tgz
.DS_Store
```

**Fix:** add the three missing entries. The extra `.DS_Store` line can stay.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
.DS_Store
```

### C3: Missing `.yarnrc.yml`, so installs run without the template's Yarn safety settings

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** When the module is installed with Yarn 4 (the template's package manager), nothing configures Yarn for this repository. Yarn then runs the install scripts of every dependency, installs a package version the moment it is published, and uses its Plug'n'Play mode instead of a `node_modules` folder. The first two are the protections the template adds against a hijacked npm package reaching the module.

**Why it happens:** The template's `.yarnrc.yml` turns off dependency install scripts (`enableScripts: false`), keeps the `node_modules` layout (`nodeLinker: node-modules`), and makes Yarn wait until a release is 3 days old before installing it (`npmMinimalAgeGate: 3d`), with `@companion-module/*` packages exempt. This repository has no `.yarnrc.yml`.

**Evidence:** validator: `.yarnrc.yml`: Required file is missing (tracked by the template).

```yaml
# expected (companion-module-template-js @ 89da037, .yarnrc.yml)
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

**Fix:** add `.yarnrc.yml` at the repository root with exactly the template's contents above, together with the Yarn 4 switch in [C7](#c7-packagejson-doesnt-pin-which-yarn-version-to-use).

### C4: Yarn's machine-specific install state is committed in `.yarn/install-state.gz`

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** [`.yarn/install-state.gz`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/.yarn/install-state.gz)

**What goes wrong:** `.yarn/install-state.gz` is a cache that Yarn rewrites on every `yarn install`, on every machine. Because it is committed, it shows up as a modified binary file in contributors' checkouts and in unrelated commits. The history shows it: six dependency-bump commits changed it, most recently 1b2a966 (2025-11-15).

**Why it happens:** The template ignores the whole `.yarn` folder (`/.yarn`), but the module's `.gitignore` doesn't ([C2](#c2-gitignore-lets-built-packages-debug-logs-and-the-yarn-folder-be-committed)), so the file was committed with the first release and has been tracked since.

**Evidence:** validator: `.yarn/install-state.gz`: Committed but template .gitignore excludes it (pattern '/.yarn')

```text
$ git ls-files .yarn
.yarn/install-state.gz
```

**Fix:** stop tracking the file and ignore the folder (the `/.yarn` entry from C2).

```bash
git rm --cached .yarn/install-state.gz
```

### C5: The module's main file `main.js` sits at the repository root instead of in `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** [`main.js:1-17`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/main.js#L1-L17), [`package.json:4`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/package.json#L4), [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/companion/manifest.json#L24)

**What goes wrong:** The module's main class (the code that runs on `init()`, `configUpdated()` and `destroy()`) is in `main.js` at the repository root, while the rest of the code is in `src/`. Anyone who opens the repository expecting the template layout, including the Bitfocus maintainers who help troubleshoot modules, has to look in two places, and the module can't be compared file-for-file with the template.

**Why it happens:** The template keeps all source under `src/`: its entry file is `src/main.js`, `package.json` points `main` at it, and the manifest's `entrypoint` is `../src/main.js`. This module points both at the root `main.js`.

**Evidence:** validator: `main.js`: Source file at module root — all source must be under src/

```text
# expected (template)
package.json            "main": "src/main.js"
companion/manifest.json "entrypoint": "../src/main.js"

# found
package.json:4             "main": "main.js"
companion/manifest.json:24 "entrypoint": "../main.js"
main.js:3                  const upgrades = require('./src/upgrades')
```

**Fix:** move `main.js` to `src/main.js`, change its `require('./src/…')` lines to `require('./…')`, and update the two paths.

```json
"main": "src/main.js",
```

```json
"entrypoint": "../src/main.js"
```

### C6: `package.json` doesn't say which Node and Yarn versions the module needs

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/package.json)

**What goes wrong:** This release moves the module's runtime from Node 18 to Node 22 (manifest `runtime.type` `node22`), but `package.json` says nothing about it. A contributor on Node 18 or Yarn 1 can install and build the module without any warning, and get different results from the Node 22 runtime the module ships for.

**Why it happens:** The template's `package.json` has an `engines` block that names Node 22.20+ and Yarn 4. Package managers and tools read `engines` to warn about a mismatched setup. This `package.json` has no `engines` field.

**Evidence:** validator: `package.json`: Missing required field 'engines' (present in template)

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
},
```

**Fix:** add the template's `engines` block above to `package.json`.

### C7: `package.json` doesn't pin which Yarn version to use

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/package.json), [`yarn.lock:1-2`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/yarn.lock#L1-L2)

**What goes wrong:** Each contributor installs with whatever Yarn they happen to have. The repository already shows both versions in use: `yarn.lock` is in the old Yarn 1 format (`# yarn lockfile v1`), while `.yarn/install-state.gz` is written only by Yarn 2 and later. A Yarn 4 user rewrites the whole lockfile on the next install, and a Yarn 1 user keeps the old format, so the lockfile can flip between formats from one commit to the next.

**Why it happens:** The template's `package.json` sets `"packageManager": "yarn@4.12.0"`. Node's Corepack reads that field and runs exactly that Yarn version for the repository. This `package.json` has no `packageManager` field.

**Evidence:** validator: `package.json`: Missing required field 'packageManager' (present in template)

```text
# expected (template package.json)
"packageManager": "yarn@4.12.0"

# found (yarn.lock:1-2)
# THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.
# yarn lockfile v1
```

**Fix:** add the field, then convert the lockfile with Yarn 4 and commit it. Add `.yarnrc.yml` from [C3](#c3-missing-yarnrcyml-so-installs-run-without-the-templates-yarn-safety-settings) first, then check that a clean checkout installs with `yarn install --immutable`.

```json
"packageManager": "yarn@4.12.0"
```

```bash
corepack enable
yarn install
git add package.json yarn.lock .yarnrc.yml
```

### C8: There is no `package` script, so `yarn package` can't build the module

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** [`package.json:5-7`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/package.json#L5-L7)

**What goes wrong:** The template's way to build the module's installable package is `yarn package`. It produces the `.tgz` file that can be imported into Companion to test a release. In this repository `yarn package` stops with an error that there is no `package` script.

**Why it happens:** The template's `package.json` has `"package": "companion-module-build"` in its scripts. This module only has `format`. `@companion-module/tools`, which provides `companion-module-build`, is already a devDependency, so only the script line is missing.

**Evidence:** validator: `package.json`: Missing required script 'package'

```json
// found (package.json:5-7)
"scripts": {
	"format": "prettier -w ."
},
```

**Fix:** add the template's `package` script.

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
},
```

### C9: Building the module package with `yarn package` fails

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW (whole-module template check; also present in v2.3.0)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/package.json)

**What goes wrong:** The review builds every release from a clean checkout (`yarn install --immutable`, then `yarn package`). The install passed, but the build failed, so v2.3.1 could not be turned into a Companion package.

**Why it happens:** The build failed because the `package` script is missing ([C8](#c8-there-is-no-package-script-so-yarn-package-cant-build-the-module)). Nothing else was reached.

**Evidence:** validator: `package.json`: yarn package (build) failed. Root cause: the missing `package` script (PKG-SCRIPT, C8).

**Fix:** fix C8, and C5's paths if `main.js` moves. Then run `yarn package` in a clean checkout and check that it writes `rundown-studio-2.3.1.tgz` without errors.

## 🟡 Medium

### M1: Output Message: Set expands variables in its Text a second time

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (caused by this release's `@companion-module/base` bump)
- **File:** [`src/actions.js:211`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/actions.js#L211)

**What goes wrong:** Usually nothing visible. A user adds the "Output Message: Set" action and types `Now: $(internal:time_hms)` into "Text (leave blank to keep unchanged)". Companion has already replaced the variable before the action runs, and the module then looks for variables in the result again. That second pass only matters when a variable's value itself contains `$(…)` text. For example, if a custom variable holds the literal text `$(internal:time_hms)`, Rundown Studio's output message shows the current time instead of that text. Otherwise the extra call just does nothing.

**Why it happens:** This release raises `@companion-module/base` from `~1.5.1` to `~1.15.1`. Since module API 1.13, Companion fills in the variables of a text option that declares `useVariables` before it calls the action, and base 1.15.1 marks `parseVariablesInString` as deprecated ("Companion now handles this for you, for actions and feedbacks"). The Text option declares `useVariables: true`, but the action still passes it through `parseVariablesInString`.

```js
// src/actions.js:157
useVariables: true,
// src/actions.js:211
const text = await self.parseVariablesInString(action.options.text || '')
```

**Fix:** use the Text value as Companion delivers it. Keep the `parseVariablesInString` calls on the Cue and sub-timer dropdowns ([`src/actions.js:56`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/actions.js#L56), [`src/actions.js:264`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/actions.js#L264), [`src/api.js:419`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/api.js#L419)). A v1 dropdown that allows custom values can't declare `useVariables`, so Companion doesn't fill those in (see A1).

```js
const text = String(action.options.text ?? '')
```

## 🟢 Low

### L1: The advanced connection settings use a show/hide rule that API 2.0 removes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (caused by this release's `@companion-module/base` bump)
- **File:** [`src/config.js:64`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/config.js#L64), [`src/config.js:72`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/config.js#L72), [`src/config.js:81`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/config.js#L81), [`src/config.js:89`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/config.js#L89), [`src/config.js:97`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/config.js#L97)

**What goes wrong:** Nothing visible today: ticking "Advanced Configuration" still shows "API Base URL", "Update Interval (ms)" and "Verbose Mode" with their help texts. But the way these fields are shown and hidden is deprecated in base 1.15.1 ("This will be removed in 2.0.0 of this api"), so they will stop showing and hiding correctly when the module moves to API 2.x unless they are converted.

**Why it happens:** The base bump in this release takes the module past API 1.12, which replaced `isVisible` functions with `isVisibleExpression`, a text expression Companion evaluates itself. All five advanced fields still use an `isVisible` function.

```js
// src/config.js:64 (same on lines 72, 81, 89, 97)
isVisible: (config) => config.advancedConfig === true,
```

**Fix:** replace each `isVisible` function with the equivalent expression on `apiBaseUrl`, `updateInterval`, `updateInterval-info`, `verbose` and `verbose-info`.

```js
isVisibleExpression: '$(options:advancedConfig)',
```

## 💡 Nice to Have

### N1: The API Token is stored and exported as plain text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (made possible by this release's `@companion-module/base` bump)
- **File:** [`src/config.js:20-26`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/config.js#L20-L26)

**What goes wrong:** When a user exports their Companion configuration or a connection (to share it for support, or to move it to another machine), the Rundown Studio "API Token" is included in plain text, so anyone who receives the export can control the rundown.

**Why it happens:** Module API 1.13, which this release adopts with the `~1.15.1` base, added a `secret-text` config field whose value goes to Companion's secrets store instead of the regular config (see A2). The API Token is still a plain `textinput`.

**Fix:** declare the field as `secret-text` and read it from the `secrets` argument of `init(config, isFirstInit, secrets)` and `configUpdated(config, secrets)` instead of `this.config.apiToken`. Add an upgrade script to `src/upgrades.js` that moves `props.config.apiToken` into `updatedSecrets` and removes it from `updatedConfig`, so existing connections keep working.

```js
{
	type: 'secret-text',
	id: 'apiToken',
	label: 'API Token',
	width: 8,
	tooltip: 'The API token can be taken from your Rundown Studio Dashboard',
},
```

### N2: Help texts in the connection settings may not sit next to their settings anymore

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (caused by this release's `@companion-module/base` bump)
- **File:** [`src/config.js:41-99`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/src/config.js#L41-L99)

**What goes wrong:** In the connection settings, the explanations for "Advanced Configuration", "Update Interval (ms)" and "Verbose Mode" are separate text fields with an empty label, sized to sit beside their setting. With this release the module uses Companion's automated settings layout, where these help texts may appear as their own unlabeled rows, detached from the setting they describe. This is cosmetic only: the settings keep working.

**Why it happens:** The base bump from `~1.5.1` to `~1.15.1` crosses API 1.14, where Companion lays out connection settings automatically by default (the module rightly doesn't opt out). The panel was designed for the old width-based grid (width 4 for the setting, width 8 for its help text; see A3).

**Fix:** open the connection settings in Companion 4.2 or later and check the panel. If the help rows look detached, remove the `advancedConfig-info`, `updateInterval-info` and `verbose-info` text fields and put their text in the `description` property (available since API 1.13) of `advancedConfig`, `updateInterval` and `verbose`.

```js
{
	type: 'checkbox',
	id: 'verbose',
	label: 'Verbose Mode',
	description: 'Enable this to log more information to the debug log. This can be useful for troubleshooting.',
	default: false,
	isVisibleExpression: '$(options:advancedConfig)',
},
```

## 🔮 Next Release

### NR1: Plan the move to Companion module API 2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:14`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/package.json#L14)

**What goes wrong:** Nothing changes for users now. `~1.15.1` is the end of the v1 line. API 2.x (Companion 4.3 and later) adds expression support for options and removes the deprecated v1 patterns this module still uses, such as the `isVisible` functions ([L1](#l1-the-advanced-connection-settings-use-a-showhide-rule-that-api-20-removes)) and `parseVariablesInString` ([M1](#m1-output-message-set-expands-variables-in-its-text-a-second-time)).

**Why it happens:** This release updates `@companion-module/base` to `~1.15.1`. The next API step is the 2.x major version, which has breaking changes.

**Fix:** in a future release, migrate to `@companion-module/base` 2.x following the v1-to-v2 migration guide: an ESM entry point, `isVisibleExpression`, expression-aware options, and upgrade scripts for any option whose shape changes.

## 📝 Additional Notes

- This release raises `@companion-module/base` from `~1.5.1` to `~1.15.1` ([`package.json:14`](https://github.com/bitfocus/companion-module-rundown-studio/blob/f6622272745b7f1542ed73041b07cd55abc36c70/package.json#L14)). v2.3.0 ran on Companion 3.1 and later. v2.3.1 needs a Companion release that supports module API 1.15, which means Companion 4.2 or later at the least, since API 1.14 already needs 4.2 (see A4). Consider stating the minimum Companion version in the release notes or `companion/HELP.md`.
