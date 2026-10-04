# companion-module-review

A Claude Code review system for [Bitfocus Companion](https://bitfocus.io/companion) modules. It discovers pending module submissions on the BitFocus developer portal, performs structured code reviews, and produces a ranked review report for the maintainer. It is **report-only**: it never modifies a module's code or creates fix branches — the maintainer applies the fixes.

Deterministic checks (template compliance, build, lint, file/field rules) run in PowerShell scripts; the review subagents spend their attention on judgment — protocol correctness, logic, architecture.

---

## Setup

### 1. Prerequisites

| Tool | Why | Install |
|------|-----|---------|
| **Claude Code** | Runs the review | [claude.com/claude-code](https://claude.com/claude-code) |
| **PowerShell 7.6+** | The automation scripts are PowerShell | [macOS](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-macos) · [Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows) — verify `pwsh --version` |
| **GitHub CLI** (`gh`) | GitHub auth, repo ops, the BitFocus portal API token | [cli.github.com](https://cli.github.com/) — verify `gh --version` |

### 2. Clone the repo and run setup

```powershell
git clone https://github.com/<org>/companion-module-review.git
cd companion-module-review
pwsh setup.ps1
```

`setup.ps1` does three things, all idempotent:
- Configures the git hooks (which prevent cloned modules being committed).
- Creates the gitignored `companion-modules-reviewing/` directory **inside the repo** where modules are cloned during reviews.
- Clones the official module templates into the gitignored `companion-module-templates/` (v2 `companion-module-template-{js,ts}` from GitHub; v1 `-{js,ts}-v1` variants pinned to the last v1.x commit) — these are what `validate-template.ps1` diffs each module against. Override their location with `COMPANION_TEMPLATES_DIR`.

  Templates that already exist are only **reported on**, never pulled: reviews often run several at a time against the same clones, so an automatic update would move the reference underneath a review in progress. Refresh them deliberately, between sessions, with `pwsh scripts/update-templates.ps1`. Every review verifies the clone against upstream first and stops if it is behind — a stale template produces false findings against a correct module.

### 3. Verify GitHub auth

```powershell
gh auth status      # run `gh auth login` if needed
```

The scripts use your existing `gh` auth for both GitHub and the BitFocus portal API — no extra credentials.

### 4. Open the workspace (optional)

Open `companion-module-review.code-workspace` in VS Code.

### 5. Verify the install

Run the script test suites — they need no network and should all pass:

```powershell
pwsh scripts/tests/run-all.ps1           # all suites, combined summary (add -Quiet for one line each)
```

Or individually:

```powershell
pwsh scripts/tests/ReviewState.Tests.ps1
pwsh scripts/tests/ValidateTemplate.Tests.ps1
pwsh scripts/tests/ModuleFacts.Tests.ps1
pwsh scripts/tests/ApiScan.Tests.ps1
```

---

## Usage

### Run a review

In Claude Code, say **"review the next module"** or **"review companion-module-X"**, or run **`/review-module [name] [tag|module|both]`**. This triggers the `review-companion-module` skill, which runs the pipeline in order — `bitfocus-queue` → `bitfocus-setup-module` → `module-facts` → `validate-template -RunBuild` → three parallel review subagents (`companion-protocol-reviewer`, `companion-qa-reviewer`, `companion-compliance-reviewer`) → assemble one review under `reviews/{module-name}/` + a ⬜ `TRACKER.md` row. It is **report-only**: it never modifies the module or creates fix branches. (See [CLAUDE.md](CLAUDE.md).)

**Scope** (default `tag`):
- `tag` — only this release's changes (the `previousTag..reviewTag` diff); findings are new/regression; pre-existing issues not surfaced.
- `module` — the whole current module, flat by severity (no diff, no new-vs-existing split).
- `both` — the whole module classified new vs pre-existing (only new blocks; pre-existing noted).

### Scripts reference

All scripts are read-only against GitHub/BitFocus except `git clone` (setup) and `cleanup` (local deletes). Add `-Json` where available for machine-readable output.

| Script | What it does |
|--------|--------------|
| **`bitfocus-queue.ps1 [-Json]`** | Show the pending review queue, oldest first, **labeled by local review state** (`needs review` / `reviewed - feedback pending` / `re-review?`). "Next up" never points at a module already reviewed locally whose feedback hasn't been sent yet. |
| **`bitfocus-setup-module.ps1 [-ModuleName <name>] [-Force] [-Json]`** | Validate `PENDING` status, find the previous approved tag, and clone the module into `companion-modules-reviewing/`. Auto-selects the oldest module **that still needs review** (skips feedback-pending). Naming a feedback-pending module requires `-Force`. |
| **`module-facts.ps1 -ModuleDir <path> [-GitTag <tag>] [-SkipTemplateCheck] [-SkipTemplateFreshness] [-SkipApiScan] [-Json]`** | The shared **fact sheet**: language (JS/TS), API version → the single applicable api-compliance skill, the exact **API level** (`1` / `2.0` / `2.1`, resolved from the lockfile before the `package.json` range — `baseVersion`, `baseVersionSource`, `apiAmbiguous` when only a minor-floating range like `^2.0.0` was available) with the minimum Companion release and the **`apiReferences`** the compliance reviewer must load (`references/v2.0.md`, plus `v2.1.md` for 2.1 — never a later one), package.json/manifest essentials, detected protocols, source-tree list, a template-compliance summary, and the **`apiScan`** hints from `api-scan.ps1`. Run once at review start; hand it to every reviewer. |
| **`validate-template.ps1 -ModuleDir <path> [-ExpectedVersion <tag>] [-RunBuild] [-TemplateDir <path>] [-SkipTemplateFreshness] [-Json]`** | The **deterministic** template review: required files, config-file parity, package.json/manifest fields, LICENSE, `src/`-only source, devDependencies, husky, gitignored-not-committed. Auto-selects the matching template by API version × language (the `-v1`/v2, js/ts variants in `companion-module-templates/`). Verifies the template clone against upstream **before** comparing anything (read-only `git ls-remote`; no fetch, no pull) — a clone behind upstream would judge the module against outdated expectations. Which files are compared is derived from the template's own tracked files, so a file added upstream is checked automatically. **API 2.1 allowances:** the v2 templates still pin base 2.0.x / `node22`, so `runtime.type` is judged against the module's API level — `node26` is accepted on 2.1 and a Critical `MAN-RUNTIME` on 2.0 — and a tsconfig whose only difference is extending tools' `node26/recommended` preset (2.1 + `node26` runtime) is an Info `TSCONFIG-NODE26`, not a `CONFIG-DIFF`. Test support is an accepted deviation: root `*.config.(js|ts)` tool files are not `SRC-AT-ROOT`, and a `tsconfig.json` widened for tests (extra include/exclude/types, `rootDir`, `noEmit`) is an Info `TSCONFIG-DEV-SCOPE`; an `eslint.config.mjs` whose only change is overrides scoped to test/tooling files is an Info `ESLINT-TEST-SCOPE`. `-RunBuild` also runs `yarn install`/`yarn package` (+ `yarn lint` for TS). Exits 1 on any Critical, **3** if the template is stale or unverifiable. |
| **`api-scan.ps1 -ModuleDir <path> [-ApiLevel <level>] [-Json]`** | Deterministic, comment-aware grep of `src/` + the manifest for API usage, keyed to the module's API level: v1 leftovers on any v2 module (`V1-*`), 2.1-only features on a 2.0 module (`LATER-API-2.1`), missing `affectedProperties` / `optionsToMonitorForSubscribe` and deprecated `setCustomVariableValue` on 2.1, and two v2 behaviours that compile but misbehave (`HELPER-SEND-AWAIT`, `BOOL-FEEDBACK-HELPER-BUG`). v1 modules aren't scanned. **Hints, not findings** — the compliance reviewer verifies each `file:line`; always exits 0. Run automatically by `module-facts.ps1`. |
| **`update-templates.ps1 [-DryRun] [-Yes] [-Json]`** | **The only thing that ever moves a template.** Fast-forwards the two v2 clones to `origin/main` (`--ff-only`; refuses a dirty work tree or a diverged clone) and asserts the pinned `-v1` clones haven't drifted. Warns when reviews look in flight. Never run by the pipeline — refresh between review sessions, not during one. |
| **`cleanup-modules.ps1`** | Remove cloned `companion-module-*` directories from `companion-modules-reviewing/` to reclaim disk. |
| **`archive-reviewed-clones.ps1 [-Destination <path>] [-Apply]`** | Move clones of fully signed-off modules — at least one `TRACKER.md` row and **every** row ✅ — into `companion-modules-reviewing/_removed/` for a final look before deleting by hand. A single ⬜ row keeps the clone; modules with no row are left alone. Dry run unless `-Apply`; nothing is deleted. |

### The review process, mapped to the tooling

| Step | Tooling |
|------|---------|
| Find the next module | `bitfocus-queue.ps1` (skips already-reviewed) |
| Set it up | `bitfocus-setup-module.ps1` (clone + previous-tag lookup) |
| Gather shared context | `module-facts.ps1` → fact sheet (also establishes template freshness, the API level + reference files, and the `api-scan.ps1` hints) |
| Template up to date? | if not, the review **stops** — `update-templates.ps1`, then start over |
| Deterministic compliance | `validate-template.ps1 -RunBuild` |
| Judgment review | the review subagents (protocol, QA/logic, compliance/tests) read the fact sheet + the one applicable api skill (and, for v2, only the `apiReferences` up to the module's API level) |
| Assemble + record | single review file under `reviews/{module}/` + a ⬜ row in `reviews/TRACKER.md` |
| Deliver feedback | send the maintainer the review via the developer portal, then mark the row ✅ in `TRACKER.md` |

> The ✅/⬜ column in `TRACKER.md` is how the queue knows a module is done. A module stays in the online queue until feedback is uploaded, so marking ✅ after delivery is what keeps it from being reviewed twice.

---

## How it works

1. **Discover** — `bitfocus-queue.ps1` lists pending modules and labels each by local review state.
2. **Set up** — `bitfocus-setup-module.ps1` clones the target into `companion-modules-reviewing/`.
3. **Bootstrap** — `module-facts.ps1` produces the shared fact sheet (language, API version, protocols, template-check summary) and verifies the template clone is current; a stale clone aborts the review here, before any build or subagent runs. `validate-template.ps1 -RunBuild` then runs the deterministic compliance + build/lint.
4. **Review** — three review subagents (protocol, QA/logic, compliance) review at the chosen scope, loading only the applicable v1/v2 api-compliance skill.
5. **Assemble** — the orchestrator merges all findings into one review under `reviews/{module-name}/` and adds a ⬜ row to `reviews/TRACKER.md`.
6. **Deliver** — send the maintainer the review via the developer portal; they apply the fixes. (Reviews never edit the module — report only.) Mark the TRACKER row ✅ once delivered.

---

## Directory structure

```text
companion-module-review/            ← this repo
├── reviews/                        ← completed review files + TRACKER.md
├── scripts/                        ← PowerShell automation
│   ├── lib/ReviewState.ps1         ← shared helpers (modules dir, TRACKER parsing, review state)
│   ├── bitfocus-queue.ps1          ← pending queue, labeled by review state (read-only)
│   ├── bitfocus-setup-module.ps1   ← clone + validate a module (dedups against local reviews)
│   ├── module-facts.ps1            ← shared "fact sheet" gathered once per review
│   ├── validate-template.ps1       ← deterministic template/build/lint compliance
│   ├── cleanup-modules.ps1         ← remove cloned modules
│   └── tests/                      ← self-contained test suites (no Pester)
├── companion-modules-reviewing/    ← cloned modules under review (gitignored)
│   └── companion-module-{name}/    ← one per module, its own git repo
├── companion-module-templates/     ← official templates, cloned by setup.ps1 (gitignored)
│   ├── companion-module-template-js / -ts        ← v2 templates
│   └── companion-module-template-js-v1 / -ts-v1  ← v1 templates (pinned commits)
└── .claude/                        ← the review system
    ├── skills/                     ← review-companion-module orchestrator + companion/review knowledge
    ├── agents/                     ← the three review subagents
    └── commands/                   ← /review-module
```
> Override the templates location with `COMPANION_TEMPLATES_DIR` if you keep them elsewhere.

---

## Review roles

The review runs in Claude Code as an orchestrator skill plus three subagents:

| Role | What it does |
| ---- | ------------ |
| **`review-companion-module`** (orchestrator skill) | Runs the pipeline, dispatches the subagents, assembles the report, writes the TRACKER row. Architecture + final verdict. |
| **`companion-protocol-reviewer`** | Network lifecycle, OSC/TCP/UDP/HTTP/Bonjour, socket cleanup, status transitions. |
| **`companion-qa-reviewer`** | Bugs, edge cases, error handling, performance, async correctness. |
| **`companion-compliance-reviewer`** | v1.x/v2.x API compliance, actions/feedbacks/presets/variables/config structure, upgrade scripts, tests. |

Deterministic template/build/lint compliance is handled by `validate-template.ps1`, not a subagent.

---

## Skills

Skills (`.claude/skills/*/SKILL.md`) are the orchestrator plus the companion/review domain knowledge the orchestrator and subagents read.

### Companion module reference

Reference for understanding and reviewing module code (the Companion module API). Examples are protocol-neutral.

| Skill | Description |
| ------- | ------------- |
| `companion-actions` · `companion-action-file-pattern` · `companion-add-action-to-category-file` | Action definitions, the multi-file action pattern, and adding actions |
| `companion-feedbacks` · `companion-feedback-file-pattern` · `companion-add-feedback-to-category-file` | Boolean/advanced feedbacks, the multi-file pattern, and adding feedbacks |
| `companion-preset-category-file` · `companion-add-preset-to-category-file` | Enum-based preset pattern / adding presets |
| `companion-config` | Config field types, regex constants, `configUpdated()` lifecycle |
| `companion-variable-definition` · `companion-variable-set-value` | Declare variables / set & read values |
| `companion-upgrades` | Upgrade scripts, migration helpers, version numbering |
| `osc-integration` | OSC UDP/TCP integration with the `osc` package |

### Review workflow

| Skill | Description |
| ------- | ------------- |
| `companion-template-compliance` | Thin wrapper: run `validate-template.ps1`, interpret findings, judge the few non-deterministic items (HELP quality, tsconfig deviations, manifest version normalization) |
| `companion-v1-api-compliance` · `companion-v2-api-compliance` | Per-version API checklists (the orchestrator loads only the one that applies) |
| `companion-bitfocus-dashboard` | BitFocus portal API: pending reviews, previous-tag lookup, repo URLs, clone workflow |
| `review-scorecard` | Standard scorecard / Table-of-Contents format |
| `review-follow-up-same-tag` | How to run a re-review that verifies a maintainer's fixes |
| `review-yarn4-lockfile-validation` | Yarn 4 lockfile validation checks |
| `project-conventions` | Review output location, naming, report-only directives, TRACKER update |

---

## Authentication

The BitFocus portal API and GitHub both use your existing `gh` CLI auth — no extra credentials.

```powershell
gh auth status
```

---

## Related links

- [BitFocus developer portal](https://developer.bitfocus.io)
- [Companion module development docs](https://companion-module.github.io/companion-module-tools/)
- [BitFocus Companion](https://bitfocus.io/companion)
- [OpenAPI spec for the portal](https://developer.bitfocus.io/openapi.yaml)
