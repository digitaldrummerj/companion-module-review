# Review: qsys-remote-control v4.0.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-qsys-remote-control` |
| **Scope** | `tag` (v3.2.6..v4.0.1) |
| **Version** | v4.0.1 |
| **Release** | Update — last published v3.2.6 |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11, main) |
| **Commit** | [`0b2c8ce`](https://github.com/bitfocus/companion-module-qsys-remote-control/commit/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A feedback style value that is an object (`{ isExpression, value }`) instead of a number renders as no colour or an invalid colour, rather than being unwrapped by Companion | Upgrade-script output is stored unchanged (confirmed); how Companion's button renderer treats a non-numeric `style.bgcolor` was not traced | [M1](#m1-very-old-boolean-and-threshold-feedbacks-lose-their-colours-when-upgraded) |
| A2 | Companion's action recorder stores `recordAction` options as given, so a `''` value lands in a number option and the editor shows it as blank or invalid | base 2.2.1 types `recordAction` options as plain `CompanionOptionValues` with no module-side validation; the host side is not visible from the module | [L1](#l1-recorded-control-set-actions-get-blank-ramp-minimum-and-maximum-fields) |
| A3 | When a module stops defining a feedback id, Companion keeps the saved feedback on the button and shows it as unknown or unavailable in the button editor, rather than silently dropping it | General Companion behaviour for missing definitions; not verifiable from the module or the base package | [L2](#l2-buttons-with-the-old-change-text-to-reflect-control-value-feedback-show-an-unknown-feedback) |

## 📋 Issues

### Blocking

- [ ] [C1: Module source files are at the repository root, not under src](#c1-module-source-files-are-at-the-repository-root-not-under-src)
- [ ] [C2: Yarn settings allow install scripts and packages from any Git repository](#c2-yarn-settings-allow-install-scripts-and-packages-from-any-git-repository)
- [ ] [C3: Git ignore rules miss the templates lockfile, package and Yarn entries](#c3-git-ignore-rules-miss-the-templates-lockfile-package-and-yarn-entries)
- [ ] [C4: Two template files are missing (gitattributes and prettierignore)](#c4-two-template-files-are-missing-gitattributes-and-prettierignore)
- [ ] [C5: Second maintainer in the manifest has no contact email](#c5-second-maintainer-in-the-manifest-has-no-contact-email)
- [ ] [H1: LICENSE file does not match the template](#h1-license-file-does-not-match-the-template)
- [ ] [H2: Release workflow does not match the template](#h2-release-workflow-does-not-match-the-template)

### Non-blocking

- [ ] [M1: Very old Boolean and Threshold feedbacks lose their colours when upgraded](#m1-very-old-boolean-and-threshold-feedbacks-lose-their-colours-when-upgraded)
- [ ] [M2: Module memory keeps growing with every new meter or indicator image](#m2-module-memory-keeps-growing-with-every-new-meter-or-indicator-image)
- [ ] [L1: Recorded Control Set actions get blank Ramp, Minimum and Maximum fields](#l1-recorded-control-set-actions-get-blank-ramp-minimum-and-maximum-fields)
- [ ] [L2: Buttons with the old Change text to reflect control value feedback show an unknown feedback](#l2-buttons-with-the-old-change-text-to-reflect-control-value-feedback-show-an-unknown-feedback)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Module source files are at the repository root, not under src

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW (three of the files were added in this tag; the rest are unchanged since v3.2.6)
- **File:** [`composites.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/composites.js), [`composites.spec.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/composites.spec.js), [`config.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/config.js), [`index.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js), [`index.spec.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.spec.js), [`options.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/options.js), [`upgrades.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/upgrades.js), [`upgrades.spec.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/upgrades.spec.js), [`utils.js`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/utils.js)

**What goes wrong:** All of the module's code sits at the top of the repository instead of in a `src/` folder. Every Companion module is expected to follow the template layout, so tooling and other maintainers can find the code in the usual place. This release adds three more files at the root (`composites.js`, `composites.spec.js`, `upgrades.spec.js`).

**Why it happens:** The template keeps all source under `src/` with `src/main.js` as the entry point. This module keeps its entry point at `index.js`: `package.json` has `"main": "index.js"` and [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/companion/manifest.json#L27) has `"entrypoint": "../index.js"`.

**Evidence (expected vs found):**

```text
Expected: all source files under src/ (template entry src/main.js)
Found:    composites.js, composites.spec.js, config.js, index.js, index.spec.js,
          options.js, upgrades.js, upgrades.spec.js, utils.js at the module root
```

**Confirm by:** list the repository root at [`0b2c8ce`](https://github.com/bitfocus/companion-module-qsys-remote-control/tree/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1). There is no `src/` folder.

**Fix:** move the source and spec files into `src/` and point both entry settings at the same file (keeping the name `index.js` is fine). `vitest.config.js` stays at the root.

```json
// package.json
"main": "src/index.js",
// companion/manifest.json
"entrypoint": "../src/index.js"
```

### C2: Yarn settings allow install scripts and packages from any Git repository

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check; the settings are unchanged since v3.2.6)
- **File:** [`.yarnrc.yml:1-4`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/.yarnrc.yml#L1-L4)

**What goes wrong:** Anyone who installs the module's dependencies lets every package run its own install scripts, and Yarn will accept dependencies pulled from any Git repository. The template turns both off to protect maintainers and the build server from a compromised dependency.

**Why it happens:** The module's `.yarnrc.yml` sets `enableScripts: true` (template: `false`) and adds an `approvedGitRepositories` key that the template does not have.

**Evidence (expected vs found):**

```yaml
# .yarnrc.yml:1-4
approvedGitRepositories:
  - '**'

enableScripts: true
```

Template: `enableScripts: false` and no `approvedGitRepositories` key.

**Confirm by:** open [`.yarnrc.yml:1-4`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/.yarnrc.yml#L1-L4) and compare it with the template's `.yarnrc.yml`.

**Fix:** delete the `approvedGitRepositories` block and set `enableScripts: false`, then confirm `yarn install` still works.

### C3: Git ignore rules miss the templates lockfile, package and Yarn entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check; the file is unchanged since v3.2.6)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/.gitignore)

**What goes wrong:** A stray `package-lock.json`, a packaged `.tgz` with a different name, or the `.yarn` folder can be committed by accident.

**Why it happens:** The template's `.gitignore` has `package-lock.json`, `/*.tgz` and `/.yarn`. The module has `.yarn/*` with `!.yarn/...` exceptions and `qsys-remote-control-*.tgz`, but not the template's own entries.

**Evidence (expected vs found):**

```text
Missing template .gitignore entries: package-lock.json, /*.tgz, /.yarn
```

**Confirm by:** open [`.gitignore`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/.gitignore) and compare it with the template's `.gitignore`.

**Fix:** add the three template entries (the module's extra entries can stay).

```text
package-lock.json
/*.tgz
/.yarn
```

### C4: Two template files are missing (gitattributes and prettierignore)

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check; both files are also absent in v3.2.6)
- **File:** `.gitattributes`, `.prettierignore` (not present in the repository)

**What goes wrong:** Without `.gitattributes`, line endings can change depending on the contributor's OS, which produces noisy diffs. Without `.prettierignore`, Prettier formats generated and packaged files it should skip.

**Why it happens:** Both files are part of the template and were never added to this module.

**Evidence (expected vs found):**

```text
.gitattributes  — Required file is missing (tracked by the template)
.prettierignore — Required file is missing (tracked by the template)
```

**Confirm by:** list the repository root at [`0b2c8ce`](https://github.com/bitfocus/companion-module-qsys-remote-control/tree/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1). Neither file exists.

**Fix:** copy `.gitattributes` and `.prettierignore` from `companion-module-template-js` unchanged.

### C5: Second maintainer in the manifest has no contact email

- **Source:** 🤖 validate-template (MAN-PLACEHOLDER)
- **Classification:** 🆕 NEW (template check; the entry is unchanged since v3.2.6)
- **File:** [`companion/manifest.json:17-20`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/companion/manifest.json#L17-L20)

**What goes wrong:** Bitfocus and users have no way to contact the second listed maintainer about the module.

**Why it happens:** The second entry in `maintainers` has an empty `email`.

**Evidence (expected vs found):**

```json
// companion/manifest.json:17-20
{
	"name": "Phillip Ivan Pietruschka",
	"email": ""
}
```

**Confirm by:** open [`companion/manifest.json:17-20`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/companion/manifest.json#L17-L20).

**Fix:** add a real contact email for this maintainer, or remove the entry.

## 🟠 High

### H1: LICENSE file does not match the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW (template check; the file is unchanged since v3.2.6)
- **File:** [`LICENSE:1-3`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/LICENSE#L1-L3)

**What goes wrong:** The module's licence text and copyright holder differ from the standard Bitfocus licence every module ships with.

**Why it happens:** The file starts with `The MIT License` and `Copyright (c) 2019 Andreas H. Thomsen`; the template's starts with `MIT License` and `Copyright (c) 2022 Bitfocus AS - Open Source`.

**Evidence (expected vs found):**

```text
Found:    The MIT License
          Copyright (c) 2019 Andreas H. Thomsen
Template: MIT License
          Copyright (c) 2022 Bitfocus AS - Open Source
```

**Confirm by:** open [`LICENSE:1-3`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/LICENSE#L1-L3) and compare it with the template's `LICENSE`.

**Fix:** replace `LICENSE` with the template's file verbatim.

### H2: Release workflow does not match the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (this tag only changed Node 22.x to 26.x here; the structural difference pre-dates v4.0.1)
- **File:** [`.github/workflows/release.yaml:10-65`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/.github/workflows/release.yaml#L10-L65)

**What goes wrong:** Releases are packaged by a hand-written workflow instead of the shared Bitfocus module checks, so release builds don't get the same checks and packaging as every other module, and fixes to the shared workflow never reach this module.

**Why it happens:** The template's `release.yaml` has a `package` job that calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` and a separate `attach` job that downloads the `pkg` artifact and uploads it with a normalised asset name. This module replaces both with one self-built job.

**Evidence (expected vs found):**

```yaml
# .github/workflows/release.yaml:10-18 (module)
# Deliberately does not run lint or tests. This fires on release: published, by
# which point the release already exists — a failing check here could not stop it
# being issued, only leave it with no package attached. A tagged release is better
# off with a build than without one. Gating belongs on the tag push in node.yaml.
jobs:
  package:
    name: Package and attach to release
    runs-on: ubuntu-latest
    timeout-minutes: 15
# :24       - uses: actions/checkout@v7
# :28-32    - uses: actions/setup-node@v7 with node-version: 26.x
# :38       yarn install
# :49-54    yarn package --dev [--prerelease]
# :63       gh release upload "${{ github.event.release.tag_name }}" ./*.tgz --clobber
```

Template `release.yaml:10-53`: a `package` job with `uses: bitfocus/actions/.github/workflows/module-checks.yaml@main` (`git-ref`, `prerelease`, `upload-artifact: true`, `if: !contains(github.repository, 'companion-module-template-')`, `permissions: packages: read`), then an `attach` job (`needs: package`, `timeout-minutes: 5`) that downloads artifact `pkg` with `actions/download-artifact@v8` and uploads it as `$ASSET` with `--repo "$GITHUB_REPOSITORY"`.

**Confirm by:** `diff companion-module-template-js/.github/workflows/release.yaml .github/workflows/release.yaml`, or open [`.github/workflows/release.yaml:10-65`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/.github/workflows/release.yaml#L10-L65).

**Fix:** replace `.github/workflows/release.yaml` with the template's file verbatim.

## 🟡 Medium

### M1: Very old Boolean and Threshold feedbacks lose their colours when upgraded

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`upgrades.js:228-238`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/upgrades.js#L228-L238)

**What goes wrong:** A user imports or upgrades a config whose "Feedback on boolean control value" or "Feedback on control value threshold" feedbacks were made before module v2.0.0 (December 2022) and still carry the old background/text colour options. When the control turns on, the button shows no red background (or an invalid colour) instead of the colour the user picked. Anyone whose config has already been used with module v2.0.0 or later is not affected, because the first upgrade script has already run for them.

**Why it happens:** This release moves the module to `@companion-module/base` 2.2.1, so Companion now hands every upgrade script its options wrapped as `{ isExpression: false, value: 16711680 }` rather than the bare colour `16711680`. Upgrade script 0 still uses the base helper `CreateConvertToBooleanFeedbackUpgradeScript`, which copies the option straight into the feedback style (`feedback.style[style_key] = rawVal`, `node_modules/@companion-module/base/dist/module-api/upgrade.js:37-39`). The style therefore receives the wrapper object, not the number. Under base 1.x the same helper was correct.

**Evidence:**

```js
// upgrades.js:228-238
export default [
	CreateConvertToBooleanFeedbackUpgradeScript({
		'control-boolean': {
			bg: 'bgcolor',
			fg: 'color',
		},
		'control-threshold': {
			bg: 'bgcolor',
			fg: 'color',
		},
	}),
```

**Fix:** keep index 0 but replace the helper with a local script that unwraps the value before writing the style. Only connections that never ran index 0 receive it, so changing it in place is safe. Add a test in `upgrades.spec.js` that feeds wrapped `bg`/`fg` values in.

```js
function convertToBooleanFeedbacks(_ctx, props) {
	const updatedFeedbacks = []
	const map = { bg: 'bgcolor', fg: 'color' }
	for (const fb of props.feedbacks) {
		if (fb.feedbackId !== 'control-boolean' && fb.feedbackId !== 'control-threshold') continue
		let changed = false
		for (const [opt, style] of Object.entries(map)) {
			const o = fb.options[opt]
			if (o === undefined) continue
			fb.style ??= {}
			if (!o.isExpression) fb.style[style] = o.value
			delete fb.options[opt]
			changed = true
		}
		if (changed) updatedFeedbacks.push(fb)
	}
	return { updatedConfig: null, updatedActions: [], updatedFeedbacks }
}
```

### M2: Module memory keeps growing with every new meter or indicator image

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`package.json:22`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/package.json#L22)

**What goes wrong:** Users with pages of the (now deprecated) Level Meter, Indicator or LED advanced feedbacks see the module's memory use climb as the controls change. Each distinct image (for example a Level Meter at 37% on a 72x72 button) is about 20 KB and is kept for the life of the process. v3.1.1 capped this cache at 5000 entries ("Improvement: Limit drawing library cache size" in the README); v4.0.1 drops the cap without mentioning it in the changelog, so with several meters on different button sizes or option sets the cache can grow to tens or hundreds of MB.

**Why it happens:** This tag deletes the Yarn patch `.yarn/patches/companion-module-utils-npm-0.5.0-031725c535.patch`, which evicted the oldest image once the cache held more than 5000, and moves to plain `companion-module-utils` `^0.6.1`. The 0.6.1 image cache is an unbounded `Map` (`this.data.set(key, imageBuffer)`), and the feedbacks at [`index.js:1446`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L1446), [`:1514`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L1514), [`:1537`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L1537), [`:1551`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L1551) and [`:1567`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L1567) still draw through it on every recheck.

**Fix:** re-apply an equivalent Yarn patch to `companion-module-utils@0.6.1` (evict the oldest entry above 5000), or upstream the cap and depend on a release that has it. If dropping the cap was deliberate because these feedbacks are deprecated in favour of composite elements, say so in the changelog.

## 🟢 Low

### L1: Recorded Control Set actions get blank Ramp, Minimum and Maximum fields

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:2053-2070`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L2053-L2070)

**What goes wrong:** A user clicks Record in Companion's action recorder and moves a fader on the Q-SYS core. Each recorded "Control.Set" action is saved with Ramp, Minimum and Maximum set to an empty string, so the editor shows blank or invalid number fields that differ from a hand-added Control.Set. The action still sends correctly (no ramp and no clamping are applied).

**Why it happens:** This release turns Ramp, Minimum and Maximum into number fields (defaults 0, lowest and highest safe number), and the upgrade script converts blanks to those numbers for existing actions. The recorder code was not updated and still builds `min: ''`, `max: ''`, `ramp: ''`.

**Fix:** record the new field defaults instead of empty strings (or leave the three options out so Companion fills in the defaults).

```js
min: Number.MIN_SAFE_INTEGER,
max: Number.MAX_SAFE_INTEGER,
ramp: 0,
```

### L2: Buttons with the old Change text to reflect control value feedback show an unknown feedback

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:1286`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L1286), [`options.js:612-621`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/options.js#L612-L621)

**What goes wrong:** Some users still have the long-deprecated "Change text to reflect control value" feedback (`control-string`) on their buttons. After upgrading to v4.0.1 its definition is gone, so those buttons keep a feedback that Companion most likely shows as unknown or unavailable in the button editor, and the user has to delete it by hand. The button's look doesn't change, because the feedback never styled anything.

**Why it happens:** This tag deletes `feedbacks['control-string']` from `initFeedbacks()` (it used to sit just before "Feedback on boolean control value", now at [`index.js:1286`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/index.js#L1286)). No upgrade script handles existing instances, and its option builder `options.feedbacks.controlString` is left behind as dead code.

**Fix:** either keep a minimal deprecated `control-string` definition (as v3.2.6 did) so existing buttons stay valid, or state in HELP.md and the release notes that the feedback is gone and must be removed from buttons. Either way, delete the unused `controlString` builder in [`options.js:612-621`](https://github.com/bitfocus/companion-module-qsys-remote-control/blob/0b2c8ce9fc78463ba21d462f453eaf2df7f18ca1/options.js#L612-L621).

## 📝 Additional Notes

- The module is on API 2.2 (`@companion-module/base` 2.2.1). The API compliance check covers only the v2.0 and v2.1 rules; no v2.2-specific rules were available to check against.
