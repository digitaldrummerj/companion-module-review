# Review: companion-module-livelogix-cadence v1.4.1 (follow-up to v1.4.0)

| | |
| --- | --- |
| **Module** | [`companion-module-livelogix-cadence`](https://github.com/bitfocus/companion-module-livelogix-cadence) |
| **Scope** | `tag` |
| **Version** | `v1.4.1` |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`406873c`](https://github.com/bitfocus/companion-module-livelogix-cadence/tree/406873c4182f47b38daed24d409898553dcb0621) |
| **Prior review** | [v1.4.0 (2026-10-30)](review-livelogix-cadence-v1.4.0-20261030-090507.md) — every finding fixed except NR1, which is carried forward |
| **Review date** | 2026-10-31 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Cadence's show editor lets the operator delete, insert or reorder countdown timers, which changes their position in the `clocks` list of `/api/(show/)state` while their ids stay the same | `variables.js` and `presets.js` number timers by their position among the countdown clocks, and `shapeSignature()` treats id order as part of the shape. The Cadence app itself was not available to confirm how it behaves | [M1](#m1-timer-preset-buttons-show-one-timers-name-and-time-but-control-a-different-timer-after-timers-are-deleted-or-reordered) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Timer preset buttons show one timer's name and time but control a different timer after timers are deleted or reordered](#m1-timer-preset-buttons-show-one-timers-name-and-time-but-control-a-different-timer-after-timers-are-deleted-or-reordered)
- [ ] [L1: Connection status can stay on Unknown error after Cadence is answering normally again](#l1-connection-status-can-stay-on-unknown-error-after-cadence-is-answering-normally-again)
- [ ] [NR1: Plan the move to the v2 module API](#nr1-plan-the-move-to-the-v2-module-api)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Timer preset buttons show one timer's name and time but control a different timer after timers are deleted or reordered

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:40-116`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/406873c4182f47b38daed24d409898553dcb0621/src/presets.js#L40-L116)

**What goes wrong:** An operator drags the "Start/Pause + live time (state colours)" preset from the "Timer 1: Speaker A" category onto a button. The button reads "Speaker A / 04:59", and pressing it starts Speaker A. Later they delete or reorder timers in Cadence, so "Speaker B" becomes the first countdown timer. The same button now reads "Speaker B / 10:00", but pressing it still starts or pauses Speaker A, and its green, amber and red colours still follow Speaker A. During a live show the button shows one timer and controls another. The "Live time in the on-screen colour", "Big digits" (hours, minutes, seconds), "Reset" and "Undo last edit" presets have the same mismatch. Buttons placed after the change are correct until the next reorder.

**Why it happens:** The preset's action and feedbacks store the timer's fixed id. The button text uses position-based variables (`timer_1_name`, `timer_1_time`, `timer_1_hh`, `timer_1_undo`, …), which the module fills with whichever countdown timer is currently in that position. Once the timer list changes, a placed button keeps its old id while its text follows the new timer in that position.

**Evidence:**

```js
// src/presets.js:43-48
const pick = { pick: c.id, overrideId: '' }
presets[`timer_${n}_toggle`] = button(
	cat,
	'Start/Pause + live time (state colours)',
	`${v(`timer_${n}_name`)}\\n${v(`timer_${n}_time`)}`,
	[act('timer_transport', { ...pick, action: 'toggle' })],
```

**Fix:** build the timer presets' button text from the id-based variables that already exist for every clock (`clock_<id>_name`, `_time`, `_hh`, `_mm`, `_ss`, `_sign`), the way the stopwatch "MARK" preset already uses `stopwatch_<id>_last`. Add an `undo` entry to the `clock` variables so the "Undo last edit" preset can use `clock_<id>_undo` too. Keep the `timer_N_*` variables for users who deliberately want position-based buttons.

```js
`${v(`clock_${key(c.id)}_name`)}\\n${v(`clock_${key(c.id)}_time`)}`
```

## 🟢 Low

### L1: Connection status can stay on Unknown error after Cadence is answering normally again

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:96-102`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/406873c4182f47b38daed24d409898553dcb0621/src/main.js#L96-L102), [`src/helpers.js:168-175`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/406873c4182f47b38daed24d409898553dcb0621/src/helpers.js#L168-L175)

**What goes wrong:** This only happens if the module's own code fails while handling a Cadence reply, for example if rebuilding the dropdowns fails on an unusual clock list. The connection then shows the red "Couldn't read Cadence's reply (…)" Unknown error status. If the next replies are handled fine, timers and buttons update again, but the status on the Connections page stays on the error until Cadence becomes unreachable and comes back. The user sees a red connection that is actually working. It can't happen in normal use without a module bug, so the effect is small.

**Why it happens:** When a poll succeeds, the module marks itself connected before it processes the reply, and reports "OK" only when it wasn't connected before. If processing the reply throws, the error handler sets the Unknown error status but leaves the module marked as connected, so every later successful poll skips the "OK" update. The new shape signature is also stored before the definitions are rebuilt, so a failed rebuild isn't retried.

**Fix:** in the error handler, also mark the connection as not connected and clear the stored shape signature, so the next good poll rebuilds the definitions and reports "OK" again.

```js
} catch (e) {
	this.connected = false
	this.lastShapeSig = ''
	this.log('error', `Couldn't read Cadence's reply: ${e.stack || e.message}`)
	this.updateStatus(InstanceStatus.UnknownError, `Couldn't read Cadence's reply (${e.message})`)
}
```

## 🔮 Next Release

### NR1: Plan the move to the v2 module API

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-livelogix-cadence/blob/406873c4182f47b38daed24d409898553dcb0621/package.json)

**What goes wrong:** Nothing breaks today: the module runs on Companion 4.2 and later with API 1.14. Staying on v1 means users can't use expressions in option fields, and the module can't adopt v2 features such as action results, abort signals and layered presets. This was NR1 in the v1.4.0 review and is carried forward.

**Fix:** in a later release, migrate to `@companion-module/base` v2 (2.0 for Companion 4.3+, or 2.1 for Companion 5.0+) following the v1-to-v2 migration guide, and re-check the module against the v2 API compliance checklist when you do.

## 📝 Additional Notes

- First release: the module has never been published, so there is no previous tag to diff against. The whole module at v1.4.1 was reviewed, and every finding is classified 🆕 NEW.
- Follow-up to the [v1.4.0 review](review-livelogix-cadence-v1.4.0-20261030-090507.md): every finding from that review is fixed in v1.4.1, apart from NR1 (carried forward above). Fixed: C1 (source moved into `src/`, entry points updated), H1 (template workflow restored, including the job guard), M1 (issue forms added), M2 (Planning Center link now part of the schedule signature), M3 (`parseVariablesInString` calls removed), L1 (follow-up commands skipped when the first one fails), L2 (network, non-Cadence and internal errors reported separately), L3 (`destroyed` flag, abort timer cleared in `finally`, in-flight request aborted in `destroy()`), L4 (only changed variables sent, feedbacks re-checked only when the snapshot changes), L5 (negative plain-second durations rejected), L6 (`isVisibleExpression` used) and N1 (offline blanking limited to live-time variables).
