# Review: yunxi-yolobox (YoloBox) — v1.0.3

| | |
|---|---|
| **Module** | yunxi-yolobox (YoloBox) |
| **Version** | v1.0.3 |
| **Scope** | `tag` — review surface is the `v1.0.2..v1.0.3` diff; every code finding would be NEW/REGRESSION |
| **Language** | JavaScript (ESM, `type: module`) — v1 API (`@companion-module/base ~1.12.0`) |
| **Transport** | WebSocket (`ws ^8.20.1`). The fact-sheet OSC/HTTP/Bonjour entries are false positives from base64 image data in `src/icons.generated.js` |
| **Build/Package** | ✅ `yarn package` (companion-module-build) succeeds |
| **Lint/Format** | ✅ `yarn lint` and `yarn format:check` both pass in a clean checkout |
| **Reviewed** | 2026-06-21 |
| **Note** | This is the **v1.0.3 resubmission of the v1.0.2 review**. All v1.0.2 blockers (C1, C3–C8) are verified resolved (see below). The `v1.0.2..v1.0.3` diff is comment translation (Chinese→English) + Prettier reflow + template/config compliance — **no behavioral code change**. The deterministic validator reported 16 "Critical" template findings, but it misclassified the module as TypeScript (it keys off the `typescript` devDependency, which the maintainer added solely as the peer `typescript-eslint` requires to lint the JS). Adjudicated against the correct **`companion-module-template-js-v1`**, those 16 are false positives — there is no tsconfig/husky/build step in a JS module, and packaging + lint + format all pass. |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| **Total** | **0** | **0** | **0** |

## Verdict: ✅ Approved

## 📋 Issues

**Blocking**
- *(none)*

**Non-blocking**
- [ ] [NR1: Action responses correlated FIFO instead of by orderId](#nr1-action-responses-correlated-fifo-instead-of-by-orderid)
- [ ] [NR2: Connection-timeout timer is never tracked or cleared](#nr2-connection-timeout-timer-is-never-tracked-or-cleared)
- [ ] [NR3: Action-socket re-creates on every close with no backoff](#nr3-action-socket-re-creates-on-every-close-with-no-backoff)
- [ ] [NR4: _ensureActionSocket readiness interval can leak or null-deref](#nr4-_ensureactionsocket-readiness-interval-can-leak-or-null-deref)
- [ ] [NR5: InstanceStatus only toggles Ok/Disconnected](#nr5-instancestatus-only-toggles-okdisconnected)
- [ ] [NR6: Device push for an unmapped property sets an undefined variable](#nr6-device-push-for-an-unmapped-property-sets-an-undefined-variable)
- [ ] [NR7: Action callbacks do not null-guard self.wsClient](#nr7-action-callbacks-do-not-null-guard-selfwsclient)
- [ ] [NR8: manifest name does not match id](#nr8-manifest-name-does-not-match-id)

## ✅ v1.0.2 findings verified resolved

The prior review listed C1 and C3–C8 as blocking. All are fixed in v1.0.3:

- **C1 — non-English comments:** all source comments/JSDoc are now English; commit messages are English. ✅
- **C3 — `.gitattributes` missing:** present and identical to the JS v1 template. ✅
- **C4 — `.prettierignore` missing:** present (template content + a justified `src/icons.generated.js` ignore for the generated file). ✅
- **C5 — `.gitignore` missing entries:** now a superset of the template (`/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`, `package-lock.json` all present). ✅
- **C6 — `.yarnrc.yml` differs:** now byte-identical to the template (`nodeLinker: node-modules`). ✅
- **C7 — missing `prettier` config field:** `package.json` now sets `"prettier": "@companion-module/tools/.prettierrc.json"` and the standalone `.prettierrc.json` was removed. ✅
- **C8 — lint/format broken in a clean checkout:** `eslint`, `prettier`, `typescript-eslint` (and `typescript` as its required peer) are now declared in `devDependencies`; `yarn lint` and `yarn format:check` both pass. ✅

## 🔮 Next Release

These are **pre-existing** issues present identically in v1.0.2 and v1.0.3 — the comment-only diff neither introduced nor was expected to fix them. They do **not** block this release under `tag` scope; the maintainer may want to address them in a future version. Files are in `src/` unless noted.

### NR1: Action responses correlated FIFO instead of by orderId

`websocket-client.js:206-218` — Each `sendAction()` allocates a monotonic `orderId` stored in `pendingRequests`, but the response handler ignores it and resolves `entries[0]` (the oldest pending request) for any inbound `data.response`. With two actions in flight (rapid presses, or a press during a slow response) request A can be resolved with request B's result; combined with the optimistic state write in `actions.js`, this can record the wrong property value until the next device push.

**Fix:** If the device echoes an id/property, match the response to the pending request by that key; otherwise serialize sends so at most one request is outstanding (queue, or await the previous promise). At minimum document the single-flight assumption.

### NR2: Connection-timeout timer is never tracked or cleared

`websocket-client.js:65-70` — The `CONNECTION_TIMEOUT` `setTimeout` in `connect()` is fire-and-forget; it is not stored, so `_onOpen()` / `_clearTimers()` / `disconnect()` cannot cancel it. It re-checks `this.isConnected` so it's mostly benign, but within a fast disconnect→reconnect window it can call `close()` on a newly created subscriber socket.

**Fix:** Store it as `this.connectTimer` and `clearTimeout` it in `_onOpen()` and `_clearTimers()`.

### NR3: Action-socket re-creates on every close with no backoff

`websocket-client.js:234-248` — The action socket's `'close'` handler unconditionally calls `_createActionSocket()` whenever `this.host && this.isConnected`. If the device refuses/drops the action port, this becomes a tight create→error→close→create loop with no backoff or cap.

**Fix:** Gate re-creation behind a backoff timer (reuse `RECONNECT_INTERVAL`), or recreate lazily on the next `sendAction()` rather than eagerly in `close`.

### NR4: _ensureActionSocket readiness interval can leak or null-deref

`websocket-client.js:163-174` — `_ensureActionSocket` polls `setInterval(checkReady, 50)`. If `disconnect()`/`_handleConnectionLost()` nulls `this.actionSocket` while it is still `CONNECTING`, `this.actionSocket.readyState` throws, and the interval handle is local — `disconnect()` cannot clear it.

**Fix:** Guard `if (!this.actionSocket)` inside the interval (clear + reject), and track the handle so `disconnect()` can clear it.

### NR5: InstanceStatus only toggles Ok/Disconnected

`index.js:45-55` + `websocket-client.js:391-401` — `onConnectionChange(connected)` maps only to `InstanceStatus.Ok` or `InstanceStatus.Disconnected`. During probe-based reconnection (`RECONNECTING`) and on `ERROR`, the Companion status is not updated, so the UI shows "Disconnected" with no "Connecting"/"ConnectionFailure" feedback.

**Fix:** Surface `CONNECTING`/`RECONNECTING` as `InstanceStatus.Connecting` and `ERROR` as `InstanceStatus.ConnectionFailure` via the callback.

### NR6: Device push for an unmapped property sets an undefined variable

`index.js:119-132` + `variables.js:52-55` — `updateDeviceState` runs for every property the device pushes and calls `updateStateVariable`, but `setupVariables` only *defines* variables for properties in `PropertyToActionMap`. A push for a property outside that map writes a value to an undefined variable id — Companion tolerates it, but the state is silently never surfaced.

**Fix:** Guard `updateStateVariable` on a known-variable set, or define variables from the same superset of properties the device can push.

### NR7: Action callbacks do not null-guard self.wsClient

`actions.js:111,142` — Action callbacks call `self.wsClient.sendAction(...)` directly; `destroy()` sets `this.wsClient = null`. A button press racing with teardown throws `Cannot read properties of null`. The callback is `async` so Companion swallows the rejection, but it logs an error.

**Fix:** Early-return with a warn if `!self.wsClient` in both handlers.

### NR8: manifest name does not match id

`companion/manifest.json` — `name` is `"YoloBox"` while `id` is `"yunxi-yolobox"`; the template convention is `name === id` (the lowercase slug), with the display name carried by `shortname` (already `"YoloBox"`) and the product label. This did not change in v1.0.3 and is schema-valid (`companion-module-build` packaging succeeds), so it is non-blocking — but worth aligning to convention.

**Fix:** Set `name` to `"yunxi-yolobox"` to match `id`; keep the display name in `shortname`/products.
