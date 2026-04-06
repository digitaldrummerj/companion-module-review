# Review: snellwilcox-kahuna v1.0.0

**Module:** companion-module-snellwilcox-kahuna  
**Version:** v1.0.0 (first release)  
**Previous Tag:** (none)  
**API Version:** v2.0 (`@companion-module/base ~2.0.3`)  
**Language:** TypeScript (ESM)  
**Protocol:** Dual-TCP (ASCII command + binary tally)  
**Requested by:** Justin James  
**Review Date:** 2026-04-06  

---

## Verdict: ✅ APPROVED

**Reason:** Excellent v2.0 API compliance, clean build/lint/tests (88/88), no blocking issues. Minor template deviations are justified or cosmetic.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 6 | 0 | 6 |
| 🟢 Low | 10 | 0 | 10 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **19** | **0** | **19** |

**Blocking:** 0 issues  
**Fix complexity:** N/A — no blocking issues  
**Health delta:** 0 blocking introduced · 0 pre-existing · all findings are first-release cosmetic/enhancement items

---

## 📋 Issues

**Blocking**
*(none)*

**Non-blocking**
- [ ] [M1: Race condition in `configUpdated()` — queue not awaited](#m1-race-condition-in-configupdated-queue-not-awaited)
- [ ] [M2: p-queue can grow unbounded on repeated action calls](#m2-p-queue-can-grow-unbounded-on-repeated-action-calls)
- [ ] [M3: Response ERROR doesn't emit event or reject promise early](#m3-response-error-doesnt-emit-event-or-reject-promise-early)
- [ ] [M4: Tally indexing inconsistency (1-indexed vs 0-indexed)](#m4-tally-indexing-inconsistency-1-indexed-vs-0-indexed)
- [ ] [M5: Missing `tsconfig.node.json` referenced in `eslint.config.mjs`](#m5-missing-tsconfignodejson-referenced-in-eslintconfigmjs)
- [ ] [M6: `moduleResolution` uses `Node16` instead of `nodenext`](#m6-moduleresolution-uses-node16-instead-of-nodenext)
- [ ] [L1: Empty `updatePresets()` method stub](#l1-empty-updatepresets-method-stub)
- [ ] [L2: Event listener cleanup gap in `triggerMacro()`](#l2-event-listener-cleanup-gap-in-triggermacro)
- [ ] [L3: TypeScript `as` cast could hide runtime errors](#l3-typescript-as-cast-could-hide-runtime-errors)
- [ ] [L4: No safe default in `kahunaTally` getter](#l4-no-safe-default-in-kahunatally-getter)
- [ ] [L5: Tally stream runaway discards without diagnostics](#l5-tally-stream-runaway-discards-without-diagnostics)
- [ ] [L6: tsconfig extends `recommended-esm` instead of `recommended`](#l6-tsconfig-extends-recommended-esm-instead-of-recommended)
- [ ] [L7: tsconfig extra compiler options beyond template](#l7-tsconfig-extra-compiler-options-beyond-template)
- [ ] [L8: tsconfig.json includes `vitest.config.ts`](#l8-tsconfigjson-includes-vitestconfigts)
- [ ] [L9: eslint.config.mjs contains custom test rules](#l9-eslintconfigmjs-contains-custom-test-rules)
- [ ] [L10: vitest infrastructure not in template](#l10-vitest-infrastructure-not-in-template)
- [ ] [N1: Add explicit queue size limit](#n1-add-explicit-queue-size-limit)
- [ ] [N2: Connection-ready guard in `triggerMacro()`](#n2-connection-ready-guard-in-triggermacro)
- [ ] [N3: Document overflow behavior for project/macro values](#n3-document-overflow-behavior-for-projectmacro-values)

---

## 🔴 Critical

None.

---

## 🟠 High

None.

---

## 🟡 Medium

### M1: Race condition in `configUpdated()` — queue not awaited

**File:** `src/main.ts:48-54`  
**Classification:** 🆕 NEW  
**Source:** Zoe (QA)

The abort signal is sent and a new `AbortController` is immediately created, but `initKahuna()` is called without waiting for in-flight p-queue tasks to fully clean up. Event listeners from the old Kahuna instance might still fire after the new instance starts.

**Recommendation:** Add `await this.#queue.onIdle()` after `this.#queue.clear()` to wait for aborting tasks to complete.

---

### M2: p-queue can grow unbounded on repeated action calls

**File:** `src/main.ts:22`  
**Classification:** 🆕 NEW  
**Source:** Zoe (QA), Wash (Protocol)

The p-queue has `intervalCap: 1, interval: 10` (rate limiting) but no size limit. Rapid button-mashing could cause unbounded queue growth.

**Mitigations present:** Queue cleared on `destroy()` and `configUpdated()`, timeouts clear stale tasks, memory per task is small.

**Recommendation:** Consider adding `queueSize: 100` or manual size checking in `triggerMacro()`.

---

### M3: Response ERROR doesn't emit event or reject promise early

**File:** `src/kahuna_plugin.ts:295-299`  
**Classification:** 🆕 NEW  
**Source:** Wash (Protocol)

When the mixer responds with `ERROR`, the module discards the command and moves to the next, but does not emit a `macro_complete` event or reject the waiting promise. The promise times out after 5 seconds instead of rejecting immediately.

**Recommendation:** Emit a `macro_error` event or modify queue to reject pending promise early.

---

### M4: Tally indexing inconsistency (1-indexed vs 0-indexed)

**File:** `src/kahuna_plugin.ts:185-188, 392` and `src/main.ts:96`  
**Classification:** 🆕 NEW  
**Source:** Wash (Protocol), Zoe (QA)

The tally number is stored as-is from the mixer (1-indexed) but `requestTally()` returns `tallyNumber - 1` (0-indexed). The `tally_changed` event emits the raw 1-indexed value. The variable shows 1-indexed, but the feedback getter returns 0-indexed.

**Recommendation:** Standardize on one indexing convention throughout.

---

### M5: Missing `tsconfig.node.json` referenced in `eslint.config.mjs`

**File:** `eslint.config.mjs:13`  
**Classification:** 🆕 NEW  
**Source:** Kaylee (Module Dev)

The eslint config references `./tsconfig.node.json` in the parserOptions.project array, but this file does not exist. Lint still passes, so ESLint is likely silently falling back.

**Recommendation:** Either create the file or remove the reference.

---

### M6: `moduleResolution` uses `Node16` instead of `nodenext`

**File:** `tsconfig.build.json:13`  
**Classification:** 🆕 NEW  
**Source:** Mal (Lead)

Uses `"moduleResolution": "Node16"` instead of `"nodenext"`. While this works (Node16 ≈ NodeNext for current Node versions), the v2.0 API spec recommends `"nodenext"` for forward compatibility.

---

## 🟢 Low

### L1: Empty `updatePresets()` method stub

**File:** `src/main.ts:194-195`  
**Classification:** 🆕 NEW  
**Source:** Mal (Lead)

Empty method. Consider removing the stub or adding presets if applicable for this device type.

---

### L2: Event listener cleanup gap in `triggerMacro()`

**File:** `src/main.ts:159-160`  
**Classification:** 🆕 NEW  
**Source:** Zoe (QA)

If `configUpdated()` is called while a macro is mid-flight, the `onComplete` listener on the old Kahuna instance may orphan until timeout cleanup. The 5-second timeout ensures eventual cleanup.

---

### L3: TypeScript `as` cast could hide runtime errors

**File:** `src/variables.ts:11`  
**Classification:** 🆕 NEW  
**Source:** Zoe (QA)

The `variables` object is cast from `Partial<...>` to the full type. Consider removing `Partial` and initializing directly to leverage TypeScript's exhaustiveness checking.

---

### L4: No safe default in `kahunaTally` getter

**File:** `src/main.ts:179-184` and `src/feedbacks.ts:30`  
**Classification:** 🆕 NEW  
**Source:** Zoe (QA)

The `kahunaTally` getter throws if called before initialization. The feedback callback calls this without try-catch. Companion likely handles this gracefully, but returning `0` as a safe default would be cleaner.

---

### L5: Tally stream runaway discards without diagnostics

**File:** `src/kahuna_plugin.ts:332-336`  
**Classification:** 🆕 NEW  
**Source:** Wash (Protocol)

When the 1000-byte buffer limit is triggered, all accumulated data is discarded silently. Consider logging first/last 50 bytes for diagnostics before discarding.

---

### L6: tsconfig extends `recommended-esm` instead of `recommended`

**File:** `tsconfig.build.json:2`  
**Classification:** 🆕 NEW  
**Source:** Kaylee (Module Dev)

Uses `recommended-esm.json` instead of `recommended`. This is appropriate for ESM modules with `"type": "module"` and the build passes. Justified deviation but noted.

---

### L7: tsconfig extra compiler options beyond template

**File:** `tsconfig.build.json:11-15`  
**Classification:** 🆕 NEW  
**Source:** Kaylee (Module Dev)

Adds `"target": "es2023"`, `"lib": ["ES2023"]`, `"strict": true` beyond template. These are enhancements (stricter checking) rather than problems. Build passes.

---

### L8: tsconfig.json includes `vitest.config.ts`

**File:** `tsconfig.json:3`  
**Classification:** 🆕 NEW  
**Source:** Kaylee (Module Dev)

Template expects only `src/**/*.ts` in include. Adding `vitest.config.ts` is necessary for vitest type-checking. File is outside `src/` and won't be packaged.

---

### L9: eslint.config.mjs contains custom test rules

**File:** `eslint.config.mjs:3-21`  
**Classification:** 🆕 NEW  
**Source:** Kaylee (Module Dev)

Extends base eslint config with test-specific rules (`n/no-unpublished-import: off`, `@typescript-eslint/unbound-method: off`). These are reasonable accommodations for test infrastructure.

---

### L10: vitest infrastructure not in template

**File:** `vitest.config.ts:1-7`  
**Classification:** 🆕 NEW  
**Source:** Kaylee (Module Dev)

The module includes vitest testing infrastructure not present in template. Testing is excellent practice and this deviation is beneficial.

---

## 💡 Nice to Have

### N1: Add explicit queue size limit

**File:** `src/main.ts:22`  
**Classification:** 🆕 NEW  
**Source:** Wash (Protocol)

Consider adding explicit `queueSize` limit to p-queue configuration as a paranoia safeguard against unbounded growth.

---

### N2: Connection-ready guard in `triggerMacro()`

**File:** `src/main.ts:127-130`  
**Classification:** 🆕 NEW  
**Source:** Wash (Protocol)

The check ensures `#kahuna` exists but doesn't verify the command socket is connected. Current behavior is acceptable—commands queue and auto-reconnect sends them, with 5-second timeout as escape hatch.

---

### N3: Document overflow behavior for project/macro values

**File:** Tests  
**Classification:** 🆕 NEW  
**Source:** Simon (Test Runner)

Tests don't verify behavior when project > 99 or macro > 999 (would exceed padding). Consider adding tests or documentation noting the limits.

---

## 🔮 Next Release

None flagged.

---

## ⚠️ Pre-existing Notes

None — this is a first release.

---

## 🧪 Tests

### ✅ EXCELLENT — 88/88 Tests Passing (100%)

| Metric | Value |
|--------|-------|
| Total Test Files | 2 |
| Total Tests | 88 |
| Passed | 88 (100%) |
| Failed | 0 |
| Skipped | 0 |
| Duration | 145ms (tests: 28ms) |

**Test Files:**
- `kahuna_command.test.ts` — 27 tests (constructor, stage control, wire format, boundary values)
- `kahuna_plugin.test.ts` — 61 tests (config validation, tally state, TCP lifecycle, stream parsing)

**Highlights:**
- Comprehensive coverage (1,028 LOC across test files)
- Excellent wire protocol testing with exact format verification
- Sophisticated MockTCPHelper for socket simulation
- Binary tally stream parsing with fragmentation handling
- State machine testing for multi-stage command progression
- No always-pass assertions detected
- Well-organized with clear test descriptions

**Source:** Simon (Test Runner)

---

## ✅ What's Solid

### v2.0 API Compliance — Full Pass

| Requirement | Status | Location |
|-------------|--------|----------|
| Default export class extending `InstanceBase<T>` | ✅ | `src/main.ts:19` |
| Named export `UpgradeScripts` | ✅ | `src/main.ts:17` |
| No `runEntrypoint()` call | ✅ | Not present (correct) |
| `manifest.json` has `"type": "connection"` | ✅ | `companion/manifest.json:5` |
| `manifest.json` runtime is `"node22"` | ✅ | `companion/manifest.json:19` |
| `@companion-module/tools` v3.0.0 | ✅ | `package.json:31` |
| `InstanceBase<T>` generic with InstanceTypes shape | ✅ | `src/types.ts:6-12` |
| `setVariableDefinitions` uses object form | ✅ | `src/variables.ts:9-11` |

### Breaking API Avoidance — Full Pass

| Removed API | Status |
|-------------|--------|
| `parseVariablesInString` | ✅ Not used |
| `checkFeedbacks()` no-args | ✅ Not used |
| `optionsToIgnoreForSubscribe` | ✅ Not used |
| `imageBuffer` raw Buffer | ✅ Not used |
| `setPresetDefinitions` single-array | ✅ Not used |

### Protocol Implementation — Excellent

- **Dual-TCP architecture:** Command socket (ASCII) + Tally socket (binary stream)
- **Connection lifecycle:** Proper init/destroy/reconnect with TCPHelper auto-reconnection
- **Status management:** Dual-status tracking with worst-case aggregation
- **p-queue with AbortSignal:** Proper rate limiting and cancellation support
- **Binary stream parser:** Robust tally parsing with buffer accumulation, control-byte framing, runaway protection
- **Input validation:** Strong IP/hostname/port validation before state mutation

### Template Compliance — Pass

- All required files present (manifest.json, HELP.md, .gitignore, etc.)
- Correct package.json structure (engines, repository, scripts, dependencies)
- yarn.lock with Yarn 4.13.0 packageManager
- No `dist/` committed
- Valid MIT License with real copyright holder
- Good HELP.md documentation covering device configuration

### Architecture Quality

- Clean TypeScript with strict mode enabled
- Proper ESM with `.js` extensions on all imports
- Well-designed plugin architecture (`KahunaPlugin` class with event-driven design)
- TypeScript exhaustiveness checking in command stage handling

---

**Review assembled by Mal (Lead)**  
**Agents contributing:** Mal, Wash, Kaylee, Zoe, Simon
