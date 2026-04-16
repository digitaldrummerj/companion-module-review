# Re-Review: generic-snmp @ v3.0.1

| Field | Value |
|-------|-------|
| **Module** | `companion-module-generic-snmp` |
| **Tag** | `v3.0.1` |
| **Commit** | `1cb9a84` |
| **Previous reviewed version** | `v3.0.1` (review dated 2026-04-09) |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v2.0 (`@companion-module/base ~2.0.3`) |
| **Module type** | TypeScript / ESM |
| **Validation** | ✅ `yarn build` · ✅ `yarn lint` · ✅ `yarn test` (329/329 passed) |

---

## Verdict

### ❌ CHANGES REQUIRED — no blocking findings from the prior v3.0.1 review were fixed

This is a same-tag follow-up. I found no release-code delta to re-review beyond the previously reviewed `v3.0.1` submission: the checkout still matches tag `v3.0.1`, and the only newer change on `main` is a `yarn.lock` update outside the release. The three blocking lifecycle bugs in `src/index.ts` remain, and no new release-delta issues were introduced.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 3 | 3 |
| 🟡 Medium | 0 | 8 | 8 |
| 🟢 Low | 0 | 8 | 8 |
| 💡 Nice to Have | 0 | 2 | 2 |
| **Total** | **0** | **21** | **21** |

**Blocking:** 3 issues (3 carried-forward high)  
**Fix complexity:** Medium — all remaining blockers are still localized to `src/index.ts` connection lifecycle logic  
**Health delta:** 0 introduced · 21 pre-existing carried forward  

---

## Fix Verification (prior v3.0.1 review → current submission)

**Findings fixed:** none.

### Blocking findings

| ID | Prior finding | Severity | Current status |
|----|---------------|----------|----------------|
| H1 | `pollOids()` silently terminates poll chain on SNMP error | 🟠 High | ❌ **Not fixed** — `pollOids()` still does `await this.getOid(...oids)` with no local `try/catch`, and the reschedule call still uses `.catch(() => {})` (`src/index.ts:580-590`). |
| H2 | `createListener` promise never settles on rapid `configUpdated` | 🟠 High | ❌ **Not fixed** — `initializeConnection()` still awaits `createListener()` before any post-bind generation check, while `closeListener()` still removes listeners from the in-flight socket (`src/index.ts:122-129`, `259-273`, `282-332`). |
| H3 | No try/catch in `connectAgent`; synchronous throws from `net-snmp` are unhandled | 🟠 High | ❌ **Not fixed** — `connectAgent()` still calls `snmp.createSession()` / `snmp.createV3Session()` directly without a surrounding `try/catch` (`src/index.ts:155-180`, `247-248`). |

### Non-blocking carry-forwards

- 🟡 **M1-M8 remain open.** No fixes landed for the previously reported bind-address, SNMPv3 trap auth, feedback subscribe, cache clearing, key validation, callback cancellation, or OID tracker cleanup issues.
- 🟢 **L1-L8 remain open.** The `config.test.ts` mock-hoisting warnings still reproduce during `yarn test`, and the previously noted wrapper/config/action cleanup items are unchanged.
- 💡 **NTH1-NTH2 remain open.** Upgrade placeholder and getter naming notes are unchanged.
- ⚠️ **PE1-PE3 remain unchanged.** Package/manifest naming notes are still the same pre-existing advisory items from the prior review.

---

## New issues introduced in this follow-up delta

None. There is no module-code delta from the previously reviewed `v3.0.1` submission to classify as a new regression or newly introduced issue.

---

## 🧪 Validation

- ✅ `yarn build`
- ✅ `yarn lint`
- ✅ `yarn test` — 329/329 tests passed
- ⚠️ Same existing Vitest warnings remain: two `vi.mock()` calls in `src/config.test.ts` are still not at module top level

---

## ✅ Still Solid

- Clean v2.0 module structure remains intact: `export default class ... extends InstanceBase<ModuleTypes>`, named `UpgradeScripts` export, ESM package shape, `manifest.type: "connection"`, and `runtime.type: "node22"`.
- The existing test suite is still strong and passes cleanly.
- Upgrade coverage from earlier versions is still present; this follow-up failure is strictly about unresolved lifecycle bugs, not template compliance.

---

*Follow-up review conducted by Mal only, constrained to the prior `v3.0.1` review delta.*
