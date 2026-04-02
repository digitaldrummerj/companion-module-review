📌 Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2026-04-01: rtw-touchmonitor review - REJECTED

**Module:** companion-module-rtw-touchmonitor v1.0.1
**Device:** RTW TouchMonitor series (TMxCore, TouchControl 5, TouchMonitor 5) via OSC

**Blocking Issue Found:**
- `runEntrypoint(ModuleInstance, UpgradeScripts)` is missing from `src/main.ts` - without this call, the module will not bootstrap with Companion. Template requires this at module end.

**Architecture Notes:**
- Uses `@companion-module/base` v2.0.1 (newer than template's v1.14.1)
- Uses `@companion-module/tools` v3.0.0 (newer than template's v2.6.1)
- Correctly extends `InstanceBase` with custom `RtwTypes` for full type safety
- Properly exports `UpgradeScripts` but never passes them to `runEntrypoint`
- Has a custom `StatusManager` utility class with throttling (good pattern)
- Uses `PQueue` for OSC message rate limiting (good for device communication)
- No presets file (optional, not blocking)
- Empty feedbacks/variables (OSC is send-only for this device)
- `dist/` in .gitignore but present locally (not committed - OK)
- Uses ESM (`"type": "module"`) with proper `.js` extensions on imports

**Session Closed:** 2026-04-01T18:42:18Z (re-review)
Orchestration log written to `.squad/orchestration-log/2026-04-01T21:43:37Z-mal.md`
Session log: `.squad/log/2026-04-01T21:43:37Z-rtw-touchmonitor-review.md`

### 2026-04-02: generic-snmp v3.0.0 review - APPROVED WITH NOTES (initial)
### 2026-04-02: generic-snmp v3.0.0 RE-REVIEW - REJECTED (all four prior findings unaddressed)

**Module:** companion-module-generic-snmp v3.0.0
**API:** `@companion-module/base ~2.0.2` (v2.0 rules)
**Previous:** v2.3.0 (JavaScript) → v3.0.0 (full TypeScript conversion + API 2.0)

**Critical Finding (STILL UNFIXED):**
- Action ID case mismatch: upgrade script targets `'setOid'` (line 194 of upgrades.ts) but new enum registers `'setOID'` (actions.ts line 28). Upgrade migrates options but doesn't rename the actionId — existing "Set OID value to an OID" buttons silently break.

**Medium Findings (ALL STILL UNFIXED):**
- `getOID` action upgrade in v300 doesn't remove stale `displaystring` option (the feedback branch does it correctly, action branch omits it)
- Dead export `DisplayStringOption` in options.ts — leftover from v2.x, not used anywhere
- Non-awaited `walk()` calls in `initializeConnection()` — "complete" log fires before walk finishes; async errors silently swallowed via `.catch(() => {})`

**Architecture Notes:**
- v2.0 compliance is thorough — correct `InstanceBase<ModuleTypes>` with full InstanceTypes shape, no removed APIs, proper exports
- Upgrade scripts cover DisplayString→encoding rename, config defaults, engine ID generation, secrets migration
- 329 tests passing across 8 test files (no upgrade tests exist)
- Strong TypeScript — no `any` in production code, proper schemas for actions/feedbacks
- Uses `optionsToMonitorForSubscribe` correctly on all subscribing actions
- `learn` callbacks correctly return only learned options
- Clean ESM with `.js` extensions, `moduleResolution: "nodenext"`
- `yarn package` succeeds, yarn-only lockfile

**Process Note:**
- Re-review was requested by Justin James after prior APPROVED WITH NOTES verdict
- None of the flagged issues were addressed between review sessions
- Per new process rules: findings written to `.squad/decisions/inbox/mal-review-findings.md` (NOT to module directory)

### 2025-07-17: fiverecords-tallyccupro v3.0.2 review — APPROVED WITH NOTES

**Module:** companion-module-fiverecords-tallyccupro v3.0.2
**API:** `@companion-module/base` ~1.14.1 (v1.x rules)
**Release type:** First release — all code is new, no prior versions

**Key Findings:**
- Source files at module root instead of `src/` directory (High — structural violation per directive)
- Release tags (`3.0.2`, `V3.0.1`, `V3.0.0`) don't follow `vMajor.Minor.Patch` format (High — per directive)
- `actions.js` is 11,920 lines / 289 actions in a single monolithic file (Medium — maintainability)
- All 284 `sendParam()` calls in action callbacks are not awaited (Medium — silent error swallowing)
- ~133 Spanish comments and some Spanish log messages (Medium — English-language project)
- License mismatch: HELP.md says GPL-3.0, everything else says MIT (Medium)
- `feedbacks.js` exists but is never imported or called from `main.js` (Medium — dead code)

**Architecture Notes:**
- v1.x compliance is correct — `runEntrypoint` present, all lifecycle methods implemented
- Dual-channel architecture: HTTP for commands, TCP push for real-time sync — well designed
- Clean timer/socket cleanup in `destroy()`
- `yarn package` succeeds, yarn-only lockfile, no `dist/` committed
- JavaScript (CJS) module — no `"type": "module"` set, uses `require()` throughout
- Empty `UpgradeScripts` is correct for a first release
- `companion/manifest.json` uses `node22` runtime correctly
