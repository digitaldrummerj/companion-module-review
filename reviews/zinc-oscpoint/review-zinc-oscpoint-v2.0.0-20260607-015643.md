# Review: zinc-oscpoint v2.0.0

| | |
|---|---|
| **Module** | zinc-oscpoint (OSCPoint) |
| **Review tag** | v2.0.0 |
| **Previous tag** | v1.4.0 |
| **Scope** | `tag` (release diff `v1.4.0..v2.0.0`) |
| **Language / API** | JS (CommonJS) · @companion-module/base ~2.0.0 (v2) |
| **Protocol** | OSC (UDP) |
| **Maintainer** | Nick Roberts (@phuvf) |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: isVisibleExpression given JS functions instead of string expressions](#c1-isvisibleexpression-given-js-functions-instead-of-string-expressions)
- [ ] [C2: Build fails — no package script](#c2-build-fails--no-package-script)
- [ ] [C3: Source files at module root instead of src/](#c3-source-files-at-module-root-instead-of-src)
- [ ] [C4: package.json missing required fields and devDependency](#c4-packagejson-missing-required-fields-and-devdependency)
- [ ] [C5: Required template files missing](#c5-required-template-files-missing)
- [ ] [C6: gitignore missing template entries](#c6-gitignore-missing-template-entries)
- [ ] [H1: UpgradeScripts exported as null, discarding the imported array](#h1-upgradescripts-exported-as-null-discarding-the-imported-array)
- [ ] [H2: yarn lint is broken under ESLint 9](#h2-yarn-lint-is-broken-under-eslint-9)

**Non-blocking**

- [ ] [M1: Duplicate type key on posPercent option](#m1-duplicate-type-key-on-pospercent-option)
- [ ] [M2: Implicit global slideNumber assignments](#m2-implicit-global-slidenumber-assignments)
- [ ] [L1: useVariables true on number fields](#l1-usevariables-true-on-number-fields)
- [ ] [L2: Dead commented-out preset header code](#l2-dead-commented-out-preset-header-code)
- [ ] [N1: Redundant re-parsing of already-numeric option values](#n1-redundant-re-parsing-of-already-numeric-option-values)

## 🔴 Critical

### C1: isVisibleExpression given JS functions instead of string expressions

**Classification:** 🆕 NEW · **File:** `actions.js:152, 165, 423, 437, 524`

The migration renamed `isVisible: (options) => {...}` to `isVisibleExpression: (options) => {...}` but left the value as a JavaScript arrow function. In v2, `isVisibleExpression` is typed as a **string** Companion expression — confirmed in `node_modules/@companion-module/base/dist/module-api/input.d.ts:38` (`isVisibleExpression?: string`). There is no function-form `isVisible` in v2. A function is never evaluated as a visibility rule, so the conditional option fields break:

- `slideshowStart` — the Section-name vs Slide-number fields won't toggle on `startPosition` (`:152`, `:165`)
- `mediaGotoTime` — the Milliseconds vs Percent fields won't toggle on `type` (`:423`, `:437`)
- the disable-warning static text won't hide (`:524`)

Operators see the wrong / always-visible inputs. This is the central migration defect.

**Fix (maintainer):** Convert each to a string expression referencing options, e.g.

- `:152` → `isVisibleExpression: "$(options:startPosition) == 'section'"`
- `:165` → `isVisibleExpression: "$(options:startPosition) == 'slideNumber'"`
- `:423` → `isVisibleExpression: "$(options:type) != 'percent'"`
- `:437` → `isVisibleExpression: "$(options:type) == 'percent'"`
- `:524` → `isVisibleExpression: "$(options:action) == 'disable'"`

### C2: Build fails — no package script

**Classification:** ⚠️ Pre-existing (deterministic) · **File:** `package.json`

`yarn package` fails: `error Command "package" not found.` The required `"package": "companion-module-build"` script is absent, so the module cannot be packaged for release.

**Fix (maintainer):** Add `"package": "companion-module-build"` to `scripts` (matches the official template).

### C3: Source files at module root instead of src/

**Classification:** ⚠️ Pre-existing (deterministic) · **Files:** repo root + `package.json` + `companion/manifest.json`

The official template requires all source under `src/`. This module keeps the flat v1 layout. Validator findings:

- `SRC-AT-ROOT` — `actions.js`, `config.js`, `feedbacks.js`, `imgs.js`, `main.js`, `osc-listener.js`, `presets.js`, `text-helper.js`, `upgrades.js`, `variable-defaults.js`, `variables.js` (11 files at root)
- `FILE-MISSING` — `src/main.js`
- `PKG-MAIN` — `package.json` `main` is `main.js`, should be `src/main.js`
- `MAN-RUNTIME` — manifest `runtime.entrypoint` is `../main.js`, should be `../src/main.js`

**Fix (maintainer):** Move all `.js` source into `src/`, then update `package.json` `main` → `src/main.js` and manifest `runtime.entrypoint` → `../src/main.js`. Adjust relative `require()` paths to `img/` etc. accordingly.

### C4: package.json missing required fields and devDependency

**Classification:** ⚠️ Pre-existing (deterministic) · **File:** `package.json`

- `PKG-FIELD` — missing `engines` (template: `{ "node": "^22.20", "yarn": "^4" }`)
- `PKG-FIELD` — missing `packageManager` (template: `"yarn@4.12.0"`)
- `PKG-DEVDEP` — missing devDependency `prettier`

**Fix (maintainer):** Add `engines`, `packageManager`, and the `prettier` devDependency to match the template.

### C5: Required template files missing

**Classification:** ⚠️ Pre-existing (deterministic) · **Files:** `.gitattributes`, `.yarnrc.yml`

Both required template files are absent. `.yarnrc.yml` in particular is needed for the Yarn 4 toolchain the template assumes (see C4 `packageManager`).

**Fix (maintainer):** Copy `.gitattributes` and `.yarnrc.yml` from the current JS template.

### C6: gitignore missing template entries

**Classification:** ⚠️ Pre-existing (deterministic) · **File:** `.gitignore`

Missing template entries: `/*.tgz`, `DEBUG-*`, `/.yarn`.

**Fix (maintainer):** Add the missing lines so build artefacts and the Yarn cache aren't committed.

## 🟠 High

### H1: UpgradeScripts exported as null, discarding the imported array

**Classification:** 🆕 NEW · **File:** `main.js:2, 74`

`main.js:2` still does `const UpgradeScripts = require('./upgrades')`, but `main.js:74` exports `module.exports.UpgradeScripts = null`, discarding the imported array and leaving the `require` as dead code. The v2 contract is `module.exports.UpgradeScripts = <array>`.

`upgrades.js` is currently an empty array, so runtime impact today is nil — but this is a latent break: the moment any upgrade script is added it is silently ignored. It also matters for *this* migration: v1 stored slide-number / width / height / position fields as **string** `textinput` values, and v2 turns them into `number` fields. Users upgrading from v1.4.0 have saved actions with string values and there is no upgrade path to coerce them.

**Fix (maintainer):** Export the real array — `module.exports.UpgradeScripts = UpgradeScripts`. Consider adding an upgrade script in `upgrades.js` to coerce the old string values in the migrated numeric fields (the numeric-fixup helpers in `@companion-module/tools` are the intended mechanism).

### H2: yarn lint is broken under ESLint 9

**Classification:** ⚠️ Pre-existing (tooling) · **Files:** `.eslintrc.js`, `package.json`

`yarn lint` fails: *"ESLint couldn't find an eslint.config.(js|mjs|cjs) file."* The module depends on `eslint ^9` (since v1.4.0) but ships the legacy `.eslintrc.js`. ESLint 9 requires flat config. The advertised lint script therefore never runs — which is also why M2's `no-undef` and L1's dead props weren't caught locally.

**Fix (maintainer):** Migrate to a flat `eslint.config.mjs` that consumes `@companion-module/tools/eslint`, and delete `.eslintrc.js`.


## 🟡 Medium

### M1: Duplicate type key on posPercent option

**Classification:** 🆕 NEW · **File:** `actions.js:427, 431`

The `posPercent` option literal declares `type: 'textinput'` (`:427`) and then `type: 'number'` (`:431`) in the same object. The second wins, so the stray `'textinput'` is dead and misleading — a sign the migration was hand-edited.

**Fix (maintainer):** Delete the leftover `type: 'textinput',` line; keep only `type: 'number'`.

### M2: Implicit global slideNumber assignments

**Classification:** 🆕 NEW · **File:** `actions.js:105, 126`

In the `hide_slide` (`:105`) and `unhide_slide` (`:126`) callbacks, `slideNumber` is assigned with no `let`/`const` (`slideNumber = sanitiseSlideNumber(...)`), creating an implicit global. These lines were edited this release (previously `let slideNumber = await self.parseVariablesInString(...)`). It throws under strict mode and is flagged by `no-undef`.

**Fix (maintainer):** Add `const` to both assignments.

## 🟢 Low

### L2: Dead commented-out preset header code

**Classification:** 🆕 NEW · **Files:** `presets/files.js`, `presets/media.js`, `presets/slides.js`, `presets.js:7`

The old `type: 'text'` header presets were commented out rather than deleted during the move to the `setPresetDefinitions(structure, presets)` two-param form (~20 commented lines in `files.js`, ~12 in `media.js`, ~21 in `slides.js`, plus a stray `//let presets = {...}` at `presets.js:7`).

**Fix (maintainer):** Delete the commented-out blocks. While there, audit that every preset id listed in the `presets.js` `structure` (`'prevSection'`, `'nextSection'`, `'lastTenSeconds'`, …) resolves to a key in the merged `presets` object — a typo'd id silently drops the preset from its group.

---
