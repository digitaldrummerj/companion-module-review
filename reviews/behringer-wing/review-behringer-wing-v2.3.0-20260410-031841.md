# Review: behringer-wing v2.3.0

| Field | Value |
|-------|-------|
| **Module** | companion-module-behringer-wing |
| **Version** | v2.3.0 |
| **Previous Tag** | v2.3.0-beta.2 |
| **Language** | TypeScript |
| **API** | v1.x (`@companion-module/base ~1.13`) |
| **Protocol** | OSC over UDP (Behringer WING mixer) |
| **Review Date** | 2026-04-10 |
| **Reviewed By** | Mal, Wash, Kaylee, Zoe, Simon |

---

## 🛠️ Fix Summary for Maintainer

This release ships a **critical regression** and multiple **template compliance violations** that block approval. The functional scope of v2.3.0 is small (fader floor guards + version bump), but the `src/index.ts` change accidentally removed the connection error status update, making all OSC socket failures invisible in the Companion UI. This regression plus six pre-existing template compliance gaps and one identity mismatch must all be addressed before this release can be approved.

**Fixes required for approval:**

1. **C1 — Restore `updateStatus(InstanceStatus.ConnectionFailure)` in the connection error handler** (`src/index.ts:157`)
2. **C2 — Add `.gitattributes`** with `* text=auto eol=lf`
3. **C3 — Fix `.gitignore`** — replace `/pkg.tgz` with `/*.tgz`, remove `.DS_Store`, add `/.vscode`
4. **C4 — Add `engines` block** to `package.json` (`node: "^22.20"`, `yarn: "^4"`)
5. **C5 — Fix `repository.url`** in `package.json` to `git+https://github.com/bitfocus/companion-module-behringer-wing.git`
6. **C6 — Update `manifest.json` `runtime.type`** from `"node18"` to `"node22"`
7. **C7 — Update `tsconfig.build.json`** extends from `node18` to `node22`
8. **M1 — Align `package.json` `name`** with manifest `id`: change `"wing-companion"` to `"behringer-wing"`

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 6 | 7 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 1 | 1 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 0 | 0 | 0 |
| **Total** | **1** | **7** | **8** |

**Blocking:** 8 issues (1 new critical, 6 pre-existing critical, 1 pre-existing medium)
**Fix complexity:** Multiple config file changes
**Health delta:** 1 introduced · 6 pre-existing surfaced

---

## ✋ Verdict: CHANGES REQUIRED

Seven Critical issues and one Medium issue block approval. One Critical is a newly introduced regression (connection error status silently dropped); the remaining six Criticals are template compliance gaps carried forward from prior releases that must now be resolved. The Medium (`package.json` name mismatch) is also required for approval.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Connection error no longer updates module status](#c1-connection-error-no-longer-updates-module-status)
- [ ] [C2: `.gitattributes` file missing](#c2-gitattributes-file-missing)
- [ ] [C3: `.gitignore` content deviates from template](#c3-gitignore-content-deviates-from-template)
- [ ] [C4: `engines` field absent from `package.json`](#c4-engines-field-absent-from-packagejson)
- [ ] [C5: `repository.url` incorrect in `package.json`](#c5-repositoryurl-incorrect-in-packagejson)
- [ ] [C6: `manifest.json` `runtime.type` is `"node18"` — must be `"node22"`](#c6-manifestjson-runtimetype-is-node18--must-be-node22)
- [ ] [C7: `tsconfig.build.json` extends `node18` instead of `node22`](#c7-tsconfigbuildjson-extends-node18-instead-of-node22)
- [ ] [M1: `package.json` `name` field does not match module ID](#m1-packagejson-name-field-does-not-match-module-id)

---

## 🔴 Critical

### C1: Connection error no longer updates module status

- **Severity:** 🔴 Critical
- **Classification:** 🆕 NEW (regression introduced in v2.3.0)
- **File:** `src/index.ts:157–159`
- **Description:** The `connection?.on('error', ...)` handler was changed from calling `this.updateStatus(InstanceStatus.ConnectionFailure, err.message)` to only logging via `this.logger?.error(JSON.stringify(err))`. UDP socket errors (ECONNREFUSED, ENETUNREACH, EADDRINUSE, etc.) now produce zero visible status change in the Companion UI. The module will silently remain `Ok` or `Connecting` indefinitely after a fatal socket error, giving users no indication the connection is broken.
- **Evidence:**
  ```diff
  - this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
  + this.logger?.error(JSON.stringify(err))
  ```
- **Recommendation:** Restore `this.updateStatus(InstanceStatus.ConnectionFailure, err.message)`. If additional logging is also desired, do both:
  ```ts
  this.connection?.on('error', (err: Error) => {
      this.logger?.error(`OSC connection error: ${err.message}`)
      this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
  })
  ```

---

### C2: `.gitattributes` file missing

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `.gitattributes` (absent from repo root)
- **Description:** The template requires `.gitattributes` with `* text=auto eol=lf`. The file is entirely absent. Without it, line-ending normalization is undefined and cross-platform builds can diverge.
- **Template expects:**
  ```
  * text=auto eol=lf
  ```
- **Found:** File does not exist
- **Recommendation:** Add `.gitattributes` with the exact content above.

---

### C3: `.gitignore` content deviates from template

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `.gitignore`
- **Description:** Three deviations from the required TS template:
  1. `/pkg.tgz` instead of `/*.tgz` — only ignores one specific filename, not all tarballs at root
  2. `.DS_Store` present — macOS artifact, not in template
  3. `/.vscode` missing — required by TS template
- **Template expects (TS):**
  ```
  node_modules/
  package-lock.json
  /pkg
  /*.tgz
  DEBUG-*
  /.yarn
  /dist
  /.vscode
  ```
- **Found:**
  ```
  node_modules/
  package-lock.json
  /pkg
  /pkg.tgz
  /dist
  DEBUG-*
  /.yarn
  .DS_Store
  ```
- **Recommendation:** Replace `.gitignore` with the exact template content above.

---

### C4: `engines` field absent from `package.json`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `package.json`
- **Description:** The `engines` field is present but empty (`{}`). Both `engines.node` and `engines.yarn` are required to constrain the execution environment.
- **Template expects:**
  ```json
  "engines": {
    "node": "^22.20",
    "yarn": "^4"
  }
  ```
- **Found:** `"engines": {}`
- **Recommendation:** Add `node` and `yarn` constraint values to the `engines` block.

---

### C5: `repository.url` incorrect in `package.json`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `package.json`
- **Description:** The repository URL references the wrong GitHub slug (`companion-module-wing-companion`) which does not correspond to the actual repository.
- **Template expects:** `"git+https://github.com/bitfocus/companion-module-behringer-wing.git"`
- **Found:** `"git+https://github.com/bitfocus/companion-module-wing-companion.git"`
- **Recommendation:** Update the URL to the canonical `companion-module-behringer-wing` repository.

---

### C6: `manifest.json` `runtime.type` is `"node18"` — must be `"node22"`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `companion/manifest.json`
- **Description:** The runtime target is `"node18"`, which is end-of-life. The Companion module standard requires `"node22"`. This directly controls which Node.js runtime Companion uses to run the module.
- **Template expects:** `"type": "node22"`
- **Found:** `"type": "node18"`
- **Recommendation:** Update `runtime.type` to `"node22"`.

---

### C7: `tsconfig.build.json` extends `node18` instead of `node22`

- **Severity:** 🔴 Critical
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `tsconfig.build.json`
- **Description:** The build config extends `@companion-module/tools/tsconfig/node18/recommended`. This must be `node22` to match the current Companion module standard and align with the `manifest.json` runtime target.
- **Template expects:** `"extends": "@companion-module/tools/tsconfig/node22/recommended"`
- **Found:** `"extends": "@companion-module/tools/tsconfig/node18/recommended"`
- **Recommendation:** Update the `extends` value to `@companion-module/tools/tsconfig/node22/recommended`.

---

## 🟡 Medium

### M1: `package.json` `name` field does not match module ID

- **Severity:** 🟡 Medium
- **Blocking:** ✅ Yes
- **Classification:** ⚠️ PRE-EXISTING
- **File:** `package.json`
- **Description:** `"name": "wing-companion"` does not match the module's canonical ID in `manifest.json` (`"behringer-wing"`). The build tooling derives the tgz name from the manifest ID so the build output is correct, but the mismatch creates confusion in the npm ecosystem and is inconsistent with the repository name.
- **Recommendation:** Align `package.json` `"name"` with the manifest `"id"`: `"behringer-wing"`.

---

## 🧪 Tests

No test framework detected (no jest or vitest dependency, no test files). Absence of tests is **not blocking** per team policy.

The module contains 80 TypeScript files across ~2,228 lines of core logic. The modular handler architecture (`ConnectionHandler`, `StateHandler`, `FeedbackHandler`, `VariableHandler`) would support unit testing well. Priority areas for future test coverage: state management, command handling, action execution (especially the fader delta clamping logic introduced in this release), and feedback evaluation.

---

## ✅ What's Solid

- **Build passes cleanly** — `yarn install && yarn package` produces a valid `behringer-wing-2.3.0.tgz` with no errors
- **Well-modular architecture** — clean separation into `ConnectionHandler`, `StateHandler`, `FeedbackHandler`, `VariableHandler`, and `OscForwarder`; each handler owns its concerns
- **SDK lifecycle correctly structured** — `init` → `configUpdated` → `destroy` pattern followed; `runEntrypoint` used properly with `UpgradeScripts`
- **Upgrade script is substantive** — `upgrades.ts` includes a real migration (RecorderState feedback type conversion) with correct `CompanionStaticUpgradeScript` typing
- **Debounced message batching** — `debounceFn` with `maxWait` is well-tuned for high-frequency OSC state-dump traffic
- **`isVisibleExpression` adoption** in `choices/common.ts` is clean and thorough; helper functions are reusable and minimize expression duplication
- **FeedbackHandler poll health check** — using poll timeouts as a secondary health signal for UDP is a thoughtful defensive pattern
- **`configUpdated` guard flow** — IP regex validation before opening the socket prevents spurious connection attempts on bad config
- **`.prettierignore` and `.yarnrc.yml`** — both match template exactly
- **All required TS scripts present** — `postinstall`, `format`, `package`, `build`, `build:main`, `dev`, `lint:raw`, `lint`
- **`lint-staged` config** — correctly structured for TS/JS and CSS/JSON/MD files
- **`eslint.config.mjs`** — correctly uses `generateEslintConfig({ enableTypescript: true })`
- **`manifest.json` keywords** — empty `[]`, no banned terms
- **`@companion-module/tools` bump** (`^2.1.1` → `^2.6.1`) is a positive modernization step
- **No v2 API patterns backported** — module is clean on `@companion-module/base ~1.13`
