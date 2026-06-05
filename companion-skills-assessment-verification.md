# Companion Skills Assessment — Post-Refactor Verification

**Date:** 2026-06-05
**Scope:** Verify the refactor (branch `feature/review-queue-dedup`) against the original [`companion-skills-assessment.md`](companion-skills-assessment.md), and scan for issues the refactor itself introduced.
**Method:** Audited the real tree — `scripts/`, `.squad/skills/`, `.squad/team.md`, agent charters — reading current files (not from memory). Severity legend: ✅ Resolved · 🔧 Needs to Fix · 💡 Nice to Have.

---

## 1. Original findings — status

Every original finding is **resolved**. Evidence is the current file (and the commit that landed it).

| # | Finding | Status | Evidence |
|---|---------|--------|----------|
| F1 | 3 review skills lack frontmatter | ✅ | `name`/`description` present on `.squad/skills/{companion-template-compliance,companion-v1-api-compliance,companion-v2-api-compliance}/SKILL.md` (commit `8918b35`) |
| F2 | Deterministic checklist runs through the LLM | ✅ | `companion-template-compliance` is now 66 lines wrapping `scripts/validate-template.ps1` (was 392) |
| F3 | "build runs / lint runs" not a named gate | ✅ | `validate-template.ps1 -RunBuild` runs `yarn install`/`yarn package`/`yarn lint` → `BUILD-INSTALL`/`BUILD-PACKAGE`/`LINT` findings |
| F4 | No "gitignored files not committed" gate | ✅ | `validate-template.ps1` `GITIGNORED-COMMITTED` via `git ls-files` × template `.gitignore` |
| F5 | Coverage gaps vs manual checklist | ✅ | F3/F4 closed; plus LICENSE content-match, source-must-be-in-`src/`, devDependencies, lint-staged added to the validator |
| F6 | Dashboard skill clones into wrong dir | ✅ | `companion-bitfocus-dashboard` clones to the sibling `companion-modules-reviewing/`; was already fixed in `.squad`, now synced to `.copilot` (commit `9431beb`) |
| F7 | `COMPANION_MODULES_DIR` undocumented | ✅ | Documented in the dashboard skill and honored by every modules-workspace script via `Resolve-ModulesDir` |
| F8 | Queue recommends already-reviewed (feedback-pending) modules | ✅ | `lib/ReviewState.ps1` `Get-ReviewState` + `bitfocus-queue.ps1` labels; "Next up" and auto-select exclude `feedback-pending` (commit `a360f4d`) |
| F9 | Same-tag resubmission vs done not distinguished | ✅ | `re-review` state (review file + submitted TRACKER row); `-Force` to re-review a named module |
| F10 | Scripts emit only console text | ✅ | `-Json` on `bitfocus-queue.ps1`, `bitfocus-setup-module.ps1`, `module-facts.ps1`, `validate-template.ps1`, `sync-skills.ps1 -Check` |
| F11 | `cleanup-modules.ps1` inconsistent path resolution | ✅ | Now dot-sources `ReviewState.ps1` and uses `Resolve-ModulesDir` (env-aware) |
| P1 | Move deterministic checks to a script | ✅ | `validate-template.ps1` (+ tests 20/20); template-compliance reduced to judgment items |
| P2 | Keep authoring skills out of review context | ✅ | `.squad/team.md` "Skill loading during review" — load only the applicable v1/v2 skill, never authoring skills |
| P3 | Detect API version once; load one skill | ✅ | `module-facts.ps1` resolves `apiVersion` → single `apiSkill`; team.md bootstrap shares it |
| P4 | Gather a module fact sheet once | ✅ | `module-facts.ps1` (tests 9/9); team.md Review Bootstrap writes it once and hands it to all reviewers |
| P5 | Model tiering | ✅ | Already cost-aware (`auto` + Haiku for Simon/Scribe); Kaylee shifted to running the validator. Left as-is by design |
| P6 | Consolidate redundant clusters | ✅ (skip) | **Intentionally not done.** Phase-5 loading discipline removed the token rationale, and the deep analysis advised keeping the reference / file-pattern / add-to-category split (useful when authoring). Merging would lengthen skills and hurt targeted loading. Recorded as a deliberate skip |
| P7 | De-contaminate authoring examples | ✅ | 6 authoring skills cleared of Zoom/Room/OSC identifiers (grep clean); generic `target`/`instance.sendCommand(...)` placeholders (commit `7ac553e`) |
| Appendix | `.copilot` vs `.squad` single source | ✅ | `.squad/skills` is canonical; `scripts/sync-skills.ps1` mirrors to `.copilot` (tests 6/6); Scribe charter calls the script |

**Test posture:** 51 tests across 4 suites (`ReviewState` 16, `ValidateTemplate` 20, `SyncSkills` 6, `ModuleFacts` 9), all passing.

---

## 2. New issues introduced by the refactor

All are **documentation/clarity**, not design defects. The scripts themselves are portable (no hardcoded paths). None block shipping.

### N1 — Template-location duality ✅ (mostly resolved)
`validate-template.ps1` and `module-facts.ps1` resolve templates from `~/Development/companion-module-dev` (override `COMPANION_TEMPLATES_DIR`), where the four templates (v2 + v1 js/ts) actually live. Docs that wrongly treated `companion-modules-reviewing/` as the template home have been corrected:
- ✅ `README.md` — Setup + directory structure now point templates at `~/Development/companion-module-dev`.
- ✅ `.squad/team.md` — Layer 2 now states templates are a separate concern in `companion-module-dev`, not under `companion-modules-reviewing/`.
- ✅ `.squad/agents/kaylee/charter.md` — "when unsure" now points at `companion-module-dev` and defers to `validate-template.ps1`.
- 💡 **Remaining:** `scripts/cleanup-modules.ps1`'s `$keep` list still names `companion-module-template-js/ts` as dirs to preserve inside `companion-modules-reviewing/`. This is now harmless dead config (templates never live there, and that dir is the in-repo module-checkout workspace — see Workspace change below), but the `$keep` entries could be dropped for clarity.

### N2 — Hardcoded user paths in squad docs 💡 (partially resolved)
Absolute `/Users/lynbh/...` paths in docs/skills. Fixed: ✅ `.squad/team.md` (now repo-relative) and ✅ `.squad/skills/companion-bitfocus-dashboard` (now derives the root via `git rev-parse --show-toplevel`). 💡 **Remaining:** `.squad/routing.md:29`, `.squad/agents/ralph/charter.md:37`, `.squad/agents/mal/charter.md:172`, `.squad/skills/project-conventions/SKILL.md`. The `.ps1` scripts were always clean (`Split-Path`/`Resolve-ModulesDir`/env).
**Fix:** parameterize the remainder with `${COMPANION_MODULES_DIR:-…}` or repo-relative paths.

### N3 — Fact-sheet vs Scribe inbox cleanup 💡 (Nice to Have)
`module-facts.ps1` output is written to `.squad/decisions/inbox/module-facts.json` (`team.md:64`). Scribe's charter step 3 merges `inbox/*.md` then "delete inbox files." In practice Scribe only processes `*.md`, so the `.json` survives — but the wording is ambiguous and the fact sheet lives in a directory another agent prunes.
**Fix:** tighten the charter wording to "delete the merged `.md` findings files," or write the fact sheet outside `inbox/` (e.g. a transient path in the cloned module).

### N4 — Bootstrap write has no guard 💡 (Nice to Have)
`team.md:64` redirects `module-facts.ps1 ... > .squad/decisions/inbox/module-facts.json` with no check that it succeeded or that the dir exists; a failure could leave reviewers reading an empty file.
**Fix:** create the dir and verify non-empty output (e.g. `Tee-Object` + a sanity read), or have the bootstrap step assert the file parses.

### Workspace change (this session) ✅
The module-checkout workspace was moved **from a sibling directory into the repo**: modules now clone to `companion-modules-reviewing/` inside the repo, ignored via a committed `.gitignore` entry (`/companion-modules-reviewing/`) plus the existing `companion-module-*/` safety net and the pre-commit hook (now also blocking the container path). `Resolve-ModulesDir` is the single switch (still honoring `COMPANION_MODULES_DIR`); all six workspace-aware scripts follow it automatically. Verified: `git status` stays clean and `git check-ignore` confirms the path is ignored, so nested module repos don't pollute the outer repo. Docs (README, `team.md`, `setup.ps1`, dashboard skill) updated to match.

---

## 3. Conclusion

The refactor is **complete and sound**: all 18 original findings + the Appendix are resolved (P6 a deliberate, documented skip), backed by 51 passing tests. The only new items are documentation consistency — chiefly **N1 (template-location duality)**, worth fixing so there is one canonical template home. N2–N4 are polish. No design regressions found.
