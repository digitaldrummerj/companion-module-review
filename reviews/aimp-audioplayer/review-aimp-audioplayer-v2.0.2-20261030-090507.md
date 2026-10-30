# Review: aimp-audioplayer v2.0.2 (follow-up to the v1.0.2 review)

| | |
| --- | --- |
| **Module** | aimp-audioplayer |
| **Version** | v2.0.2 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) |
| **Scope** | `tag` (first release: no previous published tag, so no diff was taken and the whole module was reviewed; every finding is new) |
| **Language** | JavaScript (ESM) |
| **Protocol** | WebSocket (AIMP HTTP Remote Control plugin, WebSocket mode) |
| **Commit** | [`26ece0c`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175) |
| **Prior review** | [v1.0.2 (2026-07-01)](review-aimp-audioplayer-v1.0.2-20260701-205147.md) |
| **Reviewed** | 2026-10-30 |

This is a follow-up to the v1.0.2 review. Every finding from that review is fixed in v2.0.2 (see [📝 Additional Notes](#-additional-notes)). The module also moved from HTTP polling to a WebSocket push connection, so this release was reviewed in full. The portal has never published a release of this module, so there is no earlier published tag to diff against.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a module process throws an uncaught exception, Companion logs it as a crash and restarts the module process; it does not catch the exception and carry on with the new settings | how Companion runs modules as child processes; `@companion-module/base` 2.0.4 registers no `uncaughtException` handler (grep of its `dist` found none). The crash was reproduced only in a standalone Node run of the module's `AimpWsClient`, not inside Companion | [H1](#h1-module-crashes-when-settings-are-saved-or-the-connection-is-disabled-while-aimp-is-still-connecting) |
| A2 | Companion renders a preset text size given as an unlisted numeric string (for example `'40'`) at that point size, rather than rejecting it or falling back to auto | the base typings only show that `'40'` is outside the `CompanionTextSize` union; Companion's renderer was not checked | [L5](#l5-preset-text-sizes-40-10-and-12-are-strings-the-api-does-not-allow) |
| A3 | Companion does not re-run feedbacks or reset variable values by itself when a connection's settings change; only the module's own `setVariableValues` and `checkFeedbacks` calls update them | general Companion host behaviour; the module code confirms it never pushes its reset state itself | [L6](#l6-buttons-keep-showing-the-old-players-state-after-the-connection-settings-change) |

## 📋 Issues

### Blocking

- [ ] [H1: Module crashes when settings are saved, or the connection is disabled, while AIMP is still connecting](#h1-module-crashes-when-settings-are-saved-or-the-connection-is-disabled-while-aimp-is-still-connecting)

### Non-blocking

- [ ] [L1: Status stays at Connecting forever when the host cannot form a valid WebSocket address](#l1-status-stays-at-connecting-forever-when-the-host-cannot-form-a-valid-websocket-address)
- [ ] [L2: Focus Track Index variable shows 0 when the focused track is unknown](#l2-focus-track-index-variable-shows-0-when-the-focused-track-is-unknown)
- [ ] [L3: Playlist Next/Previous Track jumps to the wrong place when a playlist holds the same file twice](#l3-playlist-nextprevious-track-jumps-to-the-wrong-place-when-a-playlist-holds-the-same-file-twice)
- [ ] [L4: Upgrade scripts are declared inline in main.js instead of their own upgrades.js](#l4-upgrade-scripts-are-declared-inline-in-mainjs-instead-of-their-own-upgradesjs)
- [ ] [L5: Preset text sizes 40, 10 and 12 are strings the API does not allow](#l5-preset-text-sizes-40-10-and-12-are-strings-the-api-does-not-allow)
- [ ] [L6: Buttons keep showing the old player's state after the connection settings change](#l6-buttons-keep-showing-the-old-players-state-after-the-connection-settings-change)
- [ ] [N1: Every position tick rewrites all 26 variables](#n1-every-position-tick-rewrites-all-26-variables)
- [ ] [N2: Track feedbacks make users type a full file path instead of picking the track](#n2-track-feedbacks-make-users-type-a-full-file-path-instead-of-picking-the-track)
- [ ] [N3: Play or Set focus dropdowns can be switched to expression mode, which has no real use](#n3-play-or-set-focus-dropdowns-can-be-switched-to-expression-mode-which-has-no-real-use)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: Module crashes when settings are saved, or the connection is disabled, while AIMP is still connecting

- **Source:** 🔎 protocol reviewer, QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/ws-client.js:52-71`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/ws-client.js#L52-L71), [`src/main.js:71-83`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L71-L83), [`src/main.js:118-124`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L118-L124)

**What goes wrong:** Say the AIMP Host is set to a PC that is off or unreachable (for example 192.168.1.50), or the user typed the wrong IP. The connection shows Connecting / Connection Failure and keeps retrying, and each attempt can wait up to 8 seconds for the handshake. If the user corrects the AIMP Host or WebSocket Port and clicks Save during one of those attempts, the module process crashes with "Unhandled 'error' event: WebSocket was closed before the connection was established". Companion then has to restart the module, and the log shows a crash instead of a clean reconnect to the new address. Disabling or deleting the connection during an attempt leaves the same crash in the log. Both reviewers reproduced this outside Companion with the module's own `AimpWsClient` and its bundled ws 8.21.0: connect to a host that never answers, call `close()` 200–500 ms later, and Node exits with code 1.

**Why it happens:** When the settings are saved or the connection is removed, the module tears down its WebSocket client: `configUpdated()` and `destroy()` both call `_teardown()`, which calls the client's `close()`. `close()` first removes every listener from the socket, including its error handler, and then calls `terminate()`. In ws 8.x, terminating a socket that is still connecting emits an `error` event on the next tick. No listener is left to receive it, so Node treats it as an uncaught exception and the process exits. The base package installs no handler that would catch it.

**Evidence:**

```js
// src/ws-client.js:52-71
	close() {
		this._stopped = true
		clearTimeout(this._reconnectTimer)
		clearTimeout(this._connectTimer)
		this._reconnectTimer = null
		this._connectTimer = null

		const ws = this._ws
		this._ws = null
		this._open = false
		if (ws) {
			ws.removeAllListeners()
			try {
				ws.terminate()
			} catch {
				// socket already gone
			}
		}
		this._settlePending()
	}
```

```js
// src/main.js:71-83
	async configUpdated(config) {
		this.config = config
		this._destroyed = false
		this._teardown()
		...
	async destroy() {
		this._destroyed = true
		this._teardown()
	}
// src/main.js:118-124
	_teardown() {
		this._stopInventoryTimer()
		if (this._ws) {
			this._ws.close()
			this._ws = null
		}
	}
```

```js
// node_modules/ws/lib/websocket.js:492-497, 1121, 1060 (ws 8.21.0)
  terminate() {
    if (this.readyState === WebSocket.CLOSED) return;
    if (this.readyState === WebSocket.CONNECTING) {
      const msg = 'WebSocket was closed before the connection was established';
      abortHandshake(this, this._req, msg);
      return;
...
    process.nextTick(emitErrorAndClose, websocket, err);
...
  websocket.emit('error', err);
```

Local loopback repro (a TCP server that accepts but never answers the handshake; `AimpWsClient.connect()`, then `close()` shortly after):

```text
node:events:497
      throw er; // Unhandled 'error' event
Error: WebSocket was closed before the connection was established
    at WebSocket.terminate (.../node_modules/ws/lib/websocket.js:496:7)
    at AimpWsClient.close (.../src/ws-client.js:65:8)
Emitted 'error' event on WebSocket instance at:
    at emitErrorAndClose (.../node_modules/ws/lib/websocket.js:1060:13)
exit=1
```

**Confirm by:** open [`src/ws-client.js:63-65`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/ws-client.js#L63-L65). `ws.removeAllListeners()` runs before `ws.terminate()`, and no `error` listener is added back. Then open `node_modules/ws/lib/websocket.js:494-497` and `1121`: `terminate()` on a connecting socket emits `error` on the next tick.

**Fix:** keep a do-nothing error listener on the old socket while it is torn down.

```js
if (ws) {
	ws.removeAllListeners()
	ws.on('error', () => {})
	try {
		ws.terminate()
	} catch {
		// socket already gone
	}
}
```

Another option is to remove only the `open` / `message` / `close` listeners and keep the existing `error` handler, which already ignores stale sockets through `if (this._ws !== ws) return`.

## 🟢 Low

### L1: Status stays at Connecting forever when the host cannot form a valid WebSocket address

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/ws-client.js:112-121`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/ws-client.js#L112-L121)

**What goes wrong:** If the AIMP Host value cannot be turned into a valid `ws://` address (for example an IPv6 literal such as `::1`), the connection keeps showing Connecting instead of an error. The only clue is an error line in the log, repeated on every retry.

**Why it happens:** When creating the WebSocket throws, `_openSocket()` only logs the error and schedules another attempt. It never emits `close`, so the module never sets the Connection Failure or Bad Config status.

**Fix:** emit a status-bearing event in that branch, or check the host in `main.js` and call `this.updateStatus(InstanceStatus.BadConfig, 'Invalid host')` instead of retrying an address that can never work.

### L2: Focus Track Index variable shows 0 when the focused track is unknown

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:281-286`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L281-L286)

**What goes wrong:** The `$(aimp-remote:focus_track_index)` variable shows 0, the same as the first track, when the focused playlist's tracks have not loaded yet, failed to load, or when the focused file appears in the playlist more than once. A button labelled "Track #$(aimp-remote:focus_track_index)" then shows the wrong track number.

**Why it happens:** `_trackIndexById()` returns 0 both when the track list isn't cached and when the track isn't found. Repeat occurrences of a file are cached with a `|2`-style suffix, but AIMP's status push carries only the bare file path, so they never match.

**Fix:** return an empty value (or -1) when the track isn't found, and refresh the variable once the focused playlist's tracks finish loading.

### L3: Playlist Next/Previous Track jumps to the wrong place when a playlist holds the same file twice

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:294-300`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/actions.js#L294-L300)

**What goes wrong:** Take a playlist where the same file is at positions 2 and 5, and position 5 is playing. Pressing a button with "Playlist: Next Track (in playlist)" plays position 3 instead of 6, because the module believes position 2 is playing.

**Why it happens:** The module remembers the playing and focused track by bare file path ([`src/main.js:206`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L206), [`src/main.js:234`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L234)), while the track cache gives repeat occurrences an id of `path|n` ([`src/main.js:413-415`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L413-L415)). The lookup therefore always matches the first occurrence.

**Fix:** track the playing/focused position by the server's track index instead of the file path, or store the index next to the id in the track cache and match on that.

### L4: Upgrade scripts are declared inline in main.js instead of their own upgrades.js

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:26`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L26)

**What goes wrong:** Users see no difference today, because the list is empty. When an option is later renamed (for example the Playlist dropdown of "Playlist: Play from Beginning"), its upgrade script will land in `main.js` instead of the file the template and other modules use, which makes it easier to miss.

**Why it happens:** `export const UpgradeScripts = []` is defined directly in the entry file. The JS template (v2.0.4) keeps it in a dedicated `src/upgrades.js` that `main.js` imports and re-exports.

**Fix:** create `src/upgrades.js` with `export const UpgradeScripts = []`, then in `main.js` use `import { UpgradeScripts } from './upgrades.js'` and `export { UpgradeScripts }`.

### L5: Preset text sizes 40, 10 and 12 are strings the API does not allow

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:18`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/presets.js#L18) (also lines 34, 43, 51, 59, 162, 175, 188, 199, 207, 215, 223, 241, 254)

**What goes wrong:** Presets such as "Play/Pause" (size `'40'`), "Track Info" (size `'10'`) and "Focus: Next Playlist" (size `'12'`) probably render at the intended size, but the button's Font size control in the editor may show a value that isn't one of its standard choices. The presets still work.

**Why it happens:** In `@companion-module/base` 2.0.4 the text size type is `'auto' | '7' | '14' | '18' | '24' | '30' | '44' | number`. The strings `'40'`, `'10'` and `'12'` aren't in that list, and because the module is plain JavaScript nothing type-checks the presets.

**Fix:** use numbers for sizes outside the string list (`size: 40`, `size: 10`, `size: 12`), or pick one of the allowed strings such as `'44'` or `'14'`.

### L6: Buttons keep showing the old player's state after the connection settings change

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:60-78`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L60-L78), [`src/main.js:126-135`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L126-L135)

**What goes wrong:** A user changes AIMP Host from 127.0.0.1 to 192.168.1.50 and that host is unreachable. Buttons still show `$(aimp-remote:playing_track_title)` = "Song A" and the "Player: Is Playing" feedback stays lit, although the module has internally reset to "stopped". The playlist dropdowns in "Playlist: Play from Beginning" also keep listing the old host's playlists until the new host connects. On first start, all variables stay empty until AIMP pushes its first status.

**Why it happens:** `configUpdated()` resets the module's internal state and playlist lists (`_resetCaches()`), but never pushes the reset values to Companion (`updateVariables`, `checkAllFeedbacks`) or rebuilds the action, feedback and preset definitions. `init()` defines the variables but never sets their starting values.

**Fix:** after `_resetCaches()` in `configUpdated()`, and after `registerVariables(this)` in `init()`, call `updateVariables(this)` and `this.checkAllFeedbacks()`. In `configUpdated()` also call `registerFeedbacks(this)`, `this.setActionDefinitions(buildActions(this))` and `updatePresets(this)`.

## 💡 Nice to Have

### N1: Every position tick rewrites all 26 variables

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:174-179`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/main.js#L174-L179)

**What goes wrong:** Users see no difference, but on every playback position update the module sends all 26 variables (titles, playlist names and so on) to Companion, although only position, duration, remaining and progress changed. That is extra traffic and variable processing for as long as a track plays.

**Why it happens:** The `position` event handler calls the full `updateVariables(this)`.

**Fix:** add a small helper that sets only `position`, `position_fmt`, `duration`, `duration_fmt`, `remaining`, `remaining_fmt` and `progress_pct`, and call it from the `position` branch.

### N2: Track feedbacks make users type a full file path instead of picking the track

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:61-111`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/feedbacks.js#L61-L111)

**What goes wrong:** To light a button while a given track plays, users add "Playing: Track matches (playlist + file path)" and must type the exact path, for example `C:\Music\Intro.mp3`. A typo or a different drive letter means the feedback never lights. The "Track: Play or Focus (browse list)" action already offers a track dropdown, but these feedbacks don't.

**Why it happens:** The `focus_track_is` and `playing_track_is` feedbacks use a plain text field for the track; the per-playlist track dropdowns are only used in `actions.js`.

**Fix:** reuse the per-playlist track dropdown pattern from the browse action (one dropdown per playlist with `isVisibleExpression` and `allowCustom: true`), or at least add a description telling users to copy the path from `$(aimp-remote:playing_track_id)`.

### N3: Play or Set focus dropdowns can be switched to expression mode, which has no real use

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:258-267`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/actions.js#L258-L267), [`src/actions.js:336-345`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/actions.js#L336-L345), [`src/actions.js:384-392`](https://github.com/bitfocus/companion-module-aimp-audioplayer/blob/26ece0ca6c08960f138aa3b10955e8ca1b657175/src/actions.js#L384-L392)

**What goes wrong:** In "Playlist: Play or Focus" and the two "Track: Play or Focus" actions, users can switch the Action dropdown (Play / Set focus) to expression mode. Any expression result other than `play` or `select` makes the action do nothing. Normal dropdown use is unaffected.

**Why it happens:** API 2.0 lets a module mark fixed-choice fields with `disableAutoExpression: true` so they can't be switched to expressions; these dropdowns don't set it.

**Fix:** add `disableAutoExpression: true` to the three `action` dropdowns.

## 📝 Additional Notes

- First release: the portal has never published this module, so no `previousTag..reviewTag` diff was taken and the whole module was reviewed. Earlier git tags (v1.0.0 – v2.0.1) exist in the repo but were never published.
- Follow-up check against the [v1.0.2 review](review-aimp-audioplayer-v1.0.2-20260701-205147.md): all of its findings are fixed in v2.0.2.
  - C1 (manifest entrypoint): fixed, `runtime.entrypoint` is now `../src/main.js`.
  - C3 (manifest `id` vs `name`): fixed, both are `aimp-audioplayer`.
  - C4 (keyword `aimp`): fixed, keywords are now `audio`, `player`, `music`.
  - C5 (`repository.url`): fixed, it points at `bitfocus/companion-module-aimp-audioplayer`.
  - C6 (missing `.gitattributes`): fixed, the file now matches the template.
  - M1 (overlapping polls) and M3 (80 ms poll default): no longer apply; player state now arrives as WebSocket push events, and the only timer is a 30 s playlist inventory refresh that is stopped on teardown.
  - M2 (failed track load cached forever): fixed, failures are tracked in a separate `tracksError` map and the track cache stays empty so a retry is allowed.
  - M5 (work continuing after `destroy()`): fixed, a `_destroyed` flag now guards the socket events and the track-loading continuations.
- `-RunBuild` passed: `yarn install --immutable` and `yarn package` both succeeded.
