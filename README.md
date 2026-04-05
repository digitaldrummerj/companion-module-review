# companion-module-review

An AI-assisted code review workspace for [BitFocus Companion](https://bitfocus.io/companion) modules. The team reviews module submissions from maintainers against quality, API compliance, template standards, and protocol correctness — producing a structured markdown review report for each module release.

## What It Does

When a Companion module maintainer submits a new release for approval, this workspace:

1. Fetches the pending review queue from the BitFocus developer portal API
2. Clones the module repository into the sibling `companion-modules-reviewing/` directory
3. Runs a multi-agent review across build, API compliance, protocol implementation, template structure, tests, and error handling
4. Writes a single assembled review file to `reviews/{module-name}/`

Reviews are **read-only** — the team never opens PRs, posts comments, or calls write APIs anywhere. All output is local markdown.

---

## Repository Layout

```
companion-module-review/
├── reviews/                        # Permanent review history (one folder per module)
│   └── {module-name}/
│       └── review-{name}-{tag}-{date}.md
├── scripts/
│   ├── bitfocus-setup-module.ps1   # Fetch queue + clone a module for review
│   ├── bitfocus-queue.ps1          # List pending modules from the BitFocus API
│   └── cleanup-modules.ps1        # Remove all reviewed modules from the workspace
├── .squad/                         # AI team state (agents, decisions, skills, logs)
├── .copilot/                       # GitHub Copilot skills (knowledge base for agents)
├── .github/
│   ├── agents/squad.agent.md       # AI team governance rules
│   └── workflows/                  # Squad label automation workflows
└── companion-module-review.code-workspace
```

The `companion-modules-reviewing/` directory lives **outside** this repo (a sibling directory) and holds the temporary module checkouts. Two permanent reference directories live there and are never reviewed:

- `companion-module-template-js/` — JavaScript module baseline
- `companion-module-template-ts/` — TypeScript module baseline

---

## Review Workflow

### 1. Set Up a Module for Review

```powershell
# Auto-select the oldest pending module and clone it:
pwsh scripts/bitfocus-setup-module.ps1

# Or target a specific module:
pwsh scripts/bitfocus-setup-module.ps1 -ModuleName allenheath-sq
```

### 2. Run the Review

Open GitHub Copilot CLI (`gh copilot`) and ask the team to review the module. The AI team (Mal, Wash, Kaylee, Zoe, Simon) each inspect their domain in parallel and produce a single assembled review report.

### 3. Deliver the Review

The assembled report is written to:
```
reviews/{module-name}/review-{module-name}-{tag}-{YYYY-MM-DD-HHmmss}.md
```

Share the report with the module maintainer. Once reviewed, remove the cloned module directory from `companion-modules-reviewing/`.

### 4. Clean Up

```powershell
# Remove all temporary module checkouts (preserves the two template folders):
pwsh scripts/cleanup-modules.ps1
```

---

## Review Checklist

A module is **approved** when all of the following pass:

| # | Check | Notes |
|---|-------|-------|
| 0 | `yarn install` runs clean | Always first |
| 1 | `yarn package` succeeds and produces a `.tgz` | Build gate |
| 2 | No `package-lock.json` | Only `yarn.lock` allowed |
| 3 | Template compliance | File structure matches JS or TS template |
| 4 | SDK version | `@companion-module/base` on a supported version |
| 5 | Protocol implementation | Connect/disconnect/reconnect/error lifecycle handled correctly |
| 6 | Actions / Feedbacks / Presets | Properly typed, labelled, and structured |
| 7 | Error handling | `try/catch` on async calls, no silent failures |
| 8 | Performance | No busy-loops, appropriate debouncing, no memory leaks |
| 9 | Lint | `yarn lint` passes (or linter absent — noted) |
| 10 | Tests | Jest/Vitest tests pass if present (absence acceptable but noted) |

Findings use severity order: 🔴 Critical → 🟠 High → 🟡 Medium → 🟢 Low → 💡 Nice to Have → 🔮 Next Release → ✅ What's Solid

---

## AI Team

| Name   | Role                  | Responsibility |
|--------|-----------------------|----------------|
| Mal    | Lead                  | Architecture review, SDK patterns, code quality gates, final sign-off |
| Wash   | Protocol Specialist   | TCP/UDP/OSC/HTTP/Bonjour implementations, connection lifecycle |
| Kaylee | Module Dev Reviewer   | Template compliance, actions/feedbacks/presets/variables, yarn build |
| Zoe    | QA Reviewer           | Bugs, edge cases, error handling, performance, test coverage |
| Simon  | Test Runner           | Jest detection & execution, test validity & missing coverage |
| Scribe | (silent)              | Session logs, decisions |
| Ralph  | Work Monitor          | Queue management, backlog tracking |

---

## Skills Index

Skills are knowledge documents that agents read before performing specific tasks. They are organized into two locations:

- **`.squad/skills/`** — Project-level skills (companion review domain)
- **`.copilot/skills/`** — AI team operational skills (squad infrastructure)

### 🔧 Companion Module Skills

These skills teach the AI team the Companion SDK patterns, file structures, and API compliance rules needed to review modules correctly.

| Skill | Purpose |
|-------|---------|
| `companion-actions` | Reference for `CompanionActionDefinition` API — action callbacks, options, subscribe/unsubscribe lifecycle |
| `companion-action-file-pattern` | Multi-file action pattern: how to create a new action category file and wire it into a `GetActions` aggregator |
| `companion-add-action-to-category-file` | How to extend an existing `src/actions/action-{category}.ts` with new actions |
| `companion-feedbacks` | Reference for `CompanionFeedbackDefinition` API — boolean vs advanced feedbacks, button color/graphics, subscribe lifecycle |
| `companion-feedback-file-pattern` | How to create a new `src/feedbacks/feedback-{category}.ts` file and wire it into the aggregator |
| `companion-add-feedback-to-category-file` | How to extend an existing feedback category file with new feedbacks |
| `companion-preset-category-file` | Enum-based preset category file pattern — create `src/presets/preset-{category}.ts` and wire into `presets.ts` |
| `companion-add-preset-to-category-file` | How to add presets to an existing enum-based preset category file |
| `companion-config` | Reference for module config fields — field types, regex validation, `configUpdated` lifecycle |
| `companion-variable-definition` | How to register variables with `setVariableDefinitions` and `CompanionVariableDefinition` |
| `companion-variable-set-value` | How to update variable values with `setVariableValues()` and read them with `getVariableValue()` |
| `companion-upgrades` | Reference for `CompanionStaticUpgradeScript` — migrate user data across breaking changes |
| `companion-template-compliance` | Full checklist for verifying a module matches the official JS or TS template (files, `package.json`, `manifest.json`, `HELP.md`, husky hooks) |
| `companion-v1-api-compliance` | Compliance checklist for modules on `@companion-module/base` v1.x |
| `companion-v2-api-compliance` | Compliance checklist for modules on `@companion-module/base` v2.0 |
| `companion-bitfocus-dashboard` | BitFocus developer portal API — fetch pending queue, look up previous approved tags, derive GitHub repo URLs, auto-clone workflow |
| `osc-integration` | OSC UDP/TCP patterns using the `osc` npm package — send/receive, action handlers, module lifecycle wiring |

### 📋 Review Process Skills

| Skill | Purpose |
|-------|---------|
| `review-scorecard` | Standard scorecard and table of contents format for the assembled review file — issue counts by severity with New vs. Existing columns |
| `review-auto-fix` | Auto-fix branch workflow — after a review, create a fix branch inside the module repo and commit each fix individually (no PR opened) |

### 🤖 AI Team Operational Skills

These skills govern how the Squad AI team itself operates — model selection, collaboration patterns, and infrastructure.

| Skill | Purpose |
|-------|---------|
| `agent-collaboration` | Standard collaboration patterns for all agents — worktree awareness, decisions drop-box, cross-agent communication |
| `agent-conduct` | Hard behavioral rules enforced across all agents |
| `architectural-proposals` | How to write comprehensive architectural proposals that drive alignment before code is written |
| `ci-validation-gates` | Defensive CI/CD patterns: semver validation, token checks, retry logic, draft detection |
| `client-compatibility` | Platform detection for CLI vs VS Code vs other surfaces — adaptive spawning behavior |
| `cross-squad` | Coordinating work across multiple Squad instances |
| `distributed-mesh` | Coordinating with squads on different machines using git as transport |
| `docs-standards` | Microsoft Style Guide + Squad-specific documentation patterns |
| `economy-mode` | Shifts model selection to cost-optimized alternatives when economy mode is active |
| `external-comms` | PAO workflow for scanning, drafting, and presenting community responses with human review gate |
| `gh-auth-isolation` | Safely managing multiple GitHub identities (EMU + personal) in agent workflows |
| `git-workflow` | Squad branching model: dev-first workflow with insiders preview channel |
| `github-multi-account` | Detect and set up account-locked `gh` aliases for multi-account GitHub environments |
| `history-hygiene` | Rules for recording to `history.md` — final outcomes only, no intermediate or reversed decisions |
| `humanizer` | Tone enforcement patterns for external-facing community responses |
| `init-mode` | Team initialization flow: Phase 1 proposal + Phase 2 creation |
| `make-skill-template` | Scaffold a new skill — generates `SKILL.md` with proper frontmatter and directory structure |
| `model-selection` | Per-agent model selection algorithm — 4-layer hierarchy from config overrides to task-aware auto-selection |
| `nap` | Context hygiene — compress, prune, and archive `.squad/` state when context windows grow large |
| `personal-squad` | Personal agent discovery — user-level agents that travel across projects in read-only consult mode |
| `project-conventions` | Core conventions and patterns for this codebase |
| `release-process` | Step-by-step release checklist for Squad — prevents common release mistakes |
| `reskill` | Team-wide charter and history optimization through skill extraction |
| `reviewer-protocol` | Reviewer rejection workflow and strict lockout semantics |
| `secret-handling` | Never read `.env` files or write secrets to committed `.squad/` files |
| `session-recovery` | Find and resume interrupted Copilot CLI sessions using session store queries |
| `squad-conventions` | Core conventions and patterns used in the Squad codebase |
| `test-discipline` | Update tests when changing APIs — no exceptions |
| `windows-compatibility` | Cross-platform path handling and command patterns for Windows/macOS/Linux agents |

---

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/bitfocus-setup-module.ps1` | Fetch the BitFocus pending queue, validate the target module status, look up the previous approved tag, and clone the repo into the workspace |
| `scripts/bitfocus-queue.ps1` | List all modules currently pending review from the BitFocus API |
| `scripts/cleanup-modules.ps1` | Remove all `companion-module-*` directories from `companion-modules-reviewing/` except the two template folders |

---

## Security Notes

- The team **never writes to GitHub** (no PR comments, issue comments, release notes) or the BitFocus API (no POST/PUT/PATCH/DELETE calls)
- No secrets or tokens are stored in this repository
- `.copilot/mcp-config.json` contains an example-only entry using `${GITHUB_TOKEN}` as a placeholder — not a real credential
