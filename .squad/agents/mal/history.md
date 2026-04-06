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

### 2025-07-17: softouch-easyworship v2.1.0 review — REJECTED

**Module:** companion-module-softouch-easyworship v2.1.0
**API:** `@companion-module/base` ^1.11.0 (v1.x rules)
**Previous:** v2.0.2

**Critical Finding (BLOCKING):**
- `connectezw` action calls `this.clearIdleTimer()` which is not defined anywhere — runtime TypeError crash. Likely should be `this.clearKeepalive()`.

**Medium Findings:**
- 13 actions had dummy dropdown options removed without upgrade scripts (options were non-functional single-choice "Not used" dropdowns — not breaking but should be cleaned up)
- `@companion-module/base` version `1.11.3` doesn't satisfy `@companion-module/tools` peer dep of `^1.12.0`
- Manifest version says "2.0.2" but package.json says "2.1.0"

**Architecture Notes:**
- Substantial rewrite of connection handling — exponential backoff, keepalive, buffer management, Bonjour discovery
- v1.x compliance correct — `runEntrypoint` present, all lifecycle methods implemented
- JavaScript CJS module (no `"type": "module"`), source files at root (not `src/`)
- Optimistic state updates with rollback pattern — good
- `is_connected` feedback and `Connected` variable added — good additions
- Pre-existing `destroy()` bug (bare `bonjour` reference) fixed in v2.1.0
- `yarn build` succeeds, yarn-only lockfile, no `dist/` committed
- No tests exist (not blocking per decisions)

### 2026-04-02: softouch-easyworship v2.1.0 RE-REVIEW — REJECTED

**Module:** companion-module-softouch-easyworship v2.1.0
**Session:** 2026-04-02T041821Z

**Blocking Issue (NEW FINDING):**
- Same `clearIdleTimer()` issue from previous review session remains unfixed
- Orchestration log: `.squad/orchestration-log/2026-04-02T041821Z-mal.md`

### 2026-04-06: glensound-gtmmobile v1.0.0 review — CHANGES REQUIRED

**Module:** companion-module-glensound-gtmmobile v1.0.0
**API:** `@companion-module/base ~1.8.0` (v1.x rules)
**Release type:** First release — all code is new

**Critical Findings (15 total — all blocking):**
- 12 template compliance violations: missing required files (.gitattributes, .prettierignore, .yarnrc.yml, yarn.lock), incorrect .gitignore, incorrect package.json structure (repository, engines, scripts, devDependencies, banned keywords), incorrect manifest.json fields (name, repository, runtime, $schema, maintainer email)
- 3 logic errors: channel array index mismatch (inconsistent 1-13 vs 2-14 ranges), silent command failures (no InstanceStatus update on sendCmd error), race condition in configUpdated (socket close is async but start() called immediately)

**Medium/Low Findings:**
- Missing error handler on bind operations (Medium)
- Inconsistent socket error handling (Medium)
- Mute/volume toggle with null state defaults unexpectedly (Medium)
- Missing error propagation in action callbacks (Medium)
- Async action callbacks without await (Low)
- No reconnection logic after socket error (Low)
- Various cosmetic and defensive programming issues (Low)

**Architecture Notes (positive):**
- v1.x compliance correct — `runEntrypoint(GlenSoundGTMMobile, [])` present at end of main.js
- All lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- Clean dual-socket UDP architecture: command socket for sending, multicast socket for status
- Proper cleanup in `closeSockets()` — clears intervals, drops multicast membership, closes sockets
- Good auto-detection of multicast interface based on device IP subnet
- Connection timeout handling with `resetTimeout()` for offline device detection
- Clean protocol implementation with proper GlenSound packet building
- JavaScript CJS module, source files in `src/` directory
- No `dist/` committed, no `package-lock.json`
- Empty upgrade scripts correct for first release
- Well-documented HELP.md

**Fix Complexity:** Medium — template fixes are mechanical copy-paste, logic fixes require ~30 lines of code changes

**Review file:** `reviews/glensound-gtmmobile/review-glensound-gtmmobile-v1.0.0-20260406-035504.md`

### 2026-04-06: eventsync-server v0.9.8 review — CHANGES REQUIRED (Final Assembly)

**Module:** companion-module-eventsync-server v0.9.8
**API:** `@companion-module/base ~1.10.0` (v1.x rules)
**Release type:** First release — all code is new

**Final Verdict:** CHANGES REQUIRED — 17 blocking issues (12 Critical, 5 High)

**Critical Findings (12 — template compliance):**
- Missing required files: `.gitattributes`, `.prettierignore`, `.yarnrc.yml`, `tsconfig.build.json`, `.husky/pre-commit`
- Incorrect `.gitignore` content (missing entries, wrong paths, extra comments)
- Missing `package.json` fields: `engines`, `packageManager`
- Wrong `prettier` config (inline object instead of shared config reference)
- Wrong repository URLs in both `package.json` and `manifest.json` (eventsync org instead of bitfocus)
- Missing required scripts: `postinstall`, `package`, `build:main`, `lint:raw`

**High Findings (5 — protocol and dependencies):**
- WebSocket event listeners not removed in `disconnect()` — memory leak (`src/connection.ts:67-75`)
- Auth failure reconnect loop — infinite 5s reconnect cycle on bad passcode (`src/connection.ts:89-92`)
- Outdated `@companion-module/base ~1.10.0` requires Node 18, incompatible with Node 22 runtime
- Outdated `@companion-module/tools ^2.6.1` — missing Node 22 TypeScript config
- Missing `lint-staged` configuration in `package.json`

**Medium Findings (5):**
- Version mismatch: `package.json` 0.9.8 vs `manifest.json` 0.9.6
- Passcode uses `textinput` instead of `secret-text` (credential exposure)
- No exponential backoff on reconnect attempts
- Unhandled promise rejections in async action callbacks
- Silent failures when `send()` called on closed WebSocket

**Architecture Notes (positive):**
- v1.x compliance correct — `runEntrypoint(EventSyncModule, [])` at end of main.ts
- All lifecycle methods implemented correctly
- Clean TypeScript — no `any` abuse, proper interfaces
- WebSocket with reconnection logic, ping keepalive
- Good separation of concerns across 8 source files
- 32 actions, 14 feedbacks, rich preset library

**Build Status:** ❌ FAILED (`@companion-module/base@1.10.0` incompatible with Node 22)

**Review file:** `reviews/eventsync-server/review-eventsync-server-v0.9.8-20260406-040342.md`

### 2026-04-06: cosmomedia-slidelizer v1.0.0 review — APPROVED

**Module:** companion-module-cosmomedia-slidelizer v1.0.0
**API:** `@companion-module/base ~1.14.1` (v1.x rules)
**Release type:** First release — all code is new

**Verdict:** APPROVED — clean first-release module with no blocking issues.

**Minor Finding:**
- `.gitignore` should include `dist/` — currently has `package-lock.json` but not `dist/`. Not blocking since no dist exists yet.

**Architecture Notes (positive):**
- v1.14 compliance correct — `runEntrypoint(SlidelizerInstance, [])` at line 330 of `src/main.js`
- All lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- Clean socket cleanup in `destroy()` — closes TCP socket AND clears reconnect timer
- Good reconnection logic with exponential backoff (1s to 10s max)
- 9 variables covering timer, clock, and video modes with multiple format variants
- 5 advanced feedbacks returning formatted text
- Uses `node22` runtime in manifest (correct for v1.14)
- JavaScript CJS module, source in `src/` directory
- Empty UpgradeScripts correct for first release
- No deprecated v1.12+ patterns (`isVisible`, redundant `parseVariablesInString`)
- No `package-lock.json` committed, uses yarn-only

**Review file:** `.squad/decisions/inbox/mal-review-findings.md`
