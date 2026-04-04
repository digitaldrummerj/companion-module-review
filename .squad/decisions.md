# Team Decisions

## 2026-04-01: Workspace layout and review workflow

**By:** Justin James
**What:** The workspace directory (`companion-module-review/`) is a dynamic review queue. Modules are added as subdirectories when they need review and removed once review is complete. The only permanent entries are `companion-module-template-js/` and `companion-module-template-ts/`, which serve as the reference baseline for all reviews.
**Why:** Keeps the review workspace clean — done modules don't accumulate. Templates stay to allow reviewers to compare structure at any time.

## 2026-04-01: Review verdict levels

**By:** Justin James (via Coordinator)
**What:** Three verdict levels: APPROVED (ships as-is), APPROVED WITH NOTES (ships but issues should be addressed before next release), REJECTED (blocking issues — must be fixed before any release).
**Why:** Matches standard Companion module maintainer review workflow.

## 2026-04-01: Yarn-only — no package-lock.json

**By:** Justin James (via Coordinator)
**What:** `package-lock.json` presence is an automatic REJECTION. Only `yarn.lock` is allowed. `yarn package` must succeed without errors for a module to be approved.
**Why:** Companion module build pipeline uses Yarn v4. Mixed lockfiles cause dependency resolution issues.

## 2026-04-01: Missing tests are not a rejection reason

**By:** Justin James (via Coordinator)
**What:** Most modules do not have Jest tests. Absence of tests is noted but does not block approval. If tests exist, they must pass (`yarn test`).
**Why:** Community module maintainers are not required to ship tests — they are encouraged but optional.

### 2026-04-01T21:54:53Z: User directive

**By:** Justin James (via Copilot)
**What:** All module reviews must be written to a file named `review-{YYYY-MM-DD-HHmmss}.md` in the reviewed module's directory. The date/time in the filename is the current date and time at the moment the review is run. The file is the deliverable given to the maintainer after review.
**Why:** User request — maintainers need a written review artifact they can act on.

### 2026-04-01T22:00:36Z: User directive

**By:** Justin (via Copilot)
**What:** Review output files must order findings by severity from top to bottom: Critical → High → Medium → Low → Nice to Have → Next Release
**Why:** User request — ensures maintainers see the most important issues first and can triage by priority without reading the whole document

### 2026-04-02T00:26:20Z: User directive

**By:** Justin (via Copilot)
**What:** If a module has changes to action names, new options for actions, removed options for actions, removed actions, removed feedbacks, new config values, or changed config values — there must be upgrade scripts for those changes so that the module keeps working as it previously was.
**Why:** User request — captured for team memory. Existing user setups (saved buttons, surfaces, exports) would silently break without upgrade scripts when breaking changes ship.

### 2026-04-02T00:31:05Z: User directive

**By:** Justin (via Copilot)
**What:** Always run `yarn install` in a module directory before starting a review. This must be part of the standard review process so dependencies are present for build, test, and lint steps.
**Why:** User request — captured for team memory. Without yarn install, `yarn package`, `yarn test`, and `yarn lint` may fail with missing dependency errors unrelated to the module's actual quality.

### 2026-04-02T01:05:56Z: User directive

**By:** Justin James (via Copilot)
**What:** Review files must always be written into the module folder being reviewed (e.g., `companion-module-generic-snmp/review-{datetime}.md`), never at the root of the review workspace.
**Why:** User request — captured for team memory.

### 2026-04-02T01:07:10Z: User directive

**By:** Justin James (via Copilot)
**What:** After a review, there should be only ONE assembled review file per module (written to the module folder). Individual agents must NOT each write their own review-*.md file. Instead, each agent writes their findings to `.squad/decisions/inbox/{agent}-review-findings.md` (the drop-box pattern). The coordinator assembles the single final review from all inbox findings files. Scribe cleans up the inbox files after assembly.
**Why:** User request — avoids cluttered module folders and eliminates any risk of agents overwriting each other's review files.

### 2026-04-02T01:59:31Z: User directive

**By:** Justin James (via Copilot)
**What:** When reviewing a module, separate pre-existing issues from issues introduced by the new release. A review should only FAIL (be REJECTED) if the blocking issue was **caused by changes between the previous and new release**. Pre-existing bugs that existed before the new release should be noted (with their severity) but must NOT cause a rejection — they can wait for a future release. To support this, the review process must:
1. Ask for the new release tag and the previous release tag before starting a review
2. Run a `git diff` between those two tags to identify what changed
3. Classify each finding as either "introduced in this release" (can block) or "pre-existing" (note only, never blocks)
**Why:** User request — prevents blocking a release over bugs the maintainer didn't introduce in that release cycle.

### 2026-04-02T02:50:21Z: User directive

**By:** lynbh (via Copilot)
**What:** Release tag names must follow the format `vMajor.Minor.Patch` (e.g., `v3.0.2`). No other tag formats are permitted for releases.
**Why:** User request — captured for team memory.

### 2026-04-02T02:54:42Z: User directive

**By:** Justin James (via Copilot)
**What:** Module source code must be placed in a `src/` directory. Code files at the root of the module (e.g., `main.js`, `actions.js`, `tcp.js` alongside `package.json`) is a structural violation. Reviewers should flag this as a finding — modules not using `src/` should be noted accordingly.
**Why:** User request — captured for team memory. Matches the companion-module-template-js and companion-module-template-ts structure where all source files live under `src/`.

## 2026-04-02: Review session — companion-module-fiverecords-tallyccupro v3.0.2

**Date:** 2026-04-02
**Module:** companion-module-fiverecords-tallyccupro
**Version:** 3.0.2 (first release — all code is new, no prior version, all findings eligible to block)
**Agents:** Mal (claude-opus-4.6 · Lead/Architecture), Wash (claude-sonnet-4.5 · Protocol), Kaylee (claude-sonnet-4.5 · Module Dev), Zoe (claude-sonnet-4.5 · QA), Simon (claude-haiku-4.5 · Tests) — all parallel
**Verdict:** ❌ REJECTED — 4 blocking issues
**Review file:** `companion-module-fiverecords-tallyccupro/review-2026-04-02-030343.md`

**Blocking issues:**
1. Source files not in `src/` directory (all `.js` files at module root)
2. Unhandled promise rejection in connection monitor startup (`connection.js` line 102)
3. TCP error handler leaks event listeners on dead socket (`tcp.js`)
4. All 284+ `sendParam()` calls in action callbacks not awaited — silent command failures

**Expected verdict once fixed:** APPROVED WITH NOTES

### 2026-04-02T034458Z: User directive

**By:** Lyn (via Copilot)
**What:** The convention that code files should be in the `src` directory is a suggestion/preference, not a hard rule. Agents should recommend it but not enforce it or block work because of it.
**Why:** User request — captured for team memory

### 2026-04-02T190519Z: User directive — Read-only external access

**By:** Justin James (via Copilot)
**What:** The team must NEVER write anything back to GitHub or the BitFocus developer API. All interactions with `https://developer.bitfocus.io/api/v1/*` and GitHub (repos, issues, releases) are strictly **read-only**. No `POST`, `PUT`, `PATCH`, or `DELETE` requests to either service. The only output from a review is the markdown review file written to the local `reviews/` directory.
**Why:** User request — captured for team memory

---

### 2026-04-02T190519Z: User directive — Review output directory structure

**By:** Justin James (via Copilot)
**What:** Review output files must be written to a dedicated `reviews/` directory at the workspace root, NOT to the individual module directory. Structure:
```
reviews/
  {module-directory-name}/
    review-{tag}-{YYYY-MM-DD-HHmmss}.md
```
Example: `reviews/companion-module-softouch-easyworship/review-v2.1.0-2026-04-02-041821.md`

The tag in the filename is the release tag being reviewed (e.g., `v2.1.0`). This provides permanent historical records — module directories are still cloned and removed manually after a review is delivered, but the review files in `reviews/` are kept indefinitely.

**Why:** User request — module directories are temporary (removed after review delivery); review history must persist separately.

### 2026-04-02T191405Z: User directive — Review filename includes module name (no companion-module prefix)

**By:** Justin James (via Copilot)
**What:** Review filenames must include the module name (without the `companion-module-` prefix) so the file is self-identifying even when copied out of its directory. Updated format:
```
reviews/companion-module-{name}/review-{name}-{tag}-{YYYY-MM-DD-HHmmss}.md
```
Example: `reviews/companion-module-softouch-easyworship/review-softouch-easyworship-v2.1.0-2026-04-02-041821.md`
**Why:** User request — captured for team memory

### 2026-04-02T191531Z: User directive — Review directory also strips companion-module prefix

**By:** Justin James (via Copilot)
**What:** The `reviews/` subdirectory for each module also strips the `companion-module-` prefix, not just the filename. Final format:
```
reviews/{module-name}/review-{module-name}-{tag}-{YYYY-MM-DD-HHmmss}.md
```
Example: `reviews/softouch-easyworship/review-softouch-easyworship-v2.1.0-2026-04-02-041821.md`
**Why:** User request — captured for team memory

### 2026-04-02T21:20:36Z: User directive — Template compliance required for all reviews

**By:** Justin James (via Copilot)
**What:** Template compliance checks are now required for all module reviews. Both JavaScript and TypeScript modules must be checked against the official templates.

**JavaScript modules** — verify these files exist and match template values:
- `.gitattributes` — must match template
- `.gitignore` — must match template
- `.prettierignore` — must match template
- `.yarnrc.yml` — must match template
- `LICENSE` — must match template
- `companion/manifest.json` — see manifest rules below
- `package.json` — see package.json rules below

**TypeScript modules** — same as JS plus:
- `eslint.config.mjs`
- `tsconfig.build.json`
- `tsconfig.json`
- `.husky/` directory must be committed with lint-staged hook

**package.json rules (JS):**
- `repository.url` must be the bitfocus GitHub URL
- `version` must match the git tag without the leading `v`
- `engines.node` must exist with correct values
- `prettier` field must exist
- `packageManager` field must exist
- `dependencies` must include `@companion-module/base`
- `devDependencies` must include `@companion-module/tools` and `prettier`

**package.json rules (TS):**
- All of the above JS rules, plus:
- All template `scripts` must be present
- All template `devDependencies` must be present
- `lint-staged` section must be present
- All fields: packageManager, engines, lint-staged, prettier, repository

**manifest.json rules (both JS and TS):**
- `id` must equal the module name (without `companion-module-` prefix)
- `name` must equal the `id`
- `maintainers` must be filled out with real name and email (not placeholder values)
- `repository` must be the bitfocus GitHub repo URL
- `keywords` must NOT include: companion, module, stream deck, manufacturer name, module name, product name

**help.md rules (both):**
- Must be filled out (not placeholder/stub content)

**Reporting:** Highlight when values differ from the template. Flag missing files as blocking issues.
**Why:** User request — ensures module submissions meet the BitFocus template baseline.

### 2026-04-02T21:27:21Z: User directive — Template compliance violations are critical

**By:** Justin James (via Copilot)
**What:** Template compliance failures are CRITICAL severity. Any file that does not match the template is a critical fail — all template compliance violations block approval.
**Why:** User request — captured for team memory

### 2026-04-02T210137Z: User directive — Pre-existing severity policy

**By:** Justin (via Copilot)
**What:** Pre-existing issues are NOT automatically non-blocking. Severity drives the blocking decision:
- **Pre-existing CRITICAL** → Always blocks (maintainer must fix, likely unaware since prior reviews missed it)
- **Pre-existing HIGH** → Strongly flagged as "Required Fix" for next release, but non-blocking for this release
- **Pre-existing MEDIUM/LOW** → Noted, non-blocking

The distinction between new vs. pre-existing must still be clearly shown in the review so the maintainer understands what's a regression vs. inherited debt. But "pre-existing" is never an excuse to ignore a critical flaw.

**Why:** User request — previous reviewers may have missed the critical issues, so the maintainer may have no awareness of them. Flagging them as "non-blocking" because they predate the current release means the bug never gets surfaced.

### 2026-04-02T23:47:02Z: User directive — Include line numbers in findings

**By:** Justin (via Copilot)
**What:** When a review identifies an error in a file, the finding must include the line number so the reviewer can easily locate it.
**Why:** User request — makes reviews actionable without requiring the maintainer to search for the issue manually.

### 2026-04-04T18:37:53Z: User directive — manifest.json version field rule

**By:** Lyn (via Copilot)
**What:** `companion/manifest.json` version field rule: The recommended value is `0.0.0`. If the version is `0.0.0`, no action needed (non-blocking note at most). If the version is NOT `0.0.0`, it MUST exactly match the `version` in `package.json` — a mismatch is a blocking (High) issue.
**Why:** User request — captured for team memory

### 2026-04-04T19:50:00Z: User directive — Version bump required on auto-fix branches

**By:** Lyn (via Copilot)
**What:** When creating an auto-fix branch for a module review, **the fix branch must include a version bump commit** before it is pushed. This is required because the maintainer will need to submit a new release, and the version must be incremented accordingly.

**Specifics:**

| File | Action |
|------|--------|
| `package.json` | Increment **patch version** (e.g., `2.1.0` → `2.1.1`) |
| `companion/manifest.json` | Set `"version"` to `"0.0.0"` (already required by prior directive) |

The manifest.json rule (`0.0.0`) was established in an earlier directive. This directive adds the `package.json` patch version increment requirement.

**Rationale:**
Auto-fix branches represent a release-candidate state: the fixes address review findings and the module is ready for the maintainer to submit as a new version. Setting the version at the time of the fix branch ensures:
- The maintainer doesn't have to guess which version to publish
- The package.json version won't collide with the reviewed version
- The manifest.json `0.0.0` sentinel + bumped package.json version clearly signals "this is pre-release work"

**Commit:** Include the version bump in a single commit at the **end** of the fix branch, after all issue fixes:
```
chore: bump version to {new_version} for next release
```

**Scope:** Applies to all auto-fix branches going forward. Retroactively apply to any in-progress fix branches before they are pushed.

**Why:** User request — captured for team memory.

### 2026-04-04T20:00:00Z: User directive — Upgrade scripts must live in upgrades.js

**By:** Lyn (via Copilot)
**What:** When writing upgrade scripts as part of an auto-fix, they must **not** be defined inline in the entry point file. They must be placed in a dedicated `upgrades.js` file (in `src/` if the module uses the src structure, or at root if not).

**Pattern (v1.x API — runEntrypoint):**

**`src/upgrades.js`:**
```js
module.exports = [
    // Each upgrade function is permanent — never remove
    function v200_someDescription(_context, props) {
        // ... transform props.actions / props.feedbacks / props.config
        return { updatedConfig: null, updatedActions: [], updatedFeedbacks: [] }
    },
]
```

**`src/index.js` (entry point):**
```js
const UpgradeScripts = require('./upgrades')
// ...
runEntrypoint(ModuleInstance, UpgradeScripts)
```

**Pattern (v2.x API — getUpgradeScripts export):**

```js
// src/upgrades.js — same structure, but consumed differently
export const upgradeScripts = [ ... ]

// src/main.js (or index.js)
import { upgradeScripts } from './upgrades.js'
export { upgradeScripts as getUpgradeScripts }
```

**Reference:** See `companion-module-template-js/src/upgrades.js` and `companion-module-template-js/src/main.js` for the canonical pattern.

**Scope:** Applies to all auto-fix branches. If an existing module has inline upgrade scripts and auto-fix is adding or touching upgrade scripts, extract all of them to `upgrades.js` in the same commit.

**Why:** User request — captured for team memory.
