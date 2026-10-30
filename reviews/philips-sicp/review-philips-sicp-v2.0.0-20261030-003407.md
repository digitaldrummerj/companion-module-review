# Review: philips-sicp v2.0.0

| | |
| --- | --- |
| **Module** | [`companion-module-philips-sicp`](https://github.com/bitfocus/companion-module-philips-sicp) |
| **Scope** | `tag` (v1.0.3..v2.0.0) |
| **Version** | v2.0.0 (commit [`84dfae1`](https://github.com/bitfocus/companion-module-philips-sicp/commit/84dfae18db7d91d7f02045a3d0d43abdbc198947)) |
| **Release** | Update — last published v1.0.3 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review date** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A Philips display (or a wrong port pointing at another service) can accept the TCP connection without answering SICP requests for a long time | the module's own comments and its "Display not responding" handling in [`src/sicp.ts:343-355`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L343-L355); device behaviour not checked | [M1](#m1-connection-shows-ok-while-the-display-is-not-answering-and-the-display-not-responding-status-never-shows) |
| A2 | Companion waits for an action callback to finish when running a sequential action group, so a callback that never settles holds up the later actions in that group | Companion action-group "wait for completion" behaviour; not determinable from the module or base | [L1](#l1-toggle-actions-can-hang-when-the-connection-resets-while-requests-are-queued) |
| A3 | Companion's connection settings form flags an empty text field that has `minLength: 1` the same way it flagged v1 `required: true` | the v2.0 compliance rules; the host UI rendering was not checked | [L2](#l2-target-ip-is-no-longer-marked-as-a-required-field-in-the-connection-settings) |
| A4 | Companion 5 aborts `context.signal` when a user aborts a running button's actions (for example with an "Abort actions" button) | the v2.1 API reference; the Companion host source was not checked for exactly when the signal fires | [L3](#l3-aborting-a-buttons-actions-does-not-cancel-queued-power-source-or-volume-commands) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Connection shows OK while the display is not answering, and the Display not responding status never shows](#m1-connection-shows-ok-while-the-display-is-not-answering-and-the-display-not-responding-status-never-shows)
- [ ] [L1: Toggle actions can hang when the connection resets while requests are queued](#l1-toggle-actions-can-hang-when-the-connection-resets-while-requests-are-queued)
- [ ] [L2: Target IP is no longer marked as a required field in the connection settings](#l2-target-ip-is-no-longer-marked-as-a-required-field-in-the-connection-settings)
- [ ] [L3: Aborting a button's actions does not cancel queued power, source or volume commands](#l3-aborting-a-buttons-actions-does-not-cancel-queued-power-source-or-volume-commands)
- [ ] [N1: Redundant setNoDelay call reaches into an internal TCPHelper field](#n1-redundant-setnodelay-call-reaches-into-an-internal-tcphelper-field)

## 🟡 Medium

### M1: Connection shows OK while the display is not answering, and the Display not responding status never shows

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sicp.ts:196-198`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L196-L198), [`src/sicp.ts:343-355`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L343-L355), [`src/sicp.ts:188`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L188)

**What goes wrong:** Take a display that accepts the TCP connection on port 5000 but never answers SICP requests, for example when the port points at another service. The connection turns green "OK" on the Connections page as soon as TCP connects. After 10 s without an answer the module sets "Display not responding" and, in the same moment, switches to "Connecting"; when TCP reconnects it goes back to green "OK". So the user sees OK most of the time while Power, Set Source and Mute buttons do nothing, and "Display not responding" is never visible.

**Why it happens:** The module is written to report OK only after the display's first reply (in `#processFrame`, [`src/sicp.ts:389-393`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L389-L393)). But the TCP helper's own status events are passed straight to Companion, and the helper reports OK as soon as the socket connects, which bypasses that check. In `#missedResponse` the error status is set just before `#connect()` runs, and `#connect()` begins by setting "Connecting", so the error is replaced at once.

**Evidence:**

```ts
// src/sicp.ts:188
this.#self.updateStatus(InstanceStatus.Connecting)
// src/sicp.ts:196-198
socket.on('status_change', (status, message) => {
	this.#self.updateStatus(status, message ?? null)
})
// src/sicp.ts:351-354
this.#reportProblem('warn', 'Display did not respond to requests, reconnecting')
this.#self.updateStatus(InstanceStatus.UnknownError, 'Display not responding')
}
this.#connect()
```

**Fix:** let only a real SICP reply report OK, and set the error status after reconnecting instead of before. In the `status_change` handler, ignore (or map to Connecting) the helper's `InstanceStatus.Ok`. In `#missedResponse`, call `this.#connect()` first and then set "Display not responding" (or keep a flag so `#connect()` doesn't overwrite a pending error until the display answers again).

## 🟢 Low

### L1: Toggle actions can hang when the connection resets while requests are queued

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sicp.ts:225-233`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L225-L233), [`src/sicp.ts:278-290`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L278-L290)

**What goes wrong:** A user presses a button with "Power: toggle" or "Mute: toggle" while a few poll requests are still queued, and then the display stops answering, so the module reconnects after 10 s (or the socket errors). That press does nothing and the action never finishes. If it sits in a sequential action group, the later actions on that button may wait indefinitely.

**Why it happens:** On a reset, `#resetConnectionState` empties the request queue with `this.#queue.clear()`. In p-queue 9.3.4, `clear()` throws queued tasks away without settling the promises that callers are waiting on. The "stale generation" check inside each queued task was meant to resolve such requests with `undefined`, but a cleared task never runs, so the awaited calls in `togglePower`, `toggleMute`, `setVolume` and `#sendCommand` stay pending.

**Fix:** don't clear the queue on reset; the existing generation check already turns stale tasks into quick no-ops that resolve `undefined`. Alternatively, keep a list of pending request resolvers and resolve them all with `undefined` when the queue is cleared.

### L2: Target IP is no longer marked as a required field in the connection settings

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/config.ts:14-20`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/config.ts#L14-L20)

**What goes wrong:** In v1.0.3 Companion highlighted the "Target IP" field until the user typed an address. In v2.0.0 a user who saves a new Philips SICP connection with "Target IP" empty gets no hint in the form. They still see the connection status "Bad configuration - No host configured" ([`src/sicp.ts:183-186`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L183-L186)), so only the form hint is lost.

**Why it happens:** The v2 migration removed `required: true`, which no longer exists on text fields in base 2.x, without adding its replacement `minLength: 1` (declared on `CompanionInputFieldTextInput` in base 2.1.3).

**Fix:** add `minLength: 1` to the `host` field.

```ts
{ type: 'textinput', id: 'host', label: 'Target IP', width: 8, regex: Regex.IP, minLength: 1 },
```

### L3: Aborting a button's actions does not cancel queued power, source or volume commands

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:75-179`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/actions.ts#L75-L179)

**What goes wrong:** Every action waits for SICP requests that go through a one-at-a-time queue (up to 20 entries, 1 s response timeout each), so "Power" toggle, "Set Volume" with Output "Speakers", or "Mute" toggle can take several seconds when the display is slow or in standby. If a user stops a running button with Companion 5's abort (for example an "Abort actions" button), the command still goes out to the display later, and the log doesn't say it was cancelled.

**Why it happens:** On API 2.1 each action callback receives a `context.signal` that Companion aborts when the user cancels. None of the callbacks read it or pass it down to the queue in [`src/sicp.ts:278-341`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L278-L341). The impact is small because each request times out after 1 s and stale requests are dropped on reconnect.

**Fix:** take the second callback argument (`callback: async (action, context) => ...`) and pass `context.signal` into the SICP methods. In `#send`, skip a queued request when `signal.aborted` is true, or pass `{ signal }` to `PQueue.add`, which p-queue 9 supports. See companion-v2-actions.

## 💡 Nice to Have

### N1: Redundant setNoDelay call reaches into an internal TCPHelper field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/sicp.ts:193-194`](https://github.com/bitfocus/companion-module-philips-sicp/blob/84dfae18db7d91d7f02045a3d0d43abdbc198947/src/sicp.ts#L193-L194)

**What goes wrong:** Users see no difference. The module's `socket._socket.setNoDelay(true)` call does nothing extra, and it relies on the underscore-prefixed `_socket` field, which a future base release could change.

**Why it happens:** `TCPHelper` in base 2.1.3 already calls `setNoDelay(true)` on every socket it creates, including the ones it creates when it reconnects (`node_modules/@companion-module/base/dist/helpers/tcp.js:98-100`).

**Fix:** remove the `socket._socket.setNoDelay(true)` line and its comment.
