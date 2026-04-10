# Review: prodlink-draw-on-slides v1.0.0

**Module:** companion-module-prodlink-draw-on-slides  
**Version:** v1.0.0 (FIRST RELEASE)  
**Review Date:** 2026-04-06  
**API Version:** @companion-module/base ~1.11.0 (v1.x)  
**All Findings:** 🆕 NEW (first release — no pre-existing issues)

---

## Fix Summary for Maintainer

To unblock this release, fix these issues:

1. **C1:** Add fetch timeout in `src/api.ts:81-96`
2. **C2:** Add `.catch()` handler to initial poll in `src/main.ts:163`
3. **C3:** Protect immediate poll with `isPolling` guard in `src/main.ts:163`
4. **C4:** Add missing `.gitattributes` file (required: `* text=auto eol=lf`)
5. **C5:** Add missing `.yarnrc.yml` file (required: `nodeLinker: node-modules`)
6. **C6:** Commit `yarn.lock` file (required for reproducible builds)
7. **C7:** Add `tsconfig.build.json` (required for TS module builds)
8. **C8:** Add `yarn.lock` for reproducible builds
9. **C9:** Replace all `any` type usages with proper TypeScript types throughout `src/actions.ts` and `src/feedbacks.ts`
10. **H1:** Fix toggle action race condition in `src/actions.ts:290-305`
11. **H2:** Add `@companion-module/tools` as devDependency in `package.json`
12. **H3:** Replace `any` type for instance parameter in `src/actions.ts:5` and `src/feedbacks.ts:5`
13. **M1:** Add `engines` field to `package.json`
14. **M2:** Add `packageManager` field to `package.json`
15. **M3:** Add logging for each failure when boolean settings type checks fail in `src/actions.ts:296`
16. **M4:** Upgrade manifest runtime from `node18` to `node22` in `companion/manifest.json:21`

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 9 | 0 | 9 |
| 🟠 High | 3 | 0 | 3 |
| 🟡 Medium | 9 | 0 | 9 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 0 | 0 | 0 |
| **Total** | **21** | **0** | **21** |

**Blocking:** 16 issues (9 critical, 3 high, 4 medium)  
**Fix complexity:** Medium — requires timeout implementation, file additions, and validation logic  
**Health delta:** 21 introduced · 0 pre-existing (first release)

---

## Verdict

**🔴 CHANGES REQUIRED**

Module has correct v1.x architecture but is blocked by 16 issues: missing fetch timeout, unhandled promise rejection, polling race condition, missing template infrastructure files (.gitattributes, .yarnrc.yml, yarn.lock, tsconfig.build.json), pervasive `any` type usage, missing devDependency, missing package.json fields, inadequate runtime type-check logging, and outdated manifest runtime.

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
- [ ] [C8: Missing yarn.lock](#c8-missing-yarnlock)
- [ ] [C9: Use of `any` type is not allowed](#c9-use-of-any-type-is-not-allowed)
- [ ] [H1: Toggle action race condition](#h1-toggle-action-race-condition)
- [ ] [H2: Missing @companion-module/tools devDependency](#h2-missing-companion-moduletools-devdependency)
- [ ] [H3: Using any type for instance parameter](#h3-using-any-type-for-instance-parameter)
- [ ] [M1: Missing engines field](#m1-missing-engines-field)
- [ ] [M2: Missing packageManager field](#m2-missing-packagemanager-field)
- [ ] [M3: Boolean settings type-checked at runtime](#m3-boolean-settings-type-checked-at-runtime)
- [ ] [M4: Consider upgrading manifest runtime to node22](#m4-consider-upgrading-manifest-runtime-to-node22)

**Non-blocking**
- [ ] [M5: Incomplete .gitignore](#m5-incomplete-gitignore)
- [ ] [M6: Missing eslint config](#m6-missing-eslint-config)
- [ ] [M7: Missing null checks in feedback callbacks](#m7-missing-null-checks-in-feedback-callbacks)
- [ ] [M8: Silent error suppression in action callbacks](#m8-silent-error-suppression-in-action-callbacks)
- [ ] [M9: No validation of user-provided color values](#m9-no-validation-of-user-provided-color-values)

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

### C8: Missing yarn.lock
**Classification:** 🆕 NEW  
**File:** (project root)  
**Owner:** Mal

No lock file present — Companion module repos should have `yarn.lock` for reproducible builds.

---

### C9: Use of `any` type is not allowed
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, `src/feedbacks.ts`  
**Owner:** Zoe

Using the `any` type is not recommended in TypeScript and should not be used. Code should be updated to use the real/proper type throughout the module. This bypasses TypeScript's type safety guarantees and can hide runtime errors.

**Fix:** Replace all `any` type usages with proper TypeScript types. Define a shared interface or import the correct type to avoid circular dependencies.

---

## 🟠 High

### H1: Toggle action race condition
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, lines 290-305  
**Owner:** Wash

Toggle action reads current state, flips it, then writes. If user presses button twice rapidly, both reads see same value → toggle appears to fail.

**Fix:** Consider server-side toggle endpoint, or add debouncing/locking to action callback.

---

### H2: Missing @companion-module/tools devDependency
**Classification:** 🆕 NEW  
**File:** `package.json`  
**Owner:** Mal

The module doesn't include `@companion-module/tools` as a devDependency. Recommended for build tooling and type definitions.

---

### H3: Using any type for instance parameter
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, line 5; `src/feedbacks.ts`, line 5  
**Owner:** Wash

Type safety bypassed with `any`:
```typescript
export function getActions(instance: any): CompanionActionDefinitions
```

---

## 🟡 Medium
### M1: Missing engines field
**Classification:** 🆕 NEW  
**File:** `package.json`  
**Owner:** Mal

No `engines` field specifying Node version. Recommended: `"engines": { "node": ">=18" }`

---

### M2: Missing packageManager field
**Classification:** 🆕 NEW  
**File:** `package.json`  
**Owner:** Mal

No `packageManager` field. Recommended: `"packageManager": "yarn@4.x.x"`

---

### M3: Boolean settings type-checked at runtime
**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, line 296  
**Owner:** Wash

The module should log for each failure when boolean settings type checks fail at runtime, rather than silently passing through incorrect types.

---

### M4: Consider upgrading manifest runtime to node22
**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 21  
**Owner:** Mal

Manifest specifies `"type": "node18"`. Node 22 is available in API v1.11+ and recommended for security patches.

---


### M5: Incomplete .gitignore
**Classification:** 🆕 NEW  
**File:** `.gitignore`  
**Owner:** Kaylee

Missing required entries: `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`, `/.vscode`

---

### M6: Missing eslint config
**Classification:** 🆕 NEW  
**File:** `eslint.config.mjs`  
**Owner:** Kaylee

TypeScript modules should include ESLint configuration. Not strictly blocking but important for code quality.

---

### M7: Missing null checks in feedback callbacks
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
