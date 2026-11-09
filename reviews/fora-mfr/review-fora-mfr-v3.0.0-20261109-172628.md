# Companion Module Review: fora-mfr v3.0.0 (follow-up)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-fora-mfr` (For.A MFR routing switchers) |
| **Version** | v3.0.0 (previous tag v1.0.2; follow-up to the [v2.0.0 review](review-fora-mfr-v2.0.0-20261106-181511.md)) |
| **Release** | Update — last published v1.0.2 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` (`v1.0.2..v3.0.0`) |
| **Commit** | [`4129201`](https://github.com/bitfocus/companion-module-fora-mfr/commit/4129201a6816014bbf8b86c027708dcf0fc30772) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: Cut and Stage buttons blame the selection when the router has not been read yet](#l1-cut-and-stage-buttons-blame-the-selection-when-the-router-has-not-been-read-yet)
- [ ] [L2: In expression mode, the auto-route mode, lock mode and video format options only accept internal codes the list never shows](#l2-in-expression-mode-the-auto-route-mode-lock-mode-and-video-format-options-only-accept-internal-codes-the-list-never-shows)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Cut and Stage buttons blame the selection when the router has not been read yet

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW (also in v2.0.0, not raised in the previous review)
- **File:** [`src/main.ts:217-222`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/main.ts#L217-L222)

**What goes wrong:** Companion starts while the MFR is switched off, unreachable, or hasn't yet answered the module's request for its size. An operator presses DST 3, then SRC 5, then the button for "Cut selected source to selected destination" or "Stage selected source to selected destination". Nothing is sent, which is correct. But the log says "Select a destination and a source before switching", although both are selected and highlighted. With the connection setting "When a destination and a source are both selected" on "Cut straight away" or "Stage straight away", the same misleading warning appears after every destination and source pair. The operator is pointed at the selection when the real cause is that the router hasn't been read. The "Cut a route" and "Stage a route" actions already log the right reason ("Cannot route yet: the router has not reported its level").

**Why it happens:** The selection-based cut and stage check three things in one condition (the router's level is known, a destination is selected, a source is selected) and log one message, which only talks about the selection. Selecting a port still works while the router's size is unknown, because the port range check is skipped until the router reports its size. So the missing level is the only failing condition, yet the message blames the selection.

**Evidence:**

```ts
// src/main.ts:217-222
	routeSelection(mode: 'cut' | 'preset'): void {
		const { selectedDst, selectedSrc } = this.state
		if (this.state.level === undefined || selectedDst === undefined || selectedSrc === undefined) {
			this.log('warn', 'Select a destination and a source before switching')
			return
		}
```

**Fix:** check the selection and the router's level separately, and reuse the wording of the explicit route actions for the level.

```ts
if (selectedDst === undefined || selectedSrc === undefined) {
	this.log('warn', 'Select a destination and a source before switching')
	return
}
if (this.state.level === undefined) {
	this.log('warn', 'Cannot route yet: the router has not reported its level')
	return
}
```

### L2: In expression mode, the auto-route mode, lock mode and video format options only accept internal codes the list never shows

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW (also in v2.0.0, not raised in the previous review)
- **File:** [`src/actions.ts:81-118`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/actions.ts#L81-L118), [`src/actions.ts:172`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/actions.ts#L172), [`src/feedbacks.ts:124`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/feedbacks.ts#L124), [`src/choices.ts:5-69`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/choices.ts#L5-L69)

**What goes wrong:** This only affects a user who switches one of these options to expression mode. Buttons that pick from the list work.

- **Set auto-route mode** action and **Auto-route mode** feedback: the list shows "Stage: stage straight away", and the `$(fora-mfr:auto_route_mode)` variable reads `STAGE`, but in expression mode the option only accepts `preset`. Typing `stage`, or feeding the feedback `$(fora-mfr:auto_route_mode)`, matches no choice, so Companion skips the action or feedback.
- **Lock/Unlock a destination**, "Lock mode :": the option only accepts `0`, `1` and `toggle`, not `unlock` or `lock`.
- **Preset video format**, "Set video format :": the option only accepts the router's hex codes, e.g. `0A` for 1080/29.97p and `04` for 1080/50i. Typing `10` picks 1080/25PsF (hex `10`), not 1080/30p, the 10th format in the list.

Nothing in the action editor tells the user which values to type. In v3.0.0 the port options got an expression description for exactly this reason, but these options did not.

**Why it happens:** In API 2.x any dropdown can be switched to expression mode, and Companion checks the computed value against the ids of the choices. The ids here are internal or protocol codes: `preset` for Stage ([`src/choices.ts:58-62`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/choices.ts#L58-L62)), `0` / `1` / `toggle` for the lock mode ([`src/choices.ts:64-69`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/choices.ts#L64-L69)), and hex video format codes ([`src/choices.ts:5-27`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/choices.ts#L5-L27)). The labels shown are different, and none of these options sets an `expressionDescription` (the text Companion shows in place of the list when an option is in expression mode).

**Evidence:**

```ts
// src/choices.ts:58-67
export const AUTO_ROUTE_MODES: DropdownChoice<string>[] = [
	{ id: 'off', label: 'Off: wait for the cut or stage button' },
	{ id: 'preset', label: 'Stage: stage straight away' },
	{ id: 'cut', label: 'Cut: cut straight away' },
]

export const LOCK_MODES: DropdownChoice<string>[] = [
	{ id: '0', label: 'Unlock' },
	{ id: '1', label: 'Lock' },
	{ id: 'toggle', label: 'Toggle lock / unlock' },
```

```ts
// src/feedbacks.ts:124
			options: [{ type: 'dropdown', id: 'mode', label: 'Mode :', default: 'cut', choices: AUTO_ROUTE_MODES }],
```

**Fix:** keep the ids, because saved buttons and the `autoRoute` connection setting depend on them, and add an `expressionDescription` that lists the accepted values, as `portDropdown` does for the port options. For example:

- `setAutoRoute` `mode` and the `AutoRouteMode` feedback's `mode`: `'off, preset (stage), cut, or next'` (the feedback has no `next`)
- `lockDst` `mode`: `'0 = unlock, 1 = lock, toggle'`
- `setVideoFormat` `format` / `ref` / `point`: `'Router code, e.g. 04 = 1080/50i, 0A = 1080/29.97p; RA/RB/RT; SF/SO/SE; or default'`

If an option makes no sense as an expression, set `disableAutoExpression: true` on it instead, as v3.0.0 already does for the "Use the selected destination" and "Apply straight away" checkboxes.

## 📝 Additional Notes

- **Follow-up to the v2.0.0 review:** every finding of the [previous review](review-fora-mfr-v2.0.0-20261106-181511.md) is fixed in v3.0.0, and the template check now reports no differences:
  - v2.0.0 C1-C4, M2, M3 (template): `.gitattributes`, the husky and lint-staged pre-commit setup, `.prettierignore`, Node 26 in all five places, and the `node.yaml` and `release.yaml` workflows now match the template.
  - v2.0.0 M1: port options and port variables use the port number shown in the list, with an expression description and `allowInvalidValues: true`, and the new upgrade script ([`src/upgrades.ts`](https://github.com/bitfocus/companion-module-fora-mfr/blob/4129201a6816014bbf8b86c027708dcf0fc30772/src/upgrades.ts)) converts saved hex picks. Expressions and button text that use the old hex values must be changed by hand, as the CHANGELOG says.
  - v2.0.0 L1: an empty, fractional or out-of-range MFR Port shows "Bad configuration" instead of crashing the module.
  - v2.0.0 L2: the port names page refuses an Apply that the command queue can't hold in full, and asks for smaller batches.
  - v2.0.0 L3: the refresh runs on its own timer, at the interval set.
  - v2.0.0 N1: the Destination option of Lock/Unlock a destination is hidden while "Use the selected destination" is ticked.
  - v2.0.0 N2: a route action skips the re-read when an identical one is already waiting in the queue.
  - v2.0.0 N3: a source rename updates the routed-name variables of only the destinations that use that source.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a dropdown option in expression mode computes a value that matches no choice id, and the option does not set `allowInvalidValues` or `allowCustom`, Companion skips the action or feedback | The v2 API reference ("Expression validation") and the `allowInvalidValues` comment in the base 2.1.3 typings; Companion's own comparison code was not run | [L2](#l2-in-expression-mode-the-auto-route-mode-lock-mode-and-video-format-options-only-accept-internal-codes-the-list-never-shows) |
