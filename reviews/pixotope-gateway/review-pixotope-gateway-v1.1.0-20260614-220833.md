# Review — pixotope-gateway v1.1.0

| | |
|---|---|
| **Module** | pixotope-gateway |
| **Review tag** | v1.1.0 |
| **Previous tag** | v1.0.1 |
| **Scope** | `tag` (only the `v1.0.1..v1.1.0` diff) |
| **Language / API** | TypeScript · @companion-module/base v1.x (~1.14.1) |
| **Protocols** | HTTP (keep-alive socket pool), TCP |
| **Build / Lint** | ✅ `yarn build` clean · ✅ `yarn lint` clean |
| **Date** | 2026-06-14 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 2 | 2 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 2 | 0 | 2 |
| 🟢 Low | 4 | 0 | 4 |
| **Total** | **2** | **6** | **8** |

> The 2 Critical findings are **pre-existing template/config drift** (the flagged files are unchanged in the `v1.0.1..v1.1.0` diff). They are surfaced because the template/build checks are full-module release gates that apply regardless of scope. The actual v1.1.0 **code** changes introduced **zero** new blocking issues — the networking-hardening and the new `call_event` action are sound.

## Verdict: Approved

## 📋 Issues

**Non-blocking**
- [ ] [M1: call_event silently treats a Gateway application-level failure as success](#m1-call_event-silently-treats-a-gateway-application-level-failure-as-success)
- [ ] [M2: Redundant dual timeout mechanism in publish()](#m2-redundant-dual-timeout-mechanism-in-publish)
- [ ] [L1: Redundant parseVariablesInString on an auto-parsed useVariables textinput](#l1-redundant-parsevariablesinstring-on-an-auto-parsed-usevariables-textinput)
- [ ] [L2: call_event tooltip example omits the required Target parameter; no Default-Engine fallback](#l2-call_event-tooltip-example-omits-the-required-target-parameter-no-default-engine-fallback)
- [ ] [L3: Response-stream error handler parameter is untyped](#l3-response-stream-error-handler-parameter-is-untyped)
- [ ] [L4: resetSockets() can tear down a concurrent in-flight requests socket](#l4-resetsockets-can-tear-down-a-concurrent-in-flight-requests-socket)

---

## 🟡 Medium

### M1: call_event silently treats a Gateway application-level failure as success

**File:** `src/actions.ts:182-196`
**Classification:** 🆕 New

The new `call_event` callback is fire-and-forget:

```ts
await self.sendRequest(parseGatewayUrl(url))
```

`self.sendRequest` (`src/main.ts:276-288`) already wraps `publish` in its own `try/catch`, logs `Gateway request failed: …`, calls `setConnected(false)`, and **returns `undefined` rather than re-throwing**. Two consequences:

1. The `try/catch` in `call_event` can only ever catch a **`parseGatewayUrl` parse error** — never a network/HTTP/timeout failure (those are swallowed inside `sendRequest`). So a transport failure is logged once as the generic "Gateway request failed", never with the `Call Event:` context.
2. More importantly, a Gateway reply that is HTTP-2xx but reports an **application-level failure** in the body (the `extractFailure` helper exists precisely to surface these) is **silently treated as success**. The operator gets no feedback that the Blueprint event did not actually fire.

This fire-and-forget shape matches the module's other write actions, but `call_event` is new in this release, so it is a new silent-failure path. Suggested fix:

```ts
const response = await self.sendRequest(parseGatewayUrl(url))
if (response) {
	const failure = extractFailure(response.body)
	if (failure) self.log('warn', `Call Event failed: ${failure}`)
}
```

(Keep `parseGatewayUrl` inside the `try` for the parse-error log, or move it out — either is fine.)

### M2: Redundant dual timeout mechanism in publish()

**File:** `src/api.ts:308-351`
**Classification:** 🆕 New

`publish()` now arms two independent timeouts at the same `this.timeout` duration:

- the `timeout: this.timeout` request option that drives `req.on('timeout')` (socket inactivity), and
- the new `hardTimer = setTimeout(…, this.timeout)` wall-clock backstop.

Both handlers call `req.socket?.destroy()` + `req.destroy(...)`. The single-settle guard (`fail`) makes this safe — the promise still settles exactly once and `req.destroy()` is idempotent — so **there is no functional bug**. But two same-duration mechanisms measuring different things is confusing, and a future maintainer could "simplify" by removing the wrong one (the `hardTimer` is the one that protects against a connect-hang where `req.socket` never materializes and the native `timeout` event never fires). Suggested fix: keep a single mechanism, or add a comment marking the redundancy as intentional belt-and-suspenders so neither is removed accidentally.

---

## 🟢 Low

### L1: Redundant parseVariablesInString on an auto-parsed useVariables textinput

**File:** `src/actions.ts:186`
**Classification:** 🆕 New

The `url` option declares `useVariables: true`, so under @companion-module/base v1.13+ (this module is ~1.14.1) Companion auto-parses variables in the field before the callback runs. The explicit `await context.parseVariablesInString(str(action.options.url))` therefore re-parses already-resolved text — a harmless, idempotent no-op. The same pattern exists in the older actions (house style), so per `tag` scope only the new occurrence is flagged. Optional simplification: `const url = str(action.options.url).trim()` (then rename the now-unused `context` to `_context` to satisfy lint).

### L2: call_event tooltip example omits the required Target parameter; no Default-Engine fallback

**File:** `src/actions.ts` (tooltip) · `companion/HELP.md`
**Classification:** 🆕 New

`parseGatewayUrl` throws `URL is missing the Target parameter` when `Target` is absent (`src/api.ts:68-69`). The `call_event` tooltip example string ends `…&Method=CallFunction&ParamObjectSearch=BP_test_C_1&ParamFunctionName=PX_showMe` with no `Type`/`Target` shown. A real editor-copied URL includes them, so this is a docs nit — but a user hand-typing from the example hits a confusing error. Separately, unlike the property actions (which apply `|| self.config.defaultEngine`), `call_event` passes the parsed request straight through, so a blank/missing `Target` is rejected rather than defaulted to the configured engine (HELP.md states a blank Target should mean the Default Engine for Raw API requests). Suggested fix: document that `Target` is mandatory in the pasted URL, or default a missing `Topic.Target` to `self.config.defaultEngine` for parity.

### L3: Response-stream error handler parameter is untyped

**File:** `src/api.ts:316`
**Classification:** 🆕 New

`res.on('error', (err) => fail(err))` — `err` is implicitly `any` and passed straight into `fail(err: Error)`. Every other handler in the diff types or guards its error. Low impact (response-stream errors are practically always `Error` instances). Suggested fix: `res.on('error', (err: Error) => fail(err))`.

### L4: resetSockets() can tear down a concurrent in-flight request's socket

**File:** `src/api.ts:276-279`
**Classification:** 🆕 New

`publish()` binds `agent: this.agent` at call time, so a `resetSockets()` triggered by one failing poll destroys the agent a *concurrent* in-flight request is using, tearing down its socket mid-flight. Today this is **not a real fault** — the caller's `polling`/`watching` no-overlap guards serialize requests, and the resulting error is caught and settled correctly. Noted only as a latent hazard: if request concurrency is ever broadened, this could surface as spurious failures during a reset. No change needed now; optionally only `resetSockets()` when no request is in flight.

---

## Summary of the v1.1.0 code changes (confirmed sound)

The reviewers verified the release's actual code changes are well constructed:

- **Reconnection fix (the headline change)** — `resetSockets()` (`api.ts:276-279`) destroys the stale keep-alive agent and swaps in a fresh one; `main.ts:262-268` calls it only on the Connected→Disconnected *transition* (`if (changed)` + `if (!connected)`), so it evicts a half-open pool after a Gateway restart without churning on every failed poll. The `agent` field was correctly changed from `readonly` to mutable. `destroy()` still tears the agent down. No leak.
- **Single-settle guards** (`api.ts:287-298`) — `fail`/`succeed` guarantee the promise settles exactly once across every path (`res 'error'`, non-2xx status, `end`, `req 'error'`, socket timeout, hard timer). No double-settle / unhandled-rejection risk.
- **Hard timeout ceiling + `req.on('close')` cleanup** — guarantees settlement even on a connect-hang and always clears the timer; `req.socket?.destroy()` before `req.destroy()` keeps a half-open socket out of the pool.
- **New `res.on('error')` handler** — response-stream errors are now caught (previously only the request had a handler). Good catch.
- **New `call_event` action** — v1.x API-compliant: `textinput` + `useVariables: true`, correct `(action, context)` callback, valid `warn`/`error` log levels, empty-URL guard, `parseGatewayUrl` wrapped in try/catch. No upgrade script needed (nothing renamed/removed).

No test framework is configured (no `test` script, no `*.test.ts`/`*.spec.ts`) — acceptable and non-blocking per policy.
