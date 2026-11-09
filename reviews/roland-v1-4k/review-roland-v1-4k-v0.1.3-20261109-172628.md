# Review: companion-module-roland-v1-4k v0.1.3

| Field | Value |
| --- | --- |
| **Module** | [companion-module-roland-v1-4k](https://github.com/bitfocus/companion-module-roland-v1-4k) |
| **Scope** | `tag` |
| **Version** | v0.1.3 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Commit** | [`8161abb`](https://github.com/bitfocus/companion-module-roland-v1-4k/tree/8161abb215a7a7f8ca85834289dba775f792d9aa) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Status polling doubles after the switcher closes the session, and the extra poll timer survives Save](#m1-status-polling-doubles-after-the-switcher-closes-the-session-and-the-extra-poll-timer-survives-save)
- [ ] [M2: Memory 6 to 8 Name variables never fill in, and none fill in at a 1000 ms polling rate](#m2-memory-6-to-8-name-variables-never-fill-in-and-none-fill-in-at-a-1000-ms-polling-rate)
- [ ] [M3: The switcher's network password is shown in plain text in the connection settings](#m3-the-switchers-network-password-is-shown-in-plain-text-in-the-connection-settings)
- [ ] [M4: Still-image and tally options use raw device codes, so expression mode is hard to use](#m4-still-image-and-tally-options-use-raw-device-codes-so-expression-mode-is-hard-to-use)
- [ ] [L1: Tally State feedback set to PGM goes dark while the source is on both PGM and PST](#l1-tally-state-feedback-set-to-pgm-goes-dark-while-the-source-is-on-both-pgm-and-pst)
- [ ] [L2: Tally variables are not updated when the switcher pushes a tally change](#l2-tally-variables-are-not-updated-when-the-switcher-pushes-a-tally-change)
- [ ] [L3: ROI Mode preset can turn ROI on but never off](#l3-roi-mode-preset-can-turn-roi-on-but-never-off)
- [ ] [L4: Send Custom Command sends variable names literally instead of their values](#l4-send-custom-command-sends-variable-names-literally-instead-of-their-values)
- [ ] [L5: PVW Source Select and the PVW Select presets duplicate PST Source Select](#l5-pvw-source-select-and-the-pvw-select-presets-duplicate-pst-source-select)
- [ ] [L6: Last Memory Number counts from 0 while every other memory label counts from 1](#l6-last-memory-number-counts-from-0-while-every-other-memory-label-counts-from-1)
- [ ] [L7: Connection status shows Reconnecting instead of the actual failure](#l7-connection-status-shows-reconnecting-instead-of-the-actual-failure)
- [ ] [L8: Connection turns green OK before the password is accepted](#l8-connection-turns-green-ok-before-the-password-is-accepted)
- [ ] [L9: No status when the IP Address is empty](#l9-no-status-when-the-ip-address-is-empty)
- [ ] [L10: HELP.md gives the wrong Polling Rate default](#l10-helpmd-gives-the-wrong-polling-rate-default)
- [ ] [L11: Capture Still Image and Delete Still Image start timers that cleanup does not cancel](#l11-capture-still-image-and-delete-still-image-start-timers-that-cleanup-does-not-cancel)
- [ ] [N1: init() does not await configUpdated()](#n1-init-does-not-await-configupdated)
- [ ] [N2: Every reply line re-checks every feedback, and the first poll waits a full polling period](#n2-every-reply-line-re-checks-every-feedback-and-the-first-poll-waits-a-full-polling-period)
- [ ] [N3: Polling Rate field stays visible when polling is disabled](#n3-polling-rate-field-stays-visible-when-polling-is-disabled)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Status polling doubles after the switcher closes the session, and the extra poll timer survives Save

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — ⚠️ needs your check
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:509-520`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L509-L520), [`src/main.js:154-172`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L154-L172), [`src/main.js:187-194`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L187-L194)

**What goes wrong:** Take a user with "Enable Polling" on and "Polling Rate (ms)" at 3000. If the V-1-4K closes the LAN-control session cleanly but stays reachable, the module reconnects by itself 2 seconds later, gets "Welcome to V-1-4K." again and starts a second 3000 ms poll timer while the first one is still running. From then on the switcher gets the 20-command status poll twice per period, and every further clean reconnect adds another copy. The old timer can no longer be stopped:

- If the user unticks "Enable Polling" and clicks Save, polling keeps going.
- If they change "Polling Rate (ms)" from 3000 to 10000, the old 3000 ms timer keeps polling as well.
- `destroy()` clears only the newest timer. (Companion stops the module's process when the connection is disabled, so the leftover timer matters while the connection is running and after a Save.)

While the session is down, the connection also keeps showing a green OK, because nothing updates the status on a clean disconnect.

A local fake V-1-4K server at Polling Rate 1000 reproduced it: after one clean close and auto-reconnect there were 2 live intervals and 10 status polls in 5 s (double). After a Save with "Enable Polling" off, 4 polls still arrived in 4 s.

**Why it happens:** `startInterval()` stores a new `setInterval` in `this.INTERVAL` without clearing the one already there. Only the socket's `error` handler and `configUpdated()` clear the old interval, and the module has no `end` or `status_change` listener. The connection helper (`TCPHelper`, created with its default `reconnect: true`) reconnects on its own after a clean close without emitting `error`, so the next "Welcome" handshake calls `startInterval()` again and the old interval handle is overwritten and lost.

**Evidence:**

```js
// src/main.js:509-520
	startInterval() {
		this.pollQueue = []
		this.pollTimer = null
		this.memoryNamesLoaded = false

		if (this.config.polling) {
			let rate = parseInt(this.config.pollingrate) || 3000
			if (rate < 1000) rate = 1000
			this.log('info', `Polling interval: ${rate}ms`)
			this.INTERVAL = setInterval(() => this.getData(), rate)
		}
	}
```

```js
// src/main.js:154-172
			this.socket = new TCPHelper(this.config.host, this.config.port)
			this.receiveBuffer = ''

			this.socket.on('error', (err) => {
				if (this.config.verbose) {
					this.log('warn', 'Error: ' + err)
				}
				clearInterval(this.INTERVAL)
				this.handleError(err)
			})

			this.socket.on('connect', () => {
				this.log('info', 'Connected')
				this.updateStatus(InstanceStatus.Ok)
			})

			this.socket.on('data', (buffer) => {
				this.processIncomingData(buffer.toString('utf8'))
			})
```

```js
// src/main.js:187-194
		if (this.receiveBuffer.includes('Welcome to V-1-4K.')) {
			this.updateStatus(InstanceStatus.Ok)
			this.log('info', 'Authenticated.')
			this.receiveBuffer = ''
			this.sendSimpleCommand('VER;')
			this.startInterval()
			this.subscribeToTally()
```

```js
// src/main.js:48-61 (configUpdated clears only the current handle)
	async configUpdated(config) {
		this.config = config
		if (this.socket !== undefined) {
			this.socket.destroy()
			delete this.socket
		}
		clearInterval(this.INTERVAL)
```

```js
// node_modules/@companion-module/base/dist/helpers/tcp.js:116-123 (base 2.0.4)
        this._socket.on('end', () => {
            this.#connected = false;
            this.#new_status(InstanceStatus.Disconnected);
            if (!this.#connecting && this.#options.reconnect) {
                this.#queueReconnect();
            }
            this.emit('end');
        });
```

```text
// localhost check: the module's own TCPHelper against a 127.0.0.1 server that sends "Welcome to V-1-4K." and then calls s.end() on the first session
{ conns: 2, welcomes: 2, errors: 0 }
```

**Confirm by:** check whether a real V-1-4K ever closes the port-8023 LAN-control session cleanly while it stays reachable (an idle timeout, a second client taking the session, a soft reboot). If it does, [`src/main.js:518`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L518) overwrites `this.INTERVAL` without calling `clearInterval` first, so each reconnect adds another poll timer. Power-off, cable pulls and resets arrive as `error` (timeout or reset), and that path does clear the interval.

**Fix:** stop the previous poll timers at the top of `startInterval()` before creating new ones, and stop polling and update the status when the session ends.

```js
startInterval() {
	if (this.INTERVAL) {
		clearInterval(this.INTERVAL)
		this.INTERVAL = null
	}
	if (this.pollTimer) {
		clearTimeout(this.pollTimer)
		this.pollTimer = null
	}
	// ...existing code
}

// in initConnection()
this.socket.on('end', () => {
	clearInterval(this.INTERVAL)
	this.INTERVAL = null
	this.updateStatus(InstanceStatus.Disconnected)
})
```

For the same reason, clear `pollTimer` and empty `pollQueue` in `configUpdated()` and in the `error` handler, next to `clearInterval(this.INTERVAL)`.

### M2: Memory 6 to 8 Name variables never fill in, and none fill in at a 1000 ms polling rate

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:546-559`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L546-L559)

**What goes wrong:** With the default "Polling Rate (ms)" of 3000, the variables Memory 6 Name, Memory 7 Name and Memory 8 Name (`$(roland-v1-4k:memoryname_6)` to `_8`) never get a value, and Memory 5 Name misses its last character. HELP.md gives 1000 as the Polling Rate default; at 1000, none of Memory 1–8 Name load, so buttons that show memory names stay blank. "Last Memory Name" is also empty for any memory whose name was never fetched. The names are only requested again after a reconnect or a settings Save, and the same truncation happens again.

**Why it happens:** The first poll queues 20 status queries plus 64 memory-name requests (one per character, 8 memories × 8 characters) and marks the names as loaded right away. The queue sends one command every 50 ms, so it needs about 4.2 s to drain. The next poll tick replaces the whole queue with the 20 status queries, which throws away the memory-name requests not yet sent, and because the names are already marked as loaded they are never queued again. A simulation of the module's queue code sent 39 of 64 requests at 3000 ms (Memory 1–4 complete, Memory 5 seven characters, Memory 6–8 none), 0 of 64 at 1000 ms and 64 of 64 at 5000 ms.

**Evidence:**

```js
// src/main.js:546-559
		this.pollQueue = commands.slice()

		if (!this.memoryNamesLoaded) {
			for (let i = 0; i < 8; i++) {
				let hexMem = i.toString(16).padStart(2, '0').toUpperCase()
				for (let j = 0; j < 8; j++) {
					let hexChar = j.toString(16).padStart(2, '0').toUpperCase()
					this.pollQueue.push('RQH:60' + hexMem + hexChar + ',000001;')
				}
			}
			this.memoryNamesLoaded = true
		}

		this.processQueue()
```

**Fix:** keep the unsent memory-name requests. Any one of these works:

- In `getData()`, skip the tick while the previous queue is still draining: `if (this.pollQueue.length > 0) return`.
- Append the status commands to the existing queue instead of replacing it.
- Set `memoryNamesLoaded = true` only after the last `RQH` request has actually been sent.
- Request the memory names once, right after "Welcome", through their own queue.

### M3: The switcher's network password is shown in plain text in the connection settings

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:90-96`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L90-L96), [`src/main.js:182`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L182)

**What goes wrong:** In the connection settings, the Password field shows the V-1-4K's 8-character network password in clear text. The password is stored in the ordinary connection config, which base 2.0.4 documents as reported in full to the web UI, so anyone who can open the Companion web UI can read it ([A2](#-assumptions-to-confirm)).

**Why it happens:** The field is a plain text input (`textinput`). API 2.0 has a `secret-text` config field whose value goes into a separate secrets store; Companion passes it to `init(config, isFirstInit, secrets)` and `configUpdated(config, secrets)`.

**Evidence:**

```js
// src/main.js:90-96
			{
				type: 'textinput',
				id: 'password',
				label: 'Password',
				default: '',
				width: 6,
			},
```

**Fix:** make the password a secret field and read it from the secrets object. The module has never been published, so no upgrade script is needed (see the companion-v2-config skill).

```js
{ type: 'secret-text', id: 'password', label: 'Password', default: '', width: 6 }
```

Accept `secrets` in `init(config, isFirstInit, secrets)` and `configUpdated(config, secrets)`, store it (e.g. `this.secrets = secrets`), and send `this.secrets.password` in `processIncomingData()`.

### M4: Still-image and tally options use raw device codes, so expression mode is hard to use

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:1091-1113`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/actions.js#L1091-L1113), [`src/actions.js:1128-1137`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/actions.js#L1128-L1137), [`src/feedbacks.js:15-31`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/feedbacks.js#L15-L31)

**What goes wrong:** A user who switches the "Capture Still Image" action's "Capture Source" or "Target Storage" option to expression mode has to type device codes: `00` to `04` for HDMI IN 1 to 5, and `00`/`01` for STILL 1/STILL 2. The "Delete Still Image" Target uses `7F` for ALL. In the "Tally State" feedback, Source takes 0 to 14 (7 means INPUT 1) and State takes 1, 2 or 3. An expression that returns `STILL2` or `HDMI1` fails choice validation, and Companion skips the action or feedback.

**Why it happens:** The dropdown choice ids are the protocol's hex bytes or array indexes instead of readable names. In API 2.x, users type these ids directly in expression mode.

**Evidence:**

```js
// src/actions.js:1104-1113
			{
				type: 'dropdown',
				label: 'Target Storage',
				id: 'target',
				default: '00',
				choices: [
					{ id: '00', label: 'STILL 1' },
					{ id: '01', label: 'STILL 2' },
				],
			},
```

**Fix:** use readable ids and map them to the device codes inside the callback: `HDMI1` to `HDMI5`, `STILL1`/`STILL2` and `ALL` for the still actions; `HDMI1` … `INPUT8` and `PGM`/`PST`/`PGM_PST` for the tally feedback. Do it before the first published release, because changing ids afterwards needs an upgrade script.

## 🟢 Low

### L1: Tally State feedback set to PGM goes dark while the source is on both PGM and PST

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:34-40`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/feedbacks.js#L34-L40)

**What goes wrong:** A user adds the "Tally State" feedback with Source = HDMI1 and State = PGM to light a red on-air button. When HDMI1 is on program and also selected on preset, the module reports tally status 3 (PGM+PST) and the button turns off, even though HDMI1 is still live. Today the user has to stack a second "PGM & PST" feedback to get a correct on-air light.

**Why it happens:** The feedback checks for an exact match (`tally.status == state`), but the module itself treats the status as flags: the tally variables map 1 = PGM, 2 = PST and 3 = PGM+PST.

**Fix:** use a flag check so PGM matches 1 and 3 and PST matches 2 and 3; keep the "PGM & PST" choice for an exact match if needed.

```js
const state = Number(feedback.options.state)
return (tally.status & state) === state
```

### L2: Tally variables are not updated when the switcher pushes a tally change

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:409-414`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L409-L414)

**What goes wrong:** When a tally change arrives as a pushed `DTH:0C00xx` message (the module subscribes to these with `DTH:0C0100,01;` after login), the "Tally State" feedback updates, but variables such as `$(roland-v1-4k:tally_hdmi1)` keep the old PGM/PST/OFF text until the next poll. With "Enable Polling" unticked they never update.

**Why it happens:** The polled tally reply (`TLY`, [`src/main.js:269-276`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L269-L276)) calls `updateTallyVariables()` after changing the tally state. The pushed tally branch changes the same state but never calls it.

**Fix:** call `this.updateTallyVariables()` after updating the tally state in `parseDTHResponse()`.

### L3: ROI Mode preset can turn ROI on but never off

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:239-252`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/presets.js#L239-L252)

**What goes wrong:** The "ROI Mode" preset in the "SPLIT & ROI" section lights blue while ROI is on, so it looks like a toggle. Every press sends `ROISW:ON;`, so pressing it again while ROI is on does nothing, and the operator cannot turn ROI off from this button.

**Why it happens:** The preset (`roi_mode_toggle`) uses the "ROI Mode" action with a fixed `{ state: 'ON' }`, and that action has no toggle choice.

**Fix:** add a toggle choice to the "ROI Mode" action (or a separate toggle action, as the module already has for PinP, DSK and SPLIT) and use it in this preset, or give the preset two steps (ON, then OFF).

### L4: Send Custom Command sends variable names literally instead of their values

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:1205-1218`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/actions.js#L1205-L1218)

**What goes wrong:** A user enters `PGM:$(internal:custom_cam);` in the Command field of "Send Custom Command". The module sends that text literally to the switcher, which rejects it. Variables only work if the user switches the field to expression mode.

**Why it happens:** In API 2.x, Companion only replaces variables in a normal (non-expression) text field when the field sets `useVariables: true`.

**Fix:** add `useVariables: true` to the `command` text input.

### L5: PVW Source Select and the PVW Select presets duplicate PST Source Select

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:22-52`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/actions.js#L22-L52), [`src/presets.js:77-110`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/presets.js#L77-L110)

**What goes wrong:** The action list has both "PST Source Select" and "PVW Source Select", and the preset panel has both "PST Select" and "PVW Select" (15 buttons each). Both actions send the same `PST:<source>;` command, and both preset groups light up from the same "PST Source" feedback. Users may expect a separate preview bus and get the same result.

**Why it happens:** The `select_pvw` action sends `PST:${event.options.source};`, the same command as `select_pst`, and the presets build a second group around it.

**Fix:** remove `select_pvw` and the `pvw_*` presets, or keep one action named "PST/PVW Source Select" and one preset group. The module is unpublished, so no upgrade script is needed.

### L6: Last Memory Number counts from 0 while every other memory label counts from 1

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:434-441`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L434-L441)

**What goes wrong:** When Memory 1 is recalled, the "Last Memory Number" variable shows 0, while every other memory label in the module (the Memory 1–8 choices and the Memory 1–8 Name variables) counts from 1. A button that shows "Memory $(roland-v1-4k:last_memory_number)" therefore reads one lower than the memory the operator picked.

**Why it happens:** The module treats the reported memory number as a 0-based index: it uses it to look up the stored name, which is filed under the same 0-based index that feeds "Memory 1 Name" ([`src/main.js:429`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L429)). The same raw value is then published as the user-visible number.

**Fix:** publish `last_memory_number` as `memNum + 1` and keep the 0-based value only for the internal name lookup.

### L7: Connection status shows Reconnecting instead of the actual failure

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:466-507`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L466-L507)

**What goes wrong:** A user enters the wrong IP or the device refuses the port. The module sets the status to Connection Failure "Connection Refused" (or "Connection Timed Out"), then overwrites it at once with Connection Failure "Reconnecting". The Connections page never shows why it failed; the cause appears only in the log.

**Why it happens:** `handleError()` sets the specific status message and then calls `startReconnectInterval()`, which immediately sets Connection Failure "Reconnecting".

**Fix:** pass the specific message into `startReconnectInterval()` (for example "Connection Refused, retrying in 30s"), or don't set a status in `startReconnectInterval()` when one was just set.

### L8: Connection turns green OK before the password is accepted

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:165-168`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L165-L168)

**What goes wrong:** As soon as the TCP port opens, the connection shows OK, before the switcher has asked for or accepted the password. The status then drops to "Connecting: Authenticating" and goes back to OK only after "Welcome to V-1-4K.". A login that never completes therefore never shows a failure status.

**Why it happens:** The socket's `connect` handler sets OK on TCP connect; the real OK is set after the welcome message at [`src/main.js:188`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L188).

**Fix:** set Connecting (for example "Waiting for login") in the `connect` handler, and keep OK only for the "Welcome to V-1-4K." branch.

### L9: No status when the IP Address is empty

- **Source:** 🔎 QA reviewer + protocol reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:151-173`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L151-L173)

**What goes wrong:** A user adds the connection and saves without an IP Address. No socket is opened and no status is reported, so the Connections page doesn't show "Bad Config" or point the user to the missing IP ([A1](#-assumptions-to-confirm)). If the user clears the IP Address of a connection that was working, the old green OK stays shown.

**Why it happens:** `initConnection()` only acts inside `if (this.config.host)` and has no `else` branch that sets a status.

**Fix:** report the missing IP as a configuration problem.

```js
} else {
	this.updateStatus(InstanceStatus.BadConfig, 'IP address not set')
}
```

### L10: HELP.md gives the wrong Polling Rate default

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:13`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/companion/HELP.md#L13)

**What goes wrong:** The help page says the Polling Rate default is 1000 ms, but a new connection shows 3000 in the "Polling Rate (ms)" field ([`src/main.js:104-112`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L104-L112)). A user who follows the help page and sets 1000 also gets no memory names at all (see [M2](#m2-memory-6-to-8-name-variables-never-fill-in-and-none-fill-in-at-a-1000-ms-polling-rate)).

**Why it happens:** The documentation was not updated to match the config field's default.

**Fix:** change the HELP.md default to 3000, or change the field default to match the docs.

### L11: Capture Still Image and Delete Still Image start timers that cleanup does not cancel

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:1118-1120`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/actions.js#L1118-L1120), [`src/actions.js:1142-1144`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/actions.js#L1142-L1144)

**What goes wrong:** Nothing visible to the user. Each press of "Capture Still Image" or "Delete Still Image" starts a 100 ms one-shot timer that `destroy()` and `configUpdated()` don't know about. If the connection is disabled or saved within those 100 ms the timer still fires, and the command is dropped because the socket is no longer connected. This is code hygiene only.

**Why it happens:** The action callbacks call `setTimeout(() => self.sendCommand(...), 100)` and never store the handle.

**Fix:** the callbacks are already `async`, so wait inside them instead of starting a detached timer.

```js
self.sendCommand('0A0500', event.options.source)
self.sendCommand('0A0501', event.options.target)
await new Promise((r) => setTimeout(r, 100))
self.sendCommand('0A0502', '01')
```

## 💡 Nice to Have

### N1: init() does not await configUpdated()

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:26-28`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L26-L28)

**What goes wrong:** Users see no difference today. If anything inside `configUpdated()` throws, the error is not tied to `init()` and turns into an unhandled promise rejection instead of a failed init.

**Why it happens:** `this.configUpdated(config)` is called without `await` or `return` inside the async `init()`.

**Fix:** use `await this.configUpdated(config)`.

### N2: Every reply line re-checks every feedback, and the first poll waits a full polling period

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:239`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L239), [`src/main.js:518`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L518)

**What goes wrong:** Each poll round of about 20 replies triggers about 20 full re-evaluations of all 16 feedback types (about 84 during the first round with memory names). After connecting, buttons stay unlit for one full polling period (3 s by default) before the first status query goes out.

**Why it happens:** `updateData()` calls `checkAllFeedbacks()` for every received line, and `startInterval()` only uses `setInterval`, with no immediate first `getData()`.

**Fix:** call `checkFeedbacks()` with only the feedback types the parsed reply affects (or debounce `checkAllFeedbacks()`), and call `this.getData()` once right after authentication, before starting the interval.

### N3: Polling Rate field stays visible when polling is disabled

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:104-112`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L104-L112)

**What goes wrong:** After unticking "Enable Polling", the "Polling Rate (ms)" field is still shown, although it has no effect.

**Why it happens:** The config field has no visibility condition.

**Fix:** add `isVisibleExpression: '$(options:polling)'` to the `pollingrate` field.

## 📝 Additional Notes

- This is the module's first release (never published), so there is no published version to diff against: the tag scope covers the whole module at v0.1.3, and every finding is new.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a module never sets a status (a new connection saved without an IP Address), Companion shows a neutral or unknown status rather than Bad Config, and after a Save it keeps showing the status the module set last | Companion host behaviour, not visible in the module or the base package; the module code provably sets no status when the host is empty ([`src/main.js:151`](https://github.com/bitfocus/companion-module-roland-v1-4k/blob/8161abb215a7a7f8ca85834289dba775f792d9aa/src/main.js#L151)) | [L9](#l9-no-status-when-the-ip-address-is-empty) |
| A2 | Companion keeps `secret-text` values out of the config it shows in the web UI and out of connection exports, while ordinary config values, including this password, are included | base 2.0.4 `base.d.ts:71` says the whole config object, but only the keys of the secrets object, are reported to the web UI; how Companion exports config was not checked | [M3](#m3-the-switchers-network-password-is-shown-in-plain-text-in-the-connection-settings) |
