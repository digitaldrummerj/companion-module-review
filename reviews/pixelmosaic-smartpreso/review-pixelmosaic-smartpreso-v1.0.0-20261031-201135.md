# Review: companion-module-pixelmosaic-smartpreso v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-pixelmosaic-smartpreso` |
| **Scope** | `tag` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`59dafaa`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/tree/59dafaa81c29790c40db9b7833f343f2f38ce45f) |
| **Reviewed** | 2026-10-31 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Smart Preso (SP Builder) sends no state back to the controller over OSC today, so a feedback would need a new listener (if the device can report state) or state the module last commanded | The maintainer's comment in [`src/feedbacks.ts:3`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/feedbacks.ts#L3), [`companion/HELP.md:37`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/companion/HELP.md#L37) and the send-only socket; the Smart Preso OSC documentation was not checked | [H1](#h1-no-feedbacks-buttons-cant-show-what-smart-preso-is-doing) |
| A2 | The first-release rule (at least one device-state feedback) applies to a one-way, send-only protocol too | The rule lists no exception for one-way protocols; whether one applies is a policy call | [H1](#h1-no-feedbacks-buttons-cant-show-what-smart-preso-is-doing) |

## 📋 Issues

### Blocking

- [ ] [H1: No feedbacks: buttons can't show what Smart Preso is doing](#h1-no-feedbacks-buttons-cant-show-what-smart-preso-is-doing)

### Non-blocking

- [ ] [L1: Connection shows OK when every send fails, and stays red after a socket error](#l1-connection-shows-ok-when-every-send-fails-and-stays-red-after-a-socket-error)
- [ ] [L2: Typos in action and preset definitions won't be caught at build time](#l2-typos-in-action-and-preset-definitions-wont-be-caught-at-build-time)
- [ ] [L3: Test pattern option is hard to use in expression mode](#l3-test-pattern-option-is-hard-to-use-in-expression-mode)
- [ ] [N1: Preset helper comment describes a target default that doesn't exist](#n1-preset-helper-comment-describes-a-target-default-that-doesnt-exist)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: No feedbacks: buttons can't show what Smart Preso is doing

- **Source:** 🔎 compliance reviewer — ⚠️ needs your check
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:3-8`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/feedbacks.ts#L3-L8)

**What goes wrong:** This is the module's first release, at v1.0.0, and it registers no feedbacks at all. A user who builds a page of Smart Preso buttons (for example "System: Set test pattern" with "Color Bars", a "Cue List: Activate" button, or "Cue Sequence: Play") finds an empty feedback list on every button. No button can light up to show the active test pattern, the active cue list or that a sequence is playing, so the operator gets no confirmation on the surface of which state the show is in.

**Why it happens:** The module registers an empty set of feedback definitions, and its feedback type list is declared as empty. The code comment and the help file explain this by saying the OSC protocol is one-way: the module only sends, and nothing listens for replies. A first release needs at least one feedback that shows the device's state.

**Evidence:**

```ts
// src/feedbacks.ts:1-8
import type ModuleInstance from './main.js'

// The OSC protocol is one-way (no state comes back from Smart Preso), so there are no feedbacks yet.
export type FeedbacksSchema = Record<string, never>

export function UpdateFeedbacks(self: ModuleInstance): void {
	self.setFeedbackDefinitions({})
}
```

```ts
// src/osc.ts:50-59 (send-only UDP socket; the only listener is 'error', there is no 'message' handler in src/)
/** A UDP sender with broadcast enabled, so the destination can be a broadcast or unicast address. */
export class OscSender {
	...
		const socket = createSocket({ type: 'udp4', reuseAddr: true })
		this.socket = socket
		socket.on('error', onError)
```

```markdown
<!-- companion/HELP.md:37 -->
Smart Preso does not currently report state back to Companion, so this module has no feedbacks or variables.
```

**Confirm by:** open [`src/feedbacks.ts:6-8`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/feedbacks.ts#L6-L8) and [`src/osc.ts:50-80`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/osc.ts#L50-L80). The feedback definitions are `{}` and the socket only sends (no `'message'` listener). Then decide whether the first-release feedback rule applies to a send-only device that reports no state (see [A1](#-assumptions-to-confirm) and A2). If one-way devices are exempt, drop this finding.

**Fix:** add at least one boolean feedback that shows real device state, and attach it to the presets.

- If SP Builder can send state back (an OSC reply or a status port), listen for it and add feedbacks such as "Test pattern is …", "Cue List … is active" and "Cue Sequence playing".
- If the device can't report state, a feedback built from the last command the module sent (for example the last pattern sent by "System: Set test pattern" with target `all`) is possible, but it can be wrong when several SP Builders receive a broadcast or something else also controls Smart Preso. Call `checkFeedbacks('<id>')` after each send.

Add the feedback types to `FeedbacksSchema` in [`src/feedbacks.ts`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/feedbacks.ts) and use them in [`src/presets.ts`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/presets.ts).

## 🟢 Low

### L1: Connection shows OK when every send fails, and stays red after a socket error

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:58-77`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/main.ts#L58-L77)

**What goes wrong:** A user sets Destination address to `10.11.0.255` and Port `10500`. The socket opens, so the connection shows OK. If the computer then has no route to that address (adapter unplugged, wrong subnet broadcast typed, a VPN took the default route), pressing a TAKE button ("Cue List: Take (run) current Cue List Item") fails with an error such as `ENETUNREACH`. The module only writes "Failed to send /sp/all/cuelist/current/take: …" to the log, and the connection stays green, so the operator has no sign on the Connections page that cues aren't going out. The reverse also happens: once the socket's error handler sets an error status, it stays red even when later sends work, until the connection settings are saved again.

**Why it happens:** Node's UDP `send` reports failures through its callback, not through the socket's `error` event, so a failed send never reaches the handler that sets the error status. `sendOsc` catches the failure and only logs it. Nothing sets the status back to OK after a later successful send. With no replies over UDP, send results are the only failure signal the module has.

**Fix:** let the status follow the most recent send. Set an error status in `sendOsc`'s catch block and OK after a successful send (Companion ignores a status that hasn't changed).

```ts
// src/main.ts, in sendOsc
try {
	await this.osc.send(this.config.host, this.config.port, address, args)
	this.updateStatus(InstanceStatus.Ok)
	// ...
} catch (err) {
	this.updateStatus(InstanceStatus.UnknownError, `Send failed: ${(err as Error).message}`)
	this.log('error', `Failed to send ${address}: ${(err as Error).message}`)
}
```

### L2: Typos in action and preset definitions won't be caught at build time

- **Source:** 🔎 compliance reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:96-120`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/actions.ts#L96-L120), [`src/presets.ts:27`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/presets.ts#L27), [`src/presets.ts:69`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/presets.ts#L69)

**What goes wrong:** Users see no change today. But TypeScript can't catch future mistakes in the definitions: a preset that sets a misspelled option id (for example `patern` instead of `pattern` on "System: Set test pattern") would still compile, and users would get a preset button that silently falls back to the default "OFF" pattern. A field renamed in a future `@companion-module/base` version would also only break at runtime.

**Why it happens:** The action definitions and the preset map are built as untyped records (`Record<string, unknown>`) and then cast to the API's types when they are passed to `setActionDefinitions` and `setPresetDefinitions`. The cast tells the compiler to trust them, so nothing is checked. The actions are generated from a command table on purpose, so this is Low.

**Fix:** type the containers instead of casting them: `CompanionActionDefinitions<ActionsSchema>` for the actions and `CompanionPresetDefinitions<ModuleSchema>` for the presets, and have `button()` return `CompanionSimplePresetDefinition<ModuleSchema>`. Then remove the `as` casts so every definition is checked.

### L3: Test pattern option is hard to use in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/commands.ts:42-50`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/commands.ts#L42-L50), [`src/commands.ts:185`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/commands.ts#L185)

**What goes wrong:** In the "System: Set test pattern" action, a user who switches the "Test pattern" option to expression mode has to type `3` for "Color Bars" or `6` for "Cross Hatch", and nothing in the UI tells them those numbers. Picking from the dropdown works normally.

**Why it happens:** The dropdown choice ids are the device's numeric pattern indices (0-6). The v2 guidelines recommend readable ids because users type them in expression mode.

**Fix:** either use string ids (`off`, `pixel_map_grid`, `color_bars`, …) and map them to the OSC integer in `oscArgFor`, or keep the numeric ids and add an `expressionDescription` listing `0 = OFF … 6 = Cross Hatch`. Changing the ids now, before anyone has saved buttons, needs no upgrade script.

## 💡 Nice to Have

### N1: Preset helper comment describes a target default that doesn't exist

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:7-11`](https://github.com/bitfocus/companion-module-pixelmosaic-smartpreso/blob/59dafaa81c29790c40db9b7833f343f2f38ce45f/src/presets.ts#L7-L11)

**What goes wrong:** Users see no effect. The comment on the preset helper says presets use "an empty target (= connection default)", but the presets set the target to `all`, and the connection has no default-target setting. A maintainer reading the comment could be misled.

**Why it happens:** The comment and the code disagree: the comment describes an empty target, and the next lines set `target: 'all'`.

**Fix:** change the comment to say the presets target `all`.

## 📝 Additional Notes

- First release (new module, never published): there is no previous tag to diff against, so the whole module at v1.0.0 was reviewed and every finding is classified 🆕 NEW.
