# Review: highcriteria-lhs v1.0.0

**Module:** companion-module-highcriteria-lhs  
**Version:** v1.0.0  
**API:** @companion-module/base ~2.0.3 (v2.0)  
**Type:** First Release — all findings are NEW  
**Review Date:** 2026-04-06  
**Reviewers:** Mal (Lead), Simon (Tests), Wash (Protocol), Kaylee (Template), Zoe (QA)

---

## Fix Summary for Maintainer

**Blocking fixes required before approval:**

1. **[H1]** Use strict equality (`===`/`!==`) in `src/main.ts:69-76`
2. **[M1]** Fix typo in `companion/manifest.json`: `"shortname"` — "Serivce" → "Service"
3. **[M2]** Fix typo in `companion/manifest.json`: `"description"` — "intergration" → "integration"

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 2 | 0 | 2 |
| 🟢 Low | 2 | 0 | 2 |
| **Total** | **5** | **0** | **5** |

**Blocking:** 3 issues (1 high, 2 medium)  
**Fix complexity:** Low-Medium — requires type safety fixes and manifest typo corrections  
**Health delta:** 5 introduced · 0 pre-existing (first release)

---

## Verdict: **Changes Required**

Loose equality in feedback comparisons and manifest typos — 3 blocking issues total.

---

## 📋 Issues

**Blocking**
- [ ] [H1: Loose equality in feedback comparisons](#h1-loose-equality-in-feedback-comparisons)
- [ ] [M1: Typo in shortname field](#m1-typo-in-shortname-field)
- [ ] [M2: Typo in description field](#m2-typo-in-description-field)

**Non-blocking**
- [ ] [L1: Redundant checkFeedbacks call pattern](#l1-redundant-checkfeedbacks-call-pattern)
- [ ] [L2: Missing maintainer email in manifest](#l2-missing-maintainer-email-in-manifest)

---

## 🟠 High

### H1: Loose equality in feedback comparisons

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 69-76  
**Source:** Zoe

**Issue:** Feedback check comparison uses loose equality (`!=`/`==`) instead of strict equality (`!==`/`===`). This is inconsistent with TypeScript best practices.

```typescript
if (state.roomId == this.config.room || state.roomId == '') {
    if (oldState?.isPaused != state.isPaused) feedbacksToCheck.push(FeedbackId.isPaused)
    if (oldState?.isRecording != state.isRecording) feedbacksToCheck.push(FeedbackId.isRecording)
```

**Impact:** Potential type coercion issues, less safe comparison.

**Fix:** Use `!==` and `===` throughout.

---

## 🟡 Medium

### M1: Typo in shortname field

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 5  
**Source:** Kaylee, Mal

**Issue:** `"shortname": "Liberty Helper Serivce"` — typo: "Serivce" should be "Service".

**Impact:** User-facing text with spelling error.

**Fix:** Correct to `"Liberty Helper Service"`

---

### M2: Typo in description field

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 6  
**Source:** Kaylee, Mal

**Issue:** `"description": "Liberty Helper Service intergration for companion"` — typo: "intergration" should be "integration".

**Impact:** User-facing text with spelling error.

**Fix:** Correct to `"integration"`

---

## 🟢 Low

### L1: Redundant checkFeedbacks call pattern

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, line 75  
**Source:** Zoe

**Issue:** The code passes `feedbacksToCheck[0]` twice (once as first arg, once in the spread):
```typescript
this.checkFeedbacks(feedbacksToCheck[0], ...feedbacksToCheck)
```

**Impact:** Minor code smell, no functional issue (checkFeedbacks deduplicates).

**Fix:** Use `this.checkFeedbacks(...feedbacksToCheck)` instead.

---

### L2: Missing maintainer email in manifest

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 13  
**Source:** Kaylee

**Issue:** The maintainer entry is missing the `email` field.

**Impact:** Incomplete maintainer information (optional field).

**Fix:** Add email field for the maintainer if desired.

---

## 🧪 Tests

**No tests found.** The module does not include any automated tests. No `vitest.config.*`, `jest.config.*`, or test files present.

**Simon's assessment:** Not a finding for a first release of this size, but tests recommended for future versions, particularly for:
- Client lifecycle (destroy before init completes)
- Rapid config changes
- Malformed TCP data handling
- Connection drops during operations

---

## ✅ What's Solid

1. **v2.0 API compliance (entry point):** Correct `export default class ModuleInstance extends InstanceBase<LhsTypes>` pattern — no deprecated `runEntrypoint`.

2. **InstanceTypes shape:** `LhsTypes` interface correctly implements `{ config, secrets, actions, feedbacks, variables }` shape as required by v2.0.

3. **UpgradeScripts export:** Correctly exported as named export. Empty array is acceptable for a first release.

4. **Lifecycle methods:** `init()`, `destroy()`, `configUpdated()`, and `getConfigFields()` all implemented correctly.

5. **TypeScript configuration:** `tsconfig.build.json` correctly extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`.

6. **Build tooling:** `@companion-module/tools` is v3.0.0 (exceeds v2.7.1+ requirement).

7. **ESM compliance:** All relative imports use `.js` extension correctly.

8. **No deprecated patterns:** No `parseVariablesInString`, no `checkFeedbacks()` without arguments, no `optionsToIgnoreForSubscribe`.

9. **Protocol implementation:** Excellent binary TCP client — proper framing with `LISv#bgn`/`LISv#end` magic markers, correct Big Endian byte order, PCAP-researched.

10. **Flow control:** PQueue ensures one frame at a time with 20ms minimum interval — prevents overwhelming device.

11. **Build passes:** `yarn build` and `yarn package` both succeed, producing `highcriteria-lhs-1.0.0.tgz` (10KB).

12. **Template compliance:** Most template conventions correct — package.json scripts, dependencies, LICENSE, .prettierignore, .yarnrc.yml all match template.

---

## Adjudication Notes

The following findings from Kaylee were downgraded based on functional impact:

- **Extra `*.pcap` in .gitignore** → 🔵 Low (not listed above — PCAP files are legitimately ignorable for protocol development, minor deviation that doesn't affect functionality)
- **eslint.config.mjs test configuration** → 🔵 Low (not listed above — build passes, harmless extra config for tests that don't exist)
- **tsconfig.build.json uses `nodenext` vs `Node16`** → Not blocking — build passes, `nodenext` is functionally equivalent for ESM modules and is the recommended setting for v2.0 modules

---

**Review assembled by:** Mal, Lead Reviewer  
**Date:** 2026-04-06
