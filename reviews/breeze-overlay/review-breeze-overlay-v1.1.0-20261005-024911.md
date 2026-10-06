# Review: breeze-overlay v1.1.0

| | |
| --- | --- |
| **Module** | `companion-module-breeze-overlay` |
| **Version** | v1.1.0 |
| **Scope:** | tag |
| **Previous tag** | none (first release, so there is no diff and the whole module was reviewed) |
| **Template** | `companion-module-template-ts` @ `d62230e` (2026-08-28) |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Review date** | 2026-10-05 |

> This is the module's first release to Bitfocus, so there was no `previousTag..v1.1.0` diff to limit the review to. The whole module was reviewed, and every finding is classed as 🆕 NEW. The repo also has local tags `v1.0.0` and `v1.0.1`, but neither is a published Bitfocus release.
>
> Build and lint: `yarn install --immutable`, `yarn package` and `yarn lint` all pass. No build artifacts (`dist/`, `pkg/`, `*.tgz`, `node_modules`) are committed.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
| ---------- | -------- | ------------- | ------- |
| 🔴 Critical | 5 | 0 | 5 |
| 🟠 High | 2 | 0 | 2 |
| 🟡 Medium | 3 | 0 | 3 |
| 🟢 Low | 6 | 0 | 6 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **18** | **0** | **18** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: tsconfig.build.json differs from the template](#c1-tsconfigbuildjson-differs-from-the-template)
- [ ] [C2: Missing postinstall script](#c2-missing-postinstall-script)
- [ ] [C3: Missing husky devDependency](#c3-missing-husky-devdependency)
- [ ] [C4: Missing lint-staged devDependency](#c4-missing-lint-staged-devdependency)
- [ ] [C5: Missing lint-staged section in package.json](#c5-missing-lint-staged-section-in-packagejson)
- [ ] [H1: LICENSE differs from the template](#h1-license-differs-from-the-template)
- [ ] [H2: Overlapping connect calls leak a poll interval and outlive destroy](#h2-overlapping-connect-calls-leak-a-poll-interval-and-outlive-destroy)

**Non-blocking**

- [ ] [M1: A wrong API key never shows as AuthenticationFailure](#m1-a-wrong-api-key-never-shows-as-authenticationfailure)
- [ ] [M2: Connection status never recovers when no channel is watched](#m2-connection-status-never-recovers-when-no-channel-is-watched)
- [ ] [M3: Action callbacks ignore context.signal](#m3-action-callbacks-ignore-contextsignal)
- [ ] [L1: init waits up to about 20 seconds against a slow server](#l1-init-waits-up-to-about-20-seconds-against-a-slow-server)
- [ ] [L2: Socket states and response bodies are cast without type checks](#l2-socket-states-and-response-bodies-are-cast-without-type-checks)
- [ ] [L4: Some variables keep stale values](#l4-some-variables-keep-stale-values)
- [ ] [L6: A poll round from the old config blocks and overrides the new one](#l6-a-poll-round-from-the-old-config-blocks-and-overrides-the-new-one)
- [ ] [L7: cycle state dropdown is missing disableAutoExpression](#l7-cycle-state-dropdown-is-missing-disableautoexpression)
- [ ] [L8: Preset names are blank for channels without a display name](#l8-preset-names-are-blank-for-channels-without-a-display-name)
- [ ] [N1: No timeout on the WebSocket welcome](#n1-no-timeout-on-the-websocket-welcome)
- [ ] [N2: Every poll tick re-checks every feedback and resets the status](#n2-every-poll-tick-re-checks-every-feedback-and-resets-the-status)
- [ ] [N3: restart comment says it dials at once but it backs off](#n3-restart-comment-says-it-dials-at-once-but-it-backs-off)

---

## 🔴 Critical

### C1: tsconfig.build.json differs from the template

**Classification:** 🆕 NEW · **File:** `tsconfig.build.json`

The file must match the template exactly, but it differs in three ways:

- It is indented with 2 spaces. The template uses tabs.
- `compilerOptions` adds `"lib": ["es2024", "dom"]`.
- It adds a long block comment explaining the `lib` change.

The comment says `dom` is needed because `api.ts` uses the global `fetch`, `Response`, `RequestInit` and `AbortSignal`. That isn't the case: `@types/node` 22, which the module already depends on (resolved 22.20.3), declares those globals itself in `web-globals/fetch.d.ts` and `web-globals/abortcontroller.d.ts`. During this review, `src/` type-checked with **zero errors** against the template's `node22/recommended-esm.json`, without the `dom` override.

**Fix:** Restore `tsconfig.build.json` from the template exactly: tabs, no `lib` override and no comment.

### C2: Missing postinstall script

**Classification:** 🆕 NEW · **File:** `package.json`

The required script `"postinstall": "husky"` is missing from `scripts`.

**Fix:** Add `"postinstall": "husky"` to `scripts`, as in the template.

### C3: Missing husky devDependency

**Classification:** 🆕 NEW · **File:** `package.json`

The template lists `husky` in `devDependencies`, but this module doesn't. The repo ships a `.husky/` directory, but because husky is never installed, its hooks never run.

**Fix:** Add `husky` to `devDependencies` at the template's version.

### C4: Missing lint-staged devDependency

**Classification:** 🆕 NEW · **File:** `package.json`

The template lists `lint-staged` in `devDependencies`, but this module doesn't.

**Fix:** Add `lint-staged` to `devDependencies` at the template's version.

### C5: Missing lint-staged section in package.json

**Classification:** 🆕 NEW · **File:** `package.json`

The template's top-level `lint-staged` config block is missing.

**Fix:** Copy the template's `lint-staged` section into `package.json`.

## 🟠 High

### H1: LICENSE differs from the template

**Classification:** 🆕 NEW · **File:** `LICENSE:3`

LICENSE must match the template byte for byte, but line 3 differs:

- **Found:** `Copyright (c) 2026 Dave Clark`
- **Template:** `Copyright (c) 2022 Bitfocus AS - Open Source`

**Fix:** Replace `LICENSE` with the template's file.

### H2: Overlapping connect calls leak a poll interval and outlive destroy

**Classification:** 🆕 NEW · **Files:** `src/main.ts:214-235`, `src/main.ts:539-543`, `src/main.ts:156-163`, `src/main.ts:165-191`

**Root cause:**

- `connect()` calls `stopPolling()` only once, before its first `await`. It then waits on `health()` and `refreshPresets()`, which run `allChannels`, `mode` and `sources` in sequence, each with a 5 s timeout.
- After the waits, `connect()` calls `syncSockets()`, `startPolling()` and `startSourcePolling()`. It never checks whether a newer `connect()` has started, or whether `destroy()` has run, in the meantime.
- `startPolling()` (line 541) assigns `this.timer = setInterval(...)` without clearing an existing timer. `startSourcePolling()`, by contrast, does clear its timer first.

**How it happens:** The user saves the config twice inside that window, which is common when correcting a wrong host. Both `connect()` calls reach `startPolling()`. The first interval loses its handle, so no later `configUpdated()` or `destroy()` can clear it. Each overlap adds another poller that runs permanently.

**Other effects:**

- The older `connect()` still runs `applyVersion(<old server version>)`, `this.reachable = true` and `updateStatus(Ok)`, or `reportError`, after the new config is in place. The status and the version gate (sockets and allowed actions) then describe a server the connection no longer points at.
- If `destroy()` runs while `connect()` is waiting, `connect()` carries on afterwards. It starts intervals and opens hub WebSockets with their own reconnect timers on an instance that has already been torn down.
- A `poll()`, `checkServer()` or `recheckVersion()` still in flight resolves after `destroy()`. It then calls `markReachable`, `updateStatus` and `setVariableValues`. Through `recheckVersion` → `applyVersion` → `syncSockets()`, it can also open new sockets.

**Fix:**

- Call `this.stopPolling()` at the top of `startPolling()`.
- Add a connect generation counter. Increment it in `connect()`, capture it before the awaits, and return early after each `await` if it has changed.
- Add a `destroyed` flag and set it in `destroy()`. Check it in `connect()`, `markReachable()`, `applyVersion()` and `syncSockets()`, and after the awaits in `poll()`, `checkServer()` and `recheckVersion()`.

## 🟡 Medium

### M1: A wrong API key never shows as AuthenticationFailure

**Classification:** 🆕 NEW · **Files:** `src/main.ts:218-223`, `src/main.ts:582-591`, `src/main.ts:598-602`, `src/main.ts:439-443`

With a wrong or missing key, the status shows Ok, for these reasons:

- `connect()` checks `/healthz`, which needs no key, so it reports Ok. `refreshPresets()` then gets a 401 from `/api/channels`, but it only logs "Could not build presets".
- In `poll()`, any `BreezeError` with a non-zero status, including 401, sets `reachable = true`. `markReachable(true)` then calls `updateStatus(Ok)` on every tick (1 s by default).
- When an action gets a 401, `reportError` sets AuthenticationFailure, but the next poll tick sets the status back to Ok.

The hub socket needs no key, so live feedbacks keep working while every action fails. The operator sees a healthy connection.

**Fix:**

- In the `poll()` catch, handle `error.status === 401` separately. Send it through `reportError`, and don't let `markReachable(true)` override it.
- Report a 401 the same way in `refreshPresets()` and `readSources()`.
- Probe a keyed endpoint during `connect()` (for example `allChannels()`) and send its error through `reportError`, so a bad key shows as AuthenticationFailure from the start.
- Set Ok only after a successful keyed read.

### M2: Connection status never recovers when no channel is watched

**Classification:** 🆕 NEW · **Files:** `src/main.ts:224-234`, `src/main.ts:566`, `src/main.ts:308-310`, `src/main.ts:324-326`

Once `health()` fails in `connect()`, the status is ConnectionFailure. The only way back is `poll()` → `markReachable(true)` → `recheckVersion()`. But `poll()` returns at line 566 when no button watches a channel, and the 5 s source and mode polls swallow every error without reporting reachability.

**Example:** A new connection has no buttons yet, and Companion starts before the Breeze server (a normal boot order). The status stays ConnectionFailure, `serverVersion` stays empty, and presets are never built, so there is no preset to make the first button from. This lasts until the user saves the config again.

Likewise, if the server fails while only source, mode or media buttons are placed, the outage is never reported.

**Fix:** When `keys.length === 0`, have the poll tick fall back to a `/healthz` check and call `markReachable()` with the result. `markReachable(true)` already rechecks the version and rebuilds the presets.

### M3: Action callbacks ignore context.signal

**Classification:** 🆕 NEW · **Files:** `src/api.ts:150-163`, `src/actions.ts:75-107` (and the callbacks at lines 387-392, 421-427 and 476-482)

On API 2.1, every action callback receives a `context` with an abort `signal`. None of these callbacks use it. `request()` always sets its own `signal: AbortSignal.timeout(5000)`, and because that comes after `...init`, it would also overwrite any signal a caller passed in. So when Companion aborts an action (the button is aborted, the action group is cancelled, or the connection is torn down), the request still runs for up to 5 s. It can then update the status and the log after the abort.

**Fix:**

- Give the callbacks a `context` parameter, and pass `context.signal` through `send()` and the `BreezeApi` methods.
- In `request()`, combine the signals: `signal: init?.signal ? AbortSignal.any([init.signal, AbortSignal.timeout(5000)]) : AbortSignal.timeout(5000)`.
- Return quietly, without calling `reportError`, when the caller's signal is aborted.

## 🟢 Low

### L1: init waits up to about 20 seconds against a slow server

**Classification:** 🆕 NEW · **Files:** `src/main.ts:128-154`, `src/main.ts:218-223`

`init()` awaits `connect()`, which runs `health()`, then `allChannels()`, then `readMode()` and `sources()`, one after another, each with a 5 s timeout. Against a slow server, `init()` can take about 20 s to return.

**Fix:** Set Connecting, then start `void this.connect()` without awaiting it (its errors are already caught inside). Alternatively, build the presets in the background once the status is Ok.

### L2: Socket states and response bodies are cast without type checks

**Classification:** 🆕 NEW · **Files:** `src/live.ts:165-171`, `src/main.ts:643-687`, `src/api.ts:179`

`stateOf()` only checks that the hub's `state` is an object before casting it to `ChannelState`. Fields such as `playback.tables[0].secondsLeft`, `page`, `pageCount`, `renderers` and `controllers` are then used without type checks. A wrong-type or missing field shows up as `NaN` or `"undefined"` in variables such as `cycle_seconds_left` and `sources_connected`. HTTP bodies are likewise cast with `as T`. A body with the wrong shape is caught, but it only surfaces as a generic error.

**Fix:**

- In `stateOf()`, check that `playback` is an object or null and that `tables` is an array, and use `Number.isFinite` on the numeric fields.
- Check `typeof health.version === 'string'` before calling `applyVersion`.

### L4: Some variables keep stale values

**Classification:** 🆕 NEW · **Files:** `src/main.ts:137-151`, `src/main.ts:180`, `src/main.ts:643-655`

- **`media_up` / `media_down`:** `init()` never sets these, and `configUpdated()` (line 180) doesn't reset them. On a server below 0.74, `readSources` returns early, so they keep the previous server's counts indefinitely.
- **`project`:** The no-target branch of `publishDefaultVariables` doesn't write `project`. If the project field is cleared, the old project name stays in `$(…:project)`.

**Fix:**

- Add `media_up: ''` and `media_down: ''` to the initial `setVariableValues` in `init()` and to the reset in `configUpdated()`.
- Set `project: this.config.project ?? ''` in the no-target branch.

### L6: A poll round from the old config blocks and overrides the new one

**Classification:** 🆕 NEW · **File:** `src/main.ts:562-596`

The `polling` guard is shared across reconfigures, and each round reads channels one at a time with a 5 s timeout per channel. Against a dead old host, a round can take N × 5 s. During that time, the new config's `poll()` returns immediately. When the old round finishes, it calls `markReachable()` and can set the new connection's status from the old server's result.

**Fix:** Tie each round to the connect generation from H2, and drop its result if the generation has changed. Alternatively, run the channel requests in parallel with `Promise.allSettled`.

### L7: cycle state dropdown is missing disableAutoExpression

**Classification:** 🆕 NEW · **File:** `src/actions.ts:306-316`

The `cycle` action's `state` dropdown (toggle / hold / resume) doesn't set `disableAutoExpression: true`. Every other mode-selector dropdown in the module does: `page.by`, `source_use.mode`, `mode.how`, `page_is.by`, `source_state.state` and `media_state.state`. An expression makes little sense for this choice, and the callback (line 321) treats any value other than `resume` or `toggle` as `hold`.

**Fix:** Add `disableAutoExpression: true` to this option.

### L8: Preset names are blank for channels without a display name

**Classification:** 🆕 NEW · **File:** `src/presets.ts:73` (also lines 92, 100, 108, 124, 138 and 149)

The preset and section names use `entry.name` directly. The button text uses the fallback `label = entry.name || channel` (line 62). So a channel with no display name appears in the preset list as " — PLAY", and its section has an empty name.

**Fix:** Use `label` in place of `entry.name` in the preset names (for example `${label} — PLAY`) and in the section `name`.

## 💡 Nice to Have

### N1: No timeout on the WebSocket welcome

**Classification:** 🆕 NEW · **File:** `src/live.ts:100-120`

Nothing limits how long the handshake, or the wait for the `welcome` message, can take. If the socket connects to something other than a Breeze hub, it never becomes live. It stays open indefinitely and is never retried. Polling still covers the channel.

**Fix:** Start a timer of about 10 s in `connect()`. If no welcome has arrived by then, call `drop()` and `scheduleRetry()`.

### N2: Every poll tick re-checks every feedback and resets the status

**Classification:** 🆕 NEW · **Files:** `src/main.ts:591-592`, `src/main.ts:598-602`

Each poll tick (1 s by default) calls `refresh()`, which runs `checkFeedbacks(...ALL_FEEDBACKS)` and rewrites all the default-channel variables, even when nothing changed. `markReachable()` also calls `updateStatus` on every tick and on every socket message.

**Fix:**

- Have `acceptState` report whether the state changed, and call `refresh()` only when something did.
- In `markReachable`, call `updateStatus` only when `ok !== this.reachable`.

### N3: restart comment says it dials at once but it backs off

**Classification:** 🆕 NEW · **File:** `src/live.ts:75-82`

The comment on `restart()` says "dial again at once", but `restart()` calls `scheduleRetry()`, which waits for the current backoff delay (up to 10 s).

**Fix:** Correct the comment, or reset `this.delay` to `FIRST_RETRY_MS` before calling `scheduleRetry()`.
