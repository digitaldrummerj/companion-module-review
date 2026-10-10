# Review: chromaq-vista v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-chromaq-vista` ([repo](https://github.com/bitfocus/companion-module-chromaq-vista)) |
| **Version** | v1.0.0 (`b53552f`) |
| **Previous tag** | none. This is the first release, so there is no diff and the whole module was reviewed. Every finding is 🆕 NEW. |
| **Scope:** | tag |
| **Language** | TypeScript |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned for API 2.0) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Transport** | OSC over UDP (node-osc 11.7.1): a client sends to **Target IP** : **Target Port**, and a server listens on `0.0.0.0` : **Listen Port** |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-08 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a UDP send fails (for example an address lookup or `sendto` error), Node passes the error to the send callback the module supplies, and does not also emit it as a socket `'error'` event | Node's `dgram` `socket.send` documentation; not run in this review | [M1](#m1-a-rare-network-socket-error-can-crash-the-connection) |
| A2 | On Windows, an "ICMP port unreachable" reply (Vista not listening on **Target Port**) does not surface as a receive error on the module's unconnected UDP socket | libuv ignores `WSAECONNRESET` on UDP receive; not checked against this module or the base package | [M1](#m1-a-rare-network-socket-error-can-crash-the-connection) |

If either assumption is wrong, an unreachable Vista or a closed Vista port could trigger the M1 crash in normal use, and M1 would be High (blocking).

## 📋 Issues

### Blocking

- [ ] [C1: package.json repository link still points at the template placeholder](#c1-packagejson-repository-link-still-points-at-the-template-placeholder)
- [ ] [H1: The connection shows OK before it is listening, even with no Target IP](#h1-the-connection-shows-ok-before-it-is-listening-even-with-no-target-ip)
- [ ] [H2: Type checking is off for actions, feedbacks and variables](#h2-type-checking-is-off-for-actions-feedbacks-and-variables)
- [ ] [H3: Some warnings go to the console instead of the connection log](#h3-some-warnings-go-to-the-console-instead-of-the-connection-log)
- [ ] [H4: A search keyword is misspelled](#h4-a-search-keyword-is-misspelled)
- [ ] [H5: Method name updateConifg is misspelled](#h5-method-name-updateconifg-is-misspelled)
- [ ] [H6: Saving the config can leave the connection with no sockets](#h6-saving-the-config-can-leave-the-connection-with-no-sockets)
- [ ] [H7: Every message from Vista is written to the connection log](#h7-every-message-from-vista-is-written-to-the-connection-log)

### Non-blocking

- [ ] [M1: A rare network socket error can crash the connection](#m1-a-rare-network-socket-error-can-crash-the-connection)
- [ ] [M2: One stray or garbled packet on the listen port marks the connection as failed](#m2-one-stray-or-garbled-packet-on-the-listen-port-marks-the-connection-as-failed)
- [ ] [M3: Fractional or out-of-range numbers are sent to Vista, which can crash it](#m3-fractional-or-out-of-range-numbers-are-sent-to-vista-which-can-crash-it)
- [ ] [L1: Socket errors are passed to the connection status as an object, not text](#l1-socket-errors-are-passed-to-the-connection-status-as-an-object-not-text)
- [ ] [L2: Failed sends are only logged and never reported as a failed action](#l2-failed-sends-are-only-logged-and-never-reported-as-a-failed-action)
- [ ] [L3: Fader levels and button states are sent as text](#l3-fader-levels-and-button-states-are-sent-as-text)
- [ ] [L4: Send message without arguments actually sends one empty argument](#l4-send-message-without-arguments-actually-sends-one-empty-argument)

---

## 🔴 Critical

### C1: package.json repository link still points at the template placeholder

- **Source:** 🤖 validate-template (PKG-REPO)
- **Classification:** 🆕 NEW
- **File:** [`package.json:19`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/package.json#L19)

**What goes wrong:** No effect inside Companion, but anyone (or any tool) following the package's repository link from `package.json` lands on a non-existent `companion-module-your-module-name` repo. `companion/manifest.json` already has the correct URL, so the two files disagree.

**Why it happens:** The `repository.url` field was never changed from the template's placeholder.

**Evidence:**

```text
Template expects:  "repository.url": "git+https://github.com/bitfocus/companion-module-chromaq-vista.git"
Found:             "repository.url": "git+https://github.com/bitfocus/companion-module-your-module-name.git"
```

**Confirm by:** open [`package.json:19`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/package.json#L19) and compare it with the `repository` line in [`companion/manifest.json:10`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/companion/manifest.json#L10).

**Fix:** point `repository.url` at this module's repo.

```json
"url": "git+https://github.com/bitfocus/companion-module-chromaq-vista.git"
```

---

## 🟠 High

### H1: The connection shows OK before it is listening, even with no Target IP

- **Source:** 🔎 protocol reviewer, compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:38`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L38), [`src/main.ts:45-50`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L45-L50), [`src/main.ts:58-61`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L58-L61), [`src/core/client.ts:28-31`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L28-L31)

**What goes wrong:** A newly added connection shows green (OK) straight away, even before the user has entered a **Target IP**. With the IP empty, button presses are quietly sent to the Companion machine itself instead of Vista, and nothing tells the user why Vista isn't responding.

**Why it happens:** `init()` sets the status to OK before the listen socket has opened, and **Target IP** has no default and isn't checked by the module. The module's `bad_config` status exists but is never used, and saving new settings never moves the status back to Connecting. The later OK only means the **Listen Port** opened; UDP gives no signal that Vista is actually reachable.

**Evidence:**

```ts
// src/main.ts:38, 45-46 (OK is set before the listen socket exists)
		this.updateStatus(InstanceStatus.Ok)
	...
		this.VistaClient = new VistaClient(config)
		this.VistaClient.connect()
```

```ts
// src/core/client.ts:28-31 (OK again once the listen port opens; Target IP is never checked)
	connect(): void {
		this.#server = new Server(this.listenPort, '0.0.0.0', () => {
			this.emit('status', { status: 'ok' })
		})
```

**Confirm by:** add a new connection without filling in **Target IP**: it turns green at once. In [`src/main.ts:38`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L38), `updateStatus(InstanceStatus.Ok)` runs before `connect()`. `bad_config` only appears in the status map at `src/main.ts:21`; nothing ever emits it.

**Fix:** report a bad config when the IP or a port is missing, and otherwise show Connecting until the listen socket is open.

- In `init()` and `configUpdated()`, set `InstanceStatus.BadConfig` and skip `connect()` when **Target IP** is empty or invalid, or a port is missing.
- Otherwise set `InstanceStatus.Connecting` first and let the server's listening callback set OK. Consider saying "listening" in the OK message, since UDP can't confirm Vista is there.

### H2: Type checking is off for actions, feedbacks and variables

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:5-9`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L5-L9), [`src/actions.ts:41`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L41), [`src/feedbacks.ts:4`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/feedbacks.ts#L4), [`src/variables.ts:4`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/variables.ts#L4)

**What goes wrong:** No direct user-visible effect. The build no longer catches mistakes such as a preset pointing at a misspelled action id or a wrong option name, so those would ship and fail at runtime.

**Why it happens:** The Companion 4.3 module API (2.0) lets a module describe its actions, feedbacks and variables in one *schema* type, so TypeScript can check every action id and option. This module declares the action schema as "any id, any options" and the feedback and variable schemas as `any`, which turns those checks off. The `event.options.address as string` cast in [`src/actions.ts:41`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L41) is a symptom.

**Evidence:**

```ts
// src/actions.ts:5-9
type VistaActionSchema = {
	options: CompanionOptionValues
}

export type ActionsSchema = Record<string, VistaActionSchema>
```

```ts
// src/feedbacks.ts:4 and src/variables.ts:4
export type FeedbacksSchema = any
export type VariablesSchema = any
```

**Confirm by:** open [`src/actions.ts:5-9`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L5-L9), [`src/feedbacks.ts:4`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/feedbacks.ts#L4) and [`src/variables.ts:4`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/variables.ts#L4).

**Fix:** declare concrete schema types, as the v2 template does.

- The custom message action: `{ options: { address: string } }`.
- For `COMMANDS`, derive the types or give each command family an explicit type.
- Use `Record<string, never>` instead of `any` while there are no feedbacks or variables.
- Remove the cast.

### H3: Some warnings go to the console instead of the connection log

- **Source:** 🔎 QA reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:43`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L43), [`src/actions.ts:58`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L58), [`src/actions.ts:75`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L75), [`src/core/client.ts:71`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L71)

**What goes wrong:** When an action runs before the connection is set up, the "Module did not initialize client properly" and "Connection not established" messages never appear in the Companion connection log, so the user can't see why the button did nothing.

**Why it happens:** Those messages use `console.log`, which doesn't reach the connection log.

**Evidence:**

```ts
// src/actions.ts:42-43 (also :57-58 and :74-75)
			if (!self.VistaClient) {
				console.log('Module did not initialize client properly')
```

```ts
// src/core/client.ts:70-71
		if (!this.#client) {
			console.log('Connection not established')
```

**Confirm by:** search `src/` for `console.log`: these four calls are the warnings a user would need to see.

**Fix:** use `self.log('warn', …)` in the actions and the existing `clientLogger.warn(…)` in `client.ts`.

### H4: A search keyword is misspelled

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/companion/manifest.json#L27)

**What goes wrong:** The manifest's search keyword is `"lighing"`, so someone searching Companion's module list for "lighting" won't find this module.

**Evidence:**

```json
// companion/manifest.json:27
	"keywords": ["lighing", "osc"]
```

**Confirm by:** open [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/companion/manifest.json#L27).

**Fix:** change the keyword to `"lighting"`.

### H5: Method name updateConifg is misspelled

- **Source:** 🔎 QA reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/core/client.ts:57`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L57)

**What goes wrong:** No user-visible effect; a code-readability fix.

**Evidence:**

```ts
// src/core/client.ts:57
	async updateConifg(config: ModuleConfig): Promise<void> {
```

```ts
// src/main.ts:60
		if (this.VistaClient) await this.VistaClient.updateConifg(config)
```

**Confirm by:** search `src/` for `updateConifg`: it appears at these two places only.

**Fix:** rename `updateConifg` to `updateConfig`, including the call in [`src/main.ts:60`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L60).

### H6: Saving the config can leave the connection with no sockets

- **Source:** 🔎 protocol reviewer, QA reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/core/client.ts:45-66`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L45-L66), [`src/main.ts:58-61`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L58-L61)

**What goes wrong:** If closing the old listen socket fails while the user saves new connection settings, the module never opens new sockets, so every action silently does nothing until the connection is disabled and re-enabled or Companion restarts. Saving the settings twice in quick succession can trigger that failure.

**Why it happens:** Saving the config runs `destroy()` and then `connect()`. `destroy()` awaits the server socket's `close()` with no error handling. node-osc's `close()` rejects when the socket can't be closed (for example because it is already closing), so `destroy()` throws before it clears the server field or closes the client socket. The `.then(() => this.connect())` after it never runs.

**Evidence:**

```ts
// src/core/client.ts:45-54
	async destroy(): Promise<void> {
		if (this.#server) {
			await this.#server.close()
			this.#server = undefined
		}
		if (this.#client) {
			await this.#client.close()
			this.#client = undefined
		}
	}
```

```ts
// src/core/client.ts:63-65
		await this.destroy().then(() => {
			this.connect()
		})
```

```js
// node_modules/node-osc/lib/Server.mjs:209-219 (Client.close is the same)
  close(cb) {
    if (cb) {
      this._sock.close(cb);
    } else {
      return new Promise((resolve, reject) => {
        this._sock.close((err) => {
          if (err) reject(err);
          else resolve();
```

**Confirm by:** open [`src/core/client.ts:45-54`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L45-L54): neither `await ...close()` is wrapped in `try/catch`, so a rejected close skips everything after it, including the `connect()` in [`src/core/client.ts:63-65`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L63-L65).

**Fix:** wrap each `close()` in its own `try/catch`, and clear the field whether or not the close succeeded, so one failure can't skip the other socket or the reconnect.

```ts
async destroy(): Promise<void> {
	const server = this.#server
	const client = this.#client
	this.#server = undefined
	this.#client = undefined
	try {
		await server?.close()
	} catch (e) {
		clientLogger.warn(`Error closing listen socket: ${e}`)
	}
	try {
		await client?.close()
	} catch (e) {
		clientLogger.warn(`Error closing send socket: ${e}`)
	}
}
```

### H7: Every message from Vista is written to the connection log

- **Source:** 🔎 QA reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`src/core/client.ts:89-91`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L89-L91)

**What goes wrong:** HELP.md tells users to set up a Vista OSC client pointing at Companion. If Vista then sends feedback (fader moves, state echoes), every message is logged at info level whether or not **Enable verbose logging** is on, which floods the connection log.

**Why it happens:** The receive handler logs unconditionally at `info`. Its parameter is also typed `string`, but node-osc passes the decoded message as an array.

**Evidence:**

```ts
// src/core/client.ts:33-35 (every incoming message is passed on)
		this.#server.on('message', (msg) => {
			this.#receiveMessage(msg)
		})
```

```ts
// src/core/client.ts:89-91 (logged at info, with no #verbose check; only send() checks it, at :76)
	#receiveMessage(message: string): void {
		clientLogger.info(`Received message: ${message}`)
	}
```

```markdown
<!-- companion/HELP.md:19 -->
- Under _OSC Clients_, create a new client with Companion's IP address and an unused port number (defaults to 9000)
```

**Confirm by:** open [`src/core/client.ts:89-91`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L89-L91): the `info` call has no `this.#verbose` check, unlike the send logging at [`src/core/client.ts:76`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L76).

**Fix:** only log incoming messages when verbose logging is enabled, at `debug` level, and type the parameter as the OSC message array (`unknown[]`).

---

## 🟡 Medium

### M1: A rare network socket error can crash the connection

- **Source:** 🔎 protocol reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/core/client.ts:28-42`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L28-L42)

**What goes wrong:** If the module's sending socket ever hits a low-level UDP error, the module's process crashes and the connection restarts instead of showing a status. In normal use this should not happen: the verifier found that ordinary send failures are handled, so only rare socket failures (for example the operating system refusing the socket's first bind, or a receive error on it) would trigger it. Whether a closed or unreachable Vista port can cause one is not certain (see A1 and A2).

**Why it happens:** In Node, an object that emits an `'error'` event with nobody listening for it throws, and an uncaught throw ends the process. node-osc's `Client` passes every error from its UDP socket on as an `'error'` event. The module listens for errors on its OSC server, but not on its OSC client, and the base package installs no catch-all handler. Errors from individual sends are not affected: every `send()` passes a callback, so those errors go to the callback instead. The **Target IP** field only accepts an IP address and the ports are limited to 1–65535, so a bad config cannot reach the socket either.

**Evidence:**

```ts
// src/core/client.ts:28-42
	connect(): void {
		this.#server = new Server(this.listenPort, '0.0.0.0', () => {
			this.emit('status', { status: 'ok' })
		})
		...
		this.#server.on('error', (error) => {
			this.emit('status', { status: 'connection_failure', msg: error })
		})

		this.#client = new Client(this.host, this.sendPort)
	}
```

```js
// node_modules/node-osc/lib/Client.mjs:39-51 (node-osc 11.7.1, pinned in yarn.lock)
  constructor(host, port) {
    super();
    ...
    this._sock = createSocket({
      type: 'udp4',
      reuseAddr: true
    });

    this._sock.on('error', (err) => {
      this.emit('error', err);
    });
  }
```

```ts
// src/core/client.ts:75-82 (each send passes a callback)
		await this.#client.send(address, args, (err: any) => {
			...
			if (err) {
				clientLogger.error(`Error sending message: address - ${address}, args - ${args}, error - ${err}`)
			}
		})
```

```js
// node_modules/node-osc/lib/internal/send.mjs:48-53
  catch (e) {
    if (e.code !== 'ERR_SOCKET_DGRAM_NOT_RUNNING') throw e;
    const error = new ReferenceError('Cannot send message on closed socket.');
    error.code = e.code;
    callback(error);
  }
```

**Confirm by:** open [`src/core/client.ts:41`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L41) and check that nothing calls `.on('error', ...)` on `#client` (it is only used at lines 14, 23, 41, 50-52, 70 and 75). Then see `node_modules/node-osc/lib/Client.mjs:48-50`, where the socket's `'error'` is passed on to the client.

**Fix:** listen for errors on the OSC client as soon as it is created, and report them as a connection failure.

```ts
this.#client.on('error', (err) => {
	clientLogger.error(`OSC client error: ${err.message}`)
	this.emit('status', { status: 'connection_failure', msg: err.message })
})
```

### M2: One stray or garbled packet on the listen port marks the connection as failed

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/core/client.ts:37-39`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L37-L39), [`src/main.ts:48-50`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L48-L50)

**What goes wrong:** If anything sends a packet to the **Listen Port** that isn't valid OSC, the connection turns red ("Connection Failure") and stays that way until the user saves the config again or Companion restarts, even though sending to Vista still works.

**Why it happens:** node-osc's server raises the same `'error'` event for a packet it can't decode (`can't decode incoming message: …`, `Server.mjs:113-121`) as for a real socket failure. The module treats every server error as a connection failure, and only sets the status back to OK when the listen port is first opened.

**Fix:** treat only real socket errors (errors that carry a `code`, such as `EADDRINUSE` or `EACCES`) as connection failures. Log decode errors at debug or warn level and leave the status alone.

### M3: Fractional or out-of-range numbers are sent to Vista, which can crash it

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:11-25`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L11-L25), [`src/actions.ts:62`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L62), [`src/core/commands.ts:20-43`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L20-L43), [`src/core/commands.ts:77-108`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L77-L108), [`src/core/commands.ts:129-143`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L129-L143), [`src/core/commands.ts:201-208`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L201-L208)

**What goes wrong:** The **Console: Playback button** and **Console: Playback fader** actions warn that "sending an out-of-range request has been known to crash Vista", but the module doesn't stop such requests. If a user switches **Row**, **Column**, **panel** or **bank** to an expression that returns `2.5` or `60`, the module sends an address like `/row/2.5/...` or `/col/60/...` to Vista. The same applies to **Action Grid: Trigger Button** and **Softkey**.

**Why it happens:** Each number option is pasted straight into the OSC address path. The options don't set `asInteger: true` (which makes Companion round to a whole number), and the module never re-checks the option's min/max when the action runs. The min/max in the editor don't apply to expression results or imported configs. Text values are passed through unchanged too, so a `/` or a space could change the address.

**Fix:** make every option that becomes part of the address a whole number, and refuse to send when a value is outside its range.

- Add `asInteger: true` to the `actionGrid`, `row`, `col`, `panel`, `bank` and `softkey` options.
- When the action runs, check each value with `Number.isInteger(n)` and the option's own `min`/`max` (already in `c.options`). Log a warning and skip the send when it fails, rather than clamping it.
- Don't accept arbitrary text for numeric segments.

---

## 🟢 Low

### L1: Socket errors are passed to the connection status as an object, not text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/core/client.ts:38`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L38), [`src/main.ts:49`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/main.ts#L49)

**What goes wrong:** When the listen socket fails, the explanation next to the Connection Failure status is unlikely to show the actual error text. Exactly what Companion displays for it wasn't checked.

**Why it happens:** The module passes the whole `Error` object as the status message, where Companion expects a string. An `Error` object doesn't carry its message through Companion's process boundary in a useful way, and TypeScript misses the mistake because the `status` event isn't typed.

**Fix:** pass the error's text (`msg: error.message`). Type the emitter, for example `EventEmitter<{ status: [{ status: keyof typeof statusMap; msg?: string }] }>`, and type the `statusMap` keys as a union so an unknown status can't reach `updateStatus` as `undefined`.

### L2: Failed sends are only logged and never reported as a failed action

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/core/client.ts:75-82`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L75-L82)

**What goes wrong:** When a message to Vista fails to send, Companion still treats the action as successful and the connection status doesn't change; the failure only appears in the log. With **Enable verbose logging** on, the "Sending OSC" line appears after the send rather than before, and is missing if the send throws straight away.

**Why it happens:** The module calls node-osc's `send()` with a completion callback. In that form `send()` returns nothing to wait for (`Client.mjs:124-127`), so `await` doesn't wait, and errors stay inside the callback.

**Fix:** log the verbose line before sending, then use the promise form inside `try/catch`: `await this.#client.send(address, ...args)` (arguments spread, not as an array). On error, log it and either set Connection Failure or rethrow so Companion reports the failed action.

### L3: Fader levels and button states are sent as text

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/core/commands.ts:8`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L8), [`src/core/commands.ts:45`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L45), [`src/core/commands.ts:62-68`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L62-L68), [`src/core/commands.ts:110`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L110), [`src/core/commands.ts:145-151`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/commands.ts#L145-L151), [`src/core/client.ts:69`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/core/client.ts#L69)

**What goes wrong:** **Console: Grandmaster fader** at 50% sends the text `"0.5"`, and the button actions send the text `"true"` / `"false"`, rather than an OSC number or boolean. If Vista expects typed values, those actions do nothing or misbehave. Whether Vista accepts text here wasn't checked.

**Why it happens:** OSC tags each argument with its type, and node-osc picks the tag from the JavaScript type (`Message.mjs:113-140`). Every argument in this module is a JavaScript string, so every argument is tagged as text (`,s`).

**Fix:** check Vista's OSC spec. If it expects typed values, widen `args` to `(string | number | boolean)[]`, send `true`/`false` as booleans, and send fader levels as `{ type: 'float', value: level / 100 }` (a plain number would be sent as an integer at exactly 0 or 1).

### L4: Send message without arguments actually sends one empty argument

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:46`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L46), [`src/actions.ts:67`](https://github.com/bitfocus/companion-module-chromaq-vista/blob/b53552f7ba3594771105e6d584dc1c640583d34d/src/actions.ts#L67)

**What goes wrong:** **Custom: Send message without arguments**, and every command that has no arguments, sends one empty-text argument (`,s ""`) instead of no arguments. That doesn't match the action's name, and a strict OSC receiver may reject it or read it as a value.

**Why it happens:** The module falls back to `['']` (a list holding one empty string) instead of `[]` (an empty list).

**Fix:** send `[]` (and use `c.args ?? []`) unless Vista is confirmed to need the empty string. Either way, make the action name match what is sent.
