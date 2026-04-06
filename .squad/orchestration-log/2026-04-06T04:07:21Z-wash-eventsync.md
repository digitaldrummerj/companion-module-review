# Orchestration Log: wash-eventsync

**Agent:** Wash (Protocol Specialist)  
**Task:** WebSocket protocol review, eventsync-server v0.9.8  
**Timestamp:** 2026-04-06T04:07:21Z  
**Status:** ✅ Completed

## Verdict
🔴 **FAIL** — 2 blocking issues

## Summary
Wash reviewed WebSocket lifecycle, connection management, error handling, and resource cleanup. Found 2 critical protocol issues blocking release: listener leaks on disconnect and infinite reconnect loop on auth failure. Core protocol is sound but lifecycle cleanup required.

## Blocking Issues Found
1. **WebSocket Event Listeners Not Removed** — Resource leak
   - `src/connection.ts:67-75` — disconnect() closes socket but doesn't remove listeners
   - Can cause memory leaks, ghost events, duplicate handlers
   
2. **Reconnect on `authFailed` Creates Persistent Failure Loop** — Server abuse
   - `src/connection.ts:89-92` — Failed auth triggers infinite reconnect every 5s
   - No way to stop loop except destroying module instance

## Recommendations
- Implement exponential backoff on reconnects
- Add connection timeout handling
- Defensive ping interval cleanup

## Artifacts
- Full review: `.squad/decisions/inbox/wash-review-findings.md`

## Good Practices Observed
- Error handlers registered (prevents crashes)
- Defensive message parsing with try-catch
- ReadyState checks before sending
- Proper InstanceStatus tracking
- Cleanup in module destroy
