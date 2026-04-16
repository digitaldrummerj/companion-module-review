# Follow-up Review: neol-epowerswitch @ v1.1.2

| Field | Value |
|-------|-------|
| **Module** | `companion-module-neol-epowerswitch` |
| **Tag** | `v1.1.2` |
| **Commit** | `e256304` |
| **Previous reviewed version** | `v1.1.1` (original review dated 2026-04-06; repo tag is `1.1.1`) |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.12 (`@companion-module/base ~1.12.0`) |
| **Module type** | JavaScript / ESM |
| **Validation** | ⚠️ `corepack yarn install --immutable` fails (`YN0028: The lockfile would have been modified`) · ❌ `corepack yarn lint` (`command not found: companion-module-lint`) · ✅ `corepack yarn package` after a non-immutable install · ✅ no `package-lock.json` in tag root |

---

## Verdict

### ❌ CHANGES REQUIRED — v1.1.2 fixes every blocker from the v1.1.1 review, but the tagged release introduces a broken Yarn 4 lockfile and a non-runnable lint script

This review is constrained to the `1.1.1` → `v1.1.2` release delta plus the prior neol-epowerswitch review context. The maintainer closed all 16 previously blocking findings and left only the prior advisory items untouched, but the submitted tag now fails immutable Yarn install validation and the newly added lint script does not execute.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 0 | 1 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 1 | 0 | 1 |
| 🟢 Low | 0 | 1 | 1 |
| 💡 Nice to Have | 0 | 4 | 4 |
| **Total** | **2** | **5** | **7** |

**Blocking:** 1 issue (1 new critical)  
**Fix complexity:** Quick — regenerate the tagged `yarn.lock` correctly and replace the lint command with a runnable script  
**Health delta:** 2 introduced · 5 pre-existing carried forward

---

## Fix Verification (v1.1.1 → v1.1.2)

**16 of 21 prior findings are fixed in this patch.**

### Fixed in v1.1.2

| ID | Prior finding | Severity | Resolution |
|----|---------------|----------|------------|
| C1 | Root `index.js` wrapper instead of `src/main.js` | 🔴 Critical | ✅ **Fixed** — root `index.js` was removed and `package.json` now points directly to `src/main.js`. |
| C2 | `manifest.json` `runtime.entrypoint` must be `../src/main.js` | 🔴 Critical | ✅ **Fixed** — `companion/manifest.json` now uses `../src/main.js`. |
| C3 | `package.json` missing `format` script | 🔴 Critical | ✅ **Fixed** — `package.json` now includes `"format": "prettier -w ."`. |
| C4 | `package.json` `build` script must be named `package` | 🔴 Critical | ✅ **Fixed** — the script is now `"package": "companion-module-build"`. |
| C5 | `package.json` `engines.node` must be `^22.x` | 🔴 Critical | ✅ **Fixed** — `engines.node` is now `^22.x`. |
| C6 | `package.json` missing `engines.yarn` field | 🔴 Critical | ✅ **Fixed** — `engines.yarn` is now declared as `^4`. |
| C7 | `package.json` `prettier` field points to wrong path | 🔴 Critical | ✅ **Fixed** — the `prettier` field now points to `@companion-module/tools/.prettierrc.json`. |
| C8 | `package.json` `repository.url` missing `git+` prefix | 🔴 Critical | ✅ **Fixed** — repository URL now uses the required `git+https://...` form. |
| C9 | `manifest.json` `repository` URL missing `git+` prefix | 🔴 Critical | ✅ **Fixed** — manifest repository now uses the `git+https://...` form. |
| C10 | `manifest.json` banned keywords present | 🔴 Critical | ✅ **Fixed** — `neol` and `epowerswitch` were removed from `keywords`. |
| H1 | `.prettierignore` contains extra entries beyond template | 🟠 High | ✅ **Fixed** — `.prettierignore` now contains only `package.json` and `/LICENSE.md`. |
| H2 | `manifest.json` `runtime.type` is `node18` | 🟠 High | ✅ **Fixed** — manifest runtime now declares `node22`. |
| H3 | `@companion-module/tools` peer dependency mismatch | 🟠 High | ✅ **Fixed** — `@companion-module/base` was raised to `~1.12.0`, matching the tools peer range. |
| M1 | `.gitignore` missing `dist/` and build artifacts | 🟡 Medium | ✅ **Fixed** — `.gitignore` now includes `dist/`, logs, editor files, and common local artifacts. |
| M2 | Upgrade scripts are dead code from another module | 🟡 Medium | ✅ **Fixed** — `src/upgrade.js` now exports an empty upgrade script array. |
| M3 | `configUpdated()` missing explicit `stopPolling()` call | 🟡 Medium | ✅ **Fixed** — `src/main.js` now stops polling before reinitializing config/state. |

### Still open (advisory only)

| ID | Finding | Severity | Current status |
|----|---------|----------|----------------|
| L1 | Swallowed poll errors provide no persistent-failure signal | 🟢 Low | ⚠️ **PRE-EXISTING** — `pollStatus(self).catch(() => {})` still appears in the immediate poll, interval poll, and early refresh paths. |
| N1 | Use `Connecting` during startup instead of `Ok` | 💡 Nice to Have | ⚠️ **PRE-EXISTING** — `init()` and `configUpdated()` still set `InstanceStatus.Ok` before a successful device poll. |
| N2 | Default config object duplicated in `init()` and `configUpdated()` | 💡 Nice to Have | ⚠️ **PRE-EXISTING** — the same default config object is still duplicated in both methods. |
| N3 | Error logs missing URL/outlet context | 💡 Nice to Have | ⚠️ **PRE-EXISTING** — polling and command error logs are still generic and do not include the target URL/outlet. |
| N4 | Action and feedback descriptions are too technical | 💡 Nice to Have | ⚠️ **PRE-EXISTING** — the action and feedback descriptions still expose `hidden.htm` internals instead of plain operator language. |

---

## New issues introduced in v1.1.2

### C11: Tagged Yarn 4 lockfile is stale, so the submitted release is not reproducible

**Classification:** 🆕 NEW  
**Severity:** 🔴 Critical  
**Files:** `package.json`, `yarn.lock`

`v1.1.2` updates the Yarn metadata and dependency set, but the committed `yarn.lock` in the tag does not match that package state. In a clean checkout of `v1.1.2`, `COREPACK_ENABLE_DOWNLOAD_PROMPT=0 corepack yarn install --immutable` fails with `YN0028: The lockfile would have been modified`, so the release does not provide a reproducible install.

**Fix:** Regenerate `yarn.lock` from the exact `v1.1.2` tree, commit it, and retag only once `corepack yarn install --immutable` passes cleanly.

---

### M4: New lint script points to a command that does not exist

**Classification:** 🆕 NEW  
**Severity:** 🟡 Medium  
**Files:** `package.json`

`package.json` line 20 adds `"lint": "companion-module-lint"`, but after install the command is not available: `corepack yarn lint` fails immediately with `command not found: companion-module-lint`. So the follow-up release added lint wiring, but not a runnable lint path.

**Fix:** Replace the script with the actual template lint command or another working ESLint invocation, then regenerate and commit the resulting lockfile.

---

## 🧪 Validation

- ⚠️ `COREPACK_ENABLE_DOWNLOAD_PROMPT=0 corepack yarn install --immutable` — fails with `YN0028: The lockfile would have been modified`
- ❌ `corepack yarn lint` — fails with `command not found: companion-module-lint`
- ✅ `corepack yarn package` — succeeds after allowing a non-immutable install and writes `neol-epowerswitch-1.1.2.tgz`
- ✅ No `package-lock.json` present in the `v1.1.2` tag root
- ℹ️ No test script is configured in `package.json`

---

## ✅ Still Solid

- The `v1.1.2` delta genuinely addresses all of the v1.1.1 template blockers: entrypoint layout, manifest runtime, package metadata, `.prettierignore`, `.gitignore`, and dead upgrade scripts are all corrected in the tagged code.
- The only source-code logic change in `src/main.js` is the required `stopPolling(this)` teardown in `configUpdated()`, which is the right fix for the prior race-condition finding.
- `corepack yarn package` succeeds, package/manifest versions both report `1.1.2`, and the tag still avoids the forbidden `package-lock.json`.

---

*Follow-up review conducted by Mal only, constrained to the `1.1.1` → `v1.1.2` release delta and prior neol-epowerswitch review context.*
