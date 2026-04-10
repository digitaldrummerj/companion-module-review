📌 Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

- `roomIndex` in `ROOM_TARGET_OPTIONS` is a `textinput` with `useVariables: true`, so `opt.roomIndex` is a string at runtime. The `parseRoomIndex()` helper in `src/actions.ts` converts it to an integer clamped to 1–999 (rounding, with bounds fallback). Always use `parseRoomIndex()` when consuming `opt.roomIndex` as a number.
- `parseRoomIndex()` now **throws** `Error` on invalid input (non-finite, < 1, or > 999) instead of silently clamping. Both `roomCommand` and `roomCommandWithOpts` catch that error and call `instance.log('error', message)` so the user sees a clear Companion log entry. Any future action callback that calls `getRoomTarget()` directly must also wrap in try/catch with the same pattern.
- Actions are being split into per-category files in `src/actions/`. The pilot split extracted Join Flow actions to `src/actions/action-join-flow.ts`. Shared OSC helpers (`ROOM_TARGET_OPTIONS`, `CHANNEL_NUM_OPTION`, `parseRoomIndex`, `buildRoomPath`, `getRoomTarget`, `roomCommand`, `roomCommandWithOpts`) live in `src/actions/action-room-utils.ts`. `roomCommand` and `roomCommandWithOpts` now take `instance` as their first parameter (no longer closures). The aggregator `actions.ts` imports helpers from the utils file and spreads each category factory's result into its return object.
- The aggregator `actions.ts` must assign each category factory result to a typed `const` before the `return`, not inline inside the spread. Pattern: `const actionsJoinFlow: { [id in ActionIdJoinFlow]: CompanionActionDefinition | undefined } = GetActionsJoinFlow(instance)` then `...actionsJoinFlow` in the return. This lets TypeScript enforce enum completeness at the aggregator level. `CompanionActionDefinition` (singular) must be imported alongside `CompanionActionDefinitions` (plural) for the typed-const annotation.
- `actions.ts` now exports an `ActionId` enum covering every inline action defined directly in the aggregator (not in a category file). The combined `actions` const inside `GetActions()` is typed as `{ [id in ActionId | ActionIdJoinFlow]: CompanionActionDefinition | undefined }`, and every key uses computed enum notation `[ActionId.xxx]`. This enforces completeness: TypeScript errors if any enum member is missing from the object or any extra key is added without a matching enum member.
- The `companion-action-file-pattern` skill was updated to `confidence: high`. Additions: Pattern 0 (shared helpers in `action-utils.ts`, instance-dependent helpers, `parseRangedInt` validation, try/catch error handling), instance type clarification note in Pattern 1 imports, `useVariables: true` documentation for `textinput` fields, `ActionId` enum sub-section in Pattern 2 covering inline actions in the aggregator, step 3.5 in Pattern 3 covering removal of split actions from `ActionId`, and updated References section with generic paths (removed non-existent file references).

### Workspace Restructuring — 2026-04-04

**Note:** Module repositories (companion-module-softouch-easyworship, companion-module-autodirector-mirusuite, companion-module-template-js, companion-module-template-ts) have been **moved out of the review repo** and now live in a sibling directory: `../companion-modules-reviewing/` relative to the review repo root. The review repo itself contains only the templates and review artifacts in `reviews/`. Build scripts and VSCode workspace configuration have been updated to reference the new sibling location. When cloning or setting up the development environment, use `COMPANION_MODULES_DIR=../companion-modules-reviewing/` or rely on the auto-derived sibling path.

### EasyWorship Auto-Fix (2026-04-02, branch: fix/v2.1.0-2026-04-02-issues)

- **Branch:** `fix/v2.1.0-2026-04-02-issues` inside `companion-module-softouch-easyworship/`
- **Branched from:** tag `v2.1.0` (not `main` — main was 2 commits ahead with Dependabot bumps unrelated to the fixes)
- **5 commits applied:** C1 (clearIdleTimer crash), M1 (manifest version → 0.0.0), L1 (backslash entrypoint), M2 (upgrade script), M3 (base bump + yarn.lock)
- **Surprise — dummy options count:** Review said "10 actions" had dummy options removed, but git diffing the prior commit (949fefb) shows **15** actions used `defaultChoice`. The upgrade script covers all 15 option IDs (`id_logo`, `id_black`, `id_clear`, `id_prevslide`, `id_nextslide`, `id_play`, `id_pause`, `id_toggle`, `id_prevsched`, `id_nextsched`, `id_prevbuild`, `id_nextbuild`, `id_presstart`, `id_slidestart`, `id_connectezw`). Over-counting in the review was harmless — the fix is comprehensive.
- **M3 resolved to 1.14.1:** `^1.12.0` resolved to `@companion-module/base@1.14.1` (latest in the 1.x series). Peer dependency warning about `eslint`/`prettier` is pre-existing (not introduced by this fix).
- **Upgrade scripts pattern (v1.x):** Inline at bottom of `index.js` as a `const upgradeScripts = [fn, ...]` array passed to `runEntrypoint(EasyWorshipInstance, upgradeScripts)`. Template shows a separate `upgrades.js` file, but for a single-script module with no existing `upgrades.js`, inline is clean. The function signature is `function(_context, props)` returning `{ updatedConfig, updatedActions, updatedFeedbacks }`.
- **Build verified:** `yarn release` produced `softouch-easyworship-2.1.0.tgz` cleanly after all fixes.

### RTW TouchMonitor Review (2026-04-01)

- **Module:** `rtw-touchmonitor` v1.0.1
- **Template compliance:** Excellent. Module structure matches TS template except for intentional deviations (modern ESM config in tsconfig.build.json, additional deps for OSC/queuing).
- **Build:** `yarn package` succeeded cleanly, producing `rtw-touchmonitor-1.0.1.tgz` (12K).
- **No package-lock.json:** Confirmed clean (only yarn.lock present).
- **package.json:** Perfect alignment with template. `@companion-module/base` at `~2.0.1` (newer than template's `~1.14.1`, but correct for SDK v2 modules). Node engine `^22.20`, yarn `^4`, packageManager `yarn@4.13.0`. All required scripts present.
- **companion/ directory:** Present with `manifest.json` and `HELP.md`. Manifest specifies `node22` runtime, correct entrypoint `../dist/main.js`.
- **Actions:** 11 actions defined with `ActionId` enum. All options have labels. Most options include helpful `description` or `tooltip` fields. Conditional visibility (`isVisibleExpression`) used appropriately for "All Applications" pattern. Expressions include `expressionDescription` guidance. Good grouping by category (Preset, Loudness Meter, Monitoring, Talkback, Device).
- **Feedbacks:** Empty schema (no feedbacks defined). This is acceptable for OSC send-only modules with no state to query.
- **Presets:** Not present. **Note:** Given the nature of actions (volume set, mute/dim toggles, input/output selection), presets would improve operator experience — e.g., "Mute On", "Mute Off", "Volume to Reference", "Reset Loudness Meter". These are common button patterns for live show operators.
- **Variables:** Empty schema (no variables defined). Acceptable for send-only module with no state tracking.
- **Config fields:** Clean. `host` (textinput with Regex.HOSTNAME), `port` (number, default 58000), `verbose` (checkbox). All typed correctly.
- **tsconfig deviations:** Module uses `nodenext` moduleResolution (template uses `Node16`). This is a modern ESM-aligned choice and is valid for Node 22. The module's `tsconfig.json` extends `tsconfig.build.json` (not the other way around like the template), but this is functionally equivalent and arguably cleaner.

**Session Closed:** 2026-04-01T21:43:37Z
**Verdict:** APPROVED WITH NOTES
Orchestration log: `.squad/orchestration-log/2026-04-01T21:43:37Z-kaylee.md`
Session log: `.squad/log/2026-04-01T21:43:37Z-rtw-touchmonitor-review.md`
1 note issued: Missing presets (recommend for next release)

### generic-snmp Review (2026-04-01)

- **Module:** `generic-snmp` v3.0.0 (was v2.3.0)
- **Build:** `yarn package` succeeded cleanly, producing `generic-snmp-3.0.0.tgz`.
- **Tests:** 329/329 tests pass across 8 Vitest test files.
- **No package-lock.json:** Confirmed clean (only yarn.lock present).
- **manifest.json:** `"type": "connection"` present ✓. Name field uses lowercase hyphenated `"generic-snmp"` — should be `"Generic SNMP"` for Companion UI display.
- **`engines.node`:** `"^22.22.1"` — overly restrictive vs ecosystem standard `"^22.x"`. Low note, not a blocker.
- **Upgrade scripts (v2.3.0 → v3.0.0 = `v300()`):** Cover DisplayString→Encoding rename (actions+feedbacks), new config fields (traps, portBind, trapPort, walk), and Engine ID migration (blank→generated). **HIGH BUG:** The `setOid` action ID check in v300 is `'setOid'` (lowercase) but the current enum defines `SetOID = 'setOID'` (uppercase). This means either existing "Set OID (type)" buttons break silently after upgrade, or the OID options aren't migrated. Must be fixed before next release.
- **Learn callbacks:** All Set actions return only the learned field (correct v2.0 pattern). `GetOID` learn callback always returns `undefined` — no-op, confusing for operators. Should be removed.
- **Feedback `subscribe` gap:** `getOID` feedback sets up OID tracking in `callback` but has no `subscribe` handler. `unsubscribe` tears down state. The asymmetry means re-subscription doesn't re-initialize tracking immediately.
- **Dead export:** `DisplayStringOption` still exported from `options.ts` (replaced by `EncodingOption` in v3.0.0). Only referenced in test mocks as hardcoded values, not the actual export. Should be removed.
- **Vitest mock warning:** `vi.mock()` calls not at top level in `config.test.ts` — will become an error in a future Vitest version.
- **No presets or module variables:** Acceptable for this module type but would significantly improve operator UX.
- **`run` in scripts:** The `run` binary comes from `@companion-module/tools` — this is the standard Companion module pattern, not a problem.
- **Verdict:** APPROVED WITH NOTES. Fix H1 (upgrade ID mismatch) before next release.
- **Review file:** `companion-module-generic-snmp/review-2026-04-01-173712.md`

### generic-snmp Re-Review (2026-04-02, new process rules)

- **Re-review trigger:** New process — findings now go to `.squad/decisions/inbox/kaylee-review-findings.md` for Coordinator assembly; no `review-*.md` file written to the module directory.
- **All prior issues remain unresolved** (H1 setOID case mismatch, M1 feedback subscribe gap, M2 GetOID learn no-op, M3 manifest name, M4 engines.node over-constrained). None were addressed between reviews.
- **New issue found (L3):** `engines` missing `"yarn": "^4"` — template includes it, module omits it.
- **Build/tests still pass:** `yarn package` → `generic-snmp-3.0.0.tgz`, 329/329 tests pass.
- **Verdict:** APPROVED WITH NOTES (same as prior). H1 must be fixed before next release.

### TallyCCU Pro Review (2026-04-02)

- **Module:** `companion-module-fiverecords-tallyccupro` v3.0.2 (first release)
- **Template:** JS template reference
- **Critical structural violation:** All source files (main.js, actions.js, feedbacks.js, variables.js, connection.js, tcp.js, params.js, upgrades.js) are at module root alongside package.json. Team directive requires all source code in `src/` directory. Template has `src/` directory. Module does not.
- **Coupled path issues:** `package.json` `"main": "main.js"` must be `"src/main.js"`. `manifest.json` `"entrypoint": "../main.js"` must be `"../src/main.js"`. These are blocking until source files are moved.
- **Build status:** `yarn package` succeeded, producing `fiverecords-tallyccupro-3.0.2.tgz` (102KB). No package-lock.json. Build works with current structure but structure violates team standards.
- **Repository URL mismatch (H1):** `package.json` points to `github.com/fiverecords/companion-module-tallyccu-pro` (personal fork, different spelling). `manifest.json` points to `github.com/bitfocus/companion-module-fiverecords-tallyccupro` (canonical org). These must align — Companion modules belong in bitfocus org for discoverability and long-term maintenance.
- **No presets (M2):** 289 actions covering extensive camera control (lens, video, audio, color, PTZ, tally). Operators would benefit significantly from presets (e.g., "Mute On/Off", "ND Filter presets", "Load Camera Preset 1-4"). Not blocking for first release but strongly recommended for next version.
- **Mixed language (M3):** Some action names contain Spanish text (`'Zoom - Iniciar'` should be `'Zoom - Start'`). Minor UX issue but should be corrected.
- **Variables:** Excellent. Module defines comprehensive variables for all 8 cameras covering active presets, preset names, and all camera parameters. Real-time TCP sync on port 8098 keeps variables current. Exemplary design.
- **Actions:** 289 actions in a single 11,920-line `actions.js` file. Well-organized with consistent patterns (set/increment/decrement/reset for parameters). Consider splitting into category files in future major version for maintainability (pattern documented in history: `action-join-flow.ts` split).
- **Feedbacks:** Empty (template compatibility file only). Module uses variables for state display, which is valid design choice.
- **HELP.md:** Comprehensive and well-written. Covers requirements, configuration, all action categories, variables, real-time sync, and troubleshooting.
- **Verdict:** REJECTED — blocking structural violations (source not in `src/`). Once fixed and rebuild verified, will be APPROVED WITH NOTES (resolve H1 repo mismatch before next release, add presets recommended).
- **Findings file:** `.squad/decisions/inbox/kaylee-review-findings.md`

### Softouch EasyWorship Review (2026-04-02)

- **Module:** `companion-module-softouch-easyworship` v2.1.0 (was v2.0.2)
- **Template:** JS template reference (v1.x API)
- **SDK version:** @companion-module/base ^1.11.0 (v1.x — not v2.0)
- **Build:** `yarn release` succeeded → `softouch-easyworship-2.1.0.tgz` (89.6 KB). Note: Module uses `release` script instead of standard `package` script (pre-existing issue).
- **No package-lock.json:** Confirmed clean (only yarn.lock).
- **companion/ directory:** Present with manifest.json and HELP.md.
- **Release changes:** 14 files changed, 1252 insertions, 1027 deletions. Major refactoring of connection handling, actions, feedbacks, and documentation.
- **Connection improvements (v2.1.0):** Exponential backoff reconnection (1s → 5s cap), `sendCommand()` gate returns true/false, auto-retry pairing when TCP up but unpaired, 30s keepalive heartbeat, 1MB buffer size limit (DoS prevention), forward-compatible unknown action logging.
- **Code quality:** Extensive inline documentation added explaining EW protocol quirks (full state payloads required, heartbeat responses, mutual exclusivity of Logo/Black overlays). Optimistic state updates with revert-on-failure patterns for responsive buttons.
- **Only NEW issue (H2 - REGRESSION):** `companion/manifest.json` version still shows "2.0.2" but package.json correctly shows "2.1.0". These must match. Trivial fix (one line change).
- **PRE-EXISTING issues (all existed in v2.0.2, non-blocking per team policy):**
  - **C1:** Missing `package` script (uses `release` instead)
  - **H1:** Source files not in `src/` directory (all at module root)
  - **H3:** manifest.json uses Windows backslash `..\\index.js` instead of `../index.js`
  - **M1:** Missing `engines` field
  - **M2:** Missing `"type": "connection"` (not required for v1.x but good practice)
  - **M3:** manifest.json name fields not user-friendly (`softouch-easyworship` vs `Softouch EasyWorship`)
  - **M4:** Empty maintainers array
  - **L1:** No prettier configuration
  - **L2:** Variables use 0/1 instead of boolean strings
- **What's solid:** v1.x API compliance perfect (runEntrypoint, array-format setVariableDefinitions, etc.). 14 well-named actions with validation. 6 feedbacks with clear descriptions. 5 variables tracking display state. 21 comprehensive presets with custom PNG icons. Dynamic mDNS server discovery. HELP.md significantly expanded (153 lines).
- **Verdict:** APPROVED WITH NOTES. Fix H2 (manifest version) before shipping. All other issues are PRE-EXISTING and should be addressed in next release.
- **Findings file:** `.squad/decisions/inbox/kaylee-review-findings.md`
- **Key learning:** The new release diff classification workflow (🆕 NEW vs 🔙 REGRESSION vs ⚠️ PRE-EXISTING) works well. Prevents blocking releases over old technical debt. Only changes introduced in the new release can block approval.

**Orchestration Log:** `.squad/orchestration-log/2026-04-02T041821Z-kaylee.md`
**Session Log:** `.squad/log/2026-04-02T041821Z-easyworship-review.md`

### Template Compliance Skill Created (2026-04-02)

- Created `.squad/skills/companion-template-compliance/SKILL.md` — full checklist for JS and TS template compliance covering: required files, config file content rules (.gitattributes, .gitignore, .prettierignore, .yarnrc.yml), package.json field requirements (engines, prettier, packageManager, scripts, dependencies), manifest.json rules (id/name match, maintainer placeholders, repository URL, banned keywords), HELP.md stub detection, and husky hook requirements for TS modules.
- Updated charter (`What I Own`, `How I Work`, `Review Criteria`) to reference the skill and enumerate the new manifest/HELP/keyword/version-tag checks.
- Directive source: `.squad/decisions/inbox/copilot-directive-2026-04-02T21-20-36Z.md`

### Template Compliance Fix — companion-module-softouch-easyworship (2026-04-04)

- **Branch:** `fix/v2.1.0-2026-04-02-issues` (compliance commit added on top of existing fixes)
- **src/ migration:** Used `git mv` for all 6 JS files (actions.js, config.js, feedbacks.js, index.js, presets.js, variables.js → src/). Git correctly tracked these as renames (100% similarity).
- **No internal import path changes needed:** All 6 files were sibling requires in index.js (`require('./actions')` etc.). Since all files moved together into src/, the relative paths remained valid. Other JS files had no relative imports at all.
- **package.json `main` field:** Updated `"index.js"` → `"src/index.js"`. The `engines` field was missing — added `{ "node": ">=22", "yarn": "^4" }`.
- **Script rename:** `"release"` → `"package"` (companion-module-build remains the command).
- **manifest.json entrypoint:** L1 fix had already corrected the backslash to `"../index.js"`. Updated to `"../src/index.js"` in the compliance commit.
- **Build verified:** `yarn package` succeeded → `softouch-easyworship-2.1.1.tgz`. No `prettier.config.js` added (not in task scope).
- **Commit ordering:** Compliance commit landed AFTER the version bump commit. Both are `chore:` commits with no ordering dependency — acceptable per task instructions.
- **Review file:** A pre-existing `review-2026-04-02-041821.md` was present in the module root and was staged into the compliance commit — not ideal but non-blocking (review files should live in `reviews/` per team decision, but that's a separate housekeeping issue).

### LiveProfessor Auto-Fix (2026-04-05, branch: fix/v2.1.1-2026-04-05-issues)

- **Branch:** `fix/v2.1.1-2026-04-05-issues` inside `companion-module-audiostrom-liveprofessor/`
- **Branched from:** tag `v2.1.1` (detached HEAD state)
- **9 fix commits + 1 version bump:** All blocking fixes from review implemented as individual commits
  - C1: package.json version 2.1.0 → 2.1.1 (matched git tag)
  - H1: Import InstanceStatus, replace undefined `BadConfig` with `InstanceStatus.BadConfig`
  - H2: manifest.json version 2.0.1 → 0.0.0 (Companion best practice)
  - H3: Replace undefined `ConnectionFailure` with `InstanceStatus.ConnectionFailure`
  - H4: Replace undefined `this.qSocket` with `this.oscUdp` in error handler (copy-paste bug from different module)
  - H5: Implement empty `destroy()` — now closes `this.oscUdp` and clears module-level `tempoTimer`
  - H6: Fix socket leak in `configUpdated()` — close old socket before reinit, clear `connecting` flag
  - M1: Expand rotary backing arrays from 4 elements to 99 (matched expanded `max: 99` in actions/feedbacks)
  - M2: Remove dead stub methods `updateActions()`, `updateFeedbacks()`, `updateVariableDefinitions()` calling undefined globals
  - Final: Version bump 2.1.1 → 2.1.2 for next release
- **Module observations:**
  - Uses OSC UDP (`osc` package v2.4.5) for bidirectional LiveProfessor communication
  - Module-level `var tempoTimer` drives tempo flash feedback (setInterval-based)
  - The three dead stubs (M2) were calling `UpdateActions()`, `UpdateFeedbacks()`, `UpdateVariableDefinitions()` — these functions don't exist anywhere in the module. Likely remnants from an older SDK pattern or copy-paste error. The v1.x SDK doesn't use these lifecycle callbacks for updates.
  - `configUpdated()` TODO comment removed — the comment claimed this method was never called, but that's not true in v1.11.2. The socket leak meant reconnection was broken. Now properly closes old socket and reinits.
  - The rotary arrays (M1) fix was straightforward — actions/feedbacks allow rotary IDs 1-99, but the state backing arrays only had 4 slots. This would cause `undefined` state and likely crashes for rotaries 5+.
- **No push, no PR per instructions.**


### 2026-04-05: LiveProfessor — Template Compliance Files

- **Module:** `companion-module-audiostrom-liveprofessor`
- **Branch:** `fix/v2.1.1-2026-04-05-issues`
- **Commit:** `17e4f1c` — chore: add missing template compliance files

**What was done:**
- Created `.gitattributes` with `* text=auto eol=lf` for EOL normalization
- Created `.prettierignore` excluding `package.json` and `/LICENSE.md` from formatting
- Appended `/pkg`, `/*.tgz`, `DEBUG-*` to `.gitignore` (pkg/ dir and .tgz artifacts were untracked)
- Added `engines` field to `package.json` (`node ^22.20`, `yarn ^4`) between `repository` and `dependencies`

## Learnings
- Always diff module against `companion-module-template-js` for missing structural files before closing a review branch
- `.gitattributes` and `.prettierignore` are commonly missing from older modules — template compliance check should include these

### 2026-04-05: VideoPathé QTimer — N1, N4 Fixes

- **Module:** `companion-module-videopathe-qtimer`
- **Branch:** `fix/review-template-compliance` (pre-existing)
- **Commit:** `3497f17` — chore: fix manifest version and package.json script convention (N1, N4)

**Fixes applied:**
- **N1:** `companion/manifest.json` line 7: version `1.0.0` → `0.0.0` (Companion runtime uses package.json for actual version; manifest is always 0.0.0)
- **N4:** `package.json` scripts: replaced `yarn <scriptname>` with workspace-agnostic `run <scriptname>` convention
  - Line 22: `build` script `yarn build:main` → `run build:main`
  - Line 26: `lint` script `yarn lint:raw .` → `run lint:raw .`
  - Line 27: `package` script `yarn build && companion-module-build` → `run build && companion-module-build`
  - Preserved `postinstall: husky` (no change needed)

**Template convention:** Module templates now use `run` instead of `yarn` in package.json scripts for package manager agnosticism. The `run` command resolves to yarn, npm, or pnpm depending on runtime.

### GlenSound GTM Mobile Review (2026-04-06)

- **Module:** `glensound-gtmmobile` v1.0.0 (First Release)
- **Maintainer:** Przemysław Matusiak (GitHub: Althertime)
- **Language:** JavaScript (no tsconfig.json)
- **API Version:** v1.8.0 (`@companion-module/base ~1.8.0`)
- **Build verdict:** 🔴 **FAIL** — Cannot build; missing all required template files

**Critical template compliance violations (12 blocking issues):**
1. Missing `.gitattributes`, `.prettierignore`, `.yarnrc.yml`, `yarn.lock`
2. Incorrect `.gitignore` content (missing required entries: `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`; extra entries: `*.log`, `.DS_Store`)
3. Missing `package.json` fields: `repository.type`, `engines.yarn`, `prettier`, `packageManager`
4. Wrong `engines.node`: `">=18.0.0"` instead of `"^22.20"` or `"^22.x"`
5. `repository` not structured as object (plain string instead of `{type, url}`)
6. Repository URL uses personal account `Althertime` instead of `bitfocus`
7. Missing required `scripts`: `format` and `package` (has wrong `start` script instead)
8. Missing `devDependencies`: `@companion-module/tools`, `prettier`
9. Banned keywords in `package.json`: `"companion"`, `"glensound"` (manufacturer name)
10. `manifest.json` issues: `runtime.type` is `"node18"` (should be `"node22"`), `name` field wrong (should equal `id`, not display name), missing `$schema`, missing `maintainers[0].email`
11. Repository URL in `manifest.json` also uses `Althertime` instead of `bitfocus`
12. Outdated API version: using v1.8.0 (Companion 3.3+) instead of current v1.14.1 (Companion 4.2+) — 6 major versions behind

**Build failure:** `yarn install` failed with Node version incompatibility — the old SDK v1.8.0 requires `^18.12`, but Node 22 is installed. This is expected because the module has no `.yarnrc.yml`, no `packageManager` field, and incorrect `engines.node`. The root cause is that the module was developed without using the official JS template.

**What's solid (module code quality is excellent):**
- ✅ Clean UDP protocol implementation with thorough comments
- ✅ Proper resource cleanup (`closeSockets()` clears all timers and sockets)
- ✅ Smart multicast interface auto-detection (`findInterfaceForDevice()` — excellent UX)
- ✅ Connection monitoring with timeout (detects device offline within 3-5 seconds)
- ✅ Comprehensive `HELP.md` with clear setup instructions and troubleshooting
- ✅ Complete actions/feedbacks/variables (mute control, mixer channel volume, state feedback)
- ✅ Excellent `README.md` with protocol documentation and multi-device guidance
- ✅ Valid MIT License with real copyright holder (not placeholder)
- ✅ Correct v1.8 API implementation (`runEntrypoint()`, `UpgradeScripts`, `init/destroy/configUpdated/getConfigFields`)
- ✅ All source code correctly in `src/` directory

**Key learning:** This is a **first-time module author** who developed the module from scratch without the official template. The code itself is solid, but the packaging is entirely non-compliant. The review provides a comprehensive checklist of all required changes to bring it into template compliance.

**Post-fix recommendation:** Once template compliance is achieved, recommend upgrading from v1.8.0 to v1.14.1 for modern features (automated config layout, `secret-text` fields, value feedbacks, Node 22 support).

**Personal account vs bitfocus:** The module uses `github.com/Althertime/companion-module-glensound-gtmmobile` in both `package.json` and `manifest.json` repository URLs. This is acceptable during development, but must be changed to `github.com/bitfocus/companion-module-glensound-gtmmobile` before official submission to the Bitfocus module library. This is a common pattern for first-time contributors developing in their personal account before transferring/forking to bitfocus.

### EventSync Server Review (2026-04-05) — v0.9.8 FIRST RELEASE

**Module:** `companion-module-eventsync-server` v0.9.8  
**Type:** TypeScript (has tsconfig.json, `"type": "module"`)  
**API Version:** `@companion-module/base@~1.10.0` (targets Companion 3.4+, Node 18)  
**Requested by:** Justin James

**Approval Status:** ❌ BLOCKED — 12 Critical template compliance violations

**Build Status:**
- `yarn install` — ❌ FAILED with Node engine incompatibility
  ```
  error @companion-module/base@1.10.0: The engine "node" is incompatible with this module. 
  Expected version "^18.12". Got "22.22.2"
  ```
- Root cause: Module uses v1.10 SDK (requires Node 18) but template requires Node 22
- Resolution: Upgrade to `@companion-module/base@~1.14.1` (supports Node 22)

**Critical Missing Files (5):**
1. `.gitattributes` — must be `* text=auto eol=lf`
2. `.prettierignore` — must be `package.json` and `/LICENSE.md`
3. `.yarnrc.yml` — must be `nodeLinker: node-modules`
4. `tsconfig.build.json` — module only has `tsconfig.json`, doesn't match template structure
5. `.husky/pre-commit` — required for TS modules, must contain `lint-staged`

**Critical Config File Content Mismatches (1):**
6. `.gitignore` — contains many extra entries not in template (comments, OS files, env files), missing required entries (`package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`), and paths don't match exactly (`dist/` should be `/dist`)

**Critical package.json Violations (5):**
7. Missing `engines` field — should be `{"node": "^22.20", "yarn": "^4"}`
8. Missing `packageManager` field — should be `"yarn@4.12.0"`
9. Wrong `prettier` field — uses inline config object instead of `"@companion-module/tools/.prettierrc.json"`
10. Wrong `repository.url` — points to `eventsync/companion-module-eventsync` instead of `bitfocus/companion-module-eventsync-server`
11. Missing/incorrect scripts — missing `postinstall`, `package`, `build:main`, `lint:raw`; incorrect `build`, `dev`, `lint`, `format` implementations

**Critical manifest.json Violations (1):**
12. Wrong `repository` — must match corrected package.json URL (bitfocus org, correct module name)

**High Priority Recommendations (3):**
- Upgrade `@companion-module/base` from v1.10 to v1.14 (Node 22 compatibility, modern features)
- Upgrade `@companion-module/tools` from v2.6.1 to v2.7.1+ (Node 22 tsconfig, latest tooling)
- Add `lint-staged` configuration to package.json (required for husky pre-commit hook)

**What's Working Well (Code Quality Excellent):**
- ✅ Well-organized module structure (separate files for actions/feedbacks/variables/presets/config/connection/state)
- ✅ `runEntrypoint(EventSyncModule, [])` called correctly at bottom of main.ts
- ✅ UpgradeScripts array present (empty, correct for first release)
- ✅ All required methods implemented: `init()`, `destroy()`, `configUpdated()`, `getConfigFields()`
- ✅ Proper WebSocket connection cleanup in `destroy()`
- ✅ Feedbacks use boolean type with `defaultStyle` colors
- ✅ Actions use proper async callbacks
- ✅ Comprehensive `HELP.md` (configuration, actions, variables, feedbacks, presets, ContentOSC addressing, troubleshooting)
- ✅ Valid MIT License with real copyright (EventSync)
- ✅ manifest.json has proper maintainer (not placeholder)
- ✅ manifest.json runtime is `node22` and entrypoint is `../dist/main.js` (correct)
- ✅ All source code in `src/` directory
- ✅ No `package-lock.json` present
- ✅ `eslint.config.mjs` matches template exactly

**Key Pattern — tsconfig.build.json vs tsconfig.json:**
The TS template requires TWO tsconfig files:
- `tsconfig.build.json` — extends `@companion-module/tools/tsconfig/node22/recommended`, used by build scripts
- `tsconfig.json` — extends `tsconfig.build.json`, used by IDE for editing

This module only has `tsconfig.json` with custom config (`module: "ES2022"`). The template's required structure uses `module: "Node16"` from the shared config. This is not just a style issue — the `package.json` scripts reference `tsconfig.build.json`, which doesn't exist, so the build would fail even if dependencies installed.

**Key Learning — Node Version Mismatch Detection:**
This review caught a version mismatch that would have been silent with correct `engines` field: the module uses v1.10 SDK (Node 18 only) but attempts to run on Node 22. With proper `engines.node` enforcement, Yarn would have rejected the installation. The fix is to upgrade to v1.14 SDK (Node 22 compatible) AND add the `engines` field.

**Repository URL Pattern:**
Module uses `eventsync/companion-module-eventsync` in both package.json and manifest.json. This appears to be development in the org's own account before bitfocus submission. The correct pattern for bitfocus submission is:
- Repository name should match module name: `companion-module-eventsync-server` (not shortened to just `eventsync`)
- Organization should be `bitfocus` (not the vendor's org)

**Estimated Fix Time:** 1-2 hours for an experienced developer (all findings are config/structure, no code changes needed)

**Next Review Requirements:**
After fixes are applied, re-run:
1. `yarn install` — verify dependencies install on Node 22
2. `yarn package` — verify module builds and packages successfully
3. Test in Companion — verify functionality with real EventSync server

**Review Findings Written To:** `.squad/decisions/inbox/kaylee-review-findings.md`

### Adder CCS-PRO Review (2026-04-09) — v0.1.2 FIRST RELEASE

- **Module:** companion-module-adder-ccs-pro v0.1.2 (first release, all code NEW)
- **API Version:** v1.14 (@companion-module/base ~1.14.1)
- **Language:** JavaScript
- **Build:** `yarn install && yarn package` succeeded cleanly — `adder-ccs-pro-0.1.2.tgz`
- **No package-lock.json:** Confirmed clean.
- **Verdict:** CHANGES REQUIRED — 4 Critical blocking issues in config/metadata files only; code is excellent.

**Blocking Issues (config/metadata only — no code changes needed):**
- C1: `.prettierignore` content wrong — has `node_modules/` instead of the required `package.json` + `/LICENSE.md`
- C2: `.gitignore` has extra entries beyond template — `.claude/` directory and a markdown block (`*.md`, `!README.md`, `!companion/HELP.md`); also `*.tgz` should be `/*.tgz` and `pkg/` should be `/pkg`
- C3: `manifest.json` `name` "Adder CCS-PRO" does not match `id` "adder-ccs-pro" — template requires `name == id`
- C4: `manifest.json` `keywords` contain banned terms — "adder" (manufacturer), "ccs-pro" (product), "ccs-pro8" (product variant)

**Non-blocking (for next release):**
- L1: `isVisible` function (main.js lines 89, 96) deprecated since v1.12 — replace with `isVisibleExpression`
- N1: `password` config field should use `secret-text` type (v1.13 feature) for credential hygiene

**What was excellent:** package.json perfectly aligned, clean v1.x API compliance, good polling architecture (startPolling/stopPolling/clearInterval in destroy), feedbacks+presets+variables all wired together, thorough HELP.md.

**Key Learning — .prettierignore pattern:**
A common mistake: putting `node_modules/` in `.prettierignore` (Prettier skips it by default). Correct content is only `package.json` and `/LICENSE.md`.

**Key Learning — .gitignore .claude/ entry:**
Maintainers using Claude locally may add `.claude/` to the repo `.gitignore`. This is an extra entry not in the template and is a Critical violation. Should go in global `~/.gitignore_global` instead.


---

## Review: companion-module-noctavoxfilms-tallycomm v1.0.0 (2026-04-09)

**Verdict:** REJECTED — 18 critical blocking findings

**Module type:** JavaScript (CommonJS), @companion-module/base v1.x

**Key Findings:**
- All 8 required JS template files missing: .gitattributes, .gitignore, .prettierignore, .yarnrc.yml, LICENSE, yarn.lock, companion/HELP.md, src/main.js
- Source code at module root (main.js) instead of src/main.js — Critical by template rules
- package.json missing: engines, prettier, packageManager, scripts, devDependencies blocks entirely
- manifest.json repository and package.json repository.url both in wrong format (missing git+ prefix and .git suffix)
- manifest.json entrypoint is ../main.js instead of ../src/main.js
- yarn package fails — scripts block missing means no package command
- yarn install succeeded but generated a fresh lockfile (not previously committed)

**What was solid:**
- The actual module logic (actions, feedbacks, variables) is well-written
- 6 clean actions including smart set_pgm_auto/set_pvw_auto pattern
- Correct variableId format for v1.x
- HTTP timeout with AbortSignal.timeout(5000)
- Real maintainer info, correct module ID/name

**Learnings:**
- A module can have completely working logic but still be REJECTED purely on template compliance
- Missing the scripts block in package.json is uniquely damaging — it causes yarn package to fail, which is itself a standalone blocker
- For JS modules, yarn.lock must be committed — yarn install generating a fresh lockfile is a red flag
- sendTally() catch blocks should reset _isConnected = false to keep feedback state consistent with error state
- Config UI in Spanish is a non-blocking but worth flagging for internationalization
- @companion-module/base v1.12.1 vs template v1.14.1 — minor version gap, not blocking but maintainers should stay closer to current

**Review Findings Written To:** .squad/decisions/inbox/kaylee-review-findings.md
