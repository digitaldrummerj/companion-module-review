# companion-module-review

An AI-powered review system for [Bitfocus Companion](https://bitfocus.io/companion) modules. The squad — a Firefly-universe cast — discovers pending module submissions on the BitFocus developer portal, performs structured code reviews, and produces fix branches ready for maintainers to inspect.

---

## How it works

1. **Discover** — Check what's pending on the BitFocus developer portal (`scripts/bitfocus-queue.ps1`)
2. **Set up** — Clone the target module into the sibling `companion-modules-reviewing/` workspace (`scripts/bitfocus-setup-module.ps1`)
3. **Review** — The squad (Mal, Wash, Kaylee, Zoe, Simon) analyse the module across template compliance, API compliance, actions, feedbacks, variables, presets, and OSC integration
4. **Assemble** — Scribe assembles findings into a single review file under `reviews/{module-name}/`
5. **Fix** — Kaylee and Wash create a `fix/v{version}-{date}-issues` branch inside the module repo with individual commits per issue

---

## Directory structure

```
companion-module-review/          ← this repo
├── reviews/                      ← completed review files
│   ├── autodirector-mirusuite/
│   └── softouch-easyworship/
├── scripts/                      ← PowerShell automation
│   ├── bitfocus-queue.ps1        ← show pending review queue (read-only)
│   ├── bitfocus-setup-module.ps1 ← clone + validate a module for review
│   └── cleanup-modules.ps1       ← remove cloned modules except templates
├── .squad/                       ← squad team state (agents, decisions, skills)
├── .copilot/                     ← Copilot agent skills
└── squad-export.json             ← squad export (gitignored)

companion-modules-reviewing/      ← sibling directory (gitignored contents)
├── companion-module-template-ts/ ← TypeScript template (reference)
├── companion-module-template-js/ ← JavaScript template (reference)
└── companion-module-{name}/      ← cloned modules under review
```

---

## Scripts

### `scripts/bitfocus-queue.ps1`

Shows the pending review queue from the BitFocus developer portal, sorted oldest-first. Read-only — never clones anything. Run this first to see what needs reviewing.

```powershell
pwsh scripts/bitfocus-queue.ps1
```

Output: a table of pending modules, their submitted tags, days waiting, and whether they're already cloned locally.

### `scripts/bitfocus-setup-module.ps1`

Validates and clones a module for review. Auto-selects the oldest PENDING module if no name is given. Verifies `PENDING` status (skips `WITHDRAWN`), finds the previous approved tag for diff context, and clones the GitHub repo.

```powershell
# Auto-select oldest pending module:
pwsh scripts/bitfocus-setup-module.ps1

# Or specify a module explicitly:
pwsh scripts/bitfocus-setup-module.ps1 -ModuleName allenheath-sq
```

### `scripts/cleanup-modules.ps1`

Removes all `companion-module-*` directories from the sibling `companion-modules-reviewing/` directory, except the two template repos. Run after finishing reviews to reclaim disk space.

```powershell
pwsh scripts/cleanup-modules.ps1
```

---

## The squad (Firefly cast)

| Name | Role | Scope |
|------|------|-------|
| **Mal** | Lead / Coordinator | Scope, final verdict, decisions |
| **Wash** | Backend / Protocol | Network lifecycle, OSC, connection errors, status transitions |
| **Kaylee** | Module Dev | Actions, feedbacks, variables, presets, template compliance, auto-fix |
| **Zoe** | Tester | Test coverage, edge cases, quality |
| **Simon** | API Compliance | v1.x and v2.0 API checks |
| **Scribe** | Silent logger | Assembles review file, logs decisions |
| **Ralph** | Monitor | Work queue, BitFocus dashboard, backlog |

---

## Skills

Skills are Copilot Agent Skills (SKILL.md files) that teach the squad domain knowledge. They live in two locations:

| Location | Purpose |
|----------|---------|
| `.squad/skills/` | Project-specific skills for this review workflow |
| `.copilot/skills/` | Personal/global skills (also available to all squad agents) |

### Companion Module Development Skills

These teach the squad the Bitfocus Companion module API — used both during review and when implementing auto-fixes.

| Skill | Description |
|-------|-------------|
| `companion-actions` | Full reference for `CompanionActionDefinition`, option field types, callbacks, subscribe/unsubscribe lifecycle |
| `companion-action-file-pattern` | Multi-file action pattern: creating `src/actions/action-{category}.ts` files and wiring them into the `actions.ts` aggregator |
| `companion-add-action-to-category-file` | Add actions to an existing category file (3-step recipe) |
| `companion-feedbacks` | Full reference for boolean and advanced feedback definitions, `checkFeedbacks`, subscribe/unsubscribe |
| `companion-feedback-file-pattern` | Multi-file feedback pattern: creating `src/feedbacks/feedback-{category}.ts` files and wiring the aggregator |
| `companion-add-feedback-to-category-file` | Add feedbacks to an existing category file |
| `companion-config` | Config field types (`textinput`, `number`, `dropdown`, `checkbox`, `secret`, etc.), `Regex.*` constants, `configUpdated()` lifecycle |
| `companion-upgrades` | Upgrade scripts (`CompanionStaticUpgradeScript`), migration helpers, version numbering |
| `companion-variable-definition` | Declare variables with `setVariableDefinitions()`, `variableId` naming rules, dynamic registration |
| `companion-variable-set-value` | Set and read variable values with `setVariableValues()` / `getVariableValue()` |
| `companion-preset-category-file` | Enum-based preset category file pattern and aggregator wiring |
| `companion-add-preset-to-category-file` | Add presets to an existing category file |
| `osc-integration` | OSC UDP/TCP integration using the `osc` npm package: socket lifecycle, send, receive, action wiring, state updates |

### Review Workflow Skills

These govern how reviews are conducted and how results are structured.

| Skill | Description |
|-------|-------------|
| `companion-template-compliance` | Full checklist for JS and TS template compliance: required files, `package.json` rules, `manifest.json` rules, HELP.md validation, husky hooks. All violations are 🔴 Critical |
| `companion-v1-api-compliance` | Per-version checklist for `@companion-module/base` v1.5–v1.14 (Companion 3.1–4.2): deprecated patterns, breaking changes, upgrade recommendations |
| `companion-v2-api-compliance` | Checklist for `@companion-module/base` v2.0+ (Companion 4.3+): removed APIs, breaking changes, expression handling |
| `companion-bitfocus-dashboard` | BitFocus developer portal API: list pending reviews, get previous approved tag, derive repo URLs, clone workflow. PowerShell and bash patterns included |
| `review-scorecard` | Standard scorecard format (issue counts by severity, New vs Existing columns), Table of Contents format, anchor generation rules |
| `review-auto-fix` | Fix branch workflow: branch naming (`fix/v{version}-{date}-issues`), commit strategy (one commit per issue), scope of fixes, no-PR rule |
| `project-conventions` | Project-level conventions (template — fill in as the codebase evolves) |
| `make-skill-template` | Meta-skill for creating new skills: SKILL.md frontmatter, directory structure, validation checklist |

### Squad / Agent Framework Skills

These govern how the squad operates as a team and are shared across all projects.

| Skill | Description |
|-------|-------------|
| `agent-collaboration` | Worktree awareness, decision recording, cross-agent communication, reviewer lockout protocol |
| `agent-conduct` | Hard rules: Product Isolation Rule (no hardcoded agent names in product code), Peer Quality Check |
| `architectural-proposals` | How to write architectural proposals: required sections, tone ceiling, wave restructuring, risk documentation |
| `ci-validation-gates` | Defensive CI/CD: semver validation, NPM token type, retry logic for registry propagation, draft release detection |
| `cli-wiring` | CLI command wiring checklist: command file → routing block → help text (prevents the "implemented but not routed" bug) |
| `client-compatibility` | Platform detection (CLI vs VS Code vs fallback), spawn adaptations per surface, SQL tool caveat |
| `cross-squad` | Coordinating work across multiple Squad instances via manifests, issue handoff protocol, feedback loops |
| `distributed-mesh` | Distributed squad coordination using git as transport: three-zone model (local/remote-trusted/remote-opaque), `mesh.json`, sync scripts |
| `docs-standards` | Microsoft Style Guide rules, Squad-specific formatting patterns, structure conventions |
| `economy-mode` | Cost-optimized model selection: activation phrases, model substitution table, persistent config |
| `external-comms` | PAO workflow for drafting community responses: scan → classify → draft → human review gate → post → audit |
| `gh-auth-isolation` | Managing multiple GitHub accounts (EMU + personal): detecting active identity, token extraction, push patterns |
| `git-workflow` | Squad branching model: `dev`-first, `squad/{number}-{slug}` branch names, worktree patterns for parallel issues |
| `github-multi-account` | AI-driven setup for `ghp`/`ghw` aliases for personal/work GitHub accounts |
| `history-hygiene` | Record final outcomes to history.md, not intermediate states or reversed decisions |
| `humanizer` | Tone enforcement for external-facing community responses: warm, active voice, second person, specific |
| `init-mode` | Team initialization: Phase 1 proposal (no files created), Phase 2 team creation, casting algorithm, `## Members` header requirement |
| `model-selection` | 5-layer model resolution hierarchy: per-agent config → global config → session directive → charter preference → task-aware auto |
| `nap` | Context hygiene: compress histories, prune logs, archive stale decisions before heavy fan-out work |
| `personal-squad` | User-level agents that travel across projects: ghost protocol (advise only, no writes to project state) |
| `release-process` | Step-by-step release runbook: semver validation, NPM token type, tag/release workflow, rollback procedure |
| `reskill` | Team-wide charter optimization: extract shared patterns into skills, trim charters to ≤1.5KB |
| `reviewer-protocol` | Reviewer rejection and strict lockout semantics: rejected author is locked out, different agent must revise |
| `secret-handling` | Never read `.env` files, never write secrets to `.squad/` committed files, Scribe pre-commit validation |
| `session-recovery` | Find and resume interrupted Copilot CLI sessions via `session_store` SQL queries |
| `squad-conventions` | Squad CLI codebase conventions: zero dependencies, `node:test`, `fatal()` pattern, Windows compatibility |
| `test-discipline` | Update tests when changing APIs — same commit, keep assertion arrays in sync with disk reality |
| `windows-compatibility` | Cross-platform patterns: safe timestamps (no colons), `path.join()`, `git commit -F` (no inline newlines) |

---

## Authentication

The BitFocus portal API and GitHub use your existing `gh` CLI auth. No extra credentials needed.

```powershell
# Verify auth is set up
gh auth status
```

---

## Related links

- [BitFocus developer portal](https://developer.bitfocus.io)
- [Companion module development docs](https://companion-module.github.io/companion-module-tools/)
- [BitFocus Companion](https://bitfocus.io/companion)
- [OpenAPI spec for the portal](https://developer.bitfocus.io/openapi.yaml)
