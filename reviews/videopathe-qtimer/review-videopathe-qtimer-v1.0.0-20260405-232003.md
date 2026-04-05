# Review: companion-module-videopathe-qtimer v1.0.0

| Field | Value |
|-------|-------|
| **Module** | `companion-module-videopathe-qtimer` |
| **Version** | `1.0.0` |
| **Previous Version** | N/A — first release |
| **API** | `@companion-module/base ~1.14.1` (v1.x) |
| **Language** | TypeScript (ESM) |
| **Date** | 2026-04-05 |
| **Reviewers** | Mal (Lead), Wash (Protocol), Kaylee (Template/Build), Zoe (QA), Simon (Tests) |

---

## Fix Summary for Maintainer

**17 blocking issues must be fixed before approval.** Numbered by priority:

1. **Add `.yarnrc.yml`** with `nodeLinker: node-modules` — without it, Yarn 4 defaults to PnP and `yarn package` fails. (C1)
2. **Add `.gitignore`** from template — prevents `dist/`, `node_modules/`, and PnP artifacts from being committed. (C2)
3. **Add `.gitattributes`** with `* text=auto eol=lf` — required template file for cross-platform line endings. (C3)
4. **Add `.husky/pre-commit`** with content `lint-staged` and `chmod +x` — wires up the lint-staged pipeline that's already configured. (C4)
5. **Add `.prettierignore`** — prevents prettier from reformatting `package.json`. (C5)
6. **Fix `manifest.json` line 9** — change `repository` URL from `videopathe` org to `bitfocus` org to match `bugs` URL and `package.json`. (C6)
7. **Add `AbortController` timeout to `fetchJson()`** in `src/api.ts` — without it, a TCP stall permanently locks `pollInFlight` and kills all state updates. (H1)
8. **Add `handshakeTimeout: 10000`** to WebSocket constructor in `src/main.ts` line 165 — prevents WS from getting stuck in CONNECTING forever. (H2)
9. **Move `@types/ws`** from `dependencies` to `devDependencies` in `package.json`. (H3)
10. **Add `InstanceStatus` update and change log level to `error`** in WebSocket `error` handler, `src/main.ts` line 201. (M1)
11. **Abort in-flight fetches in `destroy()`** — store an `AbortController` and abort it on teardown, `src/main.ts`. (M2)
12. **Abort in-flight fetches in `configUpdated()`** before starting new polling — prevents old-host responses from clobbering new connection state. (M3)
13. **Preserve audio sounds on partial failure** — use `this.runtimeState.audioSounds` fallback when `audioResponse` is `undefined`, `src/main.ts` line 289. (M4)
14. **Validate `ruleId` is non-empty** before building URL in `audio_set_rule_enabled` and `audio_set_rule_volume`, `src/actions.ts` lines 449/472. (M5)
15. **Guard against `null`/array in WebSocket payload** — add `payload.data === null || Array.isArray(payload.data)` check, `src/main.ts` line 209. (M6)
16. **Reset `runtimeState` in `configUpdated()`** before reconnecting — prevents stale server data from persisting, `src/main.ts` line 92. (M7)

**After applying all fixes, verify with:**

```bash
yarn                  # install deps and set up Husky pre-commit hook
yarn run format       # auto-fix Prettier formatting issues
yarn run lint         # must pass with 0 errors before committing
yarn build            # confirm build still succeeds
```

> ⚠️ **Husky note:** `yarn` must be run at least once after cloning so that the `postinstall` script installs the Husky pre-commit hook. Without this step, the hook is not active and lint-staged will not run on commits.

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 6 | 0 | 6 |
| 🟠 High | 3 | 0 | 3 |
| 🟡 Medium | 8 | 0 | 8 |
| 🟢 Low | 0 | 0 | 0 |
| 💡 Nice to Have | 4 | 0 | 4 |
| **Total** | **21** | **0** | **21** |

**Blocking:** 17 issues (6 new critical, 3 new high, 8 new medium)  
**Fix complexity:** Medium — template files are copy-from-template; network fixes require AbortController pattern (~30 lines)  
**Health delta:** 24 introduced · 0 pre-existing (first release)

---

## Verdict

**❌ CHANGES REQUIRED** — 6 critical template compliance violations, 3 high-severity network reliability issues, and 8 medium issues block approval. The code architecture and logic quality are genuinely strong — the blocking items are primarily missing configuration files and missing network timeouts, all straightforward to fix.

---

## 📋 Issues

**Blocking**
- [ ] [C1: Missing `.yarnrc.yml` — Yarn PnP breaks packaging](#c1-missing-yarnrcyml--yarn-pnp-breaks-packaging)
- [ ] [C2: Missing `.gitignore` — build artifacts will be committed](#c2-missing-gitignore--build-artifacts-will-be-committed)
- [ ] [C3: Missing `.gitattributes`](#c3-missing-gitattributes)
- [ ] [C4: Missing `.husky/pre-commit` hook](#c4-missing-huskypre-commit-hook)
- [ ] [C5: Missing `.prettierignore`](#c5-missing-prettierignore)
- [ ] [C6: `manifest.json` repository URL uses wrong GitHub org](#c6-manifestjson-repository-url-uses-wrong-github-org)
- [ ] [H1: No HTTP fetch timeout — `pollInFlight` can lock permanently](#h1-no-http-fetch-timeout--pollinflight-can-lock-permanently)
- [ ] [H2: No WebSocket handshake timeout — socket stuck in CONNECTING forever](#h2-no-websocket-handshake-timeout--socket-stuck-in-connecting-forever)
- [ ] [H3: `@types/ws` in `dependencies` instead of `devDependencies`](#h3-typesws-in-dependencies-instead-of-devdependencies)
- [ ] [M1: WebSocket `error` event does not update `InstanceStatus`](#m1-websocket-error-event-does-not-update-instancestatus)
- [ ] [M2: In-flight `fetch` calls not cancelled on `destroy()`](#m2-in-flight-fetch-calls-not-cancelled-on-destroy)
- [ ] [M3: Config change mid-poll — old host response clobbers new connection state](#m3-config-change-mid-poll--old-host-response-clobbers-new-connection-state)
- [ ] [M4: Audio sounds cleared on partial audio-endpoint failure](#m4-audio-sounds-cleared-on-partial-audio-endpoint-failure)
- [ ] [M5: Empty `ruleId` sends malformed URL in audio rule actions](#m5-empty-ruleid-sends-malformed-url-in-audio-rule-actions)
- [ ] [M6: Unsafe `as` cast for WebSocket state payload](#m6-unsafe-as-cast-for-websocket-state-payload)
- [ ] [M7: `configUpdated()` does not clear stale state before reconnecting](#m7-configupdated-does-not-clear-stale-state-before-reconnecting)

**Non-blocking**
- [ ] [N1: `manifest.json` version should be `0.0.0`](#n1-manifestjson-version-should-be-000)
- [ ] [N2: `InstanceStatus.Disconnected` never used](#n2-instancestatusdisconnected-never-used)
- [ ] [N3: Yarn peer dependency warning](#n3-yarn-peer-dependency-warning)
- [ ] [N4: `package.json` scripts use `yarn` instead of `run`](#n4-packagejson-scripts-use-yarn-instead-of-run)

---

## 🔴 Critical

### C1: Missing `.yarnrc.yml` — Yarn PnP breaks packaging

**Classification:** 🆕 NEW  
**File:** `.yarnrc.yml` (missing)  
**Source:** Kaylee (K2), Zoe (Z4)

Without `.yarnrc.yml` specifying `nodeLinker: node-modules`, Yarn v4 defaults to PnP (Plug'n'Play) mode. Companion's `companion-module-build` tool and most native Node.js packages are incompatible with PnP. This will cause `yarn package` to fail in a clean environment.

**Impact:** Module is unpackageable in a clean CI environment. Any reviewer or CI system without pre-existing `node_modules/` will hit PnP resolution errors.

**Fix:** Create `.yarnrc.yml` at the module root:
```yaml
nodeLinker: node-modules
```

---

### C2: Missing `.gitignore` — build artifacts will be committed

**Classification:** 🆕 NEW  
**File:** `.gitignore` (missing)  
**Source:** Kaylee (K3), Zoe (Z2)

Without `.gitignore`, `node_modules/`, `dist/`, and build artifacts may be committed to the repository. Zoe noted that `.pnp.cjs` and `.pnp.loader.mjs` (Yarn PnP artifacts) are already present — evidence that generated files are landing in the repo unchecked.

**Impact:** High risk of `dist/` and `node_modules/` being committed, bloating the repo and creating stale build artifacts in version control.

**Fix:** Create `.gitignore`:
```
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```
Remove any committed PnP artifacts (`.pnp.cjs`, `.pnp.loader.mjs`) from version control.

---

### C3: Missing `.gitattributes`

**Classification:** 🆕 NEW  
**File:** `.gitattributes` (missing)  
**Source:** Kaylee (K1), Zoe (Z1)

Required template file is absent. Controls line-ending normalization for cross-platform contributors.

**Impact:** Contributors on Windows may commit CRLF endings, causing diff noise and lint failures in CI.

**Fix:** Create `.gitattributes`:
```
* text=auto eol=lf
```

---

### C4: Missing `.husky/pre-commit` hook

**Classification:** 🆕 NEW  
**File:** `.husky/pre-commit` (missing)  
**Source:** Kaylee (K5), Zoe (Z5)

The `package.json` correctly includes `"postinstall": "husky"` and `lint-staged` is configured, but the actual pre-commit hook file that wires them together is missing. Husky will silently do nothing on commit.

**Impact:** `lint-staged` never runs on commit. Code that fails lint or formatting can be committed unchecked.

**Fix:** Create `.husky/pre-commit` with content:
```
lint-staged
```
Then `chmod +x .husky/pre-commit`.

---

### C5: Missing `.prettierignore`

**Classification:** 🆕 NEW  
**File:** `.prettierignore` (missing)  
**Source:** Kaylee (K4), Zoe (Z3)

Without it, `yarn format` will reformat `package.json` (potentially mangling field order).

**Fix:** Create `.prettierignore`:
```
package.json
/LICENSE.md
```

---

### C6: `manifest.json` repository URL uses wrong GitHub org

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 9  
**Source:** Kaylee (K6), Zoe (Z6)

The `repository` field points to the `videopathe` GitHub org, but `bugs` (line 10) and `package.json` both use `bitfocus`. Companion's module registry uses this URL to link to the source repo.

**Found:**
```json
"repository": "git+https://github.com/videopathe/companion-module-videopathe-qtimer.git"
```

**Expected:**
```json
"repository": "git+https://github.com/bitfocus/companion-module-videopathe-qtimer.git"
```

**Fix:** Update `manifest.json` line 9 to use the `bitfocus` org URL.

---

## 🟠 High

### H1: No HTTP fetch timeout — `pollInFlight` can lock permanently

**Classification:** 🆕 NEW  
**File:** `src/api.ts`, lines 6–21; `src/main.ts`, lines 262–322  
**Source:** Wash (W1), Zoe (Z7)

`fetchJson()` passes no `signal` to `fetch()`. Node's built-in `fetch` will wait indefinitely if the remote TCP connection stalls. In `refreshAllState()`, `pollInFlight` is set to `true` (line 272) and released only in `finally` (line 321). If any fetch hangs, `pollInFlight` stays `true` permanently — every subsequent poll tick returns early. Polling is silently dead for the rest of the module's lifetime.

**Impact — polling path:** All state updates freeze permanently with no log and no status change. On a live show, the operator sees frozen timer values with no indication anything is wrong.

**Impact — command path:** `postCommand()` also hangs indefinitely. An operator pressing a button gets no response.

**Fix:** Add `AbortController` timeout in `api.ts`:
```typescript
export async function fetchJson<T>(url: string, init?: RequestInit, timeoutMs = 10_000): Promise<T> {
    const controller = new AbortController()
    const timer = setTimeout(() => controller.abort(), timeoutMs)
    try {
        const response = await fetch(url, {
            ...init,
            signal: controller.signal,
            headers: {
                'Content-Type': 'application/json',
                ...(init?.headers ?? {}),
            },
        })
        if (!response.ok) {
            const bodyText = await response.text()
            throw new Error(`HTTP ${response.status} ${response.statusText}${bodyText ? `: ${bodyText}` : ''}`)
        }
        return (await response.json()) as T
    } finally {
        clearTimeout(timer)
    }
}
```

---

### H2: No WebSocket handshake timeout — socket stuck in CONNECTING forever

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, line 165  
**Source:** Wash (W2)

**References:**
- `ws` v8.19.0 source — `node_modules/ws/lib/websocket.js`
  - Line 641: JSDoc declares `options.handshakeTimeout` as optional with no default value
  - Line 755: `opts.timeout = opts.handshakeTimeout` — when omitted, `opts.timeout` is `undefined`
  - Line 876: `if (opts.timeout) { req.on('timeout', () => { abortHandshake(...) }) }` — the timeout handler is **never registered** when the option is absent
- GitHub source: https://github.com/websockets/ws/blob/8.19.0/lib/websocket.js#L876

The WebSocket constructor is called with no options object. The `ws` library's `handshakeTimeout` option is purely opt-in — there is no default. When omitted, `opts.timeout` is `undefined`, the `if (opts.timeout)` guard at line 876 of `websocket.js` is never entered, and no timeout handler is registered on the HTTP request. If the host accepts TCP but the HTTP `Upgrade` response stalls (e.g., reverse proxy, firewall, slow QTimer boot), the socket sits in `CONNECTING` indefinitely. The `ws` library only fires `error` and `close` events when the connection attempt actively fails — a permanently stalled handshake produces neither. Without `close`, the reconnect timer in the module's `close` handler never fires.

**Impact:** If the handshake stalls, the WebSocket channel is permanently dead with no recovery path. The module will appear to be connecting but never establish a channel.

**Current code (`src/main.ts`, line 165):**
```typescript
const websocket = new WebSocket(wsUrl)
```

**Fix:**
```typescript
const websocket = new WebSocket(wsUrl, { handshakeTimeout: 10000 })
```

When `handshakeTimeout` is set, `ws` calls `req.on('timeout', ...)` which invokes `abortHandshake()`, closing the request and emitting `error` + `close` — triggering the existing reconnect logic normally.

---

### H3: `@types/ws` in `dependencies` instead of `devDependencies`

**Classification:** 🆕 NEW  
**File:** `package.json`, line 31  
**Source:** Kaylee (K7)

`@types/ws` is a compile-time type declaration package with no runtime content. Placing it in `dependencies` causes it to be installed by consumers and inflates the `.tgz` package.

**Fix:** Move `"@types/ws": "^8.18.1"` from `dependencies` to `devDependencies`.

---

## 🟡 Medium

### M1: WebSocket `error` event does not update `InstanceStatus`

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 196–202  
**Source:** Wash (W3)

The `error` handler only logs at `debug` level and does not call `updateStatus()`. While `ws` guarantees a `close` event after `error` (so reconnect still fires), there is a window where the error is not surfaced to the operator via InstanceStatus. Additionally, logging at `debug` means errors are invisible in production unless debug logging is explicitly enabled — WebSocket errors should always be visible.

**Current code (`src/main.ts`, lines 196–202):**
```typescript
websocket.on('error', (error) => {
    if (this.websocket !== websocket) return
    this.log('debug', `WebSocket error: ${this.formatError(error)}`)
})
```

**Fix:**
```typescript
websocket.on('error', (error) => {
    if (this.websocket !== websocket) return
    this.log('error', `WebSocket error: ${this.formatError(error)}`)
    this.updateStatus(InstanceStatus.ConnectionFailure, this.formatError(error))
})
```

---

### M2: In-flight `fetch` calls not cancelled on `destroy()`

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 47–52, 86–90, 276–285  
**Source:** Wash (W4)

`destroy()` clears the interval timer and disconnects the WebSocket, but any in-flight `refreshAllState()` fetch continues executing. When it resolves, `updateStatus()`, `setVariableValues()`, and `checkFeedbacks()` are called on a destroyed instance.

`AbortController` is a global available in Node.js 14.17+ (this module requires Node 22) and in all modern browsers. It exposes a `signal` property that can be passed to `fetch()` via its `RequestInit` options. When `abort()` is called, any in-flight fetch using that signal rejects with an `AbortError`. No additional dependencies are needed.

Note: `fetchJson` already accepts an optional `RequestInit` argument (see `src/api.ts` line 6), so a `signal` can be passed without modifying `api.ts`.

**References:**
- MDN — AbortController: https://developer.mozilla.org/en-US/docs/Web/API/AbortController
- MDN — fetch() `signal` option: https://developer.mozilla.org/en-US/docs/Web/API/RequestInit#signal
- Node.js 22 globals — AbortController: https://nodejs.org/docs/latest-v22.x/api/globals.html#class-abortcontroller

**Current code (`src/main.ts`, lines 47–52):**
```typescript
private pollTimer: NodeJS.Timeout | undefined
private pollInFlight = false
private websocket: WebSocket | undefined
private websocketReconnectTimer: NodeJS.Timeout | undefined
private websocketConnected = false
private audioPresetSignature = ''
```

**Current code (`src/main.ts`, lines 86–90):**
```typescript
async destroy(): Promise<void> {
    this.stopPolling()
    this.disconnectWebSocket(false)
    this.log('debug', 'destroy')
}
```

**Current code (`src/main.ts`, lines 276–285):**
```typescript
const [statusResponse, playlistResponse, audioResponse] = await Promise.all([
    fetchJson<QTimerStatusResponse>(`${baseUrl}/api/status`),
    fetchJson<QTimerPlaylistStateResponse>(`${baseUrl}/api/playlist/state`).catch((error) => {
        this.log('debug', `Playlist refresh failed: ${this.formatError(error)}`)
        return undefined
    }),
    fetchJson<QTimerAudioSettingsResponse>(`${baseUrl}/api/audio/settings`).catch((error) => {
        this.log('debug', `Audio refresh failed: ${this.formatError(error)}`)
        return undefined
    }),
])
```

**Fix:** Add an `AbortController` instance variable, abort it in `destroy()`, and pass its signal to all fetch calls:
```typescript
// Add instance variable alongside the others:
private fetchAbortController: AbortController = new AbortController()

// destroy():
async destroy(): Promise<void> {
    this.fetchAbortController.abort()
    this.stopPolling()
    this.disconnectWebSocket(false)
    this.log('debug', 'destroy')
}

// In refreshAllState(), pass the signal to all fetchJson calls:
const signal = this.fetchAbortController.signal
const [statusResponse, playlistResponse, audioResponse] = await Promise.all([
    fetchJson<QTimerStatusResponse>(`${baseUrl}/api/status`, { signal }),
    fetchJson<QTimerPlaylistStateResponse>(`${baseUrl}/api/playlist/state`, { signal }).catch((error) => {
        this.log('debug', `Playlist refresh failed: ${this.formatError(error)}`)
        return undefined
    }),
    fetchJson<QTimerAudioSettingsResponse>(`${baseUrl}/api/audio/settings`, { signal }).catch((error) => {
        this.log('debug', `Audio refresh failed: ${this.formatError(error)}`)
        return undefined
    }),
])
```

---

### M3: Config change mid-poll — old host response clobbers new connection state

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 92–96  
**Source:** Wash (W5)

When `configUpdated()` fires while a poll is in-flight against the **old** host, the old fetch completes and writes `runtimeState = { connected: true, serverUrl: oldHost }`, overwriting new connection state with stale data from the previous server. Amplified by H1 — without a timeout, the old request can hang indefinitely.

**Current code (`src/main.ts`, lines 92–96):**
```typescript
async configUpdated(config: ModuleConfig): Promise<void> {
    this.config = config
    this.startPolling(true)
    this.connectWebSocket()
}
```

**Fix:** Abort in-flight requests and reset the controller before starting new polling (same `AbortController` added for M2):
```typescript
async configUpdated(config: ModuleConfig): Promise<void> {
    this.fetchAbortController.abort()
    this.fetchAbortController = new AbortController()
    this.config = config
    this.startPolling(true)
    this.connectWebSocket()
}
```

---

### M4: Audio sounds cleared on partial audio-endpoint failure

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 289, 301  
**Source:** Zoe (Z8)

When `/api/audio/settings` fails (transient error), `normalizeAudioSounds(undefined)` returns `[]` and overwrites `audioSounds`. Contrast with playlist, which preserves the last value: `playlistResponse?.playlist ?? this.runtimeState.playlist`.

**Impact:** Audio presets disappear from Companion UI on every transient audio endpoint failure and reappear on next successful poll.

**Fix:**
```typescript
audioSounds: audioResponse !== undefined
    ? this.normalizeAudioSounds(audioResponse)
    : (this.runtimeState.audioSounds ?? []),
```

---

### M5: Empty `ruleId` sends malformed URL in audio rule actions

**Classification:** 🆕 NEW  
**File:** `src/actions.ts`, lines 449, 472  
**Source:** Zoe (Z9)

The `ruleId` textinput is not validated before building the URL. Empty/whitespace `ruleId` produces `/api/audio/rules//enabled` (double slash), which fails at the server with no diagnostic.

**Fix:** Add early validation:
```typescript
const ruleId = String(event.options.ruleId ?? '').trim()
if (!ruleId) {
    self.log('warn', 'audio_set_rule_enabled: ruleId is required')
    return
}
```

---

### M6: Unsafe `as` cast for WebSocket state payload

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, line 219  
**Source:** Zoe (Z10)

`payload.data as QTimerStateSnapshot` casts `unknown` without full structural validation. The existing check at line 209 (`typeof payload.data !== 'object'`) passes `null` (since `typeof null === 'object'`) and arrays.

**Fix:** Extend the guard:
```typescript
if (typeof payload.data !== 'object' || payload.data === null || Array.isArray(payload.data)) {
    return
}
```

---

### M7: `configUpdated()` does not clear stale state before reconnecting

**Classification:** 🆕 NEW  
**File:** `src/main.ts`, lines 92–96  
**Source:** Zoe (Z11)

When the operator changes host/port, the old server's state persists in `runtimeState` until the first successful poll. If the new server is unreachable, feedbacks continue showing the previous server's timer values.

**Fix:** Reset state at top of `configUpdated()`:
```typescript
this.runtimeState = {
    connected: false,
    lastError: null,
    serverUrl: '',
    lastUpdated: null,
}
this.updateVariablesFromState()
this.checkFeedbacks()
```

---

## 💡 Nice to Have

### N1: `manifest.json` version should be `0.0.0`

**Classification:** 🆕 NEW  
**File:** `companion/manifest.json`, line 6  
**Source:** Kaylee (K10), Zoe (Z13)

Convention is `"version": "0.0.0"` in manifest (runtime uses `package.json`). Current value `"1.0.0"` matches `package.json`, so non-blocking, but diverges from convention.

---

### N2: `InstanceStatus.Disconnected` never used

**Classification:** 🆕 NEW  
**File:** `src/main.ts`  
**Source:** Wash (W8)

The module uses `BadConfig`, `Connecting`, `Ok`, and `ConnectionFailure` but never `Disconnected`. When the WebSocket drops and reconnect is scheduled, status stays whatever polling last set — potentially `Ok` while websocket is reconnecting.

**Suggestion:** Set `InstanceStatus.Connecting` in `disconnectWebSocket()` when `scheduleReconnect` is `true`.

---

### N3: Yarn peer dependency warning

**Classification:** 🆕 NEW  
**File:** *(install output)*  
**Source:** Kaylee (K9)

`yarn install` emits `YN0086: Some peer dependencies are incorrectly met`. Non-blocking but worth investigating.

---

### N4: `package.json` scripts use `yarn` instead of `run`

**Classification:** 🆕 NEW  
**File:** `package.json`, lines 22, 27  
**Source:** Kaylee (K11)

Template convention uses workspace-agnostic `run build` / `run build:main`. Module uses `yarn build` / `yarn build:main`. Both work, but deviates from template.

---

## ⚠️ Pre-existing Notes

N/A — first release. All findings are new.

---

## 🧪 Tests

**No tests present.** No test files (`*.test.ts`, `*.spec.ts`, `__tests__/`), no test runner config, no test scripts in `package.json`.

**Verdict:** Compliant — tests are not required for v1.0.0 first release per team standards. Testing is encouraged for future releases, particularly for `api.ts` (HTTP communication), `state.ts` (state management logic), and `actions.ts` (action handlers).

---

## ✅ What's Solid

- **Architecture is clean and well-structured.** 10 source files with clear separation of concerns: `main.ts` (lifecycle), `actions.ts`, `feedbacks.ts`, `presets.ts`, `variables.ts`, `config.ts`, `state.ts`, `api.ts`, `choices.ts`, `upgrades.ts`.
- **`destroy()` is leak-free.** Poll timer cleared, WebSocket listeners removed, `terminate()` called (not just `close()`), reconnect timer cancelled.
- **WebSocket stale-socket guard.** The `if (this.websocket !== websocket) return` pattern on every handler correctly handles the race between reconnect and delayed callbacks from old sockets.
- **`pollInFlight` guard.** Prevents concurrent poll requests from stacking up on the interval timer.
- **TypeScript quality is excellent.** No `any`, no `@ts-ignore`, no `as unknown as`. Only two minimal `as` casts, both scoped appropriately.
- **Null safety is consistent.** Thorough use of optional chaining (`?.`) and `safeNumber()` throughout all state access patterns. Feedbacks and variables are safe with undefined state.
- **Error paths in `refreshAllState()`.** `Promise.all` with individual `.catch()` on secondary endpoints (playlist, audio) correctly allows the primary `/api/status` to succeed even when secondary endpoints fail.
- **`postCommand()` error handling.** Catches, updates state/status, and re-throws so action callers see the failure.
- **InstanceStatus transitions.** `BadConfig` on invalid config, `Connecting` at poll start, `Ok` on success, `ConnectionFailure` on HTTP error — all correct.
- **Message parsing is defensive.** `handleWebSocketMessage` validates `payload.type` and `typeof payload.data` before processing.
- **Comprehensive feature coverage.** 47 actions, 30 feedbacks, 80+ variables, 79 presets including ready-page categories — this module covers the full QTimer API surface.
- **HELP.md is substantive.** Covers connection setup, all feature areas, variables, feedbacks, presets, and local development instructions. Not a stub.
- **Build succeeds cleanly.** `yarn build` produces all 10 expected JS artifacts with source maps.
- **`runEntrypoint(ModuleInstance, UpgradeScripts)` correctly used** for v1.x module.
- **Empty `UpgradeScripts`** is correct for v1.0.0 — no prior version to migrate from.
