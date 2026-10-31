# Re-review: cisco-cbs-350 v1.0.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-cisco-cbs-350](https://github.com/bitfocus/companion-module-cisco-cbs-350) |
| **Version** | v1.0.1 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag`. This is still the module's first release (v1.0.0 was never published), so there is no previous tag to diff against and the whole module was reviewed again |
| **Follow-up of** | [v1.0.0 review (2026-10-30)](review-cisco-cbs-350-v1.0.0-20261030-090507.md): every finding from that review is fixed (see [📝 Additional Notes](#-additional-notes)) |
| **Commit** | [`e04b887`](https://github.com/bitfocus/companion-module-cisco-cbs-350/commit/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e) |
| **Review date** | 2026-10-31 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | In API 2.x, Companion checks an expression-mode dropdown value against the choice ids without converting types, so the number `5` does not match the choice id `"5"` and the action or feedback is skipped | The v2.0 compliance reference: dropdown values must match a choice unless `allowCustom` is set, and a failed value means the action or feedback is skipped. Whether the comparison is strict or loose isn't visible in `@companion-module/base`; it happens inside Companion, whose code was not checked | [L2](#l2-port-options-in-expression-mode-may-not-match-any-port-so-the-action-or-feedback-is-skipped) |
| A2 | Companion 5 (API 2.1) signals a user's abort to running action callbacks through `context.signal` | The v2.1 compliance reference; the host-side abort behaviour was not checked | [N1](#n1-aborting-a-running-poe-or-link-reset-has-no-effect) |

## 📋 Issues

### Non-blocking

- [ ] [L1: Profile names and other variables stay empty on buttons until the switch has been read once](#l1-profile-names-and-other-variables-stay-empty-on-buttons-until-the-switch-has-been-read-once)
- [ ] [L2: Port options in expression mode may not match any port, so the action or feedback is skipped](#l2-port-options-in-expression-mode-may-not-match-any-port-so-the-action-or-feedback-is-skipped)
- [ ] [N1: Aborting a running PoE or link reset has no effect](#n1-aborting-a-running-poe-or-link-reset-has-no-effect)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Profile names and other variables stay empty on buttons until the switch has been read once

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:62-67`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L62-L67), [`src/main.ts:145-161`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L145-L161)

**What goes wrong:** A user adds the Profiles presets, for example "Select profile 1" (text `$(cbs350:profile_1_name)`) or the STORE / RECALL buttons (`$(cbs350:selected_profile_name)`). If the switch is offline when Companion starts, or the SNMP community is wrong, these buttons stay blank, even though the profile names come from the module's own config ("Profile 1", or a name the user typed), not from the switch. `unsaved_changes`, `last_save` and `selected_port_name` ("None") are also empty until the first successful poll. As soon as the switch answers, everything fills in.

**Why it happens:** `init()` builds the definitions and starts connecting, but never sets the variable values. Values are only set after a successful read of the switch in `#readSwitch()`; a failed poll doesn't set them. `configUpdated()` sets them only in the branch that doesn't reconnect.

**Fix:** set the variable values once right after the definitions are built. `getVariableValues()` already handles an empty switch state (port count 0, selected port "None", profile names from the config), so the config-based variables appear at once and the switch-based ones after the first poll.

```ts
this.updateDefinitions(true)
this.updateVariables()
```

Do the same in `configUpdated()` after `this.updateDefinitions(true)`, in both branches.

### L2: Port options in expression mode may not match any port, so the action or feedback is skipped

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/choices.ts:5-14`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/choices.ts#L5-L14), [`src/actions.ts:11-25`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/actions.ts#L11-L25), [`src/feedbacks.ts:11-17`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/feedbacks.ts#L11-L17)

**What goes wrong:** A user switches the "Port" option of "Set PoE of port" or of the "Port link is up" feedback to expression mode and enters `$(cbs350:selected_port_id)` or `$(local:port)`. The expression gives the number `5`, but the port dropdown's choices are the text values `"1"` … `"52"`. If Companion compares them strictly (see [A1](#-assumptions-to-confirm)), the value fails the choice check and Companion skips the action or feedback: nothing happens on the switch and the button never lights. The VLAN and "Profile slot" dropdowns already use numbers, so only the Port option behaves differently. Users who pick a port from the dropdown are not affected.

**Why it happens:** `portChoices()` builds the choices with text ids (`id: String(p.id)`), and the action and feedback schemas declare `port` as a string; every callback converts it back with `Number(options.port)`. The `selected_port_id` variable, on the other hand, is a number. In API 2.x every option except text inputs can be switched to expression mode, and Companion checks the computed value against the dropdown choices.

**Fix:** use numeric port ids, the way the VLAN dropdown already does. Return `DropdownChoice<number>[]` with `id: p.id` from `portChoices()`, type `port` as `number` in `ActionsSchema` and `FeedbacksSchema`, drop the `Number(options.port)` conversions, and pass `port: port.id` in the presets. This is a first release, so no upgrade script is needed. If ports stay text, add `disableAutoExpression: true` to the port options, or document that expressions must return text.

## 💡 Nice to Have

### N1: Aborting a running PoE or link reset has no effect

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:185-205`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/actions.ts#L185-L205)

**What goes wrong:** Nothing visible in normal use. If a user aborts a button's running actions (Companion 5's abort action) while "Reset PoE of port (power cycle the device)" is waiting out its "Power off duration" (up to 60 s), the module still waits and then switches PoE back on. That is the safe outcome, so this is only polish.

**Why it happens:** The reset actions ("Reset PoE of port", "Reset link of port" and their selected-port versions) wait for `resetPortPoe()` / `resetPortLink()`, which include a timer of up to 60 seconds plus SNMP round-trips, and never look at the abort signal (`context.signal`) that API 2.1 passes to action callbacks.

**Fix:** optionally pass `context.signal` into `resetPortPoe()` / `resetPortLink()` and return early if it is already aborted before the first write (switching the port off). Keep the second half (switching PoE or the link back on) unconditional, so an abort never leaves a port powered off.

## 📝 Additional Notes

- Follow-up of the v1.0.0 review: all eight findings are fixed in v1.0.1.
  - C1 (Node 22 runtime): fixed. [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/companion/manifest.json#L19) is `node26`, and the validator reports no template differences.
  - H1 (CI on Node 22): fixed. [`.github/workflows/node.yaml:21-25`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/.github/workflows/node.yaml#L21-L25) uses Node 26.x.
  - M1 (port left off when the connection is disabled or edited during a reset): fixed. Resets in progress are tracked, and `disconnect()` switches the port back on before closing the session ([`src/main.ts:100-108`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L100-L108), [`src/main.ts:219-247`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L219-L247)).
  - M2 (community saved as plain config): fixed. The community is now a `secret-text` field stored in the module's secrets.
  - L1 ("Reset link" re-enables a disabled port): fixed. The reset is skipped when the port is disabled ([`src/main.ts:397-400`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L397-L400)).
  - L2 (failed writes leave the connection green): fixed. A refused write sets a warning status asking whether the community is Read-Write ([`src/main.ts:202-208`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L202-L208)).
  - L3 (profile names in dropdowns not updated): fixed. `configUpdated()` rebuilds the definitions in both branches ([`src/main.ts:78`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L78)).
  - N1 ("Save config after applying" skipped): fixed ([`src/main.ts:495`](https://github.com/bitfocus/companion-module-cisco-cbs-350/blob/e04b887624fdadfa5ab6e909d8d0b7106ee7a58e/src/main.ts#L495)).
