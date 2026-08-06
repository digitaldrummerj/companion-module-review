# Module Review — stype-realline v2.0.0

| | |
|---|---|
| **Module** | `companion-module-stype-realline` |
| **Review tag** | `v2.0.0` |
| **Previous tag** | `v1.3.1` |
| **Scope** | `tag` — only the `v1.3.1..v2.0.0` diff |
| **Language** | TypeScript |
| **API** | `@companion-module/base` v2 (2.0.4) |
| **Protocols** | WebSocket, OSC |
| **Reviewed** | 2026-08-03 |

**Changed in this release:** `.yarnrc.yml`, `companion/HELP.md`, `companion/manifest.json`, `package.json`, `src/actions.ts`, `src/feedbacks.ts`, `src/icons.ts`, `src/presets.ts`, `src/types.ts`, `src/variables.ts`, `yarn.lock`

**Build:** ✅ `yarn build` passes · **Lint:** ✅ `yarn lint` passes

---

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 0 | 0 | 0 |
| 🟠 High | 0 | 0 | 0 |
| 🟡 Medium | 4 | 0 | 4 |
| 🟢 Low | 2 | 0 | 2 |
| 💡 Nice to Have | 0 | 0 | 0 |
| **Total** | **6** | **0** | **6** |

## Verdict: Approved

## 📋 Issues

**Blocking**

- None

**Non-blocking**

- [ ] [M1: record_all_status returns text: '' and blanks user button text](#m1-record_all_status-returns-text--and-blanks-user-button-text)
- [ ] [M2: Working PNG icons replaced with raw Unicode glyphs](#m2-working-png-icons-replaced-with-raw-unicode-glyphs)
- [ ] [M3: record_all_status has no disconnected or unknown state](#m3-record_all_status-has-no-disconnected-or-unknown-state)
- [ ] [M4: Idle record button is red-on-grey at roughly 1.3:1 contrast](#m4-idle-record-button-is-red-on-grey-at-roughly-131-contrast)
- [ ] [L1: any_warning overlay dropped from the record_all preset](#l1-any_warning-overlay-dropped-from-the-record_all-preset)
- [ ] [L2: all_idle reports true when the tracker list is empty](#l2-all_idle-reports-true-when-the-tracker-list-is-empty)

---

## 🟡 Medium

### M1: record_all_status returns text: '' and blanks user button text

**File:** `src/feedbacks.ts:136`, `src/feedbacks.ts:142`
**Classification:** 🔙 REGRESSION

Both branches of the rewritten `record_all_status` advanced feedback now return `text: ''`:

```ts
return isRecording
    ? { bgcolor: combineRgb(181, 0, 0), text: '', png64: STOP_ICON_PNG64, pngalignment: 'center:center' }
    : { bgcolor: combineRgb(70, 70, 70), text: '', png64: RECORD_ICON_PNG64, pngalignment: 'center:center' }
```

The v1.3.1 version returned only `bgcolor`/`color`/`png64`/`pngalignment` and left the button's own text alone. Advanced-feedback style results merge over the button style and `''` is a defined value, so this now unconditionally blanks the text of *any* button the feedback is attached to. A user who adds `record_all_status` to a button showing `$(stype-realline:take_no)` or a custom label sees their text vanish, with no way to recover it except removing the feedback.

**Suggested fix:** drop the `text` key from both returned style objects. The `record_all` preset already sets `text: ''` in its base style (`src/presets.ts:140`), so the icon-only look is preserved without hijacking user buttons.

### M2: Working PNG icons replaced with raw Unicode glyphs

**File:** `src/icons.ts:16-17`, used at `src/presets.ts:155` and `src/presets.ts:168`
**Classification:** 🔙 REGRESSION

The known-good `NEXT_ICON_PNG64` / `RELOAD_ICON_PNG64` base64 icons were deleted and replaced with text glyphs rendered at `size: '44'`:

```ts
export const NEXT_GLYPH = '⏭' // U+23ED  (fallback: '▶▶')
export const RELOAD_GLYPH = '↻' // U+21BB
```

Rendering now depends entirely on Companion's font-fallback chain. U+21BB is a Miscellaneous-Symbols arrow that isn't in the default button face; U+23ED carries default *emoji* presentation, so it may render as a colour emoji that ignores the preset's `color: BLACK`. Worst case both render as tofu boxes — and since `text` is *only* the glyph, the operator gets an unlabelled button with no fallback. The `(fallback: '▶▶')` note is a comment only; nothing implements it.

**Suggested fix:** restore the two PNG constants (recoverable via `git show v1.3.1:src/icons.ts`), or — if you keep the glyphs — verify both on physical Stream Deck hardware *and* in the web-UI button preview across platforms, and add a text label (e.g. `'NEXT\n⏭'` at a smaller size) so the button stays identifiable if the glyph doesn't resolve.

### M3: record_all_status has no disconnected or unknown state

**File:** `src/feedbacks.ts:126-146`
**Classification:** 🆕 NEW

The callback computes `isRecording` purely from cached tracker state, with no branch for "not connected" or "no trackers yet". When the WebSocket is down, `instance.state.trackers` holds whatever was last received (or is empty), so the button renders the idle grey + red record circle — visually identical to a healthy, armed, ready-to-record button. Pressing it reaches `WsClient.send()` (`src/ws.ts:77-81`), which returns silently without sending when the socket isn't `OPEN`. The operator gets no signal at all that the command was dropped.

This release aggravates it: `handleWsDisconnected()` (`src/main.ts:71-75`) sets `wsConnected = false` but never resets `state.trackers`, and the `record_all` preset previously stacked `any_warning` and `not_all_recording` on top but now carries only `record_all_status` (`src/presets.ts:147`). This single callback is the button's entire visual state model.

**Suggested fix:** add a leading branch, e.g. `if (!instance.state.wsConnected || instance.state.trackers.length === 0) return { bgcolor: combineRgb(0, 0, 0), png64: RECORD_ICON_PNG64, pngalignment: 'center:center' }`, so disconnected/unknown is visually distinct from armed-and-idle. Consider also resetting the volatile per-tracker flags (`recording`/`frozen`/`hasWarning`) in `handleWsDisconnected()` before `onStateChanged()`, and having `WsClient.send()` log a `warn` when it drops a command.

### M4: Idle record button is red-on-grey at roughly 1.3:1 contrast

**File:** `src/feedbacks.ts:140-145`, `src/presets.ts:139-146`
**Classification:** 🆕 NEW

The idle state of the new oscillating record button is a `#B50000` red circle on a `#464646` grey background — roughly **1.3:1** contrast, which is near-invisible on a Stream Deck at operating distance. Decoding the base64 confirms `RECORD_ICON_PNG64` is a 72×72 plain red disc on transparent with **no white outline**, contradicting the comment at `src/feedbacks.ts:131`. The v1.3.1 button this replaces was a light-grey play triangle on black — high contrast.

**Suggested fix:** either re-export the record icon with the white ring the comment describes, or set the idle `bgcolor` to `combineRgb(0, 0, 0)` in both the `record_all_status` idle branch and the `record_all` preset base style, so the red disc reads clearly.

---

## 🟢 Low

### L1: any_warning overlay dropped from the record_all preset

**File:** `src/presets.ts:147`
**Classification:** 🆕 NEW

The `record_all` preset lost its `any_warning` overlay (previously a yellow `bgcolor` when any tracker warned). The `any_warning` feedback still exists in the module but is now referenced by no preset, so tracker warnings pushed by RealLine over the WebSocket are invisible on the module's flagship button. A fresh install never surfaces hardware warnings unless the user wires them manually. Deliberate per the commit message, but it's an operator-visible loss of signal shipped without notice.

**Suggested fix:** re-add `{ feedbackId: 'any_warning', options: {}, style: { bgcolor: combineRgb(220, 120, 0) } }` to the preset's `feedbacks` array — it layers on top of `record_all_status` without disturbing the icon — or ship a dedicated "Warning" preset. Either way, note the change in `HELP.md`.

### L2: all_idle reports true when the tracker list is empty

**File:** `src/feedbacks.ts:78`
**Classification:** 🆕 NEW

```ts
callback: () => instance.state.trackers.every((t: TrackerInfo) => !t.recording),
```

`Array.prototype.every` returns `true` on an empty array, so "All Trackers — All Idle" lights up when the module has zero trackers — before the first `state` message lands, and after a disconnect that leaves the list empty. That asserts a hardware state the module has never observed. Its siblings guard correctly: `all_recording` at `src/feedbacks.ts:70` and the `record_all_status` callback at `src/feedbacks.ts:128` both check `trackers.length > 0`.

The empty-array behaviour itself predates this release, but the line was rewritten here (dropping the `previewing` term), so the inconsistency is newly cemented and the fix is one clause.

**Suggested fix:** `callback: () => instance.state.trackers.length > 0 && instance.state.trackers.every((t: TrackerInfo) => !t.recording),`

---
