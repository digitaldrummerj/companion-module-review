# Follow-up Review: generic-snmp @ v3.0.2

| Field | Value |
|-------|-------|
| **Module** | `companion-module-generic-snmp` |
| **Tag** | `v3.0.2` |
| **Commit** | `b82e7cb` |
| **Previous reviewed version** | `v3.0.1` (follow-up review dated 2026-04-16; original review dated 2026-04-09) |
| **Reviewed** | 2026-04-16 |
| **Reviewer** | Mal (Lead) |
| **API version** | v2.0 (`@companion-module/base ~2.0.3`) |
| **Module type** | TypeScript / ESM |
| **Validation** | ✅ `yarn build` · ✅ `yarn lint` · ✅ `yarn test` (326/326 passed) |

---

## Verdict

### ❌ CHANGES REQUIRED — v3.0.2 fixes most of the prior release findings, but one blocking listener-lifecycle bug still remains

This review is constrained to the v3.0.1 → v3.0.2 release delta plus the prior generic-snmp review context. v3.0.2 meaningfully improves the module and closes 12 previously reported release findings, but `createListener()` can still leave an in-flight `configUpdated()` call permanently pending during rapid trap-enabled reconfiguration.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 1 | 1 |
| 🟡 Medium | 0 | 4 | 4 |
| 🟢 Low | 0 | 2 | 2 |
| 💡 Nice to Have | 0 | 2 | 2 |
| **Total** | **0** | **9** | **9** |

**Blocking:** 1 issue (1 carried-forward high)  
**Fix complexity:** Medium — the remaining blocker still needs a real cancellation/settlement path in the trap-listener lifecycle  
**Health delta:** 0 introduced · 9 pre-existing carried forward

---

## Fix Verification (v3.0.1 → v3.0.2)

**12 of 21 prior release findings are fixed in this patch.**

### Fixed in v3.0.2

| ID | Prior finding | Severity | Resolution |
|----|---------------|----------|------------|
| H1 | `pollOids()` silently terminates poll chain on SNMP error | 🟠 High | ✅ **Fixed** — `pollOids()` now wraps `getOid(...oids)` in `try/catch` and keeps scheduling the next poll (`src/index.ts:586-603`). |
| H3 | No try/catch in `connectAgent`; synchronous throws from `net-snmp` are unhandled | 🟠 High | ✅ **Fixed** — both `snmp.createSession()` and `snmp.createV3Session()` are now wrapped in `try/catch` with status/log handling (`src/index.ts:180-187`, `253-259`). |
| M1 | `SharedUdpSocket.bind()` called with remote device IP as local bind address | 🟡 Medium | ✅ **Fixed** — listener bind now uses only the local port (`src/index.ts:342`). |
| M4 | `configUpdated` does not clear `oidValues` cache on device change | 🟡 Medium | ✅ **Fixed** — `configUpdated()` now clears `oidValues` before reconnecting (`src/index.ts:67-84`). |
| M6 | SNMPv3 auth/priv keys have no minimum-length validation | 🟡 Medium | ✅ **Fixed** — config fields now enforce minimum lengths and regex validation for username/auth/priv credentials (`src/configs.ts:121-196`). |
| M8 | `FeedbackOidTracker.clear()` does not clear `oidsToPoll` | 🟡 Medium | ✅ **Fixed** — `clear()` now clears `oidsToPoll` too (`src/oidtracker.ts:145-149`). |
| L1 | Double `removeFromPollGroup` call in feedback `unsubscribe` | 🟢 Low | ✅ **Fixed** — `unsubscribe` now only calls `removeFeedback()` (`src/feedbacks.ts:58-60`). |
| L2 | `Buffer.slice` deprecated; use `Buffer.subarray` | 🟢 Low | ✅ **Fixed** — `bufferToBigInt()` now uses `subarray` (`src/oidUtils.ts:40`). |
| L4 | Redundant `oid.length == 0` guard alongside `isValidSnmpOid` | 🟢 Low | ✅ **Fixed** — redundant guards were removed from `setOid()`, `getOid()`, and `walk()` (`src/index.ts:414-481`). |
| L5 | `SetOpaque` action missing `learn` callback | 🟢 Low | ✅ **Fixed** — `SetOpaque` now implements `learn` (`src/actions.ts:197-210`). |
| L6 | Silent `127.0.0.1` fallback for `agentAddress` on DNS failure | 🟢 Low | ✅ **Fixed** — DNS fallback now logs a warning (`src/index.ts:102-111`). |
| L7 | Multiple typos in log strings, comments, and variable names | 🟢 Low | ✅ **Fixed** — typo cleanup landed across wrapper/config/action text (`src/wrapper.ts:48-132`, `src/configs.ts:33-35,99`, `src/actions.ts:579-586`). |

### Still blocking

| ID | Finding | Severity | Current status |
|----|---------|----------|----------------|
| H2 | `createListener` promise never settles on rapid `configUpdated` | 🟠 High | ❌ **Not fixed** — `closeListener()` still removes all listeners from the in-flight socket (`src/index.ts:281-283`), while `createListener()` still relies on those same `'error'` / `'listening'` handlers to resolve or reject its promise (`src/index.ts:303-340`). The new generation check after `await this.createListener()` (`src/index.ts:123-131`) runs too late to rescue a promise that never settles. |

### Non-blocking carry-forwards

- 🟡 **M2 remains open.** SNMPv3 trap receiver setup still passes auth/priv fields unconditionally in `addUser()` instead of mirroring the security-level gating used by `connectAgent()` (`src/index.ts:328-336`).
- 🟡 **M3 remains open.** `FeedbackId.GetOID` still has no `subscribe` callback, so OID tracking still begins on first evaluation rather than at registration time (`src/feedbacks.ts:23-61`).
- 🟡 **M5 remains open.** The Trap/Inform warning still bakes `self.config.version == 'v1'` into a literal boolean in `isVisibleExpression` (`src/actions.ts:527`).
- 🟡 **M7 remains open.** `configUpdated()` still does not cancel pending throttled/debounced callbacks; only `destroy()` does (`src/index.ts:67-84`, `91-93`).
- 🟢 **L3 remains open.** `getFeedbacksForOid()` is still unused dead code (`src/oidtracker.ts:87-89`).
- 🟢 **L8 remains open.** `yarn test` still warns because `loadConfig()` re-registers two `vi.mock()` calls inside the helper body (`src/config.test.ts:15-16`).
- 💡 **NTH1-NTH2 remain open.** The empty `pre200` upgrade placeholder and `get getOidsToPoll()` naming note are unchanged.
- ⚠️ **PE1-PE3 remain unchanged.** `package.json` name prefix, `manifest.name`, and the standard `manifest.runtime.apiVersion` placeholder are unchanged pre-existing notes.

---

## New issues introduced in v3.0.2

None. I did not find any new release-delta issues beyond the carried-forward v3.0.1 findings above.

---

## 🧪 Validation

- ✅ `yarn build`
- ✅ `yarn lint`
- ✅ `yarn test` — 326/326 tests passed
- ⚠️ Same existing Vitest warning remains: nested `vi.mock()` calls in `src/config.test.ts` will become errors in a future Vitest release

---

## ✅ Still Solid

- The module still has the right v2.0 shape: `InstanceBase`, named `UpgradeScripts` export, ESM package structure, `manifest.type: "connection"`, and no `package-lock.json`.
- v3.0.2 is a real corrective patch, not a no-op resubmission — the maintainer fixed most of the concrete lifecycle, cache, and polish issues from the last review.
- Package metadata now matches the submitted release version (`package.json` is `3.0.2`).

---

*Follow-up review conducted by Mal only, constrained to the v3.0.1 → v3.0.2 release delta and prior generic-snmp review context.*
