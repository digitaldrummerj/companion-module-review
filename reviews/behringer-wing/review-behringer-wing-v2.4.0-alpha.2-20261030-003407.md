# Review: behringer-wing @ v2.4.0-alpha.2 (follow-up to v2.4.0-alpha.1)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-behringer-wing` |
| **Scope** | `tag` (`v2.3.1..v2.4.0-alpha.2`) |
| **Version** | `v2.4.0-alpha.2` |
| **Release** | Update — last published v2.3.1 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`cc16453`](https://github.com/bitfocus/companion-module-behringer-wing/tree/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4) |
| **Previous review** | [v2.4.0-alpha.1](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md) (❌ Changes Required) |
| **Build** | ✅ `yarn install --immutable`, `yarn package`, `yarn lint` |
| **Reviewed** | 2026-10-30 |

This is a follow-up to the v2.4.0-alpha.1 review. Every finding from that review was fixed except two: the two "To" dropdowns on send actions (alpha.1 L4, now [M1](#m1-send-actions-always-show-two-to-dropdowns-so-main-sources-can-hit-the-wrong-send)) and the channel names in presets (alpha.1 N3, now [N2](#n2-channel-presets-do-not-show-the-consoles-channel-name)). The new upgrade script that fixes alpha.1 C3 introduces one new blocking problem ([H1](#h1-send-actions-and-the-send-mute-feedback-that-used-variables-stop-working-after-the-upgrade)). The two Critical items come from the template: since the alpha.1 review the API 2.1 template moved to Node 26 (2026-10-08) and now also checks `.github/**` and `.husky/*` against the module.

---

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion checks the computed value of every dropdown option in expression mode against its choices, including options the callback never reads, and skips the whole action or feedback when a value is not one of the choices | The `allowInvalidValues` doc comment in `node_modules/@companion-module/base/dist/module-api/input.d.ts:45-51` (base 2.1.3); Companion's host source was not checked | [H1](#h1-send-actions-and-the-send-mute-feedback-that-used-variables-stop-working-after-the-upgrade) |
| A2 | Some v2.3.x users ticked "Use Variables for Source and Destination" on a send action or feedback, with a Channel/Aux/Bus source and a Bus/Main destination | The option existed in v2.3.1; real-world use can't be confirmed from code | [H1](#h1-send-actions-and-the-send-mute-feedback-that-used-variables-stop-working-after-the-upgrade) |
| A3 | Companion's action/feedback editor shows every option that has no `isVisibleExpression`, so both "To" dropdowns appear together with the same label | Standard Companion option rendering; the module sets no visibility rule on either field | [M1](#m1-send-actions-always-show-two-to-dropdowns-so-main-sources-can-hit-the-wrong-send) |

## 📋 Issues

### Blocking

- [ ] [C1: Module runs on Node 22 although API 2.1 modules must use Node 26](#c1-module-runs-on-node-22-although-api-21-modules-must-use-node-26)
- [ ] [C2: Git pre-commit hook differs from the template](#c2-git-pre-commit-hook-differs-from-the-template)
- [ ] [H1: Send actions and the Send Mute feedback that used variables stop working after the upgrade](#h1-send-actions-and-the-send-mute-feedback-that-used-variables-stop-working-after-the-upgrade) — ⚠️ please validate first; we are not sure it is valid

### Non-blocking

- [ ] [M1: Send actions always show two To dropdowns, so Main sources can hit the wrong send](#m1-send-actions-always-show-two-to-dropdowns-so-main-sources-can-hit-the-wrong-send)
- [ ] [M2: Release workflow from the template is missing](#m2-release-workflow-from-the-template-is-missing)
- [ ] [M3: CI workflow builds on Node 18 instead of the module's runtime](#m3-ci-workflow-builds-on-node-18-instead-of-the-modules-runtime)
- [ ] [M4: Bug report issue template differs from the template](#m4-bug-report-issue-template-differs-from-the-template)
- [ ] [M5: Issue template config differs from the template](#m5-issue-template-config-differs-from-the-template)
- [ ] [M6: Feature request issue template differs from the template](#m6-feature-request-issue-template-differs-from-the-template)
- [ ] [L1: Connection status stays at Connecting forever when the console is off or the IP is wrong](#l1-connection-status-stays-at-connecting-forever-when-the-console-is-off-or-the-ip-is-wrong)
- [ ] [N1: Action and feedback options are not type-checked against a schema](#n1-action-and-feedback-options-are-not-type-checked-against-a-schema)
- [ ] [N2: Channel presets do not show the console's channel name](#n2-channel-presets-do-not-show-the-consoles-channel-name)

### Fixed since v2.4.0-alpha.1

- [x] [C3: Removed Use Variables and percentage options have no upgrade script](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#c3-removed-use-variables-and-percentage-options-have-no-upgrade-script) (new upgrade script; see H1 for one gap in it)
- [x] [H1: Text fields no longer substitute variables in value mode](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#h1-text-fields-no-longer-substitute-variables-in-value-mode)
- [x] [H2: Base dependency range does not pin the 2.1 API](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#h2-base-dependency-range-does-not-pin-the-21-api)
- [x] [M1: New last-message status variables are never set](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#m1-new-last-message-status-variables-are-never-set)
- [x] [M2: Main/Alt status variable definition removed but still set](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#m2-mainalt-status-variable-definition-removed-but-still-set)
- [x] [M3: isVisibleExpression references fields that can become expressions](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#m3-isvisibleexpression-references-fields-that-can-become-expressions)
- [x] [M4: Set Delay Mode amount fields pass the visibility rule as the tooltip](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#m4-set-delay-mode-amount-fields-pass-the-visibility-rule-as-the-tooltip)
- [x] [L1: Debug Mode config option no longer does anything](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#l1-debug-mode-config-option-no-longer-does-anything)
- [x] [L2: Set SOF now honours Toggle, changing existing buttons](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#l2-set-sof-now-honours-toggle-changing-existing-buttons)
- [x] [L3: getStringWithVariables casts instead of converting](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#l3-getstringwithvariables-casts-instead-of-converting)
- [x] [L5: Preset option values do not match dropdown choice ids](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#l5-preset-option-values-do-not-match-dropdown-choice-ids)
- [x] [N1: WingInstance import in state.ts should be type-only](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#n1-winginstance-import-in-statets-should-be-type-only)
- [x] [N2: Dropdowns give no list of valid ids for expression mode](review-behringer-wing-v2.4.0-alpha.1-20261005-024911.md#n2-dropdowns-give-no-list-of-valid-ids-for-expression-mode)

---

## 🔴 Critical

### C1: Module runs on Node 22 although API 2.1 modules must use Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW (this release moves the module to API 2.1; the API 2.1 template switched to Node 26 on 2026-10-08, after the alpha.1 review)
- **File:** [`companion/manifest.json:22-23`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/companion/manifest.json#L22-L23), [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/tsconfig.build.json)

**What goes wrong:** This release moves the module from `@companion-module/base` `~1.13` to `~2.1.3` (API 2.1), but the manifest still asks Companion to run it on Node 22. Every API 2.1 module is expected to match the API 2.1 template, which runs on Node 26. A module that runs on a different runtime than its template makes later troubleshooting confusing for both the maintainer and Bitfocus.

**Why it happens:** `runtime.type` in the manifest was left at `"node22"` during the API migration. `tsconfig.build.json` also changed in this release: it no longer extends a preset and inlines its own compiler options (Node16 module, nodenext resolution, es2022 target) instead of extending the template's Node 26 preset.

**Evidence:**

```text
validate-template: runtime.type 'node22' should be 'node26' to match the API 2.1 template; also extend '@companion-module/tools/tsconfig/node26/recommended.json' in tsconfig.build.json, as the template does
```

```json
// companion/manifest.json:22-23
"runtime": {
	"type": "node22",
```

**Confirm by:** open [`companion/manifest.json:23`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/companion/manifest.json#L23) (`"node22"`) and compare with the template's `"node26"`.

**Fix:** switch the runtime to Node 26 and build with the template's Node 26 TypeScript preset.

```json
// companion/manifest.json
"runtime": {
	"type": "node26",
```

```json
// tsconfig.build.json (as in the template)
{
	"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
	"include": ["src/**/*.ts"],
	"exclude": ["node_modules/**", "src/**/*spec.ts", "src/**/__tests__/*", "src/**/__mocks__/*"],
	"compilerOptions": {
		"outDir": "./dist",
		"rootDir": "./src",
		"verbatimModuleSyntax": true
	}
}
```

To match the template fully, also set `engines.node` to `^26` and `@types/node` to `^26.6.4` in `package.json`, and use Node 26 in CI (see [M3](#m3-ci-workflow-builds-on-node-18-instead-of-the-modules-runtime)).

### C2: Git pre-commit hook differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** ⚠️ Pre-existing (unchanged since v2.3.1, commit `6933385`; the validator now compares `.husky/*`)
- **File:** [`.husky/pre-commit`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/.husky/pre-commit)

**What goes wrong:** The template's pre-commit hook only runs `lint-staged`. This module's hook also regenerates `companion/HELP.md` and stages it on every commit. A contributor who expects the template's behaviour gets an extra file changed and added to their commit without asking for it.

**Why it happens:** After `lint-staged`, the module's hook adds a `#!/bin/sh` line, a comment, `node scripts/update-actions-md.js` and `git add companion/HELP.md`.

**Evidence:**

```text
validate-template: Differs from template (line 2: found '#!/bin/sh', template '<missing>')
```

```bash
# .husky/pre-commit
lint-staged
#!/bin/sh

# Husky pre-commit hook to update companion/HELP.md with all action names and descriptions
node scripts/update-actions-md.js
git add companion/HELP.md
```

**Confirm by:** open [`.husky/pre-commit`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/.husky/pre-commit) and compare with the template's one-line `lint-staged`.

**Fix:** reduce the hook to the template's single line, and run `scripts/update-actions-md.js` yourself (for example as a `package.json` script) when actions change.

```bash
lint-staged
```

---

## 🟠 High

### H1: Send actions and the Send Mute feedback that used variables stop working after the upgrade

- **Source:** 🔎 compliance reviewer — verified · ⚠️ needs maintainer validation
- **Classification:** 🆕 NEW (the upgrade script that fixes alpha.1 C3)
- **File:** [`src/upgrades.ts:76-82`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/upgrades.ts#L76-L82)

> **⚠️ Please validate before changing code.** We are not sure this finding is valid. It depends on how Companion handles a dropdown whose expression value is not in its choices (assumptions [A1](#-assumptions-to-confirm) and [A2](#-assumptions-to-confirm)), which we could not confirm from the module code alone. Please run the live check under **Confirm by** below. If the upgraded button still works, tell us in Slack and we will drop H1. If it does nothing, apply the fix.

**What goes wrong:** Take a user on v2.3.1 with a "Set Send Level" button that has "Use Variables for Source and Destination" ticked, From = `$(custom:src)` (resolving to `/ch/1`) and To = `$(custom:dest)` (resolving to `/bus/3`). After updating to 2.4.0, the upgrade writes the same `$(custom:dest)` expression into both "To" fields. The second "To" only lists Matrices, so `/bus/3` is not one of its choices, and Companion skips the whole action: the button does nothing. The same happens to every send action that used variables (Set/Store/Restore/Adjust/Undo Send Level, Set Send Mute) whenever the source is a Channel, Aux or Bus and the destination is a Bus or Main. A "Send Mute" feedback converted the same way never lights up. Users have to re-enter the option by hand. Send actions that never used variables are not affected.

**Why it happens:** Send actions have two destination dropdowns: `dest` (Buses, Mains and Matrices, used for Channel/Aux/Bus sources) and `mainDest` (Matrices only, used for Main sources). The upgrade copies the old destination variable text into both of them, whatever the source is. A variable written into a dropdown becomes an expression, and in base 2.1.3 an expression whose value is not one of the dropdown's choices makes Companion skip the whole action or feedback, unless the field sets `allowInvalidValues`. The module's callback only reads `mainDest` when the source starts with `/main`, but the check happens before the callback runs.

**Evidence:**

```ts
// src/upgrades.ts:75-82
	// Send source/destination variables
	if (options.send_src_dest_use_variables !== undefined) {
		if (options.send_src_dest_use_variables?.value === true) {
			options.src = legacyVariableTextToValue(options.send_src_variables, options.src)
			const dest = legacyVariableTextToValue(options.send_dest_variables, options.dest)
			options.dest = dest
			options.mainDest = dest
		}
```

```ts
// src/upgrades.ts:176  (the same conversion is applied to feedbacks)
			if (upgradeLegacyVariableOptions(feedback.options, [])) updatedFeedbacks.push(feedback)
```

```ts
// src/actions/common.ts:119-124  (identical in src/feedbacks/common.ts:32-37)
	const channelAuxBusSendDestinations = [
		...state.namedChoices.busses,
		...state.namedChoices.mains,
		...state.namedChoices.matrices,
	]
	const mainSendDestinations = [...state.namedChoices.matrices]
```

```ts
// src/choices/common.ts:188-191 + 82-90  (GetDropdown sets no allowInvalidValues)
		GetDropdown('From', 'src', sendSources),
		GetDropdown('To', 'dest', channelAuxBusSendDestinations),
		GetDropdown('To', 'mainDest', mainSendDestinations),
...
		return {
			type: 'dropdown',
			label: label,
			id: id,
			default: defaultChoice ?? choices[0].id ?? '',
			choices: choices,
			tooltip: tooltip,
			expressionDescription: GetChoiceIdDescription(choices),
		}
```

```js
// node_modules/@companion-module/base/dist/module-api/upgrade.js:151-157  (a "$(custom:dest)" string becomes expression mode)
        if (trimmedStr.startsWith('$(') && trimmedStr.endsWith(')') && !trimmedStr.slice(2).includes('$(')) {
            // It does, so we can treat that as a plain expression!
            return {
                isExpression: true,
                value: oldValRaw,
            };
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:45-51  (base 2.1.3)
     * Enabling this will tell companion to validate the value of this field against the definition of the field.
     * If the computed value for this option does not match the validation rules, it will be passed through unchanged.
     * If this is not set, then any invalid value will result in the action/feedback being skipped entirely.
     * Note: This only applies when in expression mode.
     */
    allowInvalidValues?: boolean;
```

```ts
// src/actions/utils.ts:121-126  (the callback reads only one of the two fields)
	if (src.startsWith('/main')) {
		dest = getStringWithVariables(event, 'mainDest')
	} else {
		dest = getStringWithVariables(event, 'dest')
	}
```

**Confirm by:** open [`src/upgrades.ts:81`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/upgrades.ts#L81) (`options.mainDest = dest` is written whatever the source is), then [`src/actions/common.ts:124`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/actions/common.ts#L124) (`mainDest` offers matrices only) and [`src/choices/common.ts:82-90`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/choices/common.ts#L82-L90) (no `allowInvalidValues`). To check live: on 2.3.1 make a Set Send Level button with variables (src = `/ch/1`, dest = `/bus/3`), upgrade to 2.4.0-alpha.2 and press it.

**Fix:** let the unused destination field hold an off-list value, and only write `mainDest` when the source really is a Main. Set `allowInvalidValues: true` on both the `dest` and `mainDest` dropdowns in `GetSendSourceDestinationFields`. That also repairs buttons that already ran the upgrade. In the upgrade, write `mainDest` only when the legacy source text is a literal starting with `/main`, and otherwise leave `mainDest` at its stored static value. The upgrade script has not shipped in a stable release yet, so it can still be fixed in place before 2.4.0 final.

```ts
// src/choices/common.ts
		GetDropdown('From', 'src', sendSources),
		{ ...GetDropdown('To', 'dest', channelAuxBusSendDestinations), allowInvalidValues: true },
		{ ...GetDropdown('To', 'mainDest', mainSendDestinations), allowInvalidValues: true },
```

```ts
// src/upgrades.ts
			const dest = legacyVariableTextToValue(options.send_dest_variables, options.dest)
			const srcText = options.send_src_variables?.value
			if (typeof srcText === 'string' && srcText.trim().startsWith('/main')) {
				options.mainDest = dest
			} else {
				options.dest = dest
			}
```

---

## 🟡 Medium

### M1: Send actions always show two To dropdowns, so Main sources can hit the wrong send

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION (carried forward from alpha.1 L4, not fixed; raised to Medium for the wrong-send scenario)
- **File:** [`src/choices/common.ts:179-193`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/choices/common.ts#L179-L193)

**What goes wrong:** In v2.3.1 the send actions showed one "To" dropdown at a time, and a Main source (for example Main 1) showed only the Matrix list. Now both "To" dropdowns are always shown with the same label. The first lists Buses, Mains and Matrices; the second lists only Matrices and is the one used when "From" is a Main. A user who adds "Set Send Level" with From = Main 1 and picks Matrix 3 in the first "To" gets a button that changes the Main 1 → Matrix 1 send instead, because the second dropdown kept its default. "Adjust Send Level", "Set Send Mute", Store/Restore/Undo Send Level and the "Send Mute" feedback are all affected, and the feedback reports the wrong send.

**Why it happens:** `GetSendSourceDestinationFields()` returns the two dropdowns with no visibility rule. The old helper hid `dest` when the source started with `/main` and hid `mainDest` otherwise. The callback (`GetSendSourceDestinationFieldsWithVariables`, [`src/actions/utils.ts:116-128`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/actions/utils.ts#L116-L128)) still picks the field by source, so what the user sees and what the module uses no longer match.

**Fix:** restore the visibility rules on the two destination dropdowns (combine with the `allowInvalidValues` change from [H1](#h1-send-actions-and-the-send-mute-feedback-that-used-variables-stop-working-after-the-upgrade)). If the rule can't be evaluated when the source is in expression mode, at least give the fields distinct labels, such as "To (Channel/Aux/Bus source)" and "To (Main source)".

```ts
{ ...GetDropdown('To', 'dest', channelAuxBusSendDestinations), isVisibleExpression: "indexOf($(options:src), '/main') != 0" },
{ ...GetDropdown('To', 'mainDest', mainSendDestinations), isVisibleExpression: "indexOf($(options:src), '/main') == 0" },
```

### M2: Release workflow from the template is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** ⚠️ Pre-existing (the template added `release.yaml` on 2026-10-09, after the alpha.1 review)
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** The template ships a release workflow that packages the module and attaches the package to each GitHub release. Without it, releases of this module don't get the packaged build the template provides.

**Why it happens:** The file was never added; `.github/workflows/` only has `companion-module-checks.yaml` and `node.yaml`.

**Fix:** copy `.github/workflows/release.yaml` from the template unchanged.

### M3: CI workflow builds on Node 18 instead of the module's runtime

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** ⚠️ Pre-existing (unchanged in this release)
- **File:** [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/.github/workflows/node.yaml#L18-L23)

**What goes wrong:** CI builds and lints the module on Node 18, while the module runs on Node 22 today and must run on Node 26 ([C1](#c1-module-runs-on-node-22-although-api-21-modules-must-use-node-26)). A problem that only shows up on the real runtime won't be caught by CI.

**Why it happens:** The workflow is an older copy of the template: Node 18.x with `actions/checkout@v4` and `actions/setup-node@v4`, and no `persist-credentials: false`. The template uses Node 26.x, `actions/checkout@v7` (with `persist-credentials: false`) and `actions/setup-node@v6`. Validator message: "Differs from template (line 18: found '      - uses: actions/checkout@v4', template '      - uses: actions/checkout@v7')".

**Fix:** copy `.github/workflows/node.yaml` from the template.

### M4: Bug report issue template differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** ⚠️ Pre-existing (unchanged in this release)
- **File:** [`.github/ISSUE_TEMPLATE/bug_report.yml:5`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/.github/ISSUE_TEMPLATE/bug_report.yml#L5)

**What goes wrong:** New bug reports are titled slightly differently from other modules' reports.

**Why it happens:** Validator message: "Differs from template (line 5: found 'title: '[BUG] '', template 'title: '[BUG]'')".

**Fix:** copy `.github/ISSUE_TEMPLATE/bug_report.yml` from the template.

### M5: Issue template config differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** ⚠️ Pre-existing (unchanged in this release)
- **File:** [`.github/ISSUE_TEMPLATE/config.yml:3`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/.github/ISSUE_TEMPLATE/config.yml#L3)

**What goes wrong:** The "new issue" page links out to Companion with different wording from the template.

**Why it happens:** Validator message: "Differs from template (line 3: found '  - name: Bug or Feature for Companion itself', template '  - name: BUG OR FEATURE REQUEST FOR COMPANION ITSELF')".

**Fix:** copy `.github/ISSUE_TEMPLATE/config.yml` from the template.

### M6: Feature request issue template differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** ⚠️ Pre-existing (unchanged in this release)
- **File:** [`.github/ISSUE_TEMPLATE/feature_request.yml:9`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/.github/ISSUE_TEMPLATE/feature_request.yml#L9)

**What goes wrong:** Feature requesters are asked to check the latest beta build instead of confirming they updated to the latest module version, as the template asks.

**Why it happens:** Validator message: "Differs from template (line 9: found '      label: Make sure you've checked the latest beta build', template '      label: Make sure you have updated to the latest version of the module')".

**Fix:** copy `.github/ISSUE_TEMPLATE/feature_request.yml` from the template.

---

## 🟢 Low

### L1: Connection status stays at Connecting forever when the console is off or the IP is wrong

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:122-128`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/index.ts#L122-L128)

**What goes wrong:** A user adds a Wing connection with host 192.168.1.50, but the console is switched off or the IP has a typo. In v2.3.1 the connection turned red after about 30 s ("Disconnected – Unable to detect a console on the network"). In this release it stays yellow with "Connecting – Waiting for answer from console..." and never shows a failure, unless a "Library Scenes" poll subscription exists. The user can still tell nothing works, but nothing says the console is unreachable.

**Why it happens:** The handler for "no console detected" now only logs a warning instead of setting the Disconnected status. The maintainer did that on purpose, because network discovery gives false negatives on hosts with several network interfaces, and that reason is valid. But nothing replaced it. The "ready" event that sets Connecting comes from binding the local UDP socket, not from the console. The only other path to an error status is the poll timeout in `FeedbackHandler.startPolling()` ([`src/handlers/feedback-handler.ts:69-82`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/handlers/feedback-handler.ts#L69-L82)), and it returns early when there are no poll paths, which is the case unless the Library Scenes action is used.

**Fix:** keep the discovery-based status removed and check the configured host directly instead. In the "ready" handler, start a one-shot timeout (for example the status poll rate, or 5 s) that `handleMessages()` clears when the first reply arrives. If it fires, call `updateStatus(InstanceStatus.Disconnected, 'No answer from console at <host>')`. Clear the timer in `stop()`/`destroy()`.

---

## 💡 Nice to Have

### N1: Action and feedback options are not type-checked against a schema

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/types.ts:7-10`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/types.ts#L7-L10)

**What goes wrong:** No visible effect for users; this is code quality only. A typo in a preset's option id, or a renamed option, still compiles without error.

**Why it happens:** `WingTypes` declares only `config` and `secrets`, so TypeScript can't check action/feedback option ids or preset option values. Callbacks still cast values, for example `event.options.toggle as boolean` in Set SOF ([`src/actions/control.ts:170`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/actions/control.ts#L170)).

**Fix:** optionally add `actions`/`feedbacks` schema types to `WingTypes` and build the definitions with `CompanionActionDefinitions<WingTypes['actions']>` / `CompanionFeedbackDefinitions<...>`, so option ids and preset steps are type-checked.

### N2: Channel presets do not show the console's channel name

- **Source:** 🔎 carried forward from the alpha.1 review (N3), not addressed
- **Classification:** 🆕 NEW
- **File:** [`src/presets/channels.ts:39`](https://github.com/bitfocus/companion-module-behringer-wing/blob/cc16453a8e83e16c3d34fc765dbc6ba1b64b8ef4/src/presets/channels.ts#L39) (also lines 72, 105 and 134)

**What goes wrong:** The Mute, Solo, SOF and Boost & Center template presets show only "Mute CH 1" and similar, not the channel name set on the desk (for example "Lead Vox").

**Why it happens:** The button text expressions are built only from the `base` and `index` local variables. The v2.3.1 presets tried to show the channel name, but that expression was malformed and never rendered, so nothing working was lost.

**Fix:** use the channel's name variable, with the current text as a fallback, in the text expression, built from the `base`/`index` local variables.
