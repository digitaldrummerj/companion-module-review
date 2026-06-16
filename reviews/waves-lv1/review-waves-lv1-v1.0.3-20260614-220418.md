# Re-review — waves-lv1 v1.0.3 (follow-up)

| | |
|---|---|
| **Module** | waves-lv1 |
| **Tag** | v1.0.3 |
| **Scope** | tag — changes since last reviewed release (`v1.0.1..v1.0.3`) + verification of prior findings |
| **Prior review** | [review-waves-lv1-v1.0.1-20260608-181452.md](review-waves-lv1-v1.0.1-20260608-181452.md) |
| **Language / API** | TypeScript · `@companion-module/base` ~1.12.1 (v1) |
| **Protocols** | OSC, TCP, UDP, Bonjour/zDNS |
| **Reviewed** | 2026-06-14 |

> **Follow-up note.** The BitFocus portal reports no prior *approved* release, but the repo's v1.0.2 commit ("Address Bitfocus review v1.0.1") and v1.0.3 are the maintainer's response to the v1.0.1 review. This review diffs `v1.0.1..v1.0.3` (the maintainer's changes) and verifies the prior findings. Confirmed **FIXED** in this range: M2, M4, M7, H4, L3, H6, and most prior template criticals (C1–C12 — husky/lint-staged/eslint/tsconfig adopted, `yarn lint` now clean, prior H1 resolved). All remaining findings below are NEW in this range.

## Verdict: Approved

## 📋 Issues

**Blocking**

- [ ] [H1: no-ACK handshake leaves the socket open and status stuck on Connecting](#h1-no-ack-handshake-leaves-the-socket-open-and-status-stuck-on-connecting)

**Non-blocking**

- [ ] [M1: fallback discovery in connectIfReady is not cancellable](#m1-fallback-discovery-in-connectifready-is-not-cancellable)
- [ ] [L1: duplicate DiscoverHandle interface declaration](#l1-duplicate-discoverhandle-interface-declaration)
- [ ] [L2: emit error passes an unknown value instead of an Error](#l2-emit-error-passes-an-unknown-value-instead-of-an-error)

## 🟠 High

### H1: no-ACK handshake leaves the socket open and status stuck on Connecting

**Classification:** 🆕 New (regression introduced by the M2 fix) · `src/osc-tcp.ts:217-221,241-244`, `src/main.ts:302-304`
The v1.0.1 M2 fix correctly stops `register()` from emitting `'registered'` when the handshake ACK never arrives — both branches now `emit('error')` and `return`. But neither branch destroys the socket, and the M4 connect-deadline timer was already cleared on `'connect'` (`osc-tcp.ts:75`). So a device that completes the TCP connect but never ACKs the handshake leaves the socket half-open: no `'close'` event fires, `autoReconnect` never re-triggers, and `consecutiveFailures` never increments (so `rediscoverPort` never runs). In `main.ts` the OSC `'error'` handler only logs. Net effect: the module is stuck on `InstanceStatus.Connecting` indefinitely with no recovery — the false "Ok" was traded for a permanently-hung state.
**Fix:** in both no-ACK branches, destroy the socket (`this.socket?.destroy()`) after emitting the error so `'close'` fires and auto-reconnect resumes; or have `main.ts`'s OSC `'error'` handler set `InstanceStatus.ConnectionFailure`/`Disconnected` and tear down the client so it isn't left half-open.

## 🟡 Medium

### M1: fallback discovery in connectIfReady is not cancellable

**Classification:** 🆕 New (gap in the H2 fix) · `src/main.ts:223-226`, `src/main.ts:120-132` (`destroy()`)
The v1.0.1 H2 fix added `DiscoverHandle`/`cancelDiscovery()` and wired the cache-driven scans (`ensureInitialScan`/`refreshDiscovery`/`rediscoverPort`) into it. But the one-shot `discover({...}).done` started directly inside `connectIfReady()` is not registered as a cancellable handle, so `cancelDiscovery()` (called from both `destroy()` and the `configUpdated` restart) cannot stop it — that dgram socket, bound to the fixed port 13337, lingers up to its ~6 s timeout. Since `connectIfReady()` is awaited from both `init()` and `configUpdated()`, a delete/reconfigure during an in-flight fallback scan leaves a live socket holding multicast membership (mitigated, but not eliminated, by `reuseAddr: true`). This is the exact leak class H2 set out to close, on a path the fix didn't cover.
**Fix:** store the `DiscoverHandle` from the `connectIfReady` one-shot on the instance and call its `.stop()` in `destroy()`/`configUpdated`, or route that scan through `refreshDiscovery` so `cancelDiscovery()` covers it.

## 🟢 Low

### L1: duplicate DiscoverHandle interface declaration

**Classification:** 🆕 New · `src/zdns-discover.ts:103-105`
`export interface DiscoverHandle` is declared twice — the original single-member `{ stop }` (lines 103–105) was left behind when the `{ stop; done }` version (lines 110–113) was added. TypeScript declaration-merges them so the build passes, but the first block is dead and misleading.
**Fix:** delete lines 103–105 and keep only the documented `{ stop; done }` interface.

### L2: emit error passes an unknown value instead of an Error

**Classification:** 🆕 New · `src/osc-tcp.ts:252-253`
The catch now does `this.emit('error', err)` with `err` typed `unknown` (previously `err as Error`). The instance `'error'` handler (`main.ts:302`) reads `err.message`, so a non-`Error` throw would surface as `undefined`. Low risk in practice (the awaited paths throw `Error`s), but worth normalizing.
**Fix:** `this.emit('error', err instanceof Error ? err : new Error(String(err)))`.
