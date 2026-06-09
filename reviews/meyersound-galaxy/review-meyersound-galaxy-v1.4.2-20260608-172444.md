# Review — companion-module-meyersound-galaxy

| | |
|---|---|
| **Module** | meyersound-galaxy |
| **Version (tag)** | v1.4.2 |
| **Previous tag** | (none — first registry submission) |
| **Scope** | tag |
| **Language / API** | JavaScript (CommonJS) · @companion-module/base v1 (~1.14.1) |
| **Protocols** | Raw TCP (Node `net`, default port 25003) to Meyer Sound Galaxy DSP; virtual-Galaxy localhost probing |
| **Reviewed** | 2026-06-08 |

> **Note on scope:** This is the module's first registry submission, so there is no `previousTag..reviewTag` diff. Per the `tag` fallback rule, this was conducted as a **full review of the whole module**; every finding is classified 🆕 NEW.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 2 | 0 | 2 |
| 🟠 High | 4 | 0 | 4 |
| 🟡 Medium | 7 | 0 | 7 |
| 🟢 Low | 7 | 0 | 7 |
| 💡 Nice to Have | 3 | 0 | 3 |
| **Total** | **23** | **0** | **23** |

## Verdict: ❌ Changes Required

You have several files that have over 1,000 lines in them and should be split into smaller manageable files.  Having the large files is very difficult to review and maintain.

## 📋 Issues

**Blocking**

- [ ] [C1: Source files at module root instead of src/](#c1-source-files-at-module-root-instead-of-src)
- [ ] [C2: Manifest keywords duplicate manufacturer and product](#c2-manifest-keywords-duplicate-manufacturer-and-product)
- [ ] [H1: Matrix presets reference a non-existent action matrix_gain_set](#h1-matrix-presets-reference-a-non-existent-action-matrix_gain_set)
- [ ] [H2: All Muted preset references a non-existent action mute_all](#h2-all-muted-preset-references-a-non-existent-action-mute_all)
- [ ] [H3: Upgrade script renames actions to IDs that do not exist](#h3-upgrade-script-renames-actions-to-ids-that-do-not-exist)
- [ ] [H4: Subscribe-socket reconnect fires twice per failure](#h4-subscribe-socket-reconnect-fires-twice-per-failure)

**Non-blocking**

- [ ] [M1: Virtual-Galaxy discovery runs continuously on physical connections](#m1-virtual-galaxy-discovery-runs-continuously-on-physical-connections)
- [ ] [M2: Dead requestSnapshots call leaves snapshot state stale after operations](#m2-dead-requestsnapshots-call-leaves-snapshot-state-stale-after-operations)
- [ ] [M3: Log-history socket leaked on destroy and reconfigure](#m3-log-history-socket-leaked-on-destroy-and-reconfigure)
- [ ] [M4: Matrix route summaries recomputed on every matrix-gain message](#m4-matrix-route-summaries-recomputed-on-every-matrix-gain-message)
- [ ] [M5: Stale bonjourQueries block in manifest](#m5-stale-bonjourqueries-block-in-manifest)
- [ ] [M6: Redundant parseVariablesInString on auto-parsed fields](#m6-redundant-parsevariablesinstring-on-auto-parsed-fields)
- [ ] [M7: Two number fields missing min and max](#m7-two-number-fields-missing-min-and-max)
- [ ] [L1: presetsRefreshTimer not cleared in configUpdated](#l1-presetsrefreshtimer-not-cleared-in-configupdated)
- [ ] [L2: BigInt on unvalidated device value can throw](#l2-bigint-on-unvalidated-device-value-can-throw)
- [ ] [L3: Untracked gain-debounce timers fire after destroy](#l3-untracked-gain-debounce-timers-fire-after-destroy)
- [ ] [L4: Commands issued during teardown spawn a transient socket](#l4-commands-issued-during-teardown-spawn-a-transient-socket)
- [ ] [L5: No connect/idle timeout on the main sockets](#l5-no-connectidle-timeout-on-the-main-sockets)
- [ ] [L6: ConnectionFailure status branch is dead code](#l6-connectionfailure-status-branch-is-dead-code)
- [ ] [L7: Deprecated isVisible callback functions throughout](#l7-deprecated-isvisible-callback-functions-throughout)
- [ ] [N1: console.error used instead of this.log](#n1-consoleerror-used-instead-of-thislog)
- [ ] [N2: Dead _gainFades* fade-tracking code](#n2-dead-_gainfades-fade-tracking-code)
- [ ] [N3: Overlapping multi-output matrix fades can fight](#n3-overlapping-multi-output-matrix-fades-can-fight)

## 🔴 Critical

### C1: Source files at module root instead of src/

**Classification:** 🆕 NEW · **Source:** deterministic template check (SRC-AT-ROOT)

All module source lives at the repository root. The official `companion-module-template-js-v1` requires source under `src/` with the manifest `entrypoint` set to `../src/main.js` and `package.json` `main` set to `src/main.js`. This module ships source at root with `entrypoint: ../main.js` and `main: main.js`.

Files at root that must move under `src/`:
`actions-data.js`, `actions-helpers.js`, `actions.js`, `feedbacks.js`, `helpers.js`, `main.js`, `presets.js`, `upgrades.js`, `variables.js` (and the `actions/` directory).

**Fix:** Move all source into `src/` (e.g. `src/main.js`, `src/actions/…`), update `companion/manifest.json` `runtime.entrypoint` to `../src/main.js`, and set `package.json` `main` to `src/main.js`. Adjust any relative `require()` paths accordingly.

### C2: Manifest keywords duplicate manufacturer and product

**Classification:** 🆕 NEW · **Source:** deterministic template check (MAN-KEYWORD) · `companion/manifest.json:25`

`keywords` is `["meyersound", "audio", "galaxy", "DSP"]`. `"meyersound"` duplicates the `manufacturer` ("Meyer Sound") and `"galaxy"` duplicates the `products` entry ("Galaxy"). Bitfocus rejects keywords that merely repeat the manufacturer/product name — keywords should add discovery value not already covered by those fields.

**Fix:** Remove `"meyersound"` and `"galaxy"`. Keep distinct, additive terms (e.g. `["audio", "DSP", "loudspeaker", "processor"]`).

## 🟠 High

### H1: Matrix presets reference a non-existent action matrix_gain_set

**Classification:** 🆕 NEW · `presets.js:2759`, `presets.js:2801`, `presets.js:2844`

The Matrix Row/Column presets emit `actionId: 'matrix_gain_set'`, but the matrix action is registered as `matrix_gain` (`actions/matrix.js:21`). No `matrix_gain_set` action exists anywhere in the module. Companion silently drops unknown action IDs, so buttons created from these presets do nothing on press.

**Fix:** Change the three preset `actionId` values to `'matrix_gain'`. The option keys (`matrix_inputs`, `matrix_outputs`, `gain`, `fadeMs`, `curve`) already match the real action; `mode` defaults to `'set'`, so the payload is otherwise compatible.

### H2: All Muted preset references a non-existent action mute_all

**Classification:** 🆕 NEW · `presets.js:983`

The "All Muted" preset emits `actionId: 'mute_all'` with `options: { op: 'toggle' }`, but no `mute_all` *action* is defined in any `actions/*.js` file (only a `mute_all` *feedback* exists at `feedbacks.js:278`). The preset's down-action is broken.

**Fix:** Define a `mute_all` action accepting an `op` option, or repoint the preset to the real "mute all" action if one exists under a different ID.

### H3: Upgrade script renames actions to IDs that do not exist

**Classification:** 🆕 NEW · `upgrades.js:19-23`, `upgrades.js:31-33`

The V1 upgrade renames saved actions to `matrix_gain_set`, `matrix_gain_nudge`, `matrix_delay_set` (and `system_input_mode_set`). None of those IDs are registered in the current code — the real matrix actions are `matrix_gain` (`actions/matrix.js:21`) and `matrix_delay_full` (`actions/matrix.js:144`). Any config carrying the old multi-IDs is "migrated" to a still-dead ID and becomes an orphaned no-op. Lower real-world risk on a first submission (few legacy configs exist), but the rename map is internally inconsistent with the shipped action set.

**Fix:** Point the upgrade renames at the actually-registered IDs and remap their option keys to the target action's schema. Verify `matrix_gain_nudge`, `matrix_delay_set`, and `system_input_mode_set` against the current action list and drop or correct entries that resolve to nonexistent IDs.

### H4: Subscribe-socket reconnect fires twice per failure

**Classification:** 🆕 NEW · `main.js:477-502`

The subscribe socket registers the same `reconnect` handler on `error`, `end`, and `close`. On a typical failure Node emits `error` then `close` (or `end`+`close` on a clean remote close), so `reconnect()` runs twice for one socket. The only guard (`if (this.subSock === sock) this.subSock = null`, line 479) does not early-return, so each double-fire increments `_reconnectAttempts` twice (line 489), doubles `_reconnectDelay` twice (line 490 — backoff jumps 1s→2s→4s in a single failure instead of 1s→2s), and schedules **two** `setTimeout(() => this._startSubscribe(), …)` (line 497). With `RECONNECT_MAX_ATTEMPTS = 0` (infinite) against an unreachable host this compounds into duplicate parallel reconnect chains.

**Fix:** Make `reconnect` idempotent per socket — gate the entire body on the socket-identity check and return otherwise:

```js
const reconnect = () => {
  if (this._destroyed) return
  if (this.subSock !== sock) return   // already handled this socket
  this.subSock = null
  // …rest of body…
}
```

(The command-socket `retry` at `main.js:1272-1277` has the same multi-event registration but is effectively safe because it `clearTimeout(this.cmdTimer)` before scheduling.)

## 🟡 Medium

### M1: Virtual-Galaxy discovery runs continuously on physical connections

**Classification:** 🆕 NEW · `main.js:316-318`, `main.js:4275-4331`

`_startVirtualDiscoveryLoop()` is started unconditionally in `init()`/`configUpdated()`. `_runVirtualDiscovery()` probes `VIRTUAL_MIN_ID..VIRTUAL_MAX_ID` (20) across 3 hosts = up to 60 short-lived TCP sockets every `VIRTUAL_SCAN_INTERVAL_MS` (10s), plus persistent watcher sockets to any detected localhost devices — regardless of `config.connection_type`. On a plain physical-device install this is steady background socket churn for a feature the user isn't using.

**Fix:** Gate discovery on `this.config?.connection_type === 'virtual'` (or only run it while the config dialog is open). Skip the loop entirely for physical connections.

### M2: Dead requestSnapshots call leaves snapshot state stale after operations

**Classification:** 🆕 NEW · `actions/snapshots.js:254-255, 273-274, 295-296, 367-368, 394-395, 427-428, 460-461`

After create/update/duplicate/rename/delete/lock/unlock, each handler does `setTimeout(() => { if (typeof self.requestSnapshots === 'function') self.requestSnapshots() }, 500)`. `requestSnapshots` is not defined anywhere in the module, so the guard is always false and the post-operation re-fetch never runs. No crash (guarded), but snapshot variables/labels go stale after operations until the device pushes again on its own.

**Fix:** Implement `requestSnapshots()` (re-issue the `/project/snapshot/...` reads) or replace these blocks with the real seeding routine. If intentional, remove the dead code.

### M3: Log-history socket leaked on destroy and reconfigure

**Classification:** 🆕 NEW · `main.js:2154-2233` (esp. 2166-2167, 2227)

`_fetchLogHistory()` opens a dedicated socket stored as `this._logHistoryInFlight`, with a 2s `endTimer` armed only inside the `connect()` success callback (line 2227). Neither `destroy()` (321-352) nor `configUpdated()` (354-397) clears/destroys `_logHistoryInFlight`. If the module is destroyed or reconfigured while a log fetch is connecting or streaming, the socket and its timer survive, and `finish()` calls `_announceCompanionConnected()` / `this.log(...)` on a dead instance. A hung connect (no connect timeout) keeps the socket alive indefinitely.

**Fix:** In `destroy()` and `configUpdated()`: `try { this._logHistoryInFlight?.destroy() } catch {}` then null it. Arm a guard timer before/at `connect()` rather than only in the success callback.

### M4: Matrix route summaries recomputed on every matrix-gain message

**Classification:** 🆕 NEW · `main.js:1857`, `main.js:1902-1928`

Every `_applyMatrixGain` calls `_collectMatrixRouteSummaries`, which loops 32 inputs × 16 outputs, rebuilds two strings, then calls `setVariableValues`. On connect the seed phase pushes up to 32×16 = 512 matrix gains, so this runs up to 512× (~24k iterations plus 512 `setVariableValues` and 512 `checkFeedbacks`) in a burst. The `=== rounded` early-return only helps unchanged repeats, not the initial fill.

**Fix:** Debounce/batch the route-summary recompute (like the meter batch), or skip it during the initial seed and run it once after seeding completes.

### M5: Stale bonjourQueries block in manifest

**Classification:** 🆕 NEW · `companion/manifest.json:26-31`

The manifest declares `bonjourQueries.bonjour_host` (`_galaxy._tcp`), but the module no longer has a `bonjour-device` config field — `getConfigFields()` (`main.js:400-462`) exposes only `connection_type`, `host`, `virtual_id`, and a hidden `port`, and upgrade V2 (`upgrades.js:119-184`) explicitly removes `bonjour_host`. The Bonjour query targets a field that doesn't exist (dead configuration). There is no Bonjour discovery in the runtime code.

**Fix:** Remove the `bonjourQueries` block, or re-add a `bonjour-device` config field if discovery is still intended.

### M6: Redundant parseVariablesInString on auto-parsed fields

**Classification:** 🆕 NEW · `actions/snapshots.js:265-266`, `actions/snapshots.js:337-338`

`snapshot_name` / `snapshot_comment` are `textinput` with `useVariables: true` (`actions/snapshots.js:109-122`). On @companion-module/base v1.13+ (this module is ~1.14.1), variables in such fields are auto-parsed before the callback, so `e.options.snapshot_name` already holds the resolved value. The `await self.parseVariablesInString(...)` calls are no-ops. (No local/button variables are used anywhere in the module, so there's no `$(this:*)`/`$(local:*)` case that would still need manual parsing.)

**Fix:** Drop the `parseVariablesInString` calls and read `e.options.snapshot_name` / `e.options.snapshot_comment` directly.

### M7: Two number fields missing min and max

**Classification:** 🆕 NEW · `actions/subwoofer-design.js:321` (`spacing`), `actions/subwoofer-design.js:512` (`spacing_arrayendfire`)

Both `number` fields define `default` and `step` but no `min`/`max`. In v1 the number-input field type expects bounds; without them the UI offers no validation and a user can enter out-of-range/negative spacing (which feeds the delay math). The other 88 of 90 number fields in the module supply `min`/`max`.

**Fix:** Add sensible `min`/`max` (e.g. `min: 0` and an appropriate upper bound) to both spacing fields.

## 🟢 Low

### L1: presetsRefreshTimer not cleared in configUpdated

**Classification:** 🆕 NEW · `main.js:370-377`

`configUpdated()` clears the actions/feedbacks/variables/meter timers but omits `_presetsRefreshTimer` (it *is* cleared in `destroy()` at line 339). A pending preset-refresh `setTimeout` survives a config change. Minor — the callback is wrapped in try/catch and only calls `updatePresets`.

**Fix:** Add `clearTimeout(this._presetsRefreshTimer); this._presetsRefreshTimer = null` to `configUpdated()`.

### L2: BigInt on unvalidated device value can throw

**Classification:** 🆕 NEW · `main.js:3917` (`_parseAccessPrivilege`)

`const v = BigInt(rhs)` runs on the raw extracted RHS without validating it's an integer string; a float/empty/text value throws `SyntaxError`. It's contained (`_onSubLine` wraps `_onSubLineUnsafe` in try/catch, 881-888), so the process won't crash, but the whole line is dropped and an error logged on each occurrence.

**Fix:** Validate with `/^-?\d+$/` before `BigInt`, or wrap in try/catch returning `undefined`.

### L3: Untracked gain-debounce timers fire after destroy

**Classification:** 🆕 NEW · `main.js:2649-2660` (input), `main.js:2705-2716` (output)

The 1050ms `setTimeout`s in `_applyInputGain`/`_applyOutputGain` are not stored or cleared on `destroy()`. They only mutate internal tracking state (no Companion API calls) and self-guard (`if (!cur) return`), so impact is low, but they're uncancelled timers that can fire post-destroy and accumulate transiently under rapid gain changes.

**Fix:** Track these timers and clear them in `destroy()`, or guard their bodies with `if (this._destroyed) return`.

### L4: Commands issued during teardown spawn a transient socket

**Classification:** 🆕 NEW · `main.js:326, 343-351, 365`

`destroy()`/`configUpdated()` call `_stopOutputChase()` → `_muteAllOutputs()` → `_cmdSendBatch` → `_cmdFlush` → `_ensureCmdSocket` *before* the command socket is destroyed. This enqueues mute commands and may create a new command socket that is immediately torn down, so the mutes may not actually be delivered and a short-lived socket can be created during teardown.

**Fix:** Bail out of `_ensureCmdSocket()`/`_cmdFlush()` when `this._destroyed`, or stop the chase without re-issuing commands during teardown.

### L5: No connect/idle timeout on the main sockets

**Classification:** 🆕 NEW · `main.js:473`, `main.js:1269`

Neither `subSock` nor `cmdSock` calls `sock.setTimeout(...)`, so a `connect()` to a silently-unreachable host relies on the OS TCP timeout (~75s) before `error` fires. The virtual-probe and watcher sockets correctly use `setTimeout` (lines 4197, 4350) — the pattern is just missing on the two main sockets.

**Fix:** Add `sock.setTimeout(connectMs, () => sock.destroy())` so failed connects surface promptly and feed the existing reconnect/retry path.

### L6: ConnectionFailure status branch is dead code

**Classification:** 🆕 NEW · `main.js:39`, `main.js:483-484`

`RECONNECT_MAX_ATTEMPTS = 0` and the branch at line 483 only runs when `> 0`, so `InstanceStatus.ConnectionFailure` (line 484) is never set as shipped. Not a defect, but the status is unreachable.

**Fix:** Either expose max-attempts as config, or drop the dead branch so the status set isn't misleading.

### L7: Deprecated isVisible callback functions throughout

**Classification:** 🆕 NEW · `main.js:435, 447, 459` plus ~129 occurrences across `actions/*.js` and `feedbacks.js`

`isVisible: (options) => …` callbacks are deprecated since v1.12 in favor of `isVisibleExpression` string expressions. Still fully functional in v1.x (non-blocking), but worth migrating before any v2.0 move where expressions are first-class.

**Fix (future):** Migrate to `isVisibleExpression: "$(options:connection_type) == 'physical'"`-style expressions over time. No action required for this release.

## 💡 Nice to Have

### N1: console.error used instead of this.log

`actions/index.js:20, 24, 28` and `actions-helpers.js:19` use `console.error` instead of `self.log('error', …)`. These are guard/parse paths unlikely to fire in production, but per module conventions logging should route through the instance logger.

### N2: Dead _gainFades* fade-tracking code

`_stopInputFade`/`_stopOutputFade` (`main.js:1771-1779, 1814-1822`) reference `this._gainFadesIn/_gainFadesOut`, which the fade starters never populate (they use the generic `_fades` map keyed `in-${c}`/`out-${c}`, correctly stopped via `_stopFade`). The `_gainFades*` handling is dead but harmless.

### N3: Overlapping multi-output matrix fades can fight

`_startMatrixGainFadeMulti` (`main.js:2007`) keys the fade by the exact output set (`mx-${i}-[${targets.join(',')}]`). Two overlapping multi-fades on the same input with *different* output sets won't cancel each other and will fight on overlapping crosspoints. Edge case only.

## 🧪 Tests

No test framework, test files, or `test` script present — non-blocking, nothing to run.

---

### Verified clean (no findings)

- **Build/package:** `yarn package` (`companion-module-build`) completes successfully.
- **Lifecycle:** `init`/`destroy`/`configUpdated`/`getConfigFields` all implemented. `destroy()` and `configUpdated()` tear down `subSock`, `cmdSock`, `cmdTimer`, all refresh timers, fades, chase, flash, and call `_disableVirtualDiscovery()`.
- **Virtual discovery teardown:** `_disableVirtualDiscovery()` clears both scan timers, destroys every watcher socket, clears watcher reconnect timers; the 10s scan interval is singleton (no duplicate intervals across init/configUpdated).
- **TCP framing:** residual buffer is carried between chunks on subscribe (506-507), watcher (4212-4213), probe (4357-4358), and log-history (2174-2175). Incoming-line parsing is wrapped in try/catch; socket writes are guarded and re-queued on failure.
- **Parsing robustness:** numeric parses check `Number.isFinite`; channel/band/matrix indices range-checked against `NUM_INPUTS`/`NUM_OUTPUTS`/`MATRIX_INPUTS`; subwoofer/array math guards divisors (`Math.max(1e-6, freq)`, `|| 1`). No divide-by-zero or NaN-to-device path found.
- **Compliance:** `runEntrypoint(ModuleInstance, UpgradeScripts)` present; `UpgradeScripts` exported as an array; config `host` uses `Regex`, hidden `port` bounded 1–65535; boolean feedbacks declare `defaultStyle` and return booleans, advanced feedbacks return style objects; `setVariableDefinitions` called before `setVariableValues`; all `variableId`s are lowercase/underscore-safe and match `companion/HELP.md`; preset `feedbackId`s all resolve (only the *action* refs in H1/H2 are broken).
- **Repo hygiene:** `pkg/`, `*.tgz`, `node_modules/`, `.yarn` are all gitignored and untracked; `package-lock.json` absent. `apiVersion: "0.0.0"` is the template build placeholder (not an issue). HELP.md is thorough and accurate.
