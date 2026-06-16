# Review: companion-module-iccms-sib v3.0.0

| | |
|---|---|
| **Module** | iccms-sib |
| **Review tag** | v3.0.0 |
| **Previous tag** | v1.0.2 |
| **Scope** | tag (`v1.0.2..v3.0.0` diff) |
| **Language** | JavaScript (ESM) |
| **API** | `@companion-module/base` ~1.12.1 (v1.x) |
| **Protocols** | HTTP (polling) + WebSocket (`ws`) |
| **Build** | `companion-module-build` ✅ (tgz written) · `yarn package` ❌ (script missing) · lint ❌ (eslint not installed) |
| **Tests** | jest — 146 passed, 1 skipped (36/37 suites) ✅ |

> **Architecture Note:** The module feels like it is over architected and more complex then it needs to be as most modules do not use a domain driven design.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Source files at module root instead of under src/](#c1-source-files-at-module-root-instead-of-under-src)
- [ ] [C2: yarn package build fails — required package script missing](#c2-yarn-package-build-fails--required-package-script-missing)
- [ ] [C3: package.json missing required package script](#c3-packagejson-missing-required-package-script)
- [ ] [C4: package.json missing required engines field](#c4-packagejson-missing-required-engines-field)
- [ ] [C5: package.json missing prettier devDependency](#c5-packagejson-missing-prettier-devdependency)
- [ ] [C8: Required file .gitattributes is missing](#c8-required-file-gitattributes-is-missing)
- [ ] [C9: .gitignore missing template entries](#c9-gitignore-missing-template-entries)
- [ ] [C10: .yarnrc.yml differs from template](#c10-yarnrcyml-differs-from-template)
- [ ] [C11: .yarn release binary committed but gitignored by template](#c11-yarn-release-binary-committed-but-gitignored-by-template)
- [ ] [C12: DEBUG-INSPECT committed but gitignored by template](#c12-debug-inspect-committed-but-gitignored-by-template)
- [ ] [C13: DEBUG-PACKAGED_1 committed but gitignored by template](#c13-debug-packaged_1-committed-but-gitignored-by-template)
- [ ] [C14: Local IDE/agent config committed (.idea, .claude, .clinerules)](#c14-local-ideagent-config-committed-idea-claude-clinerules)
- [ ] [C15: Remove Winston logger and move to the built in Companion logger](#c15-remove-winston-logger-and-move-to-the-built-in-companion-logger)
- [ ] [H1: lint script references eslint but eslint is not a dependency](#h1-lint-script-references-eslint-but-eslint-is-not-a-dependency)
- [ ] [H2: Move Markdown Docs to Docs Folder](#h2-move-markdown-docs-to-a-docs-folder)
- [ ] [H3: Remove webpack and babel](#h3-we-do-not-normally-need-webpack-or-babel-for-companion-modules)

**Non-blocking**

- [ ] [M4: Synchronous PNG composite in the hot preset-build path with no memoization](#m4-synchronous-png-composite-in-the-hot-preset-build-path-with-no-memoization)
- [ ] [M6: Empty composite string still assigned to png64 — blank button image](#m6-empty-composite-string-still-assigned-to-png64--blank-button-image)
- [ ] [M10: SibComputer.setSibTeams clears the wrong field on bad input](#m10-sibcomputersetsibteams-clears-the-wrong-field-on-bad-input)
- [ ] [L5: init swallows startup errors and never sets InstanceStatus](#l5-init-swallows-startup-errors-and-never-sets-instancestatus)
- [ ] [N2: Config field width 16 is out of the 12-column range](#n2-config-field-width-16-is-out-of-the-12-column-range)

---

## 🔴 Critical

### C1: Source files at module root instead of under src/

**Classification:** 🆕 NEW · **File:** `main.js`, `logger.js` (and all of `application/`, `domain/`, `infrastructure/`)

All source lives at the module root in a DDD-style layout (`application/`, `domain/`, `infrastructure/`, plus `main.js`/`logger.js`). The official template requires all source under `src/`. The manifest entrypoint is `../main.js` rather than `../dist/...` or `../src/...`.

**Fix:** Move all source into `src/` and update `companion/manifest.json` `runtime.entrypoint` and the package `main` accordingly (or build into `dist/` per the template). The internal `application/domain/infrastructure` structure can be preserved underneath `src/`.

### C2: yarn package build fails — required package script missing

**Classification:** 🆕 NEW · **File:** `package.json`

The deterministic `yarn package` build fails: `Couldn't find a script named "package"`. The module renamed the build script to `dist` (`"dist": "yarn companion-module-build"`). The real build via `companion-module-build` **does** succeed (writes `iccms-sib-3.0.0.tgz`), so this is a script-naming problem, not a compilation failure — but the template/CI pipeline invokes `package`, so the release cannot ship as-is.

**Fix:** Add the template's standard `"package": "companion-module-build"` script (the template keeps `package`, not `dist`).

### C3: package.json missing required package script

**Classification:** 🆕 NEW · **File:** `package.json`

Same root cause as C2, flagged independently by the template check (`PKG-SCRIPT`). The required `package` script is absent.

**Fix:** Restore `"package"` to `scripts` (see C2).

### C4: package.json missing required engines field

**Classification:** 🆕 NEW · **File:** `package.json`

`engines` is present in the template and missing here.

**Fix:** Add the template's `engines` block (e.g. `"engines": { "node": "^22.0.0" }`) to match the node22 runtime (see C6).

### C5: package.json missing prettier devDependency

**Classification:** 🆕 NEW · **File:** `package.json`

`prettier` is a template devDependency and is not declared, yet `scripts.format` runs `prettier -w .`.

**Fix:** Add `prettier` to `devDependencies`.

### C8: Required file .gitattributes is missing

**Classification:** 🆕 NEW · **File:** `.gitattributes`

The template's `.gitattributes` is required and absent.

**Fix:** Add the template `.gitattributes`.

### C9: .gitignore missing template entries

**Classification:** 🆕 NEW · **File:** `.gitignore`

Missing template entries: `/*.tgz`, `DEBUG-*`, `/.yarn`.

**Fix:** Add the three missing patterns to `.gitignore` (this also prevents C11–C13 from recurring).

### C10: .yarnrc.yml differs from template

**Classification:** 🆕 NEW · **File:** `.yarnrc.yml`

Line 1 is `compressionLevel: mixed`; the template expects `nodeLinker: node-modules`.

**Fix:** Align `.yarnrc.yml` with the template (set `nodeLinker: node-modules`).

### C11: .yarn release binary committed but gitignored by template

**Classification:** 🆕 NEW · **File:** `.yarn/releases/yarn-4.10.3.cjs`

Committed even though the template `.gitignore` excludes `/.yarn`.

**Fix:** Remove `.yarn/` from version control and add the `/.yarn` ignore (see C9).

### C12: DEBUG-INSPECT committed but gitignored by template

**Classification:** 🆕 NEW · **File:** `DEBUG-INSPECT`

A `DEBUG-*` artifact is committed; the template `.gitignore` excludes `DEBUG-*`.

**Fix:** Delete `DEBUG-INSPECT` from the repo and add the `DEBUG-*` ignore.

### C13: DEBUG-PACKAGED_1 committed but gitignored by template

**Classification:** 🆕 NEW · **File:** `DEBUG-PACKAGED_1`

Same as C12 for `DEBUG-PACKAGED_1`.

**Fix:** Delete `DEBUG-PACKAGED_1` from the repo and add the `DEBUG-*` ignore.

### C14: Local IDE/agent config committed (.idea, .claude, .clinerules)

**Classification:** 🆕 NEW · **File:** `.idea/`, `.claude/`, `.clinerules/`, `.vscode/`

The release commits per-developer IDE and AI-agent config: the full `.idea/` JetBrains project (including `runConfigurations`, `jsLibraryMappings.xml`), `.claude/settings.local.json`, and `.clinerules/`. These are developer-local and should not ship in a published module. (`.vscode/launch.json`/`extensions.json` is acceptable per template; `.idea/` and the agent config are not.)

**Fix:** Remove `.idea/`, `.claude/settings.local.json`, and `.clinerules/` from version control and add them to `.gitignore`.

### C15: Remove Winston logger and move to the built in Companion logger

The winston logger is not needed and potentially hides the error messages from the Companion UI.  

**Fix:** remove Winston and replace with the built-in Companion instance logger.

---

## 🟠 High

### H1: lint script references eslint but eslint is not a dependency

**Classification:** 🆕 NEW · **File:** `package.json`

`scripts.lint:raw` runs `eslint ...`, but `eslint` is not in `dependencies`/`devDependencies`; `yarn lint` fails with `command not found: eslint`. The advertised lint step cannot run in a clean checkout.

**Fix:** add `eslint` (+ the module's eslint config) to `devDependencies`

### H2: Move markdown docs to a docs folder

There are several markdown files at the module root that should be moved into a docs folder.  Architecture.md, Companion_Hooks.md, Presets_Guide.md, and testing-guide.md.

**Fix:** Move all markdown docs into `docs/`.

### H3: we do not normally need webpack or babel for Companion modules

It is not normal to use Webpack or Babel with Companion modules since Companion already has its own build system.

**Fix:** Remove the webpack and babel dependencies.  

## 🟡 Medium

### M4: Synchronous PNG composite in the hot preset-build path with no memoization

**Classification:** 🆕 NEW · **File:** `domain/imageProcessing.js:23-108` (called from `createPresetFromButton.js:81`, `createPresetsFromRundownsArray.js:88`, `createPresetsFromTeamsArray.js:68`)

`composeIconWithGradient` uses `PNG.sync.read`/`PNG.sync.write` plus a nested per-pixel loop over a 72×58 canvas, invoked once per preset every time presets are rebuilt (every data change), with no caching by `IconId`. With many collections/groups/buttons + teams + rundowns this is a synchronous CPU burst on Companion's main thread per poll.

**Fix:** Memoize the composited base64 by `iconId` (and team logo by `teamId`); invalidate only when the source icon changes.

### M6: Empty composite string still assigned to png64 — blank button image

**Classification:** 🆕 NEW · **File:** `application/presetFactory/createPresetFromButton.js:80-82`, `application/presetFactory/createPresetsFromTeamsArray.js:66-68`

When `composeIconWithGradient` catches an error it returns `''` (imageProcessing.js:106), and callers assign that empty string to `style.png64` unconditionally (`hasIcon` was true). An empty `png64` is a malformed/blank image rather than a fallback.

**Fix:** Only set `style.png64` when the composite returns a non-empty string.

### M10: SibComputer.setSibTeams clears the wrong field on bad input

**Classification:** 🆕 NEW · **File:** `domain/sibComputer.js:155,161`

On malformed input `setSibTeams` clears `#sibCollections` instead of `#sibTeams` (copy/paste bug), corrupting unrelated state.

**Fix:** Clear `#sibTeams` in the `setSibTeams` guard paths.

---

## 🟢 Low

### L5: init swallows startup errors and never sets InstanceStatus

**Classification:** 🆕 NEW · **File:** `main.js:235-237`

The top-level `catch (e) { logger.error(e, 'init failed.') }` logs to winston (stdout, not the Companion connection log) and leaves the instance with no error status — the operator sees a stuck/blank state.

**Fix:** `this.updateStatus(InstanceStatus.UnknownError, e.message)` and prefer `this.log('error', ...)` so it reaches Companion's log.

---

## 💡 Nice to Have

### N2: Config field width 16 is out of the 12-column range

**Classification:** 🆕 NEW · **File:** `main.js:370,376`

The config grid is 12 columns wide; `width: 16` on the two password fields is clamped to 12. Cosmetic.

**Fix:** Set `width: 12`.

---
