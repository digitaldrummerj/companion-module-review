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

- [ ] [H1: A button for a channel or snapshot that isn't in the module's current list acts on channel 1 or snapshot 0 instead](#h1-a-button-for-a-channel-or-snapshot-that-isnt-in-the-modules-current-list-acts-on-channel-1-or-snapshot-0-instead)
- [ ] [H2: Upgraded v1 Macro buttons now recall macro N instead of pressing OSC macro button N](#h2-upgraded-v1-macro-buttons-now-recall-macro-n-instead-of-pressing-osc-macro-button-n)
- [ ] [H3: The build scripts use tsc6 and a TypeScript 6 alias instead of the template's tsc and typescript](#h3-the-build-scripts-use-tsc6-and-a-typescript-6-alias-instead-of-the-templates-tsc-and-typescript)
- [ ] [H4: The CI workflow (node.yaml) still differs from the template](#h4-the-ci-workflow-nodeyaml-still-differs-from-the-template)
- [ ] [H5: The release workflow (release.yaml) is rewritten instead of using the template's](#h5-the-release-workflow-releaseyaml-is-rewritten-instead-of-using-the-templates)

### Non-blocking

- [ ] [M1: A macro state feedback for a button the console doesn't have keeps querying the console and rebuilding every definition](#m1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-keeps-querying-the-console-and-rebuilding-every-definition)
- [ ] [M2: Upgraded macro-state feedbacks lose Use Console Macro Name, so the button no longer shows the macro's name](#m2-upgraded-macro-state-feedbacks-lose-use-console-macro-name-so-the-button-no-longer-shows-the-macros-name)
- [ ] [L1: When the Receive Port can't be opened, the handshake waits forever and the port-unavailable handling never runs](#l1-when-the-receive-port-cant-be-opened-the-handshake-waits-forever-and-the-port-unavailable-handling-never-runs)
- [ ] [L2: The help page names the connection settings and the macro feedback differently from Companion](#l2-the-help-page-names-the-connection-settings-and-the-macro-feedback-differently-from-companion)
- [ ] [L3: The Dynamics Mode action and feedback are labelled "Maybe?" for users](#l3-the-dynamics-mode-action-and-feedback-are-labelled-maybe-for-users)
- [ ] [L4: Each definitions refresh resends several megabytes of options, even for records that didn't change](#l4-each-definitions-refresh-resends-several-megabytes-of-options-even-for-records-that-didnt-change)
- [ ] [L5: The base dependency range allows versions that don't have the IPv4 regex the config uses](#l5-the-base-dependency-range-allows-versions-that-dont-have-the-ipv4-regex-the-config-uses)
- [ ] [N1: A console that never answers shows a yellow warning instead of a connection failure](#n1-a-console-that-never-answers-shows-a-yellow-warning-instead-of-a-connection-failure)
- [ ] [N2: Count variables are named like sections instead of counts](#n2-count-variables-are-named-like-sections-instead-of-counts)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: A button for a channel or snapshot that isn't in the module's current list acts on channel 1 or snapshot 0 instead

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:49-55`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/actions.ts#L49-L55), [`src/actions.ts:342-344`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/actions.ts#L342-L344), [`src/actions.ts:485`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/actions.ts#L485), [`src/actions.ts:564-568`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/actions.ts#L564-L568), [`src/main.ts:197`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L197)

**What goes wrong:** An operator built a button with "[Input Channels] Mute", Input Channel 60, Value On, while a 64-input session was loaded. Later a 48-input session is loaded, so Input 60 is no longer in the module's channel list. The button doesn't just do nothing: it sends `/Input_Channels/1/mute 1` and mutes Input 1. The same happens when the channel multi-select is left empty. With "[Snapshots] Recall Snapshot", "[Snapshots] Update Snapshot" or "[Snapshots] Delete Snapshot" set to a snapshot that no longer exists on the console, the module sends `/Snapshots/Recall_Snapshot/0`, `/Snapshots/Update_Snapshot/0` or `/Snapshots/Delete_Snapshot/0`, so it recalls, overwrites or deletes the console's snapshot at index 0. If the Receive Port can't be opened, the module never learns the console's channel list, so every channel action goes to channel 1 for the whole session while the commands are still sent. "[Presets] Recall Preset" and "[Presets] New Preset" fall back to the first target in the same way. Reproduced with the built module: with 48 inputs and 2 snapshots discovered, Input 60 Mute On sent `/Input_Channels/1/mute [f 1]`, and Recall, Update and Delete Snapshot 12 sent `.../0`. This code was already in v2.0.1; the previous review missed it.

**Why it happens:** Before sending, the action keeps only the selected items that appear in the list of choices the module built from the console. If nothing is left, it substitutes a fallback: channel 1 for channel commands and index 0 for Snapshots, Macros and Presets. When the console's list hasn't been read (for example because the receive port failed), that list holds only channel 1. The "No snapshots found" and "No items in this section" placeholders also use id 0, so picking one sends to index 0.

**Evidence:**

```ts
// src/actions.ts:49-55
function optionIndexes(value: unknown, choices: Array<{ id: number | string }>, fallback = 1): number[] {
	const valid = choices.flatMap((choice) => (typeof choice.id === 'number' ? [choice.id] : []))
	const selected = Array.isArray(value) ? value : value === undefined || value === null ? [] : [value]
	if (selected.includes('all')) return valid.length ? valid : [fallback]
	const indexes = [...new Set(selected.map(Number).filter((index) => Number.isInteger(index) && valid.includes(index)))]
	return indexes.length ? indexes : [fallback]
}
```

```ts
// src/actions.ts:342-344
		const selectorChoices = selectorDefinitions.map(({ path, axis }) =>
			root && hasEntityRoot(root) ? self.getEntityChoices(root) : self.getParameterChoices(path, axis),
		)
// src/actions.ts:485
				const paths = selectedPaths(row.oscPath, event.options, selectorChoices, root && hasEntityRoot(root) ? 0 : 1)
// src/actions.ts:564-568
				const args = wireArguments(row, value)
				for (const path of paths) {
					self.cancelCrossfade(path)
					self.send_osc(path, args)
				}
```

```ts
// src/main.ts:197
		if (choicesByIndex.size === 0) choicesByIndex.add(1)
// src/main.ts:116-118  (no handshake / discovery gate on sends)
	public send_osc(path: string, args: OSCSomeArguments): void {
		this.mixer?.sendOsc(path, args)
	}
// src/main.ts:775-779  (definitions are only rebuilt once discovery completes)
	private scheduleDefinitionRefresh(): void {
		if (!this.discoveryComplete) {
			this.definitionsRefreshPending = true
			return
		}
```

```text
// node -e on a copy of optionIndexes (src/actions.ts:49-55)
pre-discovery input 12: [ 1 ]
pre-discovery snapshot 12: [ 0 ]
48 inputs, select 60: [ 1 ]
empty multiselect: [ 1 ]
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:45-51
// (static values are not validated against the choices; only expression values are)
     * Enabling this will tell companion to validate the value of this field against the definition of the field.
     * If the computed value for this option does not match the validation rules, it will be passed through unchanged.
     * If this is not set, then any invalid value will result in the action/feedback being skipped entirely.
     * Note: This only applies when in expression mode.
    allowInvalidValues?: boolean;
```

**Confirm by:** open [`src/actions.ts:49-55`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/actions.ts#L49-L55) and check that `return indexes.length ? indexes : [fallback]` turns an unlisted or empty selection into channel 1 (0 for Snapshots, Macros and Presets, [`src/actions.ts:485`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/actions.ts#L485)). Then check that [`src/actions.ts:564-568`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/actions.ts#L564-L568) sends to that path with no check, and that [`src/main.ts:197`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L197) leaves only channel 1 in the list when nothing was read from the console.

**Fix:** never replace the stored item with a different one. Return every number the user stored (and the full list for "All"), without filtering it against a list that may be out of date and without a fallback. When nothing is left, `combinations()` yields no paths, so nothing is sent; log a warning in that case.

```ts
function optionIndexes(value: unknown, choices: Array<{ id: number | string }>): number[] {
	const selected = Array.isArray(value) ? value : value === undefined || value === null ? [] : [value]
	if (selected.includes('all')) return choices.flatMap((c) => (typeof c.id === 'number' ? [c.id] : []))
	return [...new Set(selected.map(Number).filter(Number.isInteger))]
}
```

Apply the same rule to the preset target fallback (`targets[0]?.id ?? 1`) in Recall Preset and New Preset. Give the "No snapshots found" and "No items in this section" placeholders an id that can't be a real index (for example `''`) and skip it in the callback.

### H2: Upgraded v1 Macro buttons now recall macro N instead of pressing OSC macro button N

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:30`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L30), [`src/upgrades.ts:151`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L151), [`src/upgrades.ts:159`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/upgrades.ts#L159)

**What goes wrong:** A v1.0.4 user has a button with the action "Macro" (number 3) and the feedback "Change button color for macro state" (Macro Number 3). In v1.0.4 the action sent `/Macros/Buttons/press` with the value 2, which presses the third configured OSC macro button. After the upgrade the action becomes "[Macros] Recall Macro" with item 3 and sends `/Macros/Recall_Macro/3`: a different command that picks from the console's macro list, with a different numbering. The same upgrade moves the button's feedback to "[Macros] OSC Macro State" for OSC macro button 2, so the button lights up for one macro and fires another. If the macro list has no item 3, [H1](#h1-a-button-for-a-channel-or-snapshot-that-isnt-in-the-modules-current-list-acts-on-channel-1-or-snapshot-0-instead) makes it recall item 0. v2.1.0 already has the exact v1 command as "[Macros] OSC Macro Press". Users without v1 Macro buttons are not affected. Reproduced with the compiled upgrade script. This mapping was already in v2.0.1; the previous review missed it.

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

### H3: The build scripts use tsc6 and a TypeScript 6 alias instead of the template's tsc and typescript

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:12-13`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/package.json#L12-L13), [`package.json:37`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/package.json#L37)

**What goes wrong:** Users see no difference: the module builds and runs. The problem is maintenance. This API 2.2 module no longer matches its TypeScript template, so anyone who troubleshoots it or updates it from the template (for example at the template's next TypeScript bump) has to know that it uses a different compiler package and a different command. This was already in v2.0.1; the previous review missed it.

**Why it happens:** The template's `build:main` and `dev` scripts run `tsc`, and the template declares `"typescript": "~6.0.3"`. The module swaps in the `@typescript/typescript6` package through an npm alias, with a caret range, and calls its `tsc6` command in both scripts.

**Evidence:**

```json
// package.json:11-13 (at v2.1.0)
		"build": "rimraf dist && run build:main",
		"build:main": "tsc6 -p tsconfig.build.json",
		"dev": "tsc6 -p tsconfig.build.json --watch",
// package.json:37 (at v2.1.0)
		"typescript": "npm:@typescript/typescript6@^6.0.2",
```

```json
// companion-module-template-ts/package.json:11-12 (@ e0d42b7)
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
// companion-module-template-ts/package.json:36 (@ e0d42b7)
		"typescript": "~6.0.3",
```

```text
// node_modules/typescript/package.json (installed alias)
  "name": "@typescript/typescript6",
  "version": "6.0.2",
  "bin": {
    "tsc6": "./bin/tsc6"
```

**Confirm by:** compare [`package.json:12-13`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/package.json#L12-L13) and [`package.json:37`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/package.json#L37) with `companion-module-template-ts/package.json` lines 11-12 and 36. The module has `tsc6` and `npm:@typescript/typescript6@^6.0.2`; the template has `tsc` and `~6.0.3`.

**Fix:** match the template, then run `yarn install` to refresh `yarn.lock`:

```json
"build:main": "tsc -p tsconfig.build.json",
"dev": "tsc -p tsconfig.build.json --watch",
"typescript": "~6.0.3",
```

### H4: The CI workflow (node.yaml) still differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/.github/workflows/node.yaml#L18)

**What goes wrong:** The previous review raised this file as its H4. The Node 26 lines are now fixed, but the lint job's checkout step still leaves out the template's `persist-credentials: false`. So the job keeps the GitHub token in the checked-out repo's git config for the rest of the run.

**Why it happens:** The module's `node.yaml` was updated by hand instead of being copied from the current template.

**Evidence:** validator: `.github/workflows/node.yaml: Differs from template (line 16: found '- name: Use Node.js 26.x', template 'with:')`. The module's `- uses: actions/checkout@v7` at line 18 has no options; the template's step continues with `with:` / `persist-credentials: false`.

```yaml
# module .github/workflows/node.yaml:18-19
      - uses: actions/checkout@v7
      - name: Use Node.js 26.x
# template .github/workflows/node.yaml
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      - name: Use Node.js 26.x
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml` should show no difference.

**Fix:** copy the template's `node.yaml`, which restores `with: persist-credentials: false` on the `actions/checkout@v7` step.

### H5: The release workflow (release.yaml) is rewritten instead of using the template's

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

### L2: The help page names the connection settings and the macro feedback differently from Companion

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:37-41`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/companion/HELP.md#L37-L41), [`companion/HELP.md:72`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/companion/HELP.md#L72)

**What goes wrong:** Step 4 of the help tells users to set "Receive/listen port", "Send destination port" and "Send destination IP", but the connection settings are labelled "Receive Port", "Transmit Port" and "Mixer IP Address". The "Using feedbacks" section mentions a "Macro button state" feedback, but the feedback list shows "[Macros] OSC Macro State". Users following the help have to guess which field or feedback is meant.

**Why it happens:** The help text wasn't updated to the labels in [`src/config.ts`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/config.ts) and the boolean feedback name in [`digico_entities.csv:3`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/digico_entities.csv#L3).

**Fix:** use the real labels in HELP.md: "Receive Port" `7000`, "Transmit Port" `7001`, "Mixer IP Address" = the console's Local IP Address, and "[Macros] OSC Macro State" for the macro feedback.

### L3: The Dynamics Mode action and feedback are labelled "Maybe?" for users

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`digico_osc.csv:429`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/digico_osc.csv#L429)

**What goes wrong:** The action and the value feedback for `/Input_Channels/*/Dynamics/gate-duck-comp` show the description "Dynamics Mode - Maybe?" in Companion's action and feedback pickers. That tells users the command may not work, and the field is a plain number from 0 to 2 with no meaning given for each value. The other unverified rows from the previous review are no longer offered; this one was written "Maybe?" instead of "MAYBE?", so it was missed.

**Why it happens:** The command table's description column becomes the action and feedback description as-is. This writable row still carries a research note, and there is no value mapping for `gate-duck-comp`.

**Fix:** confirm the command on a console. Then replace the description with a real one (for example "Dynamics mode") and add a `gate-duck-comp` entry to `src/value-mappings.json` (for example 0 = Gate, 1 = Ducker, 2 = Compressor, if those are the console's values) so users get a dropdown. If the command can't be confirmed, clear its `RW` flag like the other unverified rows so it isn't offered.

### L4: Each definitions refresh resends several megabytes of options, even for records that didn't change

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:168-207`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L168-L207), [`src/main.ts:775-789`](https://github.com/bitfocus/companion-module-digico-osc/blob/44239fd513799febe33eea9fce813a070c30adbf/src/main.ts#L775-L789)

**What goes wrong:** No functional effect. Whenever a name changes, or a macro, snapshot or layout record arrives after a record for a different item, the module rebuilds and resends all of its roughly 690 action and feedback definitions 500 ms later. Measured with the built module: about 3.4 MB of option data per rebuild, taking 43 ms of CPU with a small value cache and 300 ms with 10,000 cached values (for example after an iPad has synced through the relay). On large consoles the Companion UI can feel sluggish while names stream in or macro buttons are pressed on the console. The previous review's L5 is partly fixed: refreshes now wait until discovery has finished.

**Why it happens:** The "did it change?" test compares an incoming record with the last value stored at the shared response path, not with that record's own previous value, so consecutive records for different items always look changed (see [M1](#m1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-keeps-querying-the-console-and-rebuilding-every-definition)). On top of that, the channel list for each action is cached per command path, so the same list is rebuilt for every command, and each build scans the whole value cache.

**Fix:** compare against the record's own previous value (`${record.schemaPath}|${record.key}`), as in M1, and cache the choices per selector section (for example by provider key) instead of per command path, so each list is built once per refresh.

### L5: The base dependency range allows versions that don't have the IPv4 regex the config uses

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
| H4 `node.yaml` differs from the template | Still open: the Node lines are fixed, `persist-credentials: false` is still missing ([H4](#h4-the-ci-workflow-nodeyaml-still-differs-from-the-template)) |
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
| M12 `release.yaml` missing | Added, but not the template's ([H5](#h5-the-release-workflow-releaseyaml-is-rewritten-instead-of-using-the-templates)) |
| M13 deprecated `Regex.IP` | Fixed: `Regex.IPV4` (see [L5](#l5-the-base-dependency-range-allows-versions-that-dont-have-the-ipv4-regex-the-config-uses) for the version range) |
| L1 iPad relay problems only logged | Fixed |
| L2 port-in-use shown as "No response" | Fixed for users: the status keeps the socket error; the new port-unavailable path never runs ([L1](#l1-when-the-receive-port-cant-be-opened-the-handshake-waits-forever-and-the-port-unavailable-handling-never-runs)) |
| L3 upgraded channel stored as a single value | Fixed |
| L4 queues wake every 5 ms | Fixed |
| L5 every name change rebuilds all definitions | Partly: refreshes wait for discovery; each refresh is still expensive ([L4](#l4-each-definitions-refresh-resends-several-megabytes-of-options-even-for-records-that-didnt-change)) |
| L6 MAYBE? commands shown to users | Fixed: unverified rows are no longer offered; one "Maybe?" row remains ([L3](#l3-the-dynamics-mode-action-and-feedback-are-labelled-maybe-for-users)) |
| L7 upgrade log messages | Fixed: module logger |
| L8 help page incomplete | Fixed: a few labels still don't match the UI ([L2](#l2-the-help-page-names-the-connection-settings-and-the-macro-feedback-differently-from-companion)) |
| N1 count variable names | Still open ([N2](#n2-count-variables-are-named-like-sections-instead-of-counts)) |
| N2 README version history | Partly: 0.9.0 now says the rewrite isn't based on 1.0.4; 2.0.0 still reads "Version change only" |

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion passes a static (non-expression) dropdown or multi-select value to the action callback unchanged, even when that value is no longer one of the current choices | base 2.2.2 `input.d.ts`: validation against the field "only applies when in expression mode"; Companion host code not checked | [H1](#h1-a-button-for-a-channel-or-snapshot-that-isnt-in-the-modules-current-list-acts-on-channel-1-or-snapshot-0-instead) |
| A2 | Companion re-runs a feedback's callback each time the module calls `checkFeedbacksById` for it, and can start a new run while an earlier one is still waiting; this decides whether the query loop runs about once a second or hundreds of times a second | base 2.2.2 `checkFeedbacksById` only forwards the ids to the host (`module-api/base.js:112-113`); host-side scheduling not checked | [M1](#m1-a-macro-state-feedback-for-a-button-the-console-doesnt-have-keeps-querying-the-console-and-rebuilding-every-definition) |
| A3 | In the Connections list, `InstanceStatus.UnknownWarning` shows as a yellow warning and `InstanceStatus.ConnectionFailure` as a red error | Companion host status rendering; the base package only defines the enum values | [N1](#n1-a-console-that-never-answers-shows-a-yellow-warning-instead-of-a-connection-failure) |
