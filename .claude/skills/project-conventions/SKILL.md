---
name: project-conventions
description: 'Core conventions and file layout for the companion-module-review project. Read this before writing any review output files.'
---

## Context

This is the `companion-module-review` repository — a Claude Code review system for BitFocus Companion modules. It reviews modules submitted to the BitFocus developer portal and writes structured review reports. It is **report-only** (see Process Directives).

- **Review repo root:** this repository.
- **Module clones:** `companion-modules-reviewing/` inside this repo (gitignored).
- **Templates:** `companion-module-templates/` inside this repo (gitignored).

---

## ⚠️ CRITICAL: Review File Output Location

**All assembled review files MUST be written to the `reviews/` directory inside this repo — NOT to the module's own folder.**

```
reviews/{short-module-name}/review-{short-module-name}-{version}-{YYYYMMDD}-{HHmmss}.md
```

`{short-module-name}` = the module folder name with the `companion-module-` prefix stripped.

| Module folder | Version | Correct output path |
|---|---|---|
| `companion-module-panasonic-ak-hrp1000` | v1.0.1 | `reviews/panasonic-ak-hrp1000/review-panasonic-ak-hrp1000-v1.0.1-20260405-070000.md` |
| `companion-module-red-rcp2` | v1.4.6 | `reviews/red-rcp2/review-red-rcp2-v1.4.6-20260405-065528.md` |

Timestamp: `date -u +"%Y%m%d-%H%M%S"`. Create the dir first: `mkdir -p reviews/{short-module-name}/`.

**❌ Never** write a review file inside the module clone (`companion-modules-reviewing/companion-module-*/`).

---

## Review File Naming

- **Filename:** `review-{short-module-name}-{version}-{YYYYMMDD}-{HHmmss}.md`
- **Version:** include the `v` prefix (e.g. `v1.0.1`).
- **Timestamp:** UTC, `YYYYMMDD-HHmmss`.

---

## Process Directives

- **Reviews are report-only** — never modify module code, create fix branches, or push to a module's repo. The only output is the review markdown. The maintainer applies the fixes.
- **Do NOT auto-commit review output files** — write them, let the user review first; the user pushes the review to *this* repo and delivers it to the maintainer.
- Module reviews run **one at a time** — complete one module (all reviewers + assembly + tracker) before starting the next.

---

## ✅ Tracker Update (required at review completion)

After writing the review file, add a row to `reviews/TRACKER.md` (bottom of the table):

```markdown
| ⬜ | {short-module-name} | {version} | {YYYY-MM-DD} | [review]({short-module-name}/review-{short-module-name}-{version}-{timestamp}.md) |
```

- `⬜` = feedback not yet submitted to the maintainer (default; the user changes it to ✅ after delivering).
- `{YYYY-MM-DD}` = review date (UTC); the link path is relative to `reviews/`.
- On a re-review (new version), **add a new row** — don't edit or remove the existing entry.
