# Review: companion-module-rm-tallylights v2.0.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-rm-tallylights` |
| **Scope** | `tag` (first release: there is no previous tag to diff against, so the whole module was reviewed) |
| **Version** | v2.0.1 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Commit** | [`36acf94`](https://github.com/bitfocus/companion-module-rm-tallylights/commit/36acf9491e376dc2ca999f4cea2932531a60b5a1) |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The status shown for the connection in Companion's Connections list is the one the module sets with `updateStatus()`; Companion does not derive it from the module's feedbacks or its WebSocket | `updateStatus()` is documented in base's `base.d.ts` as the instance status setter; Companion's host code not checked | [M1](#m1-connection-status-stays-red-after-the-master-comes-online-and-green-after-it-goes-offline) |
| A2 | An HTTP request to a powered-off master on the LAN can hang until the configured timeout instead of failing at once with "connection refused" | Typical TCP behaviour when no host answers; depends on the network | [L3](#l3-actions-feedbacks-and-presets-are-missing-for-up-to-20-seconds-when-companion-starts-with-the-master-offline) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Connection status stays red after the master comes online, and green after it goes offline](#m1-connection-status-stays-red-after-the-master-comes-online-and-green-after-it-goes-offline)
- [ ] [L1: An empty Master address shows Master unreachable instead of asking for the address](#l1-an-empty-master-address-shows-master-unreachable-instead-of-asking-for-the-address)
- [ ] [L2: Tally feedbacks stay dark with no warning when the master's state socket cannot be reached](#l2-tally-feedbacks-stay-dark-with-no-warning-when-the-masters-state-socket-cannot-be-reached)
- [ ] [L3: Actions, feedbacks and presets are missing for up to 20 seconds when Companion starts with the master offline](#l3-actions-feedbacks-and-presets-are-missing-for-up-to-20-seconds-when-companion-starts-with-the-master-offline)
- [ ] [N1: Removing every camera on the master leaves the old cameras in dropdowns and presets](#n1-removing-every-camera-on-the-master-leaves-the-old-cameras-in-dropdowns-and-presets)

## 🟡 Medium

### M1: Connection status stays red after the master comes online, and green after it goes offline

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:111-112`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/main.ts#L111-L112), [`src/main.ts:137`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/main.ts#L137), [`src/main.ts:243-252`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/main.ts#L243-L252)

**What goes wrong:** A venue often powers up Companion before the RM Tally Lights master. At startup the connection shows a red Connection Failure, "Master unreachable". When the master boots, the module connects and the tally feedbacks ("Camera is Live", "Camera is Preview", "On Air is On", "Master is Connected") and variables start updating, but the connection status stays red "Master unreachable" until someone presses a button that sends a command. The reverse happens too: if the master goes offline after a good start, the feedbacks turn off but the connection status stays green until an action is pressed and times out. The status column doesn't tell the operator whether the module is actually talking to the master.

**Why it happens:** The connection status is only set in two places: once after the startup HTTP check of `/test`, and after each command an action sends. The live state comes over a separate WebSocket, and its "connected / disconnected" handler only updates the internal flag and the "Master is Connected" feedback. It never updates the connection status.

**Evidence:**

```ts
// src/main.ts:243-252
onConnected: (connected) => {
	this.state = setConnected(this.state, connected)
	if (connected) {
		this.unresolvedCameraIds.clear()
		void this.refreshCameras()
	}
	this.pushState()
},
```

**Fix:** update the connection status whenever the state socket opens or closes, and skip it once the instance is being destroyed (as `pushState()` already does).

```ts
onConnected: (connected) => {
	this.state = setConnected(this.state, connected)
	if (!this.destroyed) {
		this.updateStatus(connected ? InstanceStatus.Ok : InstanceStatus.Disconnected, connected ? undefined : 'State socket closed')
	}
	// ...
},
```

## 🟢 Low

### L1: An empty Master address shows Master unreachable instead of asking for the address

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:97-113`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/main.ts#L97-L113)

**What goes wrong:** When a user adds the connection and hasn't filled in "Master address" yet (it is empty by default), the connection goes red with Connection Failure "Master unreachable". That points the user at the network, when they only need to enter the address. The log says "No master address configured", but the status column doesn't.

**Why it happens:** The startup check of `/test` runs even when the address is empty. The empty address makes the request fail the same way an unreachable host does, so it is reported as "Master unreachable". Only the WebSocket start-up checks for an empty address.

**Fix:** at the start of `connect()`, after `stopSocket()`, check for an empty address, set a Bad Configuration status, still register the definitions, and return without probing.

```ts
if (!this.config.host) {
	this.updateStatus(InstanceStatus.BadConfig, 'Enter the master address')
	this.updateActions()
	this.updatePresets()
	this.updateFeedbacks()
	this.updateVariables()
	return
}
```

### L2: Tally feedbacks stay dark with no warning when the master's state socket cannot be reached

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/socket.ts:166-176`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/socket.ts#L166-L176)

**What goes wrong:** If the master answers HTTP but its state socket can't be reached (firmware older than v1.3.0, a firewall, or a port that doesn't serve `/ws`), the connection shows green and actions work. But "Camera is Live", "Camera is Preview", "On Air is On" and "Master is Connected" never light, and `$(rm-tallylights:live_cam)` stays at 0. At the default log level the log shows nothing, so the user can't tell why the feedbacks are dead.

**Why it happens:** A socket error is only logged at debug level, and a closed socket just schedules a reconnect without logging anything. Repeated failed connection attempts are invisible at the default log level.

**Fix:** log a warning once, after the first failed attempt or when the reconnect backoff reaches its maximum, for example "Could not open ws://host:port/ws — feedbacks need master firmware v1.3.0+". With the [M1](#m1-connection-status-stays-red-after-the-master-comes-online-and-green-after-it-goes-offline) fix in place, the connection status also shows the socket is down.

### L3: Actions, feedbacks and presets are missing for up to 20 seconds when Companion starts with the master offline

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:47-50`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/main.ts#L47-L50), [`src/main.ts:99-148`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/main.ts#L99-L148)

**What goes wrong:** When Companion starts or the connection is enabled, the module registers no actions, feedbacks, presets or variables until its startup HTTP requests finish. With the default "Request timeout (ms)" of 10000 and a master that doesn't answer, that can take 10–20 seconds. During that time the connection's buttons show their actions and feedbacks as unknown, and the presets list is empty.

**Why it happens:** `init()` waits for `connect()`, and `connect()` only registers the definitions after both the `/test` check and the camera-list request have finished.

**Fix:** register the definitions straight away in `init()`, with the current (empty) camera list, before starting the checks. `connect()` already rebuilds them once the camera list arrives. Optionally don't await `connect()` in `init()`.

## 💡 Nice to Have

### N1: Removing every camera on the master leaves the old cameras in dropdowns and presets

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:285-302`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/main.ts#L285-L302)

**What goes wrong:** If the operator deletes every camera on the master, the Camera dropdown on "Set Camera Live" and the "Cameras" preset section still list the old cameras (for example "3 — Wide") after a reconnect. They only clear when the connection settings are saved again. Removing some, but not all, cameras updates correctly.

**Why it happens:** The camera list is only replaced when the new list is not empty, because [`src/cameras.ts:37-41`](https://github.com/bitfocus/companion-module-rm-tallylights/blob/36acf9491e376dc2ca999f4cea2932531a60b5a1/src/cameras.ts#L37-L41) returns an empty list both for a failed request and for a master that really has no cameras, so the two can't be told apart.

**Fix:** have `fetchCameras()` return `null` (or a result with `ok: false`) when the request fails, so `refreshCameras()` can accept a successful empty list and keep the cached list only after a failed request.
