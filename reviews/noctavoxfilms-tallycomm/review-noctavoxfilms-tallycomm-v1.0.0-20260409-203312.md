# Module Review: companion-module-noctavoxfilms-tallycomm v1.0.0

**Review date:** 2026-04-09
**Reviewer team:** Mal 🏗️ · Wash 🔧 · Kaylee ⚛️ · Zoe 🧪 · Simon 🧪
**Module version:** v1.0.0 (first release — no previous tag)
**Language:** JavaScript (CommonJS)
**API version:** v1.x (`@companion-module/base ^1.12.1`)
**Protocol:** HTTP POST to TallyComm cloud/self-hosted API (`/api/tally`)
**Source entry:** `main.js` at repo root (template non-compliant — should be `src/main.js`)

---

## Fix Summary

This is a first release of a single-file tally relay module for the TallyComm service. The functional logic is thoughtful — six well-designed actions including smart auto-clear variants, three boolean feedbacks, four variables, and clean SDK usage throughout. However, the module was submitted without any of the required template scaffolding, making it a **build failure** out of the box. Separately, the connection health-check design has a phantom tally risk and the status lifecycle has a false-positive `Ok` on init. All findings are 🆕 NEW (first release).

**Critical blocking work (must fix before merge):**
- Move `main.js` → `src/main.js` and update entrypoint references in `manifest.json` and `package.json`
- Add 7 missing required files: `.gitattributes`, `.gitignore`, `.prettierignore`, `.yarnrc.yml`, `LICENSE`, `yarn.lock`, `companion/HELP.md`
- Complete `package.json`: add `scripts`, `engines`, `prettier`, `packageManager`, `devDependencies`, fix `repository.url` scheme
- Fix `manifest.json`: add `$schema`, fix `repository` URL scheme
- Fix premature `InstanceStatus.Ok` on init (use `Connecting` first)

---

## 📊 Scorecard

| Category | New | Existing | Total |
|----------|-----|----------|-------|
| 🔴 Critical | 9 | 0 | **9** |
| 🟠 High | 1 | 0 | **1** |
| 🟡 Medium | 2 | 0 | **2** |
| 🟢 Low | 0 | 0 | **0** |
| 💡 Nice to Have | 0 | 0 | **0** |
| **Total** | **12** | **0** | **12** |

**Blocking findings:** 10 (9 Critical + 1 High)
**Non-blocking findings:** 2 (2 Medium)
**Build status:** ❌ FAIL (`yarn package` — `Command "package" not found`)
**Test coverage:** None (non-blocking for first release)
**Health delta:** N/A (first release)

---

## ✋ Verdict

> ### 🔴 CHANGES REQUIRED
>
> **10 blocking issues** (9 Critical template violations + 1 High logic issue).
>
> The module is not ready for merge. `yarn package` fails outright due to missing `scripts` block. The source layout, all required config files, and all required `package.json` fields are non-compliant with the module template. These must be corrected as part of a proper module submission.
>
> Beyond template compliance, one High-severity protocol issue requires attention: the premature `InstanceStatus.Ok` on init creates a false-positive connection indicator.

---

## 📋 Issues TOC

### 🔴 Critical
- [C-1: Source file at repository root — not in `src/`](#c-1-source-file-at-repository-root--not-in-src)
- [C-2: Missing required files (7)](#c-2-missing-required-files-7)
- [C-3: `package.json` — No `scripts` block (build fails)](#c-3-packagejson--no-scripts-block-build-fails)
- [C-4: `package.json` — `engines` is empty `{}`](#c-4-packagejson--engines-is-empty-)
- [C-5: `package.json` — Missing `prettier` config reference](#c-5-packagejson--missing-prettier-config-reference)
- [C-6: `package.json` — Missing `packageManager` field](#c-6-packagejson--missing-packagemanager-field)
- [C-7: `package.json` — Missing `devDependencies`](#c-7-packagejson--missing-devdependencies)
- [C-8: `package.json` — `repository.url` missing `git+` prefix](#c-8-packagejson--repositoryurl-missing-git-prefix)
- [C-9: `manifest.json` — `repository` missing `git+` prefix](#c-9-manifestjson--repository-missing-git-prefix)

### 🟠 High
- [H-1: `init()` sets `InstanceStatus.Ok` before connection is verified](#h-1-init-sets-instancestatusok-before-connection-is-verified)

### 🟡 Medium
- [M-1: `legacyIds` contains `"tallycomm"` on a first release](#m-1-legacyids-contains-tallycomm-on-a-first-release)
- [M-2: `@companion-module/base` version outdated](#m-2-companion-modulebase-version-outdated)

---

## 🔴 Critical

### C-1: Source file at repository root — not in `src/`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **Files:** `main.js` (root), `companion/manifest.json:12`, `package.json`

All Companion JS modules must place source under `src/main.js`. This module places `main.js` at the repository root with no `src/` directory present. The `manifest.json` entrypoint correctly reflects the actual location (`"../main.js"`), but both the file location and entrypoint reference are non-compliant.

**Evidence:**
```
/main.js                           ← at root, no src/ directory exists
package.json: "main": "main.js"   ← should be "src/main.js"
manifest.json: "entrypoint": "../main.js"  ← should be "../src/main.js"
```

**Recommendation:** Move `main.js` → `src/main.js`. Update `package.json` `"main"` to `"src/main.js"`. Update `manifest.json` `"entrypoint"` to `"../src/main.js"`.

Additionally, split the current `main.js` into separate files for better maintainability:
- `src/main.js` — Main module initialization
- `src/actions.js` — Action definitions
- `src/feedbacks.js` — Feedback definitions
- `src/presets.js` — Preset definitions
- `src/config.js` — Configuration schema
- `src/variables.js` — Variable definitions

See the [Companion module template](https://github.com/bitfocus/companion-module-template) for an example of this file structure.

---

### C-2: Missing required files (7)

- **Severity:** 🔴 Critical (×7)
- **Classification:** 🆕 NEW — Template Compliance
- **Location:** Repository root / `companion/`

The following files required by the Companion module template are entirely absent:

| File | Expected content |
|------|-----------------|
| `.gitattributes` | `* text=auto eol=lf` |
| `.gitignore` | `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn` |
| `.prettierignore` | `package.json` and `/LICENSE.md` |
| `.yarnrc.yml` | `nodeLinker: node-modules` |
| `LICENSE` | MIT license text — `package.json` declares `"license": "MIT"` but no file exists |
| `yarn.lock` | Generated by `yarn install` with Yarn v4 — currently absent; running `yarn install` used Yarn Classic v1.22 due to missing `.yarnrc.yml` and `packageManager` |
| `companion/HELP.md` | Real user-facing documentation — not a stub |

**Recommendation:** Copy all seven files from the official JS module template. For `companion/HELP.md`, adapt content from the existing `README.md` which already contains thorough documentation.

**Note:** During build validation, running `yarn install` without `.yarnrc.yml` or `packageManager` caused Yarn Classic v1.22 to run instead of the required Yarn v4 Berry, generating an incompatible lockfile format.

---

### C-3: `package.json` — No `scripts` block (build fails)

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `scripts` block is entirely absent. `yarn package` is required to build the module for distribution; without it, the module cannot be submitted. The `format` script is required for automated formatting checks.

**Build result:**
```
$ yarn package
error Command "package" not found.
```

**Template expects:**
```json
"scripts": {
  "format": "prettier -w .",
  "package": "companion-module-build"
}
```

---

### C-4: `package.json` — `engines` is empty `{}`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `engines` key exists but is an empty object. Both `node` and `yarn` version constraints are required.

**Found:** `"engines": {}`
**Template expects:**
```json
"engines": {
  "node": "^22.20",
  "yarn": "^4"
}
```

---

### C-5: `package.json` — Missing `prettier` config reference

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `prettier` field is absent. Without it, Prettier will not pick up the shared config from `@companion-module/tools`, meaning formatting will not match the Companion standard.

**Template expects:** `"prettier": "@companion-module/tools/.prettierrc.json"`

---

### C-6: `package.json` — Missing `packageManager` field

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

`packageManager` is absent. This caused `yarn install` to fall back to Yarn Classic v1.22 during review instead of the required Yarn v4 Berry.

**Template expects:** `"packageManager": "yarn@4.x.x"` (e.g. `"yarn@4.12.0"`)

---

### C-7: `package.json` — Missing `devDependencies`

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The `devDependencies` block is entirely absent. Both `@companion-module/tools` (provides `companion-module-build` for the `package` script and the shared Prettier config) and `prettier` are required.

**Template expects:**
```json
"devDependencies": {
  "@companion-module/tools": "^2.6.1",
  "prettier": "^3.7.4"
}
```

---

### C-8: `package.json` — `repository.url` missing `git+` prefix

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `package.json`

The npm/Yarn toolchain expects the `git+https://` URL scheme for repository entries.

**Found:** `"url": "https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`
**Expected:** `"url": "git+https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`

---

### C-9: `manifest.json` — `repository` missing `git+` prefix

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW — Template Compliance
- **File:** `companion/manifest.json`

The `repository` URL in the manifest also uses the plain `https://` scheme.

**Found:** `"repository": "https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`
**Expected:** `"repository": "git+https://github.com/bitfocus/companion-module-noctavoxfilms-tallycomm.git"`

---

## 🟠 High

### H-1: `init()` sets `InstanceStatus.Ok` before connection is verified

- **Severity:** 🟠 High
- **Classification:** 🆕 NEW
- **File:** `main.js:18`

`updateStatus(InstanceStatus.Ok)` is called synchronously at the top of `init()`, before `checkConnection()` has resolved. Because `checkConnection()` is intentionally not awaited and times out after 5 seconds, the Companion UI displays a green "OK" indicator for the full timeout window even when the server is unreachable. Operators relying on the `is_connected` feedback or `connected` variable will see a false-positive "online" state — and if the server never responds, permanently.

**Evidence:**
```js
async init(config) {
    // ...
    this.updateStatus(InstanceStatus.Ok)   // ← immediate Ok, before check
    this.initActions()
    this.initFeedbacks()
    this.initVariables()
    this.updateVariables()
    this.checkConnection()                 // ← async, not awaited
}
```

**Recommendation:** Set `InstanceStatus.Connecting` on init; let `checkConnection()` transition to `Ok` or `ConnectionFailure`:
```js
this.updateStatus(InstanceStatus.Connecting)
// ... init actions/feedbacks/variables ...
this.checkConnection()
```

---

## 🟡 Medium

### M-1: `legacyIds` contains `"tallycomm"` on a first release

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `companion/manifest.json`

`legacyIds` is set to `["tallycomm"]` on what is presented as a first release. `legacyIds` is used to migrate user configs from a prior module ID. If no prior module with ID `"tallycomm"` was ever shipped, this field should be `[]`.

**Recommendation:** Confirm whether a prior module with ID `"tallycomm"` was ever shipped through the official Bitfocus channel. If not, set `"legacyIds": []`.

---

### M-2: `@companion-module/base` version outdated

- **Severity:** 🟡 Medium
- **Classification:** 🆕 NEW
- **File:** `package.json`

The module pins `^1.12.1`. The current JS template baseline is `~1.14.1`.

**Recommendation:** Update to `"@companion-module/base": "~1.14.1"` to align with the current template.

---

## 🧪 Tests

No test files found (`*.test.js`, `*.spec.js`, `__tests__/`). No test framework (Jest/Vitest) configured. No `test` script in `package.json`.

**Status: ✅ Non-blocking.** Absence of tests is expected for a first-release single-file module. The logic is simple enough to be well-covered by manual integration testing against a live TallyComm instance.

---

## ✅ What's Solid

Despite the extensive template compliance failures and protocol lifecycle issues, the **functional module logic is genuinely well-designed**:

- **Actions (6):** `set_pgm`, `set_pvw`, `clear_cam`, `clear_all`, `set_pgm_auto`, `set_pvw_auto` — all structurally correct with proper async `callback` signatures. The "auto-clear previous" variants (`set_pgm_auto`, `set_pvw_auto`) are thoughtful ergonomic additions that reduce required action count for switcher integrations
- **Feedbacks (3):** `cam_pgm`, `cam_pvw`, `is_connected` — correctly typed as `type: 'boolean'` with appropriate `defaultStyle` color values. `is_connected` feedback is a practical addition for panel-based status indication
- **Variables (4):** `pgm`, `pvw`, `room`, `connected` — well-named, appropriate scope, correctly registered and updated
- **`clear_all` edge case:** Correctly handles the `currentPgm === currentPvw` overlap — only one `clear` sent, no duplicate requests
- **`AbortSignal.timeout(5000)`** used consistently in both `sendTally()` and `checkConnection()` — no indefinitely-hanging requests
- **`sendTally()` `response.ok` check** is correct — non-ok HTTP responses are properly surfaced as errors (the same pattern just needs to be applied in `checkConnection()`)
- **URL trailing-slash normalization** (`replace(/\/$/, '')`) is a small but correct defensive touch that prevents malformed API URLs
- **`configUpdated()` triggers `checkConnection()`** — re-verifying connectivity on config save is correct behavior
- **`runEntrypoint(TallyCommInstance, [])`** — empty upgrade scripts array is correctly supplied for a first release
- **`README.md`** is thorough and well-structured with a practical ATEM switcher integration example — this content can be directly adapted for `companion/HELP.md`
- **`.github/workflows/companion-module-checks.yaml`** — CI workflow is wired up correctly
