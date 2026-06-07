---
name: review-companion-module
description: Review a Bitfocus Companion module for release approval and produce a ranked review report. Use when the user says "review the next module", "review a/the (next) companion module", "review companion-module-X", "start a module review", or names a module. Supports a review scope — "just the tag/the changes" (tag), "the whole module / a full review" (module), or "both" — defaulting to tag. Runs the deterministic scripts, dispatches parallel review subagents, and assembles one review markdown — REPORT ONLY (never modifies the module).
---

# Review a Companion Module (orchestrator)

You are the review **coordinator**. Run the pipeline below **in order**, then assemble one review file. This is **REPORT ONLY**: never modify the module's code, create fix branches, or push to its repo. The maintainer applies the fixes. Your only output is the review markdown under `reviews/` (plus a `TRACKER.md` row).

All commands run from the review repo root (`/Users/lynbh/Development/companion-module-review`). Scripts are PowerShell — invoke with `pwsh`.

## Step 0 — Determine the review scope

Pick the scope from the request (default **`tag`** if unspecified):
- **`tag`** — review only what changed in this release (the `previousTag..reviewTag` diff). Triggers: explicit `tag`, or "just the tag", "the changes", "what changed". Pre-existing issues are not surfaced.
- **`module`** — review the whole current module flat (all findings by severity, no diff, no new-vs-existing split). Triggers: explicit `module`, "the whole module", "full review", "the existing module".
- **`both`** — whole module reviewed AND classified new vs pre-existing. Triggers: explicit `both`.

State the chosen scope to the user before proceeding.

## Step 1 — Pick the target

- If the user named a module (e.g. "allenheath-sq"), use it (strip any `companion-module-` prefix).
- Otherwise: `pwsh scripts/bitfocus-queue.ps1 -Json` → the target is the first entry whose `state` is `needs-review` (the script excludes `feedback-pending`). If all are `feedback-pending`, tell the user there's nothing new and stop.

## Step 2 — Set up the module

```
pwsh scripts/bitfocus-setup-module.ps1 -ModuleName <name> -Json
```
Clones into `companion-modules-reviewing/`; returns `{ module, reviewTag, previousTag, directory }`. `previousTag` is needed for `tag`/`both`; for `module` scope it's not used. If it errors that the module is already reviewed with feedback pending, surface that; only re-run with `-Force` if the user confirms.

## Step 3 — Generate the shared fact sheet

```
pwsh scripts/module-facts.ps1 -ModuleDir <directory> -GitTag <reviewTag> -Json
```
Capture `language`, `apiVersion`, **`apiSkill`** (`companion-v1-api-compliance` or `companion-v2-api-compliance`), `protocols`, `srcFiles`, `templateCheck`.

## Step 4 — Deterministic compliance + build/lint

```
pwsh scripts/validate-template.ps1 -ModuleDir <directory> -ExpectedVersion <reviewTag> -RunBuild -Json
```
Every `Critical` finding is **blocking** — carry each into the review verbatim. (These are full-module checks; they apply regardless of scope, since a release that breaks the build/template can't ship.)

## Step 5 — Scope the review surface

- **`tag`:** `git -C <directory> diff <previousTag>..<reviewTag>` — the changed files/hunks are the review surface; every code finding is NEW/REGRESSION.
- **`module`:** no diff; the whole current `src/` is the surface; findings are reported flat (no classification).
- **`both`:** whole module is the surface AND each finding is classified NEW / REGRESSION / PRE-EXISTING via the same diff (only NEW/REGRESSION block; pre-existing medium-and-lower are non-blocking notes).
- **First release** (`previousTag` = "(none — first release)") under `tag`/`both`: there's no diff, so fall back to a full review and note it in the report.
- **Re-review:** if a prior review for this module exists under `reviews/<name>/`, read `.claude/skills/review-follow-up-same-tag/SKILL.md` and frame this as a follow-up that *verifies the maintainer's fixes* — still report-only.

## Step 6 — Dispatch the review subagents (in parallel)

Launch all three with the Agent tool in one message. Give each: the **scope** (Step 0), the **fact sheet**, the clone `directory`, the `previousTag`, and the `apiSkill` name. Each returns findings (severity, `file:line`, classification when scope ≠ module, description, suggested fix **for the maintainer**) — they never edit the module.
- `companion-protocol-reviewer` — connection lifecycle, sockets, OSC/TCP/UDP/HTTP/Bonjour, timeouts, `destroy()` cleanup, `InstanceStatus`.
- `companion-qa-reviewer` — bugs, edge cases, error handling, performance, async correctness, silent failures.
- `companion-compliance-reviewer` — reads `.claude/skills/<apiSkill>/SKILL.md`; actions/feedbacks/presets/variables/config structure, upgrade scripts, test detection (absence is non-blocking).

(Template/build/lint already came from Step 4 — don't duplicate it.)

## Step 7 — Assemble the review

Read `.claude/skills/review-scorecard/SKILL.md` for the 📊 Scorecard and 📋 Issues format. Merge the Step-4 deterministic findings + the subagents' findings into ONE file, deduped by file+line. Header meta table includes a **`Scope:`** line (`tag` / `module` / `both`). Sections in order: title + meta, **📊 Scorecard**, **Verdict**, **📋 Issues** (Blocking / Non-blocking), `🔴 Critical` → `🟠 High` → `🟡 Medium` → `🟢 Low` → `💡 Nice to Have` → `🔮 Next Release` → `⚠️ Pre-existing Notes` → `🧪 Tests`. Omit empty sections. The **Verdict** section is the status line only (`✅ Approved` / `❌ Changes Required`) — no reasoning paragraph. Include `🧪 Tests` **only if tests were found** (framework/files/`test` script present) — if none, omit the section entirely rather than writing "no tests found." Plain text (no emoji) in individual issue headings for stable anchors.

Scope adjusts the presentation:
- **`tag`:** omit `⚠️ Pre-existing Notes`; scorecard "⚠️ Existing" column is 0 (all findings new).
- **`module`:** omit `⚠️ Pre-existing Notes`; present scorecard counts by severity only and add the note "whole-module scope — new vs pre-existing not assessed."
- **`both`:** full New/Existing scorecard + pre-existing notes.

Write to `reviews/<name>/review-<name>-<reviewTag>-<YYYYMMDD-HHMMSS>.md` (`mkdir -p reviews/<name>/` first; timestamp from `date -u +"%Y%m%d-%H%M%S"`). Append to `reviews/TRACKER.md`:
```
| ⬜ | <name> | <reviewTag> | <YYYY-MM-DD> | [review](<name>/review-<name>-<reviewTag>-<stamp>.md) |
```
The ⬜ stays until the user delivers the review and marks it ✅ — that's what keeps the module from being reviewed twice.

## Step 8 — Stop (report only)

Tell the user the review file path, the scope, the verdict (✅ Approved / ❌ Changes Required), and the blocking count. Do **not** modify the module, create a `fix/...` branch, or push anything to the module's repo. The user reviews the report, then delivers it to the maintainer.
