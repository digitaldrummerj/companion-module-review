# Review: companion-module-biamp-tesira v3.0.3

| | |
|---|---|
| **Module** | biamp-tesira |
| **Review tag** | v3.0.3 |
| **Previous tag** | v2.1.1-beta.3 |
| **Scope** | `tag` (v2.1.1-beta.3 .. v3.0.3 diff) |
| **Language / API** | TypeScript · @companion-module/base v1.x (~1.14.1) |
| **Protocol** | Tesira Text Protocol (TTP) over Telnet/TCP |
| **Build** | ✅ `yarn build` (tsc) passes |
| **Reviewed** | 2026-06-14 |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [H1: subscribe_helper upgrade drops the old attribute value, breaking migrated subscriptions](#h1-subscribe-helper-upgrade-drops-the-old-attribute-value-breaking-migrated-subscriptions)
- [ ] [H2: Level-range override parser splits on the wrong delimiter](#h2-level-range-override-parser-splits-on-the-wrong-delimiter)

**Non-blocking**

- [ ] [M2: Transient poll-socket error forces the whole instance to ConnectionFailure](#m2-transient-poll-socket-error-forces-the-whole-instance-to-connectionfailure)
- [ ] [N1: No end/close handler; clean far-end disconnect not reflected in status](#n1-no-endclose-handler-clean-far-end-disconnect-not-reflected-in-status)
- [ ] [N2: Status reaches Ok from the command socket only; poll-socket stall stays hidden](#n2-status-reaches-ok-from-the-command-socket-only-poll-socket-stall-stays-hidden)
- [ ] [N3: Level-hold timer flips status to ConnectionFailure on every tick when the socket drops](#n3-level-hold-timer-flips-status-to-connectionfailure-on-every-tick-when-the-socket-drops)

---

## 🟠 High

### H1: subscribe helper upgrade drops the old attribute value breaking migrated subscriptions

**File:** `src/upgrades.ts:57-83` (`remapActionSpecificOptions`) · **Classification:** 🆕 NEW

The new `upgradeV2ActionIds` script correctly maps all 12 renamed action IDs and the common option renames (`instanceID→instanceTag`, `presetID→presetId`, `customvar→variableName`, `index→index1`, `muteStatus→state`, `rate→intervalMs`, numeric→string coercion, etc.) — that part is solid. **The one gap is the subscribe path.** The old `subscribeParameter` action carried a free-text `attribute` option (default `level`). It now maps to `subscribe_helper`, whose attribute comes from a `templateId` dropdown plus a `customAttribute` textinput that is only used when `templateId === 'custom'` (`src/actions.ts:496-509`, callback `:552-555`). The upgrade never remaps the old `attribute`: it leaves a stray `attribute` key and an undefined `templateId`. At runtime `templateId` coerces to `'custom'` with an empty `customAttribute`, so the attribute resolves to `''` and the callback throws *"Instance tag, attribute, and variable name are required."* Existing users' custom subscriptions silently stop working after they update.

(The new `unsubscribe_helper` still uses a plain `attribute` textinput at `src/actions.ts:587`, so unsubscribe migrates fine — the gap is subscribe-only.)

**Fix (maintainer):** in `remapActionSpecificOptions`, for `subscribe_helper`, when an old `attribute` key is present set `options.templateId = 'custom'`, `options.customAttribute = options.attribute`, then delete `attribute`.

### H2: Level-range override parser splits on the wrong delimiter

**File:** `src/feedbacks.ts:70` (`parseRangeOverrides`) · **Classification:** 🆕 NEW

v3.0.3 wired `readRangeOverride` into `resolveLevelRange` / `resolveMeterRange` / `resolveGenericRange` (`feedbacks.ts:118, 139, 165`), which was the intent of the prior M2 fix — good. But the feedback-side parser splits entries on `/[\n;]/` (newlines/semicolons), while the config tooltip **and** the parallel parser in `presets.ts:53-55` both use **comma-separated** entries (e.g. `Lobby_Level=-80:12,Podium_Level=-40:0`). Feeding the documented multi-entry comma string to the feedback parser returns an **empty map** (the `min:max` split picks up `12,Podium_Level=-40` → `NaN` → entry dropped). A single lone entry parses only by coincidence. Net result: manually-placed meter/level feedbacks still ignore the override for any real multi-entry config, so the original M2 symptom (wrong bar fill) persists.

**Fix (maintainer):** split on `,` to match `presets.ts` and the tooltip — better, export and **reuse** `parseRangeOverrides` from `presets.ts` so the two parsers can't drift. Also align the key/value parse: `presets.ts` uses `indexOf('=')` + `slice` (tolerates `=` in values) while `feedbacks.ts` uses `split('=')` (breaks on a second `=`).

---

## 🟡 Medium

### M2: Transient poll-socket error forces the whole instance to ConnectionFailure

**File:** `src/main.ts:630-635` · **Classification:** 🆕 NEW

The prior M4 fix (poll-socket errors now surface in status) is in place and correct in principle. The side effect: the poll-socket `error` handler unconditionally calls `updateStatus(InstanceStatus.ConnectionFailure, …)`, so a transient blip on the *polling* socket drives the **whole instance** to `ConnectionFailure` even when the primary control socket is healthy, and nothing re-asserts `Ok` until the next `connect`/`status_change`. The operator can be left looking at a stuck red status after a recovered blip.

**Fix (maintainer):** confirm a reconnect/`status_change` drives status back to `Ok` after a transient poll-socket error, or gate the `ConnectionFailure` on the control socket also being down (e.g. report a degraded/warning state for poll-only failures).

---

## 💡 Nice to Have

### N1: No end/close handler; clean far-end disconnect not reflected in status

**File:** `src/main.ts:588-658` · **Classification:** 🆕 NEW

Neither `initCommandSocket()` nor `initPollingSocket()` registers an `'end'`/`'close'`/`'disconnect'` listener. On a clean far-end FIN (no error), `isReady` can stay `true` and status can stay `Ok` until the next failed send/poll. The module relies on `TelnetHelper`'s built-in auto-reconnect and the welcome-line path to re-arm — reasonable — but a graceful close isn't reflected immediately. Consider an `'end'`/`'disconnect'` listener that sets `isReady = false` and `updateStatus(Disconnected/Connecting)`.

### N2: Status reaches Ok from the command socket only; poll-socket stall stays hidden

**File:** `src/main.ts:621-641` · **Classification:** 🆕 NEW

`Ok` is set solely on the command socket's welcome line (`main.ts:691-693`); the poll socket's `connect` (`:637-641`) starts the poll timer without confirming the poll socket reached the TTP prompt. If the command socket logs in but the poll socket stalls at the login prompt, status shows `Ok` while metering is dead until the poll socket actually errors. (The M4 fix covers the error case; this is the silent-stall case.) Consider gating `Ok` on both sockets seeing the welcome banner.

### N3: Level-hold timer flips status to ConnectionFailure on every tick when the socket drops

**File:** `src/main.ts:449-454` · **Classification:** 🆕 NEW

`startLevelHold` repeatedly calls the guarded `sendCommand`; if the socket drops mid-hold, each tick re-flips status to `ConnectionFailure`. Functionally safe (timer is cleared in `stopLevelHold()`/`closeConnections()`), just noisy. Consider stopping `levelHoldTimer` when `sendCommand` detects a disconnected socket.
