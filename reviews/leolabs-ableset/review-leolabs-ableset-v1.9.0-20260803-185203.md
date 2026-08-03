# Module Review: leolabs-ableset v1.9.0

| | |
|---|---|
| **Module** | companion-module-leolabs-ableset |
| **Version** | v1.9.0 |
| **Scope** | `tag` (diff `v1.7.3..v1.9.0`) |
| **API** | @companion-module/base 2.0.4 (**v2.x** — migrated from ~1.12.1 this release) |
| **Language** | TypeScript |
| **Protocols** | OSC (UDP) |
| **Build / Lint** | ✅ Pass / ✅ Pass |
| **Review Date** | 2026-08-03 |

> **Context.** The last *approved* tag is **v1.7.3**, so this `tag` diff spans v1.8.0, v1.8.1, v1.8.2 and v1.9.0. Prior reviews of v1.8.0 and v1.8.1 were delivered.
>
> **Previously-flagged items now resolved** — nice work: the missing `UpgradeScript` for `setAutoLoopCurrentSection` now exists (`src/upgrades.ts`, though see H2/H3), the `autoLoopCurrentSection` removal is documented in `HELP.md`, `countInDuration` / `jumpMode` were removed from `BOOLEAN_SETTINGS`, and both `tsconfig.json` and `tsconfig.build.json` were realigned to the template.
>
> **The v1→v2 API migration itself is well executed.** Class-based default export, `runEntrypoint` removed, all `parseVariablesInString` calls removed with `useVariables: true` retained on the four affected fields, `setVariableDefinitions` object form, the two-arg `setPresetDefinitions(structure, presets)` with `type: 'simple'`, and manifest `type: "connection"` + `runtime.type: "node22"` are all correct. The 330-preset graph was machine-checked: no duplicate IDs, no orphaned structure entries, no unknown action/feedback IDs, and every `$(AbleSet:…)` reference resolves.
>
> **What blocks this release is the `node-osc` v9 → v11 upgrade** (commit `cd6b84e`), which changes `Client.send()` from swallow-all to promise-rejecting. The call sites were changed to `void` those promises, which converts previously-silent UDP failures into process-terminating unhandled rejections. Both crash paths were reproduced against the module's own `node_modules` (see C1).

---

## Verdict: ❌ Changes Required

---

## 📋 Issues

**Blocking**

- [ ] [C1: void client.client.send() discards a rejecting promise and terminates the module process](#c1-void-clientclientsend-discards-a-rejecting-promise-and-terminates-the-module-process)
- [ ] [C2: No error listener on the node-osc v11 Client EventEmitter](#c2-no-error-listener-on-the-node-osc-v11-client-eventemitter)
- [ ] [H2: upgradeRemoveAutoLoopCurrentSection blanks actionId, which is not a supported deletion](#h2-upgraderemoveautoloopcurrentsection-blanks-actionid-which-is-not-a-supported-deletion)
- [ ] [H3: Upgrade scripts do not migrate saved option values holding autoLoopCurrentSection](#h3-upgrade-scripts-do-not-migrate-saved-option-values-holding-autoloopcurrentsection)
- [ ] [H4: PlayAUDIO12 OSC addresses dropped, contradicting the AbleSet 2 compatibility claim in HELP.md](#h4-playaudio12-osc-addresses-dropped-contradicting-the-ableset-2-compatibility-claim-in-helpmd)

**Non-blocking**

- [ ] [M2: close() is not idempotent and destroy() has no error handling](#m2-close-is-not-idempotent-and-destroy-has-no-error-handling)
- [ ] [M4: extends InstanceBase without the InstanceTypes generic](#m4-extends-instancebase-without-the-instancetypes-generic)
- [ ] [M5: Inconsistent audioInterfaces address shapes need verification against the AbleSet 3 OSC API](#m5-inconsistent-audiointerfaces-address-shapes-need-verification-against-the-ableset-3-osc-api)
- [ ] [L1: remainingSetTime preset is named Remaining Time in Song](#l1-remainingsettime-preset-is-named-remaining-time-in-song)
- [ ] [L2: formatDuration mishandles Infinity and the HH:mm:ss description is inaccurate](#l2-formatduration-mishandles-infinity-and-the-hhmmss-description-is-inaccurate)
- [ ] [L3: Debounced and throttled handlers are not cancelled on teardown](#l3-debounced-and-throttled-handlers-are-not-cancelled-on-teardown)
- [ ] [L4: required removed from the by-name text inputs with no minLength replacement](#l4-required-removed-from-the-by-name-text-inputs-with-no-minlength-replacement)
- [ ] [L5: Remaining-time variables are written at full OSC rate](#l5-remaining-time-variables-are-written-at-full-osc-rate)
- [ ] [N1: allowNegative parameter is dead code](#n1-allownegative-parameter-is-dead-code)
- [ ] [N2: makeOrdinal produces 21th for indices at or above 20](#n2-makeordinal-produces-21th-for-indices-at-or-above-20)
- [ ] [N3: getPort() probes a TCP port to pick a UDP port](#n3-getport-probes-a-tcp-port-to-pick-a-udp-port)
- [ ] [N4: settingEqualsValue choices duplicate BOOLEAN_SETTINGS with drifting labels](#n4-settingequalsvalue-choices-duplicate-boolean_settings-with-drifting-labels)
- [ ] [N5: enableScripts false disables the husky postinstall and the canvas build](#n5-enablescripts-false-disables-the-husky-postinstall-and-the-canvas-build)
- [ ] [N6: Feedback.IsSyncingPlayback has no definition](#n6-feedbackissyncingplayback-has-no-definition)

---

## 🔴 Critical

### C1: void client.client.send() discards a rejecting promise and terminates the module process

**Classification:** 🔙 REGRESSION
**File:** `src/main.ts:147`, `src/main.ts:148`, `src/main.ts:167`, `src/main.ts:216`

This release upgrades `node-osc` 9.1.7 → 11.6.0 (`cd6b84e`) **and** writes the call sites as `void client.client.send(...)`. Those two changes are individually reasonable and jointly fatal.

In node-osc 9, `send()` without a callback substituted a no-op — verified in `node-osc@9.1.7/lib/Client.mjs:26`:

```js
callback = () => {};
```

In node-osc 11, `send()` without a callback **returns a promise that rejects** — verified in the module's own `node_modules/node-osc/lib/Client.mjs:128-139`:

```js
else {
  // No callback provided, return a Promise
  return new Promise((resolve, reject) => {
    callback = (err) => { if (err) reject(err); else resolve(); };
    performSend(this._sock, message, args, this.port, this.host, callback);
  });
}
```

`void` discards the handle, so every send failure is now an unhandled rejection. Node 22 defaults to `--unhandled-rejections=throw`, and `@companion-module/base@2.0.4` registers no `unhandledRejection` handler, so the connection process is terminated.

**Both crash paths were reproduced** against the module's installed `node-osc@11.6.0` on Node v22.21.1:

*Repro A — unresolvable host (mirrors `tryConnecting()` at `:147`).* The `serverHost` config field explicitly accepts hostnames, so a typo is enough:

```js
const c = new Client('this-host-does-not-exist.invalid', 39051)
void c.send(['/subscribe', 'auto', 1234, 'Companion', false])
```

→ `Error: getaddrinfo ENOTFOUND …`, **process exits 1**. The same script against node-osc 9.1.7 stays alive. Because `tryConnecting()` is re-armed by `setInterval(…, 2000)` (`:152-157`), Companion restarts the connection and it dies again — a permanent crash loop from one typo in the config.

*Repro B — send after the socket closed (mirrors `sendOsc()` at `:216`).*

```js
const c = new Client('127.0.0.1', 39051)
await c.close()
void c.send(['/global/play', 'uuid=abc'])
```

→ `ReferenceError: Cannot send message on closed socket.` (`ERR_SOCKET_DGRAM_NOT_RUNNING`), **process exits 1**. See H1 for how the module reaches this state in normal use.

Secondary consequence: the `try/catch` at `:145-150` is now dead for send failures. An async rejection can never be caught by it, so the `Couldn't send subscribe command to …` log line is unreachable and `InstanceStatus` is never updated on send failure — the operator gets a bare stack trace instead of a diagnostic.

**Fix Required:** never `void` a node-osc promise. Add one helper and use it at all four sites:

```ts
private trySend(client: Client, message: unknown[]): void {
  client.send(message as never).catch((e: unknown) => {
    this.log('error', `OSC send to ${client.host} failed: ${getErrorMessage(e)}`)
    this.updateStatus(InstanceStatus.ConnectionFailure, getErrorMessage(e))
  })
}
```

The callback form (`client.send(msg, (err) => …)`) is equally fine — it takes the non-promise branch. Whichever you pick, the `.catch()` should carry the log message that `:149` was meant to emit.

---

### C2: No error listener on the node-osc v11 Client EventEmitter

**Classification:** 🆕 NEW
**File:** `src/main.ts:105`

In node-osc 11, `Client extends EventEmitter` and re-emits socket errors — `node_modules/node-osc/lib/Client.mjs:45-47`:

```js
this._sock.on('error', (err) => {
  this.emit('error', err);
});
```

An `EventEmitter` that emits `'error'` with no registered listener **throws**. The module attaches a handler to `client.server` (`:121`) but never to `client.client`, so any client socket error crashes the module.

This requirement is new to v11 — in v9 `Client` was not an `EventEmitter` at all, so there was nothing to listen to. It is easy to miss when reading the upgrade diff.

**Fix Required:** attach a listener immediately after constructing the client at `:105`:

```ts
const client = new Client(host.trim(), 39051)
client.on('error', (e) => this.log('error', `OSC client for ${host.trim()} errored: ${getErrorMessage(e)}`))
```

---

## 🟠 High

### H2: upgradeRemoveAutoLoopCurrentSection blanks actionId, which is not a supported deletion

**Classification:** 🆕 NEW
**File:** `src/upgrades.ts:9-21`

The script's doc comment states the goal is *"so that buttons referencing them don't end up with orphaned, non-loading actions"*, and implements it by blanking the ID:

```ts
const updatedActions = props.actions.filter((action) => action.actionId === 'setAutoLoopCurrentSection')
for (const action of updatedActions) {
  action.actionId = ''
}
```

`CompanionStaticUpgradeResult` in `@companion-module/base@2.0.4` (`dist/module-api/upgrade.d.ts:36-53`) exposes only `updatedConfig`, `updatedSecrets`, `updatedActions` and `updatedFeedbacks` — there is **no removal channel**, and an empty string is not a documented deletion signal in the base types or the Bitfocus upgrade-scripts wiki. Running the exported `UpgradeScripts` against sample saved data confirms the output is literally `actionId: ""`.

Net effect: the orphaned action stays on the button *and* now has no identifiable ID, so the user can no longer tell what it was, it is harder to find and delete than before the upgrade, and a future corrective upgrade script has nothing left to match on. That is strictly worse than doing nothing.

**Fix Required:** since `setAutoLoopCurrentSection` has no AbleSet 3 replacement, leave `actionId` untouched — Companion renders it as a recognisable unknown action the user can delete, and the ID stays available for a future migration. Alternatively remap it to a real, harmless action. If Companion 4.3 genuinely does treat a blank ID as a deletion, please cite that in a code comment; as written it reads as an unsupported hack.

---

### H3: Upgrade scripts do not migrate saved option values holding autoLoopCurrentSection

**Classification:** 🆕 NEW
**File:** `src/upgrades.ts`, `src/constants.ts:6-19`, `src/main.ts:951-961`, `src/main.ts:1690-1720`

`autoLoopCurrentSection` was removed from `BOOLEAN_SETTINGS` and from the `settingEqualsValue` dropdown, but it survives inside saved **option values** on two widely-used generic entries:

- the `toggleSetting` action, option `setting`
- the `settingEqualsValue` feedback, option `setting`

The `booleanSettingsPresets` generator (`src/presets.ts:733-755`) means many users have exactly these buttons. Running both upgrade scripts against saved `toggleSetting {setting: 'autoLoopCurrentSection'}` and `settingEqualsValue {setting: 'autoLoopCurrentSection'}` entries returns them untouched.

Result: the dropdown holds a value absent from `choices` so the field renders as invalid in the button editor, the feedback silently evaluates to `false` forever, and pressing the button emits `/settings/autoLoopCurrentSection` to a server that no longer implements it — a dead button with no diagnostic.

**Fix Required:** extend `upgradeRemoveAutoLoopCurrentSection` (or append a third script — never reorder the existing two) to scan `props.actions` for `actionId === 'toggleSetting'` and `props.feedbacks` for `feedbackId === 'settingEqualsValue'` and retarget or clearly mark the stale value. **Note the v2 option shape:** migration option values are `ExpressionOrValue` wrappers (`upgrade.d.ts:58-60`), so test `action.options.setting?.value === 'autoLoopCurrentSection'`, not the raw value. Add each touched entry to `updatedActions` / `updatedFeedbacks`.

---

### H4: PlayAUDIO12 OSC addresses dropped, contradicting the AbleSet 2 compatibility claim in HELP.md

**Classification:** 🆕 NEW
**File:** `src/main.ts:518`, `src/main.ts:522`, `src/main.ts:933`, `src/main.ts:938`; `companion/HELP.md:3-4`, `:20-23`

The rename replaced the old OSC addresses rather than adding the new ones alongside:

| Direction | Before | After |
|---|---|---|
| inbound | `/playaudio12/isConnected` | `/audioInterfaces/connected` |
| inbound | `/playaudio12/scene` | `/audioInterfaces/all/scene` |
| outbound | `/playaudio12/setScene` | `/audioInterfaces/setScene` |
| outbound | `/playaudio12/toggleScene` | `/audioInterfaces/toggleScene` |

Meanwhile `HELP.md` now claims *"It's compatible with AbleSet 3, but most features will also work with AbleSet 2"* and *"The old variables still work, but are considered deprecated"*, and `src/variables.ts:91-92` keeps `playAudio12Connected` / `playAudio12Scene` marked `(deprecated)`.

Those deprecated variables are only ever written from the **new** addresses (`:519`, `:523`). Against AbleSet 2, which emits and accepts only `/playaudio12/*`, the entire feature goes dead: `audioInterfaceConnected`, `audioInterfaceScene`, **and** both deprecated variables stay permanently empty; the Audio Interface Connected / Scene feedbacks never fire; and Set/Toggle Scene send addresses AbleSet 2 ignores. Users who upgraded — including via the otherwise-correct rename upgrade script — get silently dead buttons with no error.

**Fix Required:** keep the two legacy `server.on('/playaudio12/…')` listeners alongside the new ones (they cost nothing and write the same variable pair), and either send both address forms from `AudioInterfaceSetScene` / `AudioInterfaceToggleScene` or gate on a detected AbleSet version. If audio-interface control genuinely requires AbleSet 3, amend `HELP.md` to say so explicitly instead of implying the old variables still work.

---

## 🟡 Medium

### M2: close() is not idempotent and destroy() has no error handling

**Classification:** 🆕 NEW
**File:** `src/main.ts:167-170`, `src/main.ts:622-626`

In node-osc 11, `Server.close()` and `Client.close()` **reject** (rather than throw synchronously) when the socket is already closed. `destroy()` uses a bare `Promise.all` with no `.catch()`, so a second `destroy()` — for instance Companion tearing down after a `configUpdated()` whose `init()` threw before reassigning `oscConnections` — makes `destroy()` itself reject and abandons the rest of the teardown, leaking the remaining sockets and intervals.

**Fix:** track a per-connection `closed` boolean and return early from `close()` if already set; wrap each close in try/catch so one failure doesn't abort the others.

---

### M4: extends InstanceBase without the InstanceTypes generic

**Classification:** 🆕 NEW
**File:** `src/main.ts:55`

```ts
export default class ModuleInstance extends InstanceBase {
```

In v2 the signature is `InstanceBase<TManifest extends InstanceTypes = InstanceTypes>` (`node_modules/@companion-module/base/dist/module-api/base.d.ts:42`). Falling back to the default leaves `config` as `JsonObject` and actions/feedbacks/variables as open records, so `checkFeedbacks()`, `getVariableValue()` and `setVariableValues()` accept any string and `config.serverHost` is not compile-checked at the boundary where the connection is built.

This is not merely stylistic: supplying the manifest types would have caught **H3** and **N6** at compile time.

**Fix:** declare the manifest shape and use it — `interface AbleSetTypes { config: Config; secrets: undefined; actions: …; feedbacks: …; variables: … }`, then `extends InstanceBase<AbleSetTypes>`.

---

### M5: Inconsistent audioInterfaces address shapes need verification against the AbleSet 3 OSC API

**Classification:** 🆕 NEW
**File:** `src/main.ts:518`, `src/main.ts:522`, `src/main.ts:933`, `src/main.ts:938`

Three different shapes are used for what should be one namespace:

- inbound connected: `/audioInterfaces/connected` (no `/all/`)
- inbound scene: `/audioInterfaces/all/scene` (**with** `/all/`)
- outbound: `/audioInterfaces/setScene`, `/audioInterfaces/toggleScene` (no `/all/`)

node-osc's `Server` dispatches per-address events on an exact string match, so if any one of these is wrong the corresponding variable or feedback simply never updates, with no log line and no status change. This can't be verified against the AbleSet firmware from here — it's a "please confirm all four", particularly the `/all/` on the scene listener.

**Fix:** confirm each address against the AbleSet 3 OSC reference. Consider adding a `server.on('message')` fallback that debug-logs unmatched `/audioInterfaces/*` addresses so future mismatches are visible.

---

## 🟢 Low

### L1: remainingSetTime preset is named Remaining Time in Song

**Classification:** 🆕 NEW
**File:** `src/presets.ts:687`

```ts
remainingSetTime: {
  name: 'Remaining Time in Song',   // copy/paste from remainingSongTime at :679
```

Both new remaining-time presets carry the same `name`; only `previewStyle.text` distinguishes them, so the preset browser shows two identically named entries with identical tooltips.

**Fix:** `name: 'Remaining Time in Set'`.

---

### L2: formatDuration mishandles Infinity and the HH:mm:ss description is inaccurate

**Classification:** 🆕 NEW
**File:** `src/utils/format-duration.ts:5-7`, `:22-27`; `src/variables.ts` (`remainingTimeInSongFormatted`, `remainingTimeInSetFormatted`); `src/presets.ts:681`, `:689`

- `Number.isNaN` guards NaN but not `Infinity` — `formatDuration(Infinity)` returns `"Infinity:NaN:NaN"`.
- The variable descriptions say *"Formatted in HH:mm:ss"*, but `hours` is only pushed when `> 0`, so under an hour the value is `MM:SS`. That's a reasonable display choice; the description just doesn't match it.
- The presets render `'-$(AbleSet:remainingTimeInSongFormatted)'` with a hardcoded leading `-`. Before the first `/setlist/remainingTimeInSong` message — or whenever the OSC arg is missing (`Number(undefined)` → `NaN` → `''`) — the button shows a bare `-`, which reads as a rendering glitch. It also shows `-00:00` for clamped negatives.

**Fix:** use `Number.isFinite(seconds)` for the guard; either move the `-` inside `formatDuration` or default the two variables to `'00:00'`; and align the variable descriptions with the actual `[HH:]MM:SS` output.

---

### L3: Debounced and throttled handlers are not cancelled on teardown

**Classification:** 🆕 NEW
**File:** `src/main.ts:230`, `:255`, `:306-312`, `:165`

The lodash → `es-toolkit` swap preserved the previous lifecycle gap: only `handleHeartbeat.cancel()` runs during teardown. The `updateSongs` / `updateSections` debounces and the throttled `/global/finePosition` handler are never cancelled, so a trailing invocation can call `setVariableValues()` / `checkFeedbacks()` on a destroyed instance. `es-toolkit` exposes `.cancel()` on both `debounce` and `throttle` results.

**Fix:** hoist the throttled finePosition handler to a field and call `this.updateSongs.cancel()`, `this.updateSections.cancel()` and `this.throttledFinePosition.cancel()` in `destroy()`.

---

### L4: required removed from the by-name text inputs with no minLength replacement

**Classification:** 🆕 NEW
**File:** `src/main.ts:763-770` (Jump to Song by Name), `src/main.ts:869-876` (Jump to Section by Name)

Base v2 removed the `required` property on input fields and this release correctly drops it — but nothing replaced it. A user can now save "Jump to Song by Name" with an empty field; the callback sends `/setlist/jumpToSong ""`, which fails silently with no log line and no status change.

**Fix:** add `minLength: 1` to both text inputs and guard the callbacks (`if (!name) { this.log('warn', …); return }`).

---

### L5: Remaining-time variables are written at full OSC rate

**Classification:** 🆕 NEW
**File:** `src/main.ts:475-486`

`/setlist/remainingTimeInSong` and `/setlist/remainingTimeInSet` are both in `NOISY_ADDRESSES` (`:42-43`), i.e. they arrive at a high rate. Each message now writes **two** variables instead of one, doubling variable-update IPC traffic on these paths — even though the formatted string is identical for essentially every message within a given second.

**Fix:** cache the last formatted string per variable and only call `setVariableValues` for the formatted pair when it actually changes.

---

## 💡 Nice to Have

### N1: allowNegative parameter is dead code

**File:** `src/utils/format-duration.ts:4`, `:9-13`, `:31`

No caller passes `allowNegative`, so with the default the `isNegative` branch is unreachable in production. Either drop the parameter, or use it for the remaining-time variables — a signed value is arguably the more useful display when a song runs over, and it would let you remove the hardcoded `-` prefix noted in L2.

---

### N2: makeOrdinal produces 21th for indices at or above 20

**File:** `src/presets.ts:63-73`

`makeOrdinal` emits `21th`, `22th`, `23th`. Not reachable today (`RELATIVE_SONG_PRESETS_COUNT` and `RELATIVE_SECTION_PRESETS_COUNT` are both 8), but it will bite the moment those constants are raised.

---

### N3: getPort() probes a TCP port to pick a UDP port

**File:** `src/utils/get-port.ts`, `src/main.ts:92`

`getPort()` opens a **TCP** listener on an ephemeral port, closes it, and returns the number; the module then binds that number as **UDP**. A free TCP port implies nothing about UDP availability, and there is a TOCTOU gap between close and bind.

node-osc 11 removes the need for this entirely — the `Server` constructor accepts port `0` and rewrites `this.port` from the real bound socket once listening. So: `new Server(0, '0.0.0.0')`, await `listening`, use `server.port` in the `/subscribe` payload at `:147`, and delete `src/utils/get-port.ts`.

---

### N4: settingEqualsValue choices duplicate BOOLEAN_SETTINGS with drifting labels

**File:** `src/main.ts:1699-1719` vs `src/constants.ts:6-19`

The `settingEqualsValue` choice list is hand-maintained and duplicates `BOOLEAN_SETTINGS`, already with *different labels for the same ids* — "AbleNet" vs "AbleNet Enabled", "Stop on Song End" vs "Always Stop on Song End", "Back to Arrangement on Song Jump" vs "Reset Tracks Back to Arrangement on Song Jump".

Deriving both dropdowns from `BOOLEAN_SETTINGS` (plus the two non-boolean entries) would stop the labels drifting and would mean a future removal only has to be done once — which is precisely the class of mistake behind H3.

---

### N5: enableScripts false disables the husky postinstall and the canvas build

**File:** `.yarnrc.yml:2`, `package.json` (`"postinstall": "husky"`, `canvas` devDependency)

`.yarnrc.yml` sets `enableScripts: false` while `package.json` retains `"postinstall": "husky"` and a `canvas` devDependency that requires install scripts to build. Harmless for the packaged module build, but `yarn install` will no longer set up the git hooks or build `canvas` for `scripts/create-progress-icons.ts` — so the `.husky/pre-commit` lint-staged hook silently doesn't run for contributors.

Worth either documenting in the README or reconsidering the `postinstall` entry. (Related to C3's `.yarnrc.yml` row.)

---

### N6: Feedback.IsSyncingPlayback has no definition

**File:** `src/presets.ts:836`; `src/enums.ts:28`; `src/main.ts:360`

`Feedback.IsSyncingPlayback` is declared in the enum and checked at `src/main.ts:360`, but `setFeedbackDefinitions` never defines it — it is the only enum member with no definition. The `syncPlaybackNow` preset attaches it, so that preset produces a button with an unresolvable feedback and the "Syncing…" state never shows.

**This one is pre-existing** — identical in v1.7.3 (`presets.ts:708` / `main.ts:336`) — so it's outside the `tag` scope and listed only because `presets.ts` was rewritten wholesale in this release, making it a cheap win to fold into the same pass. Adding a boolean `[Feedback.IsSyncingPlayback]` definition returning `this.getVariableValue('isSyncingPlayback') === true` would close it.
