---
description: Review a Bitfocus Companion module (next pending, or one you name) at a chosen scope and produce a ranked review report. Report-only.
argument-hint: "[module-name] [version] [tag|module|both]   (defaults: next pending module, oldest pending version, tag scope)"
---

Review a Bitfocus Companion module using the **review-companion-module** skill.

Arguments: $ARGUMENTS

Interpret the arguments:
- If an argument is exactly `tag`, `module`, or `both`, it is the **scope**.
- If an argument matches a version pattern (`^v?\d+\.\d+`, e.g. `v2.1.0` or `2.1.0`), it is the **version** to review — pass it to the skill as the review tag. A version requires a module name; if it isn't pending for that module, the run errors and lists the pending versions.
- Any other argument is the **module name** (strip any `companion-module-` prefix). Module names like `panasonic-ak-hrp1000` don't match the version pattern.
- Missing module name → review the **next pending** module (the skill runs `bitfocus-queue.ps1` and picks the dedup-aware "Next up").
- Missing version → review the **oldest** pending version of the module.
- Missing scope → default **`tag`** (only this release's changes).

Scopes: `tag` = only the `previousTag..reviewTag` diff (new/regression only); `module` = the whole current module, flat by severity; `both` = whole module classified new vs pre-existing.

Follow the skill's ordered pipeline (queue → setup → fact sheet → validate-template → parallel review subagents → assemble the review + TRACKER row). This is **report-only**: do not modify the module, create fix branches, or push to its repo. When done, tell me the review file path, the scope, the verdict, and the blocking count.
