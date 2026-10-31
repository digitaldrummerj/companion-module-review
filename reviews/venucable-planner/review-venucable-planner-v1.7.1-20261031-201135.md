# Review: venucable-planner v1.7.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-venucable-planner` |
| **Scope** | `tag` (first release: no previous tag, so there is no diff and the whole module was reviewed) |
| **Version** | v1.7.1 |
| **Release** | New module — never published |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review commit** | [`5f0a8eb`](https://github.com/bitfocus/companion-module-venucable-planner/commit/5f0a8ebcc1487770efa844de362ed73555312d71) |
| **Build** | `yarn install --immutable` + `yarn package` passed |
| **Date** | 2026-10-31 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When an API 1 module's `init()` or `configUpdated()` throws, Companion only logs the error. It doesn't set an error status of its own or restart the module, so the user keeps seeing the last status the module set ("Connecting to VenuCable") | `@companion-module/base` 1.12.1 `dist/module-api/base.js` only logs and rethrows the error to Companion; what Companion itself does with it was not checked | [L2](#l2-a-mistyped-relay-address-testing-only-leaves-the-connection-stuck-on-connecting-and-stops-the-clock-variables) |
| A2 | For an API 1 module, Companion does not rewrite `$(<label>:...)` references inside preset definitions the module has already registered when the connection is renamed, and the rename reaches the module through `configUpdated()` | general knowledge of Companion's v1 preset handling; not verifiable from the module or the base package | [L3](#l3-presets-dragged-in-after-renaming-the-connection-still-point-at-the-old-connection-name) |

## 📋 Issues

### Non-blocking

- [ ] [L1: With no internet, the connection stays on Connecting to VenuCable and never says the relay is unreachable](#l1-with-no-internet-the-connection-stays-on-connecting-to-venucable-and-never-says-the-relay-is-unreachable)
- [ ] [L2: A mistyped Relay address (testing only) leaves the connection stuck on Connecting and stops the clock variables](#l2-a-mistyped-relay-address-testing-only-leaves-the-connection-stuck-on-connecting-and-stops-the-clock-variables)
- [ ] [L3: Presets dragged in after renaming the connection still point at the old connection name](#l3-presets-dragged-in-after-renaming-the-connection-still-point-at-the-old-connection-name)
- [ ] [L4: Config fields use the deprecated isVisible functions instead of isVisibleExpression](#l4-config-fields-use-the-deprecated-isvisible-functions-instead-of-isvisibleexpression)
- [ ] [L5: Upgrade scripts are passed inline instead of from a dedicated upgrades file](#l5-upgrade-scripts-are-passed-inline-instead-of-from-a-dedicated-upgrades-file)

## 🟢 Low

### L1: With no internet, the connection stays on Connecting to VenuCable and never says the relay is unreachable

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/relay.js:111-130`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/relay.js#L111-L130), [`src/main.js:126-128`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L126-L128)

**What goes wrong:** A user picks "Through VenuCable (any computer, needs internet)" on a Companion machine with no internet, or on a network that blocks `wss://app.venucable.com`. The connection status stays on "Connecting to VenuCable" for as long as the module keeps retrying in the background. The module's own "Can't reach VenuCable - retrying" message never appears, so nothing tells the user the relay is unreachable or that "Same computer as VenuCable" is the offline option. Users whose relay connected at least once and then dropped do see the message.

**Why it happens:** When the relay socket closes, the module reports "relay down" only if that socket had opened before. A connection that never opened skips that report, so the status code that sets "Can't reach VenuCable - retrying" is never reached.

**Fix:** report the relay as down once on a failed first attempt too (for example when the first retry is scheduled), so the status changes to "Can't reach VenuCable - retrying". The retry behaviour can stay as it is.

```js
if (was || this.tries === 1) this.emit('relay', false)
```

### L2: A mistyped Relay address (testing only) leaves the connection stuck on Connecting and stops the clock variables

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/relay.js:66-71`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/relay.js#L66-L71), [`src/main.js:7-16`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L7-L16)

**What goes wrong:** A tester types `app.venucable.com/link` (without `wss://`) into "Relay address (testing only)" and saves. The connection stays on "Connecting to VenuCable" for good, with no log line explaining why. If this happens when the module starts, the clock variables (`$(venucable:clock)`, `$(venucable:clock_short)`) and the live countdown variables never update, and correcting the address later doesn't bring them back. The field is marked testing-only, so normal users are unlikely to hit this.

**Why it happens:** The relay address is turned into a URL without any error handling, so a malformed address throws while the link is starting, after the status was already set to "Connecting to VenuCable". At startup the throw also ends `init()` before the 1-second clock timer is created, and only `init()` creates that timer.

**Fix:** check the relay address before connecting. On a bad address, set a "bad config" status with a clear message and don't connect. Also consider creating the 1-second timer before starting the link in `init()`, so a failed start can't stop the clock.

```js
try {
	new URL(this.relayUrl())
} catch {
	this.updateStatus(InstanceStatus.BadConfig, 'Relay address must start with wss://')
	return
}
```

### L3: Presets dragged in after renaming the connection still point at the old connection name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/definitions.js:561-562`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/definitions.js#L561-L562), [`src/main.js:12`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L12), [`src/main.js:23-26`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L23-L26)

**What goes wrong:** A user renames the connection from "venucable" to "venucable2" and then drags a preset from the Presets tab. The preset's text still uses `$(venucable:...)`, so the plan name, countdown and segment text on that button stay blank until the module restarts.

**Why it happens:** The presets put the connection's current name into their button text when they are built, and the module builds them only once, in `init()`. `configUpdated()`, which Companion calls when the connection is renamed, doesn't rebuild them.

**Fix:** rebuild the presets in `configUpdated()` so new presets always use the current name.

```js
async configUpdated(config) {
	this.config = config
	this.setPresetDefinitions(presets(this))
	await this.startLink()
}
```

### L4: Config fields use the deprecated isVisible functions instead of isVisibleExpression

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:29`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L29), [`src/main.js:58`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L58), [`src/main.js:70`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L70), [`src/main.js:90`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L90), [`src/main.js:99`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L99)

**What goes wrong:** Users see nothing different today: "Pairing key" and "Relay address (testing only)" still hide in "Same computer" mode, and "Port" and "Extra allowed web addresses (testing only)" still hide in "Through VenuCable" mode. The function form of `isVisible` is deprecated since API 1.12 and removed in API 2.0, so these fields will need rework when the module moves to v2.

**Why it happens:** The four fields decide their visibility with JavaScript functions (`isVisible: (o) => o.mode !== 'local'` and the `local` helper) instead of the expression strings Companion now prefers.

**Fix:** replace each function with an expression, then remove the `local` helper.

```js
isVisibleExpression: "$(options:mode) != 'local'", // key, relay
isVisibleExpression: "$(options:mode) == 'local'", // port, origins
```

### L5: Upgrade scripts are passed inline instead of from a dedicated upgrades file

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:297`](https://github.com/bitfocus/companion-module-venucable-planner/blob/5f0a8ebcc1487770efa844de362ed73555312d71/src/main.js#L297)

**What goes wrong:** Users see no effect today: this is a first release and there are no upgrade scripts yet. Without a dedicated upgrades file like the template's, the first real upgrade script (for example after renaming an action option) is likely to be added inline in `main.js`, where it is harder to maintain and review.

**Why it happens:** The entry point passes an empty array straight to `runEntrypoint`, and there is no `src/upgrades.js`.

**Fix:** add `src/upgrades.js` as in the v1 JS template and pass its list to `runEntrypoint`.

```js
// src/upgrades.js
export const UpgradeScripts = []

// src/main.js
import { UpgradeScripts } from './upgrades.js'
runEntrypoint(VenuCableInstance, UpgradeScripts)
```
