# Review: companion-module-globalaudiosolutions-rita v1.0.7 (follow-up)

| | |
| --- | --- |
| **Module** | [companion-module-globalaudiosolutions-rita](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita) |
| **Scope** | `tag` (first release: no published tag to diff against, so the whole module was reviewed) |
| **Version** | v1.0.7 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`52eca84`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/tree/52eca842bfa4110b716dd2daac5e01c6519ff4ab) |
| **Prior review** | [v1.0.4 (2026-10-30)](review-globalaudiosolutions-rita-v1.0.4-20261030-192328.md) — ❌ Changes Required |
| **Review date** | 2026-11-06 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not re-run a connection's feedbacks by itself when the connection status changes or when `configUpdated()` runs. A boolean feedback keeps showing its last result until the module calls `checkFeedbacks` / `checkAllFeedbacks`, or the feedback is added or its options are edited | `@companion-module/base` 2.1.3 only gives the module `checkFeedbacks`, `checkAllFeedbacks` and `checkFeedbacksById`, and the API 2.x feedback model runs callbacks on add, on an options change and on an explicit check. Companion's host-side re-evaluation triggers were not read | [L1](#l1-connected-to-rita-stays-green-after-the-settings-are-saved-with-an-address-that-does-not-connect) |
| A2 | On the Companion side, `setVariableValues` and `checkAllFeedbacks` cost work for every key and every feedback sent, rather than being compared and dropped cheaply before any processing | In base 2.1.3 both pass straight through to the host (`dist/module-api/base.js:82-98`). The host implementation was not read | [N1](#n1-every-level-meter-poll-and-every-change-event-rebuilds-all-variables-and-re-runs-every-feedback) |
| A3 | In Companion 5.0, the value an action returns with `hasResult` can be stored by the user (for example in a local or custom variable) and used later on the same button | The base 2.1.3 typings (`hasResult` / `result` in `module-api/action.d.ts`, and the deprecation note pointing at "the action result flow"). How the Companion UI exposes the result was not checked | [N3](#n3-the-answer-of-advanced-send-api-command-only-reaches-the-log-so-a-button-cannot-use-it) |

## 📋 Issues

### Non-blocking

- [ ] [L1: "Connected to RiTA" stays green after the settings are saved with an address that does not connect](#l1-connected-to-rita-stays-green-after-the-settings-are-saved-with-an-address-that-does-not-connect)
- [ ] [N1: Every level-meter poll and every change event rebuilds all variables and re-runs every feedback](#n1-every-level-meter-poll-and-every-change-event-rebuilds-all-variables-and-re-runs-every-feedback)
- [ ] [N2: HELP.md and README lag behind the module: wrong config field name, an undocumented option and no Presets section](#n2-helpmd-and-readme-lag-behind-the-module-wrong-config-field-name-an-undocumented-option-and-no-presets-section)
- [ ] [N3: The answer of "Advanced: send API command" only reaches the log, so a button cannot use it](#n3-the-answer-of-advanced-send-api-command-only-reaches-the-log-so-a-button-cannot-use-it)

### Notes

- **Commit messages:** the earlier commits in this release are in Spanish (e.g. `ba4dbfe` "Barrido largo, con sus tamaños de FFT y su retardo", `708a88d` "Los textos dicen 2.8.1, que es la que se publica"). The commits from `7d430a8` on are in English, thank you. Please keep writing commit messages in English.
- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: "Connected to RiTA" stays green after the settings are saved with an address that does not connect

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:375-388`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L375-L388)

**What goes wrong:** A user has a button with the **Connected to RiTA** feedback, green while the module is connected to RiTA at 192.168.1.10. They change **RiTA IP address** to 192.168.1.20, where RiTA is not running (or clear the field), and save. The connection status changes to Connection failure ("No port in 26101-26105 accepted the connection: …") or Bad config ("No IP address configured"), but the button stays green. Buttons with **Generator is running**, **Measurement engine is active** or **Mute group is muted** also keep showing the old RiTA's state, even though every `$(rita:...)` variable has gone blank. The buttons contradict the connection status until a new connection opens (see [A1](#-assumptions-to-confirm)).

**Why it happens:** When the settings are saved, the module shuts down its old RiTA client, empties its cached RiTA state and clears the variables, but it never asks Companion to re-check the feedbacks. The only places that re-check **Connected to RiTA** run when a socket opens or when a socket that had opened closes. The old client is shut down with its listeners removed first, so it never reports the disconnect, and the new client never opens, so neither place runs.

**Evidence:**

```ts
// src/index.ts:375-388
private startClient(): void {
	this.stopPolling()
	// …
	if (this.resumeTimer) clearTimeout(this.resumeTimer)
	this.resumeTimer = undefined
	this.rita?.destroy()
	this.eventsSupported = false
	this.optional = new Map()
	this.state = createEmptyState()
	UpdateVariableValues(this)
	this.rita = new RitaClient(this)
	this.rita.connect()
}
// src/feedbacks.ts:21-27
connected: {
	type: 'boolean',
	name: 'Connected to RiTA',
	// …
	callback: () => self.rita.connected,
},
```

**Fix:** re-check every feedback at the end of `startClient()`, once the new client is in place, so the buttons match the empty state and the not-yet-connected client at once.

```ts
this.rita = new RitaClient(this)
this.rita.connect()
this.checkAllFeedbacks()
```

Re-checking only `this.checkFeedbacks('connected')` fixes the most visible part.

## 💡 Nice to Have

### N1: Every level-meter poll and every change event rebuilds all variables and re-runs every feedback

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:322-323`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L322-L323), [`src/index.ts:427-428`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L427-L428), [`src/index.ts:467`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L467), [`src/index.ts:644-645`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L644-L645)

**What goes wrong:** Users see no difference. With the default **Level meter and sync poll interval** of 2000 ms, the module re-sends all 181 variable values and asks Companion to re-run every RiTA feedback on every button every 2 seconds. It does the same for each single change event from RiTA, and 39 times in a row on every connect while it subscribes. That is extra CPU and IPC work for Companion, more noticeable on large pages or while a gain is being dragged in RiTA, which sends one event per step (see [A2](#-assumptions-to-confirm)).

**Why it happens:** Both places that merge RiTA's answers into the cached state (one for a single target, one for the level-meter overview that the poll timer reads) end by rebuilding the complete variable set and re-running every feedback. Subscribing goes through the single-target path once per subscribed target, and each change event does too.

**Fix:** on the level-meter path, update only the engine (`meas_N_*`) and sync variables, and re-check only the feedbacks that depend on them (`checkFeedbacks('measurement_active', 'measurement_selected', 'sync_active', 'sync_possible')`) instead of `checkAllFeedbacks()`. In `subscribeAll()`, skip the per-target refresh and do one `UpdateVariableValues(this)` and one `checkAllFeedbacks()` after the loop. A simpler alternative is to keep the last values sent and pass only the changed keys to `setVariableValues`.

### N2: HELP.md and README lag behind the module: wrong config field name, an undocumented option and no Presets section

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:7-12`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/companion/HELP.md#L7-L12), [`companion/HELP.md:108-110`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/companion/HELP.md#L108-L110), [`README.md:44-53`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/README.md#L44-L53)

**What goes wrong:** A user reading the help in Companion looks for a field called **Level meter poll interval**, but the settings show **Level meter and sync poll interval in ms (0 = off)**. The **Log every API message** checkbox is not explained anywhere. The 55 ready-made buttons under Presets (Generator, Measurement, AVG, Mute groups, DSP) are not described. Two paragraphs about **DSP: clear channel** say overlapping things. The README's structure table lists neither `src/presets.ts` nor `src/config.ts`. These are documentation gaps only; the module itself behaves correctly.

**Why it happens:** The config label ([`src/config.ts:55`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/config.ts#L55)), the verbose checkbox ([`src/config.ts:63-69`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/config.ts#L63-L69)) and the presets were added or renamed after the docs were written, and the docs were not updated to match.

**Fix:** bring the docs in line with the module:

- In HELP.md's Configuration section, use the exact label **Level meter and sync poll interval**, and add a line for **Log every API message** (it writes every request and reply to the debug log, with the password masked).
- Add a short **Presets** section to HELP.md that lists the preset groups.
- Merge the two **DSP: clear channel** paragraphs at HELP.md lines 108 and 110.
- Add `src/presets.ts` and `src/config.ts` to the README's structure table.

### N3: The answer of "Advanced: send API command" only reaches the log, so a button cannot use it

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:1155-1183`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/actions.ts#L1155-L1183)

**What goes wrong:** A user sets up **Advanced: send API command** with Action `get` and Target `measurements/1` to read something the module has no variable for. RiTA's reply only appears in the connection log as `get measurements/1: {…}`. The user cannot store it in a variable or use it in a later action or expression on the same button (see [A3](#-assumptions-to-confirm)).

**Why it happens:** The action sends the request and logs the reply, but returns nothing. On API 2.1 (base 2.1.3) an action can declare that it returns a result, and Companion then hands that value to the user through its action result flow.

**Fix:** optional polish on API 2.1: declare a result type for `raw_command`, set `hasResult: true` on its definition, and return the reply from the callback. Keep the log line.

```ts
// src/index.ts, ActionsSchema
raw_command: CompanionActionSchemaWithResult<{ action: string; target: string; properties: string }, JsonValue>

// src/actions.ts, raw_command definition
hasResult: true,
callback: async ({ options }) => {
	// … as today …
	if (response !== undefined) self.log('info', `${options.action} ${target}: ${JSON.stringify(response)}`)
	return response ?? null
},
```

## 📝 Additional Notes

- First release: the module has never been published, so there is no published tag to diff against and the whole module at v1.0.7 was reviewed. The tags v1.0.5 and v1.0.6 were never released; the v1.0.4..v1.0.7 changes were read to verify the fixes to the prior review.
- Prior review, template tooling (C1–C18, H1, M1, M2): fixed. The template's files, `package.json` scripts, `prettier` field, `lint-staged` section, devDependencies and `.github` workflows are in place; `validate-template.ps1` reports nothing, and `yarn install --immutable`, `yarn package` and `yarn lint` all pass.
- Prior review, Node version (C19): fixed. The manifest runtime is `node26`, `engines.node` is `^26` and `@types/node` matches the template.
- Prior review, README in Spanish (H2): fixed. [`README.md`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/README.md) is in English.
- Prior review, connection handling (M3, L1, N1): fixed. The IP address is trimmed and a refused address now shows Bad config ([`src/api.ts:198-211`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/api.ts#L198-L211)); a rejected password stays visible after a reconnect ([`src/api.ts:220-223`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/api.ts#L220-L223)); the connection-failure status names the last error ([`src/api.ts:263-268`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/api.ts#L263-L268)).
- Prior review, actions (M4, M5, L2, L3, N2): fixed. Callbacks return their promise and the long waits stop on Companion's abort signal, a settings save or a disabled connection ([`src/index.ts:529-550`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L529-L550), [`src/actions.ts:649-650`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/actions.ts#L649-L650)); On / Off / Toggle has `disableAutoExpression` and the number dropdowns have an `expressionDescription`, in actions and feedbacks; **Measurement: sync all** uses `asList` and one overview pass ([`src/actions.ts:768-792`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/actions.ts#L768-L792)).
- Prior review, resume timer (L4): fixed. A settings save now cancels it ([`src/index.ts:377-380`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L377-L380)).
- Prior review, config and manifest (L5, L6): fixed. **RiTA IP address** uses `Regex.HOSTNAME` ([`src/config.ts:33`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/config.ts#L33)) and the manifest name is "Global Audio Solutions: RiTA".
- Prior review, typed options (L7): fixed. `ActionsSchema` and `FeedbacksSchema` list every action and feedback with its options ([`src/index.ts:45-133`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/index.ts#L45-L133)).
- Prior review, presets (N3): fixed. [`src/presets.ts`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/52eca842bfa4110b716dd2daac5e01c6519ff4ab/src/presets.ts) adds 55 presets in Generator, Measurement, AVG, Mute groups and DSP groups.
