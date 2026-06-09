# Review — yunxi-yolobox v1.0.0

| | |
|---|---|
| **Module** | yunxi-yolobox |
| **Review tag** | v1.0.0 |
| **Previous tag** | (none — first release) |
| **Scope** | `tag` (first release → full `src/` review; every finding is NEW) |
| **Language / API** | JS / `@companion-module/base` v1.x (`~1.12.0`, manifest apiVersion 1.12.1, node22) |
| **Protocols** | WebSocket |
| **Reviewed** | 2026-06-08 |

> First release: there is no `previousTag..reviewTag` diff, so the whole `src/` was reviewed as a full review and all findings are classified NEW.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C2: Required file missing — .gitattributes](#c2-required-file-missing--gitattributes)
- [ ] [C3: Required file missing — .prettierignore](#c3-required-file-missing--prettierignore)
- [ ] [C4: .gitignore missing required template entries](#c4-gitignore-missing-required-template-entries)
- [ ] [C5: .yarnrc.yml differs from template](#c5-yarnrcyml-differs-from-template)
- [ ] [C6: package.json missing required prettier field](#c6-packagejson-missing-required-prettier-field)
- [ ] [C7: package.json missing prettier devDependency](#c7-packagejson-missing-prettier-devdependency)
- [ ] [H1: No real heartbeat — a silently dead device is never detected, status stays Ok](#h1-no-real-heartbeat--a-silently-dead-device-is-never-detected-status-stays-ok)
- [ ] [H3: Icon loading reads the filesystem with no manifest permission — silently fails on Companion 4.0+](#h3-icon-loading-reads-the-filesystem-with-no-manifest-permission--silently-fails-on-companion-40)
- [ ] [H4: Timers/intervals are not tracked and not cleared on disconnect/destroy](#h4-timers-and-intervals-are-not-tracked-and-not-cleared-on-disconnect-and-destroy)
- [ ] [H5: Host regex accepts invalid octets and rejects hostnames](#h5-host-regex-accepts-invalid-octets-and-rejects-hostnames)

**Non-blocking**

- [ ] [M6: No ConnectionFailure/Connecting status while reconnecting](#m6-no-connectionfailureconnecting-status-while-reconnecting)
- [ ] [M7: Definitions re-registered on every connect; variables not filtered to the spec](#m7-definitions-re-registered-on-every-connect-variables-not-filtered-to-the-spec)
- [ ] [M8: cycle_state advanced feedback promises button text but never sets any](#m8-cycle_state-advanced-feedback-promises-button-text-but-never-sets-any)
- [ ] [L1: Preset icons read from disk on every setup with no caching](#l1-preset-icons-read-from-disk-on-every-setup-with-no-caching)

## 🔴 Critical

### C2: Required file missing — .gitattributes

**File:** `.gitattributes`

Required template file is missing. (Deterministic template check, `FILE-MISSING`.)

**Fix (maintainer):** add the template `.gitattributes` from `companion-module-template-js-v1`.

### C3: Required file missing — .prettierignore

**File:** `.prettierignore`

Required template file is missing. (Deterministic template check, `FILE-MISSING`.)

**Fix (maintainer):** add the template `.prettierignore`.

### C4: .gitignore missing required template entries

**File:** `.gitignore`

Missing template entries: `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`. (Deterministic template check, `CONFIG-DIFF`.)

**Fix (maintainer):** add the missing entries so the ignore set matches the template.

### C5: .yarnrc.yml differs from template

**File:** `.yarnrc.yml`

Line 1 is `approvedGitRepositories:` where the template expects `nodeLinker: node-modules`. (Deterministic template check, `CONFIG-DIFF`.) A non-`node-modules` linker breaks the standard build/packaging the platform expects.

**Fix (maintainer):** restore `nodeLinker: node-modules` as the template defines; keep any additional keys below it only if intentional.

### C6: package.json missing required prettier field

**File:** `package.json`

Missing required `prettier` field present in the template. (Deterministic template check, `PKG-FIELD`.)

**Fix (maintainer):** add the template's `prettier` config key to `package.json`.

### C7: package.json missing prettier devDependency

**File:** `package.json`

Missing devDependency `prettier` present in the template. (Deterministic template check, `PKG-DEVDEP`.)

**Fix (maintainer):** add `prettier` to `devDependencies` at the template's version.

## 🟠 High

### H1: No real heartbeat — a silently dead device is never detected, status stays Ok

**File:** `src/websocket-client.js:289-315` (and `_handleConnectionLost`, `308-311`)

`_startHeartbeat()` opens a heartbeat socket but never sends a ping and never enforces a pong/response deadline — it only reacts to the *socket* closing. `HEARTBEAT_INTERVAL` (`src/constants.js:18`) is declared but unused. If the network drops silently (no FIN/RST), the heartbeat `close` never fires, so the module keeps reporting `InstanceStatus.Ok` while every subsequent action queues against a dead action socket and times out one-by-one (3s each). The operator sees a connected, unresponsive module.

**Fix (maintainer):** implement an actual heartbeat — periodic ping on `HEARTBEAT_INTERVAL` with a pong/response deadline that triggers `_handleConnectionLost()` (and a status transition) when missed.

### H3: Icon loading reads the filesystem with no manifest permission — silently fails on Companion 4.0+

**File:** `src/presets.js:8,22-33` (`fs.existsSync` / `fs.readFileSync` in `loadIcon`); `companion/manifest.json` (no `permissions` block)

`loadIcon` reads 291 bundled PNG icons from disk at runtime, but the manifest declares no `permissions`. Under the v1.12 node-permissions model, filesystem access requires `"permissions": { "filesystem": true }`. Because `loadIcon` is wrapped in try/catch the throw is swallowed — icons silently fail to load rather than crashing — so on Companion 4.0+ presets render without their intended icons.

**Fix (maintainer):** add `"permissions": { "filesystem": true }` to `companion/manifest.json`. Alternatively, since the PNGs ship in the module, encode them at build time (import/inline as base64) and drop the runtime `fs` reads entirely (also resolves L1).

### H4: Timers and intervals are not tracked and not cleared on disconnect and destroy

**File:** `src/websocket-client.js:65, 164-172, 237, 339`

The connect timeout (`65`), the `_ensureActionSocket` `checkReady` 50ms `setInterval` (`164-172`, only cleared on OPEN/CLOSED — runs forever on a half-open socket), the action-socket close 200ms timer (`237`), and the per-probe timeout (`339`) are not stored and not cleared by `disconnect()`/`destroy()`. After teardown these can still fire against a torn-down instance.

**Fix (maintainer):** store every handle and clear them in `_clearTimers()`/`disconnect()`; bound the `checkReady` interval with a max-attempts/timeout.

### H5: Host regex accepts invalid octets and rejects hostnames

**File:** `src/config.js:18`

`/^(?:\d{1,3}\.){3}\d{1,3}$/` accepts `999.999.999.999` and rejects hostnames/mDNS names.

**Fix (maintainer):** use the Companion Regex.IP helper function.

## 🟡 Medium

### M6: No ConnectionFailure/Connecting status while reconnecting

**File:** `src/index.js:45-55`; `src/websocket-client.js:391-401`

`onConnectionChange` maps only to `Ok`/`Disconnected`. While probing/reconnecting (`ConnectionState.RECONNECTING`) or on a connect timeout, the instance stays `Disconnected` and never shows `ConnectionFailure` or returns to `Connecting`. Related: `configUpdated` (`src/index.js:78-95`) does nothing when host/port are unchanged but the socket has since died, relying solely on the probe loop.

**Fix (maintainer):** map `RECONNECTING` → `InstanceStatus.Connecting` and a hard connect failure → `InstanceStatus.ConnectionFailure`; consider forcing a reconnect from `configUpdated` when not currently connected.

### M7: Definitions re-registered on every connect; variables not filtered to the spec

**File:** `src/index.js:58-61`, `src/index.js:150-152`

`init()` registers actions/feedbacks/presets/variables, then `_fetchAndApplySpecification()` re-runs `setupActions`/`setupFeedbacks`/`setupPresets` with the filtered `supportedProperties`. Two issues: (a) variables are not re-registered from the filtered set, so variable definitions never narrow to the spec (minor inconsistency); (b) after a reconnect to a device with a different spec, the action/preset set narrows but never widens back unless a new spec arrives.

**Fix (maintainer):** register the full definition set once in `init()`; only re-run setup when the spec actually changes the supported set, and document that variables are intentionally always-full.

### M8: cycle_state advanced feedback promises button text but never sets any

**File:** `src/feedbacks.js:149-176`

The `cycle_state` advanced feedback is named "Show current cycle value as button text" and its description promises showing the value as text, but the callback only returns `{ bgcolor, color }` — no `text`. It does not do what its name/description states.

**Fix (maintainer):** return `{ text: String(currentValue) }`, or rename/redescribe to "highlight when cycle value is non-zero."

## 🟢 Low

### L1: Preset icons read from disk on every setup with no caching

**File:** `src/presets.js:22-33,39`

`loadIcon` does `fs.existsSync` + `fs.readFileSync` + base64 per function (~70 functions) on every `setupPresets()` — init, every spec fetch, and every reconnect — with no caching.

**Fix (maintainer):** cache base64 results in a module-level `Map` keyed by icon name (or inline at build time per H3).
