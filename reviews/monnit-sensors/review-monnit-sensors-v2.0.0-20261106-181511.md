# Review: monnit-sensors v2.0.0

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-monnit-sensors`](https://github.com/bitfocus/companion-module-monnit-sensors) |
| **Scope** | `tag` (v1.2.0..v2.0.0) |
| **Version** | v2.0.0 (`05b0319`) |
| **Release** | Update — last published v1.2.0 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When Companion loads a saved feedback that lacks an option the definition now has (for example `above_bgcolor`), it does not fill in that option's default, so the callback receives `undefined` | The `@companion-module/base` 2.2.2 types pass the stored options through unchanged, and the module's own v1.1.0 upgrade script added these keys explicitly. Companion's host code was not checked | [M1](#m1-temperature-and-humidity-threshold-buttons-stop-changing-colour-for-users-who-update-straight-from-v10x) |
| A2 | When an advanced feedback returns `bgcolor` and `color` as `undefined`, Companion ignores them and the button keeps its normal style, rather than erroring or applying another colour | Reproduced locally that the callback returns `{ bgcolor: undefined, color: undefined }`, which JSON serialisation turns into `{}`. Not checked: that the module-to-Companion channel drops `undefined` keys, and how Companion merges the style | [M1](#m1-temperature-and-humidity-threshold-buttons-stop-changing-colour-for-users-who-update-straight-from-v10x) |

## 📋 Issues

### Blocking

- [ ] [C1: The module cannot be built into an installable package](#c1-the-module-cannot-be-built-into-an-installable-package)
- [ ] [C2: package.json has no package script](#c2-packagejson-has-no-package-script)
- [ ] [C3: Source files sit at the repository root instead of in src](#c3-source-files-sit-at-the-repository-root-instead-of-in-src)
- [ ] [C4: The Yarn version is not pinned and the lockfile is a Yarn 1 lockfile](#c4-the-yarn-version-is-not-pinned-and-the-lockfile-is-a-yarn-1-lockfile)
- [ ] [C5: The Yarn 4 install hardening is missing because .yarnrc.yml is absent](#c5-the-yarn-4-install-hardening-is-missing-because-yarnrcyml-is-absent)
- [ ] [C6: Build output and the Yarn cache are not ignored by git](#c6-build-output-and-the-yarn-cache-are-not-ignored-by-git)
- [ ] [C7: Line endings are not pinned to LF because .gitattributes is missing](#c7-line-endings-are-not-pinned-to-lf-because-gitattributes-is-missing)
- [ ] [C8: Formatting would rewrite files the template leaves alone because .prettierignore is missing](#c8-formatting-would-rewrite-files-the-template-leaves-alone-because-prettierignore-is-missing)
- [ ] [C9: package.json has no format script](#c9-packagejson-has-no-format-script)

### Non-blocking

- [ ] [M1: Temperature and Humidity Threshold buttons stop changing colour for users who update straight from v1.0.x](#m1-temperature-and-humidity-threshold-buttons-stop-changing-colour-for-users-who-update-straight-from-v10x)
- [ ] [M2: Publishing a GitHub release does not attach a built package](#m2-publishing-a-github-release-does-not-attach-a-built-package)
- [ ] [N1: Battery, signal and last check-in thresholds accept negative values](#n1-battery-signal-and-last-check-in-thresholds-accept-negative-values)
- [ ] [N2: Aborting a button's actions does not cancel a running sensor refresh](#n2-aborting-a-buttons-actions-does-not-cancel-a-running-sensor-refresh)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The module cannot be built into an installable package

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** [`package.json:6-8`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/package.json#L6-L8)

**What goes wrong:** `yarn package`, the command that builds the `.tgz` package Companion installs, fails, so v2.0.0 can't be turned into an installable package.

**Why it happens:** package.json has no `package` script (see [C2](#c2-packagejson-has-no-package-script)), so Yarn has nothing to run.

**Evidence:**

```text
Expected: yarn package builds the module package
Found:    yarn package failed (package.json has no "package" script)
```

**Fix:** add the template's `package` script ([C2](#c2-packagejson-has-no-package-script)), then run `yarn package` and check that it produces the package.

### C2: package.json has no package script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** [`package.json:6-8`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/package.json#L6-L8)

**What goes wrong:** There is no `yarn package` command, so neither you nor the Bitfocus build can turn the module into the package Companion installs. This is the direct cause of [C1](#c1-the-module-cannot-be-built-into-an-installable-package).

**Why it happens:** The template's `scripts` block has `"package": "companion-module-build"`. The module's `scripts` block holds only the npm placeholder `test` script.

**Evidence:**

```json
// package.json:6-8
"scripts": {
	"test": "echo \"Error: no test specified\" && exit 1"
},
```

**Fix:** add the template's script.

```json
"scripts": {
	"format": "prettier -w .",
	"package": "companion-module-build"
},
```

### C3: Source files sit at the repository root instead of in src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** [`actions.js`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/actions.js), [`feedbacks.js`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/feedbacks.js), [`main.js`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/main.js), [`presets.js`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/presets.js), [`upgrades.js`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/upgrades.js), [`variables.js`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/variables.js)

**What goes wrong:** All six source files sit next to package.json, the manifest and the config files. The template keeps every source file under `src/`, so the module's layout differs from every other module built from the template, which makes it harder for others to find their way around and to troubleshoot it.

**Why it happens:** The v1 layout was kept when the module moved to API 2.x. package.json `main` and the manifest's `runtime.entrypoint` still point at the root `main.js`.

**Evidence:**

```text
Expected: all source under src/
Found:    actions.js, feedbacks.js, main.js, presets.js, upgrades.js, variables.js at the module root
```

**Fix:** move the six files into `src/`, then point package.json [`main`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/package.json#L4) and the manifest's [`runtime.entrypoint`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/companion/manifest.json#L21) at the new location, as the template does.

```json
// package.json
"main": "src/main.js",
// companion/manifest.json
"entrypoint": "../src/main.js"
```

### C4: The Yarn version is not pinned and the lockfile is a Yarn 1 lockfile

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/package.json), [`yarn.lock:1-2`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/yarn.lock#L1-L2)

**What goes wrong:** Dependencies are installed with whatever Yarn version each machine happens to have, rather than the Yarn 4.18.1 the template pins, so your machine, CI and the Bitfocus build can install differently. The committed `yarn.lock` is in the Yarn 1 format, which the template's Yarn 4 setup doesn't use.

**Why it happens:** The template pins Yarn with `"packageManager": "yarn@4.18.1"`, which Corepack reads to run that exact Yarn version. The module has no `packageManager` field, and its lockfile was generated by Yarn 1.

**Evidence:**

```text
Expected: "packageManager": "yarn@4.18.1" in package.json
Found:    no packageManager field; yarn.lock starts with "# yarn lockfile v1"
```

**Fix:** add the field, then regenerate the lockfile with Yarn 4 and commit it.

```json
"packageManager": "yarn@4.18.1"
```

```bash
corepack enable
yarn install
```

### C5: The Yarn 4 install hardening is missing because .yarnrc.yml is absent

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing); this release adds [`.yarnrc:1-2`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/.yarnrc#L1-L2) instead

**What goes wrong:** Installing the module's dependencies doesn't get the template's supply-chain protections. Dependencies' install scripts are allowed to run, and a package version published minutes ago (possibly a compromised one) can be installed straight away.

**Why it happens:** The template's `.yarnrc.yml` sets `nodeLinker: node-modules`, `enableScripts: false`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages` for `@companion-module/*`. This release adds a Yarn 1 `.yarnrc` that only turns off the engine check (`ignore-engines true`). Yarn 4 does not read `.yarnrc`.

**Evidence:**

```text
# .yarnrc:1-2
# @companion-module/tools declares engines ^22.18 but is used with Node 26
ignore-engines true
```

**Fix:** delete `.yarnrc` and add the template's `.yarnrc.yml`. Yarn 4 doesn't enforce dependencies' `engines` ranges during install, so the `ignore-engines` workaround should no longer be needed.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C6: Build output and the Yarn cache are not ignored by git

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** [`.gitignore:1-2`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/.gitignore#L1-L2)

**What goes wrong:** Once the module is packaged, `yarn package` writes a `pkg/` folder and a `.tgz` at the repository root, Yarn 4 writes a `.yarn/` folder and debug runs write `DEBUG-*` files. None of these are ignored, so a `git add .` would commit them.

**Why it happens:** The template's `.gitignore` has `/pkg`, `/*.tgz`, `DEBUG-*` and `/.yarn`. The module's has only `node_modules/` and `package-lock.json`.

**Evidence:**

```text
Expected: node_modules/, package-lock.json, /pkg, /*.tgz, DEBUG-*, /.yarn
Found:    node_modules/, package-lock.json
```

**Fix:** add the four missing entries.

```text
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C7: Line endings are not pinned to LF because .gitattributes is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor on Windows can commit files with CRLF line endings. Those show up as whole-file changes in diffs, and Prettier's check then flags every line of those files.

**Why it happens:** The template tracks a `.gitattributes` that makes git store every text file with LF line endings. The module has none.

**Evidence:**

```text
Expected: .gitattributes (tracked by the template)
Found:    no .gitattributes
```

**Fix:** add `.gitattributes` with the template's rule.

```text
* text=auto eol=lf
```

### C8: Formatting would rewrite files the template leaves alone because .prettierignore is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** `.prettierignore` (missing)

**What goes wrong:** Once the `format` script is added ([C9](#c9-packagejson-has-no-format-script)), `yarn format` also reformats `package.json`, which Yarn rewrites in its own format whenever it changes dependencies, so the two tools keep changing the file back and forth.

**Why it happens:** The template's `.prettierignore` excludes `package.json` and `/LICENSE.md` from Prettier. The module has none.

**Evidence:**

```text
Expected: .prettierignore (tracked by the template)
Found:    no .prettierignore
```

**Fix:** add `.prettierignore` with the template's entries.

```text
package.json
/LICENSE.md
```

### C9: package.json has no format script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** [`package.json:6-8`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/package.json#L6-L8)

**What goes wrong:** There is no `yarn format` command, so you and other contributors have no one-step way to apply the module's Prettier style before committing.

**Why it happens:** The template has `"format": "prettier -w ."`. The module's `scripts` block has only the placeholder `test` script.

**Evidence:**

```text
Expected: "format": "prettier -w ." in scripts
Found:    no format script
```

**Fix:** add `"format": "prettier -w ."` to `scripts` (shown together with the `package` script in [C2](#c2-packagejson-has-no-package-script)).

## 🟡 Medium

### M1: Temperature and Humidity Threshold buttons stop changing colour for users who update straight from v1.0.x

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`upgrades.js:1-5`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/upgrades.js#L1-L5), [`feedbacks.js:63-68`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/feedbacks.js#L63-L68), [`feedbacks.js:121-126`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/feedbacks.js#L121-L126)

**What goes wrong:** Take a user who set up buttons on v1.0.0 to v1.0.2 with the "Temperature Threshold" or "Humidity Threshold" feedback (before the colour pickers existed) and then updates directly to v2.0.0. The sensor reads 82 and "Above" is 79. On v1.2.0 that button turned red. On v2.0.0 the feedback returns no colours, so the button keeps its normal style, and the "Above: Background Color", "Above: Text Color", "Below: Background Color" and "Below: Text Color" pickers are empty in the feedback editor. Their "Specific Temperature" and "Specific Humidity" feedbacks still work, but the "Expression" dropdown shows no selection. Users who already ran v1.1.x or v1.2.0 are not affected.

**Why it happens:** Companion runs each upgrade script once per connection, by its position in the list. In v1.2.0, position 0 was the v1.1.0 script that filled in the four colour options and the "Expression" option. v2.0.0 put `EmptyUpgradeScript` at position 0, so a connection that never ran a v1.1.0+ version now runs a script that does nothing. The threshold callbacks read the colour options with no fallback, so they return `undefined` colours. The old script only needs porting to the API 2.x option format (each value wrapped as `{ isExpression: false, value }`), not removing.

**Evidence:**

```js
// upgrades.js:1-5
import { EmptyUpgradeScript } from '@companion-module/base'

// Upgrade scripts from the 1.x module API were removed when moving to @companion-module/base 2.x,
// as their option formats are no longer applicable. Add new scripts after this one.
export const UpgradeScripts = [EmptyUpgradeScript]
```

```js
// feedbacks.js:63-68
if (fb.options.above !== undefined && value > fb.options.above) {
	return { bgcolor: fb.options.above_bgcolor, color: fb.options.above_color }
}
if (fb.options.below !== undefined && value < fb.options.below) {
	return { bgcolor: fb.options.below_bgcolor, color: fb.options.below_color }
}
```

**Confirm by:** compare v1.2.0's [`upgrades.js:4`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/af449a0ef60041859bac8fa8004db618b4a7c722/upgrades.js#L4) and [`upgrades.js:51`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/af449a0ef60041859bac8fa8004db618b4a7c722/upgrades.js#L51) (`module.exports = [upgradeV110]`) with v2.0.0's [`upgrades.js:5`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/upgrades.js#L5), and note there is no fallback for a missing `above_bgcolor` at [`feedbacks.js:64`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/feedbacks.js#L64).

**Fix:** put a real script back at position 0, ported to the API 2.x option format. Connections that already ran it on v1.1.x or later will not run it again. Do this before v2.0.0 is published: once v1.0.x connections have run the empty script, a later fix at position 0 never reaches them.

```js
import { combineRgb } from '@companion-module/base'

const val = (value) => ({ isExpression: false, value })

function upgradeV110(_context, props) {
	const updatedFeedbacks = []
	for (const fb of props.feedbacks) {
		if (
			(fb.feedbackId === 'temperature_specific' || fb.feedbackId === 'humidity_specific') &&
			fb.options.expression === undefined
		) {
			fb.options.expression = val('=')
			updatedFeedbacks.push(fb)
		} else if (
			(fb.feedbackId === 'temperature_warning' || fb.feedbackId === 'humidity_warning') &&
			fb.options.above_bgcolor === undefined
		) {
			Object.assign(fb.options, {
				above_bgcolor: val(combineRgb(255, 0, 0)),
				above_color: val(combineRgb(255, 255, 255)),
				below_bgcolor: val(combineRgb(0, 0, 255)),
				below_color: val(combineRgb(255, 255, 255)),
			})
			updatedFeedbacks.push(fb)
		}
	}
	return { updatedConfig: null, updatedActions: [], updatedFeedbacks }
}

export const UpgradeScripts = [upgradeV110]
```

As a safety net, also fall back to the defaults in the two threshold callbacks, for example `bgcolor: fb.options.above_bgcolor ?? combineRgb(255, 0, 0)`.

### M2: Publishing a GitHub release does not attach a built package

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (first release checked against the API 2.x template)
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** When you publish a release on GitHub, nothing builds the module or attaches the `.tgz` to the release, so users and testers have no ready-made package to download.

**Why it happens:** The template's `release.yaml` runs the Bitfocus module checks for the release's tag and uploads the built package as a release asset. The module's `.github/workflows/` has only `companion-module-checks.yaml`.

**Fix:** copy `.github/workflows/release.yaml` from the template unchanged.

## 💡 Nice to Have

### N1: Battery, signal and last check-in thresholds accept negative values

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`feedbacks.js:278`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/feedbacks.js#L278), [`feedbacks.js:294`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/feedbacks.js#L294), [`feedbacks.js:310`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/feedbacks.js#L310)

**What goes wrong:** The "Below %" field of the "Battery Level Warning" and "Signal Strength Warning" feedbacks accepts anything from -100000 to 100000, and so does "Older Than Minutes" in "Last Checkin". A user who types -20 in "Below %" gets a feedback that never fires, with nothing telling them why, and a negative "Older Than Minutes" always fires. Sensible values work correctly.

**Why it happens:** API 2.x requires `min` and `max` on number fields, and the migration copied one generic range (-100000 to 100000) onto every number field, including the percentage and duration fields.

**Fix:** use `min: 0, max: 100` for the two "Below %" fields and `min: 0` (with a sensible `max`) for "Older Than Minutes". The temperature, humidity, humidex and wet-bulb fields can keep the wide range.

### N2: Aborting a button's actions does not cancel a running sensor refresh

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:8-10`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/actions.js#L8-L10), [`actions.js:23-25`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/actions.js#L23-L25)

**What goes wrong:** A button runs "Refresh All Sensors" or "Refresh Single Sensor" and the user aborts the button's running actions. The request to imonnit.com keeps going, and its result still updates the sensor variables a moment later. The visible effect is small.

**Why it happens:** Since API 2.1, Companion passes action callbacks an abort signal (`context.signal`) that fires when the action is aborted. Both callbacks wait on `fetch` requests ([`main.js:185-193`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/main.js#L185-L193), [`main.js:247-255`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/main.js#L247-L255)) without passing or checking that signal.

**Fix:** accept `(event, context)` in both callbacks, pass `context.signal` through `fetchSensorData(signal)` and `fetchSingleSensor(name, signal)` to `fetch(url, { ..., signal })`, and skip queued work when `signal.aborted` is already true. Polling calls can pass no signal.

## 📝 Additional Notes

- API compliance was re-checked on 2026-11-06 against the API 2.2 rules (companion-v2-api-compliance 1.2.0): the module has no `src/`, so the six source files at the repository root were checked by hand. No value-type feedbacks, preset `storeResult`/`localVariables` or `hasResult`, Regex keys or UDP/shared sockets are used, and every variable id is valid (`last_poll_date`, `last_poll_time`, and per-sensor ids built by [`sanitizeId`](https://github.com/bitfocus/companion-module-monnit-sensors/blob/05b0319e961b88878985634acb9dc36a729ab47a/main.js#L9-L11), which maps every character outside a-z and 0-9 to `_`). No API 2.2 findings.
