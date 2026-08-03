# Review: crewlan-connect v1.1.0

| | |
|---|---|
| **Module** | crewlan-connect |
| **Version** | v1.1.0 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full `src/` review; all findings new) |
| **Language / API** | TS / @companion-module/base v2 (~2.0.4) |
| **Protocols** | HTTP (REST + SSE) |
| **Reviewed** | 2026-08-03 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- It is bad form to check all feedbacks unless completely needed.  It is far better to explicitly check feedbacks that need to be updated based off the action
- please move all of the code from instance.ts to main.ts and remove instance.ts.  There is no value add to having an main.ts that is just an import of instance.ts.
- There are several extra sections in package.json that are not in the template's package.json and are not needed.  The module template is located at [https://github.com/bitfocus/companion-module-template-ts](https://github.com/bitfocus/companion-module-template-ts)
- The .github workflow verify is not needed and it not part of the Companion module template
- Please pull in the .github/workflows from the module template as well as the .github/ISSUE_TEMPLATE
- please match the engines node version in the package.json to the module template's version
- [ ] [C3: required template files are missing](#c3-required-template-files-are-missing)
- [ ] [C4: husky and lint-staged pre-commit tooling is missing](#c4-husky-and-lint-staged-pre-commit-tooling-is-missing)
- [ ] [C5: .gitignore is missing required template entries](#c5-gitignore-is-missing-required-template-entries)
- [ ] [C6: eslint.config.mjs does not use the template config generator](#c6-eslintconfigmjs-does-not-use-the-template-config-generator)
- [ ] [C7: tsconfig.json / tsconfig.build.json extends chain is inverted vs the template](#c7-tsconfigjson--tsconfigbuildjson-extends-chain-is-inverted-vs-the-template)
- [ ] [C8: package.json is missing the prettier field and three required scripts](#c8-packagejson-is-missing-the-prettier-field-and-three-required-scripts)
- [ ] [C10: banned/low-value manifest keyword stream deck](#c10-bannedlow-value-manifest-keyword-stream-deck)
- [ ] [C11: legacyIds reserved for module name changes](#c11-legacyids-are-reserved-for-when-a-module-has-a-name-change)
- [ ] [H1: no timeout on any HTTP request](#h1-no-timeout-on-any-http-request)
- [ ] [H2: poll interval fires without waiting for the previous snapshot](#h2-poll-interval-fires-without-waiting-for-the-previous-snapshot)
- [ ] [H3: a failed talk push-up leaves the mic open with only a warn log](#h3-a-failed-talk-push-up-leaves-the-mic-open-with-only-a-warn-log)

**Non-blocking**

- [ ] [M1: instance status stays stuck on failure after a transient action error](#m1-instance-status-stays-stuck-on-failure-after-a-transient-action-error)
- [ ] [M2: a cleanly closed event stream is never restarted](#m2-a-cleanly-closed-event-stream-is-never-restarted)
- [ ] [M3: a stale poll response overwrites newer control state](#m3-a-stale-poll-response-overwrites-newer-control-state)
- [ ] [M4: the AbortSignal plumbing is dead code — nothing is cancellable](#m4-the-abortsignal-plumbing-is-dead-code--nothing-is-cancellable)
- [ ] [M5: unvalidated JSON casts — a malformed controls payload throws inside feedbacks and variables](#m5-unvalidated-json-casts--a-malformed-controls-payload-throws-inside-feedbacks-and-variables)
- [ ] [M6: reconnect has no backoff and retries non-recoverable errors forever](#m6-reconnect-has-no-backoff-and-retries-non-recoverable-errors-forever)
- [ ] [M7: publishState() re-registers every action, feedback and preset on every state change](#m7-publishstate-re-registers-every-action-feedback-and-preset-on-every-state-change)
- [ ] [M8: CRLF normalization across chunk boundaries silently drops events](#m8-crlf-normalization-across-chunk-boundaries-silently-drops-events)
- [ ] [M9: auth-failure masking hides the actionable token-capability error](#m9-auth-failure-masking-hides-the-actionable-token-capability-error)
- [ ] [M10: legacyIds claims crewlan-v1 on a first release](#m10-legacyids-claims-crewlan-v1-on-a-first-release)
- [ ] [M11: set_status with an empty status id silently does nothing](#m11-set_status-with-an-empty-status-id-silently-does-nothing)
- [ ] [L1: the poll interval keeps running while a reconnect is pending](#l1-the-poll-interval-keeps-running-while-a-reconnect-is-pending)
- [ ] [L2: the SSE reader is never cancelled when the loop exits](#l2-the-sse-reader-is-never-cancelled-when-the-loop-exits)
- [ ] [L3: the SSE buffer can grow unbounded and is rescanned quadratically](#l3-the-sse-buffer-can-grow-unbounded-and-is-rescanned-quadratically)
- [ ] [L4: SSE parse failures are swallowed with no diagnostics](#l4-sse-parse-failures-are-swallowed-with-no-diagnostics)
- [ ] [L5: the fallback poll runs at full rate even while the event stream is healthy](#l5-the-fallback-poll-runs-at-full-rate-even-while-the-event-stream-is-healthy)
- [ ] [L6: no idle or heartbeat timeout on the event stream](#l6-no-idle-or-heartbeat-timeout-on-the-event-stream)
- [ ] [L7: setEntityStatus PUT plus follow-up GET can report failure for a successful write](#l7-setentitystatus-put-plus-follow-up-get-can-report-failure-for-a-successful-write)
- [ ] [L8: stale status and controls are retained on disconnect](#l8-stale-status-and-controls-are-retained-on-disconnect)
- [ ] [L9: toggle actions compute from possibly stale local state](#l9-toggle-actions-compute-from-possibly-stale-local-state)
- [ ] [L10: every 404 is mapped to BadConfig](#l10-every-404-is-mapped-to-badconfig)
- [ ] [L11: status dropdowns have no allowCustom](#l11-status-dropdowns-have-no-allowcustom)
- [ ] [L12: boolean state is published as the strings true and false](#l12-boolean-state-is-published-as-the-strings-true-and-false)
- [ ] [N1: the hand-maintained feedbackIds list will drift](#n1-the-hand-maintained-feedbackids-list-will-drift)
- [ ] [N2: normalizeBaseUrl keeps embedded userinfo credentials](#n2-normalizebaseurl-keeps-embedded-userinfo-credentials)
- [ ] [N3: a non-JSON 200 response raises a raw SyntaxError](#n3-a-non-json-200-response-raises-a-raw-syntaxerror)
- [ ] [N4: the last_alert variable carries no content and never auto-clears](#n4-the-last_alert-variable-carries-no-content-and-never-auto-clears)
- [ ] [N5: getCompanionStatusFontSize ignores its argument](#n5-getcompanionstatusfontsize-ignores-its-argument)
- [ ] [N6: upgrade script can return undefined for updatedSecrets](#n6-upgrade-script-can-return-undefined-for-updatedsecrets)
- [ ] [N7: config fields have no tooltips or descriptions](#n7-config-fields-have-no-tooltips-or-descriptions)
- [ ] [N8: migrateLegacyEntityToken duplicates the upgrade script on every init](#n8-migratelegacyentitytoken-duplicates-the-upgrade-script-on-every-init)

## 🔴 Critical

### C3: required template files are missing

**File:** `.gitattributes`, `.prettierignore`, `LICENSE` (all missing)

Three files required by `companion-module-template-ts` are absent. `LICENSE` in particular is required for the Bitfocus listing — `package.json` and `companion/manifest.json` both declare `MIT`, but no license text ships with the module.

**Fix:** Add the template `.gitattributes` (LF enforcement), `.prettierignore`, and an MIT `LICENSE` file matching the declared license.

### C4: husky and lint-staged pre-commit tooling is missing

**File:** `.husky/pre-commit` (missing), `package.json` (`devDependencies`, `lint-staged`, `scripts.postinstall`)

The template's pre-commit chain is absent in full: no `.husky/pre-commit` hook, no `husky` devDependency, no `lint-staged` devDependency, no `lint-staged` section in `package.json`, and no `postinstall` script to install the hooks.

**Fix:** Add `husky` and `lint-staged` as devDependencies, add the template's `lint-staged` config block and `"postinstall": "husky"` script, and commit `.husky/pre-commit` running `lint-staged`.

### C5: .gitignore is missing required template entries

**File:** `.gitignore`

Missing template entries: `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. Without `/dist` and `/*.tgz` in particular, build output and packaged tarballs can be committed to the repo.

**Fix:** Adopt the template `.gitignore` verbatim and add any module-specific entries below it.

### C6: eslint.config.mjs does not use the template config generator

**File:** `eslint.config.mjs:1`

The file starts with `import tseslint from "typescript-eslint";` instead of the template's `import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'`. A hand-rolled config drifts from the shared Bitfocus ruleset, so lint results are not comparable to other modules.

**Fix:** Replace with the template `eslint.config.mjs` (`generateEslintConfig(...)`) and layer any module-specific overrides on top of the generated config.

### C7: tsconfig.json / tsconfig.build.json extends chain is inverted vs the template

**File:** `tsconfig.json:2`, `tsconfig.build.json:2`

The template has `tsconfig.json` extend `./tsconfig.build.json`, which in turn extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`. This module inverts it: `tsconfig.json` declares its own `compilerOptions` and `tsconfig.build.json` extends `./tsconfig.json`. The shared Bitfocus compiler settings are therefore never applied.

**Fix:** Restore the template layering — `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`, `tsconfig.json` extends `./tsconfig.build.json`, and only genuine module-specific overrides remain local.

### C8: package.json is missing the prettier field and three required scripts

**File:** `package.json`

Missing the `prettier` field (present in the template), and missing the required scripts `format`, `build:main` and `lint:raw`. (`postinstall` is covered by C4.) Without `lint:raw`/`format` the standard Bitfocus tooling commands don't work against this repo.

**Fix:** Copy the template's `prettier` field and add the `format`, `build:main` and `lint:raw` scripts.

### C10: banned/low-value manifest keyword stream deck

**File:** `companion/manifest.json` (`keywords`)

`keywords` contains `stream deck`, which is a banned/low-value search keyword (every Companion module is used with a Stream Deck).

**Fix:** Remove `stream deck`; the remaining keywords (`status`, `alerts`, `public api`) are already descriptive.

### C11: legacyIds are reserved for when a module has a name change

**File:** `companion/manifest.json` (`keywords`)

The legacyIds is reserved for when a module has been released and then later renamed.  I am not seeing any crewlan-v1 module.

**Fix:** Remove the crewlan-v1 under the legacyIds

## 🟠 High

### H1: no timeout on any HTTP request

**File:** `src/api.ts:247-255`, `:203-209`

`request()` builds every fetch with no `signal` and no deadline, and the mutating methods (`setEntityStatus`, `patchEntityControls`, `dismissEntityAlerts`) don't even accept an `AbortSignal`. On a half-open TCP connection — a CrewLAN box dropping off Wi-Fi without a FIN, which is the normal failure mode on show floors — a request hangs until undici's 300 s headers timeout. An action's promise never settles, `connect()` never completes (widening the C1 window), and combined with H2 the poll keeps stacking new snapshots on top of stuck ones.

**Fix:** Give every request a deadline — `signal: AbortSignal.any([callerSignal, AbortSignal.timeout(this.timeoutMs ?? 5000)])` — and thread a signal through the write methods too. Use a separate, longer/heartbeat-based watchdog for `streamEvents` (see L6).

### H2: poll interval fires without waiting for the previous snapshot

**File:** `src/instance.ts:398-406`

`startPolling()` uses `setInterval`, firing `loadSnapshot()` unconditionally every `pollIntervalMs` (floor 1000 ms, default 5000 ms) regardless of whether the previous run finished. Each `loadSnapshot()` issues **6 HTTP requests** (`session`, `workspace`, `entity`, `statuses`, `status`, `controls`). With no request timeout (H1), a stalled host accumulates roughly 60 overlapping snapshot runs — ~360 in-flight sockets — before anything errors. Out-of-order completions also write stale state (see M3).

**Fix:** Replace `setInterval` with a self-rescheduling `setTimeout` chain that only re-arms in a `finally` after the snapshot settles, or add an `if (this.pollInFlight) return` guard.

### H3: a failed talk push-up leaves the mic open with only a warn log

**File:** `src/instance.ts:266-275` (`setTalkState`), `:228-234` (`runCrewLanAction`), `src/actions.ts:93-101`

`talk_push_up` fires a single PATCH to clear `talk.active`. If it fails — or hangs, per H1 — `runCrewLanAction()` routes to `handleOperationError()`, which logs a warning and sets an instance status; the talk channel stays **live on the device**. For an intercom module this is the highest-consequence failure path in the codebase (an open mic that the operator believes is closed), and it is effectively silent: the button has already returned to its idle look while `talk_live` still reads true.

**Fix:** Treat the release path specially — use a short timeout and retry once or twice on failure, and surface a distinct, loud failure (`this.log('error', 'Failed to release talk — microphone may still be live')`) rather than the generic operation-error path.

## 🟡 Medium

### M1: instance status stays stuck on failure after a transient action error

**File:** `src/instance.ts:546-556` (`handleOperationError`), `:315`

`handleOperationError()` calls `updateStatus(statusForError(error), message)` for *any* action failure, but the only place that ever returns to `InstanceStatus.Ok` is `connect()` (`:315`). `publishState()` never touches the status. So a single transient 500 on a PATCH, or a 404 on `set_status` for a status that was just deleted (mapped to `BadConfig` — see L10), leaves the connection displayed as broken indefinitely while polling and SSE keep succeeding.

**Fix:** Have the success path — `loadSnapshot()`, or `patchControls()`/`setEntityStatus()` — call `this.updateStatus(InstanceStatus.Ok)` when the previous status wasn't `Ok`. Consider reporting per-action failures via `log`/`lastError` only, and reserving `updateStatus` for connection-level problems.

### M2: a cleanly closed event stream is never restarted

**File:** `src/api.ts:226-228`, `src/instance.ts:383-396`

When the server closes the SSE response, `reader.read()` returns `done` and `streamEvents()` **resolves**. `startEventStream()` only attaches a `.catch`, so nothing fires: `this.eventAbortController` stays set, no reconnect is scheduled, and the status stays `Ok`. After a CrewLAN restart or a reverse-proxy idle timeout the module silently degrades to 5-second polling while still reporting a healthy connection — push-to-talk feedback becomes visibly laggy with no indication why.

**Fix:** Treat normal completion as a disconnect unless the signal was aborted: `void api.streamEvents(...).then(() => { if (!controller.signal.aborted) { this.handleConnectionError(new Error('event stream closed')); this.scheduleReconnect() } }, err => ...)`.

### M3: a stale poll response overwrites newer control state

**File:** `src/instance.ts:369-381` vs `:266-275`, `:455-468`

`loadSnapshot()` assigns `controls`/`status` unconditionally from a response that may have been requested *before* an operator action or an SSE event. Concrete path: operator presses Talk Push Down → PATCH returns `talk.active = true` → a poll started 200 ms earlier resolves and overwrites `controls` with `active: false`. The talk feedback drops out and the button misreports mic state until the next poll. H2's overlapping polls make out-of-order completion likelier.

**Fix:** Discard snapshot results from a stale connection generation (C1), and/or ignore snapshot writes older than the last applied `updatedAt` — both `PublicEntityStatusDto` and `PublicEntityControlsDto` carry one.

### M4: the AbortSignal plumbing is dead code — nothing is cancellable

**File:** `src/instance.ts:344` (`loadSnapshot(signal?)`), call sites `:314` and `:401`

`loadSnapshot()` accepts an `AbortSignal` and forwards it to all six API calls, but **neither caller ever passes one**, so `signal` is always `undefined`. `cleanupConnection()` therefore aborts only the SSE stream; every REST call in flight during `destroy()`/`configUpdated()` runs to completion and then mutates state on a dead connection. This is the mechanism behind C2.

**Fix:** Hold one `AbortController` per connection generation, pass `controller.signal` into `loadSnapshot()` at both call sites and into the write methods (which need a signal parameter added), and abort it in `cleanupConnection()`.

### M5: unvalidated JSON casts — a malformed controls payload throws inside feedbacks and variables

**File:** `src/api.ts:89`, `:273`, `src/instance.ts:347`, `:455-468`, `src/variables.ts:50-51`, `src/feedbacks.ts:91-155`

Every response is `JSON.parse`d and cast (`as T`, `as PublicEventEnvelope`) with no shape check. Two concrete failure modes:

- `state.controls?.shoutbox.listen` guards only the *first* level. If the server returns a `controls` object without `shoutbox` (older firmware, partial payload, a 200 from a proxy error page), `UpdateVariableValues()` throws. Reached via `applyControlsEvent()`, that throw propagates out of `onEvent()` → `streamEvents()` rejects → `handleConnectionError()` + reconnect, which re-enters the same bad payload: a reconnect loop caused by a parsing gap.
- `session.entities.filter` (`instance.ts:347`) surfaces a raw `Cannot read properties of undefined` to the operator when `entities` is absent.

**Fix:** Add narrow type guards at the API boundary (a hand-rolled guard per DTO is enough) and throw `CrewLanApiError('Unexpected response from CrewLAN…')` instead of letting `TypeError`s escape into Companion callbacks. At minimum, wrap the `onEvent(event)` call at `api.ts:242` in a try/catch so one bad frame can't kill the stream.

### M6: reconnect has no backoff and retries non-recoverable errors forever

**File:** `src/instance.ts:408-417`

The reconnect delay is always `max(1000, pollIntervalMs)`, and every failure funnels into it — bad URL, empty token, revoked token, and "the token must grant exactly one CrewLAN entity capability" alike. With `pollIntervalMs` at its 1000 ms floor the module hammers `/api/v1/session` with an invalid bearer token once per second indefinitely, which is a good way to trip server-side rate limiting or an account lockout.

**Fix:** Use exponential backoff with jitter, capped at ~30–60 s, reset on a successful snapshot. For `BadConfig`/`AuthenticationFailure`, stop retrying entirely (or back off to a long interval) — `configUpdated()` and the Refresh/Reconnect action already provide recovery paths.

### M7: publishState() re-registers every action, feedback and preset on every state change

**File:** `src/instance.ts:558-569`

`publishState()` calls `updateActions()`, `updateFeedbacks()` **and** `updatePresets()` on every invocation — and it is invoked on every poll tick (≥ every 5 s), every SSE event (push-to-talk can generate several per second) and after every action. Each run re-sends all action defs, all 12 feedback defs and the entire preset tree (`src/presets.ts:15-201`) over IPC, and refreshes the definitions in the web UI while a user may be editing a button. Only the status dropdown choices actually depend on state, and those change only when `state.statuses` changes.

**Fix:** Split values from definitions. `publishState()` should do `UpdateVariableValues(this)` + `checkAllFeedbacks()` only; re-register definitions from `loadSnapshot()` and only when the selectable-status list actually changed (compare joined `id`+`label` keys against what was last registered).

### M8: CRLF normalization across chunk boundaries silently drops events

**File:** `src/api.ts:230-232`

The accumulated buffer is re-normalized on every chunk: `buffered.replace(/\r\n/gu, "\n").replace(/\r/gu, "\n")`. If a chunk ends with a bare `\r` and the next begins with `\n` — a legal TCP split of a single `\r\n` — the first pass rewrites the trailing `\r` to `\n`, and appending the next chunk produces a false `\n\n` boundary in the middle of an event. `parseServerSentEvents()` then fails `JSON.parse` and returns `[]` (`api.ts:88-92`), so the event vanishes with no log at all (L4).

**Fix:** Don't normalize the accumulated buffer. Hold back a trailing `\r` until the next chunk arrives, or search the raw buffer for both `\n\n` and `\r\n\r\n` and normalize only the extracted complete block.

### M9: auth-failure masking hides the actionable token-capability error

**File:** `src/instance.ts:120-126` (`describeCompanionErrorForDisplay`), `:350-352`, `:533-544`

`describeCompanionErrorForDisplay()` replaces every `AuthenticationFailure` message with the generic *"Could not establish a connection because authentication failed."*, and `handleConnectionError()` logs that same masked string. Because `statusForError()` maps token/capability wording to `AuthenticationFailure`, the specific and highly actionable *"The token must grant exactly one CrewLAN entity capability."* (`:350`) is never shown **or logged anywhere** — a user with a multi-entity token has no way to diagnose it. (The masking itself is good practice and is test-covered; the problem is that the real reason is discarded rather than demoted.)

**Fix:** Keep the generic text for `updateStatus()`, but also `this.log('debug', describeError(error))` with the real reason so it lands in the connection log. Messages that carry no secret material (like the capability error) can safely be logged at `warn`.

### M10: legacyIds claims crewlan-v1 on a first release

**File:** `companion/manifest.json:25-27`, asserted by `scripts/check-module.mjs:12-14` and `tests/manifest.test.ts`

`legacyIds: ["crewlan-v1"]` makes Companion adopt connections previously stored under that id. On a first release this claims an id the module has never owned — and because `check-module.mjs` hard-fails if it's removed, it can't drift away accidentally either.

**Fix:** Confirm that `crewlan-v1` really is a previously published Companion module id being superseded here. If it isn't, drop it from the manifest and relax the assertions in `scripts/check-module.mjs` and `tests/manifest.test.ts`.

### M11: set_status with an empty status id silently does nothing

**File:** `src/instance.ts:236-239`, `:217-222`, `src/actions.ts:50-61`

When statuses haven't loaded, `getStatusChoices()` returns a single placeholder `{ id: "", label: "No selectable statuses loaded" }` and `getDefaultStatusChoice()` defaults to `""`. A user can save a `set_status` button with that value; `setCrewLanStatus()` then returns immediately on `statusId.trim().length === 0` with no log, no status change and no user-visible feedback. The operator presses the button and nothing at all happens.

**Fix:** Log a warning before returning (`this.log('warn', 'Set My Status: no status selected / status list not loaded')`), validate the id against `state.statuses`, and make the placeholder read as unselectable (e.g. `— not connected —`).

## 🟢 Low

### L1: the poll interval keeps running while a reconnect is pending

**File:** `src/instance.ts:408-417`

`scheduleReconnect()` doesn't clear `pollTimer`, so a failing host keeps getting a burst of 6 doomed requests per interval until the reconnect actually fires — and each of those failures calls `scheduleReconnect()` again.

**Fix:** `clearInterval(this.pollTimer)` (and null it) inside `scheduleReconnect()`.

### L2: the SSE reader is never cancelled when the loop exits

**File:** `src/api.ts:219-245`

If `signal.aborted` flips between reads, `streamEvents()` returns with the reader still locked and the body never drained.

**Fix:** Wrap the loop in `try { ... } finally { await reader.cancel().catch(() => {}) }`.

### L3: the SSE buffer can grow unbounded and is rescanned quadratically

**File:** `src/api.ts:221`, `:230-232`

If no `\n\n` boundary ever arrives (a broken server, or non-SSE content served as 200), `buffered` grows without limit, and the two whole-buffer `replace()` calls run over the entire accumulated string on every chunk.

**Fix:** Cap the buffer (e.g. 256 KB–1 MB) and throw/reset once exceeded; normalize only the newly appended chunk.

### L4: SSE parse failures are swallowed with no diagnostics

**File:** `src/api.ts:88-92`

A malformed event returns `[]` from the `catch` with no log, so field-debugging lost state updates is impossible — and M8 makes silent drops a realistic occurrence.

**Fix:** Log at `debug` level with a truncated payload before discarding.

### L5: the fallback poll runs at full rate even while the event stream is healthy

**File:** `src/instance.ts:398-406`, `src/config.ts:87`

The config field is labelled "Poll fallback (ms)" but the poll always runs, issuing 6 requests every 5 s per instance (~72 requests/min) even while SSE is connected and delivering the same data.

**Fix:** Only poll when the stream isn't connected, or drop to a low-rate reconciliation interval (30–60 s) once SSE is up — and make the label match the behaviour.

### L6: no idle or heartbeat timeout on the event stream

**File:** `src/api.ts:223`

A half-open TCP connection leaves `reader.read()` pending forever while the instance still reports `Ok`; detection depends entirely on the poll timer noticing separately.

**Fix:** Track the time of the last event or `:` comment frame and abort/restart the stream if nothing arrives within ~2× the server's keepalive interval.

### L7: setEntityStatus PUT plus follow-up GET can report failure for a successful write

**File:** `src/api.ts:151-157`

`setEntityStatus()` issues a `PUT` and then a separate `GET` to read the new state. If the PUT succeeds and the GET fails, the action reports an error and `state.status` isn't updated even though the device did change. It also doubles the round-trips per status change and races the poll.

**Fix:** Use the PUT response body if the API returns the updated DTO; otherwise treat a failed re-read as non-fatal (log it and let the next poll/SSE settle state).

### L8: stale status and controls are retained on disconnect

**File:** `src/instance.ts:533-544`

`handleConnectionError()` sets `connected: false` but leaves the last-known `status`/`controls`/`entity` in place, so `$(crewlan:talk_live)` and every shoutbox feedback keep asserting the last known values while the module is offline. Only `connection_ok` reflects reality.

**Fix:** Clear (or explicitly mark stale) the control/status fields on disconnect, or document in HELP.md that shoutbox feedbacks should be paired with `connection_ok`.

### L9: toggle actions compute from possibly stale local state

**File:** `src/instance.ts:248-264`

`setListenMuteMode('toggle')` and `setTalkLatchMode('toggle')` invert `this.state.controls`, which can be up to one poll interval old — or arbitrarily old if the SSE stream died silently (M2). A toggle can then send the value the device already holds.

**Fix:** Low-risk while SSE is healthy; consider a server-side toggle endpoint, or a fresh `getEntityControls()` read before inverting when the last update is older than one poll interval.

### L10: every 404 is mapped to BadConfig

**File:** `src/instance.ts:94-96`

`statusForError()` maps any 404 to `InstanceStatus.BadConfig`. A transient 404 (an entity removed and re-added, a reverse-proxy hiccup) permanently red-flags the instance as misconfigured — and combined with M1 that state never clears.

**Fix:** Restrict `BadConfig` to 404s from the session/entity bootstrap path; treat action-path 404s as recoverable.

### L11: status dropdowns have no allowCustom

**File:** `src/actions.ts:50-55`, `src/feedbacks.ts:49-55`, `:67-73`

All three `statusId` dropdowns are built entirely from live device data, so buttons can't be configured before the first successful connection, and a saved `statusId` shows as an invalid selection whenever the connection is down.

**Fix:** Add `allowCustom: true` (optionally with a `regex`) so known status ids can be entered offline and survive a disconnect.

### L12: boolean state is published as the strings true and false

**File:** `src/variables.ts:23-25`, `:50-67`

`boolValue()` converts booleans to `"true"`/`"false"` strings. `CompanionVariableValue` is `JsonValue` in v2, so real booleans are supported; the string form forces users into `$(crewlan:talk_active) == 'true'` comparisons in expressions.

**Fix:** Type the boolean entries in `VariablesSchema` as `boolean`, drop `boolValue()`, and publish `talk?.active === true` directly.

## 💡 Nice to Have

### N1: the hand-maintained feedbackIds list will drift

**File:** `src/instance.ts:35-48`, used at `:564-568`

The array currently matches `FeedbacksSchema` exactly, but a newly added feedback that isn't added here will silently never be re-checked.

**Fix:** Use `this.checkAllFeedbacks()` (all feedbacks are being checked anyway) and delete the array.

### N2: normalizeBaseUrl keeps embedded userinfo credentials

**File:** `src/api.ts:45-53`

`normalizeBaseUrl()` strips path/search/hash but preserves userinfo, so `http://user:pass@host:4848` survives into `this.baseUrl` and into every request URL that may end up in a log.

**Fix:** Clear `url.username`/`url.password` (or reject such input) during normalization.

### N3: a non-JSON 200 response raises a raw SyntaxError

**File:** `src/api.ts:273`

Pointing the module at a captive portal or the wrong service yields a 200 with HTML; the bare `await response.json()` throws a `SyntaxError` that `statusForError()` maps to `ConnectionFailure` with an unhelpful message.

**Fix:** Wrap in try/catch and rethrow `new CrewLanApiError('CrewLAN returned an unexpected (non-JSON) response — check the address.')`.

### N4: the last_alert variable carries no content and never auto-clears

**File:** `src/instance.ts:470-489`

`last_alert` is set to `"Workspace alert <ISO timestamp>"` only, so operators can't tell what the alert was, and it persists until the Dismiss Alerts action runs.

**Fix:** Include the alert type/message from the event payload, and consider an age-based auto-clear.

### N5: getCompanionStatusFontSize ignores its argument

**File:** `src/status-labels.ts:53-58`

The body is `void status; return 14;` — a dead abstraction that reads like intended per-status sizing.

**Fix:** Either implement length-based sizing or inline the constant at the call sites.

### N6: upgrade script can return undefined for updatedSecrets

**File:** `src/upgrades.ts:28-30`

`updatedSecrets: migration.migrated ? migration.secrets : null` can yield `undefined` when the migration removed an empty legacy field; `null` is the documented "no change" value.

**Fix:** `updatedSecrets: migration.migrated ? (migration.secrets ?? null) : null`.

### N7: config fields have no tooltips or descriptions

**File:** `src/config.ts:69-96`

`baseUrl` uses only `Regex.SOMETHING` for validation, and `Poll fallback (ms)` doesn't explain that it's the fallback for the event stream (nor, per L5, that it currently always runs).

**Fix:** Add a URL-shaped regex and short `tooltip`/`description` text to each field so the connection dialog is self-explanatory.

### N8: migrateLegacyEntityToken duplicates the upgrade script on every init

**File:** `src/instance.ts:290-301`

`migrateLegacyEntityToken()` + `saveConfig()` runs on every `init()`/`configUpdated()`, duplicating what `UpgradeScripts[0]` already does. Harmless as a safety net, but it reads as an accidental double migration.

**Fix:** Add a comment explaining it's a deliberate belt-and-braces fallback, or drop it and rely on the upgrade script.
