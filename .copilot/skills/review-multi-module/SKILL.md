---
name: review-multi-module
confidence: high
description: 'Governs how to handle prompts that request reviews of multiple Companion modules at once. Always serial — one module at a time. Never parallel.'
---

# Multi-Module Review Sequencing

Defines the execution order when a single prompt asks for reviews of more than one Companion module.

## When to Use This Skill

- User provides 2+ module names or repo URLs in a single review request
- User says "review all of these" or "review X, Y, and Z"
- A batch of modules appears in a PRD, issue, or list

---

## Rule: Serial Execution — One Module at a Time

**Always review modules sequentially.** Do NOT fan out parallel full-review batches across multiple modules.

### Why

A full module review fans out ~5 agents (Lead + Protocol + Module Dev + QA + Tests). Each fan-out includes at least one premium-tier (opus) call for the Lead. Reviewing N modules in parallel = N × 5 concurrent agents, which risks hitting API rate limits.

### How

1. **Acknowledge the full list** upfront so the user knows what's queued.
2. **Complete one module's full review cycle** before starting the next — all agents, Scribe merge, verdict posted.
3. **Report completion** after each module: `"✅ {module-name} done — {verdict}. Starting {next-module-name}…"`
4. **Do not ask for permission** between modules — continue automatically until all are done.
5. **After all modules complete**, present a summary table with verdict and blocker count per module.

### Queue Format

When acknowledging a multi-module request, show the queue:

```
📋 Review queue (serial):
  1. {module-name}  ← starting now
  2. {module-name}
  3. {module-name}
```

### Summary Table (after all complete)

```
## Review Batch Summary

| Module | Verdict | Blockers | Fix Complexity |
|--------|---------|----------|----------------|
| {name} | ✅ APPROVED / ❌ REJECTED | {n} | Quick / Medium / Complex |
| {name} | ✅ APPROVED / ❌ REJECTED | {n} | Quick / Medium / Complex |
```

---

## Exception: Explicit Parallel Request

If the user explicitly says "review them in parallel" or "do them all at once", acknowledge the rate limit risk:

> "⚠️ Parallel multi-module reviews can hit API rate limits (5 agents × N modules, some at opus tier). Want to proceed anyway, or stick to serial?"

Do not override serial by default — always get explicit confirmation before going parallel.
