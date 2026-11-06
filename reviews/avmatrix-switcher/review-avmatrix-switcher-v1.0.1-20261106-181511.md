# Review: companion-module-avmatrix-switcher v1.0.1 (follow-up to the v1.0.0 review)

| | |
| --- | --- |
| **Module** | `companion-module-avmatrix-switcher` |
| **Scope** | `tag` |
| **Version** | `v1.0.1` |
| **Release** | New module — never published |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`9f9e26e`](https://github.com/bitfocus/companion-module-avmatrix-switcher/tree/9f9e26e8803abd98003191f6d0b240b7abefd023) (tag `v1.0.1`) |
| **Previous tag** | none published (`v1.0.0` was reviewed but never published, so the whole module was reviewed again) |
| **Prior review** | [v1.0.0 review, 2026-10-30](review-avmatrix-switcher-v1.0.0-20261030-090507.md) (❌ Changes Required) |
| **Date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the Device dropdown only offers "No supported device found", Companion saves Device as an empty string, so a user who then types a Target IP ends up with an empty Device and a Target IP | [`src/config.ts:41-44`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/config.ts#L41-L44) gives that placeholder the id `''` and uses it as the default; how the Companion UI saves a dropdown with a single placeholder choice was not checked | [H2](#h2-a-shark-h4k-reached-by-a-typed-target-ip-is-sent-shark-s6-plus-commands) |
| A2 | A SHARK H4K does not act correctly on key presses and probes sent in the S6 PLUS packet format and key numbering | The module's own key tables and comments (`src/devices/protocols.ts`, `src/devices/types.ts`); not tested on hardware | [H2](#h2-a-shark-h4k-reached-by-a-typed-target-ip-is-sent-shark-s6-plus-commands) |
| A3 | Controlling a SHARK H4K through a typed Target IP is a normal, supported setup. If the H4K is not officially supported yet, Medium may fit H2 better | The help page and the Target IP tooltip document typing an IP, and the code ships H4K profiles; but `companion/HELP.md` lists only the SHARK S6 and S6 PLUS | [H2](#h2-a-shark-h4k-reached-by-a-typed-target-ip-is-sent-shark-s6-plus-commands), [L5](#l5-the-help-page-does-not-list-the-shark-s5-h5-h4k-or-h4k-plus-that-this-release-supports) |
| A4 | One Companion session can send 65,535 commands on one connection, for example days of shows without a restart, or a T-Bar or Adjust action on an encoder | The counter is only reset when a new connection object is built (reconnect or restart); the packets per action come from the code, real usage is an estimate | [H3](#h3-after-65535-commands-every-button-fails-while-the-status-stays-green) |
| A5 | When a module re-registers its actions with different dropdown choice IDs, Companion keeps each saved button's stored option value and passes it to the callback unchanged | How Companion stores API 1 action options; not verifiable from the module code | [M2](#m2-buttons-built-under-one-device-profile-press-different-keys-after-the-profile-changes) |
| A6 | Companion does not replace variables in an API 1 feedback's text option by itself; the module has to call `parseVariablesInString` | The base 1.14.1 typing describes `useVariables` only as "Whether to suggest variables to the user"; Companion's host code was not checked | [N2](#n2-the-last-action-flash-key-field-offers-variables-but-does-not-resolve-them) |
| A7 | Companion runs the actions of one button step at the same time, not one after another | Companion's default action execution; not in the module code | [L7](#l7-the-orange-last-action-flash-can-light-the-wrong-button-or-none-when-two-actions-run-at-the-same-time) |

## 📋 Issues

### Blocking

- [ ] [H1: Action descriptions, option labels, code comments and the changelog are in Chinese](#h1-action-descriptions-option-labels-code-comments-and-the-changelog-are-in-chinese)
- [ ] [H2: A SHARK H4K reached by a typed Target IP is sent SHARK S6 PLUS commands](#h2-a-shark-h4k-reached-by-a-typed-target-ip-is-sent-shark-s6-plus-commands)
- [ ] [H3: After 65,535 commands every button fails while the status stays green](#h3-after-65535-commands-every-button-fails-while-the-status-stays-green)

### Non-blocking

- [ ] [M1: After a dropout the connection can turn green again with the heartbeat stopped, so the next failure is never shown](#m1-after-a-dropout-the-connection-can-turn-green-again-with-the-heartbeat-stopped-so-the-next-failure-is-never-shown)
- [ ] [M2: Buttons built under one device profile press different keys after the profile changes](#m2-buttons-built-under-one-device-profile-press-different-keys-after-the-profile-changes)
- [ ] [L1: Disabling the connection during a device scan leaves the scan sockets broadcasting (v1.0.0 M1 only partly fixed)](#l1-disabling-the-connection-during-a-device-scan-leaves-the-scan-sockets-broadcasting-v100-m1-only-partly-fixed)
- [ ] [L2: Short follow-up timers after button presses keep running after the connection is disabled](#l2-short-follow-up-timers-after-button-presses-keep-running-after-the-connection-is-disabled)
- [ ] [L3: On a SHARK H4K the PIP1 Adjust preset picks IN2 and the LUMA Adjust preset sends Clip 50](#l3-on-a-shark-h4k-the-pip1-adjust-preset-picks-in2-and-the-luma-adjust-preset-sends-clip-50)
- [ ] [L4: Two switchers of the same model show as identical entries in the Device dropdown](#l4-two-switchers-of-the-same-model-show-as-identical-entries-in-the-device-dropdown)
- [ ] [L5: The help page does not list the SHARK S5, H5, H4K or H4K PLUS that this release supports](#l5-the-help-page-does-not-list-the-shark-s5-h5-h4k-or-h4k-plus-that-this-release-supports)
- [ ] [L6: Switcher reports and field writes still flood the log at info level, and H4K packets are handled twice (v1.0.0 L11 partly fixed)](#l6-switcher-reports-and-field-writes-still-flood-the-log-at-info-level-and-h4k-packets-are-handled-twice-v100-l11-partly-fixed)
- [ ] [L7: The orange Last Action (Flash) can light the wrong button, or none, when two actions run at the same time](#l7-the-orange-last-action-flash-can-light-the-wrong-button-or-none-when-two-actions-run-at-the-same-time)
- [ ] [N1: Fix action IDs and names now, before the first publish makes them permanent](#n1-fix-action-ids-and-names-now-before-the-first-publish-makes-them-permanent)
- [ ] [N2: The Last Action (Flash) key field offers variables but does not resolve them](#n2-the-last-action-flash-key-field-offers-variables-but-does-not-resolve-them)
- [ ] [N3: Feedback dropdowns and action descriptions show SHARK S6 PLUS ranges and raw protocol codes on a SHARK H4K](#n3-feedback-dropdowns-and-action-descriptions-show-shark-s6-plus-ranges-and-raw-protocol-codes-on-a-shark-h4k)
- [ ] [N4: Leftover unused code, a non-null assertion and a double cast (v1.0.0 N1 partly addressed)](#n4-leftover-unused-code-a-non-null-assertion-and-a-double-cast-v100-n1-partly-addressed)
- [ ] [NR1: Plan the move to @companion-module/base v2.x](#nr1-plan-the-move-to-companion-modulebase-v2x)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: Action descriptions, option labels, code comments and the changelog are in Chinese

- **Source:** 🤖 validate-template (NOT-ENGLISH)
- **Classification:** 🆕 NEW
- **File:** [`.idea/workspace.xml:4`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/.idea/workspace.xml#L4), [`CHANGELOG.md:3`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/CHANGELOG.md#L3), [`src/main.ts:47`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L47), [`src/actions.ts:728`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L728) and many more (the finding spans 16 files, plus the [`md/`](https://github.com/bitfocus/companion-module-avmatrix-switcher/tree/9f9e26e8803abd98003191f6d0b240b7abefd023/md) folder)

**What goes wrong:** Everything in a Companion module must be in English. An English-speaking user who adds the "Transition WIPE Style (Wipe1/2/3)" action reads the description "设置指定 WIPE 通道的样式（0x0020），可选是否同时按下该 WIPE 键切换通道" and a checkbox labelled "同时按下 WIPE 键（切换到该通道）". The "Key Module Press (KEY / ON AIR)" action, the "Key Module Selected" feedback, the "LUMA Mask" / "CHROMA Mask" descriptions and several log messages (for example the T-Bar "未生效" warning) are also partly in Chinese. The v1.0.0 review's L9 got the config tooltips translated, but the rest is unchanged. The code comments throughout `src/`, the whole CHANGELOG, the committed `.idea/` IDE files and the 20 developer notes in `md/` (for example `md/AVM同步协议.md`) are in Chinese, so the next maintainer or the Bitfocus team cannot follow the code or the release notes.

**Why it happens:** The module was written in Chinese, and v1.0.1 added more Chinese text with the new H4K profiles. The `md/` folder isn't in the validator's file list below, but it is part of the same finding.

**Evidence:**

```text
Validator message (verbatim):
Everything in the module must be written in English (code comments, user-facing text, HELP.md, README.md, …). 717 lines are in another language: .idea/workspace.xml (4 lines: 4, 30, 32-33); CHANGELOG.md (60 lines: 3, 9, 13, 17, 21-40, 44, 48-49, 51, 53, 55-78, 84-89, 93); src/actions.ts (81 lines: 10, 14-15, 21, 25, 30, 32, 46, 57, 71, 73, 78, 85-86, …); src/commandHandler.ts (38 lines: 20, 22, 32, 50, 60, 71, 79, 89, 93, 95-97, 99, 129, …); src/communication.ts (94 lines: 16, 23-24, 29, 34-35, 38, 41, 56, 62-63, 71-72, 74, 83-85, 102, …); src/config.ts (14 lines: 3, 6-7, 11, 13, 15, 19, 23, 25, 27, 29, 33, 40, …); src/debug.ts (5 lines: 2, 4-5, 7, 11); src/devices/index.ts (15 lines: 15-18, 21, 27, 45, 50, 58-60, 69, 75, 80, 116); src/devices/profiles.ts (14 lines: 3, 18-19, 24-25, 30-32, 37-38, 74, 84-85, 96); src/devices/protocols.ts (28 lines: 30, 42, 51, 59, 62, 65, 96, 99, 130, 142, 145, 162, …); src/devices/types.ts (66 lines: 3, 6, 8-9, 11, 23, 30, 45-47, 50, 58, 60, 62, 70, …); src/features.ts (58 lines: 2, 4-7, 9-10, 12-13, 22, 24, 26, 29-31, 37, 56, 79, 108, …); src/feedbacks.ts (21 lines: 8, 23, 55, 87, 116, 128, 154, 183, 207-210, 212, 246, 252, …); src/main.ts (192 lines: 47, 51, 54, 56, 58, 60, 66, 68, 70, 72, 74, 76, …); src/presets.ts (25 lines: 6, 12-13, 27, 34, 70-71, 73, 78, 81, 84, 112, 140, 219, …); src/variables.ts (2 lines: 14, 27)
```

```ts
// src/main.ts:47
	// 当前设备所属产品档案：决定可用功能分组与协议命令表
// src/actions.ts:728 and :747 (shown in the action editor)
			description: '设置指定 WIPE 通道的样式（0x0020），可选是否同时按下该 WIPE 键切换通道',
					label: '同时按下 WIPE 键（切换到该通道）',
// src/actions.ts:1080
			description: '直接按 PIP/LUMA/CHROMA/DSK 的 KEY 或 ON AIR 键',
// src/feedbacks.ts:271
			description: '当前激活的 Key 模块（0x0130 回读，仅 H4K）',
```

```markdown
<!-- CHANGELOG.md:3 -->
本文件遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 规范，版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。
```

**Confirm by:** run `grep -nP '[\x{4e00}-\x{9fff}]' -r src CHANGELOG.md .idea md` in the clone at `v1.0.1`.

**Fix:** translate every comment, action and feedback description, option label, log message and the CHANGELOG into English. Remove the `.idea/` IDE folder and the `md/` developer notes from the repository (add them to `.gitignore`), or translate the notes if they should stay.

### H2: A SHARK H4K reached by a typed Target IP is sent SHARK S6 PLUS commands

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:512-518`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L512-L518), [`src/main.ts:256-270`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L256-L270), [`src/devices/index.ts:46-48`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/devices/index.ts#L46-L48)

**What goes wrong:** The help text says Target IP can be typed in by hand when the switcher is on another subnet and cannot be discovered. Take a SHARK H4K on another VLAN, at 10.0.5.20. The user types that address and saves. The module can't find it in the scan list, so it falls back to the SHARK S6 PLUS profile, and every button then uses S6 PLUS key values and command codes:

- "Switch CUT / AUTO / FTB / MUTE" > CUT sends key 17. The module's own H4K table says CUT is 13 and 17 is SPEED1.
- "DSK Status" uses command 0x0040, which the H4K table assigns to LOGO.
- The action list shows S6 PLUS items such as "Switch Stream" and PIP2/PIP3, which the H4K doesn't have.

Either the switcher never answers the S6 PLUS-style probe and the status ends in Connection Failure, or it answers, the status goes green, and the buttons do the wrong thing or nothing.

The same happens on the local subnet if the H4K is off when the connection is added: the scan finds nothing, the user types the IP, and the S6 PLUS profile stays until Companion has been restarted twice. The reverse also happens. Leave Device on a local H4K (the one the first scan picked) and change Target IP to a remote S6 PLUS. After the next restart the start-up scan switches the profile to H4K, so the S6 PLUS gets H4K-format commands.

**Why it happens:** The connection picks the device profile only by looking the Target IP up in the scanned device list. If the address isn't there, the profile falls back to the default, which is the SHARK S6 PLUS. The config has no way to choose the model by hand, although the module's own scan warning ([`src/main.ts:480`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L480), in Chinese) tells users to "manually specify Device Model in the config". The start-up scan then refreshes the profile and the heartbeat target from the scan entry that matches the **Device** dropdown (`config.device`), not the Target IP the connection actually uses (`config.host`). The S6, S5 and H5 profiles share the S6 PLUS command set, so only the SHARK H4K and H4K PLUS are affected. All of this code is new in v1.0.1.

**Evidence:**

```ts
// src/main.ts:512-518 (setupConnection)
		// 当前连接目标对应的扫描信息（可能因手动输入 IP 而不存在）
		const targetDevice = this.discoveredDevices.find((d) => d.host === this.config.host)
		// 依据扫描到的型号（或设备类型标识）切换产品档案
		this.applyDeviceProfile(targetDevice?.model, targetDevice?.productType)
		const modelLabel = targetDevice
			? resolveDeviceModel(targetDevice.model, targetDevice.productType)
			: 'Unknown (manual IP)'
```

```ts
// src/devices/index.ts:45-48
/** 取当前设备的产品档案；未识别型号回退默认档案 */
export function getActiveProfile(rawModel: string | undefined, deviceType?: number): DeviceProfile {
	return matchDeviceProfile(rawModel, deviceType) ?? DEFAULT_DEVICE_PROFILE
}
```

```ts
// src/devices/profiles.ts:96-98
/** 未识别型号时使用的档案（保持原有行为：按 S6 PLUS 全功能处理） */
export const DEFAULT_DEVICE_PROFILE: DeviceProfile =
	DEVICE_PROFILES.find((p) => p.id === 'shark-s6-plus') ?? DEVICE_PROFILES[0]
```

```ts
// src/devices/protocols.ts:105-109 (CCP_0617_KEY_MAP) and 136-140 (H4K_KEY_MAP)
	cut: 17,
	auto: 18,
	ftb: 19,
	mute: 20,
	speed1: 21,
...
	cut: 13,
	auto: 14,
	ftb: 15,
	mute: 16,
	speed1: 17,
```

```ts
// src/communication.ts:489 (the scan is broadcast-only, so a host on another subnet never enters the scan list)
				const broadcastTarget = '255.255.255.255'
```

```ts
// src/main.ts:256-270 (start-up scan keys the profile and heartbeat target on config.device, not config.host)
			const firstSetup = !this.config.device && !this.config.host
			if (!firstSetup) {
				const stillOnline = saved.find((d) => d.host === this.config.device)
				...
				if (stillOnline) {
					this.applyDeviceProfile(stillOnline.rawModel, stillOnline.productType)
					if (this.comm) {
						this.comm.setTargetDevice(this.discoveredDevices.find((d) => d.host === stillOnline.host))
						if (this.comm.getStatus()) this.comm.startHeartbeat()
```

```ts
// src/config.ts:62-68 (no model field; Target IP documented as editable by hand)
			type: 'textinput',
			id: 'host',
			label: 'Target IP',
			...
			tooltip: 'IP of the selected device; can be edited manually (useful when the device is on another subnet)',
```

**Confirm by:** open [`src/main.ts:512-515`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L512-L515) and [`src/devices/index.ts:46-48`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/devices/index.ts#L46-L48). A Target IP that is missing from the scan list resolves to the SHARK S6 PLUS profile. Then check [`src/main.ts:258`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L258), which matches on `config.device` instead of `config.host` before it calls `applyDeviceProfile` and `setTargetDevice`.

**Fix:** choose the profile from the address the connection actually uses, and give users a way to set the model by hand.

1. In `scanDevicesOnce()`, look up `saved.find((d) => d.host === this.config.host)` and pass that entry to `applyDeviceProfile` and `setTargetDevice`.
2. Add a "Device Model" dropdown to the config (Auto / SHARK S6 / S6 PLUS / S5 / H5 / H4K / H4K PLUS), and use it whenever the Target IP is not in the scan list. The scan warning already promises this field.
3. In `setupConnection()`, when no scanned device matches, apply the manual model or keep the current profile instead of falling back to the S6 PLUS.

```ts
const profileSource = targetDevice ?? this.manualModelDevice()
if (profileSource) this.applyDeviceProfile(profileSource.model, profileSource.productType)
```

### H3: After 65,535 commands every button fails while the status stays green

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/communication.ts:255-257`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L255-L257), [`src/communication.ts:339-341`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L339-L341), [`src/communication.ts:108`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L108)

**What goes wrong:** The connection numbers every packet it sends: button presses, each field of an Adjust action, and the H4K state queries after connecting and after T-Bar moves. On the 65,536th command the packet can no longer be built, and from then on every command fails. CUT, "Source (PGM / PVW)", "T-Bar Move" and every other action stop working. The log shows `Send failed: The value of "value" is out of range. It must be >= 0 and <= 65535. Received 65536` and `[Action] Failed to send: CUT`. The connection status stays green, because the heartbeat uses a fixed packet number and keeps getting replies. Only disabling and re-enabling the connection, or restarting Companion, fixes it. Saving the config with the same Target IP does not.

The limit comes sooner than it sounds. A single "CHROMA Adjust" press on an H4K sends about 17 packets, and every "T-Bar Move" step on an H4K sends 2, so a show machine that runs for days, or a T-Bar on an encoder, gets there.

**Why it happens:** The packet number (`indexCounter`) goes up by one before every command and never wraps back. The packet builder writes it into a 2-byte field with `Buffer.writeUInt16BE`, which throws for any value above 65535. `sendCommand()` catches that error and returns `false` for every later command. Nothing resets the counter except building a new connection object, which only happens on a reconnect. The same code was already in the unpublished v1.0.0.

**Evidence:**

```ts
// src/communication.ts:255-257
	private sessionCounter = 1
	/** 报文序号，参考上位机 _index，每发一条指令自增 */
	private indexCounter = 0
```

```ts
// src/communication.ts:339-341 (the same pattern is at :374-375 in sendCommandWithCallback)
		try {
			const session = this.sessionCounter++
			const packet = UDPPacker.packCommand(cmd, data, ++this.indexCounter, session)
```

```ts
// src/communication.ts:357-361
		} catch (error) {
			this.log('error', `Send failed: ${(error as Error).message}`)
			this.onErrorCallback?.(error as Error)
			return false
		}
```

```ts
// src/communication.ts:107-108
		offset += 2
		packet.writeUInt16BE(index, offset) // 数据包序号
```

```ts
// src/communication.ts:722-729 (heartbeat/probe use a fixed index of 1, so the status stays OK)
				packet = UDPPacker.packHeartbeat(device.udpType ?? 0xff, device.mac, 1, 1)
				probeLabel = '0xEEEE'
			} else if (probeCommand !== undefined) {
				packet = UDPPacker.packCommand(probeCommand, Buffer.alloc(0), 1, 1)
				probeLabel = `0x${probeCommand.toString(16).padStart(4, '0')}`
			} else {
				packet = UDPPacker.packCommand(0xffff, Buffer.from([0xff]), 1, 1)
```

```ts
// src/main.ts:180-183 (a config save with the same host keeps the old connection, so the counter is not reset)
		if (!deviceChanged && this.comm && this.config.host === this.connectedHost) {
			this.log('debug', '[Config] Same connected host, keeping existing connection')
			return
		}
```

```text
grep "indexCounter\s*=" src   -> only src/communication.ts:257 (the initializer); nothing resets or wraps it
node -e 'Buffer.alloc(2).writeUInt16BE(65536,0)'   -> ERR_OUT_OF_RANGE The value of "value" is out of range. It must be >= 0 and <= 65535. Received 65536
```

**Confirm by:** open [`src/communication.ts:341`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L341) and [`src/communication.ts:375`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L375). `++this.indexCounter` never wraps (no `& 0xffff`), and [`src/communication.ts:108`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L108) writes it with `writeUInt16BE`. The heartbeat at [`src/communication.ts:722-729`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L722-L729) uses a hard-coded index of 1, so it keeps working after commands start failing.

**Fix:** keep the packet number within 1..65535 in both `sendCommand()` and `sendCommandWithCallback()`. Wrap the session counter the same way, for completeness.

```ts
this.indexCounter = (this.indexCounter % 0xffff) + 1
const packet = UDPPacker.packCommand(cmd, data, this.indexCounter, session)
// session: this.sessionCounter = (this.sessionCounter + 1) >>> 0
```

## 🟡 Medium

### M1: After a dropout the connection can turn green again with the heartbeat stopped, so the next failure is never shown

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/communication.ts:753-765`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L753-L765), [`src/communication.ts:775-786`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L775-L786)

**What goes wrong:** Say the network to the switcher drops for 20 s. After three missed heartbeats (about 15 s) the module shows Connection Failure and stops sending heartbeats. When the network comes back and someone changes a source on the switcher's front panel, the switcher's state report turns the status green again ("Device responded"), but the heartbeat is never restarted. If the switcher then goes away again, for example it is powered off, the status stays green for good. The "Device Disconnected" feedback stays off, and button presses are logged as sent while nothing reaches the device.

**Why it happens:** On three misses the heartbeat stops itself and reports Connection Failure. Any valid incoming packet marks the device alive (the module's own comment at [`src/communication.ts:848`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L848) calls this its disconnect-recovery path) and reports OK, but doesn't restart the heartbeat. The heartbeat is only started when the UDP socket first reports ready, and once from the start-up scan.

**Fix:** restart the heartbeat when the device comes back: in `markDeviceAlive()`, inside `if (!this.isConnected)`, add `if (!this.heartbeatTimer) this.startHeartbeat()`. A simpler alternative is to keep probing every 5 s after three misses (report Connection Failure, but don't call `stopHeartbeat()`), so the module also recovers on its own when the switcher comes back.

### M2: Buttons built under one device profile press different keys after the profile changes

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:1012-1016`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L1012-L1016), [`src/presets.ts:85-93`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/presets.ts#L85-L93)

**What goes wrong:** Take a page built from the bundled presets while the connection used the SHARK S6 PLUS profile, for example during the typed-IP fallback in [H2](#h2-a-shark-h4k-reached-by-a-typed-target-ip-is-sent-shark-s6-plus-commands), or before an S6 PLUS was replaced by an H4K and the Device dropdown changed. Once the profile is H4K, the "PVW1" button still shows PVW1 and lights green when PVW1 is on preview, but pressing it selects PVW3. The CUT button sends SPEED1, and FTB sends a CHROMA key. The action editor shows the stored value under a different label, for example "PVW3".

**Why it happens:** The "Source (PGM / PVW)" and "Switch CUT / AUTO / FTB / MUTE" dropdowns, and the presets, store the raw device key number, which differs between the S6 PLUS and H4K protocols. Saved buttons keep those numbers when the actions are re-registered for a new profile. The feedbacks, by contrast, use logical source numbers (1-6), so the button still lights for the right source.

**Fix:** store device-independent IDs in the action options, for example `pgm1`, `pvw1`, `pgm_pattern1`, `cut`, `auto`, `ftb`, `mute`, `mix`, `dip`, `freeze`, and map them to the active protocol's key table when sending. Do the same in the presets and in the Transition MIX / DIP, Switch Stream and Key Module Press dropdowns. This is easiest now, before the first publish stores any key numbers in users' buttons.

## 🟢 Low

### L1: Disabling the connection during a device scan leaves the scan sockets broadcasting (v1.0.0 M1 only partly fixed)

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:148-157`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L148-L157), [`src/main.ts:456-502`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L456-L502), [`src/main.ts:586-591`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L586-L591), [`src/communication.ts:622-671`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L622-L671)

**What goes wrong:** The module scans for devices for about 4.5 s every time the connection is enabled, and again when a "Scan Network for Devices" button is pressed. If the user disables or deletes the connection during those seconds, the scan isn't stopped. Its UDP sockets (one per network interface on the Companion computer) stay open and keep sending the remaining discovery rounds to 255.255.255.255:7000 until the scan ends by itself, about 4.5 s after it started (10 s when an interface failed to bind). The results are thrown away, and the operator sees nothing. The v1.0.1 CHANGELOG says M1's "still sending/listening after destroy" is fixed, but only the timeout path and the connection's own `disconnect()` were changed. v1.0.1 does fix the v1.0.0 leak: the scan now closes all its sockets on both the normal end and the timeout.

**Why it happens:** The scan runs on its own `CommunicationManager`, created as a local variable in `scanDevices()` and closed only in that function's `finally` once the scan has finished. `destroy()` only disconnects the main connection, which is a different object. The 1 s and 1.5 s round timers in `sendDiscoveryScans()` aren't stored anywhere either. Also, a socket whose bind fails is never added to `scanSockets`, so nothing closes it.

**Evidence:**

```ts
// src/main.ts:456-467 and 500-502
	private async scanDevices(): Promise<DeviceInfo[]> {
		this.log('debug', '[Scan] Starting UDP broadcast device discovery')
		const scanner = new CommunicationManager({
			...
		})

		try {
			await scanner.scanNetwork()
...
		} finally {
			scanner.disconnect()
		}
```

```ts
// src/main.ts:586-591 (destroy() -> destroyConnection() only reaches this.comm)
	private destroyConnection(): void {
		if (this.comm) {
			this.comm.disconnect()
			this.comm = undefined
		}
		this.connectedHost = undefined
```

**Fix:** keep the active scanner on the instance and stop it from `destroy()`, and let `disconnect()` stop a scan that is running.

1. Keep the scanner in a field and disconnect it from `destroy()`:

   ```ts
   private scanner: CommunicationManager | undefined
   // scanDevices(): this.scanner = scanner
   // finally: scanner.disconnect(); if (this.scanner === scanner) this.scanner = undefined
   // destroy(): this.scanner?.disconnect(); this.scanner = undefined
   ```

2. In `CommunicationManager`, store the scan timeout handle, every `setTimeout(sendScan, 1000)` and 1500 ms handle, and the scan's `finish` callback on the instance. In `disconnect()`, set a `scanAborted` flag, clear those timers, close the sockets and call `finish()`. Start `sendScan` with `if (this.scanAborted) return`. The guard is required: without it, a pending `sendScan` timer calls `sock.send()` on a closed socket, which throws `ERR_SOCKET_DGRAM_NOT_RUNNING` inside a timer and crashes the module.
3. Push each socket into `scanSockets` when it is created, not in its bind callback.

### L2: Short follow-up timers after button presses keep running after the connection is disabled

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:814-816`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L814-L816), [`src/main.ts:1088-1090`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L1088-L1090), [`src/main.ts:1129-1132`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L1129-L1132), [`src/main.ts:1281-1283`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L1281-L1283)

**What goes wrong:** Nothing visible changes, but `destroy()` doesn't stop everything the module started. v1.0.1 adds several one-shot timers after button presses:

- the AUTO highlight release (800 ms);
- the Key Type re-query after PIP/LUMA/CHROMA/DSK keys (300 ms and 400 ms);
- the T-Bar read-back check (800 ms, then up to 1 s of 50 ms polling);
- the WIPE style read-back (250 ms, [`src/actions.ts:715-717`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L715-L717) and [`src/actions.ts:763-765`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L763-L765)).

The connect-time state query also waits 150 to 700 ms between sends. If a user presses AUTO or T-Bar and disables the connection straight away, these fire after `destroy()`. Most find no connection and return, but the AUTO timer still calls `checkFeedbacks('auto_active')`, and the T-Bar check logs "[T-Bar] No fresh 0x0110 reply" after the connection is gone. The v1.0.0 review's L1 (the 400 ms flash timer) was the same kind of issue and is fixed; these timers are new since then.

**Why it happens:** Each timer is a bare `setTimeout(...)` whose handle isn't kept. `destroy()` clears only the flash timer and, through `destroyConnection()`, the blink timer and the heartbeat.

**Fix:** route these timers through a small helper that records the handles, and clear them in `destroy()`. In the awaited sleeps (`queryDeviceState`, `sendQueryRound`, `waitFreshStateReport`), stop the loop when `!this.instanceAlive`.

```ts
private pendingTimers = new Set<NodeJS.Timeout>()
private later(fn: () => void, ms: number): void {
	const t = setTimeout(() => {
		this.pendingTimers.delete(t)
		fn()
	}, ms)
	this.pendingTimers.add(t)
}
// destroy(): for (const t of this.pendingTimers) clearTimeout(t); this.pendingTimers.clear()
```

### L3: On a SHARK H4K the PIP1 Adjust preset picks IN2 and the LUMA Adjust preset sends Clip 50

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:241-246`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/presets.ts#L241-L246), [`src/presets.ts:264-270`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/presets.ts#L264-L270)

**What goes wrong:** On a SHARK H4K, the "PIP1 Adjust" preset sets the PIP source to IN2, not IN1, because in the H4K source list id 1 is IN2 (IN1 is 0). The "LUMA Adjust" preset sends Clip = 50, but on the H4K the action's Clip option is a dropdown with Off (0), On (1) and Curve (2), so the action editor shows an invalid Clip value and the switcher receives 50.

**Why it happens:** The preset options are hard-coded for the S6 PLUS tables. The actions themselves already use per-protocol defaults (`defaultSourceId()`, and the H4K Clip dropdown at [`src/actions.ts:217-229`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L217-L229)).

**Fix:** build these preset options from the active protocol: `defaultSourceId(family.pipSources)` for `source`, and for `clip` 0 on the H4K (the dropdown) and 50 on the S6 PLUS (the slider). Leave out options the protocol doesn't have.

### L4: Two switchers of the same model show as identical entries in the Device dropdown

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:444-451`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L444-L451)

**What goes wrong:** At a site with two SHARK S6 PLUS units, at 192.168.1.10 and 192.168.1.11, the Device dropdown lists "SHARK S6 PLUS" twice with no IP address. The user can't tell which entry is which switcher, and may pick the wrong one and switch the wrong production output.

**Why it happens:** `buildDeviceChoices()` labels each entry with the model's display name only.

**Fix:** add the IP address to the label, for example ``label: `${resolveDeviceModel(device.model, device.productType)} (${device.host})` ``.

### L5: The help page does not list the SHARK S5, H5, H4K or H4K PLUS that this release supports

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:5-9`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/companion/HELP.md#L5-L9), [`companion/manifest.json:28`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/companion/manifest.json#L28)

**What goes wrong:** An H4K owner opens the module's help in Companion and sees only "SHARK S6 (VS0605)", "SHARK S6 PLUS (VS0617)" and "other models may work". They can't tell that the H4K and H4K PLUS are supported, or that the H4K gets a reduced action set (4 inputs, 1 PIP, 3 wipes, no Stream). The manifest keywords list only "SHARK S6", so searching the connection list for "H4K" finds nothing.

**Why it happens:** v1.0.1 adds profiles for the SHARK S5 (VS0405E), SHARK H5 (VS0405EH), SHARK H4K PLUS and SHARK H4K ([`src/devices/profiles.ts:36-94`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/devices/profiles.ts#L36-L94)), but `HELP.md` and the manifest `keywords` weren't updated.

**Fix:** list every supported model in HELP.md under "Supported devices" (SHARK S6, S6 PLUS, S5, H5, H4K, H4K PLUS), with a short note on what the H4K lacks (Stream, PIP2/PIP3, XLR/Line In, All AFV, Audio Reset). Add "H4K", "SHARK H4K", "SHARK S5" and "SHARK H5" to the manifest `keywords`.

### L6: Switcher reports and field writes still flood the log at info level, and H4K packets are handled twice (v1.0.0 L11 partly fixed)

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:618-621`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L618-L621), [`src/main.ts:721-724`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L721-L724), [`src/main.ts:887`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L887), [`src/main.ts:946`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L946), [`src/main.ts:1036-1039`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L1036-L1039), [`src/communication.ts:874-884`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L874-L884)

**What goes wrong:** The packet hex dumps and heartbeat lines from v1.0.0 L11 are now at debug, but while the connection runs, every state report from the switcher still logs "[Report 0x0110] PGM=…" and "[Switch] PGM=…" at info level. That can be many lines per second while someone moves the physical T-Bar. Each "LUMA Adjust" or "CHROMA Adjust" press logs one "[Set] …" info line per field, up to about 17. On an H4K reached by a typed IP, every 5 s heartbeat reply logs "[Report] Unhandled cmd=0x0001" at info. H4K reports are also processed twice, so each "[Report] …" line appears twice. Real warnings are hard to find.

**Why it happens:** These hot-path lines still use `info`. For the H4K protocol, `handleDeviceData()` parses the payload again, so a report packet (type 2) goes through both the report handler and the general data handler into `syncSwitchState()`.

**Fix:** log the `[Report 0x0110]`, `[Switch]`, `[Set]`, `[Report] <key>` and `[Query Reply]` lines and the H4K "Unhandled cmd" line at `debug`. Skip the data callback for packets already handed to the report callback (`else this.onDataCallback?.(…)`), or ignore type-2 packets in `handleDeviceData()`.

### L7: The orange Last Action (Flash) can light the wrong button, or none, when two actions run at the same time

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:1158-1170`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L1158-L1170)

**What goes wrong:** A user puts two actions on one button, for example "Source (PGM / PVW)" PGM1 and "Transition WIPE1", or presses two buttons quickly. Companion runs both actions at once. The first action's send can finish while the second action's key is current, so the "Last Action (Flash)" feedback flashes the second button. Then the first action's cleanup clears the key, and the second button never flashes for its own send. Only the orange flash is wrong; device control is unaffected.

**Why it happens:** The action wrapper stores the current flash key in one shared field (`pendingFlashKey`) before it awaits the action. The send functions read that field after the UDP send completes ([`src/main.ts:622-623`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/main.ts#L622-L623)), and the wrapper's `finally` resets it to `undefined`, which can clear another action's key.

**Fix:** don't keep the flash key in shared state. Pass it explicitly, for example `sendProtocolField(cmdKey, field, value, label, flashKey)` / `sendToDevice(id, params, flashKey)`, or have the wrapper call `self.flash(flashKeyFor(id, event.options))` itself after the action succeeds.

## 💡 Nice to Have

### N1: Fix action IDs and names now, before the first publish makes them permanent

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:929`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L929), [`src/actions.ts:772-774`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L772-L774), [`src/actions.ts:651-654`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/actions.ts#L651-L654)

**What goes wrong:** Small naming problems users will see. The "Transition MIX / DIP" action also offers FREEZE, so users looking for Freeze won't find it by name. "LOGO Select" lists "Logo 0" … "Logo 7", where users expect 1-based names. The internal action ID `audio_mic_pregate` misspells Pre-Gain. Once published, action IDs are stored in every user's buttons, and renaming one later needs an upgrade script.

**Fix:** rename the ID to `audio_mic_pregain` (and update the preset IDs and `actionId` references in [`src/presets.ts:578-586`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/presets.ts#L578-L586)), rename the action to "Transition MIX / DIP / FREEZE", and use ``label: `Logo ${n + 1}` ``. Do it in the resubmission, so no upgrade script is ever needed.

### N2: The Last Action (Flash) key field offers variables but does not resolve them

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:301-311`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/feedbacks.ts#L301-L311)

**What goes wrong:** The "Action key" field of the "Last Action (Flash)" feedback shows the variable picker. If a user builds the key from a variable, for example `set_source|source=$(internal:custom_src)`, the button never flashes, because the text is compared literally.

**Why it happens:** In API 1, `useVariables: true` only adds variable suggestions to the field. The callback reads the option without resolving the variables.

**Fix:** either remove `useVariables: true`, or make the callback async and resolve the text with `const key = await context.parseVariablesInString(String(feedback.options.key ?? ''))`.

### N3: Feedback dropdowns and action descriptions show SHARK S6 PLUS ranges and raw protocol codes on a SHARK H4K

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:36-46`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/feedbacks.ts#L36-L46), [`src/feedbacks.ts:68-78`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/feedbacks.ts#L68-L78), [`src/feedbacks.ts:138-145`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/feedbacks.ts#L138-L145)

**What goes wrong:** On an H4K, "PGM Source Active (Red)" and "PVW Source Active (Green)" offer PGM5/PGM6 and PVW5/PVW6, which never light because the H4K has 4 inputs. "WIPE Mode Active (Green)" offers WIPE4, but the H4K has 3 wipes. Action descriptions read "LUMA Fill Source (0-7)" / "LUMA Key Source (0-7)" while the H4K dropdown has 4 entries, and "Transition WIPE1" is described as "Set WIPE1 style (0x0020, No.1) and press WIPE1 (0x0010, Key_val=29)", which shows internal protocol codes to users.

**Why it happens:** The feedback choices are hard-coded lists, while the actions already build theirs from the protocol's input and wipe counts. Several action descriptions hard-code S6 PLUS ranges or embed command codes.

**Fix:** build the PGM/PVW feedback choices from `family.inputCount` (plus the two Pattern entries) and the WIPE choices from `family.wipeCount`, as the actions already do. Write descriptions without protocol hex codes or fixed ranges, for example "Select the LUMA key source".

### N4: Leftover unused code, a non-null assertion and a double cast (v1.0.0 N1 partly addressed)

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/communication.ts:364-404`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L364-L404), [`src/communication.ts:579`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L579), [`src/commandHandler.ts:22-87`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/commandHandler.ts#L22-L87)

**What goes wrong:** Users see no difference. v1.0.1 typed the report path as the v1.0.0 review's N1 asked, but some leftovers remain, and the H4K refactor added more:

- `this.discoverySocket!` is still used at [`src/communication.ts:579`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/communication.ts#L579), and [`src/feedbacks.ts:309`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/src/feedbacks.ts#L309) casts with `as unknown as`.
- `sendCommandWithCallback()` and `send()` are never called, nor are the `DeviceCommands` entries `PGM_PVW_CUT`, `GET_SWITCH_STATE`, `GET_INPUT_STATUS` and `GET_VERSION`, or `hexOf()` in `src/debug.ts`.
- The exported `PGM_KEY_VALUES`, `PVW_KEY_VALUES`, `PATTERN_KEY_VALUES`, `TRANSITION_KEY_VALUES`, `FUNCTION_KEY_VALUES`, `WIPE_KEY_VALUES` and `SHORTCUT_KEY_VALUES` tables in `src/commandHandler.ts` hold only the S6 PLUS key codes and are never imported; the real codes come from the key maps in `src/devices/protocols.ts`. A future maintainer may read them as the module's key codes.
- Each TRANSITIONS preset in `src/presets.ts` (lines 303-397) declares a `flashKey` that is never read.

**Fix:** use the local socket variable instead of `this.discoverySocket!`, read `feedback.options.key` without the double cast, and delete the unused methods, constants, key tables and the `flashKey` field.

## 🔮 Next Release

### NR1: Plan the move to @companion-module/base v2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-avmatrix-switcher/blob/9f9e26e8803abd98003191f6d0b240b7abefd023/package.json)

**What goes wrong:** No visible problem today. The module is on `@companion-module/base` ~1.14.1 (Companion 4.2+). Staying on v1 means no expression support in options and none of the newer API (v2.0 for Companion 4.3+, v2.1 for Companion 5.0+). The CHANGELOG already plans this as NR1.

**Fix:** in a later release, migrate to `@companion-module/base` v2.x, following the Companion v1-to-v2 migration guide (ESM entry point, expression-aware options, Node 22). If the dropdown IDs are made device-independent before the first publish ([M2](#m2-buttons-built-under-one-device-profile-press-different-keys-after-the-profile-changes)), the v2 move needs far fewer upgrade-script migrations.

## 📝 Additional Notes

- This is still the module's first release: `v1.0.0` was reviewed on 2026-10-30 but never published, so there is no published diff. The whole module was reviewed again at `v1.0.1`, every finding is classified 🆕 NEW, and this review also verifies the fixes for the [v1.0.0 review](review-avmatrix-switcher-v1.0.0-20261030-090507.md).
- **Fixed from the v1.0.0 review:** C1 (`.yarnrc.yml` hardening), H1 (awaited UDP sends), H2 (a typed Target IP is now probed and fails cleanly), H3 (the start-up scan only picks a device on first setup), M2, M3, M4, M5, M6, L1, L2, L3, L4, L5, L6, L7, L8, L9 (config tooltips) and L10 (`legacyIds` removed).
- **Partly fixed:** v1.0.0 M1 (scan sockets) continues as [L1](#l1-disabling-the-connection-during-a-device-scan-leaves-the-scan-sockets-broadcasting-v100-m1-only-partly-fixed), L11 (info-level logging) as [L6](#l6-switcher-reports-and-field-writes-still-flood-the-log-at-info-level-and-h4k-packets-are-handled-twice-v100-l11-partly-fixed), and N1 (loose typing, unused code) as [N4](#n4-leftover-unused-code-a-non-null-assertion-and-a-double-cast-v100-n1-partly-addressed). v1.0.0 NR1 is carried forward as [NR1](#nr1-plan-the-move-to-companion-modulebase-v2x).
- **Kept by the maintainer:** v1.0.0 N2 (zero-width characters to order the preset categories) is intentionally unchanged, with the reason given in the CHANGELOG. It was a Nice to Have, so it is not raised again.
- `validate-template.ps1 -RunBuild` passed `yarn install --immutable`, `yarn package` and `yarn lint`, and the first-release manifest check is clean. Apart from [H1](#h1-action-descriptions-option-labels-code-comments-and-the-changelog-are-in-chinese), the module matches the API 1 TypeScript template.
