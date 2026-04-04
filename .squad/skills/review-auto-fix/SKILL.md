---
name: review-auto-fix
description: 'Defines the auto-fix branch workflow for Companion module reviews. Use after a review is finalized to create a fix branch inside the module repo, implement each fix as an individual commit, and add missing template files as a single commit. Never opens a PR — the branch is for human review before merging.'
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

## No PR

After committing all fixes, push the branch:

```bash
git push origin fix/v{version}-{YYYY-MM-DD}-issues
```

**Do NOT open a PR.** The branch exists for the maintainer (or reviewer) to inspect before deciding whether to merge, open a PR to upstream, or request further changes.

---

## Agent Responsibilities

| Agent | Auto-fix scope |
|-------|----------------|
| **Kaylee** | Code fixes: actions, feedbacks, presets, variables, lifecycle methods, `package.json`, `companion/manifest.json`, template compliance (file moves, missing files, script renames) |
| **Wash** | Protocol/network fixes: socket lifecycle, connection error handling, `InstanceStatus` transitions, HTTP client patterns, Bonjour cleanup |
| **Mal** | Coordinates which issues to fix; verifies no regressions are introduced; reviews fix commits before push |

---

## Post-Fix Summary

After all commits are made and the branch is pushed, report:

```
🔧 Fix branch created: fix/v{version}-{YYYY-MM-DD}-issues

Commits:
  fix(C1): replace clearIdleTimer() with clearKeepalive() in connectezw action
  fix(M1): update manifest.json version from 2.0.2 to 2.1.0
  chore: apply template compliance fixes

Branch pushed to origin. No PR opened — review manually before merging.
```
