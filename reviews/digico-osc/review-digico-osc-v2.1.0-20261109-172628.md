# Review: digico-osc v2.1.0 (follow-up to the v2.0.1 review)

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-digico-osc`](https://github.com/bitfocus/companion-module-digico-osc) |
| **Scope** | `tag` (changes `v1.0.4..v2.1.0`) |
| **Version** | v2.1.0 ([`44239fd`](https://github.com/bitfocus/companion-module-digico-osc/commit/44239fd513799febe33eea9fce813a070c30adbf)) |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Previous review** | [v2.0.1 (2026-11-06)](review-digico-osc-v2.0.1-20261106-181511.md), never published; what happened to each of its findings is in [📝 Additional Notes](#-additional-notes) |
| **Reviewed** | 2026-11-09 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [H1: Upgraded v1 Macro buttons now recall macro N instead of pressing OSC macro button N](#h1-upgraded-v1-macro-buttons-now-recall-macro-n-instead-of-pressing-osc-macro-button-n)
- [ ] [H2: The release workflow (release.yaml) is rewritten instead of using the template's](#h2-the-release-workflow-releaseyaml-is-rewritten-instead-of-using-the-templates)
- [ ] [H3: The help page names the connection settings and the macro feedback differently from Companion](#h3-the-help-page-names-the-connection-settings-and-the-macro-feedback-differently-from-companion)

### Non-blocking

- [ ] [M1: A macro state feedback for a button the console doesn't have keeps querying the console and rebuilding every definition](#m1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-keeps-querying-the-console-and-rebuilding-every-definition)
- [ ] [M2: Upgraded macro-state feedbacks lose Use Console Macro Name, so the button no longer shows the macro's name](#m2-upgraded-macro-state-feedbacks-lose-use-console-macro-name-so-the-button-no-longer-shows-the-macros-name)
- [ ] [L1: When the Receive Port can't be opened, the handshake waits forever and the port-unavailable handling never runs](#l1-when-the-receive-port-cant-be-opened-the-handshake-waits-forever-and-the-port-unavailable-handling-never-runs)
- [ ] [L2: The Dynamics Mode action and feedback are labelled "Maybe?" for users](#l2-the-dynamics-mode-action-and-feedback-are-labelled-maybe-for-users)
- [ ] [L3: Each definitions refresh resends several megabytes of options, even for records that didn't change](#l3-each-definitions-refresh-resends-several-megabytes-of-options-even-for-records-that-didnt-change)
- [ ] [L4: The base dependency range allows versions that don't have the IPv4 regex the config uses](#l4-the-base-dependency-range-allows-versions-that-dont-have-the-ipv4-regex-the-config-uses)
- [ ] [N1: A console that never answers shows a yellow warning instead of a connection failure](#n1-a-console-that-never-answers-shows-a-yellow-warning-instead-of-a-connection-failure)
- [ ] [N2: Count variables are named like sections instead of counts](#n2-count-variables-are-named-like-sections-instead-of-counts)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: Upgraded v1 Macro buttons now recall macro N instead of pressing OSC macro button N

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:30`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L30), [`src/upgrades.ts:151`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L151), [`src/upgrades.ts:159`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L159)

**What goes wrong:** A v1.0.4 user has a button with the action "Macro" (number 3) and the feedback "Change button color for macro state" (Macro Number 3). In v1.0.4 the action sent `/Macros/Buttons/press` with the value 2, which presses the third configured OSC macro button. After the upgrade the action becomes "[Macros] Recall Macro" with item 3 and sends `/Macros/Recall_Macro/3`: a different command that picks from the console's macro list, with a different numbering. The same upgrade moves the button's feedback to "[Macros] OSC Macro State" for OSC macro button 2, so the button lights up for one macro and fires another. v2.1.0 already has the exact v1 command as "[Macros] OSC Macro Press". Users without v1 Macro buttons are not affected. Reproduced with the compiled upgrade script. This mapping was already in v2.0.1; the previous review missed it.

**Why it happens:** The upgrade script maps the old `macros` action to `/Macros/Recall_Macro/*` and copies the macro number unchanged. The module's own command tables treat OSC macro buttons (`/Macros/Buttons/*`) and console macros (`/Macros/name`, `/Macros/Recall_Macro/*`) as two separate lists. The feedback upgrade in the same file does target the OSC button list, with number − 1, so the action and the feedback no longer point at the same thing.

**Evidence:**

```js
// git show v1.0.4:index.js:161-167 (IPAD series; the OSC series at 254-260 sends '/sd/Macros/Buttons/press' with the same -1)
				case 'macros':
					arg = [ {
						type: "i",
						value: parseInt(opt.macro)-1,
					}]
					cmd = '/Macros/Buttons/press'
					break;
```

```ts
// src/upgrades.ts:30
	macros: { actionId: '/Macros/Recall_Macro/*', options: { macro: 'index_1' } },
// src/upgrades.ts:151
	const macroIndex = Number(macroValue) - 1
// src/upgrades.ts:159
			index_1: { isExpression: false, value: Number.isFinite(macroIndex) ? macroIndex : 0 },
```

```text
// digico_entities.csv:3,5,7,9 (the module's own model: two separate lists)
/Macros/Buttons/state/*,Int,0,2,R,OSC macro button state,...,macroButtonState,state,State,1,0,macroStatus,,,true,
/Macros/Buttons/press,Int,0,255,W,Press this macro button,,1,,[Macros] OSC Macro Press,,,,,,,,,,Macro,/Macros/Buttons/state,,
/Macros/name,Int,0,9999,R,Macro info by index,,1,entityRecord,,,,,,,,,,,,,,
/Macros/Recall_Macro/*,,,,W,Recall or trigger this macro,,1,,,,,,,,,,,,,,,
```

```json
// src/entity-schemas.json (OSC buttons and console macros are separate record sets)
		"/Macros/Buttons/state/*": { "responsePath": "/Macros/Buttons/state", "fields": "index,state,name", "queryPath": "/Macros/Buttons", ... "emptyChoicesLabel": "No OSC macro buttons found" },
		"/Macros/name": { "responsePath": "/Macros/name", "fields": "index,name" },
```

```text
// Running the compiled dist/upgrades.js UpgradeScripts[0] on a v1 macro button
Action before: {"actionId":"macros","options":{"macro":3}}
Action after:  {"actionId":"/Macros/Recall_Macro/*","options":{"index_1":3}}
feedback -> "feedbackId":"macroButtonState","options":{"index_1":{"isExpression":false,"value":2}, ...}
```

**Confirm by:** open [`src/upgrades.ts:30`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L30) and compare it with [`src/upgrades.ts:151`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L151) and [`src/upgrades.ts:159`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L159). The action goes to `/Macros/Recall_Macro/*` with the number unchanged, while the feedback goes to the OSC macro button list with number − 1. v1 (`git show v1.0.4:index.js | sed -n 161,167p`) sent `/Macros/Buttons/press` with `macro-1`, which matches the v2 "[Macros] OSC Macro Press" action (`/Macros/Buttons/press`) and its `value` option.

**Fix:** migrate `macros` to "[Macros] OSC Macro Press" with the v1 offset. It needs a value change, not only a rename, so handle it on its own in `migrateAction()`:

```ts
if (action.actionId === 'macros') {
	const old = action.options.macro
	if (isWrappedValue(old) && old.isExpression)
		return { ...action, actionId: '/Macros/Buttons/press', options: { value: { isExpression: true, value: `(${String(old.value)}) - 1` } } }
	const index = Number(isWrappedValue(old) ? old.value : old) - 1
	return { ...action, actionId: '/Macros/Buttons/press', options: { value: { isExpression: false, value: Number.isInteger(index) ? index : 0 } } }
}
```

v2.0.0, v2.0.1 and v2.1.0 have not been published, so you can fix the existing upgrade script in place.

### H2: The release workflow (release.yaml) is rewritten instead of using the template's

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:3-9`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/.github/workflows/release.yaml#L3-L9), [`.github/workflows/release.yaml:11-39`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/.github/workflows/release.yaml#L11-L39)

**What goes wrong:** The previous review flagged this file as missing (its M12). It has been added, but it is a custom workflow, not the template's. Pushing any `v*` tag now builds the package on the runner and creates or updates a GitHub release with a token that can write to the whole repo for the entire run. The Bitfocus module checks that the template runs before packaging are skipped.

**Why it happens:** The template's workflow runs when a GitHub release is published. Its `package` job calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` (with the template-repo `if:` guard and `packages: read`), and a separate `attach` job, the only one with write permission, downloads the `pkg` artifact and uploads it to the release. The module's file replaces all of that with one job.

**Evidence:** validator: `.github/workflows/release.yaml: Differs from template (line 3: found 'push:', template 'release:')`.

- [`.github/workflows/release.yaml:4-6`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/.github/workflows/release.yaml#L4-L6) triggers on `push: tags: - 'v*'` instead of `release: types: [published]`.
- [`.github/workflows/release.yaml:9`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/.github/workflows/release.yaml#L9) sets workflow-wide `contents: write` instead of `contents: read`.
- [`.github/workflows/release.yaml:12-39`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/.github/workflows/release.yaml#L12-L39) is a single `package-and-release` job that runs checkout, setup-node, `yarn install` and `yarn package` itself, then calls `gh release create`/`upload`. The template's `package` and `attach` jobs are gone.

**Confirm by:** `diff companion-module-template-ts/.github/workflows/release.yaml .github/workflows/release.yaml` should show no difference.

**Fix:** replace `release.yaml` with the template's file.

### H3: The help page names the connection settings and the macro feedback differently from Companion

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:37-41`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/companion/HELP.md#L37-L41), [`companion/HELP.md:72`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/companion/HELP.md#L72)

**What goes wrong:** Step 4 of the help tells users to set "Receive/listen port", "Send destination port" and "Send destination IP", but the connection settings are labelled "Receive Port", "Transmit Port" and "Mixer IP Address". The "Using feedbacks" section mentions a "Macro button state" feedback, but the feedback list shows "[Macros] OSC Macro State". Users following the help have to guess which field or feedback is meant.

**Why it happens:** The help text wasn't updated to the labels in [`src/config.ts`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/config.ts) and the boolean feedback name in [`digico_entities.csv:3`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/digico_entities.csv#L3).

**Fix:** use the real labels in HELP.md: "Receive Port" `7000`, "Transmit Port" `7001`, "Mixer IP Address" = the console's Local IP Address, and "[Macros] OSC Macro State" for the macro feedback.

## 🟡 Medium

### M1: A macro state feedback for a button the console doesn't have keeps querying the console and rebuilding every definition

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:439-461`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L439-L461), [`src/main.ts:554`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L554), [`src/main.ts:610-623`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L610-L623)

**What goes wrong:** A user has "[Macros] OSC Macro State" (or "[Macros] OSC Macro State Value") on a button for Macro 6, but the loaded session only has OSC macro buttons 0-3. This happens after loading a different session, removing a button on the console, or upgrading a v1 macro feedback for a button that no longer exists. From then on the module sends `/Macros/Buttons/?` to the console about once a second for as long as the connection runs, and each reply rebuilds every action and feedback definition (about 3.4 MB each time, measured). If Companion re-runs the feedback while an earlier run is still waiting, the rate climbs much higher: 1,432 queries in 5 s in a simulation. Users see nothing except load on Companion and the console, and noise in the debug log.

**Why it happens:** When the requested button isn't cached, the feedback asks the console for the whole button list, and the module never remembers that the list has already been loaded. Each reply record is then compared with the value stored at the shared path `/Macros/Buttons/state`, which is the last record received, usually for another button. So every record counts as "changed": that re-runs every feedback watching the path (including the one for the missing button, which queries again) and schedules a definitions refresh. Reproduced with the built module and a stub console that answers with 4 button records: button 5 gave 5 queries and 20 refresh requests in 5 s, while button 2 (which exists) gave 1 query.

**Fix:** remember which lists have been loaded and stop querying for an index that isn't in a loaded list. For example, keep a `Set` of loaded `queryPath`s, add the path when its first reply arrives and remove it on the `/!` change notice for that path; in `getIndexedRecordOrQuery()`, return `undefined` straight away when the list is loaded and the index isn't in it. In `onOscMessage()`, compare each record with its own previous value (``this.dataStore.get(`${record.schemaPath}|${record.key}`)``) instead of the shared path, and only re-check feedbacks or schedule a definitions refresh when that item's value or name changed.

### M2: Upgraded macro-state feedbacks lose Use Console Macro Name, so the button no longer shows the macro's name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:155-163`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L155-L163)

**What goes wrong:** In v1.0.4, the feedback "Change button color for macro state" with "Use Console Macro Name" on changed the button text to the console's macro name (for example "Band Mute") while the macro was in the chosen state. After the upgrade it becomes the boolean "[Macros] OSC Macro State" feedback, which can only set colours, and the name setting is dropped, so the button shows its own fixed text instead. No other feedback or variable gives the OSC macro button's name, so users can't rebuild the label.

**Why it happens:** The feedback upgrade keeps only the button and the state as options, and only the text and background colours as style. The v1 `name` option, and the text it produced, have no equivalent in v2.1.0.

**Fix:** expose the OSC macro button names, for example a `macro_button_<n>_name` variable per discovered button (from the `name` field of the `/Macros/Buttons/state` records) or a value feedback that returns the name. When the v1 `name` option was on, have the upgrade script set the button text to that variable. At minimum, say in HELP.md that the macro-name text option is gone.

## 🟢 Low

### L1: When the Receive Port can't be opened, the handshake waits forever and the port-unavailable handling never runs

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/mixers.ts:70-78`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/mixers.ts#L70-L78), [`src/mixers.ts:144-158`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/mixers.ts#L144-L158)

**What goes wrong:** Users see little difference. If Receive Port 7000 is already used by another program, the connection shows the error `OSC receive socket error: <reason>` and keeps it. But the first "/Console/Name" handshake query never finishes, so the code written for this case never runs: the "Receive port 7000 unavailable" status in the handshake loop and the "Skipping OSC queries because UDP 7000 is not open" log line. The stuck query is only released when the connection is disabled or its settings are saved. Reproduced with a stub socket against the built `dist/mixers.js`: after 3 s the query was still pending.

**Why it happens:** The first query reaches the send loop before the port has finished opening, so the loop marks it as the active query, puts it back at the front of the queue and waits for the socket. When opening the port then fails, the error handler sets the "port unavailable" flag but doesn't clear the active query. On the next pass the loop only looks for non-query messages, because a query is still marked active, so the parked query is never picked up again and never reaches the branch that would fail it. The handshake loop stays waiting on that query and never reaches its own port-failed check ([`src/main.ts:716-719`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L716-L719)).

**Fix:** in the socket error handler's bind-failure branch (`if (!this.receiveSocketListening) { ... }`), also clear the parked query and wake the send loop: `this.activeQueryPath = undefined; this.wakeSendQueue()`. The parked query then fails as intended, and `waitForConsole()` reports the port problem. (Or check `mixer.hasReceiveSocketFailed` in `waitForConsole()` before awaiting the query.)

### L2: The Dynamics Mode action and feedback are labelled "Maybe?" for users

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`digico_osc.csv:429`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/digico_osc.csv#L429)

**What goes wrong:** The action and the value feedback for `/Input_Channels/*/Dynamics/gate-duck-comp` show the description "Dynamics Mode - Maybe?" in Companion's action and feedback pickers. That tells users the command may not work, and the field is a plain number from 0 to 2 with no meaning given for each value. The other unverified rows from the previous review are no longer offered; this one was written "Maybe?" instead of "MAYBE?", so it was missed.

**Why it happens:** The command table's description column becomes the action and feedback description as-is. This writable row still carries a research note, and there is no value mapping for `gate-duck-comp`.

**Fix:** confirm the command on a console. Then replace the description with a real one (for example "Dynamics mode") and add a `gate-duck-comp` entry to `src/value-mappings.json` (for example 0 = Gate, 1 = Ducker, 2 = Compressor, if those are the console's values) so users get a dropdown. If the command can't be confirmed, clear its `RW` flag like the other unverified rows so it isn't offered.

### L3: Each definitions refresh resends several megabytes of options, even for records that didn't change

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:168-207`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L168-L207), [`src/main.ts:775-789`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L775-L789)

**What goes wrong:** No functional effect. Whenever a name changes, or a macro, snapshot or layout record arrives after a record for a different item, the module rebuilds and resends all of its roughly 690 action and feedback definitions 500 ms later. Measured with the built module: about 3.4 MB of option data per rebuild, taking 43 ms of CPU with a small value cache and 300 ms with 10,000 cached values (for example after an iPad has synced through the relay). On large consoles the Companion UI can feel sluggish while names stream in or macro buttons are pressed on the console. The previous review's L5 is partly fixed: refreshes now wait until discovery has finished.

**Why it happens:** The "did it change?" test compares an incoming record with the last value stored at the shared response path, not with that record's own previous value, so consecutive records for different items always look changed (see [M1](#m1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-keeps-querying-the-console-and-rebuilding-every-definition)). On top of that, the channel list for each action is cached per command path, so the same list is rebuilt for every command, and each build scans the whole value cache.

**Fix:** compare against the record's own previous value (`${record.schemaPath}|${record.key}`), as in M1, and cache the choices per selector section (for example by provider key) instead of per command path, so each list is built once per refresh.

### L4: The base dependency range allows versions that don't have the IPv4 regex the config uses

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:27`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/package.json#L27)

**What goes wrong:** Users see no difference: `yarn.lock` resolves @companion-module/base 2.2.2, so the module builds and the IP fields are validated. But the declared range `~2.2.0` says 2.2.0 and 2.2.1 work too, and on those versions `Regex.IPV4` doesn't exist: the TypeScript build fails, and the Mixer IP Address and iPad IP Address fields would have no validation.

**Why it happens:** [`src/config.ts:60`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/config.ts#L60) and [`src/config.ts:94`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/config.ts#L94) now use `Regex.IPV4` (the fix for the previous review's M13), which arrived in base 2.2.2. The dependency range wasn't raised to match.

**Fix:** declare the minimum the code needs, `"@companion-module/base": "~2.2.2"`, then run `yarn install`.

## 💡 Nice to Have

### N1: A console that never answers shows a yellow warning instead of a connection failure

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:727-728`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L727-L728)

**What goes wrong:** When the console at 192.168.1.100 is switched off, or its DiGiCo Pad device points at the wrong IP, the connection shows the warning "No response received from connected Mixer" rather than a connection failure. The message is clear, but the status level, and so its colour in the Connections list, is softer than for other modules that can't reach their device.

**Fix:** use `this.updateStatus(InstanceStatus.ConnectionFailure, 'No response received from connected Mixer')` for the handshake timeout, and keep `UnknownWarning` for the iPad relay warnings.

### N2: Count variables are named like sections instead of counts

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:4-13`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/variables.ts#L4-L13)

**What goes wrong:** In the variable picker, `$(digico-osc:input_channels)` is listed as "Input Channels", but its value is a count such as "48". The same goes for Aux Outputs, Group Outputs, Matrix Inputs and Outputs, Control Groups, Graphic EQs and Multis. The entity variables are already named "Macros count" and so on. Still open from the previous review (its N1).

**Fix:** name them like the entity variables, for example `input_channels: 'Input Channels count'`. Keep the ids unchanged so existing `$(…)` references keep working.

## 📝 Additional Notes

- `tsconfig.build.json` adds `"resolveJsonModule": true` after the template's `"verbatimModuleSyntax": true`. The module builds, so no change is required.
- What happened to the findings of the [v2.0.1 review](review-digico-osc-v2.0.1-20261106-181511.md) (IDs below are that review's):

| v2.0.1 finding | Status in v2.1.0 |
| --- | --- |
| C1 repository link placeholder | Fixed |
| C2 Node 22 instead of Node 26 | Fixed: manifest, `tsconfig.build.json` and `node.yaml` use Node 26 |
| H1 v1 IP and ports lost on upgrade | Fixed: the upgrade script carries `host`/`port`/`receiveport` over |
| H2 macro-state feedback upgraded to a missing id | Fixed: it now becomes "[Macros] OSC Macro State" with its colours and state; the name text is still lost ([M2](#m2-upgraded-macro-state-feedbacks-lose-use-console-macro-name-so-the-button-no-longer-shows-the-macros-name)) |
| H3 `Bfloat` rows sent without a value | Fixed |
| H4 `node.yaml` differs from the template | Fixed: the Node lines now match the template; the checkout step still leaves out `persist-credentials: false`, which is not treated as a finding |
| M1 feedbacks stop after saving settings | Fixed: `checkAllFeedbacks()` after the handshake |
| M2 one failed send stops all queries | Fixed: send errors are now logged separately |
| M3 default ports reversed from HELP | Fixed: defaults and HELP agree (Receive 7000, Transmit 7001) |
| M4 two connections on one Receive Port | Fixed: packets are filtered by sender address |
| M5 Renumber Snapshot rounding | Fixed: `Math.round` |
| M6 recorded values not scaled | Fixed |
| M7 cross-fades can't be stopped | Fixed: one fade per path, and the abort signal is honoured |
| M8 OSC and S-Range upgrades misfire | Fixed: OSC fader values are converted, S-series snapshot actions are mapped |
| M9 preset option ids shift | Fixed: ids come from the section name |
| M10 Relative mode can't step down | Fixed: separate Relative delta field |
| M11 no boolean feedbacks | Fixed |
| M12 `release.yaml` missing | Added, but not the template's ([H2](#h2-the-release-workflow-releaseyaml-is-rewritten-instead-of-using-the-templates)) |
| M13 deprecated `Regex.IP` | Fixed: `Regex.IPV4` (see [L4](#l4-the-base-dependency-range-allows-versions-that-dont-have-the-ipv4-regex-the-config-uses) for the version range) |
| L1 iPad relay problems only logged | Fixed |
| L2 port-in-use shown as "No response" | Fixed for users: the status keeps the socket error; the new port-unavailable path never runs ([L1](#l1-when-the-receive-port-cant-be-opened-the-handshake-waits-forever-and-the-port-unavailable-handling-never-runs)) |
| L3 upgraded channel stored as a single value | Fixed |
| L4 queues wake every 5 ms | Fixed |
| L5 every name change rebuilds all definitions | Partly: refreshes wait for discovery; each refresh is still expensive ([L3](#l3-each-definitions-refresh-resends-several-megabytes-of-options-even-for-records-that-didnt-change)) |
| L6 MAYBE? commands shown to users | Fixed: unverified rows are no longer offered; one "Maybe?" row remains ([L2](#l2-the-dynamics-mode-action-and-feedback-are-labelled-maybe-for-users)) |
| L7 upgrade log messages | Fixed: module logger |
| L8 help page incomplete | Fixed: a few labels still don't match the UI ([H3](#h3-the-help-page-names-the-connection-settings-and-the-macro-feedback-differently-from-companion)) |
| N1 count variable names | Still open ([N2](#n2-count-variables-are-named-like-sections-instead-of-counts)) |
| N2 README version history | Partly: 0.9.0 now says the rewrite isn't based on 1.0.4; 2.0.0 still reads "Version change only" |

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion re-runs a feedback's callback each time the module calls `checkFeedbacksById` for it, and can start a new run while an earlier one is still waiting; this decides whether the query loop runs about once a second or hundreds of times a second | base 2.2.2 `checkFeedbacksById` only forwards the ids to the host (`module-api/base.js:112-113`); host-side scheduling not checked | [M1](#m1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-keeps-querying-the-console-and-rebuilding-every-definition) |
| A2 | In the Connections list, `InstanceStatus.UnknownWarning` shows as a yellow warning and `InstanceStatus.ConnectionFailure` as a red error | Companion host status rendering; the base package only defines the enum values | [N1](#n1-a-console-that-never-answers-shows-a-yellow-warning-instead-of-a-connection-failure) |
