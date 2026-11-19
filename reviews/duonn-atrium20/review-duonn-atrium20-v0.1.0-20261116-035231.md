# Review: duonn-atrium20 v0.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-duonn-atrium20` |
| **Scope** | `tag` |
| **Version** | `v0.1.0` ([`26ba9ff`](https://github.com/bitfocus/companion-module-duonn-atrium20/commit/26ba9ff2700ab3f5ae4358d164d7300102f01fa7)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.0, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Reviewed** | 2026-11-16 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: "Fader: nudge up/down" with a negative step opens a fully closed fader to minus 91 dB](#m1-fader-nudge-updown-with-a-negative-step-opens-a-fully-closed-fader-to-minus-91-db)
- [ ] [M2: On/off/toggle choices can be switched to expression mode; lock them before the first release](#m2-onofftoggle-choices-can-be-switched-to-expression-mode-lock-them-before-the-first-release)
- [ ] [L1: The connection stays green for minutes after the console loses power or its network cable](#l1-the-connection-stays-green-for-minutes-after-the-console-loses-power-or-its-network-cable)
- [ ] [L2: High-pass or EQ band on/off right after connecting resets the frequency to 100 Hz or 1000 Hz](#l2-high-pass-or-eq-band-onoff-right-after-connecting-resets-the-frequency-to-100-hz-or-1000-hz)
- [ ] [L3: "Input: rename channel" does nothing and logs nothing while the console is offline](#l3-input-rename-channel-does-nothing-and-logs-nothing-while-the-console-is-offline)
- [ ] [L4: Mute and fader targets are typed as plain strings and cast in the callbacks](#l4-mute-and-fader-targets-are-typed-as-plain-strings-and-cast-in-the-callbacks)
- [ ] [N1: Every connection failure says "No answer from" the console, and the real reason is only in the debug log](#n1-every-connection-failure-says-no-answer-from-the-console-and-the-real-reason-is-only-in-the-debug-log)
- [ ] [N2: "EQ: high-pass filter" always shows "Frequency (Hz)", even when the field is ignored](#n2-eq-high-pass-filter-always-shows-frequency-hz-even-when-the-field-is-ignored)
- [ ] [N3: Variables typed into the "Input: rename channel" name are sent to the console as literal text](#n3-variables-typed-into-the-input-rename-channel-name-are-sent-to-the-console-as-literal-text)
- [ ] [N4: Every state change re-sends all variables and re-checks every feedback](#n4-every-state-change-re-sends-all-variables-and-re-checks-every-feedback)
- [ ] [NR1: Use the template's `~2.1.3` range for `@companion-module/base` instead of the exact 2.1.0 pin](#nr1-use-the-templates-213-range-for-companion-modulebase-instead-of-the-exact-210-pin)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: "Fader: nudge up/down" with a negative step opens a fully closed fader to minus 91 dB

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:73-79`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L73-L79)

**What goes wrong:** An operator presses the "CH1 fader to -inf" preset, then the "CH1 fader -1 dB" preset (or any "Fader: nudge up/down" action with Step = -1). The console fader moves **up** from -inf to -91 dB, and `$(atrium:ch1_fader)` changes from `-inf` to `-91.0`. With Step = -20 it lands at -110 dB. -91 dB is practically inaudible, but a "down" button has moved the fader off its fully closed position, which an operator does not expect. Running the module's own scale functions gives raw 290 (-91 dB) for step -1.

**Why it happens:** When the fader is at -inf (raw value 0), the callback starts from -90 dB so that a positive nudge can leave -inf. It then adds the step whatever its sign, so a negative step gives -90 plus the step, which is still above -inf.

**Evidence:**

```ts
// src/actions.ts:73-79
			callback: (e) => {
				const id = ids.fader(e.options.target as FaderTarget)
				const cur = self.value(id)
				if (cur === undefined) return self.log('warn', 'Fader level not read yet, try again in a moment')
				const now = cur === 0 ? -90 : scale.faderFromRaw(cur)
				self.set(id, scale.faderToRaw(now + e.options.step))
			},
```

**Fix:** use the -90 dB starting point only for positive steps, and leave a fully closed fader alone when the step is zero or negative. Also check whether -89 dB is the right first stop when nudging up from -inf (the lowest real step is -119.9 dB, raw 1).

```ts
if (cur === 0 && e.options.step <= 0) return // already fully down
const now = cur === 0 ? -90 : scale.faderFromRaw(cur)
```

### M2: On/off/toggle choices can be switched to expression mode; lock them before the first release

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:26-27`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L26-L27)

**What goes wrong:** Every action with an on/off/toggle choice ("Mute: channel, aux or main" > Mute, "DCA: on/off" > State, "EQ: on/bypass" > EQ, "EQ: high-pass filter" > State, "EQ band: on/off" > State) shows the expression toggle on a field that only makes sense as a fixed choice. If a user types an expression that returns anything other than one of the choices (for example `1` or `true`), Companion skips the action and the button does nothing. Locking the field later is not free: the base typings warn that adding the lock to an option that is already in use breaks any expressions users have saved. Before the first publication it costs nothing.

**Why it happens:** The shared `mode()` helper builds the dropdown without `disableAutoExpression: true`, the setting that hides the expression toggle. The v2 compliance rules recommend it for on/off/toggle fields. The base typings (`node_modules/@companion-module/base/dist/module-api/input.d.ts:46-49`) confirm that an invalid expression value makes Companion skip the action entirely.

**Evidence:**

```ts
// src/actions.ts:26-27
const mode = (label: string, choices = ON_OFF_TOGGLE) =>
	({ id: 'mode', type: 'dropdown', label, choices, default: 'toggle' }) as const
```

**Fix:** add `disableAutoExpression: true` to the object the `mode()` helper returns, before v0.1.0 is published. This also lets an `isVisibleExpression` reference `$(options:mode)` (see [N2](#n2-eq-high-pass-filter-always-shows-frequency-hz-even-when-the-field-is-ignored)).

```ts
const mode = (label: string, choices = ON_OFF_TOGGLE) =>
	({ id: 'mode', type: 'dropdown', label, choices, default: 'toggle', disableAutoExpression: true }) as const
```

## 🟢 Low

### L1: The connection stays green for minutes after the console loses power or its network cable

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/socket.ts:47-48`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/socket.ts#L47-L48)

**What goes wrong:** Say the console loses power at the wall, or someone pulls its network cable. The Duonn Atrium connection in Companion's Connections list stays green (OK) for minutes ([A1](#-assumptions-to-confirm)): on a Linux host such as a Companion Pi, roughly 15 minutes. During that time "Mute: channel, aux or main" and "Fader: set level" buttons do nothing on the console, the log does not show "Not connected to the console, command dropped", and the mute feedbacks and `$(atrium:ch1_fader)`-style variables keep their last values. A graceful close (a console reboot that resets the connection, or a refused connection) is detected correctly; only a silent loss of the console is affected.

**Why it happens:** The module asks the socket to time out after 10 seconds of inactivity, but Node counts the module's own writes as activity, not only replies. Once connected, the module sends a poll every second, so the 10-second timeout never fires. The reviewers reproduced this in Node: a socket with a 1.5 s timeout that writes every 300 ms to a silent peer never times out. Nothing else checks that the console is still replying, so the dead connection is only noticed when the operating system gives up retransmitting.

**Evidence:**

```ts
// src/socket.ts:47-48
		sock.setTimeout(10000)
		sock.on('timeout', () => sock.destroy(new Error('timeout')))
// src/main.ts:22
const POLL_MS = 1000
```

**Fix:** add a reply watchdog. Record when the console last replied, and when nothing has come back for about 5 seconds (the console's own keepalive window, per the comment at [`src/main.ts:21`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/main.ts#L21)), drop the connection through the existing reconnect path. That shows Connection Failure and starts the 5-second reconnect. Keep `setTimeout(10000)` as the connect and handshake timeout.

```ts
private lastRx = 0
// in the open callback and in onMessage():
this.lastRx = Date.now()
// at the top of poll():
if (Date.now() - this.lastRx > 5000) return this.scheduleReconnect()
```

### L2: High-pass or EQ band on/off right after connecting resets the frequency to 100 Hz or 1000 Hz

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:37-40`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L37-L40), [`src/actions.ts:139-144`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L139-L144), [`src/actions.ts:193-199`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L193-L199)

**What goes wrong:** Say CH12's high-pass is set to 80 Hz and switched off on the console. Right after Companion connects (or after the connection settings are saved), the operator presses the "CH12 HPF" preset, or runs "EQ: high-pass filter" with State = "On (keep frequency)". The high-pass comes on at 100 Hz instead of 80 Hz, and the console's setting is lost. "Off" in the same window also writes 100 Hz. "EQ band: on/off" does the same with 1000 Hz, wiping the band's frequency. The window is real: the module reads 20 values per second, so the first full read takes about 16 seconds, and CH16's filters are read about 14 seconds after connecting.

**Why it happens:** When the current value has not been read yet, the shared on/off helper (`withFlag`) falls back to a hard-coded frequency and sends it as a full value. The nudge actions ("Fader: nudge up/down", "Input: nudge gain", "EQ band: nudge gain") refuse in the same situation with "not read yet, try again in a moment"; this helper does not. Saving the connection settings clears the stored values, so the window reopens after every save.

**Evidence:**

```ts
// src/actions.ts:37-40
	const withFlag = (id: number, on: boolean, fallbackHz: number): void => {
		const cur = self.value(id) ?? fallbackHz | OFF_FLAG
		self.set(id, on ? cur & ~OFF_FLAG : cur | OFF_FLAG)
	}
```

**Fix:** when the value hasn't been read yet, log a warning and skip the command instead of sending a default frequency, the same way the nudge actions do.

```ts
const withFlag = (id: number, on: boolean): void => {
	const cur = self.value(id)
	if (cur === undefined) return self.log('warn', 'Filter state not read yet, try again in a moment')
	self.set(id, on ? cur & ~OFF_FLAG : cur | OFF_FLAG)
}
```

### L3: "Input: rename channel" does nothing and logs nothing while the console is offline

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:94-96`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/main.ts#L94-L96)

**What goes wrong:** While the connection is red or still connecting, pressing a button with "Input: rename channel" (Channel CH3, Name "Pastor") does nothing, and nothing appears in the log. Every other action logs "Not connected to the console, command dropped" in the same situation, so the user can't tell the rename was lost.

**Why it happens:** The general send path checks that the connection is open and logs a warning before sending. The rename path skips that check, and the socket's send silently discards the frame when the connection isn't open ([`src/socket.ts:62-64`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/socket.ts#L62-L64)).

**Evidence:**

```ts
// src/main.ts:94-96
	rename(ch: number, name: string): void {
		this.socket?.send(renameFrame(ch, name))
	}
```

**Fix:** use the same connection check as `set()` in `rename()`.

```ts
rename(ch: number, name: string): void {
	if (!this.socket?.isOpen) {
		this.log('warn', 'Not connected to the console, command dropped')
		return
	}
	this.socket.send(renameFrame(ch, name))
}
```

### L4: Mute and fader targets are typed as plain strings and cast in the callbacks

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:6-7`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L6-L7), [`src/actions.ts:54`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L54), [`src/actions.ts:65`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L65), [`src/actions.ts:74`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L74), [`src/feedbacks.ts:7`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/feedbacks.ts#L7), [`src/feedbacks.ts:24`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/feedbacks.ts#L24)

**What goes wrong:** Users see no difference: Companion already rejects values that aren't in the dropdown choices, so the casts are safe at runtime. But the casts hide from the compiler any mismatch between the dropdown ids and the protocol's target types, so a typo in a choice id would only show up on a real console.

**Why it happens:** The action and feedback schemas declare the Target option as `string`, so each callback has to cast it (`as MuteTarget` / `as FaderTarget`). The v2 rules note that option casts usually mean the schema is looser than it should be.

**Fix:** type the schema options as `target: MuteTarget` / `target: FaderTarget` (actions and the "Mute: channel, aux or main is muted" feedback), type `MUTE_TARGETS` / `FADER_TARGETS` as `DropdownChoice<MuteTarget>[]` / `DropdownChoice<FaderTarget>[]`, then remove the casts.

## 💡 Nice to Have

### N1: Every connection failure says "No answer from" the console, and the real reason is only in the debug log

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:112-113`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/main.ts#L112-L113), [`src/main.ts:127-130`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/main.ts#L127-L130)

**What goes wrong:** Whether the user entered the wrong port (for example 80, where the console's web page answers instead of the WebSocket server), the console refused the connection, or the IP belongs to another device, the connection always shows "Connection Failure: No answer from 192.168.1.10". The actual cause ("WebSocket handshake refused", "connect ECONNREFUSED", "timeout") is logged only at debug level, so with the default log level a user can't tell a wrong port from an unreachable console.

**Why it happens:** The socket error callback only writes a debug log line, and the reconnect step always sets the fixed status text with the host name, without the last error.

**Fix:** keep the last socket error and show it in the Connection Failure status, falling back to the current text. Optionally log a handshake refusal once at `warn`, not on every 5-second retry.

```ts
error: (err) => {
	this.lastError = err.message
	this.log('debug', `Socket error: ${err.message}`)
},
// in scheduleReconnect():
this.updateStatus(InstanceStatus.ConnectionFailure, this.lastError ?? `No answer from ${this.config.host}`)
```

### N2: "EQ: high-pass filter" always shows "Frequency (Hz)", even when the field is ignored

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:131-137`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L131-L137)

**What goes wrong:** In "EQ: high-pass filter", the "Frequency (Hz)" field is always shown, but it is only used when State is "On at frequency". A user who picks "Toggle" and sets 400 Hz could expect the filter to come on at 400 Hz, but it comes back at its previous frequency.

**Why it happens:** The frequency option has no visibility rule (`isVisibleExpression`). Such a rule can only reference a field that has `disableAutoExpression: true`, which the State field doesn't have yet.

**Fix:** after adding `disableAutoExpression: true` to the State field ([M2](#m2-onofftoggle-choices-can-be-switched-to-expression-mode-lock-them-before-the-first-release)), add `isVisibleExpression: "$(options:mode) == 'set'"` to the high-pass `freq` option.

### N3: Variables typed into the "Input: rename channel" name are sent to the console as literal text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:204`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/actions.ts#L204)

**What goes wrong:** If a user types `$(internal:custom_presenter)` into the Name field, as most Companion text fields allow, the console channel is renamed to the literal text `$(internal:custom_` (the first 16 characters), not the variable's value. Variables only work if the user first switches the field to expression mode.

**Why it happens:** The Name text field doesn't set `useVariables: true`. In API v2, only text fields with that flag resolve `$(...)` variables in normal (non-expression) mode.

**Fix:** add `useVariables: true` to the `name` text field. Companion then resolves variables before the callback runs, so no callback change is needed.

### N4: Every state change re-sends all variables and re-checks every feedback

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:145-160`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/src/main.ts#L145-L160)

**What goes wrong:** No visible effect in normal use. Each poll reply or console change that alters any value rebuilds and sends the full set of about 330 variables and re-runs every feedback on every button. When an operator rides a fader on the console, every change message triggers a full refresh. That is wasted work, which may matter on low-power Companion hosts with many buttons.

**Why it happens:** The update step tracks whether anything changed, but not which values, so the deferred refresh always calls `setVariableValues()` with every variable and `checkAllFeedbacks()` with no filter.

**Fix:** collect the changed ids in `apply()`, send only the variables derived from them (with an id-to-variable map built next to `allIds()`), and call `checkFeedbacks('muted')`, `checkFeedbacks('dca_off')` and so on only for the feedback types whose ids changed.

## 🔮 Next Release

### NR1: Use the template's `~2.1.3` range for `@companion-module/base` instead of the exact 2.1.0 pin

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:26`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/package.json#L26)

**What goes wrong:** Companion users see no difference today. The module is built against version 2.1.0 of Companion's module library, and because the version is pinned exactly, it never picks up the 2.1.x patch releases (2.1.1 to 2.1.3) that the official TypeScript template targets. A module that differs from its template is harder to troubleshoot and maintain, so match the template in the next release.

**Why it happens:** `package.json` names the dependency as an exact version, and an older patch than the template's tilde range (`~2.1.3`, which accepts any 2.1.x from 2.1.3 up). So `yarn install` locks 2.1.0, as `yarn.lock` shows. The rest of `package.json` matches the template line for line, so this is the only difference there.

**Evidence:**

```json
// companion-modules-reviewing/companion-module-duonn-atrium20/package.json:25-27 (at v0.1.0)
	"dependencies": {
		"@companion-module/base": "2.1.0"
	},
```

```json
// companion-module-templates/companion-module-template-ts/package.json:25-27 (main @ e0d42b7)
	"dependencies": {
		"@companion-module/base": "~2.1.3"
	},
```

```text
// companion-modules-reviewing/companion-module-duonn-atrium20/yarn.lock:30-32
"@companion-module/base@npm:2.1.0":
  version: 2.1.0
  resolution: "@companion-module/base@npm:2.1.0"
```

```text
// git -C companion-module-template-ts log -L25,27:package.json (commit 63b0c7d "chore: update module-base to 2.1")
-		"@companion-module/base": "2.0.4"
+		"@companion-module/base": "~2.1.3"
```

**Confirm by:** open [`package.json:26`](https://github.com/bitfocus/companion-module-duonn-atrium20/blob/26ba9ff2700ab3f5ae4358d164d7300102f01fa7/package.json#L26), which reads `"2.1.0"`, and the same line in `companion-module-templates/companion-module-template-ts/package.json`, which reads `"~2.1.3"`.

**Fix:** use the template's version range, then refresh the lockfile and rebuild. Run `yarn install` so `yarn.lock` moves to 2.1.3, run `yarn build`, and commit both files. The module uses no advanced feedbacks, no action `subscribe` and no static-text action options, so the stricter 2.1.3 typings should not need code changes ([A2](#-assumptions-to-confirm)).

```json
	"dependencies": {
		"@companion-module/base": "~2.1.3"
	},
```

## 📝 Additional Notes

- This is the module's first release, so there is no published version to diff against: the whole module was reviewed, and every finding is classified 🆕 NEW.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the console disappears without closing the TCP connection (power cut, cable pulled), the host operating system reports the connection dead only after its TCP retransmission timeout: about 15 minutes with Linux defaults (`tcp_retries2=15`), shorter on macOS and Windows. So how long the status stays green depends on the OS, not on the module | General TCP behaviour. The Node part (the module's own writes reset the socket's idle timer) was reproduced locally with Node 22; the OS give-up time was not measured | [L1](#l1-the-connection-stays-green-for-minutes-after-the-console-loses-power-or-its-network-cable) |
| A2 | Moving to `@companion-module/base` ~2.1.3 needs no code changes, because the module uses none of the APIs whose typings changed in 2.1.1 to 2.1.3 (advanced feedbacks, action `subscribe`, static-text action options) | Code inspection and the v2.1 compliance reference's list of 2.1.3 typing changes; only 2.1.0 is installed in the clone, so the module was not compiled against the 2.1.3 typings | [NR1](#nr1-use-the-templates-213-range-for-companion-modulebase-instead-of-the-exact-210-pin) |
