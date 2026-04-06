---
name: review-auto-fix
description: 'Defines the auto-fix branch workflow for Companion module reviews. Use after a review is finalized to create a fix branch inside the module repo, implement each fix as an individual commit, and add missing template files as a single commit. The branch is NOT pushed and NO PR is opened until a human reviews the changes and says to proceed.'
---

# Review Auto-Fix Workflow

After a review is assembled and the final review file is committed to the review repo, the team creates a fix branch inside the **module's own git repo** and implements the identified fixes as individual commits.

---

## Key Rule: Work Inside the Module Repo

The module repos (e.g., `companion-module-softouch-easyworship/`, `companion-module-autodirector-mirusuite/`) live in the **`companion-modules-reviewing/`** sibling directory next to the review repo. They are **independent git repositories**. All git operations for the fix branch — `git checkout`, `git add`, `git commit`, `git push` — happen **inside the module folder**.

```
~/Development/
├── companion-module-review/                         ← review repo (untouched by auto-fix)
│   ├── reviews/
│   └── .squad/
└── companion-modules-reviewing/
    ├── companion-module-softouch-easyworship/       ← fix branch created HERE
    │   └── (independent git repo)
    └── companion-module-autodirector-mirusuite/     ← fix branch created HERE
        └── (independent git repo)
```

---

## Branch Setup

### Naming convention

```
fix/v{version}-{YYYY-MM-DD}-issues
```

Examples:
- `fix/v2.1.0-2026-04-02-issues` — inside `../companion-modules-reviewing/companion-module-softouch-easyworship/`
- `fix/v1.0.3-2026-04-02-issues` — inside `../companion-modules-reviewing/companion-module-autodirector-mirusuite/`

### Branch creation

```bash
# Navigate into the module repo
cd {module-folder}/

# For repos on main:
git checkout -b fix/v{version}-{YYYY-MM-DD}-issues

# For detached-HEAD repos (e.g., checked out at tag v1.0.3):
git checkout main
git checkout -b fix/v{version}-{YYYY-MM-DD}-issues

# Or branch directly from the tag if main has diverged significantly:
git checkout -b fix/v{version}-{YYYY-MM-DD}-issues {tag}
```

---

## Commit Strategy

### Individual issue fixes — one commit per fix

Each blocking or new non-blocking issue gets its own commit:

```
fix({ID}): {short description of what was changed}
```

Examples:
- `fix(C1): replace clearIdleTimer() with clearKeepalive() in connectezw action`
- `fix(H1): call closeEventHandler() in destroy() to prevent SSE leak`
- `fix(H2): call closeEventHandler() before reinit in configUpdated()`
- `fix(H3): only set InstanceStatus.Ok on successful HTTP response path`
- `fix(M1): set manifest.json version to 0.0.0`
- `fix(M3): bump @companion-module/base to ^1.12.0 in package.json`

### Version bump — one commit, last on the branch

Every fix branch **must** end with a version bump commit before it is pushed. The maintainer will need to submit a new release, so the version must be incremented:

| File | Action |
|------|--------|
| `package.json` | Increment **patch version** (e.g., `2.1.0` → `2.1.1`) |
| `companion/manifest.json` | Set `"version"` to `"0.0.0"` (already required by manifest directive; do this in its own `fix` commit earlier) |

Commit message:
```
chore: bump version to {new_version} for next release
```

Example: `chore: bump version to 2.1.1 for next release`

This commit goes **after** all issue fix commits and any template compliance commits.

### Template and structural fixes — one commit for all

If fixes include any of the following, group them into a **single commit**:
- Moving source files from module root to `src/`
- Adding missing template files (`prettier.config.js`, `.eslintrc.js`, `HELP.md`, etc.)
- Renaming `package.json` scripts (e.g., `release` → `package`)
- Adding missing `package.json` fields (`engines`, `packageManager`, `license`)

Commit message:
```
chore: apply template compliance fixes

- Move source files from root to src/
- Rename 'release' script to 'package' in package.json
- Add missing prettier.config.js
- Add engines field to package.json
```

### Structural moves — use `git mv`

When moving source files to preserve git history:
```bash
git mv index.js src/main.js
git mv actions.js src/actions.js
# etc.
```
Update all import paths and the `main` field in `package.json` in the same commit.

---

## Scope of Fixes

| Category | Fix? |
|----------|------|
| 🔴 Critical — any source | ✅ Always attempt |
| 🟠 High — any source | ✅ Always attempt |
| 🟡 Medium — NEW or REGRESSION | ✅ Attempt if straightforward |
| 🟡 Medium — PRE-EXISTING (in main High/Medium sections) | ✅ Attempt if straightforward |
| 🟢 Low — NEW | ✅ Attempt if straightforward |
| Structural/template fixes (file moves, script renames, missing files) | ✅ Include |
| ⚠️ Pre-existing — template compliance (src/ structure, script renames, missing `package.json`/manifest fields) | ✅ Always include — module is being released anyway, clean it up |
| ⚠️ Pre-existing — logic, style, or content issues (notes table only) | ⏭️ Skip — leave for next release |

---

## Code Fix Format — Always Show Before AND After

When writing a review finding that includes a code fix, **always show both the current code and the proposed replacement**. Never show only the fix without the before state.

### Required format for every code-level finding:

````markdown
**Current code (`src/main.ts`, line N):**
```typescript
// what is there now
someFunction(oldArg)
```

**Fix:**
```typescript
// what it should be
someFunction(newArg, { timeout: 10_000 })
```
````

**Rules:**
- Include a `**Current code (`{file}`, line N):**` block before every fix block
- Show enough surrounding context (1–3 lines) to identify the exact location
- If the current code is an absence (e.g., a missing field), write `*(field absent)*` instead of a code block
- This applies to ALL severity levels: Critical, High, Medium, Low, and Nitpick

**Example — absence (missing field):**
````markdown
**Current code (`companion/manifest.json`):**
*(field absent)*

**Fix:** Add to `manifest.json`:
```json
"categories": ["utility"]
```
````

---

## Mark Fixed Issues in the Review File

After each fix commit is made in the module repo, **update the review markdown file** in the review repo to mark the fixed issue as done. This keeps the review file in sync with the work that has been done.

Find the corresponding line in the `## 📋 Issues` section of the review file and change `- [ ]` to `- [x]`:

```bash
# Example: marking H1 as fixed
# Before:  - [ ] [H1: EventSource not closed in `destroy()`](#h1-eventsource-not-closed-in-destroy)
# After:   - [x] [H1: EventSource not closed in `destroy()`](#h1-eventsource-not-closed-in-destroy)
```

Use `sed` (or equivalent) to make this change in-place, or edit the file directly. Mark each issue as done **as you go** — one checkbox per completed fix commit, not all at once at the end. This lets the review file accurately reflect partial progress if the auto-fix is interrupted.

After all fixes, commit the updated review file to the review repo:

```bash
# From inside the review repo
git add reviews/{module-name}/review-{...}.md
git commit -m "chore({module}): mark fixed issues in review checklist"
```

---

## No Push, No PR (module repo)

After committing all fixes, **do NOT push the fix branch** in the module repo. Leave it as a local branch.

The human reviewer will inspect the branch locally and decide whether to push and open a PR to upstream.

---

## When a Human Approves Push + PR

When the human reviewer says to go ahead, push the branch and open a PR:

> **Rule: Always use `-u` (or `--set-upstream`) on the first push of a fix branch.**
> Without it, the local branch has no upstream and subsequent `git push` commands fail
> with "no upstream branch". Using `-u` links the local branch to the remote so future
> pushes work normally.

```bash
# From inside the module repo
git push -u origin fix/v{version}-{YYYY-MM-DD}-issues
gh pr create --title "fixes: findings from the v{reviewed_version} module review" \
  --body "..." --base main
```

### PR Title Convention

The PR title MUST follow this exact format:

```
fixes: findings from the v{version} module review
```

- `{version}` is the **reviewed module version** (e.g., `v1.0.0`, `v2.1.0`) — the version that was audited, NOT the bumped version.
- **Never include internal finding IDs** (e.g., C1, H1, L2) in the PR title. Use plain human terms only.

**Good:** `fixes: findings from the v1.0.0 module review`
**Bad:** `fix: address review findings from v1.0.0 audit (C1, H1, L2)` ← contains IDs

---

## Agent Responsibilities

| Agent | Auto-fix scope |
|-------|----------------|
| **Kaylee** | Code fixes: actions, feedbacks, presets, variables, lifecycle methods, `package.json`, `companion/manifest.json`, template compliance (file moves, missing files, script renames) |
| **Wash** | Protocol/network fixes: socket lifecycle, connection error handling, `InstanceStatus` transitions, HTTP client patterns, Bonjour cleanup |
| **Mal** | Coordinates which issues to fix; verifies no regressions are introduced; reviews fix commits before push |

---

## Post-Fix Summary

After all commits are made (and the review file updated), report:

```
🔧 Fix branch created: fix/v{version}-{YYYY-MM-DD}-issues

Commits:
  fix(C1): replace clearIdleTimer() with clearKeepalive() in connectezw action
  fix(M1): update manifest.json version from 2.0.2 to 2.1.0
  chore: apply template compliance fixes

Review file updated: {N} issues marked done in reviews/{module}/review-{...}.md

Branch is local only — not pushed. Review manually before pushing or merging.
```
