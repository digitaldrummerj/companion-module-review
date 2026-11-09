# Module Review: companion-module-PosiStageNet-protocol v1.3.1 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-PosiStageNet-protocol`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol) |
| **Scope** | `tag` (v1.2.0..v1.3.1) |
| **Version** | v1.3.1 ([`ec0f487`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/commit/ec0f487f299a05fed8ab4deb98548d7ef858c2c1)) |
| **Release** | Update — last published v1.2.0 |
| **API** | 1 (base 1.11.3, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Follow-up to** | [v1.3.0 review](review-PosiStageNet-protocol-v1.3.0-20261106-181511.md) (changes required: C1-C2, H1). All 9 of its findings are fixed in v1.3.1; see [📝 Additional Notes](#-additional-notes) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: With the default 10 ms timeout, tracker validity blanks out between every PSN packet](#m1-with-the-default-10-ms-timeout-tracker-validity-blanks-out-between-every-psn-packet)
- [ ] [N1: Bind to specific IP tooltip still names a different default than the new Any interface entry](#n1-bind-to-specific-ip-tooltip-still-names-a-different-default-than-the-new-any-interface-entry)
- [ ] [N2: Tracker Moving feedback description does not say which value it compares with 0](#n2-tracker-moving-feedback-description-does-not-say-which-value-it-compares-with-0)
- [ ] [N3: Unused `lastSeen` timestamp left behind after the stale-check change](#n3-unused-lastseen-timestamp-left-behind-after-the-stale-check-change)
- [ ] [NR1: Upgrade to base 1.14 and replace isVisible functions with isVisibleExpression](#nr1-upgrade-to-base-114-and-replace-isvisible-functions-with-isvisibleexpression)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: With the default 10 ms timeout, tracker validity blanks out between every PSN packet

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:93-104`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/config.ts#L93-L104), [`src/main.ts:476-487`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/main.ts#L476-L487), [`companion/HELP.md:67`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/companion/HELP.md#L67)

**What goes wrong:** A user turns on Advanced Options, ticks "Clear Validity when tracker data is stale" and leaves "Tracker data timeout (ms)" at its default of 10. The PSN source keeps sending normally at 60 Hz, one packet about every 16.7 ms. Even so, every tracker's validity variable (for example `$(psn:tracker_1_validity)` on a connection named `psn`) is cleared to empty about 10 ms after each packet and set back (for example to `1.00`) when the next packet arrives. Buttons and triggers that use it flip between the value and blank about 60 times a second, and the validity is blank about 40% of the time although the tracker is live. The extra refreshes also multiply the module's work: with 5 trackers, a reviewer simulation of the module's timer logic counted about 349 full variable updates per second instead of about 57, and 290 of them had a blank validity. With a 200 ms timeout the same simulation sent about 57 updates and never blanked the value. The module's own help page recommends 100–500 ms for a 60 Hz source, so the default contradicts the documentation. Users who leave the option off, or set a timeout above their source's packet interval, are not affected.

**Why it happens:** Each data packet restarts a per-tracker timer set to the configured timeout. When the timer runs out, the module marks that tracker stale and pushes all tracker variables again, which writes an empty validity. Both the settings field default and the code fallback are 10 ms, shorter than the gap between two packets from a 60 Hz source, so the timer runs out between every pair of packets. The v1.3.1 fix for the prior review's M1 made this timer reliable, so at 10 ms it now clears the value after every packet. Each tracker has its own timer and each one triggers a full variable push plus a feedback re-check, so N trackers cause N extra full pushes per packet.

**Evidence:**

```ts
// src/config.ts:93-104
		{
			type: 'number',
			id: 'trackerTimeout',
			label: 'Tracker data timeout (ms)',
			width: 6,
			default: 10,
			min: 1,
			max: 60000,
			tooltip:
				"How long (in milliseconds) without a data packet before a tracker's validity variable is considered stale and cleared.",
			isVisible: (options) => options.advancedOptions === true && options.useTrackerTimeout === true,
		},
// src/main.ts:476-487
		if (this.config.useTrackerTimeout) {
			const existing = this.trackerTimeoutTimers.get(tracker.id)
			if (existing) clearTimeout(existing)
			const deadline = this.config.trackerTimeout ?? 10
			this.trackerTimeoutTimers.set(
				tracker.id,
				setTimeout(() => {
					this.trackerTimeoutTimers.delete(tracker.id)
					tracker.stale = true
					this.updateTrackerVariables()
				}, deadline),
			)
```

```markdown
<!-- companion/HELP.md:67 -->
- **Tracker data timeout (ms)**: how long to wait without data before a tracker is considered stale. Choose a value comfortably above your PSN source's packet interval (e.g. 100–500 ms for a 60 Hz source).
```

**Confirm by:** open [`src/config.ts:98`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/config.ts#L98) (`default: 10`) and [`companion/HELP.md:67`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/companion/HELP.md#L67) (recommends 100–500 ms for a 60 Hz source), then [`src/main.ts:476-487`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/main.ts#L476-L487), where each tracker's timer marks it stale and pushes all variables when it fires.

**Fix:** use a default inside the help page's own recommended range, and match the code fallback to it. Consider raising the minimum so the timeout can't be set below one 60 Hz packet interval.

```ts
// src/config.ts
default: 500,
min: 20,
// src/main.ts:479
const deadline = this.config.trackerTimeout ?? 500
```

Optionally, coalesce the stale refreshes so timers that run out together cause one variable push instead of one per tracker: set a flag and schedule a single `setImmediate` refresh, or use one shared sweep timer instead of one timer per tracker. Clear it in `closeConnection()` like the existing timers.

## 💡 Nice to Have

### N1: Bind to specific IP tooltip still names a different default than the new Any interface entry

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:59-70`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/config.ts#L59-L70)

**What goes wrong:** With Advanced Options on, the "Bind to specific IP" dropdown now defaults to "Any interface (OS default)" (`0.0.0.0`), and the new help section describes it the same way. Hovering over the field still shows "the IP address of the network interface to bind to. default is $(internal:bind_ip)". That suggests the module uses Companion's own bind IP by default, which it does not, and the user may see the literal `$(internal:bind_ip)` text. The setting also only picks the interface that joins the multicast group; it does not bind the socket.

**Why it happens:** This release turned the field into a dropdown and added the "Any interface (OS default)" choice and help text, but kept the tooltip from the old text field.

**Fix:** update the tooltip to match what the field does.

```ts
tooltip: 'Network interface used to join the multicast group. Default: Any interface (OS default, 0.0.0.0). Custom values must be IP addresses.',
```

### N2: Tracker Moving feedback description does not say which value it compares with 0

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:42`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/feedbacks.ts#L42)

**What goes wrong:** In the feedback picker, "Tracker Moving" shows "Changes the button's style when the value is below or above 0." A user can't tell which value that means, or which colours apply. The feedback actually reads the value picked with the Type and Axis options (for example Speed, y-axis reads `tracker_1_speed_y`), and uses the Up colours above 0, the Down colours below 0 and the Default colours at 0. No functional effect.

**Why it happens:** This release added a generic description that doesn't name the Type and Axis options or the three colour states.

**Fix:** make the description specific.

```ts
description: 'Colours the button by the sign of the chosen tracker value (Type and Axis): Up colours above 0, Down colours below 0, Default colours at 0.',
```

### N3: Unused `lastSeen` timestamp left behind after the stale-check change

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:41`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/main.ts#L41), [`src/main.ts:473`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/main.ts#L473)

**What goes wrong:** Users see no difference. The time of the last data packet is still recorded for every tracker on every packet, but nothing reads it any more, so the code suggests a time-based stale check that no longer exists.

**Why it happens:** The fix commit `e96242d` replaced the "time since last packet" comparison with the new `stale` flag, but left the `lastSeen` field and the line that sets it.

**Fix:** remove `lastSeen?: number` from `TrackerData` and the `tracker.lastSeen = Date.now()` line. If you switch to a single shared sweep timer (see [M1](#m1-with-the-default-10-ms-timeout-tracker-validity-blanks-out-between-every-psn-packet)), keep it, because the sweep would use it.

## 🔮 Next Release

### NR1: Upgrade to base 1.14 and replace isVisible functions with isVisibleExpression

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:91`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/config.ts#L91), [`src/config.ts:103`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/config.ts#L103)

**What goes wrong:** Nothing changes for users today. Base 1.11.3 only supports `isVisible` functions to show or hide a settings field, so the two new Advanced Options fields ("Clear Validity when tracker data is stale" and "Tracker data timeout (ms)") have to use them. `isVisible` functions are deprecated from API 1.12, and the API 1.x template is on `~1.14.1`. Each release that adds another one means more to convert later.

**Why it happens:** The module is still on `@companion-module/base ~1.11.3`, which has no `isVisibleExpression`, and this release added two more `isVisible: (options) => …` config fields.

**Fix:** in a future release, update `@companion-module/base` to `~1.14.1` (needs Companion 4.2+). Then replace each `isVisible` function with an expression string, and do the same for the other config fields and the feedback options.

```ts
isVisibleExpression: '$(options:advancedOptions)',
// the timeout field:
isVisibleExpression: '$(options:advancedOptions) && $(options:useTrackerTimeout)',
```

## 📝 Additional Notes

- Prior review (v1.3.0) C1, fixed: `.gitattributes` with `* text=auto eol=lf` is added.
- Prior review (v1.3.0) C2, fixed: `/.vscode` is added to `.gitignore`.
- Prior review (v1.3.0) H1, fixed: [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/tsconfig.build.json#L2) now extends the Node 22 preset.
- Prior review (v1.3.0) M1, fixed: the timeout timer sets a `stale` flag that [`src/main.ts:536`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/main.ts#L536) reads, so validity now always clears when the stream stops (the new M1 above is about the 10 ms default, not the clear itself).
- Prior review (v1.3.0) L1, fixed: "Bind to specific IP" checks custom values with `Regex.IP` again.
- Prior review (v1.3.0) L2, fixed: the log prints the socket's real address and names the multicast interface.
- Prior review (v1.3.0) N1, fixed: the interface list is built each time the settings open and starts with "Any interface (OS default)".
- Prior review (v1.3.0) N2, fixed: "Tracker Active" has a real description.
- Prior review (v1.3.0) N3, fixed: `companion/HELP.md` documents the interface dropdown and the stale-validity options.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion redraws buttons and re-evaluates triggers and expressions for each variable change, so the 60 Hz flip between value and blank is visible on a button and fires triggers that test for an empty validity | General Companion host behaviour; any redraw throttling was not checked. The flip-flopping values themselves were reproduced with a Node simulation of [`src/main.ts:473-488`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/main.ts#L473-L488) and [`src/main.ts:535-538`](https://github.com/bitfocus/companion-module-PosiStageNet-protocol/blob/ec0f487f299a05fed8ab4deb98548d7ef858c2c1/src/main.ts#L535-L538) | [M1](#m1-with-the-default-10-ms-timeout-tracker-validity-blanks-out-between-every-psn-packet) |
| A2 | Companion shows connection-settings tooltips as plain text, so `$(internal:bind_ip)` appears literally instead of being replaced with a value | Companion host UI behaviour; not checked in a live Companion | [N1](#n1-bind-to-specific-ip-tooltip-still-names-a-different-default-than-the-new-any-interface-entry) |
