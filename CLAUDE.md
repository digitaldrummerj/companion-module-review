# companion-module-review — guide for Claude Code

This repo is the **workspace** for reviewing Bitfocus Companion modules for release approval: it produces a **ranked review report** for the maintainer. The review system itself — the orchestrator and review skills, the three review subagents, `/review-module`, and the PowerShell pipeline scripts — ships as the **`companion-module-review`** plugin in the [`bitfocus-companion-skills`](https://github.com/digitaldrummerj/bitfocus-companion-skills) marketplace, together with the companion knowledge plugins the reviewers consult. `.claude/settings.json` declares the marketplace and every plugin this workspace needs; `pwsh setup.ps1` installs any that are missing.

## Run a review

Say **"review the next module"** or **"review companion-module-X"**, or use **`/review-module [name] [tag|module|both]`**. Both invoke the plugin's `review-companion-module` skill, which runs the pipeline in order:

`bitfocus-queue.ps1` → `bitfocus-setup-module.ps1` → `module-facts.ps1` (runs `api-scan.ps1`; reports the API level — 1 / 2.0 / 2.1 — and which v2 reference files apply) → `validate-template.ps1 -RunBuild` → dispatch the `companion-protocol-reviewer`, `companion-qa-reviewer`, and `companion-compliance-reviewer` subagents → assemble one review under `reviews/{module}/` + a ⬜ `TRACKER.md` row.

The scripts live in the plugin (`<plugin>/scripts/`); the skill invokes them from there. Run from this repo's root — the scripts locate the workspace from `COMPANION_REVIEW_ROOT` or the git toplevel of the current directory.

**Scope** (default `tag`): `tag` = only this release's changes (`previousTag..reviewTag` diff); `module` = the whole current module, flat by severity; `both` = whole module classified new vs pre-existing.

## Report-only — the hard rule

Reviews **report only**. NEVER:
- modify a module's code, run an auto-fix, or "apply" review findings;
- create `fix/...` branches inside a module's repo; or
- commit or push anything to a module's repo.

The **only** output of a review is the markdown file under `reviews/`. The maintainer applies the fixes themselves; a resubmission gets a re-review that *verifies* their changes.

## Workspace layout

- `reviews/` — completed reviews + `TRACKER.md` (the ✅/⬜ feedback-submitted ledger; ⬜ + a local review = "don't re-review yet").
- `companion-modules-reviewing/` — cloned modules under review (gitignored; each is its own git repo). **Never commit these.** Override with `COMPANION_MODULES_DIR`.
- `companion-module-templates/` — official JS/TS, v1/v2 templates the validator diffs against (gitignored; cloned by `setup.ps1`). Override with `COMPANION_TEMPLATES_DIR`. **Never auto-updated:** concurrent review sessions share these clones, so an automatic pull would move the reference mid-review. Refresh explicitly with the plugin's `update-templates.ps1` *between* sessions — it is the only thing that ever moves a template.
- `.claude/settings.json` — the marketplace, the enabled plugins, and the script permissions.
- `setup.ps1` — workspace bootstrap: git hooks, plugin install, module/template directories.

## Changing the review system

Edit it in the skills repo, not here: `bitfocus-companion-skills/plugins/companion-module-review/` (skills, agents, command, scripts) and the shared companion plugins next to it. To try changes before they're published, run `claude --plugin-dir ~/Development/bitfocus-companion-skills/plugins/companion-module-review` from this repo, and set `COMPANION_REVIEW_PLUGIN_DIR` to the same path for `setup.ps1`. The script tests live there too: `pwsh plugins/companion-module-review/scripts/tests/run-all.ps1` (no network needed).

## Conventions

- Run scripts with `pwsh`. They honor `COMPANION_REVIEW_ROOT` / `COMPANION_MODULES_DIR` / `COMPANION_TEMPLATES_DIR`.
- A review **aborts** if the template clone is behind upstream — a stale reference produces false findings against a correct module. Refresh with `update-templates.ps1`, then re-run.
- Reviews run one module at a time.
- Don't auto-commit the review file — write it and let the user review before they push it to this repo and deliver it.
