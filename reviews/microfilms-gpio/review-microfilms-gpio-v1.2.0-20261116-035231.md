# Review: microfilms-gpio v1.2.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-microfilms-gpio](https://github.com/bitfocus/companion-module-microfilms-gpio) |
| **Scope** | `tag` (first release: there is no published version to diff against, so the whole module was reviewed) |
| **Version** | v1.2.0 (commit [`c4261ee`](https://github.com/bitfocus/companion-module-microfilms-gpio/commit/c4261eefe0ba2522d87e2512ee5090d71ecd95d0)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01, main) |
| **Reviewed** | 2026-11-16 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: A Target Port above 65535 stops the connection from starting, with no Bad Config status](#l1-a-target-port-above-65535-stops-the-connection-from-starting-with-no-bad-config-status)
- [ ] [L2: Every ping writes two debug lines, so the connection log fills with ping noise](#l2-every-ping-writes-two-debug-lines-so-the-connection-log-fills-with-ping-noise)
- [ ] [L3: The GPIO preset section shows all 64 buttons in one flat list](#l3-the-gpio-preset-section-shows-all-64-buttons-in-one-flat-list)
- [ ] [N1: The Two states preset IDs are misspelled as towStates](#n1-the-two-states-preset-ids-are-misspelled-as-towstates)

### Notes

- **Commit messages:** many commit messages in this release are in French (e.g. `55b389b` "chore: intègre les commits du bot Bitfocus (issue templates, checks)"). The most recent ones are in English; please keep writing commit messages in English.
- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: A Target Port above 65535 stops the connection from starting, with no Bad Config status

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:92-100`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/main.js#L92-L100), [`src/network.js:102`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/network.js#L102)

**What goes wrong:** In the connection editor the Target Port field only accepts 1 to 65534, so most users never hit this. But a port outside 1 to 65535 (for example `70000` or `-1`) can still reach the module through an imported or hand-edited config. With such a port the connection never starts. No ping is sent, every GPIO button does nothing, and the connection shows Connecting (or a generic start-up error) instead of a Bad Config status that names the port. Users who set the port in the editor are not affected.

**Why it happens:** The module replaces an empty or zero port with the default 7770, but it never checks the range. Node's UDP `send()` throws an `ERR_SOCKET_BAD_PORT` error straight away for a port outside 1 to 65535 (the QA reviewer reproduced this with Node 22). The first ping is sent from inside the network manager's constructor, with no try/catch around it. So the error escapes from `init()` (or `configUpdated()`) before the network manager is stored and before any status other than Connecting is set.

**Evidence:**

```js
// src/main.js:95
port: Number(config?.port) || DEFAULT_PORT,
// src/main.js:98-100
this.setConnectionStatus(InstanceStatus.Connecting)

const networkManager = new NetworkManager(this.config, this.log.bind(this))
// src/network.js:102 (first called from the constructor, src/network.js:46)
this.udpClient.send(this.pingMessage, this.config.port, this.config.host, (err) => {
```

**Fix:** Check the port range right after building `this.config`, and report Bad Config instead of creating the network manager when it is out of range.

```js
this.config = {
	...config,
	host: config?.host || DEFAULT_HOST,
	port: Number(config?.port) || DEFAULT_PORT,
}
if (!Number.isInteger(this.config.port) || this.config.port < 1 || this.config.port > 65535) {
	this.networkManager = undefined
	this.setConnectionStatus(InstanceStatus.BadConfig, `Invalid Target Port: ${config?.port}`)
	return
}
```

As an extra safeguard, wrap the two `udpClient.send(...)` calls in [`src/network.js:102`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/network.js#L102) and [`src/network.js:132`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/network.js#L132) in try/catch, and emit `pingError` / `sendError` from the catch.

### L2: Every ping writes two debug lines, so the connection log fills with ping noise

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/network.js:71-74`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/network.js#L71-L74), [`src/network.js:111`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/network.js#L111)

**What goes wrong:** While the robot is connected, the module writes two debug lines for every ping: `Command "Set GPIO PING" sent successfully.` and `"Status" response from 192.168.10.10:7770 (GPIO=...)`. A ping goes out every 500 ms, so that is about 4 lines per second, roughly 345,000 a day per connection. Someone who opens the connection's log to look for a real problem (a failed send, a status change) has to scroll past pages of identical ping lines. Nothing else is affected.

**Why it happens:** The ping's send callback logs a debug line after every successful send. The handler for incoming UDP messages also logs every Status response, even when the GPIO state hasn't changed. The module already writes an info line when the state really changes ("GPIO status changed", in [`src/main.js:176`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/main.js#L176)), so the per-ping lines add nothing.

**Fix:** Remove the per-ping debug line in `sendGpioPing`. In the message handler, log the Status response only when it differs from the previous one, or drop that line too.

```js
// src/network.js:111 — remove
this.log('debug', 'Command "Set GPIO PING" sent successfully.')
```

### L3: The GPIO preset section shows all 64 buttons in one flat list

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:89-95`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/presets.js#L89-L95)

**What goes wrong:** A user opens the Presets panel for the Microfilms GPIO connection and expands the "GPIO" section. All 64 buttons appear as one block: IMP 1 to IMP 32, then TS 1 to TS 32. There is no heading where the Impulse buttons end and the Two states buttons start, so finding "TS 17" means scrolling past all 32 Impulse buttons. Every preset works; this is only about finding them.

**Why it happens:** The preset structure has a single section whose list is every preset ID in one flat array. API 2.x lets a section hold named groups instead (`type: 'simple'` with a `presets` list). It also offers template groups (`type: 'template'`), which base 2.1.3 describes as a way "to avoid generating repetitive presets which vary just by a few simple values", like these presets that differ only in the GPIO number.

**Fix:** Split the section into two named groups, one per kind of button.

```js
const presetStructure = [
	{
		id: 'gpio',
		name: 'GPIO',
		definitions: [
			{ id: 'impulse', type: 'simple', name: 'Impulse', presets: impulseIds },
			{ id: 'two_states', type: 'simple', name: 'Two states', presets: twoStateIds },
		],
	},
]
```

`impulseIds` and `twoStateIds` are the preset IDs collected in the two existing loops. Optionally, you could go further and replace the 64 generated presets with one template group per kind, which reads the GPIO number from a local variable.

## 💡 Nice to Have

### N1: The Two states preset IDs are misspelled as towStates

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:72`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/c4261eefe0ba2522d87e2512ee5090d71ecd95d0/src/presets.js#L72)

**What goes wrong:** Users see no difference: the preset names (`Two states 1 button` to `Two states 32 button`) and the button text (`TS n`) are correct. Only the internal preset IDs are misspelled `towStates1` to `towStates32`, which makes the code harder to search.

**Why it happens:** A typo in the ID template: ``presetDefinitions[`towStates${gpio}`]``.

**Fix:** Rename the key to ``twoStates${gpio}``. This is the module's first release, so nothing depends on these IDs yet.

## 📝 Additional Notes

- The repo also has the tags v1.0.1 and v1.1.0, but neither was ever published, so this review covers the whole module as it stands at v1.2.0 rather than a diff.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Module log lines written at `debug` level are forwarded to Companion and shown in the connection's log view, so the per-ping lines are visible to a user who is troubleshooting | base 2.1.3 forwards every log level to the host logger (`dist/module-api/base.js`, `dist/logging.js`); how the Companion host filters or displays debug lines was not checked | [L2](#l2-every-ping-writes-two-debug-lines-so-the-connection-log-fills-with-ping-noise) |
| A2 | Companion 5's connection editor won't save a Target Port that fails the field's `Regex.PORT` check (1 to 65534 in base 2.1.3), so an out-of-range port can only arrive through an import or another path that skips the editor | general knowledge of the Companion web UI; base only passes the regex string to the host, and the host's save behaviour was not checked | [L1](#l1-a-target-port-above-65535-stops-the-connection-from-starting-with-no-bad-config-status) |
