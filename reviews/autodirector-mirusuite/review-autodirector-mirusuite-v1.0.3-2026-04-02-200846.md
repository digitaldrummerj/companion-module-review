# Review: autodirector-mirusuite v1.0.3

**Module:** `companion-module-autodirector-mirusuite`
**Review tag:** `v1.0.3`
**Previous tag:** `v1.0.2`
**Review date:** 2026-04-02
**Reviewers:** Mal (Lead), Wash (Protocol), Kaylee (Module Dev), Zoe (QA), Simon (Tests)

---

## Verdict: ✅ APPROVED WITH NOTES

This release is a clean architectural improvement — the feedback and action system has been generalized from director-specific to a full component abstraction (INPUT / CONTROLLER / DIRECTOR / AUTO_CUT). A proper upgrade script handles the breaking feedback rename. Build passes, no new regressions introduced.

**All blocking-level findings are pre-existing from v1.0.2.** Per review policy, pre-existing issues are never blockers. They are documented below for the maintainer to track for the next release.

---

## 🔴 Critical

*No critical issues introduced in this release.*

---

## 🟠 High

*No high-severity issues introduced in this release.*

---

## 🟢 Low

### L1: Build script `rimraf dist` removal may leave stale files
**File:** `package.json` line 10
**Classification:** 🆕 NEW
**Issue:** `rimraf dist` was removed from the build script. TypeScript's incremental build doesn't remove files that are no longer produced — if a source file is deleted or renamed, stale compiled output may accumulate in `dist/`.
**Impact:** Low — unlikely to cause issues in practice as TypeScript generally overwrites correctly.
**Recommendation:** Monitor for stale file issues. If they appear, re-add `rimraf dist &&` before the `tsc` call.

---

## 💡 Nice to Have

### N1: Unused import in `upgrades.ts`
**File:** `src/upgrades.ts` line 11
**Classification:** 🆕 NEW
**Issue:** `CompanionUpgradeContext` is imported but the upgrade function parameter is named `_` (unused). The linter may flag this.
**Suggestion:** Remove the import or rename the parameter if it may be needed later.

---

## 🔮 Next Release

### NR1: Fix EventSource not closed in `destroy()`
**File:** `src/main.ts` + `src/scripts/eventhandler.ts`
**Classification:** ⚠️ Pre-existing (existed in v1.0.2)
**Issue:** `destroy()` does not call `closeEventHandler()`. The SSE connection remains open after module deletion, preventing garbage collection of the module instance.

```typescript
// Current destroy():
async destroy(): Promise<void> {
    this.log('debug', 'Destroying module')
}

// Fix:
async destroy(): Promise<void> {
    this.log('debug', 'Destroying module')
    closeEventHandler()
}
```

`closeEventHandler()` already exists in `src/scripts/eventhandler.ts` (lines 106–110) — it just needs to be called. This is the highest-priority issue for v1.0.4.

### NR2: Fix EventSource connection leak on config change
**File:** `src/main.ts` lines 42–47
**Classification:** ⚠️ Pre-existing
**Issue:** `configUpdated()` calls `init()` when host/port changes without first closing the existing EventSource. The old connection continues firing events against the new module state.

```typescript
// Fix:
async configUpdated(config: ModuleConfig): Promise<void> {
    this.log('debug', 'Config updated')
    if (config.host !== this.config.host || config.port !== this.config.port) {
        closeEventHandler()   // close old connection first
        await this.init(config)
    }
}
```

### NR3: Add `onerror` handler to EventSource
**File:** `src/scripts/eventhandler.ts` line 14
**Classification:** ⚠️ Pre-existing
**Issue:** EventSource has no `onerror` handler. Network failures and server shutdowns are silently ignored — `InstanceStatus` is not updated and no log entry is written.

```typescript
evtSource.onerror = (error: any) => {
    self.log('error', 'SSE connection error: ' + error)
    self.updateStatus(InstanceStatus.ConnectionFailure)
}
```

### NR4: Fix `_getVideoDevicesFromData()` ignoring its parameter
**File:** `src/scripts/store.ts` lines 52–54
**Classification:** ⚠️ Pre-existing
**Issue:** The method ignores its `_data` parameter and always filters `this.devices`. Change detection logic using this method may fire on incorrect data.

```typescript
// Fix:
_getVideoDevicesFromData(data: Device[] | undefined): Device[] {
    return (data ?? []).filter((device) => getInputComponentType(device) === 'VIDEO')
}
```

### NR5: HTTP error handler sets status to `Ok` after logging failure
**File:** `src/api/backend.ts` lines 36–44
**Classification:** ⚠️ Pre-existing
**Issue:** `checkedFetch` logs the error and sets `ConnectionFailure`, then immediately sets `Ok` on the next line. Status flips back to `Ok` on every failed request.

```typescript
// Fix: only set Ok on success path:
if (!response.ok) {
    this.self.updateStatus(InstanceStatus.ConnectionFailure)
    this.self.log('error', 'Backend returned code ' + response.status)
    // do NOT set Ok here
    return response
}
this.self.updateStatus(InstanceStatus.Ok)
return response
```

### NR6: Add `engines` field to `package.json`
**Classification:** ⚠️ Pre-existing
**Issue:** Template specifies `engines.node` and `engines.yarn`. Missing from this module.
```json
"engines": {
    "node": "^22.20",
    "yarn": "^4"
}
```

### NR7: Consider migrating to Yarn v4
**Classification:** ⚠️ Pre-existing
**Issue:** Module uses `yarn@1.22.22`. Template recommends Yarn v4. Module builds correctly as-is; migration is low urgency but improves template alignment.

### NR8: Add unit tests for the upgrade script
**Classification:** Suggestion
**Context:** The v1.0.3 upgrade script migrates `enabledDirector` feedbacks to `enabledComponentType`. No tests cover this path.
**Suggestion:** Add Jest tests verifying the migration correctly transforms affected feedbacks and leaves unrelated feedbacks untouched. Protects against regressions if the upgrade script is modified.

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
- `InstanceStatus` transitions (Connecting, Ok, ConnectionFailure) are set appropriately
- No blocking network calls on the main thread
- v1.0.3 feature additions (generalized component control) did not introduce any new protocol issues

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

v1.0.3 is approved. The component abstraction work is solid and the upgrade script correctly handles the breaking feedback rename.

The items in the **Next Release** section are all pre-existing issues that were present before this submission. The highest-priority fix is **NR1** (calling `closeEventHandler()` in `destroy()`): the function already exists and the fix is literally one line. We recommend addressing NR1–NR3 together in v1.0.4 since they're all part of the same EventSource lifecycle gap.
