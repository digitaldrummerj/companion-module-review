# Review — companion-module-easyprompter-remote v1.1.0

| | |
|---|---|
| **Module** | easyprompter-remote |
| **Review tag** | v1.1.0 |
| **Previous tag** | (none — first release) |
| **Scope** | `tag` |
| **Language / API** | TypeScript · @companion-module/base ^2.0.0 (v2) |
| **Protocols** | socket.io (WebSocket) + one HTTP `fetch` |
| **Reviewed** | 2026-08-03 |

> **Scope note:** Requested scope was `tag`, but this is the **first release** (no previous tag, no diff), so it falls back to a **full-module review**. Every finding is classified 🆕 NEW.
>
> **Protocol note:** The registry/deps suggested "OSC / HTTP," but the actual transport is **socket.io-client (WebSocket)** for realtime control plus a single plain **HTTP `fetch`** for the script list. There is no OSC / `dgram` / `net` code in the module.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 6 | 0 | 6 |
| 🟠 High | 2 | 0 | 2 |
| 🟡 Medium | 5 | 0 | 5 |
| 🟢 Low | 5 | 0 | 5 |
| 💡 Nice to Have | 2 | 0 | 2 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: Companion Module Tools Dependency Should Be v3](#c1-companion-module-tools-dependency-should-be-v3)
- [ ] [C2: Lint/format/git-hook toolchain stripped from template (yarn lint fails)](#c2-lintformatgit-hook-toolchain-stripped-from-template-yarn-lint-fails)
- [ ] [C3: package.json missing required metadata fields and build script](#c3-packagejson-missing-required-metadata-fields-and-build-script)
- [ ] [C4: .yarnrc.yml missing](#c4-yarnrcyml-missing)
- [ ] [C5: .gitattributes missing](#c5-gitattributes-missing)
- [ ] [C6: tsconfig.build.json differs from template](#c6-tsconfigbuildjson-differs-from-template)
- [ ] [H1: TLS certificate validation disabled for all connections](#h1-tls-certificate-validation-disabled-for-all-connections)
- [ ] [H2: API key logged and stored as a plain textinput](#h2-api-key-logged-and-stored-as-a-plain-textinput)


**Non-blocking**

- [ ] [M1: Outbound fetch has no timeout and inconsistent TLS handling](#m1-outbound-fetch-has-no-timeout-and-inconsistent-tls-handling)
- [ ] [M2: connect() swallows socket-creation errors, leaving module stuck in Connecting](#m2-connect-swallows-socket-creation-errors-leaving-module-stuck-in-connecting)
- [ ] [M3: connect_error always reconnects, so permanent auth failures loop forever](#m3-connect_error-always-reconnects-so-permanent-auth-failures-loop-forever)
- [ ] [M4: Missing config reported as Disconnected instead of BadConfig](#m4-missing-config-reported-as-disconnected-instead-of-badconfig)
- [ ] [M6: InstanceBase used without config generic, forcing double casts](#m6-instancebase-used-without-config-generic-forcing-double-casts)
- [ ] [L1: Connecting status is immediately overwritten and never shown](#l1-connecting-status-is-immediately-overwritten-and-never-shown)
- [ ] [L2: set_speed / shuttle_set read numeric options without a default (NaN risk)](#l2-set_speed--shuttle_set-read-numeric-options-without-a-default-nan-risk)
- [ ] [L3: Speed debounce can drop increments from a stale base value](#l3-speed-debounce-can-drop-increments-from-a-stale-base-value)
- [ ] [L4: No guard against connect() while already connected](#l4-no-guard-against-connect-while-already-connected)
- [ ] [L5: Timer sync can push stale elapsed/remaining after session ends](#l5-timer-sync-can-push-stale-elapsedremaining-after-session-ends)
- [ ] [N1: Dead code — ConnectionManager is never used](#n1-dead-code--connectionmanager-is-never-used)
- [ ] [N2: Weak 32-bit clientId hash](#n2-weak-32-bit-clientid-hash)

---

## 🔴 Critical

### C1: Companion Module Tools dependency should be v3

The @companion-module/tools dependency should be v3.0 as that version goes with the @companion-module/base.

**Fix:** update the dependency version to match the typescript module template that can be found at [https://github.com/bitfocus/companion-module-template-ts](https://github.com/bitfocus/companion-module-template-ts)

### C2: Lint/format/git-hook toolchain stripped from template (yarn lint fails)

**Classification:** 🆕 NEW · **Files:** `eslint.config.mjs`, `.prettierignore`, `.husky/pre-commit` (all missing); `package.json` (`PKG-DEVDEP`, `PKG-SCRIPT`, `PKG-FIELD`, `PKG-LINTSTAGED`)

The entire lint/format/hook scaffold from the official TS template is absent. Deterministic checks flagged all of the following:

- **Missing required files:** `eslint.config.mjs`, `.prettierignore`, `.husky/pre-commit`
- **Missing devDependencies:** `eslint`, `prettier`, `husky`, `lint-staged`, `typescript-eslint`
- **Missing scripts:** `format`, `postinstall`
- **Missing package.json field:** `prettier`
- **Missing `lint-staged` section**

Consequence: `yarn lint` **fails** (`/bin/sh: eslint: command not found`, exit 127) because `eslint` is not installed and there is no config — the module cannot pass the lint gate.

**Fix (maintainer):** Restore the template's tooling: copy `eslint.config.mjs`, `.prettierignore`, and `.husky/pre-commit`; add the `eslint`, `prettier`, `husky`, `lint-staged`, and `typescript-eslint` devDependencies; add the `format` and `postinstall` scripts; add the `prettier` field and the `lint-staged` section to `package.json`. Match the current `companion-module-template-ts` values, then `yarn install` and confirm `yarn lint` runs clean. Module template is located at [https://github.com/bitfocus/companion-module-template-ts](https://github.com/bitfocus/companion-module-template-ts)

### C3: package.json missing required metadata fields and build script

**Classification:** 🆕 NEW · **File:** `package.json` (`PKG-FIELD`, `PKG-SCRIPT`)

Independent of the tooling cluster (C2), `package.json` is missing template-required entries:

- **Fields:** `engines`, `packageManager`
- **Script:** `build:main`

**Fix (maintainer):** Add the `engines` and `packageManager` fields and the `build:main` script from `companion-module-template-ts` (match the template's current values).

### C4: .yarnrc.yml missing

**Classification:** 🆕 NEW · **File:** `.yarnrc.yml` (missing, `FILE-MISSING`)

The repo has no `.yarnrc.yml`. The template ships one (e.g. `nodeLinker: node-modules`); without it the Companion build/packaging pipeline can default to Yarn PnP and break.

**Fix (maintainer):** Add `.yarnrc.yml` matching the template, then `yarn install` and commit the result.

### C5: .gitattributes missing

**Classification:** 🆕 NEW · **File:** `.gitattributes` (missing, `FILE-MISSING`)

The template's `.gitattributes` (line-ending / lockfile normalization) is absent.

**Fix (maintainer):** Add `.gitattributes` from `companion-module-template-ts`.

### C6: tsconfig.build.json differs from template

**Classification:** 🆕 NEW · **File:** `tsconfig.build.json` (`CONFIG-DIFF`)

The build tsconfig's `exclude` diverges from the template:

- **Found:** `"exclude": ["node_modules/**"]`
- **Template:** `"exclude": ["node_modules/**", "**/*spec.ts", "src/**/__tests__/**", "**/__mocks__/*"]`

The module's narrower exclude would compile spec/mock files into `dist` if any were added.

**Fix (maintainer):** Restore the template's `exclude` array in `tsconfig.build.json`.

---

## 🟠 High

### H1: TLS certificate validation disabled for all connections

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:205`

The socket is created with `io(this.serverUrl, { … rejectUnauthorized: false })` **unconditionally**, disabling TLS certificate verification for every connection. The default server is a public HTTPS SaaS (`https://beta.easyprompter.com`, `src/config.ts:20`), so this downgrades production connections and exposes users to man-in-the-middle interception — and the API key is sent in both `auth` and `query`. The inline comment justifies it for local mkcert dev certs, but it is always on.

**Fix (maintainer):** Default to secure (`rejectUnauthorized: true`). Gate the insecure path behind an explicit, off-by-default "Allow self-signed certificates" checkbox in `getConfigFields()`, and apply it only when the user opts in (or only for localhost / private-network hosts).

### H2: API key logged and stored as a plain textinput

**Classification:** 🆕 NEW · **File:** `src/index.ts:226`, `src/config.ts:24-27`

The API key is logged at `info` level (first 4 chars + length), and the `apiKey` config field is a plain `textinput`. Not a compliance blocker.

**Fix (maintainer):** Drop the key prefix from the log line (keep only the length if useful); optionally move `apiKey` to v2 `secrets` handling for masking.

---

## 🟡 Medium

### M1: Outbound fetch has no timeout and inconsistent TLS handling

**Classification:** 🆕 NEW · **File:** `src/index.ts:399-402` (`refreshScripts`)

`refreshScripts()` awaits `fetch(url, …)` with no timeout/`AbortController`, so a hung or slow server leaves the request pending indefinitely. It is called on connect and on every `scripts_changed`. It is wrapped in `try/catch` (no unhandled rejection), but there is no bound on the wait. Additionally, `fetch` uses default TLS validation while the socket sets `rejectUnauthorized: false` — so against a self-signed dev server the socket connects but the script dropdown silently fails to populate.

**Fix (maintainer):** Pass `signal: AbortSignal.timeout(5000-10000)` (or an `AbortController`) to `fetch`, and make its TLS behavior consistent with whatever secure/insecure decision is made for H1.

### M2: connect() swallows socket-creation errors, leaving module stuck in Connecting

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:391-394`

If `io(this.serverUrl, …)` throws synchronously (e.g. a malformed `serverUrl`), the `catch` only logs and sets `this.socket = null`. It does not call `setConnectionState("error")` and does not `scheduleReconnect()`. The caller has already set `InstanceStatus.Connecting`, so the module stays in *Connecting* forever with no recovery and nothing surfaced to the operator.

**Fix (maintainer):** In the catch, call `this.setConnectionState("error")` (or `scheduleReconnect()` for transient failures) so the state machine reflects the failure.

### M3: connect_error always reconnects, so permanent auth failures loop forever

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:237-246`

Permanent-error handling (`PERMANENT_ERROR_CODES`, e.g. `INVALID_REMOTE_KEY`) only runs in the `disconnect` handler, which requires the server to first emit an `error` event and then disconnect. A rejection that arrives as `connect_error` (e.g. a handshake auth rejection) unconditionally schedules a reconnect with generic `"disconnected"` status, producing an indefinite retry loop that never shows `ConnectionFailure`.

**Fix (maintainer):** Inspect the `connect_error` payload / `_lastErrorCode` and transition to `"error"` for permanent auth failures instead of always reconnecting.

### M4: Missing config reported as Disconnected instead of BadConfig

**Classification:** 🆕 NEW · **File:** `src/index.ts:102, 113`

When `serverUrl` / `apiKey` are empty the module sets `InstanceStatus.Disconnected, "Missing configuration"`. Companion convention is `InstanceStatus.BadConfig` so the UI flags it as a configuration problem. (A permanently invalid/revoked key also maps to `ConnectionFailure` via `connection.ts:230`; `BadConfig` would be more accurate there too, but that is minor.)

**Fix (maintainer):** Use `InstanceStatus.BadConfig` for the missing-config branches.

### M6: InstanceBase used without config generic, forcing double casts

**Classification:** 🆕 NEW · **File:** `src/index.ts:26`

`extends InstanceBase` is used without the config generic, forcing `this.config = config as unknown as EasyPrompterConfig` in both `init` (`:74`) and `configUpdated` (`:107`) and typing the params as `Record<string, unknown>`.

**Fix (maintainer):** Declare `extends InstanceBase<EasyPrompterConfig>` and type `init(config: EasyPrompterConfig, …)` / `configUpdated(config: EasyPrompterConfig)`, dropping the double casts.

---

## 🟢 Low

### L1: Connecting status is immediately overwritten and never shown

**Classification:** 🆕 NEW · **File:** `src/index.ts:234` vs `:237-246`

`connect()` sets `InstanceStatus.Connecting`, then subscribes to `onConnectionStateChange`, which fires synchronously with the current state `"disconnected"` (`connection.ts:124`) → `updateStatus(Disconnected)`. The operator sees *Disconnected* during the connect window instead of *Connecting*.

**Fix (maintainer):** Set `Connecting` after wiring the subscription, or suppress the initial synchronous replay for the `"disconnected"` state.

### L2: set_speed / shuttle_set read numeric options without a default (NaN risk)

**Classification:** 🆕 NEW · **File:** `src/actions.ts:93, 167`

Unlike the other numeric actions, `set_speed` and `shuttle_set` read `options.x as number` with no `?? default`. If the option is ever `undefined`, `Math.min(MAX, undefined)` yields `NaN`, which is then sent as `speedWpm` / `displacement`.

**Fix (maintainer):** Add `?? 150` / `?? 0.5` before clamping, matching the pattern used elsewhere.

### L3: Speed debounce can drop increments from a stale base value

**Classification:** 🆕 NEW · **File:** `src/index.ts:197-213`

`queueSpeedChange` computes `this.currentSpeed + d`, but `currentSpeed` only advances when the server echoes back. Rapid presses spanning multiple 80ms debounce windows before the echo each compute from the same stale base and re-send the same target (e.g. two "+5" presses both send 155 instead of reaching 160).

**Fix (maintainer):** Optimistically update `this.currentSpeed` to the sent value after emitting `set_speed`, then let server echoes correct it.

### L4: No guard against connect() while already connected

**Classification:** 🆕 NEW · **File:** `src/index.ts:217`

`connect()` overwrites `this.connection` and pushes more `unsubscribers` without tearing down an existing connection. Currently unreachable (both call sites precede it with `disconnect()`), but it is a latent leak if a future caller invokes it directly.

**Fix (maintainer):** Early-return or call `disconnect()` if `this.connection` is non-null.

### L5: Timer sync can push stale elapsed/remaining after session ends

**Classification:** 🆕 NEW · **File:** `src/index.ts:299-309`

On `session_ended` the connection nulls `_lastTimer`, but the module's 600ms `_timerSyncTimer` is not cleared there, so a buffered pair can post ~600ms after the session ended. Cosmetic only.

**Fix (maintainer):** Clear `_timerSyncTimer` when connection state leaves `"active"`.


---

## 💡 Nice to Have

### N1: Dead code — ConnectionManager is never used

**Classification:** 🆕 NEW · **File:** `src/remote-client/manager.ts`

`ConnectionManager` (and `disconnectAllExcept` / `removeConnection`) is never imported by `src/index.ts`, which uses `EasyPrompterConnection` directly. Not a runtime bug.

**Fix (maintainer):** Remove the unused manager, or wire it up if it was intended.

### N2: Weak 32-bit clientId hash

**Classification:** 🆕 NEW · **File:** `src/remote-client/connection.ts:36-49` (`deriveClientId`)

The derived UUID drops the chars at hash indices 12 and 16 (valid UUID, reduced entropy) and the underlying `hash` is a 32-bit value, so distinct API keys could in principle derive the same `clientId`. Since the clientId is meant to prevent ghost connections, a collision across two different keys could cause one to evict the other. Very low likelihood.

**Fix (maintainer):** Use a wider hash (or a stored random UUID) for `clientId` derivation.
