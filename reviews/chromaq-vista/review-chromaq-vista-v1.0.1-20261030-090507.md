# Review: chromaq-vista v1.0.1 (follow-up to the v1.0.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-chromaq-vista` ([repo](https://github.com/bitfocus/companion-module-chromaq-vista)) |
| **Version** | v1.0.1 (`9a42373`) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Previous tag** | none. v1.0.0 was reviewed but never published, so v1.0.1 is a resubmission of the first release. There is no diff: the whole module was reviewed again, and every finding is 🆕 NEW. |
| **Previous review** | [v1.0.0 review (2026-10-08)](review-chromaq-vista-v1.0.0-20261005-024911.md). Its findings are checked one by one under [📝 Additional Notes](#-additional-notes). |
| **Scope** | tag |
| **Language** | TypeScript |
| **Transport** | OSC over UDP (node-osc 11.7.1): a client sends to **Target IP** : **Target Port**, and a server listens on `0.0.0.0` : **Listen Port** |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass; no template differences |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a module passes an `Error` object instead of text as the connection status message, Companion shows it as an empty or unreadable reason (for example `{}` or `[object Object]`) rather than the error text | `updateStatus(status, message?: string \| null)` in base 2.0.4 forwards the value unchanged; an `Error` serialises to `{}`. How the Companion host renders a non-string message was not checked | [M1](#m1-a-stray-packet-or-a-busy-listen-port-turns-the-connection-red-and-it-stays-red-while-buttons-still-work) |
| A2 | Vista rejects or misbehaves on fractional index values in an OSC address, such as `/panel/2.5/` | The module's own action descriptions warn that out-of-range requests have crashed Vista; Vista's handling of non-integer indices was not checked | [L3](#l3-fractional-or-out-of-range-grid-panel-bank-row-column-and-softkey-numbers-are-sent-to-vista) |

## 📋 Issues

### Blocking

- [ ] [H1: Buttons cannot show any Vista state because the module has no feedbacks](#h1-buttons-cannot-show-any-vista-state-because-the-module-has-no-feedbacks)

### Non-blocking

- [ ] [M1: A stray packet or a busy Listen Port turns the connection red, and it stays red while buttons still work](#m1-a-stray-packet-or-a-busy-listen-port-turns-the-connection-red-and-it-stays-red-while-buttons-still-work)
- [ ] [L1: A socket error on the sending side could crash the connection](#l1-a-socket-error-on-the-sending-side-could-crash-the-connection)
- [ ] [L2: Momentary button releases can still fire after the connection is disabled or re-saved](#l2-momentary-button-releases-can-still-fire-after-the-connection-is-disabled-or-re-saved)
- [ ] [L3: Fractional or out-of-range grid, panel, bank, row, column and softkey numbers are sent to Vista](#l3-fractional-or-out-of-range-grid-panel-bank-row-column-and-softkey-numbers-are-sent-to-vista)
- [ ] [L4: Custom message with an empty or malformed OSC Address fails with only a log line](#l4-custom-message-with-an-empty-or-malformed-osc-address-fails-with-only-a-log-line)
- [ ] [L5: Variables typed into the custom OSC Address are sent as literal text](#l5-variables-typed-into-the-custom-osc-address-are-sent-as-literal-text)
- [ ] [N1: Playback actions show lowercase panel and bank labels](#n1-playback-actions-show-lowercase-panel-and-bank-labels)

### Notes

- [📝 Additional Notes](#-additional-notes)

---

## 🟠 High

### H1: Buttons cannot show any Vista state because the module has no feedbacks

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:4-9`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/feedbacks.ts#L4-L9), [`src/core/client.ts:36-38`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/core/client.ts#L36-L38)

**What goes wrong:** This is the module's first release. When a user adds a Chroma-Q Vista connection and opens the Feedbacks list on a button, the list is empty. A button such as the **Play** preset (Console > Playback Keys) or a **Console: Playback button** action can't change colour to show whether a cuelist is playing or a fader is up. The module only sends commands, so users get no state on their buttons at all. A first release needs at least one feedback.

**Why it happens:** The feedback list is declared as an empty schema and registered as an empty set of definitions. The module does receive OSC messages from Vista on its **Listen Port**, but it only writes them to the log (when verbose logging is on) and never stores them as state that a feedback could show. The v1.0.0 review did not raise this.

**Evidence:**

```ts
// src/feedbacks.ts:4-9
export type FeedbacksSchema = Record<string, never>

export function UpdateFeedbacks(self: ModuleInstance): void {
	const feedbacks: CompanionFeedbackDefinitions<FeedbacksSchema> = {}
	self.setFeedbackDefinitions(feedbacks)
}
```

```ts
// src/core/client.ts:36-38
		this.#server.on('message', (msg) => {
			if (this.#verbose) clientLogger.info(`Received message: ${msg}`)
		})
```

`grep -rn "setFeedbackDefinitions\|checkFeedbacks" src` finds only `src/feedbacks.ts:8`.

**Confirm by:** open [`src/feedbacks.ts:7`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/feedbacks.ts#L7), where the definitions object is `{}`. Then search `src/` for `setFeedbackDefinitions` / `checkFeedbacks`: the only hit is `feedbacks.ts:8`.

**Fix:** add at least one boolean feedback for device state before the first release. Keep the incoming Vista OSC messages (playback and fader state) in a small state store, expose boolean feedbacks for them, and call `self.checkFeedbacks('<id>')` when that state changes. Then attach those feedbacks to the Playback Keys presets.

---

## 🟡 Medium

### M1: A stray packet or a busy Listen Port turns the connection red, and it stays red while buttons still work

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW (carried forward from the v1.0.0 review's M2 and L1)
- **File:** [`src/core/client.ts:32-43`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/core/client.ts#L32-L43)

**What goes wrong:** A user adds the connection with the default **Listen Port** 9000. Another OSC connection or app on the same machine already uses UDP 9000, or any packet that isn't valid OSC arrives on port 9000. The connection then shows **Connection Failure**, and the reason beside it is likely empty or unreadable instead of, for example, `bind EADDRINUSE 0.0.0.0:9000` (see A1). Actions such as **Action Grid: Trigger Button** or **Console: Grandmaster fader** still reach Vista, because sending uses a separate socket. Nothing sets the status back to OK, so the user sees a failed connection that is in fact working, until they save the config again.

**Why it happens:** The listen socket is used only for verbose logging of incoming messages, yet every error it raises is reported as a connection failure. node-osc's server raises the same `'error'` event for a port it can't bind and for each incoming packet it can't decode (`can't decode incoming message`, `Server.mjs:118-119`). The status only goes back to OK once, when the port first opens. The handler also passes the whole `Error` object as the status message, where Companion expects text.

**Fix:** treat listen-port problems as log-only, or as a warning that doesn't hide a working send path, and pass the error text rather than the object.

- Log decode errors from stray packets (for example with `clientLogger.warn`) and leave the status alone.
- For real socket errors, pass `msg: error.message`.
- If no feature uses the listener, consider removing it and setting OK once the send client exists.

---

## 🟢 Low

### L1: A socket error on the sending side could crash the connection

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW (carried forward from the v1.0.0 review's M1)
- **File:** [`src/core/client.ts:45`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/core/client.ts#L45)

**What goes wrong:** Normally nothing visible. If the sending socket ever hit a low-level UDP error, the module's process would crash and Companion would restart the connection. Ordinary send failures come back through the promise that `send()` already catches, so this is unlikely in practice.

**Why it happens:** In Node, an `'error'` event that nobody listens for is thrown, and an uncaught throw ends the process. node-osc's `Client` passes every error from its UDP socket on as an `'error'` event (`Client.mjs:48-50`), and the module creates the client without listening for it.

**Fix:** listen for errors on the send client right after creating it.

```ts
this.#client.on('error', (err) => clientLogger.error(`OSC send socket error: ${err.message}`))
```

### L2: Momentary button releases can still fire after the connection is disabled or re-saved

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:124-126`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L124-L126), [`src/actions.ts:195-197`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L195-L197), [`src/actions.ts:248-310`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L248-L310)

**What goes wrong:** Almost never visible. Each momentary action (**Action Grid: Trigger Button**, **Console: Playback button**, **Console: Play** and the other playback keys) sends `true`, then sends `false` 20 ms later. If the connection is disabled or its config saved within those 20 ms, the release still fires afterwards: it either logs "Connection not established" or goes out on the new socket. A button could miss its release only in that 20 ms window.

**Why it happens:** The 20 ms release timers are started with `setTimeout`, but their handles aren't kept, so `destroy()` can't cancel them.

**Fix:** keep the timer handles in a set on the instance and clear them in `destroy()`, or wait the 20 ms inside the callback (`await new Promise((r) => setTimeout(r, 20))`) so the release stays within the action's lifetime.

### L3: Fractional or out-of-range grid, panel, bank, row, column and softkey numbers are sent to Vista

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW (carried forward from the v1.0.0 review's M3)
- **File:** [`src/actions.ts:96-122`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L96-L122), [`src/actions.ts:159-193`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L159-L193), [`src/actions.ts:215-232`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L215-L232), [`src/actions.ts:318-328`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L318-L328)

**What goes wrong:** The **Console: Playback button** and **Console: Playback fader** descriptions warn that out-of-range values have crashed Vista, but the module sends whatever the number fields hold. A **Row** of 2.5 (typed in, or from an expression such as `$(internal:x)/2`) becomes `/V3/console/EX/1/playbackButton/panel/0/bank/0/row/2.5/col/0`. A value outside the field's min/max can also arrive through an expression or an imported config. The same applies to **Action Grid: Trigger Button** and **Softkey**. One button could crash the lighting software mid-show.

**Why it happens:** The number options that become part of the OSC address don't set `asInteger: true`, so Companion accepts decimals. The callbacks paste the values into the address without rounding, range or NaN checks; only the fader **Fader position** gets a NaN check.

**Fix:** make every number that goes into an address a whole number, and refuse to send it when it is out of range.

- Add `asInteger: true` to the `actionGrid`, `row`, `col`, `panel`, `bank` and `softkey` options. Leave the fader `level` options as they are.
- In the callbacks, check each value with `Number.isInteger()` and the option's min/max, and log and skip the send when it fails.

### L4: Custom message with an empty or malformed OSC Address fails with only a log line

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW (the `console.log` is what remains of the v1.0.0 review's H3)
- **File:** [`src/actions.ts:76-90`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L76-L90)

**What goes wrong:** If an operator adds **Custom: Send message without arguments** and leaves **OSC Address** empty (the default), or types an address without the leading `/` (for example `V3/global/save`), pressing the button sends nothing useful or the send fails, with only a line in the module log. The action's "Module did not initialize client properly" message also goes to `console.log`, so it never appears in the connection's log (in practice that branch can't run, because the client is always created in `init()`).

**Why it happens:** The callback passes the address straight to the send function with no trim or `/` check, and the option has no `minLength` or `regex`. The missing-client branch logs with `console.log` instead of the module logger.

**Fix:** trim the address; if it is empty or doesn't start with `/`, log a warning through `actionsLogger` and return. Add `minLength: 1` (and optionally a `regex` requiring a leading `/`) to the option, and replace `console.log` with `actionsLogger.error`.

### L5: Variables typed into the custom OSC Address are sent as literal text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:76-81`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L76-L81)

**What goes wrong:** In **Custom: Send message without arguments**, a user who types `/V3/actionGrid/$(internal:custom_grid)/button/row/1/col/1` has the literal text `$(internal:custom_grid)` sent to Vista. Variables only work if the user first switches the field to expression mode.

**Why it happens:** A text field only replaces `$(...)` variables in its normal (value) mode when the option sets `useVariables: true`, and this option doesn't.

**Fix:** add `useVariables: true` to the `address` option. This is the first release, so no upgrade script is needed.

---

## 💡 Nice to Have

### N1: Playback actions show lowercase panel and bank labels

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:162`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L162), [`src/actions.ts:170`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L170), [`src/actions.ts:218`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/9a423738cbcb75c9b4ff8a0519546c7259fdc424/src/actions.ts#L218)

**What goes wrong:** In the **Console: Playback button** and **Console: Playback fader** editors, the labels "panel" and "bank" are lowercase next to "Row", "Column" and "Fader position". Cosmetic only.

**Fix:** change the labels to "Panel" and "Bank".

---

## 📝 Additional Notes

Status of each finding from the [v1.0.0 review](review-chromaq-vista-v1.0.0-20261005-024911.md), checked against v1.0.1 (`9a42373`):

| v1.0.0 finding | Status in v1.0.1 |
| --- | --- |
| C1: package.json repository link still points at the template placeholder | ✅ Fixed: `repository.url` now points at `companion-module-chromaq-vista`, and the validator reports no template differences |
| H1: The connection shows OK before it is listening, even with no Target IP | ✅ Fixed: an empty **Target IP** now sets Bad Config, and OK is only set once the listen port opens |
| H2: Type checking is off for actions, feedbacks and variables | ✅ Fixed: concrete `ActionsSchema`, and `Record<string, never>` for feedbacks and variables |
| H3: Some warnings go to the console instead of the connection log | ✅ Mostly fixed: `client.ts` uses `clientLogger`; one `console.log` remains in the custom message action, now part of [L4](#l4-custom-message-with-an-empty-or-malformed-osc-address-fails-with-only-a-log-line) |
| H4: A search keyword is misspelled | ✅ Fixed: the keyword is now `lighting` |
| H5: Method name updateConifg is misspelled | ✅ Fixed: `updateConifg` is gone; `configUpdated()` calls `connect()` |
| H6: Saving the config can leave the connection with no sockets | ✅ Fixed: `destroy()` clears both fields first and catches a failed close |
| H7: Every message from Vista is written to the connection log | ✅ Fixed: incoming messages are only logged when **Enable verbose logging** is on |
| M1: A rare network socket error can crash the connection | ❌ Still open, now [L1](#l1-a-socket-error-on-the-sending-side-could-crash-the-connection) |
| M2: One stray or garbled packet on the listen port marks the connection as failed | ❌ Still open, now [M1](#m1-a-stray-packet-or-a-busy-listen-port-turns-the-connection-red-and-it-stays-red-while-buttons-still-work) |
| M3: Fractional or out-of-range numbers are sent to Vista, which can crash it | ❌ Still open, now [L3](#l3-fractional-or-out-of-range-grid-panel-bank-row-column-and-softkey-numbers-are-sent-to-vista) |
| L1: Socket errors are passed to the connection status as an object, not text | ❌ Still open, merged into [M1](#m1-a-stray-packet-or-a-busy-listen-port-turns-the-connection-red-and-it-stays-red-while-buttons-still-work) |
| L2: Failed sends are only logged and never reported as a failed action | ✅ Addressed: `send()` now logs before sending and awaits the promise form inside `try/catch` |
| L3: Fader levels and button states are sent as text | Not carried forward: whether Vista accepts text arguments is device behaviour, and the module's choice is trusted |
| L4: Send message without arguments actually sends one empty argument | Not carried forward: the empty-string argument is the maintainer's choice for Vista, and is trusted |
