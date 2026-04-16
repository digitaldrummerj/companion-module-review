�� Imported from squad-export on 2026-04-01T20:41:10.786Z. Portable knowledge carried over; project learnings from previous project preserved below.

# Project Context

- **Owner:** Justin James
- **Project:** BitFocus Companion module for Custom AV Controller for Zoom Room Controller application communicating via OSC protocol
- **Stack:** TypeScript, Node.js, BitFocus Companion SDK
- **Created:** 2026-03-13

## Core Context

### Patterns & Anti-Patterns Learned (2026-03-13 → 2026-04-09)

Reviewed 25+ modules across multiple releases. Key learnings:

**Critical Findings (Most Common):**
- Missing `runEntrypoint()` call — module won't bootstrap in Companion
- Source code at root level instead of `src/` — template violation
- `package-lock.json` presence — instant rejection (use yarn.lock only)
- Missing `type: "connection"` in manifest.json — blocks v4.3+ compatibility
- Banned keywords in manifest names (manufacturer/product names)
- Duplicate source files (outdated root-level code vs. refactored src/)

**High Findings (Recurring Patterns):**
- `checkConnection()` ignoring `response.ok` — silent failures
- `JSON.stringify(err)` produces `{}` for native Errors — always use `err.message` or `err.stack`
- Unhandled promise rejections in action callbacks
- `destroy()` no-op when cleanup needed (unresolved requests)
- No connection retry/backoff strategy
- Config value mismatches across sections (e.g., action ID case: `setOid` vs `setOID`)

**Medium Findings:**
- Missing upgrade scripts for breaking changes (renames, removed options, config changes)
- Silent error swallowing via `.catch(() => {})` without logging
- Race conditions on connection updates
- Typos in manifest (e.g., "Serivce" → "Service")

**Architecture Patterns (Solid):**
- `destroy()` that calls `stop()` is correct — if `stop()` exists, `destroy()` must invoke it
- Binary protocol implementations benefit from custom types and protocol documentation
- PQueue for device communication rate limiting (prevents flooding)
- EventEmitter for async event handling
- Proper TCP lifecycle: handshake, heartbeat, queue, cleanup

**First Release Anti-Pattern:**
- New modules commonly missing all template scaffolding (scripts, linting, build config)
- Results in instant rejection — requires manual structure rebuild

### Recent Sessions (2026-04-05 → 2026-04-09)

- behringer-wing v2.3.0: 8 findings (critical connection handling regression)
- noctavoxfilms-tallycomm v1.0.0: First release lacking template structure
- wearefalcon-falconplay v1.0.0: Duplicate source files, name mismatch
- adder-ccs-pro v0.1.2: Template compliance violations
- 12+ other module reviews with varying findings

---

## Learnings

<!-- Append new learnings below. Each entry is something lasting about the project. -->

## behringer-wing v2.3.1 (2026-04-16) — Re-Review

**Module:** companion-module-behringer-wing v2.3.1
**API:** @companion-module/base ~1.13
**Release Type:** Follow-up patch to v2.3.0

**Final Verdict:** ✅ APPROVED — All 8 findings from v2.3.0 fixed; no regressions or new issues.

**Findings Fixed:**
- 🔴 C1: Connection error handler regression (v2.3.0) — `updateStatus(InstanceStatus.ConnectionFailure)` restored
- 🟠 H1: `JSON.stringify(err)` → uses `err.message` + `err.stack` 
- 🟠 H2: Missing connection retry handling — retry logic with exponential backoff added
- 🟠 H3: Incomplete error message context — now includes full error details in logs
- 🟡 M1-M4: (4 medium template/linting issues) — all corrected

**What Improved:**
- Error handling now discriminates between connection failures and application errors
- Proper Error object serialization in logs (not empty `{}`)
- Retry strategy with jitter prevents thundering herd on outages
- No new issues introduced; build passes, module structure intact

**Pattern Learned:**
When a follow-up patch fixes all prior findings with no new issues, module is ready for release. The v2.3.0 → v2.3.1 cleanup was thorough and professional.

**Review file:** reviews/behringer-wing/review-behringer-wing-v2.3.1-20260416-054930.md
