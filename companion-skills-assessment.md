# Companion Skills Assessment

**Scope:** the 16 `companion-*` skills in `.copilot/skills/`
**Date:** 2026-06-04
**Type:** Report only — no skill files were edited. Apply changes yourself after reading.
**Severity legend:** 🔧 **Needs to Fix** (blocks consistent/cheap reviews) · 💡 **Nice to Have** (polish)

---

## 1. Executive Summary

The skill set is **fundamentally sound** — API guidance is accurate (no stale v1/v2 claims found), frontmatter is mostly high-quality, and the cluster structure (actions / feedbacks / presets / variables / config / upgrades) mirrors Companion's model well. The problems are about **consistency** and **cost**, which are exactly your two stated goals.

### Top 5 Needs-to-Fix

1. **3 review-critical skills have no frontmatter** (`companion-template-compliance`, `companion-v1-api-compliance`, `companion-v2-api-compliance`). Without a `name`/`description`, an agent cannot reliably auto-select them — the most important review skills are the least discoverable.
2. **The deterministic checklist (template-compliance) is encoded as an LLM skill, not a script.** ~90% of it is mechanical file/field/diff checking. Running it as prose through an LLM is both the #1 source of "things falling through the cracks" (the model skips rows) and a large recurring token cost.
3. **No skill makes "actually run the build / run lint" a named gate.** Your manual process runs `yarn package` (and `yarn lint` for TS) and confirms success; the skills only verify the *scripts are defined*, never that they *pass*.
4. **No explicit "gitignored files must not be committed" gate.** Your manual process checks that `node_modules`, `/pkg`, `*.tgz`, `/.yarn`, `DEBUG-*`, `/dist` aren't checked in; the skills only verify these appear in `.gitignore`.
5. **The queue can recommend a module you already reviewed but haven't uploaded feedback for yet.** The online queue only contains modules Bitfocus still considers un-reviewed — it has no idea you've already produced a local review whose feedback hasn't been submitted. Nothing in the scripts dedups "Next up" against your local `reviews/` + `TRACKER.md`, so the same module gets reviewed twice. Plus the `companion-bitfocus-dashboard` skill's clone workflow targets the wrong directory (review repo instead of the sibling). This is the *entry point* of every review (find queue → pick next → clone), so errors here corrupt the whole repeatable process. See §3b.

6. **Authoring skills are contaminated with one module's code** (Zoom Rooms / OSC: `getRoomOption()`, `createCommand()`, `instance.state.pairedRooms`, `/zoom/room/...`). They read as generic but bake in a specific module's architecture, which misleads reviews of other modules.

### Single Highest-Leverage Token Change

**Move the deterministic half of the review into a script and out of the LLM.** A `validate-template.ps1` (or node script) that checks file presence, `package.json`/`manifest.json` fields, banned keywords, and config-file diffs against the template — emitting a findings list — removes the largest review skill (347 lines) from every agent's context, makes those checks 100% repeatable, and lets the LLM spend tokens only on judgment (logic, protocol, architecture). This addresses **both** goals at once. See §5.

---

## 2. Per-Skill Findings

| # | Skill | Lines | Role | Frontmatter | Top issue | Severity |
|---|-------|-------|------|-------------|-----------|----------|
| 1 | companion-template-compliance | 346 | Review | ❌ **none** | No frontmatter; mostly deterministic → belongs in a script | 🔧 |
| 2 | companion-v1-api-compliance | 229 | Review | ❌ **none** | No frontmatter; loaded even for v2 modules | 🔧 |
| 3 | companion-v2-api-compliance | 89 | Review | ❌ **none** | No frontmatter; loaded even for v1 modules | 🔧 |
| 4 | companion-bitfocus-dashboard | 267 | Ops/Discovery | ✅ good | Clone workflow targets wrong dir (review repo, not sibling); drifts from actual `scripts/` | 🔧 |
| 5 | companion-actions | 237 | Authoring (ref) | ✅ good | Module-specific state examples (`self.deviceState`, `self.connection`) | 💡 |
| 6 | companion-action-file-pattern | 446 | Authoring | ✅ good | Heavy Zoom/OSC contamination; low review utility | 💡 |
| 7 | companion-add-action-to-category-file | 162 | Authoring | ✅ excellent | OSC examples; self-aware but no generic fallback | 💡 |
| 8 | companion-feedbacks | 285 | Authoring (ref) | ✅ excellent | Module-specific state examples | 💡 |
| 9 | companion-feedback-file-pattern | 374 | Authoring | ✅ good | Heavy room-based contamination (`getRoomOption`) | 💡 |
| 10 | companion-add-feedback-to-category-file | 172 | Authoring | ✅ excellent | Room-based state examples | 💡 |
| 11 | companion-preset-category-file | 390 | Authoring | ✅ good | Assumes `btn()` helper exists, never explains it | 💡 |
| 12 | companion-add-preset-to-category-file | 158 | Authoring | ✅ excellent | Clean | — |
| 13 | companion-config | 426 | Authoring (ref) | ✅ excellent | Clean; high review utility | — |
| 14 | companion-variable-definition | 142 | Authoring (ref) | ✅ excellent | Clean | — |
| 15 | companion-variable-set-value | 147 | Authoring (ref) | ✅ excellent | Could note `setVariableValues()` merge semantics | 💡 |
| 16 | companion-upgrades | 387 | Authoring (ref) | ✅ excellent | Clean; high review utility | — |

**Role split:** Only **4** skills (1–4) are *review/ops* skills. The other **12** are *authoring* skills — they teach how to **build** a module, not how to **review** one. Five of them (config, variables×2, upgrades, and the actions/feedbacks references) genuinely help spot bugs; the file-pattern and add-to-category recipes are construction tutorials with low review value. This split drives the token recommendations in §5.

---

## 3. Detailed Findings — 🔧 Needs to Fix

### F1. Three review-critical skills have no frontmatter
**Skills:** `companion-template-compliance`, `companion-v1-api-compliance`, `companion-v2-api-compliance`
**Problem:** Each file starts with a `# Skill: …` heading but no YAML frontmatter (`name` / `description`). Every other companion skill has it. In a skill-discovery system the `description` is what an agent matches against to decide *when* to load a skill — so the three skills most central to a review are the only three that can't be auto-triggered. This is a direct cause of inconsistent reviews.
**Fix:** Add frontmatter to each, with a description that states the trigger and the version boundary. Examples:
- template-compliance: *"Checklist for verifying a Companion module matches the official JS/TS template (required files, package.json/manifest.json fields, config-file parity, HELP.md, husky). Use at the start of every module review."*
- v1-api-compliance: *"Compliance checks for modules on @companion-module/base v1.x (v1.5–v1.14). Use only when package.json resolves @companion-module/base to ^1.x. For ^2.x use companion-v2-api-compliance."*
- v2-api-compliance: mirror image, pointing back to v1.

### F2. The deterministic checklist runs through the LLM instead of a script
**Skill:** `companion-template-compliance` (and the "Required Checks" table in the v1/v2 skills)
**Problem:** Almost everything in template-compliance is a mechanical check a script does perfectly every time: does file X exist, does `package.json.engines.yarn` equal `^4`, does `manifest.json.repository` match the repo, are banned keywords present, does `.gitattributes` exactly equal the template. Asking an LLM to walk a 17-row severity table by hand is where rows get skipped ("things falling through the cracks") **and** it re-reads template + module files into context on every run.
**Fix:** Extract the deterministic checks into a script (`scripts/validate-template.ps1` or a node script) that takes the module dir + the matching template dir and emits a structured findings list (file, expected, found, severity). The skill then shrinks to *"run validate-template.ps1, interpret its output, and apply judgment to the few non-deterministic items (is HELP.md *meaningful*, is a tsconfig deviation *justified*)."* See §5 P1 — this is the single biggest win.

### F3. "Build runs" and "lint runs" are not named gates
**Skills:** `companion-template-compliance` (lists scripts), `companion-v1/v2-api-compliance`
**Problem:** Your manual process explicitly runs `yarn package` (build) and, for TS, `yarn lint`, and confirms they succeed. The skills verify the `package`/`build`/`lint` scripts are *defined* in `package.json` but never instruct the reviewer to *execute* them and gate on the result. A module can have all the right scripts and still fail to build.
**Fix:** Add an explicit gate (ideally in the same `validate-template.ps1`, or a sibling `verify-build.ps1`): run `yarn install --immutable`, `yarn package`, and (TS) `yarn lint`; capture pass/fail + first error. Document it as a 🔴 Critical gate in template-compliance (build must pass) and a 🟠 High gate for lint.

### F4. No "gitignored files must not be committed" gate
**Skill:** `companion-template-compliance`
**Problem:** The skill confirms `.gitignore`/`.gitignore`-of-`dist` content matches the template, but nothing checks that the *ignored* artifacts aren't actually committed. Your manual process checks exactly this (people commit `node_modules`, `/pkg`, `*.tgz`, `/.yarn`, `DEBUG-*`, `/dist`). The v1 skill mentions only `dist/` "never committed."
**Fix:** Add a check (script-friendly: `git ls-files` intersected with the template `.gitignore` patterns) and list it as a 🔴 Critical gate. Cheap, deterministic, currently missing.

### F5. Coverage gaps vs. your manual checklist (summary)
See the full matrix in §4. Net gaps that need a home: build-runs (F3), lint-runs (F3), gitignored-files-not-committed (F4). "yarn-not-npm" is *adequately* covered today as a proxy (`package-lock.json` present = npm = automatic rejection), but consider naming it explicitly since it's a check you call out by name.

---

## 3b. Detailed Findings — Scripts & Review Queue (`scripts/`)

The first step of every review is **find the queue → pick the next module → clone it**, driven by `scripts/bitfocus-queue.ps1` and `scripts/bitfocus-setup-module.ps1` and documented by the `companion-bitfocus-dashboard` skill. I read all three scripts plus `setup.ps1`. The scripts themselves are solid, but the skill has drifted from them and the queue logic has gaps that let work fall through the cracks.

### F6. The dashboard skill's clone workflow targets the wrong directory 🔧
**Where:** `companion-bitfocus-dashboard` Workflow 1 (line ~149) and Workflow 4 (lines ~200–211).
**Problem:** The skill's hand-run workflow sets `$workspace = "/Users/lynbh/Development/companion-module-review"` and clones with `Join-Path $workspace "companion-module-$name"` / `git clone <url>` from inside `$workspace` — i.e. **into the review repo itself**. The actual scripts clone into the **sibling** `companion-modules-reviewing/` (`$modulesDir = Join-Path (Split-Path -Parent $workspace) "companion-modules-reviewing"`). The repo even has a pre-commit hook specifically to stop `companion-module-*` dirs from being committed — the skill's workflow walks straight into the thing that hook exists to prevent. Workflow 1 also references `$workspace` without ever defining it (undefined variable).
**Why it matters:** An agent that follows the skill (rather than the script) clones to the wrong place, pollutes the review repo, and computes "cloned/not cloned" against the wrong path. The skill and scripts must agree on the clone location.
**Fix:** Rewrite the skill's workflows to clone into the sibling dir, honor the `COMPANION_MODULES_DIR` override (see F7), and drop the hardcoded absolute path. Better: have the skill simply say "run `scripts/bitfocus-setup-module.ps1`" and stop duplicating the logic in prose that can drift.

### F7. `COMPANION_MODULES_DIR` override is undocumented 💡
**Where:** all three scripts honor `$env:COMPANION_MODULES_DIR`; the skill never mentions it.
**Problem:** The scripts are portable via that env var, but the skill hardcodes a path, so anyone reading the skill assumes a fixed location. Document the override in the skill (and note it's the seam you'd use to give each concurrent review its own workspace — relevant to your "run multiple reviews independently" goal).

### F8. The queue can recommend a module already reviewed locally but not yet uploaded 🔧 (most important queue fix)
**Where:** `bitfocus-queue.ps1` (cloned/not-cloned only, lines 40, 57–67), `bitfocus-setup-module.ps1`.
**Problem:** The online `/modules-pending-review` queue only lists modules Bitfocus still considers un-reviewed. But your workflow has a lag: you produce a local review, then **later** upload the feedback through the developer portal. In that window the module is **done on your side but still in the online queue**, because Bitfocus only learns it's reviewed once you submit feedback. Nothing in the scripts cross-references your local state, so "Next up" (and an auto-selecting `bitfocus-setup-module.ps1` with no `-ModuleName`) will happily pick a module you've already reviewed — and you review it a second time.
**Why it matters:** This is the exact double-review failure you flagged, and it's both a "things fall through the cracks" inconsistency and a direct token sink (re-running a full review for nothing). It's the highest-value queue fix.
**Fix — dedup against local state, which is the source of truth for "already reviewed":**
- `reviews/TRACKER.md` is the canonical record. **The review process appends a row to it when a review is produced**; the owner **manually adds the X (feedback-submitted) when the review is sent to the module owner.** So:
  - **Row present, no X** = *reviewed — feedback pending*. This is the dangerous state: still in the online queue (Bitfocus only drops it after feedback is uploaded) but must **not** be re-reviewed.
  - **Row present, X** = *done*.
  - **No row** = *needs review*.
- The matching review file `reviews/{name}/review-{name}-{tag}-*.md` is a secondary confirmation, but TRACKER.md is the human-curated source of truth.
- Annotate each queue row as `needs review` / `reviewed — feedback pending` / `done`, and **exclude any module that already has a TRACKER.md row for the current tag from "Next up"** (and from auto-select in the setup script).

### F9. Same-tag resubmissions and re-reviews aren't distinguished 💡
**Where:** `bitfocus-queue.ps1`, `bitfocus-setup-module.ps1`.
**Problem:** Even once F8 dedups by `{name, tag}`, there are two legitimate cases where a module *should* be reviewed again: (a) a **new tag** of an already-reviewed module (a genuine re-review of the delta), and (b) a maintainer **re-pushing the same tag** after applying fixes. Matching purely on tag handles (a) correctly but can mishandle (b). The existing reviews already model re-reviews (e.g. the `behringer-wing` fix-verification review), so the data's there — the queue just doesn't reason about it.
**Why it matters:** Distinguishing "done" from "legitimately needs another pass" keeps the dedup from hiding real work.
**Fix:** Key the dedup on `{name, tag}` for the common case, but surface modules whose latest local review is older than the current submission (e.g. same tag re-submitted after your review date) as `re-review?` rather than `done`.

### F10. Scripts emit only colored console text — no machine-readable output 💡→ (high value for automation)
**Where:** all scripts use `Write-Host` exclusively.
**Problem:** To orchestrate **multiple independent reviews** (your stated aspiration) or to let an agent decide the next module without burning tokens reasoning over scraped console text, the queue/setup scripts should optionally emit JSON (`-Json` switch) — module, tag, previous tag, status, cloned?, reviewed?, clone path. A script deciding the next module is *free*; an LLM parsing colored text is not.
**Fix:** Add a `-Json` output mode to `bitfocus-queue.ps1` and `bitfocus-setup-module.ps1`. This is the seam that makes a no-LLM "pick next" step possible and lets a coordinator spawn per-module review jobs deterministically.

### F11. `cleanup-modules.ps1` is inconsistent with the other scripts 💡
**Where:** `cleanup-modules.ps1` lines 4.
**Problem:** Uses `Resolve-Path "$PSScriptRoot\..\..\companion-modules-reviewing"` — Windows-style backslashes, and `Resolve-Path` **throws** if the dir doesn't exist (the other scripts compute the path without requiring existence). It also ignores `COMPANION_MODULES_DIR`, which the other two honor — so under an env override it would scan/delete the wrong location or fail.
**Fix:** Use the same `$modulesDir` resolution block as the other scripts (with the env override and `Join-Path`). Low risk but it's a delete script, so consistency matters.

### What's solid in the scripts
- `bitfocus-setup-module.ps1` correctly re-validates `PENDING` status (lines 97–100) before acting — the right safety net.
- Previous-approved-tag lookup and the "first release" path (lines 106–116) are handled cleanly.
- `setup.ps1` wires the pre-commit hook and creates the sibling dir idempotently.
- Sibling-clone design (each module gets its own git context, outside the review repo) is the right call and supports independent/parallel reviews.

---

## 4. Coverage Matrix — Manual Checklist → Skill

| Your manual step | Covered by | Status |
|------------------|-----------|--------|
| Structure matches template; all template files present | template-compliance §2 | ✅ |
| Yarn used, not npm | template-compliance (`package-lock.json` = auto-reject) + `packageManager: yarn@4` | ⚠️ proxy only — not named |
| Files in template `.gitignore` not committed to git | — | 🔧 **gap (F4)** |
| `manifest.json` complete + URL points to reviewed repo | template-compliance §6 | ✅ |
| `package.json` complete + URL points to reviewed repo | template-compliance §5 | ✅ |
| `companion/HELP.md` filled out (not a stub) | template-compliance §7 | ✅ |
| LICENSE / `.gitattributes` / `.gitignore` / `.prettierignore` / `tsconfig.json` / `tsconfig.build.json` / `eslint.config.mjs` / `.yarnrc.yml` match template | template-compliance §4 | ✅ |
| TS: `.husky/` committed + matches template | template-compliance §8 | ✅ |
| `package` build script **runs successfully** | — (script only verified as *defined*) | 🔧 **gap (F3)** |
| TS: `lint` script **runs successfully** | — (script only verified as *defined*) | 🔧 **gap (F3)** |
| Source-code standards (actions/feedbacks/config/variables/upgrades/protocol) | companion-actions, -feedbacks, -config, -variable-*, -upgrades, v1/v2-api-compliance | ✅ |

Every manual step maps to a skill **except** three (F3 build, F3 lint, F4 gitignored-files) — these are the items most likely to "fall through the cracks" today because no skill owns them.

---

## 5. Token-Optimization Recommendations (prioritized)

> Context for the cost problem: the squad fans out ~5 agents per review, and skills/source tend to get pulled into context broadly. The biggest levers are (a) don't run deterministic work through the model, (b) don't load skills an agent doesn't need, and (c) gather shared facts once.

**P1 — Move deterministic checks to a script (biggest win; also fixes consistency).**
~90% of `companion-template-compliance` (347 lines) and the "Required Checks" tables are mechanical. A `validate-template.ps1` that diffs the module against the template and prints findings removes that skill from every agent's context and runs in milliseconds with zero variance. Pairs with F2/F3/F4. *Impact: removes the largest review skill from context on every run + eliminates the most error-prone manual step.*

**P2 — Keep authoring skills out of review context.**
The 12 authoring skills total ~3,300 lines. During a *review* you don't need the file-pattern/add-to-category construction tutorials at all, and the API references (actions/feedbacks/config/variables/upgrades) are only useful when an agent is actually inspecting that area. Load review-oriented skills eagerly (template-compliance + the one applicable api-compliance + bitfocus-dashboard) and let the API references load **on demand**. *Impact: avoids ~3,300 lines × (number of agents) of dead weight per review.*

**P3 — Detect the API version once and load only v1 OR v2.**
The two compliance skills are mutually exclusive (read `@companion-module/base` from `package.json`). Today both can land in context. Resolve the version up front (cheap, one line) and load only the matching skill. *Impact: drops 89 or 229 lines per review and removes a source of v1/v2 confusion.*

**P4 — Gather a "module fact sheet" once, share it with all agents.**
The dominant cost is N agents each re-reading the same `package.json`, `manifest.json`, file tree, base version, and language. Have one cheap pass produce a small fact sheet (tree + key manifest/package fields + detected API version + JS/TS) and pass *that* to the specialist agents, so they read only the source files relevant to their role rather than re-deriving the basics. *Impact: removes 4× redundant reads of the boilerplate every review — likely the single largest raw-token line item.*

**P5 — Tier the models by role.**
Mechanical roles (template/lint/test detection, Scribe logging) are deterministic checklist work — ideal for Haiku. Reserve Opus for architecture, protocol correctness, and logic review (Mal/Wash/Zoe). The charters already mention tiering; make sure the cheap roles are actually pinned to the cheap tier. *Impact: shifts a chunk of every review off the premium tier.*

**P6 — Collapse the redundant clusters (marginal, but reduces payload + maintenance).**
3 action skills, 3 feedback skills, 2 preset skills overlap heavily. The reference + file-pattern + add-to-category split is defensible for *authoring*, but for this repo's purpose (reviews) you could merge each cluster's file-pattern + add-to-category into one, or drop the add-to-category recipes from the review context entirely. *Impact: smaller skill payload, fewer files to keep in sync.*

**P7 — De-contaminate the authoring examples (consistency, not raw tokens).**
Skills 6, 7, 9, 10 (and to a lesser degree 5, 8) embed Zoom Rooms / OSC specifics (`getRoomOption()`, `createCommand()`, `instance.state.pairedRooms`, `/zoom/room/...`). Replace with generic placeholders (`this.device.send(...)`, `this.state.<x>`) so the examples don't anchor a reviewer to one module's architecture. *Impact: fewer misjudgments; lower review utility means low priority, but worth doing when you touch these.*

---

## 6. Appendix — `.copilot/skills` vs `.squad/skills` (noted, not audited)

Out of scope for this report, but flagging it because it bears on both goals: a **near-duplicate set of companion skills exists in `.squad/skills/`**, and the squad agents actually read from `.squad/skills/`. Two copies means (a) edits to `.copilot/skills/` may not reach the agents doing reviews, and (b) double the maintenance and double the drift risk. Recommend picking **one** source of truth (symlink or generate one from the other) before investing in the fixes above — otherwise F1–F4 may need to be applied twice. A focused follow-up could diff the two trees and report drift.

---

## 7. Suggested Order of Work

1. **F1** — add frontmatter to the 3 review skills (5-minute fix, immediate discoverability win).
2. **F8 + F6** — fix the queue/clone entry point: make "Next up" and the setup script's auto-select **dedup against local `reviews/` + `TRACKER.md`** so an already-reviewed-but-feedback-pending module is never reviewed twice; and correct the dashboard skill's clone directory (or replace its prose with "run the script"). These corrupt the very first step of every review.
3. **P1 + F2 + F3 + F4** — build `validate-template.ps1` covering file presence, package/manifest fields, banned keywords, config-file diffs, gitignored-files-not-committed, and build/lint execution. Shrink template-compliance to "run the script + judgment items." This is the consistency *and* cost win together.
4. **F9 + F10** — distinguish genuine re-reviews (new tag, or same tag re-pushed after fixes) from done, and add `-Json` output. This is the foundation for deterministic, no-LLM "pick next" and for running multiple independent reviews.
5. **P3 + P4** — version-detect once, build the shared fact sheet, scope agent reads.
6. **P2 + P5** — gate authoring skills out of review context; pin mechanical roles to cheap models.
7. **Appendix + F7 + F11** — resolve the `.copilot`/`.squad` duplication so the above lands in one place; document `COMPANION_MODULES_DIR`; align `cleanup-modules.ps1` with the other scripts.
8. **P6 + P7** — consolidate/clean clusters and de-contaminate examples when convenient (lowest urgency).
