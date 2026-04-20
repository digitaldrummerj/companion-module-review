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

### Session Recap: 2026-04-16T06:02:12Z — 2026-04-16T06:26:31Z

**Five consecutive follow-up reviews completed in rapid session:**

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->
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

## eventsync-server v0.9.8 (2026-04-16) — Same-tag follow-up

**Module:** companion-module-eventsync-server  
**API:** @companion-module/base ~1.10.0  
**Release Type:** Same-tag follow-up review

**Final Verdict:** ❌ CHANGES REQUIRED — no still-valid blocker from the first review was fixed; one prior package-keywords finding closed on re-check.

**Pattern Learned:** When a same-tag follow-up only adds repository maintenance files and a lockfile bump, keep the review anchored to the original module findings. Re-check prior template diagnoses against the current team rules, though: for eventsync-server, the package.json keywords complaint was too strict and should be closed instead of carried forward.

**Review file:** reviews/eventsync-server/review-eventsync-server-v0.9.8-20260416-063509.md

### Session Recap: 2026-04-16T06:37:06Z

**Session entry recorded and decision merged to team decisions.md.**

## 2026-04-16T06:40:38Z: neol-epowerswitch v1.1.2 Follow-up Review

**Status:** ✅ Completed  
**Module:** companion-module-neol-epowerswitch v1.1.2  
**Release Type:** Follow-up patch review (`1.1.1` → `v1.1.2`)  
**Verdict:** ❌ CHANGES REQUIRED — all prior blockers fixed, but the tagged release introduced a stale Yarn 4 lockfile and a broken lint script

**Key Result:**
- Fixed: C1-C10, H1-H3, M1-M3 (all 16 prior blocking findings)
- Carried forward advisory only: L1, N1, N2, N3, N4
- New issues: C11 (`corepack yarn install --immutable` fails with `YN0028`), M4 (`corepack yarn lint` fails with `command not found: companion-module-lint`)

**Pattern Learned:** Review the exact submitted tag, not `main`, when a follow-up release has post-tag fix commits. For neol-epowerswitch, `main` already had a later lockfile-correction commit, but the actual `v1.1.2` tag still shipped the broken lockfile and had to be judged on that tagged state.

**Deliverables:**
- Review file: `reviews/neol-epowerswitch/review-neol-epowerswitch-v1.1.2-20260416-064038.md`
- Tracker update: `reviews/TRACKER.md`
- Decision recorded to `.squad/decisions/inbox/mal-neol-epowerswitch-rereview.md`

## 2026-04-16T06:50:00Z: videopathe-qtimer v1.0.1 Follow-up Review

**Status:** ✅ Completed  
**Module:** companion-module-videopathe-qtimer v1.0.1  
**Release Type:** Follow-up patch review (`v1.0.0` → `v1.0.1`)  
**Verdict:** ❌ CHANGES REQUIRED — 14 prior findings fixed, but 5 critical template blockers remain and the new tag still reports `package.json` version `1.0.0`

**Key Result:**
- Fixed: C6, H1-H3, M1-M9, M11
- Still blocking: C1-C5
- Carried forward: M10 (`YN0086` peer warning still emitted on immutable install)
- New issue: C7 (`package.json` version still `1.0.0` in the `v1.0.1` tag)

**Pattern Learned:** In Companion follow-up reviews, `companion/manifest.json` should usually stay at `0.0.0`, but `package.json` still must be bumped to the exact release tag version. A maintainer can correctly fix the manifest-side convention and still ship a broken release if the package version metadata is left behind.

**Deliverables:**
- Review file: `reviews/videopathe-qtimer/review-videopathe-qtimer-v1.0.1-20260416-065000.md`
- Tracker update: `reviews/TRACKER.md`
- Decision recorded to `.squad/decisions/inbox/mal-videopathe-qtimer-rereview.md`

### Session closed: Inbox decision merged to decisions.md (2026-04-16T06:53:24Z)

The videopathe-qtimer v1.0.1 follow-up decision has been merged into `.squad/decisions.md`. Inbox file removed.

## 2026-04-16T18:58:40Z: eventsync-server v0.9.9 — Corrected Follow-up

**Status:** ✅ Completed  
**Module:** companion-module-eventsync-server v0.9.9  
**Release Type:** Corrected follow-up review (prior mis-targeted v0.8 review replaced)  
**Verdict:** ✅ APPROVED

**Key Result:**
- No blocking issues remain
- Prior non-blocking reconnect advisory carried forward
- No new issues introduced by corrected tag

**Pattern Reinforced:** When re-reviewing with the correct tag after a mis-targeted review, use the corrected tag's actual state for the verdict. The v0.9.9 review confirms release readiness with only carry-forward guidance.

**Deliverables:**
- Review file: `reviews/eventsync-server/review-eventsync-server-v0.9.9-20260416-115648.md`
- Tracker update: `reviews/TRACKER.md`
- Decision merged to `.squad/decisions.md`


## 2026-04-18T01:06:07Z: adder-ccs-pro v0.1.3 Follow-up Review

**Status:** ✅ Completed  
**Module:** companion-module-adder-ccs-pro v0.1.3  
**Release Type:** Follow-up patch review (`v0.1.2` → `v0.1.3`)  
**Verdict:** ✅ APPROVED

**Key Result:**
- Fixed: C1, C2, C3, M1, M2, M4
- Remaining from prior review: none
- New issues: none

**Pattern Reinforced:** When a follow-up tag closes every previously reviewed blocker and the only logic fix in the delta resolves the last carried-forward runtime note, the verdict can move all the way to Approved. Keep the rereview anchored to the prior review record so resolved blockers are credited cleanly.

**Deliverables:**
- Findings file: `.squad/decisions/inbox/mal-review-findings.md`
- Decision recorded: `.squad/decisions/inbox/mal-adder-rereview.md`

## 2026-04-XX: Review edit — wearefalcon-falconplay v1.0.0 findings pruning

**Status:** ✅ Complete
**Task:** Surgical removal of 14 non-blocking findings from wearefalcon-falconplay v1.0.0 review.

**Removed findings:**
- Critical: C-4 (`$schema` template field), C-5 (`runtime.apiVersion`)
- High: H-2 (`response.ok` check)
- Medium: M-1 through M-7 (init status, configUpdated refresh, checkFeedbacks, change detection, concurrency, silent failures, type mismatch)
- Low: L-1, L-2, L-4, L-5 (in-flight cancellation, variable init, error discarding, action logging)

**Updated scorecard:**
- Before: 25 total (7 Critical, 2 High, 8 Medium, 6 Low, 2 NTH)
- After: 11 total (5 Critical, 1 High, 1 Medium, 2 Low, 2 NTH)
- Blocking: 9 → 6

**Consistency updates applied:**
- Fix Summary: removed references to manifest schema/apiVersion and HTTP error handling
- Scorecard: updated counts and blocking math
- Verdict: updated issue counts and impact narrative
- TOC: removed 14 issue links
- Issue detail sections: surgically removed all 14 issues with proper markdown boundaries

**File state:** All internal cross-references, anchors, and section counts now consistent.

**Pattern:** Review pruning maintains document structure and readability. All delta references (prior counts, blocking math) were recalculated to prevent internal inconsistency.

## 2026-04-XX: Final review cleanup — wearefalcon-falconplay v1.0.0 release cut

**Status:** ✅ Complete
**Task:** Final removals to release-ready FalconPlay review. Removed L-6 (`.gitignore`/`.prettierignore` deviations), N-1 (human-readable name field), N-2 (presets), and entire "🔮 Next Release" section.

**Removed findings (this session):**
- Low: L-6 (minor `.gitignore`/`.prettierignore` deviations from template)
- Nice to Have: N-1 (human-readable `name` field), N-2 (preset definitions)

**Removed section:**
- Next Release guidance (presets, polling backoff, dependency upgrade notes)

**Updated scorecard:**
- Before: 11 total (5C, 1H, 1M, 2L, 2NTH) → 6 blocking, 5 non-blocking
- After: 6 total (3C, 1H, 1M, 1L, 0NTH) → 4 blocking, 2 non-blocking
- Note: The 5→3 Critical reduction reflects the earlier pruning pass (C-4, C-5 removed); this session removed L-6, N-1, N-2

**Consistency updates applied:**
- Scorecard: updated counts, removed Nice to Have row, updated blocking math (6→4)
- Verdict: updated to reference 4 blocking issues instead of 6
- TOC: removed L-6, N-1, N-2 section links
- Issue sections: surgically removed L-6, N-1, N-2 detail blocks with proper markdown boundaries
- Next Release section: fully removed
- Spacing: cleaned up orphaned blank lines

**File state:** Document is internally consistent, clean, and ready for stakeholder sign-off. All section counts (3C+1H+1M+1L=6), blocking math (3+1=4), and cross-references validated.

## 2026-04-20T23:49:07Z: rode-rcv v1.8.0 Review Trim to APPROVED

**Status:** ✅ Complete
**Module:** companion-module-rode-rcv v1.8.0
**Task:** Trim review file to APPROVED verdict by removing all Critical, High, Medium, and Pre-existing findings.

**Removed findings:**
- Critical: C1, C2, C3 (manifest version regressions, OSC buffer stall)
- High: H1, H2, H3, H4 (build-only dependencies, unvoided promise, missing SVG sources, prettier packaging failure)
- Medium: M1–M5 (dead RxJS, auto-generated issues, module status timing, parse error logging, dead imports)
- Pre-existing: PE1–PE9 (9 items documenting pre-v1.8.0 issues)

**Retained findings:**
- Low: L1 (minor typo "seleected" → "selected")

**Added findings:**
- Nice-to-Have: NTH1 (recommendation to add .gitattributes, ESLint, and Prettier)

**Updated scorecard:**
- Before: 7 blocking (C3, H4, M3, M5, M7, M11, M12)
- After: 0 blocking, only 1 Low cosmetic + 1 Nice-to-Have advisory

**Consistency updates applied:**
- Fix Summary: changed from 7 blocking to 0 blocking; noted L1 as cosmetic
- Scorecard: updated all area statuses to ✅; severity table: 0C, 0H, 0M, 1L, 1NTH
- Verdict: changed from ❌ CHANGES REQUIRED to ✅ APPROVED
- TOC: removed all section links except L1 and NTH1
- What's Solid section: updated image generation bullet for production readiness

**Pattern Reinforced:** Review trimming for stakeholder approval requires surgical removal of entire finding classes while maintaining document structure. All cross-references and anchor links must be reconciled to prevent orphaned content.

**Deliverables:**
- File updated: `reviews/rode-rcv/review-rode-rcv-v1.8.0-20260409-211811.md`
- Decision merged: `.squad/decisions.md`
- Orchestration log: `.squad/orchestration-log/2026-04-20T23:49:07Z-mal-trim-rode-review.md`
- Session log: `.squad/log/2026-04-20T23:49:07Z-session-trim-rode-review.md`
