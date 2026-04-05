---
name: 'project-conventions'
description: 'Core conventions and file layout for the companion-module-review project. Read this before writing any output files.'
domain: 'project-conventions'
confidence: 'high'
source: 'lyn'
---

## Context

This is the `companion-module-review` repository — an AI-assisted review system for BitFocus Companion modules. The team reviews modules submitted to the BitFocus developer portal and writes structured review reports.

**Review repo root:** `/Users/lynbh/Development/companion-module-review/`  
**Module clones root:** `/Users/lynbh/Development/companion-modules-reviewing/`

---

## ⚠️ CRITICAL: Review File Output Location

**All final assembled review files MUST be written to the `reviews/` directory inside the review repo — NOT to the module's own folder.**

### Correct path pattern

```
{REVIEW_REPO}/reviews/{short-module-name}/review-{short-module-name}-{version}-{YYYYMMDD}-{HHmmss}.md
```

Where `{short-module-name}` is the module folder name **with the `companion-module-` prefix stripped**.

### Examples

| Module folder | Version | Correct output path |
|---|---|---|
| `companion-module-panasonic-ak-hrp1000` | v1.0.1 | `reviews/panasonic-ak-hrp1000/review-panasonic-ak-hrp1000-v1.0.1-20260405-070000.md` |
| `companion-module-spacecommz-intercom` | v1.1.0 | `reviews/spacecommz-intercom/review-spacecommz-intercom-v1.1.0-20260405-060928.md` |
| `companion-module-red-rcp2` | v1.4.6 | `reviews/red-rcp2/review-red-rcp2-v1.4.6-20260405-065528.md` |

### How to derive the timestamp

```bash
date -u +"%Y%m%d-%H%M%S"
```

### How to create the directory if it doesn't exist

```bash
mkdir -p {REVIEW_REPO}/reviews/{short-module-name}/
```

### ❌ Anti-pattern — DO NOT write to the module folder

```
# WRONG — never write review files here:
/Users/lynbh/Development/companion-modules-reviewing/companion-module-panasonic-ak-hrp1000/review-*.md
```

---

## File Structure

```
companion-module-review/
├── reviews/                          ← ALL review output files live here
│   ├── panasonic-ak-hrp1000/
│   │   └── review-panasonic-ak-hrp1000-v1.0.0-20260404-185852.md
│   ├── spacecommz-intercom/
│   │   └── review-spacecommz-intercom-v1.1.0-20260405-060928.md
│   └── ...
├── scripts/                          ← PowerShell helper scripts
│   ├── bitfocus-queue.ps1            ← Lists pending modules from BitFocus API
│   └── bitfocus-setup-module.ps1     ← Gets authoritative previous approved tag
└── .squad/                           ← Team state (decisions, charters, skills)
    ├── decisions/
    │   ├── decisions.md              ← Canonical decision ledger
    │   └── inbox/                    ← Drop-box for agent findings (gitignored)
    ├── skills/                       ← Reusable team knowledge
    └── agents/                       ← Per-agent charters and history
```

---

## Review File Naming

- **Filename:** `review-{short-module-name}-{version}-{YYYYMMDD}-{HHmmss}.md`
- **Version:** Include the `v` prefix (e.g., `v1.0.1`, not `1.0.1`)
- **Timestamp:** UTC, format `YYYYMMDD-HHmmss`
- **Directory:** Create `reviews/{short-module-name}/` if it doesn't exist

---

## Agent Inbox Drop-Box

Agent findings are written to `.squad/decisions/inbox/{agent}-{module-slug}-findings.md` (gitignored — local only). Scribe merges these into `decisions.md` and deletes inbox files after each review.

---

## Process Directives

- **DO NOT push fix branches or create PRs without human approval** — Lyn (the user) reviews all output manually before any push or PR
- **DO NOT auto-commit review output files** — write them, let Lyn review first
- Module reviews run **serially** — complete one module (all agents + assembly + Scribe) before starting the next
- PR titles must use plain human terms — no internal finding IDs (C1, H1, etc.)
