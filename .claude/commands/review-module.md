---
description: Review a Bitfocus Companion module (next pending, or one you name) at a chosen scope and produce a ranked review report. Report-only.
argument-hint: "[module-name] [tag|module|both]   (defaults: next pending module, tag scope)"
---

Review a Bitfocus Companion module using the **review-companion-module** skill.

Arguments: $ARGUMENTS

Interpret the arguments:
- If an argument is exactly `tag`, `module`, or `both`, it is the **scope**.
- Any other argument is the **module name** (strip any `companion-module-` prefix).
- Missing module name → review the **next pending** module (the skill runs `bitfocus-queue.ps1` and picks the dedup-aware "Next up").
- Missing scope → default **`tag`** (only this release's changes).

Scopes: `tag` = only the `previousTag..reviewTag` diff (new/regression only); `module` = the whole current module, flat by severity; `both` = whole module classified new vs pre-existing.

Follow the skill's ordered pipeline (queue → setup → fact sheet → validate-template → parallel review subagents → assemble the review + TRACKER row). This is **report-only**: do not modify the module, create fix branches, or push to its repo. When done, tell me the review file path, the scope, the verdict, and the blocking count.
