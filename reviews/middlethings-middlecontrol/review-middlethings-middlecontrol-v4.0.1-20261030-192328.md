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

- [ ] [C1: The module cannot be installed or packaged with the standard build](#c1-the-module-cannot-be-installed-or-packaged-with-the-standard-build)
- [ ] [C2: Yarn settings file is missing, so installs don't use the template's safety settings](#c2-yarn-settings-file-is-missing-so-installs-dont-use-the-templates-safety-settings)
- [ ] [C3: Line-ending settings file is missing](#c3-line-ending-settings-file-is-missing)
- [ ] [C4: Build output and debug files are not ignored by git](#c4-build-output-and-debug-files-are-not-ignored-by-git)
- [ ] [C5: Source files sit at the module root instead of in a src folder](#c5-source-files-sit-at-the-module-root-instead-of-in-a-src-folder)
- [ ] [C6: Package file is missing the engines, prettier and packageManager fields](#c6-package-file-is-missing-the-engines-prettier-and-packagemanager-fields)
- [ ] [C7: Package file is missing the format and package scripts](#c7-package-file-is-missing-the-format-and-package-scripts)
- [ ] [C8: Prettier is not a dev dependency](#c8-prettier-is-not-a-dev-dependency)
- [ ] [C9: Module asks Companion for Node 18 instead of Node 22](#c9-module-asks-companion-for-node-18-instead-of-node-22)
- [ ] [H1: Module checks workflow adds a unit test job the template does not have](#h1-module-checks-workflow-adds-a-unit-test-job-the-template-does-not-have)

### Non-blocking

- [ ] [M1: Feedbacks with a Camera ID keep showing an old camera state when Monitor all cameras is off](#m1-feedbacks-with-a-camera-id-keep-showing-an-old-camera-state-when-monitor-all-cameras-is-off)
- [ ] [L1: Variables of a camera removed during a reconnect stay listed until the module restarts](#l1-variables-of-a-camera-removed-during-a-reconnect-stay-listed-until-the-module-restarts)
- [ ] [L2: Set CCU Value shows no variable picker for its Value field](#l2-set-ccu-value-shows-no-variable-picker-for-its-value-field)
- [ ] [N1: Set Speed rounds a decimal Zoom speed without saying so](#n1-set-speed-rounds-a-decimal-zoom-speed-without-saying-so)

## 🔴 Critical

### C1: The module cannot be installed or packaged with the standard build

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

**Fix:** move the module onto the template's Yarn 4 setup: add `"packageManager": "yarn@4.12.0"` and the template's `.yarnrc.yml` (C2), add the `package` script (C7), then run `yarn install` with Yarn 4 and commit the regenerated `yarn.lock`.

### C2: Yarn settings file is missing, so installs don't use the template's safety settings

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

### C3: Line-ending settings file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor on Windows can commit files with CRLF line endings, which then show up as whole-file changes and formatting failures.

**Why it happens:** The template tracks a `.gitattributes` that forces LF line endings; the module does not have one.

**Fix:** add the template's `.gitattributes`.

```text
* text=auto eol=lf
```

### C4: Build output and debug files are not ignored by git

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

### C5: Source files sit at the module root instead of in a src folder

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** partly 🆕 NEW — [`upgrades.js`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/upgrades.js), [`upgrades.test.js`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/upgrades.test.js) and [`feedbacks.test.js`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/feedbacks.test.js) were added at the root in this release; the other 12 files were already there in v3.4.0
- **File:** module root (15 files)

**What goes wrong:** All of the module's code lives next to `package.json`, `yarn.lock` and the config files, unlike every other module built from the template. Anyone troubleshooting the module later has to work around a layout the build tooling and templates don't expect.

**Why it happens:** The template keeps all source under `src/` (entry point `src/main.js`). This module has these files at the root: `actions.js`, `commands.js`, `commands.test.js`, `config.js`, `discovery.js`, `discovery.test.js`, `feedbacks.js`, `feedbacks.test.js`, `index.js`, `lib.js`, `lib.test.js`, `presets.js`, `upgrades.js`, `upgrades.test.js`, `variables.js`.

**Fix:** move the source and test files into `src/`, then update `"main"` in `package.json` and `runtime.entrypoint` in `companion/manifest.json` to point at the new entry file (e.g. `src/main.js`, entrypoint `../src/main.js`).

### C6: Package file is missing the engines, prettier and packageManager fields

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json)

**What goes wrong:** Nothing pins the Node and Yarn versions the module is built with, and the formatter has no shared config, so builds and formatting differ between machines (and `packageManager` is part of why C1 fails).

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

### C7: Package file is missing the format and package scripts

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

### C8: Prettier is not a dev dependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/package.json)

**What goes wrong:** The `format` script (C7) has no Prettier installed to run.

**Why it happens:** `devDependencies` only lists `@companion-module/tools`; the template also lists `prettier`.

**Fix:** add `"prettier": "^3.7.4"` to `devDependencies`.

### C9: Module asks Companion for Node 18 instead of Node 22

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** template check (whole module) — already the case in v3.4.0
- **File:** [`companion/manifest.json`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/companion/manifest.json)

**What goes wrong:** Companion starts the module on the Node 18 runtime, which is end-of-life, instead of the Node 22 runtime the template targets.

**Why it happens:** The manifest has `"runtime": { "type": "node18", … }`; the template has `"node22"`.

**Fix:** set `runtime.type` to `"node22"` in `companion/manifest.json`.

## 🟠 High

### H1: Module checks workflow adds a unit test job the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW change to an already-differing file — v3.4.0 already had the `unit:` job; this release added `cache: yarn` and the install step to it
- **File:** [`.github/workflows/companion-module-checks.yaml:19-32`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/.github/workflows/companion-module-checks.yaml#L19-L32)

**What goes wrong:** The workflow file differs from the template, so it no longer matches what other modules run. The extra job also runs on Node 18 with `yarn install --frozen-lockfile`, a Yarn 1 command that stops working once the module moves to Yarn 4 (C1).

**Why it happens:** The template's `companion-module-checks.yaml` ends after the `check:` job at line 17. The module adds a second `unit:` job.

**Evidence:**

```yaml
# .github/workflows/companion-module-checks.yaml:19-32
  unit:
    name: Unit tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 18
          cache: yarn
      # The tests import the real module files, some of which import @companion-module/base.
      - name: Install dependencies
        run: yarn install --frozen-lockfile
      - name: Run unit tests
        run: node --test
```

**Confirm by:** diff [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-middlethings-middlecontrol/blob/f760cd6905d79dcb2c74efcd33f9a04d7abd3d59/.github/workflows/companion-module-checks.yaml) against `companion-module-template-js-v1/.github/workflows/companion-module-checks.yaml` (the template ends at line 17).

**Fix:** restore the template's `companion-module-checks.yaml` (remove lines 19-32). Run the unit tests locally with `yarn test`, or from a separate workflow file of your own.

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
