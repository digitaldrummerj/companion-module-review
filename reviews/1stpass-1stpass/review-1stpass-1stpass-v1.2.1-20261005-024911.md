# Review: 1stpass-1stpass v1.2.1

| | |
|---|---|
| **Module** | `1stpass-1stpass` |
| **Version** | v1.2.1 |
| **Scope:** | tag (`v1.1.2..v1.2.1`) |
| **Language** | TypeScript |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `d62230e` (2026-08-28) |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Protocol** | WebSocket (`ws` 8.21.0) |
| **Build** | `yarn install --immutable`, `yarn package`, `yarn lint` all pass |
| **Previous review** | v1.1.1 (2026-06-09). All of its findings (C1-C21, L6, L8, N2, F1-F5) are resolved in the current code. |
| **Reviewed** | 2026-10-05 |

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 1 | 0 | 1 |
| 🟡 Medium | 1 | 0 | 1 |
| 🟢 Low | 4 | 0 | 4 |
| 💡 Nice to Have | 5 | 0 | 5 |
| **Total** | **11** | **0** | **11** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**
- [ ] [H1: LICENSE does not match the template](#h1-license-does-not-match-the-template)

**Non-blocking**
- [ ] [M1: Tally state is not cleared on configUpdated](#m1-tally-state-is-not-cleared-on-configupdated)
- [ ] [L1: tally_state payload is only partly validated](#l1-tally_state-payload-is-only-partly-validated)
- [ ] [L2: Off-air camera name can render black on black](#l2-off-air-camera-name-can-render-black-on-black)
- [ ] [L3: Preset fallback text never shows, so disconnected buttons go fully blank](#l3-preset-fallback-text-never-shows-so-disconnected-buttons-go-fully-blank)
- [ ] [L4: Camera number range differs between actions and tally](#l4-camera-number-range-differs-between-actions-and-tally)
- [ ] [N1: Hex color parser accepts malformed strings](#n1-hex-color-parser-accepts-malformed-strings)
- [ ] [N2: Missing tally snapshot is reported only in the log](#n2-missing-tally-snapshot-is-reported-only-in-the-log)
- [ ] [N3: Presses for unknown cameras are dropped with only a debug log](#n3-presses-for-unknown-cameras-are-dropped-with-only-a-debug-log)
- [ ] [N4: Tally variables are rewritten even when nothing changed](#n4-tally-variables-are-rewritten-even-when-nothing-changed)
- [ ] [N5: Down-step action names use a Unicode minus sign](#n5-down-step-action-names-use-a-unicode-minus-sign)

---

## 🟠 High

### H1: LICENSE does not match the template

**File:** `LICENSE:3`
**Classification:** Template compliance (checked across the whole module, whatever the review scope)

Line 3 reads `Copyright (c) 2026 1stPass`; the template has `Copyright (c) 2022 Bitfocus AS - Open Source`. The template LICENSE is the licence Bitfocus ships for every module. It is not a scaffold to personalise, so it must match the template byte-for-byte. Line endings and trailing whitespace are ignored when comparing.

`LICENSE` has not changed since the initial release. The v1.1.1 review did not flag it because the template check has changed since then, not the module.

**Fix:** copy `LICENSE` from `companion-module-template-ts-v1` unchanged. If 1stPass needs different licence terms, raise that with Bitfocus rather than editing the file.

---

## 🟡 Medium

### M1: Tally state is not cleared on configUpdated

**Files:** `src/connection.ts:153-156`, `src/connection.ts:386-407`, `src/main.ts:42-46`
**Classification:** 🆕 NEW

`onDisconnect()` (`connection.ts:332-354`) clears `tally`, blanks the `camera_N_*` / `program_camera` / `standby_camera` variables and re-checks `camera_tally_name`. It only runs from the socket's `'close'` handler. `cleanup()` calls `this.ws.removeAllListeners()` before `close()`, so the handler never fires on an intentional disconnect (`configUpdated()` → `disconnect()` → `connect()`).

Effects for the operator:
- After a host or port change, buttons keep the old host's red and green tally until the new host pushes state.
  - If the new config is invalid (the `BadConfig` early return at `connection.ts:77-87`) or the new host is unreachable, the old tally stays indefinitely.
  - That is the "tally that lies" case the code comments say must never happen. It also breaks HELP.md's promise that these values "are cleared while the module is disconnected".
- `tally.hasReceivedState` stays `true`, so the "1stPass never sent tally state" warning (`connection.ts:236`) is suppressed for the new host.
- `noSuchCamera()` (`actions.ts:56-58`) keeps filtering `select_camera`, `camera_focus` and the stepper actions against the old host's camera list.

**Fix:** move the reset block of `onDisconnect()` (`tally.clear()`, the cleared variable map, and `checkFeedbacks('camera_tally_name')`) into a `resetTally()` helper. Call it from `disconnect()`, or at the start of `connect()` so the `BadConfig` path is covered too, as well as from the `'close'` handler.

---

## 🟢 Low

### L1: tally_state payload is only partly validated

**Files:** `src/connection.ts:197-198`, `src/tally.ts:132-138`, `src/feedbacks.ts:96`
**Classification:** 🆕 NEW

`msg.cameras` is cast to `TallyCamera[]`, and each entry is checked only for `typeof number === 'number'`. As a result:
- A non-string `name` (`null`, `undefined`, a number) goes straight into `setVariableValues` (`connection.ts:219`, `:225-226`) and into the feedback's `text`.
- An unexpected `state` or `preview_color` silently becomes idle or green.
- A `number` sent as a string (`"1"`) drops every entry, so all buttons go blank. The snapshot-missing warning is also suppressed, because `clearTallyWatch()` has already run.

**Fix:** normalise each entry in `TallyState.update()`:
- keep an entry only if `Number.isInteger(c.number) && c.number >= 1`, or coerce with `Number(...)` first;
- `name: String(c.name ?? '')`;
- accept only `'program' | 'preview' | 'idle'` for `state`, else `'idle'`;
- `preview_color: c.preview_color === 'blue' ? 'blue' : 'green'`.

Log at `warn` when entries are discarded.

### L2: Off-air camera name can render black on black

**Files:** `src/feedbacks.ts:91-92`, `src/tally.ts:68-83`
**Classification:** 🆕 NEW

For an off-air camera the background is `COLOR_BLACK` and the text colour is `hexToCompanionColor(camera.color)`. That function returns `COLOR_BLACK` for a missing or unparseable colour, and a genuinely dark camera colour has the same effect. The label disappears and the button looks like an empty slot.

**Fix:** when the parsed colour is the fallback, or its luma is below a threshold (reuse the `readableTextColor` math), use `COLOR_WHITE` or a light grey instead.

### L3: Preset fallback text never shows, so disconnected buttons go fully blank

**Files:** `src/feedbacks.ts:68-72`, `src/presets.ts:21-29`
**Classification:** 🆕 NEW

The preset comment calls the `CAM n` style "the disconnected fallback". But whenever `tally.get(n)` is undefined, `camera_tally_name` returns `{ bgcolor: COLOR_BLACK, color: COLOR_EMPTY_TEXT, text: '' }` while `use_camera_name` is true, which is the preset default. That includes every slot while disconnected, because `tally.clear()` runs. So `CAM n` is never visible on a placed button, and the operator cannot tell Camera 7 from Camera 12 until 1stPass reconnects.

**Fix:** while `!self.tally.hasReceivedState`, return `{}` (or omit `text`) so the button's own style shows. Keep the blank/black override for "connected, but no such camera". If the blank surface is intended, correct the preset comment and say so in HELP.md.

### L4: Camera number range differs between actions and tally

**Files:** `src/actions.ts:37-46`, `src/feedbacks.ts:45-52`, `src/tally.ts:11`
**Classification:** 🆕 NEW

The shared `cameraOption()` used by `select_camera`, `camera_focus` and all 20 stepper actions allows cameras 1-99. The `camera_tally_name` feedback, the presets and the `camera_N_*` variables stop at `MAX_CAMERAS` (20). A button can drive camera 25 but cannot carry a matching tally feedback or variables.

**Fix:** use `max: MAX_CAMERAS` in `cameraOption()`, or raise `MAX_CAMERAS` to match. If 99 is intentional, add a field `description` (and a HELP.md line) saying tally and variables cover cameras 1-20 only.

---

## 💡 Nice to Have

### N1: Hex color parser accepts malformed strings

**File:** `src/tally.ts:70`

`replace(/[^0-9a-fA-F]/g, '')` deletes every non-hex character instead of just an optional leading `#`. So `"rgb(255,0,0)"` becomes `"b25500"` and renders as `#B25500`, and `"#12 34 56"` parses as `#123456`. That contradicts the doc comment's promise that anything unparseable falls back to black.

**Fix:** strip only an optional leading `#` (`hex.trim().replace(/^#/, '')`), then require `/^([0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$/i` before parsing.

### N2: Missing tally snapshot is reported only in the log

**File:** `src/connection.ts:232-243`

The watchdog that detects an older 1stPass build only writes a `warn` log line. Operators rarely read the log, so the camera buttons just stay blank with no visible reason.

**Fix:** also call `updateStatus(InstanceStatus.UnknownWarning, '1stPass did not send tally state — update the app')`, and reset to `Ok` in `handleTallyState()`.

### N3: Presses for unknown cameras are dropped with only a debug log

**Files:** `src/actions.ts:56-58`, `:162-163`, `:286-287`, `:324-325`

`select_camera` used to always send. Now, once any `tally_state` has arrived, a press for a camera that is not in the list is dropped and logged only at `debug`. An operator who presses a button and sees nothing happen gets no feedback at the default log level.

**Fix:** log at `info`, or mention in HELP.md that a press is ignored when the camera is not in the show.

### N4: Tally variables are rewritten even when nothing changed

**Files:** `src/connection.ts:216-229`, `src/connection.ts:332-354`

- Every `tally_state` push rewrites all 42 tally variables and re-runs every `camera_tally_name` feedback, even when nothing changed.
- `onDisconnect()` runs on every `'close'`, including each failed reconnect attempt. So while 1stPass is unreachable, it re-sends 43 already-empty variables and re-checks feedbacks every 5 s.

**Fix:** diff against the previous values and pass only changed keys to `setVariableValues`, skipping `checkFeedbacks` when nothing changed. For the disconnect path, a `wasOpen` flag set in the `'open'` handler is enough.

### N5: Down-step action names use a Unicode minus sign

**File:** `src/actions.ts:172`

The down-step names use `−` (U+2212) rather than an ASCII `-`. Typing `-` in Companion's action search won't find "Camera Iris −" or the other down-step actions.

**Fix:** use an ASCII `-`, or the words "Up" / "Down", in the display name. Action IDs are unchanged, so no upgrade script is needed.

---

## 🔮 Next Release

- **Closing a socket that is still connecting can crash the module.** `src/connection.ts:400-405`. This code is outside this release's diff (unchanged since the initial release), so it does not affect this verdict, but it is worth fixing alongside M1.
  - `cleanup()` calls `this.ws.removeAllListeners()` and then `this.ws.close()` while the socket may still be `CONNECTING`.
  - In ws 8.21, `close()` on a connecting socket calls `abortHandshake()`, which emits `'error'` on the next tick (`node_modules/ws/lib/websocket.js:304-306`). With no listener left, Node throws it as an uncaught exception.
  - It is triggered by `configUpdated()` or `destroy()` while the host is unreachable and a handshake is pending (up to 10 s per attempt), for example by disabling the connection while the device is offline.
  - **Fix:** after `removeAllListeners()`, attach a no-op handler (`this.ws.on('error', () => {})`) before closing, or use `this.ws.terminate()` with an error listener still attached.
- **Consider migrating to `@companion-module/base` v2.x** (v2.0 for Companion 4.3+, v2.1 for Companion 5.0+), following the v1-to-v2 migration guide. Not required for this release.
