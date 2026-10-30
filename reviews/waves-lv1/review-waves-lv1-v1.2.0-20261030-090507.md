# Review — waves-lv1 v1.2.0 (follow-up)

| | |
| --- | --- |
| **Module** | [companion-module-waves-lv1](https://github.com/bitfocus/companion-module-waves-lv1) |
| **Scope** | `tag` — changes in `v1.1.0..v1.2.0`, plus a check of the prior review's findings |
| **Version** | v1.2.0 (`7711f3a`) |
| **Release** | Update — last published v1.1.0 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Prior review** | [review-waves-lv1-v1.0.3-20260614-220418.md](review-waves-lv1-v1.0.3-20260614-220418.md) |
| **Reviewed** | 2026-10-30 |

This is a follow-up to the v1.0.3 review. v1.2.0 adds eMotion LV1 v17 support: Monitor buses, internal routing, stereo balance, and an experimental second "Companion I/O" connection that reads the I/O patch. `yarn install`, `yarn package` and `yarn lint` all pass. The four findings from the v1.0.3 review are still open; they are listed under [📝 Additional Notes](#-additional-notes).

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion restarts a crashed module process, so after the crash the user sees the connection go to an error/restarting state rather than Companion itself going down | General knowledge of Companion's process-per-connection supervision; `@companion-module/base` 1.12.1 installs no `uncaughtException`/`unhandledRejection` handler (checked). Companion's host code not checked | [H1](#h1-turning-off-read-io-patch-or-changing-the-lv1-ip-while-the-desk-is-unreachable-crashes-the-module) |
| A2 | The module's Node runtime uses the default `--unhandled-rejections=throw`, so an unhandled promise rejection (the handshake-window variant of H1) also ends the module process | Node 22 default; base 1.12.1 registers no `unhandledRejection` handler. How Companion launches the module process not checked | [H1](#h1-turning-off-read-io-patch-or-changing-the-lv1-ip-while-the-desk-is-unreachable-crashes-the-module) |
| A3 | Companion does not redraw a connection's feedbacks when the module clears its internal state; only `checkFeedbacks()` (or possibly a later `setFeedbackDefinitions`) re-runs the feedback callbacks | How v1 feedback re-evaluation is generally triggered; not confirmed from the base package whether the host rechecks feedbacks after `setFeedbackDefinitions` | [L1](#l1-phantom-polarity-route-and-io-patch-buttons-can-keep-showing-the-previous-desks-state-after-switching-lv1) |
| A4 | When the LV1 restarts on a new TCP port after a mixer-configuration change, the old port stops accepting connections | The module's own comment on `rediscoverPort()` ("the LV1 restarts and gets a fresh port") | [L2](#l2-io-patch-variables-freeze-after-the-lv1-comes-back-on-a-new-port) |

## 📋 Issues

### Blocking

- [ ] [C1: `.prettierignore` differs from the template (`/LICENSE` instead of `/LICENSE.md`)](#c1-prettierignore-differs-from-the-template-license-instead-of-licensemd)
- [ ] [H1: Turning off Read I/O patch or changing the LV1 IP while the desk is unreachable crashes the module](#h1-turning-off-read-io-patch-or-changing-the-lv1-ip-while-the-desk-is-unreachable-crashes-the-module)
- [ ] [H2: `.github/workflows/companion-module-checks.yaml` differs from the template](#h2-githubworkflowscompanion-module-checksyaml-differs-from-the-template)
- [ ] [H3: `.github/workflows/node.yaml` differs from the template](#h3-githubworkflowsnodeyaml-differs-from-the-template)

### Non-blocking

- [ ] [L1: Phantom, polarity, route and I/O-patch buttons can keep showing the previous desk's state after switching LV1](#l1-phantom-polarity-route-and-io-patch-buttons-can-keep-showing-the-previous-desks-state-after-switching-lv1)
- [ ] [L2: I/O patch variables freeze after the LV1 comes back on a new port](#l2-io-patch-variables-freeze-after-the-lv1-comes-back-on-a-new-port)
- [ ] [L3: Console version from the previous LV1 is kept after pointing the connection at a different desk](#l3-console-version-from-the-previous-lv1-is-kept-after-pointing-the-connection-at-a-different-desk)
- [ ] [L4: Stereo balance variable shows 0.00 before the desk has reported a balance](#l4-stereo-balance-variable-shows-000-before-the-desk-has-reported-a-balance)
- [ ] [L5: New Internal route fields use the deprecated isVisible function](#l5-new-internal-route-fields-use-the-deprecated-isvisible-function)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.prettierignore` differs from the template (`/LICENSE` instead of `/LICENSE.md`)

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW to this review — the file is unchanged since v1.0.0; the prior reviews did not check it
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/.prettierignore#L2)

**What goes wrong:** The module's `.prettierignore` does not match the API 1 TypeScript template. Template files must match byte-for-byte so every module behaves the same in CI and when someone else troubleshoots it later.

**Why it happens:** Line 2 was changed from the template's `/LICENSE.md` to `/LICENSE`.

**Evidence:**

```diff
# diff companion-module-template-ts-v1/.prettierignore .prettierignore
2c2
< /LICENSE.md
---
> /LICENSE
```

**Confirm by:** `diff companion-module-template-ts-v1/.prettierignore .prettierignore`

**Fix:** copy the template's `.prettierignore` exactly.

## 🟠 High

### H1: Turning off Read I/O patch or changing the LV1 IP while the desk is unreachable crashes the module

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:361-366`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L361-L366), [`src/main.ts:190-207`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L190-L207), [`src/osc-tcp.ts:69-71`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L69-L71), [`src/osc-tcp.ts:101-118`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L101-L118)

**What goes wrong:** A user ticks the new "Read I/O patch (experimental, eMotion LV1 v17+)" checkbox. The LV1 is then off, rebooting or on the wrong IP, so both connections keep retrying. The user saves the connection settings, for example correcting "LV1 IP (override)" from 192.168.1.50 to 192.168.1.60, or unticking "Read I/O patch". About 3 s later the module process dies with "Unhandled 'error' event", and the connection goes to a crashed/restarting state instead of using the new settings. If the old address does answer, the stray I/O client stays connected instead: the LV1 shows an extra "Companion I/O" recorder connection that nothing can close until the module restarts. The same crash happens if the settings are saved during the I/O client's 3 s handshake wait. Users who never tick "Read I/O patch" are not affected by the crash.

**Why it happens:** When the settings change, the module stops the old I/O client by removing all of its event listeners (including its only `'error'` listener) and then disconnecting it. Disconnecting destroys the current socket, but it does not cancel the "reconnect in 3 s" timer queued by the previous failed attempt, and `connect()` resets the "destroyed" flag. When that timer fires, the old client opens a new socket to the old address. When that connect fails, the client emits `'error'` with no listener attached, and Node treats that as an uncaught exception. The reconnect timer was already there; the second client and the listener removal are new in this release, and together they turn it into a crash.

**Evidence:**

```ts
// src/main.ts:361-366
	private stopIoPatchClient(): void {
		if (!this.ioOsc) return
		this.ioOsc.removeAllListeners()
		this.ioOsc.disconnect()
		this.ioOsc = null
	}
// src/main.ts:190-207 (configUpdated)
		const restart =
			this.config.selected !== config.selected ||
			this.config.host !== config.host ||
			this.config.port !== config.port ||
			!!this.config.readIoPatch !== !!config.readIoPatch
		...
		if (restart) {
			if (this.osc) {
				this.osc.disconnect()
				this.osc = null
			}
			this.stopIoPatchClient()
```

```ts
// src/osc-tcp.ts:69-71, 89, 101-118
	connect(): void {
		if (this.socket) return
		this.destroyed = false
...
		sock.on('error', (err) => this.emit('error', err))
...
		sock.on('close', (hadError) => {
			this.connected = false
			this.socket = null
			this.rxBuf = Buffer.alloc(0)
			this.emit('close', { hadError })
			if (this.autoReconnect && !this.destroyed) {
				setTimeout(() => this.connect(), this.reconnectMs)
			}
		})
...
	disconnect(): void {
		this.destroyed = true
		this.autoReconnect = false
		if (this.socket) this.socket.destroy()
	}
```

```text
// verifier repro against the built dist/osc-tcp.js (127.0.0.1:1, reconnectMs 300; stop called while the reconnect timer is pending)
err ECONNREFUSED
stopping during reconnect wait
node:events:497
      throw er; // Unhandled 'error' event
Error: connect ECONNREFUSED 127.0.0.1:1
```

**Confirm by:** open [`src/osc-tcp.ts:107`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L107): the reconnect `setTimeout` is never stored or cleared, and `connect()` at [`src/osc-tcp.ts:71`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L71) sets `destroyed` back to `false`. Then open [`src/main.ts:363`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L363), where `removeAllListeners()` drops the only `'error'` listener before `disconnect()`.

**Fix:** make `disconnect()` cancel every pending timer, and never leave a discarded client without an `'error'` listener. Store the reconnect timer and clear it in `disconnect()`, have the timer callback return early once the client is destroyed, and clear the handshake wait timer too. The same fix also stops the main connection from reconnecting to the old address after a settings change.

```ts
// osc-tcp.ts
private reconnectTimer: NodeJS.Timeout | null = null
// in the 'close' handler
this.reconnectTimer = setTimeout(() => {
	this.reconnectTimer = null
	if (!this.destroyed) this.connect()
}, this.reconnectMs)
// in disconnect()
if (this.reconnectTimer) clearTimeout(this.reconnectTimer)
this.reconnectTimer = null

// main.ts stopIoPatchClient()
this.ioOsc.removeAllListeners()
this.ioOsc.on('error', () => {}) // a late socket error must never become an unhandled 'error'
this.ioOsc.disconnect()
```

### H2: `.github/workflows/companion-module-checks.yaml` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW to this review — the file is unchanged since v1.0.0; the prior reviews did not check it
- **File:** [`.github/workflows/companion-module-checks.yaml:9-10`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/.github/workflows/companion-module-checks.yaml#L9-L10)

**What goes wrong:** The module's copy of the Companion module-check workflow does not match the template. Template files must match exactly, so CI behaves the same in every module repo.

**Why it happens:** The template's repository guard (template line 10) is removed, so the `check` job goes straight from `name: Check module` to `permissions:`.

**Evidence:**

```diff
# diff companion-module-template-ts-v1/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml
10,11d9
<     if: ${{ !contains(github.repository, 'companion-module-template-') }}
<
```

**Confirm by:** `diff companion-module-template-ts-v1/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml`

**Fix:** copy the template file exactly.

### H3: `.github/workflows/node.yaml` differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW to this review — the file is unchanged since v1.0.0; the prior reviews did not check it
- **File:** [`.github/workflows/node.yaml:20-27`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/.github/workflows/node.yaml#L20-L27)

**What goes wrong:** The module's Node CI workflow does not match the template, so its CI runs different steps than every other module built from the API 1 template.

**Why it happens:** Three parts were changed:

- Line 20 has a reworded comment ("This should match the version in the manifest.json runtime field").
- Lines 24-27 drop the template's "Prepare Environment (For template repository)" step (with `CI: false`) and rename its "Prepare module" step to a single `Install dependencies: yarn install` step; the `run: |` blocks are also collapsed to one-line `run:` commands.
- The template's commented-out `test:` job (template lines 52-76) is removed.

**Evidence:**

```text
.github/workflows/node.yaml:20  found:    # This should match the version in the manifest.json runtime field
                                template: # This should match the version of Node.js you have defined in the manifest.json runtime field
.github/workflows/node.yaml:24-27  "Install dependencies: yarn install" in place of the template's
                                   "Prepare Environment (For template repository)" and "Prepare module" steps
template lines 52-76               commented-out test: job, missing from the module
```

**Confirm by:** `diff companion-module-template-ts-v1/.github/workflows/node.yaml .github/workflows/node.yaml`

**Fix:** copy the template file exactly.

## 🟢 Low

### L1: Phantom, polarity, route and I/O-patch buttons can keep showing the previous desk's state after switching LV1

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:189-232`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L189-L232)

**What goes wrong:** A button uses "Channel +48 V phantom ON" for Ch 3 and is lit while connected to LV1 A. The user edits the connection and picks LV1 B from the dropdown. The button can stay lit as "+48 V ON" for B's Ch 3, and "Channel +48 V state unknown" stays off. Phantom is only reported when it changes, so nothing from desk B corrects it. "Channel has an I/O patch (experimental)" can also stay lit if desk B never sends its I/O patch, and "Channel internally routed to destination" is not redrawn either (though desk B's channel list may correct it on connect). The module's own rule that unknown phantom "must render blank, never as off" is not kept across a host change.

**Why it happens:** When the host changes, the module wipes its stored channel, route and I/O-patch state, but it never asks Companion to re-check the feedbacks afterwards. The feedback definitions are refreshed earlier in `configUpdated()`, before the state is cleared.

**Fix:** after clearing state in the restart branch, redraw the feedbacks and blank the per-channel variables.

```ts
this.checkFeedbacks('routeAssigned', 'channelHasPatch', 'channelPolarity', 'channelPhantom', 'channelPhantomUnknown')
// or simply this.checkFeedbacks()
```

### L2: I/O patch variables freeze after the LV1 comes back on a new port

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:409-419`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L409-L419)

**What goes wrong:** With "Read I/O patch" ticked, the user switches the LV1 mixer configuration (for example 64ch to 80ch), and the desk restarts on a new TCP port. The main connection finds the new port (the log shows "Rediscovered … on port … — reconnecting") and goes back to OK. The second "Companion I/O" connection keeps retrying the old port every 3 s, and its errors only go to the debug log. `$(waves-lv1:in1_patch)`, `$(waves-lv1:io_patch_connections)` and the "Channel has an I/O patch (experimental)" feedback keep their old values, and the connection status gives no sign of it, until the user saves the connection settings again.

**Why it happens:** The port re-discovery only moves the main connection to the new port. The I/O-patch connection was started with the original port and is never told about the new one.

**Fix:** move the I/O-patch connection along with the main one, and log its repeated failures at `warn`.

```ts
this.osc.updateTarget(this.lastHost, match.port)
this.ioOsc?.updateTarget(this.lastHost, match.port)
```

### L3: Console version from the previous LV1 is kept after pointing the connection at a different desk

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:201-233`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L201-L233)

**What goes wrong:** A user connects to an eMotion LV1 v17 desk, then changes "LV1 IP (override)" to a v16 desk. Until the new desk reports its version, the module still treats it as v17, and `$(waves-lv1:console_version)` still shows the old version. Channel data from the v16 desk is decoded with the v17 layout in that window, so channel mute feedback, `*_pan` / `*_balance` / `*_stereo` and "Channel internally routed to destination" can show values the module only trusts on v17.

**Why it happens:** The restart branch of `configUpdated()` resets channels, routes and the detected mixer config, but not the stored console major version (`consoleMajor`), which gates the v17 decoding at [`src/main.ts:825`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L825).

**Fix:** reset the console version with the rest of the state.

```ts
this.consoleMajor = null
this.setVariableValues({ console_version: '' })
```

### L4: Stereo balance variable shows 0.00 before the desk has reported a balance

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:95`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/variables.ts#L95), [`src/variables.ts:172`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/variables.ts#L172), [`src/main.ts:1177`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L1177)

**What goes wrong:** After connecting, the new `$(waves-lv1:in1_balance)` variable shows "0.00" (centred) for every strip: mono strips, strips on a v16 console (which never sends balance), and strips before the desk reports a balance. A trigger or button text can't tell "centred" apart from "not known". The same release already shows blank for unknown phantom. `*_stereo` similarly reads "off" on v16 consoles, where the module never reads the stereo flag.

**Why it happens:** A new channel starts with `balance: 0`, and the variable code formats that number without checking whether the desk has reported it.

**Fix:** start `balance` as `null` (type `number | null`) and write `s.balance != null ? s.balance.toFixed(2) : ''`; consider `stereo: boolean | null` for the same reason.

### L5: New Internal route fields use the deprecated isVisible function

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/tracks.ts:471-492`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/tracks.ts#L471-L492)

**What goes wrong:** Nothing visible today: the "Destination number (1-based)", "Aux (FX / Monitor)" and "Aux (expression)" fields of the new "Channel: Internal route (Patch > Internal)" action and "Channel internally routed to destination" feedback show and hide correctly. They use the `isVisible` function form, which `@companion-module/base` 1.12.1 marks deprecated ("will be removed in 2.0.0 … Use isVisibleExpression instead"), so a later move to API 2 has three more fields to rewrite. Code quality only.

**Why it happens:** The new `buildRouteDestOptions()` hides the fields with `isVisible` functions plus `isVisibleData`.

**Fix:** use `isVisibleExpression`, which 1.12 already supports, and drop `isVisibleData`.

```ts
// destAux
isVisibleExpression: "$(options:destKind) == 'aux'",
// destAux_expr
isVisibleExpression: "$(options:destKind) == 'aux' && $(options:destAux) == '__custom'",
```

## 📝 Additional Notes

- `tsconfig.build.json`: `exclude` is `["node_modules/**"]`; the template also excludes `src/**/*spec.ts`, `src/**/__tests__/*` and `src/**/__mocks__/*`. Fine as long as the module builds — no change required.
- `tsconfig.json`: adds `compilerOptions.allowImportingTsExtensions` and widens `include` to `["src/**/*.ts", "tests/**/*.ts"]` (template `["src/**/*.ts"]`). Fine as long as the module builds — no change required.
- Prior review (v1.0.3) H1 is still open: when the LV1 accepts the TCP connection but never answers the handshake, the socket is left open and the status stays on Connecting with no reconnect ([`src/osc-tcp.ts:223-226`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L223-L226), [`src/osc-tcp.ts:247-250`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L247-L250); the main connection's error handler only logs). That review approved the release with it open.
- Prior review (v1.0.3) M1 is still open: the one-shot discovery started in `connectIfReady()` ([`src/main.ts:286`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/main.ts#L286)) is not registered with `cancelDiscovery()`, so deleting or reconfiguring the connection during that scan leaves the discovery socket open for up to 6 s.
- Prior review (v1.0.3) L1 is still open: `DiscoverHandle` is still declared twice ([`src/zdns-discover.ts:123-125`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/zdns-discover.ts#L123-L125)).
- Prior review (v1.0.3) L2 is still open: the handshake `catch` still emits the raw `unknown` value as the error ([`src/osc-tcp.ts:259`](https://github.com/bitfocus/companion-module-waves-lv1/blob/7711f3a5dec1971ecadd0e87c44b05d8a17f7274/src/osc-tcp.ts#L259)).
