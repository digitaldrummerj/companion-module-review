# companion-module-review

An AI-powered review system for [Bitfocus Companion](https://bitfocus.io/companion) modules. The squad — a Firefly-universe cast — discovers pending module submissions on the BitFocus developer portal, performs structured code reviews, and produces fix branches ready for maintainers to inspect.

Deterministic checks (template compliance, build, lint, file/field rules) run in PowerShell scripts; the AI agents spend their attention on judgment — protocol correctness, logic, architecture.

---

## Setup

### 1. Prerequisites

| Tool | Why | Install |
|------|-----|---------|
| **PowerShell 7.6+** | The automation scripts are PowerShell | [macOS](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-macos) · [Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows) — verify `pwsh --version` |
| **GitHub CLI** (`gh`) | GitHub auth, repo ops, the BitFocus portal API token | [cli.github.com](https://cli.github.com/) — verify `gh --version` |
| **GitHub Copilot CLI** | Runs the squad | [docs.github.com](https://docs.github.com/en/copilot/copilot-in-the-cli/about-github-copilot-in-the-cli) — verify `copilot --version` |
| **Squad** | The multi-agent framework | [github.com/bradygaster/squad](https://github.com/bradygaster/squad) |

### 2. Clone the repo and run setup

```powershell
git clone https://github.com/<org>/companion-module-review.git
cd companion-module-review
pwsh setup.ps1
```

`setup.ps1` configures the git hooks (which prevent cloned modules being committed) and creates the `companion-modules-reviewing/` directory **inside the repo** where modules are cloned during reviews. That directory is gitignored, so checkouts never show up as changes.

### 3. Set up the template repos (required)

`validate-template.ps1` and `module-facts.ps1` compare each module against the **official template, selected by API version × language**. The four templates live in `~/Development/companion-module-dev` (override with the `COMPANION_TEMPLATES_DIR` environment variable):

```powershell
cd ~/Development/companion-module-dev   # or your $COMPANION_TEMPLATES_DIR

# v2 templates (current)
git clone https://github.com/bitfocus/companion-module-template-js
git clone https://github.com/bitfocus/companion-module-template-ts

# v1 templates — same repos pinned to the last v1.x commit, with a -v1 suffix
git clone companion-module-template-js companion-module-template-js-v1
git -C companion-module-template-js-v1 checkout 9e222b4d0b1a68b2acda7d8adb52c9f90ee4c3d1

git clone companion-module-template-ts companion-module-template-ts-v1
git -C companion-module-template-ts-v1 checkout 42609d8dab515a25ec2f3b3c7adafe57aa41b7be
```

The validator detects a module's `@companion-module/base` major version and picks `companion-module-template-{js,ts}` (v2) or the `-v1` variant automatically.

### 4. Verify GitHub auth

```powershell
gh auth status      # run `gh auth login` if needed
```

The scripts use your existing `gh` auth for both GitHub and the BitFocus portal API — no extra credentials.

### 5. Open the workspace (optional)

Open `companion-module-review.code-workspace` in VS Code for multi-repo support across the review repo and any cloned modules.

### 6. Verify the install

Run the script test suites — they need no network and should all pass:

```powershell
pwsh scripts/tests/ReviewState.Tests.ps1
pwsh scripts/tests/ValidateTemplate.Tests.ps1
pwsh scripts/tests/SyncSkills.Tests.ps1
pwsh scripts/tests/ModuleFacts.Tests.ps1
```

---

## Usage

### Run a review with the squad (primary path)

1. Open a terminal and run `copilot` to enter the Copilot CLI.
2. Run `/agents` and select **Squad**.
3. Ask the team:
   - Next pending module: `"hey team, let's review the next module"`
   - A specific module: `"hey team, let's review companion-module-allenheath-sq"`

The squad runs the **bootstrap** first (generates a shared *module fact sheet* so the reviewers don't each re-derive the basics), then reviews across template/API compliance, protocol, actions/feedbacks/variables/presets, and tests, assembles a single review under `reviews/{module-name}/`, and adds a ⬜ row to `reviews/TRACKER.md`.

### Scripts reference

All scripts are read-only against GitHub/BitFocus except `git clone` (setup) and `cleanup` (local deletes). Add `-Json` where available for machine-readable output.

| Script | What it does |
|--------|--------------|
| **`bitfocus-queue.ps1 [-Json]`** | Show the pending review queue, oldest first, **labeled by local review state** (`needs review` / `reviewed - feedback pending` / `re-review?`). "Next up" never points at a module already reviewed locally whose feedback hasn't been sent yet. |
| **`bitfocus-setup-module.ps1 [-ModuleName <name>] [-Force] [-Json]`** | Validate `PENDING` status, find the previous approved tag, and clone the module into `companion-modules-reviewing/`. Auto-selects the oldest module **that still needs review** (skips feedback-pending). Naming a feedback-pending module requires `-Force`. |
| **`module-facts.ps1 -ModuleDir <path> [-GitTag <tag>] [-SkipTemplateCheck] [-Json]`** | The shared **fact sheet**: language (JS/TS), API version → the single applicable api-compliance skill, package.json/manifest essentials, detected protocols, source-tree list, and a template-compliance summary. Run once at review start; hand it to every reviewer. |
| **`validate-template.ps1 -ModuleDir <path> [-ExpectedVersion <tag>] [-RunBuild] [-TemplateDir <path>] [-Json]`** | The **deterministic** template review: required files, config-file parity, package.json/manifest fields, LICENSE, `src/`-only source, devDependencies, husky, gitignored-not-committed. `-RunBuild` also runs `yarn install`/`yarn package` (+ `yarn lint` for TS). Exits 1 on any Critical. |
| **`sync-skills.ps1 [-Check]`** | Mirror `.squad/skills/` (source of truth) → `.copilot/skills/`. Run after editing any skill. `-Check` reports drift without writing (CI / pre-commit friendly). |
| **`cleanup-modules.ps1`** | Remove cloned `companion-module-*` directories from `companion-modules-reviewing/` to reclaim disk. |

### The review process, mapped to the tooling

| Step | Tooling |
|------|---------|
| Find the next module | `bitfocus-queue.ps1` (skips already-reviewed) |
| Set it up | `bitfocus-setup-module.ps1` (clone + previous-tag lookup) |
| Gather shared context | `module-facts.ps1` → fact sheet |
| Deterministic compliance | `validate-template.ps1 -RunBuild` |
| Judgment review | squad agents (protocol, logic, tests) read the fact sheet + the one applicable api skill |
| Assemble + record | single review file under `reviews/{module}/` + a ⬜ row in `reviews/TRACKER.md` |
| Deliver feedback | send the maintainer the review via the developer portal, then mark the row ✅ in `TRACKER.md` |

> The ✅/⬜ column in `TRACKER.md` is how the queue knows a module is done. A module stays in the online queue until feedback is uploaded, so marking ✅ after delivery is what keeps it from being reviewed twice.

---

## How it works

1. **Discover** — `bitfocus-queue.ps1` lists pending modules and labels each by local review state.
2. **Set up** — `bitfocus-setup-module.ps1` clones the target into `companion-modules-reviewing/`.
3. **Bootstrap** — `module-facts.ps1` produces the shared fact sheet (language, API version, protocols, template-check summary); `validate-template.ps1 -RunBuild` runs the deterministic compliance + build/lint.
4. **Review** — the squad (Mal, Wash, Kaylee, Zoe, Simon) reviews, loading only the applicable v1/v2 api-compliance skill — not the authoring skills.
5. **Assemble** — Scribe assembles findings into `reviews/{module-name}/` and adds a ⬜ row to `reviews/TRACKER.md`.
6. **Fix** — Kaylee and Wash create a `fix/v{version}-{date}-issues` branch in the module repo with one commit per issue.

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
│   ├── sync-skills.ps1             ← mirror .squad/skills → .copilot/skills
│   ├── cleanup-modules.ps1         ← remove cloned modules
│   └── tests/                      ← self-contained test suites (no Pester)
├── companion-modules-reviewing/    ← cloned modules under review (gitignored)
│   └── companion-module-{name}/    ← one per module, its own git repo
├── .squad/                         ← squad team state (agents, decisions, skills = source of truth)
└── .copilot/                       ← Copilot agent skills (mirror of .squad/skills + system skills)

~/Development/companion-module-dev/ ← template repos (COMPANION_TEMPLATES_DIR)
├── companion-module-template-js / -ts        ← v2 templates
└── companion-module-template-js-v1 / -ts-v1  ← v1 templates (pinned commits)
```

---

## The squad (Firefly cast)

| Name | Role | Scope |
| ------ | ------ | ------- |
| **Mal** | Lead / Coordinator | Scope, final verdict, decisions |
| **Wash** | Backend / Protocol | Network lifecycle, OSC, connection errors, status transitions |
| **Kaylee** | Module Dev | Runs `validate-template.ps1`; actions/feedbacks/variables/presets structure; auto-fix |
| **Zoe** | Tester | Test coverage, edge cases, quality |
| **Simon** | API Compliance | v1.x and v2.0 API checks |
| **Scribe** | Silent logger | Assembles review file, logs decisions, runs `sync-skills.ps1` |
| **Ralph** | Monitor | Work queue, BitFocus dashboard, backlog |

---

## Skills

Skills are Copilot Agent Skills (`SKILL.md` files) that teach the squad domain knowledge.

| Location | Role |
| ---------- | --------- |
| `.squad/skills/` | **Source of truth.** Edit skills here. |
| `.copilot/skills/` | A **generated mirror** of `.squad/skills/` (plus Copilot-global system skills). Kept in sync by `scripts/sync-skills.ps1` — don't edit directly. |

> After editing any skill in `.squad/skills/`, run `pwsh scripts/sync-skills.ps1` (or `-Check` to verify sync).

### Companion module development skills

Authoring references — used when implementing auto-fixes. Examples are protocol-neutral (no module-specific code).

| Skill | Description |
| ------- | ------------- |
| `companion-actions` | Reference for `CompanionActionDefinition`, option field types, callbacks, subscribe/unsubscribe |
| `companion-action-file-pattern` | Multi-file action pattern: `src/actions/action-{category}.ts` + aggregator |
| `companion-add-action-to-category-file` | Add actions to an existing category file |
| `companion-feedbacks` | Boolean and advanced feedback definitions, `checkFeedbacks`, subscribe/unsubscribe |
| `companion-feedback-file-pattern` | Multi-file feedback pattern + aggregator |
| `companion-add-feedback-to-category-file` | Add feedbacks to an existing category file |
| `companion-config` | Config field types, `Regex.*` constants, `configUpdated()` lifecycle |
| `companion-upgrades` | Upgrade scripts, migration helpers, version numbering |
| `companion-variable-definition` / `companion-variable-set-value` | Declare variables / set & read values |
| `companion-preset-category-file` / `companion-add-preset-to-category-file` | Enum-based preset pattern / add presets |
| `osc-integration` | OSC UDP/TCP integration with the `osc` package |

### Review workflow skills

| Skill | Description |
| ------- | ------------- |
| `companion-template-compliance` | Thin wrapper: run `scripts/validate-template.ps1`, interpret findings, and apply the few judgment items the script can't decide (HELP quality, tsconfig deviations, manifest version normalization) |
| `companion-v1-api-compliance` | `@companion-module/base` v1.5–v1.14 checklist (loaded only for v1 modules) |
| `companion-v2-api-compliance` | `@companion-module/base` v2.0+ checklist (loaded only for v2 modules) |
| `companion-bitfocus-dashboard` | BitFocus portal API: pending reviews, previous-tag lookup, repo URLs, clone workflow |
| `review-scorecard` | Standard scorecard / Table-of-Contents format |
| `review-auto-fix` | Fix-branch workflow: branch naming, one commit per issue, no-PR rule |
| `project-conventions` | Project-level conventions |
| `make-skill-template` | Meta-skill for creating new skills |

### Squad / agent framework skills

Shared squad-operation skills (`agent-collaboration`, `model-selection`, `git-workflow`, `secret-handling`, `windows-compatibility`, `reviewer-protocol`, `release-process`, and others) live in `.copilot/skills/` and govern how the team operates across projects.

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
