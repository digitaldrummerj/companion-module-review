---
name: review-scorecard
description: 'Defines the standard scorecard and table of contents format for Companion module reviews. Use when assembling the final review file to generate the 📊 Scorecard section (issue counts by severity with New vs. Existing columns) and 📋 Table of Contents section (clickable anchor links to each finding).'
---

# Review Scorecard & Table of Contents

Defines the standard format for the two sections inserted immediately after the Verdict in every assembled review.

## When to Use This Skill

- When assembling the final review file from all agents' findings
- When computing New vs. Existing issue counts per severity level
- When generating a Table of Contents with anchor links to each finding
- When a review needs retroactive formatting

---

## Section 1: 📊 Scorecard

Insert this section immediately after the Verdict section.

### Issue Counting Rules

**Column definitions:**
- **🆕 New** — findings classified as `🆕 NEW` or `🔙 REGRESSION` anywhere in the review
- **⚠️ Existing** — findings classified as `⚠️ PRE-EXISTING` anywhere in the review, including items in the `## ⚠️ Pre-existing Notes` table
- **Total** — sum of New + Existing for that severity row

**Severity rows to include:** Always include Critical through Low. Include "Nice to Have" only if there are findings at that level.

**Blocking count:** Count all findings in the `## 🔴 Critical` and `## 🟠 High` main sections. Pre-existing issues in those main sections still block per review policy. Do NOT count the `⚠️ Pre-existing Notes` table entries as blocking — those are explicitly non-blocking.

**Fix complexity:** Estimate based on the blocking issues only:
- **Quick** — all blocking fixes are one-liners or simple substitutions
- **Medium** — blocking fixes require logic changes or new code (< 50 lines total)
- **Complex** — blocking fixes require architectural changes, file moves, or significant new code

**Health delta:** State how many issues were introduced in this release vs. how many pre-existing issues were surfaced:
- "0 introduced · 3 pre-existing surfaced" — release added nothing new, but old issues were found
- "7 introduced · 9 pre-existing noted" — release introduced new issues, with pre-existing also noted
- "2 introduced · 0 pre-existing" — clean pre-existing record, but this release added issues

### Scorecard Template

```markdown
## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | {n} | {n} | {n} |
| 🟠 High | {n} | {n} | {n} |
| 🟡 Medium | {n} | {n} | {n} |
| 🟢 Low | {n} | {n} | {n} |
| 💡 Nice to Have | {n} | {n} | {n} |
| **Total** | **{n}** | **{n}** | **{n}** |

**Blocking:** {n} issue(s) ({brief description — e.g., "1 new critical"})  
**Fix complexity:** {Quick / Medium / Complex} — {one-line description}  
**Health delta:** {n} introduced · {n} pre-existing {surfaced/noted}  
```

Omit the "Nice to Have" row if there are no findings at that level.

### Example — REJECTED with pre-existing blocking issues

```markdown
## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 3 | 3 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 1 | 0 | 1 |
| 💡 Nice to Have | 1 | 0 | 1 |
| **Total** | **2** | **3** | **5** |

**Blocking:** 3 issues (3 pre-existing high)  
**Fix complexity:** Quick — three one-line fixes  
**Health delta:** 2 introduced · 3 pre-existing surfaced  
```

### Example — REJECTED with new critical issue

```markdown
## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 1 | 0 | 1 |
| 🟠 High | 0 | 2 | 2 |
| 🟡 Medium | 3 | 3 | 6 |
| 🟢 Low | 3 | 4 | 7 |
| **Total** | **7** | **9** | **16** |

**Blocking:** 1 issue (1 new critical)  
**Fix complexity:** Quick — one-line fix required  
**Health delta:** 7 introduced · 9 pre-existing noted  
```

---

## Section 2: 📋 Table of Contents

Insert this section immediately after the Scorecard section.

### TOC Rules

- **Include every finding** with a heading in the main review body (Critical through Nice to Have sections)
- **Group as Blocking / Non-blocking** — Blocking = items from `🔴 Critical` and `🟠 High` main sections; Non-blocking = everything else
- **Omit** the Pre-existing Notes table entries — they don't have individual headings to link to
- If there are no blocking issues, omit the **Blocking** group header (or write `*(none)*`)
- If there are no non-blocking issues, omit the **Non-blocking** group header

### Anchor Generation (GitHub Markdown Rules)

To generate the anchor for a heading:
1. Lowercase the entire heading text
2. Remove everything that is NOT: letters, digits, spaces, hyphens
3. Replace spaces with hyphens
4. Backtick content keeps its inner text (backticks themselves are removed)
5. Emoji characters are removed
6. Special characters removed: `:` `(` `)` `—` `.` `@` `/` `'` `` ` `` `!` `?` `⚠️`

### Anchor Examples

| Heading | Anchor |
|---------|--------|
| `### C1: \`clearIdleTimer()\` called in Reconnect action — method does not exist` | `#c1-clearidletimer-called-in-reconnect-action--method-does-not-exist` |
| `### H1: EventSource not closed in \`destroy()\` ⚠️ Pre-existing (v1.0.2)` | `#h1-eventsource-not-closed-in-destroy--pre-existing-v102` |
| `### M3: \`@companion-module/base\` version doesn't satisfy peer dependency` | `#m3-companion-modulebase-version-doesnt-satisfy-peer-dependency` |
| `### L1: Build script \`rimraf dist\` removal may leave stale files` | `#l1-build-script-rimraf-dist-removal-may-leave-stale-files` |
| `### N1: Unused import in \`upgrades.ts\`` | `#n1-unused-import-in-upgradests` |

### TOC Template

```markdown
## 📋 Table of Contents

**Blocking**
- [C1: Issue title here](#c1-anchor-here)
- [H1: Issue title here](#h1-anchor-here)

**Non-blocking**
- [M1: Issue title here](#m1-anchor-here)
- [L1: Issue title here](#l1-anchor-here)
- [N1: Issue title here](#n1-anchor-here)
```

---

## Updated Section Order in Assembled Review

1. Title + meta header
2. **Verdict**
3. **📊 Scorecard** ← this skill
4. **📋 Table of Contents** ← this skill
5. 🔴 Critical
6. 🟠 High
7. 🟡 Medium
8. 🟢 Low
9. 💡 Nice to Have
10. 🔮 Next Release
11. ⚠️ Pre-existing Notes
12. 🧪 Tests
13. ✅ What's Solid
14. Fix Summary for Maintainer

Omit any section that has no findings.
