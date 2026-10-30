# Re-review: utopianacademy-deckboy v1.0.7

| Field | Value |
| --- | --- |
| **Module** | [companion-module-utopianacademy-deckboy](https://github.com/bitfocus/companion-module-utopianacademy-deckboy) |
| **Scope** | `tag` |
| **Version** | v1.0.7 (`42d9af8`) |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Previous review** | v1.0.4, reviewed 2026-10-30 (✅ Approved, non-blocking: M1, M2, L1, L2, N1) |
| **Release diff** | `v1.0.4..v1.0.7` |
| **Language** | JavaScript (ESM) |
| **Build** | `yarn install --immutable` PASS, `yarn package` PASS. Lint N/A (the JS template has no lint script) |
| **Review date** | 2026-10-30 |

This is a follow-up to the v1.0.4 review. The release changes `.github/workflows/release.yaml` (new), `companion/HELP.md`, the manifest, `package.json`, `src/actions.js`, `src/feedbacks.js`, `src/main.js` and `test/wiring.test.js`. All five findings from the v1.0.4 review are fixed. The release also adds a Passphrase connection setting, four general actions (Take all playlists, Run dashboard tile, Run a sequence, Stop running sequences) and three audio-routing actions. The findings below are all in that new code.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 5 delivers a `secret-text` config value only in the `secrets` argument of `init()` / `configUpdated()`, never in the config object | base 2.1.3 typings in the module's `node_modules` (`input.d.ts:366` says the value "will be in the secrets store, not the config store"; `base.d.ts:61,70` give both methods a separate `secrets` parameter); Companion's host code not checked | [H1](#h1-the-passphrase-field-is-never-sent-to-deckboy-so-a-passphrase-protected-deckboy-refuses-the-connection) |
| A2 | While a client is not authenticated, Deckboy answers each STATUS with an `ERR AUTH …` line and keeps the TCP connection open for at least the first few refusals (if it closes the connection instead, the status still flips between Disconnected and OK, but on the TCP reconnect timer rather than the stall watchdog) | the module's own `ERR AUTH` branch and comment in [`src/main.js:289-301`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L289-L301), and HELP.md ("Five wrong passphrases end the connection"); the device itself not checked | [H1](#h1-the-passphrase-field-is-never-sent-to-deckboy-so-a-passphrase-protected-deckboy-refuses-the-connection), [M1](#m1-a-refused-passphrase-makes-the-connection-drop-and-reconnect-every-few-seconds-instead-of-staying-on-bad-config) |

## 🔁 Since the last review (v1.0.4)

| ID (prior) | Finding | Status | Note |
| --- | --- | --- | --- |
| M1 | Publishing a GitHub release does not build and attach the module package | ✅ Fixed | `.github/workflows/release.yaml` added; the validator finds no difference from the template |
| M2 | Seven State and Action dropdowns offer an expression mode that silently skips the action on any other value | ✅ Fixed | `disableAutoExpression: true` added to those dropdowns and to the other fixed-choice dropdowns |
| L1 | Seek with a blank or non-numeric Seconds value sends a command Deckboy rejects | ✅ Fixed | The Seconds value is now checked with `number()` and nothing is sent when it is not a number |
| L2 | Cue tally and preview buttons light up when the Cue number is blank | ✅ Fixed | Both feedbacks return `false` for a blank Cue number |
| N1 | Every feedback is re-checked on every poll while a deck is playing | ✅ Fixed | The playhead now has its own signature and only re-checks `deck_remaining_below` |

## 📋 Issues

### Blocking

- [ ] [H1: The Passphrase field is never sent to Deckboy, so a passphrase-protected Deckboy refuses the connection](#h1-the-passphrase-field-is-never-sent-to-deckboy-so-a-passphrase-protected-deckboy-refuses-the-connection)

### Non-blocking

- [ ] [M1: A refused passphrase makes the connection drop and reconnect every few seconds instead of staying on Bad config](#m1-a-refused-passphrase-makes-the-connection-drop-and-reconnect-every-few-seconds-instead-of-staying-on-bad-config)
- [ ] [L1: A passphrase refusal is logged only once per module run, even after it was fixed and fails again](#l1-a-passphrase-refusal-is-logged-only-once-per-module-run-even-after-it-was-fixed-and-fails-again)
- [ ] [L2: The Device field on the new limiter and output-effects actions does not resolve variables](#l2-the-device-field-on-the-new-limiter-and-output-effects-actions-does-not-resolve-variables)
- [ ] [N1: Run dashboard tile silently does nothing for an invalid tile number](#n1-run-dashboard-tile-silently-does-nothing-for-an-invalid-tile-number)

## 🟠 High

### H1: The Passphrase field is never sent to Deckboy, so a passphrase-protected Deckboy refuses the connection

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:40-53`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L40-L53), [`src/main.js:86-93`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L86-L93), [`src/main.js:165-168`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L165-L168)

**What goes wrong:** An operator whose Deckboy has a Companion passphrase (for example `stage42`) types `stage42` into the new "Passphrase (only if one is set in Deckboy)" field and saves. The module still connects without sending `AUTH stage42`, so Deckboy answers nothing useful. The connection shows Bad config, "Deckboy needs a passphrase — enter it in this connection's settings", even though the passphrase is filled in. No tally, countdown or variable updates, and the button actions do nothing. The passphrase feature added in this release cannot work. Users whose Deckboy has no passphrase are not affected.

**Why it happens:** In `@companion-module/base` 2.1.3, a `secret-text` config field is kept in a separate secrets store, not in the config object. Companion hands it to the module as a third argument, `secrets`, of `init(config, isFirstInit, secrets)`, and as the second argument of `configUpdated(config, secrets)`. The module ignores that argument and reads `this.config.passphrase`, which is always empty, so the `AUTH` line is never sent.

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
// node_modules/@companion-module/base/dist/module-api/input.d.ts:364-366
 * A text input field for secret values
 *
 * Available for config. Note: the value for this will be in the secrets store, not the config store.
```

```ts
// node_modules/@companion-module/base/dist/module-api/base.d.ts:61,70
    abstract init(config: TManifest['config'], isFirstInit: boolean, secrets: TManifest['secrets']): Promise<void>;
    abstract configUpdated(config: TManifest['config'], secrets: TManifest['secrets']): Promise<void>;
```

`grep -rn secrets src/` finds nothing: the module never reads the `secrets` argument. `git diff v1.0.4..v1.0.7 -- src/main.js` shows the `secret-text` field and the `AUTH` send are both new in this release.

**Confirm by:** open [`src/main.js:40-53`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L40-L53) and [`src/main.js:167`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L167). Neither `init` nor `configUpdated` takes the `secrets` parameter, and the `AUTH` line reads `this.config?.passphrase`. Then open `node_modules/@companion-module/base/dist/module-api/input.d.ts:366`, which says `secret-text` values live in the secrets store.

**Fix:** keep the `secrets` argument Companion passes, and read the passphrase from it. A wiring test that passes a secrets object to `init()` and checks that `AUTH <passphrase>` is the first line sent on connect would catch this. If the value does not need to be secret, a plain `textinput` field also works.

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

### M1: A refused passphrase makes the connection drop and reconnect every few seconds instead of staying on Bad config

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:159-171`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L159-L171), [`src/main.js:197-218`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L197-L218), [`src/main.js:289-301`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L289-L301)

**What goes wrong:** When Deckboy refuses the passphrase (a typo, or none sent because of [H1](#h1-the-passphrase-field-is-never-sent-to-deckboy-so-a-passphrase-protected-deckboy-refuses-the-connection)), the connection should stay red with "Deckboy refused the passphrase — check it in this connection's settings". At the default 250 ms poll it instead loops about every 4.5 seconds: green OK on connect, then Bad config with the passphrase message, then Connection failure "No STATUS reply from Deckboy — reconnecting", then Connecting, and OK again. Each loop writes the warning "Deckboy has not answered STATUS 3 times — reconnecting" to the log, so the real cause, logged only once, is drowned out. A "Deckboy unreachable" feedback flashes on and off, and buttons keep showing the last tally. Each reconnect also sends the passphrase again, which counts toward the "five wrong passphrases" limit in HELP.md.

**Why it happens:** The `connect` handler sets the status to OK before Deckboy has accepted the passphrase. The new `ERR AUTH` branch sets Bad config but leaves polling running and the "STATUS still pending" flag set; only a full status report clears that flag. The stall watchdog in `requestStatus()` therefore counts three unanswered STATUS requests and reconnects, and the cycle repeats. The module treats a known refusal as a dead link.

**Fix:** on an `ERR AUTH` line, stop polling, clear the pending flag and stall count, and set a flag (for example `this.authFailed = true`) that makes `requestStatus()` return early. Reset the flag (and `lastAuthMessage`) in `openConnection()` / `configUpdated()` so a corrected passphrase is retried. Consider holding off on `InstanceStatus.Ok` until the first STATUS report arrives, so a refused connection never shows green.

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

### L1: A passphrase refusal is logged only once per module run, even after it was fixed and fails again

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:295-298`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/main.js#L295-L298)

**What goes wrong:** An operator fixes the passphrase and the connection works. Later the passphrase in Deckboy is changed and the connection is refused again for the same reason. The connection status shows Bad config, but no new line appears in the connection log, so someone reading the log sees only the old, already-fixed error. The status itself is correct, so the visible effect is small.

**Why it happens:** `this.lastAuthMessage` is set when an `ERR AUTH` arrives but is never reset: not on connect, not on a successful report, not in `configUpdated()`. Only a refusal with a different reason is logged again.

**Fix:** reset `this.lastAuthMessage = undefined` in the `connect` handler, next to `this.lastErrorMessage = undefined` (or in `flushReport()`), and initialise it in the constructor with the other fields.

### L2: The Device field on the new limiter and output-effects actions does not resolve variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:292`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/actions.js#L292), [`src/actions.js:314`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/actions.js#L314)

**What goes wrong:** In "Output limiter on / off" or "Output effects: bypass all (A/B)", a user types `$(internal:custom_device)` into "Device (empty: the focused deck's)". Deckboy receives the literal text `LIMITER ON DEVICE $(internal:custom_device)` instead of the device name. The new "Output name" field in "Patch a playlist to a named output" does resolve variables, so fields in the same group behave differently. Switching the field to expression mode works around it.

**Why it happens:** Both Device text fields leave out `useVariables: true`. In base 2.x, a text field only resolves `$(…)` variables when that flag is set.

**Fix:** add `useVariables: true` to both Device fields, as the `output` field in `patch_point` already does.

```js
{ type: 'textinput', label: 'Device (empty: the focused deck’s)', id: 'device', default: '', useVariables: true },
```

## 💡 Nice to Have

### N1: Run dashboard tile silently does nothing for an invalid tile number

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:164-167`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/42d9af8d3e53cd332fc3eea6383bce4a6a5b4926/src/actions.js#L164-L167)

**What goes wrong:** If the Tile option of "Run dashboard tile" is switched to an expression that comes out empty or as `2.5`, pressing the button sends nothing and logs nothing. Every other numeric action in the module logs "… is not a number — nothing sent". Values from the plain number field are not affected.

**Why it happens:** The callback checks the value itself instead of going through the module's `number()` helper, which logs the warning.

**Fix:** use the helper.

```js
callback: ({ options }) => {
	const tile = number(options.tile, 'Tile', { integer: true })
	if (tile !== null && tile >= 1) send(`DASH ${tile}`)
},
```
