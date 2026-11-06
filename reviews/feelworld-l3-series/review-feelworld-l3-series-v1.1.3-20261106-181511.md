# Review: companion-module-feelworld-l3-series v1.1.3 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | [companion-module-feelworld-l3-series](https://github.com/bitfocus/companion-module-feelworld-l3-series) |
| **Scope** | `tag` |
| **Version** | v1.1.3 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`38128c8`](https://github.com/bitfocus/companion-module-feelworld-l3-series/tree/38128c8c12f1ec27e61730ed24884bd490d4a017) |
| **Follow-up to** | [v1.1.0 review](review-feelworld-l3-series-v1.1.0-20261030-192328.md) (2026-10-30, ❌ Changes Required) |
| **Reviewed** | 2026-11-06 |

This is a follow-up to the v1.1.0 review. The module has still never been published, so v1.1.3 is still its first release: there is no published tag to diff against, the whole module was reviewed again, and every finding is classified 🆕 NEW. The changes since v1.1.0 (v1.1.1 to v1.1.3: 21 files, +540/-719) were also checked against each finding of that review.

- **Fixed:** every blocking finding of v1.1.0 (C1-C11 template files and `package.json`, H1 `release.yaml`, H2 Chinese text, which is now all English), M1-M4 (issue templates and `node.yaml`), M5 (the connection now shows Connecting until the switcher answers, and "No response from device" after 5 s), M6 (the PGM/PVW Match Alert now works on Input 1) and L2 (the PGM highlight is now #B71F16 red).
- **Partly fixed:** L1. The startup sync timers are now cleared on teardown; the short action timers are not, see [L3](#l3-a-few-short-action-timers-keep-running-after-a-settings-save-or-when-the-connection-is-disabled).
- **Still open:** M7 (now [M1](#m1-action-and-feedback-schemas-are-still-untyped-so-option-ids-and-values-are-not-type-checked)), L3 (now [L9](#l9-numbered-copies-of-actions-instead-of-one-action-with-an-option), optional), L4 (now [L6](#l6-source-and-stream-dropdown-values-are-0-based-so-expression-mode-entries-pick-the-wrong-input)), L5 (now [L7](#l7-long-running-toggle-actions-ignore-abort-actions)), N1 and N2 (still [N1](#n1-duplicate-send-code-and-untyped-json-report-handling) and [N2](#n2-volume-scene-recording-and-stream-state-are-not-available-as-variables)).

The one blocking finding, [H1](#h1-current-programpreview-source-variables-show-0-4-not-the-documented-1-5), was already present in v1.1.0; the earlier review missed it.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The switcher numbers its inputs from 0 (Input 1 = 0 … Media = 4) in both the `0x20 0x0d`/`0x0e` replies and the `pgmpvwInfo` JSON report, as the module's comments say ("confirmed by testing"). If it numbers them from 1, the variables are right and the Source Indicator feedbacks and presets are off by one instead | The comments at [`src/feedbacks.ts:15`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L15), [`src/main.ts:383`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L383) and [`src/main.ts:537-538`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L537-L538), and the preset mapping at [`src/presets.ts:353-354`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L353-L354); not checked on hardware | [H1](#h1-current-programpreview-source-variables-show-0-4-not-the-documented-1-5), [L6](#l6-source-and-stream-dropdown-values-are-0-based-so-expression-mode-entries-pick-the-wrong-input) |
| A2 | When a button has several actions, Companion starts them concurrently by default, so two "Stream N Toggle" actions on one button wait for the device's confirmation at the same time | Companion's default action-group behaviour (concurrent unless the user picks sequential or adds waits); not determinable from the module or the base package | [L2](#l2-starting-one-stream-can-mark-a-different-stream-as-live-and-hide-its-address-empty-warning) |
| A3 | The operating system reports UDP send failures (for example `EHOSTUNREACH` / `ENETUNREACH` when the route to the switcher is gone) through the `dgram` send callback | General Node `dgram` behaviour; the module only shows that callback errors are logged | [L4](#l4-the-connection-stays-green-when-commands-cant-be-sent) |

## 📋 Issues

### Blocking

- [ ] [H1: Current Program/Preview Source variables show 0-4, not the documented 1-5](#h1-current-programpreview-source-variables-show-0-4-not-the-documented-1-5)

### Non-blocking

- [ ] [M1: Action and feedback schemas are still untyped, so option ids and values are not type-checked](#m1-action-and-feedback-schemas-are-still-untyped-so-option-ids-and-values-are-not-type-checked)
- [ ] [L1: PGM Vol +1 can drop the output volume to 1 when the volume read gets no reply](#l1-pgm-vol-1-can-drop-the-output-volume-to-1-when-the-volume-read-gets-no-reply)
- [ ] [L2: Starting one stream can mark a different stream as live and hide its ADDRESS EMPTY warning](#l2-starting-one-stream-can-mark-a-different-stream-as-live-and-hide-its-address-empty-warning)
- [ ] [L3: A few short action timers keep running after a settings save or when the connection is disabled](#l3-a-few-short-action-timers-keep-running-after-a-settings-save-or-when-the-connection-is-disabled)
- [ ] [L4: The connection stays green when commands can't be sent](#l4-the-connection-stays-green-when-commands-cant-be-sent)
- [ ] [L5: An IP typed with leading zeros passes validation but every reply is ignored](#l5-an-ip-typed-with-leading-zeros-passes-validation-but-every-reply-is-ignored)
- [ ] [L6: Source and Stream dropdown values are 0-based, so expression-mode entries pick the wrong input](#l6-source-and-stream-dropdown-values-are-0-based-so-expression-mode-entries-pick-the-wrong-input)
- [ ] [L7: Long-running toggle actions ignore Abort actions](#l7-long-running-toggle-actions-ignore-abort-actions)
- [ ] [L8: README's developer guide names Companion 3.0+ and an API call that v2 removed](#l8-readmes-developer-guide-names-companion-30-and-an-api-call-that-v2-removed)
- [ ] [L9: Numbered copies of actions instead of one action with an option](#l9-numbered-copies-of-actions-instead-of-one-action-with-an-option)
- [ ] [N1: Duplicate send code and untyped JSON report handling](#n1-duplicate-send-code-and-untyped-json-report-handling)
- [ ] [N2: Volume, scene, recording and stream state are not available as variables](#n2-volume-scene-recording-and-stream-state-are-not-available-as-variables)
- [ ] [N3: HELP lists preset button captions under Actions, so users can't find them in the action picker](#n3-help-lists-preset-button-captions-under-actions-so-users-cant-find-them-in-the-action-picker)
- [ ] [N4: Stale color comments and leftover lock preset entries](#n4-stale-color-comments-and-leftover-lock-preset-entries)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: Current Program/Preview Source variables show 0-4, not the documented 1-5

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:705-711`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L705-L711)

**What goes wrong:** A user puts the "Current Program Source" variable (`$(feelworld-l3-series:current_pgm)`) on a button as a tally label, or builds a trigger such as `$(feelworld-l3-series:current_pgm) == 1` to light the camera-1 tally. HELP and README both say the variable holds the source number 1-5, which matches the action names "PGM Source 1" to "PGM Source 5". The variable actually shows the device's 0-based channel: with Input 1 on Program it shows 0, with Input 3 it shows 2, and with Media it shows 4. The button label is off by one, and the `== 1` trigger fires when Input 2 is live, not Input 1. The "Current Preview Source" variable (`current_pvw`) has the same problem. This was already the case in v1.1.0.

**Why it happens:** The switcher reports its channels counted from 0 (Input 1 = 0 … Media = 4); the module's own comments and the feedback dropdown say so. Every place that stores the current Program or Preview source keeps that raw channel number, and the code that publishes the variables passes it on unchanged, without adding 1. HELP, README, the action names and the presets (which subtract 1 to get the device channel) all count from 1.

**Evidence:**

```ts
// src/main.ts:705-711
	private updateVariableValues(): void {
		// -1 = not yet known; hide the variables until the first state sync
		this.setVariableValues({
			current_pgm: this.currentPgm >= 0 ? this.currentPgm : undefined,
			current_pvw: this.currentPvw >= 0 ? this.currentPvw : undefined,
		})
	}
```

```ts
// src/main.ts:383,394-402
	 * Confirmed: the id==1 entry in pgmpvwInfo is the main channel; channel numbers are 0-based (HDMI1-4=0-3, MEDIA=4).
...
				return typeof main?.channel === 'number' ? main.channel : null
			}
			const pgm = pick(pgmpvw.pgmInfo)
			const pvw = pick(pgmpvw.pvwInfo)
			if (pgm !== null) this.currentPgm = pgm
			if (pvw !== null) this.currentPvw = pvw
```

```ts
// src/main.ts:537-543, 551-553
		// Source read reply: CMD=0x20, DAT1=0x0d PGM / 0x0e PVW, DAT2=source index 0-4
		// (HDMI1-4=0-3, MEDIA=4, 0-based matching panel keys 1-5; same numbering as the pgmpvwInfo JSON channel)
		if (cmd === 0x20 && (dat1 === 0x0d || dat1 === 0x0e)) {
			if (dat1 === 0x0d) {
				this.currentPgm = dat2
			} else {
				this.currentPvw = dat2
...
		if (cmd === 0x54 && dat1 === 0x0a) {
			this.currentPgm = dat2
			this.currentPvw = dat3
```

```ts
// src/feedbacks.ts:15-27
// Device channels are 0-based: HDMI1-4 = 0-3, MEDIA = 4 (confirmed by testing)
const SOURCE_OPTIONS: SomeCompanionFeedbackInputField[] = [
	{
		type: 'dropdown',
		label: 'Source',
		id: 'source',
		default: '0',
		choices: [
			{ id: '0', label: 'Input 1' },
			{ id: '1', label: 'Input 2' },
			{ id: '2', label: 'Input 3' },
			{ id: '3', label: 'Input 4' },
			{ id: '4', label: 'Media' },
```

```ts
// src/presets.ts:354
						options: { source: String(Number(source[2]) - 1) },
```

```markdown
// companion/HELP.md:98-101
## Variables

- **current_pgm**: Current Program source (1-5)
- **current_pvw**: Current Preview source (1-5)
```

```markdown
// README.md:228-231
| Variable ID   | Description                     |
| ------------- | ------------------------------- |
| `current_pgm` | Current PGM source number (1–5) |
| `current_pvw` | Current PVW source number (1–5) |
```

**Confirm by:** open [`src/main.ts:705-711`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L705-L711): `current_pgm` and `current_pvw` are published as the raw 0-based channel, with no `+ 1`. Compare with [`companion/HELP.md:100-101`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/companion/HELP.md#L100-L101) and [`README.md:230-231`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/README.md#L230-L231) ("1-5"), and with [`src/presets.ts:354`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L354), where preset N maps to feedback source N-1.

**Fix:** publish the source number counted from 1, so Input 1 shows 1 and Media shows 5.

```ts
current_pgm: this.currentPgm >= 0 ? this.currentPgm + 1 : undefined,
current_pvw: this.currentPvw >= 0 ? this.currentPvw + 1 : undefined,
```

Optionally name the variables "Current Program Source (1-5)" / "Current Preview Source (1-5)" in [`src/variables.ts`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/variables.ts), so the range shows in the variables list. If 0-4 is really intended, change HELP.md and README.md instead, but 1-5 matches the action and preset names (PGM 1 to PGM 5).

## 🟡 Medium

### M1: Action and feedback schemas are still untyped, so option ids and values are not type-checked

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:11`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L11), [`src/actions.ts:8`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/actions.ts#L8)

**What goes wrong:** Nothing is visible to users today; this is code quality. A typo in a feedback option id, or in a preset's feedback options (for example `{ scnee: '1' }` instead of `{ scene: '1' }`), still compiles and ships, and a preset button built from it never lights. This was M7 in the v1.1.0 review and is unchanged.

**Why it happens:** Both schemas say "any id, with any options": `ActionsSchema = Record<string, { options: CompanionOptionValues }>` and `FeedbacksSchema = Record<string, { type: 'boolean'; options: CompanionOptionValues }>`. So the feedback callbacks have to cast their options (`feedback.options.source as string` at [`src/feedbacks.ts:83`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L83) and 98, `scene` at 192, `index` at 257, `actionId` at 282), the preset feedback maps are typed `Record<string, any>` ([`src/presets.ts:221`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L221), [`src/presets.ts:300`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L300)), and `CompanionPresetDefinitions<ModuleSchema>` at [`src/presets.ts:341`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L341) checks nothing.

**Fix:** declare each feedback and action with its own options, then remove the casts and the `Record<string, any>` preset option maps.

```ts
type FeedbacksSchema = {
	pgm_source: { type: 'boolean'; options: { source: string } }
	scene_active: { type: 'boolean'; options: { scene: string } }
	pip_active: { type: 'boolean'; options: Record<string, never> }
	// …
}
```

Do the same for actions. Skills: companion-v2-feedbacks, companion-v2-actions.

## 🟢 Low

### L1: PGM Vol +1 can drop the output volume to 1 when the volume read gets no reply

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:976-1010`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L976-L1010)

**What goes wrong:** The PGM volume is at 80 on the switcher. If the module has never received a volume reply (for example the startup read was lost) and the read that "PGM Vol +1" sends also gets no answer within 1 s, the module sets the volume to 1. The program audio drops from 80 to almost silent, on air. "PVW Vol +1" behaves the same way; "PGM Vol -1" / "PVW Vol -1" do nothing in the same situation.

**Why it happens:** When the volume read times out, the module falls back to its stored volume. That stored value starts at 0 ([`src/main.ts:72-73`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L72-L73)) and is only updated by a volume reply or by the step itself. The step then writes "stored value + 1" to the device as an absolute volume.

**Fix:** remember whether the volume has ever been read from the device (for example `private pgmVolumeKnown = false`, set to `true` in the `0x41 0x03` reply handler). In `stepVolume()`, if the read timed out and the volume is not known, log a warning and skip the write instead of sending `0 + delta`.

### L2: Starting one stream can mark a different stream as live and hide its ADDRESS EMPTY warning

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:417-426`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L417-L426), [`src/main.ts:798-810`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L798-L810)

**What goes wrong:** A user builds one "Go Live" button with both "Stream 1 Toggle" and "Stream 2 Toggle". Stream 1 has an address configured; Stream 2 is empty. The device answers only for Stream 1, but that one answer confirms both starts. The "Stream 2 Active" highlight lights up as if Stream 2 were live, and the yellow ADDRESS EMPTY warning never appears on the Stream 2 button. The operator believes both destinations are live when only one is.

**Why it happens:** A stream start waits for the device's status report as its confirmation. When any status report with stream information arrives, the module wakes the waiting starts of **every** stream, not only the stream the report is about, and each woken start then marks its own stream as live, overriding the on/off state just read from that same report.

**Fix:** let only one stream start wait at a time (a small queue or promise chain, so the next start is sent once the previous one is confirmed or times out). Alternatively, if the report can be tied to a stream (for example by the `urlInfo` entry that changed), wake only that stream's waiters.

### L3: A few short action timers keep running after a settings save or when the connection is disabled

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:102-121`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L102-L121)

**What goes wrong:** There is little to see in normal use. A user presses "LOGO Toggle" and saves the connection settings (for example a new Device IP Address) within 100 ms: the logo read-back query from the old connection still goes out, on the new connection. The 100 ms button flash ("Cut", "Auto", "Menu"…), the 1 s ADDRESS EMPTY and NO DISK warnings and the 500 ms wait for a split status report also run on after a settings save and re-check feedbacks. When the connection is disabled or deleted, Companion stops the module's process right after `destroy()`, so the effect there is brief, but `destroy()` should still stop every timer the module started. This is what is left of L1 from the v1.1.0 review: the startup sync timers and the new 5 s "No response from device" timer are now cleared properly.

**Why it happens:** `destroy()` and `configUpdated()` clear the sync timers and the connect timeout, and `destroy()` also clears the status-report wait timer. The one-shot timers made by `flashAction()` ([`src/main.ts:1131`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L1131)), `warnStreamNoAddress()` ([`src/main.ts:835`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L835)), `warnNoDisk()` ([`src/main.ts:878`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L878)) and `toggleLogo()` ([`src/main.ts:937`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L937)) are created with a bare `setTimeout` and their handles are thrown away. `configUpdated()` also never calls `clearJsonWait()`, so the status-report wait timer ([`src/main.ts:313-330`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L313-L330)) survives a settings save.

**Fix:** track every module timer in one place and clear them all on teardown.

```ts
private timers = new Set<NodeJS.Timeout>()

private later(fn: () => void, ms: number): void {
	const t = setTimeout(() => {
		this.timers.delete(t)
		fn()
	}, ms)
	this.timers.add(t)
}

private clearTimers(): void {
	for (const t of this.timers) clearTimeout(t)
	this.timers.clear()
}
```

Use `this.later(...)` in `flashAction()`, `warnStreamNoAddress()`, `warnNoDisk()` and `toggleLogo()`, and call `clearTimers()` in `destroy()` and `configUpdated()`. In `configUpdated()`, also call `this.clearJsonWait()` before `connect()`.

### L4: The connection stays green when commands can't be sent

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:720-755`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L720-L755)

**What goes wrong:** If sending fails (for example the Companion computer loses its network route to the switcher), every button press writes "Send error: send EHOSTUNREACH ..." to the log, but the connection stays green (OK) in the Connections list. The user has no visible sign that nothing reaches the switcher.

**Why it happens:** Both send paths (`sendBuffer()` and `sendCommand()`) only log the send error. Once the device has answered once, nothing moves the connection status off OK again.

**Fix:** on a send error, set the status to Connection Failure with the error message (`this.updateStatus(InstanceStatus.ConnectionFailure, err.message)`) and reset `this.deviceReplied = false`. The existing reply handler then switches the status back to OK on the next reply. Merging `sendCommand()` into `sendBuffer()` (see [N1](#n1-duplicate-send-code-and-untyped-json-report-handling)) means this only has to be done once.

### L5: An IP typed with leading zeros passes validation but every reply is ignored

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:133-137`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L133-L137)

**What goes wrong:** A user types the Device IP Address as 192.168.001.100. The field accepts it, because Companion's IP pattern allows leading zeros. Commands reach the switcher (Node sends them to 192.168.1.100), but every reply is thrown away. After 5 s the connection shows "Connection failure: No response from device", and the Program/Preview, PIP, mute and other feedbacks never update, even though the buttons do control the switcher.

**Why it happens:** The new reply filter (which ignores packets from other addresses) compares the sender's address, always in the short form `192.168.1.100`, with the text typed in the config field, character for character.

**Fix:** normalise the address before comparing: resolve the configured host once in `connect()` (with `dns.promises.lookup(this.config.host, 4)`, or by parsing the four numbers into a canonical dotted string), store the result, and compare the sender's address with that stored value.

### L6: Source and Stream dropdown values are 0-based, so expression-mode entries pick the wrong input

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:16-30`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L16-L30), [`src/feedbacks.ts:247-255`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L247-L255)

**What goes wrong:** A user switches the "Source" option of "PGM Source Indicator" (or "PVW Source Indicator") to expression mode and enters 1, meaning Input 1. The feedback then lights for Input 2, because the values behind the labels are '0' = Input 1 … '4' = Media. The "Stream" option of "Stream Warn: Address Empty" works the same way ('0' = Stream 1 … '3' = Stream 4). This was L4 in the v1.1.0 review and is unchanged.

**Why it happens:** In API 2.x a user can switch any dropdown to an expression, and the expression must produce the stored choice id, not the label. These ids are the device's 0-based channel and stream numbers.

**Fix:** use ids that match the labels ('1'-'5', or 'input1'…'input4' / 'media', and '1'-'4' for streams), and subtract 1 in the callbacks ([`src/feedbacks.ts:83`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L83), 98, 257). Update the preset options too: [`src/presets.ts:354`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L354) (`String(Number(source[2]) - 1)` becomes `source[2]`) and [`src/presets.ts:310-334`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L310-L334) (`index: '0'`…`'3'`). The module is unpublished, so no upgrade script is needed.

### L7: Long-running toggle actions ignore Abort actions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:788-811`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L788-L811), [`src/main.ts:892-913`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L892-L913), [`src/main.ts:999-1010`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L999-L1010)

**What goes wrong:** A button uses Companion 5's "Abort actions" while "Stream 1 Toggle" is waiting for the device to confirm. The module carries on anyway: for up to about 3.2 s it keeps sending the stop and retry commands, and it may then mark the stream as on or show ADDRESS EMPTY. "Record Toggle" (up to 1.5 s waiting for the USB-disk reply), "PVW/PGM Vol +1/-1" and "Background Toggle" (up to 1 s each) also run to the end after an abort. This was L5 in the v1.1.0 review and is unchanged.

**Why it happens:** Companion passes each action callback an abort signal (`context.signal`, declared in base 2.1.3 `module-api/action.d.ts:62`). The callback at [`src/actions.ts:328`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/actions.ts#L328) ignores it, so it never reaches `toggleStream()`, `startStreamAndWaitConfirm()`, `queryUdisk()`, `queryVolume()` or `queryBackground()`.

**Fix:** change `ActionSpec.run` to `(instance, signal: AbortSignal) => Promise<void>` and pass `context.signal` from the callback. In the waiting helpers, resolve early on the signal's `abort` event, and check `signal.aborted` before each follow-up send (for example before the retry in `toggleStream()` and before the write in `stepVolume()`). Skill: companion-v2-actions.

### L8: README's developer guide names Companion 3.0+ and an API call that v2 removed

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:62`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/README.md#L62), [`README.md:261`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/README.md#L261), [`README.md:410`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/README.md#L410)

**What goes wrong:** The README lists "Bitfocus Companion (v3.0+, latest stable recommended)" as a requirement. The module is built on API 2.1 and only loads in Companion 5.0 or later, so someone on Companion 3.x or 4.x who follows the README gets a module that doesn't load. The "State Feedback & Variable Updates" section tells contributors to call `this.checkFeedbacks()` with no arguments, which does not compile on base 2.1.3 (the module itself correctly uses `checkAllFeedbacks()`). "Case 5" uses a `jsonAction(...)` helper that does not exist in `src/actions.ts`.

**Why it happens:** These parts of the README follow older Companion and API conventions and were not updated for API 2.1. Base 2.1.3 declares `checkFeedbacks(feedbackType, ...feedbackTypes)`, which needs at least one feedback id (`module-api/base.d.ts:142`).

**Fix:** change line 62 to "Bitfocus Companion 5.0 or later (module API 2.1)". At line 261, replace `this.checkFeedbacks()` with `this.checkAllFeedbacks()` (or `this.checkFeedbacks('feedback_id')`). Either add the `jsonAction` helper to `src/actions.ts` or rewrite Case 5 with `customAction(..., (instance) => instance.sendJsonCommand(...))`.

### L9: Numbered copies of actions instead of one action with an option

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:144-317`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/actions.ts#L144-L317)

**What goes wrong:** The action list holds about 90 entries with no options, many of them numbered copies: "PGM Source 1"-"5", "PVW Source 1"-"5", "Scene 1"-"8", "Effect Mode 1"-"16", "PIP Template 1"-"8", "AFV 1"-"5 Toggle" and "Stream 1"-"4 Toggle". Users therefore can't pick the input from a variable or expression; one "Set Program" button driven by `$(custom:next_cam)` is not possible. The feedbacks are mixed: "PGM Source Indicator" and "Scene Active" have a dropdown, but "AFV 1"-"5 Active" and "Stream 1"-"4 Active" are separate feedbacks. This was L3 in the v1.1.0 review; the maintainer kept the numbered actions, which that review said was acceptable.

**Why it happens:** Every action is built from a fixed spec with no options ([`src/actions.ts:327`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/actions.ts#L327)), and the number is part of the action id.

**Fix:** optional. Before the first release locks these ids in, consider single actions with a dropdown or number option (for example `pgm_source` with option `source`, `scene_recall` with option `scene`, `afv_toggle` with option `channel`) and matching single feedbacks. Changing ids after publishing needs upgrade scripts, so now is the cheapest time. Keeping the numbered actions is also acceptable.

## 💡 Nice to Have

### N1: Duplicate send code and untyped JSON report handling

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:720-755`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L720-L755), [`src/main.ts:359`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L359), [`src/main.ts:385`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/main.ts#L385)

**What goes wrong:** No user-visible effect; this is code quality, unchanged since v1.1.0 (N1). `sendBuffer()` and `sendCommand()` still repeat the same socket check and send/log logic, so any fix to one (for example [L4](#l4-the-connection-stays-green-when-commands-cant-be-sent)) has to be made twice. `tryParseLooseJson()` and `applyJsonReport()` still use `any`, so a typo in a report field name (for example `pgmpvwinfo`) compiles and silently stops that feedback from updating.

**Fix:** have `sendCommand()` build the string and call `this.sendBuffer(Buffer.from(command, 'ascii'), command)`. Add a small interface for the `0xB1 0x58` report (`pgmpvwInfo`, `streamInfo`, `recordInfo`, `bgInfo`, `keyInfo`, `pipInfo`, `sceneInfo`, `effectInfo`, `transInfo`, `audioInfo`, `logoInfo`) and type `applyJsonReport(data: Partial<L3Report>)` instead of `any`.

### N2: Volume, scene, recording and stream state are not available as variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:3-12`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/variables.ts#L3-L12)

**What goes wrong:** Users can press "PVW Vol +1" / "PGM Vol +1" but can't show the current volume on a button, although the module already reads it. The same is true of the current scene, recording, stream 1-4 state and transition type: each is only available as an on/off highlight, never as text such as "SCN 3" or "VOL 72". This was N2 in the v1.1.0 review and is unchanged.

**Fix:** add variables such as `pgm_volume`, `pvw_volume`, `current_scene`, `recording`, `stream_1`…`stream_4` and `transition_type`, and set them wherever the matching state changes (`handleFixedFrame()`, `applyJsonReport()` and the optimistic toggles). Define them before setting them, as `init()` already does. Skills: companion-v2-variable-definition, companion-v2-variable-set-value.

### N3: HELP lists preset button captions under Actions, so users can't find them in the action picker

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:16-79`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/companion/HELP.md#L16-L79)

**What goes wrong:** A user reads HELP, then searches the action list for "REC", "SCN 1", "BKGD NEXT", "T-MIX" or "VOL± PVW" and finds nothing: the actions are called "Record Toggle", "Scene 1", "Background Toggle", "Transition MIX" and "PVW Vol +1". HELP's names are the preset button captions. The fifth source is also named two ways: the action says "Set Program to Input 5" ([`src/actions.ts:153`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/actions.ts#L153)), but the feedback dropdown calls the same source "Media" ([`src/feedbacks.ts:27`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L27)).

**Fix:** under "## Actions", use the action names users see in Companion ("Record Toggle", "Scene 1-8", "Background Toggle", "PVW Vol +1 / -1", …), and mention the preset captions separately if useful. Name the fifth source the same way everywhere, for example "Set Program to Media (Input 5)".

### N4: Stale color comments and leftover lock preset entries

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:204`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L204), [`src/presets.ts:45`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L45), [`src/presets.ts:136`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L136), [`src/presets.ts:210-211`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L210-L211)

**What goes wrong:** Nothing is visible to users, but a later maintainer can be misled. The color-scheme comments still say "PGM1-5 highlight: background #28181C" ([`src/feedbacks.ts:46`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/feedbacks.ts#L46), [`src/presets.ts:204`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/presets.ts#L204)), but both files now use #B71F16 (the v1.1.0 L2 fix). `src/presets.ts` also keeps `lock` entries for an action that is commented out ([`src/actions.ts:184`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/38128c8c12f1ec27e61730ed24884bd490d4a017/src/actions.ts#L184)), plus two commented-out color constants.

**Fix:** change both comments to #B71F16. Remove the `lock` entries from `CATEGORY_BY_ACTION` and `STYLE_BY_ACTION`, or bring the action back. Delete the commented-out constants.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: `exclude` uses `src/**/*.spec.ts` where the template has `src/**/*spec.ts` (line 4). It builds fine; no change required.
