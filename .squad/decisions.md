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
