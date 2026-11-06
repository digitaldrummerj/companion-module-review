# Review: companion-module-spaceage-visibox v1.0.1 (follow-up to the v1.0.0 review)

| | |
| --- | --- |
| **Module** | [companion-module-spaceage-visibox](https://github.com/bitfocus/companion-module-spaceage-visibox) |
| **Scope** | `tag` |
| **Version** | `v1.0.1` (commit [`a99e086`](https://github.com/bitfocus/companion-module-spaceage-visibox/commit/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Diff** | None published: v1.0.0 was reviewed but never published, so this is still the first release and the whole module was reviewed. Since the v1.0.0 review, `v1.0.0..v1.0.1` changes only tooling and config (`.github`, `.gitignore`, `.yarnrc.yml`, the manifest version, `package.json`, npm lockfile replaced by `yarn.lock`), with no `src/` changes |
| **Follow-up** | Verifies the maintainer's fixes to the [v1.0.0 review](review-spaceage-visibox-v1.0.0-20261030-192328.md) (2026-10-30). What was fixed is listed under [📝 Additional Notes](#-additional-notes); each finding below names its v1.0.0 ID |
| **Date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a user clears a text field in the connection settings and clicks Save, Companion stores an empty string, not "no value" and not the field's default | Usual Companion behaviour for `textinput` config fields; not confirmable from the module code or `@companion-module/base` | [L1](#l1-a-blank-visibox-host-shows-disconnected-with-no-hint-that-the-setting-is-wrong) |
| A2 | When Visibox receives a play or release clip command with only a clip index and no song ID, it applies it to the song that is active when the command arrives | The module's HELP.md ("0 = active song"), the Song Offset tooltip ("0 = active"), the module sending the clip index alone for offset 0, and the client library's `[index, songID?]` signature; Visibox's own behaviour was not checked | [M1](#m1-trigger-clip-with-a-song-offset-past-the-first-or-last-song-plays-the-clip-in-the-current-song) |
| A3 | When a connection is renamed, Companion does not restart the module and does not rewrite the `$(label:...)` references inside preset definitions the module already sent; it only passes the new label and calls `configUpdated()` | `InstanceBase.label` JSDoc and `_handleConfigUpdateAndLabel` in base 1.14.1 (label set just before `configUpdated()`); Companion's host-side preset storage was not checked. The compliance reviewer recalls Companion's host code rewriting these prefixes on a rename (`updateVariablePrefixesForLabel`); if that is right, L3 goes away | [L3](#l3-preset-button-text-keeps-the-old-connection-name-after-the-connection-is-renamed) |
| A4 | Companion 4.2 cannot import a page export with `"version": 12` that contains `button-layered` controls (the Companion 5.0 export format); it refuses the file or produces unusable buttons | The export header of `starter/visibox-starter.companionconfig` (version 12, companionBuild 5.0.5) and the API 1.14 to Companion 4.2 mapping; not tested in Companion 4.2 | [L4](#l4-the-starter-page-needs-companion-50-but-the-module-also-runs-on-companion-42-and-the-help-text-doesnt-say-so) |
| A5 | Companion 4.0 and 4.1 do not offer or run a module built on `@companion-module/base` 1.14 (manifest `apiVersion` 1.14.1) | The v1 compliance skill's version table (API 1.14 means Companion 4.2+); Companion's host-side version gating was not checked | [L5](#l5-readme-says-the-module-works-on-companion-40-but-api-114-needs-companion-42-or-later) |
| A6 | Visibox reports each output-level, mute or fullscreen change as one `state-update` event carrying an `appState` update | Inferred from the client library's message handling (`@visibox/api-client` 1.1.0); not checked against a running Visibox | [H1](#h1-each-output-level-mute-or-fullscreen-change-from-visibox-re-runs-every-feedback-and-rewrites-all-29-variables-three-times) |

## 📋 Issues

### Blocking

- [ ] [C1: `.gitattributes` is missing, so line endings are not normalised](#c1-gitattributes-is-missing-so-line-endings-are-not-normalised)
- [ ] [C2: `.gitignore` is missing template entries, so debug logs and editor settings can be committed](#c2-gitignore-is-missing-template-entries-so-debug-logs-and-editor-settings-can-be-committed)
- [ ] [C3: `.husky/pre-commit` is missing, so commits are not linted or formatted](#c3-huskypre-commit-is-missing-so-commits-are-not-linted-or-formatted)
- [ ] [C4: `.prettierignore` is missing](#c4-prettierignore-is-missing)
- [ ] [C5: `package.json` has no `prettier` field, so formatting does not use the Companion style](#c5-packagejson-has-no-prettier-field-so-formatting-does-not-use-the-companion-style)
- [ ] [C6: `package.json` has no `postinstall` script, so the git hooks are never installed](#c6-packagejson-has-no-postinstall-script-so-the-git-hooks-are-never-installed)
- [ ] [C7: `package.json` has no `format` script](#c7-packagejson-has-no-format-script)
- [ ] [C8: `package.json` has no `build:main` script](#c8-packagejson-has-no-buildmain-script)
- [ ] [C9: `package.json` has no `lint:raw` script](#c9-packagejson-has-no-lintraw-script)
- [ ] [C10: `husky` is not a devDependency](#c10-husky-is-not-a-devdependency)
- [ ] [C11: `lint-staged` is not a devDependency](#c11-lint-staged-is-not-a-devdependency)
- [ ] [C12: `package.json` has no `lint-staged` section](#c12-packagejson-has-no-lint-staged-section)
- [ ] [H1: Each output level, mute or fullscreen change from Visibox re-runs every feedback and rewrites all 29 variables three times](#h1-each-output-level-mute-or-fullscreen-change-from-visibox-re-runs-every-feedback-and-rewrites-all-29-variables-three-times)
- [ ] [H2: The module bundles itself with esbuild instead of the template's build, which Companion's tooling already does](#h2-the-module-bundles-itself-with-esbuild-instead-of-the-templates-build-which-companions-tooling-already-does)

### Non-blocking

- [ ] [M1: Trigger Clip with a Song Offset past the first or last song plays the clip in the current song](#m1-trigger-clip-with-a-song-offset-past-the-first-or-last-song-plays-the-clip-in-the-current-song)
- [ ] [M2: The Node CI workflow is missing](#m2-the-node-ci-workflow-is-missing)
- [ ] [L1: A blank Visibox Host shows Disconnected with no hint that the setting is wrong](#l1-a-blank-visibox-host-shows-disconnected-with-no-hint-that-the-setting-is-wrong)
- [ ] [L2: Set Control "Adjust by amount" counts turns that never reached Visibox, so the next turn jumps](#l2-set-control-adjust-by-amount-counts-turns-that-never-reached-visibox-so-the-next-turn-jumps)
- [ ] [L3: Preset button text keeps the old connection name after the connection is renamed](#l3-preset-button-text-keeps-the-old-connection-name-after-the-connection-is-renamed)
- [ ] [L4: The starter page needs Companion 5.0, but the module also runs on Companion 4.2 and the help text doesn't say so](#l4-the-starter-page-needs-companion-50-but-the-module-also-runs-on-companion-42-and-the-help-text-doesnt-say-so)
- [ ] [L5: README says the module works on Companion 4.0, but API 1.14 needs Companion 4.2 or later](#l5-readme-says-the-module-works-on-companion-40-but-api-114-needs-companion-42-or-later)
- [ ] [N1: Song ID, Control and Target ID fields don't accept variables](#n1-song-id-control-and-target-id-fields-dont-accept-variables)
- [ ] [N2: Pressing a Clip button while Visibox is closed logs "a gate clip may still be playing" although nothing played](#n2-pressing-a-clip-button-while-visibox-is-closed-logs-a-gate-clip-may-still-be-playing-although-nothing-played)
- [ ] [NR1: Consider moving to Companion module API 2.x](#nr1-consider-moving-to-companion-module-api-2x)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.gitattributes` is missing, so line endings are not normalised

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)
- **v1.0.0 review:** [C4](review-spaceage-visibox-v1.0.0-20261030-192328.md#c4-gitattributes-is-missing-so-line-endings-are-not-normalised), not fixed

**What goes wrong:** Without the template's `.gitattributes`, a contributor on Windows can commit files with CRLF line endings, which then show up as whole-file diffs and lint failures.

**Why it happens:** The template's `.gitattributes` forces LF line endings for every text file. The module still has no `.gitattributes`.

**Evidence:**

```text
validate-template: .gitattributes: Required file is missing (tracked by the template)
```

**Confirm by:** `git ls-files .gitattributes` in the module repo prints nothing.

**Fix:** add `.gitattributes` with the template's content.

```text
* text=auto eol=lf
```

### C2: `.gitignore` is missing template entries, so debug logs and editor settings can be committed

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-7`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/.gitignore#L1-L7)
- **v1.0.0 review:** [C5](review-spaceage-visibox-v1.0.0-20261030-192328.md#c5-gitignore-is-missing-template-entries), partly fixed (`package-lock.json` was added)

**What goes wrong:** `DEBUG-*` log files and the `.vscode` folder are not ignored, so they can be committed by accident. The other entries are written differently from the template, so the file does not match what other Companion maintainers expect.

**Why it happens:** v1.0.1 added the template's `package-lock.json` entry, but the rest of the file is still the module's own. It has the unanchored forms `dist/`, `.yarn/`, `*.tgz` and `pkg/` where the template writes `/dist`, `/.yarn`, `/*.tgz` and `/pkg`, and it has no `DEBUG-*` or `/.vscode` entry at all.

**Evidence:**

```text
validate-template: .gitignore: Missing template .gitignore entries: /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode
found: node_modules/, dist/, .test-build/, .yarn/, *.tgz, pkg/, package-lock.json
```

**Confirm by:** open [`.gitignore:1-7`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/.gitignore#L1-L7) and compare it with the template's `.gitignore`.

**Fix:** use the template's entries exactly as the template writes them, and keep the module's own `.test-build/` entry.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
.test-build/
```

### C3: `.husky/pre-commit` is missing, so commits are not linted or formatted

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)
- **v1.0.0 review:** [C6](review-spaceage-visibox-v1.0.0-20261030-192328.md#c6-huskypre-commit-is-missing-so-commits-are-not-linted-or-formatted), not fixed

**What goes wrong:** The template runs lint-staged before every commit, which formats changed files and fixes lint problems. Without the hook, unformatted or failing code can be committed.

**Why it happens:** The module has no `.husky/pre-commit` file, and also lacks the `husky` devDependency and the `postinstall` script that installs the hook ([C6](#c6-packagejson-has-no-postinstall-script-so-the-git-hooks-are-never-installed), [C10](#c10-husky-is-not-a-devdependency)).

**Evidence:**

```text
validate-template: .husky/pre-commit: Required file is missing (tracked by the template)
```

**Confirm by:** `git ls-files .husky` in the module repo prints nothing.

**Fix:** add `.husky/pre-commit` with the template's content.

```text
lint-staged
```

### C4: `.prettierignore` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore` (missing)
- **v1.0.0 review:** [C7](review-spaceage-visibox-v1.0.0-20261030-192328.md#c7-prettierignore-is-missing), not fixed

**What goes wrong:** Running the template's `format` script ([C7](#c7-packagejson-has-no-format-script)) would reformat `package.json`, which the template deliberately leaves alone.

**Why it happens:** The module has no `.prettierignore`.

**Evidence:**

```text
validate-template: .prettierignore: Required file is missing (tracked by the template)
```

**Confirm by:** `git ls-files .prettierignore` in the module repo prints nothing.

**Fix:** add `.prettierignore` with the template's content.

```text
package.json
/LICENSE.md
```

### C5: `package.json` has no `prettier` field, so formatting does not use the Companion style

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json)
- **v1.0.0 review:** [C9](review-spaceage-visibox-v1.0.0-20261030-192328.md#c9-packagejson-has-no-prettier-field-so-formatting-does-not-use-the-companion-style), not fixed

**What goes wrong:** The template points prettier at the shared Companion style from `@companion-module/tools`. Without that field, formatting, and the lint's formatting check, use the module's own `.prettierrc` instead.

**Why it happens:** v1.0.1 added `prettier` as a devDependency, but not the template's `prettier` field in `package.json`.

**Evidence:**

```text
validate-template: package.json: Missing required field 'prettier' (present in template)
expected: "prettier": "@companion-module/tools/.prettierrc.json"
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json); there is no `prettier` field.

**Fix:** add the template's field to `package.json`, then run `yarn format` ([C7](#c7-packagejson-has-no-format-script)) once so the code matches the shared style. The module's own `.prettierrc` is then no longer needed.

```json
"prettier": "@companion-module/tools/.prettierrc.json"
```

### C6: `package.json` has no `postinstall` script, so the git hooks are never installed

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12)
- **v1.0.0 review:** [C11](review-spaceage-visibox-v1.0.0-20261030-192328.md#c11-packagejson-has-no-postinstall-script-so-the-git-hooks-are-never-installed), not fixed

**What goes wrong:** The pre-commit hook from [C3](#c3-huskypre-commit-is-missing-so-commits-are-not-linted-or-formatted) only runs once husky has installed it, which the template does from `postinstall` after every `yarn install`.

**Why it happens:** The module's `scripts` have no `postinstall` entry.

**Evidence:**

```text
validate-template: package.json: Missing required script 'postinstall'
expected: "postinstall": "husky"
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12).

**Fix:** add the template's script.

```json
"postinstall": "husky"
```

### C7: `package.json` has no `format` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12)
- **v1.0.0 review:** [C12](review-spaceage-visibox-v1.0.0-20261030-192328.md#c12-packagejson-has-no-format-script), not fixed

**What goes wrong:** Contributors have no `yarn format` command to apply the shared Companion formatting.

**Why it happens:** The module's `scripts` have no `format` entry.

**Evidence:**

```text
validate-template: package.json: Missing required script 'format'
expected: "format": "prettier -w ."
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12).

**Fix:** add the template's script.

```json
"format": "prettier -w ."
```

### C8: `package.json` has no `build:main` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12)
- **v1.0.0 review:** [C13](review-spaceage-visibox-v1.0.0-20261030-192328.md#c13-packagejson-has-no-buildmain-script), not fixed

**What goes wrong:** The template splits the build into `build` (clean, then run `build:main`) and `build:main` (compile with `tsc`). This module puts its whole esbuild command into `build`, so the script layout other Companion maintainers expect is not there.

**Why it happens:** The module's `build` script runs `rimraf`, `tsc --noEmit` and `esbuild` in one line, and there is no `build:main`. The esbuild step itself is [H2](#h2-the-module-bundles-itself-with-esbuild-instead-of-the-templates-build-which-companions-tooling-already-does); one change fixes both.

**Evidence:**

```text
validate-template: package.json: Missing required script 'build:main'
expected: "build:main": "tsc -p tsconfig.build.json"
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12).

**Fix:** use the template's `build` / `build:main` pair (see [H2](#h2-the-module-bundles-itself-with-esbuild-instead-of-the-templates-build-which-companions-tooling-already-does)).

```json
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json"
```

### C9: `package.json` has no `lint:raw` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12)
- **v1.0.0 review:** [C14](review-spaceage-visibox-v1.0.0-20261030-192328.md#c14-packagejson-has-no-lintraw-script), not fixed

**What goes wrong:** The template's lint-staged section runs `yarn lint:raw --fix` on changed files. Without `lint:raw`, the pre-commit hook would fail once it is added.

**Why it happens:** The module's `lint` script calls `eslint .` directly, and there is no `lint:raw`.

**Evidence:**

```text
validate-template: package.json: Missing required script 'lint:raw'
expected: "lint:raw": "eslint" (and "lint": "run lint:raw .")
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L6-L12).

**Fix:** add the template's script pair.

```json
"lint:raw": "eslint",
"lint": "run lint:raw ."
```

### C10: `husky` is not a devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-36`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L25-L36)
- **v1.0.0 review:** [C15](review-spaceage-visibox-v1.0.0-20261030-192328.md#c15-husky-is-not-a-devdependency), not fixed

**What goes wrong:** The `postinstall` script from [C6](#c6-packagejson-has-no-postinstall-script-so-the-git-hooks-are-never-installed) runs `husky`, which can't install the git hooks when the package is not installed.

**Why it happens:** `husky` is missing from `devDependencies`.

**Evidence:**

```text
validate-template: package.json: Missing devDependency 'husky' (present in template)
expected: "husky": "^9.1.7"
```

**Confirm by:** open [`package.json:25-36`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L25-L36).

**Fix:** `yarn add -D husky@^9.1.7`.

### C11: `lint-staged` is not a devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-36`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L25-L36)
- **v1.0.0 review:** [C16](review-spaceage-visibox-v1.0.0-20261030-192328.md#c16-lint-staged-is-not-a-devdependency), not fixed

**What goes wrong:** The pre-commit hook from [C3](#c3-huskypre-commit-is-missing-so-commits-are-not-linted-or-formatted) runs `lint-staged`, which fails when the package is not installed.

**Why it happens:** `lint-staged` is missing from `devDependencies`.

**Evidence:**

```text
validate-template: package.json: Missing devDependency 'lint-staged' (present in template)
expected: "lint-staged": "^16.2.7"
```

**Confirm by:** open [`package.json:25-36`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L25-L36).

**Fix:** `yarn add -D lint-staged@^16.2.7`.

### C12: `package.json` has no `lint-staged` section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json)
- **v1.0.0 review:** [C18](review-spaceage-visibox-v1.0.0-20261030-192328.md#c18-packagejson-has-no-lint-staged-section), not fixed

**What goes wrong:** Even with the hook and packages in place, lint-staged has no rules, so the pre-commit hook would format and lint nothing.

**Why it happens:** The template's `lint-staged` section was not added to `package.json`.

**Evidence:**

```text
validate-template: package.json: Missing 'lint-staged' section (present in template)
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json); there is no `lint-staged` key.

**Fix:** add the template's section.

```json
"lint-staged": {
	"*.{css,json,md,scss}": [
		"prettier --write"
	],
	"*.{ts,tsx,js,jsx}": [
		"yarn lint:raw --fix"
	]
}
```

## 🟠 High

### H1: Each output level, mute or fullscreen change from Visibox re-runs every feedback and rewrites all 29 variables three times

- **Source:** 🔎 QA reviewer, compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:80-89`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/main.ts#L80-L89), [`src/api.ts:49`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/api.ts#L49)
- **v1.0.0 review:** [H4](review-spaceage-visibox-v1.0.0-20261030-192328.md#h4-every-visibox-state-update-refreshes-all-feedbacks-and-variables-two-or-three-times) (raised to High by the human reviewer), not fixed: `src/` is unchanged in v1.0.1

**What goes wrong:** An operator turns a rotary bound to Output Level "Up by step" (5%), or presses the Mute or Fullscreen preset. Each time Visibox reports the change, the module makes Companion re-run every feedback on every button that uses this connection (Clip Playing, Clip Paused, Specific Clip Active, Song Active, Output Muted, Output Fullscreen) three times, rewrites all 29 variables three times, and downloads the whole active project from Visibox again. The first app-state fetch after connecting does the full refresh twice. Song and clip changes refresh once, but still re-run every feedback when only some of them could have changed. On a page with the 10 Clip, 5 Song and Now Playing presets, Companion does several times the work it needs to during a show.

**Why it happens:** The module asks the Visibox client library to manage state for it (`manageState: true`) and hands the same refresh routine to two callbacks: the library's "state changed" callback and its "app state changed" event. For one app-state update, the library calls the first callback, then fires the event, then re-downloads the project over HTTP and calls the first callback again: three full refreshes. The initial app-state fetch also fires both, so the code comment that it "only emits the event" does not match the library, and the second listener adds nothing. Each refresh calls `checkFeedbacks()` with no feedback IDs, which tells Companion to re-run all of the module's feedbacks. Companion's module library merges overlapping checks of the same feedback a little, but each update still runs every feedback about three times, sends three full variable updates and re-downloads the project (see [A6](#-assumptions-to-confirm)).

**Evidence:**

```ts
// src/main.ts:80-89
    // Wire state changes to feedback/variable refresh. onStateChanged covers
    // project/playstate and live appState pushes; the initial appState fetch
    // only emits the event.
    const refresh = () => {
      this.checkFeedbacks()
      RefreshVariables(this)
    }
    this.apiClient.onStateChanged = refresh
    this.apiClient.on('app-state-changed', refresh)
    refresh()

// src/api.ts:49
      manageState: true,
```

```js
// node_modules/@visibox/api-client/dist/index.js:1 (v1.1.0, handleMessage excerpt)
if(n){this.onStateChanged?.(this.state);let o=this.eventHandlers.get("app-state-changed");o&&o.forEach(a=>a(this.state.appState))}}if(this.manageState){if(e.type==="event"&&e.event==="state-update"){this.log("debug","State update received, refreshing..."),this.refreshState();return}

// node_modules/@visibox/api-client/dist/index.js:1 (refreshState excerpt)
async refreshState(){try{let e=await this.http.getActiveProject(); ... this.onStateChanged?.(this.state)}

// node_modules/@visibox/api-client/dist/index.js:1 (fetchInitialAppState / completeConnection excerpts)
this.state.appState=t.appState;let s=this.eventHandlers.get("app-state-changed");s&&s.forEach(i=>i(this.state.appState)),this.manageState&&this.onStateChanged?.(this.state)
this.manageState?this.refreshState().then(()=>this.fetchInitialAppState()):this.fetchInitialAppState()
```

```ts
// node_modules/@visibox/api-client/dist/index.d.ts:1249
     * Emits 'app-state-changed' (and onStateChanged for managed clients).
```

```js
// node_modules/@companion-module/base/dist/internal/feedback.js:247-257 (base 1.14.1)
    checkFeedbacks(feedbackTypes) {
        const types = new Set(feedbackTypes);
        for (const [id, feedback] of this.#feedbackInstances.entries()) {
            ...
                if (types.size === 0 || types.has(feedback.feedbackId)) {
                    this.#triggerCheckFeedback(id);

// node_modules/@companion-module/base/dist/internal/feedback.js:123-128
    #triggerCheckFeedback(id) {
        const existingRecheck = this.#feedbacksBeingChecked.get(id);
        if (existingRecheck) {
            // Already being checked
            existingRecheck.needsRecheck = true;
            return;
```

```text
git diff --stat v1.0.0..v1.0.1 (src/ untouched)
 .github/..., .gitignore, .yarnrc.yml, companion/manifest.json, package-lock.json, package.json, yarn.lock
```

**Confirm by:** open [`src/main.ts:87-88`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/main.ts#L87-L88): the same `refresh`, which calls `checkFeedbacks()` with no IDs, is set as `onStateChanged` and also added as an `app-state-changed` listener. Then search `node_modules/@visibox/api-client/dist/index.js` for `if(n){this.onStateChanged?.(this.state);let o=this.eventHandlers.get("app-state-changed")` and the `this.refreshState();return` that follows it.

**Fix:** handle each update once, and re-check only the feedbacks and variables it can affect. Delete the `app-state-changed` listener and correct the comment: with `manageState` on, `onStateChanged` already covers every case. In the handler, keep the previous `appState`, `project` and `playstate` references, compare them, and re-run only the affected feedbacks. Pass only the variables whose values changed to `setVariableValues`.

```ts
// remove: this.apiClient.on('app-state-changed', refresh)
if (appChanged) this.checkFeedbacks('output_muted', 'output_fullscreen')
if (playChanged || projectChanged)
  this.checkFeedbacks('clip_playing', 'clip_paused', 'specific_clip_active', 'song_active')
```

### H2: The module bundles itself with esbuild instead of the template's build, which Companion's tooling already does

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-9`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L7-L9), [`package.json:29-30`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L29-L30)
- **v1.0.0 review:** [H2](review-spaceage-visibox-v1.0.0-20261030-192328.md#h2-the-module-bundles-itself-with-esbuild-which-companions-build-tooling-already-does), not fixed: v1.0.1 only switched `npm run` to `yarn` in these scripts

**What goes wrong:** Users see no direct effect: the packaged module loads and works. The problem is maintainability. `yarn package` first bundles `src/main.ts` with esbuild into `dist/main.js`, using its own list of packages to leave out, and then Companion's packaging tool (`companion-module-build`) bundles that output again with webpack. Other Companion maintainers expect the template's `tsc` build, and won't expect a second bundler with its own exclusions list when they troubleshoot the module or take it over.

**Why it happens:** The `build` script runs `tsc --noEmit` only to type-check, and esbuild produces `dist/main.js`. The template compiles with `tsc -p tsconfig.build.json` (its `build:main` script) and leaves all bundling to `companion-module-build`. The module's `tsconfig.build.json` matches the template's, and its imports already use `.js` suffixes, so the plain `tsc` output would run. The missing `build:main` script is the validator's view of the same problem ([C8](#c8-packagejson-has-no-buildmain-script)); one change fixes both.

**Evidence:**

```json
// package.json:4-11
  "main": "dist/main.js",
  "type": "module",
  "scripts": {
    "build": "rimraf dist && tsc -p tsconfig.build.json --noEmit && esbuild src/main.ts --bundle --platform=node --target=node22 --format=esm --main-fields=module,main --external:@companion-module/base --external:ws --outfile=dist/main.js",
    "dev": "yarn build",
    "package": "yarn build && companion-module-build",
    "lint": "eslint .",

// package.json:25-30
  "devDependencies": {
    "@companion-module/tools": "^2.6.1",
    "@types/node": "^22.19.3",
    "@types/ws": "^8.18.1",
    "@visibox/api-client": "^1.1.0",
    "esbuild": "^0.28.1",
```

```json
// companion-module-template-ts-v1/package.json:9-12 (API 1.x template, matching manifest apiVersion 1.14.1)
		"package": "run build && companion-module-build",
		"build": "rimraf dist && run build:main",
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
```

```js
// node_modules/@companion-module/tools/webpack.config.cjs:9,25-26 (companion-module-build re-bundles whatever "main" points at)
	if (!pkgJson.main) throw new Error(`Missing main in package.json`)
		entry: {
			main: './' + pkgJson.main, // path.join(frameworkDir, 'dist/entrypoint.js'),
```

```text
Build artefacts in the clone after yarn package: dist/main.js 62170 bytes (esbuild), pkg/main.js 180313 bytes (webpack re-bundle)
```

**Confirm by:** open [`package.json:7-9`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L7-L9) and compare it with the template's `package.json` scripts: `build` runs esbuild with its own `--external` list and `tsc --noEmit`, there is no `build:main`, and `companion-module-build` (webpack entry = `main`) then bundles `dist/main.js` a second time.

**Fix:** switch to the template's build and let `companion-module-build` do all the bundling.

```json
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json",
"package": "run build && companion-module-build"
```

- Remove the `esbuild` devDependency.
- List `@visibox/api-client` under `dependencies`, since the compiled code imports it at runtime ([`src/api.ts:10-14`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/api.ts#L10-L14), [`src/feedbacks.ts:17`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/feedbacks.ts#L17)).
- Run `yarn package` and check that the module still loads in Companion.

## 🟡 Medium

### M1: Trigger Clip with a Song Offset past the first or last song plays the clip in the current song

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:87-108`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L87-L108), [`src/actions.ts:136-151`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L136-L151), [`src/actions.ts:195`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L195)
- **v1.0.0 review:** [M1](review-spaceage-visibox-v1.0.0-20261030-192328.md#m1-trigger-clip-with-a-song-offset-past-the-first-or-last-song-plays-the-clip-in-the-current-song), not fixed

**What goes wrong:** A user builds a button with **Trigger Clip**, Clip Index 2 and Song Offset +1 ("play clip 3 of the next song"). While the last song of the project is active, or before the project has loaded after connecting, pressing the button plays clip 3 of the **current** song on the output, when nothing should have happened. Song Offset -1 on the first song does the same, and so does **Release Clip** when it has no matching press and works the song out again. Nothing is logged for the press.

**Why it happens:** The helper that works out which song to address (`resolveClipParams`) starts with just the clip index and adds a song ID only when the offset lands on a song that exists and the project is known. Otherwise it returns the clip index alone, which is the same command the module sends for Song Offset 0, and HELP.md documents Song Offset 0 as the active song (see [A2](#-assumptions-to-confirm)). Trigger Clip sends it without checking.

**Fix:** when Song Offset is not 0 and there is no song at that offset, send nothing and log a warning.

```ts
// in resolveClipParams: return null when songOffset !== 0 and no target song was found
const params = resolveClipParams(clipIndex, songOffset)
if (!params) {
	self.log('warn', `Trigger Clip: no song at offset ${songOffset}, nothing sent`)
	return
}
```

### M2: The Node CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)
- **v1.0.0 review:** [M6](review-spaceage-visibox-v1.0.0-20261030-192328.md#m6-the-node-ci-workflow-is-missing), not fixed

**What goes wrong:** Pushes and pull requests are not built or linted on GitHub, so a broken build or lint goes unnoticed until release review.

**Why it happens:** v1.0.1 added the template's issue forms and its `companion-module-checks.yaml` workflow (which now matches the template), but not `node.yaml`.

**Fix:** copy `.github/workflows/node.yaml` from the template.

## 🟢 Low

### L1: A blank Visibox Host shows Disconnected with no hint that the setting is wrong

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:44`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/api.ts#L44), [`src/main.ts:59-93`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/main.ts#L59-L93), [`src/config.ts:23-31`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/config.ts#L23-L31)
- **v1.0.0 review:** [L1](review-spaceage-visibox-v1.0.0-20261030-192328.md#l1-an-empty-visibox-host-shows-disconnected-with-no-hint-that-the-setting-is-wrong), not fixed

**What goes wrong:** A user clears the **Visibox Host** field in the connection settings (for example while swapping 127.0.0.1 for 192.168.1.50) and clicks Save. The connection never shows Bad Configuration. It flips between Connecting and Disconnected every 5 seconds, which looks exactly like Visibox simply not running. The only trace is a debug-level log line, "Failed to connect to Visibox: Error: Visibox API not responding", so nothing points the user at the host field.

**Why it happens:** The module falls back to 127.0.0.1 only when the host is missing entirely, not when it is an empty string (see [A1](#-assumptions-to-confirm)). The Visibox client library then builds the address `http://:17736/health`, which Node rejects as an invalid URL; the library treats that as a plain disconnect and retries every 5 seconds. Neither startup nor a settings change checks the host first, and the host field has no `regex`, so the settings form does not flag it either.

**Fix:** before creating the client, check for a blank host; if it is blank, stop any existing client, show Bad Configuration and don't connect.

```ts
if (!this.config.host?.trim()) {
	this.apiClient?.destroy()
	this.updateStatus(InstanceStatus.BadConfig, 'Visibox Host is required')
	return
}
```

Feedbacks and actions read `self.apiClient`, so keep a destroyed or placeholder client assigned (or guard those reads) when you return early. You can also add `regex: Regex.HOSTNAME` (or `Regex.IP`) to the host field in `src/config.ts`, so the settings form marks a blank or invalid host in red.

### L2: Set Control "Adjust by amount" counts turns that never reached Visibox, so the next turn jumps

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:462-481`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L462-L481)
- **v1.0.0 review:** [L2](review-spaceage-visibox-v1.0.0-20261030-192328.md#l2-set-control-adjust-by-amount-counts-presses-that-never-reached-visibox-so-the-next-press-jumps), not fixed

**What goes wrong:** A user drives Real-Time Control A from a rotary with **Set Control**, Mode "Adjust by amount (for rotaries)", Value +10. Turns made while Visibox is unreachable still move the module's remembered position: five failed turns take it from 50% to 100%. Once Visibox is reachable again, the next turn sends 100% (or the clamped maximum) instead of 60%, and the targets jump.

**Why it happens:** The action stores the new position before it sends it, and does not undo the stored value when the send fails. Over the WebSocket a send always reports success (a plan refusal arrives later as a separate response), so this applies to sends that fail outright and to refusals on the HTTP fallback.

**Fix:** store the new position only after a successful send.

```ts
const result = await self.apiClient.setControl(address, next)
if (result.success) {
	lastControlValues.set(address, next)
} else {
	self.log('warn', `Set Control ${address}: ${result.error ?? 'send failed'}`)
}
```

### L3: Preset button text keeps the old connection name after the connection is renamed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:23`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/presets.ts#L23), [`src/main.ts:99-120`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/main.ts#L99-L120)
- **v1.0.0 review:** [L3](review-spaceage-visibox-v1.0.0-20261030-192328.md#l3-preset-button-text-keeps-the-old-connection-name-after-the-connection-is-renamed), not fixed

**What goes wrong:** A user adds the Visibox connection (label `visibox`) and later renames it to `stage`. Dragging the **Clip 1**, **Song 1** or **Now Playing** preset still puts `$(visibox:clip_1_name)` / `$(visibox:active_song_name)` on the button. Those variables no longer exist, so the button shows no clip or song name until the connection is restarted (see [A3](#-assumptions-to-confirm)).

**Why it happens:** The presets write the connection's label into their button text when they are built, and they are only built at startup. A rename updates the label and then calls the module's settings-changed handler (`configUpdated()`), which compares only the host, ports, pairing code and token, returns early when only the label changed, and never rebuilds the presets.

**Fix:** remember the label the presets were built with (in a field set at the end of startup), and in `configUpdated()` call `UpdatePresets(this)` when `this.label` differs from it, before the early return.

### L4: The starter page needs Companion 5.0, but the module also runs on Companion 4.2 and the help text doesn't say so

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`starter/visibox-starter.companionconfig:1-11`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/starter/visibox-starter.companionconfig#L1-L11), [`companion/HELP.md:33`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/companion/HELP.md#L33)
- **v1.0.0 review:** [L4](review-spaceage-visibox-v1.0.0-20261030-192328.md#l4-the-starter-page-needs-companion-5-but-the-module-also-runs-on-companion-42), not fixed

**What goes wrong:** The help text tells users to import `visibox-starter.companionconfig` in **Import / Export**. The file was exported from Companion 5.0.5 (format version 12, with layered buttons), but a module on API 1.14 also runs on Companion 4.2. A Companion 4.2 user who follows the help text will probably have the import refused or get no usable buttons, with no hint why (see [A4](#-assumptions-to-confirm)).

**Why it happens:** The starter page was exported from a newer Companion than the oldest one the module supports, and neither HELP.md nor README.md says which Companion version it needs.

**Fix:** re-export the starter page from Companion 4.2, or add a line to the Starter Page section of `companion/HELP.md` (and to README.md) saying it needs Companion 5.0 or later, and point 4.x users to the presets.

### L5: README says the module works on Companion 4.0, but API 1.14 needs Companion 4.2 or later

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:19`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/README.md#L19)
- **v1.0.0 review:** not raised (README.md is unchanged since v1.0.0)

**What goes wrong:** A user on Companion 4.0 or 4.1 reads "Companion 4.0 or higher" in the README and expects to add a SpaceAge Visibox connection. The module is built on `@companion-module/base` 1.14.1 (manifest `apiVersion` 1.14.1), which needs Companion 4.2 or later, so on 4.0 or 4.1 the module won't be available or won't run (see [A5](#-assumptions-to-confirm)).

**Why it happens:** The prerequisites line was not updated to the minimum Companion version for base 1.14.

**Fix:** change README.md line 19 to "**Companion** 4.2 or higher". If the starter page stays a Companion 5 export ([L4](#l4-the-starter-page-needs-companion-50-but-the-module-also-runs-on-companion-42-and-the-help-text-doesnt-say-so)), say so there too.

## 💡 Nice to Have

### N1: Song ID, Control and Target ID fields don't accept variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:234-241`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L234-L241), [`src/actions.ts:423-430`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L423-L430), [`src/actions.ts:490-497`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L490-L497)
- **v1.0.0 review:** [N1](review-spaceage-visibox-v1.0.0-20261030-192328.md#n1-song-id-control-and-target-id-fields-do-not-accept-variables), not fixed

**What goes wrong:** A user can't put a variable such as `$(internal:custom_song)` into **Song Select → Song ID**, **Set Control (Real-Time Control) → Control** or **Set Target Param (Real-Time Control) → Target ID**. The text is sent to Visibox exactly as typed, so these actions only work with fixed values.

**Why it happens:** None of these text fields declares `useVariables`. Companion only replaces variables in a text field before the action runs when the field declares it.

**Fix:** add `useVariables: true` to the `songId`, `control` and `targetId` options. Companion then resolves the variables before the callback runs, so the callbacks need no other change.

### N2: Pressing a Clip button while Visibox is closed logs "a gate clip may still be playing" although nothing played

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:141-151`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L141-L151), [`src/actions.ts:203-217`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/src/actions.ts#L203-L217)
- **v1.0.0 review:** not raised (`src/` is unchanged since v1.0.0)

**What goes wrong:** With Visibox closed or not yet paired, an operator presses and releases the **Clip 3** preset. The press does nothing, but on release the connection log shows the error "Failed to release clip [2] — a gate clip may still be playing". An operator reading the log may think something is stuck on stage and hit Panic for no reason.

**Why it happens:** Trigger Clip remembers the press for the matching release without checking whether the press was actually sent. When the release then fails to send too, Release Clip logs at error level on the assumption that the press succeeded.

**Fix:** in Trigger Clip, remember the press only when `await self.apiClient.sendAction(...)` returns true. In Release Clip, log the gate-clip error only when there was a remembered press; otherwise log at debug or warn level.

## 🔮 Next Release

### NR1: Consider moving to Companion module API 2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:22`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/a99e086cf5e83503fc9d5ba51bf7a0bf711fb519/package.json#L22)

**What goes wrong:** Nothing breaks today: API 1.14 is the last v1 release and is supported. Staying on v1 means users can't use expressions in the module's options, and the module misses Companion 5's newer preset and action features (API 2.1). The starter page shows the maintainer already uses Companion 5.

**Why it happens:** The module depends on `@companion-module/base` `~1.14.1`. API 2.0 (Companion 4.3+) and 2.1 (Companion 5.0+) are the current lines.

**Fix:** in a later release, migrate to `@companion-module/base` 2.x following the Companion v1-to-v2 migration guide and the API 2.0 / 2.1 change notes, then match the corresponding `companion-module-template-ts` template.

## 📝 Additional Notes

- **Fixed since the v1.0.0 review:** C1–C3 (the module now uses yarn: `yarn.lock` is committed, `package-lock.json` is removed and ignored), C8 (`.yarnrc.yml` added), C10 (`packageManager` set), C17 (`prettier` devDependency added), H1 (`yarn lint` now passes) and M2–M5 (issue forms and the Companion module checks workflow added). `yarn install --immutable`, `yarn package` and `yarn lint` all pass.
- **Not carried forward:** v1.0.0 H3 (the Visibox client library is a devDependency). It is unchanged, but on re-check nothing goes wrong for users: the library is the module author's own MIT package, its notice is already in the packaged LICENSE, and the packaged module loads it from the bundle. [H2](#h2-the-module-bundles-itself-with-esbuild-instead-of-the-templates-build-which-companions-tooling-already-does)'s fix still lists it under `dependencies` as part of the template build.
- **New in this review:** [L5](#l5-readme-says-the-module-works-on-companion-40-but-api-114-needs-companion-42-or-later), [N2](#n2-pressing-a-clip-button-while-visibox-is-closed-logs-a-gate-clip-may-still-be-playing-although-nothing-played) and [NR1](#nr1-consider-moving-to-companion-module-api-2x) are in code that has not changed since v1.0.0. The v1.0.0..v1.0.1 changes themselves introduced no new issues.
- `tsconfig.build.json`: `exclude` is `["node_modules/**", "src/**/*.test.ts"]` instead of the template's `["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"]`. The build and lint pass, so no change is required.
