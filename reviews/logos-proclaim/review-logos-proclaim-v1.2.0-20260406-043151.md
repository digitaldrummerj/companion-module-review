# Review: logos-proclaim v1.2.0

**Module:** companion-module-logos-proclaim  
**Version:** v1.2.0 (diff from v1.1.1)  
**API:** `@companion-module/base ~1.14.1`  
**Runtime:** node22  
**Date:** 2026-04-06  
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Module Dev), Zoe (QA), Simon (Tests)

---

## Fix Summary for Maintainer

**Blocking fixes required:**
1. **C1** — `src/api.js:211`: Change `this.log()` → `this.instance.log()`
2. **C2** — `src/api.js:214`: Add null check: `error.response?.statusCode`
3. **H2** — `src/api.js:163-168`: Add null check and logging for non-401 errors in `getAuthToken()`

**Recommended (non-blocking):**
4. **L1** — `src/main.js:76`: Replace `isVisible: (configValues) => ...` with `isVisibleExpression: "configValues.ip !== '127.0.0.1'"`
5. **L2** — `src/main.js:72-78`: Change password field `type: 'textinput'` to `type: 'secret-text'`

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 2 | 2 |
| 🟠 High | 0 | 1 | 1 |
| 🟡 Medium | 0 | 2 | 2 |
| 🟢 Low | 2 | 2 | 4 |
| **Total** | **2** | **7** | **9** |

**Blocking:** 3 issues (2 pre-existing critical, 1 pre-existing high)  
**Fix complexity:** Medium — requires error handling refactors across api.js  
**Health delta:** 2 introduced · 7 pre-existing surfaced

---

## Verdict

**⚠️ CHANGES REQUIRED**

The v1.2.0 refactor is clean with no regressions, but 3 blocking issues must be addressed:
- 2 Critical: Method call bug + unsafe property access will crash module on errors
- 1 High PRE-EXISTING: Silent error suppression in getAuthToken()

---

## 📋 Issues

**Blocking**
- [ ] [C1: Incorrect method call `this.log()` in sendAppCommand()](#c1-incorrect-method-call-thislog-in-sendappcommand)
- [ ] [C2: Unsafe `error.response.statusCode` access crashes on network errors](#c2-unsafe-errorresponsestatuscode-access-crashes-on-network-errors)
- [ ] [H2: Silent error suppression in getAuthToken()](#h2-silent-error-suppression-in-getauthtoken)

**Non-blocking**
- [ ] [L1: Deprecated `isVisible` function pattern](#l1-deprecated-isvisible-function-pattern)
- [ ] [L2: Password field should use secret-text type](#l2-password-field-should-use-secret-text-type)

---

## 🔴 Critical

### C1: Incorrect method call `this.log()` in sendAppCommand()

**File:** `src/api.js`, line 211  
**Classification:** ⚠️ PRE-EXISTING

```javascript
this.log('debug', `Unexpected response from Proclaim: ${data}`)
```

**Issue:** `this.log()` does not exist on the `ProclaimAPI` class. Should be `this.instance.log()`. This will throw `TypeError: this.log is not a function` whenever Proclaim returns a response other than `"success"`.

**Fix:**
```javascript
this.instance.log('debug', `Unexpected response from Proclaim: ${data}`)
```

---

### C2: Unsafe `error.response.statusCode` access crashes on network errors

**File:** `src/api.js`, lines 214-218  
**Classification:** ⚠️ PRE-EXISTING

```javascript
} catch (error) {
    if (error.response.statusCode == 401 && this.proclaim_auth_required) {
        // ...
    }
}
```

**Issue:** `error.response` is accessed without null check. When `got` throws network errors (ETIMEDOUT, ECONNREFUSED, DNS failure), `error.response` is `undefined`, causing `Cannot read property 'statusCode' of undefined`.

**Impact:** Module crashes on any network failure during command execution.

**Fix:**
```javascript
} catch (error) {
    if (error.response?.statusCode == 401 && this.proclaim_auth_required) {
        this.proclaim_auth_successful = false
        this.proclaim_auth_token = ''
        this.setModuleStatus()
    } else {
        this.instance.log('warn', `Command failed: ${error.message}`)
    }
}
```

---

## 🟠 High

### H2: Silent error suppression in getAuthToken()

**File:** `src/api.js`, lines 163-168  
**Classification:** ⚠️ PRE-EXISTING

```javascript
} catch (error) {
    if (error.response && error.response.statusCode == 401 && this.proclaim_auth_required) {
        this.proclaim_auth_successful = false
        this.setModuleStatus()
    }
}
```

**Issue:** Non-401 errors (network timeouts, DNS failures, JSON parse errors) are silently swallowed with no logging and no status update. If authentication times out, the module shows "Connecting" status indefinitely.

**Fix:**
```javascript
} catch (error) {
    if (error.response?.statusCode == 401 && this.proclaim_auth_required) {
        this.proclaim_auth_successful = false
        this.setModuleStatus()
    } else {
        this.instance.log('warn', `Authentication error: ${error.message}`)
    }
}
```

---

## 🟢 Low

### L1: Deprecated `isVisible` function pattern

**File:** `src/main.js`, line 76  
**Classification:** 🆕 NEW  
**Severity:** 🟢 Low — non-blocking

```javascript
isVisible: (configValues) => configValues.ip !== '127.0.0.1'
```

**Issue:** The function form of `isVisible` was deprecated in v1.12 in favor of `isVisibleExpression`. It still works in v1.x but is not forward-compatible and will be removed in v2.x.

**Recommended fix:**
```javascript
isVisibleExpression: "configValues.ip !== '127.0.0.1'"
```

---

### L2: Password field should use secret-text type

**File:** `src/main.js`, lines 72-78  
**Classification:** 🆕 NEW  
**Severity:** 🟢 Low — non-blocking

```javascript
{
    type: 'textinput',
    id: 'password',
    label: 'Password',
    width: 6,
    isVisible: (configValues) => configValues.ip !== '127.0.0.1',
}
```

**Issue:** Password field uses `textinput` instead of `secret-text` (available since v1.13). Credentials will be visible in exported configurations.

**Recommended fix:** Change `type: 'textinput'` to `type: 'secret-text'`.

---

## ⚠️ Pre-existing Notes

Non-blocking issues carried forward from v1.1.1:

| # | Severity | File | Issue |
|---|----------|------|-------|
| 1 | Medium | `src/api.js:123` | Uses `console.log(error)` instead of `this.instance.log()` in `onair_poll()` |
| 2 | Medium | `src/api.js:101` | Magic number `30` for session ID length check — undocumented threshold |
| 3 | Low | `src/api.js:36, 210` | Uses `!=` instead of `!==` (weak equality) |
| 4 | Low | `src/feedbacks.js`, `presets.js`, `variables.js` | Functions declared `async` but contain no `await` |

---

## 🧪 Tests

No test suite detected. The module has no test files, test framework, or test scripts configured.

**Recommendation:** Add unit tests for API integration, error scenarios, and module lifecycle.

---

## ✅ What's Solid

**v1.x Architecture — All core requirements met:**
- `runEntrypoint(ProclaimInstance, UpgradeScripts)` correctly at bottom of `src/main.js:99`
- `UpgradeScripts` exported from `src/upgrades.js` and imported in `main.js`
- `init()`, `destroy()`, `configUpdated()`, `getConfigFields()` all implemented
- No `package-lock.json`, no committed `dist/`

**Clean Refactor — v1.2.0 reorganization is well-executed:**
- Source files properly moved from root to `src/` directory
- Modern tooling: Yarn 4, ESLint 9, Prettier 3
- Updated to `@companion-module/base ~1.14.1` with node22 runtime
- Dependencies updated: `got` v14.6.6, `@companion-module/tools` v2.7.1
- New actions added cleanly (Show Text, Custom Quick Screens, Show Last Slide)

**Template Compliance — Full pass from Kaylee:**
- All required files present and matching template exactly
- Build succeeds: `logos-proclaim-1.2.0.tgz` generated
- `package.json` and `manifest.json` fully compliant

**Protocol Handling — Good patterns from Wash:**
- Polling interval properly cleared in `destroy()`
- `configure()` clears old interval before creating new one
- `got` v14 used correctly with async/await
- Proper timeout (1000ms) and retry (disabled) configuration
- Smart auth retry logic when connection restored

**No Regressions:**
- Zero new bugs introduced in the refactor
- All 9 pre-existing issues were carried forward unchanged
- The v1.2.0 diff is clean organizational work

---

**End of Review**
