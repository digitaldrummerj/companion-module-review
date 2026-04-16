# Follow-up Review: prodlink-draw-on-slides @ v1.0.2

| Field | Value |
|-------|-------|
| **Module** | `companion-module-prodlink-draw-on-slides` |
| **Tag** | `v1.0.2` |
| **Commit** | `87b6568` |
| **Previous reviewed version** | `v1.0.0` (original review dated 2026-04-06) |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.12 (`@companion-module/base ~1.12.0`) |
| **Module type** | TypeScript / ESM |
| **Validation** | ⚠️ `corepack yarn install --immutable` fails (`YN0028: The lockfile would have been modified`) · ✅ `corepack yarn build` after a non-immutable install · ❌ `corepack yarn lint` (`command not found: eslint`) |

---

## Verdict

### ❌ CHANGES REQUIRED — v1.0.2 fixes almost all of the v1.0.0 review, but reproducible Yarn builds are still broken and the new lint script does not run

This review is constrained to the `v1.0.0` → `v1.0.2` release delta plus the prior prodlink-draw-on-slides review context. The maintainer fixed 14 of the 16 previously reported findings and did not introduce any new runtime regressions in `src/main.ts`, `src/api.ts`, `src/actions.ts`, or `src/feedbacks.ts`, but the original duplicate lockfile blocker is still not actually resolved and the new lint wiring is incomplete.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 1 | 1 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 1 | 0 | 1 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **1** | **1** | **2** |

**Blocking:** 1 issue (1 carried-forward critical)  
**Fix complexity:** Quick — regenerate the Yarn 4 lockfile correctly and add the missing lint dependency  
**Health delta:** 1 introduced · 1 pre-existing carried forward

---

## Fix Verification (v1.0.0 → v1.0.2)

**14 of 16 prior release findings are fixed in this patch.**

### Fixed in v1.0.2

| ID | Prior finding | Severity | Resolution |
|----|---------------|----------|------------|
| C1 | Add fetch timeout in `src/api.ts` | 🔴 Critical | ✅ **Fixed** — `request()` now wraps `fetch()` with `AbortController` and a 5-second timeout (`src/api.ts:83-103`). |
| C2 | Add `.catch()` handler to initial poll | 🔴 Critical | ✅ **Fixed** — the immediate poll now has explicit error handling before scheduling the next cycle (`src/main.ts:162-169`). |
| C3 | Protect immediate poll with `isPolling` guard | 🔴 Critical | ✅ **Fixed** — the first poll now uses the same `isPolling` gate as scheduled polls (`src/main.ts:162-169`). |
| C4 | Add missing `.gitattributes` | 🔴 Critical | ✅ **Fixed** — `.gitattributes` now contains the expected `* text=auto eol=lf` rule. |
| C5 | Add missing `.yarnrc.yml` | 🔴 Critical | ✅ **Fixed** — `.yarnrc.yml` now sets `nodeLinker: node-modules`. |
| C7 | Add `tsconfig.build.json` | 🔴 Critical | ✅ **Fixed** — `tsconfig.build.json` now exists and `tsconfig.json` correctly extends it. |
| C9 | Replace `any` usage with real types | 🔴 Critical | ✅ **Fixed** — `actions.ts` and `feedbacks.ts` now use `SlideDrawInstance` / `SettingsState` instead of `any`. |
| H1 | Add `@companion-module/tools` devDependency | 🟠 High | ✅ **Fixed** — `package.json` now includes `@companion-module/tools` and a proper lint/build script set. |
| M1 | Add `engines` field | 🟡 Medium | ✅ **Fixed** — `package.json` now declares `"node": ">=18"`. |
| M2 | Add `packageManager` field | 🟡 Medium | ✅ **Fixed** — `package.json` now declares `yarn@4.6.0`. |
| M3 | Upgrade manifest runtime from `node18` to `node22` | 🟡 Medium | ✅ **Fixed** — `companion/manifest.json` now uses `node22` and `apiVersion: "1.12.0"`. |
| M4 | Complete `.gitignore` | 🟡 Medium | ✅ **Fixed** — the missing template ignores were added. |
| M5 | Add ESLint configuration | 🟡 Medium | ✅ **Fixed** — `eslint.config.mjs` is now present. |
| M6 | Replace warn-only action error handling | 🟡 Medium | ✅ **Fixed** — action callbacks now log failures at `error` level instead of quietly downgrading them to warnings (`src/actions.ts`). |

### Still blocking

| ID | Finding | Severity | Current status |
|----|---------|----------|----------------|
| C6 / C8 | Commit a valid `yarn.lock` for reproducible builds | 🔴 Critical | ❌ **Not fixed** — the original review duplicated the lockfile finding, and the underlying blocker still remains. `v1.0.2` now includes `yarn.lock`, but with `packageManager: "yarn@4.6.0"` the release still fails `corepack yarn install --immutable` with `YN0028: The lockfile would have been modified`, so the submitted lockfile does not actually provide a reproducible Yarn 4 install. |

---

## New issues introduced in v1.0.2

### M7: New lint script is not runnable because `eslint` is not installed

**Classification:** 🆕 NEW  
**Severity:** 🟡 Medium  
**Files:** `package.json`, `eslint.config.mjs`

`v1.0.2` adds a proper `lint` script and an ESLint config, but the package set is incomplete: after install, `corepack yarn lint` fails immediately with `command not found: eslint`. The new review delta therefore introduces a broken validation path even though the config file itself is now present.

**Fix:** Add the missing lint runtime dependency set so `yarn lint` actually executes in a clean checkout, then regenerate and commit the resulting lockfile.

---

## 🧪 Validation

- ⚠️ `corepack yarn install --immutable` — fails because the committed `yarn.lock` would be rewritten
- ✅ `corepack yarn build` — succeeds after allowing a non-immutable install in a scratch checkout
- ❌ `corepack yarn lint` — fails with `command not found: eslint`
- ℹ️ No test script is configured in `package.json`

---

## ✅ Still Solid

- The release delta is real and substantial: the timeout fix, first-poll guard, type cleanup, and template file additions all landed in the tagged code.
- Package and manifest versions now correctly report `1.0.2`.
- I did not find any new runtime regressions in the reviewed source delta beyond the packaging/build issues above.

---

*Follow-up review conducted by Mal only, constrained to the `v1.0.0` → `v1.0.2` release delta and prior prodlink-draw-on-slides review context.*
