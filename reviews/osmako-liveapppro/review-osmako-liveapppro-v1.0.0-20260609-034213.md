# Review — osmako-liveapppro v1.0.0

| | |
|---|---|
| **Module** | osmako-liveapppro |
| **Version** | v1.0.0 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full review) |
| **Language** | TypeScript |
| **API** | @companion-module/base v2 (resolved 2.0.4) |
| **Protocol** | HTTP (REST/JSON) |
| **Previous tag** | (none — first release) |
| **Reviewed** | 2026-06-09 |

> First release: there is no `previousTag..reviewTag` diff, so the whole module was reviewed and every finding is NEW.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 6 | 0 | 6 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 3 | 0 | 3 |
| 🟢 Low | 7 | 0 | 7 |
| 💡 Nice to Have | 1 | 0 | 1 |
| **Total** | **18** | **0** | **18** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [C1: Build fails — package.json is hand-rolled and missing the required template scripts, devDependencies, and fields](#c1-build-fails-packagejson-is-hand-rolled-and-missing-the-required-template-scripts-devdependencies-and-fields)
- [ ] [C2: Build artifacts and dependencies committed to the repo — node_modules, dist, pkg, and a tgz](#c2-build-artifacts-and-dependencies-committed-to-the-repo-node_modules-dist-pkg-and-a-tgz)
- [ ] [C3: Required template files are missing](#c3-required-template-files-are-missing)
- [ ] [C4: tsconfig.json does not extend the template's tsconfig.build.json](#c4-tsconfigjson-does-not-extend-the-templates-tsconfigbuildjson)
- [ ] [C5: Legacy ESLint config and lint failure](#c5-legacy-eslint-config-and-lint-failure)
- [ ] [C6: repository URL points to a personal fork and is not the canonical git+https bitfocus form](#c6-repository-url-points-to-a-personal-fork-and-is-not-the-canonical-githttps-bitfocus-form)
- [ ] [H1: Connection status gets stuck on Connecting when the device is unreachable from the first poll](#h1-connection-status-gets-stuck-on-connecting-when-the-device-is-unreachable-from-the-first-poll)

**Non-blocking**
- [ ] [M1: Polling loop has no reentrancy guard — polls overlap and stack against a slow or dead host](#m1-polling-loop-has-no-reentrancy-guard-polls-overlap-and-stack-against-a-slow-or-dead-host)
- [ ] [M2: No BadConfig status — an empty host produces a malformed URL and silent failure](#m2-no-badconfig-status-an-empty-host-produces-a-malformed-url-and-silent-failure)
- [ ] [M3: manifest runtime.apiVersion is the placeholder 0.0.0](#m3-manifest-runtimeapiversion-is-the-placeholder-000)
- [ ] [L1: Overlay feedback matching depends on unconfirmed server index semantics](#l1-overlay-feedback-matching-depends-on-unconfirmed-server-index-semantics)
- [ ] [L2: Action POST failures are only logged, never surfaced to the operator](#l2-action-post-failures-are-only-logged-never-surfaced-to-the-operator)
- [ ] [L3: current_item_id variable mixes number and empty-string types](#l3-current_item_id-variable-mixes-number-and-empty-string-types)
- [ ] [L4: Port default of 80 may not match the LiveApp Pro Inbox Server](#l4-port-default-of-80-may-not-match-the-liveapp-pro-inbox-server)
- [ ] [L5: Boolean variables are emitted as the literal strings true/false](#l5-boolean-variables-are-emitted-as-the-literal-strings-truefalse)
- [ ] [L6: Overlay-list fetch failures are swallowed with no diagnostic](#l6-overlay-list-fetch-failures-are-swallowed-with-no-diagnostic)
- [ ] [L7: post() ignores the response body and any API-level error payload](#l7-post-ignores-the-response-body-and-any-api-level-error-payload)
- [ ] [N1: Number() coercion of options can produce NaN with no guard](#n1-number-coercion-of-options-can-produce-nan-with-no-guard)

---

## 🔴 Critical

### C1: Build fails — package.json is hand-rolled and missing the required template scripts, devDependencies, and fields

`package.json`

The package was written by hand rather than derived from the official TS template, so the standard build does not run. `yarn package` (the build the release process invokes, which runs `companion-module-build`) fails because the `package` script does not exist. The TypeScript source itself compiles cleanly under `tsc`, so this is purely packaging — but a release that can't be packaged can't ship.

Specifically, relative to the official `companion-module-template-ts`, `package.json` is missing:
- **Scripts:** `postinstall`, `format`, `package`, `build:main`, `dev`, `lint:raw`, `lint` (only `build` / `build:watch` are present).
- **devDependencies:** `@companion-module/tools`, `@types/node`, `eslint`, `husky`, `lint-staged`, `prettier`, `rimraf`, `typescript-eslint`.
- **Fields:** `prettier`, `packageManager`, and the `lint-staged` section.

**Fix (maintainer):** Start from the current `companion-module-template-ts` `package.json` and port the module's name/description/dependencies into it, rather than maintaining a hand-written one. That restores the `package`/`build:main`/`lint`/`format` scripts and the `@companion-module/tools` toolchain the release build depends on.

### C2: Build artifacts and dependencies committed to the repo — node_modules, dist, pkg, and a tgz

repository root

The repo commits a large volume of generated content that must never be tracked: the entire `node_modules/` tree, the compiled `dist/` output (`dist/*.js`, `*.d.ts`, `*.map`), a `pkg/` packaged-output directory, and a published tarball `osmako-liveapppro-0.0.1.tgz`. The deterministic check counted ~3,510 tracked files that the template `.gitignore` would exclude. This bloats the repo, defeats the build pipeline, and (in the case of `node_modules`) ships dependencies that should be resolved from the lockfile.

**Fix (maintainer):** Add the template `.gitignore`, then untrack the generated content (e.g. `git rm -r --cached node_modules dist pkg osmako-liveapppro-0.0.1.tgz`) and commit. The repo should contain `src/`, `companion/`, and the template config files only — never `node_modules`, `dist`, `pkg`, or `.tgz` artifacts.

### C3: Required template files are missing

repository root

The following files required by the official TS template are absent:

- `.gitattributes`
- `.gitignore`
- `.prettierignore`
- `.yarnrc.yml`
- `LICENSE`
- `yarn.lock`
- `eslint.config.mjs`
- `tsconfig.build.json`
- `.husky/pre-commit`

The missing `.gitignore` is what allowed C2 to happen; the missing `yarn.lock` / `.yarnrc.yml` mean dependency resolution isn't pinned; the missing `LICENSE` is a publishing requirement (the manifest declares `MIT` but no license file is present).

**Fix (maintainer):** Bring these in from the current `companion-module-template-ts`. Add a real `LICENSE` (MIT) with the correct copyright holder.

### C4: tsconfig.json does not extend the template's tsconfig.build.json

`tsconfig.json:2`

The module's `tsconfig.json` is a standalone config (`"compilerOptions": { … }`) rather than the template form, which extends a shared base: the template's line 2 is `"extends": "./tsconfig.build.json"`. Without `tsconfig.build.json` (see C3) and the extends chain, the module diverges from the standard compiler settings the toolchain expects.

**Fix (maintainer):** Adopt the template's `tsconfig.json` + `tsconfig.build.json` pair and remove the hand-tuned compiler options unless a specific one is genuinely needed.

### C5: Legacy ESLint config and lint failure

`.eslintrc.json` (present), `eslint.config.mjs` (missing)

The module ships a legacy `.eslintrc.json` (eslintrc format) instead of the flat `eslint.config.mjs` the template uses, and `eslint`/`typescript-eslint` aren't in devDependencies (C1), so `yarn lint` reports problems / cannot run as configured.

**Fix (maintainer):** Replace `.eslintrc.json` with the template's `eslint.config.mjs` flat config and add the lint toolchain devDependencies. Confirm `yarn lint` passes on a clean checkout.

### C6: repository URL points to a personal fork and is not the canonical git+https bitfocus form

`package.json` (`repository.url`), `companion/manifest.json:9-10` (`repository`, `bugs`)

`package.json` declares `repository.url` as `https://github.com/patcrowley-cell/companion-module-osmako-liveapppro.git`; the release standard is `git+https://github.com/bitfocus/companion-module-osmako-liveapppro.git`. The manifest's `repository` and `bugs` fields likewise point at the `patcrowley-cell` personal account.

**Fix (maintainer):** Once the module is transferred into the `bitfocus` org for catalog acceptance, set `package.json` `repository.url` to the `git+https://github.com/bitfocus/...` form and update the manifest `repository`/`bugs` URLs to the `bitfocus/...` repo.

---

## 🟠 High

### H1: Connection status gets stuck on Connecting when the device is unreachable from the first poll

`src/index.ts:81-94` (the `poll()` catch block), with `src/index.ts:35`/`:48-49` and the initial `connected: false` from `src/api.ts:31`

The failure branch of `poll()` only calls `updateStatus(InstanceStatus.ConnectionFailure, …)` when `wasConnected` is `true`. On the very first poll after `init()` (or after `configUpdated()`), `this.state.connected` is `false` (from `makeEmptyState()`), so `wasConnected` is `false`, the `ConnectionFailure` update is skipped, and the status set in `init()` (`InstanceStatus.Connecting`) is never replaced.

The result: when the host/port is wrong or the Inbox Server is disabled — the single most common first-run situation — the module shows a permanent yellow **Connecting** with no error text, instead of **Connection Failure** with the helpful "Ensure the Inbox Server is enabled in Settings → Inbox" message that is already written into the code but never reached. The most important error path is effectively dead.

**Fix (maintainer):** Report the failure on every failed poll, not only on a connected→disconnected transition. `updateStatus` is idempotent, so calling it each poll is harmless; gate only the `log('warn', …)` line on `wasConnected` to avoid log spam:

```ts
} catch (err: unknown) {
    const wasConnected = this.state.connected
    this.state = { ...makeEmptyState(), connected: false }
    this.updateStatus(
        InstanceStatus.ConnectionFailure,
        'Cannot reach LiveApp Pro at ' + this.config.host + ':' + String(this.config.port) +
        '. Ensure the Inbox Server is enabled in Settings -> Inbox.',
    )
    if (wasConnected) this.log('warn', 'Lost connection: ' + (err instanceof Error ? err.message : String(err)))
    this.setVariableValues(buildVariableValues(this.state))
    this.checkAllFeedbacks()
}
```

---

## 🟡 Medium

### M1: Polling loop has no reentrancy guard — polls overlap and stack against a slow or dead host

`src/index.ts:57-61` (`startPolling`), `:70-95` (`poll`)

`setInterval` re-invokes `poll()` on a fixed interval regardless of whether the previous poll has resolved. The per-request fetch timeout is 3000ms (`src/api.ts:149,160`) while the poll interval can be as low as 500ms (`:58`). Against a dead or slow host, multiple `poll()` cycles run concurrently — each firing two requests via `Promise.all` (`src/api.ts:67-70`) — so up to ~6 cycles can be in flight before timeouts clear them. They also race to write `this.state` and call `setVariableValues`/`checkAllFeedbacks`. State isn't corrupted (each poll fully replaces it), but the work is wasted and ordering is non-deterministic.

**Fix (maintainer):** Use a self-rescheduling loop instead of `setInterval`: guard with an `inFlight` boolean (skip if a poll is still running), or `await poll()` and then `setTimeout` the next run. Consider keeping the fetch timeout shorter than the minimum poll interval.

### M2: No BadConfig status — an empty host produces a malformed URL and silent failure

`src/index.ts:22-37`, `:44-51`; `src/config.ts:18-24`

The `host` field has a default but no required/empty validation. If the user clears it, `baseUrl` becomes `http://:80/api` (`src/api.ts:58-59`), every request fails, and — combined with H1 — the module sits silently on **Connecting**. There is no `InstanceStatus.BadConfig` path. Port is bounded by the config field (`min:1,max:65535`), so only host is exposed.

**Fix (maintainer):** At the top of `init()`/`configUpdated()`, if `config.host` is empty/whitespace, call `updateStatus(InstanceStatus.BadConfig, 'Host is required')`, skip `startPolling()`, and return.

### M3: manifest runtime.apiVersion is the placeholder 0.0.0

`companion/manifest.json:24`

`runtime.apiVersion` is `"0.0.0"`, a placeholder rather than the API generation the module targets. Bitfocus tooling uses this field for compatibility gating; other 2.x modules declare a real value (typically `"1.0.0"`).

**Fix (maintainer):** Set `runtime.apiVersion` to the actual supported API generation (typically `"1.0.0"` for a current `node22` / base 2.x module).

---

## 🟢 Low

### L1: Overlay feedback matching depends on unconfirmed server index semantics

`src/feedbacks.ts:57-61` vs `src/actions.ts:138` and `src/presets.ts:103-116`

Actions convert the 1-based UI value to 0-based and send it directly as the API `index` (`overlayActivate(n-1)`). The feedback does the same conversion (`idx = overlayIndex - 1`) and then matches against `o.index` from the parsed overlay list (`src/api.ts:186`). This is only correct if the server's `index` in `/overlay/list` is a dense 0-based grid position aligning with the value `/overlay/activate` accepts. If the list `index` is instead an arbitrary id or 1-based, the feedback will highlight the wrong button (or none) while the action still works.

**Fix (maintainer):** Confirm against a live device that the `index` returned by `/overlay/list` uses the same 0-based keying that `/overlay/activate` expects; if not, reconcile (e.g. match on array position, or document the contract).

### L2: Action POST failures are only logged, never surfaced to the operator

`src/actions.ts:27` (`err` helper) and every action callback using `.catch(err(...))`

When an action's POST fails (device gone, HTTP 4xx/5xx), the error is logged via `logError` and swallowed. The operator pressing the button sees nothing — no status change, no feedback — and the module keeps advertising whatever the last poll set. This logs rather than crashing (so non-blocking), but the operator-visible behavior is a button that silently does nothing.

**Fix (maintainer):** On action failure, additionally nudge status toward `InstanceStatus.ConnectionFailure`, or at minimum log at `warn`/`error` with the failing path so it's diagnosable. Passing the instance (or an `onError` that updates status) into `buildActionDefinitions` would let action failures surface like poll failures.

### L3: current_item_id variable mixes number and empty-string types

`src/variables.ts:31`

`current_item_id` is emitted as a number when present and `''` when null (`itemId` is `number | null`). Companion accepts both, but the mixed type can surprise expressions doing arithmetic/comparison on the variable.

**Fix (maintainer):** Emit a consistent string: `state.videocue.itemId != null ? String(state.videocue.itemId) : ''`.

### L4: Port default of 80 may not match the LiveApp Pro Inbox Server

`src/config.ts:30` (and the host default at `:23`)

The `port` field defaults to `80`, while the static-text hint tells the user to "enter the IP address and port shown in the app," implying the Inbox Server advertises a specific port. If that port is a known non-80 value, defaulting to it reduces setup friction; defaulting to 80 will silently fail for most users (compounded by H1/M2).

**Fix (maintainer):** Confirm the Inbox Server's default port and set it as the field default (or leave 80 only if that genuinely is the app default).

### L5: Boolean variables are emitted as the literal strings true/false

`src/variables.ts:28-29`

`is_playing` and `output_enabled` are published as the strings `'true'`/`'false'`. This works, but `CompanionVariableValue` accepts a boolean directly, and the matching feedbacks already expose the boolean state, so real booleans compare more naturally in expressions. Convention nit only.

**Fix (maintainer):** Optionally publish the boolean directly (`state.videocue.isPlaying`).

### L6: Overlay-list fetch failures are swallowed with no diagnostic

`src/api.ts:69`

`this.get('/overlay/list').catch(() => [])` treats the overlay list as optional (reasonable), but a persistent failure — e.g. older app firmware lacking that endpoint — yields an empty overlay list with zero logging, so overlays silently vanish with no clue why.

**Fix (maintainer):** Log at `debug` inside the `.catch` so the failure is observable without affecting the connected state.

### L7: post() ignores the response body and any API-level error payload

`src/api.ts:155-163`

`post()` checks only `res.ok` (HTTP status). If the LiveApp API can return HTTP 200 with an error/`success:false` JSON body, the action is reported as succeeded. Acceptable if the API always signals failure via HTTP status codes.

**Fix (maintainer):** Confirm the API's error contract; if failures are encoded in the body, parse and throw on `success:false`.

---

## 💡 Nice to Have

### N1: Number() coercion of options can produce NaN with no guard

`src/actions.ts:99, 138, 156, 174`

With `type: 'number'` option fields the value is normally numeric, but if an option is ever undefined/non-numeric (e.g. an imported or malformed config), `Number(undefined)` → `NaN` is sent in the JSON body.

**Fix (maintainer):** Guard with `if (!Number.isFinite(n)) return` before posting.

---

## Reviewer notes (not findings)

The following were checked and are **correct** for the installed `@companion-module/base` 2.0.4 — recorded so they aren't re-raised:

- **`useVariables: true` on "Load Item by Name"** (`src/actions.ts:75,79`) reading `action.options.name` directly is **correct**. In 2.0.4 the action callback context (`CompanionActionContext`) has **no** `parseVariablesInString`; the framework resolves variable/expression option values *before* invoking the callback. (An initial reviewer pass flagged this as a bug — verified against the installed types as a false positive.)
- The v2.0.4 API shapes used here are all valid: default-export class + `export const UpgradeScripts = []` (no `runEntrypoint`); 3-arg `init(config, isFirstInit, secrets)`; two-arg `setPresetDefinitions(structure, presets)` with `CompanionPresetSection[]` and `type: 'simple'` presets; object-form `setVariableDefinitions`; `checkAllFeedbacks()`.
- `destroy()` clears the poll timer; `configUpdated()` correctly stops, resets, re-targets, and restarts. Every fetch has a 3000ms `AbortSignal.timeout`. `parseState()` defensively coerces all untrusted hardware JSON.
- The empty `UpgradeScripts` array is correct and required for a first release.
- The deterministic `MAN-IDNAME` check (manifest `id` ≠ `name`) does **not** apply here: `id` is the slug and `name` is the display name, which are supposed to differ (consistent with approved modules like `biamp-qtx` → "Qt X"). Excluded as a false positive.
