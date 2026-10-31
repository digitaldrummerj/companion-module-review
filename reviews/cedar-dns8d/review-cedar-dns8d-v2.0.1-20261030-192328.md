# Review: companion-module-cedar-dns8d v2.0.1 (follow-up to the v2.0.0 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-cedar-dns8d` |
| **Scope** | `tag` (v1.0.7..v2.0.1) |
| **Version** | v2.0.1 |
| **Release** | Update — last published v1.0.7 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`e91a849`](https://github.com/bitfocus/companion-module-cedar-dns8d/tree/e91a8492339cd7e52fd626b8fada3bf5d4734b9a) |
| **Prior review** | [v2.0.0 review](review-cedar-dns8d-v2.0.0-20261030-003407.md) |
| **Review date** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When an expression for a dropdown whose choice ids are the strings `'0'`, `'1'` and `'2'` returns the number `2`, Companion either skips the action (no choice matches) or passes the number through unchanged. It does not convert the number to the matching string id | the `@companion-module/base` 2.2.2 typings document `expressionDescription` and expression-mode validation, but not whether a dropdown value is converted to the choice id's type; Companion's host validation code was not checked | [M1](#m1-on-and-learn-expression-help-asks-for-a-number-but-only-the-text-values-0-1-and-2-work) |
| A2 | Companion does not check a plain (non-expression) dropdown value against the choices before it calls the action | `input.d.ts` says `allowInvalidValues` validation "only applies when in expression mode"; Companion's handling of plain values was not checked in its source | [L1](#l1-an-upgraded-button-saved-with-custom-channel-0-now-switches-global-on-or-global-learn) |

## 📋 Issues

### Non-blocking

- [ ] [M1: On and Learn expression help asks for a number, but only the text values 0, 1 and 2 work](#m1-on-and-learn-expression-help-asks-for-a-number-but-only-the-text-values-0-1-and-2-work)
- [ ] [L1: An upgraded button saved with custom channel 0 now switches Global On or Global Learn](#l1-an-upgraded-button-saved-with-custom-channel-0-now-switches-global-on-or-global-learn)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: On and Learn expression help asks for a number, but only the text values 0, 1 and 2 work

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:15-42`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/e91a8492339cd7e52fd626b8fada3bf5d4734b9a/src/options.ts#L15-L42), [`src/utils.ts:26-28`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/e91a8492339cd7e52fd626b8fada3bf5d4734b9a/src/utils.ts#L26-L28)

**What goes wrong:** A user switches the On option of **Channel On** or **Global On** (or the Learn option of **Channel Learn** or **Global Learn**) to expression mode. The help text added in this release says "Should return a number: 0: off, 1: on, 2: toggle", so the user writes `2`, or uses a custom variable that holds the number 2. Pressing the button does not toggle DNS. Depending on how Companion handles the value (see [A1](#-assumptions-to-confirm)), it either skips the action because no choice matches, or the module skips the toggle and sends `on="2"` to the DNS8D. Users who follow the module's own instruction get a button that doesn't work. Buttons that keep the dropdown (no expression) are not affected.

**Why it happens:** The dropdown's choice ids are the text values `'1'`, `'0'` and `'2'`, not numbers. The toggle helper (`calcBooleanVal`) compares strictly against the text `'2'`; any other value, including the number 2, is passed straight through to the message sent to the device.

```ts
// src/options.ts:15-19
const TOGGLE_CHOICES = [
	{ id: '1', label: 'On' },
	{ id: '0', label: 'Off' },
	{ id: '2', label: 'Toggle' },
] as const satisfies DropdownChoice<ToggleValue>[]
// src/options.ts:41
	expressionDescription: 'Should return a number: 0: off, 1: on, 2: toggle',
// src/utils.ts:26-28
export function calcBooleanVal(actVal: ToggleValue, curVal: boolean): '0' | '1' {
	return actVal === '2' ? (!curVal ? '1' : '0') : actVal
}
```

**Fix:** make the help text match the ids. This is the smallest change:

```ts
expressionDescription: "Should return '1' (on), '0' (off) or '2' (toggle)",
```

Alternatively, accept both forms: convert the value with `String(actVal)` in `calcBooleanVal`, send only `'1'` or `'0'`, and set `allowInvalidValues: true` on the toggle dropdown so a numeric result reaches the module. Or turn expression mode off for this field with `disableAutoExpression: true`. Add an `actions.spec.ts` case where `value` is the number 2.

## 🟢 Low

### L1: An upgraded button saved with custom channel 0 now switches Global On or Global Learn

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.ts:55-79`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/e91a8492339cd7e52fd626b8fada3bf5d4734b9a/src/actions.ts#L55-L79), [`src/message.ts:53-54`](https://github.com/bitfocus/companion-module-cedar-dns8d/blob/e91a8492339cd7e52fd626b8fada3bf5d4734b9a/src/message.ts#L53-L54)

**What goes wrong:** In v1.0.7 the Channel dropdown accepted custom values. A saved **Channel On** or **Channel Learn** button with the custom channel `0` was refused with "Invalid channel: 0". After upgrading to v2.0.1, pressing that button switches **Global On** (or **Global Learn**) for the whole unit. It always sends "on", because the module's stored state for a channel 0 is always off. Only buttons saved with an unusual custom channel are affected, so this is rare.

**Why it happens:** This release removed the module's own channel and band range checks, on the basis that Companion now validates the options. Companion only checks a value against the dropdown choices when the option is in expression mode (see [A2](#-assumptions-to-confirm)). The upgrade script turns a saved custom `0` into the plain number 0, not an expression, so no check runs. The message builder treats channel 0 as the unit's global settings.

**Fix:** keep a cheap range check in the channel and band actions before building the message, for example:

```ts
if (!CHANNELS.includes(id as ChannelNumber)) throw new Error(`Invalid channel: ${id}`)
```

Alternatively, add an upgrade script that flags or clamps saved plain channel values outside 1-8.

## 📝 Additional Notes

- Follow-up on the [v2.0.0 review](review-cedar-dns8d-v2.0.0-20261030-003407.md). Fixed in v2.0.1:
  - C1 `.gitattributes` added, matching the template.
  - C3 `.husky/pre-commit` now runs `lint-staged`.
  - C4 `approvedGitRepositories` removed from `.yarnrc.yml`.
  - C5 the unused `companion-module-utils` 0.5.0 patch is deleted.
  - H1 and H2: `node.yaml` and `release.yaml` now match the template.
  - L1 an unreadable device reply now sets the connection status and clears it on the next good message.
  - N2 `configUpdated()` now resets the once-per-outage log flags.
  - L2 and N1 (wrong "Invalid channel" messages) no longer apply, because the module's own checks were removed. That removal is what [L1](#l1-an-upgraded-button-saved-with-custom-channel-0-now-switches-global-on-or-global-learn) covers.
  - C2 is only partly fixed and is carried forward as [C1](#c1-templates-yarn-and-tgz-entries-are-still-missing-from-gitignore). M1 now has an `expressionDescription`, but its wording is new [M1](#m1-on-and-learn-expression-help-asks-for-a-number-but-only-the-text-values-0-1-and-2-work).
- The API compliance check covered the API 2.0 and 2.1 rules only. The reference has no API 2.2 rules yet, so any 2.2-specific changes were not checked.
- `tsconfig.build.json` differs from the template only in a trailing comma after `"rootDir": "./src"`. No change required.
- `tsconfig.json` differs from the template (extra `compilerOptions.allowJs`; trailing comma after `"types": ["node"]`). Fine as long as the module builds — no change required.
