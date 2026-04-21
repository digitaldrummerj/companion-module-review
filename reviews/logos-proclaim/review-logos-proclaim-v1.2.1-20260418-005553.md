# Re-Review: logos-proclaim @ v1.2.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-logos-proclaim` |
| **Tag** | `v1.2.1` |
| **Commit** | `577f39c` |
| **Previous reviewed version** | `v1.2.0` |
| **Reviewed** | 2026-04-18 |
| **Reviewer** | Copilot |
| **API version** | v1.x (`@companion-module/base ~1.14.1`) |
| **Module type** | JavaScript / ESM |
| **Release diff** | `package.json`, `src/api.js`, `src/feedbacks.js`, `src/main.js`, `src/presets.js`, `src/upgrades.js`, `src/variables.js`, `yarn.lock` |
| **Validation** | ❌ `yarn lint` · ✅ `yarn package` |

---

## Verdict

### ⚠️ CHANGES REQUIRED

`v1.2.1` is a real corrective follow-up: all previously reported functional and advisory findings from the `v1.2.0` review are fixed. The resubmission is still not ready to accept because the submitted tag no longer passes `yarn lint`; it now fails with three ESLint/Prettier errors in `src/api.js` and `src/upgrades.js`.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 1 | 0 | 1 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **1** | **0** | **1** |

**Blocking:** 0 functional blockers  
**Acceptance blockers:** 1 release-delta validation issue  
**Health delta:** 9 prior findings fixed · 1 new issue introduced

---

## Fix Verification (`v1.2.0` review → `v1.2.1`)

| ID | Prior finding | Status | Notes |
|----|---------------|--------|-------|
| C1 | `src/api.js` used `this.log()` inside `sendAppCommand()` | ✅ Fixed | Now uses `this.instance.log(...)` in `src/api.js:212` |
| C2 | `src/api.js` dereferenced `error.response.statusCode` without a null check | ✅ Fixed | `sendAppCommand()` now uses `error.response?.statusCode` in `src/api.js:216` |
| H2 | `getAuthToken()` swallowed non-401 failures | ✅ Fixed | `src/api.js:164` now logs auth failures and updates status |
| L1 | Config field used deprecated `isVisible` callback | ✅ Fixed | Replaced with `isVisibleExpression` in `src/main.js:77` |
| L2 | Password field used `textinput` instead of `secret-text` | ✅ Fixed | Password field is now `secret-text` in `src/main.js:73` |
| M1 | `onair_poll()` used `console.log(error)` | ✅ Fixed | Replaced with module logging in `src/api.js:123` |
| M2 | `onair_poll()` relied on undocumented magic number `30` | ✅ Fixed | Session-id check now uses `data.length > 0` in `src/api.js:101` |
| L3 | Weak equality remained in `src/api.js` | ✅ Fixed | Updated comparisons now use strict inequality in the reviewed paths |
| L4 | `async` wrappers had no `await` | ✅ Fixed | `src/feedbacks.js`, `src/presets.js`, and `src/variables.js` no longer export unnecessary `async` functions |

**Result:** 9 of 9 previously reported findings are fixed in `v1.2.1`.

---

## 🆕 New Issue Introduced

### M9: `v1.2.1` no longer passes `yarn lint`

**Classification:** 🆕 NEW  
**Severity:** 🟡 Medium  
**Files:** `src/api.js:99`, `src/upgrades.js:6`, `src/upgrades.js:18`

This tag introduces a new release-validation regression. The previous `v1.2.0` follow-up review validated cleanly with `yarn lint`, but `v1.2.1` now fails lint with three errors:

- `src/api.js:99` — `prettier/prettier`: stray indentation on a blank line
- `src/upgrades.js:6` — `no-unused-vars`: `props` is declared but never used
- `src/upgrades.js:18` — `prettier/prettier`: missing trailing comma

**Why this matters:** this is part of the submitted release delta, not an old advisory note. The functional fixes landed, but the release now reports a broken validation state in a clean checkout.

**Required fix:** make `yarn lint` pass cleanly for the submitted tag, then re-tag/resubmit. Removing or renaming the unused `props` argument and reformatting the touched files should clear the current errors.

---

## 🧪 Validation

- ❌ `yarn lint` — fails with 3 errors in `src/api.js` and `src/upgrades.js`
- ✅ `yarn package` — produced `logos-proclaim-1.2.1.tgz`
- ✅ No `package-lock.json` present in the module root

---

## ✅ What's Solid

- This is not a no-op resubmission: the previously reported runtime, status-handling, config, and advisory findings were all addressed.
- The password field migration to `secret-text` was carried through properly in both config handling and the new upgrade script.
- The module still packages cleanly for `v1.2.1`.

---

*Follow-up review constrained to the delta from the previously reviewed `v1.2.0` submission.*
