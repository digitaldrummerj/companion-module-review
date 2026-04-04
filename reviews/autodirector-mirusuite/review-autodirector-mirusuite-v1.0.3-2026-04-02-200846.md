# Review: autodirector-mirusuite v1.0.3

**Module:** `companion-module-autodirector-mirusuite`
**Review tag:** `v1.0.3`
**Previous tag:** `v1.0.2`
**Review date:** 2026-04-02
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Module Dev), Zoe (QA), Simon (Tests)

---

## Verdict: ❌ REJECTED

This release introduces a clean architectural improvement and is well-structured. However, **three high-severity issues that were present in v1.0.2 are blocking this release.** These issues were not flagged by prior reviews — the maintainer is likely unaware of them. They must be fixed before v1.0.3 can be approved.

Pre-existing issues are labeled as such so the maintainer knows these are inherited debt, not regressions introduced in this release. That context matters — but it does not change whether they must be fixed.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 3 | 3 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 1 | 0 | 1 |
| 💡 Nice to Have | 1 | 0 | 1 |
| **Total** | **2** | **3** | **5** |

**Blocking:** 3 issues (3 pre-existing high)  
**Fix complexity:** Quick — three one-line fixes  
**Health delta:** 2 introduced · 3 pre-existing surfaced  

---

## 📋 Table of Contents

**Blocking**
- [H1: EventSource not closed in `destroy()`](#h1-eventsource-not-closed-in-destroy--pre-existing-v102)
- [H2: EventSource not closed before config change reinit](#h2-eventsource-not-closed-before-config-change-reinit--pre-existing-v102)
- [H3: HTTP error handler resets status to `Ok` after failure](#h3-http-error-handler-resets-status-to-ok-after-failure--pre-existing-v102)

**Non-blocking**
- [L1: Build script `rimraf dist` removal may leave stale files](#l1-build-script-rimraf-dist-removal-may-leave-stale-files)
- [N1: Unused import in `upgrades.ts`](#n1-unused-import-in-upgradests)

---

## 🔴 Critical

*No critical issues.*

---

## 🟠 High

### H1: EventSource not closed in `destroy()` ⚠️ Pre-existing (v1.0.2)
**File:** `src/main.ts` + `src/scripts/eventhandler.ts`
**Classification:** ⚠️ PRE-EXISTING — existed in v1.0.2, not introduced in this release
**Issue:** `destroy()` does not call `closeEventHandler()`. When a user removes the connection, the SSE stream stays open indefinitely. The orphaned EventSource continues receiving events and trying to update state on a destroyed module instance, causing runtime errors and preventing garbage collection.

```typescript
// Current — connection never closed:
async destroy(): Promise<void> {
    this.log('debug', 'Destroying module')
}

// Fix — closeEventHandler() already exists (eventhandler.ts lines 106–110):
async destroy(): Promise<void> {
    this.log('debug', 'Destroying module')
    closeEventHandler()
}
```

**Impact:** Runtime errors when Companion processes events on a destroyed module; memory leak on repeated add/remove cycles.
**Required fix:** v1.0.4

---

### H2: EventSource not closed before config change reinit ⚠️ Pre-existing (v1.0.2)
**File:** `src/main.ts` lines 42–47
**Classification:** ⚠️ PRE-EXISTING
**Issue:** When the host or port changes, `configUpdated()` calls `init()` immediately without closing the existing EventSource first. The old connection keeps firing events against the new module state — mixing events from two different servers, causing state corruption and confusing log output.

```typescript
// Fix:
async configUpdated(config: ModuleConfig): Promise<void> {
    this.log('debug', 'Config updated')
    if (config.host !== this.config.host || config.port !== this.config.port) {
        closeEventHandler()   // tear down before reinit
        await this.init(config)
    }
}
```

**Impact:** State corruption during host/port config changes; ghost events from old server.
**Required fix:** v1.0.4 (same one-line change pattern as H1)

---

### H3: HTTP error handler resets status to `Ok` after failure ⚠️ Pre-existing (v1.0.2)
**File:** `src/api/backend.ts` lines 36–44
**Classification:** ⚠️ PRE-EXISTING
**Issue:** `checkedFetch` sets `ConnectionFailure` on a non-2xx response but then unconditionally sets `Ok` on the next line. The module shows green in Companion even when every HTTP request is failing — operators have no indication the connection is broken.

```typescript
// Current (broken):
if (!response.ok) {
    this.self.updateStatus(InstanceStatus.ConnectionFailure)
    this.self.log('error', 'Backend returned code ' + response.status)
}
this.self.updateStatus(InstanceStatus.Ok)   // <-- overwrites the failure status
return response

// Fix:
if (!response.ok) {
    this.self.updateStatus(InstanceStatus.ConnectionFailure)
    this.self.log('error', 'Backend returned code ' + response.status)
    return response   // exit here — do NOT set Ok
}
this.self.updateStatus(InstanceStatus.Ok)
return response
```

**Impact:** Module always appears connected even when the backend is unreachable; operators cannot diagnose outages.
**Required fix:** v1.0.4

---

## 🟢 Low

### L1: Build script `rimraf dist` removal may leave stale files
**File:** `package.json` line 10
**Classification:** 🆕 NEW
**Issue:** `rimraf dist` was removed from the build script. TypeScript's incremental build doesn't remove files that are no longer produced — deleted or renamed source files may leave stale compiled output in `dist/`.
**Impact:** Low — unlikely in practice; TypeScript overwrites correctly in most cases.
**Recommendation:** Re-add `rimraf dist &&` before `tsc` if stale files become an issue.

---

## 💡 Nice to Have

### N1: Unused import in `upgrades.ts`
**File:** `src/upgrades.ts` line 11
**Classification:** 🆕 NEW
**Issue:** `CompanionUpgradeContext` is imported but the upgrade function parameter is `_` (unused). The linter may flag this.
**Suggestion:** Remove the import or use the parameter if it may be needed.

---

## ⚠️ Pre-existing Notes (non-blocking)

These were present before v1.0.3 and carry lower severity. Address when convenient.

- **Missing `onerror` on EventSource** (`src/scripts/eventhandler.ts` line 14) — network failures are silently ignored; `InstanceStatus` is not updated. Add `evtSource.onerror` to log errors and set `ConnectionFailure`.
- **`_getVideoDevicesFromData()` ignores its parameter** (`src/scripts/store.ts` lines 52–54) — always filters `this.devices` regardless of input; change detection may fire incorrectly. Fix: filter the `data` parameter instead.
- **Missing `engines` field in `package.json`** — template specifies `node` and `yarn` version constraints; add for consistency.
- **Yarn v1 instead of v4** — module uses `yarn@1.22.22`; template targets Yarn v4. Functional as-is; migrate when convenient.
- **No tests for upgrade script** — the `enabledDirector` → `enabledComponentType` migration has no unit test coverage.

---

## ✅ What's Solid

**Architecture (Mal):**
- Correctly extends `InstanceBase<ModuleConfig>` with all required lifecycle methods
- `runEntrypoint(MiruSuiteModuleInstance, UpgradeScripts)` correctly called
- The refactor from director-specific to component-generic is a clean design improvement
- Upgrade script handles the `enabledDirector` → `enabledComponentType` rename correctly, defaulting `componentType` to `'DIRECTOR'` to preserve existing user setups
- ESM imports use `.js` extensions on relative imports — correct for the module type

**Build (Kaylee):**
- `yarn install && yarn package` succeeds cleanly, producing `autodirector-mirusuite-1.0.3.tgz`
- No `package-lock.json` — only `yarn.lock` present
- `companion/manifest.json` is complete and correctly configured
- New `setComponent` action is well-typed with clear labels and sensible defaults

**Protocol (Wash):**
- HTTP client uses `openapi-fetch` with TypeScript types generated from OpenAPI spec — strong type safety
- All network calls are properly awaited — no floating promises
- No blocking network calls on the main thread
- v1.0.3 feature additions did not introduce any new protocol issues

**QA (Zoe):**
- New `toggleComponent()` and `getComponentsOfType()` implementations are correct
- Backward compatibility preserved — `toggleDirector`/`setDirector` actions still work
- Type safety on component type unions is correct
- No new memory leaks introduced by this release
- `toggleComponent()` properly guards against `device === undefined` and `componentId === undefined`

**Tests (Simon):**
- ✅ No tests present — not required

---

## Summary for Maintainer

v1.0.3 is rejected due to three high-severity pre-existing issues (H1–H3). These existed in v1.0.2 and were not flagged by prior reviews — they are not regressions you introduced in this release, but they must be fixed before approval.

The good news: **all three fixes are small and self-contained.**

1. **H1** — `destroy()` never closes the EventSource. `closeEventHandler()` already exists — just call it in `destroy()`. One line.
2. **H2** — `configUpdated()` doesn't close the old EventSource before reinit. Same fix: call `closeEventHandler()` before `await this.init(config)`. One line.
3. **H3** — HTTP error handler resets status to `Ok` after a failure. Remove the unconditional `updateStatus(Ok)` and only set it on the success path.

Fix these three, cut a new tag, and resubmit.
