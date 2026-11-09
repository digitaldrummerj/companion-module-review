# Review: alto-tmd16 v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-alto-tmd16`](https://github.com/bitfocus/companion-module-alto-tmd16) |
| **Scope** | `tag` |
| **Version** | v1.0.0 ([`590ae15`](https://github.com/bitfocus/companion-module-alto-tmd16/commit/590ae150e23f9992599922ef0da2544957672dd4)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Fader level feedback does not light after Set fader level for many dB values](#m1-fader-level-feedback-does-not-light-after-set-fader-level-for-many-db-values)
- [ ] [M2: Channel dropdowns in expression mode select the wrong channel](#m2-channel-dropdowns-in-expression-mode-select-the-wrong-channel)
- [ ] [L1: Mute, fader and preset buttons show a change while the mixer is offline](#l1-mute-fader-and-preset-buttons-show-a-change-while-the-mixer-is-offline)
- [ ] [L2: Read-back and preset refresh timers are not cancelled when the connection is closed](#l2-read-back-and-preset-refresh-timers-are-not-cancelled-when-the-connection-is-closed)
- [ ] [L3: Mute action and fader comparison choices can be switched to expression mode](#l3-mute-action-and-fader-comparison-choices-can-be-switched-to-expression-mode)
- [ ] [N1: The comment explaining the packet pacing sits on the wrong method](#n1-the-comment-explaining-the-packet-pacing-sits-on-the-wrong-method)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Fader level feedback does not light after Set fader level for many dB values

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:52-64`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/feedbacks.ts#L52-L64), [`src/protocol.ts:202-214`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/protocol.ts#L202-L214)

**What goes wrong:** A user builds a button with the action "Set fader level" (Channel: Ch 1, Level (dB): -10) and adds the feedback "Fader level compared to value" (Channel: Ch 1, Fader is: Equal to (within 0.05 dB), Level (dB): -10). They press the button and the fader moves, but the feedback never lights. The mixer is now at -10.1 dB, which is 0.1 dB away from -10. With "At or above" -10 the feedback also stays off, because -10.1 is below -10. The same happens for -12 (the mixer goes to -11.9 dB), -15 (-14.9), -18 (-17.9), -25 (-25.2), +3 (+2.8) and many more: 646 of the 900 levels you can type in 0.1 dB steps never match "Equal to" after "Set fader level" with the same value. -80 is a special case. The action's Level field shows -80 as -inf and pulls the fader all the way down, but the feedback's Level field has no -inf and compares against -80 dB, so "Equal to" -80 never lights for a fader that is all the way down.

**Why it happens:** The TMD16 has 256 fader positions in uneven steps (0.1 to 0.7 dB apart, and 3.0 dB is skipped). The action rounds the typed dB value to the nearest position in that table (`dbToGainValue`). The feedback does not: it converts the mixer's position back to dB and compares that with the exact number typed in, so the two disagree whenever the typed value is not in the table.

**Evidence:**

```ts
// src/feedbacks.ts:52-64
callback: ({ options }) => {
	const raw = self.gains.get(options.channel)
	if (raw === undefined) return false
	const db = gainValueToDb(raw)
	switch (options.comparison) {
		case 'gte':
			return db >= options.level
		case 'lte':
			return db <= options.level
		default:
			return Math.abs(db - options.level) < 0.05
	}
},
```

**Fix:** compare fader positions instead of dB values, the same way the action works. The gain table only goes up, so a higher position always means a higher level:

```ts
const target = dbToGainValue(options.level)
switch (options.comparison) {
	case 'gte':
		return raw >= target
	case 'lte':
		return raw <= target
	default:
		return raw === target
}
```

Also add `showMinAsNegativeInfinity: true` to the feedback's Level (dB) option, so -80 shows as -inf as it does in the action. `dbToGainValue(-80)` already returns 0, so "Equal to" -inf then matches a fader that is all the way down.

### M2: Channel dropdowns in expression mode select the wrong channel

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:13-14`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/actions.ts#L13-L14), [`src/feedbacks.ts:12-13`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/feedbacks.ts#L12-L13)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** In Companion 5 any dropdown can be switched to expression mode, where the user types the value instead of picking it. A user who switches the Channel option of "Mute / unmute channel" to expression mode and enters `3` (or `$(local:channel)` holding 3) to mute "Ch 3" actually mutes "Ch 4". Entering `9` controls "Ch 11/12", and `13` mutes "SUB 1/2". This affects the Channel option of "Set fader level", "Adjust fader level", "Mute / unmute channel", "Channel is muted" and "Fader level compared to value". Nothing in the UI or in HELP.md shows the numbering. Users who pick the channel from the dropdown are not affected.

**Why it happens:** Each dropdown choice has a label the user sees and an id that Companion stores, and an expression has to produce that id. The Channel choices use the mixer's internal channel numbers as ids, and those start at 0 (0 = Ch 1, 8 = Ch 9/10, 12 = Main L/R, 16 = Aux 2). The channel list already has readable keys (`ch1`, `ch9_10`, `main`, `sub1_2`, `aux1`, `fx`) that would make sense to type.

**Evidence:**

```ts
// src/actions.ts:13-14
const faderChoices: DropdownChoice<number>[] = FADER_CHANNELS.map((c) => ({ id: c.id, label: c.label }))
const channelChoices: DropdownChoice<number>[] = CHANNELS.map((c) => ({ id: c.id, label: c.label }))
```

**Fix:** use the readable key as the choice id and look up the channel number in the callback, ignoring unknown keys:

```ts
const channelChoices: DropdownChoice<string>[] = CHANNELS.map((c) => ({ id: c.key, label: c.label }))

// in each callback
const channel = CHANNELS.find((c) => c.key === options.channel)?.id
if (channel === undefined) return
```

Change the Channel option types in `ActionsSchema` and `FeedbacksSchema` to `string` (default `'ch1'`), and pass `ch.key` instead of `ch.id` in the presets ([`src/presets.ts:21`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/presets.ts#L21), [`src/presets.ts:28`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/presets.ts#L28), [`src/presets.ts:53`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/presets.ts#L53)). Do this in this first release: once v1.0.0 is published, changing the ids needs an upgrade script for every saved button.

## 🟢 Low

### L1: Mute, fader and preset buttons show a change while the mixer is offline

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:188-189`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/main.ts#L188-L189), [`src/main.ts:314-330`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/main.ts#L314-L330)

**What goes wrong:** When the TMD16 can't be reached (network cable out, wrong IP address, other subnet), the connection shows Disconnected or an error, but the buttons still look like they work. Pressing a "Mute / unmute channel" button (Ch 1, Mute) turns the "Channel is muted" feedback red and sets `$(alto-tmd16:mute_ch1)` to `muted`, while nothing was sent and Ch 1 is still live. Each "Adjust fader level" press (+1 dB) raises `$(alto-tmd16:fader_ch1)` by 1 dB while the real fader doesn't move, and "Recall preset" (User Preset 03) lights "Preset is current" for User 3. The wrong values stay until the connection comes back and the module reads the mixer again. During first setup with a wrong IP address, this makes the module look like it is working.

**Why it happens:** The send helper (`#write`) quietly does nothing when there is no connection. The actions don't know that, so they always update the feedbacks and variables straight away, expecting the read-back about 100 ms later to correct them. Because nothing was sent, no read-back is scheduled either.

**Evidence:**

```ts
// src/main.ts:188-189
#write(key: string, set: Buffer, get: Buffer): void {
	if (!this.#tcp?.isConnected) return
// src/main.ts:319-323
setMute(channel: number, state: 'mute' | 'unmute' | 'toggle'): void {
	const muted = state === 'toggle' ? !this.mutes.get(channel) : state === 'mute'
	this.#write(`m${channel}`, buildPacket(Cmd.SetMute, channel, muted ? 1 : 0), buildPacket(Cmd.GetMute, channel))
	this.#updateMute(channel, muted)
}
```

**Fix:** have `#write` return whether it sent anything, and only update the shown state when it did:

```ts
if (this.#write(`m${channel}`, set, get)) this.#updateMute(channel, muted)
```

Do the same in `#writeFader` and `recallPreset`, and optionally log "Not connected, command not sent" so the user can see why the press did nothing.

### L2: Read-back and preset refresh timers are not cancelled when the connection is closed

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:195-202`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/main.ts#L195-L202), [`src/main.ts:328`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/main.ts#L328), [`src/main.ts:110-123`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/main.ts#L110-L123)

**What goes wrong:** Nothing visible. For about 100 ms after any fader, mute or preset press, and 300 ms after "Recall preset", a timer can still run after the connection is disabled or its settings are saved. Each timer checks for a live connection first, so it does nothing, or after a settings save it sends one harmless read request on the new connection. It's reported because `destroy()` should stop every timer the module starts.

**Why it happens:** `#write()` and `recallPreset()` start these timers with `setTimeout` but don't keep the handle, so `#disconnect()` (called from `destroy()` and when the settings change) cannot cancel them. `#disconnect()` does cancel the poll, meter and send timers.

**Fix:** keep the handles in a set, remove each one when it fires, and clear them all in `#disconnect()`:

```ts
#oneShotTimers = new Set<NodeJS.Timeout>()

// when starting one
const t = setTimeout(() => {
	this.#oneShotTimers.delete(t)
	// ...
}, READBACK_DELAY_MS)
this.#oneShotTimers.add(t)

// in #disconnect()
for (const t of this.#oneShotTimers) clearTimeout(t)
this.#oneShotTimers.clear()
```

### L3: Mute action and fader comparison choices can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:63-73`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/actions.ts#L63-L73), [`src/feedbacks.ts:31-40`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/feedbacks.ts#L31-L40)

**What goes wrong:** The Action dropdown of "Mute / unmute channel" (Mute / Unmute / Toggle) and the "Fader is" dropdown of "Fader level compared to value" (At or above / At or below / Equal to) show the expression toggle. A user who switches one of them to expression mode has to type the internal id (`toggle`, `gte`). Any other value is not one of the choices, so the action or feedback doesn't work and nothing tells the user why. There is little reason to drive these choices from an expression, so the toggle only adds a way to break the button.

**Why it happens:** These options don't set `disableAutoExpression: true`, which hides the expression toggle for one option. Adding it later to an option users have already saved breaks their saved expressions, so the first release is the time to add it.

**Fix:** add `disableAutoExpression: true` to the `state` dropdown of "Mute / unmute channel" and to the `comparison` dropdown of "Fader level compared to value".

## 💡 Nice to Have

### N1: The comment explaining the packet pacing sits on the wrong method

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:168-177`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/main.ts#L168-L177)

**What goes wrong:** Nothing visible. The comment that explains why packets are sent one at a time with a short pause ("The device only answers the first message of a TCP segment…") sits above `#trace()` instead of `#send()` or `#drainQueue()`, so the most important rule of the protocol is easy to miss when someone changes the send code later.

**Why it happens:** Two doc comments are stacked above `#trace()`; the first one belongs to `#send()`.

**Fix:** move the first comment ([`src/main.ts:168-171`](https://github.com/bitfocus/companion-module-alto-tmd16/blob/590ae150e23f9992599922ef0da2544957672dd4/src/main.ts#L168-L171)) down to `#send()` or `#drainQueue()`, and mention next to it that `TCPHelper` already calls `setNoDelay(true)`, so each write leaves as its own TCP segment.

## 📝 Additional Notes

- First release: v1.0.0 has never been published, so there is no earlier version to diff against. This review covers the whole module, and every finding is 🆕 NEW.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | In expression mode, Companion passes the expression's result to the module as the option value, so a Channel expression that gives 3 selects the choice whose id is the number 3 ("Ch 4") | companion-v2-api-compliance `references/v2.0.md` and the `disableAutoExpression` / `allowInvalidValues` typings in `@companion-module/base` 2.1.3; not live-tested in Companion | [M2](#m2-channel-dropdowns-in-expression-mode-select-the-wrong-channel) |
