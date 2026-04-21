📌 Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Core Context

**Archive of Kaylee's foundational work prior to 2026-04-09 reviews.** This section summarizes key learnings from early reviews (RTW TouchMonitor, generic-snmp v3.0.0, TallyCCU Pro, Softouch EasyWorship, EventSync Server, Adder CCS-PRO, and Behringer Wing). Core themes are preserved below. Full pre-2026-04-09 review context is archived in a collapsible section at the end of this file.

**Template Compliance (Critical):**
- Source code MUST be in `src/` directory. Module root structure is automatic rejection.
- JS modules require: `.gitattributes`, `.gitignore`, `.prettierignore`, `.yarnrc.yml`, `LICENSE`, `yarn.lock`, `companion/HELP.md`, `src/main.js`.
- TS modules require: `tsconfig.build.json` (extends `@companion-module/tools/tsconfig/node22/recommended`) and `tsconfig.json` (extends build version).
- `package.json` `main` must be `"src/main.js"` or `"src/main.ts"`.
- `manifest.json` `entrypoint` must be `"../src/main.js"` or `"../src/main.ts"`.
- `package-lock.json` presence = automatic rejection; `yarn.lock` required and must be committed.

**Engines & Runtime:**
- `engines.node` must match SDK target (e.g., `"^22.x"` for v2.x SDK, `"^18.x"` for v1.x SDK). Mismatch is Critical.
- `engines.yarn` should be `"^4"` (Yarn v4 only, no Classic).
- `packageManager` field required (e.g., `"yarn@4.13.0"`). Missing = yarn falls back to Classic v1.
- Empty `engines: {}` block fails same as missing block — both Critical.

**Actions & Enums (Best Practices):**
- Actions split into category files (e.g., `src/actions/action-join-flow.ts`) with per-category enums (`ActionIdJoinFlow`).
- Main `actions.ts` aggregator must use typed `const` pattern: `const actionsJoinFlow: { [id in ActionIdJoinFlow]: CompanionActionDefinition | undefined } = GetActionsJoinFlow(instance)` before spread.
- Aggregator exports `ActionId` enum covering all inline actions; aggregated object type enforces completeness with `{ [id in ActionId | ActionIdJoinFlow]: CompanionActionDefinition | undefined }`.
- Instance parameter passed explicitly (no closures). Both `roomCommand` and `roomCommandWithOpts` take `instance` as first parameter.
- Parse helpers like `parseRoomIndex()` now throw on invalid input; callers must wrap in try/catch + `instance.log('error', message)`.

**Upgrade Scripts (Mandatory for Breaking Changes):**
- Required for: removed/renamed actions, removed/renamed feedbacks, removed/renamed config fields, changed config field types.
- v1.x pattern: inline at bottom of `index.js` as `const upgradeScripts = [fn, ...]` array passed to `runEntrypoint()`.
- v2.x pattern: separate `src/upgrades.ts` file imported and passed.
- Function signature: `function(_context, props)` returning `{ updatedConfig, updatedActions, updatedFeedbacks }`.
- Case sensitivity matters: action IDs in upgrade scripts must match enum cases exactly (e.g., `'setOID'` not `'setOid'`).

**Module Organization & Metadata:**
- `manifest.json` `name` field must match module ID (e.g., `"id": "adder-ccs-pro"` requires `"name": "adder-ccs-pro"`).
- Keywords in `manifest.json` must NOT contain manufacturer names, product names, or product variants (banned: "adder", "ccs-pro", "ccs-pro8").
- Repository URLs must use bitfocus org, not vendor org, and must follow pattern `github.com/bitfocus/companion-module-{id}`.
- `.prettierignore` must contain: `package.json`, `/LICENSE.md` (no `node_modules/` or module-specific ignores).
- `.gitignore` must contain template defaults; avoid extra patterns like `*.md` (breaks `HELP.md`) or `*.tgz` (use `/*.tgz` instead).

**Deprecation Warnings:**
- `isVisible()` function deprecated since v1.12; replace with `isVisibleExpression`.
- Plain `textinput` fields for credential storage should use `secret-text` type (v1.13+).
- `vi.mock()` calls must be at top level of test file (will error in future Vitest).

**State Management & Feedbacks:**
- For OSC send-only modules with no state tracking, empty feedbacks/variables is acceptable.
- Feedback `subscribe` handler must mirror `unsubscribe` (asymmetry breaks re-subscription).
- Learn callbacks should match the pattern: return only the learned field, not undefined (`GetOID` learn returning undefined confuses operators).

**UX Enhancements (Non-blocking but Recommended):**
- Presets significantly improve operator experience — especially for volume, mute/unmute, input/output selection, mode toggles.
- Variables for state display are valid design choice, especially for TCP sync modules.
- Module-level variables (pollGeneration, oidsToPoll state) should be properly initialized and cleared in destroy().
- Config fields with regex validation (e.g., `Regex.HOSTNAME` for host input) provide clearer error messages.

**Known Issues from Early Reviews (Examples):**
- generic-snmp H1: setOID case mismatch in upgrade script (setOid vs setOID) causes silent button breakage post-upgrade.
- generic-snmp M1: Feedback subscribe gap — OID tracking not re-initialized on re-subscription.
- TallyCCU Pro: 289 actions in single 11,920-line file; future refactor recommended for maintainability.
- EventSync Server: Node version mismatch silent with missing engines field (v1.10 SDK on Node 22).

---

## Archived Context (Pre-2026-04-09 Sessions)

The entries below represent foundational learning from early Kaylee reviews (2026-03-13 through 2026-04-08). Core themes are extracted above in the main context section. Full details are preserved for historical reference but are not part of active review notes.

## Recent Reviews (2026-04-09+)

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

## behringer-wing v2.3.0 (2026-04-10)
- Modules using `src/index.ts` as entry point (instead of `src/main.ts`) need a rename + manifest + package.json update — three files change together
- `tsconfig.build.json` extends path and `manifest.json` runtime.type must match (both node18 or both node22)
- Empty `engines: {}` block fails the same as a missing engines block — both are Critical
- `repository.url` slug in package.json can drift from actual repo name; always verify it matches the GitHub URL

## noctavoxfilms-tallycomm v1.0.0 (2026-04-09)
- First release with zero template files — count as 7 separate Critical findings (each file is its own Critical)
- Missing packageManager causes yarn install to fall back to Yarn Classic v1 — always check for this
- manifest.json legacyIds set on first release is suspicious — flag as Medium, request confirmation
- Build failure (no scripts block) is Critical — document exact error: "Command 'package' not found"

## noctavoxfilms-tallycomm v1.0.0 Review Trim (2026-04-15)
- Justin James requested scope reduction on the published review; 8 low-priority findings + Next Release section were removed
- Trimmed items: H-5, H-6, M-1, M-2, L-1, L-2, L-4, N-1 (no renumbering of remaining issues to preserve external reference stability)
- Scorecard adjusted: 34 findings → 26 findings (16 C, 4 H, 5 M, 1 L, 0 N); blocking: 22 → 20
- Result: File size reduced from 31.1 KB to ~24 KB (~30% reduction). Structure, tests, verdict sections preserved.
- Decision archived to .squad/decisions.md

---

## Archived Reviews — Pre-2026-04-09

### Detailed learnings from foundational reviews (RTW TouchMonitor, generic-snmp, TallyCCU Pro, Softouch EasyWorship, EventSync Server, Adder CCS-PRO, Behringer Wing) archived below for historical context and reference. See "Core Context" section above for distilled key learnings.

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

### generic-snmp Review (2026-04-01) & Re-Review (2026-04-02)

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

**Re-review (2026-04-02):** All prior issues remain unresolved. New issue found: `engines` missing `"yarn": "^4"`. Verdict remains APPROVED WITH NOTES.

### TallyCCU Pro Review (2026-04-02)

- **Module:** `companion-module-fiverecords-tallyccupro` v3.0.2 (first release)
- **Template:** JS template reference
- **Critical structural violation:** All source files at module root alongside package.json, not in `src/` directory.
- **Coupled path issues:** `package.json` `"main": "main.js"` must be `"src/main.js"`. `manifest.json` `"entrypoint": "../main.js"` must be `"../src/main.js"`.
- **Build status:** `yarn package` succeeded, producing `fiverecords-tallyccupro-3.0.2.tgz` (102KB). No package-lock.json. Build works with current structure but structure violates team standards.
- **Repository URL mismatch (H1):** `package.json` points to `github.com/fiverecords/companion-module-tallyccu-pro` (personal fork). `manifest.json` points to `github.com/bitfocus/companion-module-fiverecords-tallyccupro` (canonical org). Must align.
- **No presets (M2):** 289 actions covering extensive camera control. Operators would benefit significantly from presets.
- **Mixed language (M3):** Some action names contain Spanish text. Minor UX issue but should be corrected.
- **Variables:** Excellent. Module defines comprehensive variables for all 8 cameras covering active presets, preset names, and all camera parameters.
- **Actions:** 289 actions in single 11,920-line `actions.js` file. Well-organized with consistent patterns. Consider splitting into category files in future major version.
- **Feedbacks:** Empty (template compatibility file only). Module uses variables for state display, which is valid design choice.
- **HELP.md:** Comprehensive and well-written.
- **Verdict:** REJECTED — blocking structural violations. Once fixed and rebuild verified, will be APPROVED WITH NOTES.

### Softouch EasyWorship Review (2026-04-02)

Module template: JS  
Version reviewed: v2.1.0 (via fixes branch)

**Critical Findings Fixed (5 commits applied):**
- C1: clearIdleTimer crash (try/catch on undefined timer)
- M1: manifest.json version hardcoded to 0.0.0 (set to 2.1.0)
- L1: Entrypoint backslash in manifest.json (convert to forward slash)
- M2: Missing upgrade script for 10 removed dummy options (created script)
- M3: Base dependency resolve & yarn.lock update

**Upgrade Script Pattern (v1.x):** Inline at bottom of `index.js` as `const upgradeScripts = [fn, ...]` array. Function signature `function(_context, props)` returns `{ updatedConfig, updatedActions, updatedFeedbacks }`.

**Surprise Finding:** Review said "10 actions" had dummy options removed, but git diff shows 15 actions used `defaultChoice`. Upgrade script covers all 15 comprehensively (over-counting harmless).

**Build Verified:** `yarn release` produced `softouch-easyworship-2.1.0.tgz` cleanly after all fixes.

### EventSync Server Review (2026-04-03)

**Critical findings (blocking):**
- C1: .gitignore has `*.md` entry (breaks HELP.md); also `*.tgz` should be `/*.tgz`, `pkg/` should be `/pkg`
- C2: .prettierignore has wrong content (should be `package.json` + `/LICENSE.md`, not `node_modules/` or extra patterns)
- C3: tsconfig.build.json does not exist (referenced by package.json scripts); only tsconfig.json present with custom config
- C4: Repository URL mismatch — package.json `eventsync/companion-module-eventsync`, manifest.json same; must be `bitfocus/companion-module-eventsync-server`
- C5: Node SDK version mismatch — module uses v1.10 (Node 18 only) but attempts Node 22; needs v1.14 SDK upgrade

**Key Learning — Node Version Mismatch Detection:** This review caught a version mismatch that would have been silent without proper `engines` field. Yarn enforces `engines.node` at install time — missing it allows incompatible versions.

**Key Learning — Repository URL Pattern:** For bitfocus submission, repository name should match module name: `companion-module-eventsync-server` (not shortened). Organization must be `bitfocus`.

**Estimated Fix Time:** 1-2 hours for experienced developer (config/structure only, no code changes).

**Next Review Requirements:** After fixes: 1) `yarn install` on Node 22, 2) `yarn package` build success, 3) Functional test with real EventSync server.

### Adder CCS-PRO Review (2026-04-09)

- **Module:** companion-module-adder-ccs-pro v0.1.2 (first release, all code NEW)
- **API Version:** v1.14 (@companion-module/base ~1.14.1)
- **Language:** JavaScript
- **Build:** `yarn install && yarn package` succeeded cleanly — `adder-ccs-pro-0.1.2.tgz`
- **Verdict:** CHANGES REQUIRED — 4 Critical blocking issues in config/metadata files only; code is excellent.

**Blocking Issues (config/metadata only):**
- C1: `.prettierignore` content wrong — has `node_modules/` instead of `package.json` + `/LICENSE.md`
- C2: `.gitignore` has extra entries — `.claude/` directory, markdown block (`*.md`, `!README.md`, `!companion/HELP.md`); also `*.tgz` should be `/*.tgz` and `pkg/` should be `/pkg`
- C3: `manifest.json` `name` "Adder CCS-PRO" does not match `id` "adder-ccs-pro"
- C4: `manifest.json` `keywords` contain banned terms — "adder" (manufacturer), "ccs-pro" (product), "ccs-pro8" (product variant)

**Non-blocking (for next release):**
- L1: `isVisible` function (main.js lines 89, 96) deprecated since v1.12 — replace with `isVisibleExpression`
- N1: `password` config field should use `secret-text` type (v1.13 feature) for credential hygiene

**What was excellent:** package.json perfectly aligned, clean v1.x API compliance, good polling architecture, feedbacks+presets+variables all wired together, thorough HELP.md.

---

## 2026-04-15 Session: Noctavoxfilms-TallyComm C1 Enhancement

**Decision Merged:** C-1 Finding Enhanced with Template Guidance (from decision inbox)

**Action Taken:** Updated C-1 recommendation in noctavoxfilms-tallycomm review to provide explicit file-splitting guidance. Originally C-1 found that `main.js` needed to be moved into `src/`, but didn't prescribe internal structure. Now provides concrete guidance: split into `src/actions.js`, `src/feedbacks.js`, `src/presets.js`, `src/config.js`, `src/variables.js`, `src/main.js` using Companion module template as reference.

**Rationale:** Prevents rework, aligns with ecosystem standards, reduces follow-up reviews, improves maintainability.

**Files Updated:**
- `reviews/noctavoxfilms-tallycomm/review-noctavoxfilms-tallycomm-v1.0.0-20260409-203312.md` — C-1 section enhanced
- `.squad/decisions.md` — Decision merged and indexed by timestamp

## 2026-04-15 Session: Review Renumbering — H2 H3 H4 M5 Removal

**Task:** Remove H-2, H-3, H-4, and M-5 findings from noctavoxfilms-tallycomm review; renumber remaining findings.

**Changes Made:**
- Removed 4 findings: H-2 (phantom tally), H-3 (response.ok), H-4 (error swallow), M-5 (reliability)
- Renumbered remaining findings sequentially: M-3→M-1, M-4→M-2, M-6→M-3, M-7→M-4; L-3→L-1
- Updated scorecard: High 4→1, Medium 5→4, Total 26→22, Blocking 20→17
- Updated verdict narrative: Removed protocol issues, focused on H-1 premature init issue
- Updated Fix Summary: Removed bullets for protocol issues, kept critical blockers
- Updated TOC: All cross-references refreshed

**File:** `reviews/noctavoxfilms-tallycomm/review-noctavoxfilms-tallycomm-v1.0.0-20260409-203312.md`

**Verification:** All 4 findings completely removed (no orphaned references); all internal cross-references updated; scorecard and verdict reconciled; file structure maintained.

**Rationale:** Focuses review on immediate delivery blockers; improves clarity on actual blocking issues vs. deferred work.

## 2026-04-16: noctavoxfilms-tallycomm Review Trim

**Action:** Removed 15 findings from noctavoxfilms-tallycomm v1.0.0 review per stakeholder request.  
**Findings removed:** C9, C10, H2, H3, H4, H5, H6, M1, M2, M5, L1, L2, L4, N1, Next Release section.  
**Result:** Review reduced from 16 findings (11 blocking) to 12 findings (10 blocking); all remaining findings renumbered sequentially within severity tiers.

## Learnings
- 2026-04-18: For tag rereviews, use a detached worktree for the submitted tag so `yarn install` and `yarn package` validate the exact release without disturbing the module's main checkout.

## 2026-04-21: Capacitimer Review Consistency Polish

**Task (Part 1):** Restore the unintended Next Release section removal and fix scorecard/verdict consistency issues.

**Issue Identified:** Prior trim left inconsistencies:
- Fix Summary stated "five blocking issues"
- Scorecard showed 5 High
- But actual findings present were only H1, H2, H3 (3 High)
- Next Release section was accidentally removed

**Changes Made:**
- Updated Fix Summary: "five blocking issues"→"three blocking issues"
- Updated scorecard High: 5→3
- Confirmed Medium: 0, Low: 5
- Updated Verdict: "3 blocking issues (3 High NEW)"
- **Restored Next Release Suggestions section** with four recommendations:
  - Exponential back-off on WebSocket reconnect
  - Handle `license-update` WebSocket event
  - Reset device state variables on host change
  - Provide `eslint` config and lint script
- Fixed L1 header consistency ("explicitly set to"→"set to")
- Verified all cross-references and section alignment

**File:** `reviews/creativeland-capacitimer/review-creativeland-capacitimer-v1.1.1-20260409-222116.md`

**Task (Part 2):** Fix L4/L5 TOC mismatch

**Issue Identified:** Issues TOC had L4 and L5 entries reversed:
- TOC showed L4 as `eslint` missing, L5 as sanitization
- Actual sections: L4 is sanitization, L5 is `eslint` missing

**Changes Made:**
- Swapped L4 and L5 entries in TOC table
- L4 and L5 now match actual section headings exactly

**Verification:** ✅ Full document alignment: TOC→sections→scorecard→verdict all consistent.

**Rationale:** The prior edit left counting errors (5 High vs. 3 actual) and dropped important Next Release context. This pass corrects the math, restores the forward-looking guidance, and aligns TOC entries with their actual section content.

**Pattern:** After major edits involving finding removal, always verify:
1. Scorecard counts match actual findings present
2. Verdict narrative matches scorecard
3. TOC row order matches section order in body
4. All cross-references still point to existing content

---

## Task (Part 3): Final Review Update — Remove L4/L5 and Convert TOC to Linkable Format

**Date:** 2026-04-21T00:38:49Z  
**Requested by:** Justin James  
**Task:** Update review-creativeland-capacitimer-v1.1.1-20260409-222116.md with final removals and formatting

### Changes Applied

#### 1. Removed Low Findings L4 and L5
- **L4** ("No input sanitization on `host` config field") — completely deleted
- **L5** ("eslint missing from `devDependencies`") — completely deleted

#### 2. Removed Next Release Suggestions Section
Entire `## 🔮 Next Release Suggestions` section removed, including:
- Implement exponential back-off on WebSocket reconnect
- Handle `license-update` WebSocket event for live Pro tier switching
- Reset device state variables on host change
- Consider providing `eslint` config and a `lint` script

#### 3. Converted Issues TOC to Linkable Markdown Format
**Before:** Table format with | separators  
**After:** Linkable markdown with anchor references

Structure:
```markdown
## 📋 Issues

**Blocking**
- [ ] [H1: Missing upgrade scripts for 3 removed feedback IDs](#h1--missing-upgrade-scripts-for-3-removed-feedback-ids)
- [ ] [H2: ...](#h2--...)

**Non-blocking**
- [ ] [L1: ...](#l1--...)
```

#### 4. Updated Issue Heading Format
Changed heading separators from ` — ` to `:` for proper anchor compatibility:
- **Before:** `### H1 🆕 — Missing upgrade scripts...`
- **After:** `### H1 🆕 Missing upgrade scripts...`

#### 5. Updated Scorecard
- Low severity count: 5 → 3 (reflects removal of L4/L5)
- All 6 remaining issues (H1, H2, H3, L1, L2, L3) retain substantive content
- Only formatting/presentation modified

### Verification Checklist
- ✅ L4/L5 fully removed from findings
- ✅ Next Release Suggestions section completely deleted
- ✅ TOC format matches linkable markdown style used in other reviews
- ✅ Anchor links properly formatted (lowercase, spaces→hyphens)
- ✅ Scorecard low count updated to 3
- ✅ All 6 remaining issues present and unchanged in content
- ✅ File formatting consistent with repository conventions

### Style Consistency
The new TOC format matches linkable markdown style used in:
- highcriteria-lhs review
- audiostrom-liveprofessor review
- logos-proclaim review

Benefits:
- Direct anchor links from TOC to issue sections
- Blocking/non-blocking visual grouping
- Clickable checkboxes for finding tracking
- Improved readability and navigation

---
