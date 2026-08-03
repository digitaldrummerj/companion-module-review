# Review: nextologies-nextotalk v1.0.0

| | |
|---|---|
| **Module** | nextologies-nextotalk |
| **Version** | v1.0.0 |
| **Scope** | tag (first release — no previous tag, so reviewed as a full `src/` review; all findings new) |
| **Language / API** | TS / @companion-module/base v1 (~1.14.1) |
| **Protocols** | WebSocket (server — `ws` ^8.21.0) |
| **Reviewed** | 2026-08-03 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: no error listener on accepted client sockets — any peer can crash the module](#c1-no-error-listener-on-accepted-client-sockets--any-peer-can-crash-the-module)
- [ ] [C3: eslint.config.mjs differs from the template](#c3-eslintconfigmjs-differs-from-the-template)
- [ ] [C4: package.json repository.url points to the wrong org](#c4-packagejson-repositoryurl-points-to-the-wrong-org)
- [ ] [C6: banned/low-value manifest keyword NextoTalk](#c6-bannedlow-value-manifest-keyword-nextotalk)
- [ ] [C7: MODULE_VERSION is 0.4.0 in a v1.0.0 release](#c7-module_version-is-040-in-a-v100-release)

**Non-blocking**

- [ ] [M1: InstanceStatus.Ok is reported before the server is listening](#m1-instancestatusok-is-reported-before-the-server-is-listening)
- [ ] [M2: no ping/pong keepalive — half-open connections accumulate forever](#m2-no-pingpong-keepalive--half-open-connections-accumulate-forever)
- [ ] [M3: server binds all interfaces with no origin check or authentication](#m3-server-binds-all-interfaces-with-no-origin-check-or-authentication)
- [ ] [M5: missing meetingId or sdKeyId silently creates phantom undefined state entries](#m5-missing-meetingid-or-sdkeyid-silently-creates-phantom-undefined-state-entries)
- [ ] [M6: map_sdkey_to_room stores coordinates under an action id but every reader keys by controlId](#m6-map_sdkey_to_room-stores-coordinates-under-an-action-id-but-every-reader-keys-by-controlid)
- [ ] [M8: info-level logging on every message and every render floods the Companion log](#m8-info-level-logging-on-every-message-and-every-render-floods-the-companion-log)
- [ ] [M9: room state maps grow without bound](#m9-room-state-maps-grow-without-bound)
- [ ] [M11: hardcoded 8-column grid and Companion 2.x bank: control-id parsing](#m11-hardcoded-8-column-grid-and-companion-2x-bank-control-id-parsing)
- [ ] [M12: upgrade script writes feedback options that do not exist](#m12-upgrade-script-writes-feedback-options-that-do-not-exist)
- [ ] [M13: 20 declared variables are never assigned a value](#m13-20-declared-variables-are-never-assigned-a-value)
- [ ] [L1: all inbound-message failures are labelled WS Parse Error](#l1-all-inbound-message-failures-are-labelled-ws-parse-error)
- [ ] [L2: the Port in use catch branch is dead code](#l2-the-port-in-use-catch-branch-is-dead-code)

- [ ] [L5: controlIdToLocationMap is never pruned](#l5-controlidtolocationmap-is-never-pruned)
- [ ] [L6: optimistic mute toggle is applied even with zero connected clients](#l6-optimistic-mute-toggle-is-applied-even-with-zero-connected-clients)
- [ ] [L7: room_allocated is broadcast back to the sender](#l7-room_allocated-is-broadcast-back-to-the-sender)
- [ ] [L8: dead code — MeetingInfo, getRoomByNumber, RoomMeta](#l8-dead-code--meetinginfo-getroombynumber-roommeta)
- [ ] [L9: untyped variable definition array](#l9-untyped-variable-definition-array)
- [ ] [L10: .idea/ is committed to the repo](#l10-idea-is-committed-to-the-repo)
- [ ] [L11: toggle_mic action has no description](#l11-toggle_mic-action-has-no-description)
- [ ] [N1: no status or variable reflecting connected clients](#n1-no-status-or-variable-reflecting-connected-clients)
- [ ] [N2: connection count is unbounded](#n2-connection-count-is-unbounded)
- [ ] [N3: no idle/handshake timeout on accepted connections](#n3-no-idlehandshake-timeout-on-accepted-connections)
- [ ] [N4: SocketCommand.data is any, disabling all inbound type checking](#n4-socketcommanddata-is-any-disabling-all-inbound-type-checking)
- [ ] [N5: roomNumber option is capped at 100 and lacks a description](#n5-roomnumber-option-is-capped-at-100-and-lacks-a-description)
- [ ] [N6: presets could use headline strings](#n6-presets-could-use-headline-strings)
- [ ] [N7: toBool maps every unrecognised value to false](#n7-tobool-maps-every-unrecognised-value-to-false)

## 🔴 Critical

### C1: no error listener on accepted client sockets — any peer can crash the module

**File:** `src/main.ts:73-96`

The `connection` handler registers `'message'` (line 84) and `'close'` (line 92) but never `ws.on('error')`. The server-level handler at line 98 does not cover per-connection errors. In `ws` 8.21.0 the server does not attach a default error listener to the emitted `WebSocket`; `receiverOnError` and `socketOnError` both call `websocket.emit('error', err)`. An `EventEmitter` emitting `'error'` with no listener throws `ERR_UNHANDLED_ERROR`, and `@companion-module/base` 1.14.1 installs no `process.on('uncaughtException')` handler — so the module child process dies.

This is trivially reachable without any authentication: an `ECONNRESET` when the extension's host sleeps or drops Wi-Fi, or a single malformed frame from a port scanner (invalid opcode, RSV1 set, unmasked client frame, invalid UTF-8, or a payload over the 100 MiB default `maxPayload`). Every button goes down and all in-memory room state — which is never persisted — is lost.

**Fix:** inside the `connection` handler, add an error listener that logs, removes the socket from `this.clients`, and terminates it:

```ts
ws.on('error', (err) => {
	this.log('error', `WS client error: ${err.message}`)
	this.clients.delete(ws)
	try { ws.terminate() } catch { /* already gone */ }
})
```

Also pass a sane `maxPayload` (e.g. `new WebSocketServer({ port, maxPayload: 1024 * 1024 })`) so an oversize frame is rejected cheaply rather than buffered.

### C3: eslint.config.mjs differs from the template

**File:** `eslint.config.mjs`

The module wraps the generated config (`const baseConfig = await generateEslintConfig({...})`, then spreads it into a `customConfig` that disables `n/no-missing-import` and `node/no-unpublished-import`) where the template does `export default generateEslintConfig({...})`. Silencing the import-resolution rules hides real module-resolution problems.

**Fix:** restore `eslint.config.mjs` to the template form and fix whatever import errors the rules were suppressing.  Lint passes with these extra rules removed.

### C4: package.json repository.url points to the wrong org

**File:** `package.json` (`repository.url`)

`git+https://github.com/nxto-tv/companion-module-nextologies-nextotalk.git` — a published module must point at the Bitfocus org: `git+https://github.com/bitfocus/companion-module-nextologies-nextotalk.git`.

**Fix:** update `repository.url` (and, once the repo moves, the matching `repository`/`bugs` fields in `companion/manifest.json`, which have the same problem).

### C6: banned/low-value manifest keyword NextoTalk

**File:** `companion/manifest.json` (`keywords`)

`NextoTalk` duplicates the product/manufacturer name, which is already indexed from `products`/`manufacturer`. Keywords should describe function, not repeat identity.

**Fix:** drop `Nextologies` and `NextoTalk` (and the near-duplicate `NextoTalk mic controller`); keep functional terms like `mic`, `mute`, `push to talk`, `conferencing`.

### C7: MODULE_VERSION is 0.4.0 in a v1.0.0 release

**File:** `src/main.ts:20, 80`

`const MODULE_VERSION = '0.4.0'` — its own comment says "Keep in sync with package.json / companion/manifest.json", and it wasn't. It is user-visible in the connection status string (lines 44, 70 → `v0.4.0 · :7005`), in the init log (line 42), and in the `module_version` variable (line 50). A second independent literal, `version: '1.0.0.0-companion'`, sits in the WS welcome payload at line 80 and will drift the same way, so the peer cannot tell which build it is talking to.

(`companion/manifest.json`'s `version: "0.4.0"` and `apiVersion: "0.0.0"` are **not** findings — `companion-module-build` overwrites both at package time, and the packaged `pkg/companion/manifest.json` correctly reads `1.0.0` / `1.14.1`. Still worth aligning for readers of the repo.)

**Fix:** drop the constant and both literals; derive one value at build time from `package.json` and use it for the status text, the variable, and the welcome payload.

## 🟡 Medium

### M1: InstanceStatus.Ok is reported before the server is listening

**File:** `src/main.ts:44, 70`

`init()` sets `Ok` at line 44 before `initWebSocketServer()` is even called, and line 70 sets `Ok` immediately after the constructor returns. Binding is asynchronous, so on `EADDRINUSE` the UI shows green briefly before line 98's handler flips it. `companion/HELP.md:19` tells users the status shows **OK** with the port when the connection is live, which this makes untrustworthy.

**Fix:** drop the `updateStatus` at line 44, set `InstanceStatus.Connecting` before constructing the server, and move the `Ok` into `this.wss.on('listening', …)`.

### M2: no ping/pong keepalive — half-open connections accumulate forever

**File:** `src/main.ts:73-96`

There is no ping interval and no pong tracking. When the extension's host sleeps, drops off Wi-Fi, or is force-quit without a TCP FIN, the socket never emits `'close'`, so it is never removed from `this.clients` (line 93 is the only removal path). The zombie stays `readyState === OPEN`, so `broadcast()` keeps writing `toggle_mic` requests into a dead socket while the operator sees no response and no error. Over a multi-day show the set grows unbounded.

**Fix:** implement the standard `ws` keepalive — set `isAlive = true` on `'connection'` and `'pong'`, and run a 30 s `setInterval` that terminates any socket still `isAlive === false` before pinging the rest. Store the handle and `clearInterval` it in `destroy()` and on server restart.

### M3: server binds all interfaces with no origin check or authentication

**File:** `src/main.ts:69`

`new WebSocketServer({ port })` listens on `0.0.0.0`. There is no `host` option, no `verifyClient`, no shared secret, and no `Origin` validation. `handleMessage` accepts `reset` (line 116 — wipes all mappings), `release_key` (line 353 — blanks a button mid-show), `map_meeting_room_to_key`, and `update_mic_status` from any peer. Any device on the venue network can repoint or blank the operator's talkback buttons — and because browser WebSocket connections are not subject to CORS, so can any web page open on a machine on that LAN.

**Fix:** default `host` to `'127.0.0.1'` (the extension runs on the same machine per `HELP.md`) with an optional config field to widen it, and/or add a `verifyClient` that checks a token from a config field. At minimum, document the exposure in `companion/HELP.md`.

### M5: missing meetingId or sdKeyId silently creates phantom undefined state entries

**File:** `src/main.ts:146-191, 256-291, 331-339`

`SocketCommand.data` is `any` (`command.ts:4`), so nothing type-checks these payloads. In `map_meeting_room_to_key`, if `data.meetingId` is absent the `String()` coercion at lines 150-152 is skipped, `mapActionToMeeting(sdKeyId, undefined)` (line 155) takes the **unmap** branch — silently blanking the operator's button — and lines 164/167/170/181 then write `meetingRoomNumberMap['undefined']`, `activeMeetings.add('undefined')`, and `meetingIdTitleMap['undefined']` (via `String()` in `state.ts:56/66/81`). The phantom room shows up in `persisted_room_meta` and in the `getRoomByNumber` scan. `update_mic_status` (lines 272/279/288) and `update_room_name` (line 337) have the same hole, and an `undefined` `sdKeyId` yields an `actionIdMeetingIdMap['undefined']` key.

**Fix:** validate at the top of each case and bail with a warning — `if (meetingId === undefined || meetingId === null || meetingId === '') { this.log('warn', …); break }` — and the same for `sdKeyId`. Better, narrow `SocketCommand['data']` to per-action typed payloads (see N4).

### M6: map_sdkey_to_room stores coordinates under an action id but every reader keys by controlId

**File:** `src/main.ts:141-142`

`state.setControlLocation(sdKeyId, …)` and `checkActionPositionUpdate(sdKeyId)` are handed `sdKeyId`, which is the *action instance* id (that is what the module sends out as `data.id` at lines 460/511). But `controlIdToLocationMap` is read with `action.controlId` (lines 412, 485) and `controlIdToActionId` is keyed by `controlId` (line 388). So the lookup at line 142 always misses and the stored entry can never be read — server-supplied coordinates are silently ignored.

**Fix:** translate first — resolve `actionId → controlId` (e.g. via `activeActions.get(sdKeyId).controlId`) and key `setControlLocation`/`checkActionPositionUpdate` by that.

### M8: info-level logging on every message and every render floods the Companion log

**File:** `src/feedbacks.ts:22,31,35,40,46,48,56,64-67,87`; `src/main.ts:109,161,184,278,281,301,338,366,386,391,414,453,501`

A single `update_mic_status` produces an `info` line in `handleMessage` plus 2-4 `info` lines per rendered button in the feedback callback. At speaking-indicator rates that is hundreds of lines per second — a real UI and disk burden, and it buries genuine errors. Across `src/` there are 26 `info` calls against 5 `debug`.

**Fix:** demote every per-message and per-render log to `'debug'`; reserve `'info'` for lifecycle events (server started/stopped, client connect/disconnect, mapping changes).

### M9: room state maps grow without bound

**File:** `src/state.ts:14-18, 78`

Entries are added for every `meetingId` ever seen (`update_mic_status`, and the `nextotalk_rooms` bulk loop at `main.ts:311-326`) but removed only by an explicit `release_key` or `reset`. When a meeting ends, `main.ts:279` merely calls `setMeetingActive(meetingId, false)` — the five `Record` maps keep their entries forever. On a long-running install (weeks of uptime, hundreds of meetings a day) this is a steady leak that also slows the `Object.entries` scans at `feedbacks.ts:32`, `main.ts:210`, and `state.ts:117`.

**Fix:** evict a meeting's entries when it goes inactive (or age them out) — call `removeMeeting()` on the inactive path rather than only flipping the flag.

### M11: hardcoded 8-column grid and Companion 2.x bank: control-id parsing

**File:** `src/main.ts:488-497, 198`

`getCoordinatesFromAction` falls back to `/bank:(\d+):(\d+)/` with `Math.floor(buttonNum / 8)` and `buttonNum % 8`. `bank:page:bank` is the Companion 2.x control-id format — Companion 3/4 control IDs are opaque — and page grid size is user-configurable. So the fallback either never matches (returning `null` and suppressing `sd_key_appear`) or, on a non-8-column grid, reports the wrong row/column and the extension maps the wrong button. Line 198 likewise advertises a fixed `{ columns: 8, rows: 4 }` surface in the `get_sd_devices` response.

**Fix:** delete both regex fallbacks and rely solely on the `$(this:row)`/`$(this:column)` values resolved in the feedback callback; report the real grid size (or omit `size`).

### M12: upgrade script writes feedback options that do not exist

**File:** `src/upgrades.ts:21-36`

The script injects `discovery_row: '$(this:row)'` and `discovery_col: '$(this:column)'` into every saved `mic_status` feedback, but `feedbacks.ts:11-20` declares only a `roomNumber` option and nothing in the codebase reads those keys. For anyone migrating from the 0.4.0 pre-release it permanently writes two dead keys into their config; for fresh v1.0.0 installs it never runs at all.

**Fix:** since v1.0.0 is the first public release, reduce this to `export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = []`. If 0.4.0 installs must be cleaned up, write a script that *removes* `discovery_row`/`discovery_col` instead.

### M13: 20 declared variables are never assigned a value

**File:** `src/variables.ts:6-9`

The loop defines `room_1_name`…`room_10_name` and `room_1_status`…`room_10_status`, but the only `setVariableValues` call in the module is `main.ts:50` for `module_version`. Users browsing the variable picker see 20 variables that always resolve empty, and any button expression built on them silently produces nothing.

**Fix:** populate them from `ModuleState` whenever mic status or room name changes (alongside the existing `checkFeedbacks('mic_status')` calls), or delete lines 6-9 and keep only `module_version`.

## 🟢 Low

### L1: all inbound-message failures are labelled WS Parse Error

**File:** `src/main.ts:84-91`

The `try` wraps both `JSON.parse` (line 86) and the whole of `handleMessage` (line 87), so a `TypeError` deep inside a handler — e.g. `command.data.meetingId` at lines 132/148/257/296/332/354 when a peer sends `{"action":"update_mic_status"}` with no `data` — is logged as a parse error and swallowed, leaving state partially applied. `handleMessage`'s switch (lines 110-381) also has no `default:` case, so an unrecognised action vanishes with only the `debug` line at 109, and line 86 assumes the frame is a `Buffer` with no `isBinary` check.

**Fix:** split the try/catch — one around `JSON.parse` logging "WS parse error", a separate one around `handleMessage` logging "Error handling <action>". Add a `default:` that warns on unknown actions, guard `command?.data` before the switch, and check `typeof command.action === 'string'`.

### L2: the Port in use catch branch is dead code

**File:** `src/main.ts:102-105`

`new WebSocketServer({ port })` does not throw synchronously on `EADDRINUSE` — the error arrives asynchronously on the `'error'` event. So the real port conflict lands at line 100 with the raw `WS Error: listen EADDRINUSE…` string, while the friendly `Port ${port} in use?` at line 104 fires only for synchronous constructor validation errors. The troubleshooting table at `companion/HELP.md:143` points users at a status the module rarely produces.

**Fix:** remove the try/catch and move the port-in-use wording into the `error` handler behind `if ((err as NodeJS.ErrnoException).code === 'EADDRINUSE')`.

### L5: controlIdToLocationMap is never pruned

**File:** `src/main.ts:394`; `src/state.ts:24`

`onActionAppearance(false)` deletes `lastReportedLocation` (keyed by action id) but not the location entry (keyed by controlId), so the map grows slowly as buttons are created and deleted.

**Fix:** delete the `controlIdToLocationMap` entry on unsubscribe once no action remains for that control (pairs with M10).

### L6: optimistic mute toggle is applied even with zero connected clients

**File:** `src/actions.ts:13-27`

`broadcast()` silently no-ops when `this.clients` is empty, but line 16 has already flipped the local state and line 17 repainted the key. The operator sees a colour change for a command that never reached the app.

**Fix:** expose a client-count getter and bail with a warning before the optimistic update when no client is connected, and/or reconcile on a timeout.

### L7: room_allocated is broadcast back to the sender

**File:** `src/main.ts:253`

`broadcast()` has no sender exclusion, so the originating client receives its own message back; if the peer ever re-processes and re-broadcasts, this is an echo loop.

**Fix:** add an `exclude?: WebSocket` parameter to `broadcast()` and pass the originating `ws`.

### L8: dead code — MeetingInfo, getRoomByNumber, RoomMeta

**File:** `src/state.ts:1-10, 116-126`; `src/command.ts:43-47`

None of the three is referenced anywhere in `src/`. `RoomMeta` in particular duplicates the inline type built at `main.ts:207`.

**Fix:** delete all three, or put `RoomMeta` to work as the type of `roomMetaMap` at `main.ts:207`.

### L9: untyped variable definition array

**File:** `src/variables.ts:4`

`const variables = []` is an evolving `any[]`, so the objects pushed at lines 5, 7, and 8 are never checked against `CompanionVariableDefinition` — a typo in `variableId` would compile.

**Fix:** `import type { CompanionVariableDefinition } from '@companion-module/base'` and declare `const variables: CompanionVariableDefinition[] = []`.

### L10: .idea/ is committed to the repo

**File:** `.gitignore`

Six JetBrains files are tracked: `.idea/.gitignore`, `.idea/modules.xml`, `.idea/nextotalk-companion-plugin.iml`, `.idea/prettier.xml`, `.idea/vcs.xml`, `.idea/inspectionProfiles/Project_Default.xml`. The template `.gitignore` covers `/.vscode` but not `/.idea`.

**Fix:** add `/.idea` to `.gitignore` and run `git rm -r --cached .idea`.

### L11: toggle_mic action has no description

**File:** `src/actions.ts:6-8`

The action has zero options and its target room is bound at runtime by the extension, so in the action picker a user has no way to tell what it does or why there is no room selector.

**Fix:** add a `description`, e.g. "Toggles the mic of the meeting room the NextoTalk extension has mapped to this button. No options — the mapping is assigned at runtime."

## 💡 Nice to Have

### N1: no status or variable reflecting connected clients

**File:** `src/main.ts:557-562`

Because this is a server, `Ok` means only "the port is bound". With zero extensions connected, every `toggle_mic` broadcast is a silent no-op while the button still looks healthy. Consider holding `InstanceStatus.Connecting` ("waiting for NextoTalk") until the first client joins, reverting on the last `'close'`, plus a `clients_connected` variable so operators can build a link-up indicator.

### N2: connection count is unbounded

**File:** `src/main.ts:31, 74`

No max-connection cap; a misbehaving peer can open thousands of connections, each receiving every broadcast. This protocol expects a single extension — consider rejecting connections past a small limit.

### N3: no idle/handshake timeout on accepted connections

**File:** `src/main.ts:73-96`

A peer that completes the upgrade and then sends nothing holds a socket and a `clients` slot indefinitely. The keepalive in M2 largely covers this.

### N4: SocketCommand.data is any, disabling all inbound type checking

**File:** `src/command.ts:4`

A discriminated union keyed on `action` would have caught M5 and M6 at compile time.

### N5: roomNumber option is capped at 100 and lacks a description

**File:** `src/feedbacks.ts:12-19`

`max: 100` arbitrarily blocks room 101, and the "0 = Auto/None" semantics live only in the label — v1.13+ supports a persistent `description` hint.

### N6: presets could use headline strings

**File:** `src/presets.ts:23-39`

Add v1.10+ `headline` strings to the preset's action and feedback entries so users see what each part does in the button editor, and consider a second preset with `roomNumber` pre-set to a fixed room to demonstrate the non-auto mode.

### N7: toBool maps every unrecognised value to false

**File:** `src/main.ts:22-26`

`'yes'`, `'TRUE'`, and `2` all become `false` — i.e. "unmuted/green". A stricter parse plus a warning on unknown input would avoid a wrong-colour key.
