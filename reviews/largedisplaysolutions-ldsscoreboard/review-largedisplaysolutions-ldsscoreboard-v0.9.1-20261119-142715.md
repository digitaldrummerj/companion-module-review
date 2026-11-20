# Review: largedisplaysolutions-ldsscoreboard v0.9.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-largedisplaysolutions-ldsscoreboard](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard) |
| **Scope** | `tag` |
| **Version** | v0.9.1 ([`bec89a6`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346)) |
| **Release** | New module — never published |
| **API** | 1 (base 1.11.0, package.json range) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-19 |

This is the module's first release. There is no published version to compare it with, so the whole module was reviewed, and every finding is 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: The release can't be built because yarn package has no script to run](#c1-the-release-cant-be-built-because-yarn-package-has-no-script-to-run)
- [ ] [C2: package.json has none of the template's scripts](#c2-packagejson-has-none-of-the-templates-scripts)
- [ ] [C3: package.json has no devDependencies, so TypeScript and the Companion build tools are missing](#c3-packagejson-has-no-devdependencies-so-typescript-and-the-companion-build-tools-are-missing)
- [ ] [C4: package.json is missing the engines, packageManager, prettier and scripts fields](#c4-packagejson-is-missing-the-engines-packagemanager-prettier-and-scripts-fields)
- [ ] [C5: package.json has no lint-staged section](#c5-packagejson-has-no-lint-staged-section)
- [ ] [C6: No yarn.lock is committed, so every build picks its own dependency versions](#c6-no-yarnlock-is-committed-so-every-build-picks-its-own-dependency-versions)
- [ ] [C7: The template's .yarnrc.yml is missing](#c7-the-templates-yarnrcyml-is-missing)
- [ ] [C8: The template's eslint.config.mjs is missing](#c8-the-templates-eslintconfigmjs-is-missing)
- [ ] [C9: The template's .husky/pre-commit hook is missing](#c9-the-templates-huskypre-commit-hook-is-missing)
- [ ] [C10: The template's .prettierignore is missing](#c10-the-templates-prettierignore-is-missing)
- [ ] [C11: The LICENSE file is missing](#c11-the-license-file-is-missing)
- [ ] [C12: .gitattributes doesn't force LF line endings](#c12-gitattributes-doesnt-force-lf-line-endings)
- [ ] [C13: .gitignore is missing seven of the template's entries](#c13-gitignore-is-missing-seven-of-the-templates-entries)
- [ ] [C14: Move to @companion-module/base 1.14, the template's version](#c14-move-to-companion-modulebase-114-the-templates-version)
- [ ] [H1: Scores, team names, counters and labels never update with the default connection settings](#h1-scores-team-names-counters-and-labels-never-update-with-the-default-connection-settings)
- [ ] [H2: The module can't be built even once the scripts are added, because TypeScript stops with more than 100 errors](#h2-the-module-cant-be-built-even-once-the-scripts-are-added-because-typescript-stops-with-more-than-100-errors)
- [ ] [H3: Action, feedback, variable and preset names, option labels, comments and README.md are in French](#h3-action-feedback-variable-and-preset-names-option-labels-comments-and-readmemd-are-in-french)
- [ ] [H4: The template's src/upgrades.ts is missing, so there is no place for future upgrade scripts](#h4-the-templates-srcupgradests-is-missing-so-there-is-no-place-for-future-upgrade-scripts)
- [ ] [H5: Lint can't run because package.json has no lint script](#h5-lint-cant-run-because-packagejson-has-no-lint-script)

### Non-blocking

- [ ] [M1: The connection stays red after the scoreboard PC is reachable again](#m1-the-connection-stays-red-after-the-scoreboard-pc-is-reachable-again)
- [ ] [M2: Neither feedback ever changes a button, because both always return false](#m2-neither-feedback-ever-changes-a-button-because-both-always-return-false)
- [ ] [M3: The custom button action always shows an empty list, so it can't be set up by hand](#m3-the-custom-button-action-always-shows-an-empty-list-so-it-cant-be-set-up-by-hand)
- [ ] [M4: A mistyped IP address leaves the connection green while nothing works](#m4-a-mistyped-ip-address-leaves-the-connection-green-while-nothing-works)
- [ ] [M5: The template's module-checks CI workflow is missing](#m5-the-templates-module-checks-ci-workflow-is-missing)
- [ ] [M6: The template's Node CI workflow is missing](#m6-the-templates-node-ci-workflow-is-missing)
- [ ] [L1: Counters and timers with a space or accent in their name don't refresh after Set value or Reset](#l1-counters-and-timers-with-a-space-or-accent-in-their-name-dont-refresh-after-set-value-or-reset)
- [ ] [L2: Players 15 to 19 are polled and get presets, but their variables are never defined](#l2-players-15-to-19-are-polled-and-get-presets-but-their-variables-are-never-defined)
- [ ] [L3: One failed list refresh empties the counter, timer and label variables, dropdowns and presets](#l3-one-failed-list-refresh-empties-the-counter-timer-and-label-variables-dropdowns-and-presets)
- [ ] [L4: Every HTTP request is logged at info level, flooding the connection log](#l4-every-http-request-is-logged-at-info-level-flooding-the-connection-log)
- [ ] [L5: Display presets hard-code the connection label LDSscoreboard](#l5-display-presets-hard-code-the-connection-label-ldsscoreboard)
- [ ] [N1: Unused code in pollValuesStaggered, and every definition is re-sent on each refresh](#n1-unused-code-in-pollvaluesstaggered-and-every-definition-is-re-sent-on-each-refresh)
- [ ] [NR1: Add feedbacks before 1.0.0, so buttons can show the scoreboard's state](#nr1-add-feedbacks-before-100-so-buttons-can-show-the-scoreboards-state)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The release can't be built because yarn package has no script to run

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json:1-11`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json#L1-L11)

**What goes wrong:** The Bitfocus build packages a module with `yarn package`. For this release that command fails immediately, so no installable package can be produced and users can't install v0.9.1. The manifest's entrypoint (`../dist/main.js`) is build output. It isn't committed, and nothing in the repository can produce it: package.json has no scripts and no `typescript` dependency.

**Evidence:**

```text
yarn package → error Command "package" not found.
```

**Fix:** add the template's scripts ([C2](#c2-packagejson-has-none-of-the-templates-scripts)) and devDependencies ([C3](#c3-packagejson-has-no-devdependencies-so-typescript-and-the-companion-build-tools-are-missing)), fix the TypeScript errors ([H2](#h2-the-module-cant-be-built-even-once-the-scripts-are-added-because-typescript-stops-with-more-than-100-errors)), and confirm `yarn package` completes in a clean checkout.

### C2: package.json has none of the template's scripts

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json)

**What goes wrong:** Nobody can build, package, lint or format the module with the standard commands, including the Bitfocus build.

**Evidence:**

```text
Missing required script 'postinstall'
Missing required script 'format'
Missing required script 'package'
Missing required script 'build'
Missing required script 'build:main'
Missing required script 'dev'
Missing required script 'lint:raw'
Missing required script 'lint'
```

**Fix:** add the template's `scripts` block.

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
},
```

### C3: package.json has no devDependencies, so TypeScript and the Companion build tools are missing

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json)

**What goes wrong:** The tools that compile the TypeScript source (`typescript`), package the module (`@companion-module/tools`), and lint and format it are not installed, so none of those steps can run.

**Evidence:**

```text
Missing devDependency '@companion-module/tools' (present in template)
Missing devDependency '@types/node' (present in template)
Missing devDependency 'eslint' (present in template)
Missing devDependency 'husky' (present in template)
Missing devDependency 'lint-staged' (present in template)
Missing devDependency 'prettier' (present in template)
Missing devDependency 'rimraf' (present in template)
Missing devDependency 'typescript' (present in template)
Missing devDependency 'typescript-eslint' (present in template)
```

**Fix:** add the template's `devDependencies`.

```json
"devDependencies": {
	"@companion-module/tools": "^2.6.1",
	"@types/node": "^22.19.3",
	"eslint": "^9.39.2",
	"husky": "^9.1.7",
	"lint-staged": "^16.2.7",
	"prettier": "^3.7.4",
	"rimraf": "^6.1.2",
	"typescript": "~5.9.3",
	"typescript-eslint": "^8.51.0"
},
```

### C4: package.json is missing the engines, packageManager, prettier and scripts fields

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json)

**What goes wrong:** Without `packageManager`, anyone building the module gets whatever Yarn they have installed globally. The review build ran under Yarn 1.22.22 and wrote a Yarn 1 lockfile, not the Yarn 4 setup the template uses. Without `engines` the supported Node and Yarn versions aren't stated, and without `prettier` the shared formatting rules aren't applied.

**Evidence:**

```text
Missing required field 'engines' (present in template)
Missing required field 'prettier' (present in template)
Missing required field 'packageManager' (present in template)
Missing required field 'scripts' (present in template)
```

**Fix:** add the template's fields (the `scripts` block is in [C2](#c2-packagejson-has-none-of-the-templates-scripts)).

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
},
"prettier": "@companion-module/tools/.prettierrc.json",
"packageManager": "yarn@4.12.0"
```

### C5: package.json has no lint-staged section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json)

**What goes wrong:** The template's pre-commit hook runs lint-staged, which formats and lints the changed files before each commit. Without this section it has nothing to run.

**Evidence:**

```text
Missing 'lint-staged' section (present in template)
```

**Fix:** add the template's section.

```json
"lint-staged": {
	"*.{css,json,md,scss}": [
		"prettier --write"
	],
	"*.{ts,tsx,js,jsx}": [
		"yarn lint:raw --fix"
	]
},
```

### C6: No yarn.lock is committed, so every build picks its own dependency versions

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `yarn.lock` (missing)

**What goes wrong:** Without a lockfile, each build resolves `@companion-module/base ~1.11.0` and the tools to whatever versions are newest that day. The package users install can differ from the one the maintainer tested.

**Evidence:**

```text
yarn.lock: Required file is missing
```

**Fix:** after adding `packageManager` ([C4](#c4-packagejson-is-missing-the-engines-packagemanager-prettier-and-scripts-fields)) and `.yarnrc.yml` ([C7](#c7-the-templates-yarnrcyml-is-missing)), run `yarn install` with Yarn 4 and commit the resulting `yarn.lock`.

### C7: The template's .yarnrc.yml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Yarn 4 doesn't get the template's settings, so installs don't use the `node_modules` layout that Companion module builds expect, and don't get the template's install safeguards.

**Evidence:**

```text
.yarnrc.yml: Required file is missing (tracked by the template)
```

**Fix:** add `.yarnrc.yml` with the template's content.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

### C8: The template's eslint.config.mjs is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `eslint.config.mjs` (missing)

**What goes wrong:** `yarn lint` has no ESLint configuration, so the module can't be checked with the shared Companion lint rules.

**Evidence:**

```text
eslint.config.mjs: Required file is missing (tracked by the template)
```

**Fix:** add the template's file.

```js
import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'

export default generateEslintConfig({
	enableTypescript: true,
})
```

### C9: The template's .husky/pre-commit hook is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Commits aren't formatted or linted before they are made.

**Evidence:**

```text
.husky/pre-commit: Required file is missing (tracked by the template)
```

**Fix:** add `.husky/pre-commit` containing the single line `lint-staged`, as in the template.

### C10: The template's .prettierignore is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore` (missing)

**What goes wrong:** `yarn format` would rewrite `package.json` and `LICENSE.md`, which the template keeps out of formatting.

**Evidence:**

```text
.prettierignore: Required file is missing (tracked by the template)
```

**Fix:** add `.prettierignore` with the template's content.

```text
package.json
/LICENSE.md
```

### C11: The LICENSE file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `LICENSE` (missing)

**What goes wrong:** package.json and the manifest declare the module MIT-licensed, but no licence text ships with it.

**Evidence:**

```text
LICENSE: Required file is missing
```

**Fix:** add the template's MIT `LICENSE`. The copyright line is yours to fill in.

### C12: .gitattributes doesn't force LF line endings

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitattributes:2`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/.gitattributes#L2)

**What goes wrong:** On a Windows checkout the files get CRLF line endings, which then show up as formatting and lint differences.

**Evidence:**

```text
Differs from template (line 1: found '* text=auto', template '* text=auto eol=lf')
```

**Fix:** use the template's rule.

```text
* text=auto eol=lf
```

### C13: .gitignore is missing seven of the template's entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/.gitignore)

**What goes wrong:** Build output (`/pkg`), Yarn's cache (`/.yarn`), debug logs, editor settings and an npm lockfile can be committed by accident.

**Evidence:**

```text
Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode
```

**Fix:** add the template's entries. Your extra entries (such as `.DS_Store`) can stay.

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

### C14: Move to @companion-module/base 1.14, the template's version

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:9`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json#L9)

**What goes wrong:** The module doesn't match the API 1.x template it is built from. It targets API 1.11 (Companion 3.5 and later), while the template is on `~1.14.1`, which adds option descriptions, automatic variable parsing in text fields (1.13), `isVisibleExpression`, value feedbacks, secret-text fields and the Node permission model. This first release would ship on an API version the template has already moved past.

**Why it happens:** The dependency is `~1.11.0`.

**Evidence:**

```json
// package.json:8-10
  "dependencies": {
    "@companion-module/base": "~1.11.0"
  }
```

```json
// companion-module-template-ts-v1/package.json:26
    "@companion-module/base": "~1.14.1"
```

**Confirm by:** compare [`package.json:9`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json#L9) with the API 1.x TypeScript template's `dependencies`.

**Fix:** change to `"@companion-module/base": "~1.14.1"` in this release, together with the template's devDependencies, and re-test. The module only uses `node:http`, so it needs no `runtime.permissions`. Later, consider moving to API 2.x.

## 🟠 High

### H1: Scores, team names, counters and labels never update with the default connection settings

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:278-299`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L278-L299), [`src/main.ts:312-314`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L312-L314)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** A user adds the connection with the default settings, where 'Poll roster / player data' is ticked. None of the scoreboard variables ever fill in: `$(LDSscoreboard:local_team_score)`, `guest_team_score`, `local_team_name`, `guest_team_name`, `local_team_fauls`, `guest_team_fauls`, `players_local`, `players_guest` and every `counter_*`, `label_*`, `vector_*` and `player_*` variable stay blank for the whole session. The 'Score local', 'Score visiteur', 'Fautes locale' and 'Nom équipe locale' presets show only their fixed text ("LOCAL", "GUEST", …). Pressing 'Compteurs : Décrémenter', 'Timers : Démarrer', 'Labels : Définir', 'Reset scoreboard' or a 'Roster : …' action refreshes nothing, although each of them asks for a full refresh. Because `players_local` is never set, the 'Roster Local' and 'Roster Guest' preset categories never appear. Nothing is logged and the connection stays green. Only the timer variables (polled every second) and the values refreshed straight after 'Compteurs : Incrémenter' ever update. Unticking 'Poll roster / player data' makes the team and score variables work. The reviewers reproduced this against a mock LDSscoreboard HTTP server: with the option ticked the poll set 0 variables, and with it unticked it set 19.

**Why it happens:** The routine that reads the scoreboard (`pollValues()`) uses the two player counts from `results` (lines 280-281) before `results` is created further down the same block (line 299). JavaScript doesn't allow reading a `const` before its declaration has run, so every poll stops there with "Cannot access 'results' before initialization". An empty `catch` hides the error, so the step that writes the variables (`setVariableValues()`) is never reached. Even without the error, the counts couldn't be known at that point, because their requests haven't been awaited yet.

**Evidence:**

```ts
// src/main.ts:236-238
    async pollValues() {
        try {
            const requests = [
```

```ts
// src/main.ts:278-281
            // Player stats (only real count if roster polling enabled)
            if (this.config.pollRoster !== false) {
                const localCount = parseInt(extractValue(results?.[6]) || '0', 10) || 0;
                const guestCount = parseInt(extractValue(results?.[7]) || '0', 10) || 0;
```

```ts
// src/main.ts:299-314
            const results = await Promise.all(requests);
            const values = {};
            keys.forEach((key, i) => {
                const val = extractValue(results[i]);
                if (val !== null && val !== undefined && val !== '') {
                    values[key] = val;
                }
            });
            this.log('info', `Player0 score: ${values['player_local_0_score'] ?? 'empty'}`);
            if (Object.keys(values).length > 0) {
                this.setVariableValues(values);
            }
        }
        catch {
            // silent
        }
```

```ts
// src/config.ts:35-41
        {
            type: 'checkbox',
            id: 'pollRoster',
            label: 'Poll roster / player data',
            width: 6,
            default: true,
        },
```

```json
// tsconfig.json:6
    "target": "ES2022",
```

```text
node run of the same structure:
pollRoster: true      -> caught: ReferenceError Cannot access 'results' before initialization
pollRoster: undefined -> caught: ReferenceError Cannot access 'results' before initialization
pollRoster: false     -> ok
tsc: src/main.ts(280,58): error TS2448: Block-scoped variable 'results' used before its declaration.
```

**Confirm by:** open [`src/main.ts:278-299`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L278-L299): `results` is read at line 280, inside the same `try` block where `const results` is only declared at line 299, and the empty `catch` at lines 312-314 hides the error. 'Poll roster / player data' defaults to ticked at [`src/config.ts:40`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/config.ts#L40).

**Fix:** wait for the two player-count replies before building the per-player requests, keep the final `Promise.all` where it is, and log errors instead of discarding them.

```ts
if (this.config.pollRoster !== false) {
	const [localRaw, guestRaw] = await Promise.all([requests[6], requests[7]])
	const localCount = parseInt(extractValue(localRaw) || '0', 10) || 0
	const guestCount = parseInt(extractValue(guestRaw) || '0', 10) || 0
	// ...push the per-player requests as today...
}
const results = await Promise.all(requests)
// ...
} catch (e) {
	this.log('debug', `poll failed: ${e}`)
}
```

### H2: The module can't be built even once the scripts are added, because TypeScript stops with more than 100 errors

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:8-91`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L8-L91), [`tsconfig.json:1-14`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/tsconfig.json#L1-L14)
- **Assumption:** [A2](#-assumptions-to-confirm)

**What goes wrong:** Adding the missing scripts and devDependencies ([C2](#c2-packagejson-has-none-of-the-templates-scripts), [C3](#c3-packagejson-has-no-devdependencies-so-typescript-and-the-companion-build-tools-are-missing)) is not enough to release this module. `yarn build` and `yarn package` would still fail: compiling the source with the module's own strict `tsconfig.json` reports 135 errors and exits with code 2 (TypeScript 5.9.3, base 1.11.3, `@types/node` 22). The template's `package` script stops at the first failing step, so no package is produced.

**Why it happens:** The `.ts` files are plain JavaScript with a `.ts` extension, while the API 1.x TypeScript template is typed TypeScript. No function parameter, class field or definition has a type. The instance class extends `InstanceBase` without its config type, uses fields it never declares (`timerInterval`, `vectorData`, `vectorLengths`, `buttons`), and the action, feedback and preset builders return plain objects instead of Companion's definition types. TypeScript still writes `dist/main.js` (the tsconfig doesn't set `noEmitOnError`), but it exits with an error, and that is what stops the build.

**Evidence:**

```ts
// src/main.ts:8
function extractValue(raw) {
```

```ts
// src/main.ts:45-47
class LDSscoreboardInstance extends InstanceBase {
    config;
    pollInterval;
```

```ts
// src/main.ts:88-91
    async destroy() {
        if (this.pollInterval) clearInterval(this.pollInterval);
        if (this.timerInterval) clearInterval(this.timerInterval);
    }
```

```text
scratch copy, tsc 5.9.3 -p tsconfig.build.json (module's own tsconfig, base 1.11.3, @types/node 22)
exit=2   135 errors: 45 TS2339, 42 TS7053, 36 TS7006, 3 TS2794, 2 TS7008, 2 TS2454, 2 TS2448, 1 TS2345, 1 TS2322, 1 TS2314
src/main.ts(45,37): error TS2314: Generic type 'InstanceBase<TConfig>' requires 1 type argument(s).
src/main.ts(90,18): error TS2339: Property 'timerInterval' does not exist on type 'LDSscoreboardInstance'.
src/main.ts(280,58): error TS2448: Block-scoped variable 'results' used before its declaration.
src/main.ts(346,15): error TS2345: Argument of type 'typeof LDSscoreboardInstance' is not assignable to parameter of type 'InstanceConstructor<unknown>'.
src/actions.ts(10,28): error TS7006: Parameter 'self' implicitly has an 'any' type.
```

**Confirm by:** open [`src/main.ts:45`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L45) (`extends InstanceBase` with no `<Config>` and untyped fields) and [`src/main.ts:90`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L90) (`timerInterval` is never declared). With `typescript` and `@types/node` installed, `tsc -p tsconfig.build.json --noEmit` exits with code 2 and more than 100 strict-mode errors.

**Fix:** convert the source to typed TypeScript, following the template, until `yarn build` passes.

- [ ] `src/config.ts`: add a `ModuleConfig` interface (`host: string`, `port: number`, `refreshInterval: number`, `fastTimers: boolean`, `pollRoster: boolean`) and return `SomeCompanionConfigField[]`.
- [ ] `src/main.ts`: `class LDSscoreboardInstance extends InstanceBase<ModuleConfig>`, with every field declared and typed (`timerInterval?: NodeJS.Timeout`, `vectorData: { id: string; length: number; name: string }[]`, `vectorLengths: Record<string, number>`, `buttons: string[]`, …) and typed helper parameters.
- [ ] `src/actions.ts`, `src/feedbacks.ts`, `src/presets.ts`: return `CompanionActionDefinitions`, `CompanionFeedbackDefinitions` and `CompanionPresetDefinitions`, and type `self` as the instance class.
- [ ] Remove the unused `allKeys` and `requests` locals in `pollValuesStaggered()` (the template's tsconfig reports unused locals).

### H3: Action, feedback, variable and preset names, option labels, comments and README.md are in French

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:1-241`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/actions.ts#L1-L241), [`src/feedbacks.ts:5-20`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/feedbacks.ts#L5-L20), [`src/main.ts:128-164`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L128-L164), [`src/presets.ts:21-230`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/presets.ts#L21-L230), [`README.md:3-29`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/README.md#L3-L29)

**What goes wrong:** Companion users who don't read French see action names such as "Compteurs : Incrémenter", "Timers : Arrêter", "Roster : Avertissements +" and "Boutons : Cliquer", option labels such as "Équipe" (with the choices "Locale" and "Visiteuse"), "Index joueur", "Valeur" and "Seuil", and empty dropdowns that read "(liste vide)". The feedbacks are "Compteur > valeur" and "Timer en cours", the variables have names such as "Nom équipe locale" and "Joueur visiteur 3 avert.", the preset categories are "Compteurs", "Vecteurs", "Boutons" and "Général", and preset buttons read "FAUTES", "JOUEURS" and "AVERT". `README.md` is entirely in French, and so are several code comments, so other maintainers and people troubleshooting the module can't follow them. `companion/HELP.md` is already in English.

**Why it happens:** Every user-facing string outside `src/config.ts` was written in French. The template check only detects non-Latin scripts, so it couldn't flag French text.

**Evidence:**

```ts
// src/actions.ts:1
function dropdown(id, label, choices, fallback = '(liste vide)') {
```

```ts
// src/actions.ts:29-31
        increment_counter: {
            name: 'Compteurs : Incrémenter',
            options: [dropdown('name', 'Compteur', counters)],
```

```ts
// src/actions.ts:131-134
            name: 'Roster : Score +',
            options: [
                { type: 'dropdown', id: 'team', label: 'Équipe', choices: [{ id: 'local', label: 'Locale' }, { id: 'guest', label: 'Visiteuse' }], default: 'local' },
                { type: 'number', id: 'index', label: 'Index joueur', default: 0, min: 0, max: 30 },
```

```ts
// src/feedbacks.ts:5-6
            name: 'Compteur > valeur',
            description: 'True si un compteur est supérieur à la valeur',
```

```ts
// src/main.ts:128-129
            { variableId: 'local_team_name', name: 'Nom équipe locale' },
            { variableId: 'guest_team_name', name: 'Nom équipe visiteuse' },
```

```ts
// src/presets.ts:151-157
    // === BOUTONS PERSONNALISÉS ===
    if (Array.isArray(buttons)) {
        buttons.forEach((btn) => {
            const base = btn.replace(/[^a-zA-Z0-9]/g, '_');
            presets[`button_${base}`] = {
                category: 'Boutons',
                name: `Bouton: ${btn}`,
```

```markdown
<!-- README.md:3-5 -->
Module Bitfocus Companion complet pour **LDSscoreboard**.

## Fonctionnalités
```

**Confirm by:** open [`src/actions.ts`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/actions.ts), [`src/feedbacks.ts:5-20`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/feedbacks.ts#L5-L20), [`src/main.ts:128-164`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L128-L164), [`src/presets.ts`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/presets.ts) and [`README.md`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/README.md): the names, labels, comments and README text are in French.

**Fix:** translate every user-facing string, comment and the README into English. Keep the device's own endpoint and variable ids (such as `local_team_fauls`) unchanged.

- [ ] `src/actions.ts`: action names, option labels and choices, and the empty-list placeholder (for example "Counters: Increment", "Team" with "Home" / "Guest", "Player index", "Value", "(empty list)").
- [ ] `src/feedbacks.ts`: feedback names, descriptions and option labels.
- [ ] `src/main.ts`: variable names (for example "Home team name", "Guest player 3 cautions").
- [ ] `src/presets.ts`: categories, preset names, button text ("FOULS", "PLAYERS", "CAUTION") and comments.
- [ ] `README.md`: rewrite in English, or use the template's short README that points to `HELP.md`. Its install steps (`npm install`, `npm run build`) also don't work: the module uses Yarn, and there is no build script yet.

### H4: The template's src/upgrades.ts is missing, so there is no place for future upgrade scripts

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:346`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L346)

**What goes wrong:** Users see nothing today. But when an action or option id is renamed in a later release, the saved buttons need an upgrade script, and this module has no file for one. A missed upgrade script breaks users' saved buttons. A layout that differs from the template is also harder to maintain and troubleshoot.

**Why it happens:** The API 1.x TypeScript template keeps its upgrade scripts in `src/upgrades.ts`, which exports an `UpgradeScripts` array (empty at first) that `main.ts` passes to `runEntrypoint`. This module has no such file and passes an empty array written inline.

**Evidence:**

```ts
// src/main.ts:346
runEntrypoint(LDSscoreboardInstance, []);
```

```ts
// companion-module-template-ts-v1/src/main.ts:4
import { UpgradeScripts } from './upgrades.js'
// companion-module-template-ts-v1/src/main.ts:57
runEntrypoint(ModuleInstance, UpgradeScripts)
// companion-module-template-ts-v1/src/upgrades.ts:4
export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = [
```

```text
git ls-files src (v0.9.1): src/actions.ts src/config.ts src/feedbacks.ts src/main.ts src/presets.ts src/variables.ts
grep -rn "Upgrade" src/: no matches
```

**Confirm by:** run `git ls-files src` in the module (there is no `upgrades.ts`), then open [`src/main.ts:346`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L346) and compare it with the template's `src/upgrades.ts` and `src/main.ts:57`.

**Fix:** add `src/upgrades.ts` as in the template and pass its array to `runEntrypoint`. Exporting the instance class, as the template does, keeps the layout aligned.

```ts
// src/upgrades.ts
import type { CompanionStaticUpgradeScript } from '@companion-module/base'
import type { ModuleConfig } from './config.js'

export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = []

// src/main.ts
import { UpgradeScripts } from './upgrades.js'
// ...
runEntrypoint(LDSscoreboardInstance, UpgradeScripts)
```

### H5: Lint can't run because package.json has no lint script

- **Source:** 🤖 validate-template (LINT)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/package.json)

**What goes wrong:** The module can't be checked against the shared Companion lint rules, so problems such as the one in [H1](#h1-scores-team-names-counters-and-labels-never-update-with-the-default-connection-settings) go unnoticed.

**Evidence:**

```text
yarn lint → error Command "lint" not found.
```

**Fix:** add the scripts ([C2](#c2-packagejson-has-none-of-the-templates-scripts)), devDependencies ([C3](#c3-packagejson-has-no-devdependencies-so-typescript-and-the-companion-build-tools-are-missing)) and `eslint.config.mjs` ([C8](#c8-the-templates-eslintconfigmjs-is-missing)), then run `yarn lint` and fix what it reports.

## 🟡 Medium

### M1: The connection stays red after the scoreboard PC is reachable again

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:68-84`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L68-L84), [`src/main.ts:323-338`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L323-L338)
- **Assumption:** [A3](#-assumptions-to-confirm)

**What goes wrong:** Companion starts before LDSscoreboard is running, the scoreboard PC reboots during an event, or a single request takes longer than 3 seconds. The connection turns red with 'Connection Failure' and stays red after the scoreboard is reachable again, even though buttons and the timer variables work. It only turns green when the user opens the connection and clicks Save, so the operator can't tell a real outage from a glitch that is already over. The reviewers reproduced this: the status stayed failed after the mock device came back and a poll returned a score.

**Why it happens:** The connection is set to OK only in `init()` and `configUpdated()`, before any request has been made. Every failed request (including the 3-second timeout) sets 'Connection Failure', but a successful reply never sets OK again.

**Fix:** set the status to OK when a reply succeeds and the status isn't OK already, and start `init()` and `configUpdated()` at Connecting instead of OK.

```ts
if (code >= 200 && code < 400) {
	if (this.lastStatus !== InstanceStatus.Ok) {
		this.lastStatus = InstanceStatus.Ok
		this.updateStatus(InstanceStatus.Ok)
	}
	resolve(data.trim())
}
```

### M2: Neither feedback ever changes a button, because both always return false

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:3-23`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/feedbacks.ts#L3-L23)

**What goes wrong:** A user adds the "Compteur > valeur" feedback with counter `score_local` and threshold 5. The counter reaches 10, and the button never turns red. "Timer en cours" never turns a button green either, whether the timer runs or not. Both appear in the feedback list as working features, so users lose time debugging their buttons.

**Why it happens:** Both feedback callbacks are placeholders that return `false` without reading any counter value or timer state, and the module never asks Companion to re-check feedbacks (`checkFeedbacks`) when values change.

**Fix:** implement them from state the module already polls, or remove them until they can work. For "Compteur > valeur", offer the counters in a dropdown, compare the polled value with the threshold, and call `this.checkFeedbacks('counter_above')` after each `setVariableValues()`.

```ts
callback: (feedback) =>
	Number(self.getVariableValue(`counter_${feedback.options.name}`)) > Number(feedback.options.value),
```

### M3: The custom button action always shows an empty list, so it can't be set up by hand

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:197-204`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/actions.ts#L197-L204)

**What goes wrong:** A user adds the 'Boutons : Cliquer' action to a button by hand. Its 'Bouton' dropdown only ever offers "(liste vide)", even when LDSscoreboard has custom buttons, and pressing the button sends nothing. Only buttons made from the 'Boutons' presets work, because the preset fills in the button id itself.

**Why it happens:** The action asks the instance for `getButtonChoices()`, but the instance never defines that method. It defines choice lists for slides, counters, timers, labels and vectors only, although it does fetch and store the custom button list. The optional call quietly returns nothing, so the dropdown falls back to the empty placeholder.

**Fix:** add the missing method next to the other choice lists in `src/main.ts`, and call it without `?.` so a missing method becomes a compile error.

```ts
getButtonChoices() {
	return (this.buttons ?? []).map((b) => ({ id: b, label: b }))
}
```

### M4: A mistyped IP address leaves the connection green while nothing works

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:316-320`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L316-L320), [`src/config.ts:3-9`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/config.ts#L3-L9)

**What goes wrong:** A user types `192.168.1.50:8086` (address plus port) into 'IP Address of LDSscoreboard PC', or leaves it empty. The connection stays green and no error is logged, but no list or counter variables are defined, every action dropdown shows "(liste vide)", and pressed actions fail with an error that only shows as an action-execution error. The reviewers reproduced this for both values. A typo such as `192.168.1.` is accepted the same way.

**Why it happens:** The request code builds an invalid URL (`http://192.168.1.50:8086:8086/…`), and Node's `http.get()` throws at once instead of reporting a connection error, so the handler that sets 'Connection Failure' never runs. The list refresh and polling routines then swallow the error in empty `catch` blocks. The host field has no format check, so the bad value is accepted.

**Fix:** validate the host field, catch the throw in `makeRequest()` and report a bad configuration.

- [ ] `src/config.ts`: add `regex: Regex.HOSTNAME` (or `Regex.IP`) from `@companion-module/base` to the `host` field.
- [ ] `src/main.ts`: wrap `http.get()` in `try`/`catch`, log the error, call `this.updateStatus(InstanceStatus.BadConfig, 'Invalid host or port')` and resolve.

### M5: The template's module-checks CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/companion-module-checks.yaml` (missing)

**What goes wrong:** Pushes and pull requests aren't checked by the shared Bitfocus module checks, so problems such as a failing build ([C1](#c1-the-release-cant-be-built-because-yarn-package-has-no-script-to-run)) aren't caught before a release is submitted.

**Fix:** copy `.github/workflows/companion-module-checks.yaml` from the template.

### M6: The template's Node CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** Pushes aren't installed, linted and built in CI, so a broken build or lint only shows up at release review.

**Fix:** copy `.github/workflows/node.yaml` from the template.

## 🟢 Low

### L1: Counters and timers with a space or accent in their name don't refresh after Set value or Reset

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:55-61`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/actions.ts#L55-L61), [`src/actions.ts:87-92`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/actions.ts#L87-L92), [`src/main.ts:136-151`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L136-L151), [`src/main.ts:211-233`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L211-L233)
- **Assumption:** [A4](#-assumptions-to-confirm)

**What goes wrong:** A user has a counter named "Score Home" (or "Période") and presses a button with 'Compteurs : Définir valeur' set to 5. The scoreboard changes, but the follow-up refresh asks LDSscoreboard for the counter `Score%2520Home` and writes the reply to a variable that doesn't exist, so `$(LDSscoreboard:counter_Score Home)` keeps its old value until the next full poll. 'Timers : Reset' has the same problem, hidden by the 1-second timer polling. Variables for such names also get ids with spaces or accents (`counter_Score Home`), which are hard or impossible to use in `$(LDSscoreboard:…)`, and the generated presets use those same references. 'Compteurs : Incrémenter' does the refresh correctly.

**Why it happens:** 'Définir valeur' and 'Reset' URL-encode the name and then pass the encoded name to the refresh routine (`refreshSpecific()`), which builds the variable id from it and encodes it a second time for the request. Variable ids are built straight from the device's names, while preset ids are already cleaned up with `replace(/[^a-zA-Z0-9]/g, '_')`.

**Fix:** pass the raw name to `refreshSpecific()` and encode it only in the URL. Build variable ids from a cleaned-up name (the same `replace` the presets use), and keep a map from that id back to the device name for requests.

```ts
const raw = String(action.options.name ?? '')
if (raw) await self.makeRequest(`/pcontrol/set_counter/${encodeURIComponent(raw)}/${value}`)
await self.refreshSpecific([`counter_${raw}`])
```

### L2: Players 15 to 19 are polled and get presets, but their variables are never defined

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:156-166`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L156-L166), [`src/main.ts:282-297`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L282-L297), [`src/presets.ts:207`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/presets.ts#L207)

**What goes wrong:** This shows once [H1](#h1-scores-team-names-counters-and-labels-never-update-with-the-default-connection-settings) is fixed. A team has 18 players in LDSscoreboard. The 'Roster Local' presets go up to L17, but the display buttons for players L15 to L17 (for example 'L15 Score') stay blank. Their values are fetched from the scoreboard on every poll and then discarded. The roster actions also accept 'Index joueur' up to 30, but nothing above 14 can be shown.

**Why it happens:** Player variables are defined for indexes 0 to 14 only, while the polling loop and the presets go up to 20 players. `@companion-module/base` 1.11 drops values for variables that have no definition.

**Fix:** use one shared constant (for example `MAX_PLAYERS = 20`) for the variable definitions, the polling loop, the presets and the 'Index joueur' maximum, or define the player variables from the polled player counts.

### L3: One failed list refresh empties the counter, timer and label variables, dropdowns and presets

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:98-123`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L98-L123), [`src/main.ts:316-344`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L316-L344)

**What goes wrong:** The module re-reads all lists every refresh interval (60 seconds by default). If one refresh fails, for example because LDSscoreboard was restarted between matches, the affected lists become empty. Every `counter_*`, `timer_*`, `label_*` and `vector_*` variable is removed (buttons using `$(LDSscoreboard:counter_Period)` go blank), the action dropdowns switch to "(liste vide)", and the Slides, Compteurs and Timers presets disappear until a later refresh succeeds. The code comment says the intent is to keep the previous values.

**Why it happens:** The request helper (`makeRequest()`) never fails on a network or HTTP error; it returns an empty result instead. The list refresh therefore always "succeeds", parses each empty result as an empty list, and overwrites the stored lists. The `catch { // keep previous values }` block never runs for these failures.

**Fix:** make the request helper report a failure (reject, or return `{ ok: false }`), replace a list only when its own request succeeded, and skip re-defining variables, actions and presets when nothing changed.

### L4: Every HTTP request is logged at info level, flooding the connection log

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:307`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L307), [`src/main.ts:318`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L318)
- **Assumption:** [A5](#-assumptions-to-confirm)

**What goes wrong:** With 'Update timers every second' on (the default) and three timers on the scoreboard, the connection log gets three `→ http://127.0.0.1:8086/pcontrol/get_timer_time/…` lines every second, about 180 a minute. Each full poll adds one line per counter, label, vector element and player, plus a leftover `Player0 score: …` line. Real warnings and errors are hard to find.

**Why it happens:** The request helper logs every URL at `info` level, and the poll routine still has a debugging line at `info` level.

**Fix:** log requests at `debug` level (or not at all), remove the `Player0 score` line, and log the "Lists →" and "Variables defined" lines only when the lists change.

### L5: Display presets hard-code the connection label LDSscoreboard

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:24`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/presets.ts#L24), [`src/presets.ts:88`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/presets.ts#L88), [`src/presets.ts:211`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/presets.ts#L211)
- **Assumption:** [A6](#-assumptions-to-confirm)

**What goes wrong:** A user renames the connection (for example to "Scoreboard") or adds a second LDSscoreboard connection. Display presets such as 'Score local' still contain `$(LDSscoreboard:local_team_score)`, so they show `$NA` or the first connection's values instead of this connection's.

**Why it happens:** The preset builder writes the label `LDSscoreboard` into every preset text instead of the connection's current label. The same applies to the counter, timer, vector, label, team-name and roster display presets.

**Fix:** pass the connection's label (`this.label`) to `getPresets()` and build the text from it, for example `` `$(${label}:local_team_score)` ``. The presets are already rebuilt in `configUpdated()`, so they follow a rename.

## 💡 Nice to Have

### N1: Unused code in pollValuesStaggered, and every definition is re-sent on each refresh

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:174-178`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L174-L178), [`src/main.ts:184-191`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/main.ts#L184-L191)

**What goes wrong:** Nothing visible. `pollValuesStaggered()` says it staggers requests, but it builds two unused arrays and just calls `pollValues()`. Every refresh tick also re-sends the variable, action and preset definitions to Companion even when no list changed.

**Fix:** remove `pollValuesStaggered()` (or implement the staggering it describes), and send the definitions again only when a list actually changed.

## 🔮 Next Release

### NR1: Add feedbacks before 1.0.0, so buttons can show the scoreboard's state

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:1-25`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/src/feedbacks.ts#L1-L25)

**What goes wrong:** This release has no working feedback ([M2](#m2-neither-feedback-ever-changes-a-button-because-both-always-return-false)), so no button can show anything about the scoreboard yet. For example, a fouls button can't turn red once a team reaches 5 fouls, and a score button can't highlight the leading team. That's acceptable for 0.9.1, but please add working feedbacks before 1.0.0.

**Fix:** add feedbacks based on state the module already polls, and call `checkFeedbacks` after each `setVariableValues()`. For example:

- [ ] a counter at or above a value (with a dropdown of counters)
- [ ] team fouls at or above N (`local_team_fauls` / `guest_team_fauls`)
- [ ] home or guest team leading (`local_team_score` against `guest_team_score`)
- [ ] a player's fouls or cautions at or above N (`player_<team>_<i>_faults` / `_cautions`)
- [ ] a timer at zero (`timer_<name>`)

## 📝 Additional Notes

- [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/tsconfig.build.json) differs from the template (line 2: `"extends": "./tsconfig.json"` where the template has `"extends": "@companion-module/tools/tsconfig/node22/recommended"`). Fine as long as the module builds; no change required.
- [`tsconfig.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsscoreboard/blob/bec89a6e83cdbdabe3733ec70157ada885758346/tsconfig.json) differs from the template (it has its own `compilerOptions` block where the template has `"extends": "./tsconfig.build.json"`). Fine as long as the module builds; no change required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The packaged build keeps `const results` as a block-scoped `const`, so the early read throws. A build that turned it into `var` wouldn't throw, but the player stats would still never be polled | `tsconfig.json` targets ES2022 and the source fails the same way when run under Node 22; there is no build script, so the real build output couldn't be checked | [H1](#h1-scores-team-names-counters-and-labels-never-update-with-the-default-connection-settings) |
| A2 | The Bitfocus release build runs the module's build command and stops when `tsc` exits with an error | the template's `"package": "run build && companion-module-build"` and the validator's build gate; the Bitfocus pipeline itself wasn't checked | [H2](#h2-the-module-cant-be-built-even-once-the-scripts-are-added-because-typescript-stops-with-more-than-100-errors) |
| A3 | Companion keeps showing the last status a module sent until the module sends a new one; it doesn't reset it on its own | Companion host status handling; the module side (no OK after a successful reply) was reproduced in a harness | [M1](#m1-the-connection-stays-red-after-the-scoreboard-pc-is-reachable-again) |
| A4 | Companion variable references only resolve ids made of letters, digits, `_` and `-`, so an id with a space or an accent can't be used in `$(LDSscoreboard:…)` | general Companion host behaviour; `@companion-module/base` passes ids through unchanged | [L1](#l1-counters-and-timers-with-a-space-or-accent-in-their-name-dont-refresh-after-set-value-or-reset) |
| A5 | Module log lines at `info` level show in the connection's log view and are kept in its log buffer | Companion host log handling | [L4](#l4-every-http-request-is-logged-at-info-level-flooding-the-connection-log) |
| A6 | Companion doesn't rewrite a hard-coded `$(LDSscoreboard:…)` in preset text to the connection's actual label, and a renamed or second connection has a different label | general Companion 3.x behaviour; Companion's preset handling wasn't checked and may update the label prefix itself | [L5](#l5-display-presets-hard-code-the-connection-label-ldsscoreboard) |
