# Review: hopla-powerstudio

| | |
|---|---|
| **Module** | companion-module-hopla-powerstudio |
| **Version** | v1.0.0 |
| **Scope** | tag |
| **Language** | TypeScript |
| **API** | @companion-module/base v2.x (2.0.4) |
| **Protocols** | HTTP (REST) |
| **Reviewed** | 2026-06-29 |

> **First release (v1.0.0).** There is no `previousTag` to diff against, so the `tag` scope falls back to a **full review** of the current `src/`. Every finding is NEW.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: package-lock.json present and committed — module must use yarn](#c1-package-lockjson-present-and-committed--module-must-use-yarn)
- [ ] [C2: yarn.lock missing](#c2-yarnlock-missing)
- [ ] [C3: .gitignore missing package-lock.json entry](#c3-gitignore-missing-package-lockjson-entry)
- [ ] [C4: package.json missing packageManager field](#c4-packagejson-missing-packagemanager-field)
- [ ] [C5: You should not be patching the companion tools](#c5-you-should-not-be-patching-companion-tool)
- [ ] [C6: Husky pre-commit file does not need npx](#c6-husky-pre-commit-file-does-not-need-npx)
- [ ] [C7: tsconfig.json differs from template](#c7-tsconfigjson-differs-from-template)
- [ ] [C8: tsconfig.build.json differs from template](#c8-tsconfigbuildjson-differs-from-template)
- [ ] [H1: Overlapping re-entrant polls cause request pileup and state races](#h1-overlapping-re-entrant-polls-cause-request-pileup-and-state-races)
- [ ] [H2: yarn lint fails on prettier formatting errors](#h2-yarn-lint-fails-on-prettier-formatting-errors)

**Non-blocking**

- [ ] [M1: Aggressive default and minimum poll interval](#m1-aggressive-default-and-minimum-poll-interval)
- [ ] [M2: configUpdated and destroy do not cancel in-flight requests](#m2-configupdated-and-destroy-do-not-cancel-in-flight-requests)
- [ ] [M3: Full variable and feedback recompute on every poll tick](#m3-full-variable-and-feedback-recompute-on-every-poll-tick)
- [ ] [L1: set_next_item accepts blank or zero input as valid](#l1-set_next_item-accepts-blank-or-zero-input-as-valid)
- [ ] [L2: Client log routed to console.log instead of the Companion logger](#l2-client-log-routed-to-consolelog-instead-of-the-companion-logger)
- [ ] [L3: Floating void refreshStatus relies on internal catching](#l3-floating-void-refreshstatus-relies-on-internal-catching)
- [ ] [L4: options.test.ts not wired into run-tests.ts](#l4-optionstestts-not-wired-into-run-teststs)
- [ ] [N1: Redundant refreshes on the Cue or cue-or-stop path](#n1-redundant-refreshes-on-the-cue-or-cue-or-stop-path)
- [ ] [N2: set_next_item could support useVariables](#n2-set_next_item-could-support-usevariables)

## 🔴 Critical

### C1: package-lock.json present and committed — module must use yarn

**File:** `package-lock.json`

A `package-lock.json` is committed to the repo. Companion modules must use **yarn**, not npm; an npm lockfile is grounds for automatic rejection. The template's `.gitignore` also excludes `package-lock.json`, so its presence both violates the package-manager requirement and the gitignore policy.

**Fix (maintainer):** Delete `package-lock.json`, run `corepack enable` and `yarn install` to produce a `yarn.lock` (see C2), and ensure the npm lockfile is never re-committed.

### C2: yarn.lock missing

**File:** `yarn.lock`

The required `yarn.lock` is absent. The module cannot be built reproducibly under the official yarn-based pipeline without it.

**Fix (maintainer):** Run `yarn install` (with the correct `packageManager` set — see C4) and commit the resulting `yarn.lock`.

### C3: .gitignore missing package-lock.json entry

**File:** `.gitignore`

`.gitignore` is missing the template entry that excludes `package-lock.json`. This is what allowed the npm lockfile (C1) to be committed.

**Fix (maintainer):** Add `package-lock.json` to `.gitignore` to match the template.

### C4: package.json missing packageManager field

**File:** `package.json`

The required `packageManager` field (present in the template) is missing. This field pins the yarn version via corepack and is mandatory for the build pipeline.

**Fix (maintainer):** Add the `packageManager` field matching the template (e.g. `"packageManager": "yarn@..."`).

### C5: You should not be patching Companion Tool

**File:** scripts\patch-companion-tools.mjs

You should not be patching the companion-tools.  If there is a need to patch the companion-tool, you should submit a PR with the changes to the companion-tools.

**Fix:** remove the scripts\patch-companion-tools.mjs and postinstall script in package.json

### C6: husky pre-commit file does not need npx

In the .husky/pre-commit you do not need to include npx.  you can just have it be lint-staged.

### C7: tsconfig.json differs from template

**File:** `tsconfig.json`

Line 3 reads `"include": ["src*.ts", "tests*.ts"],`; the template is `"include": ["src*.ts"],`. Including `tests` in the base tsconfig pulls test sources into the default compile graph.

**Fix (maintainer):** Match the template's `include`; if tests must be type-checked, do so through `tsconfig.build.json`/a dedicated test tsconfig rather than the base config.

### C8: tsconfig.build.json differs from template

**File:** `tsconfig.build.json`

Line 7 reads `"rootDir": "./src",`; the template expects `"baseUrl": "./",`. A changed build-time root/base can shift emitted output layout away from what the runtime entry (`../dist/main.js`) expects.

**Fix (maintainer):** Restore the template's `tsconfig.build.json` settings.

## 🟠 High

### H1: Overlapping re-entrant polls cause request pileup and state races

**File:** `src/main.ts:267-273` (with `refreshStatus` at `:114-171`)

`startPolling()` uses `setInterval(() => void this.refreshStatus(), interval)` with no in-flight guard. The default poll interval is 100 ms (`config.ts:5`) while the default request timeout is 3000 ms (`config.ts:33`). When the host is slow or unreachable, a new `refreshStatus()` launches every 100 ms while the previous one is still awaiting `fetch` — allowing ~30 concurrent runs, each with its own `fetch`/`AbortController` and each mutating `this.state` and calling `setVariableValues`/`checkAllFeedbacks`. Concurrent runs interleave their writes to `this.state`, so stale data can overwrite fresh data, and a recovering host produces a resolving burst.

**Fix (maintainer):** Replace the fixed `setInterval` with a self-rescheduling `setTimeout` that schedules the next poll only in a `finally` after the current `refreshStatus()` settles, and/or add an `isRefreshing` guard at the top of `refreshStatus()` that returns early if a refresh is in flight. Consider enforcing `pollInterval >= requestTimeout` or warning when it isn't.

### H2: yarn lint fails on prettier formatting errors

**File:** `src/types.ts:32,56`

`yarn lint` exits non-zero with 2 `prettier/prettier` errors (union-type member formatting on lines 32 and 56). A release must pass lint cleanly.

**Fix (maintainer):** Run `yarn lint --fix` (or `yarn format`) and commit the result.

## 🟡 Medium

### M1: Aggressive default and minimum poll interval

**File:** `src/config.ts:5-6`

`DEFAULT_POLL_INTERVAL = 100` polls `/api/status/total` plus `/api/playlist/current` ~10×/sec by default, and `MIN_POLL_INTERVAL = 10` lets an operator configure up to 100 polls/sec. Combined with H1 this is sustained load on both Companion and the device.

**Fix (maintainer):** Raise the default to ~500–1000 ms and the minimum to ~100–250 ms, and/or document why sub-second polling is required in the field tooltip.

### M2: configUpdated and destroy do not cancel in-flight requests

**File:** `src/main.ts:54-58, 60-92`

`configUpdated()` calls `stopPolling()` (which only clears the interval timer) then resets `this.state` and builds a new client — but a `refreshStatus()` already in flight against the *old* client/host keeps running, and when it resolves it writes to the freshly-reset state and calls `setConnectionStatus(...)`, briefly showing stale data/status after a rapid config change. `destroy()` sets `this.client = undefined` but does not abort an in-flight `refreshStatus()`, which can call `updateStatus`/`setVariableValues` after teardown.

**Fix (maintainer):** Track the active request's `AbortController` and abort it in `stopPolling()`/`destroy()`, and/or capture a generation/epoch counter at the start of `refreshStatus()` and discard the result if the client/epoch changed before it resolved.

### M3: Full variable and feedback recompute on every poll tick

**File:** `src/main.ts:282-295`

`refreshStatus()` ends with `setConnectionStatus(InstanceStatus.Ok, ...)` on every successful poll, which unconditionally rebuilds the entire `values` object (players, carts, 16 playlist-window items, all rack slots) and calls `checkAllFeedbacks()` — 10×/sec at the default interval even when nothing changed. `UpdateVariableValues` also rebuilds arrays via `getCartRackItems`/`getPlaylistWindowItems` each time, and each advanced feedback re-runs `getPlaylistWindowItems().find(...)`.

**Fix (maintainer):** Push variable/feedback updates only when relevant state actually changed (compare a lightweight fingerprint, or skip the redundant `UpdateVariableValues`/`checkAllFeedbacks` in `setConnectionStatus` when status and message are unchanged).

## 🟢 Low

### L1: set_next_item accepts blank or zero input as valid

**File:** `src/actions.ts:187-191`

`Number(event.options.nextLineId)` returns `0` for an empty string, and `Number.isSafeInteger(0)` is `true`, so an empty/whitespace field silently passes validation and sends `nextLineId: 0` to the device. Whitespace like `" 5 "` also coerces successfully.

**Fix (maintainer):** Reject empty/whitespace explicitly (`if (event.options.nextLineId.trim() === '') throw ...`) and/or require `nextLineId > 0` if 0 is not a valid line id.

### L2: Client log routed to console.log instead of the Companion logger

**File:** `src/main.ts:88`

`new PowerStudioClient(this.config, this.secrets, (message) => console.log(message))` sends HTTP response/error detail (`describeHttpResponse`, `client.ts:139`) to stdout instead of the connection log panel, bypassing Companion's log-level handling.

**Fix (maintainer):** Pass `(message) => this.log('debug', message)`.

### L3: Floating void refreshStatus relies on internal catching

**File:** `src/main.ts:91, 271`

Both call sites use `void this.refreshStatus()`. `refreshStatus` wraps only the *network* calls in `Promise.allSettled`; the post-processing (`applyTotalStatusVersion`, `applyTotalStatus`, `updateDynamicDefinitions`, `checkAllFeedbacks`, `UpdateVariableValues`) runs unguarded. A synchronous throw there (e.g. a malformed payload reaching a selector) would become an unhandled rejection on the floated promise. (Action callbacks that `await refreshStatus` are safe.)

**Fix (maintainer):** Wrap the floated calls with `.catch((e) => this.log('error', ...))`, or broaden `refreshStatus`'s own try/catch to cover the post-fetch processing.

### L4: options.test.ts not wired into run-tests.ts

**File:** `tests/run-tests.ts`

`tests/options.test.ts` contains real assertions but is not imported by `run-tests.ts` (only 12 of 13 test files are imported), so those tests never execute under `yarn test`.

**Fix (maintainer):** Add `import './options.test.js'` to `run-tests.ts`.

## 💡 Nice to Have

### N1: Redundant refreshes on the Cue or cue-or-stop path

**File:** `src/actions.ts:347-351` (with `runCommand` at `main.ts:205-225`)

`resolveCueOrStopCommand` awaits `refreshStatus()` to decide Cue vs Stop, then `runCommand` awaits `refreshStatus()` again after sending — a Cue press is three round-trips (refresh, command, refresh). Functionally correct, just chatty.

**Fix (maintainer):** Reuse the most recent polled state when it is fresh enough instead of forcing a refresh before resolving.

### N2: set_next_item could support useVariables

**File:** `src/actions.ts:176-197`

The `set_next_item` action uses a `textinput` for `nextLineId` parsed with `Number()`, but does not set `useVariables: true`, so the target can't be driven from a variable/expression (e.g. the module's own `playlist_item_N_line_id` variables).

**Fix (maintainer):** Add `useVariables: true` to that field so the next-item target can be computed dynamically.
