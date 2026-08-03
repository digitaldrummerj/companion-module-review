# Review: internetclicker-internetclickerremote v2.0.6

| | |
|---|---|
| **Module** | internetclicker-internetclickerremote |
| **Version** | v2.0.6 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full `src/` review; all findings new) |
| **Language / API** | TS / @companion-module/base v2 (pinned `2.0.4`) |
| **Protocols** | HTTP (SignalR negotiate) + WebSocket |
| **Reviewed** | 2026-08-03 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 7 | 0 | 7 |
| 🟠 High | 7 | 0 | 7 |
| 🟡 Medium | 8 | 0 | 8 |
| 🟢 Low | 10 | 0 | 10 |
| 💡 Nice to Have | 4 | 0 | 4 |
| **Total** | **36** | **0** | **36** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: yarn install --immutable fails — committed yarn.lock is a Yarn 1 Classic lockfile](#c1-yarn-install---immutable-fails--committed-yarnlock-is-a-yarn-1-classic-lockfile)
- [ ] [C2: packageManager field missing and .yarnrc.yml requires Yarn 4.10+](#c2-packagemanager-field-missing-and-yarnrcyml-requires-yarn-410)
- [ ] [C3: tsconfig.build.json diverges from the template](#c3-tsconfigbuildjson-diverges-from-the-template)
- [ ] [C4: .gitignore is missing /\*.tgz and contains corrupted UTF-16 bytes](#c4-gitignore-is-missing-tgz-and-contains-corrupted-utf-16-bytes)
- [ ] [C5: build artifact .tgz committed to the repo and README tells users to sideload it](#c5-build-artifact-tgz-committed-to-the-repo-and-readme-tells-users-to-sideload-it)
- [ ] [C6: package.json repository.url is still the template placeholder](#c6-packagejson-repositoryurl-is-still-the-template-placeholder)
- [ ] [C8: companion/HELP.md is the template stub](#c8-companionhelpmd-is-the-template-stub)
- [ ] [H1: connection loss is never detected — status stays Ok and the feedback stays green](#h1-connection-loss-is-never-detected--status-stays-ok-and-the-feedback-stays-green)
- [ ] [H2: start() can hang forever — the connect timeout is cleared before the handshake and onclose never rejects](#h2-start-can-hang-forever--the-connect-timeout-is-cleared-before-the-handshake-and-onclose-never-rejects)
- [ ] [H3: no automatic reconnect — one transient failure disables the module permanently](#h3-no-automatic-reconnect--one-transient-failure-disables-the-module-permanently)
- [ ] [H4: destroy() or configUpdated() during a pending connect leaves a zombie WebSocket and clobbers status](#h4-destroy-or-configupdated-during-a-pending-connect-leaves-a-zombie-websocket-and-clobbers-status)
- [ ] [H5: a rejected handshake leaves the connection marked connected with the socket open](#h5-a-rejected-handshake-leaves-the-connection-marked-connected-with-the-socket-open)
- [ ] [H6: presets.ts ships the unmodified template placeholder preset](#h6-presetsts-ships-the-unmodified-template-placeholder-preset)
- [ ] [H7: yarn lint fails with 3 errors](#h7-yarn-lint-fails-with-3-errors)

**Non-blocking**

- [ ] [M1: negotiate fetch() has no timeout or abort signal](#m1-negotiate-fetch-has-no-timeout-or-abort-signal)
- [ ] [M2: sendCommand() checks the wrong thing and hides failures from the operator](#m2-sendcommand-checks-the-wrong-thing-and-hides-failures-from-the-operator)
- [ ] [M3: isConnected goes stale on the BadConfig and teardown paths](#m3-isconnected-goes-stale-on-the-badconfig-and-teardown-paths)
- [ ] [M4: no client keepalive — Azure SignalR will drop an idle connection](#m4-no-client-keepalive--azure-signalr-will-drop-an-idle-connection)
- [ ] [M5: blanket catch in the message loop swallows handler errors](#m5-blanket-catch-in-the-message-loop-swallows-handler-errors)
- [ ] [M6: negotiate response is untyped and the WebSocket URL is built by string concatenation](#m6-negotiate-response-is-untyped-and-the-websocket-url-is-built-by-string-concatenation)
- [ ] [M7: Event Code config field has no default, required flag, tooltip or trimming](#m7-event-code-config-field-has-no-default-required-flag-tooltip-or-trimming)
- [ ] [M8: WebSocket errors after the handshake are swallowed](#m8-websocket-errors-after-the-handshake-are-swallowed)
- [ ] [L1: the Event Code is logged in full inside the negotiate URL](#l1-the-event-code-is-logged-in-full-inside-the-negotiate-url)
- [ ] [L2: catch (err: any) then err.message yields undefined on a non-Error throw](#l2-catch-err-any-then-errmessage-yields-undefined-on-a-non-error-throw)
- [ ] [L3: binary WebSocket frames degrade to "[object Blob]"](#l3-binary-websocket-frames-degrade-to-object-blob)
- [ ] [L4: checkFeedbacks() called inside destroy()](#l4-checkfeedbacks-called-inside-destroy)
- [ ] [L5: configUpdated() does not set Connecting](#l5-configupdated-does-not-set-connecting)
- [ ] [L6: stop() leaves event handlers attached and the handler map populated](#l6-stop-leaves-event-handlers-attached-and-the-handler-map-populated)
- [ ] [L7: manifest legacyIds is empty although earlier builds shipped the id internetclicker](#l7-manifest-legacyids-is-empty-although-earlier-builds-shipped-the-id-internetclicker)
- [ ] [L8: type-safety escapes throughout the transport](#l8-type-safety-escapes-throughout-the-transport)
- [ ] [L9: README promises the button turns red when disconnected, but no red style is defined](#l9-readme-promises-the-button-turns-red-when-disconnected-but-no-red-style-is-defined)
- [ ] [L11: the connection_status feedback has no description](#l11-the-connection_status-feedback-has-no-description)
- [ ] [N1: GetSettings isActive is logged but never surfaced](#n1-getsettings-isactive-is-logged-but-never-surfaced)
- [ ] [N4: init() blocks on the network connect](#n4-init-blocks-on-the-network-connect)
- [ ] [N5: the non-Azure negotiate error message reads like a bug](#n5-the-non-azure-negotiate-error-message-reads-like-a-bug)
- [ ] [N6: manifest keywords is empty](#n6-manifest-keywords-is-empty)

## 🔴 Critical

### C1: yarn install --immutable fails — committed yarn.lock is a Yarn 1 Classic lockfile

**File:** `yarn.lock`, `package.json`
**Validator IDs:** `BUILD-INSTALL`, `BUILD-PACKAGE`

The committed `yarn.lock` begins with `# yarn lockfile v1` and contains no `__metadata` block — it is a **Yarn 1 (Classic)** lockfile. The project, however, declares `engines.yarn: "^4"` and ships a Yarn 4-style `.yarnrc.yml`. The two cannot coexist:

- With Yarn 1 (what bare `corepack enable` gives you when no version is pinned), install aborts immediately:
  `error companion-module-internetclicker@2.0.6: The engine "yarn" is incompatible with this module. Expected version "^4". Got "1.22.22"`
- With Yarn 4, the Classic lockfile is unusable and `--immutable` fails:
  `YN0028: The lockfile would have been modified by this install, which is explicitly forbidden.`

The stale lockfile also resolves `@companion-module/base` to **2.1.0**, while `package.json` pins it exactly to **2.0.4** — the lockfile does not even describe the declared dependency set.

This blocks the module: `.github/workflows/node.yaml` runs `yarn install` with `CI: true` (which is implicitly `--immutable` under Yarn 4), and the Bitfocus build pipeline runs `yarn package` off the same install. Neither can succeed from a clean checkout.

Verified: after deleting the Classic lockfile and running `yarn@4.11.0 install`, both `yarn build` and `yarn package` complete successfully — so this is purely a lockfile/toolchain problem, not a source problem.

**Fix:** Delete the Yarn 1 `yarn.lock`, run `yarn install` under Yarn 4 (see C2) to generate a proper Yarn 4 lockfile, and commit it. Confirm `yarn install --immutable && yarn package` succeeds in a fresh clone before re-tagging.

### C2: packageManager field missing and .yarnrc.yml requires Yarn 4.10+

**File:** `package.json`, `.yarnrc.yml`
**Validator IDs:** `PKG-FIELD`, `CONFIG-DIFF`

`package.json` has no `packageManager` field (the template has `"packageManager": "yarn@4.12.0"`). Without it, corepack has nothing to resolve and falls back to Yarn 1 — which is exactly what triggers the engine error in C1.


**Fix:** Add `"packageManager": "yarn@4.12.0"` to `package.json` (matching the template) so corepack resolves a Yarn version that understands these settings. 

### C3: tsconfig.build.json diverges from the template

**File:** `tsconfig.build.json`
**Validator ID:** `CONFIG-DIFF`

The module's `compilerOptions` are `outDir`, `rootDir: "./src"`, `verbatimModuleSyntax: true`. The template's are `outDir`, `baseUrl: "./"`, `paths: { "*": ["./node_modules/*"] }`, `module: "nodenext"`, `moduleResolution: "nodenext"`.

The build does compile with the module's version, but Bitfocus requires config-file parity with the official template so that module builds stay reproducible as the toolchain moves.

**Fix:** Restore the template's `tsconfig.build.json` `compilerOptions` block. If `rootDir`/`verbatimModuleSyntax` are genuinely needed, add them **on top of** the template options rather than replacing them.

### C4: .gitignore is missing /\*.tgz and contains corrupted UTF-16 bytes

**File:** `.gitignore`
**Validator ID:** `CONFIG-DIFF`

Two problems in one file:

1. The template entry `/*.tgz` is missing — which is what let the packaged tarball get committed (C5).
2. The file is not valid text. `file .gitignore` reports `data`, and a hexdump of the tail shows UTF-16LE bytes appended to an otherwise UTF-8 file:

```
0000004b: 73 00 6f 00 75 00 72 00 63 00 65 00 2f 00 64 00 69 00 73 00 74 00 2f 00 0d 00 0a 00   s.o.u.r.c.e./.d.i.s.t./...
```

which renders as `s o u r c e / d i s t /` and `s o u r c e / p k g /`, each duplicated twice — the signature of a PowerShell `>>` append. Those bytes do not function as ignore rules, and the mixed encoding will confuse diffs and tooling.

**Fix:** Rewrite `.gitignore` as plain UTF-8 (LF), starting from the template's contents, and add `/*.tgz`. Drop the `source/dist/` and `source/pkg/` entries unless they are intentional — there is no `source/` directory in this repo.

### C5: build artifact .tgz committed to the repo and README tells users to sideload it

**File:** `internetclicker-internetclickerremote-2.0.6.tgz`, `README.md`
**Validator ID:** `GITIGNORED-COMMITTED`

The packaged module tarball is committed at the repo root, and `README.md` steps 1–5 instruct users to download that `.tgz` and import it via Companion's **Import module package** button. Git history shows this pattern repeating (`Remove old 2.0.3 tgz`, `Remove old tgz files`) — every release adds a new binary blob.

Once the module ships through the Bitfocus store these instructions are wrong, and a committed tarball inevitably drifts out of sync with `src/`.

**Fix:** Delete the `.tgz` from the repo (and from history if practical), add `/*.tgz` to `.gitignore` (C4), and rewrite the README's *Getting Started* section to say the module installs from the Companion module store. Keep the sideload steps only as a clearly-labelled beta/manual fallback, if at all.

### C6: package.json repository.url is still the template placeholder

**File:** `package.json`
**Validator ID:** `PKG-REPO`

```json
"url": "git+https://github.com/YOUR_GITHUB_USERNAME/companion-module-internetclicker.git"
```

This points at a repository that does not exist, and it contradicts `companion/manifest.json`, which correctly reads `git+https://github.com/bitfocus/companion-module-internetclicker-internetclickerremote.git`.

**Fix:** Set `repository.url` to `git+https://github.com/bitfocus/companion-module-internetclicker-internetclickerremote.git` to match the manifest.

### C8: companion/HELP.md is the template stub

**File:** `companion/HELP.md`
**Validator ID:** `HELP-STUB`

The entire file is:

```markdown
## Your module

Write some help for your users here!
```

HELP.md is what Companion shows in the module's help panel, so users currently get the template placeholder.

**Fix:** Write real user documentation: what Internet Clicker is, where to find the Event Code in the Internet Clicker UI, the five available actions, the Connection Status feedback, the `$(internetclicker:eventCode)` variable, and basic troubleshooting. The existing README content is a good starting point.

## 🟠 High

### H1: connection loss is never detected — status stays Ok and the feedback stays green

**File:** `src/main.ts:140-144` (with `src/main.ts:194-281`)

`ws.onclose` only touches the transport's own private state:

```ts
this.ws.onclose = () => {
    clearTimeout(timeout)
    this.connected = false
    this.logger.info('WebSocket closed')
}
```

Nothing propagates to `ModuleInstance`. `this.isConnected` stays `true`, `updateStatus()` is never called again, and `checkFeedbacks('connection_status')` is never re-run.

Concrete scenario: mid-presentation the Wi-Fi blips, the laptop sleeps, or Azure SignalR recycles the connection. Companion still shows the connection as **OK**, the Connection Status button stays green, and every press of Next Slide silently does nothing except write `Command rightArrow failed: Error: Not connected` to the log. The presenter has no on-surface indication that the clicker is dead. The same applies to the server's own `type: 7` close frame handled at `src/main.ts:123-127`.

For a live-presentation remote, this is the most consequential defect in the module.

**Fix:** Give `SignalRConnection` a disconnect callback (e.g. an `onDisconnect` property, or an internal `'__closed'` event) fired from `onclose` — guarded by a `stopping` flag so an intentional `stop()` does not trigger it. Wire it in `initConnection()` to `this.isConnected = false`, `this.updateStatus(InstanceStatus.Disconnected, 'Connection lost')`, `this.checkFeedbacks('connection_status')`, and the reconnect path from H3.

### H2: start() can hang forever — the connect timeout is cleared before the handshake and onclose never rejects

**File:** `src/main.ts:85-94`, `src/main.ts:140-144`

The 10-second guard is cleared in `onopen` (line 90), but the promise only settles later, in `onmessage`, when the SignalR handshake reply arrives (line 111). And `onclose` (line 140) *also* clears the timeout without calling `reject`.

That leaves two paths where the promise never settles at all:

- The socket opens and the server never sends a handshake frame (rejected/expired access token, wrong hub, half-open connection through a proxy or firewall) — the only timer was already cleared in `onopen`.
- The socket opens and then closes before the handshake — `onclose` clears the timer and returns silently.

In both cases `await this.connection.start()` at line 260 never returns, so `init()` / `configUpdated()` never resolve. The connection sits on **Connecting** indefinitely, the `catch` block that would set `ConnectionFailure` is never reached, and the user sees only `WebSocket closed` in the log. Restarting Companion is the only recovery.

**Fix:** Keep a single overall deadline that is cleared only on the paths that actually settle the promise (`resolve` and `reject`), not in `onopen`. Add `if (!this.connected) reject(new Error('WebSocket closed before handshake'))` to `onclose`. Guard `resolve`/`reject` with a `settled` flag so late `onerror`/`onclose` events become no-ops, and call `this.ws?.close()` on the timeout path so the socket is not left half-open.

### H3: no automatic reconnect — one transient failure disables the module permanently

**File:** `src/main.ts:230-271`

A connection is attempted exactly once, from `init()` or `configUpdated()`. There is no retry, no backoff, and no timer anywhere in the module. Any transient failure — the Internet Clicker service restarting, a laptop sleep/wake, a network change, or Azure SignalR's routine connection recycling on a long session — permanently disables the module until the user manually disables and re-enables the connection or re-saves the config.

Combined with H1 (the failure is invisible), the practical result is a clicker that silently stops working part-way through an event.

**Fix:** Add a reconnect timer with capped exponential backoff (e.g. 1 s → 30 s), started from the disconnect handler (H1) and from the `catch` at lines 265-270. Set `InstanceStatus.Connecting` while retrying. Store the timer handle and clear it in `destroy()` and at the top of `initConnection()` so retries never outlive the instance or stack up.

### H4: destroy() or configUpdated() during a pending connect leaves a zombie WebSocket and clobbers status

**File:** `src/main.ts:194-207`, `src/main.ts:230-234`, `src/main.ts:56-83`

`destroy()` calls `connection.stop()`, but `stop()` can only close a socket that already exists. If `start()` is still inside `await fetch(this.negotiateUrl)` (line 59), there is no socket yet — `stop()` closes nothing, `this.connection` is set to `null`, and the orphaned `SignalRConnection` carries on: when the negotiate response finally arrives it constructs `new WebSocket(wsUrl)` (line 83) and connects. That socket is kept alive by its own event handlers and nothing will ever close it. On success, line 262 then calls `this.updateStatus(InstanceStatus.Ok)` on a destroyed instance.

The same re-entrancy bites `configUpdated()`, which calls `initConnection()` with no in-flight guard. Save the config twice in quick succession and the abandoned first attempt keeps running; when it eventually settles it overwrites the live connection's status — setting `ConnectionFailure` on a perfectly healthy connection, or a stale `Ok` on a closed one.

Both are triggered by ordinary user actions: deleting a connection while `internetclicker.com` is slow, or fixing a typo in the Event Code and saving twice.

**Fix:** Add an `AbortController` to `SignalRConnection`, pass its signal to `fetch`, and abort it in `stop()`; check the aborted flag after the negotiate `await` and bail out before constructing the WebSocket. In `ModuleInstance`, capture `const gen = ++this.connectGen` at the top of `initConnection()` and ignore every success/failure path whose generation is stale. Make `initConnection()` a no-op once the instance has been destroyed.

### H5: a rejected handshake leaves the connection marked connected with the socket open

**File:** `src/main.ts:104-114`

```ts
if (!this.connected) {
    if (parsed.error) {
        reject(new Error(`Handshake error: ${parsed.error}`))
    } else { ... }
    continue
}
```

On a handshake error the code rejects but sets no terminal flag and never closes the socket. `this.connected` is still `false`, so the **next** frame the server sends takes the same `!this.connected` branch, sets `this.connected = true`, and calls a now-no-op `resolve()`.

Net effect: `initConnection()`'s catch has already set `ConnectionFailure` and `isConnected = false`, yet `this.connection` is non-null and internally marked connected. `sendCommand()` (line 273, which only checks `this.connection`) then happily serialises invocations onto a hub that rejected the handshake — no throw, no log, and the button appears to work while doing nothing. The socket is leaked on this path as well.

**Fix:** On handshake error, call `this.ws?.close()`, null the socket, mark the connection dead with a terminal flag, and return from the message handler instead of `continue`.

### H6: presets.ts ships the unmodified template placeholder preset

**File:** `src/presets.ts:5-38`

The entire file is untouched template scaffolding: section `Section One` → group `Group One` with description *"A starting point for preset definitions!"*, containing one preset with `name: 'Name'`, text *"My first Preset button"*, `steps: []` and `feedbacks: []`.

Every user who opens the Presets tab sees a placeholder button that does literally nothing when dragged onto a page — it has no actions attached. The module has five obvious presettable actions and one feedback.

**Fix:** Replace with real presets for Next Slide, Previous Slide, Start/Pause/Stop Timer — each with `steps: [{ down: [{ actionId: 'next', options: {} }], up: [] }]` and the `connection_status` feedback attached — grouped into meaningfully named sections (e.g. `slides`, `timer`). If presets are not wanted for this release, delete `src/presets.ts` and the `updatePresets()` call at `src/main.ts:187` and `src/main.ts:222-224` rather than shipping the placeholder.

### H7: yarn lint fails with 3 errors

**File:** `src/main.ts:78`, `src/main.ts:79`, `src/main.ts:136`
**Validator ID:** `LINT`

`yarn lint` exits non-zero — and `.github/workflows/node.yaml` runs it, so CI fails:

```
src/main.ts
   78:16  error  Replace `·negotiateData.url.replace(...)` with `⏎↹↹↹negotiateData.url.replace(...)·+`   prettier/prettier
   79:4   error  Replace `+·'&access_token='·+·` with `'&access_token='·+⏎↹↹↹`                            prettier/prettier
  136:43  error  'err' will use Object's default stringification format ('[object Object]')
                 when stringified                                                          @typescript-eslint/no-base-to-string

✖ 3 problems (3 errors, 0 warnings)
```

The two prettier errors are auto-fixable. The third is a genuine defect: `this.logger.error(\`WebSocket error: ${err}\`)` stringifies a DOM `Event` and produces `WebSocket error: [object Event]` — no diagnostic value in exactly the log line a user will send you for support.

**Fix:** Run `yarn format` (or `yarn lint:raw --fix`) for the prettier errors. For line 136, extract a real message, e.g. `const msg = (err as ErrorEvent)?.message ?? (err as any)?.error?.message ?? 'unknown'`, and log that.

## 🟡 Medium

### M1: negotiate fetch() has no timeout or abort signal

**File:** `src/main.ts:59-62`

Node's `fetch` has no default response timeout. If `internetclicker.com` accepts the TCP connection but never responds — captive portal, DNS blackhole, firewall DROP, service outage — `await fetch(...)` blocks forever. `init()` never completes, the instance is pinned on **Connecting**, nothing is logged, and (per H4) `destroy()` cannot cancel it.

**Fix:** Pass `signal: AbortSignal.timeout(10000)`, or better an `AbortController` stored on the connection so `stop()` can abort it too (which also fixes H4). Map `TimeoutError`/`AbortError` to `InstanceStatus.ConnectionFailure` with a clear message.

### M2: sendCommand() checks the wrong thing and hides failures from the operator

**File:** `src/main.ts:273-281`

```ts
if (this.connection) {
    this.connection.invoke(command).catch((err: any) => {
        this.log('error', `Command ${command} failed: ${err.toString()}`)
    })
} else {
    this.log('warn', `Cannot send command ${command}, not connected.`)
}
```

The guard tests `this.connection !== null`, which stays true even when the socket is dead — so the "not connected" warning almost never fires. Real failures land in the `.catch` as a log line only: no `updateStatus`, no `checkFeedbacks`, no reconnect trigger. Presses during a reconnect window are lost with no user-visible signal.

**Fix:** Check `this.isConnected` (kept accurate per H1) and, ideally, `ws.readyState`. In the `.catch`, set `this.isConnected = false`, `updateStatus(InstanceStatus.Disconnected)`, `checkFeedbacks('connection_status')`, and trigger the reconnect path.

### M3: isConnected goes stale on the BadConfig and teardown paths

**File:** `src/main.ts:230-240`

`initConnection()` stops and nulls the previous connection (lines 231-234) but never resets `this.isConnected`, and the `BadConfig` early return (lines 236-240) returns without touching it either.

Scenario: the module is connected, the user clears the Event Code and saves. Status correctly becomes **BadConfig**, but `isConnected` is still `true`, so every Connection Status feedback stays green and reports a working clicker that no longer exists.

**Fix:** After stopping the old connection at line 234, set `this.isConnected = false` and call `this.checkFeedbacks('connection_status')`, so both the teardown and the `BadConfig` paths report the true state.

### M4: no client keepalive — Azure SignalR will drop an idle connection

**File:** `src/main.ts:120-122`

The client only *echoes* server pings (`type: 6`); it never sends its own keepalive and has no "no traffic in N seconds" watchdog. A real SignalR client pings roughly every 15 seconds, and Azure SignalR closes client connections idle past its client-timeout window. A half-open TCP connection (NAT timeout, sleeping laptop) is likewise invisible until the OS eventually tears it down.

Combined with H1 and H3, the practical result is a module that silently dies after a quiet stretch with no button presses.

**Fix:** On successful handshake, start a `setInterval` (~15 s) sending `{"type":6}\x1e`. Record `lastMessageAt` on every inbound frame and force a reconnect if nothing has been received for ~30 s. Store the interval handle and `clearInterval` it in `stop()` and `destroy()`.

### M5: blanket catch in the message loop swallows handler errors

**File:** `src/main.ts:101-131`

```ts
} catch (_e) {
    // skip unparseable
}
```

The `try` spans `JSON.parse` **and** the `this.emit(...)` dispatch (line 119) **and** the ping `send` (line 122). So an exception thrown by any registered handler — or a send on a closing socket — is discarded with no log at all, indistinguishable from a genuinely malformed frame. Malformed server data is equally invisible, making field diagnosis impossible, and any future handler that updates variables or feedbacks will fail silently.

**Fix:** Narrow the `try` to `JSON.parse` only and `this.logger.warn` the offending payload (truncated). Dispatch outside it, or wrap each handler call in its own `try/catch` that logs.

### M6: negotiate response is untyped and the WebSocket URL is built by string concatenation

**File:** `src/main.ts:68-79`

`const negotiateData: any = await negotiateResponse.json()` — untyped, then `negotiateData.url` is assumed to be a string that already carries a query string, because line 79 appends `'&access_token=' + ...`. If the server ever returns a URL without query params, or a self-hosted non-Azure negotiate payload (the standard `connectionToken` form), the module builds a malformed `wss://host/path&access_token=…` and fails with an opaque error. `await negotiateResponse.json()` also throws a confusing `SyntaxError` when the body is not JSON — e.g. an HTML error page or captive-portal interstitial.

**Fix:** Declare a response type, validate `typeof url === 'string' && typeof accessToken === 'string'`, and build the URL with `new URL()` + `searchParams.set('access_token', …)` instead of concatenation. Wrap `.json()` so a non-JSON body yields "Unexpected response from server" rather than a parser error.

### M7: Event Code config field has no default, required flag, tooltip or trimming

**File:** `src/config.ts:9-14` (with `src/main.ts:236`, `src/main.ts:244`)

```ts
{ type: 'textinput', id: 'code', label: 'Event Code', width: 12 }
```

No `default`, no `required`, no `tooltip`, no `regex`. `ModuleConfig` declares `code: string`, but the value is `undefined` on a fresh instance — only the falsy check at line 236 keeps that from throwing. And the value is never trimmed: a code pasted with a trailing space or newline is URL-encoded verbatim at line 244 and produces a negotiate failure the operator cannot diagnose.

**Fix:** Add `default: ''`, `required: true`, and a `tooltip` explaining where the Event Code appears in the Internet Clicker UI (plus a `regex` if the code has a known format). Trim the value before use, and treat a whitespace-only code as `BadConfig` rather than letting it become a `ConnectionFailure`.

### M8: WebSocket errors after the handshake are swallowed

**File:** `src/main.ts:134-138`

Once the handshake has resolved, the `reject()` inside `onerror` is a no-op, so an error on an established connection produces only a log line. Status stays **Ok**, `isConnected` stays `true`, and the feedback stays green.

**Fix:** Route `onerror` through the same disconnect path as H1 whenever `connected === true`.

## 🟢 Low

### L1: the Event Code is logged in full inside the negotiate URL

**File:** `src/main.ts:58`

`this.logger.info(\`Negotiating at: ${this.negotiateUrl}\`)` prints the complete URL including `?code=<eventCode>`. The Event Code is effectively the credential for the presentation — anyone holding it can drive the slides. Companion logs are routinely pasted into support threads and screenshots.

(Credit where due: the Azure `accessToken` is correctly *not* logged.)

**Fix:** Log only `${urlObj.origin}${negotiatePath}` with the query string redacted, or drop the line to `debug`. See also L10.

### L2: catch (err: any) then err.message yields undefined on a non-Error throw

**File:** `src/main.ts:265-269`

If `new WebSocket()` throws a `DOMException`-like value, or anything throws a string, `err.message` is `undefined` — producing `Connection failed: undefined` in the log and `updateStatus(ConnectionFailure, undefined)` on the surface.

**Fix:** `catch (err: unknown)` with `const msg = err instanceof Error ? err.message : String(err)`.

### L3: binary WebSocket frames degrade to "[object Blob]"

**File:** `src/main.ts:97`

`typeof event.data === 'string' ? event.data : event.data.toString()` — undici delivers binary frames as `Blob`/`ArrayBuffer`, whose `toString()` is `"[object Blob]"`, which then silently fails `JSON.parse` and is swallowed by M5. Harmless today because the SignalR JSON protocol is text-only, but it will hide a protocol change.

**Fix:** Set `this.ws.binaryType = 'arraybuffer'` and decode explicitly with `new TextDecoder().decode(...)`, or handle `Blob` via `await blob.text()`.

### L4: checkFeedbacks() called inside destroy()

**File:** `src/main.ts:200`

Re-evaluating feedbacks while the instance is being torn down has no observable effect at best; other modules have hit "instance already destroyed" warnings from this pattern.

**Fix:** Drop the call from `destroy()`. Its meaningful home is the disconnect handler from H1.

### L5: configUpdated() does not set Connecting

**File:** `src/main.ts:204-207`

Status stays at its previous value — often **Ok** — for the whole negotiate + connect window, so saving a bad Event Code shows a green, healthy-looking connection until it finally fails.

**Fix:** Call `this.updateStatus(InstanceStatus.Connecting)` at the top of `configUpdated()` (or of `initConnection()`), and set `isConnected = false` + `checkFeedbacks('connection_status')` there too (see M3).

### L6: stop() leaves event handlers attached and the handler map populated

**File:** `src/main.ts:148-154`

`stop()` calls `close()` but never detaches `onopen`/`onmessage`/`onerror`/`onclose`, and never clears `this.handlers`. A late `onclose` therefore logs `WebSocket closed` *after* `destroy()` has run. Once reconnect logic exists (H3), re-registering `on('GetSettings', …)` on a reused connection object would also duplicate handlers.

**Fix:** Null the four `on*` callbacks before `close()`, reset `this.handlers = {}`, and always construct a fresh `SignalRConnection` per attempt.

### L7: manifest legacyIds is empty although earlier builds shipped the id internetclicker

**File:** `companion/manifest.json:24`

The tagged `v1.0.12` / `v1.0.13` builds shipped `"id": "internetclicker"`, and that release's README instructed users to sideload a committed `.tgz`. Any user who did so will find their existing connections orphaned after upgrading to the `internetclicker-internetclickerremote` id, rather than migrated. Commit `17db4d9` explicitly removed `legacyIds`.

**Fix:** If those builds reached real users, add `"legacyIds": ["internetclicker"]`. If they were only ever used in testing, leaving it empty is fine — but make that a deliberate decision, since `legacyIds` cannot be retrofitted once users have re-created their connections.

### L8: type-safety escapes throughout the transport

**File:** `src/main.ts:24`, `:41`, `:48`, `:68`, `:93`, `:156`

`handlers: Record<string, ((...args: any[]) => void)[]>`, `emit(...args: any[])`, `invoke(method, ...args: any[])`, `negotiateData: any`, and the non-null assertion `this.ws!.send(...)` at line 93. That `!` is safe only because `onopen` cannot currently fire after `this.ws` is reassigned — an invariant that breaks the moment reconnect logic (H3) is added.

**Fix:** Define a `SignalRMessage` union type and a typed handler map. Capture the socket in a local `const ws = new WebSocket(wsUrl)` and use `ws.send(...)` inside the handlers instead of `this.ws!`.

### L9: README promises the button turns red when disconnected, but no red style is defined

**File:** `README.md` (Feedbacks section), `src/feedbacks.ts:15-18`

The README states the button "will turn **green** when connected and **red** when disconnected". `defaultStyle` only defines the connected (green) style — when the feedback is false the button simply reverts to whatever base style the user set, which is not red.

**Fix:** Either correct the README to say the button returns to its base style when disconnected, or ship a preset whose base style is red so the documented behaviour holds out of the box.

### L11: the connection_status feedback has no description

**File:** `src/feedbacks.ts:12-23`

The feedback defines `name` but no `description`, so users get no explanation in the feedback picker of what it indicates or how to style the false state.

**Fix:** Add a `description` such as "True while the module is connected to the Internet Clicker service. Set the button's base style for the disconnected appearance."

## 💡 Nice to Have

### N1: GetSettings isActive is logged but never surfaced

**File:** `src/main.ts:255-257`

The server pushes `isActive` on connect and the handler only writes it to the log. The operator cannot see on a button whether the event is actually active.

**Fix:** Store it on the instance and expose it as a variable (e.g. `eventActive`) plus a boolean feedback, so `checkFeedbacks` can react to later pushes.

### N4: init() blocks on the network connect

**File:** `src/main.ts:190`

`await this.initConnection()` means module startup takes as long as negotiate plus handshake — or forever, per H2 and M1. Most modules set `Connecting` and kick off the connection without blocking `init()`.

**Fix:** Set `Connecting`, start the connection without awaiting it in `init()`, and let the reconnect loop own the connection lifecycle.

### N5: the non-Azure negotiate error message reads like a bug

**File:** `src/main.ts:70-72`

`throw new Error('No Azure SignalR redirect received')` fires whenever the negotiate response lacks `url`/`accessToken`. A self-hosted or non-redirecting SignalR endpoint (the standard `connectionToken` form) surfaces this to the user as what looks like an internal error.

**Fix:** Either handle the `connectionToken` form as a fallback, or reword to something actionable: "Server did not return an Azure SignalR endpoint — check the Event Code and that internetclicker.com is reachable."

### N6: manifest keywords is empty

**File:** `companion/manifest.json:26`

`"keywords": []` — the module will not surface for searches like "clicker", "presentation", or "slides" in the Companion module list.

**Fix:** Add a few relevant, non-redundant keywords (avoid repeating the manufacturer or product name, which are already indexed).
