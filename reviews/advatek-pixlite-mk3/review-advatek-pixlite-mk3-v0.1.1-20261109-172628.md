# Review: advatek-pixlite-mk3 v0.1.1

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-advatek-pixlite-mk3`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3) |
| **Scope** | `tag` |
| **Version** | v0.1.1 ([`2f8ba60`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/commit/2f8ba60ed1071e4e71678b5ec382d2084a47f706)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Reviewed** | 2026-11-09 |

First release: this module has never been published, so there is no earlier release to diff against. The whole module was reviewed, and every finding is classified 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: The release package can't be built on macOS or Linux](#c1-the-release-package-cant-be-built-on-macos-or-linux)
- [ ] [C2: .gitignore is missing entries from the template](#c2-gitignore-is-missing-entries-from-the-template)
- [ ] [C3: The .husky/pre-commit hook is missing](#c3-the-huskypre-commit-hook-is-missing)
- [ ] [C4: .prettierignore drops the template's entries](#c4-prettierignore-drops-the-templates-entries)
- [ ] [C5: package.json repository URL lacks the git+ prefix](#c5-packagejson-repository-url-lacks-the-git-prefix)
- [ ] [C6: package.json has no prettier field, so the code isn't formatted in the Companion style](#c6-packagejson-has-no-prettier-field-so-the-code-isnt-formatted-in-the-companion-style)
- [ ] [C7: package.json is missing the postinstall script](#c7-packagejson-is-missing-the-postinstall-script)
- [ ] [C8: package.json is missing the build:main script](#c8-packagejson-is-missing-the-buildmain-script)
- [ ] [C9: package.json is missing the lint:raw script](#c9-packagejson-is-missing-the-lintraw-script)
- [ ] [C10: package.json is missing the husky devDependency](#c10-packagejson-is-missing-the-husky-devdependency)
- [ ] [C11: package.json is missing the lint-staged devDependency](#c11-packagejson-is-missing-the-lint-staged-devdependency)
- [ ] [C12: package.json is missing the rimraf devDependency](#c12-packagejson-is-missing-the-rimraf-devdependency)
- [ ] [C13: package.json is missing the lint-staged section](#c13-packagejson-is-missing-the-lint-staged-section)
- [ ] [H1: Variable definitions live in main.ts instead of the template's src/variables.ts](#h1-variable-definitions-live-in-maints-instead-of-the-templates-srcvariablests)
- [ ] [H2: The build, package, format and lint commands differ from the template](#h2-the-build-package-format-and-lint-commands-differ-from-the-template)
- [ ] [H3: Dependencies are pinned to exact versions instead of the template's version ranges](#h3-dependencies-are-pinned-to-exact-versions-instead-of-the-templates-version-ranges)

### Non-blocking

- [ ] [M1: An HTTPS connection reports a certificate failure when the controller is just offline](#m1-an-https-connection-reports-a-certificate-failure-when-the-controller-is-just-offline)
- [ ] [M2: About 1.7 MB of definitions is re-sent every 4 seconds while the controller is offline](#m2-about-17-mb-of-definitions-is-re-sent-every-4-seconds-while-the-controller-is-offline)
- [ ] [M3: Action and feedback options are not type-checked, so a typo in a preset would still compile](#m3-action-and-feedback-options-are-not-type-checked-so-a-typo-in-a-preset-would-still-compile)
- [ ] [L1: The connection shows a red Connection failure while it is still connecting](#l1-the-connection-shows-a-red-connection-failure-while-it-is-still-connecting)
- [ ] [L2: Most feedbacks show raw ids as names and raw device tokens as choices](#l2-most-feedbacks-show-raw-ids-as-names-and-raw-device-tokens-as-choices)
- [ ] [L3: Variables are listed under their raw ids instead of readable names](#l3-variables-are-listed-under-their-raw-ids-instead-of-readable-names)
- [ ] [L4: Colour mix dial presets may land with rotary actions turned off on Companion 5.0](#l4-colour-mix-dial-presets-may-land-with-rotary-actions-turned-off-on-companion-50)
- [ ] [L5: All variables and feedbacks are refreshed twice a second even when nothing changed](#l5-all-variables-and-feedbacks-are-refreshed-twice-a-second-even-when-nothing-changed)
- [ ] [N1: Read: Scene metadata could return its result to the button](#n1-read-scene-metadata-could-return-its-result-to-the-button)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The release package can't be built on macOS or Linux

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json:17`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L17), [`scripts/build-example-workspace.mjs:289-305`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/scripts/build-example-workspace.mjs#L289-L305)
- **Validator:** `package.json`: yarn package (build) failed

**What goes wrong:** `yarn package` stops with "Example workspace is stale. Run yarn workspace:build." on every macOS and Linux machine, even on a clean checkout of v0.1.1, so no installable package is produced. That includes the module's own Node CI job (`yarn build` on `ubuntu-latest` in [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/.github/workflows/node.yaml)) and the Bitfocus build that creates the package users install ([A1](#-assumptions-to-confirm)). It passes on Windows, which is probably why it built for you.

**Why it happens:** The `build` script ends with `workspace:check`. That step gzips the example workspace again and compares the result byte for byte with the committed `companion/EXAMPLE.companionconfig` and `examples/showtime-demo/SHOWTime.companionconfig`. The JSON inside is identical (315,382 characters). The only byte that differs is byte 9 of the gzip header, which records the operating system that wrote the file: the committed files have `0x0a` (Windows), while macOS writes `0x13` and Linux `0x03`. The Node version makes no difference: the check fails the same way on Node 20, 22, 24 and 26.13.0.

**Evidence:**

```json
// package.json:17, 28
    "build": "yarn build:compile && yarn workspace:check",
    "workspace:check": "node scripts/build-example-workspace.mjs --check",
```

```js
// scripts/build-example-workspace.mjs:289-305
export function encodeWorkspace(workspace) {
  return gzipSync(Buffer.from(JSON.stringify(workspace)), { level: 9 });
}
...
  const bytes = encodeWorkspace(exampleWorkspace(version));
  for (const target of [workspacePath, exampleWorkspacePath]) {
    if (process.argv.includes("--check")) {
      if (!bytes.equals(await fs.readFile(target)))
        throw new Error(
          "Example workspace is stale. Run yarn workspace:build.",
        );
```

```text
gzip header, bytes 0-9
committed companion/EXAMPLE.companionconfig      [31,139,8,0,0,0,0,0,2,10]
committed showtime-demo/SHOWTime.companionconfig [31,139,8,0,0,0,0,0,2,10]
generated on macOS (any Node version)            [31,139,8,0,0,0,0,0,2,19]

$ yarn package   (clean v0.1.1 checkout, macOS)
Error: Example workspace is stale. Run yarn workspace:build.
    at file:///.../scripts/build-example-workspace.mjs:303:15
exit=1
```

**Confirm by:** on macOS or Linux, run `yarn install && yarn package` on a clean checkout. Today it exits 1 with the error above; after the fix it must exit 0.

**Fix:** make the check independent of the platform, then regenerate the two files. Any one of these works:

- take `workspace:check` out of `build` and run it as a separate script (the template's `build` is `rimraf dist && run build:main`, see [H2](#h2-the-build-package-format-and-lint-commands-differ-from-the-template));
- have `--check` gunzip the committed files and compare the JSON text instead of the gzip bytes;
- give the gzip header a fixed OS byte, then run `yarn workspace:build` once to regenerate both files:

```js
export function encodeWorkspace(workspace) {
  const bytes = gzipSync(Buffer.from(JSON.stringify(workspace)), { level: 9 });
  bytes[9] = 0xff; // OS "unknown": every platform now writes the same bytes
  return bytes;
}
```

### C2: .gitignore is missing entries from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/.gitignore)
- **Validator:** `.gitignore`: Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode

**What goes wrong:** The module's `.gitignore` doesn't contain the template's lines. It has unanchored equivalents for `dist/`, `pkg/`, `*.tgz` and `/.yarn/`, but `package-lock.json`, `DEBUG-*` and `/.vscode` are not ignored at all, so a stray npm lockfile, a Companion debug log or editor settings can be committed by accident.

**Fix:** add the template's lines exactly as they are, and keep your extra entries (`test-dist/`, `coverage/`, …) below them.

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

### C3: The .husky/pre-commit hook is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (not in the repo)
- **Validator:** `.husky/pre-commit`: Required file is missing (tracked by the template)

**What goes wrong:** The template runs lint-staged before every commit, which formats the staged files with Prettier and fixes ESLint problems. Without the hook that check never runs, so unformatted or unlinted code can be committed.

**Fix:** add `.husky/pre-commit` with the template's single line. It needs the script, dependencies and section from [C7](#c7-packagejson-is-missing-the-postinstall-script), [C10](#c10-packagejson-is-missing-the-husky-devdependency), [C11](#c11-packagejson-is-missing-the-lint-staged-devdependency) and [C13](#c13-packagejson-is-missing-the-lint-staged-section).

```text
lint-staged
```

### C4: .prettierignore drops the template's entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/.prettierignore)
- **Validator:** `.prettierignore`: Differs from template (line 1: found 'src/companion/artwork.generated.ts', template 'package.json')

**What goes wrong:** The template's two entries, `package.json` and `/LICENSE.md`, are missing, so Prettier also formats those files. Your three entries are generated files (`src/companion/artwork.generated.ts`, `src/companion/labelled-artwork.generated.ts`, `src/discovery/page.generated.ts`), and keeping them is fine.

**Fix:** restore the template's two lines and keep your generated-file entries after them.

```text
package.json
/LICENSE.md
src/companion/artwork.generated.ts
src/companion/labelled-artwork.generated.ts
src/discovery/page.generated.ts
```

### C5: package.json repository URL lacks the git+ prefix

- **Source:** 🤖 validate-template (PKG-REPO)
- **Classification:** 🆕 NEW
- **File:** [`package.json:48`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L48)
- **Validator:** `package.json`: repository.url `'https://github.com/bitfocus/companion-module-advatek-pixlite-mk3.git'` should be `'git+https://github.com/bitfocus/companion-module-advatek-pixlite-mk3.git'`

**What goes wrong:** The repository URL doesn't use the `git+https://` form the template uses.

**Fix:**

```json
"url": "git+https://github.com/bitfocus/companion-module-advatek-pixlite-mk3.git"
```

### C6: package.json has no prettier field, so the code isn't formatted in the Companion style

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json)
- **Validator:** `package.json`: Missing required field 'prettier' (present in template)

**What goes wrong:** Without the `prettier` field, Prettier falls back to its own defaults (2-space indents, double quotes, semicolons) instead of the shared Companion style, so the code is formatted differently from the template and other modules.

**Fix:** add the template's field, then run `yarn format` once.

```json
"prettier": "@companion-module/tools/.prettierrc.json"
```

### C7: package.json is missing the postinstall script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:16-30`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L16-L30)
- **Validator:** `package.json`: Missing required script 'postinstall'

**What goes wrong:** `yarn install` never sets up the Git hooks, so the pre-commit check from [C3](#c3-the-huskypre-commit-hook-is-missing) isn't installed for anyone who clones the repo.

**Fix:**

```json
"postinstall": "husky"
```

### C8: package.json is missing the build:main script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:16-30`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L16-L30)
- **Validator:** `package.json`: Missing required script 'build:main'

**What goes wrong:** The template's `build` calls `build:main` to compile the module. This module compiles in its own `build:compile` script instead (see [H2](#h2-the-build-package-format-and-lint-commands-differ-from-the-template)).

**Fix:**

```json
"build:main": "tsc -p tsconfig.build.json"
```

### C9: package.json is missing the lint:raw script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:16-30`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L16-L30)
- **Validator:** `package.json`: Missing required script 'lint:raw'

**What goes wrong:** The template's `lint` and its lint-staged hook both call `lint:raw` (`yarn lint:raw --fix` on staged files). Without it the pre-commit hook can't fix ESLint problems.

**Fix:**

```json
"lint:raw": "eslint"
```

### C10: package.json is missing the husky devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:35-45`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L35-L45)
- **Validator:** `package.json`: Missing devDependency 'husky' (present in template)

**What goes wrong:** husky installs the Git hook from [C3](#c3-the-huskypre-commit-hook-is-missing). Without it, the `postinstall` script from [C7](#c7-packagejson-is-missing-the-postinstall-script) can't run.

**Fix:** add `"husky": "^9.1.7"` to `devDependencies` and re-run `yarn install`.

### C11: package.json is missing the lint-staged devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:35-45`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L35-L45)
- **Validator:** `package.json`: Missing devDependency 'lint-staged' (present in template)

**What goes wrong:** lint-staged is what the pre-commit hook runs. Without it the hook from [C3](#c3-the-huskypre-commit-hook-is-missing) fails.

**Fix:** add `"lint-staged": "^17.6.0"` to `devDependencies` and re-run `yarn install`.

### C12: package.json is missing the rimraf devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:35-45`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L35-L45)
- **Validator:** `package.json`: Missing devDependency 'rimraf' (present in template)

**What goes wrong:** The template's `build` starts with `rimraf dist`, so stale files from an earlier build never end up in the package. This module's build doesn't clean `dist` first.

**Fix:** add `"rimraf": "^6.1.3"` to `devDependencies` and use it in `build` (see [H2](#h2-the-build-package-format-and-lint-commands-differ-from-the-template)).

### C13: package.json is missing the lint-staged section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json)
- **Validator:** `package.json`: Missing 'lint-staged' section (present in template)

**What goes wrong:** The `lint-staged` section tells the pre-commit hook what to run on each kind of staged file. Without it the hook from [C3](#c3-the-huskypre-commit-hook-is-missing) does nothing useful.

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

### H1: Variable definitions live in main.ts instead of the template's src/variables.ts

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:181-196`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L181-L196), [`src/types.ts:19-28`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/types.ts#L19-L28)

**What goes wrong:** Nothing changes on screen: users still get variables such as `$(PixLite:mode)` and `$(PixLite:temperature_c)`. The problem is where the code lives. The API 2.1 TypeScript template keeps variable definitions in their own file, `src/variables.ts`, next to `actions.ts`, `feedbacks.ts`, `presets.ts`, `config.ts` and `upgrades.ts`. This module follows that layout for everything except variables, which are defined inline in `main.ts`. Anyone who knows the template looks for them in the wrong place, which makes the module harder to troubleshoot and maintain.

**Why it happens:** The `publish()` method in `main.ts` works out the list of variable names and calls `setVariableDefinitions` itself. `src/state/view.ts` only computes the values. There is also no `VariablesSchema` type: `ModuleSchema` declares variables as a catch-all `Record<string, CompanionVariableValue>`.

**Evidence:**

```text
// top-level files in src/ at v0.1.1: no variables.ts
src/actions.ts
src/colour-mixer.ts
src/config.ts
src/connection.ts
src/feedbacks.ts
src/main.ts
src/presets.ts
src/types.ts
src/upgrades.ts
```

```ts
// src/main.ts:181-196
    // Clear variables absent on the new target or in the new mode.
    for (const name of this.variableNames)
      if (!(name in values)) values[name] = "";
    const newNames = Object.keys(values);
    if (newNames.some((name) => !this.variableNames.has(name))) {
      newNames.forEach((name) => this.variableNames.add(name));
      this.setVariableDefinitions(
        Object.fromEntries(
          [...this.variableNames].map((name) => [
            name,
            { name: name.replaceAll("_", " ") },
          ]),
        ),
      );
    }
    this.setVariableValues(values);
```

```ts
// src/types.ts:19-28
export type ModuleSchema = {
  config: ModuleConfig;
  secrets: { password: string };
  actions: Record<string, { options: CompanionOptionValues }>;
  feedbacks: Record<
    string,
    { type: "boolean" | "value"; options: CompanionOptionValues }
  >;
  variables: Record<string, CompanionVariableValue>;
};
```

```ts
// companion-module-template-ts (e0d42b7) src/main.ts:3, 62-63
import { UpdateVariableDefinitions, type VariablesSchema } from './variables.js'
	updateVariableDefinitions(): void {
		UpdateVariableDefinitions(this)
// companion-module-template-ts (e0d42b7) src/variables.ts:9-10
export function UpdateVariableDefinitions(self: ModuleInstance): void {
	self.setVariableDefinitions({
```

**Confirm by:** list the files in `src/` and see that there is no `variables.ts`, then open [`src/main.ts:187`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L187) and find the inline `this.setVariableDefinitions(...)` call inside `publish()`.

**Fix:** move the variable definitions into a new `src/variables.ts`, as in the template. Export a `VariablesSchema` type and an `UpdateVariableDefinitions(self, names)` function that holds the `setVariableDefinitions` call and the variable labels (see [L3](#l3-variables-are-listed-under-their-raw-ids-instead-of-readable-names)), and call it from `publish()`. The tracking of which variable names exist can stay in `main.ts`.

### H2: The build, package, format and lint commands differ from the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:17-21`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L17-L21)

**What goes wrong:** Someone who knows the template expects `yarn build` to clean `dist` and compile, `yarn lint` to run ESLint and `yarn format` to format the whole repo. In this module each of those commands does something different. The custom `build` is also the step that stops the release package from building on macOS and Linux ([C1](#c1-the-release-package-cant-be-built-on-macos-or-linux)).

**Why it happens:** The module replaced the template's commands with its own pipeline. `build` runs the discovery-page generator, compiles, and then runs the byte-for-byte example-workspace check. `lint` chains a typecheck, `eslint src ui --max-warnings=0` and `prettier --check` over a list of folders. `format` formats a list of folders instead of `.`, and `package` calls `yarn build` instead of `run build`. The template's `build:main`, `lint:raw` and `postinstall` scripts are missing as well ([C7](#c7-packagejson-is-missing-the-postinstall-script), [C8](#c8-packagejson-is-missing-the-buildmain-script), [C9](#c9-packagejson-is-missing-the-lintraw-script)).

**Evidence:**

```json
// package.json:17-29 (v0.1.1)
    "build": "yarn build:compile && yarn workspace:check",
    "typecheck": "tsc -p tsconfig.json --noEmit && tsc -p ui/tsconfig.json",
    "format": "prettier --write src ui scripts companion assets/*.json package.json tsconfig*.json eslint.config.mjs \"*.md\" \"docs/**/*.md\" \"assets/**/*.md\" \"examples/**/*.md\"",
    "lint": "yarn typecheck && yarn lint:code && yarn lint:format",
    "package": "yarn build && companion-module-build",
    ...
    "workspace:check": "node scripts/build-example-workspace.mjs --check",
    "build:compile": "node scripts/build-discovery-page.mjs && tsc -p tsconfig.build.json"
```

```json
// companion-module-template-ts (e0d42b7) package.json:6-15
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

**Confirm by:** compare [`package.json:17-29`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L17-L29) with `companion-module-template-ts/package.json:6-15`.

**Fix:** restore the template's commands and keep the module's extra steps (`typecheck`, `workspace:check`, `artwork:*`, `check:module`) as separate scripts outside `build`. If the generated discovery page must be refreshed on every build, `build:main` can run `node scripts/build-discovery-page.mjs` before `tsc`.

```json
"postinstall": "husky",
"format": "prettier -w .",
"package": "run build && companion-module-build",
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json",
"lint:raw": "eslint",
"lint": "run lint:raw ."
```

### H3: Dependencies are pinned to exact versions instead of the template's version ranges

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:31-45`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L31-L45)

**What goes wrong:** There is no direct effect for users. `@companion-module/base` is pinned to `2.1.3` where the template uses `~2.1.3`, so the module never picks up 2.1.x patch fixes without a manual edit. The dev tools are pinned exactly too (`@companion-module/tools`, `typescript`, `eslint`, `prettier`, `typescript-eslint`, `@types/node`) where the template uses `^` or `~` ranges. The version numbers themselves match the template; only the range style differs. The exact pins look like a deliberate supply-chain choice (together with `npmMinimalAgeGate` in `.yarnrc.yml`), but `yarn.lock` already fixes the installed versions, so the template's ranges don't change what gets installed until the lockfile is updated.

**Why it happens:** The dependency versions were written as exact versions instead of the template's ranges.

**Evidence:**

```json
// package.json:31-45 (v0.1.1)
  "dependencies": {
    "@companion-module/base": "2.1.3",
    "pkijs": "3.4.3"
  },
  "devDependencies": {
    "@companion-module/tools": "3.1.1",
    "@types/node": "26.6.4",
    "eslint": "10.12.0",
    "prettier": "3.9.9",
    "sharp": "0.35.5",
    "svgpath": "2.6.0",
    "typescript": "6.0.3",
    "typescript-eslint": "8.71.0",
    "vite": "8.0.10"
  },
```

```json
// companion-module-template-ts (e0d42b7) package.json:25-38
	"dependencies": {
		"@companion-module/base": "~2.1.3"
	},
	"devDependencies": {
		"@companion-module/tools": "^3.1.1",
		"@types/node": "^26.6.4",
		"eslint": "^10.12.0",
		"husky": "^9.1.7",
		"lint-staged": "^17.6.0",
		"prettier": "^3.9.9",
		"rimraf": "^6.1.3",
		"typescript": "~6.0.3",
		"typescript-eslint": "^8.71.0"
	},
```

**Confirm by:** open [`package.json:31-45`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/package.json#L31-L45) next to `companion-module-template-ts/package.json:25-38`: bare versions (`2.1.3`, `3.1.1`, `6.0.3`, …) where the template has `~2.1.3`, `^3.1.1`, `~6.0.3` and `^` ranges.

**Fix:** use the template's version ranges for the packages the template lists, then re-run `yarn install` and commit the updated `yarn.lock`. Module-specific packages (`pkijs`, `sharp`, `svgpath`, `vite`) can stay as they are.

```json
"@companion-module/base": "~2.1.3",
"@companion-module/tools": "^3.1.1",
"@types/node": "^26.6.4",
"eslint": "^10.12.0",
"prettier": "^3.9.9",
"typescript": "~6.0.3",
"typescript-eslint": "^8.71.0"
```

## 🟡 Medium

### M1: An HTTPS connection reports a certificate failure when the controller is just offline

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/pixlite/advatek-tls.ts:188-198`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/pixlite/advatek-tls.ts#L188-L198), [`src/pixlite/client.ts:339-349`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/pixlite/client.ts#L339-L349)

**What goes wrong:** A connection added with "Find controllers" uses Connection = HTTPS by default. When that PixLite is later switched off, unplugged, or gets a new IP address, the connection status reads "Advatek HTTPS certificate verification failed. Check Device MAC and the controller certificate." and the `last_api_error_message` variable shows the same text. The user goes checking the Device MAC and the certificates, or switches to HTTP, when the real problem is power or network. With Connection = HTTP the same situation correctly shows "Connection failed or timed out". The reviewer reproduced this with the built client: a closed port gave the certificate message after 5 ms, and an unroutable address after 3 seconds.

**Why it happens:** The HTTPS connection code treats every way the connection can fail as a certificate failure: connection refused, host unreachable, the socket closing before the TLS handshake, and the 3-second connect deadline. All of them use the same "certificate invalid" error code, which the client then turns into the certificate message.

**Fix:** keep the certificate error for real verification failures (the ALPN mismatch, a `verifyPeer` rejection, or the deadline after `secureConnect`), and give socket errors, early closes and the deadline before `secureConnect` their own code that maps to "Connection failed or timed out". Listing that code in `TLS_ERRORS` keeps the delivery state certain, which is correct because nothing is sent before verification passes.

```ts
// src/pixlite/advatek-tls.ts
const unreachable = (): Error =>
  Object.assign(new Error("Connection failed"), { code: "ADVATEK_CONNECT_FAILED" });
socket.once("error", () => finish(unreachable()));
socket.once("close", () => finish(unreachable()));

// src/pixlite/client.ts, TLS_ERRORS
ADVATEK_CONNECT_FAILED: "Connection failed or timed out",
```

### M2: About 1.7 MB of definitions is re-sent every 4 seconds while the controller is offline

- **Source:** 🔎 QA reviewer, protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/pixlite/client.ts:376-389`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/pixlite/client.ts#L376-L389), [`src/pixlite/client.ts:431-441`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/pixlite/client.ts#L431-L441), [`src/pixlite/client.ts:459-477`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/pixlite/client.ts#L459-L477), [`src/pixlite/client.ts:525-530`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/pixlite/client.ts#L525-L530), [`src/main.ts:110`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L110)

**What goes wrong:** While a PixLite is switched off or unreachable (for example Controller address 192.168.0.50 while the rig is dark between shows), the module sends its complete set of actions (28), feedbacks (44) and presets (156) to Companion about every 4 seconds. The presets alone are about 1.7 MB of JSON, mostly embedded button images, so each offline PixLite connection produces roughly 430 KB/s of continuous traffic to Companion, about 1.5 GB per hour. Once connected, the full set still goes out twice every 30 seconds even when nothing has changed. On a low-power host such as a Raspberry Pi this is steady CPU and IPC load that grows with every PixLite connection, and the Presets panel and the action and feedback editors may refresh while someone is working in them ([A2](#-assumptions-to-confirm)). The reviewer measured the definitions being re-sent at 9 ms, 4014 ms, 8019 ms and 12023 ms against an unreachable port.

**Why it happens:** Every "media" event from the client rebuilds and sends all three definition sets. The client emits "media" at the start of every connection attempt (retried every 4 seconds while offline) and after every 30-second media and config refresh, whether or not anything changed. Nothing skips a send that is identical to the previous one.

**Evidence:**

```ts
// src/pixlite/client.ts:387-389
    this.configAt = 0;
    this.emit("media");
    this.emit("change");
// src/pixlite/client.ts:526-530
        if (!this.destroyed)
          this.timer = setTimeout(
            () => void tick(),
            this.snapshot.connected ? 1000 : 4000,
          );
// src/main.ts:110
        client.on("media", () => this.definitions());
```

**Fix:** send definitions only when their inputs change. In `definitions()`, build a key from what the definitions depend on (`snapshot.connected`, the visible scene and playlist files, `pix.colorType`, `operIf.pal`, `auxPort.mode`, the outputs) and return early when it matches the last one sent. Stop emitting "media" at the start of `connect()` unless the previous snapshot actually had files or config, and in `refreshMedia()` / `refreshContext()` emit it only when the file list or config really changed. Calling `setPresetDefinitions` separately, only when the files or colour type change, removes most of the payload.

### M3: Action and feedback options are not type-checked, so a typo in a preset would still compile

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/types.ts:19-28`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/types.ts#L19-L28)

**What goes wrong:** Nothing is broken today: every preset's action and feedback ids and option keys match their definitions. But a typo in a preset's `feedbackId` or option key would still compile, and the button would silently lose that action or feedback when a user drags the preset onto a page. Callbacks also receive untyped options, which leads to casts such as `action.options as CompanionOptionValues` in `presets.ts`.

**Why it happens:** The template builds `ModuleSchema` from per-file `ActionsSchema`, `FeedbacksSchema` and `VariablesSchema` types. This module declares actions and feedbacks as catch-all `Record<string, …>` types instead.

**Fix:** declare an `ActionsSchema` in `actions.ts` and a `FeedbacksSchema` in `feedbacks.ts` with one entry per id and its option types (e.g. `scene_play: { options: { file: string; fade: number } }`), plus the `VariablesSchema` from [H1](#h1-variable-definitions-live-in-maints-instead-of-the-templates-srcvariablests). Plug them into `ModuleSchema` and type the definitions as `CompanionActionDefinitions<ActionsSchema>`, `CompanionFeedbackDefinitions<FeedbacksSchema>` and `CompanionPresetDefinitions<ModuleSchema>`.

## 🟢 Low

### L1: The connection shows a red Connection failure while it is still connecting

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:198-211`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L198-L211)

**What goes wrong:** When Companion starts, or the user saves the connection settings, the PixLite connection immediately shows the red "Connection failure" status with the message "Connecting as operator". It stays there until the whole connect sequence has finished (seven requests in a row, each a new TLS handshake over HTTPS). Operators can read this as a fault on a controller that is working fine.

**Why it happens:** `publish()` maps every "not ready yet" state to `InstanceStatus.ConnectionFailure`. It never uses `InstanceStatus.Connecting`, even before the first attempt has finished and no error has been recorded.

**Fix:** show `Connecting` until an attempt has actually failed, and keep `ConnectionFailure` for when `snapshot.error` is set. For example, when `!values.connection_ready && !snapshot.error && !snapshot.statusAt`, call `updateStatus(InstanceStatus.Connecting, "Connecting as operator")`.

### L2: Most feedbacks show raw ids as names and raw device tokens as choices

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:252-269`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/feedbacks.ts#L252-L269), [`src/feedbacks.ts:283-286`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/feedbacks.ts#L283-L286), [`src/feedbacks.ts:309-314`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/feedbacks.ts#L309-L314)

**What goes wrong:** In the feedback picker, users see lowercase names made from ids, with no description: "connection ready", "state stale", "capability unavailable", "mode is", "playback operation is", "output policy is", "intensity priority is", "sd state is", "power output state is", "metric compare", "sd space below". The feedbacks added separately do have proper names ("Button: Last command failed or delivery is unknown", "Colour mix: Live Mix enabled"). The dropdowns show device tokens: State "Inactv" / "OvrCur", "Hi" / "Lo", "testData", Output group "pix" / "aux 1". The feedbacks' Output group ids (`pix`, `aux_1`) also differ from the actions' ids (`Pix`, `Aux:1`), which confuses users who type values in expression mode.

**Why it happens:** Every entry of the `tests` map gets `name: id.replaceAll("_", " ")`, and `choose()` uses the raw value as the label.

**Fix:** give each feedback a proper name with a category prefix, as the actions have (e.g. `mode_is` → "Mode: Operating mode is", `power_output_state_is` → "Power: Output fuse state is"), plus a short `description`. Give the choices readable labels and keep the ids, e.g. `{ id: "Inactv", label: "Inactive" }`, `{ id: "OvrCur", label: "Over current" }`.

### L3: Variables are listed under their raw ids instead of readable names

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:187-194`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L187-L194)

**What goes wrong:** In the connection's Variables list, every variable is labelled with its id, with underscores turned into spaces: "pix programmed factor", "status age s", "sd free percent", "aux 1 output fps", "port 3 power state". Users have to guess what each one means and which unit it uses ("temperature c", "bank 1 voltage v").

**Why it happens:** The variable name shown in Companion is derived from the id with `name.replaceAll("_", " ")`.

**Fix:** keep a label map with readable names and units in the new `src/variables.ts` from [H1](#h1-variable-definitions-live-in-maints-instead-of-the-templates-srcvariablests), e.g. `temperature_c` → "Temperature (°C)", `pix_programmed_percent` → "Pixel programmed intensity (%)". Generate names for the dynamic `port_N_*`, `aux_N_*` and `bank_N_*` ids from a pattern, e.g. "Port 3 power state".

### L4: Colour mix dial presets may land with rotary actions turned off on Companion 5.0

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:522-524`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/presets.ts#L522-L524)

**What goes wrong:** The "Red mix dial (turn 1%, press 0%)" style presets set `rotaryActions: true` so that turning a Stream Deck+ or encoder dial runs the rotate actions. The module's own comment says Companion 5.1.1 reads that option, but the module supports Companion 5.0. If 5.0 ignores it, the preset lands on a dial with rotary actions disabled and turning the dial does nothing until the user enables rotary actions on the button ([A3](#-assumptions-to-confirm)).

**Why it happens:** `@companion-module/base` 2.1.3 defines only `stepAutoProgress` on simple preset options. The module assigns the object through a variable so the compiler doesn't reject the extra field, so neither the compiler nor the API guarantees it is honoured.

**Fix:** check on Companion 5.0 that rotary actions are enabled when the preset is dropped on a dial. If they aren't, mention the manual step in `HELP.md`. Ask upstream (companion-module-base) to add `rotaryActions` to the simple preset options so the type workaround can go.

### L5: All variables and feedbacks are refreshed twice a second even when nothing changed

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:51-53`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L51-L53), [`src/main.ts:121-122`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L121-L122), [`src/main.ts:171-211`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/main.ts#L171-L211)

**What goes wrong:** There is no visible effect beyond background load on the Companion host. Every 500 ms, even with no controller configured or nothing changing on it, each PixLite connection pushes all of its 90-plus variables to Companion, re-evaluates every feedback on every button that uses the connection (each evaluation rebuilds the full set of values), and updates the status. With a full SHOWTime page (say 64 buttons with 4 feedbacks each) that is about 512 feedback evaluations a second on an idle device. Each media button that subscribes or unsubscribes also triggers a full re-check, so loading a page with 100 media buttons runs 100 full re-evaluations ([A4](#-assumptions-to-confirm)).

**Why it happens:** `publish()` runs unconditionally on a 500 ms timer, which the comment says is there to expire stale values. It doesn't compare with what it sent last time, and it always calls `checkAllFeedbacks()`. The media-label tracker also calls `checkAllFeedbacks()` on every change.

**Fix:** keep the timer, but publish only what changed. Compare the new values with the last ones sent and pass only the changed entries to `setVariableValues`. Call `checkFeedbacks(...)` with only the feedback ids that depend on them, or when a freshness flag flips (`connection_ready`, `status_stale`, `media_stale`, `telemetry_stale`). For the media labels, call `checkFeedbacks("button_media_name", "button_media_selected")` instead of `checkAllFeedbacks()`. Call `updateStatus` only when the status or message changes.

## 💡 Nice to Have

### N1: Read: Scene metadata could return its result to the button

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:243`](https://github.com/bitfocus/companion-module-advatek-pixlite-mk3/blob/2f8ba60ed1071e4e71678b5ec382d2084a47f706/src/actions.ts#L243)

**What goes wrong:** Nothing is broken. "Read: Scene metadata" is a query action whose result only reaches users through the shared `metadata_scene_*` / `selected_scene_*` variables, so two buttons inspecting different scenes overwrite each other's values.

**Why it happens:** API 2.1 lets a read-style action return a value (`hasResult: true` with a `result` schema) that the button can store in a local variable. This module uses shared connection variables instead.

**Fix:** optionally add `hasResult: true` and a `result` type (e.g. `{ valid: boolean; durationS: number; universes: number }`) to `scene_inspect` and return the metadata from the callback. Keep the existing variables for the `scene_valid` feedback.

## 📝 Additional Notes

- `tsconfig.build.json` doesn't extend the template's `@companion-module/tools/tsconfig/node26/recommended.json`; it defines its own `compilerOptions` (target ES2022, NodeNext, strict, noUncheckedIndexedAccess, declaration, sourceMap, `types: ["node"]`) with no `verbatimModuleSyntax` and no template `exclude` list. Fine as long as the module builds — no change required.
- `tsconfig.json` drops the template's `compilerOptions.types`, adds `noEmit: true` and widens `exclude` to `node_modules/**`, `dist/**` and `pkg/**`. No change required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | On Linux, Node's zlib writes gzip OS byte `0x03`, so the byte-for-byte check also fails on the module's `ubuntu-latest` CI and on the Bitfocus build server, which runs `yarn package` | zlib's `OS_CODE` in `zutil.h`; only macOS (`0x13`) was observed, on Node 20, 22, 24 and 26.13.0. Linux and the Bitfocus builder's exact commands were not run | [C1](#c1-the-release-package-cant-be-built-on-macos-or-linux) |
| A2 | Companion fully processes every `setActionDefinitions`, `setFeedbackDefinitions` and `setPresetDefinitions` call, with no short-cut when the payload matches the last one, and pushes it to any open Presets panel or action/feedback editor | base 2.1.3 only forwards these calls to the host (`dist/module-api/base.js:44-60`); Companion's host code was not checked | [M2](#m2-about-17-mb-of-definitions-is-re-sent-every-4-seconds-while-the-controller-is-offline) |
| A3 | Companion 5.0 ignores `rotaryActions` on a simple preset (the module's comment says 5.1.1 reads it) | base 2.1.3 `preset/definition.d.ts` (simple preset options only have `stepAutoProgress`) and the comment at `src/presets.ts:522`; Companion's host code and a live 5.0 were not checked | [L4](#l4-colour-mix-dial-presets-may-land-with-rotary-actions-turned-off-on-companion-50) |
| A4 | Companion doesn't skip unchanged `setVariableValues` entries or redundant `checkAllFeedbacks` / `updateStatus` calls cheaply enough to make a 500 ms republish free | base 2.1.3 forwards these straight to the host (`dist/module-api/base.js:82-97, 167-168`); any dedupe lives in Companion itself | [L5](#l5-all-variables-and-feedbacks-are-refreshed-twice-a-second-even-when-nothing-changed) |
