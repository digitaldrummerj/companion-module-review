# Review: integ-jnior v1.1.0 (follow-up to the v1.0.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-integ-jnior` ([repo](https://github.com/bitfocus/companion-module-integ-jnior)) |
| **Version** | v1.1.0 (`4737a5b`, 2026-10-21) |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous tag** | none published (first release); v1.0.0 was submitted and reviewed but never published |
| **Scope** | `tag` (first release: the whole module) |
| **Language** | TypeScript |
| **Build** | `validate-template.ps1 -RunBuild` reports no findings; `yarn install --immutable`, `yarn package` and `yarn lint` pass; the `package.json` version matches the tag |
| **Prior review** | [v1.0.0 review](review-integ-jnior-v1.0.0-20261005-024911.md) (❌ Changes Required) |
| **Review date** | 2026-10-30 |

This is a follow-up to the [v1.0.0 review](review-integ-jnior-v1.0.0-20261005-024911.md). The module has never been published, so this is still a first release: there is no published tag to diff against, and the whole module was reviewed again. The changes since the unpublished v1.0.0 tag (10 files, +575/-40) were also used to check each earlier finding.

All three blocking findings from v1.0.0 are fixed: the connection now reconnects on its own, the help page is complete, and relay/input feedbacks and presets were added. Most of the earlier non-blocking findings are fixed too; the status of each one is listed under [📝 Additional Notes](#-additional-notes). The findings below are all non-blocking.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | While the module is connected but not yet logged in, the JNIOR does not immediately send a Monitor message that would correct a relay state the module set itself | the module only updates relay states from Monitor messages ([`src/main.ts:275-295`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L275-L295)); when the JNIOR sends them was not checked. When the connection is down, no message can arrive, so that case does not depend on this | [M1](#m1-relay-buttons-and-variables-show-a-state-change-even-when-the-command-was-never-sent) |
| A2 | In Companion 4.3, a preset option written as an expression on a local variable (`{ isExpression: true, value: '$(local:output)' }`) resolves to a number the relay channel and output options accept | Companion's expression and local-variable handling, which is not in the module or the base package | none; this is why the presets were not flagged |

## 📋 Issues

### Non-blocking

- [ ] [M1: Relay buttons and variables show a state change even when the command was never sent](#m1-relay-buttons-and-variables-show-a-state-change-even-when-the-command-was-never-sent)
- [ ] [L1: After one malformed frame, the module stops updating variables and feedbacks while the status stays OK](#l1-after-one-malformed-frame-the-module-stops-updating-variables-and-feedbacks-while-the-status-stays-ok)
- [ ] [L2: A missing password shows as an authentication timeout instead of a configuration error](#l2-a-missing-password-shows-as-an-authentication-timeout-instead-of-a-configuration-error)
- [ ] [L3: A fractional channel from an expression is sent to the device and updates no variable](#l3-a-fractional-channel-from-an-expression-is-sent-to-the-device-and-updates-no-variable)
- [ ] [L4: An invalid port stops the connection without a clear status](#l4-an-invalid-port-stops-the-connection-without-a-clear-status)
- [ ] [N1: Saving new settings does not reset the reconnect back-off](#n1-saving-new-settings-does-not-reset-the-reconnect-back-off)
- [ ] [N2: Line-ending fallback in Console Send Command differs from the option default](#n2-line-ending-fallback-in-console-send-command-differs-from-the-option-default)
- [ ] [N3: Manifest keywords are empty, so the module is harder to find in connection search](#n3-manifest-keywords-are-empty-so-the-module-is-harder-to-find-in-connection-search)

### Notes

- [📝 Additional Notes](#-additional-notes)

---

## 🟡 Medium

### M1: Relay buttons and variables show a state change even when the command was never sent

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:68-84`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L68-L84), [`src/main.ts:72-75`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L72-L75)

**What goes wrong:** Say the JNIOR is unreachable or still logging in, so the connection shows "Connection Failure" or "Connecting". An operator presses a **Close Relay Output 3** preset, which runs **Control: Set Relay Output** with **Command** = Closed. The button still turns yellow through the **Relay Output is Closed** feedback, and `$(integ-jnior:output3State)` changes to `1`, even though nothing was sent to the JNIOR. The only trace is a "Cannot control relay before JMP authentication completes" warning in the log. The button stays wrong until the module reconnects and the JNIOR sends a Monitor message. **Toggle** does the same: each press flips the shown state while the real relay stays as it was.

**Why it happens:** The action writes the new relay state into the variable and refreshes the feedback before it tries to send the command. The send gives up silently when the module is not logged in or not connected, and it doesn't tell the action that nothing went out, so the early update is never undone.

**Evidence:**

```ts
// src/actions.ts:68-84
callback: async (event) => {
	if (event.options.command !== 'Toggle') {
		...
		self.setVariableValues({
			[`output${event.options.channel}State`]: event.options.command === 'Close' ? '1' : '0',
		})
	} else { ... }
	self.sendControl(event.options.command, event.options.channel)
	self.checkFeedbacks('fbkOutputRelayState')
},
```

```ts
// src/main.ts:72-75
if (!this.authenticated) {
	this.log('warn', 'Cannot control relay before JMP authentication completes')
	return
}
```

**Confirm by:** open [`src/actions.ts:68-84`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L68-L84): the variable is set before `sendControl()`. Then open [`src/main.ts:72-75`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L72-L75): `sendControl()` returns nothing and gives up silently when the module is not logged in.

**Fix:** only update the relay state after the command was actually sent. Have `sendControl()` and `sendMessage()` return `true`/`false` (or check that the module is logged in first), and only set `output<N>State` and call `checkFeedbacks()` when the send succeeded. Alternatively, drop the early update and rely on the JNIOR's Monitor message for the state.

---

## 🟢 Low

### L1: After one malformed frame, the module stops updating variables and feedbacks while the status stays OK

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:210-254`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L210-L254) (key line [`src/main.ts:228`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L228))

**What goes wrong:** If the data from the JNIOR ever loses sync (one malformed or wrongly sized message), the module can stop processing every later message while the connection stays up. The input and relay variables, such as `$(integ-jnior:input1State)`, and the **Digital Input is Closed** / **Relay Output is Closed** feedbacks stop updating, but the connection status still shows OK. Only disabling and re-enabling the connection recovers it. The receive buffer also keeps growing for as long as the connection stays open. This only happens after the stream has already lost sync.

**Why it happens:** After a bad message, the parser drops one byte and looks for the next `[`, which marks the start of a message. That `[` can be inside the JSON text, for example the one that starts `"Inputs":[{...`. When the byte after `[` is not a digit or a space, the parser returns the same result as "wait for more data", without dropping the `[`. So every later call finds the same `[` again and waits forever. Waiting only makes sense when the buffer ends right after the `[`; any other non-digit byte means the frame is invalid and should be skipped.

**Fix:** tell "need more bytes" apart from "invalid byte". When a non-digit byte is present after `[`, drop that `[` and keep scanning. Optionally clear the buffer if it grows past a sensible size (for example 1 MB).

```ts
if (index === lengthStart) {
	if (index < this.receiveBuffer.length) {
		this.receiveBuffer = this.receiveBuffer.subarray(1)
		return {}
	}
	return undefined
}
```

### L2: A missing password shows as an authentication timeout instead of a configuration error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:258-263`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L258-L263), [`src/main.ts:103-106`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L103-L106)

**What goes wrong:** If a user saves the connection without filling in **Password**, the module still tries to log in, using the text `undefined` as the password. After 15 seconds the connection shows "Connection Failure: JMP authentication timed out" and keeps retrying, instead of a clear Bad Configuration status that says the password is missing.

**Why it happens:** Before connecting, the module only checks that **Target IP** is filled in. The username and password are put straight into the login hash, so a missing password becomes the word `undefined`.

**Fix:** also check the username and password before connecting, and report Bad Configuration if either is missing. Use `?? ''` when building the login hash.

```ts
if (!this.config.username || !this.secrets.password) {
	this.updateStatus(InstanceStatus.BadConfig, 'Username and password are required')
	return
}
```

### L3: A fractional channel from an expression is sent to the device and updates no variable

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:48-55`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L48-L55), [`src/actions.ts:93-101`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L93-L101), [`src/actions.ts:123-131`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L123-L131), [`src/actions.ts:156-164`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L156-L164), [`src/actions.ts:178-186`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L178-L186)

**What goes wrong:** Suppose a user switches **Relay Channel** in **Control: Set Relay Output** to expression mode, and the expression gives `2.5` (for example `$(internal:some_var)/2`). The module sends channel 2.5 to the JNIOR and writes a variable named `output2.5State` that doesn't exist, so no relay variable or feedback changes. The same applies to the **Input Channel** and **I/O Channel** options of **Pulse**, **Reset Latch**, **Reset Counter** and **Reset Usage**. Typing a value in the normal number box is not affected.

**Why it happens:** The channel number fields have `step: 1` but not `asInteger: true`. Values that come from an expression are only checked against the minimum and maximum, not rounded. `asInteger` is available in base 2.0.4 (`node_modules/@companion-module/base/dist/module-api/input.d.ts:323`).

**Fix:** add `asInteger: true` to every channel number option, in `src/actions.ts` and in the input/output options in `src/feedbacks.ts`.

### L4: An invalid port stops the connection without a clear status

- **Source:** 🔎 v1.0.0 review (L3), carried forward; the code is unchanged
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:101-109`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L101-L109)

**What goes wrong:** If **Target Port** is empty or out of range, the connection never starts and the status gives no useful reason.

**Why it happens:** Only **Target IP** is checked before connecting. Node rejects a bad port with an error (`ERR_SOCKET_BAD_PORT`) when the connection is opened. Since v1.1.0 that happens inside `TCPHelper`'s deferred connect, outside any of the module's handlers, so no status is set.

**Fix:** check the port before connecting and report Bad Configuration if it is invalid.

```ts
const port = this.config.port
if (!Number.isInteger(port) || port < 1 || port > 65535) {
	this.updateStatus(InstanceStatus.BadConfig, 'Target Port must be 1-65535')
	return
}
```

---

## 💡 Nice to Have

### N1: Saving new settings does not reset the reconnect back-off

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:54-60`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L54-L60)

**What goes wrong:** Say a user typed a wrong IP and the module backed off to retrying every 60 seconds. After they fix the IP and save, the first attempt happens right away. But if that attempt fails once (for example because the JNIOR is still booting), the next retry waits 60 seconds instead of 1 second.

**Why it happens:** The retry counter is only reset when a login succeeds. Saving the config starts a new connection without resetting it.

**Fix:** set `this.reconnectAttempt = 0` in `configUpdated()` before calling `initConnection()`.

### N2: Line-ending fallback in Console Send Command differs from the option default

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:215`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L215), [`src/actions.ts:221`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/actions.ts#L221)

**What goes wrong:** No visible effect today. The **Line Ending** dropdown defaults to CR+LF, but the action falls back to CR when the option is missing. Companion checks the dropdown value before the action runs, so the fallback is effectively never used; it only matters if the code changes later.

**Why it happens:** The option has `default: 'crlf'`, but the callback uses `lineEndings[event.options.lineEnding ?? 'cr']`.

**Fix:** use the same value in both places (`?? 'crlf'`), or drop the fallback, since the option is typed as required.

### N3: Manifest keywords are empty, so the module is harder to find in connection search

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/companion/manifest.json)

**What goes wrong:** When adding a connection, a user who searches for "relay", "GPIO" or "JMP" won't find the JNIOR module. Only a search on its name or manufacturer finds it.

**Why it happens:** `"keywords": []` in the manifest.

**Fix:** add a few search terms, for example `["relay", "gpio", "io", "automation", "jmp", "janos"]`.

---

## 📝 Additional Notes

Status of the [v1.0.0 review](review-integ-jnior-v1.0.0-20261005-024911.md) findings in v1.1.0:

- **H1** (connection never recovers): ✅ fixed. The module now uses `TCPHelper` with its own reconnect timer (1 s up to 60 s), cleared in `destroyConnection()` ([`src/main.ts:101-179`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/src/main.ts#L101-L179)).
- **H2** (help page incomplete): ✅ fixed. [`companion/HELP.md`](https://github.com/bitfocus/companion-module-integ-jnior/blob/4737a5b2fdb9729b15dda48829834d5a52dc2592/companion/HELP.md) now has configuration, actions, variables and troubleshooting sections.
- **H3** (no feedbacks): ✅ fixed. **Digital Input is Closed** and **Relay Output is Closed** were added, refreshed on each Monitor message and rebuilt in `configUpdated()`.
- **L1** (failure reason replaced by "Connection closed"): ✅ fixed. The status now comes from `TCPHelper`'s status change, which carries the error message.
- **L2** (no connect timeout or keepalive): ✅ fixed. 15 s connect and login timeouts and TCP keepalive were added.
- **L3** (invalid port): still open. Carried forward as [L4](#l4-an-invalid-port-stops-the-connection-without-a-clear-status).
- **L4** (variables only for channels 1-8): ✅ fixed. Variables now cover inputs 1-28 and relays 1-20.
- **L5** (variables go blank on partial Monitor messages): not carried forward. It depended on the JNIOR sending partial Monitor messages, which is device behaviour; the maintainer's knowledge of the device is trusted.
- **L6** (variables not resolved in console Command): ✅ fixed. `useVariables: true` was added and the default is now empty.
- **L7** (Line Ending ids are control characters): ✅ fixed. The ids are now `cr`, `lf` and `crlf`.
- **L8** (console session not confirmed open): not carried forward. It depended on whether JANOS drops commands sent back to back, which is device behaviour; the maintainer's knowledge of the device is trusted.
- **N1** (no presets): ✅ fixed. Open, Close and Pulse presets for relays 1-20 were added, each with the relay-state feedback.
