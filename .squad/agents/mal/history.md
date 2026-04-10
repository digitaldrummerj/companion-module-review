📌 Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

### 2025-04-05: highcriteria-lhs v1.0.0 review - CHANGES REQUIRED

**Module:** companion-module-highcriteria-lhs v1.0.0
**API:** `@companion-module/base ~2.0.3` (v2.0)
**Release Type:** FIRST RELEASE

**Final Verdict:** ❌ CHANGES REQUIRED — Missing `type: "connection"` manifest field (critical blocker), 3 template violations, action error handling deficiencies

**Blocking Issues:**
1. **C1:** Missing `"type": "connection"` field in manifest.json — module will not load in Companion 4.3+
2. **C2:** `.gitignore` contains extra `*.pcap` entry not in template — violates file structure compliance
3. **C3:** `eslint.config.mjs` has unnecessary test file configuration block (module has no tests) — simplify to match template
4. **C4:** `tsconfig.build.json` uses `nodenext` instead of `Node16` without justification — requires either reverting or documenting reason

**Secondary Issues:**
1. **H1:** Unhandled promise rejections in 6 action callbacks — lacks try-catch blocks, no error logging; silent failures risk process crash
2. **H2:** Potential race condition on config update — old client events may fire after new client created
3. **H3:** No reconnection backoff strategy — tight 2s retry loop hammers server during outages
4. **H4:** Silent handshake failures — promise catch swallows errors without user notification
5. **M1:** Missing maintainer email in manifest.json
6. **M2:** Typos in manifest.json: `shortname` "Serivce" → "Service", `description` "intergration" → "integration"

**What's Solid:**
- ✅ Excellent binary protocol implementation — comprehensive LHS protocol documentation with proper framing (magic markers), byte order consistency, state parsing
- ✅ Clean TypeScript structure — proper module layout, source in `src/`, correct build configuration (ESM, dist-based)
- ✅ Proper connection lifecycle — TCP client with handshake, heartbeat, queue management, proper cleanup
- ✅ Good use of patterns — EventEmitter for async communication, PQueue for write serialization (prevents device flooding)
- ✅ Build succeeds — `yarn install`, `yarn build`, `yarn package` all pass, generates 10KB tarball
- ✅ Comprehensive manifest — correct ID, name, runtime type, entrypoint configuration
- ✅ Strong helper documentation — HELP.md contains real documentation of actions and feedbacks

**Agents Contributing:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)

**Review files:**
- `.squad/decisions/inbox/mal-review-findings.md`
- `.squad/decisions/inbox/kaylee-review-findings.md`
- `.squad/decisions/inbox/wash-review-findings.md`
- `.squad/decisions/inbox/zoe-review-findings.md`
- `.squad/decisions/inbox/simon-review-findings.md`

**Session Closed:** 2025-04-05T22:15:00Z
Decisions log: `.squad/decisions/decisions.md`

---

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

### 2026-04-06: cosmomedia-slidelizer v1.0.0 review — CHANGES REQUIRED (Final Assembly)

**Module:** companion-module-cosmomedia-slidelizer v1.0.0
**API:** `@companion-module/base ~1.14.1` (v1.x rules)
**Release type:** First release — all code is new

**Final Verdict:** CHANGES REQUIRED — 3 High severity issues need attention

**Blocking Findings (3 High):**
- Race condition in `configUpdated()` — multiple parallel connections possible (`src/main.js:38-42`)
- Event listener accumulation / memory leak risk in `_connect()` (`src/main.js:69-134`)
- Unhandled promise rejection in `configUpdated()` — no try-catch (`src/main.js:38-42`)

**Severity Adjudications (overridden from Kaylee's Critical):**
- `@companion-module/tools ^2.6.1` → Downgraded to Medium. Build succeeds; template skill doesn't mandate specific version.
- Missing `keywords` in package.json → Downgraded to Low. Not a required field per template compliance skill; manifest.json has keywords.
- Missing `author` in package.json → Downgraded to Low. Not a required field per template compliance skill.

**Architecture Notes (positive):**
- v1.14 compliance correct — `runEntrypoint(SlidelizerInstance, [])` at line 330 of `src/main.js`
- All lifecycle methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- Clean socket cleanup in `destroy()` — closes TCP socket AND clears reconnect timer
- Good reconnection logic with exponential backoff (1s to 10s max)
- TCP line-buffered parsing handles partial packets correctly
- 11 actions, 5 feedbacks, 9 variables
- Uses `node22` runtime in manifest (correct for v1.14)
- JavaScript CJS module, source in `src/` directory
- Build succeeds: `yarn install && yarn package` → `cosmomedia-slidelizer-1.0.0.tgz`

**Fix Complexity:** Medium — requires connection locking logic and try-catch wrapper (~20 lines)

**Review file:** `reviews/cosmomedia-slidelizer/review-cosmomedia-slidelizer-v1.0.0-20260406-041041.md`

### 2025-07-18: snellwilcox-kahuna v1.0.0 review — APPROVED

**Module:** companion-module-snellwilcox-kahuna v1.0.0
**API:** `@companion-module/base ~2.0.3` (v2.0 rules)
**Release type:** First release — all code is new

**Final Verdict:** APPROVED — Excellent v2.0 API compliance, no blocking issues.

**Medium Findings (1):**
- `tsconfig.build.json:13` uses `"moduleResolution": "Node16"` instead of recommended `"nodenext"` — works but diverges from v2.0 spec guidance

**Low Findings (1):**
- `src/main.ts:194-195` empty `updatePresets()` stub — consider removing or implementing

**Architecture Notes (positive):**
- v2.0 compliance exemplary:
  - Default export class `ModuleInstance extends InstanceBase<KahunaTypes>` at line 19
  - Named export `UpgradeScripts` at line 17 (re-exported from upgrades.ts)
  - No `runEntrypoint()` call (correctly removed for v2.0)
  - `manifest.json` has `"type": "connection"` and `"node22"` runtime
  - `@companion-module/tools ^3.0.0` (correct)
  - `KahunaTypes` interface has full InstanceTypes shape: config, secrets, actions, feedbacks, variables
  - `setVariableDefinitions` uses object form (not array)
- No removed v2.0 APIs used — no `parseVariablesInString`, no bare `checkFeedbacks()`, no `optionsToIgnoreForSubscribe`
- Clean TypeScript with strict mode, no `any` abuse
- Proper ESM with `.js` extensions on imports
- Well-designed dual-TCP plugin architecture (command socket + tally socket)
- PQueue-based command serialization with abort support
- 88 passing tests across 2 test files
- Build/lint/test all pass
- All template files present, correct structure

**Review file:** `.squad/decisions/inbox/mal-review-findings.md`

### 2026-04-06: snellwilcox-kahuna v1.0.0 — FINAL ASSEMBLY — APPROVED

**Module:** companion-module-snellwilcox-kahuna v1.0.0
**API:** `@companion-module/base ~2.0.3` (v2.0 rules)
**Session:** 2026-04-06 Final Assembly

**Final Verdict:** ✅ APPROVED — Excellent v2.0 API compliance, clean build/lint/tests (88/88), no blocking issues.

**Scorecard:**
- Critical: 0
- High: 0
- Medium: 6 (queue race, unbounded queue, error handling, tally indexing, missing tsconfig.node.json, moduleResolution)
- Low: 10 (various cosmetic/enhancement items)
- Nice to Have: 3

**Kaylee's 5 "Critical" items adjudicated:**
1. `recommended-esm` instead of `recommended` → **Low** (justified for ESM module, build passes)
2. Extra tsconfig options → **Low** (enhancements not problems, build passes)
3. tsconfig includes vitest.config.ts → **Low** (necessary for test type-checking)
4. eslint custom test rules → **Low** (reasonable for test infrastructure)
5. Missing tsconfig.node.json → **Medium** (should be cleaned up, but lint passes)

**Agents Contributing:** Mal, Wash, Kaylee, Zoe, Simon

**Review file:** `reviews/snellwilcox-kahuna/review-snellwilcox-kahuna-v1.0.0-20260406-041741.md`

### 2025-07-21: allenheath-sq v3.1.0 review — APPROVED

**Module:** companion-module-allenheath-sq v3.1.0
**API:** `@companion-module/base ~1.11.3` (v1.x rules)
**Previous:** v3.0.0

**Final Verdict:** ✅ APPROVED — Full v1.11 API compliance, clean release.

**Notable Changes:**
- Runtime upgraded from `node18` → `node22` (aligns with v1.11 recommendations)
- API base upgraded from `~1.10.0` → `~1.11.3`
- Config field IDs renamed with proper upgrade script (`tryRenameVariousConfigIds`)
- Tooling updates: ESLint 10.x, TypeScript 5.9, Vitest 4.x, Yarn 4.13.0

**v1.x Required Checks — All Passed:**
- `runEntrypoint(sqInstance, UpgradeScripts)` at bottom of `src/main.ts` ✅
- `UpgradeScripts` exported from `src/upgrades.ts` ✅
- `init()`, `destroy()`, `configUpdated()`, `getConfigFields()` all implemented ✅
- No `package-lock.json`, `dist/` gitignored ✅

**Low/Info Items (non-blocking):**
- Missing `engines.yarn` field — `packageManager` field handles this (modern Yarn 4.x approach)
- `engines.node ^22.11` vs template `^22.20` — acceptable, both Node 22.x compatible
- `@companion-module/tools ^2.6.1` — devDependency, acceptable for build tooling

**Review file:** `.squad/decisions/inbox/mal-review-findings.md`

### 2026-04-06: allenheath-sq v3.1.0 — FINAL ASSEMBLY — CHANGES REQUIRED

**Module:** companion-module-allenheath-sq v3.1.0
**API:** `@companion-module/base ~1.11.3` (v1.x rules)
**Session:** 2026-04-06 Final Assembly

**Final Verdict:** 🔴 CHANGES REQUIRED — 2 Critical template violations, 1 High pre-existing issue

**Scorecard:**
- Critical: 2 (new)
- High: 1 (pre-existing)
- Medium: 2 (new)
- Low: 2 (1 new, 1 pre-existing)
- Nice to Have: 3 (new)

**Blocking Issues:**
1. **C1:** Missing `.gitattributes` file (template compliance)
2. **C2:** Missing `engines.yarn` field in package.json (template compliance)
3. **H1:** EventEmitter listener leak on reconnect (PRE-EXISTING, mixer.ts:348-427)

**Severity Adjudications (from Kaylee's 4 "Critical" items):**
1. Missing `.gitattributes` → **Critical** KEPT (required file per template)
2. Missing `engines.yarn` → **Critical** KEPT (template requires both packageManager AND engines.yarn)
3. `engines.node: ^22.11` vs `^22.20` → **Medium** DOWNGRADED (functionally compatible, cosmetic)
4. Extra `.gitignore` entries → **Medium** DOWNGRADED (low-risk deviation, cosmetic)

**Agents Contributing:** Mal, Wash, Kaylee, Zoe, Simon

**Test Results:** 527/527 passing (100%)

**Review file:** `reviews/allenheath-sq/review-allenheath-sq-v3.1.0-20260406-042531.md`

### 2025-07-22: logos-proclaim v1.2.0 review — CHANGES REQUIRED

**Module:** companion-module-logos-proclaim v1.2.0
**API:** `@companion-module/base ~1.14.1` (v1.x rules)
**Previous:** v1.1.1

**Final Verdict:** ⚠️ CHANGES REQUIRED — 1 High severity deprecated API pattern

**High Finding (Blocking):**
- `isVisible` function pattern on password config field (`src/main.js:76`) — deprecated in v1.12, must use `isVisibleExpression` string form. Module is on v1.14 so this is a compliance violation.

**Medium Finding:**
- Password config field uses `textinput` instead of `secret-text` type (available since v1.13) — credential exposure risk in exports

**v1.x Compliance Verified:**
- `runEntrypoint(ProclaimInstance, UpgradeScripts)` at `src/main.js:99` ✅
- `UpgradeScripts` exported from `src/upgrades.js` ✅
- All lifecycle methods implemented (`init`, `destroy`, `configUpdated`, `getConfigFields`) ✅
- No `package-lock.json`, no committed `dist/` ✅
- Clean timer cleanup in `ProclaimAPI.destroy()` ✅

**Release Improvements:**
- Source files reorganized from root to `src/` directory
- API upgraded from `~1.11.3` → `~1.14.1`
- Runtime upgraded to `node22`
- Modern tooling: Yarn 4.13.0, ESLint 9, Prettier 3
- Dependencies updated: `got` v12 → v14.6.6

**Review file:** `.squad/decisions/inbox/mal-review-findings.md`

### 2026-04-05: leolabs-ableset v1.8.0 review — CHANGES REQUIRED

**Module:** companion-module-leolabs-ableset v1.8.0
**API:** `@companion-module/base ~1.12.1` (v1.x)
**Previous:** v1.7.3

**Final Verdict:** ❌ CHANGES REQUIRED — 2 Critical breaking changes, 1 Medium template violation

**Blocking Issues:**
1. **CR-1:** Missing UpgradeScript for removed `SetAutoLoopCurrentSection` action — existing user buttons will silently break
2. **CR-2:** Removed `autoLoopCurrentSection` variable without migration — user expressions will break
3. **C1:** Missing `.gitattributes` file (template compliance violation)

**Secondary Issues:**
- **M1:** Potential division by zero in progress calculations (`src/main.ts:1331`, `src/main.ts:1456`)
- **Info:** No test suite configured

**Agents Contributing:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)

**Review file:** `reviews/leolabs-ableset/review-leolabs-ableset-v1.8.0-20260405-*.md`

---

### 2026-04-05: generic-websocket v2.3.0 review — CHANGES REQUIRED

**Module:** companion-module-generic-websocket v2.3.0
**API:** `@companion-module/base ~1.12.0` (v1.x)
**Previous:** v2.2.0

**Final Verdict:** ❌ CHANGES REQUIRED — 1 Critical deprecated API, 1 Critical WebSocket memory leak, 8 Critical template violations

**Blocking Issues:**
1. **CR-1:** WebSocket listener leak on reconnection — old listeners not removed before reconnecting; causes memory leak and potential duplicate message processing
2. **CR-2:** Three config fields use deprecated `isVisible` function form instead of `isVisibleExpression` (v1.12 compliance)
3. **CR-3:** Source code at module root instead of `src/` directory (template structural violation)
4. **CR-4:** Missing `.gitattributes`, invalid `.gitignore`/`.prettierignore` content (template violations)
5. **CR-5:** Missing `engines` field (`node: ^22.20`, `yarn: ^4`) in package.json (template violation)
6. **CR-6:** Missing `prettier` dev dependency (template violation)
7. **CR-7:** Banned keywords in manifest.json (`"Generic"`, `"WebSocket"` — product/manufacturer names)

**Secondary Issues:**
- **C1:** `send_command` action lacks WebSocket connection state check; regression vs. `send_hex` pattern
- **H1:** Unhandled WebSocket send errors in ping timer callbacks
- **H2:** Origin header always uses `http://` for WSS connections (should match protocol)
- **H3:** Race condition in `configUpdated()` when User-Agent changes without reconnecting
- **M1:** No validation for `ping_hex` config field (accepts invalid hex)
- **Info:** No test suite configured

**Agents Contributing:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)

**Review files:** 
- `.squad/decisions/inbox/mal-review-findings.md`
- `.squad/decisions/inbox/kaylee-review-findings.md`
- `.squad/decisions/inbox/wash-review-findings.md`
- `.squad/decisions/inbox/zoe-review-findings.md`
- `.squad/decisions/inbox/simon-review-findings.md`

---

## prodlink-draw-on-slides v1.0.0

**Module:** companion-module-prodlink-draw-on-slides  
**API:** `@companion-module/base ~1.11.0` (v1.x)  
**Release Type:** FIRST RELEASE

**Final Verdict:** ❌ CHANGES REQUIRED — 24 Critical template violations, Critical network timeout vulnerability, Critical polling race condition, Complete lack of test coverage

**Blocking Issues:**
1. **CR-1:** Missing fetch timeout leads to indefinite hangs on network partition; requests lack abort controller (5+ min default timeout)
2. **CR-2:** Critical polling race condition — unprotected immediate poll allows concurrent API calls; initial rejection unhandled
3. **CR-3:** 24 critical template violations preventing approval:
   - Missing files: `.gitattributes`, `.prettierignore`, `.yarnrc.yml`, `yarn.lock`
   - Missing package.json fields: `engines.node`, `engines.yarn`, `prettier`, `packageManager`, `type`
   - Missing 6 scripts: `postinstall`, `build:main`, `lint:raw`, `lint`, `package`, `format`
   - Missing 7 devDependencies: `@companion-module/tools`, `@types/node`, `eslint`, `husky`, `lint-staged`, `prettier`, `rimraf`, `typescript-eslint`
   - Invalid repository URL uses `prodcontroller` org instead of `bitfocus`
   - Runtime type `node18` should be `node22`
   - Missing manifest `$schema` field
   - Banned keywords: `"slides"`, `"prodlink"` (core feature and manufacturer name)
   - Single `tsconfig.json` instead of two-file structure
4. **CR-4:** Unhandled promise rejection in initial poll prevents polling from starting on first failure
5. **CR-5:** Deprecated `isVisible` function pattern in host/port config fields — must use `isVisibleExpression` string form

**Secondary Issues:**
- **HIGH-1:** Port scanner creates unmanaged API instances without cleanup
- **HIGH-2:** No timeout on testConnection during port scan — scan blocks on unresponsive ports
- **HIGH-3:** No JSON parsing error handling in fetch response
- **HIGH-4:** Race condition in toggleSetting action (read-modify-write without atomic operation)
- **MEDIUM-1:** No HTTP response content-type validation
- **MEDIUM-2:** Silent error suppression in action callbacks — no user feedback
- **MEDIUM-3:** No distinction between recoverable and non-recoverable errors in polling
- **MEDIUM-4:** No validation of user hex color input format
- **MEDIUM-5:** Hardcoded port range (8080-8090) undocumented
- **M1:** Missing null checks in feedback callbacks
- **M2:** Port scanning race condition with config updates
- **Info:** No test suite, no test framework configured

**What's Solid:**
- ✅ Correct v1.x architecture with `runEntrypoint()` entry point
- ✅ Proper lifecycle methods (init, destroy, configUpdated)
- ✅ Smart consolidated `/api/state` endpoint reduces HTTP overhead
- ✅ Sequential polling prevents overlap (despite race with initial poll)
- ✅ Comprehensive presets (70+ button presets for user value)
- ✅ Good `.gitignore` entries
- ✅ Bonjour device discovery integration
- ✅ Well-designed polling architecture with failure recovery

**Agents Contributing:** Mal (Lead), Kaylee (Dev), Wash (Protocol), Zoe (QA), Simon (Tests)

**Review files:**
- `.squad/decisions/inbox/mal-review-findings.md`
- `.squad/decisions/inbox/kaylee-review-findings.md`
- `.squad/decisions/inbox/wash-review-findings.md`
- `.squad/decisions/inbox/zoe-review-findings.md`
- `.squad/decisions/inbox/simon-review-findings.md`


---

### 2026-04-10: adder-ccs-pro v0.1.2 review - CHANGES REQUIRED

**Module:** companion-module-adder-ccs-pro v0.1.2
**API:** companion-module/base ~1.14.1 (v1.14)
**Language:** JavaScript
**Release Type:** FIRST RELEASE (single tag v0.1.2, all code is NEW)

**Final Verdict:** CHANGES REQUIRED - 4 critical template compliance violations

**Blocking Issues:**
1. C1: .gitignore deviates from JS template - extra entries, wrong glob patterns
2. C2: .prettierignore has node_modules/ instead of template package.json + /LICENSE.md
3. C3: Banned keywords in manifest.json - adder, ccs-pro, ccs-pro8 are manufacturer/product names
4. C4: manifest.json name does not match id

**Non-blocking:** L1 (deprecated isVisible), N1 (password should use secret-text)

**What is Solid:** Clean architecture, proper lifecycle, good error handling, excellent HELP.md, yarn package succeeds

**Review file:** .squad/decisions/inbox/mal-review-findings.md

---

### 2026-04-09: noctavoxfilms-tallycomm v1.0.0 review — CHANGES REQUIRED

**Module:** companion-module-noctavoxfilms-tallycomm v1.0.0
**API:** `@companion-module/base ^1.12.1` (v1.x rules)
**Language:** JavaScript (CommonJS)
**Release Type:** FIRST RELEASE — all findings 🆕 NEW, all eligible to block

**Final Verdict:** ❌ CHANGES REQUIRED — 5 critical issues

**Blocking Issues:**
1. C1: Source code at module root (`main.js`) — must be moved to `src/main.js`
2. C2: `package.json` `"main": "main.js"` — must become `"src/main.js"`
3. C3: `companion/manifest.json` entrypoint `"../main.js"` — must become `"../src/main.js"`
4. C4: No `scripts` field in `package.json` — `yarn package` cannot run without it
5. C5: `UpgradeScripts` not exported — charter requires named export even for empty array

**High findings:**
- H1: No `packageManager` field
- H2: No `engines` field (module uses Node 18+ globals: `fetch`, `AbortSignal.timeout`)
- H3: No lockfile (neither yarn.lock nor package-lock.json)
- H4: No `devDependencies` (missing `@companion-module/tools` for packaging)
- H5: `init()` sets `InstanceStatus.Ok` before connection check (should be `Connecting`)

**What's Solid:**
- `runEntrypoint(TallyCommInstance, [])` present and correct
- All four lifecycle methods implemented
- `set_pgm_auto` / `set_pvw_auto` with auto-clear-previous is excellent UX for switcher triggers
- `AbortSignal.timeout(5000)` on all fetch calls — correct
- `Promise.all()` in `clear_all` — correct
- Excellent README with ATEM trigger example
- Version parity: package.json and manifest.json both 1.0.0

**Architecture Notes:**
- Single-file JavaScript CJS module — simple and appropriate for this scope
- HTTP-only (no WebSocket/TCP), sends tally via POST to `/api/tally`
- `checkConnection()` pings the live API endpoint with sentinel values — mild concern (server side effects)
- Config UI labels are in Spanish — should be English for Companion store
- `camChoices` duplicated across `initActions()` and `initFeedbacks()`
- Module logic is sound; structural and packaging issues are all mechanical fixes

**Review file:** `.squad/decisions/inbox/mal-review-findings.md`

### 2026-04-09: wearefalcon-falconplay v1.0.0 review - CHANGES REQUIRED

**Module:** companion-module-wearefalcon-falconplay v1.0.0  
**API:** @companion-module/base ~1.12.1 (v1.12)  
**Language:** JavaScript (CJS)  
**Release Type:** FIRST RELEASE  

**Final Verdict:** CHANGES REQUIRED — Module has solid architecture and SDK compliance, but critical naming/repository mismatches and duplicate source files block merge.

**Blocking Issues:**
1. C1: package.json name is companion-module-falcon-play but should be companion-module-wearefalcon-falconplay
2. C2: Repository URL points to personal repo instead of bitfocus org
3. H1: Duplicate source files at root level - outdated code using http module while src/ uses fetch
4. H2: @companion-module/tools version ^2.4.2 is outdated

**What's Solid:**
- Excellent SDK compliance: runEntrypoint called, all lifecycle methods implemented
- Modern HTTP using fetch API with AbortSignal.timeout(5000)
- Smart polling with Promise.allSettled() for parallel fetching
- 13 actions, 3 feedbacks, 9 variables - all well-structured
- No package-lock.json, no dist/ committed, proper .gitignore

**Architecture Pattern Learned:**
Outdated dual-file structure anti-pattern — root-level JS files indicate incomplete refactoring. Always verify only src/ contains source code.

**Review file:** .squad/decisions/inbox/mal-review-findings-wearefalcon-falconplay.md

## behringer-wing v2.3.0 (2026-04-10)
- A `destroy()` that calls `stop()` is the correct pattern — if `stop()` exists and handles cleanup, `destroy()` must invoke it
- `JSON.stringify(err)` always produces `{}` for native Error objects; use `err.message` or `err.stack`
- Floor/ceiling guards on delta actions must be applied AFTER the delta is added, not before
- When a guard is added to some delta actions but not their siblings, note the inconsistency explicitly


## noctavoxfilms-tallycomm v1.0.0 (2026-04-09)
- First release module missing all template scaffolding — instant rejection pattern
- checkConnection() ignoring response.ok is a recurring High finding (also seen in behringer-wing)
- sendTally() swallowing errors causing silent state divergence — architectural finding
- destroy() no-op is a High when combined with in-flight requests on a destroyed instance
