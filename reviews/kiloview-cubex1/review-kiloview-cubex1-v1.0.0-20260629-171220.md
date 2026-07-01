# Review: kiloview-cubex1 v1.0.0

| | |
|---|---|
| **Module** | kiloview-cubex1 |
| **Version** | v1.0.0 |
| **Scope** | `tag` (first release — no previous tag, so reviewed as a full review of all of `src/`) |
| **Language / API** | JS / @companion-module/base v2 (`~2.0.4`) |
| **Previous tag** | (none — first release) |
| **Reviewed** | 2026-06-29 |

> **First release.** There is no `previousTag..reviewTag` diff, so the `tag` scope fell back to a full-module review per the pipeline. All findings are classified 🆕 NEW.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: yarn.lock missing](#c1-yarnlock-missing-required-file)
- [ ] [C2: manifest id does not equal name](#c2-manifest-id-does-not-equal-name)
- [ ] [C3: banned keyword Kiloview collides with module slug](#c3-banned-keyword-kiloview-collides-with-module-slug)
- [ ] [H1: HTTP keep-alive agents and device session never torn down](#h1-http-keep-alive-agents-and-device-session-never-torn-down)

**Non-blocking**

- [ ] [M1: non-numeric polling rate causes a busy-loop request flood](#m1-non-numeric-polling-rate-causes-a-busy-loop-request-flood)
- [ ] [M2: token-refresh failure never updates status or reconnects](#m2-token-refresh-failure-never-updates-status-or-reconnects)
- [ ] [M3: numeric polling options use textinput instead of cycle-calls-not-awaited)
- [ ] [L3: checkSystemInfo swallows all errors](#l3-checksysteminfo-swallows-all-errors)
- [ ] [L4: action errors do not reflect connection loss in status](#l4-action-errors-do-not-reflect-connection-loss-in-status)

## 🔴 Critical

### C1: yarn.lock missing required file

**File:** `yarn.lock` · **Classification:** 🆕 NEW

Required file is missing. The repo declares `packageManager: yarn@4.12.0` and `engines.yarn: ^4`, but ships no lockfile. Companion's CI installs with `--immutable`, which requires a committed `yarn.lock`. This is the root cause of C4 and C5.

**Fix (maintainer):** run `yarn install` locally with Yarn 4 and commit the generated `yarn.lock`.

### C2: manifest id does not equal name

**File:** `companion/manifest.json` · **Classification:** 🆕 NEW

`id` is `kiloview-cubex1` but `name` is `Kiloview CUBE X1`. The module `id` and `name` must match (the validator requires `id === name`).

**Fix (maintainer):** set `name` to `kiloview-cubex1` (the module slug). The human-readable label belongs in `manufacturer` / `products` / `shortname`, which are already populated.

### C3: banned keyword Kiloview collides with module slug

**File:** `companion/manifest.json` · **Classification:** 🆕 NEW

The `keywords` array contains `Kiloview`, which is a token of the module slug (`kiloview-cubex1`). Slug-derived / low-value keywords are rejected.

**Fix (maintainer):** remove `Kiloview` from `keywords`. Keep only genuinely distinguishing search terms (e.g. `NDI`, `Matrix`, `Router`, `Distribution`).

## 🟠 High

### H1: HTTP keep-alive agents and device session never torn down

**File:** `src/cubex1.js:31-35`, `src/main.js:39-48`, `src/api.js:20-39` · **Classification:** 🆕 NEW

The client builds `http.Agent`/`https.Agent` with `keepAlive: true, maxSockets: 5`, holding persistent sockets. The class exposes no `close()`/`destroy()`, and `instance.destroy()` only stops intervals and fire-and-forgets `logout()` — the agents and their sockets are never destroyed. Worse, `initConnection()` runs on **every** `configUpdated()` and reconnect, each time assigning a fresh `KiloviewCubeX1` to `self.DEVICE` and orphaning the previous instance's agents and its still-logged-in device session. Repeated config edits / reconnect cycles leak up to 5 lingering sockets per generation and leave stale sessions on the device until the ~5-min token expires.

**Fix (maintainer):** add a `close()` to `KiloviewCubeX1` that calls `this.httpAgent.destroy()` / `this.httpsAgent.destroy()`. In `destroy()` and at the top of `initConnection()` (before replacing `self.DEVICE`), capture the old device and chain `logout().catch(()=>{})` → `close()`, then set `self.DEVICE = null`.

## 🟡 Medium

### M1: non-numeric polling rate causes a busy-loop request flood

**File:** `src/api.js:101-115`, `src/config.js:93-108` · **Classification:** 🆕 NEW

`pollingrate` / `pollingrate_resources` are `textinput` fields. The guard `self.config.pollingrate < 500` only resets sub-500 / undefined values. A non-numeric value (e.g. `"abc"`, `"1000ms"`) makes `"abc" < 500` evaluate `false`, passes the guard, then `parseInt(...)` → `NaN`, and `setInterval(fn, NaN)` collapses to ~0–1 ms — a tight loop firing `checkState` (network call + `checkAllFeedbacks` + `checkVariables`) continuously, with invocations stacking unbounded.

**Fix (maintainer):** parse first and validate: `let rate = parseInt(self.config.pollingrate); if (!Number.isFinite(rate) || rate < 500) rate = self.POLLINGRATE;` then use `rate`. Apply to both fields, and add an in-flight guard so a new `checkState` is skipped while one is running (see N1).

### M2: token-refresh failure never updates status or reconnects

**File:** `src/api.js:90-99` · **Classification:** 🆕 NEW

The `TOKEN_INTERVAL` callback catches refresh errors and only logs them. If `refreshToken()` (and its `login()` fallback) keep failing because the device went away, status stays `Ok` and no reconnect starts. The device-down path is detected only by `checkState`'s `unreachable` branch — which won't fire if polling is disabled, leaving a dead connection reporting OK indefinitely.

**Fix (maintainer):** on a refresh error whose cause is `unreachable`/auth failure, call `updateStatus(ConnectionFailure)` + `stopIntervals()` + `startReconnectInterval()`, mirroring `checkState`.

## 🟢 Low

### L3: checkSystemInfo swallows all errors

**File:** `src/api.js:184-209` · **Classification:** 🆕 NEW

Both inner try/catch blocks log only under `verbose` and never propagate `unreachable`. If polling is enabled `checkState` covers reachability, but if polling is off an unreachable device here is invisible — connectivity detection ends up entirely dependent on the panel poll.

**Fix (maintainer):** let an `unreachable` error here also trigger the reconnect path, or at least log at non-verbose level.

### L4: action errors do not reflect connection loss in status

**File:** `src/actions.js:8-16` · **Classification:** 🆕 NEW

`runAction` catches and logs the error but never updates `InstanceStatus`. If an action fails because the device just went unreachable, the operator sees only a log line until the next poll detects it — and with polling disabled, never.

**Fix (maintainer):** on an `error.unreachable` in `runAction`, surface `ConnectionFailure` (and optionally kick the reconnect path).
