---
name: review-companion-module
description: Review a Bitfocus Companion module for release approval and produce a ranked review report. Use when the user says "review the next module", "review a/the (next) companion module", "review companion-module-X", "start a module review", or names a module to review. Runs the deterministic scripts, dispatches parallel review subagents, and assembles one review markdown — REPORT ONLY (never modifies the module).
---

# Review a Companion Module (Claude Code orchestrator)

You are the **coordinator** (the "Mal" role). Run the review pipeline below **in order**, then assemble one review file. This is **REPORT ONLY**: never modify the module's code, create fix branches, or push to its repo. The maintainer applies the fixes. Your only output is the review markdown under `reviews/` (plus a `TRACKER.md` row).

All commands run from the review repo root (`/Users/lynbh/Development/companion-module-review`). Scripts are PowerShell — invoke with `pwsh`.

## Step 1 — Pick the target

- If the user named a module (e.g. "allenheath-sq" or "companion-module-allenheath-sq"), use that name (strip the `companion-module-` prefix).
- Otherwise, find the next one:
  ```
  pwsh scripts/bitfocus-queue.ps1 -Json
  ```
  Parse the JSON; the target is the first entry whose `state` is `needs-review` (the script already excludes `feedback-pending`). If everything is `feedback-pending`, tell the user there's nothing new to review and stop.

## Step 2 — Set up the module

```
pwsh scripts/bitfocus-setup-module.ps1 -ModuleName <name> -Json
```
This clones into `companion-modules-reviewing/` and returns `{ module, reviewTag, previousTag, directory }`. Capture all four.
- If it errors that the module is already reviewed with feedback pending, surface that to the user; only re-run with `-Force` if they confirm.

## Step 3 — Generate the shared fact sheet

```
pwsh scripts/module-facts.ps1 -ModuleDir <directory> -GitTag <reviewTag> -Json
```
Capture `language`, `apiVersion`, **`apiSkill`** (the single applicable compliance skill — `companion-v1-api-compliance` or `companion-v2-api-compliance`), `protocols`, `srcFiles`, and `templateCheck`.

## Step 4 — Deterministic compliance + build/lint

```
pwsh scripts/validate-template.ps1 -ModuleDir <directory> -ExpectedVersion <reviewTag> -RunBuild -Json
```
Every `Critical` finding is **blocking** — carry each into the review verbatim (file, expected, found). `-RunBuild` runs `yarn install`/`yarn package` (+ `yarn lint` for TS); a failed build is Critical. Do **not** re-check these by hand.

## Step 5 — Diff classification baseline

- If `previousTag` is a real tag (not "(none — first release)"), the reviewers classify each finding **NEW** / **REGRESSION** / **PRE-EXISTING** using `git -C <directory> diff <previousTag>..<reviewTag>`. Only NEW and REGRESSION block; pre-existing medium-and-lower are non-blocking notes.
- First release → every finding is eligible to block.
- **Re-review:** if a prior review for this module already exists under `reviews/<name>/`, read `.squad/skills/review-follow-up-same-tag/SKILL.md` and frame this as a follow-up that *verifies the maintainer's fixes* — still report-only, never re-fix.

## Step 6 — Dispatch the review subagents (in parallel)

Launch all three with the Agent tool in a single message. Give each: the **fact sheet** (so they don't re-derive basics), the clone `directory`, the `previousTag`, and the `apiSkill` name. Each returns structured findings (severity, `file:line`, classification, description, and a suggested fix **for the maintainer**) — they never edit the module.

- `companion-protocol-reviewer` — connection lifecycle, sockets, OSC/TCP/UDP/HTTP/Bonjour, timeouts, `destroy()` cleanup, `InstanceStatus`.
- `companion-qa-reviewer` — bugs, edge cases, error handling, performance, async correctness, silent failures.
- `companion-compliance-reviewer` — reads `.squad/skills/<apiSkill>/SKILL.md`; actions/feedbacks/presets/variables/config structure, upgrade scripts, and test detection (absence is non-blocking).

(Template/build/lint already came from Step 4 — don't duplicate it.)

## Step 7 — Assemble the review

Read `.squad/skills/review-scorecard/SKILL.md` for the exact 📊 Scorecard and 📋 Issues format. Merge the Step-4 deterministic findings + the three subagents' findings into ONE file, deduping by file+line. Sections in order: title + meta header, **Fix Summary for Maintainer**, **📊 Scorecard**, **Verdict**, **📋 Issues** (Blocking / Non-blocking checklist), `🔴 Critical` → `🟠 High` → `🟡 Medium` → `🟢 Low` → `💡 Nice to Have` → `🔮 Next Release` → `⚠️ Pre-existing Notes` → `🧪 Tests` → `✅ What's Solid`. Omit empty sections. Use plain text (no emoji) in individual issue headings so anchors are stable.

Write to:
```
reviews/<name>/review-<name>-<reviewTag>-<YYYYMMDD-HHMMSS>.md
```
(`mkdir -p reviews/<name>/` first; timestamp from `date -u +"%Y%m%d-%H%M%S"`). Then append a row to `reviews/TRACKER.md`:
```
| ⬜ | <name> | <reviewTag> | <YYYY-MM-DD> | [review](<name>/review-<name>-<reviewTag>-<stamp>.md) |
```
The ⬜ stays until the user delivers the review and marks it ✅ — that is what keeps the module from being reviewed twice.

## Step 8 — Stop (report only)

Tell the user the review file path, the verdict (✅ Approved / ❌ Changes Required), and the blocking count. Do **not** modify the module, create a `fix/...` branch, or push anything to the module's repo. The user reviews the report, then delivers it to the maintainer.
