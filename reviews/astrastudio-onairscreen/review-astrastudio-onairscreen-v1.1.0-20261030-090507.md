# Review: companion-module-astrastudio-onairscreen v1.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-astrastudio-onairscreen` |
| **Scope** | `tag` (v1.0.4..v1.1.0) |
| **Version** | v1.1.0 (`674d947`) |
| **Release** | Update — last published v1.0.4 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-ts-v2.0.4` @ `d62230e` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review date** | 2026-10-30 |
| **Source links** | pinned to [`674d947`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/tree/674d947f19f878c794c3430127c75e753bc17efe) |

## Verdict: ✅ Approved

## 📋 Issues

### Non-blocking

- [ ] [L1: The new Fullscreen action's State option can be switched to expression mode, which it doesn't need](#l1-the-new-fullscreen-actions-state-option-can-be-switched-to-expression-mode-which-it-doesnt-need)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: The new Fullscreen action's State option can be switched to expression mode, which it doesn't need

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:225-236`](https://github.com/bitfocus/companion-module-astrastudio-onairscreen/blob/674d947f19f878c794c3430127c75e753bc17efe/src/actions.ts#L225-L236)

**What goes wrong:** Nothing breaks. In the new **Fullscreen** action, a user can flip the **State** option (Toggle / On / Off) to expression mode. A value such as `on` (lowercase) or `maybe` then fails the dropdown's choice check, and Companion skips the action without running it. Users who leave **State** as a normal dropdown, which is how the Display > Fullscreen preset ships, see no difference.

**Why it happens:** The API 2.0 rules recommend `disableAutoExpression: true` on options that make no sense as an expression, such as an on/off/toggle choice. The new `state` dropdown leaves it out. It copies the existing LED, AIR and AIR3 top-of-hour toggle actions, which also leave it out, so this follows the module's current pattern.

**Fix:** add `disableAutoExpression: true` to the `state` dropdown of the `fullscreen` action, and consider adding it to the other `TOGGLE_CHOICES` dropdowns for consistency. This changes no saved data, so no upgrade script is needed.

```ts
{
	id: 'state',
	type: 'dropdown',
	label: 'State',
	default: 'TOGGLE',
	choices: TOGGLE_CHOICES,
	disableAutoExpression: true,
},
```

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: it adds `allowImportingTsExtensions: true` and `rewriteRelativeImportExtensions: true` after `verbatimModuleSyntax`. Fine as long as the module builds (it does) — no change required.
