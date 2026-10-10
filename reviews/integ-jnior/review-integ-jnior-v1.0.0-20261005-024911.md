# Review: integ-jnior v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-integ-jnior` ([repo](https://github.com/bitfocus/companion-module-integ-jnior)) |
| **Version** | v1.0.0 (`699673c`, 2026-09-29) |
| **Previous tag** | none (first release) |
| **Scope:** | tag (first release: the whole module) |
| **Language** | TypeScript |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned for API 2.0) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Build** | `validate-template.ps1 -RunBuild` reports no template findings; `yarn install --immutable`, `yarn package` and `yarn lint` pass; the `package.json` version matches the tag |
| **Review date** | 2026-10-08 |

This is the module's first release, so there is no previous tag to compare against. The whole module (`src/`, `companion/` and the build config) was reviewed, and every finding is new.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [H1: The connection never recovers after the JNIOR drops off the network](#h1-the-connection-never-recovers-after-the-jnior-drops-off-the-network)
- [ ] [H2: The help page leaves out setup steps, most actions and most variables](#h2-the-help-page-leaves-out-setup-steps-most-actions-and-most-variables)
- [ ] [H3: No feedbacks to show relay and input state on buttons](#h3-no-feedbacks-to-show-relay-and-input-state-on-buttons)

### Non-blocking

- [ ] [L1: The reason for a connection failure is replaced by Connection closed](#l1-the-reason-for-a-connection-failure-is-replaced-by-connection-closed)
- [ ] [L2: An unreachable or silently vanished JNIOR is noticed late or not at all](#l2-an-unreachable-or-silently-vanished-jnior-is-noticed-late-or-not-at-all)
- [ ] [L3: An invalid port stops the connection without a clear status](#l3-an-invalid-port-stops-the-connection-without-a-clear-status)
- [ ] [L4: Variables only cover inputs 1-8 and relays 1-8](#l4-variables-only-cover-inputs-1-8-and-relays-1-8)
- [ ] [L5: Variables can go blank when a Monitor message leaves fields out](#l5-variables-can-go-blank-when-a-monitor-message-leaves-fields-out)
- [ ] [L6: Variables typed in the console Command field are sent as literal text](#l6-variables-typed-in-the-console-command-field-are-sent-as-literal-text)
- [ ] [L7: The Line Ending choices cannot be typed in expression mode](#l7-the-line-ending-choices-cannot-be-typed-in-expression-mode)
- [ ] [L8: Console commands may be lost because the session is not confirmed open](#l8-console-commands-may-be-lost-because-the-session-is-not-confirmed-open)
- [ ] [N1: No presets for relay and input buttons](#n1-no-presets-for-relay-and-input-buttons)

---

## 🟠 High

### H1: The connection never recovers after the JNIOR drops off the network

- **Source:** 🔎 protocol reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:93-118`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L93-L118)

**What goes wrong:** If the JNIOR reboots, a switch is power-cycled, or the network blips, the connection goes to "Disconnected — Connection closed" and stays there. The same happens if the JNIOR is off when Companion starts. From then on every **Control: Set Relay Output**, **Control: Pulse Relay Output** and other button does nothing, and the log only says "Cannot control relay before JMP authentication completes". The connection only comes back when someone opens the connection settings and saves them, or disables and re-enables it. In a show, that means relays silently stop responding after any short outage.

**Why it happens:** The module opens its own raw TCP connection (Node's `net.Socket`). A raw socket never reconnects by itself. Companion's base library has a helper for this, `TCPHelper`, which reconnects automatically, but the module doesn't use it. The module's handlers for "connection error" and "connection closed" only update the status, and a new connection is only opened at startup (`init()`) and when the config is saved (`configUpdated()`). Until a new connection logs in, the module's "authenticated" flag stays false, and every action stops at that check.

**Evidence:**

```ts
// src/main.ts:93-118
	private initConnection(): void {
		this.destroyConnection()
		if (!this.config.host) {
			this.updateStatus(InstanceStatus.BadConfig, 'Target IP is required')
			return
		}

		this.updateStatus(InstanceStatus.Connecting)
		this.socket = new Socket()
		...
		this.socket.on('error', (error) => {
			this.log('error', `Connection error: ${error.message}`)
			this.updateStatus(InstanceStatus.ConnectionFailure, error.message)
		})
		this.socket.on('close', () => {
			this.authenticated = false
			this.updateStatus(InstanceStatus.Disconnected, 'Connection closed')
		})
		this.socket.connect(this.config.port, this.config.host)
	}
```

```ts
// src/main.ts:40 and src/main.ts:51 (the only two callers of initConnection)
		this.initConnection()
```

```ts
// src/main.ts:65-67
		if (!this.authenticated) {
			this.log('warn', 'Cannot control relay before JMP authentication completes')
			return
```

`grep -rnE "setTimeout|setInterval|reconnect|TCPHelper|setKeepAlive" src/` finds no matches.

**Confirm by:** open [`src/main.ts:93-118`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L93-L118). The `close` and `error` handlers only set the status, and `initConnection()` is called only from `init()` ([`src/main.ts:40`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L40)) and `configUpdated()` ([`src/main.ts:51`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L51)).

**Fix:** reconnect automatically after the connection closes, waiting a little longer after each failed attempt (for example 1 s, 2 s, 4 s, up to 30 s). Reset the wait once the JNIOR sends `Authenticated`, and cancel any pending attempt in `destroyConnection()`. Ignore the `close` event of a socket the module closed on purpose, so `destroy()` and `configUpdated()` don't trigger a reconnect.

```ts
private reconnectTimer: NodeJS.Timeout | undefined
private reconnectDelay = 1000

// in initConnection()
const socket = new Socket()
this.socket = socket
socket.on('close', () => {
	if (socket !== this.socket) return // a socket we closed on purpose
	this.authenticated = false
	this.updateStatus(InstanceStatus.Disconnected, 'Connection closed')
	this.reconnectTimer = setTimeout(() => this.initConnection(), this.reconnectDelay)
	this.reconnectDelay = Math.min(this.reconnectDelay * 2, 30_000)
})

// in destroyConnection()
clearTimeout(this.reconnectTimer)
this.reconnectTimer = undefined

// when the 'Authenticated' message arrives
this.reconnectDelay = 1000
```

Switching to the base library's `TCPHelper`, which reconnects on its own, is an equally good fix.

### H2: The help page leaves out setup steps, most actions and most variables

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/companion/HELP.md)

**What goes wrong:** A user setting the module up from the help page can't tell what to fill in or what the module offers:

- It doesn't describe the config fields (**Target IP**, **Target Port** 9220, **Username**, **Password**) or say whether JMP login must be enabled on the JNIOR.
- It doesn't mention **Reset Latch**, **Reset Counter** or **Reset Usage**, or explain how channels are numbered.
- It says variables exist for the relays only, but inputs (state and count) have them too, and both only cover channels 1-8.
- Typo: "intial".

**Evidence:**

```markdown
<!-- companion/HELP.md:5 (the only description of what the module does) -->
Version 1.0 of this module includes basic utility control of the JNIOR Relay I/O ports. You can send relay open, close, toggle, and pulse commands from Companion to the JNIOR as part of a broader automation system. Variables exist for each of the JNIOR's relays, and are queried from the monitor message sent by the JNIOR on intial connection.
```

**Confirm by:** open [`companion/HELP.md`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/companion/HELP.md): its nine lines have no configuration section, no action list and no variable list.

**Fix:** add short Configuration, Actions and Variables sections.

### H3: No feedbacks to show relay and input state on buttons

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:5-7`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/feedbacks.ts#L5-L7), [`src/main.ts:47-52`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L47-L52)

**What goes wrong:** Users can't light a button when a relay is closed or an input is active, so they can't see the JNIOR's state from Companion. A first release is expected to provide feedbacks as well as actions.

**Why it happens:** The feedback list is empty, even though the module already tracks input and relay state from Monitor messages (`updateMonitor()`).

**Evidence:**

```ts
// src/feedbacks.ts:3-7
export type FeedbacksSchema = Record<never, never>

export function UpdateFeedbacks(self: ModuleInstance): void {
	self.setFeedbackDefinitions({})
}
```

```ts
// src/main.ts:47-52 (only the actions are rebuilt when the config is saved)
	async configUpdated(config: ModuleConfig, secrets: ModuleSecrets): Promise<void> {
		this.config = config
		this.secrets = secrets
		this.updateActions()
		this.initConnection()
	}
```

**Confirm by:** open [`src/feedbacks.ts:5-7`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/feedbacks.ts#L5-L7): `setFeedbackDefinitions({})` registers no feedbacks.

**Fix:** add boolean feedbacks such as "Relay N closed" and "Input N active", and declare them in `FeedbacksSchema`.

- Call `checkFeedbacks()` from `updateMonitor()` so buttons update when the JNIOR reports a change.
- In `configUpdated()`, call `this.updateFeedbacks()` next to `this.updateActions()`, so both are rebuilt with the latest config.

---

## 🟢 Low

### L1: The reason for a connection failure is replaced by Connection closed

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:109-116`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L109-L116)

**What goes wrong:** When the connection fails, the status shows "Disconnected — Connection closed" instead of the useful reason (for example `ECONNREFUSED` when the port is wrong). The reason is only in the log.

**Why it happens:** Node always reports "closed" right after "error", and the "closed" handler overwrites the Connection Failure status that the "error" handler just set.

**Fix:** use the `hadError` argument of the `close` event, and don't overwrite a failure status that was just set.

### L2: An unreachable or silently vanished JNIOR is noticed late or not at all

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:101`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L101), [`src/main.ts:117`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L117)

**What goes wrong:** If the JNIOR's IP doesn't answer, the connection sits on "Connecting" until the operating system gives up, which can take minutes. If the JNIOR loses power or its cable is pulled without closing the connection, the module may never notice, so the status stays OK and the reconnect from H1 would never start.

**Why it happens:** The socket has no connect timeout and no TCP keepalive (a periodic check that the other end is still there).

**Fix:** turn on keepalive and add a connect/login timeout that closes the socket when it fires.

```ts
this.socket.setKeepAlive(true, 10_000)
this.socket.setTimeout(15_000)
this.socket.on('timeout', () => this.socket?.destroy())
```

### L3: An invalid port stops the connection without a clear status

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:95-117`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L95-L117)

**What goes wrong:** If **Target Port** is empty or out of range, the connection never starts and the status gives no useful reason.

**Why it happens:** Only **Target IP** is checked before connecting. Node's `connect()` throws an error straight away for a bad port (`ERR_SOCKET_BAD_PORT`), and nothing catches it in `init()` or `configUpdated()`, so no status is set.

**Fix:** check the port before connecting and report Bad Config if it is invalid.

```ts
const port = this.config.port
if (!Number.isInteger(port) || port < 1 || port > 65535) {
	this.updateStatus(InstanceStatus.BadConfig, 'Target Port must be 1-65535')
	return
}
```

### L4: Variables only cover inputs 1-8 and relays 1-8

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:34-64`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/variables.ts#L34-L64), [`src/main.ts:217-227`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L217-L227)

**What goes wrong:** The actions accept up to 12 inputs, 20 relays and 24 I/O channels, but variables exist only for inputs 1-8 and relays 1-8. On a JNIOR with more I/O (or with expansion modules, if those are reported in the same Monitor lists), the state of the higher channels is not available.

**Why it happens:** The variable definitions and both loops that fill them from Monitor messages are fixed at 8.

**Fix:** define variables up to the action maximums, or build the definitions from the size of the first Monitor message's lists and call `setVariableDefinitions()` again.

### L5: Variables can go blank when a Monitor message leaves fields out

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:210-228`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L210-L228)

**What goes wrong:** If a Monitor message from the JNIOR doesn't include the model, version, serial number, or the input/output lists, the matching variables (**JNIOR Model**, **JANOS Version**, **Serial Number**, the input and relay states) are set to blank until a message that includes them arrives. Whether the JNIOR ever sends such partial messages was not checked.

**Why it happens:** All 28 variables are rewritten on every Monitor message, and a missing field is written as an empty string.

**Fix:** only set a variable when its field is present in the message (`!== undefined`).

### L6: Variables typed in the console Command field are sent as literal text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:180-185`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/actions.ts#L180-L185)

**What goes wrong:** In **Console: Send Command**, typing `$(internal:time_hms)` into **Command** sends the text `$(internal:time_hms)` to the JNIOR instead of the current time. The default command, `Hello World`, is also not a useful JNIOR console command.

**Why it happens:** Companion only fills in variables in a text field when the field is declared with `useVariables: true`, and this field isn't.

**Fix:** add `useVariables: true` to the field, and use an empty default or a real command.

### L7: The Line Ending choices cannot be typed in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:187-196`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/actions.ts#L187-L196)

**What goes wrong:** In API 2.0 a user can switch any option, including **Line Ending**, to expression mode and type the value. For this option the values are the raw carriage-return and line-feed characters, which can't practically be typed there.

**Why it happens:** The dropdown uses the control characters themselves (`'\r'`, `'\n'`, `'\r\n'`) as the stored choice ids.

**Fix:** use readable ids (`'cr'`, `'lf'`, `'crlf'`) and map them to the characters in the callback, or set `disableAutoExpression: true` on the field. This first release is the cheapest time to change the ids, because no saved buttons use them yet.

### L8: Console commands may be lost because the session is not confirmed open

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:78-91`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/main.ts#L78-L91)

**What goes wrong:** On a slow or busy JNIOR, a **Console: Send Command** button may do nothing, and the operator can't tell, because console replies are never read or logged. Whether JANOS actually drops commands sent this way was not checked on a device.

**Why it happens:** The module sends "open console", the command, and "close console" back to back, without waiting for the JNIOR to confirm that the console session is open.

**Fix:** send the command once the JNIOR confirms the console is open, and close the session after the output (or a short delay). At minimum, log console replies at debug level. Check the exact sequence against the JMP specification.

---

## 💡 Nice to Have

### N1: No presets for relay and input buttons

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:4`](https://github.com/bitfocus/companion-module-integ-jnior/blob/699673c5bb84e66a444d250df6f093d32344b86d/src/presets.ts#L4)

**What goes wrong:** There are no ready-made buttons in the preset list, so every button has to be built by hand.

**Fix:** add a few presets, such as Toggle and Pulse buttons per relay, with the relay-state feedback from H3.
