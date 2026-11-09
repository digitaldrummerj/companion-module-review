# Review: chyronhego-lyric v2.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-chyronhego-lyric` |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.0.2 |
| **API** | 2.2 (base 2.2.2, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` (v1.0.2..v2.0.0) |
| **Commit** | [`23217c7`](https://github.com/bitfocus/companion-module-chyronhego-lyric/tree/23217c7615a2c15561d5960ce0b0bd619876115d) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Users can't tell which values to type for Update Mode, Buffer or Display Mode in expression mode](#m1-users-cant-tell-which-values-to-type-for-update-mode-buffer-or-display-mode-in-expression-mode)
- [ ] [L1: Host names shorter than 4 characters, such as cg1, are now rejected in the connection settings](#l1-host-names-shorter-than-4-characters-such-as-cg1-are-now-rejected-in-the-connection-settings)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Users can't tell which values to type for Update Mode, Buffer or Display Mode in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/options.ts:16-34`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/src/options.ts#L16-L34), [`src/options.ts:63-88`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/src/options.ts#L63-L88)
- **Assumption:** [A2](#-assumptions-to-confirm)

**What goes wrong:** This release moves the module to API 2.x, so every action option can now be switched to expression mode, and the help says so ([`companion/HELP.md:27`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/companion/HELP.md#L27): "Any action option can be set with an expression."). Say a user switches **Update Mode** on a "Read & Update Message" button to an expression so it can pick the mode at run time. They type the label (`'Read & Update External Update Fields'`) or a natural value like `'external'`. Neither matches a choice id, so the action is rejected and nothing reaches Lyric. The real ids are the raw command prefixes `V\5\13\1\` and `V\5\14\1\`, which need escaped backslashes in an expression and appear nowhere in the UI or the help. **Buffer** (`'0'` = VGA, `'1'` / `'2'` = Frame Buffer 1 / 2) and **Display Mode** (`'0'` = Read Next, `'1'` = Read & Display) have the same gap, though their ids are easier to type once someone knows them. Buttons that use the normal dropdown (value mode) are not affected.

**Why it happens:** The dropdown ids were kept from 1.x so that saved buttons keep working (see the comment at [`src/options.ts:29`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/src/options.ts#L29)). That was harmless while a dropdown could only hold a picked value. API 2.x adds expression mode to every field, and the computed value has to match one of the choice ids (the module's own `choiceValue()` check in [`src/actions.ts:82-96`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/src/actions.ts#L82-L96) throws "Buffer VGA is not valid" otherwise). The dropdowns have no `expressionDescription` (the hint Companion shows under a field in expression mode), and the help doesn't list the ids.

**Fix:** tell users which values each dropdown accepts in expression mode. The lightest fix is an `expressionDescription` on `readUpdate`, `readBuffer` and `readDisplayMode`, plus the same list in HELP.md under Actions:

```ts
export const readBuffer: CompanionInputFieldDropdown<'buffer'> = {
	type: 'dropdown',
	id: 'buffer',
	label: 'Buffer',
	choices: BUFFERS,
	default: BUFFERS[1].id,
	tooltip: 'Specifies destination of the message',
	expressionDescription: 'Expression must return "0" (VGA), "1" (Frame Buffer 1) or "2" (Frame Buffer 2)',
}
```

A fuller fix: switch to friendly ids (`'intelligentInterface'` / `'externalUpdate'`, `'vga'` / `'fb1'` / `'fb2'`, `'prebuild'` / `'display'`), map them to the command fragments in the callbacks, and append a new upgrade script (index 1; don't edit index 0) that converts saved values from the old ids.

## 🟢 Low

### L1: Host names shorter than 4 characters, such as cg1, are now rejected in the connection settings

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/config.ts:18-24`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/src/config.ts#L18-L24)
- **Assumption:** [A1](#-assumptions-to-confirm)

**What goes wrong:** Some sites name their Lyric machines with short host names like `cg1`, `cg2` or `lyr`. Version 1.0.2 accepted these. In 2.0.0 the **Host** field is marked invalid because of its 4-character minimum, so a user with such a host can't save the connection settings cleanly, for example when they only want to turn on **Verbose Logging**. An existing connection that already uses `cg1` still connects, because the module itself only checks that the host is not empty ([`src/main.ts:59-61`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/src/main.ts#L59-L61)). IP addresses are not affected, since the shortest one (`1.1.1.1`) is 7 characters.

**Why it happens:** v1.0.2 validated the field with `regex: Regex.HOST`, which accepts any single-label host name, including 1 to 3 characters. The 2.0.0 rewrite replaced that regex with `minLength: 4`, a minimum that rules out valid short host names:

```ts
// src/config.ts:18-24
		{
			type: 'textinput',
			id: 'host',
			label: 'Host',
			width: 8,
			minLength: 4,
		},
```

**Fix:** require only a non-empty host. `minLength: 1` is what the base package recommends in place of the deprecated `Regex.HOSTNAME` / `Regex.SOMETHING` (`node_modules/@companion-module/base/dist/module-api/enums.d.ts`). Keep the `!host` check in `#open()` as it is.

```ts
minLength: 1,
```

## 📝 Additional Notes

- `tsconfig.build.json`: the `exclude` globs are `src/**/__tests__/**` and `src/**/__mocks__/**`, where the template has `src/**/__tests__/*` and `src/**/__mocks__/*` ([`tsconfig.build.json:4`](https://github.com/bitfocus/companion-module-chyronhego-lyric/blob/23217c7615a2c15561d5960ce0b0bd619876115d/tsconfig.build.json#L4)). Fine as long as the module builds — no change required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a connection-settings `textinput` value is shorter than its `minLength`, Companion marks the field invalid or blocks saving. If Companion only shows a warning and still saves, L1 is cosmetic | base 2.2.2 typings document `minLength` as "Minimum required length of the value"; how Companion's config form enforces it was not checked | [L1](#l1-host-names-shorter-than-4-characters-such-as-cg1-are-now-rejected-in-the-connection-settings) |
| A2 | In expression mode, Companion's editor shows a dropdown's labels but not its choice ids, so a user can't find out from the UI that Buffer "VGA" is `'0'` or which string Update Mode expects | the v2 compliance skill's rule that expression results are checked against choice ids; the Companion UI was not inspected | [M1](#m1-users-cant-tell-which-values-to-type-for-update-mode-buffer-or-display-mode-in-expression-mode) |
