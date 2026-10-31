# Review: companion-module-middlethings-middlecontrol v4.0.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-middlethings-middlecontrol](https://github.com/bitfocus/companion-module-middlethings-middlecontrol) |
| **Scope** | `tag` (v3.4.0..v4.0.1) |
| **Version** | v4.0.1 (commit [`f760cd6`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/commit/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59)) |
| **Release** | Update — last published v3.4.0 |
| **API** | 1 (base 1.7.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The module is built on a very old @companion-module/base (1.7) and Node 18: update to the latest v1 base and Node 22](#c1-the-module-is-built-on-a-very-old-companion-modulebase-17-and-node-18-update-to-the-latest-v1-base-and-node-22)
- [ ] [C2: The module cannot be installed or packaged with the standard build](#c2-the-module-cannot-be-installed-or-packaged-with-the-standard-build)
- [ ] [C3: Yarn settings file is missing, so installs don't use the template's safety settings](#c3-yarn-settings-file-is-missing-so-installs-dont-use-the-templates-safety-settings)
- [ ] [C4: Line-ending settings file is missing](#c4-line-ending-settings-file-is-missing)
- [ ] [C5: Build output and debug files are not ignored by git](#c5-build-output-and-debug-files-are-not-ignored-by-git)
- [ ] [C6: Source files sit at the module root instead of in a src folder](#c6-source-files-sit-at-the-module-root-instead-of-in-a-src-folder)
- [ ] [C7: Package file is missing the engines, prettier and packageManager fields](#c7-package-file-is-missing-the-engines-prettier-and-packagemanager-fields)
- [ ] [C8: Package file is missing the format and package scripts](#c8-package-file-is-missing-the-format-and-package-scripts)
- [ ] [C9: Prettier is not a dev dependency](#c9-prettier-is-not-a-dev-dependency)
- [ ] [C10: The module still targets Node 18, but the API 1 template runs on Node 22](#c10-the-module-still-targets-node-18-but-the-api-1-template-runs-on-node-22)

### Non-blocking

- [ ] [M1: Feedbacks with a Camera ID keep showing an old camera state when Monitor all cameras is off](#m1-feedbacks-with-a-camera-id-keep-showing-an-old-camera-state-when-monitor-all-cameras-is-off)
- [ ] [L1: Variables of a camera removed during a reconnect stay listed until the module restarts](#l1-variables-of-a-camera-removed-during-a-reconnect-stay-listed-until-the-module-restarts)
- [ ] [L2: Set CCU Value shows no variable picker for its Value field](#l2-set-ccu-value-shows-no-variable-picker-for-its-value-field)
- [ ] [N1: Set Speed rounds a decimal Zoom speed without saying so](#n1-set-speed-rounds-a-decimal-zoom-speed-without-saying-so)

## 🔴 Critical

### C1: The module is built on a very old @companion-module/base (1.7) and Node 18: update to the latest v1 base and Node 22

- **Source:** 👤 Bitfocus reviewer
- **Classification:** whole module, already the case in v3.4.0
- **File:** [`package.json:15`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json#L15), [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/companion/manifest.json#L18)

**What goes wrong:** The module depends on `@companion-module/base` `~1.7`, a v1 release that is many versions old, and runs on Node 18. Users get none of the fixes and improvements made to the v1 base since then. The module also no longer matches the current API 1 template, which makes it harder for anyone to build, check or troubleshoot it the same way as other modules. Most of the template findings below come from that gap.

**Why it happens:** The module was never moved forward from its old base and toolchain. The current API 1 template uses `@companion-module/base` `~1.14.1` (the newest v1 release on npm is 1.15.1, tagged `legacy-v1`), Node 22, Yarn 4 and its `src/` layout.

**Evidence:**

```text
package.json:15            "@companion-module/base": "~1.7"
companion/manifest.json:18 "type": "node18"
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json) and [`companion/manifest.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/companion/manifest.json), and compare them with the API 1 template (`companion-module-template-js-v1`).

**Fix:** update `@companion-module/base` to the latest v1 release and move the module to Node 22. Use the current API 1 template as the starting point for the upgrade. Doing this upgrade fixes most of the other Critical findings in this review: [C2](#c2-the-module-cannot-be-installed-or-packaged-with-the-standard-build) (standard build), [C3](#c3-yarn-settings-file-is-missing-so-installs-dont-use-the-templates-safety-settings) (Yarn settings), [C4](#c4-line-ending-settings-file-is-missing) (line endings), [C5](#c5-build-output-and-debug-files-are-not-ignored-by-git) (git ignore), [C6](#c6-source-files-sit-at-the-module-root-instead-of-in-a-src-folder) (`src/` folder), [C7](#c7-package-file-is-missing-the-engines-prettier-and-packagemanager-fields), [C8](#c8-package-file-is-missing-the-format-and-package-scripts) and [C9](#c9-prettier-is-not-a-dev-dependency) (package file) and [C10](#c10-the-module-still-targets-node-18-but-the-api-1-template-runs-on-node-22) (Node version in every place).

### C2: The module cannot be installed or packaged with the standard build

- **Source:** 🤖 validate-template (BUILD-INSTALL), 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json), [`yarn.lock`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/yarn.lock)

**What goes wrong:** The Bitfocus build installs the module with Yarn 4 (`yarn install --immutable`) and then packages it with `yarn package`. Both steps fail for this module, so the release cannot be built into the package Companion installs.

**Why it happens:** The module ships a Yarn 1 lockfile (`# yarn lockfile v1`) and has no `packageManager` field and no `.yarnrc.yml`, so Yarn 4 wants to rewrite the lockfile and `--immutable` refuses. There is also no `package` script in `package.json`, so `yarn package` has nothing to run.

**Evidence:**

```text
yarn install --immutable  -> failed (lockfile would be modified; yarn.lock is "yarn lockfile v1")
yarn package              -> failed (no "package" script in package.json)
```

**Fix:** move the module onto the template's Yarn 4 setup: add `"packageManager": "yarn@4.12.0"` and the template's `.yarnrc.yml` ([C3](#c3-yarn-settings-file-is-missing-so-installs-dont-use-the-templates-safety-settings)), add the `package` script ([C8](#c8-package-file-is-missing-the-format-and-package-scripts)), then run `yarn install` with Yarn 4 and commit the regenerated `yarn.lock`.

### C3: Yarn settings file is missing, so installs don't use the template's safety settings

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Without `.yarnrc.yml`, Yarn 4 installs packages with its defaults: dependency install scripts run, and packages are not laid out in `node_modules` the way `companion-module-build` expects.

**Why it happens:** The template tracks `.yarnrc.yml`; the module does not have one.

**Fix:** copy `.yarnrc.yml` from the template unchanged.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C4: Line-ending settings file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor on Windows can commit files with CRLF line endings, which then show up as whole-file changes and formatting failures.

**Why it happens:** The template tracks a `.gitattributes` that forces LF line endings; the module does not have one.

**Fix:** add the template's `.gitattributes`.

```text
* text=auto eol=lf
```

### C5: Build output and debug files are not ignored by git

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/.gitignore)

**What goes wrong:** After running `yarn package`, the built `pkg/` folder and the `.tgz` file show up as untracked files and can be committed by accident, as can Companion `DEBUG-*` logs and Yarn 4's `.yarn` folder.

**Why it happens:** The module's `.gitignore` only has `node_modules/`, `package-lock.json` and `.DS_Store`; it is missing four template entries.

**Fix:** add the missing template entries.

```text
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C6: Source files sit at the module root instead of in a src folder

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** partly 🆕 NEW — [`upgrades.js`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/upgrades.js), [`upgrades.test.js`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/upgrades.test.js) and [`feedbacks.test.js`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/feedbacks.test.js) were added at the root in this release; the other 12 files were already there in v3.4.0
- **File:** module root (15 files)

**What goes wrong:** All of the module's code lives next to `package.json`, `yarn.lock` and the config files, unlike every other module built from the template. Anyone troubleshooting the module later has to work around a layout the build tooling and templates don't expect.

**Why it happens:** The template keeps all source under `src/` (entry point `src/main.js`). This module has these files at the root: `actions.js`, `commands.js`, `commands.test.js`, `config.js`, `discovery.js`, `discovery.test.js`, `feedbacks.js`, `feedbacks.test.js`, `index.js`, `lib.js`, `lib.test.js`, `presets.js`, `upgrades.js`, `upgrades.test.js`, `variables.js`.

**Fix:** move the source and test files into `src/`, then update `"main"` in `package.json` and `runtime.entrypoint` in `companion/manifest.json` to point at the new entry file (e.g. `src/main.js`, entrypoint `../src/main.js`).

### C7: Package file is missing the engines, prettier and packageManager fields

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json)

**What goes wrong:** Nothing pins the Node and Yarn versions the module is built with, and the formatter has no shared config, so builds and formatting differ between machines (and `packageManager` is part of why [C2](#c2-the-module-cannot-be-installed-or-packaged-with-the-standard-build) fails).

**Why it happens:** The template's `package.json` has `engines`, `prettier` and `packageManager`; the module's has none of them.

**Fix:** add the three fields from the template.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
},
"prettier": "@companion-module/tools/.prettierrc.json",
"packageManager": "yarn@4.12.0"
```

### C8: Package file is missing the format and package scripts

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json)

**What goes wrong:** `yarn package` (used by the Bitfocus build) and `yarn format` don't exist for this module, so it can't be packaged the standard way.

**Why it happens:** The `scripts` block only has `"test": "node --test"`.

**Fix:** add the template's scripts next to the existing `test` script.

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build",
	"test": "node --test"
}
```

### C9: Prettier is not a dev dependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json)

**What goes wrong:** The `format` script ([C8](#c8-package-file-is-missing-the-format-and-package-scripts)) has no Prettier installed to run.

**Why it happens:** `devDependencies` only lists `@companion-module/tools`; the template also lists `prettier`.

**Fix:** add `"prettier": "^3.7.4"` to `devDependencies`.

### C10: The module still targets Node 18, but the API 1 template runs on Node 22

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/companion/manifest.json#L18), [`.github/workflows/companion-module-checks.yaml:26-26`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/.github/workflows/companion-module-checks.yaml#L26-L26)

**What goes wrong:** Companion starts the module on Node 18, but API 1 modules are expected to match the API 1 template, which uses Node 22 in every place the Node version is named. The other places listed below still name another Node version too, so the module would run, type-check and build in CI on different Node versions even after the runtime is fixed. A module that does not match its template makes later troubleshooting harder: when something misbehaves, people look for the cause in the module instead of in the mismatched setup.

**Why it happens:** Moving a module to another Node version means changing every place the version is named: the manifest runtime, `engines.node`, `@types/node`, the TypeScript preset and the CI workflows. These places still name a different Node version than the API 1 template.

**Evidence:**

```text
companion/manifest.json runtime.type 'node18' -> 'node22'
.github/workflows/companion-module-checks.yaml line 26 node-version 18 -> 22.x
```

**Confirm by:** open each file above and compare it with the template's copy.

**Fix:** update every place to Node 22, as the template does:

- [ ] [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/companion/manifest.json#L18): `"type": "node22"` in `runtime`
- [ ] [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/.github/workflows/companion-module-checks.yaml): `node-version: 22.x` (line 26)

## 🟡 Medium

### M1: Feedbacks with a Camera ID keep showing an old camera state when Monitor all cameras is off

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:216-218`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/index.js#L216-L218), [`feedbacks.js:4-11`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/feedbacks.js#L4-L11)

**What goes wrong:** A user leaves "Monitor all cameras" off (the default) and adds the "Autofocus status" feedback with Camera ID = 2. While camera 2 is selected in Middle Control with AF on, the button turns green. The operator then selects camera 1, and the camera-2 button stays green from then on, even after AF on camera 2 is turned off or the camera is unplugged. It only clears when the TCP link drops or the settings are saved. The same applies to ND filter status, Battery level, Power source, Digital zoom status, Current preset active and the Shake / Zoom Loop / Presets Sequence running feedbacks. The Camera ID tooltip and the code comment both say this case should read as "off".

**Why it happens:** Every incoming frame is stored as that camera's state, whether or not "Monitor all cameras" is on. Old camera entries are only expired when the option is on, so with it off each camera that was ever selected keeps a frozen snapshot, and the feedbacks read that snapshot whenever a Camera ID is filled in.

**Evidence:**

```js
// index.js:217-218
const trackAll = !!this.config?.trackAll
if (cam !== undefined) this.camState[cam] = toState(p)
// feedbacks.js:4-6
// A camera number → that camera's last frame, which only
// exists when "Monitor all cameras" is on (Middle Control 4.1+); otherwise it reads as "off".
```

**Fix:** only store per-camera state when "Monitor all cameras" is on, e.g. `if (trackAll && cam !== undefined) this.camState[cam] = toState(p)`. Another option is to make `stateFor()` return `{}` for a Camera ID unless `self.config?.trackAll` is true.

## 🟢 Low

### L1: Variables of a camera removed during a reconnect stay listed until the module restarts

- **Source:** 🔎 protocol reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:129-141`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/index.js#L129-L141), [`index.js:156-166`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/index.js#L156-L166), [`index.js:252-257`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/index.js#L252-L257)

**What goes wrong:** Only users with "Monitor all cameras" on are affected. Say Middle Control has cameras 1, 3 and 5, so Companion lists `cam3_rec`, `cam3_iso` and so on. The TCP link drops (or the user saves the connection settings), and while it is down camera 3 is removed in Middle Control. After the reconnect, all the `cam3_*` variables stay in Companion's variable list showing `-` until the connection is disabled and re-enabled. A camera removed while the link stays up is cleaned up after 1 s as intended, and feedbacks are not affected.

**Why it happens:** A camera's variables are removed only when the module notices that camera has gone quiet, and it only tracks "last heard from" times for cameras it has heard from on the current link. On a reconnect those times are wiped but the list of known cameras is kept, so a camera that never sends another frame is never noticed as gone.

**Fix:** when the "last heard from" times are reset, also seed them for the cameras still known, e.g. `for (const c of this.knownCams) this._camSeen[c] = Date.now()`, so cameras that don't come back expire normally. Or forget all known cameras on a new link and call `_registerCamVars()`; cameras still present re-register on their first frame.

### L2: Set CCU Value shows no variable picker for its Value field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:604-610`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/actions.js#L604-L610), [`actions.js:622`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/actions.js#L622)

**What goes wrong:** In the new "Set CCU Value (Hue / Luma Mix)" action, the Value box shows no variable picker, so most users won't know they can type something like `$(internal:custom_hue)`. A variable typed by hand does work. The other new actions in this release ("Set Preset Transition Easing", "Focus by a Fixed Step") do show the picker.

**Why it happens:** The `id_ccu_value` text input doesn't set `useVariables: true`, although its callback resolves variables with `parseVariablesInString`.

**Fix:** add `useVariables: true` to the `id_ccu_value` option, as `id_presetease` and `id_focusstep_size` already do.

## 💡 Nice to Have

### N1: Set Speed rounds a decimal Zoom speed without saying so

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:842-849`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/actions.js#L842-L849), [`commands.js:69-81`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/commands.js#L69-L81)

**What goes wrong:** In "Set Speed", the Value label reads "0 to 100 — tenths allowed below 10, e.g. 2.5" for both modes. With "Zoom Speed" selected, a value of 2.5 is sent as `ZS3`, so the user gets a different speed than they typed, with no warning.

**Why it happens:** The label and the input check apply to both modes, but the command builder keeps tenths only for Pan/Tilt and rounds Zoom to a whole number.

**Fix:** say so in the label, e.g. "0 to 100 — tenths allowed below 10 for Pan/Tilt; Zoom is rounded".
