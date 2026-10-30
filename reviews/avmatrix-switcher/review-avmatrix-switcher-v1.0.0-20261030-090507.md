# Review: companion-module-avmatrix-switcher v1.0.0

| | |
| --- | --- |
| **Module** | `companion-module-avmatrix-switcher` |
| **Scope** | `tag` |
| **Version** | `v1.0.0` |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`f4aeb9a`](https://github.com/bitfocus/companion-module-avmatrix-switcher/tree/f4aeb9a81fece86381643ac5da79867415b81426) (tag `v1.0.0`) |
| **Previous tag** | none (first release, so the whole module was reviewed) |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion runs this module on Node 22 with Node's default `--unhandled-rejections=throw`, so an unhandled promise rejection ends the module process | The manifest's `node22` runtime; `@companion-module/base` 1.14.1 installs no `unhandledRejection` handler (checked). How the Companion host starts the module process was not checked | [H1](#h1-a-button-press-while-the-network-is-down-can-crash-the-connection) |
| A2 | When the Companion computer loses its route to the switcher, the OS reports the failure (`ENETUNREACH` / `EHOSTUNREACH`) to the UDP send callback, so the send promise rejects | Standard Node `dgram` behaviour when a callback is supplied; not tested here | [H1](#h1-a-button-press-while-the-network-is-down-can-crash-the-connection), [M3](#m3-when-the-companion-computer-loses-its-network-the-connection-stays-green) |
| A3 | The switcher does not send packets to Companion on its own before Companion has sent it something | Companion's UDP socket uses an OS-chosen port the switcher cannot know; the module's own comments say it waits for a reply to a probe. No device documentation checked | [H2](#h2-a-switcher-entered-by-manual-target-ip-never-connects-and-every-button-is-refused) |
| A4 | `saveConfig()` stores the rewritten config, so a switch to another device survives restarts | Standard `@companion-module/base` behaviour; Companion host code not checked | [H3](#h3-each-start-up-scan-can-move-the-connection-to-a-different-switcher-and-overwrites-a-manual-target-ip) |
| A5 | The UDP socket reports ready (and the module reports Connecting) right after `init()`, before any reply from the switcher | [`src/communication.ts:780-787`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L780-L787) maps the socket's ready status to Connecting; not run live | [M6](#m6-the-presets-tab-is-empty-until-the-switcher-answers-and-empties-again-when-it-goes-offline) |
| A6 | Companion shows a `static-text` option's `value` as plain text and does not replace variables in it | The base typing describes `value` only as "The text to show" and has no `useVariables` flag for `static-text`; not checked live | [L8](#l8-the-t-bar-move-action-shows-the-literal-text-selftbar_value) |
| A7 | No Companion module with the ID `szavm` was ever published | The committed `.idea/companion-module-szavm.iml` suggests it was the developer's local project name; the module registry was not checked | [L10](#l10-the-manifest-declares-a-legacy-id-szavm-on-a-first-release) |

## 📋 Issues

### Blocking

- [ ] [C1: .yarnrc.yml is missing the template's supply-chain hardening](#c1-yarnrcyml-is-missing-the-templates-supply-chain-hardening)
- [ ] [H1: A button press while the network is down can crash the connection](#h1-a-button-press-while-the-network-is-down-can-crash-the-connection)
- [ ] [H2: A switcher entered by manual Target IP never connects, and every button is refused](#h2-a-switcher-entered-by-manual-target-ip-never-connects-and-every-button-is-refused)
- [ ] [H3: Each start-up scan can move the connection to a different switcher and overwrites a manual Target IP](#h3-each-start-up-scan-can-move-the-connection-to-a-different-switcher-and-overwrites-a-manual-target-ip)

### Non-blocking

- [ ] [M1: Device-scan sockets stay open after the connection is disabled, and a failed scan leaks them](#m1-device-scan-sockets-stay-open-after-the-connection-is-disabled-and-a-failed-scan-leaks-them)
- [ ] [M2: Changing Target IP back to the selected device's IP keeps sending to the old address](#m2-changing-target-ip-back-to-the-selected-devices-ip-keeps-sending-to-the-old-address)
- [ ] [M3: When the Companion computer loses its network, the connection stays green](#m3-when-the-companion-computer-loses-its-network-the-connection-stays-green)
- [ ] [M4: A scan that finds nothing empties the Device list and drops the switcher's details](#m4-a-scan-that-finds-nothing-empties-the-device-list-and-drops-the-switchers-details)
- [ ] [M5: With no device found and no Target IP, the status stays Connecting forever](#m5-with-no-device-found-and-no-target-ip-the-status-stays-connecting-forever)
- [ ] [M6: The Presets tab is empty until the switcher answers, and empties again when it goes offline](#m6-the-presets-tab-is-empty-until-the-switcher-answers-and-empties-again-when-it-goes-offline)
- [ ] [L1: The 400 ms action-flash timer is not cleared when the connection is disabled](#l1-the-400-ms-action-flash-timer-is-not-cleared-when-the-connection-is-disabled)
- [ ] [L2: FTB, MUTE and Freeze buttons can stop blinking after a reconnect](#l2-ftb-mute-and-freeze-buttons-can-stop-blinking-after-a-reconnect)
- [ ] [L3: FTB, MUTE and Freeze pressed from Companion show solid red instead of blinking](#l3-ftb-mute-and-freeze-pressed-from-companion-show-solid-red-instead-of-blinking)
- [ ] [L4: The AUTO preset button stays red after a single AUTO press](#l4-the-auto-preset-button-stays-red-after-a-single-auto-press)
- [ ] [L5: The T-Bar value changes even when the command was not sent](#l5-the-t-bar-value-changes-even-when-the-command-was-not-sent)
- [ ] [L6: The Last Action (Flash) feedback's example keys do not match the real keys](#l6-the-last-action-flash-feedbacks-example-keys-do-not-match-the-real-keys)
- [ ] [L7: Seven feedbacks are listed under their internal IDs](#l7-seven-feedbacks-are-listed-under-their-internal-ids)
- [ ] [L8: The T-Bar Move action shows the literal text $(self:tbar_value)](#l8-the-t-bar-move-action-shows-the-literal-text-selftbar_value)
- [ ] [L9: Config field tooltips are in Chinese](#l9-config-field-tooltips-are-in-chinese)
- [ ] [L10: The manifest declares a legacy ID szavm on a first release](#l10-the-manifest-declares-a-legacy-id-szavm-on-a-first-release)
- [ ] [L11: Every packet and heartbeat is logged at info level, and device reports are handled twice](#l11-every-packet-and-heartbeat-is-logged-at-info-level-and-device-reports-are-handled-twice)
- [ ] [N1: Loose typing and unused code](#n1-loose-typing-and-unused-code)
- [ ] [N2: Preset categories are ordered with hidden zero-width characters](#n2-preset-categories-are-ordered-with-hidden-zero-width-characters)
- [ ] [NR1: Plan the move to @companion-module/base v2.x](#nr1-plan-the-move-to-companion-modulebase-v2x)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: .yarnrc.yml is missing the template's supply-chain hardening

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/.yarnrc.yml#L1)

**What goes wrong:** The template's Yarn settings block dependency install scripts, hold back package versions published less than 3 days ago, and only exempt `@companion-module/*` packages from that age gate. This module's `.yarnrc.yml` has none of these, so a compromised or freshly hijacked dependency release can run code during `yarn install` on the maintainer's machine and in the Bitfocus build.

**Why it happens:** The module's `.yarnrc.yml` contains only `nodeLinker: node-modules`. It is missing the template keys `enableScripts`, `npmMinimalAgeGate` and `npmPreapprovedPackages`.

**Evidence:**

```yaml
# .yarnrc.yml:1 (module)
nodeLinker: node-modules
```

Template expects (`companion-module-template-ts` @ `e0d42b7`):

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

**Confirm by:** open [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/.yarnrc.yml#L1). It should contain `enableScripts: false`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages: ["@companion-module/*"]` alongside `nodeLinker: node-modules`.

**Fix:** replace `.yarnrc.yml` with the template's file (shown above).

## 🟠 High

### H1: A button press while the network is down can crash the connection

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/communication.ts:347`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L347), [`src/communication.ts:384`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L384)

**What goes wrong:** An operator presses a switcher button, for example a "PGM 1", CUT or AUTO preset. If the Companion computer cannot send the packet at that moment (network cable unplugged, Wi-Fi dropped, or no route to the switcher's address), the failed send is never handled. Node 22 treats that as fatal, so the module process crashes and the connection goes into a crash-and-restart cycle instead of showing a clean "Connection Failure" status. The button press is lost and nothing useful is logged. This can happen for up to about 15 s after the network goes away, because actions stay allowed until three heartbeats have been missed.

**Why it happens:** The base library's UDP helper sends asynchronously and reports a failed send by rejecting its promise. In `sendCommand()` (used by every action) and `sendCommandWithCallback()` (currently unused), that promise is thrown away with `void`, so the surrounding `try/catch` never sees the error. The heartbeat path does this correctly: it `await`s the send inside its `try/catch`.

**Evidence:**

```ts
// src/communication.ts:335-355 (sendCommand)
		try {
			const session = this.sessionCounter++
			const packet = UDPPacker.packCommand(cmd, data, ++this.indexCounter, session)

			if (this.udp) {
				...
				void this.udp.send(packet)
				return true
			}
			return false
		} catch (error) {
			this.log('error', `Send failed: ${(error as Error).message}`)
			this.onErrorCallback?.(error as Error)
			return false
		}
```

```ts
// src/communication.ts:382-384 (sendCommandWithCallback)
		try {
			if (this.udp) {
				void this.udp.send(packet)
```

```js
// node_modules/@companion-module/base/dist/helpers/udp.js:85-98 (base 1.14.1)
    async send(message) {
        if (this.#destroyed)
            throw new Error('Cannot write to destroyed socket');
        ...
        return new Promise((resolve, reject) => {
            this.#socket.send(message, this.#port, this.#host, (error) => {
                if (error) {
                    reject(error);
```

```ts
// src/main.ts:368 and :623 (the action paths reach sendCommand)
		const ok = await this.comm.sendCommand(cmd.set, data)
		const success = await this.comm.sendCommand(cmd, data)
```

```json
// companion/manifest.json:19-20
	"runtime": {
		"type": "node22",
```

A search of `src/` and `node_modules/@companion-module/base/dist` for `unhandledRejection` / `uncaughtException` finds no handler.

**Confirm by:** open [`src/communication.ts:347`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L347) and [`src/communication.ts:384`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L384). Both are `void this.udp.send(packet)` with no `await` or `.catch`. Compare [`src/communication.ts:710`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L710), where the heartbeat awaits the same call.

**Fix:** await the send inside the existing `try/catch` (both methods are already `async`). Do the same in `sendCommandWithCallback()`, or delete that method since nothing calls it.

```ts
await this.udp.send(packet)
```

### H2: A switcher entered by manual Target IP never connects, and every button is refused

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:284-303`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L284-L303), [`src/communication.ts:681-686`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L681-L686)

**What goes wrong:** The help text says Target IP can be typed in by hand when the switcher is on another subnet and cannot be discovered. A user does exactly that, for example 10.0.5.20 for a SHARK S6 on another VLAN, and saves. The connection shows "Connecting – Waiting for device response..." forever. Nothing is ever sent to 10.0.5.20, so the switcher never answers. Every action ("Source (PGM / PVW)", "Switch CUT / AUTO / FTB / MUTE", "PIP1 Status" and so on) is refused with "Not connected" in the log. A mistyped IP behaves the same way and never ends in "Connection Failure".

**Why it happens:** When the connection starts, the module looks the Target IP up in the list of scanned devices. A manual IP is not in that list, so the connection gets no target device. The heartbeat, which is the only thing that probes the switcher, skips sending when there is no target device, so not even the built-in fallback probe for devices without a MAC address goes out, and the missed-reply counter never rises. The module only marks itself connected when a packet arrives from the switcher, and it refuses to send any action until then. Companion's UDP socket uses an OS-chosen port, so the switcher has no way to reach it first.

**Evidence:**

```ts
// src/main.ts:283-285 (setupConnection)
		// 当前连接目标对应的扫描信息（可能因手动输入 IP 而不存在）
		const targetDevice = this.discoveredDevices.find((d) => d.host === this.config.host)
		const modelLabel = targetDevice ? resolveDeviceModel(targetDevice.model) : 'Unknown (manual IP)'
```

```ts
// src/main.ts:302-303
		// 心跳包需要目标设备的 MAC 与型号，使用扫描结果中匹配的条目
		this.comm.setTargetDevice(targetDevice)
```

```ts
// src/communication.ts:681-695 (sendHeartbeat)
	private async sendHeartbeat(): Promise<void> {
		const device = this.connectedDevice
		if (!device) {
			this.log('debug', 'Heartbeat skipped - no target device selected')
			return
		}

		try {
			if (!this.udp) return

			const useHeartbeat = isValidMac(device.mac)
			// 参考样例：心跳 index=1、session=1 固定
			const packet = useHeartbeat
				? UDPPacker.packHeartbeat(device.udpType ?? 0xff, device.mac, 1, 1)
				: UDPPacker.packCommand(0xffff, Buffer.from([0xff]), 1, 1)
```

```ts
// src/communication.ts:735-742 (the only place isConnected becomes true; called from the udp 'data' handler)
	private markDeviceAlive(): void {
		const wasMissed = this.heartbeatMissed
		this.heartbeatMissed = 0

		if (!this.isConnected) {
			this.isConnected = true
```

```ts
// src/communication.ts:327-333 (sendCommand)
	public async sendCommand(cmd: number, data: Buffer): Promise<boolean> {
		if (!this.isConnected) {
			const error = new Error('Not connected')
			this.log('error', error.message)
			this.onErrorCallback?.(error)
			return false
		}
```

```ts
// src/main.ts:171-174 (an empty scan, the other-subnet case, leaves the manual host and missing target in place)
			if (devices.length === 0) {
				this.log('warn', '[Scan] No supported device found, keeping previous device list')
				return
			}
```

```markdown
<!-- companion/HELP.md:13 -->
- **Target IP**: IP address of the switcher. It is filled in from the selected device, but can also be entered manually, which is useful when the device is on another subnet and cannot be discovered.
```

**Confirm by:** open [`src/communication.ts:681-686`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L681-L686) and [`src/main.ts:284-303`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L284-L303). For a host that is not in the scanned list, `connectedDevice` is `undefined`, so `sendHeartbeat()` returns before `udp.send`. The only other sends ([`src/communication.ts:347`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L347), [`src/communication.ts:384`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L384)) are gated on `isConnected`.

**Fix:** keep probing the configured host when no scanned device matches it. The no-MAC fallback probe is already there: in `sendHeartbeat()`, send it instead of returning early, and always count the miss so a wrong IP ends in Connection Failure.

```ts
const packet =
	device && isValidMac(device.mac)
		? UDPPacker.packHeartbeat(device.udpType ?? 0xff, device.mac, 1, 1)
		: UDPPacker.packCommand(0xffff, Buffer.from([0xff]), 1, 1)
```

### H3: Each start-up scan can move the connection to a different switcher and overwrites a manual Target IP

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:185-219`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L185-L219)

**What goes wrong:** Every time the connection starts, the module scans the network and rewrites its own settings from the result:

- A user types Target IP 10.0.5.20 for a switcher on another subnet, the use the help text documents. If any switcher answers the scan on the local subnet, the next restart replaces Target IP with that switcher's address, saves it, and reconnects. The buttons now control the local switcher, not the one the user configured.
- A site has two switchers, A at 192.168.1.10 and B at 192.168.1.11, and the connection is set to B. If B is off when Companion starts and A answers, the module saves Device and Target IP as 192.168.1.10 and reconnects. The "Source (PGM / PVW)" and CUT buttons for this connection now switch A, the wrong production output, and stay on A after B comes back.

**Why it happens:** After the scan, the module keeps the selected Device only if it answered, and otherwise falls back to the first switcher that did. It then always sets Target IP to that switcher's address, writes the config with `saveConfig()` and reconnects. Nothing checks whether the user typed the Target IP by hand or whether the chosen switcher was simply offline. This contradicts the module's own comment in [`src/config.ts:59`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/config.ts#L59) ("a Target IP the user changed by hand is kept").

**Evidence:**

```ts
// src/main.ts:185-204 (scanDevicesOnce, run from init on every start)
			// 已选设备仍在线则保留其选择；否则默认第一个，并把 Target IP 绑定为其地址
			const selected = saved.find((d) => d.host === this.config.device)
			const target = selected ?? saved[0]
			const targetChanged = this.config.device !== target.host || this.config.host !== target.host

			const nextConfig: ModuleConfig = {
				...this.config,
				device: target.host,
				host: target.host,
				devices: saved,
			}
			...
			this.config = nextConfig
			if (configChanged) {
				this.saveConfig(this.config)
			}
```

```ts
// src/main.ts:217-218
			// 设备发生变化（首次识别 / 所选设备已离线）：自动连接到该设备
			this.reconnect()
```

```ts
// src/config.ts:59-60 (the module's own stated rule)
	// Target IP 与所选 Device 的 IP 保持一致；用户手动改过则保留其输入
	const defaultHost = current?.host || current?.device || devices[0]?.host || ''
```

```markdown
<!-- companion/HELP.md:13 -->
- **Target IP**: IP address of the switcher. It is filled in from the selected device, but can also be entered manually, which is useful when the device is on another subnet and cannot be discovered.
```

**Confirm by:** open [`src/main.ts:185-219`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L185-L219). `host: target.host` always replaces the Target IP with a scanned switcher's address, and `selected ?? saved[0]` falls back to the first switcher that answered; the result is saved and reconnected.

**Fix:** only pick a device automatically on first setup, when both Device and Target IP are empty. Otherwise update just the `devices` list and leave Device and Target IP as the user set them.

```ts
const firstSetup = !this.config.device && !this.config.host
const nextConfig: ModuleConfig = firstSetup
	? { ...this.config, device: saved[0].host, host: saved[0].host, devices: saved }
	: { ...this.config, devices: saved }
```

## 🟡 Medium

### M1: Device-scan sockets stay open after the connection is disabled, and a failed scan leaks them

- **Source:** 🔎 QA reviewer + protocol reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:243-273`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L243-L273), [`src/communication.ts:460-467`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L460-L467), [`src/communication.ts:560-580`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L560-L580)

**What goes wrong:** Each scan opens one UDP socket per network interface and broadcasts for about 5 s. If the user disables the connection during a scan, the sockets and their send timers keep running after `destroy()`. If one interface fails to bind (for example an address that disappears during a DHCP or VPN change), the 10 s safety timeout ends the scan but never closes the sockets that did bind, so they stay open, and every later press of "Scan Network for Devices" can leak more.

**Why it happens:** The scan runs on a separate `CommunicationManager` that the instance does not keep, so `destroy()` cannot stop it. The per-interface sockets live only in a local array that only the normal end of the scan closes. The timeout handler and `disconnect()` close only `this.discoverySocket`, which is not set in the per-interface path.

**Fix:** keep the active scanner in a field and call its `disconnect()` from `destroy()`. In `CommunicationManager`, store the per-interface sockets and the scan `setTimeout` handles on the instance, and close or clear all of them in both the timeout handler and `disconnect()`.

### M2: Changing Target IP back to the selected device's IP keeps sending to the old address

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:100-118`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L100-L118)

**What goes wrong:** Device is 192.168.1.10. The user sets Target IP to 192.168.1.20 and saves, and the module reconnects to .20. Later the user sets Target IP back to 192.168.1.10 and saves. The log says "Same device, keeping existing connection", and every button press still goes to 192.168.1.20 while the settings show 192.168.1.10, until the connection is disabled and enabled again.

**Why it happens:** `configUpdated()` decides whether to reconnect by comparing the new Target IP with the previous *Device* value, not with the Target IP the current connection actually uses.

**Fix:** remember the host the current connection was built with (e.g. `this.connectedHost`) and skip the reconnect only when `config.host === this.connectedHost`.

### M3: When the Companion computer loses its network, the connection stays green

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/communication.ts:710-728`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L710-L728)

**What goes wrong:** If the Companion computer's network interface goes down and UDP sends start failing, the log fills with "Heartbeat send failed" every 5 s, but the connection status stays OK and the Connection Status feedback never changes, so the operator sees no failure.

**Why it happens:** The missed-reply counter only goes up after a send succeeds. A failed send jumps to the `catch`, which only logs, so the three-miss limit is never reached and no status change is reported.

**Fix:** count the miss before sending (or also in the `catch`), or report `InstanceStatus.ConnectionFailure` when a heartbeat send fails.

### M4: A scan that finds nothing empties the Device list and drops the switcher's details

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:256`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L256)

**What goes wrong:** If the switcher is off when Companion starts, or the user presses "Scan Network for Devices" while it is off, the Device dropdown then shows only "No supported device found", although the log says the previous list was kept. Later reconnects can no longer find the switcher's MAC address and model, which leads to the stuck-at-Connecting behaviour in [H2](#h2-a-switcher-entered-by-manual-target-ip-never-connects-and-every-button-is-refused).

**Why it happens:** `scanDevices()` replaces the in-memory device list with the scan result before checking whether the result is empty.

**Fix:** replace `discoveredDevices` only when the scan found at least one device, or merge new results into the existing list.

### M5: With no device found and no Target IP, the status stays Connecting forever

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:79-81`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L79-L81), [`src/main.ts:171-174`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L171-L174)

**What goes wrong:** A user adds the connection on a network where the scan finds no switcher. The status shows "Connecting – Scanning for supported devices..." forever. The scan ends after about 5 s and only writes a log line, so the user is never told that nothing was found or that a Target IP is needed.

**Why it happens:** `init()` sets the status to Connecting when Target IP is empty, and the "no devices found" branch of `scanDevicesOnce()` returns without changing it.

**Fix:** in that branch, when Target IP is empty, set a clear status such as `this.updateStatus(InstanceStatus.BadConfig, 'No supported device found – enter a Target IP')`.

### M6: The Presets tab is empty until the switcher answers, and empties again when it goes offline

- **Source:** 🔎 compliance reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:309-322`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L309-L322)

**What goes wrong:** A user adds the connection and opens the Presets tab to build a page before the show, while the SHARK S6 is still off or on another network. The tab is empty: no PGM, PVW, Switch, Streams or PIP presets. They appear only once the switcher answers, and if it drops off the network for a moment during the show, every preset disappears again.

**Why it happens:** The status callback calls `setPresetDefinitions({})` for every status other than OK, and that includes Connecting, which the module reports as soon as its UDP socket is ready.

**Fix:** register the presets once in `init()` and remove both the `setPresetDefinitions({})` call and the `updatePresets()` call from the status callback. Presets are static button templates and don't depend on whether the switcher is online.

## 🟢 Low

### L1: The 400 ms action-flash timer is not cleared when the connection is disabled

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:89-93`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L89-L93), [`src/main.ts:344-353`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L344-L353), [`src/main.ts:682-692`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L682-L692)

**What goes wrong:** After a button press (for example CUT) or a switcher report that changes FTB, Freeze or Mute, the module starts a 400 ms timer that resets the `last_action` variable and the "Last Action (Flash)" feedback. If the user disables or deletes the connection inside that window, the timer still fires after `destroy()`. Nothing visible changes, but `destroy()` does not stop everything the module started.

**Why it happens:** `destroy()` calls `destroyConnection()`, which stops the connection and the blink timer but never clears `flashTimer`. `flash()` only clears the previous timer when it starts a new flash.

**Fix:** clear the flash timer in `destroy()`.

```ts
if (this.flashTimer) {
	clearTimeout(this.flashTimer)
	this.flashTimer = undefined
}
```

### L2: FTB, MUTE and Freeze buttons can stop blinking after a reconnect

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:349-352`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L349-L352), [`src/main.ts:458-466`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L458-L466), [`src/main.ts:695-708`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L695-L708)

**What goes wrong:** While FTB (or MUTE or Freeze) is active, its button blinks red and black. If the connection reconnects (a Device change, or the start-up scan) during the black phase, the blinking stops and the FTB button stays dark even though FTB is still active.

**Why it happens:** `destroyConnection()` clears the blink timer but leaves the blink phase at "off". The blink only restarts when the FTB, Freeze or Mute state changes, and the next switcher report still says FTB is on, so no change is detected.

**Fix:** reset `this.deviceState.blinkOn = true` when clearing the blink timer, or call `this.updateBlink()` after reconnecting.

### L3: FTB, MUTE and Freeze pressed from Companion show solid red instead of blinking

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:660-678`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L660-L678)

**What goes wrong:** Pressing FTB from a Companion button turns the FTB preset solid red rather than blinking. If the blink was already running and FTB is then turned off from Companion, the 500 ms blink interval keeps running with nothing active.

**Why it happens:** The local update after a button press flips the FTB/MUTE/Freeze state without calling `updateBlink()`. When the switcher's report later confirms the same value, no change is detected, so `updateBlink()` never runs.

**Fix:** call `this.updateBlink()` after each local toggle of `ftbActive`, `muteActive` and `freezeActive`.

### L4: The AUTO preset button stays red after a single AUTO press

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:657-659`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L657-L659)

**What goes wrong:** Press the AUTO preset (Switch or Streams > AUTO). The "Auto Active" feedback turns the button red and it stays red after the transition has finished. It only turns off on the next AUTO press, and from then on it is wrong the other way round.

**Why it happens:** Every AUTO press flips the module's `autoActive` flag, and no switcher report ever resets it.

**Fix:** treat AUTO as momentary: flash it, or clear `autoActive` after the transition or when the next switch report arrives. Alternatively drop the `auto_active` feedback from the preset.

### L5: The T-Bar value changes even when the command was not sent

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:747-757`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L747-L757)

**What goes wrong:** Pressing "T-Bar +" while the connection is not OK still changes the `$(avmatrix:tbar_value)` variable (e.g. from 10 to 20) although nothing reached the switcher. The displayed value no longer matches the hardware until a switcher report corrects it.

**Why it happens:** `moveTBar()` updates the stored value and the variable before sending, and ignores whether the send succeeded.

**Fix:** update the value and the variable only after `sendToDevice()` returns `true`.

### L6: The Last Action (Flash) feedback's example keys do not match the real keys

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:220`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/feedbacks.ts#L220)

**What goes wrong:** A user building their own button follows the option label "Action key (e.g. key:5 / set:luma:1 / tbar)" and enters `key:5`. The button never flashes, because button presses record keys like `set_source|source=5`. Only switcher-reported FTB, Freeze and Mute changes use the `key:NN` form.

**Why it happens:** The flash key for actions is built by `flashKeyFor()` as `actionId|option=value` ([`src/actions.ts:774`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/actions.ts#L774)), but the label still documents the older format.

**Fix:** update the label to the real format, or use one key scheme (e.g. `key:<Key_val>`) for both actions and reports.

### L7: Seven feedbacks are listed under their internal IDs

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:178-208`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/feedbacks.ts#L178-L208)

**What goes wrong:** In the feedback picker, the PIP, LUMA, CHROMA, DSK and LOGO status feedbacks appear as "pip1_status_active (Green/Red)", "luma_status_active (Green/Red)" and so on, not as readable names like "PIP1 Status". In the same list, "Connection Status" is active when the switcher is *disconnected*, and nothing on screen says so.

**Why it happens:** `statusFb()` builds the name from the internal feedback ID. The `connection_status` feedback returns "not connected" and has no `description`.

**Fix:** pass a display label into `statusFb()` (e.g. "PIP1 Status", "LUMA Key Status") and give these feedbacks a `description`. Rename "Connection Status" (e.g. "Device Disconnected") or describe it as "Active when the switcher is not responding".

### L8: The T-Bar Move action shows the literal text $(self:tbar_value)

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:647`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/actions.ts#L647)

**What goes wrong:** When a user edits a "T-Bar Move" action, the "Current Value (0-500)" line shows the text `$(self:tbar_value)` instead of a number such as 250. `self` is not this connection's label either; the real variable is `$(<connection label>:tbar_value)`, e.g. `$(avmatrix:tbar_value)`.

**Why it happens:** A `static-text` option's `value` is plain text to display; Companion does not fill in variables there.

**Fix:** remove the static-text line, or change it to an explanation such as "The current position is available as the variable tbar_value".

### L9: Config field tooltips are in Chinese

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:73`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/config.ts#L73), [`src/config.ts:82`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/config.ts#L82)

**What goes wrong:** An English-speaking user hovering over "Device" or "Target IP" in the connection settings sees "UDP 广播扫描到的设备，默认选中第一个" and "所选设备的 IP，可手动修改". The second one explains that Target IP can be edited by hand, which matters for this module.

**Fix:** translate the tooltips, e.g. "Devices found by UDP broadcast scan; the first one is selected by default" and "IP of the selected device; can be edited manually".

### L10: The manifest declares a legacy ID szavm on a first release

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:25`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/companion/manifest.json#L25)

**What goes wrong:** `legacyIds` tells Companion to treat existing connections of a module called `szavm` as this module. If no `szavm` module was ever published, the entry does nothing but confuse. If one was, its users' saved actions and feedbacks would move into this module without upgrade scripts for their IDs. The committed `.idea/companion-module-szavm.iml` suggests `szavm` was only the developer's local project name.

**Fix:** remove `"legacyIds": ["szavm"]` unless a module with that ID was actually published; if it was, add upgrade scripts that map its action and feedback IDs.

### L11: Every packet and heartbeat is logged at info level, and device reports are handled twice

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/communication.ts:697-700`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L697-L700), [`src/communication.ts:799-843`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L799-L843), [`src/communication.ts:862-864`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L862-L864)

**What goes wrong:** With the connection running, the Companion log gets an info line for every heartbeat probe (every 5 s), a full hex dump for every packet the switcher sends ("[Recv] 41B: 5aa5…"), a hex dump for every command sent, and every switch report twice. Real problems are hard to spot, and the module's warnings show up as "info" too.

**Why it happens:** Most traffic logging uses `info`, and the module's `log()` maps `warn` to `info`. Report packets go both to the report handler and to the general data handler, which both update the switch state.

**Fix:** move the `[Recv]`, `[Send]`, `[Heartbeat]` and `[Report]` traffic lines to `debug`, pass `warn` through unchanged, and send each packet to only one handler.

## 💡 Nice to Have

### N1: Loose typing and unused code

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:403`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L403), [`src/main.ts:764`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/main.ts#L764)

**What goes wrong:** No visible effect. `handleDeviceReport(packet: any)` and `getDeviceState(): any` turn off type checking on the report path, and `this.discoverySocket!` ([`src/communication.ts:557`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/communication.ts#L557)) hides a possible `undefined`. `sendCommandWithCallback()`, `send()` and most of `DeviceCommands` are never used.

**Fix:** type `packet` as `ParsedPacket` and `getDeviceState()` as `typeof this.deviceState`, remove the non-null assertion, and delete the unused helpers.

### N2: Preset categories are ordered with hidden zero-width characters

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:18-31`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/src/presets.ts#L18-L31)

**What goes wrong:** Nothing visible. Each preset category name starts with invisible U+200B characters to force a sort order, so category names differ invisibly from what users see, which can confuse search or exports.

**Fix:** drop the zero-width prefixes and use plain category names; Companion shows categories in the order the presets are defined.

## 🔮 Next Release

### NR1: Plan the move to @companion-module/base v2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/f4aeb9a81fece86381643ac5da79867415b81426/package.json)

**What goes wrong:** Nothing changes for users today. Base 1.14 is the last v1 API; moving to v2 (Companion 4.3+, or v2.1 for Companion 5.0+) brings expression support and the current module API.

**Fix:** in a future release, migrate to v2.x following the Companion v1-to-v2 migration guide.

## 📝 Additional Notes

- This is the module's first release (`v1.0.0` is its only tag), so there is no diff: the whole module was reviewed and every finding is classified 🆕 NEW.
- `validate-template.ps1 -RunBuild` passed `yarn install --immutable`, `yarn package` and `yarn lint`; apart from [C1](#c1-yarnrcyml-is-missing-the-templates-supply-chain-hardening) the module matches the API 1 TypeScript template.
