# Review: breeze-overlay v1.2.0 (follow-up to the v1.1.1 review)

| | |
| --- | --- |
| **Module** | `companion-module-breeze-overlay` |
| **Scope** | `tag` |
| **Version** | v1.2.0 |
| **Release** | Update — last published v1.1.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`11013df`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d) |
| **Previous tag** | v1.1.1 ([diff](https://github.com/bitfocus/companion-module-breeze-overlay/compare/v1.1.1...v1.2.0)) |
| **Prior review** | [v1.1.1 (2026-10-30)](review-breeze-overlay-v1.1.1-20261030-090507.md) |
| **Review date** | 2026-11-09 |

> This review covers the changes from v1.1.1 to v1.2.0: rundowns, outputs, timers, rolls, sport game tables, polls and typed fields for Breeze 0.79, and the move to `@companion-module/base` 2.2.2.
>
> **Follow-up on the v1.1.1 review:** none of that review's findings (M1, M2, L1–L4) was changed in v1.2.0. They sit in code this release didn't touch, so they aren't repeated as findings here; their status is in [📝 Additional Notes](#-additional-notes).
>
> Build and lint: `yarn install --immutable`, `yarn package` and `yarn lint` all pass. The template check reports no differences.

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [L1: Game and poll buttons stop following Breeze after the server is upgraded to 0.79 while Companion runs](#l1-game-and-poll-buttons-stop-following-breeze-after-the-server-is-upgraded-to-079-while-companion-runs)
- [ ] [L2: A blank Timer id or Roll id controls a different timer or roll than the button shows](#l2-a-blank-timer-id-or-roll-id-controls-a-different-timer-or-roll-than-the-button-shows)
- [ ] [L3: A hand-built poll Open or close button can need two presses](#l3-a-hand-built-poll-open-or-close-button-can-need-two-presses)
- [ ] [L4: Game and poll buttons keep their data source polled after they are deleted](#l4-game-and-poll-buttons-keep-their-data-source-polled-after-they-are-deleted)
- [ ] [L5: A tenths or hundredths clock started after a slower one updates only four times a second](#l5-a-tenths-or-hundredths-clock-started-after-a-slower-one-updates-only-four-times-a-second)
- [ ] [N1: A stopwatch read by polling makes Companion re-check every clock feedback up to 20 times a second](#n1-a-stopwatch-read-by-polling-makes-companion-re-check-every-clock-feedback-up-to-20-times-a-second)
- [ ] [N2: Every channel ever watched leaves an internal entry behind](#n2-every-channel-ever-watched-leaves-an-internal-entry-behind)
- [ ] [N3: The DEBUG and PROGRESS setup hints could travel with the preset as notes](#n3-the-debug-and-progress-setup-hints-could-travel-with-the-preset-as-notes)
- [ ] [N4: Game presets skip type checking of their action options](#n4-game-presets-skip-type-checking-of-their-action-options)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Game and poll buttons stop following Breeze after the server is upgraded to 0.79 while Companion runs

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:678-688`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L678-L688), [`src/main.ts:1642-1647`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1642-L1647), [`src/main.ts:1624-1634`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1624-L1634)

**What goes wrong:** Companion connects while the Breeze server is still on 0.78. Breeze is then upgraded to 0.79 and restarted, and Companion keeps running. The module notices the new version: the Rundown, Game and Poll preset sections appear and the rundown variables start working. The game and poll buttons, though, don't follow the server. Buttons placed before the upgrade with the **Game — a column of a sport game table**, **Game column is…**, **Poll — votes, percent, question or total**, **Poll is open** or **Poll option is leading** feedbacks stay blank, and so do the `home_score`, `away_score` and `period_label` variables. Buttons placed after the upgrade show the score once and then freeze. From then on they change only when a Game or Poll button in Companion is pressed, so a score entered from Breeze's own panel never shows. Saving the connection settings brings everything back. A connection that first meets the server on 0.79, or that starts while the server is down, is not affected.

**Why it happens:** The module reads game tables and polls on a timer of their own. That timer is created only at the end of `connect()`, and only when the server is not known to lack both games and polls, which a 0.78 server does lack. When the server comes back with a new version, `applyVersion()` restarts the sockets and the rundown reader and rebuilds the presets, but never starts the rows timer. The only other read happens once, the first time a feedback names a source. The module's own header says a server upgrade "is picked up without touching the connection".

**Fix:** start the rows timer when the version changes. `startRows()` already stops any running timer first, so calling it again is safe.

```ts
// src/main.ts, applyVersion()
this.syncSockets()
this.syncRundowns()
this.startRows()
```

### L2: A blank Timer id or Roll id controls a different timer or roll than the button shows

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:809`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L809), [`src/actions.ts:839`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L839), [`src/actions.ts:862`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L862), [`src/actions.ts:892`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L892), [`src/main.ts:1447`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1447), [`src/main.ts:1487`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1487)

**What goes wrong:** Take a graphic whose only timer is called `clock`. A user builds a button by hand with the **Timer — start, pause, reset, set or add** action and the **Timer — as shown, in seconds, or running** feedback, and leaves **Timer id** blank in both. The feedback picks the graphic's first timer, so the button shows `clock` at 7:42. Pressing the button sends the command for a timer called `main`, which this graphic doesn't have, so the 7:42 on the button doesn't start or stop. Rolls behave the same way: **Roll — play, pause, direction and speed** with a blank Roll id drives `main`, while the Roll feedbacks show the graphic's first roll. Presets always fill in the id, so only hand-built buttons are affected.

**Why it happens:** The action and the feedback give a blank id two different meanings. The action's label says "blank = main", and the callback sends `main`. The timer feedback's label says "blank = the channel's first, main if it has one", and it resolves the id from the timers the graphic declares. The roll feedback simply takes the first roll and never prefers `main`, although [`companion/HELP.md:302-305`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/companion/HELP.md#L302-L305) says blank means "the channel's first (`main` if it has one)" for both the timer and the roll feedbacks.

**Fix:** give a blank id one meaning everywhere. For example, add one helper that resolves a blank id the way the timer feedback does (`main` if the channel has it, else the first one known, else `main`). Use it in the `timer` and `scroll` action callbacks and in `viewTimer` and `viewRoll`, then make the option labels and HELP.md say the same thing.

### L3: A hand-built poll Open or close button can need two presses

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:1089-1091`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L1089-L1091), [`src/main.ts:1624-1634`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1624-L1634)

**What goes wrong:** A user builds a button with **Poll — vote, set a count, open, close or reset** set to **Open / close**, without the **Poll is open** feedback that the preset adds. The poll is already open, from Breeze's panel or from a separate Open button. The first press sends "open", so nothing changes; the second press closes the poll. The module's own OPEN/CLOSE preset is not affected, because its **Poll is open** feedback reads the poll first.

**Why it happens:** The toggle decides from the poll's last-read status. When nothing on the connection has read that poll yet, there is no status, and the code falls back to "open". Asking for the status does start a read, but in the background, after the decision has already been made.

**Fix:** when the module has no status for the poll, read it before choosing open or close, the same way the **Field** toggle reads the field's current value before it sends. With the non-registering getter suggested in [L4](#l4-game-and-poll-buttons-keep-their-data-source-polled-after-they-are-deleted):

```ts
const rows = self.cachedRows(source) ?? (await self.api.sourceRows(project, source, 1))
action = { type: rows[0]?.['status'] === 'open' ? 'close' : 'open' }
```

### L4: Game and poll buttons keep their data source polled after they are deleted

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:1021-1024`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L1021-L1024), [`src/actions.ts:1089-1091`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L1089-L1091), [`src/main.ts:1624-1634`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1624-L1634), [`src/main.ts:1780-1788`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1780-L1788)

**What goes wrong:** A user presses a Game button (for example HOME 3PT on the game table `hockey2`) or a Poll button set to **Open / close**. From then on the module reads that data source once per poll interval (every second by default) for as long as the connection runs, even after the button is deleted or pointed at another source. If the source is deleted in Breeze, every read fails silently. Nothing changes on the buttons; the cost is a steady stream of extra HTTP requests to the Breeze server, one more for each abandoned source. Saving the connection settings stops it.

**Why it happens:** Both actions get the source's last rows through `rowsFor()`, which also registers the button as a reader of that source, and the rows timer reads every registered source. A registration is removed only when Companion reports the action or feedback gone, through its `unsubscribe` callback. The Timer, Roll and Field actions have that callback; the Game and Poll actions don't, so their registration is never removed.

**Fix:** read the cached rows without registering. Add a getter that only returns what was last read, and use it in both actions. Alternatively, give the `game` and `poll` actions the same `subscribe`/`unsubscribe` hooks the Timer action has.

```ts
// src/main.ts
cachedRows(source: string): Array<Record<string, unknown>> | undefined {
	return this.rows.get(source.trim())
}
```

### L5: A tenths or hundredths clock started after a slower one updates only four times a second

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:1557-1563`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1557-L1563)

**What goes wrong:** A whole-second countdown (`m:ss`) or a roll is already running, so the module's clock ticker runs every 250 ms. A stopwatch that shows tenths (`m:ss.S`) or hundredths then starts, or a DEBUG button's graphic starts playing. Those buttons, and the `timer_remaining` variable, refresh every 250 ms instead of every 100 or 50 ms, so the tenths digit jumps two or three steps at a time. It stays that way until every running clock stops and the ticker starts again. The effect is cosmetic: no wrong values and no extra network traffic.

**Why it happens:** Each time the clocks change, the module works out how often it must tick: 50 ms for hundredths, 100 ms for tenths and playheads, 250 ms for whole seconds and rolls. It only creates the ticker when none is running, so a faster rate needed later never replaces the slower ticker that is already running.

**Evidence:**

```ts
// src/main.ts:1557-1563
if (tick === 0) {
	if (this.clockTicker) clearInterval(this.clockTicker)
	this.clockTicker = undefined
} else if (!this.clockTicker) {
	this.clockTicker = setInterval(() => this.onClocksChanged(), tick)
}
```

**Fix:** remember the ticker's period and restart the ticker when the needed period changes. Keep clearing it in `stopClocks()`.

```ts
} else if (!this.clockTicker || tick !== this.clockTickMs) {
	if (this.clockTicker) clearInterval(this.clockTicker)
	this.clockTickMs = tick
	this.clockTicker = setInterval(() => this.onClocksChanged(), tick)
}
```

## 💡 Nice to Have

### N1: A stopwatch read by polling makes Companion re-check every clock feedback up to 20 times a second

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:921`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L921), [`src/main.ts:1400-1405`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1400-L1405), [`src/main.ts:1551-1556`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1551-L1556)

**What goes wrong:** When a graphic's live connection to Breeze is down and the module reads it by polling instead, the module stores that graphic's timers and rolls even when no button shows them, for example on a graphic that only has a PLAY button. If a stopwatch with tenths is running there, Companion is asked to re-run every placed Timer, Roll, Playhead and Playback-colour feedback 10 times a second (20 for hundredths). The stored copy is only refreshed by polling, so this goes on after the live connection is back, until the button is removed or the settings are saved. The buttons look the same; the only cost is CPU load on Companion when a page has many such buttons.

**Why it happens:** The poll stores the clocks of every channel it reads. The live-connection path only reads them for channels that a timer or roll button, or the default channel, needs (`wantsClocks()`). Every stored running clock keeps the ticker going, and each change of the shown time triggers `checkFeedbacks(...CLOCK_FEEDBACKS)`, which re-runs all feedbacks of those types.

**Fix:** in `poll()`, store the clocks only when `this.wantsClocks(key)` is true, the same gate the live-connection path uses.

### N2: Every channel ever watched leaves an internal entry behind

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:967`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L967), [`src/main.ts:1801-1806`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1801-L1806)

**What goes wrong:** Users see no effect. Each channel that was ever watched leaves a small entry (when its state last arrived) in an internal map until the settings are saved. Channel fields filled from a changing variable produce many such entries.

**Why it happens:** Taking a channel's state records the time it arrived, but releasing a channel no longer watched deletes its state, table stamps and clocks, not that time.

**Fix:** add `this.receivedAt.delete(key)` to `release()`, next to `this.clocks.delete(key)`.

### N3: The DEBUG and PROGRESS setup hints could travel with the preset as notes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:132-242`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/presets.ts#L132-L242), [`src/presets.ts:286-395`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/presets.ts#L286-L395)

**What goes wrong:** Nothing breaks. Some setup hints live only in HELP.md: the DEBUG button does nothing when pressed and its ring colours are changed in the **Playback — colour by state** local variable, and the PROGRESS thresholds and colours are changed in the **Roll — colour by time left** local variable. A user who drags the preset onto a button never sees these hints.

**Why it happens:** Base 2.2 lets a preset carry `notes`, which Companion copies to the button when the preset is placed. The new presets don't use it.

**Fix:** add `notes` to the DEBUG and PROGRESS presets (both variants), and to any other preset that needs explaining.

```ts
notes: 'Pressing does nothing. Change the ring colours in the local variable "ringcolor" (Playback — colour by state).',
```

### N4: Game presets skip type checking of their action options

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:845-877`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/presets.ts#L845-L877)

**What goes wrong:** No visible effect today. If an option id in a game preset is misspelled, or the `game` action's options change, the code still compiles, and the preset would place a button whose action has the wrong options.

**Why it happens:** The `add()` helper in the game preset section takes `options: Record<string, unknown>` and ends with `as Presets[string]`. That cast turns off the checking that every other preset in the file gets from the module's typed preset definitions.

**Fix:** type the helper's `options` as `Partial<ActionsSchema['game']['options']>` and `extra` as the preset fields it actually sets (`feedbacks`, `localVariables`), then remove the cast.

## 📝 Additional Notes

- Follow-up on the v1.1.1 review: none of its findings was changed in v1.2.0, and each still applies as written there. They sit in code this release didn't touch, so this tag review doesn't list them again.
- v1.1.1 M1 (connection turns green against a web server that isn't Breeze): any HTTP answer, including the "answered, but not as Breeze" error from [`src/api.ts:614-618`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/api.ts#L614-L618), still counts as reachable at [`src/main.ts:895-903`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L895-L903) and [`src/main.ts:930`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L930).
- v1.1.1 M2 (a blank channel fires on whichever graphic was named first): unchanged at [`src/main.ts:1729-1733`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L1729-L1733), with the same "no default set in the connection config" log at [`src/actions.ts:153`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L153). The new Timer and Roll actions use the same blank-channel fallback ([`src/actions.ts:225`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/actions.ts#L225)).
- v1.1.1 L1 (**Playback state is…** idle lights while the server is unreachable): still `?? 'idle'` at [`src/feedbacks.ts:168`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/feedbacks.ts#L168).
- v1.1.1 L2 (**Camera list is…** frozen misses a failed camera becoming frozen): the change signature still sums failed and frozen cameras at [`src/main.ts:572-574`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L572-L574).
- v1.1.1 L3 (channel variables keep the old project's values after a config save): [`configUpdated()`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/main.ts#L355-L416) now clears the rundown, timer and game variables, but still doesn't stop the countdown ticker, republish the default-channel variables or reset `server_version`.
- v1.1.1 L4 (two camera lists whose ids differ only in punctuation share one CHECK CAMERAS preset): the preset id at [`src/presets.ts:643`](https://github.com/bitfocus/companion-module-breeze-overlay/blob/11013dffc4edc4bd060202893cca60ac2673162d/src/presets.ts#L643) still has no name hash.
