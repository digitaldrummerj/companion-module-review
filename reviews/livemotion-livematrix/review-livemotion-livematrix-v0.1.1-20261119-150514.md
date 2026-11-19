# Review: companion-module-livemotion-livematrix v0.1.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-livemotion-livematrix` |
| **Scope** | `tag` |
| **Version** | v0.1.1 ([`d9ba117`](https://github.com/bitfocus/companion-module-livemotion-livematrix/tree/d9ba117925cb339e8d5ffc042e73deee61ed663b)) |
| **Release** | New module — never published |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Diff** | None: this is the first release, so the whole module at v0.1.1 was reviewed |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Reviewed** | 2026-11-19 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: A port or IPv6 address in the host field leaves the connection stuck on Connecting](#m1-a-port-or-ipv6-address-in-the-host-field-leaves-the-connection-stuck-on-connecting)
- [ ] [M2: Intercom, Talk and Listen key presets are offered for keys that cannot use them, so the buttons do nothing](#m2-intercom-talk-and-listen-key-presets-are-offered-for-keys-that-cannot-use-them-so-the-buttons-do-nothing)
- [ ] [L1: Pressing a key while disconnected lights the button as if talk or listen were on](#l1-pressing-a-key-while-disconnected-lights-the-button-as-if-talk-or-listen-were-on)
- [ ] [L2: The manifest states API version 2.2.1, but the package is built against 2.2.2](#l2-the-manifest-states-api-version-221-but-the-package-is-built-against-222)
- [ ] [N1: The expr() helper hides the expression wrapper from TypeScript](#n1-the-expr-helper-hides-the-expression-wrapper-from-typescript)
- [ ] [N2: Preset setup hints live only in HELP.md, not on the button](#n2-preset-setup-hints-live-only-in-helpmd-not-on-the-button)
- [ ] [N3: The Talk set and Listen set actions and the User connected feedbacks don't say what they do](#n3-the-talk-set-and-listen-set-actions-and-the-user-connected-feedbacks-dont-say-what-they-do)
- [ ] [N4: The 500 ms fallback timer in stop() is never cleared](#n4-the-500-ms-fallback-timer-in-stop-is-never-cleared)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: A port or IPv6 address in the host field leaves the connection stuck on Connecting

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:109-111`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/connection.ts#L109-L111), [`src/config.ts:127-136`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/config.ts#L127-L136), [`src/config.ts:138-150`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/config.ts#L138-L150)

**What goes wrong:** A user types the host with its port, such as `192.168.1.50:9443`, an IPv6 address such as `fe80::1`, or a name with a space or a `#` into **Server host** (or **Control API host**) and saves. The connection shows "Connecting" and never changes: there is no "Bad config" or "Connection failure" message and no retry, so nothing tells the user what is wrong. The reviewers reproduced this with the module's own test stub: start-up fails with `SyntaxError: Invalid URL: wss://192.168.1.50:9443:9443/ws`, and the only status ever set is Connecting. A host typed with a scheme, such as `https://10.0.0.5`, does not get stuck, but it tries to reach a host called `https` and fails with a confusing `ENOTFOUND https`. See [A1](#-assumptions-to-confirm).

**Why it happens:** The config check only makes sure the host is not empty, and the module then pastes the raw text into the WebSocket address. The `ws` library throws at once when that address is not a valid URL. The module creates the socket without catching that error, and it has already set the status to Connecting, so the error escapes from start-up. The socket's error and close handlers, which normally set the status, were never attached.

**Evidence:**

```ts
// src/config.ts:127-130
export function validateConfig(config: LivematrixConfig, secrets: LivematrixSecrets): string | undefined {
	if (config.connection_mode === 'server') {
		if (!config.host?.trim()) return 'Server host is required'
// src/config.ts:141-143
		const host = config.host?.trim() || 'localhost'
		const port = config.port ?? (config.server_tls ? DEFAULT_SERVER_TLS_PORT : DEFAULT_SERVER_PORT)
		return `${scheme}://${host}:${port}/ws`
// src/connection.ts:109-111
	private open(): void {
		const ws = new WebSocket(this.url, { rejectUnauthorized: !this.options.allowUnverifiedCertificate })
		this.ws = ws
```

**Fix:** reject a host that doesn't form a valid address when the config is checked, so the user sees Bad config with a reason, and catch a failed socket creation so it always ends up as a status. For example, in `validateConfig()` try `new URL(buildWebSocketUrl(config))` and return `'Server host is not a valid host name or IP address'` when it throws (or check the host against `Regex.HOSTNAME` / `Regex.IP`). In `open()`, wrap `new WebSocket(...)` in `try`/`catch` and pass the failure to `this.events.error(...)`. Optionally put IPv6 addresses in brackets and strip a typed `ws://`, `wss://`, `http(s)://` prefix or `:port` suffix.

### M2: Intercom, Talk and Listen key presets are offered for keys that cannot use them, so the buttons do nothing

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:205-236`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/presets.ts#L205-L236)

**What goes wrong:** The preset panel lists every key the login has under **Intercom keys**, **Talk keys** and **Listen keys**. A user who drops **Intercom keys > By key > Program** for a listen-only feed finds that pressing or double-tapping the button never switches listening on or off; it only selects the key for the volume controls while it is held. A **Talk keys** preset for a listen-only feed, or a **Listen keys** preset for a talk-only group, does nothing at all. The user gets a normal-looking key button that ignores every press.

**Why it happens:** The preset lists are built from all keys, without looking at whether each key can talk or listen. The press handlers then ignore keys that can't do the job: the talk handlers return at once for a key that can't talk ([`src/index.ts:625`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L625), [`src/index.ts:701`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L701)), the double-tap listen toggle needs a key that can both talk and listen ([`src/index.ts:775-777`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L775-L777)), and the listen handlers return for a key that can't listen ([`src/index.ts:796`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L796), [`src/index.ts:809`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L809)).

**Fix:** offer each preset only for the keys it can drive: Talk keys from `keys.filter((k) => k.can_talk)` and Listen keys from `keys.filter((k) => k.can_listen)`, keeping each key's original position as `value` in the "By index" groups. For Intercom keys, either list only keys that can both talk and listen, or let a press on a listen-only key toggle listening (for example, call the listen handlers from the talk handlers when the key can listen but not talk).

## 🟢 Low

### L1: Pressing a key while disconnected lights the button as if talk or listen were on

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:1025-1044`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L1025-L1044), [`src/index.ts:831-842`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L831-L842), [`src/index.ts:1140-1142`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L1140-L1142)

**What goes wrong:** While the connection is down (status "Disconnected" or "Connection failure"), an operator taps an Intercom key. The talk half of the button turns red and stays red, and `$(livematrix:key_0_talk)` reads `true`, but nothing reached the server, so nobody hears them. The false "latch" disappears once the connection returns and the server sends its state. The QA reviewer reproduced this with the module's test fake: after the server dropped, one tap left **Talk active** and **Talk held (momentary)** on and `key_0_talk` at `true`.

**Why it happens:** The code that turns talk or listen on or off records the new state and redraws the buttons whether or not the message was sent. The send function returns `false` when the socket is not open, but every caller ignores that result, and nothing is logged.

**Fix:** only change the local key state when the message was sent: have `sendKeyState` return the result of `send()`, and update `keyState` and redraw only on success. Alternatively, return early from the key actions when the module is not connected, and log a warning such as "Not connected to livematrix, key press ignored".

### L2: The manifest states API version 2.2.1, but the package is built against 2.2.2

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:21`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/companion/manifest.json#L21)

**What goes wrong:** Users see no difference in Companion: the build tool overwrites the API version in the packaged manifest, which already says 2.2.2. But the manifest in the repository says 2.2.1, so anyone troubleshooting from the source reads an API version the module isn't built with.

**Why it happens:** `runtime.apiVersion` was filled in by hand. The TS template ships the placeholder `"apiVersion": "0.0.0"` and lets `yarn package` fill in the installed `@companion-module/base` version.

**Evidence:**

```json
// companion/manifest.json:18-23
	"runtime": {
		"type": "node26",
		"api": "nodejs-ipc",
		"apiVersion": "2.2.1",
		"entrypoint": "../dist/index.js"
	},
```

**Fix:** set `"apiVersion": "0.0.0"` as in the template and let `yarn package` fill it in. The API level is already set by `"@companion-module/base": "~2.2.1"` in `package.json`.

## 💡 Nice to Have

### N1: The expr() helper hides the expression wrapper from TypeScript

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:49-51`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/options.ts#L49-L51)

**What goes wrong:** No visible effect today. The `expr()` helper returns an expression object (`{ isExpression: true, value }`) but tells TypeScript it returns a plain number, text or true/false value. That switches off type checking everywhere it is used in the presets. If it is later used where only a plain value is allowed (a local variable's start value, or a template group's `value`), the build still passes, Companion receives an object instead of a number or text, and the button shows a wrong value.

**Why it happens:** The helper double-casts with `as unknown as T`. In base 2.2, preset option values and graphics element properties are already typed as `T | ExpressionOrValue<T>` (`CompanionPresetValue`, `CompanionGraphicsElementValue`), so the cast isn't needed.

**Fix:** type the helper honestly and let the compiler check each use.

```ts
import type { ExpressionOrValue, JsonValue } from '@companion-module/base'

export function expr<T extends JsonValue>(expression: string): ExpressionOrValue<T> {
	return { isExpression: true, value: expression }
}
```

### N2: Preset setup hints live only in HELP.md, not on the button

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:901-904`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/presets.ts#L901-L904), [`src/presets.ts:846-849`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/presets.ts#L846-L849), [`src/presets.ts:1017-1020`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/presets.ts#L1017-L1020)

**What goes wrong:** A user who drags the **Microphone mute** preset onto a button never learns that it has a hidden **Device** element they can switch on to show the holding device's name; that hint is only in HELP.md. Likewise, the **Selected key volume**, **Selected key volume up** and **Selected key volume down** presets show "Hold a key" and go grey until a key is held, and the button itself doesn't explain why.

**Why it happens:** API 2.2 adds a `notes` field to preset definitions, which Companion copies to the button to give the user setup information. None of the presets set it.

**Fix:** add `notes` to the layered presets. Optional polish.

```ts
// createMicPreset()
notes: 'Turn on the Device element to show which device holds the mic.',
// the selected-volume presets
notes: 'Acts on the key you are holding, or the one chosen with Select key.',
```

### N3: The Talk set and Listen set actions and the User connected feedbacks don't say what they do

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:96-98`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/actions.ts#L96-L98), [`src/actions.ts:129-131`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/actions.ts#L129-L131), [`src/feedbacks.ts:166-189`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/feedbacks.ts#L166-L189)

**What goes wrong:** In the action picker, a user sees **Talk set** and **Listen set** with no description, next to clearer names like **Talk key down** and **Set listen level**, so nothing tells them these switch talk or listen on, off or toggle it. The **User connected** and **User disconnected** feedbacks have no description either. On a party-line, feed or group key, **User connected** is always on, which looks like a bug unless it is explained.

**Why it happens:** The two actions have short names and no `description`, and the two feedbacks have no `description`, while the module treats every key that isn't a user as always connected ([`src/index.ts:1135-1138`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/index.ts#L1135-L1138)).

**Fix:** rename the actions to, for example, "Set talk (toggle/on/off)" and "Set listen (toggle/on/off)", or add a description such as "Switch talk on, off or toggle it, as a latch". Give **User connected** a description like "The user this key points at is logged in. Always on for party lines, feeds and groups", and **User disconnected** the inverse. Changing a `name` doesn't break saved buttons, because the ids stay the same.

### N4: The 500 ms fallback timer in stop() is never cleared

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/connection.ts:73-81`](https://github.com/bitfocus/companion-module-livemotion-livematrix/blob/d9ba117925cb339e8d5ffc042e73deee61ed663b/src/connection.ts#L73-L81)

**What goes wrong:** No visible effect for users. When the connection is disabled, deleted or re-saved, closing the socket leaves a one-shot 500 ms timer running even after the socket has already closed. The timer only settles a promise that is already settled, so this is code quality only.

**Why it happens:** `stop()` waits for the socket's close event and also starts `setTimeout(resolve, 500)` as a fallback. The timer's handle is never kept, so it can't be cleared once the close event wins.

**Fix:** keep the handle and clear it when the promise settles.

```ts
await new Promise<void>((resolve) => {
	const timer = setTimeout(done, 500)
	function done(): void {
		clearTimeout(timer)
		resolve()
	}
	ws.once('close', done)
	try {
		ws.close()
	} catch {
		done()
	}
})
```

## 📝 Additional Notes

- `tsconfig.build.json` drops the template's `"verbatimModuleSyntax": true` from `compilerOptions`, so `rootDir` is the last option. The module builds and lints, so no change is required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a module's `init()` or `configUpdated()` promise rejects, Companion logs the error but doesn't replace the module's last status (Connecting) with an error status that names the bad host | The code that calls `init()`/`configUpdated()` is in the Companion host, not in `@companion-module/base` 2.2.2, so it wasn't read. The synchronous throw itself was reproduced with the module's `ws` 8.22.0 and its own test stub, which only records status updates | [M1](#m1-a-port-or-ipv6-address-in-the-host-field-leaves-the-connection-stuck-on-connecting) |
