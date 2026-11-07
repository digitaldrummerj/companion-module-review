# Review: digico-osc v2.0.1

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-digico-osc`](https://github.com/bitfocus/companion-module-digico-osc) |
| **Scope** | `tag` (changes `v1.0.4..v2.0.1`) |
| **Version** | v2.0.1 ([`0602e22`](https://github.com/bitfocus/companion-module-digico-osc/commit/0602e2229ee11056f380ebecedd1d6499acc3134)) |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: The module's repository link still points at the template placeholder](#c1-the-modules-repository-link-still-points-at-the-template-placeholder)
- [ ] [C2: The module still targets Node 22, but the API 2.2 template runs on Node 26](#c2-the-module-still-targets-node-22-but-the-api-22-template-runs-on-node-26)
- [ ] [H1: Upgrading from v1.0.4 loses the saved console IP and ports, so no button reaches the console](#h1-upgrading-from-v104-loses-the-saved-console-ip-and-ports-so-no-button-reaches-the-console)
- [ ] [H2: Upgraded macro-state feedbacks point at a feedback that doesn't exist, so macro buttons stop changing colour](#h2-upgraded-macro-state-feedbacks-point-at-a-feedback-that-doesnt-exist-so-macro-buttons-stop-changing-colour)
- [ ] [H3: Five dynamic EQ and alternate-solo actions send the command without the chosen value](#h3-five-dynamic-eq-and-alternate-solo-actions-send-the-command-without-the-chosen-value)
- [ ] [H4: The CI workflow (node.yaml) differs from the template](#h4-the-ci-workflow-nodeyaml-differs-from-the-template)

### Non-blocking

- [ ] [M1: Feedbacks stop updating after the connection settings are saved](#m1-feedbacks-stop-updating-after-the-connection-settings-are-saved)
- [ ] [M2: One failed UDP send stops all console queries until the connection is restarted](#m2-one-failed-udp-send-stops-all-console-queries-until-the-connection-is-restarted)
- [ ] [M3: The default ports are the reverse of what the help tells users to set up](#m3-the-default-ports-are-the-reverse-of-what-the-help-tells-users-to-set-up)
- [ ] [M4: Two DiGiCo connections on the same Receive Port show each other's console data](#m4-two-digico-connections-on-the-same-receive-port-show-each-others-console-data)
- [ ] [M5: Renumber Snapshot sets the number 0.01 too low for about 1 in 8 values](#m5-renumber-snapshot-sets-the-number-001-too-low-for-about-1-in-8-values)
- [ ] [M6: Recorded delay, attack, release and hold actions replay at one thousandth of the recorded value](#m6-recorded-delay-attack-release-and-hold-actions-replay-at-one-thousandth-of-the-recorded-value)
- [ ] [M7: A running cross-fade can't be stopped, so two fades on the same fader fight each other](#m7-a-running-cross-fade-cant-be-stopped-so-two-fades-on-the-same-fader-fight-each-other)
- [ ] [M8: Upgraded v1 buttons from the OSC and S-Range command sets misfire (a fader OFF button sets 0 dB)](#m8-upgraded-v1-buttons-from-the-osc-and-s-range-command-sets-misfire-a-fader-off-button-sets-0-db)
- [ ] [M9: Preset actions and feedbacks lose the picked preset when the console's preset sections change](#m9-preset-actions-and-feedbacks-lose-the-picked-preset-when-the-consoles-preset-sections-change)
- [ ] [M10: Relative mode can't step a value down when the parameter's range starts at 0](#m10-relative-mode-cant-step-a-value-down-when-the-parameters-range-starts-at-0)
- [ ] [M11: No feedback can colour a button, so mute, solo or macro state can't light a button directly](#m11-no-feedback-can-colour-a-button-so-mute-solo-or-macro-state-cant-light-a-button-directly)
- [ ] [M12: The release workflow (release.yaml) is missing](#m12-the-release-workflow-releaseyaml-is-missing)
- [ ] [M13: The IP address fields reject hostnames (deprecated Regex.IP)](#m13-the-ip-address-fields-reject-hostnames-deprecated-regexip)
- [ ] [L1: iPad relay problems only reach the log, and the connection still shows OK](#l1-ipad-relay-problems-only-reach-the-log-and-the-connection-still-shows-ok)
- [ ] [L2: A Receive Port that is already in use shows up as "No response received from connected Mixer"](#l2-a-receive-port-that-is-already-in-use-shows-up-as-no-response-received-from-connected-mixer)
- [ ] [L3: Upgraded channel selections are saved as a single value in a multi-select field](#l3-upgraded-channel-selections-are-saved-as-a-single-value-in-a-multi-select-field)
- [ ] [L4: The send and receive queues wake every 5 ms even when idle](#l4-the-send-and-receive-queues-wake-every-5-ms-even-when-idle)
- [ ] [L5: Every console name change rebuilds and resends all of the roughly 660 action definitions](#l5-every-console-name-change-rebuilds-and-resends-all-of-the-roughly-660-action-definitions)
- [ ] [L6: Commands marked MAYBE? are shown to users as normal actions and feedbacks](#l6-commands-marked-maybe-are-shown-to-users-as-normal-actions-and-feedbacks)
- [ ] [L7: The upgrade script's log messages don't reach the connection log](#l7-the-upgrade-scripts-log-messages-dont-reach-the-connection-log)
- [ ] [L8: The help page doesn't cover the iPad relay, actions, feedbacks or variables, and has broken formatting](#l8-the-help-page-doesnt-cover-the-ipad-relay-actions-feedbacks-or-variables-and-has-broken-formatting)
- [ ] [N1: Count variables are named like sections, not counts](#n1-count-variables-are-named-like-sections-not-counts)
- [ ] [N2: The README version history describes the rewrite as a version-number change only](#n2-the-readme-version-history-describes-the-rewrite-as-a-version-number-change-only)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The module's repository link still points at the template placeholder

- **Source:** 🤖 validate-template (PKG-REPO)
- **Classification:** 🔙 REGRESSION
- **File:** [`package.json:20`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/package.json#L20)

**What goes wrong:** The repository link in `package.json` points at `companion-module-your-module-name`, a repo that doesn't exist, so anything that follows the package's repository link ends up at a 404 instead of this module. v1.0.4 had the right URL; the rewrite brought back the template's placeholder.

**Why it happens:** The template ships with a placeholder `repository.url`, and it wasn't replaced with this module's repo.

**Evidence:** validator expected vs found:

```text
package.json: repository.url 'git+https://github.com/bitfocus/companion-module-your-module-name.git'
should be 'git+https://github.com/bitfocus/companion-module-digico-osc.git'
```

```json
// package.json:20
"url": "git+https://github.com/bitfocus/companion-module-your-module-name.git"
```

**Confirm by:** `grep -n '"url"' package.json`

**Fix:** point the repository at this module.

```json
"repository": {
	"type": "git",
	"url": "git+https://github.com/bitfocus/companion-module-digico-osc.git"
}
```

### C2: The module still targets Node 22, but the API 2.2 template runs on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/companion/manifest.json#L19), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/tsconfig.build.json#L2), [`.github/workflows/node.yaml:19-23`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/.github/workflows/node.yaml#L19-L23), [`.github/workflows/node.yaml:60-63`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/.github/workflows/node.yaml#L60-L63)

**What goes wrong:** Companion starts the module on Node 22, because the manifest's runtime says `node22`, and CI builds it on Node 22 too. But the module is built on the API 2.2 template, which runs on Node 26, and `package.json` already declares Node 26 (`engines.node` `^26.00`, `@types/node` `^26.6.0`). So the module is typed for one Node version and runs on another.

**Why it happens:** The Node version is named in several places, and only `package.json` was moved to 26.

**Evidence:** validator expected vs found:

```text
companion/manifest.json runtime.type 'node22' -> 'node26'
tsconfig.build.json extends "@companion-module/tools/tsconfig/node22/recommended-esm.json" -> "@companion-module/tools/tsconfig/node26/recommended.json"
.github/workflows/node.yaml line 19 step name 'Use Node.js 22.x' -> 'Use Node.js 26.x'
.github/workflows/node.yaml line 23 node-version 22.x -> 26.x
.github/workflows/node.yaml line 60 step name 'Use Node.js 22.x' -> 'Use Node.js 26.x' (commented out)
.github/workflows/node.yaml line 63 node-version 22.x -> 26.x (commented out)
```

**Confirm by:** `grep -n node22 companion/manifest.json tsconfig.build.json; grep -n '22.x' .github/workflows/node.yaml`

**Fix:** move every place that still names Node 22 to Node 26:

- `companion/manifest.json`: `"runtime": { "type": "node26" }`
- `tsconfig.build.json`: `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"`
- `.github/workflows/node.yaml`: `- name: Use Node.js 26.x` (lines 19 and 60) and `node-version: 26.x` (lines 23 and 63, including the commented-out `test:` job)

## 🟠 High

### H1: Upgrading from v1.0.4 loses the saved console IP and ports, so no button reaches the console

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:100-124`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L100-L124)

**What goes wrong:** A user on v1.0.4 has Target IP 10.0.0.20, Target port 8001 and Receive port 8002. After the upgrade to v2.0.1 their buttons are moved to the new actions (the old mute action becomes "[Input Channels] Mute", for example), but the connection settings are not carried over. The connection falls back to the defaults: it sends to 192.168.1.100 on port 7000 and listens on 7001. The status shows the warning "No response received from connected Mixer", and no button, feedback or variable works until the user opens the connection and re-enters the Mixer IP Address, Transmit Port and Receive Port. Connections created new on v2 are not affected.

**Why it happens:** v1.0.4 saved its settings as `host`, `port` and `receiveport`. v2 renamed them to `ip`, `transmitPort` and `receivePort`, and nothing in the module reads the old names. The only upgrade script converts the old actions and feedbacks but returns `updatedConfig: null`, which tells Companion the config did not change. When the connection starts, `normalizeConfig()` finds no `ip` or ports and fills in the defaults.

**Evidence:**

```js
// git show v1.0.4:index.js (config_fields, lines 36-55)
			id:      'host',
			label:   'Target IP',
...
			id:      'port',
			label:   'Target port',
			default: '8001'
...
			id:      'receiveport',
			label:   'Receive port',
			default: '8002'
```

```ts
// src/upgrades.ts:100-103, 121
function upgradeLegacyDiGiCoControls(
	_context: CompanionUpgradeContext<ModuleConfig>,
	props: CompanionStaticUpgradeProps<ModuleConfig, undefined>,
): CompanionStaticUpgradeResult<ModuleConfig, undefined> {
...
	return { updatedConfig: null, updatedActions, updatedFeedbacks }
// src/upgrades.ts:17-20 (the script maps v1.0.4 action ids, so v1.0.4 connections are expected to upgrade)
const legacyActions: Record<string, LegacyActionMapping> = {
	snapshotNext: { actionId: '/Snapshots/Fire_Next_Snapshot', options: {} },
	snapshotPrev: { actionId: '/Snapshots/Fire_Prev_Snapshot', options: {} },
```

```ts
// src/config.ts:13-16
export const DEFAULT_CONFIG: ModuleConfig = {
	ip: '192.168.1.100',
	transmitPort: 7000,
	receivePort: 7001,
// src/main.ts:639-644
	private normalizeConfig(config: Partial<ModuleConfig> | undefined): ModuleConfig {
		return {
			...DEFAULT_CONFIG,
			ip: config?.ip?.trim() || DEFAULT_CONFIG.ip,
			transmitPort: Number(config?.transmitPort) || DEFAULT_CONFIG.transmitPort,
			receivePort: Number(config?.receivePort) || DEFAULT_CONFIG.receivePort,
```

```ts
// node_modules/@companion-module/base/dist/module-api/upgrade.d.ts:36-40
export interface CompanionStaticUpgradeResult<TConfig extends JsonObject, TSecrets extends JsonObject | undefined> {
    /**
     * The updated config, if any changes were made
     */
    updatedConfig: TConfig | null;
```

```text
Runtime check: UpgradeScripts[0] called with config
{host:'10.1.1.5', port:'8001', receiveport:'8002', series:'IPAD', polling:true}
returned updatedConfig: null
grep -rn "receiveport\|config\.host\|'host'\|config\.port\b" src/   -> no matches
```

**Confirm by:** run `git show v1.0.4:index.js | sed -n 30,56p` to see the ids `host`/`port`/`receiveport`, then open [`src/upgrades.ts:121`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L121) (`updatedConfig: null`) and [`src/main.ts:639-648`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L639-L648), which reads only `ip`/`transmitPort`/`receivePort` and falls back to 192.168.1.100:7000/7001.

**Fix:** copy the old settings across in the upgrade script. v2.0.0 was never published, so you can add this to the existing `upgradeLegacyDiGiCoControls`; it then runs once per connection together with the action upgrade.

```ts
const old = props.config as Record<string, unknown> | null
let updatedConfig: ModuleConfig | null = null
if (old && old.ip === undefined && typeof old.host === 'string' && old.host.trim()) {
	updatedConfig = {
		...DEFAULT_CONFIG,
		ip: old.host.trim(),
		transmitPort: Number(old.port) || DEFAULT_CONFIG.transmitPort,
		receivePort: Number(old.receiveport) || DEFAULT_CONFIG.receivePort,
	}
}
return { updatedConfig, updatedActions, updatedFeedbacks }
```

### H2: Upgraded macro-state feedbacks point at a feedback that doesn't exist, so macro buttons stop changing colour

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:89-98`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L89-L98)

**What goes wrong:** In v1.0.4 a user had the feedback "Change button color for macro state" on a button (Macro Number 3, Macro State on, green background). After the upgrade the feedback points at `/Macros/Buttons/state/name`, and no feedback in v2.0.1 has that id. Companion lists it as an unknown feedback and the button never turns green again, so the user has to delete it and rebuild the button by hand. Even with the right id, the upgrade drops the colours and the on/off state choice, and the only macro-state feedback in v2.0.1 is a value feedback, which can't colour a button by itself (see [M11](#m11-no-feedback-can-colour-a-button-so-mute-solo-or-macro-state-cant-light-a-button-directly)).

**Why it happens:** v2 feedback ids are the `osc_path` values from the CSV tables, and the only macro-button-state row is `/Macros/Buttons/state/*`, whose option id is `index_1`, not `macro`. The upgrade script renames the feedback to a different id, keeps the `macro` option under its old name, and doesn't move the old `fg`/`bg` colours into the feedback's style. v1.0.4 also numbered macros as console index + 1, while the new record index is the console's own index, so the macro number would be off by one.

**Evidence:**

```ts
// src/upgrades.ts:89-98
function migrateFeedback(feedback: CompanionMigrationFeedback): CompanionMigrationFeedback | undefined {
	if (feedback.feedbackId !== 'macroStatus') return undefined

	const macro = feedback.options.macro
	return {
		...feedback,
		feedbackId: '/Macros/Buttons/state/name',
		options: macro === undefined ? {} : { macro },
	}
}
```

```text
// digico_entities.csv:3
/Macros/Buttons/state/*,Int,0,2,RW,OSC Macro button state and name,,1,indexedRecord
```

```ts
// src/feedbacks.ts:86-95
		const recordDefinition = getEntityRecordDefinition(row.oscPath)
		if (row.feedbackSchema === 'indexedRecord' && recordDefinition?.queryPath) {
			const choices = self.getIndexedRecordChoices(recordDefinition.responsePath)
			feedbacks[row.oscPath] = {
				name: row.name,
				description: row.description,
				type: 'value',
				options: [
					{
						id: 'index_1',
// src/commandTable.ts:109, 117 (oscPath is the raw CSV value)
			const oscPath = get('osc_path').trim()
				oscPath,
```

```text
grep -rn "Buttons/state" src digico_osc.csv digico_entities.csv
src/upgrades.ts:95:		feedbackId: '/Macros/Buttons/state/name',
src/entity-schemas.json:3:		"/Macros/Buttons/state/*": {
digico_entities.csv:3:/Macros/Buttons/state/*,Int,0,2,RW,OSC Macro button state and name,,1,indexedRecord
```

```js
// git show v1.0.4:index.js:345-393 (the feedback being migrated)
		feedbacks.macroStatus = {
			label: 'Change button color for macro state',
			...
				id: 'fg',  ... id: 'bg', ... id: 'macro', min: 1, max: 256, ... id: 'state', ... id: 'name',
			callback: ({ options }, bank) => {
				let channel = options.macro;
				if (options.state == states[channel].status) {
					return { color: options.fg, bgcolor: options.bg, text: macroname[channel].name}
```

```ts
// node_modules/@companion-module/base/dist/module-api/upgrade.d.ts:101-105 (base 2.2.2)
     * If the feedback is being converted to a boolean feedback, the style can be set here.
     * If it is already a boolean feedback or is a different type of feedback, this will be ignored.
     */
    style?: Partial<CompanionFeedbackButtonStyleResult>;
```

**Confirm by:** open [`src/upgrades.ts:95`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L95) and compare the target id `/Macros/Buttons/state/name` with the only macro-state feedback id, which comes from [`digico_entities.csv:3`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_entities.csv#L3) (`/Macros/Buttons/state/*`) and is keyed by `row.oscPath` at [`src/feedbacks.ts:89`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/feedbacks.ts#L89) with the option id `index_1`.

**Fix:** add a boolean feedback that colours the button by macro state, and migrate the old feedback to it with its colours. For example, a "Macro button state" feedback with options `index_1` (the button) and `state` (on/off) and a `defaultStyle`, returning `record.state == state`. Then migrate `macroStatus` to it: `index_1 = { isExpression: false, value: Number(macro.value) - 1 }`, `state` from the old `state` option, and `style: { color: fg.value, bgcolor: bg.value }` taken from the old wrapped `fg`/`bg` options (`style` takes raw values). v2.0.0 was never published, so you can fix the existing upgrade script in place.

### H3: Five dynamic EQ and alternate-solo actions send the command without the chosen value

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`digico_osc.csv:456-459`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_osc.csv#L456-L459), [`digico_osc.csv:500`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_osc.csv#L500)

**What goes wrong:** A user adds "[Input Channels] Eq/Eq Over Under 1" (or bands 2-4, or "[Matrix Outputs] Alternate Solo") and sets Value to 1. On press, the module sends `/Input_Channels/5/EQ/eq_over-under_1` with no value at all, so the chosen setting never reaches the console. These five actions also show a plain 0-1 number field instead of the Off/On/Toggle dropdown that every other on/off parameter gets. Reproduced: the action with Value 1 sent `/Input_Channels/1/EQ/eq_over-under_1 []`.

**Why it happens:** The five CSV rows have the data type `Bfloat` (lower-case f) instead of `BFloat`. The type checks compare the text exactly, so `Bfloat` is recognised neither as an on/off type nor as a float, and the function that builds the OSC arguments returns an empty list for an unknown type.

**Evidence:**

```text
// digico_osc.csv:1
osc_path,data_type,osc_min,osc_max,rw,description,units,Scale
// digico_osc.csv:456-459
/Input_Channels/*/EQ/eq_over-under_1,Bfloat,0,1,RW,EQ band 1 dynamic EQ over/under mode,,1
/Input_Channels/*/EQ/eq_over-under_2,Bfloat,0,1,RW,EQ band 2 dynamic EQ over/under mode,,1
/Input_Channels/*/EQ/eq_over-under_3,Bfloat,0,1,RW,EQ band 3 dynamic EQ over/under mode,,1
/Input_Channels/*/EQ/eq_over-under_4,Bfloat,0,1,RW,EQ band 4 dynamic EQ over/under mode,,1
// digico_osc.csv:500
/Matrix_Outputs/*/alternate_solo,Bfloat,0,1,RW,Matrix output alternate solo state - MAYBE?,,1

Data-type counts in column 2: 148 BFloat, 5 Bfloat, 2 BInt, 463 Float, 18 Int, 12 String.
```

```ts
// src/commandTable.ts:118
				dataType: get('data_type').trim(),
// src/commandTable.ts:137-143
export function isBooleanDataType(dataType: string): boolean {
	return dataType === 'BInt' || dataType === 'BFloat'
}

export function oscDataType(dataType: string): 'Int' | 'Float' | 'String' | undefined {
	return (['Int', 'Float', 'String'] as const).find((type) => type === dataType.replace(/^B/, ''))
}
```

```ts
// src/actions.ts:79-81
function wireArguments(row: CommandRow, value: unknown): OSCSomeArguments {
	const type = oscDataType(row.dataType)
	if (!type) return []
// src/actions.ts:306
		const booleanValue = isBooleanDataType(row.dataType) || (row.dataType === 'Int' && row.min === 0 && row.max === 1)
// src/actions.ts:504-505
			const args = wireArguments(row, value)
			for (const path of paths) self.send_osc(path, args)
// src/valueMappings.ts:16
	if (isBooleanDataType(row.dataType) || (row.dataType === 'Int' && row.min === 0 && row.max === 1)) return 'boolean'
```

**Confirm by:** run `grep -n ',Bfloat,' digico_osc.csv` (5 rows), then open [`src/commandTable.ts:137-143`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/commandTable.ts#L137-L143) and [`src/actions.ts:79-81`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actions.ts#L79-L81). For `Bfloat`, `oscDataType` returns `undefined`, so `wireArguments` returns `[]` and [`src/actions.ts:504-505`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actions.ts#L504-L505) sends the path with no argument.

**Fix:** correct the five rows to `BFloat`, and make the table loader reject unknown data types so a typo can't silently turn an action into a no-value send. In `loadCommandTable()`, map `data_type` case-insensitively to `Int`/`Float`/`String`/`BInt`/`BFloat` and throw on anything else, the way it already does for a bad Scale.

```ts
const DATA_TYPES = ['Int', 'Float', 'String', 'BInt', 'BFloat']
const rawType = get('data_type').trim()
const dataType = rawType && DATA_TYPES.find((type) => type.toLowerCase() === rawType.toLowerCase())
if (rawType && !dataType) throw new Error(`Invalid data_type in ${file}, row ${index + 2}: ${rawType}`)
```

### H4: The CI workflow (node.yaml) differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/.github/workflows/node.yaml#L18)

**What goes wrong:** The CI workflow is not the template's. Leaving aside the Node version lines (covered by [C2](#c2-the-module-still-targets-node-22-but-the-api-22-template-runs-on-node-26)), the lint job's checkout step leaves out the template's `persist-credentials: false`, so the job keeps the GitHub token in the checked-out repo's git config for the rest of the run.

**Why it happens:** The module's `node.yaml` was not copied from the current template.

**Evidence:** validator: `Differs from template (line 16: found '- name: Use Node.js 26.x', template 'with:')`. With the Node version lines normalised, the only difference is the checkout step:

```yaml
# module .github/workflows/node.yaml:18-19
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
# template .github/workflows/node.yaml:18-21
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      - name: Use Node.js 26.x
```

**Confirm by:** `diff .github/workflows/node.yaml <template>/.github/workflows/node.yaml`

**Fix:** copy the template's `node.yaml`. It already has the Node 26 values from [C2](#c2-the-module-still-targets-node-22-but-the-api-22-template-runs-on-node-26).

## 🟡 Medium

### M1: Feedbacks stop updating after the connection settings are saved

- **Source:** 🔎 protocol reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:87-96`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L87-L96), [`src/main.ts:632-637`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L632-L637), [`src/main.ts:553-563`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L553-L563)

**What goes wrong:** A button shows "[Input Channels] Mute" for channel 1, or a snapshot name. The user saves the connection settings (for example changes the Mixer IP Address, or ticks "Enable simultaneous iPad connection"). The connection goes back to OK, but the feedback keeps its last value and no longer follows changes on the console, until the connection is disabled and re-enabled or the feedback's options are edited. Feedbacks can also stay empty after Companion starts, until the value next changes on the console.

**Why it happens:** Saving the settings runs `resetConnectionState()`, which clears the list of feedbacks waiting for console values (`feedbackPaths`). A feedback only gets back on that list when its own callback runs, and nothing in the module asks Companion to re-run the callbacks: `checkAllFeedbacks()` is never called. Callbacks that run before the console has answered the first handshake get no value ([`src/main.ts:121`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L121)) and don't query it later.

**Fix:** re-run every feedback once the console answers. Call `this.checkAllFeedbacks()` in `waitForConsole()` right after `this.handshakeComplete = true` (both places), next to `this.updateStatus(InstanceStatus.Ok)`. That re-registers each feedback and queries its current value after start-up, a reconnect or a settings change. Also stop clearing `feedbackPaths` in `resetConnectionState()`: feedback ids stay valid across a settings change, and `unsubscribe` already removes them.

### M2: One failed UDP send stops all console queries until the connection is restarted

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/mixers.ts:69-74`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/mixers.ts#L69-L74), [`src/mixers.ts:130-139`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/mixers.ts#L130-L139)

**What goes wrong:** If a single send fails (for example Companion starts before the console is powered on or before the network is up, and the OS reports the console's address as unreachable), the module stops sending every query, including the `/Console/Name` handshake it keeps retrying. The status stays at "No response received from connected Mixer" even after the console is up, and Learn, toggles, Relative and Cross-fade don't work until the user re-saves or re-enables the connection. The iPad relay has the same pattern: after one failed send to a sleeping iPad, console updates stop reaching the iPad.

**Why it happens:** The shared UDP socket reports a failed send as an `'error'` event. The module's only error handler treats every error as "the receive port couldn't be opened" and sets `receiveSocketFailed = true`, which only a new bind clears. From then on every query is skipped. `IpadRelay` likewise sets `listening = false` on any error, and `forwardConsolePacket` stops.

**Evidence:**

```ts
// src/mixers.ts:69-74
		this.socket.on('error', (error) => {
			this.receiveSocketListening = false
			this.receiveSocketFailed = true
			instance.updateStatus(InstanceStatus.UnknownError, `OSC receive error: ${error.message}`)
			logger.error(`OSC receive error: ${error.message}`)
		})
// src/mixers.ts:130-139
			if (message.query && !this.receiveSocketListening) {
				if (this.receiveSocketFailed) {
					this.activeQueryPath = undefined
					if (!this.querySocketFailureLogged) {
						this.querySocketFailureLogged = true
						logger.warn(`Skipping OSC queries because UDP ${this.config.receivePort} is not open`)
					}
					message.resolveQuery?.(false)
					continue
```

**Fix:** decide from the socket's real state instead of a flag that never resets. Treat the socket as failed only when it is not bound (`this.socket.boundState === undefined`, after a bind failure or a fatal error), or handle send errors separately: log them and fail only that one query. Do the same in `IpadRelay`.

### M3: The default ports are the reverse of what the help tells users to set up

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:13-21`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/config.ts#L13-L21)

**What goes wrong:** HELP tells the user to set the console's DiGiCo Pad device to Send 7000 / Rcv 7001, and the module to "Receive/listen port: 7000" and "UDP port: 7001". A new connection's defaults are the other way round: Receive Port 7001 and Transmit Port 7000. A user who follows HELP for the console and keeps the module's defaults (they look like the same two numbers) gets "No response received from connected Mixer" and no control. Existing connections are not affected.

**Why it happens:** `DEFAULT_CONFIG` sets `transmitPort: 7000` and `receivePort: 7001`, while [`companion/HELP.md:66-74`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/companion/HELP.md#L66-L74) describes the module listening on 7000 and sending to 7001.

**Fix:** make the defaults match HELP: `receivePort: 7000, transmitPort: 7001`. Or change HELP and the console steps to match the defaults.

### M4: Two DiGiCo connections on the same Receive Port show each other's console data

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/mixers.ts:59-64`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/mixers.ts#L59-L64)

**What goes wrong:** A user controls two consoles (FOH at 10.0.0.20 and Monitors at 10.0.0.30) with two DiGiCo connections, and both consoles send to Companion on 7001, the default Receive Port. Both connections open the port without an error, and each one takes in every reply from both consoles. The FOH channel 1 mute feedback can show the Monitors console's value, a toggle mute on FOH can read the Monitors state and send the wrong value, and channel counts, snapshot and macro lists and the Filename variable get mixed. With the iPad relay on, the FOH iPad also receives the Monitors console's traffic.

**Why it happens:** The module uses Companion's shared UDP socket, which exists so several connections can listen on one port; Companion hands every packet on that port to every connection that joined it. The message callback ignores who sent the packet and processes all of them.

**Fix:** drop packets that don't come from this connection's console:

```ts
this.socket = instance.createSharedUdpSocket('udp4', (packet, remote) => {
	if (this.stopped || remote.address !== this.config.ip) return
	instance.forwardConsoleOscPacket(packet)
	this.receiveQueue.push(packet)
})
```

Optionally do the same in `IpadRelay` (accept only `remote.address === this.config.ipadIp`).

### M5: Renumber Snapshot sets the number 0.01 too low for about 1 in 8 values

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:75-84`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actions.ts#L75-L84)

**What goes wrong:** A user runs "[Snapshots] Renumber Snapshot" with Value 1.15. The console receives 114 and the snapshot becomes 1.14. Values such as 0.29, 0.47, 1.13-1.19 and 2.01 all end up one hundredth too low; across 0.00-327.67, 4313 of the 32768 values are off by one. Reproduced: Value 1.15 sent `{type:'i', value:114}`.

**Why it happens:** The row has Scale 0.01 and type Int. The module divides the value by the scale (1.15 / 0.01 = 114.99999999999999, because of floating-point rounding) and then cuts off the decimals with `Math.trunc` instead of rounding.

**Evidence:**

```ts
// src/actions.ts:75-84
function numberToWire(row: CommandRow, value: number): number {
	return value / row.scale
}

function wireArguments(row: CommandRow, value: unknown): OSCSomeArguments {
	const type = oscDataType(row.dataType)
	if (!type) return []
	if (type === 'String') return [{ type: 's', value: stringValue(value) }]
	const number = numberToWire(row, Number(value ?? 0))
	return type === 'Int' ? [{ type: 'i', value: Math.trunc(number) }] : [{ type: 'f', value: number }]
```

**Fix:** round Int wire values instead of truncating them (`Math.round(number)`), and give the number option a `step` that matches the scale (0.01 here) so the field accepts two decimals.

### M6: Recorded delay, attack, release and hold actions replay at one thousandth of the recorded value

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actionRecorder.ts:27-37`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actionRecorder.ts#L27-L37)

**What goes wrong:** A user turns on Companion's action recorder and sets Input Channel 2's Channel Delay to 50 ms on the console. The recorded "[Input Channels] Channel Delay/Delay" action stores the console's raw value 0.05 as its Value, so pressing the button sends 0.00005 and the delay becomes about 0.05 ms instead of 50 ms. This affects all 72 writable parameters with a Scale of 1000 (delays, attack, release, gate hold). Recorded snapshot, macro and preset actions also get `index_1: [n]` (a list) or an `index_1` field those actions don't read, so their selection comes out wrong. Reproduced: a recorded delay of 0.05 replayed as `/Input_Channels/2/Channel_Delay/delay 0.00005`.

**Why it happens:** The recorder copies the value exactly as it arrived from the console. Action options hold display units (milliseconds here), and the action divides by the scale again when it sends. Learn and feedbacks convert console values to display units (`numberFromWire`), but the recorder doesn't. It also always writes the multi-select form `index_1: [index]`.

**Evidence:**

```ts
// src/actionRecorder.ts:33-37
			if (!isNoArgs(row) && args.length > 0) {
				const value = args[0]
				if (typeof value !== 'number' && typeof value !== 'string' && typeof value !== 'boolean') continue
				options.value = typeof value === 'boolean' ? Number(value) : value
			}
```

**Fix:** convert recorded numbers to display units, as `numberFromWire` does: store `typeof value === 'number' ? value * row.scale : value`. For entity-root actions, whose `index_1` is a single dropdown, store the index as a number instead of `[index]`, and skip recording for `/Presets/...` rows (or write their section-based option ids).

### M7: A running cross-fade can't be stopped, so two fades on the same fader fight each other

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:374`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actions.ts#L374), [`src/actions.ts:492-499`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actions.ts#L492-L499)

**What goes wrong:** An operator presses "[Input Channels] Fader" for Ch 1 with Cross-fade on, Value -inf and Cross-fade duration 10000 ms, then changes their mind and presses another button that fades Ch 1 to 0 dB over 2000 ms. Both fades run at the same time, so the fader jumps between the two curves; when the short fade ends, the long one keeps going and the fader finishes at -inf, not the 0 dB asked for last. Companion's abort action doesn't stop a running fade either, and a fade keeps running after the connection settings are saved. Reproduced: a 600 ms fade to -150 followed 100 ms later by a 200 ms fade to 0 ended at -150.

**Why it happens:** Each cross-fade is its own loop of `setTimeout` steps that can last up to 60 s. Nothing tracks the running fades per path, the callback ignores the abort signal (`context.signal`) that API 2.1+ gives action callbacks for long-running work, and `stopRuntime()` doesn't cancel the fades.

**Evidence:**

```ts
// src/actions.ts:492-499
							const steps = Math.max(1, Math.ceil(duration / 50))
							for (let step = 1; step <= steps; step++) {
								self.send_osc(
									path,
									wireArguments(row, step === steps ? target : interpolate(row, current, target, step / steps)),
								)
								if (step < steps) await new Promise<void>((resolve) => setTimeout(resolve, duration / steps))
							}
```

**Fix:** keep one fade per path and let it be cancelled. Keep a `Map<path, token>` on the instance: each new fade, or a plain set on that path, replaces the token, and the loop exits when its token is no longer current. Use `callback: async (event, context) => { ... }`, check `context.signal.aborted` before each step and make the wait end early on abort. Clear the map in `stopRuntime()` so fades also stop when the connection is disabled or its settings are saved.

### M8: Upgraded v1 buttons from the OSC and S-Range command sets misfire (a fader OFF button sets 0 dB)

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:17-57`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L17-L57), [`src/upgrades.ts:47-51`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L47-L51)

**What goes wrong:** In v1.0.4, users with Command Set "OSC" had "Set fader of channel" values on a 0-1 scale (OFF = 0, 0 dB = 0.75, +10 dB = 1). The upgrade copies those numbers into "[Input Channels] Fader", which is in dB (-150 to +10). So a "fader OFF" button now pushes the channel to 0 dB (unity), a "0 dB" button sets +0.75 dB, and "+10 dB" sets +1 dB. Users with Command Set "S-Range" had "Fire snapshot S-series" and "Fire next/previous snapshot S-series" buttons, and these become unknown actions. Neither HELP nor the README says these command sets were dropped. Users on the iPad command set are not affected by the fader part: its fader values were already in dB.

**Why it happens:** The upgrade script never looks at the old Command Set setting (`series`). Only the iPad set used dB fader values (v1 `CHOICES_FADER_IPAD`); the OSC set used `CHOICES_FADER` on a 0-1 scale. The S-series action ids (`snapshotS`, `snapshotNextS`, `snapshotPrevS`) have no mapping.

**Fix:** read `props.config?.series` in the upgrade script. When it is `OSC`, convert the old 0-1 fader value to dB using the v1 table (a lookup from the `CHOICES_FADER` entry to the matching `CHOICES_FADER_IPAD` entry), or leave those actions unmigrated and log a warning. State in HELP and the README version history that the OSC (`/sd/...`) and S-Range command sets are no longer supported.

### M9: Preset actions and feedbacks lose the picked preset when the console's preset sections change

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:201-231`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actions.ts#L201-L231), [`src/feedbacks.ts:174-216`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/feedbacks.ts#L174-L216)

**What goes wrong:** A user sets "[Presets] Recall Preset" to Section "Input Channels" and a preset. The choice is stored in a field such as `preset_4`, named after the section's position in the sorted section list. If the console's presets later include a section that sorts earlier (another session, or a preset created in a new section), "Input Channels" moves to position 5. The action then reads `preset_5`, which holds that field's default (the first preset of the section), so the button recalls a different preset or does nothing. The target, group and item fields (`target_N`, `group_N`, `index_1_N`) and the sectioned feedbacks shift the same way.

**Why it happens:** The option ids are built from the section's index in `getPresetSections()`, a sorted list partly built from records discovered on the console, while Companion stores saved option values by id.

**Fix:** derive the option ids from a stable slug of the section name instead of its position, for example `preset_${section.toLowerCase().replace(/[^a-z0-9]+/g, '_')}`, in both the action and the sectioned feedback options, and look them up the same way in the callbacks.

### M10: Relative mode can't step a value down when the parameter's range starts at 0

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:151-176`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/actions.ts#L151-L176)

**What goes wrong:** A user picks "[Input Channels] Channel Delay/delay (ms)" (range 0–1300), ticks Relative and enters -10 to make a "delay -10 ms" button. The value field only allows 0–1300, so -10 can't be saved, and in expression mode Companion rejects the out-of-range result and skips the action. 323 adjustable parameters start at 0 or above and can only be stepped up. On the fader (-150 to +10 dB), a relative step larger than +10 dB is also impossible.

**Why it happens:** Relative mode reuses the absolute `value` field, whose min and max are the parameter's absolute range. The relative result (current + entered) is also never clamped to the range before it is sent.

**Fix:** give Relative mode its own field: add `disableAutoExpression: true` to the `relative` checkbox, add a `delta` number field with a symmetric range (`-(max-min)` to `+(max-min)`) and `isVisibleExpression: '$(options:relative)'`, hide `value` while Relative is on, and clamp `current + delta` to `row.min`/`row.max` before sending.

### M11: No feedback can colour a button, so mute, solo or macro state can't light a button directly

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/feedbacks.ts:22`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/feedbacks.ts#L22)

**What goes wrong:** A user wants a button to turn red when Input Channel 5 is muted. v2.0.1 offers "[Input Channels] Mute", but like every feedback in the module it is a value feedback that returns "On"/"Off", and it can't be added to the button's style. The user has to build a local variable from the feedback plus an internal "check expression" feedback for every button. In v1.0.4 the macro feedback coloured the button directly.

**Why it happens:** `FeedbacksSchema` declares every feedback as `type: 'value'`, and `UpdateFeedbacks` only produces value feedbacks. There is no boolean feedback with a `defaultStyle`.

**Fix:** for on/off rows (`isBooleanDataType(row.dataType)`, or Int rows with range 0..1), also generate a boolean feedback, for example `${row.oscPath}#on` with the same selector options and `defaultStyle: { bgcolor: combineRgb(255, 0, 0) }`, returning `value === 1`. Keep the value feedbacks for expressions and local variables. This is also the feedback [H2](#h2-upgraded-macro-state-feedbacks-point-at-a-feedback-that-doesnt-exist-so-macro-buttons-stop-changing-colour) needs as its upgrade target.

### M12: The release workflow (release.yaml) is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** Publishing a GitHub release doesn't build the module package or attach the `.tgz` to the release, because the template's release workflow isn't in the repo.

**Why it happens:** The validator reports `.github/workflows/release.yaml: Required file is missing (tracked by the template)`. `companion-module-checks.yaml` is identical to the template.

**Fix:** add the template's `release.yaml`. It packages the module through the `bitfocus/actions` module checks when a release is published and attaches the `.tgz` to the GitHub release.

### M13: The IP address fields reject hostnames (deprecated Regex.IP)

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:31`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/config.ts#L31), [`src/config.ts:65`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/config.ts#L65)

**What goes wrong:** A user can't enter a hostname (for example `sd12.local`) for Mixer IP Address or iPad IP Address; only a dotted IPv4 address passes validation. On top of that, as soon as Companion asks for the config fields (for example when the user opens the connection settings), the connection log shows the warning "Regex.IP is deprecated. Use IPV4 instead, or preferably allow any text so that hostnames and IPv6 addresses can be entered", once per module process.

**Why it happens:** Both fields use `Regex.IP`, which @companion-module/base 2.2.2 marks `@deprecated`: "Use `IPV4` instead, or preferably a `textinput` field without a regex so that hostnames and IPv6 addresses can be entered". Under API 2.2 (base 2.2.2) deprecated Regex patterns are a Medium. Reading `Regex.IP` is also what writes the warning to the connection log (`node_modules/@companion-module/base/dist/module-api/enums.js:57`, `:88`).

**Fix:** replace `Regex.IP` on both fields. Both fields stay `textinput`, so no upgrade script is needed. One thing to check if you drop the regex to allow hostnames: both shared UDP sockets are created as `createSharedUdpSocket('udp4', ...)` ([`src/mixers.ts:59`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/mixers.ts#L59), [`src/ipadRelay.ts:23`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/ipadRelay.ts#L23)), so an IPv6 address typed into Mixer IP Address or iPad IP Address would then fail silently. So either:

- use `Regex.IPV4`, which matches the `udp4` sockets and is the smallest change; or
- drop the regex (use `minLength: 1`) and create the socket as `'udp6'` when `net.isIPv6(host)` is true.

## 🟢 Low

### L1: iPad relay problems only reach the log, and the connection still shows OK

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:504-514`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L504-L514), [`src/ipadRelay.ts:36-39`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/ipadRelay.ts#L36-L39)

**What goes wrong:** A user ticks "Enable simultaneous iPad connection" and either sets iPad Receive Port to the same value as Receive Port (both 7001, say) or picks a port another program already uses. The iPad app never connects through Companion, but the connection turns green (OK) as soon as the console answers. The only explanation is an error line in the connection log.

**Why it happens:** The equal-port check and the relay's bind-error handler only call `logger.error`. They never call `updateStatus`, and `waitForConsole()` later sets the status to OK.

**Fix:** when the ports clash, set `InstanceStatus.BadConfig` with a message such as "iPad Receive Port must differ from Receive Port". When the relay can't bind, keep a flag and set `InstanceStatus.UnknownWarning` with "iPad relay could not open UDP 7003" instead of OK after the handshake.

### L2: A Receive Port that is already in use shows up as "No response received from connected Mixer"

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:565`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L565)

**What goes wrong:** If the Receive Port (7001, say) is already used by another connection or app, the status briefly shows "OSC receive error: ...", and then the handshake loop replaces it every 2 seconds with the warning "No response received from connected Mixer". The user goes looking at the console or the network instead of the port conflict.

**Why it happens:** `waitForConsole()` sets the warning after every failed handshake without checking whether the receive socket failed to open; when it has, the queries fail immediately.

**Fix:** expose a `failed` getter on the mixer. In `waitForConsole()`, stop retrying when the socket failed to bind and keep an error status such as `InstanceStatus.UnknownError` with "Receive port 7001 unavailable".

### L3: Upgraded channel selections are saved as a single value in a multi-select field

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/upgrades.ts:67-84`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L67-L84)

**What goes wrong:** After the upgrade, a v1.0.4 "Mute channel" button for channel 5 becomes "[Input Channels] Mute" with Input Channel stored as `5` (or the text `'5'`) rather than `[5]`. The action still runs, but when the user opens it, the Input Channel multi-select may show nothing selected, and re-saving the action may drop the channel.

**Why it happens:** The old `channel` value is copied into `index_1` unchanged. The numeric-string conversion only applies to the value options, and `index_1` is now a multi-select that expects a list of numbers. The module's own action recorder writes `[index]` for the same option.

**Fix:** when mapping `channel` to `index_1`, wrap a non-expression value in a list: `{ ...oldValue, value: [Number(oldValue.value)] }`.

### L4: The send and receive queues wake every 5 ms even when idle

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/mixers.ts:122-129`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/mixers.ts#L122-L129), [`src/mixers.ts:170-176`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/mixers.ts#L170-L176)

**What goes wrong:** Each enabled DiGiCo connection runs two loops that wake about 400 times a second while nothing is happening. That costs a little CPU and power on small hosts such as a Raspberry Pi, more so with several connections. There is no other visible effect.

**Why it happens:** `runSendQueue` and `runReceiveQueue` check their arrays in a loop with `await sleep(5)` instead of being woken when work arrives.

**Fix:** process received packets directly in the socket's message callback, or wake the worker with a promise that `push()` resolves when it adds work. Drain the send queue the same way, and use a timer only while a query is waiting.

### L5: Every console name change rebuilds and resends all of the roughly 660 action definitions

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:597-604`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/main.ts#L597-L604)

**What goes wrong:** There is no functional effect. With a 128-input session, each rename on the console (and each `/!` change notice) makes the module rebuild all 659 actions and all feedbacks: about 87 ms of CPU and a 1.5 MB action payload sent to Companion, measured with a stub host. While names stream in during discovery this can repeat several times, and the Companion UI may feel sluggish on large consoles.

**Why it happens:** `scheduleDefinitionRefresh()` calls `updateActions()` and `updateFeedbacks()`, which build the channel list for every row and axis, and each of those scans the whole value cache with a regex, twice.

**Fix:** refresh once when discovery ends (or lengthen the debounce during discovery), and cache the choices per selector and section so each list is built once per refresh instead of once per row.

### L6: Commands marked MAYBE? are shown to users as normal actions and feedbacks

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`digico_osc.csv:2`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_osc.csv#L2), [`digico_osc.csv:162`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_osc.csv#L162), [`digico_osc.csv:166`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_osc.csv#L166), [`digico_osc.csv:500`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_osc.csv#L500), [`digico_entities.csv:2`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/digico_entities.csv#L2)

**What goes wrong:** In the action list users see entries such as "[Console] Session/!" described as "Command trigger or query response - MAYBE?", and "[Aux Outputs] Alternate Solo" described as "Aux output alternate solo state - MAYBE?". The descriptions tell users the command may not do what it says. There are 16 such rows: `digico_osc.csv` lines 2, 162, 166, 208, 223, 342, 343, 365, 374, 485, 486, 494, 498, 499 and 500, plus `digico_entities.csv` line 2.

**Why it happens:** The descriptions come straight from the CSV tables, where these rows were marked as unverified.

**Fix:** verify these rows and remove "- MAYBE?" from their descriptions, or leave unverified rows out of the command table (for example with an empty `rw`) until they are confirmed.

### L7: The upgrade script's log messages don't reach the connection log

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:107-112`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/upgrades.ts#L107-L112)

**What goes wrong:** Nothing visible changes in Companion. The before/after messages the upgrade script prints only reach the debug output, not the connection's log, so support can't see them when troubleshooting an upgrade.

**Why it happens:** The script uses `console.log` instead of the module logger that the rest of the module uses.

**Fix:** use `const logger = createModuleLogger('upgrade')` and `logger.debug(...)` in place of `console.log`.

### L8: The help page doesn't cover the iPad relay, actions, feedbacks or variables, and has broken formatting

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:1-3`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/companion/HELP.md#L1-L3), [`companion/HELP.md:44-52`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/companion/HELP.md#L44-L52), [`companion/HELP.md:158`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/companion/HELP.md#L158)

**What goes wrong:** Users reading the help in Companion find only console setup. Nothing explains the "Enable simultaneous iPad connection" settings, how to pick channels or use "All", that the feedbacks are value feedbacks (and how to use them for colours), or what the count and Filename variables contain. The port table under step 4 renders as loose text ("Setting Value" / "---"), the page starts with a stray "## companion-module-digico" heading, and line 158 ends mid-sentence ("Keeping **Bundles** off").

**Why it happens:** HELP.md was written as a console setup guide and not extended to the module's own settings and features.

**Fix:** add sections for the connection settings (including the iPad relay), the actions and feedbacks, and the variables. Turn step 4 into a proper Markdown table, remove the stray heading and finish the Bundles sentence.

## 💡 Nice to Have

### N1: Count variables are named like sections, not counts

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:4-13`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/src/variables.ts#L4-L13)

**What goes wrong:** In the variable list users see "Input Channels" or "Aux Outputs", but the value is a number such as 48, so it isn't obvious that these are counts.

**Fix:** name them, for example, "Input channel count" or "Aux output count". Only the display names change; the variable ids stay the same.

### N2: The README version history describes the rewrite as a version-number change only

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:12-14`](https://github.com/bitfocus/companion-module-digico-osc/blob/0602e2229ee11056f380ebecedd1d6499acc3134/README.md#L12-L14)

**What goes wrong:** Users upgrading from 1.0.4 read "Version change only to appear after the current 1.0.4" for 2.0.0, and there is no 2.0.1 entry. Nothing warns them about the new connection settings, the dropped command sets or the renamed actions.

**Fix:** describe 2.0.0 as the API v2 rewrite, listing what changes for existing users (connection settings, iPad command set only, new action names), and add a 2.0.1 entry.

## 📝 Additional Notes

- `tsconfig.build.json` adds `"resolveJsonModule": true` to `compilerOptions`, which the template does not have. The module builds, so no change is required. (The `extends` preset is covered by [C2](#c2-the-module-still-targets-node-22-but-the-api-22-template-runs-on-node-26).)
- API compliance was re-checked on 2026-11-06 against the API 2.2 rules (companion-v2-api-compliance 1.2.0): the value feedback schema already declares `result: JsonValue`, and there are no Companion presets, so no `storeResult` is needed. The only deprecated Regex is `Regex.IP` (see [M13](#m13-the-ip-address-fields-reject-hostnames-deprecated-regexip)), and there are no unknown Regex keys. The `udp4` sockets are not an IPv6 finding, because the host fields only accept IPv4 for now. All variable ids are valid and come from the module's bundled tables, not from device data.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Existing v1.0.4 connections still hold their settings under the v1 keys (`host`, `port`, `receiveport`, `series`), and Companion passes them, with the v1 action and feedback ids, to this module's upgrade script unchanged. Companion does not rename or carry over config keys by itself | v1.0.4 `config_fields`; base 2.2.2 `upgrade.d.ts`, where `updatedConfig` is the only way an upgrade can change config; the module's own script maps v1 ids. Companion's host code and its legacy wrapper not checked | [H1](#h1-upgrading-from-v104-loses-the-saved-console-ip-and-ports-so-no-button-reaches-the-console), [H2](#h2-upgraded-macro-state-feedbacks-point-at-a-feedback-that-doesnt-exist-so-macro-buttons-stop-changing-colour), [M8](#m8-upgraded-v1-buttons-from-the-osc-and-s-range-command-sets-misfire-a-fader-off-button-sets-0-db), [L3](#l3-upgraded-channel-selections-are-saved-as-a-single-value-in-a-multi-select-field) |
| A2 | The console does not apply a value from an OSC set message that has no argument (it ignores it or treats it as a query), and `BFloat` is the intended type for these five rows | the module itself sends argument-less messages as queries (`src/main.ts:534`); the 148 other on/off rows use `BFloat` | [H3](#h3-five-dynamic-eq-and-alternate-solo-actions-send-the-command-without-the-chosen-value) |
| A3 | Companion shows a migrated feedback whose id no longer exists as an unknown feedback and never runs it | how Companion matches feedback ids to definitions; not tested live | [H2](#h2-upgraded-macro-state-feedbacks-point-at-a-feedback-that-doesnt-exist-so-macro-buttons-stop-changing-colour) |
| A4 | In Companion 5 a value feedback can't be added to a button's style; only boolean feedbacks colour a button directly | companion-v2-feedbacks reference (value feedbacks are for expressions, local variables and layered graphics); not tested live | [H2](#h2-upgraded-macro-state-feedbacks-point-at-a-feedback-that-doesnt-exist-so-macro-buttons-stop-changing-colour), [M11](#m11-no-feedback-can-colour-a-button-so-mute-solo-or-macro-state-cant-light-a-button-directly) |
| A5 | Companion does not re-run feedback callbacks by itself after `configUpdated()` or after the module calls `setFeedbackDefinitions()` again; callbacks only run on subscribe, on option edits, or on `checkFeedbacks*()` / `checkAllFeedbacks()` | base 2.2.2 `setFeedbackDefinitions` only forwards the definitions to the host; host behaviour not checked | [M1](#m1-feedbacks-stop-updating-after-the-connection-settings-are-saved) |
| A6 | The Companion host rejects a shared-UDP-socket send when the OS reports a send error (for example EHOSTDOWN or ENETUNREACH while the console is off or the network is not up yet) | base 2.2.2 turns a rejected send into an `'error'` event on the socket (verified); whether and when the host rejects is host- and OS-specific | [M2](#m2-one-failed-udp-send-stops-all-console-queries-until-the-connection-is-restarted) |
| A7 | Companion's shared UDP socket delivers every datagram on a port to every connection that joined that port | base 2.2.2 doc comment on `createSharedUdpSocket`; the fan-out happens in the host | [M4](#m4-two-digico-connections-on-the-same-receive-port-show-each-others-console-data) |
| A8 | Companion's number field accepts a decimal entry such as 1.15 when no `step` is set (or the value comes from an expression) | Companion UI behaviour; the truncation itself was reproduced | [M5](#m5-renumber-snapshot-sets-the-number-001-too-low-for-about-1-in-8-values) |
| A9 | The preset sections the console reports can change in normal use (another session loaded, or a preset created in a new section) | sections come partly from console preset records (`src/main.ts:211-226`), which are session data | [M9](#m9-preset-actions-and-feedbacks-lose-the-picked-preset-when-the-consoles-preset-sections-change) |
| A10 | In value mode, Companion's number field won't save a value below the field's `min` | v2.0 reference "Expression validation" row; base typings call min/max UI hints | [M10](#m10-relative-mode-cant-step-a-value-down-when-the-parameters-range-starts-at-0) |
| A11 | Companion's multi-select editor does not show a single (non-array) value as selected, and re-saving keeps only array values | the multidropdown option type expects an array of choice ids; Companion UI not checked | [L3](#l3-upgraded-channel-selections-are-saved-as-a-single-value-in-a-multi-select-field) |
| A12 | When the module sends through a `'udp4'` shared socket, Companion's host resolves a hostname such as `sd12.local` to an IPv4 address and can't send to an IPv6 address on that socket | the v2.2 reference ("A shared UDP socket can only send to its own family") and how Node `dgram` behaves; the send happens in the Companion host, which was not checked | [M13](#m13-the-ip-address-fields-reject-hostnames-deprecated-regexip) |
