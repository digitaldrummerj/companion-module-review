# Review: companion-module-dreamchip-visca v1.0.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-dreamchip-visca` ([repository](https://github.com/bitfocus/companion-module-dreamchip-visca)) |
| **Scope** | `tag` |
| **Version** | v1.0.1 (`c9bb6d0`) |
| **Release** | New module — never published |
| **API** | 1 (base 1.11.3, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Reviewed** | 2026-11-16 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: @companion-module/base 1.11 doesn't meet the ^1.12.0 that @companion-module/tools 2.9 requires](#c1-companion-modulebase-111-doesnt-meet-the-1120-that-companion-moduletools-29-requires)
- [ ] [H1: Serial (COM) connections never work in the installed module because the serialport native binding is not packaged](#h1-serial-com-connections-never-work-in-the-installed-module-because-the-serialport-native-binding-is-not-packaged)
- [ ] [H2: Switching Connection from a failing Serial port to TCP: the old serial retry keeps killing the new TCP connection](#h2-switching-connection-from-a-failing-serial-port-to-tcp-the-old-serial-retry-keeps-killing-the-new-tcp-connection)
- [ ] [H3: With polling off (the default), the first knob turn sets the camera to a near-minimum value](#h3-with-polling-off-the-default-the-first-knob-turn-sets-the-camera-to-a-near-minimum-value)
- [ ] [H4: Actions, feedbacks, variables and upgrade scripts are not in the template's separate files](#h4-actions-feedbacks-variables-and-upgrade-scripts-are-not-in-the-templates-separate-files)
- [ ] [H5: The package.json engines field is missing the template's yarn entry](#h5-the-packagejson-engines-field-is-missing-the-templates-yarn-entry)
- [ ] [H6: The yarn format script only formats src/, unlike the template](#h6-the-yarn-format-script-only-formats-src-unlike-the-template)
- [ ] [H7: The manifest lacks the template's $schema line](#h7-the-manifest-lacks-the-templates-schema-line)
- [ ] [H8: HELP and README point to Knobs preset categories and a Picture action group that don't exist](#h8-help-and-readme-point-to-knobs-preset-categories-and-a-picture-action-group-that-dont-exist)

### Non-blocking

- [ ] [M1: Buttons pressed while the camera is offline are queued and fire later when it reconnects](#m1-buttons-pressed-while-the-camera-is-offline-are-queued-and-fire-later-when-it-reconnects)
- [ ] [M2: With polling off, AE, WB, Audio, SDI and Timecode toggle buttons start in the wrong state and the first press can do nothing](#m2-with-polling-off-ae-wb-audio-sdi-and-timecode-toggle-buttons-start-in-the-wrong-state-and-the-first-press-can-do-nothing)
- [ ] [M3: Pressing a knob preset changes the camera value, but HELP says it only re-syncs](#m3-pressing-a-knob-preset-changes-the-camera-value-but-help-says-it-only-re-syncs)
- [ ] [M4: Changing Knob step in the connection settings has no effect on existing knob buttons](#m4-changing-knob-step-in-the-connection-settings-has-no-effect-on-existing-knob-buttons)
- [ ] [M5: After a direct action sets a negative value, the next knob turn jumps that control to its maximum](#m5-after-a-direct-action-sets-a-negative-value-the-next-knob-turn-jumps-that-control-to-its-maximum)
- [ ] [M6: The manifest's version is maintained by hand and has already drifted from package.json](#m6-the-manifests-version-is-maintained-by-hand-and-has-already-drifted-from-packagejson)
- [ ] [L1: A poll safety timer keeps running for up to about 88 s after the connection is disabled](#l1-a-poll-safety-timer-keeps-running-for-up-to-about-88-s-after-the-connection-is-disabled)
- [ ] [L2: Serial ports are re-scanned every 5 seconds, even on TCP connections](#l2-serial-ports-are-re-scanned-every-5-seconds-even-on-tcp-connections)
- [ ] [L3: AE and WB toggle buttons show AUTO for any non-Manual mode, and the AE toggle stores Auto instead of FullAuto](#l3-ae-and-wb-toggle-buttons-show-auto-for-any-non-manual-mode-and-the-ae-toggle-stores-auto-instead-of-fullauto)
- [ ] [L4: The receive buffer grows without limit when the peer never sends a VISCA terminator](#l4-the-receive-buffer-grows-without-limit-when-the-peer-never-sends-a-visca-terminator)
- [ ] [L5: Four pairs of actions share the same name in the action picker](#l5-four-pairs-of-actions-share-the-same-name-in-the-action-picker)
- [ ] [N1: Searching for the camera name (Atom) in Add connection doesn't find the module](#n1-searching-for-the-camera-name-atom-in-add-connection-doesnt-find-the-module)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: @companion-module/base 1.11 doesn't meet the ^1.12.0 that @companion-module/tools 2.9 requires

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:14`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L14), [`package.json:18`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L18)

**What goes wrong:** The module's two Companion packages don't fit together. It depends on `@companion-module/base` `~1.11.0` (1.11.3 installed), but builds with `@companion-module/tools` `^2.8.0` (2.9.0 installed). Those tools supply `companion-module-build` (`yarn package`) and the shared prettier config, and they support only base `^1.12.0 || ^2.0.0`. Every `yarn install` warns about it (YN0060). `yarn package` still produces a package today, but the package Companion installs is built by tooling that doesn't support the base version it bundles. The API 1.x template has moved to base `~1.14.1`.

**Why it happens:** `package.json` keeps `@companion-module/base` on the 1.11 line while `@companion-module/tools` was raised to 2.8 or later. Tools 2.x lists `@companion-module/base` as a peer dependency with the range `^1.12.0 || ^2.0.0`. A peer dependency is a package the tools expect the module itself to provide, and 1.11.3 is outside that range. Moving to base 1.12 or later brings two changes the module has to make at the same time. First, Companion's Node permission model applies from 1.12, so the manifest must declare `"permissions": { "native-addons": true }` inside `runtime` or the serialport binding is blocked. Second, `isVisible` functions are deprecated from 1.12 in favour of `isVisibleExpression`. Five config fields use them: [`src/main.js:1430`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1430), [`1440`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1440), [`1461`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1461), [`1469`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1469) and [`1481`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1481).

**Evidence:**

```json
// package.json:13-19
  "dependencies": {
    "@companion-module/base": "~1.11.0",
    "serialport": "^12.0.0"
  },
  "devDependencies": {
    "@companion-module/tools": "^2.8.0",
// node_modules/@companion-module/tools/package.json (2.9.0): peerDependencies
"@companion-module/base": "^1.12.0 || ^2.0.0"
// companion-module-template-js-v1/package.json:18-20 (pin 9e222b4)
	"dependencies": {
		"@companion-module/base": "~1.14.1"
	},
```

```text
// yarn install --immutable --mode=skip-build in the v1.0.1 clone
➤ YN0060: │ @companion-module/base is listed by your project with version 1.11.3 (p9413a1), which doesn't satisfy what @companion-module/tools requests (^1.12.0 || ^2.0.0).
```

**Confirm by:** run `yarn install` in the clone and look for the YN0060 line, or compare [`package.json:14`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L14) (`~1.11.0`) with `peerDependencies` in `node_modules/@companion-module/tools/package.json`.

**Fix:** upgrade `@companion-module/base` to `~1.14.1`, as in the API 1.x template, and make the changes that version needs.

1. Run `yarn add @companion-module/base@~1.14.1`.
2. Add `"permissions": { "native-addons": true }` inside the `runtime` object of `companion/manifest.json` (not at the top level), so Companion allows the serialport binding to load. [H1](#h1-serial-com-connections-never-work-in-the-installed-module-because-the-serialport-native-binding-is-not-packaged) covers packaging the binding itself.
3. Replace each `isVisible: (c) => …` with `isVisibleExpression`, e.g. `isVisibleExpression: "$(options:conn) == 'serial'"`.
4. Run `yarn install` again and check that the YN0060 warning is gone. Then run `yarn package` and test both TCP and Serial (COM) in Companion.

## 🟠 High

### H1: Serial (COM) connections never work in the installed module because the serialport native binding is not packaged

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:447-455`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L447-L455), [`package.json:13-16`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L13-L16)

**What goes wrong:** A user installs the module, sets **Connection** to **Serial (COM)** and picks a port such as `/dev/ttyUSB0` or `COM3`. The connection goes straight to **Connection failure: serialport not available**, and the log shows `serialport import failed: No native build was found for platform=…`. The **Serial port** dropdown never lists any adapters either, only "(no adapters found -- enter port manually)", because the port scan fails silently for the same reason. HELP.md and the config advertise serial control, but only TCP works in the package Companion installs. Running the module from source (with `node_modules`) works, which is probably why this went unnoticed. TCP users are not affected.

**Why it happens:** The `serialport` package needs a compiled native add-on (`@serialport/bindings-cpp`), a `.node` file that it looks for at runtime in the folder above the bundled code. When Companion installs a module it runs the packaged `.tgz` built by `companion-module-build`, not the repo's `node_modules`. That build bundles the JavaScript but copies native binaries only when a `build-config.cjs` asks for them, and this repo has none. So the built `dreamchip-visca-1.0.1.tgz` holds no `prebuilds/` folder and no `.node` file, the native lookup throws, and the module's `import('serialport')` fails. Running the bundle's own lookup against the extracted package reproduced the error; the same lookup against the dev `node_modules` finds the binding.

**Evidence:**

```js
// src/main.js:447-455
		// Loaded lazily so a missing/broken native binding never breaks TCP users.
		let SerialPort
		try {
			;({ SerialPort } = await import('serialport'))
		} catch (err) {
			this.updateStatus(InstanceStatus.ConnectionFailure, 'serialport not available')
			this.log('error', `serialport import failed: ${err.message}`)
			return
		}
// src/main.js:285-296 (Serial port dropdown source; the same import failure is swallowed)
	async refreshSerialPorts() {
		try {
			const { SerialPort } = await import('serialport')
			const ports = await SerialPort.list()
			...
		} catch (_) {
			// serialport not installed/available, or listing failed (e.g. permissions)
```

```json
// package.json:13-16
  "dependencies": {
    "@companion-module/base": "~1.11.0",
    "serialport": "^12.0.0"
  },
```

```js
// node_modules/@companion-module/tools/scripts/lib/build-util.js (tools 2.9.0): native binaries are copied only from build-config.cjs
	const webpackExtPath = path.resolve('build-config.cjs')
	if (fs.existsSync(webpackExtPath)) {
		...
		if (webpackExt.prebuilds) {
	...
	if (webpackConfigJson.node?.__dirname === true) {   // set only by build-config.cjs useOriginalStructureDirname
// pkg/987.main.js (built bundle: bindings-cpp load-bindings, runtime __dirname)
const n=s(r(8169)),i=r(9023),o=r(6928),a=(0,n.default)((0,o.join)(__dirname,"../"));
```

```text
// git ls-files (v1.0.1): no build-config.cjs
.gitattributes .github/... .gitignore .prettierignore .yarnrc.yml CHANGELOG.md LICENSE README.md companion/HELP.md companion/manifest.json package.json src/commands.js src/entry.js src/images.js src/main.js yarn.lock

// tar tzf dreamchip-visca-1.0.1.tgz
pkg/ pkg/987.main.js pkg/LICENSE pkg/companion/ pkg/main.js pkg/package.json pkg/companion/HELP.md pkg/companion/manifest.json
// pkg/package.json
{"name":"dreamchip-visca","version":"1.0.1","license":"MIT","type":"commonjs","dependencies":{}}

// node-gyp-build path() against the extracted tgz vs. dev node_modules
FAIL .../extract/pkg/../ -> No native build was found for platform=darwin arch=arm64 runtime=node abi=127 uv=1 armv=8 libc=glibc node=22.21.1
FOUND .../node_modules/@serialport/bindings-cpp/dist/../ -> .../node_modules/@serialport/bindings-cpp/prebuilds/darwin-x64+arm64/node.napi.node
```

**Confirm by:** in the clone, run `git ls-files | grep build-config` (no output) and `tar tzf dreamchip-visca-1.0.1.tgz` (no `prebuilds/` folder, no `*.node` file). `node_modules/@companion-module/tools/scripts/lib/build-util.js` ships native binaries only when `build-config.cjs` sets `externals`, `prebuilds` or `useOriginalStructureDirname`. The import itself is at [`src/main.js:447-455`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L447-L455).

**Fix:** have `companion-module-build` install `serialport` into the package instead of bundling it, so its native binaries ship with it. Add a `build-config.cjs` at the repo root that declares `serialport` as an external. The build then adds `serialport` to the package's `package.json` and installs it into the package's `node_modules`, together with `@serialport/bindings-cpp` and its prebuilt `.node` files.

```js
// build-config.cjs
module.exports = {
	externals: {
		serialport: 'commonjs serialport',
	},
}
```

Once the module is on API 1.12 or later ([C1](#c1-companion-modulebase-111-doesnt-meet-the-1120-that-companion-moduletools-29-requires)), it must also declare the `native-addons` permission inside `runtime` in `companion/manifest.json`. Without it, Companion blocks the binding with `ERR_DLOPEN_DISABLED`.

```json
// companion/manifest.json
	"runtime": {
		...
		"permissions": { "native-addons": true }
	},
```

Don't use `useOriginalStructureDirname: true` for this. It makes the bundle look in `node_modules/@serialport/bindings-cpp/` inside the package, but tools 2.9.0 never copies the binaries there: its prebuild copy doesn't look inside scoped folders such as `@serialport`. A test build with that option still had no `.node` file. A test build with the `externals` config and the permission above loaded the binding under Companion's Node permission flags. `SerialPort.list()` returned the machine's ports, and opening a missing port failed with the operating system's error instead of "No native build was found".

Then run `yarn package`, extract the `.tgz` and check that `pkg/node_modules/@serialport/bindings-cpp/prebuilds/` holds the `.node` files (linux-x64, linux-arm64, darwin, win32-x64). Finally, import the `.tgz` into Companion and confirm that Serial (COM) lists ports and connects before releasing.

### H2: Switching Connection from a failing Serial port to TCP: the old serial retry keeps killing the new TCP connection

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:509-536`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L509-L536)

**What goes wrong:** A user first sets **Connection** to **Serial (COM)**, but the port can't be opened (wrong port, adapter unplugged), so the module retries every 2 seconds. They switch **Connection** to TCP, enter Target IP `192.168.1.50`, port `4000`, and save. Within 2 seconds the TCP connection is torn down and the status goes back to a serial error such as **Connection failure: Error: No such file or directory, cannot open /dev/ttyUSB0**, repeating every 2 seconds. Buttons do nothing. Saving the config again doesn't help; only disabling and re-enabling the connection recovers. In the current package this is hidden by [H1](#h1-serial-com-connections-never-work-in-the-installed-module-because-the-serialport-native-binding-is-not-packaged) (serial gives up before any retry is scheduled), but it happens when running from source and will appear as soon as H1 is fixed.

**Why it happens:** After a failed open or a dropped port, the module starts a 2-second "retry serial" timer. Setting up a serial connection clears that timer, but setting up a TCP connection does not, and only `destroy()` clears it otherwise. So after the switch the timer still fires. Its callback reconnects serial without checking that Connection is still Serial: it destroys the current connection (now the TCP one), reopens the old serial port, fails again and schedules the next retry. Both reviewers reproduced this offline with the module's own code: 2.5 s after switching to TCP, the active connection was the serial adapter again and the retry timer was still pending.

**Evidence:**

```js
// src/main.js:386-395
	async initTransport() {
		this.consecutiveTimeouts = 0
		this.linkWarning = false
		this.confirmedReply = false // a fresh transport must earn Ok again on the first real reply
		if (this.config?.conn === 'serial') {
			await this.initSerial()
		} else {
			this.initTCP()
		}
	}
// src/main.js:428-441
	async initSerial() {
		if (this.serialReconnectTimer) {
			clearTimeout(this.serialReconnectTimer)
			this.serialReconnectTimer = undefined
		}
		if (this.socket) {
			...
			this.socket.destroy()
			this.socket = undefined
		}
		const path = this.config?.serialPort
// src/main.js:509-536
		port.open((err) => {
			if (err) {
				this.log('error', `serial open: ${err.message}`)
				this.updateStatus(InstanceStatus.ConnectionFailure, err.message)
				// e.g. USB adapter unplugged -- retry on its own instead of
				// sitting dead until a config change or instance toggle.
				this.scheduleSerialReconnect()
			}
		})
	}
	...
	scheduleSerialReconnect() {
		if (this.serialReconnectTimer || !this.config) return
		this.serialReconnectTimer = setTimeout(() => {
			this.serialReconnectTimer = undefined
			this.updateStatus(InstanceStatus.Connecting)
			this.initSerial()
		}, 2000)
	}

	initTCP() {
		if (this.socket) {
			this.socket.destroy()
			this.socket = undefined
		}
// src/main.js:1529-1536
		const transportChanged =
			!prev ||
			prev.conn !== config.conn ||
			...
		if (transportChanged) await this.initTransport()
// src/main.js:1540-1546 (only destroy() clears the timer)
	async destroy() {
		...
		if (this.serialReconnectTimer) clearTimeout(this.serialReconnectTimer)
```

```text
// offline harness (stub TCPHelper + serialport whose open() always fails; no network)
after serial init: timer pending = true socket type = Object
right after switch to tcp: timer pending = true socket is TCPHelper = TCPHelper
2.5s later: tcp destroyed = true socket is TCPHelper = false timer pending = true serial opens = 2
last statuses: [..., 'connection_failure', 'Error: No such file or directory, cannot open /dev/ttyUSB0']
4.6s later: serial opens = 3 timer pending = true
```

**Confirm by:** open [`src/main.js:523-536`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L523-L536). `initTCP()` has no `clearTimeout(this.serialReconnectTimer)` (compare [`src/main.js:429-432`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L429-L432)), and the timer callback calls `initSerial()` without checking `this.config.conn`.

**Fix:** clear the serial retry timer whenever the connection is rebuilt, and make the timer callback do nothing unless Connection is still Serial.

```js
async initTransport() {
	if (this.serialReconnectTimer) {
		clearTimeout(this.serialReconnectTimer)
		this.serialReconnectTimer = undefined
	}
	// ...
}

// in scheduleSerialReconnect()'s callback, before initSerial():
if (this.destroyed || this.config?.conn !== 'serial') return
```

### H3: With polling off (the default), the first knob turn sets the camera to a near-minimum value

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:696-700`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L696-L700), [`src/main.js:719-747`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L719-L747)

**What goes wrong:** A user keeps the default **Poll ms** = `0`, drags the **Red Gain (knob)** preset onto a Stream Deck+ encoder and turns it one click right to nudge red up. The camera's Red Gain is set to raw `4`, about 0.02x (unity is 256), and the picture turns cyan. The first turn of other knobs does the same: **Color Temp** jumps to 2200 K (from e.g. 5600 K), **Contrast** to 4 (from 128), **Shutter** to its fastest value, and Gain, Blue/Green Gain, Color Gain and Bright behave alike. The **Knob: Adjust value (relative)** action does the same. Before the turn the encoder display shows `--`, so nothing warns the user, and HELP.md says the knobs work "also with polling off".

**Why it happens:** A knob turn sends an absolute value: the current value plus the step. On connect the module reads only the "startup" values (inquiries marked `once`); the live values (gain, shutter, red/blue/green gain, colour temperature, colour gain and hue, bright, contrast) are read only by the background poll, which runs only when **Poll ms** is above 0. With polling off, the module doesn't know the current value, falls back to 0, and sends 0 + step, clamped to the minimum. Reproduced by calling the module's own `adjustParam()`: the first turn right sent `81 01 04 43 00 00 00 04 FF` (Red Gain 4) and `81 01 7E 01 0B 00 08 09 08 FF` (2200 K).

**Evidence:**

```js
// src/main.js:696-700
	readValue(varId) {
		if (this.knob[varId] !== undefined) return this.knob[varId]
		const n = parseInt(this.state[varId], 10)
		return Number.isFinite(n) ? n : 0
	}
// src/main.js:719-747 (excerpt)
	adjustParam(paramId, delta) {
		const p = this.paramById?.[paramId]
		if (!p || !Number.isFinite(delta)) return
		const cur = this.readValue(p.varId)
		...
		} else {
			raw = cur + delta
		}
		const next = Math.max(p.min, Math.min(effectiveMax(p, this.cameraModel), raw))
		const c = COMMANDS[p.cmd]
		this.send([...c.prefix, ...encodeNibbles(next, c.nibbles)])
		this.setKnobValue(p.varId, next)
	}
// src/main.js:1279-1283
	startPolling() {
		this.stopPolling()
		const ms = Number(this.config?.pollInterval)
		if (ms > 0) this.pollTimer = setInterval(() => this.pollLiveOnce(), ms)
	}
// src/main.js:1361-1364
	pollStartupOnce() {
		const gatedIds = MODEL_GATED_IDS[this.cameraModel] ?? []
		this.pollBatch(Object.values(INQUIRIES).filter((q) => q.once && !gatedIds.includes(q.varId)))
	}
// src/main.js:564-567 (TCP connect; the serial 'open' handler at 479-495 does the same)
		this.socket.on('connect', () => {
			this.pump()
			this.pollStartupOnce()
		})
// src/main.js:1486-1489
				id: 'pollInterval',
				label: 'Poll ms (0=off, min 2000)',
				width: 2,
				default: 0,
// src/commands.js:1017-1020 (live-tier inquiries: no `once`)
	gain: { name: 'Gain', varId: 'gain', payload: P(0x09, 0x04, 0x4c), decode: { type: 'value' } },
	shutter: { name: 'Shutter', varId: 'shutter', payload: P(0x09, 0x04, 0x4a), decode: { type: 'value' } },
	wb_mode: { name: 'WB Mode', varId: 'wb_mode', payload: P(0x09, 0x04, 0x35), decode: { type: 'enum', map: ENUM.wb } },
	rgain: { name: 'R Gain', varId: 'rgain', payload: P(0x09, 0x04, 0x43), decode: { type: 'value' } },
```

```text
// companion/HELP.md:41
- **Turn** right/left: raises/lowers the value by the Knob step and sends it immediately, so it also works with polling off.

// harness: adjustParam() on an instance with empty state/knob, pollInterval 0
cam_rgain_direct -> 01 04 43 00 00 00 00 04 knob= 4
dct_wb_temp -> 01 7e 01 0b 00 08 09 08 knob= 2200
cam_contrast_direct -> 01 04 a2 00 00 00 04 knob= 4
cam_shutter_direct -> 01 04 4a 00 00 00 00 0b knob= 11
cam_gain_direct -> 01 04 4c 00 00 00 00 04 knob= 4
```

**Confirm by:** open [`src/main.js:696-700`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L696-L700) and [`src/main.js:719-747`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L719-L747). With **Poll ms** at 0, the connect handlers ([`src/main.js:494`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L494), [`src/main.js:566`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L566)) call only `pollStartupOnce()`, which reads only `once` inquiries, so the first turn counts from 0.

**Fix:** read the live values on every (re)connect as well, and never send a knob value computed from an unknown starting point. For example, call `pollOnce()` (or chain `pollLiveOnce()` after `pollStartupOnce()`, adjusting the `pollBusy` gate) in the `connect`/`open` handlers. In `adjustParam()`, when neither `this.knob[varId]` nor `this.state[varId]` is known, don't send: fire `inquireOnce(<inquiry>, { resyncKnob: true })` and apply the step once the value arrives, or ignore the turn.

### H4: Actions, feedbacks, variables and upgrade scripts are not in the template's separate files

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:751-1276`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L751-L1276), [`src/entry.js:4`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/entry.js#L4)

**What goes wrong:** Users see no difference. The template keeps `src/actions.js`, `src/feedbacks.js`, `src/variables.js` and `src/upgrades.js` as separate files. This module puts every action, preset, variable and feedback definition into one 1,548-line `src/main.js`, and passes the upgrade scripts inline as `[]` in `src/entry.js`. That makes the module harder to review and maintain, and there is no `upgrades.js` ready for the first breaking change.

**Why it happens:** `setupActions()`, `setupPresets()`, `setupVariables()` and `setupFeedbacks()` are methods on the instance class, and the upgrade-script list is a literal in the entry file.

**Evidence:**

```text
// git ls-files src/ (v1.0.1)
src/commands.js
src/entry.js
src/images.js
src/main.js

// companion-module-template-js-v1/src/
actions.js  feedbacks.js  main.js  upgrades.js  variables.js
```

```js
// src/entry.js:1-4
import { runEntrypoint } from '@companion-module/base'
import { DctViscaInstance } from './main.js'

runEntrypoint(DctViscaInstance, [])
// src/main.js:268-271
		this.setupActions()
		this.setupFeedbacks()
		this.setupVariables()
		this.setupPresets()
// src/main.js:751-753
	setupActions() {
		const actions = {}
		const gatedIds = MODEL_GATED_IDS[this.cameraModel] ?? []
// src/main.js:1111-1112
	setupVariables() {
		this.setVariableDefinitions(Object.values(INQUIRIES).map((q) => ({ variableId: q.varId, name: q.name })))
// src/main.js:1115
	setupFeedbacks() {
// companion-module-template-js-v1/src/main.js:1-5
const { InstanceBase, Regex, runEntrypoint, InstanceStatus } = require('@companion-module/base')
const UpgradeScripts = require('./upgrades')
const UpdateActions = require('./actions')
const UpdateFeedbacks = require('./feedbacks')
const UpdateVariableDefinitions = require('./variables')
```

**Confirm by:** run `git ls-files src/` in the clone (only `commands.js`, `entry.js`, `images.js`, `main.js`) and compare it with `ls companion-module-template-js-v1/src/` (`actions.js`, `feedbacks.js`, `main.js`, `upgrades.js`, `variables.js`). Then open [`src/entry.js:4`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/entry.js#L4) to see the inline `[]` upgrade scripts.

**Fix:** split the definitions into the template's files and call them from `main.js` the way the template does. Move `setupActions` into `src/actions.js`, `setupFeedbacks` into `src/feedbacks.js` and `setupVariables` into `src/variables.js`, each as `module.exports = function (self) { ... }` (a separate `src/presets.js` is optional but helps). Add `src/upgrades.js` exporting `[]` and pass it to `runEntrypoint`.

### H5: The package.json engines field is missing the template's yarn entry

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:22-24`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L22-L24)

**What goes wrong:** Users see no difference. The template declares `"yarn": "^4"` in `engines` next to `node`; this module declares only `node`, so the package doesn't state which Yarn major it needs, and it differs from its template.

**Why it happens:** The `engines` block was written without the template's `yarn` key. The `packageManager` field (`yarn@4.18.1`) does not replace it.

**Evidence:**

```json
// package.json:12, 22-24
  "packageManager": "yarn@4.18.1",
  ...
  "engines": {
    "node": "^22"
  },
// companion-module-template-js-v1/package.json:14-17
	"engines": {
		"node": "^22.20",
		"yarn": "^4"
	},
```

**Confirm by:** open [`package.json:22-24`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L22-L24): `engines` has only `node`, while `companion-module-template-js-v1/package.json:16` has `"yarn": "^4"`.

**Fix:** add `"yarn": "^4"` to `engines`, as in the template.

### H6: The yarn format script only formats src/, unlike the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-10`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L7-L10)

**What goes wrong:** Users see no difference. The template's `format` script is `prettier -w .`, which formats the whole repository (HELP.md, README, manifest, workflows). This module's `yarn format` runs `prettier --write src` and leaves everything outside `src/` unformatted, so it differs from the template.

**Why it happens:** The `format` script was narrowed to the `src` folder.

**Evidence:**

```json
// package.json:7-10
  "scripts": {
    "format": "prettier --write src",
    "package": "companion-module-build"
  },
// companion-module-template-js-v1/package.json:5-8
	"scripts": {
		"format": "prettier -w .",
		"package": "companion-module-build"
	},
```

**Confirm by:** open [`package.json:8`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/package.json#L8) (`prettier --write src`) and compare it with `companion-module-template-js-v1/package.json:6` (`prettier -w .`).

**Fix:** change the script to `"format": "prettier -w ."`, as in the template.

### H7: The manifest lacks the template's $schema line

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:1-3`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/companion/manifest.json#L1-L3)

**What goes wrong:** Users see no difference. The template's manifest starts with a `$schema` key that lets editors validate the manifest while it is edited; this manifest has none.

**Why it happens:** The manifest was written without the template's first key.

**Fix:** add `"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json"` as the first key, as in `companion-module-template-js-v1/companion/manifest.json`.

### H8: HELP and README point to Knobs preset categories and a Picture action group that don't exist

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:32-33`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/companion/HELP.md#L32-L33), [`companion/HELP.md:39`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/companion/HELP.md#L39)

**What goes wrong:** Users looking in the presets panel for a `Knobs: Exposure` or `Knobs: …` category, as HELP.md and README.md ([`README.md:50`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/README.md#L50), [`README.md:62`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/README.md#L62)) describe, won't find one: the knob presets sit in the ordinary parameter categories (Exposure, White Balance, System, Audio), named e.g. "Gain (knob)". HELP.md also lists a "Picture" action group, but Gamma, Bright, Contrast and Flip are under **System**.

**Why it happens:** The knob presets use the parameter's own group as their category ([`src/main.js:1053`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1053)), and the picture commands have `group: 'System'` in `src/commands.js`.

**Fix:** either use `` category: `Knobs: ${p.group}` `` for the knob presets, or update HELP.md and README.md to say they appear in each parameter's own category with a "(knob)" suffix. Remove "Picture" from the action group list, or give those commands a `Picture` group.

## 🟡 Medium

### M1: Buttons pressed while the camera is offline are queued and fire later when it reconnects

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:596-606`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L596-L606)

**What goes wrong:** While the camera is off or unreachable (status Connecting or Disconnected), an operator presses **Gain: up** five times, or the **All Reset** / **Load Settings** preset. Nothing happens at the time. When the camera comes back, possibly hours later, every queued command is sent in order: gain jumps up five steps, or the camera's settings are reset without anyone touching a button. After a Target IP change, commands queued for the old camera are sent to the new one.

**Why it happens:** Every command goes into a send queue, and the queue simply waits while there is no connection. The TCP `connect` and serial `open` handlers then drain the backlog, and nothing clears the queue when the connection drops or is rebuilt.

**Fix:** drop commands that can't be sent. In `enqueue()`, if `!this.socket?.isConnected`, log at debug level and return without queuing; or clear `this.queue` (and `this.inflight`) in `initTransport()` and when the TCP `status_change` or serial `close` handler sees the link go down.

### M2: With polling off, AE, WB, Audio, SDI and Timecode toggle buttons start in the wrong state and the first press can do nothing

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:1361-1364`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1361-L1364), [`src/main.js:979-1001`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L979-L1001)

**What goes wrong:** With **Poll ms** = `0`, a user adds the **AE: Toggle Auto/Manual** preset while the camera is in Manual. The button shows "AE AUTO" in green. Pressing it sends Manual again, so nothing changes on the camera; only a second press switches to Auto. The same applies to **Audio: Toggle On/Off** (shows OFF while audio is on; the first press sends On), **SDI: Toggle Legal/Full**, **Timecode: Toggle Run/Hold** and **WB: Toggle Auto/Manual**. The **AE mode is …** / **WB mode is …** feedbacks and variables such as `$(label:ae_mode)` stay empty until the user presses **System: Poll inquiries now**.

**Why it happens:** This has the same root cause as [H3](#h3-with-polling-off-the-default-the-first-knob-turn-sets-the-camera-to-a-near-minimum-value). AE mode, WB mode, SDI range, timecode hold and audio enable are live values, which are read only by the background poll, and on connect the module reads only the startup values. The toggles pick their direction from the stored state (for example "go Manual unless the state is already Manual"), and the display feedbacks treat an unknown state as AUTO / OFF / LEGAL / HOLD.

**Fix:** read the live values once on every (re)connect, for example by calling `pollOnce()` from the `connect` / `open` handlers. Optionally, have the toggles fire an inquiry first, or show `--`, while the state is still unknown.

### M3: Pressing a knob preset changes the camera value, but HELP says it only re-syncs

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:42`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/companion/HELP.md#L42), [`README.md:67`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/README.md#L67)

**What goes wrong:** HELP.md and README.md tell users that pressing a Stream Deck+ knob "re-reads the camera to re-sync the knob". For 12 of the knob presets, pressing changes the camera instead. **Gain**, **Shutter**, **Red/Blue/Green Gain** and **Bright** send the camera's Reset; **Color Hue** is set to 0, **Color Gain** and **Contrast** to 128, **Color Temp** to 6500 K, **Audio Gain** to 256 (0 dB) and **LUT Fast Gamma** to 138 (gamma 2.204). An operator who presses the Gain knob during a show to re-sync it resets the camera's gain on air. Only the remaining knobs do the documented re-read.

**Why it happens:** The knob presets' press step uses a Reset action ([`src/main.js:165-171`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L165-L171)) or a fixed-value set ([`src/main.js:179-190`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L179-L190)), and falls back to **Poll inquiries now** only for the others. HELP and README describe only that fallback.

**Fix:** document the real press behaviour per knob in HELP.md and README.md ("Press resets Gain/Shutter/R/G/B Gain/Bright to the camera default, sets Hue to 0°, Color Gain/Contrast to 1.0x, Color Temp to 6500 K, Audio Gain to 0 dB and LUT Fast Gamma to 2.204; other knobs re-read the camera"). Alternatively, make press a re-sync everywhere and offer the resets as separate presets.

### M4: Changing Knob step in the connection settings has no effect on existing knob buttons

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:1048-1067`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1048-L1067), [`src/main.js:1529-1537`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1529-L1537)

**What goes wrong:** A user changes **Knob step (1-255 params)** from `4` to `10` and saves, expecting the Stream Deck+ knobs to move faster, as HELP.md describes ("Step per click for rotary-knob presets"). Knobs already placed keep stepping by 4. Knob presets dragged afterwards also still use 4 until the connection restarts.

**Why it happens:** The step is copied into each knob preset's **Knob: Adjust value (relative)** action options when the presets are built, and that action uses only its own step option. The presets and the action's default step are built only in `init()`; `configUpdated()` rebuilds neither, and the adjust action never reads the connection's Knob step.

**Fix:** have the adjust action use the connection's Knob step at run time, for example with a direction-only option (or a "use connection default" choice) multiplied by `this.knobStep()` in the callback. Also call `setupPresets()` (and `setupActions()` for the default) from `configUpdated()` when `knobStep` changes. If the field is only meant as a default for newly placed presets, say so in HELP.md.

### M5: After a direct action sets a negative value, the next knob turn jumps that control to its maximum

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:798-812`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L798-L812)

**What goes wrong:** A user has a button with **White Balance: Color Hue (direct)**, Value `-20`, and a **Color Hue (knob)** encoder. After pressing the button, the variable `$(label:color_hue)` shows `236` instead of `-20`, and the knob display shows 165.9° with the bar pinned right. The next knob turn in either direction sends Hue `+127`, the maximum, so the colour swings hard. Every signed control behaves the same: Bright, Black Master, Black Red/Green/Blue, S-Log3 Master Gain, SDI Black and SDI White. For example, **SDI Black (direct)** `-10` followed by one knob click left sends SDI Black `+60`. With **Poll ms** at 0 nothing corrects the stored value; with polling on it is corrected only after the 2.5 s knob lock.

**Why it happens:** The camera expects a negative number as its unsigned "wire" form (−20 is sent as 236), so the direct action converts the value before sending. The bytes on the wire are correct, but the action then stores that converted 236 as the control's current value. The knob logic treats the stored value as a signed number in the control's range, so 236 ± step is clamped to the maximum and sent. The knob-press action already does this correctly: it converts only the bytes it sends and stores the signed value.

**Evidence:**

```js
// src/main.js:798-812
			} else if (c.kind === 'direct') {
				const bits = 4 * c.nibbles
				const max = c.modelMax?.[this.cameraModel] ?? c.max ?? (c.signed ? (1 << (bits - 1)) - 1 : (1 << bits) - 1)
				const min = c.min ?? (c.signed ? -(1 << (bits - 1)) : 0)
				const mask = (1 << bits) - 1
				a.options = [{ type: 'number', id: 'value', label: `Value (${min}-${max})`, default: min, min, max }]
				a.callback = (ev) => {
					const value = Number(ev.options.value) & mask
					this.send([...c.prefix, ...encodeNibbles(value, c.nibbles)])
					...
					const varId = this.paramById[id]?.varId
					if (varId) this.setKnobValue(varId, value)
				}
// src/main.js:707-710
	setKnobValue(varId, value) {
		this.knob[varId] = value
		this.state[varId] = String(value)
		this.setVariableValues({ [varId]: String(value) })
// src/main.js:722, 742-747 (adjustParam)
		const cur = this.readValue(p.varId)
		...
			raw = cur + delta
		...
		const next = Math.max(p.min, Math.min(effectiveMax(p, this.cameraModel), raw))
		const c = COMMANDS[p.cmd]
		this.send([...c.prefix, ...encodeNibbles(next, c.nibbles)])
		this.setKnobValue(p.varId, next)
// src/main.js:900-903 (knob-press action: masks only for encoding, stores signed)
				callback: () => {
					const mask = (1 << (4 * cmd.nibbles)) - 1
					this.send([...cmd.prefix, ...encodeNibbles(value & mask, cmd.nibbles)])
					this.setKnobValue(p.varId, value)
// src/commands.js:1365-1375 (continuousParams: signed min/max)
			const wireMin = c.signed ? -(1 << (bits - 1)) : 0
			const wireMax = c.signed ? (1 << (bits - 1)) - 1 : (1 << bits) - 1
			...
				min: c.min ?? wireMin,
				max: c.max ?? wireMax,
```

```text
// sim with the module's own commands.js helpers (node, no network)
cam_color_hue_direct direct sends [ 14, 12 ] stores 236
  knob turn -4 -> next 127 sends [ 7, 15 ]
dct_sdi_black direct sends [ 15, 6 ] stores 246
  knob turn -4 -> next 60 sends [ 3, 12 ]
hue deg of 236: 165.9  of -20: -14.1
```

**Confirm by:** open [`src/main.js:805-811`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L805-L811): `value = Number(ev.options.value) & mask` is passed to `setKnobValue()`. Compare [`src/main.js:900-903`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L900-L903), where the knob-press action masks only the bytes it encodes.

**Fix:** keep the signed value for the module's own state and convert only the bytes that are sent.

```js
a.callback = (ev) => {
	const value = Math.max(min, Math.min(max, Number(ev.options.value)))
	this.send([...c.prefix, ...encodeNibbles(value & mask, c.nibbles)])
	const varId = this.paramById[id]?.varId
	if (varId) this.setKnobValue(varId, value)
}
```

### M6: The manifest's version is maintained by hand and has already drifted from package.json

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:6`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/companion/manifest.json#L6)

**What goes wrong:** `companion/manifest.json` says `"version": "0.8.0"`, while `package.json` says `1.0.1`. The release process already copies the `package.json` version into the manifest, so the hand-written value is never used. Anyone who reads the repository's manifest sees the wrong version, and every release means updating the version in two places, as this one shows.

**Why it happens:** The API 1.x template sets the manifest `version` to `"0.0.0"` on purpose. `companion-module-build` (`yarn package`) overwrites it with the `package.json` version when it builds the package Companion installs, so the version only needs to be maintained in `package.json`. This module put a real version in the manifest and stopped updating it after 0.8.0.

**Fix:** set the manifest version back to the template's placeholder and keep the real version in `package.json` only.

```json
// companion/manifest.json
	"version": "0.0.0",
```

## 🟢 Low

### L1: A poll safety timer keeps running for up to about 88 s after the connection is disabled

- **Source:** 🔎 protocol reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:1299-1323`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1299-L1323), [`src/main.js:1540-1547`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1540-L1547)

**What goes wrong:** There is no visible effect for users. Each poll batch (on connect, **System: Poll inquiries now**, **System: Poll startup values now**, or the **Poll ms** interval) starts a one-shot safety timer of 1.6 s per inquiry, about 88 s for a full 55-inquiry poll. When the connection is disabled or deleted, that timer keeps running after `destroy()`, so `destroy()` doesn't stop everything the module started.

**Why it happens:** The safety timer's handle is a local variable inside `pollBatch()`, cleared only when every reply has arrived. `destroy()` clears the poll interval, the serial scan and retry timers and the in-flight command timer, but has no reference to the batch safety timer.

**Fix:** store the handle on the instance (`this.pollSafetyTimer = setTimeout(finish, ...)`, cleared in `finish()`) and add `clearTimeout(this.pollSafetyTimer)` to `destroy()`. While there, also reset `this.queue = []` and `this.inflight = null` in `destroy()`.

### L2: Serial ports are re-scanned every 5 seconds, even on TCP connections

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:272`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L272)

**What goes wrong:** A TCP-only user on a Raspberry Pi or another Linux machine gets a background `udevadm info -e` process every 5 seconds for each Dream Chip connection, for as long as the connection runs. That full udev database dump uses CPU and does nothing for TCP. Nothing shows in the UI.

**Why it happens:** `init()` starts the 5-second serial port scan regardless of the **Connection** setting, and on Linux the serialport library lists ports by running `udevadm`. The interval is cleared correctly in `destroy()`, so this is a cost, not a leak.

**Fix:** only scan when **Connection** is Serial, and preferably only while the config editor was opened recently (`serialProbeInterestUntil` already tracks that). For example, return early from `scanAndProbeSerialPorts()` when not in serial mode, or start and stop the interval in `configUpdated()`.

### L3: AE and WB toggle buttons show AUTO for any non-Manual mode, and the AE toggle stores Auto instead of FullAuto

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:979-1001`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L979-L1001), [`src/main.js:1233-1260`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L1233-L1260)

**What goes wrong:** If the camera is in Shutter Priority, the **AE: Toggle Auto/Manual** button shows "AE AUTO" in green. If WB is Indoor, Outdoor or ColorTemp (for example after setting Color Temp in Kelvin), **WB: Toggle Auto/Manual** shows "WB AUTO". After pressing the AE toggle to Auto with polling on, `$(label:ae_mode)` reads "Auto" and the **AE mode is FullAuto** feedback stays off until the next poll replaces it with "FullAuto".

**Why it happens:** The two display feedbacks only test "not Manual". The AE toggle writes the literal `'Auto'`, while the module's own AE mode list names that mode `'FullAuto'`, and the corrective inquiry is skipped when polling is on.

**Fix:** write `'FullAuto'` in the AE toggle (or reuse `ENUM.ae[0x00]`), and let the displays show the actual mode name, or a third style for modes other than Auto and Manual.

### L4: The receive buffer grows without limit when the peer never sends a VISCA terminator

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:571-579`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L571-L579)

**What goes wrong:** If **Target IP** / **TCP port** points at a device that isn't a VISCA camera and streams data without a `0xFF` byte, the module keeps appending it to its receive buffer. Memory and CPU use grow until the connection settings are changed, while the status only shows Connecting or "No response from camera".

**Why it happens:** The data handler trims the buffer only when it finds the VISCA terminator (`0xFF`), and the buffer has no maximum length.

**Fix:** cap the buffer. VISCA replies are at most 16 bytes, so if the buffer exceeds e.g. 64 bytes without a `0xFF`, discard it and log a warning.

### L5: Four pairs of actions share the same name in the action picker

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:756`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/main.js#L756), [`src/commands.js:298`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/commands.js#L298), [`src/commands.js:322`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/src/commands.js#L322)

**What goes wrong:** In the action list a user sees **Exposure: Gain** twice: one opens a Reset/Up/Down dropdown, the other an ISO dropdown. The same happens with **Exposure: Shutter** (Reset/Up/Down vs 1/n speeds), **System: Color Space** (number input vs named choices) and **System: Tone Mapping Mode** (number input vs named choices). The only way to tell each pair apart is to add both and look at their options.

**Why it happens:** Action names are built as "group: name", and `cam_gain` / `cam_gain_iso`, `cam_shutter` / `cam_shutter_speed`, `dct_color_space` / `dct_color_space_preset` and `dct_tm_mode` / `dct_tm_mode_preset` share the same name and group in `src/commands.js` (lines 298/322, 328/355, 677/691, 701/715).

**Fix:** give each variant a distinct name, e.g. `Gain (Reset/Up/Down)` and `Gain (ISO)`, `Shutter (Reset/Up/Down)` and `Shutter (Speed)`, `Color Space (direct)` and `Color Space`, `Tone Mapping Mode (direct)` and `Tone Mapping Mode`.

## 💡 Nice to Have

### N1: Searching for the camera name (Atom) in Add connection doesn't find the module

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:25-27`](https://github.com/bitfocus/companion-module-dreamchip-visca/blob/c9bb6d0b6007b29354013887ccfccd9111748a33/companion/manifest.json#L25-L27)

**What goes wrong:** The connection is listed as **Dream Chip Technologies: VISCA**, and the manifest's products and keywords never mention the supported cameras, so a user who searches for `Atom Two` or `Atom` when adding a connection finds nothing.

**Fix:** set `"products": ["Atom Two", "Atom Two HDR"]` (the models HELP.md lists) and add `"atom"` to `keywords`.

## 📝 Additional Notes

- First release: this module has never been published, so there is no previous release to diff against. The whole module at v1.0.1 was reviewed, and every finding is classified 🆕 NEW.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's Node runtime folder has no `prebuilds/` folder with a serialport (`@serialport/bindings-cpp`) binary, so node-gyp-build's last fallback lookup (`dirname(process.execPath)/prebuilds`) also fails for the installed module | Companion ships separate stock Node runtimes; the built `.tgz` contents and the failing lookup were reproduced, but a Companion install was not checked | [H1](#h1-serial-com-connections-never-work-in-the-installed-module-because-the-serialport-native-binding-is-not-packaged) |
| A2 | Companion keeps the saved value of a hidden config field (here **Serial port**) when **Connection** is switched to TCP. If it clears it, the TCP connection is still destroyed once, but the status reads "No serial port" and the retries stop | general Companion config behaviour (`isVisible` only hides fields); not checked in a live instance | [H2](#h2-switching-connection-from-a-failing-serial-port-to-tcp-the-old-serial-retry-keeps-killing-the-new-tcp-connection) |
