# companion-module-vyv-photon v4.0.0 — Release Review

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-vyv-photon`](https://github.com/bitfocus/companion-module-vyv-photon) |
| **Scope** | `tag` (`v3.1.1..v4.0.0`) |
| **Version** | v4.0.0 ([`c18f22a`](https://github.com/bitfocus/companion-module-vyv-photon/commit/c18f22aacdb19faecc120dfb20361a6d21088d4b)) |
| **Release** | Update — last published v3.1.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **API rules checked** | API 2.0, 2.1 and 2.2 rules plus the v1 → v2 migration checks |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When Photon quits or restarts, it closes the TCP connection cleanly, which the module sees as an `end` event. If Photon resets the connection instead, the leftover timer comes from the older `error` handler ([`index.js:196-198`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L196-L198)), which has the same pattern and the same fix | Node socket behaviour; how Photon closes its connections is not visible in the module. The leak itself is proven from the code whichever handler fires | [H1](#h1-a-reconnect-started-when-photon-closes-the-connection-is-never-cancelled-so-it-survives-settings-changes-and-removal) |
| A2 | Companion can start a connection whose saved settings have no port value (for example a carried-over or hand-edited config), because it does not fill in missing config defaults for existing connections | The config field's `default: '55503'` covers new connections; whether Companion back-fills missing keys is host behaviour not visible in the module or base | [L1](#l1-the-connection-crash-loops-when-its-saved-settings-have-no-target-port) |
| A3 | Companion routes the base library's warnings to the connection's log, where users see them | `node_modules/@companion-module/base/dist/logging.js` (the sink lookup); reproduced only with the default console sink, the host side was not checked | [M1](#m1-every-start-of-the-module-logs-two-deprecation-warnings-that-look-like-faults) |
| A4 | Companion's add-connection list and search show each `products` entry as its own product, so one comma-separated string shows as one product | The manifest schema defines `products` as an array of single product names; the UI rendering is not in the module or base | [L2](#l2-xenon-and-tachyon-do-not-show-up-as-separate-products-in-the-connection-list) |
| A5 | Companion's Presets panel shows a group's name as a heading under its section's name, so a section and its only group with the same name show the same heading twice | Base 2.2.2 preset structure typings (`dist/module-api/preset/structure.d.ts`); the UI rendering is not in base | [N1](#n1-the-presets-panel-shows-the-default-cues-heading-twice) |

## 📋 Issues

### Blocking

- [ ] [C1: The module's code lives in the repository root instead of src/](#c1-the-modules-code-lives-in-the-repository-root-instead-of-src)
- [ ] [C2: Built package files and debug logs are not ignored by git](#c2-built-package-files-and-debug-logs-are-not-ignored-by-git)
- [ ] [C3: Missing .gitattributes, so line endings are not kept as LF](#c3-missing-gitattributes-so-line-endings-are-not-kept-as-lf)
- [ ] [C4: The .prettierignore file is missing the template's LICENSE.md entry](#c4-the-prettierignore-file-is-missing-the-templates-licensemd-entry)
- [ ] [H1: A reconnect started when Photon closes the connection is never cancelled, so it survives settings changes and removal](#h1-a-reconnect-started-when-photon-closes-the-connection-is-never-cancelled-so-it-survives-settings-changes-and-removal)

### Non-blocking

- [ ] [M1: Every start of the module logs two deprecation warnings that look like faults](#m1-every-start-of-the-module-logs-two-deprecation-warnings-that-look-like-faults)
- [ ] [M2: No release workflow, so GitHub releases do not get the built package attached](#m2-no-release-workflow-so-github-releases-do-not-get-the-built-package-attached)
- [ ] [L1: The connection crash-loops when its saved settings have no Target Port](#l1-the-connection-crash-loops-when-its-saved-settings-have-no-target-port)
- [ ] [L2: Xenon and Tachyon do not show up as separate products in the connection list](#l2-xenon-and-tachyon-do-not-show-up-as-separate-products-in-the-connection-list)
- [ ] [N1: The Presets panel shows the Default Cues heading twice](#n1-the-presets-panel-shows-the-default-cues-heading-twice)
- [ ] [N2: The Special Code choice can be switched to an expression that needs the raw device codes](#n2-the-special-code-choice-can-be-switched-to-an-expression-that-needs-the-raw-device-codes)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The module's code lives in the repository root instead of src/

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW — template check on this release (the root layout predates v4.0.0; `index.js` and `presets.js` were changed in this release)
- **Files:** [`actions.js`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/actions.js), [`cues.js`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/cues.js), [`index.js`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js), [`presets.js`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/presets.js), [`upgrades.js`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/upgrades.js)

**What goes wrong:** The module's five source files sit next to `package.json` at the top of the repository. The JavaScript template keeps all module code under `src/`, with `src/main.js` as the entry point. Users see no difference, but anyone who later maintains or troubleshoots the module (or Bitfocus tooling that expects the template layout) finds the code in an unexpected place.

**Why it happens:** The module was never moved to the template's folder layout. This release migrates the module to API v2 but keeps the old layout.

**Expected vs found:**

```text
Expected (companion-module-template-js @ 89da037):
  src/main.js, src/actions.js, src/upgrades.js, ...   all source under src/
  package.json             "main": "src/main.js"
  companion/manifest.json  "entrypoint": "../src/main.js"

Found (v4.0.0):
  actions.js, cues.js, index.js, presets.js, upgrades.js   at the repository root
  package.json             "main": "index.js"
  companion/manifest.json  "entrypoint": "../index.js"
```

**Fix:** move the five files into `src/` (renaming `index.js` to `src/main.js` to match the template) and point the package and manifest at the new entry point. The relative imports between the files (`./actions.js`, `./cues.js`, …) stay as they are when the files move together.

```json
// package.json
"main": "src/main.js",
```

```json
// companion/manifest.json
"entrypoint": "../src/main.js"
```

### C2: Built package files and debug logs are not ignored by git

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW — this release edited the file (it added `/.yarn`) but left the template entries out
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/.gitignore)

**What goes wrong:** After `yarn package`, the generated `vyv-photon-4.0.0.tgz` shows up as an untracked file in `git status`, so it can easily be committed by accident. The same goes for a `package-lock.json` created by running `npm` and for `DEBUG-*` log files.

**Why it happens:** The module ignores only `/pkg.tgz`, while the packaging tool names the file after the module and version. The template ignores every `.tgz` at the root, plus `package-lock.json` and `DEBUG-*`.

**Expected vs found:**

```text
Missing template .gitignore entries: package-lock.json, /*.tgz, DEBUG-*

Template .gitignore:          Module .gitignore (v4.0.0):
  node_modules/                 node_modules/
  package-lock.json             .gitignore
  /pkg                          /pkg
  /*.tgz                        /pkg.tgz
  DEBUG-*                       /.yarn
  /.yarn
```

**Fix:** use the template's `.gitignore`.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C3: Missing .gitattributes, so line endings are not kept as LF

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW — template check on this release (the file was already missing at v3.1.1)
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor on Windows can check the module out and commit it back with CRLF line endings. That shows up as whole-file diffs, and prettier then reports every line of the changed files.

**Why it happens:** The template ships a `.gitattributes` that tells git to store and check out every text file with LF line endings. This module has no `.gitattributes`.

**Expected vs found:**

```text
Expected: .gitattributes (tracked by the template)
  * text=auto eol=lf
Found: no .gitattributes in the repository
```

**Fix:** add the template's `.gitattributes` at the repository root.

```text
* text=auto eol=lf
```

### C4: The .prettierignore file is missing the template's LICENSE.md entry

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW — template check on this release (the file is unchanged since v3.1.1)
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/.prettierignore#L2)

**What goes wrong:** `yarn format` (prettier) follows a different ignore list from the template, so a `LICENSE.md` added later would be reformatted by prettier.

**Why it happens:** The module's `.prettierignore` replaced the template's `/LICENSE.md` entry with `pkg`. The extra `pkg` entry is generated build output and is fine to keep; only the missing `/LICENSE.md` entry is the finding.

**Expected vs found:**

```text
.prettierignore line 2: found 'pkg', template '/LICENSE.md'

Template:        Module (v4.0.0):
  package.json     package.json
  /LICENSE.md      pkg
```

**Fix:** add the template's entry back; keeping `pkg` as well is fine.

```text
package.json
/LICENSE.md
pkg
```

## 🟠 High

### H1: A reconnect started when Photon closes the connection is never cancelled, so it survives settings changes and removal

- **Source:** 🔎 protocol reviewer, QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`index.js:201-213`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L201-L213), [`index.js:56-66`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L56-L66)

**What goes wrong:** Say an operator presses a button with the "Special Code" action set to "Restart Photon" or "Quit Photon", or the Photon server closes the TCP connection for any other reason. The module now waits 5 seconds (10 seconds after 3 or more failures) and then reconnects. Nothing can cancel that pending reconnect:

- If the operator saves the connection settings (say, to correct the Target IP) or presses a button with "Update Target IP Address" or "Update Target Port" inside that window, the new connection comes up and is then torn down when the old timer fires, and the module reconnects once more. If Photon is still down at that moment, two reconnect loops run side by side, each one tearing down the other's connection attempt, until Photon is back.
- If the operator disables or deletes the connection inside that window, the timer still fires afterwards and opens a new TCP connection to the Photon (for example `192.168.1.50:55503`) for a connection that no longer exists. A reviewer harness reproduced this: `destroy()` ran at t=1.0 s and a second TCP connection reached the test server at t=5.2 s. Companion stops the module's process after a connection is removed, but the module still has to stop its own timers.

Users on v3.1.1 never hit this, because that version's reconnect-on-close code never ran (see below).

**Why it happens:** This release renamed the module's "connection closed" listener from `close` to `end`. The v1 TCP helper (`TCPHelper` in base 1.14.1) never sends a `close` event, so the old listener was dead code. The v2 helper (base 2.2.2) does send `end` when Photon closes the connection, so the `setTimeout(() => this.init_tcp(), …)` inside the listener now runs in normal use. The timer handle is never stored, so neither `destroy()` (called when a connection is disabled or deleted) nor `init_tcp()` (called by `configUpdated()` and the Update Target IP/Port actions) can cancel it. The module creates the helper with `reconnect: false`, and the helper's own `destroy()` only clears the helper's internal timers, not this one. The older `error` listener at [`index.js:196-198`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L196-L198) has the same untracked timer; it predates this release, but the same fix covers it.

**Evidence:**

```js
// index.js:56-66 (v4.0.0)
	async destroy() {
		if (this.config.verbose) {
			this.log('info', 'Destroy called, tearing down socket if exists')
		}
		if (this.socket) {
			this.socket.destroy()
			if (this.config.verbose) {
				this.log('info', 'Socket destroyed')
			}
		}
	}
```

```js
// index.js:116-119 (v4.0.0) - the helper's own reconnect is off, so the module schedules reconnects itself
		this.socket = new TCPHelper(this.config.host, Number(this.config.port), {
			reconnect: false,
		})
```

```js
// index.js:196-213 (v4.0.0)
			setTimeout(() => {
				this.init_tcp()
			}, this.reconnectInterval)
		})

		this.socket.on('end', () => {
			if (this.config.verbose) {
				this.log('warn', 'TCP connection closed')
			}
			this.setVariableValues({
				connection_status: 'disconnected',
				connection_failures: this.connectionFailures.toString(),
			})

			setTimeout(() => {
				this.init_tcp()
			}, this.reconnectInterval)
		})
```

```diff
// git diff v3.1.1..v4.0.0 -- index.js
-		this.socket.on('close', () => {
+		this.socket.on('end', () => {
```

```text
// @companion-module/base 1.14.1 dist/helpers/tcp.js (used by v3.1.1) - every emit(), no 'close'
63:            this.emit('error', err);
69:            this.emit('connect');
77:            this.emit('end');
79:        this._socket.on('data', (data) => this.emit('data', data));
80:        this._socket.on('drain', () => this.emit('drain'));
127:            this.emit('error', error2);
159:            this.emit('status_change', status, message);
```

```js
// node_modules/@companion-module/base (2.2.2) dist/helpers/tcp.js - 'end' is emitted; destroy() clears only the helper's own timer
        this._socket.on('end', () => {
            this.#connected = false;
            this.#new_status(InstanceStatus.Disconnected);
            if (!this.#connecting && this.#options.reconnect) {
                this.#queueReconnect();
            }
            this.emit('end');
        });
...
    destroy() {
        ...
        if (this.#reconnectTimer !== undefined) {
            clearTimeout(this.#reconnectTimer);
        ...
        this._socket.removeAllListeners();
        this.removeAllListeners();
        this._socket.destroy();
    }
```

```text
// grep -n "setTimeout|clearTimeout" actions.js index.js presets.js
index.js:196:			setTimeout(() => {
index.js:210:			setTimeout(() => {
(no clearTimeout anywhere in the module)
```

**Confirm by:** open [`index.js:210-212`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L210-L212) and check that the `setTimeout` handle is thrown away, then [`index.js:47-66`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L47-L66): neither `configUpdated()` nor `destroy()` calls `clearTimeout`. Run `git diff v3.1.1..v4.0.0 -- index.js` to see the `close` → `end` rename that makes the listener run.

**Fix:** keep one reconnect timer, and cancel it whenever the connection is rebuilt or removed. Schedule it from both the `end` and the `error` listeners through one helper:

```js
// index.js
	scheduleReconnect() {
		clearTimeout(this.reconnectTimer)
		this.reconnectTimer = setTimeout(() => {
			this.reconnectTimer = undefined
			this.init_tcp()
		}, this.reconnectInterval)
	}

	init_tcp() {
		clearTimeout(this.reconnectTimer)
		this.reconnectTimer = undefined
		// ... existing code ...
	}

	async destroy() {
		clearTimeout(this.reconnectTimer)
		this.reconnectTimer = undefined
		// ... existing code ...
	}

	// in the 'error' and 'end' listeners, replace the setTimeout(...) blocks with:
	this.scheduleReconnect()
```

A simpler alternative is to drop the manual timers and let the helper reconnect for you with `new TCPHelper(host, Number(port), { reconnect: true, reconnect_interval: 5000 })`; the helper's `destroy()` already cancels its own reconnect timer.

## 🟡 Medium

### M1: Every start of the module logs two deprecation warnings that look like faults

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:235`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L235), [`index.js:243`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L243), [`actions.js:68`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/actions.js#L68), [`actions.js:91`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/actions.js#L91)

**What goes wrong:** Anyone who opens the log of a VYV Photon connection on v4.0.0 sees two warnings every time the module starts: "Regex.PORT is deprecated. Use a number input field with min: 1 and max: 65535 instead" and "Regex.IP is deprecated. Use IPV4 instead, or preferably allow any text so that hostnames and IPv6 addresses can be entered". They look like faults and send users looking for a problem that isn't there. The old IP pattern also keeps rejecting hostnames such as `photon.local` and IPv6 addresses in the "Target IP" setting and in the "New IP Address" option of the "Update Target IP Address" action. Buttons keep working.

**Why it happens:** This release moves to `@companion-module/base` 2.2.2, which deprecates the ready-made `Regex.IP` and `Regex.PORT` patterns and logs a one-time warning whenever a module reads one (`dist/module-api/enums.js`, the `deprecatedRegexKeys` map). The module reads both in its config fields ([`index.js:230-244`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L230-L244), edited in this release) and in two action options, which are built in `init()`. The reviewer reproduced both warnings by building the action definitions against the installed base 2.2.2. This is the API 2.2 rule "Deprecated Regex patterns" (base 2.2.2+), which is a 🟡 Medium finding. The installed base 2.2.2 lists both `IP` and `PORT` in `deprecatedRegexKeys` (`node_modules/@companion-module/base/dist/module-api/enums.js:56-68`), and reading either key logs the warning once per key. The four reads are [`index.js:235`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L235) (Target IP), [`index.js:243`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L243) (Target Port), [`actions.js:68`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/actions.js#L68) (New Port) and [`actions.js:91`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/actions.js#L91) (New IP Address).

**Fix:** follow the base library's advice for each field:

1. **"Target Port" setting:** make it `type: 'number'` with `min: 1`, `max: 65535` and `default: 55503`, and append an upgrade script that turns a saved string `port` into a number through `updatedConfig`. `Number(this.config.port)` in `init_tcp()` already handles both.
2. **"Target IP" setting:** drop the `regex` so hostnames and IPv6 addresses can be entered (the TCP helper accepts both), or use `Regex.IPV4` if Photon only works with IPv4.
3. **"Update Target Port" action, "New Port" option:** drop the regex, or make it `type: 'number'` with min 1 / max 65535. The number type needs an appended upgrade script: when `options.new_port.isExpression` is false, write back `{ isExpression: false, value: Number(options.new_port.value) }`, and leave expressions untouched.
4. **"Update Target IP Address" action, "New IP Address" option:** drop the regex, or use `Regex.IPV4`.

`Regex.IPV4` is safe to use because `package.json` pins `@companion-module/base` `~2.2.2`, the first version that has it. Changing the Target Port setting from `textinput` to `number` changes the type of the saved value, so the upgrade script in step 1 is required, not optional. The same applies to the action-option upgrade in step 3. Add both scripts to the end of the `UpgradeScripts` array in [`upgrades.js`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/upgrades.js#L22-L29), after the existing `renameActionIds` entry. Never put them before it.

### M2: No release workflow, so GitHub releases do not get the built package attached

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW — template check on this release (the file was already missing at v3.1.1)
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** When the maintainer publishes a GitHub release, no package is built or attached to it, so users who download modules from GitHub releases find no `.tgz` to import.

**Why it happens:** The template ships `.github/workflows/release.yaml`, which packages the module with Bitfocus's shared module-checks workflow on every published release and uploads the result as a release asset. This module doesn't have it.

**Fix:** copy `.github/workflows/release.yaml` from `companion-module-template-js` @ `89da037` unchanged.

## 🟢 Low

### L1: The connection crash-loops when its saved settings have no Target Port

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`index.js:117`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/index.js#L117)

**What goes wrong:** A connection whose saved settings have no port value at all (for example one carried over from an older config that never stored it) crashes the module process right after it starts. Companion restarts the process, it crashes again, and the connection never settles. The user sees a crash loop instead of a clear "Bad configuration" status. On v3.1.1 the same settings gave an ordinary connection error. A reviewer harness reproduced the crash with `init({ host: '127.0.0.1' })`.

**Why it happens:** This release changed the TCP helper's port argument to `Number(this.config.port)`. A missing port becomes `NaN`, and Node's socket `connect()` throws `ERR_SOCKET_BAD_PORT` for `NaN` straight away. The helper calls `connect()` inside `setImmediate` with no `try`/`catch`, so the module can't catch the error. Before the change, a missing port failed later through the helper's normal `error` event. The module checks that `host` is set but never checks `port`.

**Fix:** check the port before building the connection, and show a "Bad configuration" status when it is invalid. The same check covers the "Update Target Port" action, which turns an empty "New Port" field into `NaN` through `parseInt`.

```js
const port = Number(this.config.port)
if (!Number.isInteger(port) || port < 1 || port > 65535) {
	this.updateStatus(InstanceStatus.BadConfig, 'Invalid port')
	this.setVariableValues({ connection_status: 'bad_config' })
	return
}
this.socket = new TCPHelper(this.config.host, port, { reconnect: false })
```

### L2: Xenon and Tachyon do not show up as separate products in the connection list

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:30`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/companion/manifest.json#L30)

**What goes wrong:** When users add a connection in Companion and browse or search the module list, VYV shows one product called "Photon, Xenon, Tachyon" instead of three products. Anyone looking for "VYV: Xenon" or "VYV: Tachyon" as its own entry won't find one. The module still installs and works.

**Why it happens:** Commit `8c611d5` in this release changed `products` from `["Photon"]` to an array holding one comma-separated string. The manifest schema defines `products` as a list with one product name per entry, so the schema check still passes.

**Fix:** make each product its own entry.

```json
"products": ["Photon", "Xenon", "Tachyon"],
```

## 💡 Nice to Have

### N1: The Presets panel shows the Default Cues heading twice

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`presets.js:35-48`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/presets.js#L35-L48)

**What goes wrong:** In the Presets panel of a VYV Photon connection, the "Default Cues" section holds a single group that is also named "Default Cues", so users see the same heading twice above the cue buttons (Play, Pause, …). This is cosmetic only: every preset is listed and works.

**Why it happens:** The new v2 preset structure added in this release wraps all preset ids in one group with the same name as its section. In base 2.2.2 a section can also take a plain list of preset ids, which the typings describe as "shown without grouping".

**Fix:** give the section the preset ids directly with `definitions: presetIds`, or split the presets into groups whose names differ from the section's (for example "Playback", "Crossfade", "Master", "Regions").

### N2: The Special Code choice can be switched to an expression that needs the raw device codes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:40-58`](https://github.com/bitfocus/companion-module-vyv-photon/blob/c18f22aacdb19faecc120dfb20361a6d21088d4b/actions.js#L40-L58)

**What goes wrong:** Since the move to API v2, users can switch the "Special Code" dropdown of the "Special Code" action to expression mode. There they have to type Photon's raw codes ('4' = Restart Photon, '5' = Reboot Server, '6' = Quit Photon, '7' = Shutdown Server, '10' = Toggle UI Visibility), and nothing in the UI says which code does what. Users who keep the dropdown in its normal mode see no difference.

**Why it happens:** In API v2, every option that isn't a text input gets an expression toggle automatically unless it sets `disableAutoExpression: true`. The action itself wasn't edited, but the base upgrade in this release gives it the toggle.

**Fix:** add `disableAutoExpression: true` to the `s_code` dropdown so it stays a plain choice. If you'd rather keep expression support, add an `expressionDescription` that lists the codes.

## 📝 Additional Notes

- API compliance was re-checked on 2026-11-06 against the API 2.2 rules (companion-v2-api-compliance 1.2.0): no new findings. The module has no feedbacks (so no value-feedback `result`), no preset `storeResult` or `hasResult` action, no unknown `Regex` key and no UDP or shared socket (TCP only), and its four variable ids (`connection_status`, `target_port`, `target_ip`, `connection_failures`) are static and valid. api-scan scanned 0 files because the code sits at the repository root, so `actions.js`, `cues.js`, `index.js`, `presets.js` and `upgrades.js` were checked by hand. The only 2.2 issue is the deprecated `Regex.IP` / `Regex.PORT` usage, already reported as [M1](#m1-every-start-of-the-module-logs-two-deprecation-warnings-that-look-like-faults) at its correct Medium severity. Base 2.2.x needs Companion 5.1+ (Companion 5.0.x refuses to load it), so the API line above now says 5.1+.
