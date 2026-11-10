# Companion Module Review: saccani-live-studio v1.0.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-saccani-live-studio](https://github.com/bitfocus/companion-module-saccani-live-studio) |
| **Version** | v1.0.1 (commit [`bccc2a7`](https://github.com/bitfocus/companion-module-saccani-live-studio/commit/bccc2a78b10dd504232250ef2eba02969058f63d)) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` — first release: no version has been published, so there is nothing to diff against and the whole module at v1.0.1 was reviewed (the earlier tags v0.6.1, v0.6.2, v0.8.0 and v1.0.0 were never published) |
| **Reviewed** | 2026-11-09 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: Lockfiles, debug logs and editor settings can be committed by mistake](#c1-lockfiles-debug-logs-and-editor-settings-can-be-committed-by-mistake)
- [ ] [C2: The template's lint config, pre-commit hook, Prettier ignore list and build tsconfig are missing](#c2-the-templates-lint-config-pre-commit-hook-prettier-ignore-list-and-build-tsconfig-are-missing)
- [ ] [C3: Five template scripts are missing, including lint and dev](#c3-five-template-scripts-are-missing-including-lint-and-dev)
- [ ] [C4: The template's husky, lint-staged, rimraf and typescript-eslint dev tools are missing](#c4-the-templates-husky-lint-staged-rimraf-and-typescript-eslint-dev-tools-are-missing)
- [ ] [C5: Prettier doesn't use the shared Companion style and the pre-commit hook has nothing to run](#c5-prettier-doesnt-use-the-shared-companion-style-and-the-pre-commit-hook-has-nothing-to-run)
- [ ] [H1: The Bitfocus module checks are skipped whenever the repository is private](#h1-the-bitfocus-module-checks-are-skipped-whenever-the-repository-is-private)
- [ ] [H2: CI runs a custom test job instead of the template's lint job, so lint never runs in CI](#h2-ci-runs-a-custom-test-job-instead-of-the-templates-lint-job-so-lint-never-runs-in-ci)
- [ ] [H3: yarn lint fails because the module has no lint script](#h3-yarn-lint-fails-because-the-module-has-no-lint-script)
- [ ] [H4: Config, upgrade scripts, actions, feedbacks, variables and presets all live in one 1,298-line main.ts](#h4-config-upgrade-scripts-actions-feedbacks-variables-and-presets-all-live-in-one-1298-line-maints)
- [ ] [H5: yarn build, yarn package and yarn format run different commands from the template](#h5-yarn-build-yarn-package-and-yarn-format-run-different-commands-from-the-template)
- [ ] [H6: package.json engines doesn't declare Yarn 4 like the template](#h6-packagejson-engines-doesnt-declare-yarn-4-like-the-template)
- [ ] [H7: Dev tools are pinned to exact versions, and eslint is on a different major than the template](#h7-dev-tools-are-pinned-to-exact-versions-and-eslint-is-on-a-different-major-than-the-template)

### Non-blocking

- [ ] [M1: Presets offer Play, Pause, Stop, Restart and a jog dial for channels that can't play media](#m1-presets-offer-play-pause-stop-restart-and-a-jog-dial-for-channels-that-cant-play-media)
- [ ] [L1: Connection status shows raw errors such as TypeError: fetch failed instead of a helpful reason](#l1-connection-status-shows-raw-errors-such-as-typeerror-fetch-failed-instead-of-a-helpful-reason)
- [ ] [L2: Progress and seconds variables show long unrounded decimals on buttons](#l2-progress-and-seconds-variables-show-long-unrounded-decimals-on-buttons)
- [ ] [L3: Every variable and feedback is re-sent four times a second, even when nothing changed](#l3-every-variable-and-feedback-is-re-sent-four-times-a-second-even-when-nothing-changed)
- [ ] [L4: Redundant casts and Number() conversions on already-typed action options](#l4-redundant-casts-and-number-conversions-on-already-typed-action-options)
- [ ] [L5: Relative imports mix .ts and .js extensions](#l5-relative-imports-mix-ts-and-js-extensions)
- [ ] [N1: Error messages still say "tab" where the rest of the module says "channel"](#n1-error-messages-still-say-tab-where-the-rest-of-the-module-says-channel)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

C2–C5 have one cause: the module was not set up from the API 2.0 TypeScript template's tooling (husky, lint-staged, Prettier, ESLint and the separate build tsconfig). Adopting that tooling fixes all four, and [H3](#h3-yarn-lint-fails-because-the-module-has-no-lint-script) with them.

### C1: Lockfiles, debug logs and editor settings can be committed by mistake

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-8`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/.gitignore#L1-L8)

**What goes wrong:** A contributor who runs `npm install`, opens the repo in VS Code, or leaves a `DEBUG-*` log in the folder can commit `package-lock.json`, `.vscode/` or the log by accident, because the module's `.gitignore` doesn't ignore them.

**Why it happens:** The `.gitignore` was written by hand instead of copied from the template. The module has unanchored versions of four template entries (`dist/`, `pkg/`, `.yarn/`, `*.tgz`), so the entries missing in any form are `package-lock.json`, `DEBUG-*` and `/.vscode`.

**Evidence:**

```text
CONFIG-DIFF .gitignore: Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode
```

**Fix:** Add every entry from the template's `.gitignore`. The module's extra entries (`.pnp.*`, `.DS_Store`, `*.log`) can stay.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

### C2: The template's lint config, pre-commit hook, Prettier ignore list and build tsconfig are missing

- **Source:** 🤖 validate-template (FILE-MISSING ×4)
- **Classification:** 🆕 NEW
- **Files:** `.husky/pre-commit`, `.prettierignore`, `eslint.config.mjs`, `tsconfig.build.json` (none of them is in the repo)

**What goes wrong:** Users see no difference. Maintainers and contributors do: there is no ESLint configuration, so the code is never linted ([H3](#h3-yarn-lint-fails-because-the-module-has-no-lint-script)); commits don't run the pre-commit hook that formats and lints staged files; Prettier has no ignore list; and there is no separate build tsconfig. Anyone who knows the template has to work out why this module's tooling behaves differently, which makes problems harder to troubleshoot.

**Why it happens:** The template tracks these four files and the module has none of them.

**Evidence:**

```text
FILE-MISSING .husky/pre-commit     Required file is missing (tracked by the template)
FILE-MISSING .prettierignore       Required file is missing (tracked by the template)
FILE-MISSING eslint.config.mjs     Required file is missing (tracked by the template)
FILE-MISSING tsconfig.build.json   Required file is missing (tracked by the template)
```

**Fix:** Copy the four files from `companion-module-template-ts-v2.0.4`, and make `tsconfig.json` extend `./tsconfig.build.json` as the template does (see [📝 Additional Notes](#-additional-notes)). While the source keeps its `.ts` imports, `tsconfig.build.json` also needs `"rewriteRelativeImportExtensions": true` (see [L5](#l5-relative-imports-mix-ts-and-js-extensions)).

```js
// eslint.config.mjs
import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'

export default generateEslintConfig({
	enableTypescript: true,
})
```

```json
// tsconfig.build.json
{
	"extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json",
	"include": ["src/**/*.ts"],
	"exclude": ["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"],
	"compilerOptions": {
		"outDir": "./dist",
		"rootDir": "./src",
		"verbatimModuleSyntax": true
	}
}
```

```text
# .husky/pre-commit
lint-staged

# .prettierignore
package.json
/LICENSE.md
```

### C3: Five template scripts are missing, including lint and dev

- **Source:** 🤖 validate-template (PKG-SCRIPT ×5)
- **Classification:** 🆕 NEW
- **File:** [`package.json:18-24`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L18-L24)

**What goes wrong:** A contributor who follows the template's workflow gets `Couldn't find a script named ...` for `yarn lint`, `yarn lint:raw`, `yarn dev` and `yarn build:main`, and `yarn install` doesn't set up the pre-commit hook because there is no `postinstall` script.

**Why it happens:** The `scripts` block was written for the module instead of copied from the template, so these five template scripts are absent. The commands of the scripts that do exist are covered in [H5](#h5-yarn-build-yarn-package-and-yarn-format-run-different-commands-from-the-template).

**Evidence:**

```text
PKG-SCRIPT package.json: Missing required script 'postinstall'
PKG-SCRIPT package.json: Missing required script 'build:main'
PKG-SCRIPT package.json: Missing required script 'dev'
PKG-SCRIPT package.json: Missing required script 'lint:raw'
PKG-SCRIPT package.json: Missing required script 'lint'
```

**Fix:** Add the template's scripts. Extra scripts such as `check` and `test` can stay.

```json
"postinstall": "husky",
"build:main": "tsc -p tsconfig.build.json",
"dev": "tsc -p tsconfig.build.json --watch",
"lint:raw": "eslint",
"lint": "run lint:raw ."
```

### C4: The template's husky, lint-staged, rimraf and typescript-eslint dev tools are missing

- **Source:** 🤖 validate-template (PKG-DEVDEP ×4)
- **Classification:** 🆕 NEW
- **File:** [`package.json:28-34`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L28-L34)

**What goes wrong:** The template's scripts and files need these tools: `postinstall` runs husky, the pre-commit hook runs lint-staged, `yarn build` runs rimraf, and the TypeScript ESLint config needs typescript-eslint. Without them, adding the scripts and files from [C2](#c2-the-templates-lint-config-pre-commit-hook-prettier-ignore-list-and-build-tsconfig-are-missing) and [C3](#c3-five-template-scripts-are-missing-including-lint-and-dev) still fails.

**Why it happens:** The `devDependencies` list only has the tools the module's own scripts use.

**Evidence:**

```text
PKG-DEVDEP package.json: Missing devDependency 'husky' (present in template)
PKG-DEVDEP package.json: Missing devDependency 'lint-staged' (present in template)
PKG-DEVDEP package.json: Missing devDependency 'rimraf' (present in template)
PKG-DEVDEP package.json: Missing devDependency 'typescript-eslint' (present in template)
```

**Fix:** Add them with the template's version ranges, then run `yarn install`. The versions of the existing dev tools are covered in [H7](#h7-dev-tools-are-pinned-to-exact-versions-and-eslint-is-on-a-different-major-than-the-template).

```json
"husky": "^9.1.7",
"lint-staged": "^16.4.0",
"rimraf": "^6.1.3",
"typescript-eslint": "^8.59.0"
```

### C5: Prettier doesn't use the shared Companion style and the pre-commit hook has nothing to run

- **Source:** 🤖 validate-template (PKG-FIELD, PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json)

**What goes wrong:** `yarn format` formats the code with Prettier's built-in defaults instead of the shared Companion style the template points to, and once the pre-commit hook from [C2](#c2-the-templates-lint-config-pre-commit-hook-prettier-ignore-list-and-build-tsconfig-are-missing) is added it has no lint-staged rules to run.

**Why it happens:** `package.json` has neither the template's `prettier` field nor its `lint-staged` section.

**Evidence:**

```text
PKG-FIELD      package.json: Missing required field 'prettier' (present in template)
PKG-LINTSTAGED package.json: Missing 'lint-staged' section (present in template)
```

**Fix:** Add both blocks from the template's `package.json`:

```json
"prettier": "@companion-module/tools/.prettierrc.json",
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

### H1: The Bitfocus module checks are skipped whenever the repository is private

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:10-12`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/.github/workflows/companion-module-checks.yaml#L10-L12)

**What goes wrong:** Users see no difference, and the public bitfocus repository still runs the checks. But the workflow no longer matches the template: it skips the Bitfocus module checks on any private copy of the repository. Anyone comparing the module with the template has to work out why this workflow is different.

**Why it happens:** An extra `&& !github.event.repository.private` condition, with a comment explaining it, was added to the template's `if:` guard.

**Evidence:**

```diff
-    if: ${{ !contains(github.repository, 'companion-module-template-') }}
+    # The shared workflow grants its job only packages: read, so checkout cannot read a private
+    # repository. Run it on the public bitfocus repository; private copies rely on Node CI.
+    if: ${{ !contains(github.repository, 'companion-module-template-') && !github.event.repository.private }}
```

**Confirm by:** diff [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/.github/workflows/companion-module-checks.yaml#L10-L12) against the template's copy.

**Fix:** Use the template's `if:` line and drop the two comment lines. If a private development copy needs the extra condition, keep it in that copy only.

### H2: CI runs a custom test job instead of the template's lint job, so lint never runs in CI

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:11-43`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/.github/workflows/node.yaml#L11-L43)

**What goes wrong:** Every push runs a type check and the tests, but never `yarn lint`, so lint problems are never caught in CI. The workflow also no longer matches the template, which makes CI failures harder to compare with other modules.

**Why it happens:** The template's `lint` job (install, `yarn build`, `yarn lint`) was replaced by a custom `test` job that adds `persist-credentials: false` and runs `yarn check` and `yarn test`. That job is not the template's commented-out optional `test` job either, and the template-repository preparation step was dropped.

**Evidence:**

```yaml
# .github/workflows/node.yaml:11-20 and 34-41 (module)
jobs:
  test:
    name: Build and test
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      ...
      - name: Check types
        run: |
          yarn check
      ...
      - name: Build and test
        run: |
          yarn test
```

```yaml
# companion-module-template-ts-v2.0.4/.github/workflows/node.yaml:11-13 and 41-48 (template)
jobs:
  lint:
    name: Lint
      ...
      - name: Build and check types
        run: |
          yarn build
      ...
      - name: Run lint
        run: |
          yarn lint
```

**Confirm by:** diff [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/.github/workflows/node.yaml#L11-L43) against the template's `.github/workflows/node.yaml`.

**Fix:** Restore the template's `lint` job unchanged. To run the tests in CI as well, uncomment the template's optional `test` job (it runs `yarn test`) next to it, instead of replacing the lint job.

### H3: yarn lint fails because the module has no lint script

- **Source:** 🤖 validate-template (LINT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:18-24`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L18-L24)

**What goes wrong:** Running `yarn lint` in a clean checkout stops at once, so the code has never been through the template's ESLint rules and anything they would catch is still in it.

**Why it happens:** The module has no `lint` script ([C3](#c3-five-template-scripts-are-missing-including-lint-and-dev)) and no `eslint.config.mjs` ([C2](#c2-the-templates-lint-config-pre-commit-hook-prettier-ignore-list-and-build-tsconfig-are-missing)). `yarn install --immutable` and `yarn package` both succeeded.

**Evidence:**

```text
$ yarn lint
Usage Error: Couldn't find a script named "lint".
```

**Confirm by:** run `yarn lint` in a clean checkout of v1.0.1.

**Fix:** Fix C2–C4, then run `yarn lint` and fix whatever it reports.

### H4: Config, upgrade scripts, actions, feedbacks, variables and presets all live in one 1,298-line main.ts

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:88-103`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L88-L103), [`src/main.ts:172-204`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L172-L204), [`src/main.ts:436-857`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L436-L857), [`src/main.ts:932-1297`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L932-L1297)

**What goes wrong:** Users see no difference. Maintainers and reviewers do: the API 2.0 TypeScript template keeps the config fields, upgrade scripts, actions, feedbacks, variables and presets in their own files, but this module puts all of them into `src/main.ts`. Anyone used to the template has to dig through 1,298 lines to find, for example, the upgrade script or the "Status: show a row with its colors" feedback, which makes the module harder to troubleshoot and maintain.

**Why it happens:** The module was not built from the template's file layout. Its other source files (`chat.ts`, `network-control.ts`, `protocol.ts`, `status.ts`) only hold protocol and helper code; every Companion definition is written in `main.ts`.

**Evidence:**

```text
$ ls src/   (module at v1.0.1)
chat.ts  main.ts  network-control.ts  protocol.ts  status.ts      (main.ts = 1298 lines)

$ ls companion-module-template-ts-v2.0.4/src/
actions.ts  config.ts  feedbacks.ts  main.ts  presets.ts  upgrades.ts  variables.ts
```

```ts
// src/main.ts:88
export const UpgradeScripts: CompanionStaticUpgradeScript<Config, Secrets>[] = [
// src/main.ts:172
  getConfigFields(): SomeCompanionConfigField[] {
// src/main.ts:454
    this.setActionDefinitions({
// src/main.ts:730
    this.setFeedbackDefinitions({
// src/main.ts:855-856
    this.setVariableDefinitions(variables);
    this.presets();
// src/main.ts:932
  private presets(): void {
// src/main.ts:1293
    this.setPresetDefinitions(
```

```ts
// companion-module-template-ts-v2.0.4/src/main.ts:2-7
import { GetConfigFields, type ModuleConfig } from './config.js'
import { UpdateVariableDefinitions, type VariablesSchema } from './variables.js'
import { UpgradeScripts } from './upgrades.js'
import { UpdateActions, type ActionsSchema } from './actions.js'
import { UpdateFeedbacks, type FeedbacksSchema } from './feedbacks.js'
import { UpdatePresets } from './presets.js'
```

**Confirm by:** run `ls src/` in the module at v1.0.1 (no `config.ts`, `upgrades.ts`, `actions.ts`, `feedbacks.ts`, `variables.ts` or `presets.ts`), then open [`src/main.ts:88`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L88), [`src/main.ts:454`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L454) and [`src/main.ts:1293`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L1293).

**Fix:** Split `main.ts` the way the template does, one file per kind of definition, each exporting a function that takes the instance (for example `UpdateActions(self)`), called from `definitions()`:

- `src/upgrades.ts`: `UpgradeScripts` (keep `export { UpgradeScripts } from './upgrades.js'` in `main.ts`)
- `src/config.ts`: `getConfigFields()` and the `Config` / `Secrets` types
- `src/actions.ts`: `transportAction` and the action definitions
- `src/feedbacks.ts`: the feedback definitions
- `src/variables.ts`: the variable definitions and the values `publishState()` builds
- `src/presets.ts`: `presets()`

### H5: yarn build, yarn package and yarn format run different commands from the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:18-24`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L18-L24)

**What goes wrong:** Users see no difference. Maintainers do:

- `yarn build` never clears `dist/`, so a JS file left behind by a renamed or deleted source file stays in the build.
- `yarn package` hard-codes the version in the output name (`pkg/saccani-live-studio-1.0.1`). If the script isn't edited at the next bump, a 1.0.2 build is still written as `saccani-live-studio-1.0.1.tgz`.
- `yarn package` also runs the type check, the whole test suite and an extra test against the packaged entry point, which the template's packaging step doesn't do. If the Bitfocus build runs `yarn package`, those tests run there too ([A3](#-assumptions-to-confirm)).
- `yarn format` formats only the folders it lists, not the whole repository as `prettier -w .` does.

**Why it happens:** The scripts were written for the module instead of copied from the template. The validator reports the missing template scripts ([C3](#c3-five-template-scripts-are-missing-including-lint-and-dev)) but doesn't compare the commands of the scripts that exist. Without `--output`, `companion-module-build` names the package from the manifest's version, so passing `--output pkg/saccani-live-studio-1.0.1` really does freeze the name at 1.0.1.

**Evidence:**

```json
// package.json:18-24 (module at v1.0.1)
  "scripts": {
    "build": "tsc -p tsconfig.json",
    "check": "tsc -p tsconfig.json --noEmit",
    "test": "yarn build && node --experimental-strip-types --test tests/*.test.ts",
    "package": "yarn check && yarn test && companion-module-build --output pkg/saccani-live-studio-1.0.1 && SACCANI_MODULE_ENTRY=../pkg/saccani-live-studio/main.js node --experimental-strip-types --test tests/module.test.ts",
    "format": "prettier --write src tests companion package.json tsconfig.json README.md"
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

```js
// node_modules/@companion-module/tools/dist/scripts/lib/build-util.js:190-195
    let tgzFile = toSanitizedDirname(`${manifestJson.id}-${manifestJson.version}`);
    if (typeof argv['output'] === 'string') {
        // -o flag, to allow legacy behaviour creating pkg.tgz output
        tgzFile = argv['output'];
    }
    tgzFile += '.tgz';
```

**Confirm by:** compare lines 19, 22 and 23 of [`package.json`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L18-L24) with lines 8-10 of the template's `package.json`: `build` has no `rimraf dist`, `package` passes `--output pkg/saccani-live-studio-1.0.1` and runs extra tests, and `format` lists folders where the template uses `prettier -w .`.

**Fix:** Use the template's commands. Extra scripts are fine, so keep `check` and `test`, and move the post-package check into its own script instead of chaining it into `package`:

```json
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json",
"package": "run build && companion-module-build",
"format": "prettier -w .",
"test:package": "SACCANI_MODULE_ENTRY=../pkg/saccani-live-studio/main.js node --experimental-strip-types --test tests/module.test.ts"
```

### H6: package.json engines doesn't declare Yarn 4 like the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:14-16`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L14-L16)

**What goes wrong:** Users see no difference. For contributors, the template declares Yarn 4 in `engines`, so tooling warns when someone uses the wrong Yarn major. This module declares only Node, so that warning never appears, and its `package.json` differs from every other API 2.0 TypeScript module.

**Why it happens:** The template's `engines` block was only partly copied: `"yarn": "^4"` is missing. The `packageManager` field (`yarn@4.17.0`) doesn't replace it. `engines.node` already matches the template.

**Evidence:**

```json
// package.json:14-17 (module at v1.0.1)
  "engines": {
    "node": "^22.20"
  },
  "packageManager": "yarn@4.17.0",
```

```json
// companion-module-template-ts-v2.0.4/package.json:21-24
	"engines": {
		"node": "^22.20",
		"yarn": "^4"
	},
```

**Confirm by:** open [`package.json:14-16`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L14-L16). The `engines` block has no `"yarn": "^4"` line; the template has it at `package.json:23`.

**Fix:** Add `"yarn": "^4"` to `engines`, as in the template.

### H7: Dev tools are pinned to exact versions, and eslint is on a different major than the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:28-37`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L28-L37)

**What goes wrong:** Users see no difference. For maintainers, every dev tool is pinned to one exact version where the template allows patch or minor updates (`^3.1.0`, `^3.8.3`, `~6.0.3`, …), so the module drifts from the template whenever the template is updated. eslint is pinned to 10.2.0 instead of the template's `^9.39.4`, and the extra `resolutions` block that forces minimatch `^11` exists only to patch that eslint 10 dependency (commit `943f7ec`).

**Why it happens:** The dependency versions were written in a different style from the template. The Node version in `@types/node` (22.19.17) is the same as the template's; only the specifier differs (exact instead of `^`).

**Evidence:**

```json
// package.json:28-37 (module at v1.0.1)
  "devDependencies": {
    "@companion-module/tools": "3.1.0",
    "@types/node": "22.19.17",
    "eslint": "10.2.0",
    "prettier": "3.8.3",
    "typescript": "6.0.3"
  },
  "resolutions": {
    "minimatch": "^11.0.1"
  }
```

```json
// companion-module-template-ts-v2.0.4/package.json:28-38
	"devDependencies": {
		"@companion-module/tools": "^3.1.0",
		"@types/node": "^22.19.17",
		"eslint": "^9.39.4",
		"husky": "^9.1.7",
		"lint-staged": "^16.4.0",
		"prettier": "^3.8.3",
		"rimraf": "^6.1.3",
		"typescript": "~6.0.3",
		"typescript-eslint": "^8.59.0"
	},
```

**Confirm by:** compare [`package.json:28-37`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/package.json#L28-L37) with the template's `package.json:28-38`: every devDependency is exact where the template uses `^` or `~`, eslint is 10.2.0 where the template has `^9.39.4`, and the module adds a `resolutions` block the template doesn't have.

**Fix:** Write the devDependencies as the template does, run `yarn install`, and drop the minimatch `resolutions` block if `yarn npm audit` no longer needs it. `@companion-module/base` `2.0.4` (exact) already matches the template, and the missing tools are covered in [C4](#c4-the-templates-husky-lint-staged-rimraf-and-typescript-eslint-dev-tools-are-missing).

```json
"@companion-module/tools": "^3.1.0",
"@types/node": "^22.19.17",
"eslint": "^9.39.4",
"prettier": "^3.8.3",
"typescript": "~6.0.3"
```

## 🟡 Medium

### M1: Presets offer Play, Pause, Stop, Restart and a jog dial for channels that can't play media

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:940-1064`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L940-L1064)

**What goes wrong:** Take a user whose app has channel 4 set to a Channel source (it shows another channel). Under Presets → Saccani Live Studio → Channel 4 they see "Channel 4 Play / Resume", "Channel 4 Pause", "Channel 4 Stop and return to beginning", "Channel 4 Restart and play", "Channel 4 Play / Stop toggle" and "Channel 4 Video jog dial". If they drag one onto a button and press it, nothing happens in the app: `$(<connection label>:last_error)` reads "Select a loaded video or audio tab." and the log shows a warning. Only the "enable / disable" preset in that group works. The same applies to any other channel whose source is not a video or audio file.

**Why it happens:** The preset builder loops over every channel the app reports and always adds the five transport presets, then adds a volume dial for audio channels and a jog dial for every other kind. The transport and jog commands accept only video and audio channels, and the module already knows each channel's kind (the "Channel to show" dropdown filters on it).

**Evidence:**

```ts
// src/main.ts:940-951
    for (const tab of this.snapshot.playback?.tabs ??
      [...this.knownTabs].map((id) => ({ id, sourceKind: "video" }))) {
      const ids: string[] = [],
        id = tab.id;
      for (const action of [
        "toggle",
        "play",
        "pause",
        "stop",
        "restart",
      ] as const) {
// src/main.ts:985 and 1024-1025
      if (tab.sourceKind === "audio") {
      ...
      } else {
        const key = `tab_${id}_jog`;
```

```ts
// src/protocol.ts:216-220
    if (
      !["video", "audio"].includes(tab.sourceKind) ||
      (tab.sourceKind === "audio" && status.audioControl !== true)
    )
      throw new Error("Select a loaded video or audio tab.");
```

**Fix:** Add the transport presets only for `video` and `audio` channels, and the jog dial only for `video` channels (`else if (tab.sourceKind === "video")`). Keep the "enable / disable" preset for every channel; a "Channel: choose what a Channel source shows" preset would suit `channel` channels.

## 🟢 Low

### L1: Connection status shows raw errors such as TypeError: fetch failed instead of a helpful reason

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:242`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L242), [`src/main.ts:296`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L296), [`src/network-control.ts:34`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/network-control.ts#L34), [`src/network-control.ts:92-96`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/network-control.ts#L92-L96)

**What goes wrong:** The connection status message ([A1](#-assumptions-to-confirm)) is unhelpful in three common cases, though nothing stops working:

- Saccani Live Studio is closed, or Remote Control is off: the connection goes to Connection Failure with "TypeError: fetch failed", which doesn't say that `http://127.0.0.1:8765` refused the connection, so a closed app looks the same as a wrong address.
- The user types `127.0.0.1:8765` (without `http://`) in "App API URL": the status shows "TypeError: Invalid URL" instead of the module's own hint `Enter the app API base URL, for example http://127.0.0.1:8765.`
- The URL points at another web server that answers with an HTML 404 page: the status shows a JSON `SyntaxError` ("Unexpected token '<'…") instead of "HTTP 404".

**Why it happens:** The status is set from `String(error)`. Node's `fetch` reports a refused or unreachable connection as a generic `TypeError('fetch failed')` and keeps the real reason (`ECONNREFUSED`, `EHOSTUNREACH`) in `error.cause`, which never reaches the status. The `NetworkControl` constructor calls `new URL()` before its friendly URL check, so a URL without a scheme throws the raw error first. The HTTP helper parses the body as JSON before it checks the HTTP status.

**Fix:** Build the status from `error.message`, and for a fetch error add `error.cause?.code`, for example `Cannot reach Saccani Live Studio at http://127.0.0.1:8765 (ECONNREFUSED): open the app and turn on Settings… → Remote Control`. Wrap `new URL(connection.url)` in try/catch and throw the existing "Enter the app API base URL…" message. In the HTTP helper, read the body as text and only parse it as JSON when it is JSON, falling back to `HTTP ${response.status}`.

### L2: Progress and seconds variables show long unrounded decimals on buttons

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:890-893`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L890-L893)

**What goes wrong:** A user puts `$(studio:tab_1_progress)` ("Progress percent") on a button. During playback the button shows values like "42.857142857142854" instead of "43". The "position", "duration" and "remaining" seconds variables (`tab_1_position_seconds` and so on) show the same kind of long decimals, for example "7.654999999".

**Why it happens:** The variables are set straight from the app's fractional positions and from the percentage calculation, and none of them is rounded.

**Fix:** Round the percent (for example `Math.round(...)`, or one decimal with `Math.round(x * 10) / 10`), and round the seconds variables to a fixed precision such as milliseconds, or to whole seconds if they're meant for display.

### L3: Every variable and feedback is re-sent four times a second, even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:299-303`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L299-L303), [`src/main.ts:868-931`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L868-L931)

**What goes wrong:** Nothing visibly breaks. With the app open and idle, the module still sends Companion the full set of variables (about 60–100 values with three channels, chat and Status) and asks it to re-check every feedback on every button that uses this connection, four times a second ([A2](#-assumptions-to-confirm)). On a busy show page this adds steady CPU and IPC load. Blinking Status rows are driven by the same poll, so the blink can look uneven: the poll interval isn't locked to the 250 ms blink phase.

**Why it happens:** The poll runs every 250 ms, and each pass publishes every variable value and then re-checks all feedbacks, without comparing the new state with the previous one.

**Fix:** Keep the previous values and send only those that changed, and re-check only the feedbacks whose inputs changed (`checkFeedbacks('playing', …)` instead of `checkAllFeedbacks()`). If Status rows need to blink, re-check `status_row` and `status_alert` on their own steady 250 ms timer only while a blinking, uncleared alert exists, and clear that timer in `destroy()` and when the configuration changes.

### L4: Redundant casts and Number() conversions on already-typed action options

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:666-671`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L666-L671)

**What goes wrong:** Users see no difference; this is code quality only. The "Channel: enable / disable" action casts its mode option to the type the module's schema already gives it, and most actions wrap the channel number (already a `number`) in `Number(...)`. That hides the fact that the options are already typed, and the compiler would not catch a future schema change.

**Why it happens:** In API 2.0, action options are typed from the module's schema (`channel_enable: { options: { tab: number; mode: "toggle" | "on" | "off" } }` at [`src/main.ts:59`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L59)), so the cast and the conversions do nothing.

**Evidence:**

```ts
// src/main.ts:666-671
        callback: (event) =>
          this.execute((client) =>
            client.channelEnable(
              Number(event.options.tab),
              event.options.mode as "toggle" | "on" | "off",
            ),
```

**Fix:** Drop the `as "toggle" | "on" | "off"` cast and pass `event.options.mode` directly. Likewise use `event.options.tab`, `.channel` and `.row` without `Number(...)` where the schema already declares them as numbers.

### L5: Relative imports mix .ts and .js extensions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/protocol.ts:1-14`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/protocol.ts#L1-L14)

**What goes wrong:** Users see no difference: the TypeScript compiler rewrites the `.ts` imports to `.js` in `dist/`, and the module builds and loads. For maintainers, `main.ts` imports `./protocol.js` while `protocol.ts` imports `./network-control.ts`, `./chat.ts` and `./status.ts`. The build only works because of a tsconfig option the template doesn't set (`rewriteRelativeImportExtensions`), so moving to the template's `tsconfig.build.json` ([C2](#c2-the-templates-lint-config-pre-commit-hook-prettier-ignore-list-and-build-tsconfig-are-missing)) without that option breaks the build.

**Why it happens:** The tests load `src/protocol.ts` directly with `node --experimental-strip-types`, and Node needs real `.ts` extensions for that. The template, and the API 2.0 rules, expect relative imports to end in `.js`.

**Evidence:**

```ts
// src/protocol.ts:1-5
import {
  NetworkControl,
  type APIConnection,
  type APIOperation,
} from "./network-control.ts";
// src/protocol.ts:14
import { validStatusBoard, statusTab, type StatusBoard } from "./status.ts";
// src/main.ts:18
} from "./protocol.js";
```

**Fix:** Use `.js` for every relative import in `src/`, as the template does, and run the protocol and network tests against the built `dist/` files (the `test` script already builds first). Alternatively keep `.ts` everywhere, but don't mix the two styles.

## 💡 Nice to Have

### N1: Error messages still say "tab" where the rest of the module says "channel"

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/protocol.ts:208`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/protocol.ts#L208), [`src/protocol.ts:220`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/protocol.ts#L220), [`src/protocol.ts:496-530`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/protocol.ts#L496-L530)

**What goes wrong:** Every action, feedback, preset and variable name says "Channel" (for example "Channel 4 Play / Resume"), but the messages users see in `$(<label>:last_error)` and the Companion log still say "tab": "Select a loaded video or audio tab.", "Choose Chat as the source in tab 3 of the app.", "Check the audio destination in Replay tab 2.". The app now calls these channels, so users read two names for the same thing.

**Why it happens:** Commit `f02ba5f` renamed tabs to channels in the labels and presets but not in the error strings.

**Fix:** Replace "tab" with "channel" in the user-facing error strings in `src/protocol.ts` (lines 208, 220, 272, 297, 324, 496, 505, 518-519, 524, 527 and 530), [`src/chat.ts:81-84`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/chat.ts#L81-L84), [`src/status.ts:88-91`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/status.ts#L88-L91) and [`src/main.ts:629`](https://github.com/bitfocus/companion-module-saccani-live-studio/blob/bccc2a78b10dd504232250ef2eba02969058f63d/src/main.ts#L629). Internal ids such as the `tab` option and the `tab_<n>_…` variables can stay.

## 📝 Additional Notes

- `tsconfig.json` differs from the template: `extends` is `@companion-module/tools/tsconfig/node22/recommended-esm.json` where the template has `./tsconfig.build.json` (the module has no `tsconfig.build.json` and builds with `tsc -p tsconfig.json`). It builds cleanly; no change required beyond [C2](#c2-the-templates-lint-config-pre-commit-hook-prettier-ignore-list-and-build-tsconfig-are-missing).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows the message passed to `updateStatus()` next to the connection's status in the Connections list, so users see "TypeError: fetch failed" as written | In `@companion-module/base` 2.0.4, `updateStatus(status, message)` only forwards to the host; how Companion renders the message was not checked | [L1](#l1-connection-status-shows-raw-errors-such-as-typeerror-fetch-failed-instead-of-a-helpful-reason) |
| A2 | `checkAllFeedbacks()` makes Companion re-run every feedback of the connection, and the full `setVariableValues` payload is sent over IPC each time (the host may skip unchanged values, but the module-side work still happens) | `@companion-module/base` 2.0.4 forwards both calls straight to the host (`dist/module-api/base.js:75-90`); the host code was not checked | [L3](#l3-every-variable-and-feedback-is-re-sent-four-times-a-second-even-when-nothing-changed) |
| A3 | The Bitfocus build pipeline runs `yarn package`, so the module's custom script also runs the type check, the full test suite and the post-package test there | Unconfirmed Bitfocus build-server behaviour; the finding stands on the template difference alone, this is only extra risk | [H5](#h5-yarn-build-yarn-package-and-yarn-format-run-different-commands-from-the-template) |
