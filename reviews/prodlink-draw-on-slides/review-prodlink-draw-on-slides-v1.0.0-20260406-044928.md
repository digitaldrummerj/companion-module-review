# Review: prodlink-draw-on-slides v1.0.0

**Module:** companion-module-prodlink-draw-on-slides  
**Version:** v1.0.0 (FIRST RELEASE)  
**Review Date:** 2026-04-06  
**API Version:** @companion-module/base ~1.11.0 (v1.x)  
**All Findings:** 🆕 NEW (first release — no pre-existing issues)

---

## Fix Summary for Maintainer

To unblock this release, fix these issues:

1. **C1:** Add fetch timeout in `src/api.ts:81-96` — wrap fetch with AbortController (5-10s timeout)
2. **C2:** Add `.catch()` handler to initial poll in `src/main.ts:163`
3. **C3:** Protect immediate poll with `isPolling` guard in `src/main.ts:163` to fix race condition
4. **C4:** Add missing `.gitattributes` file (required: `* text=auto eol=lf`)
5. **C5:** Add missing `.yarnrc.yml` file (required: `nodeLinker: node-modules`)
6. **C6:** Commit `yarn.lock` file (required for reproducible builds)
7. **C7:** Add `tsconfig.build.json` (required for TS module builds)
8. **H3-H5:** Handle JSON parse errors, fix toggle race, add type validation in actions

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 7 | 0 | 7 |
| 🟠 High | 3 | 0 | 3 |
| 🟡 Medium | 6 | 0 | 6 |
| 🟢 Low | 9 | 0 | 9 |
| 💡 Nice to Have | 2 | 0 | 2 |
| **Total** | **27** | **0** | **27** |

**Blocking:** 10 issues (7 critical, 3 high)  
**Fix complexity:** Medium — requires timeout implementation, file additions, and validation logic  
**Health delta:** 27 introduced · 0 pre-existing (first release)

---

## Verdict

**🔴 CHANGES REQUIRED**

Module has correct v1.x architecture but is blocked by 10 issues: missing fetch timeout, unhandled promise rejection, polling race condition, missing template infrastructure files (.gitattributes, .yarnrc.yml, yarn.lock, tsconfig.build.json), and protocol robustness issues.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing fetch timeout leads to indefinite hangs](#c1-missing-fetch-timeout-leads-to-indefinite-hangs)
- [ ] [C2: Unhandled promise rejection in initial poll](#c2-unhandled-promise-rejection-in-initial-poll)
- [ ] [C3: Race condition in polling state machine](#c3-race-condition-in-polling-state-machine)
- [ ] [C4: Missing .gitattributes](#c4-missing-gitattributes)
- [ ] [C5: Missing .yarnrc.yml](#c5-missing-yarnrcyml)
- [ ] [C6: Missing yarn.lock](#c6-missing-yarnlock)
- [ ] [C7: Missing tsconfig.build.json](#c7-missing-tsconfigbuildjson)
- [ ] [H3: JSON parsing failure not caught](#h3-json-parsing-failure-not-caught)
- [ ] [H4: Toggle action race condition](#h4-toggle-action-race-condition)
- [ ] [H5: Type coercion safety in action callbacks](#h5-type-coercion-safety-in-action-callbacks)

**Non-blocking**
- [ ] [M2: Missing .prettierignore](#m2-missing-prettierignore)
- [ ] [M3: Incomplete .gitignore](#m3-incomplete-gitignore)
- [ ] [M4: Missing eslint config](#m4-missing-eslint-config)
- [ ] [M5: Missing null checks in feedback callbacks](#m5-missing-null-checks-in-feedback-callbacks)
- [ ] [M8: Silent error suppression in action callbacks](#m8-silent-error-suppression-in-action-callbacks)
- [ ] [M9: No validation of user-provided color values](#m9-no-validation-of-user-provided-color-values)
- [ ] [L1: Missing yarn.lock (arch)](#l1-missing-yarnlock-arch)
- [ ] [L2: Missing engines field](#l2-missing-engines-field)
- [ ] [L3: Missing packageManager field](#l3-missing-packagemanager-field)
- [ ] [L4: Missing @companion-module/tools devDependency](#l4-missing-companion-moduletools-devdependency)
- [ ] [L5: Using any type for instance parameter](#l5-using-any-type-for-instance-parameter)
- [ ] [L8: No cleanup of pollTimer on consecutive failures](#l8-no-cleanup-of-polltimer-on-consecutive-failures)
- [ ] [L9: Boolean settings type-checked at runtime](#l9-boolean-settings-type-checked-at-runtime)
- [ ] [L10: No validation of Bonjour device format](#l10-no-validation-of-bonjour-device-format)
- [ ] [L11: Color comparison edge cases](#l11-color-comparison-edge-cases)
- [ ] [N1: Consider upgrading manifest runtime to node22](#n1-consider-upgrading-manifest-runtime-to-node22)
- [ ] [N2: Type safety in actions/feedbacks](#n2-type-safety-in-actionsfeedbacks)

---

## 🔴 Critical

### C1: Missing fetch timeout leads to indefinite hangs
**Classification:** 🆕 NEW  
**File:** `src/api.ts`, lines 81-96  
**Owner:** Wash

The `fetch()` call has no timeout configured. If the iPad becomes unresponsive but the TCP connection doesn't close (network partition, app freeze), the request will hang indefinitely.

**Impact:**
- During network issues, polling thread blocks indefinitely
- `isPolling` flag stays true, preventing all future polls
- Module becomes permanently stuck until restart

**Code:**
```typescript
const response = await fetch(url, options);
```

**Fix:** Add AbortController with 5-10 second timeout:
```typescript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);
const response = await fetch(url, { ...options, signal: controller.signal });
clearTimeout(timeoutId);
```

---

### C2: Unhandled promise rejection in initial poll
**Classification:** 🆕 NEW  
**File:** `src/main.ts`, line 163  
**Owner:** Wash, Zoe

The immediate first poll is fire-and-forget with no error handling:

```typescript
this.pollState().then(() => scheduleNext())
```

If the initial poll throws, the rejection is unhandled and `scheduleNext()` is never called — polling silently stops.

**Fix:**
```typescript
this.pollState()
  .catch((e) => this.log('warn', `Initial poll failed: ${e}`))
  .then(() => scheduleNext());
```

---

### C3: Race condition in polling state machine
**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 147-164  
**Owner:** Zoe

The `isPolling` guard at line 150 doesn't protect the immediate poll at line 163. If the immediate poll completes quickly and calls `scheduleNext()` before the `isPolling` check runs, multiple polls can execute concurrently.

**Impact:**
- Multiple concurrent API calls to iPad
- Inconsistent variable/feedback states
- Connection failure counter corruption

**Fix:** Protect the immediate poll with the same `isPolling` guard, or refactor to a single entry point.

---

### C4: Missing .gitattributes
**Classification:** 🆕 NEW  
**File:** `.gitattributes`  
**Owner:** Kaylee

Required file is missing. Template requires:
```
* text=auto eol=lf
```

---

### C5: Missing .yarnrc.yml
**Classification:** 🆕 NEW  
**File:** `.yarnrc.yml`  
**Owner:** Kaylee

Required file is missing. Template requires:
```yaml
nodeLinker: node-modules
```

---

### C6: Missing yarn.lock
**Classification:** 🆕 NEW  
**File:** `yarn.lock`  
**Owner:** Kaylee

Lockfile is required for reproducible builds. Module cannot be deterministically built without a committed lockfile.

---

### C7: Missing tsconfig.build.json
**Classification:** 🆕 NEW  
**File:** `tsconfig.build.json`  
**Owner:** Kaylee

TypeScript modules require a separate build configuration. Template expects two-file structure:
- `tsconfig.build.json` — for compilation (extends `@companion-module/tools` config)
- `tsconfig.json` — for IDE/development (extends `tsconfig.build.json`)

---

## 🟠 High

### H3: JSON parsing failure not caught
**Classification:** 🆕 NEW  
**File:** `src/api.ts`, line 95  
**Owner:** Wash

`response.json()` can throw if response body is not valid JSON or empty:

```typescript
return response.json() as Promise<T>;
```

**Fix:**
```typescript
try {
  return await response.json() as T;
} catch (e) {
  throw new Error(`Invalid JSON response from ${url}: ${e}`);
}
```

---

### H4: Toggle action race condition
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, lines 290-305  
**Owner:** Wash

Toggle action reads current state, flips it, then writes. If user presses button twice rapidly, both reads see same value → toggle appears to fail.

**Fix:** Consider server-side toggle endpoint, or add debouncing/locking to action callback.

---

### H5: Type coercion safety in action callbacks
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, lines 67, 118, 235  
**Owner:** Zoe

Action callbacks use `String()` and `parseInt()` without validating results. If Companion passes `undefined`, this produces `NaN` for preset IDs or `"undefined"` strings for colors.

**Fix:**
```typescript
const presetId = parseInt(String(action.options.preset))
if (isNaN(presetId) || presetId < 1 || presetId > 3) {
  instance.log('error', `Invalid preset ID: ${action.options.preset}`)
  return
}
```

---

## 🟡 Medium

### M2: Missing .prettierignore
**Classification:** 🆕 NEW  
**File:** `.prettierignore`  
**Owner:** Kaylee

Formatting config file missing. Template expects:
```
package.json
/LICENSE.md
```

---

### M3: Incomplete .gitignore
**Classification:** 🆕 NEW  
**File:** `.gitignore`  
**Owner:** Kaylee

Missing required entries: `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`, `/.vscode`

---

### M4: Missing eslint config
**Classification:** 🆕 NEW  
**File:** `eslint.config.mjs`  
**Owner:** Kaylee

TypeScript modules should include ESLint configuration. Not strictly blocking but important for code quality.

---

### M5: Missing null checks in feedback callbacks
**Classification:** 🆕 NEW  
**File:** `src/feedbacks.ts`, lines 31, 45, 59, 82, 126, 164  
**Owner:** Zoe

Feedback callbacks access `instance.presetState` without null checks. On module init, these are `null` until first poll. Returns `undefined` instead of `false` during connection.

**Fix:** Add explicit null checks: `if (!instance.presetState) return false`

---

### M8: Silent error suppression in action callbacks
**Classification:** 🆕 NEW  
**File:** `src/actions.ts` (all actions)  
**Owner:** Wash

All action callbacks catch errors and log as 'warn' with no visual feedback to user.

---

### M9: No validation of user-provided color values
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, lines 116-124  
**Owner:** Wash

User can input any string as color. No hex format validation before sending to API.

**Fix:** Validate hex format: `/^#[0-9A-Fa-f]{6}$/`

---

## 🟢 Low

### L1: Missing yarn.lock (arch)
**Classification:** 🆕 NEW  
**File:** (project root)  
**Owner:** Mal

No lock file present — Companion module repos should have `yarn.lock` for reproducible builds. (Note: Elevated to Critical in C6 per template requirements.)

---

### L2: Missing engines field
**Classification:** 🆕 NEW  
**File:** `package.json`  
**Owner:** Mal

No `engines` field specifying Node version. Recommended: `"engines": { "node": ">=18" }`

---

### L3: Missing packageManager field
**Classification:** 🆕 NEW  
**File:** `package.json`  
**Owner:** Mal

No `packageManager` field. Recommended: `"packageManager": "yarn@4.x.x"`

---

### L4: Missing @companion-module/tools devDependency
**Classification:** 🆕 NEW  
**File:** `package.json`  
**Owner:** Mal

The module doesn't include `@companion-module/tools` as a devDependency. Recommended for build tooling and type definitions.

---

### L5: Using any type for instance parameter
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, line 5; `src/feedbacks.ts`, line 5  
**Owner:** Wash

Type safety bypassed with `any`:
```typescript
export function getActions(instance: any): CompanionActionDefinitions
```

---

### L8: No cleanup of pollTimer on consecutive failures
**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 79-83  
**Owner:** Wash

If module hangs during long failure sequence, pollTimer continues running.

---

### L9: Boolean settings type-checked at runtime
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, line 296  
**Owner:** Wash

Runtime type check needed because state is cast to `any`. Should be caught at compile time.

---

### L10: No validation of Bonjour device format
**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 91-100  
**Owner:** Zoe

`resolveHostPort()` doesn't validate IP format or port range from Bonjour device string.

---

### L11: Color comparison edge cases
**Classification:** 🆕 NEW  
**File:** `src/feedbacks.ts`, lines 80-83  
**Owner:** Zoe

Color comparison doesn't handle `#` prefix inconsistency between API and user input.

---

## 💡 Nice to Have

### N1: Consider upgrading manifest runtime to node22
**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 21  
**Owner:** Mal

Manifest specifies `"type": "node18"`. Node 22 is available in API v1.11+ and recommended for security patches.

---

### N2: Type safety in actions/feedbacks
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, line 5; `src/feedbacks.ts`, line 6  
**Owner:** Mal

Instance parameter typed as `any` to avoid circular dependency. Consider defining a shared interface.

---

## 🧪 Tests

**No tests found** for prodlink-draw-on-slides v1.0.0.

- No test framework configured
- No test scripts in package.json
- No test files detected (`*.test.ts`, `*.spec.ts`, `__tests__/`)
- No test-related dependencies in devDependencies

This is noted for reference. Test coverage is not a blocking requirement for Companion modules but is recommended for protocol-heavy implementations.

---

## ✅ What's Solid

1. **Correct v1.x entry point:** `runEntrypoint(SlideDrawInstance, [])` called at bottom of `src/main.ts:284` — exactly right for v1.x modules.

2. **UpgradeScripts array present:** Empty array `[]` is correct for v1.0.0 first release with no prior versions to upgrade from.

3. **All lifecycle methods implemented:**
   - `init()` — properly initializes API, actions, variables, presets, feedbacks
   - `destroy()` — cleans up poll timer correctly
   - `configUpdated()` — handles runtime config changes
   - `getConfigFields()` — returns valid config panel

4. **Clean polling architecture:** Sequential polling with failure recovery prevents request queue buildup.

5. **Smart consolidated API endpoint:** Using `/api/state` instead of 4 separate calls reduces HTTP overhead and race conditions — excellent API design.

6. **Proper cleanup in destroy():** Poll timer is correctly cleared and set to null.

7. **No listener leaks:** Module uses polling, not event listeners. No persistent connections.

8. **Graceful degradation on API failure:** Status updates to ConnectionFailure appropriately. Module continues retrying.

9. **Bonjour device discovery integration:** Clean handling of auto-discovered vs. manual IP/port configuration.

10. **Automatic port recovery:** Port scanning feature handles iPad app restarts gracefully — innovative approach.

11. **Comprehensive presets:** 70+ button presets covering all module functionality — users get immediate value.

12. **Good HELP.md:** Comprehensive, well-documented user guide (85 lines) covering setup, configuration, features, and variables.

13. **Correct LICENSE file:** MIT License with proper structure and real author attribution.

---

**Review by:** Mal (Lead), with findings from Wash (Protocol), Kaylee (Template), Zoe (QA), Simon (Tests)  
**End of Review**
