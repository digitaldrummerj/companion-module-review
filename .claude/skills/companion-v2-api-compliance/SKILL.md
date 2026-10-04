---
name: companion-v2-api-compliance
description: Version-gated compliance checks for Companion modules on @companion-module/base v2.x (API 2.0 → Companion 4.3+, API 2.1 → Companion 5.0+) — class-based export, removed runEntrypoint/parseVariablesInString, setVariableDefinitions object form, checkAllFeedbacks, manifest type connection, plus 2.1 deltas. Applies only the rules for the module's resolved version (from the module-facts fact sheet), so a 2.0 module is never asked for 2.1-only features. Use only when @companion-module/base resolves to 2.x. For 1.x modules use companion-v1-api-compliance instead.
---

# Skill: Companion Module API v2.x Compliance

## Purpose

Review a Companion module **against the API version it actually uses**. Developers choose which minor version to target. A 2.0 module that runs on Companion 4.3 is correct even when it does not use 2.1 features, so this skill must never call that out as a defect.

The detailed rules are kept in one reference file per minor version. Load only the files that apply:

| File | Load when |
|---|---|
| `references/v2.0.md` | Always, for any 2.x module (it is the baseline every 2.x module must meet) |
| `references/v2.1.md` | Only when the resolved base version is **≥ 2.1.0** |

> Future minor versions (2.2, 2.3, …) get their own `references/v2.N.md` containing **only** that version's deltas. Each one is loaded only when the module's version is at least that version.

---

## Step 1 — Resolve the installed `@companion-module/base` version

**In this repo the fact sheet already did this.** `scripts/module-facts.ps1` resolves the version with the same rules and hands you:

| Fact-sheet field | Use |
|---|---|
| `apiLevel` | `2.0`, `2.1`, … — the rule set to apply |
| `baseVersion` / `baseVersionSource` | e.g. `2.1.3` from `yarn.lock` — state this at the top of your findings |
| `apiAmbiguous` | `true` when only a caret range was available — add the 🟡 "pin the version" note below |
| `minCompanion` | the Companion version the module requires (4.3 for 2.0, 5.0 for 2.1) |
| `apiReferences` | the exact reference files to load, relative to this skill's directory (e.g. `references/v2.0.md`, `references/v2.1.md`) |
| `apiScan` | deterministic hints from `scripts/api-scan.ps1` — see "Deterministic hints" below |

Load **only** the files listed in `apiReferences`. Resolve the version yourself (rules below) **only** if the fact sheet is missing those fields.

Fallback — use the first source that gives an exact version:

1. `yarn.lock`:
   - Yarn 2+ (Berry): the `"@companion-module/base@npm:…"` entry → its `version:` line
   - Yarn 1: the `"@companion-module/base@…":` entry → its `version "…"` line
2. `package-lock.json`: `packages["node_modules/@companion-module/base"].version`
3. `pnpm-lock.yaml`: the `@companion-module/base` entry under `importers`/`packages` → its resolved version
4. `node_modules/@companion-module/base/package.json` → `version` (only if `node_modules` exists)
5. **Fallback:** the value in `package.json` `dependencies["@companion-module/base"]`
   - an exact version (`2.0.4`, `2.1.3`) → that version
   - `~2.0.x` / `2.0.x` → treat as **2.0**
   - `~2.1.x` / `2.1.x` → treat as **2.1**
   - `^2.0.0` or another range that spans minors is **ambiguous**. Treat it as the **lowest** version the range allows (2.0) and add a 🟡 note: "Pin `@companion-module/base` with `~2.N.x` (or commit the lockfile) so the target API version is explicit."

| Resolved version | Rules to apply |
|---|---|
| `1.x` | Stop. Use **companion-v1-api-compliance** instead. |
| `2.0.x` | `references/v2.0.md` only |
| `2.1.x` | `references/v2.0.md` + `references/v2.1.md` |
| `≥ 2.2` | v2.0 + v2.1 + any newer `references/v2.N.md` that exists. If a newer version has no reference file, say so in the report and review only against the files that exist. |

State the resolved version and its source at the top of the review, e.g. "Base 2.1.3 (from yarn.lock) → API 2.1 rules, Companion 5.0+".

### Deterministic hints (`apiScan`)

`scripts/api-scan.ps1` greps the module for version-specific patterns and the fact sheet carries the hits as `apiScan`. They are **leads to verify, never findings on their own** — open each `file:line`, confirm it is real code (not a comment, string or dead branch) and applies to this module's version, then report it with the severity from the reference file.

| Hint id | Applies to | Check against |
|---|---|---|
| `V1-RUNENTRYPOINT`, `V1-PARSEVARIABLES`, `V1-CHECKFEEDBACKS-NOARGS`, `V1-VARDEFS-ARRAY`, `V1-ISVISIBLE-FN`, `V1-OPTIONS-IGNORE`, `V1-PRESET-BUTTON-CATEGORY`, `V1-PRESETS-SINGLE-ARG`, `V1-REQUIRED`, `V1-INPUTVALUE`, `V1-RELATIVEDELAY` | any 2.x | `references/v2.0.md` (removed APIs, High table) |
| `LATER-API-2.1` | 2.0.x only | `references/v2.0.md` → "Uses features from a later API version" |
| `ADV-FEEDBACK-NO-AFFECTED`, `SUBSCRIBE-NO-MONITOR`, `SETCUSTOMVAR-DEPRECATED` | ≥ 2.1 | `references/v2.1.md` |
| `BOOL-FEEDBACK-HELPER-BUG`, `HELPER-SEND-AWAIT` | 2.x (bug/behaviour notes) | `references/v2.0.md` High table |

An empty `apiScan` does not mean the module is compliant — the scan only covers patterns a grep can see.

---

## Step 2 — Gating rules (avoid false positives)

- **Never** report a missing feature from a later minor version as a required change. That covers `affectedProperties`, `context.signal`, `hasResult`, layered or alternatives presets, `internal:*` preset entries, `node26`, and so on for a 2.0.x module.
- At most, add **one** consolidated line at the end: "💡 Available if you upgrade to 2.1 (Companion 5.0+): …". It lists the features that would clearly help *this* module, and it never adds to the required-change count.
- Usage that **needs** a later version **is** a defect. For 2.0.x modules the full list is in `references/v2.0.md` → "Uses features from a later API version". Examples:
  - a 2.0.x module that uses `hasResult`, `context.signal`, `affectedProperties`, preset `type: 'layered'`/`'alternatives'`, `internal:*` action/feedback ids inside preset steps, feedback-type preset local variables, or `runtime.type: "node26"`
  - Report it as 🔴. It will either fail to typecheck or Companion will drop or ignore it. The fix is either to bump base to `~2.1.x` (and accept the Companion 5.0+ requirement) or to remove the usage.
- Changes to typings within a version also count. At base 2.1.3, an advanced feedback without `affectedProperties`, or an action with `subscribe` but no `optionsToMonitorForSubscribe`, is a compile error, so it is 🔴 for 2.1 modules only.

---

## Step 3 — Review and report

Work through each loaded reference file. Group findings by severity, and give `file:line` for every finding:

| Severity | Meaning |
|---|---|
| 🔴 Critical | Module won't build or load, or risks data loss: removed API, wrong entrypoint or manifest, typecheck failure, or an upgrade script that corrupts user options |
| 🟠 High | Breaking-API misuse that Companion tolerates but that misbehaves, e.g. a learn callback that overwrites expressions, or a missing `optionsToMonitorForSubscribe` on 2.0 |
| 🟡 Medium | Recommended practice for the module's version: friendly dropdown ids, `number` instead of numeric `textinput`, `createModuleLogger` |
| 💡 Info | The single "available if you upgrade" line, plus optional polish |

For each finding, include **what** is wrong, **why** it matters for this version, and **the fix**. Point to the skill that implements the fix:

| Fix area | Skill |
|---|---|
| Project setup, manifest, tsconfig, entrypoint | **companion-v2-module-scaffold** |
| Actions | **companion-v2-add-action-to-category-file** (existing file), **companion-v2-action-file-pattern** (new category), **companion-v2-actions** (API reference) |
| Feedbacks | **companion-v2-add-feedback-to-category-file** (existing file), **companion-v2-feedback-file-pattern** (new category), **companion-v2-feedbacks** (API reference) |
| Presets | **companion-v2-add-preset-to-category-file** (existing file), **companion-v2-preset-category-file** (new category) |
| Variables | **companion-v2-variable-definition**, **companion-v2-variable-set-value** |
| Config and secrets | **companion-v2-config** |
| Upgrade scripts | **companion-v2-upgrades** |
| Leftover v1 code in a partially migrated module | **companion-v1-to-v2-migration**, **companion-v1-to-v2-migrate-definitions**, **companion-v1-to-v2-migrate-presets**, **companion-v1-to-v2-expression-upgrades** |

End the report with: resolved version, rule files applied, counts per severity, and the optional 💡 upgrade line.

---

## References

- [v2.0 API Changes](https://companion.free/for-developers/module-development/api-changes/v2.0) (Companion 4.3+)
- [v2.1 API Changes](https://companion.free/for-developers/module-development/api-changes/v2.1) (Companion 5.0+)
- [All API Changes](https://companion.free/for-developers/module-development/api-changes/)
- [Presets](https://companion.free/for-developers/module-development/connection-basics/presets)
- **companion-v1-api-compliance**: for modules on `@companion-module/base` 1.x
