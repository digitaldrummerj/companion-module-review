# Review: companion-module-google-nest v1.0.6 (follow-up to the v1.0.4 review)

| | |
| --- | --- |
| **Module** | [companion-module-google-nest](https://github.com/bitfocus/companion-module-google-nest) |
| **Scope** | `tag` |
| **Version** | v1.0.6 (`9ad5490`) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Prior reviews** | [v1.0.4, 2026-11-06](review-google-nest-v1.0.4-20261106-181511.md) — ❌ Changes Required · [v1.0.1, 2026-10-30](review-google-nest-v1.0.1-20261030-090507.md) — ❌ Changes Required |
| **Review date** | 2026-11-09 |

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: The .gitignore file is missing the template's five entries](#c1-the-gitignore-file-is-missing-the-templates-five-entries)
- [ ] [H1: The CI workflow's checkout step differs from the template](#h1-the-ci-workflows-checkout-step-differs-from-the-template)
- [ ] [H2: The CI step that sets up Node is named Use Node.js 2.x instead of 22.x](#h2-the-ci-step-that-sets-up-node-is-named-use-nodejs-2x-instead-of-22x)
- [ ] [H3: Running yarn build no longer clears dist, because the build scripts differ from the template](#h3-running-yarn-build-no-longer-clears-dist-because-the-build-scripts-differ-from-the-template)

### Non-blocking

- [ ] [L1: The ECO preset only turns ECO on, and no preset turns it off again](#l1-the-eco-preset-only-turns-eco-on-and-no-preset-turns-it-off-again)
- [ ] [L2: Four devDependencies are installed but never used](#l2-four-devdependencies-are-installed-but-never-used)
- [ ] [L3: macOS Finder metadata files are committed to the repository](#l3-macos-finder-metadata-files-are-committed-to-the-repository)
- [ ] [N1: The Mode dropdown in Thermostat: Mode active can still be switched to an expression](#n1-the-mode-dropdown-in-thermostat-mode-active-can-still-be-switched-to-an-expression)
- [ ] [N2: Set mode and Thermostat: Eco active don't match the names in the help page](#n2-set-mode-and-thermostat-eco-active-dont-match-the-names-in-the-help-page)
- [ ] [N3: The thermostat mode type now includes ECO, so the compiler would accept ECO for Set mode](#n3-the-thermostat-mode-type-now-includes-eco-so-the-compiler-would-accept-eco-for-set-mode)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The .gitignore file is missing the template's five entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:6-17`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.gitignore#L6-L17), [`.gitignore:45`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.gitignore#L45)

**What goes wrong:** Companion users see no difference. The repository's `.gitignore` doesn't contain the five entries every module built from the template must have: `/pkg`, `/*.tgz`, `/dist`, `/.yarn` and `/.vscode`. The module's own patterns ignore most of the same folders, but not all of them: `.yarn/*` with its `!.yarn/...` exceptions still lets `.yarn/patches`, `.yarn/plugins`, `.yarn/releases`, `.yarn/sdks` and `.yarn/versions` be committed, which the template's `/.yarn` keeps out. The file hasn't changed since v1.0.4, and the earlier reviews didn't raise it.

**Why it happens:** The `.gitignore` was rewritten in commit `0137018` ("Enhance .gitignore with more ignored patterns") with the module's own patterns in place of the template's lines. Extra entries are fine, but each template entry must be present exactly as the template writes it.

**Evidence:** validator message (verbatim): `Missing template .gitignore entries: /pkg, /*.tgz, /dist, /.yarn, /.vscode`

```text
# .gitignore:5-17 (module)
# Yarn (Berry)
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions

# Build artifacts
dist/
build/
pkg/
*.tgz
# .gitignore:44-45 (module)
# IDE/editor
.vscode/
```

```text
# companion-module-template-ts-v2.0.4/.gitignore
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

**Confirm by:** compare the template's `.gitignore` with the module's [`.gitignore`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.gitignore). Every template line must be present verbatim; `/pkg`, `/*.tgz`, `/dist`, `/.yarn` and `/.vscode` are not.

**Fix:** add the five template entries to `.gitignore`. The module's extra entries can stay.

```text
/pkg
/*.tgz
/dist
/.yarn
/.vscode
```

## 🟠 High

### H1: The CI workflow's checkout step differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18-20`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.github/workflows/node.yaml#L18-L20)

**What goes wrong:** Companion users see no difference. The module's CI workflow is not the template's workflow: its checkout step adds a `with: persist-credentials: false` block that the API 2.0 template doesn't have. This was part of the [v1.0.1 review](review-google-nest-v1.0.1-20261030-090507.md)'s H1 and is still in the file; the v1.0.4 review didn't list it separately.

**Why it happens:** The checkout step was edited after the workflow was copied from the template. Everything else in the file matches the template apart from the step name in [H2](#h2-the-ci-step-that-sets-up-node-is-named-use-nodejs-2x-instead-of-22x).

**Evidence:** validator message (verbatim): `Differs from template (line 16: found 'with:', template '- name: Use Node.js 22.x')`

```yaml
# .github/workflows/node.yaml:18-21 (module)
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      - name: Use Node.js 2.x
```

```yaml
# companion-module-template-ts-v2.0.4/.github/workflows/node.yaml:18-19
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
```

**Confirm by:** `diff` the module's [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.github/workflows/node.yaml) against `companion-module-template-ts-v2.0.4/.github/workflows/node.yaml`.

**Fix:** copy the template's `node.yaml`, which removes the two `with:` / `persist-credentials: false` lines from the checkout step.

### H2: The CI step that sets up Node is named Use Node.js 2.x instead of 22.x

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW (the remaining part of v1.0.4 H1)
- **File:** [`.github/workflows/node.yaml:21`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.github/workflows/node.yaml#L21)

**What goes wrong:** The v1.0.4 H1 fix moved the CI build to Node 22: `node-version` is now `22.x` ([`.github/workflows/node.yaml:25`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.github/workflows/node.yaml#L25)), and the commented-out test job says 22.x too. But the step's name was changed from "Use Node.js 26.x" to "Use Node.js 2.x", so the CI log on GitHub labels the step with a Node version that doesn't exist. CI itself runs on the right version. Every other place (the manifest's `node22` runtime, `engines.node` `^22.20`, `@types/node` and the tsconfig preset) already matches.

**Why it happens:** A typo when editing the step name: one `2` was dropped.

**Evidence:** validator message (verbatim): `The API 2.0 template runs on Node 22; update every place still on another version: .github/workflows/node.yaml line 21 step name 'Use Node.js 2.x' -> 'Use Node.js 22.x'`

```yaml
# .github/workflows/node.yaml:21-25
      - name: Use Node.js 2.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
        with:
          node-version: 22.x
```

**Confirm by:** `grep -n 'Use Node.js' .github/workflows/node.yaml` shows `22.x` on every line once fixed.

**Fix:** rename the step to the template's name.

- [ ] `.github/workflows/node.yaml`: `- name: Use Node.js 22.x` (line 21)

### H3: Running yarn build no longer clears dist, because the build scripts differ from the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:9-11`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/package.json#L9-L11)

**What goes wrong:** Companion users see no difference, because `yarn package` still empties `dist/` first through an extra `build:og` script. The effect is on the maintainer: `yarn build` no longer clears `dist/` before compiling, so when a source file is deleted or renamed, its old compiled `.js` file stays in `dist/` during local development. The `build` and `package` commands also no longer match every other TypeScript module built from the template, which makes the module harder to maintain and troubleshoot. Any difference from the template's `package.json` scripts is High under the review rules, even though users never see it.

**Why it happens:** The template's `build` script (`rimraf dist && run build:main`) was moved into a new `build:og` script. `build` was shortened to `run build:main`, and `package` was changed to call `build:og` instead of `build`. This has been the case since the first commit (`00bcc76`, "v1 Init"); the earlier reviews didn't raise it.

**Evidence:**

```json
// package.json:6-16 (module, v1.0.6)
	"scripts": {
		"postinstall": "husky",
		"format": "prettier -w .",
		"package": "run build:og && companion-module-build",
		"build": "run build:main",
		"build:og": "rimraf dist && run build:main",
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
		"lint:raw": "eslint",
		"lint": "run lint:raw ."
	},
```

```json
// companion-module-template-ts-v2.0.4/package.json:6-15
	"scripts": {
		"postinstall": "husky",
		"format": "prettier -w .",
		"package": "run build && companion-module-build",
		"build": "rimraf dist && run build:main",
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
		"lint:raw": "eslint",
		"lint": "run lint:raw ."
	},
```

**Confirm by:** open [`package.json:9-11`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/package.json#L9-L11) and compare it with lines 9-10 of `companion-module-template-ts-v2.0.4/package.json`. In the module, `build` has no `rimraf dist`, there is an extra `build:og` script, and `package` calls `build:og` instead of `build`.

**Fix:** put back the template's two lines and remove `build:og`. Extra scripts are fine to keep, but `build` and `package` must have the template's commands.

```json
"package": "run build && companion-module-build",
"build": "rimraf dist && run build:main",
```

## 🟢 Low

### L1: The ECO preset only turns ECO on, and no preset turns it off again

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:141-158`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/presets.ts#L141-L158), [`src/presets.ts:181`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/presets.ts#L181)

**What goes wrong:** An operator drags the new 'ECO' preset from a thermostat's 'Modes' group (for example 'My Home / Living Room') onto a button and presses it. The thermostat goes into ECO and the button turns green. From then on, the 'TEMP ▲/▼' and 'H/C ▲/▼' presets do nothing except log 'Living Room is in ECO mode; Google rejects setpoint changes. Turn ECO off first ("Set ECO Mode")'. Pressing the ECO button again just sends ECO on again. The Presets tab has no button that turns ECO off, so the operator has to build one by hand with the 'Set ECO Mode' action and Mode = Off.

**Why it happens:** The ECO preset has a single step that always sends 'Set ECO Mode' with Mode = ECO (`MANUAL_ECO`). The 'Modes' group holds Heat, Cool, Heat/Cool, Off and this ECO-on button only. The module's own warning ([`src/actionsThermostat.ts:30-37`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L30-L37)) tells the user to turn ECO off with 'Set ECO Mode', but no preset does that.

**Fix:** make the preset a toggle, or add a separate 'ECO Off' preset next to it in the 'Modes' group. For a toggle, either give the preset two steps (step 1: `set_mode_eco` with `MANUAL_ECO`, step 2: `set_mode_eco` with `OFF`), or add a 'Toggle' choice to 'Set ECO Mode' that sends `OFF` when the cached `traits[TRAIT.ECO]?.mode === 'MANUAL_ECO'` and `MANUAL_ECO` otherwise.

### L2: Four devDependencies are installed but never used

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:32`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/package.json#L32), [`package.json:38`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/package.json#L38), [`package.json:41-42`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/package.json#L41-L42)

**What goes wrong:** No visible effect for Companion users; this is code quality only. Every `yarn install` downloads a test framework (`vitest`), a mocking library (`vitest-mock-extended`), a documentation generator (`typedoc`) and semver typings (`@types/semver`) that nothing in the module uses. The repository has no test files and no `test` or `docs` script, and no source file imports semver. It also takes `package.json` further from the template's devDependency list.

**Why it happens:** The four packages are listed in devDependencies, but nothing in `src/`, the `tsconfig*.json` files or `eslint.config.mjs` refers to them, and none of them is in the API 2.0 TypeScript template.

**Fix:** remove the four packages with `yarn remove @types/semver typedoc vitest vitest-mock-extended`. If you plan to add tests, keep `vitest` and add a `"test": "vitest run"` script with real test files.

### L3: macOS Finder metadata files are committed to the repository

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`.DS_Store`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.DS_Store), [`src/.DS_Store`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/.DS_Store)

**What goes wrong:** No visible effect for Companion users, because the packaged module only ships its built code and the `companion/` folder. The repository contains two macOS Finder metadata files (`.DS_Store` and `src/.DS_Store`) that mean nothing to other contributors and show up in diffs whenever a Mac touches those folders.

**Why it happens:** Both files were committed in the first commit (`00bcc76`, "v1 Init"), before `.DS_Store` was added to `.gitignore` ([`.gitignore:48`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/.gitignore#L48)). Git keeps tracking files that are already committed, even after they are ignored.

**Fix:** run `git rm --cached .DS_Store src/.DS_Store` and commit. The existing `.gitignore` entry then keeps them out.

## 💡 Nice to Have

### N1: The Mode dropdown in Thermostat: Mode active can still be switched to an expression

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW (v1.0.4 N3, not fixed)
- **File:** [`src/feedbacks.ts:83-95`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/feedbacks.ts#L83-L95)

**What goes wrong:** Nothing is visibly wrong by default. A user can switch the feedback's Mode dropdown to expression mode, and a value such as `heat` (lower case) or `ECO` then fails validation: Companion skips the feedback without saying why, so the button never lights up. The action Mode dropdowns are locked to their fixed values, but this feedback dropdown is not. The v1.0.6 commit message says "N1-10 Resolved", but this one (v1.0.4 N3) is unchanged.

**Why it happens:** The fixed-choice Mode dropdown (Heat, Cool, Heat/Cool, ECO, Off) doesn't set `disableAutoExpression: true`. The `@companion-module/base` 2.0.4 typings say a feedback whose option holds an invalid value in expression mode is skipped entirely unless `allowInvalidValues` is set.

**Fix:** add `disableAutoExpression: true` to the `mode` dropdown of the 'Thermostat: Mode active' feedback (`thermostat_mode`), the same way the action Mode dropdowns already do (for example [`src/actionsThermostat.ts:330`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L330)).

### N2: Set mode and Thermostat: Eco active don't match the names in the help page

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW (the remaining part of v1.0.4 N7)
- **File:** [`src/actionsThermostat.ts:321`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L321), [`src/feedbacks.ts:132-133`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/feedbacks.ts#L132-L133)

**What goes wrong:** The action picker shows 'Set mode', but the help page, the README and the module's own warning 'Use "Set Mode" first' ([`src/actionsThermostat.ts:229`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L229)) all call it 'Set Mode', and the action next to it is 'Set ECO Mode' in title case. The feedback picker shows 'Thermostat: Eco active' with the description 'Active when the thermostat is in eco mode', while the help page lists 'Thermostat: ECO active' and the rest of the module writes 'ECO'. This is cosmetic only, but a user who searches the picker for the name in the help page or the log finds a slightly different one.

**Why it happens:** This release renamed 'Set ECO mode' to 'Set ECO Mode' but left 'Set mode' as it was, and the new ECO feedback was named 'Eco' rather than 'ECO'.

**Fix:** rename the action to 'Set Mode' (`name: 'Set Mode'`), and the feedback to 'Thermostat: ECO active' with the description 'Active when the thermostat is in ECO mode', so they match [`companion/HELP.md:18`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/companion/HELP.md#L18), [`companion/HELP.md:29`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/companion/HELP.md#L29) and the README.

### N3: The thermostat mode type now includes ECO, so the compiler would accept ECO for Set mode

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/types.ts:40`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/types.ts#L40), [`src/types.ts:14-16`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/types.ts#L14-L16), [`src/actions.ts:12`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actions.ts#L12)

**What goes wrong:** No visible effect for users; this is code quality only. To give the 'Thermostat: Mode active' feedback an ECO choice, `MANUAL_ECO` was added to the `ThermostatMode` type. The same type also describes the thermostat's mode as Google reports it and the Mode option of the 'Set mode' action. If a future edit added an ECO choice to 'Set mode', it would compile and send ECO through Google's set-mode command (`ThermostatMode.SetMode`), although the module itself turns ECO on through a different command (`ThermostatEco.SetMode`).

**Why it happens:** One type is used both for the device's mode and for the feedback's list of choices, so the feedback-only ECO value leaked into the other two.

**Fix:** keep `ThermostatMode` to the four real modes and give the feedback its own option type. While there, use `TRAIT.ECO` instead of the literal `'sdm.devices.traits.ThermostatEco'` in the 'Set ECO Mode' cache update ([`src/actionsThermostat.ts:385-386`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L385-L386)).

```ts
export type ThermostatMode = 'HEAT' | 'COOL' | 'HEATCOOL' | 'OFF'
export type ModeFeedbackChoice = ThermostatMode | 'MANUAL_ECO'
// FeedbacksSchema.thermostat_mode.options.mode: ModeFeedbackChoice
```

## 📝 Additional Notes

- First release: the module has never been published, so there is no published version to diff against. The whole module at v1.0.6 was reviewed, and every finding is classified 🆕 NEW.
- Follow-up to the [v1.0.4 review](review-google-nest-v1.0.4-20261106-181511.md): one commit (`9ad5490`) since v1.0.4 (`2864fae`). Most v1.0.4 findings are fixed; the CI Node version is fixed apart from a typo in the step name ([H2](#h2-the-ci-step-that-sets-up-node-is-named-use-nodejs-2x-instead-of-22x)), N3 is still open as [N1](#n1-the-mode-dropdown-in-thermostat-mode-active-can-still-be-switched-to-an-expression), and N7 is partly fixed ([N2](#n2-set-mode-and-thermostat-eco-active-dont-match-the-names-in-the-help-page)). The table below lists each prior finding.
- [C1](#c1-the-gitignore-file-is-missing-the-templates-five-entries) and [H3](#h3-running-yarn-build-no-longer-clears-dist-because-the-build-scripts-differ-from-the-template) are in files that haven't changed since v1.0.4, and the earlier reviews didn't raise them. [H1](#h1-the-ci-workflows-checkout-step-differs-from-the-template) was part of the v1.0.1 review's H1 but was left out of the v1.0.4 review.
- Node version: the v1.0.6 commit message says the Bitfocus TS template uses Node 26 everywhere. That is the `main` template for API 2.1 (`@companion-module/base` ~2.1.3, Companion 5.0+). This module is on base 2.0.4 (API 2.0), whose template, like the module's own `node22` runtime, uses Node 22, so 22.x is correct here. If the module later moves to base 2.1, move every Node version to 26 in the same change.
- Build and lint passed (`yarn install --immutable`, `yarn package`, `yarn lint`).

### Prior findings from the v1.0.4 review

| v1.0.4 | Finding | Status in v1.0.6 |
| --- | --- | --- |
| H1 | CI builds and lints on Node 26 | 🟡 Partly fixed: `node-version` is `22.x` in both jobs, but the step name now reads "Use Node.js 2.x", now [H2](#h2-the-ci-step-that-sets-up-node-is-named-use-nodejs-2x-instead-of-22x) |
| L1 | A Poll Interval of 0, empty or below 15 polls back-to-back | ✅ Fixed: the value is clamped to 15-300 s with a 30 s fallback ([`src/main.ts:117`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/main.ts#L117)) |
| L2 | One more failing request after a dead refresh token | ✅ Fixed: a rejected token sets a flag that keeps startup from starting the poll timer ([`src/main.ts:115-116`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/main.ts#L115-L116), [`src/main.ts:216-219`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/main.ts#L216-L219)) |
| L3 | Feedback Device dropdown can't tell same-named thermostats apart | ✅ Fixed: the feedback labels carry the home name, like the actions ([`src/feedbacks.ts:34-43`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/feedbacks.ts#L34-L43)) |
| L4 | Current temperature preset looks the same online and offline | ✅ Fixed: the feedback is inverted and turns the button red while the thermostat is offline ([`src/presets.ts:61-68`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/presets.ts#L61-L68)) |
| L5 | Refresh Token tooltip points to a help page with no instructions | ✅ Fixed: HELP.md now covers the setup, connection settings, actions, feedbacks, presets and variables ([`companion/HELP.md`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/companion/HELP.md)), and the tooltip no longer points to it ([`src/config.ts:63`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/config.ts#L63)) |
| L6 | Action option types re-declared and cast in the callbacks | ✅ Fixed: the callbacks take their types from `ActionsSchema` and the cast is gone ([`src/actions.ts:12`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actions.ts#L12), [`src/actionsThermostat.ts:339-350`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L339-L350)); the shared mode type now includes ECO, see [N3](#n3-the-thermostat-mode-type-now-includes-eco-so-the-compiler-would-accept-eco-for-set-mode) |
| N1 | Network failures show only "fetch failed" as an unknown error | ✅ Fixed: the cause is added to the message and network failures are reported as a connection failure ([`src/helpers.ts:55-66`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/helpers.ts#L55-L66), [`src/main.ts:224-225`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/main.ts#L224-L225)) |
| N2 | No feedback shows ECO mode | ✅ Fixed: new 'Thermostat: Eco active' feedback and an ECO preset ([`src/feedbacks.ts:130-151`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/feedbacks.ts#L130-L151)); the preset only turns ECO on, see [L1](#l1-the-eco-preset-only-turns-eco-on-and-no-preset-turns-it-off-again) |
| N3 | Feedback Mode dropdown can be switched to an expression | ❌ Still open: now [N1](#n1-the-mode-dropdown-in-thermostat-mode-active-can-still-be-switched-to-an-expression) |
| N4 | Contradictory warning right after a mode change | ✅ Fixed: a separate "setpoint not loaded yet" warning ([`src/actionsThermostat.ts:136-141`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L136-L141), [`src/actionsThermostat.ts:177-181`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L177-L181)) |
| N5 | Fan Timer shows Run Time when Mode is Off | ✅ Fixed: Run Time is shown only when Mode is On ([`src/actionsThermostat.ts:419`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/actionsThermostat.ts#L419)) |
| N6 | Variable names are raw Google API identifiers | ✅ Fixed: known traits get friendly names ([`src/variables.ts:12-34`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/variables.ts#L12-L34)) |
| N7 | Inconsistent action and feedback names, descriptions and labels | 🟡 Partly fixed: descriptions added, 'Heat/Cool' used everywhere, 'Set ECO Mode' renamed; 'Set mode' and the new 'Thermostat: Eco active' still differ, now [N2](#n2-set-mode-and-thermostat-eco-active-dont-match-the-names-in-the-help-page) |
| N8 | Variable definitions re-sent on every poll | ✅ Fixed: definitions are sent only when they change ([`src/variables.ts:87-97`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/variables.ts#L87-L97)) |
| N9 | Successful command responses never read | ✅ Fixed: the body is cancelled on success ([`src/sdm-client.ts:99`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/sdm-client.ts#L99)) |
| N10 | Stale comment and unused code | ✅ Fixed: the comment is updated ([`src/main.ts:150-154`](https://github.com/bitfocus/companion-module-google-nest/blob/9ad5490d4bd67815e80c145278eabc19928e072c/src/main.ts#L150-L154)), `getDevice()` is removed, and the unused `online` preset id was replaced by the ECO preset |
