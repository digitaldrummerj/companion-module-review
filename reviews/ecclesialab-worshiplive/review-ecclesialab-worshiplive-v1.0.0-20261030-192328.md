# Review: companion-module-ecclesialab-worshiplive v1.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-ecclesialab-worshiplive` |
| **Scope** | `tag` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`79093a4`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/tree/79093a498b59c2466b91cebfb6a5f2bf18c13168) |
| **Review date** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against: the whole module was reviewed, and every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all pass, and the template check found no differences that need a change.

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's module host (Node runtime) uses Node's default unhandled-rejection mode (`throw`), so an unhandled promise rejection ends the module process and Companion restarts it | No `unhandledRejection` / `uncaughtException` handler anywhere in `node_modules/@companion-module`; Node's default since v15 is `throw`. The Companion host's process flags were not checked | [M1](#m1-a-password-with-korean-or-other-non-latin-characters-crashes-the-module-instead-of-showing-a-wrong-password-status), [L1](#l1-an-unexpected-status-reply-crashes-the-module-instead-of-being-logged) |

## 📋 Issues

### Non-blocking

- [ ] [M1: A password with Korean or other non-Latin characters crashes the module instead of showing a wrong-password status](#m1-a-password-with-korean-or-other-non-latin-characters-crashes-the-module-instead-of-showing-a-wrong-password-status)
- [ ] [L1: An unexpected status reply crashes the module instead of being logged](#l1-an-unexpected-status-reply-crashes-the-module-instead-of-being-logged)
- [ ] [L2: Stopping a running button does not cancel a command already being sent](#l2-stopping-a-running-button-does-not-cancel-a-command-already-being-sent)
- [ ] [L3: The Action choice of Blackout, Main Output, Prompter Output, Overlay and Countdown can be switched to expression mode](#l3-the-action-choice-of-blackout-main-output-prompter-output-overlay-and-countdown-can-be-switched-to-expression-mode)
- [ ] [L4: All feedbacks and variables are sent to Companion every second even when nothing changed](#l4-all-feedbacks-and-variables-are-sent-to-companion-every-second-even-when-nothing-changed)
- [ ] [N1: A button can take up to a second to show its new state when pressed during a status read](#n1-a-button-can-take-up-to-a-second-to-show-its-new-state-when-pressed-during-a-status-read)
- [ ] [N2: Sending an empty stage message does nothing and logs nothing](#n2-sending-an-empty-stage-message-does-nothing-and-logs-nothing)

## 🟡 Medium

### M1: A password with Korean or other non-Latin characters crashes the module instead of showing a wrong-password status

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/client.ts:268-281`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L268-L281)

**What goes wrong:** A user controls Worship LIVE on another Mac. They set Target IP to `192.168.0.10` and type the password with the Korean input mode still on, or paste one with a non-Latin-1 character (for example `암호1234`). Instead of the clear "The password does not match" status, the module's first status read fails with an unhandled error and the module process stops. Companion restarts it, the next read fails the same way, and the connection keeps restarting without a useful message. Pressing an action such as Blackout or Next in that state fails too. Users whose password uses only Latin letters, digits and symbols are not affected.

**Why it happens:** The module sends the password to Worship LIVE in an HTTP header (`X-Deck-Key`). Node refuses header values with any character above U+00FF and throws `ERR_INVALID_CHAR` straight away (the reviewer reproduced this with Node 22). The throw happens inside the request's promise, which has no `try/catch`, so the read fails instead of returning "not OK". Every place that starts a read ignores its result with `void` ([`src/client.ts:156`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L156), [`src/client.ts:214`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L214), [`src/client.ts:259`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L259), [`src/main.ts:73`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/main.ts#L73)), so the error is never handled (see [A1](#-assumptions-to-confirm)).

**Evidence:**

```ts
// src/client.ts:268-281
async function request(target: Target, pathAndQuery: string): Promise<CallResult> {
	const local = 'socketPath' in target
	return new Promise((resolve) => {
		// The password travels in a header, not in the address, so it does not end up in logs.
		const options: http.RequestOptions = local
			? { socketPath: target.socketPath, path: pathAndQuery, method: 'GET' }
			: {
					host: target.host,
					port: target.port,
					path: pathAndQuery,
					method: 'GET',
					headers: { 'X-Deck-Key': target.password },
				}
		const req = http.request({ ...options, timeout: REQUEST_TIMEOUT_MS }, (res) => {
// src/client.ts:259
		this.#timer = setTimeout(() => void this.refresh(), this.#snapshot.connected ? POLL_MS : POLL_WHEN_DOWN_MS)
```

**Confirm by:** open [`src/client.ts:268-281`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L268-L281): the header is built from the raw password inside `new Promise((resolve) => …)` with no `try/catch`. Then [`src/client.ts:259`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L259) and [`src/main.ts:73`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/main.ts#L73): `void this.refresh()` has no `.catch`.

**Fix:** check the password before sending it, and treat a request that throws as a failed request. When the connection starts, a password with characters outside Latin-1 can set a Bad Config status with a clear message; inside `request()`, a `try/catch` around `http.request(...)` keeps any other throw from escaping.

```ts
if (/[^\t\x20-\x7e\x80-\xff]/.test(password)) {
	this.updateStatus(InstanceStatus.BadConfig, 'The password can only contain Latin letters, digits and symbols')
	return
}
// in request():
let req: http.ClientRequest
try {
	req = http.request({ ...options, timeout: REQUEST_TIMEOUT_MS }, (res) => { /* ... */ })
} catch {
	resolve({ ok: false, httpStatus: 0, error: 'bad_key' })
	return
}
```

## 🟢 Low

### L1: An unexpected status reply crashes the module instead of being logged

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/client.ts:209-220`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L209-L220), [`src/client.ts:244-247`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L244-L247)

**What goes wrong:** Nothing visible in normal use. If anything fails while the module applies a status reply (for example a list in the reply is not an array), the whole module process stops and Companion restarts it, instead of the module logging a warning and carrying on. The user would see the connection restart over and over, with nothing in the connection log to explain why.

**Why it happens:** After each status read the module rebuilds its choices, updates variables and re-checks feedbacks (`onSnapshot`). There is no `try/catch` around that step, so any error there fails the read. As in [M1](#m1-a-password-with-korean-or-other-non-latin-characters-crashes-the-module-instead-of-showing-a-wrong-password-status), every caller ignores the read's result with `void`, so the error is never handled. The reply is also cast to its expected shape without any check.

**Fix:** catch errors around the `this.#onSnapshot(next)` call, log them (for example with `this.log('error', …)` inside `ModuleInstance.onSnapshot`) and let polling continue. Optionally keep only the `lists` entries that are arrays (`Array.isArray`) before merging them over `EMPTY_LISTS`.

### L2: Stopping a running button does not cancel a command already being sent

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:68-74`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/main.ts#L68-L74), [`src/client.ts:268-306`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L268-L306)

**What goes wrong:** Every action (Next / Previous, Scene, Overlay, Countdown, Clear, …) sends an HTTP request to Worship LIVE and waits up to 2.5 seconds for the reply. If a user stops a button while it runs (for example with Companion's abort action, or by stopping a long action sequence), the module still sends the request and waits for it. The requests are short, so most users will never notice; this is a recommended API 2.1 practice rather than a malfunction.

**Why it happens:** API 2.1 gives every action callback an abort signal (`context.signal`) for exactly this case. None of the callbacks in `src/actions.ts` read it, and `run()` and `request()` build the HTTP request without a `signal`.

**Fix:** take the callback context in each action (`callback: async (event, context) => …`), pass `context.signal` through `run()` and `AppClient.call()` into `request()`, and give it to `http.request({ ..., signal })`.

### L3: The Action choice of Blackout, Main Output, Prompter Output, Overlay and Countdown can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:99`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L99), [`src/actions.ts:105`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L105), [`src/actions.ts:111`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L111), [`src/actions.ts:135-145`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L135-L145), [`src/actions.ts:158-169`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L158-L169)

**What goes wrong:** The "Action" dropdown of Blackout, Main Output and Prompter Output (Toggle / Turn on / Turn off), and of Overlay and Countdown (Toggle / Show / Hide, Start / stop / Start / Stop / Reset), shows an expression toggle. A user who switches it to expression mode has to type the internal ids (`toggle`, `on`, `off`, `show`, …). Nothing breaks, but the same kind of field already has the toggle turned off in Stage Message, Audio and Playback, so the actions behave differently from one another.

**Why it happens:** `disableAutoExpression: true` is set on the mode dropdowns of Stage Message, Audio and Playback ([`src/actions.ts:190`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L190), [`src/actions.ts:231`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L231), [`src/actions.ts:269`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L269)) but not on these five.

**Fix:** add `disableAutoExpression: true` to those five mode dropdowns, as already done for Stage Message, Audio and Playback.

### L4: All feedbacks and variables are sent to Companion every second even when nothing changed

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:85-99`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/main.ts#L85-L99)

**What goes wrong:** While connected, the module re-checks every feedback on every button (Blackout is on, Scene is in use, Overlay is shown, …) and re-sends all variables once a second, even when nothing changed in Worship LIVE. Buttons look and work correctly; the cost is extra CPU and traffic between the module and Companion, which grows with the number of buttons using this connection.

**Why it happens:** The status is read every second (`POLL_MS = 1000` in [`src/client.ts:91`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/client.ts#L91)), and `onSnapshot()` always calls `UpdateVariableValues(this)` and `this.checkAllFeedbacks()` without comparing against the previous status.

**Fix:** remember the last status (for example `JSON.stringify(snapshot.status)` plus `connected`) and only re-check feedbacks and update variables when it differs; the countdown variables can still be sent every second.

## 💡 Nice to Have

### N1: A button can take up to a second to show its new state when pressed during a status read

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:67-74`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/main.ts#L67-L74)

**What goes wrong:** A user presses a preset button such as Blackout (toggle). The command is sent, but the key only lights or unlights on the next poll, up to about a second later, instead of right away as the code comment intends. This happens only when the press falls while a status read is already in progress, which is more likely with a remote Mac on a slow network.

**Why it happens:** After the command, `run()` asks for a fresh status read. If a read is already in progress, the module hands back that read instead of starting a new one, and that read reflects the state from before the command.

**Fix:** after a command, mark the client as stale when a read is in progress, so one more read follows. For example, add an `AppClient.refreshAfterCommand()` that sets `this.#stale = true` if a read is in flight and otherwise calls `refresh()`.

### N2: Sending an empty stage message does nothing and logs nothing

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:208-215`](https://github.com/bitfocus/companion-module-ecclesialab-worshiplive/blob/79093a498b59c2466b91cebfb6a5f2bf18c13168/src/actions.ts#L208-L215)

**What goes wrong:** A user sets up a Stage Message action with Action "Send message" and Message `$(internal:custom_msg)`. If that variable is empty or only spaces, pressing the button does nothing and the connection log shows nothing, so the user cannot tell why the stage display did not change. Scene, Prompter Layout, Overlay and Countdown behave the same way when no target is chosen.

**Why it happens:** The action skips the request silently when the text (or the chosen target) is empty.

**Fix:** log a short warning when an action is skipped, for example `self.log('warn', 'Stage Message: message is empty, nothing sent')`, and a "no target chosen" warning for the dropdown-based actions.
