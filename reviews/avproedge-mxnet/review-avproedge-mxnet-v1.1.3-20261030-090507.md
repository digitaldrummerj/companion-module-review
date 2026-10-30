# Review: companion-module-avproedge-mxnet v1.1.3

| Field | Value |
| --- | --- |
| **Module** | `companion-module-avproedge-mxnet` |
| **Scope** | `tag` (changes since v1.1.2) |
| **Version** | v1.1.3 |
| **Release** | Update — last published v1.1.2 |
| **API** | 1 (base 1.11.3, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`faa013e`](https://github.com/bitfocus/companion-module-avproedge-mxnet/tree/faa013ecba8fd63c0e7618510e268e3fd0f685f3) |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | An uncaught exception thrown inside a `setInterval` callback ends the module's process (Node 22 default), and Companion then restarts the connection | `node_modules/@companion-module/base/dist` installs no `uncaughtException` / `unhandledRejection` handler (grepped); the crash reproduced in plain Node 22.21.1, but not observed inside Companion's host | [M1](#m1-leftover-polling-timers-can-crash-the-module-after-the-ip-address-is-cleared) |
| A2 | When the Control Box resets the connection (ECONNRESET, e.g. a device reboot), the socket emits `error` and `close` but not `end`, so the module's disconnect handler does not run | Node `net.Socket` behaviour; not checked in the module or base package | [M1](#m1-leftover-polling-timers-can-crash-the-module-after-the-ip-address-is-cleared) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Leftover polling timers can crash the module after the IP Address is cleared](#m1-leftover-polling-timers-can-crash-the-module-after-the-ip-address-is-cleared)
- [ ] [L1: The connection state variable never stays on disconnected](#l1-the-connection-state-variable-never-stays-on-disconnected)
- [ ] [NR1: The mock Control Box helper uses npm instead of Yarn](#nr1-the-mock-control-box-helper-uses-npm-instead-of-yarn)

## 🟡 Medium

### M1: Leftover polling timers can crash the module after the IP Address is cleared

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/instance.js:89-114`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/instance.js#L89-L114), [`src/instance.js:282-296`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/instance.js#L282-L296), [`src/instance.js:49-56`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/instance.js#L49-L56), [`src/instance.js:303-308`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/instance.js#L303-L308)

**What goes wrong:** Each time the MXnet Control Box drops the connection with an error (for example when it reboots), the module starts one more polling or heartbeat timer than it stops. After three resets there are four timers, so the module sends `matrix preset list`, `matrix list` and `config get devicelist` four times every 5 seconds instead of once, and the extra timers keep running after a settings change or when the connection is disabled. New in this release: if the user then clears the **IP Address** field and saves (status "No host configured"), the next leftover tick throws "Cannot read properties of undefined (reading 'pollMatrixPresets')" and crashes the module's process. Users whose Control Box never errors, or who never clear the IP Address, don't hit the crash, though they can still collect duplicate timers.

**Why it happens:** On a socket error, Companion's TCP helper reconnects the same socket and reports "connected" again. The module's error handler doesn't stop the running timers (only the clean-disconnect and init paths do), so the connect handler starts a new timer and overwrites the stored handle of the old one. The orphaned timers can no longer be stopped by `destroy()` or `configUpdated()`. In v1.1.2 the client object stayed set after closing, so a stray tick was harmless; v1.1.3's new `closeClient()` sets it to `undefined`, and the timer callbacks call it without a guard.

**Evidence:**

```js
// src/instance.js:49-56 (new in v1.1.3)
	closeClient() {
		if (this.mxnetClient !== undefined) {
			this.mxnetClient.close()
			this.mxnetClient = undefined
		}

		this.clearAllIntervals()
	}
// src/instance.js:89-93 (no clearAllIntervals on error)
	onError(err) {
		this.setConnectionState('error')
		this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
		this.log('error', 'Network error: ' + err.message)
	}
// src/instance.js:282-288 (both overwrite this.heartbeatInterval without clearing it)
	startHeartbeatInterval() {
		this.heartbeatInterval = setInterval(() => this.mxnetClient.sendHeartbeatCommand(), this.heartbeatTime)
	}

	startPollingInterval() {
		this.heartbeatInterval = setInterval(() => this.pollMxnetInfo(), this.config.pollingInterval || 5000)
	}
// src/instance.js:303-308 (new empty-host branch)
		if (!config.host) {
			this.closeClient()
			this.setConnectionState('not configured')
			this.updateStatus(InstanceStatus.BadConfig, 'No host configured')
			return
		}
```

**Fix:** stop any running timers before starting new ones, keep the polling timer in its own field, and guard the timer callbacks so a stray tick after closing is harmless.

```js
onConnect() {
	this.clearAllIntervals()
	// ...
}

startPollingInterval() {
	this.pollingInterval = setInterval(() => this.pollMxnetInfo(), this.config.pollingInterval || 5000)
}

pollMxnetInfo() {
	this.mxnetClient?.pollMatrixPresets()
	this.mxnetClient?.pollMatrixes()
	this.mxnetClient?.pollDevices()
}
```

## 🟢 Low

### L1: The connection state variable never stays on disconnected

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/mxnet/mxnetClient.js:55-59`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/mxnet/mxnetClient.js#L55-L59)

**What goes wrong:** [`companion/HELP.md:31`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/companion/HELP.md#L31) documents `$(avproedge-mxnet:connection_state)` as one of `connecting`, `connected`, `disconnected`, `error` or `not configured`. When the Control Box closes the telnet session, the variable goes straight from `connected` to `connecting`, so a button or trigger built on `connection_state == disconnected` (for example a red "MXnet offline" tile) never lights up, and the Disconnected connection status never shows. `connecting` still appears, so users can tell the link dropped.

**Why it happens:** New in this release, the socket's close handler calls the disconnect handler, which sets `disconnected` / Disconnected ([`src/instance.js:95-100`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/instance.js#L95-L100)), and then immediately reconnects, which overwrites both with `connecting` / Connecting ([`src/instance.js:83-87`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/instance.js#L83-L87)) in the same tick.

**Fix:** either drop `disconnected` from the documented values in HELP.md (and the comment at [`src/instance.js:58`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/src/instance.js#L58)), or reconnect after a short delay instead of calling `init()` straight from the close handler, so the disconnected state can be seen. If you add a delay, clear that timer in `close()`.

## 🔮 Next Release

### NR1: The mock Control Box helper uses npm instead of Yarn

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED) · moved from Critical by the reviewer: not blocking for this release, fix it in the next one
- **Classification:** ⚠️ PRE-EXISTING (the lockfile has been tracked since the first release, commit `486ba90`)
- **File:** [`mock_control_box/package-lock.json`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/mock_control_box/package-lock.json)

**What goes wrong:** No direct user-visible effect. The repository tracks an npm lockfile, `mock_control_box/package-lock.json`, for the local mock Control Box helper. Companion modules use Yarn, and the template's `.gitignore` excludes `package-lock.json` to keep npm lockfiles out of module repositories.

**Why it happens:** The helper (`mock_control_box/package.json`, which depends on `telnetlib`) was set up with npm, and its lockfile was committed in the first release. The module's own `.gitignore` now lists `package-lock.json` too, but a `.gitignore` rule only stops new files from being added; it doesn't untrack files that are already committed.

**Evidence:**

```text
Expected: no file matching template .gitignore pattern 'package-lock.json' is committed
Found:    mock_control_box/package-lock.json (tracked)
```

**Confirm by:** run `git ls-files mock_control_box` in the module repo at v1.1.3. [`mock_control_box/package-lock.json`](https://github.com/bitfocus/companion-module-avproedge-mxnet/blob/faa013ecba8fd63c0e7618510e268e3fd0f685f3/mock_control_box/package-lock.json) is listed.

**Fix:** switch the mock Control Box helper to Yarn, like the module itself. Remove the npm lockfile from the repository and install the helper's dependencies with Yarn from now on. The module uses Yarn 4, which only installs a nested folder as its own project when that folder has a `yarn.lock`, so create an empty one first and commit the `yarn.lock` Yarn writes.

```bash
git rm mock_control_box/package-lock.json
cd mock_control_box
touch yarn.lock
yarn install
git add yarn.lock
```
