### 2026-04-09T20:50:37Z: User directive
**By:** Lyn (via Copilot)
**What:** Never commit `diff_output.txt` (or any `diff*.txt` scratch files) to the module repo. These are local analysis artifacts generated during review prep and must not appear in any commit or PR branch.
**Why:** User request — captured after `diff_output.txt` was accidentally staged and committed alongside a fix commit in companion-module-generic-websocket. Captured for team memory to prevent recurrence.
