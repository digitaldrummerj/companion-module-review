# Review: companion-module-spaceage-visibox v1.0.0

| | |
| --- | --- |
| **Module** | [companion-module-spaceage-visibox](https://github.com/bitfocus/companion-module-spaceage-visibox) |
| **Scope** | `tag` |
| **Version** | `v1.0.0` (commit [`5554612`](https://github.com/bitfocus/companion-module-spaceage-visibox/commit/5554612e0b12ecb484081430ee413d6608fe23bb)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, package-lock.json) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Diff** | None: this is the first release, so there is no previous tag and the whole module was reviewed |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When Visibox receives a play or release clip command with only a clip index and no song ID, it applies it to the active song | The module's own Song Offset tooltip ("0 = active") and the fact that Trigger Clip sends the clip index alone for offset 0; Visibox's own behaviour was not checked | [M1](#m1-trigger-clip-with-a-song-offset-past-the-first-or-last-song-plays-the-clip-in-the-current-song) |
| A2 | When a connection is renamed, Companion does not restart the module and does not rewrite `$(label:...)` references in presets the module already sent; it only calls `configUpdated()` | The `InstanceBase.label` JSDoc in `@companion-module/base` ("can be changed just before `configUpdated` is called"); Companion's host-side preset handling was not checked | [L3](#l3-preset-button-text-keeps-the-old-connection-name-after-the-connection-is-renamed) |
| A3 | Companion 4.2 cannot import a page export with `"version": 12` that contains `button-layered` controls (a Companion 5.0 format) | The export header in `starter/visibox-starter.companionconfig` and the API 1.14 → Companion 4.2 mapping; not tested in Companion 4.2 | [L4](#l4-the-starter-page-needs-companion-5-but-the-module-also-runs-on-companion-42) |

## 📋 Issues

### Blocking

- [ ] [C1: The repository has no `yarn.lock`, so the module's dependency versions are not pinned for yarn](#c1-the-repository-has-no-yarnlock-so-the-modules-dependency-versions-are-not-pinned-for-yarn)
- [ ] [C2: The module is set up for npm (`package-lock.json`) instead of yarn](#c2-the-module-is-set-up-for-npm-package-lockjson-instead-of-yarn)
- [ ] [C3: `package-lock.json` is committed although the template's `.gitignore` excludes it](#c3-package-lockjson-is-committed-although-the-templates-gitignore-excludes-it)
- [ ] [C4: `.gitattributes` is missing, so line endings are not normalised](#c4-gitattributes-is-missing-so-line-endings-are-not-normalised)
- [ ] [C5: `.gitignore` is missing template entries](#c5-gitignore-is-missing-template-entries)
- [ ] [C6: `.husky/pre-commit` is missing, so commits are not linted or formatted](#c6-huskypre-commit-is-missing-so-commits-are-not-linted-or-formatted)
- [ ] [C7: `.prettierignore` is missing](#c7-prettierignore-is-missing)
- [ ] [C8: `.yarnrc.yml` is missing, so yarn's install safety settings are not applied](#c8-yarnrcyml-is-missing-so-yarns-install-safety-settings-are-not-applied)
- [ ] [C9: `package.json` has no `prettier` field, so formatting does not use the Companion style](#c9-packagejson-has-no-prettier-field-so-formatting-does-not-use-the-companion-style)
- [ ] [C10: `package.json` has no `packageManager` field, so the yarn version is not pinned](#c10-packagejson-has-no-packagemanager-field-so-the-yarn-version-is-not-pinned)
- [ ] [C11: `package.json` has no `postinstall` script, so the git hooks are never installed](#c11-packagejson-has-no-postinstall-script-so-the-git-hooks-are-never-installed)
- [ ] [C12: `package.json` has no `format` script](#c12-packagejson-has-no-format-script)
- [ ] [C13: `package.json` has no `build:main` script](#c13-packagejson-has-no-buildmain-script)
- [ ] [C14: `package.json` has no `lint:raw` script](#c14-packagejson-has-no-lintraw-script)
- [ ] [C15: `husky` is not a devDependency](#c15-husky-is-not-a-devdependency)
- [ ] [C16: `lint-staged` is not a devDependency](#c16-lint-staged-is-not-a-devdependency)
- [ ] [C17: `prettier` is not a devDependency](#c17-prettier-is-not-a-devdependency)
- [ ] [C18: `package.json` has no `lint-staged` section](#c18-packagejson-has-no-lint-staged-section)
- [ ] [H1: `yarn lint` crashes before checking any code, because `prettier` is not installed](#h1-yarn-lint-crashes-before-checking-any-code-because-prettier-is-not-installed)
- [ ] [H2: The module bundles itself with esbuild, which Companion's build tooling already does](#h2-the-module-bundles-itself-with-esbuild-which-companions-build-tooling-already-does)
- [ ] [H3: The Visibox client library is a devDependency, although the module loads it at runtime](#h3-the-visibox-client-library-is-a-devdependency-although-the-module-loads-it-at-runtime)

### Non-blocking

- [ ] [M1: Trigger Clip with a Song Offset past the first or last song plays the clip in the current song](#m1-trigger-clip-with-a-song-offset-past-the-first-or-last-song-plays-the-clip-in-the-current-song)
- [ ] [M2: The bug report issue form is missing](#m2-the-bug-report-issue-form-is-missing)
- [ ] [M3: The issue template chooser config is missing](#m3-the-issue-template-chooser-config-is-missing)
- [ ] [M4: The feature request issue form is missing](#m4-the-feature-request-issue-form-is-missing)
- [ ] [M5: The Companion module checks workflow is missing](#m5-the-companion-module-checks-workflow-is-missing)
- [ ] [M6: The Node CI workflow is missing](#m6-the-node-ci-workflow-is-missing)
- [ ] [L1: An empty Visibox Host shows Disconnected with no hint that the setting is wrong](#l1-an-empty-visibox-host-shows-disconnected-with-no-hint-that-the-setting-is-wrong)
- [ ] [L2: Set Control "Adjust by amount" counts presses that never reached Visibox, so the next press jumps](#l2-set-control-adjust-by-amount-counts-presses-that-never-reached-visibox-so-the-next-press-jumps)
- [ ] [L3: Preset button text keeps the old connection name after the connection is renamed](#l3-preset-button-text-keeps-the-old-connection-name-after-the-connection-is-renamed)
- [ ] [L4: The starter page needs Companion 5, but the module also runs on Companion 4.2](#l4-the-starter-page-needs-companion-5-but-the-module-also-runs-on-companion-42)
- [ ] [L5: Every Visibox state update refreshes all feedbacks and variables two or three times](#l5-every-visibox-state-update-refreshes-all-feedbacks-and-variables-two-or-three-times)
- [ ] [N1: Song ID, Control and Target ID fields do not accept variables](#n1-song-id-control-and-target-id-fields-do-not-accept-variables)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The repository has no `yarn.lock`, so the module's dependency versions are not pinned for yarn

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `yarn.lock` (missing)

**What goes wrong:** Companion modules are installed and built with yarn. Without a committed `yarn.lock`, every install resolves the dependency ranges afresh, so the module that Bitfocus builds can contain different package versions from the one the maintainer tested.

**Why it happens:** The module was set up with npm. It commits npm's lockfile (see [C2](#c2-the-module-is-set-up-for-npm-package-lockjson-instead-of-yarn)) and no yarn lockfile.

**Evidence:**

```text
expected: yarn.lock (tracked by the template)
found:    no yarn.lock in the repository at 5554612
```

**Confirm by:** `git ls-files yarn.lock` in the module repo prints nothing.

**Fix:** install with yarn 4 (`corepack enable`, then `yarn install`) after adding the `packageManager` field from [C10](#c10-packagejson-has-no-packagemanager-field-so-the-yarn-version-is-not-pinned), and commit the generated `yarn.lock`.

### C2: The module is set up for npm (`package-lock.json`) instead of yarn

- **Source:** 🤖 validate-template (NPM-LOCK)
- **Classification:** 🆕 NEW
- **File:** [`package-lock.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package-lock.json)

**What goes wrong:** Companion modules must use yarn. A committed npm lockfile is an automatic rejection, because the module's install and build would not match the yarn-based tooling every other module uses.

**Why it happens:** The repository was created with `npm install`, which writes `package-lock.json`. The `dev` script also calls `npm run build`.

**Evidence:**

```text
expected: no package-lock.json; yarn.lock instead
found:    package-lock.json committed
```

**Confirm by:** open [`package-lock.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package-lock.json) in the repo.

**Fix:** delete `package-lock.json`, install with yarn and commit `yarn.lock` (see [C1](#c1-the-repository-has-no-yarnlock-so-the-modules-dependency-versions-are-not-pinned-for-yarn)).

```bash
git rm package-lock.json
corepack enable
yarn install
git add yarn.lock
```

### C3: `package-lock.json` is committed although the template's `.gitignore` excludes it

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW
- **File:** [`package-lock.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package-lock.json)

**What goes wrong:** The template ignores `package-lock.json` so that an accidental `npm install` never ends up in the repository. This module commits it.

**Why it happens:** The module's `.gitignore` does not have the template's `package-lock.json` entry (see [C5](#c5-gitignore-is-missing-template-entries)), so npm's lockfile was committed with the rest of the code.

**Evidence:**

```text
template .gitignore pattern: package-lock.json
found: package-lock.json tracked in the repository
```

**Confirm by:** `git ls-files package-lock.json` in the module repo prints the file.

**Fix:** remove the file from the repository (`git rm package-lock.json`) and add the template's `.gitignore` entries from [C5](#c5-gitignore-is-missing-template-entries).

### C4: `.gitattributes` is missing, so line endings are not normalised

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without the template's `.gitattributes`, a contributor on Windows can commit files with CRLF line endings, which then show up as whole-file diffs and lint failures.

**Why it happens:** The template's `.gitattributes` forces LF line endings for every text file. The module has no `.gitattributes`.

**Evidence:**

```text
expected: .gitattributes (tracked by the template)
found:    missing
```

**Confirm by:** `git ls-files .gitattributes` in the module repo prints nothing.

**Fix:** add `.gitattributes` with the template's content.

```text
* text=auto eol=lf
```

### C5: `.gitignore` is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-6`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/.gitignore#L1-L6)

**What goes wrong:** Files the template keeps out of git can be committed by accident: npm's lockfile (already committed, see [C3](#c3-package-lockjson-is-committed-although-the-templates-gitignore-excludes-it)), `DEBUG-*` log files and the `.vscode` folder.

**Why it happens:** The module wrote its own `.gitignore`. It has `dist/`, `*.tgz`, `pkg/` and `.yarn/` in a different form from the template, and has no `package-lock.json`, `DEBUG-*` or `/.vscode` entry at all.

**Evidence:**

```text
missing template entries: package-lock.json, /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode
found: node_modules/, dist/, .test-build/, .yarn/, *.tgz, pkg/
```

**Confirm by:** open [`.gitignore:1-6`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/.gitignore#L1-L6).

**Fix:** use the template's `.gitignore` and keep the module's own `.test-build/` entry.

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

### C6: `.husky/pre-commit` is missing, so commits are not linted or formatted

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** The template runs lint-staged before every commit, which formats changed files and fixes lint problems. Without the hook, unformatted or failing code can be committed.

**Why it happens:** The module has no `.husky/pre-commit` file, and also lacks the `husky` devDependency and the `postinstall` script that installs the hook ([C11](#c11-packagejson-has-no-postinstall-script-so-the-git-hooks-are-never-installed), [C15](#c15-husky-is-not-a-devdependency)).

**Evidence:**

```text
expected: .husky/pre-commit (tracked by the template)
found:    missing
```

**Confirm by:** `git ls-files .husky` in the module repo prints nothing.

**Fix:** add `.husky/pre-commit` with the template's content.

```text
lint-staged
```

### C7: `.prettierignore` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore` (missing)

**What goes wrong:** Running the template's `format` script would reformat `package.json` and `LICENSE.md`, which the template deliberately leaves alone.

**Why it happens:** The module has no `.prettierignore`.

**Evidence:**

```text
expected: .prettierignore (tracked by the template)
found:    missing
```

**Confirm by:** `git ls-files .prettierignore` in the module repo prints nothing.

**Fix:** add `.prettierignore` with the template's content.

```text
package.json
/LICENSE.md
```

### C8: `.yarnrc.yml` is missing, so yarn's install safety settings are not applied

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** The template's `.yarnrc.yml` makes yarn install into a plain `node_modules` folder, blocks package install scripts, and refuses packages published less than three days ago. Without it, yarn 4 uses its Plug'n'Play layout by default and runs install scripts.

**Why it happens:** The module has no `.yarnrc.yml`.

**Evidence:**

```text
expected: .yarnrc.yml (tracked by the template)
found:    missing
```

**Confirm by:** `git ls-files .yarnrc.yml` in the module repo prints nothing.

**Fix:** add `.yarnrc.yml` with the template's content.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C9: `package.json` has no `prettier` field, so formatting does not use the Companion style

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json)

**What goes wrong:** The template points prettier at the shared Companion style. Without that field, formatting falls back to the module's own `.prettierrc`, and the lint step cannot load prettier at all (see [H1](#h1-yarn-lint-crashes-before-checking-any-code-because-prettier-is-not-installed)).

**Why it happens:** The `prettier` field from the template's `package.json` was not added.

**Evidence:**

```text
expected: "prettier": "@companion-module/tools/.prettierrc.json"
found:    no "prettier" field
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json).

**Fix:** add the template's field to `package.json`.

```json
"prettier": "@companion-module/tools/.prettierrc.json"
```

### C10: `package.json` has no `packageManager` field, so the yarn version is not pinned

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json)

**What goes wrong:** Corepack uses the `packageManager` field to pick the yarn version. Without it, each machine uses whatever yarn (or npm) it has installed, so installs and lockfiles differ between the maintainer and the Bitfocus build.

**Why it happens:** The field from the template's `package.json` was not added.

**Evidence:**

```text
expected: "packageManager": "yarn@4.12.0"
found:    no "packageManager" field
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json).

**Fix:** add the template's field to `package.json`.

```json
"packageManager": "yarn@4.12.0"
```

### C11: `package.json` has no `postinstall` script, so the git hooks are never installed

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12)

**What goes wrong:** The pre-commit hook from [C6](#c6-huskypre-commit-is-missing-so-commits-are-not-linted-or-formatted) only runs once husky has installed it, which the template does from `postinstall` after every `yarn install`.

**Why it happens:** The module's `scripts` have no `postinstall` entry.

**Evidence:**

```text
expected script: "postinstall": "husky"
found:           missing
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12).

**Fix:** add the template's script.

```json
"postinstall": "husky"
```

### C12: `package.json` has no `format` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12)

**What goes wrong:** Contributors have no `yarn format` command to apply the shared Companion formatting.

**Why it happens:** The module's `scripts` have no `format` entry.

**Evidence:**

```text
expected script: "format": "prettier -w ."
found:           missing
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12).

**Fix:** add the template's script.

```json
"format": "prettier -w ."
```

### C13: `package.json` has no `build:main` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12)

**What goes wrong:** The template splits the build into `build` (clean, then run `build:main`) and `build:main` (compile). This module puts the whole esbuild command into `build`, so the script layout other Companion maintainers expect is not there.

**Why it happens:** The module's `build` script runs `rimraf`, `tsc --noEmit` and `esbuild` in one line, and there is no `build:main`.

**Evidence:**

```text
expected script: "build:main": "tsc -p tsconfig.build.json"
found:           missing ("build" runs rimraf, tsc --noEmit and esbuild in one command)
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12).

**Fix:** use the template's `build` / `build:main` pair.

```json
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json"
```

### C14: `package.json` has no `lint:raw` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12)

**What goes wrong:** The template's lint-staged section runs `yarn lint:raw --fix` on changed files. Without `lint:raw`, the pre-commit hook would fail once it is added.

**Why it happens:** The module's `lint` script calls `eslint .` directly, and there is no `lint:raw`.

**Evidence:**

```text
expected script: "lint:raw": "eslint" (and "lint": "run lint:raw .")
found:           missing ("lint": "eslint .")
```

**Confirm by:** open [`package.json:6-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L6-L12).

**Fix:** add the template's script pair.

```json
"lint:raw": "eslint",
"lint": "run lint:raw ."
```

### C15: `husky` is not a devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-35`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L25-L35)

**What goes wrong:** The `postinstall` script from [C11](#c11-packagejson-has-no-postinstall-script-so-the-git-hooks-are-never-installed) runs `husky`, which fails to install the git hooks when the package is not installed.

**Why it happens:** `husky` is missing from `devDependencies`.

**Evidence:**

```text
expected devDependency: "husky": "^9.1.7"
found:                  missing
```

**Confirm by:** open [`package.json:25-35`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L25-L35).

**Fix:** `yarn add -D husky@^9.1.7`.

### C16: `lint-staged` is not a devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-35`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L25-L35)

**What goes wrong:** The pre-commit hook from [C6](#c6-huskypre-commit-is-missing-so-commits-are-not-linted-or-formatted) runs `lint-staged`, which fails when the package is not installed.

**Why it happens:** `lint-staged` is missing from `devDependencies`.

**Evidence:**

```text
expected devDependency: "lint-staged": "^16.2.7"
found:                  missing
```

**Confirm by:** open [`package.json:25-35`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L25-L35).

**Fix:** `yarn add -D lint-staged@^16.2.7`.

### C17: `prettier` is not a devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-35`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L25-L35)

**What goes wrong:** The ESLint setup from `@companion-module/tools` checks formatting through prettier. Without prettier installed, `yarn lint` crashes (see [H1](#h1-yarn-lint-crashes-before-checking-any-code-because-prettier-is-not-installed)), and there is no `yarn format`.

**Why it happens:** `prettier` is missing from `devDependencies`.

**Evidence:**

```text
expected devDependency: "prettier": "^3.7.4"
found:                  missing
```

**Confirm by:** open [`package.json:25-35`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L25-L35).

**Fix:** `yarn add -D prettier@^3.7.4`.

### C18: `package.json` has no `lint-staged` section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json)

**What goes wrong:** Even with the hook and packages in place, lint-staged has no rules, so the pre-commit hook would format and lint nothing.

**Why it happens:** The template's `lint-staged` section was not added to `package.json`.

**Evidence:**

```text
expected: "lint-staged" section (present in template)
found:    missing
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json).

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

### H1: `yarn lint` crashes before checking any code, because `prettier` is not installed

- **Source:** 🤖 validate-template (LINT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-35`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L25-L35)

**What goes wrong:** Running `yarn lint` aborts with a module-not-found error, so no lint check runs on the module at all, and the template's CI lint step would fail.

**Why it happens:** `@companion-module/tools` turns on `eslint-plugin-prettier`, which loads prettier to check formatting. The module does not list `prettier` as a devDependency ([C17](#c17-prettier-is-not-a-devdependency)), so ESLint stops as soon as the plugin loads.

**Evidence:**

```text
$ eslint .
Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'prettier' imported from node_modules/eslint-plugin-prettier/worker.mjs
```

**Confirm by:** `yarn lint` passes after adding the template's `prettier` devDependency ([C17](#c17-prettier-is-not-a-devdependency)) and `prettier` field ([C9](#c9-packagejson-has-no-prettier-field-so-formatting-does-not-use-the-companion-style)).

**Fix:** add prettier as in [C17](#c17-prettier-is-not-a-devdependency) and [C9](#c9-packagejson-has-no-prettier-field-so-formatting-does-not-use-the-companion-style), then run `yarn lint` and fix anything it reports.

### H2: The module bundles itself with esbuild, which Companion's build tooling already does

- **Source:** 👤 reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-9`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L7-L9), [`package.json:27-30`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L27-L30)

**What goes wrong:** The module adds its own bundler on top of Companion's. `yarn package` runs esbuild to bundle `src/main.ts` into `dist/main.js`, then `companion-module-build` bundles it again. Companion's tooling already bundles the module and all of its dependencies when it packages it, so the esbuild step, its `--external` flags and the `esbuild` devDependency are extra build machinery that other Companion maintainers will not expect when they troubleshoot or take over the module.

**Why it happens:** esbuild inlines `@visibox/api-client`, which is listed as a devDependency ([H3](#h3-the-visibox-client-library-is-a-devdependency-although-the-module-loads-it-at-runtime)), into `dist/main.js`. With the template's build, `tsc` compiles the TypeScript and `companion-module-build` (webpack, from `@companion-module/tools`) bundles every runtime dependency, so a normal `dependencies` entry is all the client library needs.

**Evidence:**

```json
"build": "rimraf dist && tsc -p tsconfig.build.json --noEmit && esbuild src/main.ts --bundle --platform=node --target=node22 --format=esm --main-fields=module,main --external:@companion-module/base --external:ws --outfile=dist/main.js",
"package": "npm run build && companion-module-build",
"@visibox/api-client": "^1.1.0",
"esbuild": "^0.28.1",
```

**Confirm by:** open [`package.json:7-9`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L7-L9) and [`package.json:27-30`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L27-L30), and compare with the template's `build` / `build:main` / `package` scripts.

**Fix:** remove esbuild and use the template's build ([C13](#c13-packagejson-has-no-buildmain-script)):

- Replace the `build` script with the template's `build` / `build:main` pair (`tsc -p tsconfig.build.json`), and use `"package": "run build && companion-module-build"`.
- Move `@visibox/api-client` from `devDependencies` to `dependencies` ([H3](#h3-the-visibox-client-library-is-a-devdependency-although-the-module-loads-it-at-runtime)).
- Remove the `esbuild` devDependency.
- Run `yarn package` and check the module still loads in Companion.

### H3: The Visibox client library is a devDependency, although the module loads it at runtime

- **Source:** 👤 reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:21-27`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L21-L27), [`src/api.ts:10-14`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/api.ts#L10-L14), [`src/feedbacks.ts:17`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/feedbacks.ts#L17)

**What goes wrong:** `@visibox/api-client` is the code that talks to Visibox: every action, feedback and variable goes through it. `package.json` lists it under `devDependencies`, which means "only needed to develop or build the module". A packaged module does not install its devDependencies, so anything that installs or packages the module the standard way treats the client library as not shipping:

- Companion's packaging tool (`companion-module-build`) builds the list of third-party packages it ships, and checks their licenses, from `dependencies` only. The Visibox client is left out, so its license is never checked or listed, although its code is inside `main.js`.
- Installing the module for production (`yarn workspaces focus --production`, `npm install --omit=dev`) skips it, so `main.js` built from the plain `tsc` output fails to load with "Cannot find package '@visibox/api-client'".

Today it only works because esbuild copies the library into `dist/main.js` at build time ([H2](#h2-the-module-bundles-itself-with-esbuild-which-companions-build-tooling-already-does)).

**Why it happens:** `src/api.ts` and `src/feedbacks.ts` import the library at runtime (not type-only imports), but it was added as a devDependency.

**Evidence:**

```ts
// src/api.ts:10-14
import {
  VisiboxApiClient as BaseClient,
  type ConnectionStatus,
  type LogFn,
} from '@visibox/api-client'

// src/feedbacks.ts:17
import { summarizePlayback } from '@visibox/api-client'
```

```json
"dependencies": {
  "@companion-module/base": "~1.14.1",
  "ws": "~8.21.1"
},
"devDependencies": {
  "@companion-module/tools": "^2.6.1",
  "@visibox/api-client": "^1.1.0",
```

**Confirm by:** open [`package.json:21-27`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/package.json#L21-L27); `@visibox/api-client` is under `devDependencies` while [`src/api.ts:10-14`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/api.ts#L10-L14) imports `VisiboxApiClient` from it.

**Fix:** move `@visibox/api-client` to `dependencies` (`yarn add @visibox/api-client`, which also removes it from `devDependencies`), and keep it pinned with `~1.1.0` like the other dependencies.

## 🟡 Medium

### M1: Trigger Clip with a Song Offset past the first or last song plays the clip in the current song

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:87-108`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/actions.ts#L87-L108), [`src/actions.ts:195`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/actions.ts#L195)

**What goes wrong:** A user builds a button with **Trigger Clip**, Clip Index 2, Song Offset +1 ("play clip 3 of the next song"). While the last song of the project is active, or before the project has loaded after connecting, pressing the button plays clip 3 of the **current** song, which goes out on the output when nothing should have happened. The same applies to Song Offset -1 on the first song, and to **Release Clip** when it has no matching press to follow.

**Why it happens:** The helper that works out which song to address (`resolveClipParams`) starts with just the clip index and only adds a song ID when the offset lands on a song that exists and the project state is known. Otherwise it returns the clip index alone, and the action sends it with no song. As the option's own tooltip says ("0 = active"), a command with no song means the active song (see [A1](#-assumptions-to-confirm)). Trigger Clip logs nothing when this happens.

**Fix:** when Song Offset is not 0 and the target song cannot be found, send nothing and log a warning instead of falling back to the active song.

```ts
// in resolveClipParams: return null when songOffset !== 0 and no song was found
const params = resolveClipParams(clipIndex, songOffset)
if (!params) {
	self.log('warn', `Trigger Clip: no song at offset ${songOffset}, nothing sent`)
	return
}
```

### M2: The bug report issue form is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/bug_report.yml` (missing)

**What goes wrong:** Users who open a GitHub issue get a blank form instead of the template's bug report form, so reports arrive without the Companion version, module version and steps to reproduce.

**Why it happens:** The module has no `.github` folder.

**Fix:** copy `.github/ISSUE_TEMPLATE/bug_report.yml` from the template.

### M3: The issue template chooser config is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/config.yml` (missing)

**What goes wrong:** GitHub's "New issue" page does not show the template's issue chooser.

**Why it happens:** The module has no `.github` folder.

**Fix:** copy `.github/ISSUE_TEMPLATE/config.yml` from the template.

### M4: The feature request issue form is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/feature_request.yml` (missing)

**What goes wrong:** Feature requests arrive as free text instead of through the template's form.

**Why it happens:** The module has no `.github` folder.

**Fix:** copy `.github/ISSUE_TEMPLATE/feature_request.yml` from the template.

### M5: The Companion module checks workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/companion-module-checks.yaml` (missing)

**What goes wrong:** Pushes and pull requests are not checked by Bitfocus's shared module checks, so problems like the ones in this review are only found at release review.

**Why it happens:** The module has no `.github` folder.

**Fix:** copy `.github/workflows/companion-module-checks.yaml` from the template.

### M6: The Node CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** Pushes and pull requests are not built or linted on GitHub, so a broken build or lint (such as [H1](#h1-yarn-lint-crashes-before-checking-any-code-because-prettier-is-not-installed)) goes unnoticed.

**Why it happens:** The module has no `.github` folder.

**Fix:** copy `.github/workflows/node.yaml` from the template.

## 🟢 Low

### L1: An empty Visibox Host shows Disconnected with no hint that the setting is wrong

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:42-44`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/api.ts#L42-L44)

**What goes wrong:** A user clears the **Visibox Host** field (say, before typing a new IP) and clicks Save. The connection goes to Disconnected and then flips between Connecting and Disconnected every 5 seconds. Nothing says the host is empty: the status never shows Bad Configuration, and the only trace is a debug-level "Failed to connect to Visibox: TypeError: Invalid URL" log line.

**Why it happens:** The module falls back to `127.0.0.1` only when the host is missing entirely (`?? '127.0.0.1'`), not when it is an empty string. An empty host produces the address `http://:17736/health`, which the Visibox client library rejects, reports as a plain disconnect and retries. Neither `init()` nor `configUpdated()` checks the host first.

**Fix:** before starting the client, check that the host is not blank; if it is, show Bad Configuration and do not connect.

```ts
if (!this.config.host?.trim()) {
	this.apiClient?.destroy()
	this.updateStatus(InstanceStatus.BadConfig, 'Visibox Host is required')
	return
}
```

### L2: Set Control "Adjust by amount" counts presses that never reached Visibox, so the next press jumps

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:462-481`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/actions.ts#L462-L481)

**What goes wrong:** A user drives Real-Time Control A from a rotary with **Set Control**, Mode "Adjust by amount (for rotaries)", +10%. Turns that fail to reach Visibox (while it is unreachable, or when the plan does not include Real-Time Control) still move the remembered position: five failed turns take it from 50% to 100%. When sending works again, the next turn sends 100% instead of 60%.

**Why it happens:** The action stores the new position before it sends it, and does not undo the stored value when the send fails.

**Fix:** store the new position only after Visibox accepted it.

```ts
const result = await self.apiClient.setControl(address, next)
if (result.success) {
	lastControlValues.set(address, next)
} else {
	self.log('warn', `Set Control ${address}: ${result.error ?? 'send failed'}`)
}
```

### L3: Preset button text keeps the old connection name after the connection is renamed

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:22-23`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/presets.ts#L22-L23), [`src/main.ts:99-120`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/main.ts#L99-L120)

**What goes wrong:** A user adds the Visibox connection (label `visibox`) and later renames it to `stage`. Dragging the "Clip 1" or "Now Playing" preset still puts `$(visibox:clip_1_name)` / `$(visibox:active_song_name)` on the button. Those variables no longer exist, so the button shows blank or `$NA` instead of the clip or song name, until the connection is disabled and re-enabled or Companion restarts (see [A2](#-assumptions-to-confirm)).

**Why it happens:** The presets write the connection label into their text when they are built, and they are only built in `init()`. A rename calls `configUpdated()`, which never rebuilds the presets and returns early when only the label changed.

**Fix:** in `configUpdated()`, remember the label from before the update and call `UpdatePresets(this)` when it changed, before the early return.

### L4: The starter page needs Companion 5, but the module also runs on Companion 4.2

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`starter/visibox-starter.companionconfig:1-12`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/starter/visibox-starter.companionconfig#L1-L12), [`companion/HELP.md:33`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/companion/HELP.md#L33)

**What goes wrong:** The help text tells users to import `visibox-starter.companionconfig` in **Import / Export**. The file was exported from Companion 5.0.5 and uses its layered buttons, but the module is built on API 1.14 and so also runs on Companion 4.2. A user on 4.2 who follows the help text will probably have the import refused or get no usable buttons (see [A3](#-assumptions-to-confirm)).

**Why it happens:** The starter page was exported from a newer Companion than the oldest one the module supports, and the help text does not say which version it needs.

**Fix:** re-export the starter page from Companion 4.2, or add a note to `companion/HELP.md` that it needs Companion 5.0 or later and point 4.x users to the presets.

### L5: Every Visibox state update refreshes all feedbacks and variables two or three times

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:80-89`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/main.ts#L80-L89)

**What goes wrong:** Nothing visible to users. Each mute, fullscreen or output-level update from Visibox rechecks every feedback and rewrites all 29 variables at least twice, plus once more when the project re-fetch triggered by the same update finishes. That is wasted work on busy pages, not a functional bug.

**Why it happens:** With `manageState: true`, the Visibox client library calls `onStateChanged` **and** emits `app-state-changed` for the same update. The module wires the same refresh to both. The code comment saying the initial fetch "only emits the event" does not match the library, which does both.

**Fix:** remove the `this.apiClient.on('app-state-changed', refresh)` line; `onStateChanged` already covers every update.

## 💡 Nice to Have

### N1: Song ID, Control and Target ID fields do not accept variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:234-241`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/actions.ts#L234-L241), [`src/actions.ts:423-430`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/actions.ts#L423-L430), [`src/actions.ts:490-497`](https://github.com/bitfocus/companion-module-spaceage-visibox/blob/5554612e0b12ecb484081430ee413d6608fe23bb/src/actions.ts#L490-L497)

**What goes wrong:** A user cannot put a variable such as `$(internal:custom_song)` into **Song Select → Song ID**, **Set Control → Control** or **Set Target Param → Target ID**. The text is sent to Visibox exactly as typed, so these actions only work with fixed values.

**Why it happens:** None of these text fields declares `useVariables`. Companion only replaces variables in a text field before the action runs when the field declares it.

**Fix:** add `useVariables: true` to the three text fields. Companion then resolves the variables before the callback runs, so the callbacks need no other change.

## 📝 Additional Notes

- `tsconfig.build.json`: the `exclude` list differs from the template (found `["node_modules/**", "src/**/*.test.ts"]`, template `["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"]`). Fine as long as the module builds; no change required.
