# Re-review: utopianacademy-deckboy v1.0.8

| Field | Value |
| --- | --- |
| **Module** | [companion-module-utopianacademy-deckboy](https://github.com/bitfocus/companion-module-utopianacademy-deckboy) |
| **Scope** | `tag` |
| **Version** | v1.0.8 (`e0e5a01`) |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Previous review** | v1.0.7, reviewed 2026-10-30 (❌ Changes Required, blocking: H1) |
| **Release diff** | `v1.0.4..v1.0.8` (since the previous review: `v1.0.7..v1.0.8`) |
| **Language** | JavaScript (ESM) |
| **Build** | `yarn install --immutable` PASS, `yarn package` PASS. Lint N/A (the JS template has no lint script) |
| **Review date** | 2026-10-31 |

This is a follow-up to the v1.0.7 review. Since v1.0.7, the release adds one action, "Effect colour" (`fx_colour`), which uses Companion's colour picker, plus a test for it, a HELP.md line and the version bump. `src/main.js` is unchanged, so none of the v1.0.7 findings is fixed. All five are carried forward below. The new "Effect colour" action has no problems. The five findings from the v1.0.4 review are still fixed.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 5 delivers a `secret-text` config value only in the `secrets` argument of `init()` / `configUpdated()`, and never copies it into the config object | base 2.1.3 typings in the module's `node_modules` (`input.d.ts:366` says the value "will be in the secrets store, not the config store"; `base.d.ts:61,70` give both methods a separate `secrets` parameter); Companion's host code not read or run | [H1](#h1-the-new-passphrase-setting-is-never-sent-so-a-deckboy-with-a-passphrase-cannot-be-controlled) |
| A2 | When a passphrase is required but missing or wrong, Deckboy does not send a full DECKBOY status report in reply to STATUS (it answers nothing, or `ERR AUTH`) | the module's own comments in [`src/main.js:165-166`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L165-L166) and [`src/main.js:289-290`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L289-L290), and HELP.md ("must send it before anything is answered"); the device itself not checked | [M1](#m1-a-wrong-or-missing-passphrase-makes-the-connection-status-cycle-through-ok-bad-config-and-connection-failure-every-few-seconds) |

## 🔁 Since the last review (v1.0.7)

| ID (prior) | Finding | Status | Note |
| --- | --- | --- | --- |
| H1 | The Passphrase field is never sent to Deckboy | ❌ Not fixed | `src/main.js` is unchanged since v1.0.7; now [H1](#h1-the-new-passphrase-setting-is-never-sent-so-a-deckboy-with-a-passphrase-cannot-be-controlled) |
| M1 | A refused passphrase makes the connection drop and reconnect every few seconds | ❌ Not fixed | Unchanged; now [M1](#m1-a-wrong-or-missing-passphrase-makes-the-connection-status-cycle-through-ok-bad-config-and-connection-failure-every-few-seconds) |
| L1 | A passphrase refusal is logged only once per module run | ❌ Not fixed | Unchanged; now [L1](#l1-a-passphrase-error-that-comes-back-after-being-fixed-is-not-logged-again) |
| L2 | The Device field on the limiter and output-effects actions does not resolve variables | ❌ Not fixed | Unchanged; now [L2](#l2-the-device-field-on-the-limiter-and-output-effects-actions-does-not-resolve-variables) |
| N1 | Run dashboard tile silently does nothing for an invalid tile number | ❌ Not fixed | Unchanged; now [N1](#n1-run-dashboard-tile-silently-does-nothing-for-an-invalid-tile-number) |

## 📋 Issues

### Blocking

- [ ] [H1: The new Passphrase setting is never sent, so a Deckboy with a passphrase cannot be controlled](#h1-the-new-passphrase-setting-is-never-sent-so-a-deckboy-with-a-passphrase-cannot-be-controlled)

### Non-blocking

- [ ] [M1: A wrong or missing passphrase makes the connection status cycle through OK, Bad config and Connection failure every few seconds](#m1-a-wrong-or-missing-passphrase-makes-the-connection-status-cycle-through-ok-bad-config-and-connection-failure-every-few-seconds)
- [ ] [L1: A passphrase error that comes back after being fixed is not logged again](#l1-a-passphrase-error-that-comes-back-after-being-fixed-is-not-logged-again)
- [ ] [L2: The Device field on the limiter and output-effects actions does not resolve variables](#l2-the-device-field-on-the-limiter-and-output-effects-actions-does-not-resolve-variables)
- [ ] [N1: Run dashboard tile silently does nothing for an invalid tile number](#n1-run-dashboard-tile-silently-does-nothing-for-an-invalid-tile-number)

## 🟠 High

### H1: The new Passphrase setting is never sent, so a Deckboy with a passphrase cannot be controlled

- **Source:** 🔎 protocol reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW (H1 in the v1.0.7 review, not fixed)
- **File:** [`src/main.js:40-53`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L40-L53), [`src/main.js:86-93`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L86-L93), [`src/main.js:165-168`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L165-L168)

**What goes wrong:** An operator whose Deckboy has a Companion passphrase (for example `show2026`) types it into the new "Passphrase (only if one is set in Deckboy)" field and saves. The module never sends it. Deckboy refuses everything from that machine, and the connection status shows "Deckboy needs a passphrase — enter it in this connection's settings", even though the passphrase is filled in. No button action, tally, countdown or variable works, and correcting the field changes nothing. The passphrase support described in HELP.md's Security section, the main feature of this release, cannot work. Users whose Deckboy has no passphrase are not affected.

**Why it happens:** In `@companion-module/base` 2.x, the value of a `secret-text` config field is kept in a separate secrets store, not in the config object. Companion hands it to the module as a separate `secrets` argument: the third argument of `init(config, isFirstInit, secrets)` and the second of `configUpdated(config, secrets)`. The module ignores that argument and reads `this.config.passphrase`, which is always empty, so the `AUTH` line is never sent. The tests don't cover the `AUTH` path, so they don't catch this.

**Evidence:**

```js
// src/main.js:40-53
	async init(config) {
		this.config = config
		this.setActionDefinitions(buildActions(this))
		...
		this.openConnection()
	}

	async configUpdated(config) {
		this.config = config
		this.openConnection()
	}
```

```js
// src/main.js:86-93
			{
				type: 'secret-text',
				id: 'passphrase',
				label: 'Passphrase (only if one is set in Deckboy)',
				tooltip: 'Settings → Network → Companion passphrase. Leave empty if Deckboy has none.',
				width: 8,
				default: '',
			},
```

```js
// src/main.js:165-168
			// First, before anything else: with a passphrase set, Deckboy answers
			// nothing from another machine until it has heard this.
			const passphrase = String(this.config?.passphrase ?? '').replace(/[\r\n]+/g, '')
			if (passphrase) this.socket.send(`AUTH ${passphrase}\n`)
```

```ts
// node_modules/@companion-module/base/dist/module-api/base.d.ts:61,70 (base 2.1.3)
    abstract init(config: TManifest['config'], isFirstInit: boolean, secrets: TManifest['secrets']): Promise<void>;
    abstract configUpdated(config: TManifest['config'], secrets: TManifest['secrets']): Promise<void>;
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:363-366
/**
 * A text input field for secret values
 *
 * Available for config. Note: the value for this will be in the secrets store, not the config store.
```

`grep -rn secrets src test` finds nothing: the module never reads the `secrets` argument. `git diff v1.0.4..v1.0.8 -- src/main.js` shows that the passphrase field, the `AUTH` send and the `ERR AUTH` handling were all added in this release.

**Confirm by:** open [`src/main.js:40-53`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L40-L53) and [`src/main.js:167`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L167). Neither `init` nor `configUpdated` takes a `secrets` parameter, and the `AUTH` line reads `this.config?.passphrase`. `base.d.ts:61,70` and `input.d.ts:366` say `secret-text` values arrive in `secrets`, not in `config`.

**Fix:** keep the `secrets` argument Companion passes, and read the passphrase from it. Add a test that calls `init({...}, true, { passphrase: 'x' })` and checks that `AUTH x` is the first line sent on connect.

```js
async init(config, _isFirstInit, secrets) {
	this.config = config
	this.secrets = secrets ?? {}
	// ...
	this.openConnection()
}

async configUpdated(config, secrets) {
	this.config = config
	this.secrets = secrets ?? {}
	this.openConnection()
}

// in the 'connect' handler
const passphrase = String(this.secrets?.passphrase ?? '').replace(/[\r\n]+/g, '')
```

## 🟡 Medium

### M1: A wrong or missing passphrase makes the connection status cycle through OK, Bad config and Connection failure every few seconds

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW (M1 in the v1.0.7 review, not fixed)
- **File:** [`src/main.js:159-171`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L159-L171), [`src/main.js:208-218`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L208-L218), [`src/main.js:291-301`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L291-L301)

**What goes wrong:** An operator connects to a Deckboy that has a passphrase but leaves the Passphrase field empty or mistypes it (or fills it in correctly and hits [H1](#h1-the-new-passphrase-setting-is-never-sent-so-a-deckboy-with-a-passphrase-cannot-be-controlled)). The connection should stay on Bad config with the passphrase message. Instead it turns green (OK), then shows "Deckboy needs a passphrase — enter it in this connection's settings" (Bad config). At the default 250 ms poll it switches about 5 seconds later to "No STATUS reply from Deckboy — reconnecting" (Connection failure), and the log shows "Deckboy has not answered STATUS 3 times — reconnecting". It then reconnects, turns green again, and starts over. The useful passphrase message keeps being replaced by a misleading network-failure message, and each reconnect sends the passphrase again, which counts toward the "five wrong passphrases" limit in HELP.md.

**Why it happens:** The `connect` handler sets the status to OK before Deckboy has accepted the passphrase. The new `ERR AUTH` branch sets Bad config but leaves polling running and the "STATUS still pending" flag set; only a full status report clears that flag. The stall watchdog in `requestStatus()` therefore counts three unanswered STATUS requests, reconnects and sets Connection failure, and the cycle repeats.

**Evidence:**

```js
// src/main.js:291-301
			if (line.startsWith('ERR AUTH')) {
				const why = line.includes('wrong')
					? 'Deckboy refused the passphrase — check it in this connection’s settings'
					: 'Deckboy needs a passphrase — enter it in this connection’s settings'
				if (this.lastAuthMessage !== why) {
					this.lastAuthMessage = why
					this.log('error', why)
				}
				this.updateStatus(InstanceStatus.BadConfig, why)
				continue
			}
```

```js
// src/main.js:209-218
		if (this.statusPending) {
			const waited = now - (this.statusSentAt || 0)
			if (waited < this.statusStallMs()) return
			this.stallCount = (this.stallCount || 0) + 1
			if (this.stallCount >= STALLS_BEFORE_RECONNECT) {
				this.log('warn', `Deckboy has not answered STATUS ${this.stallCount} times — reconnecting`)
				this.openConnection()
				this.updateStatus(InstanceStatus.ConnectionFailure, 'No STATUS reply from Deckboy — reconnecting')
				return
			}
```

**Fix:** when an `ERR AUTH` line arrives, stop the polling loop and keep the Bad config status until the settings change. Clear the pending flag and stall count, and set a flag that makes `requestStatus()` return early. Reset it in `openConnection()` / `configUpdated()` so a corrected passphrase is retried. Consider setting OK on the first full report instead of on connect, so a refused connection never shows green.

```js
if (line.startsWith('ERR AUTH')) {
	// ...log and updateStatus as today...
	this.authFailed = true
	this.stopPolling()
	this.statusPending = false
	this.stallCount = 0
	continue
}
```

## 🟢 Low

### L1: A passphrase error that comes back after being fixed is not logged again

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW (L1 in the v1.0.7 review, not fixed)
- **File:** [`src/main.js:295-298`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/main.js#L295-L298)

**What goes wrong:** An operator enters a wrong passphrase and the log shows "Deckboy refused the passphrase …" once. They fix it, and everything works. Later the passphrase in Deckboy is changed and the same error returns. The connection status shows it, but the Log tab stays silent, so someone reading the log sees only the old, already-fixed error.

**Why it happens:** The module remembers the last passphrase message it logged (`this.lastAuthMessage`) and never forgets it: not on connect (which resets the other error message), not in `openConnection()`, and not in `configUpdated()`. Only a refusal with a different reason is logged again.

**Fix:** reset the remembered message when a connection opens, and initialise it in the constructor with the other fields: `this.lastAuthMessage = undefined` in the `connect` handler, next to `this.lastErrorMessage = undefined`.

### L2: The Device field on the limiter and output-effects actions does not resolve variables

- **Source:** 🔎 compliance reviewer (carried forward from the v1.0.7 review; code unchanged)
- **Classification:** 🆕 NEW (L2 in the v1.0.7 review, not fixed)
- **File:** [`src/actions.js:292`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/actions.js#L292), [`src/actions.js:314`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/actions.js#L314)

**What goes wrong:** In "Output limiter on / off" or "Output effects: bypass all (A/B)", a user types `$(internal:custom_device)` into "Device (empty: the focused deck's)". Deckboy receives the literal text `LIMITER ON DEVICE $(internal:custom_device)` instead of the device name. The "Output name" field in "Patch a playlist to a named output" does resolve variables, so fields in the same group behave differently. Switching the field to expression mode works around it.

**Why it happens:** Both Device text fields leave out `useVariables: true`. In base 2.x, a text field only resolves `$(…)` variables when that flag is set.

**Fix:** add `useVariables: true` to both Device fields, as the `output` field in `patch_point` already does.

```js
{ type: 'textinput', label: 'Device (empty: the focused deck’s)', id: 'device', default: '', useVariables: true },
```

## 💡 Nice to Have

### N1: Run dashboard tile silently does nothing for an invalid tile number

- **Source:** 🔎 QA reviewer (carried forward from the v1.0.7 review; code unchanged)
- **Classification:** 🆕 NEW (N1 in the v1.0.7 review, not fixed)
- **File:** [`src/actions.js:164-167`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/e0e5a01160682d3e70dd00e2a72c156481d805f8/src/actions.js#L164-L167)

**What goes wrong:** If the Tile option of "Run dashboard tile" is switched to an expression that comes out empty or as `2.5`, pressing the button sends nothing and logs nothing. Every other numeric action in the module, including the new "Effect colour", logs "… is not a number — nothing sent". Values from the plain number field are not affected.

**Why it happens:** The callback checks the value itself instead of going through the module's `number()` helper, which logs the warning.

**Fix:** use the helper.

```js
callback: ({ options }) => {
	const tile = number(options.tile, 'Tile', { integer: true })
	if (tile !== null && tile >= 1) send(`DASH ${tile}`)
},
```
