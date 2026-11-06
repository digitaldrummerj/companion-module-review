# Review: venucable-planner v1.7.2 (follow-up to the v1.7.1 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-venucable-planner` |
| **Scope** | `tag` (`v1.7.1..v1.7.2`) |
| **Version** | v1.7.2 |
| **Release** | Update — last published v1.7.1 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Prior review** | [v1.7.1](review-venucable-planner-v1.7.1-20261031-201135.md) (✅ Approved, L1–L5) |
| **Review commit** | [`35e1787`](https://github.com/bitfocus/companion-module-venucable-planner/commit/35e1787715c618d49597125debf83225a50d6a03) |
| **Build** | `yarn install --immutable` + `yarn package` passed |
| **Date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's Connections list shows only the status from the most recent `updateStatus()` call, so a later Disconnected status replaces the earlier Bad config message | How the Companion host normally displays a connection's status. The order of the status calls was reproduced with the module's own test stub (`test/stub-base.js`) and the installed ws library; Companion's host source was not checked | [H1](#h1-a-rejected-pairing-key-now-shows-a-network-retry-status-instead-of-the-bad-key-message) |
| A2 | The real VenuCable relay rejects an unknown or stale pairing key with HTTP 400 on the WebSocket upgrade, the case the module handles as a bad key | The module's own comment and code at [`src/relay.js:109-110`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/relay.js#L109-L110) and its relay test (`fakeRelay({ status: 400 })`); the real relay was not contacted | [H1](#h1-a-rejected-pairing-key-now-shows-a-network-retry-status-instead-of-the-bad-key-message) |

## 📋 Issues

### Blocking

- [ ] [H1: A rejected pairing key now shows a network-retry status instead of the bad-key message](#h1-a-rejected-pairing-key-now-shows-a-network-retry-status-instead-of-the-bad-key-message)

### Non-blocking

- [ ] [L1: A Relay address (testing only) with a hash fragment still leaves the connection stuck on Connecting](#l1-a-relay-address-testing-only-with-a-hash-fragment-still-leaves-the-connection-stuck-on-connecting)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: A rejected pairing key now shows a network-retry status instead of the bad-key message

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/relay.js:108-125`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/relay.js#L108-L125), [`src/relay.js:141-145`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/relay.js#L141-L145), [`src/main.js:145-147`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/main.js#L145-L147)

**What goes wrong:** A user picks "Through VenuCable" and pastes a pairing key that looks valid (26 characters, for example `ABCDE-FGHIJ-KLMNO-PQRST-UVWXYZ`) but that the relay turns down, such as an old key or one from another project. In v1.7.1 the connection status ended on Bad config: "VenuCable did not accept that pairing key - copy it again from VenuCable". In v1.7.2 that message flashes for an instant and is then replaced by Disconnected: "Can't reach VenuCable - retrying". The user is told it is a network problem and that the module is retrying, but the module has already given up on that key and never retries. They wait, or start checking their internet, while the real cause (a wrong key) only shows in the log. Users with a working key are not affected.

**Why it happens:** When the relay refuses the key, the module marks the link as stopped, reports the bad key (which sets the Bad config status) and closes the socket. The socket's "closed" event arrives on the next tick. The new code in this release reports "relay down" on every close where the relay hasn't already been reported down, to fix the prior review's L1. On a refused key the socket never opened, so "relay down" has never been reported yet, and the report goes out. The connection's "relay down" handler then sets the Disconnected "retrying" status on top of the bad-key status. v1.7.1 only reported "relay down" when the socket had opened, so this path stayed silent.

**Evidence:**

```js
// src/relay.js:108-125 (v1.7.2)
		ws.on('unexpected-response', (_req, res) => {
			// The relay turned the key down (400): retrying won't help until the key changes.
			if (res.statusCode === 400) {
				this.stopped = true
				this.emit('error', Object.assign(new Error('VenuCable did not accept the pairing key'), { code: 'BAD_KEY' }))
			}
			ws.terminate()
		})
		ws.on('close', (code) => {
			clearInterval(this.pinger)
			if (this.ws !== ws) return
			this.ws = null
			const was = this.open
			this.open = false
			if (this.app) this.#lostApp()
			this.app = false
			// Said once, whether the relay dropped or was never reached (no internet, or blocked).
			if (was || this.relayUp !== false) this.#relay(false)
```

```js
// src/relay.js:141-152 (v1.7.2)
	#relay(up) {
		if (this.relayUp === up) return
		this.relayUp = up
		this.emit('relay', up)
	}

	// No internet, or the relay restarted: try again after 2s, doubling to 30s.
	#retry() {
		if (this.stopped) return
```

```js
// src/main.js:145-147 (v1.7.2)
			this.link.on('relay', (up) =>
				up ? waiting() : this.updateStatus(InstanceStatus.Disconnected, "Can't reach VenuCable - retrying"),
			)
```

```diff
// git diff v1.7.1..v1.7.2 -- src/relay.js
-			if (was) this.emit('relay', false)
+			// Said once, whether the relay dropped or was never reached (no internet, or blocked).
+			if (was || this.relayUp !== false) this.#relay(false)
```

```js
// node_modules/ws/lib/websocket.js:505-511, 1135 (ws 8.22.0)
  terminate() {
    if (this.readyState === WebSocket.CLOSED) return;
    if (this.readyState === WebSocket.CONNECTING) {
      const msg = 'WebSocket was closed before the connection was established';
      abortHandshake(this, this._req, msg);
      return;
    }
...
    process.nextTick(emitErrorAndClose, websocket, err);
```

Reproduced with a local fake relay on 127.0.0.1 that answers the upgrade with HTTP 400, and the key `ABCDE-FGHIJ-KLMNO-PQRST-UVWXYZ`:

```text
v1.7.2 relay.js: ["BadConfig: BAD_KEY","Disconnected: Can't reach VenuCable - retrying"] stopped= true retryTimer= false
v1.7.1 relay.js: ["BadConfig: BAD_KEY"] stopped= true retryTimer= false
```

**Confirm by:** open [`src/relay.js:116-125`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/relay.js#L116-L125). `relayUp` is only set by `#relay()`, which hasn't run when the key is refused, so it is still `undefined` when the close fires and `this.relayUp !== false` is true. Then [`src/main.js:146`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/main.js#L146) replaces the Bad config status with Disconnected "Can't reach VenuCable - retrying", while `#retry()` returns at once because `stopped` is true.

**Fix:** don't report the relay as down when the link was stopped because the key was refused. For example, add a `stopped` check to line 125 (the "another Companion is using this key" case sets `stopped` only after this line, so it still reports). Or return early after the cleanup when `this.stopped` is already true. A `relay.test.js` check that no `'relay'` false follows a bad key, or a `main.test.js` check that the last status stays `bad_config`, would keep it fixed.

```js
if (!this.stopped && (was || this.relayUp !== false)) this.#relay(false)
```

## 🟢 Low

### L1: A Relay address (testing only) with a hash fragment still leaves the connection stuck on Connecting

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:129-144`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/main.js#L129-L144), [`src/relay.js:73-76`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/relay.js#L73-L76)

**What goes wrong:** A tester types `wss://app.venucable.com/link#test` into "Relay address (testing only)". The new address check accepts it, but the connection then fails to start, its status stays on "Connecting to VenuCable", and the new "Relay address must start with wss://" message never appears. The clock variables keep running now, because the timer starts first. Only the testing-only field is affected, so few users will hit this. It is the one case of the prior review's L2 that is still open.

**Why it happens:** The new check only tests that the address parses and starts with `ws:` or `wss:`. The ws library also refuses addresses with a `#...` part: it throws "The URL contains a fragment identifier" while creating the socket. Nothing catches that error, so starting the connection (in `init()` or `configUpdated()`) fails after the status was already set to "Connecting to VenuCable".

**Fix:** reject addresses with a `#` part in the same check, or catch the error when creating the socket and report it as a Bad config.

```js
const u = new URL(this.relayUrl())
ok = ['ws:', 'wss:'].includes(u.protocol) && !u.hash
```

## 📝 Additional Notes

- **Prior review (v1.7.1):** all five Low findings were addressed in this release.
  - L1 (no "can't reach" status without internet): fixed. A relay that is never reached now shows "Can't reach VenuCable - retrying". The same change causes [H1](#h1-a-rejected-pairing-key-now-shows-a-network-retry-status-instead-of-the-bad-key-message).
  - L2 (mistyped Relay address leaves the connection stuck): fixed. The address is now checked and shows a Bad config message, and the clock timer starts before the link. An address with a `#` part still gets through, see [L1](#l1-a-relay-address-testing-only-with-a-hash-fragment-still-leaves-the-connection-stuck-on-connecting).
  - L3 (presets keep the old connection name after a rename): fixed. `configUpdated()` now rebuilds the presets.
  - L4 (deprecated `isVisible` functions): fixed. All four fields now use `isVisibleExpression`.
  - L5 (no upgrades file): fixed. [`src/upgrades.js`](https://github.com/bitfocus/companion-module-venucable-planner/blob/35e1787715c618d49597125debf83225a50d6a03/src/upgrades.js) is added and passed to `runEntrypoint`.
