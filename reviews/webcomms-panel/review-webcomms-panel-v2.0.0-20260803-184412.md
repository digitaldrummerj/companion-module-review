# Module Review: webcomms-panel v2.0.0

| | |
|---|---|
| **Module** | `companion-module-webcomms-panel` |
| **Review tag** | `v2.0.0` |
| **Previous tag** | `v1.0.12` |
| **Scope** | `tag` — only the `v1.0.12..v2.0.0` diff |
| **Language** | TypeScript |
| **API** | `@companion-module/base` 1.14.1 (v1.x) |
| **Template** | `companion-module-template-ts-v1` |
| **Maintainer** | George Patchett &lt;hello@webcomms.net&gt; |
| **Build** | ✅ pass |
| **Lint** | ✅ pass |
| **Reviewed** | 2026-08-03 |

**Release context:** v2.0.0 is a full architectural rewrite. The Supabase backend (`src/supabase.ts`, 431 lines) was deleted and replaced with a **socket.io + node `http` server** that listens on a hardcoded TCP port inside `src/main.ts`. The data direction is reversed — the web panel now connects *to* Companion rather than Companion polling a cloud backend. Because the whole module body is new in this diff, every code finding below is classified NEW or REGRESSION.

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C5: UpgradeScripts is empty although every action ID and the whole config schema changed](#c5-upgradescripts-is-empty-although-every-action-id-and-the-whole-config-schema-changed)
- [ ] [C6: package.json repository.url is still the template placeholder](#c6-packagejson-repositoryurl-is-still-the-template-placeholder)
- [ ] [C7: .husky/pre-commit was deleted but husky and lint-staged are still configured](#c7-huskypre-commit-was-deleted-but-husky-and-lint-staged-are-still-configured)
- [ ] [C8: tsconfig.build.json deviates from the template](#c8-tsconfigbuildjson-deviates-from-the-template)
- [ ] [C9: tsconfig.json adds ignoreDeprecations to accommodate a TypeScript 6 bump](#c9-tsconfigjson-adds-ignoredeprecations-to-accommodate-a-typescript-6-bump)
- [ ] [C11: .gitignore is missing the template /.vscode entry](#c11-gitignore-is-missing-the-template-vscode-entry)
- [ ] [H1: The Port config field is never read — the port is hardcoded to 7171](#h1-the-port-config-field-is-never-read--the-port-is-hardcoded-to-7171)
- [ ] [H2: Connected sockets are never removed on disconnect](#h2-connected-sockets-are-never-removed-on-disconnect)
- [ ] [H3: Unauthenticated listener on all interfaces with cors origin wildcard](#h3-unauthenticated-listener-on-all-interfaces-with-cors-origin-wildcard)
- [ ] [H4: updateFeedbacks is never called during init](#h4-updatefeedbacks-is-never-called-during-init)
- [ ] [H5: All module variables were removed, leaving a no-op stub](#h5-all-module-variables-were-removed-leaving-a-no-op-stub)
- [ ] [H6: HELP.md documents the deleted v1 architecture and is labelled alpha](#h6-helpmd-documents-the-deleted-v1-architecture-and-is-labelled-alpha)
- [ ] [H7: eslint 10x violated the Companion Module Tools Peer Range](#h7-eslint-10x-violates-the-companion-moduletools-peer-range)

**Non-blocking**

- [ ] [M1: InstanceStatus.Ok means "port bound", not "panel connected"](#m1-instancestatusok-means-port-bound-not-panel-connected)
- [ ] [M2: The sync request has no retry or timeout](#m2-the-sync-request-has-no-retry-or-timeout)
- [ ] [M3: channelResponse can produce an unbounded syncRequest loop](#m3-channelresponse-can-produce-an-unbounded-syncrequest-loop)
- [ ] [M4: Multi-client state is last-writer-wins and every action broadcasts to all panels](#m4-multi-client-state-is-last-writer-wins-and-every-action-broadcasts-to-all-panels)
- [ ] [M5: Toggle actions race on rapid presses](#m5-toggle-actions-race-on-rapid-presses)
- [ ] [M6: Raw console calls on the network and feedback hot paths](#m6-raw-console-calls-on-the-network-and-feedback-hot-paths)
- [ ] [M7: Every action press logs the full action object at info level](#m7-every-action-press-logs-the-full-action-object-at-info-level)
- [ ] [L1: Dead Supabase-era types left in types.d.ts](#l1-dead-supabase-era-types-left-in-typesdts)
- [ ] [L2: companionSyncTimeout field is orphaned](#l2-companionsynctimeout-field-is-orphaned)
- [ ] [L3: A channel rename never refreshes dropdown labels](#l3-a-channel-rename-never-refreshes-dropdown-labels)
- [ ] [L4: getChannelChoices is recomputed twice per option](#l4-getchannelchoices-is-recomputed-twice-per-option)
- [ ] [L5: Actions silently no-op before the first sync](#l5-actions-silently-no-op-before-the-first-sync)
- [ ] [L6: Three action callbacks are async with nothing awaited](#l6-three-action-callbacks-are-async-with-nothing-awaited)
- [ ] [L7: listenStatus feedback and toggleChannelOutput disagree on what "listening" means](#l7-listenstatus-feedback-and-togglechanneloutput-disagree-on-what-listening-means)
- [ ] [L8: Imports use the ./types.d.js specifier](#l8-imports-use-the-typesdjs-specifier)
- [ ] [L9: postinstall husky fails on a production install](#l9-postinstall-husky-fails-on-a-production-install)
- [ ] [L10: @types/node 26 describes a newer runtime than engines.node allows](#l10-typesnode-26-describes-a-newer-runtime-than-enginesnode-allows)
- [ ] [L11: @companion-module/base is pinned to an exact version](#l11-companion-modulebase-is-pinned-to-an-exact-version)
- [ ] [N1: No presets are defined](#n1-no-presets-are-defined)
- [ ] [N2: Dropdowns default to an empty string before a panel connects](#n2-dropdowns-default-to-an-empty-string-before-a-panel-connects)
- [ ] [N3: No cap on inbound connections or message size](#n3-no-cap-on-inbound-connections-or-message-size)

---

## 🔴 Critical

### C5: UpgradeScripts is empty although every action ID and the whole config schema changed

**File:** `src/upgrades.ts:4` · **Classification:** 🔙 REGRESSION

This is the headline upgrade problem for a v1 → v2 major. `UpgradeScripts` is still the untouched template array (only the commented-out example remains), yet the rewrite renamed every action and replaced the config schema outright:

| v1.0.12 | v2.0.0 |
|---|---|
| `toggleTalk` | `toggleChannelInput` (+ new `muteChannelInput` / `unmuteChannelInput`) |
| `toggleListen` | `toggleChannelOutput` (+ `muteChannelOutput` / `unmuteChannelOutput`) |
| `setVolume` | `setChannelVolume` |
| config `companionIdentity`, `intercomName` (textinput) | config `port` (number) |

Consequences on upgrade, all silent:

- **Actions** — no v1 ID survives, so every existing button becomes an unknown action.
- **Feedbacks** — the IDs `talkStatus` / `listenStatus` / `channelActivity` were kept, but their `channel` option now holds an ID sourced from the socket sync rather than the Supabase `templateChannel.channelId`. The stored value no longer resolves and the callbacks just `return false` (`src/feedbacks.ts:34, 68, 132`) — the feedback appears defined but never fires.
- **Config** — `this.config` comes up with `port === undefined` (there is no migration and the field is not read anyway, see H1). Even after H1 is fixed, `listen(undefined)` binds a **random ephemeral port**, so a code-level default is mandatory alongside the upgrade script.

**Fix:** add a real upgrade script that (a) maps the old action IDs to the new ones while preserving the `channel` option, and (b) returns an `updatedConfig` seeding `port: 7171` and dropping `companionIdentity` / `intercomName`. Confirm whether the v2 channel IDs are the same values previously stored in the `channel` option — if they are not, the option values need remapping too, or the migrated actions and feedbacks will still resolve to `undefined`. Where a mapping genuinely isn't possible, log a warning on init when a legacy config key is still present and state the breaking change prominently in HELP.md (H6).

### C6: package.json repository.url is still the template placeholder

**File:** `package.json` · **Classification:** 🆕 NEW · **Check:** `PKG-REPO`

```json
"url": "git+https://github.com/bitfocus/companion-module-your-module-name.git"
```

**Fix:** `git+https://github.com/bitfocus/companion-module-webcomms-panel.git` — `companion/manifest.json` already has the correct URL, so only `package.json` is out of sync.

### C7: .husky/pre-commit was deleted but husky and lint-staged are still configured

**File:** `.husky/pre-commit` · **Classification:** 🆕 NEW · **Check:** `FILE-MISSING`

This release deletes `.husky/pre-commit` (the diff shows `-1` line) while `package.json` keeps `"postinstall": "husky"`, `husky` in `devDependencies`, and a full `lint-staged` block. The result is a hook directory with no hook: `lint-staged` is configured but can never run, and formatting/lint no longer gate commits. Note also that the newly added `enableScripts: false` in `.yarnrc.yml` (C10) suppresses lifecycle scripts, so `husky` would not install the hook even if the file were restored.

**Fix:** restore `.husky/pre-commit` from the template (`yarn lint-staged`), or — if dropping the hook is deliberate — also remove `husky`, the `postinstall` script, and the `lint-staged` config so the repo doesn't advertise tooling that does nothing.

### C8: tsconfig.build.json deviates from the template

**File:** `tsconfig.build.json` · **Classification:** 🆕 NEW · **Check:** `CONFIG-DIFF`

```
found:    "extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json"
template: "extends": "@companion-module/tools/tsconfig/node22/recommended"
```

The file also drops the template's `baseUrl`, `paths`, `module: "Node16"` and `moduleResolution: "Node16"`, and adds `rootDir`, `verbatimModuleSyntax` and `ignoreDeprecations: "6.0"`.

**Fix:** align with the current template's `tsconfig.build.json`, or if the ESM preset is required for this module, raise it with Bitfocus so the deviation is on record before release.

### C9: tsconfig.json adds ignoreDeprecations to accommodate a TypeScript 6 bump

**File:** `tsconfig.json` · **Classification:** 🆕 NEW · **Check:** `CONFIG-DIFF`

The only substantive difference from the template is the added `"ignoreDeprecations": "6.0"`, which is a consequence of pinning `typescript` to `6.0.3` while the template is on `~5.9.3`. Suppressing deprecation errors to run a toolchain two majors ahead of the template is a compatibility risk for a module that must build inside Bitfocus's CI.

**Fix:** move back to the template's TypeScript version and drop `ignoreDeprecations` from both tsconfigs. This resolves alongside M11, L10 and C8 — the whole devDependency block has drifted ahead of the template.

### C11: .gitignore is missing the template /.vscode entry

**File:** `.gitignore` · **Classification:** 🆕 NEW · **Check:** `CONFIG-DIFF`

**Fix:** add `/.vscode`.

---

## 🟠 High

### H1: The Port config field is never read — the port is hardcoded to 7171

**File:** `src/main.ts:66`, `src/config.ts:7-18` · **Classification:** 🆕 NEW

`GetConfigFields()` exposes a `port` number field defaulting to 7171, `ModuleConfig.port` is typed, and `this.config` is assigned at `src/main.ts:30` — but `this.config` is then **never read anywhere in `src/`**. `listen(7171, ...)` is a literal. The operator changes the port, saves, and the server still listens on 7171 (or, per C3, the save throws outright). A UI setting that silently does nothing is worse than no setting, and it removes the only workaround for the port conflict in C2.

**Fix:**

```ts
const port = Number(this.config.port) || 7171
if (!Number.isInteger(port) || port < 1024 || port > 65535) {
	this.updateStatus(InstanceStatus.BadConfig, 'Invalid port')
	return
}
this.server.listen(port, () => { ... })
```

The `|| 7171` fallback is required, not optional — without the upgrade script from C5, upgraded instances arrive with `config.port === undefined`, and `listen(undefined)` binds a random ephemeral port that no panel can find.

### H2: Connected sockets are never removed on disconnect

**File:** `src/main.ts:23, 38` · **Classification:** 🆕 NEW

`this.sockets.push(socket)` has no matching removal, and there is no `socket.on('disconnect')` handler anywhere in `src/`. The client is a browser panel, so every page refresh, network blip or socket.io auto-reconnect permanently adds a dead `Socket` (with its buffers) to the array. `emitChannelAction` / `emitPanelAction` (`src/actions.ts:318-328`) then iterate a growing list of dead sockets on every button press, and `emit()` on a disconnected socket is a silent no-op — so the failure is invisible. Over a long show this accumulates to hundreds of entries.

**Fix:** the cleanest option is to delete `this.sockets` entirely and let socket.io do the bookkeeping — `this.io.emit('channelEvent', ...)` broadcasts to exactly the live set. If the array is kept:

```ts
socket.on('disconnect', (reason) => {
	this.sockets = this.sockets.filter((s) => s.id !== socket.id)
	this.log('info', `Client disconnected: ${reason}`)
	if (this.sockets.length === 0) {
		this.state = undefined
		this.updateStatus(InstanceStatus.Disconnected, 'No panel connected')
	}
})
```

### H3: Unauthenticated listener on all interfaces with cors origin wildcard

**File:** `src/main.ts:17-22, 66` · **Classification:** 🆕 NEW

`listen(7171)` with no host argument binds `0.0.0.0` — every interface, including public/venue Wi-Fi. There is no shared secret or handshake check on connect, and `cors: { origin: '*' }` is fully open. Consequences:

- Any host on the network can connect and is immediately sent `syncRequest`.
- Any host can push a forged `syncResponse` — whose type includes `password: string | null` (`src/types.d.ts:19`) — overwriting Companion's view of the intercom, or crash the module outright (C1).
- Any host receives every `channelEvent` / `panelEvent` the operator triggers, i.e. full visibility and control of mute/talk/volume.
- `origin: '*'` additionally lets *any* web page loaded in a browser on the operator's machine open a socket to `localhost:7171`.

The v1 design authenticated via a Companion Identity checked against the backend; that check was deleted here with nothing replacing it.

**Fix:** bind to loopback by default (`this.server.listen(port, this.config.bindAddress ?? '127.0.0.1')`) with an explicit opt-in config field for a wider bind; restrict `cors.origin` to the panel's actual origin(s) via a config field rather than `'*'`; and require a token in the handshake:

```ts
this.io.use((socket, next) => {
	if (socket.handshake.auth?.token === this.config.token) next()
	else next(new Error('unauthorized'))
})
```

Document the port, the firewall implication and the security model in HELP.md (H6).

### H4: updateFeedbacks is never called during init

**File:** `src/main.ts:34` · **Classification:** 🆕 NEW

`init()` calls only `this.updateActions()`. `setFeedbackDefinitions` is first reached inside the `syncResponse` handler at `src/main.ts:45`, so until a panel connects **and** completes a sync, the connection publishes **zero feedback definitions**. Users cannot build or edit feedback-driven buttons ahead of a show.

**Fix:** call `this.updateFeedbacks()` alongside `this.updateActions()` in `init()`.

### H5: All module variables were removed, leaving a no-op stub

**File:** `src/variables.ts:3-5` · **Classification:** 🔙 REGRESSION

```ts
export function UpdateVariableDefinitions(_: ModuleInstance): void {
	//self.setVariableDefinitions(self.generateVariableDefinitions())
}
```

The body is commented out, the function is no longer imported by `main.ts`, and no `setVariableDefinitions` or `setVariableValues` call exists anywhere in `src/`. v1.0.12 published per-channel `<Channel_Name>_volume` variables and updated them on every `volumeChange`. After this upgrade, any user button text or trigger referencing `$(webcomms-panel:..._volume)` renders as `$NA`, with nothing in the log explaining it.

**Fix:** re-implement the variables from `SyncResponse.channels` (id / name / volume / isTalking), defining them with `setVariableDefinitions` on sync *before* pushing values with `setVariableValues`, and keep the old `<Channel_Name>_volume` IDs so existing button text keeps working. If the removal is intentional, delete `src/variables.ts` and call the removal out explicitly in HELP.md.

### H6: HELP.md documents the deleted v1 architecture and is labelled alpha

**File:** `companion/HELP.md` · **Classification:** 🔙 REGRESSION

The only change in this release is the heading, now `## WebComms Panel - v2.0.0-alpha`. The body still instructs the operator to enter a "Companion Identity" and a "room name" — config fields deleted in this diff — still lists three actions under names that no longer exist, and still advertises an "Available variables — Volume of a channel" section for variables that were removed (H5). Nothing documents the listening port, the firewall requirement, the reversal of connection direction (the panel now connects *to* Companion), or the breaking upgrade.

Shipping a tagged release whose help file says `-alpha` is also a poor signal for a module going through release approval.

**Fix:** rewrite HELP.md for the v2 architecture — what the port does, how the webcomms.net panel is pointed at Companion, the full `Channel:` / `Panel:` action list, the four feedbacks, and a prominent breaking-change notice for v1 users — and drop the `-alpha` suffix.

### H7: eslint 10.x violates the @companion-module/tools peer range

**File:** `package.json` · **Classification:** 🆕 NEW

`yarn install` reports:

```
YN0060: eslint is listed by your project with version 10.6.0, which doesn't satisfy
        what @companion-module/tools and other dependencies request (^9.36.0).
```

Lint currently passes, but the module is running its lint toolchain outside the range the Bitfocus tooling declares support for. The same drift applies to `typescript` 6.0.3 vs the template's `~5.9.3` (C9), `@types/node` `^26` vs `^22.19.3` (L10) and `lint-staged` `^17` vs `^16.2.7`.

**Fix:** bring the devDependency block back in line with the current template so the peer range is satisfied.

---

## 🟡 Medium

### M1: InstanceStatus.Ok means "port bound", not "panel connected"

**File:** `src/main.ts:32, 68` · **Classification:** 🆕 NEW

Status goes `Connecting` in `init()` → `Ok` as soon as the socket is listening, with zero clients connected and `this.state === undefined`. It is never downgraded when the panel disconnects (there is no disconnect handler, H2) and never set on any error path. Operators see a green connection while every action is a silent no-op — all callbacks return early on `!self.state`. v1.0.12 did set `BadConfig` on validation failures (`Companion ID not found`, `Intercom config not found`); that feedback is gone.

**Fix:** stay `Connecting` while listening with no synced client; `Ok` only after the first valid `syncResponse`; `Disconnected` when `sockets.length === 0` or in `destroy()`; `ConnectionFailure` / `UnknownError` from the `server.on('error')` handler (C2); `BadConfig` for an invalid port (H1).

### M2: The sync request has no retry or timeout

**File:** `src/main.ts:15, 63` · **Classification:** 🔙 REGRESSION

v1.0.12 retried `requestCompanionSync()` every 2 s until state arrived. v2 emits `syncRequest` exactly once on connect. If that response is dropped, the module sits with `state === undefined` forever while reporting `Ok`, and every action and feedback silently no-ops. The `companionSyncTimeout` field that backed the old retry is still declared (`src/main.ts:15`) but is now dead — nothing assigns or clears it (L2).

**Fix:** re-add a bounded retry — re-emit `syncRequest` every 2 s up to *N* attempts — clear it on `syncResponse` and in `destroy()`, and hold a non-`Ok` status while unsynced.

### M3: channelResponse can produce an unbounded syncRequest loop

**File:** `src/main.ts:50-52` · **Classification:** 🆕 NEW

Every `channelResponse` received while `this.state` is undefined emits another `syncRequest`. `channelResponse` carries `activity` (VOX) updates, which arrive at speech rate — a client that streams activity but never answers a sync generates an unbounded request loop.

**Fix:** allow only one outstanding sync request with a minimum re-request interval (this pairs naturally with the retry in M2), and count repeated failures toward a status change.

### M4: Multi-client state is last-writer-wins and every action broadcasts to all panels

**File:** `src/main.ts:38, 43`, `src/actions.ts:318-328` · **Classification:** 🆕 NEW

There is one `this.state` but *N* accepted clients. Two panels connected to the same Companion overwrite each other's state on every `syncResponse`, and feedbacks reflect whichever panel synced most recently. `emitChannelAction` / `emitPanelAction` loop over all sockets with no addressing, so pressing "Channel: Activate Talk" acts on **every** connected panel.

**Fix:** either enforce a single active panel (reject or replace the connection on a second connect, or track a primary socket id) or key state per socket and add a target-panel option to the actions. If single-panel is the intended design, enforce it in code and say so in HELP.md.

### M5: Toggle actions race on rapid presses

**File:** `src/actions.ts:96-98, 188-190` · **Classification:** 🆕 NEW

`toggleChannelInput` reads `channel.isTalking` from local state, which only changes when the remote sends a `channelResponse`. Two presses inside the round-trip window both read the stale value and send the *same* command (e.g. `muteInput` twice), so the second press is lost. `togglePanelInput` / `togglePanelOutput` have the same issue on `state.panel`.

**Fix:** apply the optimistic local flip immediately after emitting (`channel.isTalking = !talking`) so a second press computes from the intended state; the authoritative `channelResponse` will correct it.

### M6: Raw console calls on the network and feedback hot paths

**File:** `src/main.ts:39, 42`, `src/actions.ts:315`, `src/feedbacks.ts:26` · **Classification:** 🆕 NEW

`console.log(socket.connected)` (leftover debug), `console.debug('Sync Response Received', syncData)` — which dumps the full sync payload, **including the `password` field** (`src/types.d.ts:19`), on every sync — `console.log('actions updated')`, and `console.warn('feedback', feedback)`, which fires on **every** `talkStatus` evaluation and dumps the whole feedback object. These bypass Companion's log-level filtering and the instance label, going straight to the Companion process stdout.

**Fix:** delete the debug leftovers; route anything worth keeping through `this.log('debug', ...)`. Never log the `password` field.

### M7: Every action press logs the full action object at info level

**File:** `src/actions.ts:38, 68, 100, 130, 160, 192, 232` · **Classification:** 🆕 NEW

`self.log('info', JSON.stringify(action))` on seven actions logs the complete action object at `info` on each button press.

**Fix:** remove these, or demote to `'debug'`.

---

## 🟢 Low

### L1: Dead Supabase-era types left in types.d.ts

**File:** `src/types.d.ts:41-59` · **Classification:** 🆕 NEW

`SupabaseEnvVars`, `ChannelChoice`, `PGMChoice` and `RoleChoice` are exported but referenced nowhere in `src/`. `SupabaseEnvVars` in particular names a backend that no longer exists.

**Fix:** delete them.

### L2: companionSyncTimeout field is orphaned

**File:** `src/main.ts:15` · **Classification:** 🆕 NEW

The Supabase sync-retry timer this field belonged to was deleted; nothing assigns or clears it.

**Fix:** remove it, or re-use it when reinstating the sync retry (M2) — in which case `clearTimeout()` it in `destroy()`.

### L3: A channel rename never refreshes dropdown labels

**File:** `src/main.ts:54-60` · **Classification:** 🆕 NEW

`channelResponse` splices the updated channel into state but never calls `updateActions()` / `updateFeedbacks()`, so a renamed channel keeps its old label in every dropdown until a full `syncResponse` arrives.

**Fix:** republish definitions when `channelData.name` differs from the stored name.

### L4: getChannelChoices is recomputed twice per option

**File:** `src/actions.ts:21, 51, 81, …` · **Classification:** 🆕 NEW

`getChannelChoices(self.state)` is called once for `choices` and again for `default` on each option — roughly 14 map-and-sort passes per definition rebuild.

**Fix:** hoist to a single `const choices = getChannelChoices(self.state)` at the top of `UpdateActions`.

### L5: Actions silently no-op before the first sync

**File:** `src/actions.ts:24-39` and the other callbacks · **Classification:** 🆕 NEW

Every callback returns silently when `!self.state` or the channel isn't found. An operator pressing a button before sync gets no indication of why nothing happened.

**Fix:** `self.log('warn', 'Not synced with a panel — action ignored')`.

### L6: Three action callbacks are async with nothing awaited

**File:** `src/actions.ts:279, 292, 305` · **Classification:** 🆕 NEW

`callback: async () => {…}` with no `await` inside, while the other ten actions use synchronous callbacks.

**Fix:** make them synchronous for consistency.

### L7: listenStatus feedback and toggleChannelOutput disagree on what "listening" means

**File:** `src/feedbacks.ts:71` vs `src/actions.ts:188` · **Classification:** 🆕 NEW

`listenStatus` treats `volume === 0` as not-listening, but `toggleChannelOutput` only toggles `outputMuted`. A channel sitting at volume 0 therefore shows "not listening" and the toggle appears to do nothing.

**Fix:** align the two — either ignore volume in the feedback, or have the toggle restore volume as well as unmute.

### L8: Imports use the ./types.d.js specifier

**File:** `src/main.ts:3`, `src/actions.ts:2` · **Classification:** 🆕 NEW

`import type { ... } from './types.d.js'` compiles, but the convention is a plain `src/types.ts` imported as `'./types.js'`. The `.d.js` specifier is easy to misread and prevents ever adding runtime values to that module.

**Fix:** rename to `src/types.ts` and import from `'./types.js'`.

### L9: postinstall husky fails on a production install

**File:** `package.json:7` · **Classification:** 🆕 NEW

`"postinstall": "husky"` with `husky` in `devDependencies` fails on any `--omit=dev` / production install.

**Fix:** move it to `prepare`, or guard it (`husky || true`). See also C7 and C10 — the hook, the script and `enableScripts: false` currently contradict each other.

### L10: @types/node 26 describes a newer runtime than engines.node allows

**File:** `package.json` · **Classification:** 🆕 NEW

`"@types/node": "^26.1.1"` against `"engines": { "node": "^22.20" }`. The type definitions describe a runtime two majors ahead of the one the module actually runs on, so TypeScript will accept APIs that don't exist at runtime in Node 22.

**Fix:** pin to `^22.x` to match `engines.node` and the template.

### L11: @companion-module/base is pinned to an exact version

**File:** `package.json` · **Classification:** 🆕 NEW

`"@companion-module/base": "1.14.1"` (exact), where the template uses `~1.14.1`. `@companion-module/tools`, `typescript` and `typescript-eslint` are pinned exactly too.

**Fix:** use `^1.14.1` for `base` — the Bitfocus convention — so the module picks up SDK patch fixes.

---

## 💡 Nice to Have

### N1: No presets are defined

**Classification:** 🆕 NEW

There is no `src/presets.ts` and no `setPresetDefinitions` call. With 13 actions and 4 feedbacks, a small preset set — per-channel talk and output toggles with the matching feedback already wired — would make the module considerably easier to adopt.

### N2: Dropdowns default to an empty string before a panel connects

**File:** `src/actions.ts:21`, `src/feedbacks.ts:22` · **Classification:** 🆕 NEW

Before the first sync the choice list is empty and the default is an invalid `''`.

**Fix:** add a placeholder choice such as `{ id: '', label: 'Connect a panel to populate channels' }` so the UI reads sensibly pre-connection.

### N3: No cap on inbound connections or message size

**File:** `src/main.ts:18-22, 36` · **Classification:** 🆕 NEW

`io.on('connect')` accepts connections without limit.

**Fix:** consider tuning `io.engine.maxHttpBufferSize` and rejecting connections beyond an expected client count, to bound resource use from a hostile or looping client.
