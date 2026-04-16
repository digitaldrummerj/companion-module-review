�� Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Core Context

### Patterns & Anti-Patterns Learned (2026-03-13 → 2026-04-09)

Reviewed 25+ modules across multiple releases. Key learnings:

**Critical Findings (Most Common):**
- Missing `runEntrypoint()` call — module won't bootstrap in Companion
- Source code at root level instead of `src/` — template violation
- `package-lock.json` presence — instant rejection (use yarn.lock only)
- Missing `type: "connection"` in manifest.json — blocks v4.3+ compatibility
- Banned keywords in manifest names (manufacturer/product names)
- Duplicate source files (outdated root-level code vs. refactored src/)

**High Findings (Recurring Patterns):**
- `checkConnection()` ignoring `response.ok` — silent failures
- `JSON.stringify(err)` produces `{}` for native Errors — always use `err.message` or `err.stack`
- Unhandled promise rejections in action callbacks
- `destroy()` no-op when cleanup needed (unresolved requests)
- No connection retry/backoff strategy
- Config value mismatches across sections (e.g., action ID case: `setOid` vs `setOID`)

**Medium Findings:**
- Missing upgrade scripts for breaking changes (renames, removed options, config changes)
- Silent error swallowing via `.catch(() => {})` without logging
- Race conditions on connection updates
- Typos in manifest (e.g., "Serivce" → "Service")

**Architecture Patterns (Solid):**
- `destroy()` that calls `stop()` is correct — if `stop()` exists, `destroy()` must invoke it
- Binary protocol implementations benefit from custom types and protocol documentation
- PQueue for device communication rate limiting (prevents flooding)
- EventEmitter for async event handling
- Proper TCP lifecycle: handshake, heartbeat, queue, cleanup

**First Release Anti-Pattern:**
- New modules commonly missing all template scaffolding (scripts, linting, build config)
- Results in instant rejection — requires manual structure rebuild

### Recent Sessions (2026-04-05 → 2026-04-09)

- behringer-wing v2.3.0: 8 findings (critical connection handling regression)
- noctavoxfilms-tallycomm v1.0.0: First release lacking template structure
- wearefalcon-falconplay v1.0.0: Duplicate source files, name mismatch
- adder-ccs-pro v0.1.2: Template compliance violations
- 12+ other module reviews with varying findings

---

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

## behringer-wing v2.3.1 (2026-04-16) — Re-Review

**Module:** companion-module-behringer-wing v2.3.1
**API:** @companion-module/base ~1.13
**Release Type:** Follow-up patch to v2.3.0

**Final Verdict:** ✅ APPROVED — All 8 findings from v2.3.0 fixed; no regressions or new issues.

**Findings Fixed:**
- 🔴 C1: Connection error handler regression (v2.3.0) — `updateStatus(InstanceStatus.ConnectionFailure)` restored
- 🟠 H1: `JSON.stringify(err)` → uses `err.message` + `err.stack` 
- 🟠 H2: Missing connection retry handling — retry logic with exponential backoff added
- 🟠 H3: Incomplete error message context — now includes full error details in logs
- 🟡 M1-M4: (4 medium template/linting issues) — all corrected

**What Improved:**
- Error handling now discriminates between connection failures and application errors
- Proper Error object serialization in logs (not empty `{}`)
- Retry strategy with jitter prevents thundering herd on outages
- No new issues introduced; build passes, module structure intact

**Pattern Learned:**
When a follow-up patch fixes all prior findings with no new issues, module is ready for release. The v2.3.0 → v2.3.1 cleanup was thorough and professional.

**Review file:** reviews/behringer-wing/review-behringer-wing-v2.3.1-20260416-054930.md

## generic-snmp v3.0.1 (2026-04-16) — Same-tag follow-up

**Module:** companion-module-generic-snmp v3.0.1
**API:** @companion-module/base ~2.0.3
**Release Type:** Follow-up review against the same submitted tag

**Final Verdict:** ❌ CHANGES REQUIRED — no prior findings fixed; no new release-delta issues introduced.

**Key Paths:**
- Review baseline: `reviews/generic-snmp/review-generic-snmp-v3.0.1-20260409-214750.md`
- Follow-up review: `reviews/generic-snmp/review-generic-snmp-v3.0.1-20260416-055357.md`
- Module checkout: `/Users/lynbh/Development/companion-module-reviews/companion-modules-reviewing/companion-module-generic-snmp`

**Pattern Learned:**
When a same-tag resubmission has no module-code delta, carry forward every prior finding unchanged and only check for regressions inside the tiny delta that actually moved. For generic-snmp, the unresolved blockers all still live in `src/index.ts`: `pollOids()`, `initializeConnection()`/`createListener()`, and `connectAgent()`.

**Validation Note:**
`yarn build`, `yarn lint`, and `yarn test` still pass, but `yarn test` continues to emit the known Vitest warning about nested `vi.mock()` calls in `src/config.test.ts`.

## generic-snmp v3.0.2 (2026-04-16) — Follow-up release

**Module:** companion-module-generic-snmp v3.0.2  
**API:** @companion-module/base ~2.0.3  
**Release Type:** Follow-up patch to v3.0.1

**Final Verdict:** ❌ CHANGES REQUIRED — 12 prior findings fixed, but the trap-listener lifecycle still has 1 blocking high issue.

**Key Result:**
- Fixed: H1, H3, M1, M4, M6, M8, L1, L2, L4, L5, L6, L7
- Still blocking: H2 (`createListener()` can still orphan an in-flight promise during rapid trap-enabled config changes)
- No new v3.0.2 delta issues introduced

**Pattern Learned:**
A generation guard placed after `await` does not fix an async lifecycle bug when the awaited promise itself can be orphaned. If teardown removes the only listeners that can resolve or reject an in-flight bind, the fix has to settle that promise directly or avoid stripping its handlers.

**Review file:** reviews/generic-snmp/review-generic-snmp-v3.0.2-20260416-055914.md

## generic-snmp v3.0.2 (2026-04-16) — Re-Review Complete

**Module:** companion-module-generic-snmp v3.0.2  
**Release:** Follow-up patch to v3.0.1  
**Re-Review Date:** 2026-04-16T06:02:12Z

**Final Verdict:** ❌ CHANGES REQUIRED — Same verdict as first review (H2 blocking).

**Session Outcome:**
- Orchestration log written: `.squad/orchestration-log/2026-04-16T06:02:12Z-mal.md`
- Session log written: `.squad/log/2026-04-16T06:02:12Z-generic-snmp-v3-0-2-rereview.md`
- Decision merged to `.squad/decisions.md`
- Tracker and review files confirmed in place

**Decision Record:**
See `.squad/decisions.md` → "2026-04-16T06:02:12Z: generic-snmp v3.0.2 re-review verdict"

## adder-ccs-pro v0.1.2 (2026-04-16) — Same-tag follow-up

**Module:** companion-module-adder-ccs-pro v0.1.2  
**API:** @companion-module/base ~1.14.1  
**Release Type:** Same-tag re-review

**Final Verdict:** ❌ CHANGES REQUIRED — no release-code delta, 3 critical template findings still open.

**Key Result:**
- Closed on re-check: M3 (`LICENSE` already matches the JS template aside from the allowed copyright line)
- Still open: C1, C2, C3, M1, M2, M4
- No new release-delta issues introduced

**Pattern Learned:**
On same-tag follow-ups, re-check template findings against the authoritative template instead of blindly carrying every prior diagnosis forward. For adder-ccs-pro, the unresolved `.prettierignore` problem was wrong content rather than a missing file, while the prior `LICENSE` finding closed once the template exception for the copyright line was applied.

**Review file:** reviews/adder-ccs-pro/review-adder-ccs-pro-v0.1.2-20260416-060356.md

---

## Session: adder-ccs-pro v0.1.2 Follow-Up (2026-04-16T06:05:40Z)

**Orchestration Log:** `.squad/orchestration-log/2026-04-16T06:05:40Z-mal.md`

**Task:** Re-review of v0.1.2 release post-v0.1.1 discovery of template issues.

**Outcome:** No shipped module delta found; only `.github/ISSUE_TEMPLATE/*` added post-tag. Re-verified LICENSE against template (confirmed compliant with expected copyright exception). Carried forward 6 findings (C1, C2, C3, M1, M2, M4) from prior review. Closed M3. Verdict unchanged: **CHANGES REQUIRED**.

**Session Log:** `.squad/log/2026-04-16T06:05:40Z-adder-ccs-pro-rereview.md`


## logos-proclaim v1.2.0 (2026-04-16) — Same-tag follow-up

**Module:** companion-module-logos-proclaim v1.2.0  
**API:** @companion-module/base ~1.14.1  
**Release Type:** Same-tag follow-up review

**Final Verdict:** ❌ CHANGES REQUIRED — only `yarn.lock` changed after `v1.2.0`; none of the prior findings were fixed.

**Key Result:**
- Fixed: none
- Still open: C1, C2, H2, L1, L2, plus all 4 advisory notes
- No new release-delta issues introduced

**Pattern Learned:**
When a same-version follow-up only changes a lockfile, keep the review pinned to the previously reported source findings and explicitly say the dependency bump did not alter the module verdict.

**Review file:** reviews/logos-proclaim/review-logos-proclaim-v1.2.0-20260416-060658.md

## prodlink-draw-on-slides v1.0.2 (2026-04-16) — Follow-up release

**Module:** companion-module-prodlink-draw-on-slides v1.0.2  
**API:** @companion-module/base ~1.12.0  
**Release Type:** Follow-up patch to v1.0.0

**Final Verdict:** ❌ CHANGES REQUIRED — 14 prior findings fixed, but the duplicate reproducible-build blocker remains and the new lint script is broken.

**Pattern Learned:**
When a follow-up release adds `packageManager: "yarn@4.x"` and a committed `yarn.lock`, do not mark the lockfile finding fixed until `corepack yarn install --immutable` succeeds. A generated-but-mutable lockfile can leave the original reproducible-build blocker open even though the file now exists.

**Validation Note:**
`corepack yarn build` succeeds after a non-immutable install in a scratch checkout, but `corepack yarn install --immutable` still fails with `YN0028` and `corepack yarn lint` fails because `eslint` is not installed.

**Review file:** reviews/prodlink-draw-on-slides/review-prodlink-draw-on-slides-v1.0.2-20260416-061603.md

## 2026-04-16T06:09:25Z: logos-proclaim v1.2.0 Follow-up Re-Review

**Status:** ✅ Complete  
**Finding:** Follow-up review of logos-proclaim v1.2.0 release delta. Only yarn.lock changed (picomatch 4.0.3 → 4.0.4). Prior findings persist: C1, C2, H2, L1, L2 + 4 advisories remain unresolved. No new delta issues introduced.  
**Verdict:** ❌ CHANGES REQUIRED (unchanged from prior review)  
**Review:** `reviews/logos-proclaim/review-logos-proclaim-v1.2.0-20260416-060658.md`  
**Tracker:** Updated `reviews/TRACKER.md` with follow-up completion

## 2026-04-16T06:18:27Z: prodlink-draw-on-slides v1.0.2 Follow-up Re-Review

**Status:** ✅ Complete  
**Module:** companion-module-prodlink-draw-on-slides v1.0.2  
**Release Type:** Follow-up patch review (v1.0.0 → v1.0.2 delta)  
**Finding:** v1.0.2 fixes 14 of 16 prior findings including timeout, first-poll error handling, `any` cleanup, and missing template files. The duplicate lockfile blocker persists: `corepack yarn install --immutable` still fails with `YN0028`, so reproducible installs are not fixed. New issue introduced: lint script added (`eslint .`) but eslint not installed as dependency — `corepack yarn lint` fails.  
**Verdict:** ❌ CHANGES REQUIRED — carries forward blocker + introduces new lint-path blocking issue  
**Review:** `reviews/prodlink-draw-on-slides/review-prodlink-draw-on-slides-v1.0.2-20260416-061603.md`  
**Tracker:** Updated `reviews/TRACKER.md`  
**Decision:** Merged to `.squad/decisions.md`

## generic-websocket v2.3.1 (2026-04-16) — Follow-up release

**Module:** companion-module-generic-websocket  
**API:** @companion-module/base ~1.12.0  
**Release Type:** Follow-up patch to v2.3.0

**Final Verdict:** ❌ CHANGES REQUIRED — 8 prior findings fixed, but 2 blocking high issues remain.

**Key Result:**
- Fixed: C1, C2, C4, C5, M3, M4, L3, L4
- Still blocking: H1 (`ws.send()` ping timers still lack error callbacks), H2 (Origin header still hardcodes `http://` for `wss://`)
- No new v2.3.1 delta issues introduced

**Pattern Learned:**
In Companion follow-up reviews, `companion/manifest.json` carrying `"version": "0.0.0"` is not a regression by itself. Validate the built `pkg/companion/manifest.json` instead; if packaging stamps the real release version correctly, keep the follow-up review focused on the actual release-delta bugs.

**Review file:** reviews/generic-websocket/review-generic-websocket-v2.3.1-20260416-062107.md

## 2026-04-16T06:24:44Z: generic-websocket v2.3.1 Follow-up Re-Review

**Status:** ✅ Completed  
**Module:** companion-module-generic-websocket v2.3.1  
**Release Type:** Follow-up patch review (v2.3.0 → v2.3.1)  
**Verdict:** ❌ CHANGES REQUIRED — 2 blocking high issues persist

**Key Result:**
- Fixed: C1, C2, C4, C5, M3, M4, L3, L4 (8 findings)
- Still blocking: H1 (ping timer error callbacks), H2 (Origin header protocol mismatch)
- No new delta issues introduced

**Pattern Reinforced:** When 8 of 10 prior findings are resolved but 2 high blockers remain, the module verdict stays CHANGES REQUIRED. Progress is notable but insufficient for release approval.

**Deliverables:**
- Review file: `reviews/generic-websocket/review-generic-websocket-v2.3.1-20260416-062107.md`
- Tracker update: `reviews/TRACKER.md`
- Decision merged to `.squad/decisions.md`


## 2026-04-16T06:26:31Z: spacecommz-intercom v1.1.1 Follow-up Review

**Status:** ✅ Completed  
**Module:** companion-module-spacecommz-intercom v1.1.1  
**Release Type:** Follow-up patch review (v1.1.0 → v1.1.1)  
**Verdict:** ❌ CHANGES REQUIRED — 11 prior findings fixed, but 1 critical blocker remains and a new lint failure was introduced

**Key Result:**
- Fixed: C1, C2, C4, H1, H2, H3, H4, M1, M2, M4, M6
- Still blocking: C3 (`package.json` still missing the template-required `"type": "module"` field)
- New issue: M8 (`corepack yarn lint` now exists but fails with 11 ESLint errors)

**Pattern Learned:** When a follow-up release adds missing template lint tooling, re-run the new lint path instead of assuming the template work is done. A release can close most structural findings and still introduce a new medium issue if the newly added `lint` script fails on the submitted source.

**Deliverables:**
- Review file: `reviews/spacecommz-intercom/review-spacecommz-intercom-v1.1.1-20260416-062631.md`
- Tracker update: `reviews/TRACKER.md`
- Decision recorded to `.squad/decisions/inbox/mal-spacecommz-intercom-rereview.md`

### Session closed: Inbox decision merged to decisions.md (2026-04-16T06:32:45Z)

The spacecommz-intercom v1.1.1 follow-up decision has been merged into `.squad/decisions.md`. Inbox file removed.
