# Review: companion-module-stagetec-xci v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-stagetec-xci` |
| **Scope** | `tag` (`v1.3.1..v2.0.0`) |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.3.1 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`1bee6c4`](https://github.com/bitfocus/companion-module-stagetec-xci/tree/1bee6c414a5ece863070c006649b51dff22dce4c) |
| **Reviewed** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: Yarn config allows installing packages from any git repository, unlike the template](#c1-yarn-config-allows-installing-packages-from-any-git-repository-unlike-the-template)

### Non-blocking

- [ ] [M1: The Logic Cell field stops following Reset All once Reset All is switched to an expression](#m1-the-logic-cell-field-stops-following-reset-all-once-reset-all-is-switched-to-an-expression)
- [ ] [L1: Connection stays yellow with "Reading the logic cells failed" after the XCI comes online](#l1-connection-stays-yellow-with-reading-the-logic-cells-failed-after-the-xci-comes-online)
- [ ] [N1: Code comment describes crosspoint and alarm feedbacks this module doesn't have](#n1-code-comment-describes-crosspoint-and-alarm-feedbacks-this-module-doesnt-have)
- [ ] [N2: Spelling errors in the Help text and a connection log message](#n2-spelling-errors-in-the-help-text-and-a-connection-log-message)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Yarn config allows installing packages from any git repository, unlike the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/.yarnrc.yml#L1-L2)

**What goes wrong:** This release adds a setting to the module's Yarn config that approves installs from every git repository (`approvedGitRepositories: ["**"]`). The module has no git dependencies, in `package.json` or in `yarn.lock`, so the setting does nothing today except remove a safeguard. If a dependency ever pulls in a package straight from a git repository, Yarn installs it without question. The official template doesn't have this setting.

**Why it happens:** Yarn 4 blocks dependencies fetched from git repositories unless they are listed under `approvedGitRepositories` in `.yarnrc.yml`. The `"**"` pattern matches every repository, so the check is switched off. The key is new in this release (`git diff v1.3.1..v2.0.0 -- .yarnrc.yml`).

**Evidence:** `.yarnrc.yml:1-2` has `approvedGitRepositories` with the single entry `"**"` (quoted below). It is not in `companion-module-template-ts` @ `e0d42b7` (main), whose `.yarnrc.yml` has only `enableScripts: false`, `nodeLinker: node-modules`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages: ["@companion-module/*"]`.

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - "**"
```

**Confirm by:** rerun `validate-template.ps1` and check that the CONFIG-DIFF is gone, or compare [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/.yarnrc.yml) with the template's file.

**Fix:** delete the `approvedGitRepositories` block, so `.yarnrc.yml` matches the template's keys.

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

## 🟡 Medium

### M1: The Logic Cell field stops following Reset All once Reset All is switched to an expression

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:9-30`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/options.ts#L9-L30), [`src/actions.ts:25-40`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/actions.ts#L25-L40)

**What goes wrong:** A user edits a Reset Latch or Reset Count action on a button. The Logic Cell field is shown only while Reset All is off. In Companion 5 almost every option has a toggle that switches it into expression mode, and Reset All has one too. Say the user switches Reset All to expression mode and enters `$(local:resetAll)`. The Logic Cell field no longer follows what that expression works out to: it can stay hidden while the expression is false, so the user can't pick which cell to reset (see [A1](#-assumptions-to-confirm)). Users who leave Reset All as a plain checkbox are not affected.

**Why it happens:** The Logic Cell field has a show/hide rule (its `isVisibleExpression`) that reads the Reset All checkbox through `!$(options:all)`. Companion only supports this for options that can't be switched to an expression, which is what `disableAutoExpression: true` does. Reset All doesn't set it. The base package's typings say so directly: "you can only reference fields which are set to `disableAutoExpression` here". The rule is new in v2.0.0. v1.3.1 had the same kind of rule, but it ran on API 1 (base `~1.14.1`), which had no expression mode.

**Evidence:**

```ts
// src/options.ts:9-30
export function cellOption(isVisibleExpression?: string): CompanionInputFieldNumber<'cell'> {
	return {
		id: 'cell',
		type: 'number',
		label: 'Logic Cell',
		...
		tooltip: 'Refer to Nexus Service for Logic Cell number',
		...(isVisibleExpression === undefined ? {} : { isVisibleExpression }),
	}
}

export const allCellsOption: CompanionInputFieldCheckbox<'all'> = {
	id: 'all',
	type: 'checkbox',
	label: 'Reset All',
	default: false,
}
```

```ts
// src/actions.ts:25-40
		[ActionId.ResetLatch]: {
			name: 'Reset Latch',
			options: [cellOption('!$(options:all)'), allCellsOption],
			callback: ({ options }) => {
				if (options.all) self.resetAllLatches()
				else self.resetLatch(Math.floor(options.cell))
			},
		},
		[ActionId.ResetCount]: {
			name: 'Reset Count',
			options: [cellOption('!$(options:all)'), allCellsOption],
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:35-44  (base 2.2.2)
     * You can access a value of the current options using `$(options:some_field_id)`.
     * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
     */
    isVisibleExpression?: string;
    /**
     * Whether to disable support for toggling this field to be an expression
     * Danger: Be careful if setting this to true for an existing option, if the user has already defined an expression for this,
     * it will no longer be parsed and will break their configuration.
     */
    disableAutoExpression?: boolean;
```

**Confirm by:** open [`src/options.ts:25-30`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/options.ts#L25-L30). Reset All has no `disableAutoExpression: true`, but [`src/actions.ts:27`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/actions.ts#L27) and [`src/actions.ts:35`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/actions.ts#L35) reference it through `!$(options:all)`. Compare with the note in `node_modules/@companion-module/base/dist/module-api/input.d.ts:36`.

**Fix:** turn off expression mode for Reset All. An on/off "Reset All" choice isn't useful as an expression anyway. Now is the safe time to do it: expression mode is new to this module in v2.0.0, so no saved button can have an expression on Reset All yet, while the base typings warn that adding the flag later breaks expressions users have saved. Update the option fixtures and tests to match. The alternative is to drop the show/hide rule and always show Logic Cell. See the companion-v2-actions skill.

```ts
export const allCellsOption: CompanionInputFieldCheckbox<'all'> = {
	id: 'all',
	type: 'checkbox',
	label: 'Reset All',
	default: false,
	disableAutoExpression: true,
}
```

## 🟢 Low

### L1: Connection stays yellow with "Reading the logic cells failed" after the XCI comes online

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:214-225`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/main.ts#L214-L225), [`src/main.ts:256-259`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/main.ts#L256-L259), [`src/main.ts:266-271`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/main.ts#L266-L271), [`src/main.ts:286`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/main.ts#L286)

**What goes wrong:** Companion starts before the XCI answers, for example after a venue power-up while the XCI card is still booting. The first read of the logic cells times out, and the connection turns yellow with "Reading the logic cells failed: Request timed out". A few seconds later the XCI is reachable: the Nexus status poll succeeds, the base device variables fill in, and traps arrive. The connection still stays yellow with the same message until someone presses the Refresh action or re-saves the connection settings, and nothing in the UI says so. Also, the XCI SNMP Trap feedbacks never get the cells' starting state: a cell that is already true shows false until its next trap.

**Why it happens:** The logic cells are read only once when polling starts (and by the Refresh action). The repeating loop retries only the Nexus status read. When a status read succeeds, it sets only its own part of the connection status to OK. The logic cell part keeps its warning, and the connection always shows the worst part, so the warning never clears.

**Fix:** when a status read succeeds and the last logic cell read failed, read the logic cells again. For example, keep a flag that the logic cell read sets, and check it after the status read.

```ts
// in #pollStatus, after this.#status.set('status', InstanceStatus.Ok)
if (!this.#cellsOk) void this.#pollLogicCells(client, signal)
```

Alternatively, retry the logic cell read on the status interval until it succeeds once.

## 💡 Nice to Have

### N1: Code comment describes crosspoint and alarm feedbacks this module doesn't have

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/subscriptions.ts:1-7`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/subscriptions.ts#L1-L7)

**What goes wrong:** Users see no difference; this is a code comment only. The new comment above the feedback subscription helper says feedbacks are registered "a crosspoint feedback by its destination, an alarm feedback by its alarm" and that "the router reports a change". It reads as copied from a router module. Here the key is the logic cell number, so the comment misleads the next person who maintains the code.

**Fix:** reword the comment to describe this module: the trap and latched-trap feedbacks are registered by the logic cell (1-256) their options name, so a trap for a cell only rechecks the feedbacks reading that cell.

### N2: Spelling errors in the Help text and a connection log message

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:17`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/companion/HELP.md#L17), [`companion/HELP.md:91`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/companion/HELP.md#L91), [`src/main.ts:408`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/main.ts#L408)

**What goes wrong:** A user reading the module's Help sees "recieved" (line 17, edited in this release) and "most recently occured" (line 91, new). The connection log shows "Nexus error occured: node 3 code 69 ...". These are cosmetic typos with no functional effect.

**Why it happens:** These are misspellings of "received" and "occurred". The MIB names its trap `errorOccured`, and that spelling has spread into the prose and the log text.

**Fix:** use "received" and "occurred" in [`companion/HELP.md:17`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/companion/HELP.md#L17) and [`companion/HELP.md:91`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/companion/HELP.md#L91), and in the log text at [`src/main.ts:408`](https://github.com/bitfocus/companion-module-stagetec-xci/blob/1bee6c414a5ece863070c006649b51dff22dce4c/src/main.ts#L408) (`occured ? 'occurred' : 'removed'`). Keep the MIB identifiers (`errorOccured`) as they are. While editing, you could also fix the older "recieved" and "reciever" spellings in `companion/HELP.md` (lines 5, 13, 75, 79 and 83) and the `companion/manifest.json` description, which predate this release.

## 📝 Additional Notes

- API compliance was re-checked on 2026-11-06 against the API 2.2 rules (companion-v2-api-compliance 1.2.0): the API 2.2 rules (base 2.2.2 from `yarn.lock`, `package.json` `~2.2.2`) and the v2.0 variable-id rule found nothing in the whole module (no Regex patterns, value feedback results, preset results, UDP/IPv6 or variable-id problems). C1, M1, L1, N1 and N2 are not covered by any 2.2 rule, so none of them change.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When Reset All is switched to expression mode, Companion's action editor no longer applies the expression's result to the Logic Cell field's show/hide rule, so the field stops following it (it either always hides or always shows, depending on whether the editor reads the expression text or an empty value) | The `@companion-module/base` 2.2.2 doc comment on `isVisibleExpression` (`dist/module-api/input.d.ts:36`) says such references aren't allowed. It doesn't say what the editor then shows. Companion's UI source wasn't checked and this wasn't live-tested | [M1](#m1-the-logic-cell-field-stops-following-reset-all-once-reset-all-is-switched-to-an-expression) |
