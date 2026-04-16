# Re-Review: logos-proclaim @ v1.2.0

| Field | Value |
|-------|-------|
| **Module** | `companion-module-logos-proclaim` |
| **Tag** | `v1.2.0` |
| **Commit** | `26b2e85` |
| **Previous reviewed version** | `v1.2.0` |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v1.x (`@companion-module/base ~1.14.1`) |
| **Module type** | JavaScript / ESM |
| **Release diff** | `git diff v1.2.0 HEAD -- .` → `yarn.lock` only (picomatch 4.0.3 → 4.0.4) |
| **Validation** | ✅ `yarn lint` · ✅ `yarn package` |

---

## Verdict

### ⚠️ CHANGES REQUIRED

This follow-up stayed extremely narrow: the only checkout delta from `v1.2.0` is a transitive dependency bump in `yarn.lock`. None of the previously reported module findings were fixed, and no new release-delta issues were introduced.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 2 | 2 |
| 🟠 High | 0 | 1 | 1 |
| 🟡 Medium | 0 | 2 | 2 |
| 🟢 Low | 0 | 4 | 4 |
| **Total** | **0** | **9** | **9** |

**Blocking:** 3 issues (2 pre-existing critical, 1 pre-existing high)  
**Fix complexity:** Medium — the same `src/api.js` error-handling refactor is still required  
**Health delta:** 0 introduced · 9 pre-existing noted

---

## Fix Verification (`v1.2.0` review → current pending checkout)

| ID | Prior finding | Status | Notes |
|----|---------------|--------|-------|
| C1 | `src/api.js` uses `this.log()` inside `ProclaimAPI.sendAppCommand()` | ❌ Not fixed | Line 211 still calls `this.log(...)` instead of `this.instance.log(...)` |
| C2 | `src/api.js` dereferences `error.response.statusCode` without a null check | ❌ Not fixed | Line 214 still crashes on network-level `got` errors |
| H2 | `src/api.js:getAuthToken()` swallows non-401 failures | ❌ Not fixed | Catch block still only handles 401 and leaves other failures silent |
| L1 | Config field still uses deprecated `isVisible` callback | ❌ Not fixed | `src/main.js:76` still uses function-form `isVisible` |
| L2 | Password field still uses `textinput` instead of `secret-text` | ❌ Not fixed | `src/main.js:72-78` unchanged |

**Result:** 0 of 5 headline findings were fixed. The four advisory pre-existing notes from the prior review also remain unchanged.

---

## 📋 Issues

**Blocking**
- [ ] [C1: `this.log()` call in `sendAppCommand()` still crashes non-success responses](#c1-thislog-call-in-sendappcommand-still-crashes-non-success-responses)
- [ ] [C2: `error.response.statusCode` access still crashes on network errors](#c2-errorresponsestatuscode-access-still-crashes-on-network-errors)
- [ ] [H2: `getAuthToken()` still swallows non-401 failures](#h2-getauthtoken-still-swallows-non-401-failures)

**Non-blocking**
- [ ] [L1: Password field still uses deprecated `isVisible` callback](#l1-password-field-still-uses-deprecated-isvisible-callback)
- [ ] [L2: Password field still uses `textinput` instead of `secret-text`](#l2-password-field-still-uses-textinput-instead-of-secret-text)

---

## 🔴 Critical

### C1: `this.log()` call in `sendAppCommand()` still crashes non-success responses

**File:** `src/api.js:211`  
**Classification:** ⚠️ PRE-EXISTING

```javascript
this.log('debug', `Unexpected response from Proclaim: ${data}`)
```

`ProclaimAPI` still has no `log()` method. If Proclaim returns anything other than `'success'`, this path still throws `TypeError: this.log is not a function` instead of logging the unexpected response.

**Required fix:**
```javascript
this.instance.log('debug', `Unexpected response from Proclaim: ${data}`)
```

---

### C2: `error.response.statusCode` access still crashes on network errors

**File:** `src/api.js:214-218`  
**Classification:** ⚠️ PRE-EXISTING

```javascript
} catch (error) {
if (error.response.statusCode == 401 && this.proclaim_auth_required) {
```

The unsafe dereference is unchanged. When `got` throws a timeout, DNS error, or connection refusal, `error.response` is `undefined`, so this handler still crashes while processing the original failure.

**Required fix:** use `error.response?.statusCode` and log non-401 failures.

---

## 🟠 High

### H2: `getAuthToken()` still swallows non-401 failures

**File:** `src/api.js:163-168`  
**Classification:** ⚠️ PRE-EXISTING

```javascript
} catch (error) {
if (error.response && error.response.statusCode == 401 && this.proclaim_auth_required) {
this.proclaim_auth_successful = false
this.setModuleStatus()
}
}
```

This is still the same bug from the prior review: authentication timeouts, other HTTP failures, and parse/runtime errors are silently ignored. The module can stay stuck without any useful log output explaining why auth never succeeded.

**Required fix:** keep the 401 handling, but also log and surface the non-401 error path.

---

## 🟢 Low

### L1: Password field still uses deprecated `isVisible` callback

**File:** `src/main.js:76`  
**Classification:** ⚠️ PRE-EXISTING

```javascript
isVisible: (configValues) => configValues.ip !== '127.0.0.1'
```

The config field is unchanged from the prior review. It still works on v1.x, but `isVisibleExpression` is the forward-compatible pattern.

---

### L2: Password field still uses `textinput` instead of `secret-text`

**File:** `src/main.js:72-78`  
**Classification:** ⚠️ PRE-EXISTING

The password field still uses plain `textinput`, so the password remains visible in exported configurations. This is still non-blocking, but it should move to `secret-text` on the next patch.

---

## New Issues Introduced

None. The only release delta is the `yarn.lock` picomatch bump, and it does not introduce any new module-facing review findings.

---

## ⚠️ Pre-existing Notes

| ID | Severity | File | Current status |
|----|----------|------|----------------|
| M1 | 🟡 Medium | `src/api.js:123` | Still uses `console.log(error)` in `onair_poll()` instead of module logging |
| M2 | 🟡 Medium | `src/api.js:101` | Still relies on undocumented magic number `30` for session-id length |
| L3 | 🟢 Low | `src/api.js:36,210` | Still uses weak equality (`!=`) |
| L4 | 🟢 Low | `src/feedbacks.js`, `src/presets.js`, `src/variables.js` | `async` wrappers still contain no `await` |

---

## 🧪 Tests

- ✅ `yarn lint`
- ✅ `yarn package`
- ℹ️ No `yarn test` script exists in `package.json`
- ✅ No `package-lock.json` present in the module root

---

## ✅ What's Solid

- The follow-up submission did not add any new source regressions.
- The repo still has the expected v1.x structure (`src/main.js`, lifecycle methods, `runEntrypoint(...)`, compliant metadata/scripts).
- Validation still passes cleanly despite the unresolved review findings.

---

*Follow-up review constrained to the release delta against the prior `v1.2.0` review, per request.*
