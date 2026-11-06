# Review: companion-module-twoloox-pandorasbox v3.1.6 (follow-up to the v3.1.4 review)

| | |
| --- | --- |
| **Module** | companion-module-twoloox-pandorasbox |
| **Scope** | `tag` (`v3.0.1..v3.1.6`) |
| **Version** | v3.1.6 |
| **Release** | Update — last published v3.0.1 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Follow-up to** | [v3.1.4 review](review-twoloox-pandorasbox-v3.1.4-20261030-192328.md): all 16 findings fixed |
| **Review commit** | [`1ec73b4`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/tree/1ec73b407eafd5a50165ce002fa9193571ee8f59) |
| **Date** | 2026-11-06 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the user clicks Save in the connection settings, Companion calls `configUpdated()` on the instance that is already running, without calling `destroy()` or restarting the module process first. So the earlier connection attempt and its 3-second timeout are still pending in the same process. | The standard Companion v2 lifecycle; the module's own comment at [`src/index.ts:218-219`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/src/index.ts#L218-L219) relies on the same behaviour. Not checked in the Companion host source. | [M1](#m1-saving-corrected-settings-during-a-retry-can-switch-the-connection-back-to-the-old-settings) |
| A2 | Companion's per-variable change detection makes repeated identical `setVariableValues` calls cheap: the cost is IPC traffic only, not button re-renders. | General knowledge of the Companion host (the same assumption, A2, was recorded in the v3.1.4 review); not checked in its source. | [N1](#n1-countdown-variables-are-re-sent-to-companion-on-every-poll-even-when-nothing-changed) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Saving corrected settings during a retry can switch the connection back to the old settings](#m1-saving-corrected-settings-during-a-retry-can-switch-the-connection-back-to-the-old-settings)
- [ ] [L1: Set Playhead jumps to a wrong time for inputs like 10.5 or 1m30s instead of ignoring them](#l1-set-playhead-jumps-to-a-wrong-time-for-inputs-like-105-or-1m30s-instead-of-ignoring-them)
- [ ] [N1: Countdown variables are re-sent to Companion on every poll even when nothing changed](#n1-countdown-variables-are-re-sent-to-companion-on-every-poll-even-when-nothing-changed)

### Notes

- **English:** please keep code comments and commit messages in English going forward. One comment still has a German word: "hakt" at [`src/variables.ts:182`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/src/variables.ts#L182) (the English "stutters" follows it). Not blocking for this release.
- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Saving corrected settings during a retry can switch the connection back to the old settings

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:252-258`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/src/index.ts#L252-L258), [`src/index.ts:267-280`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/src/index.ts#L267-L280), [`src/index.ts:127-134`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/src/index.ts#L127-L134)

**What goes wrong:** A user enters the wrong Domain, for example 0 when Pandoras Box uses 1. The connection then cycles about every 13 seconds: "Connecting", up to 3 seconds of waiting for a reply, then "Connection failure: No response from Pandoras Box (check Domain)", then 10 seconds until the next try. The user opens the connection settings, sets Domain to 1 and clicks Save. If the save lands inside one of those 3-second waits (roughly one save in four), the connection turns green and the sequences load. Within 3 seconds, though, the status goes back to "Connection failure ... (check Domain)". About 10 seconds after that, the module drops the working connection and starts retrying with the old Domain 0, and it keeps doing so while the settings page shows Domain 1. Buttons, variables and feedbacks stop working until the user saves the settings again or disables and re-enables the connection. Saving any other field in that window has the same effect: a new Target IP is swapped back, and ticking "Log protocol traffic (debug)" to investigate the error is silently undone. v3.0.1 had no automatic retry, so it could not swap the settings back like this. The retry logic was already in v3.1.4; the previous review didn't raise it.

**Why it happens:** Each connection attempt keeps its own copy of the settings and waits up to 3 seconds for the first Pandoras Box reply. When the settings are saved, `configUpdated()` cancels the pending "retry in 10 seconds" timer and starts a new attempt. It cannot cancel an earlier attempt that is still in its 3-second wait, and that wait's timer is never cleared. When the old wait runs out, its error handler still sets the failure status and schedules a retry with the old settings. Only the line that clears the current client checks whether the attempt is still the current one. Ten seconds later that retry disconnects the new, working client and reconnects with the old settings, and each failure then schedules another retry with the same old settings. The same unguarded path also schedules a retry if the connection is disabled during the 3-second wait.

**Evidence:**

```ts
// src/index.ts:252-258
const timeoutMs = 3000
await Promise.race([
	protocolAlive,
	new Promise<void>((_, reject) =>
		setTimeout(() => reject(new Error('No response from Pandoras Box (check Domain)')), timeoutMs),
	),
])
// src/index.ts:267-280
} catch (e: any) {
	const msg = e?.message ?? 'Connect failed'
	this.log('error', msg)
	...
	this.updateStatus(InstanceStatus.ConnectionFailure, msg)
	...
	if (this.client === client) {
		this.client = undefined
	}
	client.disconnect()
	this.scheduleReconnect(config)
}
```

**Fix:** make a superseded attempt stop without side effects, the way `onSequencesUpdated` already does. Return early from the error handler when the attempt is no longer the current client, check the same after `await client.connect()` and after the 3-second race, and clear the 3-second timer once the race settles. Because `destroy()` clears `this.client`, the same check also stops a retry from being scheduled after the connection is disabled.

```ts
let timeoutHandle: NodeJS.Timeout | undefined
try {
	await client.connect()
	if (this.client !== client) return
	// ...
	await Promise.race([
		protocolAlive,
		new Promise<void>((_, reject) => {
			timeoutHandle = setTimeout(() => reject(new Error('No response from Pandoras Box (check Domain)')), timeoutMs)
		}),
	])
	if (this.client !== client) return
	this.updateStatus(InstanceStatus.Ok)
	// ...
} catch (e: any) {
	if (this.client !== client) {
		// A newer connect (or destroy) replaced this attempt: clean up quietly.
		client.disconnect()
		return
	}
	const msg = e?.message ?? 'Connect failed'
	this.log('error', msg)
	this.updateStatus(InstanceStatus.ConnectionFailure, msg)
	this.client = undefined
	client.disconnect()
	this.scheduleReconnect(config)
} finally {
	clearTimeout(timeoutHandle)
}
```

## 🟢 Low

### L1: Set Playhead jumps to a wrong time for inputs like 10.5 or 1m30s instead of ignoring them

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:108-118`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/src/actions.ts#L108-L118), [`companion/HELP.md:48`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/companion/HELP.md#L48)

**What goes wrong:** In the "Set Playhead" action (Mode: Absolute), a user types `10.5` into the Time field, meaning 10.5 seconds. The module sends 00:00:01:05 (1 second, 5 frames). `1m30s` goes to 00:00:01:30, and `5 sec` goes to frame 5. The same happens when a variable or expression in the field returns text like this, and in Relative mode (`+1.5` moves 15 frames). HELP.md says "Invalid input is ignored, nothing is sent", so the user expects no jump; instead the sequence jumps to an unexpected position, which is risky during a live show. Times written with colons (`00:01:30:15`) are strictly checked and are not affected. The action is new since v3.0.1; this parsing was already in v3.1.4.

**Why it happens:** For input with colons, the parser rejects any group that is not plain digits. For input without colons, it deletes every non-digit character instead and reads the remaining digits in pairs from the right, so stray characters are silently dropped instead of making the input invalid. Running the same parsing logic in Node gives `10.5` → 1 s 5 f and `1m30s` → 1 s 30 f.

**Fix:** in the no-colon branch, reject anything besides digits after the optional sign, the same way the colon branch does, and parse the digits directly. If `.` should be accepted as a separator, handle it explicitly rather than stripping it.

```ts
} else {
	if (!/^\d+$/.test(body)) return undefined
	const digits = body
	// ...
}
```

## 💡 Nice to Have

### N1: Countdown variables are re-sent to Companion on every poll even when nothing changed

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:193-202`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/1ec73b407eafd5a50165ce002fa9193571ee8f59/src/index.ts#L193-L202)

**What goes wrong:** No visible effect for the user. While a sequence is stopped or paused, its countdown to the next cue stays the same (for example 00:00:12:05), but every poll reply (5 per second while stopped, 30 while playing) still sends the 5 countdown variables (`sequence_<id>_countdown*`) to Companion. With 40 stopped sequences that is about 200 redundant updates per second. The v3.1.4 review's N1 fix now skips unchanged values in the time handler; the countdown handler right below it has the same pattern and was not covered by that finding.

**Why it happens:** The countdown handler always stores the new value and sends the variables. It only uses the previous value to decide whether to re-check the "Remaining cue under threshold" feedback. The time, status, cue-info and opacity handlers already return early when nothing changed.

**Fix:** return early at the top of the countdown handler when the previous countdown has the same hours, minutes, seconds and frames, as the time handler does.

```ts
onSequenceCountdown: (seqId, h, m, s, f) => {
	const previous = this.sequenceCountdowns.get(seqId)
	if (previous && previous.h === h && previous.m === m && previous.s === s && previous.f === f) return
	// ...
},
```

## 📝 Additional Notes

- **Prior review (v3.1.4):** all 16 findings are fixed in v3.1.6, and none are carried forward: C1 (Node 26 everywhere), C2–C5 (`package`, `postinstall` and `format` scripts; `yarn package` now builds), C6 (`LICENSE`), C7 (anchored `.gitignore` entries), C8 (`.husky/pre-commit`), C9 (`.prettierignore`), M1–M2 (`node.yaml` and `release.yaml` workflows), L1 (new upgrade script gives old "Remaining cue under threshold" feedbacks sequence 1), L2 (`disableAutoExpression` on the fixed-choice dropdowns), N1 (unchanged timecode no longer re-sent), N2 (typed action and feedback options) and N3 (manifest version 3.1.6, not a prerelease). The template check, `yarn install --immutable`, `yarn package` and `yarn lint` all pass.
- **The findings above are not regressions:** M1, L1 and N1 are all on code that was already in v3.1.4 and that the 3.1.6 changes did not touch. The previous review missed them.
