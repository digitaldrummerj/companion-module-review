# Review: companion-module-middleman-breaktime v2.0.1 (follow-up to the v2.0.0 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-middleman-breaktime` |
| **Scope** | `tag` (v1.0.3..v2.0.1; v2.0.0 was not published) |
| **Version** | v2.0.1 ([`1189ab7`](https://github.com/bitfocus/companion-module-middleman-breaktime/tree/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b)) |
| **Release** | Update — last published v1.0.3 |
| **API** | 2.2 (base 2.2.2, yarn.lock) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Prior review** | [v2.0.0, 2026-10-30](review-middleman-breaktime-v2.0.0-20261030-003407.md) (❌ Changes Required) |
| **Review date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When one button runs two Start Event actions with no delay between them, Companion starts the second one less than half a second after the first, whether it runs them together or one after the other | Companion's default button step behaviour (actions without a delay run back to back or together). Not checkable from the module or the `@companion-module/base` package | [L1](#l1-a-button-with-two-start-event-or-two-end-running-event-actions-only-runs-the-first-one) |
| A2 | Once base removes `disableNewConfigLayout`, Companion's automatic config layout ignores the `width` values and shows the blank `runningSlotsFiller` static-text as an empty row | The deprecation note in base 2.2.2 `base.d.ts` and the module's own comment ("base 2.x's automatic layout ignores widths"). How Companion's UI renders it was not checked | [M3](#m3-the-connection-settings-page-relies-on-a-deprecated-layout-switch-that-will-be-removed) |
| A3 | Advanced feedbacks are likely to be removed in a future major version of the Companion module API | The companion-v2-api-compliance v2.1 reference ("discouraged and likely to be removed in a future major version"). The base 2.2.2 typings carry no `@deprecated` tag on the advanced type | [M4](#m4-the-new-status-band-and-event-tile-feedbacks-use-the-discouraged-advanced-feedback-type) |
| A4 | Companion fires an action callback's `context.signal` when the user aborts a button's running actions, and the abort usually arrives after the request has already reached BreakTime | The base 2.2.2 typing comment on `CompanionActionCallbackContext.signal` ("aborts when the result of this execution is no longer needed (eg the user aborted the running actions)"). When the host fires it was not checked | [L3](#l3-aborting-a-buttons-running-actions-doesnt-cancel-the-breaktime-request-it-is-waiting-on) |
| A5 | Companion shows a `number` option as a number box that enforces its min and max in the button editor, and a `textinput` as free text | The v2.0 compliance reference and general Companion UI behaviour. Not checked against the running Companion UI | [N1](#n1-the-seconds-field-of-the-armed-duration-actions-lost-its-number-box-and-range-check) |

## 📋 Issues

### Blocking

- [ ] [C1: The license file is named LICENSE.md instead of the template's LICENSE](#c1-the-license-file-is-named-licensemd-instead-of-the-templates-license)
- [ ] [C2: Git does not ignore the `.vscode` editor settings folder](#c2-git-does-not-ignore-the-vscode-editor-settings-folder)
- [ ] [C3: The pre-commit hook that formats and lints staged files is missing](#c3-the-pre-commit-hook-that-formats-and-lints-staged-files-is-missing)
- [ ] [C4: Prettier skips the hand-written issue templates](#c4-prettier-skips-the-hand-written-issue-templates)
- [ ] [C5: Yarn settings lack the template's install-script and package-age protections](#c5-yarn-settings-lack-the-templates-install-script-and-package-age-protections)
- [ ] [C6: The template's build config `tsconfig.build.json` is missing](#c6-the-templates-build-config-tsconfigbuildjson-is-missing)
- [ ] [C7: Installing dependencies does not set up the git hooks](#c7-installing-dependencies-does-not-set-up-the-git-hooks)
- [ ] [C8: The template's `build:main` script is missing](#c8-the-templates-buildmain-script-is-missing)
- [ ] [C9: There is no `dev` script to rebuild the module while editing](#c9-there-is-no-dev-script-to-rebuild-the-module-while-editing)
- [ ] [C10: The template's `lint:raw` script is missing](#c10-the-templates-lintraw-script-is-missing)
- [ ] [C11: The `husky` git-hook tool is not a dev dependency](#c11-the-husky-git-hook-tool-is-not-a-dev-dependency)
- [ ] [C12: The `lint-staged` tool is not a dev dependency](#c12-the-lint-staged-tool-is-not-a-dev-dependency)
- [ ] [C13: The `rimraf` tool the template's build uses is not a dev dependency](#c13-the-rimraf-tool-the-templates-build-uses-is-not-a-dev-dependency)
- [ ] [C14: package.json has no `lint-staged` section telling the hook what to check](#c14-packagejson-has-no-lint-staged-section-telling-the-hook-what-to-check)
- [ ] [C15: The module still runs on Node 22 where the API 2.2 template uses Node 26](#c15-the-module-still-runs-on-node-22-where-the-api-22-template-uses-node-26)

### Non-blocking

- [ ] [M1: No CI workflow builds and lints each push](#m1-no-ci-workflow-builds-and-lints-each-push)
- [ ] [M2: No release workflow packages the module when a GitHub release is published](#m2-no-release-workflow-packages-the-module-when-a-github-release-is-published)
- [ ] [M3: The connection settings page relies on a deprecated layout switch that will be removed](#m3-the-connection-settings-page-relies-on-a-deprecated-layout-switch-that-will-be-removed)
- [ ] [M4: The new Status Band and Event Tile feedbacks use the discouraged advanced feedback type](#m4-the-new-status-band-and-event-tile-feedbacks-use-the-discouraged-advanced-feedback-type)
- [ ] [L1: A button with two Start Event (or two End Running Event) actions only runs the first one](#l1-a-button-with-two-start-event-or-two-end-running-event-actions-only-runs-the-first-one)
- [ ] [L2: END and END NOW presets in the Simple workflows stay dim while an event is running if a different event is armed](#l2-end-and-end-now-presets-in-the-simple-workflows-stay-dim-while-an-event-is-running-if-a-different-event-is-armed)
- [ ] [L3: Aborting a button's running actions doesn't cancel the BreakTime request it is waiting on](#l3-aborting-a-buttons-running-actions-doesnt-cancel-the-breaktime-request-it-is-waiting-on)
- [ ] [L4: Action and feedback options are not type-checked against a schema](#l4-action-and-feedback-options-are-not-type-checked-against-a-schema)
- [ ] [N1: The Seconds field of the Armed Duration actions lost its number box and range check](#n1-the-seconds-field-of-the-armed-duration-actions-lost-its-number-box-and-range-check)
- [ ] [N2: State-frame parsing hides the Buffer type behind a double cast](#n2-state-frame-parsing-hides-the-buffer-type-behind-a-double-cast)

### Notes

- **Follow-up to the v2.0.0 review:** all six blocking findings of the [v2.0.0 review](review-middleman-breaktime-v2.0.0-20261030-003407.md) (C1–C5, H1) are fixed in v2.0.1, and its NR1 (move to API 2.x) is done; the status of each is in Additional Notes. The blocking findings above are new: moving to TypeScript and API 2.2 makes the TypeScript template the reference, and the module doesn't follow it yet.
- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The license file is named LICENSE.md instead of the template's LICENSE

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `LICENSE` (missing); the MIT text is in [`LICENSE.md`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/LICENSE.md)

**What goes wrong:** The repository has no `LICENSE` file. The MIT license text is in `LICENSE.md`, so the repository layout no longer matches the template every other module follows.

**Why it happens:** This release renamed `LICENSE` to `LICENSE.md` (git records it as a pure rename). The template ships the file as `LICENSE`. The template's `.prettierignore` names `/LICENSE.md`, which is probably why the rename looked right after the v2.0.0 review asked for that `.prettierignore` line. That line is a quirk of the template, not the file name to use.

**Evidence:**

```text
Required file LICENSE is missing (tracked by the template)
Found: LICENSE.md (renamed from LICENSE in this release)
```

**Fix:** rename the file back to `LICENSE`. Keep `/LICENSE.md` in `.prettierignore`, as the template has it.

```bash
git mv LICENSE.md LICENSE
```

### C2: Git does not ignore the `.vscode` editor settings folder

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/.gitignore)

**What goes wrong:** A developer's VS Code settings folder (`.vscode/`) can be committed to the repository by accident.

**Why it happens:** The TypeScript template's `.gitignore` lists `/.vscode`. The module's `.gitignore` now has every other template entry (including the `DEBUG-*` and `/.yarn` lines the v2.0.0 review asked for), but not this one. The JS v1 template that the v2.0.0 review compared against has no `/.vscode` line; it applies now because the module moved to the TypeScript template.

**Evidence:**

```text
Missing template .gitignore entries: /.vscode
```

**Fix:** add the line to `.gitignore`.

```text
/.vscode
```

### C3: The pre-commit hook that formats and lints staged files is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Nothing checks a commit before it is made, so unformatted or lint-failing code can be committed and is only caught later, if at all.

**Why it happens:** The template tracks `.husky/pre-commit`, a git hook that runs `lint-staged` to format and lint the staged files. The module has no `.husky` folder. The hook needs the rest of the template's hook setup too: [C7](#c7-installing-dependencies-does-not-set-up-the-git-hooks), [C11](#c11-the-husky-git-hook-tool-is-not-a-dev-dependency), [C12](#c12-the-lint-staged-tool-is-not-a-dev-dependency) and [C14](#c14-packagejson-has-no-lint-staged-section-telling-the-hook-what-to-check).

**Evidence:**

```text
Required file .husky/pre-commit is missing (tracked by the template)
```

**Fix:** add `.husky/pre-commit` with the template's single line.

```text
lint-staged
```

### C4: Prettier skips the hand-written issue templates

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:3-4`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/.prettierignore#L3-L4)

**What goes wrong:** `yarn format` skips the issue-template forms in `.github/ISSUE_TEMPLATE`, so those hand-written YAML files can drift from the project's formatting.

**Why it happens:** `.prettierignore` adds two entries the template doesn't have: `.github/ISSUE_TEMPLATE` (line 3) and `/dist` (line 4). `/dist` is build output, and ignoring it is fine. The issue templates are hand-written files, not generated ones. The `.github/ISSUE_TEMPLATE` line was already in v2.0.0; the v2.0.0 review didn't report it, so it is raised here for the first time.

**Evidence:**

```text
Extra entries not in template: .github/ISSUE_TEMPLATE, /dist
```

**Fix:** remove the `.github/ISSUE_TEMPLATE` line. Keeping `/dist` is fine.

### C5: Yarn settings lack the template's install-script and package-age protections

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/.yarnrc.yml)

**What goes wrong:** `yarn install` runs without the template's supply-chain protections: dependencies are allowed to run their install scripts, and a package version published a few minutes ago can be installed straight away.

**Why it happens:** `.yarnrc.yml` is new in this release, added for the v2.0.0 review's C3, but it only sets `nodeLinker: node-modules`. That review quoted only that line, which was incomplete. The template's file also sets `enableScripts: false` (dependencies' install scripts don't run), `npmMinimalAgeGate: 3d` (only versions at least 3 days old are installed) and `npmPreapprovedPackages` (`@companion-module/*` is exempt from the age gate).

**Evidence:**

```text
Missing template keys: enableScripts, npmMinimalAgeGate, npmPreapprovedPackages
```

**Fix:** replace `.yarnrc.yml` with the template's contents.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C6: The template's build config `tsconfig.build.json` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `tsconfig.build.json` (missing); [`tsconfig.json`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/tsconfig.json)

**What goes wrong:** The module builds from a single `tsconfig.json`, so it doesn't get the template's build settings (the Node 26 preset, and test files left out of the build), and the template's `build:main` and `dev` scripts ([C8](#c8-the-templates-buildmain-script-is-missing), [C9](#c9-there-is-no-dev-script-to-rebuild-the-module-while-editing)) have no file to point at.

**Why it happens:** In the template, `tsconfig.build.json` holds the build settings and `tsconfig.json` extends it. The module has no `tsconfig.build.json`; its `tsconfig.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json` directly.

**Evidence:**

```text
Required file tsconfig.build.json is missing (tracked by the template)
```

**Fix:** add the template's `tsconfig.build.json`, with the Node 26 preset (see [C15](#c15-the-module-still-runs-on-node-22-where-the-api-22-template-uses-node-26)), and make `tsconfig.json` extend it as the template's does.

```json
{
	"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
	"include": ["src/**/*.ts"],
	"exclude": ["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"],
	"compilerOptions": {
		"outDir": "./dist",
		"rootDir": "./src",
		"verbatimModuleSyntax": true
	}
}
```

### C7: Installing dependencies does not set up the git hooks

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L6-L14)

**What goes wrong:** After `yarn install`, the git hooks are not installed, so the pre-commit check ([C3](#c3-the-pre-commit-hook-that-formats-and-lints-staged-files-is-missing)) never runs on a developer's machine.

**Why it happens:** The template's `"postinstall": "husky"` script sets up the `.husky` hooks after every install. The module's `package.json` has no `postinstall` script.

**Evidence:**

```text
Missing required script 'postinstall'
```

**Fix:** add `"postinstall": "husky"` to `scripts` (the full template block is in [C8](#c8-the-templates-buildmain-script-is-missing)).

### C8: The template's `build:main` script is missing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L6-L14)

**What goes wrong:** The build scripts don't match the template. `yarn build` runs a bare `tsc`: it doesn't clear `dist/` first, and there is no `build:main` step for the other scripts to call.

**Why it happens:** The template splits the build in two: `build` clears `dist/` with `rimraf` and then runs `build:main`, which compiles with `tsconfig.build.json`. The module has only `"build": "tsc"`.

**Evidence:**

```text
Missing required script 'build:main'
```

**Fix:** use the template's scripts. Keep the module's own extra scripts (`typecheck`, `package:beta`) next to them.

```json
"scripts": {
	"postinstall": "husky",
	"format": "prettier -w .",
	"package": "run build && companion-module-build",
	"build": "rimraf dist && run build:main",
	"build:main": "tsc -p tsconfig.build.json",
	"dev": "tsc -p tsconfig.build.json --watch",
	"lint:raw": "eslint",
	"lint": "run lint:raw ."
}
```

### C9: There is no `dev` script to rebuild the module while editing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L6-L14)

**What goes wrong:** Developers have no `yarn dev` that recompiles the module on every save, as in every module built from the template.

**Why it happens:** The template's `"dev": "tsc -p tsconfig.build.json --watch"` script is missing from `package.json`.

**Evidence:**

```text
Missing required script 'dev'
```

**Fix:** add `"dev": "tsc -p tsconfig.build.json --watch"` (see the block in [C8](#c8-the-templates-buildmain-script-is-missing)).

### C10: The template's `lint:raw` script is missing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L6-L14)

**What goes wrong:** The template's pre-commit step lints the staged files by running `yarn lint:raw --fix` on them. Without a `lint:raw` script, that step fails once the hook is added.

**Why it happens:** The template defines `"lint:raw": "eslint"` and builds `lint` on it (`run lint:raw .`). The module has only `"lint": "eslint ."`.

**Evidence:**

```text
Missing required script 'lint:raw'
```

**Fix:** add `"lint:raw": "eslint"` and change `lint` to `run lint:raw .` (see the block in [C8](#c8-the-templates-buildmain-script-is-missing)).

### C11: The `husky` git-hook tool is not a dev dependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:28-36`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L28-L36)

**What goes wrong:** The `postinstall` script ([C7](#c7-installing-dependencies-does-not-set-up-the-git-hooks)) can't install the git hooks, because the tool that does it isn't installed.

**Why it happens:** The template's `devDependencies` include `husky`; the module's don't.

**Evidence:**

```text
Missing devDependency 'husky' (present in template)
```

**Fix:** add `"husky": "^9.1.7"` to `devDependencies` (`yarn add -D husky`).

### C12: The `lint-staged` tool is not a dev dependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:28-36`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L28-L36)

**What goes wrong:** The pre-commit hook ([C3](#c3-the-pre-commit-hook-that-formats-and-lints-staged-files-is-missing)) runs `lint-staged`, which isn't installed, so the hook can't run.

**Why it happens:** The template's `devDependencies` include `lint-staged`; the module's don't.

**Evidence:**

```text
Missing devDependency 'lint-staged' (present in template)
```

**Fix:** add `"lint-staged": "^17.6.0"` to `devDependencies` (`yarn add -D lint-staged`).

### C13: The `rimraf` tool the template's build uses is not a dev dependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:28-36`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L28-L36)

**What goes wrong:** The template's `build` script (`rimraf dist && run build:main`, see [C8](#c8-the-templates-buildmain-script-is-missing)) fails, because `rimraf` isn't installed.

**Why it happens:** The template's `devDependencies` include `rimraf`; the module's don't.

**Evidence:**

```text
Missing devDependency 'rimraf' (present in template)
```

**Fix:** add `"rimraf": "^6.1.3"` to `devDependencies` (`yarn add -D rimraf`).

### C14: package.json has no `lint-staged` section telling the hook what to check

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json)

**What goes wrong:** Even with the hook and tools in place, `lint-staged` would have no instructions, so staged files would be neither formatted nor linted.

**Why it happens:** The template's `package.json` has a `lint-staged` section: Prettier formats staged CSS, JSON, Markdown and SCSS files, and ESLint fixes staged TypeScript and JavaScript files. The module's `package.json` has no such section.

**Evidence:**

```text
Missing 'lint-staged' section (present in template)
```

**Fix:** add the template's section to `package.json`.

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

### C15: The module still runs on Node 22 where the API 2.2 template uses Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/companion/manifest.json#L20), [`package.json:17`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L17), [`package.json:30`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/package.json#L30), [`tsconfig.json:2`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/tsconfig.json#L2)

**What goes wrong:** Companion starts this module on Node 22, while modules built from the API 2.2 template run on Node 26. A module on a different Node version from its template makes later problems harder to troubleshoot.

**Why it happens:** The manifest's `runtime.type` is `node22`, and the other places that name a Node version still name 22: the `engines` field allows Node 22, `@types/node` is the Node 22 typings, and `tsconfig.json` extends the Node 22 preset.

**Evidence:**

```text
companion/manifest.json runtime.type 'node22' -> 'node26'
package.json engines.node '^22.20 || ^26.5' -> '^26'
package.json devDependencies @types/node '^22.20.0' -> '^26.6.4'
tsconfig.json extends '@companion-module/tools/tsconfig/node22/recommended-esm.json' (template: node26 preset via tsconfig.build.json)
```

**Fix:** move every place to Node 26.

- [ ] `companion/manifest.json`: `"runtime": { "type": "node26" }`
- [ ] `package.json`: `"engines": { "node": "^26" }`
- [ ] `package.json`: `"@types/node": "^26.6.4"` in `devDependencies`
- [ ] new `tsconfig.build.json` (see [C6](#c6-the-templates-build-config-tsconfigbuildjson-is-missing)): `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"`. The current `tsconfig.json` extends the `node22/recommended-esm.json` preset directly

## 🟡 Medium

### M1: No CI workflow builds and lints each push

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** Pushes and pull requests aren't built and linted on GitHub, so a broken build or a lint error is only found later, at release time.

**Why it happens:** The template tracks `.github/workflows/node.yaml`, which installs, builds and lints on every push and pull request. The module has only `companion-module-checks.yaml`.

**Fix:** copy the template's `.github/workflows/node.yaml`. Its `node-version: 26.x` matches the Node 26 move in [C15](#c15-the-module-still-runs-on-node-22-where-the-api-22-template-uses-node-26).

### M2: No release workflow packages the module when a GitHub release is published

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** Publishing a GitHub release doesn't build the module package or attach it to the release.

**Why it happens:** The template tracks `.github/workflows/release.yaml`, which runs the Bitfocus module checks on the release tag and attaches the built package to the release. The module has no such workflow.

**Fix:** copy the template's `.github/workflows/release.yaml`.

### M3: The connection settings page relies on a deprecated layout switch that will be removed

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:291-292`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/main.ts#L291-L292), [`src/configFields.ts:117-124`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/configFields.ts#L117-L124)

**What goes wrong:** Nothing changes for users today. The BreakTime connection settings show a hand-built 12-column grid: Host (width 8) next to Port (width 4), and Running Event Slots (width 4) next to an empty filler (width 8). Base 2.2.2 marks the switch that keeps this grid as deprecated and due for removal. Once it is gone, Companion uses its automatic layout: the widths stop mattering, and the blank filler field shows up as an empty row under Show Advanced Settings.

**Why it happens:** The module's constructor sets `this.instanceOptions.disableNewConfigLayout = true` to keep the old width-based layout. The base typings mark that option `@deprecated` ("will be removed in future versions"). It is new in this release; v1.0.3 never set it. The v2.0.0 review's NR1 already suggested checking this grid layout after a move to v2.

**Evidence:**

```ts
// src/main.ts:291-292
		// Keep the hand-built 12-column config grid; base 2.x's automatic layout ignores widths
		this.instanceOptions.disableNewConfigLayout = true
```

```ts
// node_modules/@companion-module/base/dist/module-api/base.d.ts:21-29
    /**
     * Disable the new connection configuration layout.
     *
     * @deprecated This option will be removed in future versions. Avoid using this when possible.
     *
     * We acknowledge that some modules may face challenges adapting to the new configuration layout.
     * If this is you, we want to hear from you! Let us know what is missing in order for you to adopt the new layout.
     */
    disableNewConfigLayout: boolean;
```

**Fix:** adopt the new config layout. Remove `this.instanceOptions.disableNewConfigLayout = true`, drop the `width` values and the `runningSlotsFiller` static-text (which only pads the old grid row), and check the page in Companion. If the new layout can't show something the form needs, tell Bitfocus, as the deprecation note asks.

### M4: The new Status Band and Event Tile feedbacks use the discouraged advanced feedback type

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:305-310`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/feedbacks.ts#L305-L310), [`src/feedbacks.ts:349-354`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/feedbacks.ts#L349-L354)

**What goes wrong:** Nothing changes for users today: Status Band (Remaining Time) turns a tile green, amber or red, and Event Tile shows one event's name, clock and state. On API 2.1 and later, advanced feedbacks are discouraged and likely to be removed in a future major API version. Buttons built from the Status Countdown (Armed) and Status Countdown (Latest Running) presets, and any Event Tile buttons users made, would then need rework. Status Band only sets colours, which is exactly what boolean feedbacks do.

**Why it happens:** Both feedbacks are new in this release (v1.0.3 had only boolean feedbacks) and are declared `type: 'advanced'`. They do declare `affectedProperties`, as API 2.1 requires, and the lists match what the callbacks return.

**Fix:** rebuild Status Band from boolean feedbacks: for example one "Remaining Time Below" boolean with Target (armed or latest) and Seconds options, used twice in the preset (amber at 20 s, then red at 10 s listed last so it wins), plus a "Counting Down" boolean for the green base. For Event Tile, consider boolean state feedbacks (running, armed, idle for a chosen event) with the text from variables, or a layered preset. If nothing fits Event Tile, keep it and move Status Band first.

## 🟢 Low

### L1: A button with two Start Event (or two End Running Event) actions only runs the first one

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:1852-1855`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/api.ts#L1852-L1855), [`src/api.ts:1901`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/api.ts#L1901), [`src/api.ts:1964-1967`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/api.ts#L1964-L1967), [`src/api.ts:2008`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/api.ts#L2008), [`src/api.ts:2067-2083`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/api.ts#L2067-L2083)

**What goes wrong:** Say an operator builds one button, "Start A+B", with two Start Event actions: Event "Break A" and Event "Break B". Pressing it starts only Break A. The second action is dropped, the Event Related warning shows "Pressed again within 0.5 s", and the log shows `action: start event="Break B" ... outcome=NotSent`. The same happens with two End Running Event actions set to Target "Specific event" (A and B), and with a trigger that fires Start Event less than half a second after someone pressed a Start button. [`companion/HELP.md:85`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/companion/HELP.md#L85) explains the shared half second as protection against a double press; it doesn't say that it also drops the second action of a multi-action button or a trigger.

**Why it happens:** Every Start Event and Start Armed Event action shares one "last sent" timestamp, whatever event it targets, and every End Running Event action shares another. The timestamp is set just before the first request goes out, so any second Start (or End) action within 500 ms is refused locally, even when it names a different event.

**Fix:** key the half-second window by target, so only a repeat of the same target is ignored: for example the armed event for Start Armed Event, the event ID for Start Event, and the target plus event ID for End Running Event. Another option is an action checkbox such as "Ignore a repeat within 0.5 s" (on by default) that multi-action buttons can turn off. At the least, add a sentence to HELP.md saying that two Start or End actions on one button need at least 500 ms between them.

### L2: END and END NOW presets in the Simple workflows stay dim while an event is running if a different event is armed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:296-330`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/presets.ts#L296-L330)

**What goes wrong:** The End (Latest Running) and End Now (Crash Out) presets in Simple Workflow (Fixed) and Simple Workflow (Variable) say they turn "red while an event is running, and dim while nothing is running". Their colours actually follow the armed event. Example: the operator starts "Break 1", then arms "Break 2" with an Arm Event or Arm Next button. From then on the END button shows dimmed text on dark gray while Break 1 is still running, and pressing it still ends Break 1. With nothing armed, neither colour applies, so END looks idle even while events are running. The stop button's tally doesn't match what the button does.

**Why it happens:** Both presets colour the button with the Armed Event is Running and Armed Event is Stopped feedbacks (`selectedIsRunning`, `selectedisFinished`), which read the armed event's state. The action itself ends the latest running event. The Playlist workflow's End Now and End All presets already use the Running Events At Least feedback (`runningCountAtLeast`), which follows the running events.

**Fix:** make both Simple-workflow END presets work like `Playlist_EndAll`: set the base text colour to `COLORS.DIM_TEXT` and use one `runningCountAtLeast` feedback with `{ count: 1 }` and style `{ bgcolor: COLORS.RED, color: COLORS.WHITE }`, in place of the two armed-event feedbacks. The button then turns red exactly when End has something to end.

### L3: Aborting a button's running actions doesn't cancel the BreakTime request it is waiting on

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:69-71`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/actions.ts#L69-L71), [`src/api.ts:2956-2960`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/api.ts#L2956-L2960)

**What goes wrong:** Little visible effect. If an operator aborts a button's running actions while a Start Event, End Running Event or Arm request is waiting for BreakTime, the module keeps waiting for up to 4 seconds. It then logs the outcome and may show a warning in `$(breaktime:message)` or the Status tile for an action the operator already cancelled. The request has usually reached BreakTime already, so the result on BreakTime is the same either way.

**Why it happens:** Companion gives each action callback an abort signal (`context.signal`) that fires when the action's result is no longer needed. The module's callbacks don't take it: every request is sent with only the module's own 4-second timeout as its signal. Base 2.2.2 makes respecting the signal optional; the v2.1 rules recommend it for network calls in callbacks.

**Fix:** take the context in each callback, pass its signal down to `sendREST()` / `restRequest()`, and combine it with the timeout. Skip the warning when the signal was aborted. Leave the short local-check paths as they are.

```ts
callback: async (action, context) => self.startSelected(action.options, context.signal),
// in restRequest():
signal: signal ? AbortSignal.any([signal, AbortSignal.timeout(self.REST_TIMEOUT_MS)]) : AbortSignal.timeout(self.REST_TIMEOUT_MS),
```

### L4: Action and feedback options are not type-checked against a schema

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:131-137`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/main.ts#L131-L137)

**What goes wrong:** No user-visible effect; this is code quality only. TypeScript can't catch a misspelt action or feedback id in a preset (e.g. `feedbackId: 'selectedIsFinished'` instead of `'selectedisFinished'`) or an option id typo in a callback (e.g. `options.evnet`). Mistakes like that would only show up at runtime, as a broken preset or an option that is silently ignored.

**Why it happens:** The module's type manifest (`BreakTimeInstanceTypes`) declares `actions` and `feedbacks` as open records of generic option values, so the action, feedback and preset definitions accept any id and any option shape. API 2.0 recommends building the definitions against a typed schema.

**Fix:** declare a schema per action and feedback and use them in `BreakTimeInstanceTypes`. Keep the `?? default` fallbacks for buttons saved before an option existed.

```ts
type ActionsSchema = {
	startSelected: { options: { event: string; immediate: boolean; onlyWhenIdle: boolean } }
	endSelected: { options: { target: 'latest' | 'all' | 'specific'; event: string; immediate: boolean } }
	// …
}
```

## 💡 Nice to Have

### N1: The Seconds field of the Armed Duration actions lost its number box and range check

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:151-183`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/actions.ts#L151-L183), [`src/upgrades.ts:44-46`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/upgrades.ts#L44-L46)

**What goes wrong:** In v1.0.3 the Seconds field of Armed Duration + and Armed Duration - was a number box limited to 1–65535. Now it is a free text box. Typing "5s" or "abc" is accepted in the button editor, and the mistake only shows when the button is pressed: the press is refused with "Seconds must be a whole number from 1 to 65535". The Seconds fields of Set Armed Duration and of the Armed Duration Is and Running Slot Time Remaining Below feedbacks work the same way. Nothing breaks: the module accepts both text and numbers.

**Why it happens:** The field changed from a number option to a text option with variables enabled, so it can take variables. On API 2.x a number option already accepts variables through expression mode. The upgrade script's base helper (`FixupNumericOrVariablesValueToExpressions`) is meant for the opposite conversion (text to number); for a number stored by v1.0.3 it returns the same number, so it changes nothing here except reporting every such action as updated.

**Fix:** optional. Consider `type: 'number'` with `min: 1`, `max: self.DURATION_STEP_MAX_S` and `asInteger: true` for these Seconds options: users keep variables through expression mode and get the editor's range check back. If any users already have the text form, add a new upgrade script at the end rather than editing the existing one. Also correct the comment in [`src/upgrades.ts:44-46`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/upgrades.ts#L44-L46), which says the helper "turns a stored number into the expression format".

### N2: State-frame parsing hides the Buffer type behind a double cast

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:861-863`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/api.ts#L861-L863)

**What goes wrong:** Nothing changes for users: frames parse correctly, because `JSON.parse` turns the Buffer into text. The `as unknown as string` cast turns off type checking at that spot, so a later change to the WebSocket data type (for example `binaryType: 'arraybuffer'`, or fragmented `Buffer[]` frames) would still compile but fail at runtime with a frame error on every frame.

**Why it happens:** The raw WebSocket data (`Buffer | ArrayBuffer | Buffer[]`) is passed to `JSON.parse` through a double cast instead of being converted to text explicitly.

**Fix:** convert explicitly, then parse. That removes the cast and the `eslint-disable` on the debug dump line.

```ts
const text = Buffer.isBuffer(raw)
	? raw.toString('utf8')
	: Array.isArray(raw)
		? Buffer.concat(raw).toString('utf8')
		: Buffer.from(raw).toString('utf8')
return JSON.parse(text)
```

## 📝 Additional Notes

- v2.0.0 review [C1](review-middleman-breaktime-v2.0.0-20261030-003407.md#c1-debug-logs-and-the-yarn-cache-folder-are-not-ignored-by-git) (`.gitignore` missing `DEBUG-*` and `/.yarn`): fixed, both lines are in [`.gitignore:7-8`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/.gitignore#L7-L8).
- v2.0.0 review [C2](review-middleman-breaktime-v2.0.0-20261030-003407.md#c2-prettier-ignore-list-names-license-instead-of-the-templates-licensemd) (`.prettierignore` named `/LICENSE`): fixed, line 2 is `/LICENSE.md` again. The file itself was then renamed, which [C1](#c1-the-license-file-is-named-licensemd-instead-of-the-templates-license) asks to undo.
- v2.0.0 review [C3](review-middleman-breaktime-v2.0.0-20261030-003407.md#c3-yarn-settings-file-is-missing-so-installs-can-use-a-different-yarn-setup-than-the-template) (`.yarnrc.yml` missing): fixed as asked; the template's three other keys are still missing, see [C5](#c5-yarn-settings-lack-the-templates-install-script-and-package-age-protections).
- v2.0.0 review [C4](review-middleman-breaktime-v2.0.0-20261030-003407.md#c4-module-entry-file-sits-at-the-repository-root-instead-of-under-src) (entry file at the repository root): fixed, the entry is [`src/main.ts`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/src/main.ts) and `package.json` has `"main": "dist/main.js"`, as in the template.
- v2.0.0 review [C5](review-middleman-breaktime-v2.0.0-20261030-003407.md#c5-packagejson-does-not-pin-the-yarn-version) (no `packageManager`): fixed, `"packageManager": "yarn@4.18.1"` matches the template.
- v2.0.0 review [H1](review-middleman-breaktime-v2.0.0-20261030-003407.md#h1-variables-typed-into-the-seconds-and-slot-fields-are-never-resolved-so-those-buttons-and-feedbacks-stop-working) (variables in the Seconds and Slot fields never resolved): fixed by the move to API 2.2, where Companion resolves variables in `useVariables` text fields before the callback runs.
- v2.0.0 review [NR1](review-middleman-breaktime-v2.0.0-20261030-003407.md#nr1-module-stays-on-companion-api-113-consider-114-or-v2-next) (stay on API 1.13): done, `@companion-module/base` is `~2.2.2`.
- `tsconfig.json` differs from the template: `extends` is `@companion-module/tools/tsconfig/node22/recommended-esm.json` instead of the template's `./tsconfig.build.json` (non-blocking; the module builds and lints).
- API compliance was checked against the API 2.0 and 2.1 rules only: the review's API reference has no 2.2 section yet, so changes that are new in 2.2 were not checked. [`companion/HELP.md:13`](https://github.com/bitfocus/companion-module-middleman-breaktime/blob/1189ab71b52f9ba2fb3a1846afcda80f1e06de6b/companion/HELP.md#L13) says module 2.x needs Companion 5.1 or later.
