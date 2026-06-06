---
description: Review a Bitfocus Companion module (next pending, or the one you name) and produce a ranked review report. Report-only.
argument-hint: "[module-name]   (omit to review the next pending module)"
---

Review a Bitfocus Companion module using the **review-companion-module** skill.

Target: $ARGUMENTS

- If a module name is given above, review that module (strip any `companion-module-` prefix).
- If it's empty, review the **next pending** module (the skill runs `bitfocus-queue.ps1` and picks the dedup-aware "Next up").

Follow the skill's ordered pipeline exactly (queue → setup → fact sheet → validate-template → parallel review subagents → assemble the review + TRACKER row). This is **report-only**: do not modify the module, create fix branches, or push to its repo. When done, tell me the review file path, the verdict, and the blocking count.
