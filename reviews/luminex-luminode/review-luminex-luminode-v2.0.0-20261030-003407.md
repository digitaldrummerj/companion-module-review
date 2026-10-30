# Review: companion-module-luminex-luminode v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-luminex-luminode` |
| **Scope** | `tag` (v1.2.2..v2.0.0) |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.2.2 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) |
| **Review commit** | [`8595c95`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 4.3+ checks a text field's value against the field's `regex` before running a v2 module's action, and skips the action when the value fails it | The v2.0 compliance reference says option values are validated and failing actions are skipped, but it names only number and dropdown fields. The base 2.0.4 typings only say the regex is used "to inform the user if the current input is valid". Companion's host code was not checked | [M1](#m1-snapshot-actions-may-refuse-to-run-because-the-snapshot-id-check-rejects-every-real-id) |

## 📋 Issues

### Blocking

- [ ] [C1: .gitattributes has extra comment lines not in the template](#c1-gitattributes-has-extra-comment-lines-not-in-the-template)
- [ ] [C2: .gitignore is missing template entries, so packaged .tgz files show up as untracked](#c2-gitignore-is-missing-template-entries-so-packaged-tgz-files-show-up-as-untracked)
- [ ] [C3: The pre-commit hook runs a full build on every commit](#c3-the-pre-commit-hook-runs-a-full-build-on-every-commit)
- [ ] [C4: eslint.config.mjs adds an ignores option the template doesn't have](#c4-eslintconfigmjs-adds-an-ignores-option-the-template-doesnt-have)

### Non-blocking

- [ ] [M1: Snapshot actions may refuse to run because the Snapshot ID check rejects every real id](#m1-snapshot-actions-may-refuse-to-run-because-the-snapshot-id-check-rejects-every-real-id)
- [ ] [M2: CI workflow uses an older checkout action than the template](#m2-ci-workflow-uses-an-older-checkout-action-than-the-template)
- [ ] [L1: Save current configuration to profile can send a non-text profile name](#l1-save-current-configuration-to-profile-can-send-a-non-text-profile-name)
- [ ] [N1: Action and feedback definitions are not typed against the module schema](#n1-action-and-feedback-definitions-are-not-typed-against-the-module-schema)
- [ ] [N2: On/off and fixed-choice options offer an expression toggle they don't need](#n2-onoff-and-fixed-choice-options-offer-an-expression-toggle-they-dont-need)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: .gitattributes has extra comment lines not in the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitattributes:1-3`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/.gitattributes#L1-L3)

**What goes wrong:** The module's config files must match its API level's template so that later troubleshooting can assume the standard setup. `.gitattributes` is new in this release and differs from the template.

**Why it happens:** Two comment lines were added above the template's single rule.

- **Template expects:** a single line, `* text=auto eol=lf`.
- **Found:** `# Normalize line endings: store as LF in the repo, check out LF on all platforms.` and `# Keeps prettier (endOfLine: lf) from flagging CRLF on Windows checkouts.`, then `* text=auto eol=lf`.

**Fix:** delete the two comment lines so the file matches the template exactly.

```text
* text=auto eol=lf
```

### C2: .gitignore is missing template entries, so packaged .tgz files show up as untracked

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-6`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/.gitignore#L1-L6)

**What goes wrong:** Running `yarn package` leaves `luminex-luminode-2.0.0.tgz` in the repo as an untracked file, which is easy to commit by accident. The review build did exactly that.

**Why it happens:** The template's ignore entries `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn` and `/.vscode` are missing.

- **Template expects:** `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`.
- **Found:** `node_modules/`, `package-lock.json`, `/pkg`, `/pkg.tgz`, `dist/`, `.yarn/install-state.gz`.

**Fix:** add the missing template entries. Extra entries are allowed.

```text
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

### C3: The pre-commit hook runs a full build on every commit

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.husky/pre-commit:1-2`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/.husky/pre-commit#L1-L2)

**What goes wrong:** The hook differs from the template, so every commit also runs a full build.

**Why it happens:** The hook calls `yarn lint-staged` and then `yarn build`, where the template runs only `lint-staged`.

- **Template expects:** `lint-staged`.
- **Found:** `yarn lint-staged`, then `yarn build`.

**Fix:** replace the file contents with the template's single line.

```bash
lint-staged
```

### C4: eslint.config.mjs adds an ignores option the template doesn't have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:5`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/eslint.config.mjs#L5)

**What goes wrong:** The lint setup differs from the template, so it no longer matches what other modules at this API level use.

**Why it happens:** An extra `ignores` option is passed to `generateEslintConfig`. It changes the shared config's options, so it is not the accepted test-scope deviation.

- **Template expects:** `export default generateEslintConfig({ enableTypescript: true, })`.
- **Found:** an extra `ignores: ['dist/**', 'node_modules/**', '.yarn/**', '.pnp.cjs', '.pnp.loader.mjs']` option.

**Fix:** remove the `ignores` option.

```js
export default generateEslintConfig({
	enableTypescript: true,
})
```

## 🟡 Medium

### M1: Snapshot actions may refuse to run because the Snapshot ID check rejects every real id

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.ts:219`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L219), [`src/actions.ts:244`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L244)

**What goes wrong:** A user adds "Play a specific snapshot" (or uses the "Play 1.00" / "Show 1: Record 1.00" presets) with Snapshot ID `1.00`. The field's validity check rejects `1.00`, `2.5` and every other real snapshot id, including the field's own default. In v1.2.2 that only drew a red border in the editor and the action still ran. If Companion 4.3+ also enforces the check before running a v2 action (see [A1](#-assumptions-to-confirm)), pressing the button does nothing on the LumiNode and Companion logs that it failed to parse the action options. "Trigger recording of a snapshot for a show" has the same field.

**Why it happens:** The pattern is `^d+(.d{1,2})?$`, with no backslashes, so it only matches strings made of the letter d, such as `d` or `dd.dd`. The broken pattern predates this release, but the move to API 2.0 in this tag can turn it from a cosmetic warning into a reason the action is skipped.

**Evidence:**

```ts
// src/actions.ts:214-221
				{
					type: 'textinput',
					label: 'Snapshot ID',
					id: 'snapshot_id',
					default: '1.00',
					regex: '^d+(.d{1,2})?$',
					useVariables: true,
				},
```

**Confirm by:** open [`src/actions.ts:219`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L219) and [`src/actions.ts:244`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L244); the default `1.00` does not match the pattern. Then on Companion 4.3+ press a "Play 1.00" preset button and check whether the action runs.

**Fix:** write the pattern with escaped backslashes in both Snapshot ID fields, so the runtime string is `^\d+(\.\d{1,2})?$`.

```ts
regex: '^\\d+(\\.\\d{1,2})?$',
```

### M2: CI workflow uses an older checkout action than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/.github/workflows/node.yaml#L18)

**What goes wrong:** The CI workflow differs from the template only in the checkout action's version.

**Why it happens:** Line 18 uses `actions/checkout@v4`; the template uses `actions/checkout@v7`.

**Fix:** copy the template's workflow file.

## 🟢 Low

### L1: Save current configuration to profile can send a non-text profile name

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:136-138`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L136-L138)

**What goes wrong:** A user adds "Save current configuration to profile" and switches the "Profile name" field to expression mode, for example `$(internal:time_hms)` or `1+1`. If the expression returns a number, true/false or nothing, the module sends that raw value to the device (`{"name": 2}`) instead of text, and the device may reject the save or store an unexpected name. Before v2.0.0 the name was always sent as text. Users who leave the field in normal text mode are not affected.

**Why it happens:** This release dropped the `.toString()` from `name: action.options.name`. In API 2.0 an option value can come from an expression, so it is not guaranteed to be a string.

**Fix:** convert the value to text before sending it, and skip the command when the result is empty.

```ts
const name = String(action.options.name ?? '')
```

## 💡 Nice to Have

### N1: Action and feedback definitions are not typed against the module schema

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:10-13`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/main.ts#L10-L13)

**What goes wrong:** Users see no difference. For the maintainer, a typo in an action option id or a preset's options (for example `snapshot_id` or `pb_id`) is not caught at build time.

**Why it happens:** The module's type declaration (`ModuleInstanceTypes`) lists only `config` and `secrets`. It has no action, feedback or variable schemas, and the action and feedback files still use the untyped `CompanionActionDefinition` / `CompanionFeedbackDefinition`.

**Fix:** add action, feedback and variable schemas to `ModuleInstanceTypes`, and type `getActions` / `getFeedbacks` / `getPresets` with `CompanionActionDefinitions<ModuleInstanceTypes>` and the matching feedback and preset types.

### N2: On/off and fixed-choice options offer an expression toggle they don't need

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:46-57`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L46-L57), [`src/actions.ts:71-77`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L71-L77), [`src/actions.ts:199-205`](https://github.com/bitfocus/companion-module-luminex-luminode/blob/8595c95a7dceac74abbb02a0d176d268f2240251/src/actions.ts#L199-L205)

**What goes wrong:** No functional problem. In API 2.0 the "Keep IP Settings", "Display On" and "Action" (Go/Forward/Back/Reset) options show an expression toggle that adds little for a fixed on/off or a fixed choice.

**Why it happens:** API 2.0 offers expression mode on every option unless the option opts out.

**Fix:** optionally add `disableAutoExpression: true` to those checkbox and dropdown options.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template (line 6 is `"ignoreDeprecations": "6.0",` where the template has `"outDir": "./dist",`). Fine as long as the module builds — no change required.
- `tsconfig.json` differs from the template (`compilerOptions.types` is missing; the template has `"types": ["node"]`). Fine as long as the module builds — no change required.
