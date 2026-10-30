# Review: nextkon-screen v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-nextkon-screen` |
| **Scope** | `tag` |
| **Version** | `v1.0.0` |
| **Release** | New module — never published |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`2ece07d`](https://github.com/bitfocus/companion-module-nextkon-screen/tree/2ece07d8bd1b6f536046e0e762d105e00fc3e37c) |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion fires an action callback's `context.signal` when a user aborts running actions (for example with an abort-actions button), so a callback that ignores it keeps running | The comment on `CompanionActionCallbackContext.signal` in the base 2.2.1 typings ("aborts when ... the user aborted the running actions"); Companion's host code not checked | [M1](#m1-aborting-a-buttons-actions-does-not-stop-a-running-room-or-sign-request) |
| A2 | Companion checks a dropdown value set in expression mode against the field's choices, and skips the action when it does not match and `allowCustom` is not set | The companion-v2-api-compliance v2.0 rules ("Expression validation"); not reproduced in a running Companion | [L2](#l2-swap-two-screens-and-the-room-action-skip-expression-values-the-module-itself-accepts) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Aborting a button's actions does not stop a running room or sign request](#m1-aborting-a-buttons-actions-does-not-stop-a-running-room-or-sign-request)
- [ ] [L1: Room action stops at the first screen that fails and leaves the rest unchanged](#l1-room-action-stops-at-the-first-screen-that-fails-and-leaves-the-rest-unchanged)
- [ ] [L2: Swap two screens and the room action skip expression values the module itself accepts](#l2-swap-two-screens-and-the-room-action-skip-expression-values-the-module-itself-accepts)
- [ ] [L3: A wrong server address shows a JavaScript error as the connection status](#l3-a-wrong-server-address-shows-a-javascript-error-as-the-connection-status)
- [ ] [L4: Network errors show only fetch failed, and a bare IP is always tried over https](#l4-network-errors-show-only-fetch-failed-and-a-bare-ip-is-always-tried-over-https)
- [ ] [L5: Room presets overwrite each other when room names differ only in non-ASCII characters](#l5-room-presets-overwrite-each-other-when-room-names-differ-only-in-non-ascii-characters)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Aborting a button's actions does not stop a running room or sign request

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:47-57`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/actions.ts#L47-L57), [`src/actions.ts:93-100`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/actions.ts#L93-L100), [`src/api.ts:62-65`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/api.ts#L62-L65)

**What goes wrong:** An operator presses a button with "All screens of a room: EMPTY or black" (Room: all rooms, Show: Black) at an event with 20 screens. The server is slow, so they abort the button's running actions in Companion. The module keeps sending one request per screen, each allowed up to 5 seconds, and screens keep switching to black after the operator tried to stop it. "Show sign on screen" and "Swap two screens" also ignore the abort, but they make only one request each.

**Why it happens:** Since API 2.1, Companion passes every action callback a `context.signal`: a signal that fires when the action's result is no longer needed. The callbacks here take only the event and never pass the signal on. The HTTP requests use only their own 5-second timeout, and the room loop never checks for an abort between screens. The v2.1 rules recommend honouring the signal in callbacks that talk to the network.

**Fix:** pass the abort signal from the action callbacks down to the HTTP request, and stop the room loop when it fires.

```ts
callback: async (event, context) => {
	// …
	await self.run('Room', async (api) => {
		for (const s of targets) {
			if (context.signal.aborted) throw new Error('aborted')
			await api.show(s.id, content, context.signal)
		}
	})
}
// in ScreenApi.get(): signal: AbortSignal.any([signal, AbortSignal.timeout(5000)])
```

Companion ignores errors thrown after an abort.

## 🟢 Low

### L1: Room action stops at the first screen that fails and leaves the rest unchanged

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:93-100`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/actions.ts#L93-L100)

**What goes wrong:** An operator presses a preset such as "Saal 1: all screens black" at the end of a session. If the request for one screen fails (a server error or a timeout on the 2nd of 6 screens, say), screens 3 to 6 are never sent and keep showing the previous speakers' names. The only sign is a warning in the log ("Room: …"), so the button looks like it worked.

**Why it happens:** The action sends the screens one after another inside a single "run" step. The first failed request ends the loop, and the error handler only logs a warning and returns.

**Fix:** send every screen even when one fails, then log which ones failed.

```ts
const results = await Promise.allSettled(targets.map((s) => api.show(s.id, content)))
const failed = targets.filter((_, i) => results[i].status === 'rejected').map((s) => s.name)
if (failed.length) throw new Error(`failed for ${failed.join(', ')}`)
```

### L2: Swap two screens and the room action skip expression values the module itself accepts

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:64-65`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/actions.ts#L64-L65), [`src/actions.ts:81-91`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/actions.ts#L81-L91)

**What goes wrong:** A user switches the "Screen A" option of "Swap two screens" to expression mode and enters a screen name such as `Lectern left`, or sets the "Show" option of "All screens of a room: EMPTY or black" to the expression `BLACK` (the word the "Sign" tooltip of "Show sign on screen" tells them to use). Companion compares the value with the dropdown's choices (screen ids, or `LEER` / `AUS`), finds no match, and skips the action. Nothing happens when the button is pressed. The same expressions work in "Show sign on screen", because its options allow custom values.

**Why it happens:** In API 2.x, a dropdown value from an expression must match one of the choices unless the field sets `allowCustom: true`. The `a` / `b` dropdowns of "Swap two screens" and the `room` / `content` dropdowns of the room action don't set it, even though the swap callback already accepts a screen name as well as an id. The room action's choice ids `LEER` / `AUS` are German while their labels are English, so users can't guess them.

**Fix:** allow custom values where the callback can handle them, or turn off expressions where they make no sense.

```ts
{ id: 'a', type: 'dropdown', label: 'Screen A', choices: screens, default: screens[0]?.id ?? '', allowCustom: true },
// room.content: allowCustom: true and run the value through resolveContent(),
// or disableAutoExpression: true
```

An `expressionDescription` naming the accepted values would also help.

### L3: A wrong server address shows a JavaScript error as the connection status

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:69-79`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/api.ts#L69-L79), [`src/main.ts:96-105`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/main.ts#L96-L105)

**What goes wrong:** A user enters a "Server address" that answers but isn't a NextKon Screen server, for example a router's web page at `http://192.168.1.1`. The connection turns red as it should, but the status text reads `Cannot read properties of null (reading 'gleich')` or `Cannot read properties of undefined (reading 'map')` instead of telling the user the address is wrong. Nothing crashes and polling continues.

**Why it happens:** The request helper returns whatever came back whenever the HTTP status is OK, even when the answer was not JSON (it then returns `null`) or is JSON of the wrong shape. The poll code then reads fields of that answer, which throws a JavaScript error, and the error's raw message becomes the connection status. The malformed answer is also stored as the module's state until the next good poll.

**Fix:** check the answer's shape before using it, and report a clear message when it is wrong.

```ts
// in ScreenApi.get(): throw on a 2xx answer that is not a JSON object
if (body === null || typeof body !== 'object') throw new ApiError('Unexpected answer from server – check the Server address', 0)
// in poll(): only apply a full state with Array.isArray(res.screens) && Array.isArray(res.namen)
```

### L4: Network errors show only fetch failed, and a bare IP is always tried over https

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:60-68`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/config.ts#L60-L68), [`src/api.ts:66-67`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/api.ts#L66-L67)

**What goes wrong:** The "Server address" tooltip tells users to enter `http://<IP>` for a ProPlayer Backup on the local network. A user who types only `192.168.1.20` gets `https://192.168.1.20`, and the connection status shows just "fetch failed". That text says nothing about TLS, a refused connection or an unknown host, and it is the same for every network error, including a DNS failure or no internet.

**Why it happens:** The address parser adds `https://` to any value without a scheme. When a request fails, the module reports only the error's message, which Node's `fetch` always sets to "fetch failed". The real reason (`ECONNREFUSED`, `ENOTFOUND`, a certificate error) is in the error's `cause`, which is dropped.

**Fix:** include the cause in the status text, and either default a bare IP address to `http://` or say in the tooltip that a missing scheme means https.

```ts
const cause = (e as { cause?: { code?: string; message?: string } }).cause
throw new ApiError(cause ? `${e.message}: ${cause.code ?? cause.message}` : e.message, 0)
```

### L5: Room presets overwrite each other when room names differ only in non-ASCII characters

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:53-72`](https://github.com/bitfocus/companion-module-nextkon-screen/blob/2ece07d8bd1b6f536046e0e762d105e00fc3e37c/src/presets.ts#L53-L72)

**What goes wrong:** With two rooms named, for example, "Raum Ä" and "Raum Ö", both rooms' presets get the same preset ids (`room_Raum___LEER` and `room_Raum___AUS`). In the presets panel, the General section shows the second room's "EMPTY" and "black" buttons twice, and the first room has no room presets at all.

**Why it happens:** The preset id is built from the room name with every character other than `A-Z`, `a-z`, `0-9`, `_` and `-` replaced by `_`. Umlauts and other non-ASCII letters all become `_`, so different room names can produce the same id, and the later preset overwrites the earlier one. Both ids are still added to the General section, so the surviving preset is listed twice.

**Fix:** build the room preset ids from something unique, such as the room's position in the list (`room_${i}_${content}`), or keep a set of used ids and add a counter when one repeats.

## 📝 Additional Notes

- First release: there is no previous tag, so the whole module was reviewed, not a diff.
- The module is on API 2.2 (base 2.2.1). The API checks covered the v2.0 and v2.1 rules only; rules specific to 2.2 (value-feedback result types, CSS colour strings, preset button notes, preset action-result local variables, the `sanitizeVariable` util) were not checked, because the 2.2 reference was not available to the reviewers.
