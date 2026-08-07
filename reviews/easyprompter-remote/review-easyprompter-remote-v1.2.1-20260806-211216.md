# Review — companion-module-easyprompter-remote v1.2.1

| | |
|---|---|
| **Module** | easyprompter-remote |
| **Review tag** | v1.2.1 |
| **Previous tag** | (none — no previously approved release) |
| **Scope** | `tag` |
| **Language / API** | TypeScript · @companion-module/base ^2.0.0 (v2, resolved 2.1.1) |
| **Protocols** | socket.io-client 4.8.3 (WebSocket) + one HTTPS `fetch` |
| **Reviewed** | 2026-08-06 |

> **Scope note:** Requested scope was `tag`, but the registry reports **no previously approved release** — v1.1.0 was reviewed and returned as *Changes Required*, never approved. With no approved baseline to diff against, this falls back to a **full-module review**, and every finding is classified 🆕 NEW. Where a finding restates one from the v1.1.0 review, that is noted inline.
>
> **Follow-up note:** This is a re-review. The v1.1.0 findings were verified one by one against the current source — see [🔁 v1.1.0 Follow-up](#-v110-follow-up). **12 of 20 prior findings are fixed**, including every blocking one from the previous round except the template/config cluster.
>
> **Protocol note:** The registry metadata still lists **OSC**, which is wrong — there is no OSC / `dgram` / `net` code anywhere in `src/`. The transport is socket.io (WebSocket) plus one HTTPS `fetch` for the script list.
>
> **Build gate:** `yarn install --immutable`, `yarn package`, and `yarn lint` all **pass**. (v1.1.0's `yarn lint` failed outright — that is fixed.)
>
> **Dismissed validator findings:** two deterministic findings were re-checked against the authoritative template and are **not** carried into this review. `eslint.config.mjs` — the module's `generateEslintConfig({ enableTypescript: true })` one-liner is semantically identical to the template's multi-line call (same import, same single option); cosmetic only. `LICENSE` — still the exact MIT text; only the copyright line differs (`2025 EasyPrompter`), which is appropriate for a third-party-maintained module.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 4 | 0 | 4 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 11 | 0 | 11 |
| 🟢 Low | 15 | 0 | 15 |
| 💡 Nice to Have | 5 | 0 | 5 |
| **Total** | **36** | **0** | **36** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- I am seeing some csting to unknown for things that have a type in Companion.  The Companion modules are all strongly typed so you should not have to do casting to unknown or any for things like actions, feedbacks, variables, secrets, configs, etc.
- [ ] [C1: .yarnrc.yml is missing the required supply-chain keys](#c1-yarnrcyml-is-missing-the-required-supply-chain-keys)
- [ ] [C2: package.json missing engines and packageManager](#c2-packagejson-missing-engines-and-packagemanager)
- [ ] [C3: tsconfig chain is inverted and does not extend the tools preset](#c3-tsconfig-chain-is-inverted-and-does-not-extend-the-tools-preset)
- [ ] [C4: .prettierignore diverges from the template](#c4-prettierignore-diverges-from-the-template)
- [ ] [H1: refreshScripts has no in-flight guard and is never cancelled](#h1-refreshscripts-has-no-in-flight-guard-and-is-never-cancelled)
- [ ] [H2: InstanceBase used without the v2 InstanceTypes generic](#h2-instancebase-used-without-the-v2-instancetypes-generic)
- [ ] [H3: manifest.json hardcodes the version and omits the schema key](#h3-manifestjson-hardcodes-the-version-and-omits-the-schema-key)
- [ ] [H4: Pre-Event diagnostics logged at info level flood the connection log](#h4-per-event-diagnostics-logged-at-info-level-flood-the-connection-log)
- [ ] [H5: Help.md does not need the list of actions / variables/ feedbacks / presets](#h5-helpmd-does-not-need-the-actions-variables-feedback-and-presets-listed)
- [ ] [H6: HELP.md documents a different server URL than the config default](#h6-helpmd-documents-a-different-server-url-than-the-config-default)
- [ ] [H7: UpgradeScripts declared inline instead of src/upgrades.ts](#h7-upgradescripts-declared-inline-instead-of-srcupgradests)

**Non-blocking**

- [ ] [M1: Listener notifications are unguarded, so a throwing listener kills the module](#m1-listener-notifications-are-unguarded-so-a-throwing-listener-kills-the-module)
- [ ] [M2: Sticky _lastErrorCode can permanently disable reconnection](#m2-sticky-_lasterrorcode-can-permanently-disable-reconnection)
- [ ] [M4: Prompter state is never reset when the link drops or the session ends](#m4-prompter-state-is-never-reset-when-the-link-drops-or-the-session-ends)
- [ ] [M6: configUpdated can wipe the stored integration key](#m6-configupdated-can-wipe-the-stored-integration-key)
- [ ] [M7: A partial timer_update blanks the displayed clocks to 00:00](#m7-a-partial-timer_update-blanks-the-displayed-clocks-to-0000)
- [ ] [M8: Integration key is sent in the WebSocket query string as well as the auth payload](#m8-integration-key-is-sent-in-the-websocket-query-string-as-well-as-the-auth-payload)
- [ ] [M10: Script feedbacks carry no options and depend on the load_script subscribe map](#m10-script-feedbacks-carry-no-options-and-depend-on-the-load_script-subscribe-map)
- [ ] [L1: Connecting status is set and immediately overwritten](#l1-connecting-status-is-set-and-immediately-overwritten)
- [ ] [L2: Script list is not refreshed after a transport reconnect](#l2-script-list-is-not-refreshed-after-a-transport-reconnect)
- [ ] [L4: Numeric action options are cast, not coerced](#l4-numeric-action-options-are-cast-not-coerced)
- [ ] [L5: ConnectionFailure carries no message and the error code is cleared too early](#l5-connectionfailure-carries-no-message-and-the-error-code-is-cleared-too-early)
- [ ] [L7: Socket-creation catch drops a live socket without closing it](#l7-socket-creation-catch-drops-a-live-socket-without-closing-it)
- [ ] [L8: refreshScripts swallows every failure without touching InstanceStatus](#l8-refreshscripts-swallows-every-failure-without-touching-instancestatus)
- [ ] [L14: activeDisplayName and activeDisplayColor are parsed but never surfaced](#l14-activedisplayname-and-activedisplaycolor-are-parsed-but-never-surfaced)
- [ ] [N1: Dead code — ConnectionManager is never used](#n1-dead-code--connectionmanager-is-never-used)
- [ ] [N2: Maintainer entry has no email or github](#n2-maintainer-entry-has-no-email-or-github)
- [ ] [N4: load_script dropdown has no allowCustom](#n4-load_script-dropdown-has-no-allowcustom)
- [ ] [N5: jog_tick direction values are 1 and -1](#n5-jog_tick-direction-values-are-1-and--1)

---

## 🔁 v1.1.0 Follow-up

Every finding from the v1.1.0 review, re-verified against the v1.2.1 source.

| Prior | Status | Evidence |
|---|---|---|
| **C1** `@companion-module/tools` should be v3 | ✅ **Fixed** | `package.json` devDep `^3.0.0`, resolves 3.0.2 |
| **C2** lint/format/husky toolchain stripped | ✅ **Fixed** | `eslint.config.mjs`, `.prettierignore`, `.husky/pre-commit` restored; all five devDeps, `format`/`postinstall` scripts, `prettier` field and `lint-staged` block present. `yarn lint` now passes |
| **C3** missing `engines` / `packageManager` / `build:main` | ⚠️ **Partially fixed** | `build:main` added; `engines` and `packageManager` still missing → **[C2](#c2-packagejson-missing-engines-and-packagemanager)** |
| **C4** `.yarnrc.yml` missing | ⚠️ **Partially fixed** | File added with `nodeLinker`, but the supply-chain keys are absent → **[C1](#c1-yarnrcyml-is-missing-the-required-supply-chain-keys)** |
| **C5** `.gitattributes` missing | ✅ **Fixed** | `* text=auto eol=lf` |
| **C6** `tsconfig.build.json` exclude differs | ❌ **Still open** | Now `["node_modules", "dist"]`, still no spec/`__tests__`/`__mocks__`; extends chain also inverted → **[C3](#c3-tsconfig-chain-is-inverted-and-does-not-extend-the-tools-preset)** |
| **H1** TLS validation disabled unconditionally | ✅ **Fixed** | `rejectUnauthorized` is gone from `src/`; `io()` options at `src/remote-client/connection.ts:203-222` are now default-secure |
| **H2** API key logged / plain textinput | ✅ **Fixed** | `src/config.ts:30-35` uses `type: 'secret-text'` via the secrets store; no key prefix logged anywhere |
| **M1** fetch has no timeout / inconsistent TLS | ✅ **Fixed** | `src/index.ts:422` `signal: AbortSignal.timeout(10_000)`; TLS consistent on both paths |
| **M2** `connect()` swallows socket-creation errors | ✅ **Fixed** | `src/remote-client/connection.ts:469-473` now calls `setConnectionState('error')` (residual: the orphaned socket isn't closed → **[L7](#l7-socket-creation-catch-drops-a-live-socket-without-closing-it)**) |
| **M3** `connect_error` always reconnects | ✅ **Fixed** | `src/remote-client/connection.ts:252-274` reads `err.data.code`, matches `PERMANENT_ERROR_CODES`, transitions to `'error'` without rescheduling |
| **M4** missing config → Disconnected not BadConfig | ✅ **Fixed** | `src/index.ts:110, 123` both use `InstanceStatus.BadConfig` |
| **M6** `InstanceBase` without config generic | ❌ **Still open** | `src/index.ts:33` still bare; double casts at `:80-82` and `:115-117` → **[H2](#h2-instancebase-used-without-the-v2-instancetypes-generic)** |
| **L1** Connecting status overwritten | ❌ **Still open** | Ordering at `src/index.ts:251` vs `:254-261` unchanged → **[L1](#l1-connecting-status-is-set-and-immediately-overwritten)** |
| **L2** `set_speed` / `shuttle_set` NaN risk | ✅ **Fixed** | `src/actions.ts:90` `?? 150`, `:164` `?? 0.5` (residual non-numeric case → **[L4](#l4-numeric-action-options-are-cast-not-coerced)**) |
| **L3** speed debounce uses a stale base | ❌ **Still open** | `src/index.ts:226` still computes from `this.currentSpeed`, which only advances on the server echo (`:267`) |
| **L4** no guard against `connect()` while connected | ✅ **Fixed** | `src/index.ts:234-237` early `disconnect()` |
| **L5** stale timer sync after session end | ⚠️ **Partially fixed** | `_timerSyncTimer` is cleared in `disconnect()` (`src/index.ts:504-513`), but that code already existed in v1.1.0. `session_ended` moves state to `waiting`, not disconnect, and nothing in the state listener clears the timer → **[M4](#m4-prompter-state-is-never-reset-when-the-link-drops-or-the-session-ends)** |
| **N1** dead `ConnectionManager` | ❌ **Still open** | `src/remote-client/manager.ts` still only re-exported → **[N1](#n1-dead-code--connectionmanager-is-never-used)** |
| **N2** weak 32-bit clientId hash | ❌ **Still open** | `src/remote-client/connection.ts:41-59` unchanged |

**Summary:** 12 fixed · 3 partially fixed · 5 still open.

---

## 🔴 Critical

### C1: .yarnrc.yml is missing the required supply-chain keys

**Classification:** 🆕 NEW · **File:** `.yarnrc.yml` (`CONFIG-DIFF`)

The file was added since v1.1.0, but only carries `nodeLinker`. The template's supply-chain hardening keys are absent, and two non-template keys were added:

- **Missing:** `enableScripts: false`, `npmMinimalAgeGate: 3d`, `npmPreapprovedPackages: ["@companion-module/*"]`
- **Extra:** `npmRegistryServer`, `useTelemetry`

Without `enableScripts: false`, dependency install scripts still run during the Companion build; `npmMinimalAgeGate` is Bitfocus' guard against freshly-published malicious package versions.

**Found:**

```yaml
nodeLinker: node-modules
npmRegistryServer: 'https://registry.npmjs.org'
useTelemetry: false
```

**Template:**

```yaml
nodeLinker: node-modules
enableScripts: false
npmMinimalAgeGate: 3d
npmPreapprovedPackages:
  - "@companion-module/*"
```

**Fix (maintainer):** Replace `.yarnrc.yml` with the template's contents. `npmRegistryServer` is already the default and `useTelemetry` is not part of the template — drop both unless you have a specific reason to keep them.

### C2: package.json missing engines and packageManager

**Classification:** 🆕 NEW · **File:** `package.json` (`PKG-FIELD` ×2) · *carried from prior C3*

Both fields are still absent. `packageManager` is the one that bites: without it, `yarn` in a fresh clone resolves to whatever Yarn is on `PATH` (Yarn 1 classic here) instead of the pinned Yarn 4, so contributors and CI can silently produce a different lockfile than the one committed.

**Fix (maintainer):** Add from `companion-module-template-ts`:

```json
"engines": {
    "node": "^22.20",
    "yarn": "^4"
},
"packageManager": "yarn@4.17.0"
```

### C3: tsconfig chain is inverted and does not extend the tools preset

**Classification:** 🆕 NEW · **Files:** `tsconfig.json`, `tsconfig.build.json` (`CONFIG-DIFF` ×2) · *carried from prior C6*

The module inverts the template's layout: `tsconfig.json` declares compiler options inline and `tsconfig.build.json` extends **it**. The template does the opposite — `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json` and `tsconfig.json` extends `./tsconfig.build.json`. Consequences:

- **`moduleResolution: "bundler"`** instead of the preset's `nodenext`. v2 compliance requires `nodenext` or the tools preset. `bundler` does not enforce the explicit `.js` import specifiers that Node ESM needs at runtime — the code happens to use them today, so the build passes, but nothing keeps it that way.
- **`verbatimModuleSyntax` is lost**, along with the rest of the preset's node22 settings, and the module silently opts out of future preset updates.
- **`"exclude": ["node_modules", "dist"]`** still omits `src/**/*spec.ts`, `src/**/__tests__/*`, `src/**/__mocks__/*`, so any test files added later would be compiled into `dist`.

**Fix (maintainer):** Adopt the template layout verbatim — `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json` with only `outDir`, `rootDir`, `verbatimModuleSyntax` plus the template's `exclude` array; `tsconfig.json` extends `./tsconfig.build.json` and adds `"types": ["node"]`. Then re-run `yarn build` and fix any import specifiers the stricter resolution surfaces.

### C4: .prettierignore diverges from the template

**Classification:** 🆕 NEW · **File:** `.prettierignore` (`CONFIG-DIFF`)

**Found:** `dist`, `pkg`, `node_modules` — **Template:** `package.json`, `/LICENSE.md`

The module's own entries are reasonable, but dropping the template's means `yarn format` will reformat `package.json` (which Bitfocus deliberately excludes, since its formatting is managed by the package manager).

**Fix (maintainer):** Use the union — keep `dist`, `pkg`, `node_modules` and add `package.json` and `/LICENSE.md`.

---

## 🟠 High

### H1: refreshScripts has no in-flight guard and is never cancelled

**Classification:** 🆕 NEW · **File:** `src/index.ts:397-401, 407, 413-481`

`refreshScripts()` fetches the script list and then unconditionally writes module state, but nothing bounds or cancels it:

- **`configUpdated()`** (`src/index.ts:114-125`) reassigns `this.config`, calls `disconnect()`, then `connect()` → `void this.refreshScripts()`. A refresh already in flight against the **previous** server/key keeps running (up to its 10 s abort timeout) and, on resolution, overwrites `this.cachedScripts` (`:448`), calls `setActionDefinitions` / `setFeedbackDefinitions` (`:451-452`) and can resolve `this.currentScriptId` from the old server's list (`:456-464`).
- **`destroy()`** (`:127-130`) doesn't abort it either, so the same writes — plus `checkFeedbacks` and `log` — land on a destroyed instance.
- **`onScriptsChanged`** (`:398`) fires an unguarded refresh per server event, so a burst of `scripts_changed` produces overlapping fetches that can settle out of order.

The operator-visible failure: after changing the server or key, the `load_script` dropdown offers scripts that don't exist on the new server, and `startScriptLoad()`'s "already loaded" short-circuit (`:157-169`) can match a stale `currentScriptId` — so pressing **Load Script** sends nothing at all, with no error.

**Fix (maintainer):** Hold an `AbortController` on the instance, pass `AbortSignal.any([controller.signal, AbortSignal.timeout(10_000)])`, and abort it in `disconnect()` / `destroy()`. Additionally bump a `private _configEpoch` in `init` / `configUpdated`, capture it at the top of `refreshScripts()`, and `return` after the `await` if it no longer matches. Collapse bursty `scripts_changed` events with a short (~250 ms) trailing debounce.

### H2: InstanceBase used without the v2 InstanceTypes generic

**Classification:** 🆕 NEW · **File:** `src/index.ts:33` (with `:79-82`, `:114-117`) · *prior M6*

`extends InstanceBase` is still bare, forcing `config as unknown as EasyPrompterConfig` and `secrets as unknown as EasyPrompterSecrets` in both `init` and `configUpdated`. Beyond the casts, this forfeits all v2 type safety on `setActionDefinitions` / `setFeedbackDefinitions` / `setVariableDefinitions` / `setVariableValues` — a typo'd variable id compiles clean and only surfaces as a Companion runtime warning.

**Fix (maintainer):** Declare an `InstanceTypes`-shaped schema (`config`, `secrets`, `variables`, `actions`, `feedbacks`) and use it: `class EasyPrompterModule extends InstanceBase<EasyPrompterSchema>`, with `init(config: EasyPrompterConfig, isFirstInit: boolean, secrets: EasyPrompterSecrets)` and the matching `configUpdated` signature. Delete the `as unknown as` casts.

### H3: manifest.json hardcodes the version and omits the schema key

**Classification:** 🆕 NEW · **File:** `companion/manifest.json:10` (and missing `$schema`)

`"version": "1.2.1"` is hand-maintained. The template ships `"version": "0.0.0"` because the store build injects the released version — keeping it by hand means it silently drifts from `package.json` and the git tag on some future release. The manifest also lacks the template's `"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"`, which gives editor-time validation.

**Fix (maintainer):** Set `version` back to `0.0.0` and add the `$schema` key as the first entry.

### H4: Per-event diagnostics logged at info level flood the connection log

**Classification:** 🆕 NEW · **File:** `src/index.ts:165, 353, 375-378, 383, 386, 461-477` (with `src/remote-client/connection.ts:284, 290-293, 402-409`)

Several per-event traces log at `info`: a full `JSON.stringify` of `session_joined`, `Script info received: {…}` on every `settings_update` that carries a title, two `[LoadScript]` lines per `scriptInfo`, and a refresh summary on every fetch. Compounding it, `connection.ts` notifies script-info listeners on **every** settings payload containing `scriptTitle` without comparing to the previous value — so dragging a font-size slider floods the log at the settings-update rate.

**Fix (maintainer):** Demote these to `debug` and keep `info` for lifecycle transitions only (connecting, connected, session ended). Also only call `notifyScriptInfoListeners()` when a field actually changed.

### H5: HELP.md does not need the actions, variables, feedback, and presets listed

**Classification:** 🆕 NEW · **File:** `companion/HELP.md`

The help.md does not need the list of actions, presets, variables, and feedbacks.  A user of the module can find those within Companion.  The help.md should be about configuring, using, and troubleshooting the module.

**Fix (maintainer):** Remove the actions, presets, variables and feedbacks from help.md

### H6: HELP.md documents a different server URL than the config default

**Classification:** 🆕 NEW · **File:** `companion/HELP.md:10` vs `src/config.ts:28`

HELP tells the user to enter `https://app.easyprompter.com`; the config field default is `https://easyprompter.com`. One of the two is wrong, and users will paste the documented host over a working default.

**Fix (maintainer):** Make HELP match the shipped default, and note explicitly when a different host applies.

### H7: UpgradeScripts declared inline instead of src/upgrades.ts

**Classification:** 🆕 NEW · **File:** `src/index.ts:602`

`UpgradeScripts` is an empty array declared inline in the entry file. Correct for a first release, but the template keeps it in `src/upgrades.ts`.

**Fix (maintainer):** Move it to `src/upgrades.ts` and re-export.  It should also be typed

---

## 🟡 Medium

### M1: Listener notifications are unguarded, so a throwing listener kills the module

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:569-580, 585-594, 599-610, 615, 621-624, 629-632`

`notifyScriptsChangedListeners()` (`:634-642`) wraps each listener in `try/catch` — the other five notify paths do not. `notifyStateListeners` / `notifyTimerListeners` invoke listeners from inside a `setTimeout` callback, so a throw there has **no catch anywhere up the stack**; `@companion-module/base` registers no `process.on('uncaughtException')` handler, so the module process dies and the operator loses the connection. `notifySettingsListeners` / `notifyScriptInfoListeners` run synchronously inside socket.io handlers, where a throw escapes the event handler.

This is reachable in practice: the module's listeners call `setVariableValues` / `checkFeedbacks` / `log`, which can throw once the IPC channel is torn down, and a malformed server payload can trip a listener.

**Fix (maintainer):** Apply the same per-listener `try/catch` + `this.logger.error(...)` pattern used in `notifyScriptsChangedListeners()` to all five remaining notify methods.

### M2: Sticky _lastErrorCode can permanently disable reconnection

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:333-338` (with `:234-247`)

The `error` handler stores `data.code` in `_lastErrorCode` indefinitely; it is only read and cleared in the `disconnect` handler. If the server emits a permanent code (e.g. `CONNECTION_LIMIT_REACHED`) **without** immediately dropping the socket, that code survives an arbitrarily long healthy session and is then consumed by the *next*, unrelated disconnect — a Wi-Fi blip or a server restart. The module calls `setConnectionState('error')`, returns without `scheduleReconnect()`, and sits in `ConnectionFailure` forever until the user edits the config.

**Fix (maintainer):** Clear `this._lastErrorCode = null` on the successful-auth events (`connect`, `waiting_for_session`, `session_joined`, `session_state`), or stamp the code with a timestamp and only honour it if it arrived within a second or two of the disconnect.

### M4: Prompter state is never reset when the link drops or the session ends

**Classification:** 🆕 NEW · **File:** `src/index.ts:255-260` (with `src/remote-client/connection.ts:229-233, 319-331`)

The module's connection-state listener updates `connectionState`, the status variable and `checkFeedbacks('is_connected', 'is_waiting')` — nothing else. So:

- On an unexpected socket `disconnect`, `connection.ts:231-232` sets state `disconnected` and nulls `_lastState` **without** flushing a stopped state. `this.isPlaying` (`index.ts:266`), the `is_playing` variable, `speed` and `isBlackout` all keep their last values — the Play button stays green and the speed still reads `150` while the module is offline.
- On `session_ended`, `connection.ts:327-330` nulls `_lastScriptInfo` / `_lastSettings` without notifying, so `script_title`, `script_id`, the green `is_active_script` bar and `blackout` stay stale.
- `_timerSyncTimer` isn't cleared either, so a buffered pair still posts ~600 ms after the session ends (this is the unfixed half of prior L5).

The module's reset logic lives in `disconnect()` (`:496-543`), which only runs on `configUpdated` / `destroy` — never on a network drop.

**Fix (maintainer):** In the connection-state listener, when `state !== 'active'`: reset `isPlaying = false` and `isBlackout = false`, push `is_playing: 'Paused'`, `speed: '—'`, `blackout: 'OFF'`, clear `_timerSyncTimer` and the `_pending*` fields, and call `checkFeedbacks('is_playing', 'is_blackout', ...SCRIPT_FEEDBACKS)`.

### M6: configUpdated can wipe the stored integration key

**Classification:** 🆕 NEW · **File:** `src/index.ts:114-117` (same shape at `:82`)

`this.config = { serverUrl: c?.serverUrl ?? '', apiKey: s?.apiKey ?? '' }` — the `secrets` parameter is optional (`secrets?: Record<string, unknown>`, and `InstanceTypes['secrets']` is `JsonObject | undefined`). If Companion calls `configUpdated` without re-sending unchanged secrets — a common secret-store design — then editing only the Server URL blanks `apiKey`, drops the module to `BadConfig` and disconnects it until the user retypes the key.

**Fix (maintainer):** Only overwrite the key when one is actually supplied — `apiKey: typeof s?.apiKey === 'string' ? s.apiKey : this.config.apiKey` — and log a warning when falling back.

### M7: A partial timer_update blanks the displayed clocks to 00:00

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:345-354` (with `src/index.ts:286-289`)

The handler builds a fresh `TimerData` and overwrites `_lastTimer` wholesale, so any field the server omits (or sends with the wrong type) becomes `undefined`. The module then coerces with `data.elapsed ?? '00:00'` / `data.remaining ?? '00:00'`, and because both values "changed" it takes the immediate-push branch (`index.ts:297-305`) — blanking the operator's running timers to `00:00`. A progress-only ping is enough to trigger this. Note that `_lastSettings` (`:387-395`) and `_lastScriptInfo` (`:403-407`) already merge correctly; only the timer path replaces.

**Fix (maintainer):** Merge instead of replace — `this._lastTimer = { ...this._lastTimer, ...(elapsed !== undefined ? { elapsed } : {}), … }` — matching the settings/script-info pattern.

### M8: Integration key is sent in the WebSocket query string as well as the auth payload

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:205-212`

The key is sent twice: in `auth` (the handshake payload — correct) and in `query`, which places it in the WebSocket upgrade URL. Query strings are routinely written to reverse-proxy, CDN and server access logs in plaintext even over TLS, which partially undoes the v1.2.0 move to `secret-text` storage.

**Fix (maintainer):** Send `apiKey` in `auth` only, keeping `clientId` / `clientType` in `query`. This may require a small server-side change if the handshake currently reads the key from the query.

### M10: Script feedbacks carry no options and depend on the load_script subscribe map

**Classification:** 🆕 NEW · **File:** `src/feedbacks.ts:64-109` (with `src/actions.ts:350-359`)

The three script feedbacks (`is_active_script`, `is_loading_script`, `is_failed_script`) declare no options and resolve their script solely through `instance.subscribedScripts`, a `Map<controlId, scriptId>` populated by the `load_script` action's `subscribe`. Three consequences:

- A control with more than one `load_script` action (two steps, or down + up) collapses to a single map entry — last `subscribe` wins, and the status bar shows the wrong script.
- The feedbacks are silently inert on any button without a `load_script` action, so they can't be used on a standalone status/indicator button.
- The behaviour depends on invisible action state, which is hard for a user to reason about.

**Fix (maintainer):** Give each of the three feedbacks its own `scriptId` dropdown option (same `choices` as the action) and read `feedback.options.scriptId`, keeping the `subscribedScripts` lookup only as a fallback when the option is empty. With no approved store release yet, this needs no upgrade script — doing it now avoids writing one later.

---

## 🟢 Low

### L1: Connecting status is set and immediately overwritten

**Classification:** 🆕 NEW · **File:** `src/index.ts:251` vs `:254-261` · *prior L1*

`updateStatus(InstanceStatus.Connecting)` runs at `:251`, then the `onConnectionStateChange` subscription at `:255` replays the current state synchronously (`src/remote-client/connection.ts:138`), which is `'disconnected'` → `updateStatus(Disconnected)`. The operator sees *Disconnected* for the whole connect window and during every backoff. `ConnectionState` has no `'connecting'` member (`src/remote-client/types.ts:16`), so *Connecting* is never visible at all.

**Fix (maintainer):** Move the `Connecting` update to after the subscription is wired, or add a `'connecting'` member to `ConnectionState` that `connect()` / `scheduleReconnect()` set and `updateCompanionStatus` maps to `InstanceStatus.Connecting`.

### L2: Script list is not refreshed after a transport reconnect

**Classification:** 🆕 NEW · **File:** `src/index.ts:404-407` (with `src/remote-client/connection.ts:547-551`)

`refreshScripts()` runs only on module `connect()` and on `scripts_changed`. Transport reconnects go through `scheduleReconnect()` → `connection.connect()`, which never re-triggers the fetch. If the first fetch fails — server down at Companion startup, exactly the case that also fails the socket — the `load_script` dropdown stays empty for the lifetime of the instance even after the socket recovers.

**Fix (maintainer):** Trigger `void this.refreshScripts()` from the connection-state listener on the transition into `'waiting'` / `'active'`, guarded against duplicates, instead of once at connect time.

### L4: Numeric action options are cast, not coerced

**Classification:** 🆕 NEW · **File:** `src/actions.ts:54, 72, 90, 109, 136, 164, 203, 222, 241, 260, 279, 307, 326` · *residual of prior L2*

Every numeric option uses `(action.options.x as number) ?? default`. `??` catches only `null` / `undefined` — a `NaN` or a string (possible when an option is fed from an expression or an imported config) survives the cast, and `Math.min(MAX, NaN)` → `NaN` is emitted as `speedWpm` / `displacement` / `delta`. In `queueSpeedChange` a string step would make `this._speedDelta += delta` do string concatenation (`src/index.ts:217`).

**Fix (maintainer):** Add a helper — `const num = (v: unknown, d: number) => { const n = Number(v); return Number.isFinite(n) ? n : d }` — and route all numeric options through it before clamping.

### L5: ConnectionFailure carries no message and the error code is cleared too early

**Classification:** 🆕 NEW · **File:** `src/index.ts:560-562` (with `src/remote-client/connection.ts:234-235, 243-246, 266-269, 472`)

`case 'error': this.updateStatus(InstanceStatus.ConnectionFailure)` passes no message, so a revoked key, a connection-limit rejection and a malformed server URL all present as the same bare red state. Worse, the `disconnect` handler nulls `_lastErrorCode` (`:235`) *before* the permanent-error branch, so the public `lastErrorCode` getter is already `null` by the time the module could read it.

**Fix (maintainer):** Keep the permanent code in a separate field (e.g. `_permanentErrorCode`) and pass a human-readable reason into `updateStatus(InstanceStatus.ConnectionFailure, …)`. `INVALID_REMOTE_KEY` / `REMOTE_KEY_REVOKED` are configuration problems and would be better reported as `InstanceStatus.BadConfig`.

### L7: Socket-creation catch drops a live socket without closing it

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:469-473`

If `io()` succeeds but a subsequent `this.socket.on(…)` registration throws, the catch sets `this.socket = null` without calling `removeAllListeners()` or `close()`. The orphaned socket keeps retrying with the same derived `clientId` — exactly the "ghost connection" the clientId design exists to prevent — while the module believes it has no socket.

**Fix (maintainer):** Capture the socket in a local, and in the catch call `sock?.removeAllListeners()` and `sock?.close()` before nulling.

### L8: refreshScripts swallows every failure without touching InstanceStatus

**Classification:** 🆕 NEW · **File:** `src/index.ts:478-480`

A 401 from a revoked key, a DNS failure and the 10 s abort all end as a single `warn` line. The module keeps reporting `Ok` with an empty or stale `load_script` dropdown, and the "no scripts found" hint at `:443` is easy to miss.

**Fix (maintainer):** On `resp.status === 401 || 403`, call `updateStatus(InstanceStatus.BadConfig, 'Integration key rejected')`; on repeated network failure use `InstanceStatus.ConnectionFailure` with the reason.

### L14: activeDisplayName and activeDisplayColor are parsed but never surfaced

**Classification:** 🆕 NEW · **File:** `src/remote-client/types.ts:78-79`, `src/remote-client/connection.ts:365-376, 422-435`

Both fields are validated, merged into `_lastSettings` and pushed to listeners — but `src/index.ts:334-347` ignores them and `src/variables.ts` defines no matching variables. A grep outside `src/remote-client/` finds zero consumers, so only the transport half of the "active display variables" work landed.

**Fix (maintainer):** Either surface them as `active_display_name` / `active_display_color` variables (plus a colour feedback and HELP rows), or remove the parsing and the `SettingsData` fields.

---

## 💡 Nice to Have

### N1: Dead code — ConnectionManager is never used

**Classification:** 🆕 NEW · **File:** `src/remote-client/manager.ts` (re-exported at `src/remote-client/index.ts:2`) · *prior N1*

`ConnectionManager` is still defined and re-exported, but `grep -rn "ConnectionManager" src/` returns only those two lines — nothing consumes it.

**Fix (maintainer):** Delete `manager.ts` and its barrel export, or wire it up if multi-connection sharing was intended.

### N2: Maintainer entry has no email or github

**Classification:** 🆕 NEW · **File:** `companion/manifest.json:14-18`

The entry carries only `name`. Schema-valid, but the template includes `email`, and `github` is how Bitfocus and users reach a maintainer.

**Fix (maintainer):** Add `email` and/or `github`.

### N4: load_script dropdown has no allowCustom

**Classification:** 🆕 NEW · **File:** `src/actions.ts:336-343`

Without `allowCustom`, a script can't be selected from a variable or expression, which rules out trigger-driven or "load next rundown item" workflows.

**Fix (maintainer):** Consider `allowCustom: true`, treating a non-matching value as a raw script id.

### N5: jog_tick direction values are 1 and -1

**Classification:** 🆕 NEW · **File:** `src/actions.ts:186-190`

The direction choices use the values `'1'` / `'-1'`, so anyone driving the action by expression has to supply a cryptic value.

**Fix (maintainer):** Use `'forward'` / `'backward'` as the values with the same labels — safe to change now, since there is no store release to upgrade from.
