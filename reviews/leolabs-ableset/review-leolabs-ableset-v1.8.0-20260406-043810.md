# Module Review: leolabs-ableset v1.8.0

**Module:** companion-module-leolabs-ableset  
**Version:** v1.8.0 (diff from v1.7.3)  
**API:** @companion-module/base ~1.12.1 (v1.x)  
**Review Date:** 2026-04-06  
**Reviewers:** Mal (Lead), Kaylee (Template), Wash (Protocol), Zoe (QA), Simon (Tests)  
**Auto-fixes applied:** 2026-04-09 — C2, C3, C4, C5, C6, C7, C9, M5, M6, M7, L5, L6

---

## Fix Summary for Maintainer

1. **C1** — Add UpgradeScript for removed `SetAutoLoopCurrentSection` action (`src/main.ts`)
2. ~~**C2** — Handle removed `autoLoopCurrentSection` variable with migration path (`src/variables.ts`)~~ ✅ Fixed
3. ~~**C3** — Add `.gitattributes` file with `* text=auto eol=lf`~~ ✅ Fixed
4. ~~**C4** — Add `.yarnrc.yml` file with `nodeLinker: node-modules`~~ ✅ Fixed
5. ~~**C5** — Update `package.json` `engines.node` from `>=17` to `^22.20`~~ ✅ Fixed
6. ~~**C6** — Add `engines.yarn: "^4"` to `package.json`~~ ✅ Fixed
7. ~~**C7** — Add `packageManager` field to `package.json`~~ ✅ Fixed
8. ~~**C9** — Add `tsconfig.build.json` extending node22 config, update build script to use it~~ ✅ Fixed

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2 | 6 | 8 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 4 | 4 | 8 |
| 🟢 Low | 1 | 1 | 2 |
| **Total** | **7** | **11** | **18** |

**Blocking:** 1 issue remaining (C1) — 7 of 8 auto-fixed 2026-04-09  
**Fix complexity:** Medium — upgrade script logic + template file additions  
**Health delta:** 7 introduced · 11 pre-existing surfaced

---

## Verdict

🔴 **Changes Required**

7 of 8 blocking issues auto-fixed (2026-04-09). One blocker remains: C1 — missing UpgradeScript for the removed `SetAutoLoopCurrentSection` action. Implement the UpgradeScript to clear this for approval.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing UpgradeScript for removed SetAutoLoopCurrentSection action](#c1-missing-upgradescript-for-removed-setautoloopcurrentsection-action)
- [x] [C2: Removed variable without migration](#c2-removed-variable-without-migration)
- [x] [C3: Missing .gitattributes file](#c3-missing-gitattributes-file)
- [x] [C4: Missing .yarnrc.yml file](#c4-missing-yarnrcyml-file)
- [x] [C5: Incorrect engines.node version](#c5-incorrect-enginesnode-version)
- [x] [C6: Missing engines.yarn field](#c6-missing-enginesyarn-field)
- [x] [C7: Missing packageManager field](#c7-missing-packagemanager-field)
- [x] [C9: Missing tsconfig.build.json and using node18 config](#c9-missing-tsconfigbuildjson-and-using-node18-config)

**Non-blocking**
- [ ] [M1: Dead enum entry SetAutoLoopCurrentSection](#m1-dead-enum-entry-setautoloopcurrentsection)
- [ ] [M2: Division by zero in progress calculations](#m2-division-by-zero-in-progress-calculations)
- [ ] [M3: Array access without bounds check](#m3-array-access-without-bounds-check)
- [ ] [M4: Missing null check in SettingEqualsValue](#m4-missing-null-check-in-settingequalsvalue)
- [x] [M5: Incorrect .gitignore content](#m5-incorrect-gitignore-content)
- [x] [M6: Build scripts dont match template](#m6-build-scripts-dont-match-template)
- [x] [M7: Manifest name field mismatch](#m7-manifest-name-field-mismatch)
- [ ] [L2: Inconsistent type coercion in queued feedbacks](#l2-inconsistent-type-coercion-in-queued-feedbacks)
- [x] [L5: Missing husky pre-commit hook](#l5-missing-husky-pre-commit-hook)
- [x] [L6: Missing types-node dependency](#l6-missing-types-node-dependency)

---

## 🔴 Critical

### C1: Missing UpgradeScript for removed SetAutoLoopCurrentSection action

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 958–970 (removed) / `src/enums.ts`, line 63

The `SetAutoLoopCurrentSection` action was removed in v1.8.0 but no UpgradeScript was added. Users with saved buttons using this action will have orphaned/broken configurations that silently fail after upgrading.

**Fix Required:** Add an UpgradeScript that removes the action from saved buttons cleanly or converts it to a no-op.

---

### C2: Removed variable without migration

**Classification:** 🆕 NEW  
**Status:** ✅ Fixed  
**File:** `src/variables.ts`, line 113 (removed)

The variable `autoLoopCurrentSection` was removed. Any user expressions referencing `$(AbleSet:autoLoopCurrentSection)` will now show as undefined.

**Fix Applied:** Variable re-added to `src/variables.ts` with label indicating removal in v1.8.0; initialized to `false` in `src/main.ts` for backward compatibility.

---

### C3: Missing .gitattributes file

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `.gitattributes`

Required config file is missing entirely. Template expects:
```
* text=auto eol=lf
```

**Fix Applied:** `.gitattributes` created with `* text=auto eol=lf`.

---

### C4: Missing .yarnrc.yml file

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `.yarnrc.yml`

Required Yarn v4 configuration file is missing. Template expects:
```yaml
nodeLinker: node-modules
```

**Fix Applied:** `.yarnrc.yml` created with `nodeLinker: node-modules`.

---

### C5: Incorrect engines.node version

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `package.json`

**Expected:** `"node": "^22.20"`  
**Found:** `"node": ">=17"`

The constraint `>=17` is not semver-compatible with `^22.20` — it allows Node 17, 18, 19, 20, 21 which are not supported.

**Fix Applied:** Updated `engines.node` to `"^22.20"` in `package.json`.

---

### C6: Missing engines.yarn field

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `package.json`

The `engines.yarn` field is missing. Template expects `"yarn": "^4"`.

**Fix Applied:** Added `"yarn": "^4"` to `engines` in `package.json`.

---

### C7: Missing packageManager field

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `package.json`

The `packageManager` field is missing. Template expects `"packageManager": "yarn@4.x.x"`.

**Fix Applied:** Added `"packageManager": "yarn@4.12.0"` to `package.json`.

---

### C9: Missing tsconfig.build.json and using node18 config

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `tsconfig.build.json` (missing), `tsconfig.json`

Template expects a separate `tsconfig.build.json` extending `@companion-module/tools/tsconfig/node22/recommended`. Currently the module uses `tsconfig.json` directly which extends the outdated `node18` config.

**Fix Applied:** Created `tsconfig.build.json` extending `node22/recommended`. Updated `build:main` and `dev` scripts to use `tsconfig.build.json`. Added `rimraf dist &&` clean step to `build` script.

---

## 🟡 Medium

### M1: Dead enum entry SetAutoLoopCurrentSection

**Classification:** 🆕 NEW  
**File:** `src/enums.ts`, line 63

The enum value `SetAutoLoopCurrentSection = 'setAutoLoopCurrentSection'` still exists but the action implementation was removed. This is dead code.

**Fix:** Remove the unused enum entry.

---

### M2: Division by zero in progress calculations

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 1331, 1456

In `SongProgress` and `SectionProgress` feedbacks, division by zero can occur when `activeSongEnd === activeSongStart`:

```typescript
const totalPercent = (position - activeSongStart) / (activeSongEnd - activeSongStart)
```

**Fix:** Add guard: `const duration = activeSongEnd - activeSongStart; const totalPercent = duration > 0 ? (position - activeSongStart) / duration : 0`

---

### M3: Array access without bounds check

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, line 1289

In `SectionColor` feedback, `this.sectionColors[sectionNumber]` doesn't validate bounds. Out-of-bounds access returns `undefined`.

**Fix:** Add fallback: `const color = this.sectionColors[sectionNumber] ?? COLORS.black`

---

### M4: Missing null check in SettingEqualsValue

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 1683-1684

The feedback doesn't handle undefined settings:
```typescript
const value = String(this.getVariableValue(String(options.setting)))
return value === String(options.value)
```

If `getVariableValue` returns `undefined`, `String(undefined)` becomes `"undefined"`.

**Fix:** Add explicit undefined handling.

---

### M5: Incorrect .gitignore content

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `.gitignore`

Content doesn't match template:
- Missing: `/*.tgz`, `DEBUG-*`, `/.yarn`, `/.vscode`
- Extra: `main.js`
- Wrong: `dist/` should be `/dist`

**Fix Applied:** `.gitignore` updated to match template — removed `main.js`, corrected `dist/` to `/dist`, added all missing entries.

---

### M6: Build scripts dont match template

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `package.json`

Build scripts deviate from template:
- Missing `rimraf dist` clean step
- Uses `tsconfig.json` instead of `tsconfig.build.json`
- Custom post-build script for icons

Build passes, so functional but non-compliant.

**Fix Applied:** `build` script now runs `rimraf dist &&` before building; `build:main` and `dev` updated to use `tsconfig.build.json`. Icons step preserved.

---

### M7: Manifest name field mismatch

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `companion/manifest.json`

**Expected:** `"name": "leolabs-ableset"`  
**Found:** `"name": "AbleSet"`

The `name` field should match the `id` field per template specification.

**Fix Applied:** `name` updated to `"leolabs-ableset"` in `companion/manifest.json`.

---

## 🟢 Low

### L2: Inconsistent type coercion in queued feedbacks

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 1516, 1538

The feedbacks check `queuedSongIndex !== ''` which is semantically incorrect for numbers. Should check for `-1` or `undefined`.

---

### L5: Missing husky pre-commit hook

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `.husky/pre-commit`

Husky pre-commit hook is not committed to git. Dev tooling only.

**Fix Applied:** `.husky/pre-commit` created with `lint-staged` command and marked executable.

---

### L6: Missing types-node dependency

**Classification:** ⚠️ PRE-EXISTING  
**Status:** ✅ Fixed  
**File:** `package.json`

`@types/node` is missing from devDependencies. Build passes, so TypeScript hint only.

**Fix Applied:** Added `"@types/node": "^22.19.3"` to `devDependencies` in `package.json`.

---

## 🧪 Tests

**No automated tests found.**

- No `.test.ts`, `.spec.ts`, or `__tests__/` directories
- No test scripts in package.json
- No test framework configured

This is noted but not a blocking finding.

---

## ✅ What's Solid

1. **v1.x API compliance** — `runEntrypoint(ModuleInstance, [])` correctly called at bottom of `src/main.ts`
2. **Lifecycle methods** — `init()`, `destroy()`, `configUpdated()`, and `getConfigFields()` properly implemented
3. **destroy() cleanup** — Properly closes all OSC connections via `Promise.all()`
4. **No deprecated patterns** — No `isVisible` function form (v1.12 deprecation)
5. **Correct variable parsing** — Uses `ctx.parseVariablesInString()` context parameter
6. **No package-lock.json** — Only `yarn.lock` present (correct)
7. **dist/ gitignored** — Not committed to repo
8. **Manifest runtime** — Uses `node22` runtime (recommended)
9. **Error handling improvements** — Added `getErrorMessage()` helper for proper error extraction
10. **OSC protocol implementation** — Connection lifecycle, heartbeat monitoring, and reconnection logic are well-designed
11. **Error propagation** — Errors properly surfaced to user via logging and status updates
12. **New features** — Support for new AbleSet 3 settings (AbleNet, drift correction, etc.)
13. **Build passes** — Module builds and packages successfully

---

*Review assembled by Mal (Lead Reviewer)*
