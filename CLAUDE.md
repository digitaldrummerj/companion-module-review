# companion-module-review — guide for Claude Code

This repo reviews Bitfocus Companion modules for release approval and produces a **ranked review report** for the maintainer. Deterministic checks run as PowerShell scripts in `scripts/`; judgment review runs via review subagents.

## Run a review

Say **"review the next module"** or **"review companion-module-X"**, or use **`/review-module [name]`**. Both invoke the `review-companion-module` skill, which runs the pipeline in order:

`bitfocus-queue.ps1` → `bitfocus-setup-module.ps1` → `module-facts.ps1` → `validate-template.ps1 -RunBuild` → dispatch the `companion-protocol-reviewer`, `companion-qa-reviewer`, and `companion-compliance-reviewer` subagents → assemble one review under `reviews/{module}/` + a ⬜ `TRACKER.md` row.

## Report-only — the hard rule

The squad **reviews and reports only**. NEVER:
- modify a module's code, run an auto-fix, or "apply" review findings;
- create `fix/...` branches inside a module's repo; or
- commit or push anything to a module's repo.

The **only** output of a review is the markdown file under `reviews/`. The maintainer applies the fixes themselves; a resubmission gets a re-review that *verifies* their changes. (See `.squad/decisions.md` and `.squad/skills/project-conventions`.)

## Workspace layout

- `scripts/` — the review pipeline (PowerShell; `scripts/lib/ReviewState.ps1` holds shared path/state helpers). Tests in `scripts/tests/` (no Pester).
- `companion-modules-reviewing/` — cloned modules under review (gitignored; each is its own git repo). **Never commit these.**
- `companion-module-templates/` — official JS/TS, v1/v2 templates the validator diffs against (gitignored; cloned by `setup.ps1`). Override with `COMPANION_TEMPLATES_DIR`.
- `reviews/` — completed reviews + `TRACKER.md` (the ✅/⬜ feedback-submitted ledger; ⬜ + a local review = "don't re-review yet").
- `.squad/` — the GitHub Copilot squad (its own orchestration). **`.squad/skills/` is the source of truth for domain knowledge** (companion API, template compliance, scorecard format); Claude reads these by path. `.copilot/skills/` is a generated mirror (`scripts/sync-skills.ps1`). Don't add a third copy under `.claude/`.

## Conventions

- Run scripts with `pwsh`. They honor `COMPANION_MODULES_DIR` / `COMPANION_TEMPLATES_DIR`.
- Reviews run one module at a time.
- Don't auto-commit the review file — write it and let the user review before they push it to this repo and deliver it.
