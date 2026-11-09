# Review: rationalacoustics-smaart3 v3.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-rationalacoustics-smaart3` |
| **Scope** | `tag` (`v2.1.2..v3.0.0`) |
| **Version** | v3.0.0 |
| **Release** | Update — last published v2.1.2 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`aeab022`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/commit/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: The Smaart API password appears in plain text in Companion's debug log](#m1-the-smaart-api-password-appears-in-plain-text-in-companions-debug-log)
- [ ] [N1: Keepalive traffic adds two debug log lines every second while connected](#n1-keepalive-traffic-adds-two-debug-log-lines-every-second-while-connected)

## 🟡 Medium

### M1: The Smaart API password appears in plain text in Companion's debug log

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:153-158`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/connection.ts#L153-L158), [`src/connection.ts:166-169`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/connection.ts#L166-L169)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** A user sets a Smaart API password, for example `hunter2`, in the connection's Password field. Each time the connection opens and Smaart asks for the password, the module writes this debug line: `Sent: {"action":"set","properties":[{"password":"hunter2"}],"sequenceNumber":3}`. Anyone who opens the connection's debug log, or turns on Debug on the Log page, can read the password. So can anyone who receives an exported log attached to a bug report. This release moved the password into a secret field so the web UI no longer shows it, and this log line undoes that. v2.1.2 did not log outgoing requests, so the password was not logged in normal use. The QA reviewer reproduced this against the built `dist/connection.js`: the debug output contained the line above, word for word.

**Why it happens:** The module's send routine logs every request it writes to Smaart, in full, at debug level. When Smaart's login reply says a password is needed, the password request goes through the same routine, so it is logged like any other request. If a send fails, the error log line also prints the full request. The module passes these lines straight on to Companion's log ([`src/main.ts:74`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/main.ts#L74)).

**Evidence:**

```ts
// src/connection.ts:153-158
const message = JSON.stringify({
	...request,
	sequenceNumber: request.sequenceNumber ?? this.#nextSequenceNumber(),
})
socket.send(message)
this.#options.log('debug', `Sent: ${message}`)

// src/connection.ts:262-265
if (sequenceNumber === LOGIN_SEQUENCE_NUMBER && response?.authenticationRequired === true) {
	this.#options.log('info', 'Authenticating')
	this.#sendInternal(passwordRequest(this.#options.password))
}

// src/requests.ts:25-27
export function passwordRequest(password: string): SmaartRequest {
	return { action: 'set', properties: [{ password }] }
}

// src/connection.ts:166-169
#sendInternal(request: SmaartRequest): void {
	this.send(request).catch((err) => {
		if (!this.#destroyed) this.#options.log('debug', `${JSON.stringify(request)} not sent: ${errorMessage(err)}`)
	})
}
```

**Confirm by:** open [`src/connection.ts:153-158`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/connection.ts#L153-L158): every request is logged in full as `Sent: ${message}`. Then open [`src/requests.ts:25-27`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/requests.ts#L25-L27): the password request carries the password in `properties`.

**Fix:** hide the password before anything is logged. For example, build a separate log string that replaces any `password` property with `***`, or give `send()` a flag that `#sendInternal(passwordRequest(...))` sets to skip or redact the log line. Apply the same redaction to the "not sent" log line in `#sendInternal` ([`src/connection.ts:168`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/connection.ts#L168)). A test that logs in with a password and checks that no logged message contains it would keep this from coming back.

```ts
const redact = (key: string, value: unknown) => (key === 'password' ? '***' : value)
const payload = { ...request, sequenceNumber: request.sequenceNumber ?? this.#nextSequenceNumber() }
socket.send(JSON.stringify(payload))
this.#options.log('debug', `Sent: ${JSON.stringify(payload, redact)}`)
```

## 💡 Nice to Have

### N1: Keepalive traffic adds two debug log lines every second while connected

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:158`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/connection.ts#L158), [`src/connection.ts:233`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/connection.ts#L233)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** While connected and idle, the module sends Smaart a keepalive every second. It now logs both the request (`Sent: {"action":"get","sequenceNumber":1234}`) and Smaart's reply (`Message received: ...`), about 7,200 debug lines an hour from one connection. Someone watching the connection's debug log has to filter out this noise to find the useful lines, such as an action's "Unknown Target" warning. v2.1.2 logged only the reply, one line a second. Nothing breaks; this is log noise only.

**Why it happens:** The send routine logs every request, including the keepalive that the module queues after each second without other traffic ([`src/connection.ts:179-185`](https://github.com/bitfocus/companion-module-rationalacoustics-smaart3/blob/aeab0222e24a6a42679f76a5cb7d2b82b4ed40a3/src/connection.ts#L179-L185)), and the message handler logs every reply.

**Fix:** skip the `Sent:` and `Message received:` debug lines for keepalive requests and their empty replies. For example, pass a flag from `#startKeepAlive` that turns off logging for that send, or log the keepalive exchange only when it changes the connection status.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion shows a module's debug-level log lines in the web UI (in the connection's debug log window, and on the Log page when the Debug filter is on), and includes them when a user exports or copies the log for a bug report | General knowledge of the Companion UI; the base package only forwards log calls to the host and does not document where they are shown | [M1](#m1-the-smaart-api-password-appears-in-plain-text-in-companions-debug-log), [N1](#n1-keepalive-traffic-adds-two-debug-log-lines-every-second-while-connected) |
