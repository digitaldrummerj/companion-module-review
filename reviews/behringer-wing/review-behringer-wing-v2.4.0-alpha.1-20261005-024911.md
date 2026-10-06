# Review: behringer-wing @ v2.4.0-alpha.1

| Field | Value |
| ------- | ------- |
| **Module** | `companion-module-behringer-wing` |
| **Tag** | `v2.4.0-alpha.1` |
| **Commit** | `2691268` |
| **Previous reviewed version** | `v2.3.1` (✅ Approved, 0 findings) |
| **Scope:** | tag (`v2.3.1..v2.4.0-alpha.1`) |
| **Reviewed** | 2026-10-05 |
| **Template** | `companion-module-template-ts` @ `d62230e` (2026-08-28, fresh) |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Module type** | TypeScript / ESM |
| **Build** | ✅ `yarn install --immutable`, `yarn package`, `yarn lint` |

This release moves the module from API v1 (`~1.13`) to API v2.1. The v2.3.1 review had no open findings.

---

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C3: Removed Use Variables and percentage options have no upgrade script](#c3-removed-use-variables-and-percentage-options-have-no-upgrade-script)
- [ ] [H1: Text fields no longer substitute variables in value mode](#h1-text-fields-no-longer-substitute-variables-in-value-mode)
- [ ] [H2: Base dependency range does not pin the 2.1 API](#h2-base-dependency-range-does-not-pin-the-21-api)

**Non-blocking**

- [ ] [M1: New last-message status variables are never set](#m1-new-last-message-status-variables-are-never-set)
- [ ] [M2: Main/Alt status variable definition removed but still set](#m2-mainalt-status-variable-definition-removed-but-still-set)
- [ ] [M3: isVisibleExpression references fields that can become expressions](#m3-isvisibleexpression-references-fields-that-can-become-expressions)
- [ ] [M4: Set Delay Mode amount fields pass the visibility rule as the tooltip](#m4-set-delay-mode-amount-fields-pass-the-visibility-rule-as-the-tooltip)
- [ ] [L1: Debug Mode config option no longer does anything](#l1-debug-mode-config-option-no-longer-does-anything)
- [ ] [L2: Set SOF now honours Toggle, changing existing buttons](#l2-set-sof-now-honours-toggle-changing-existing-buttons)
- [ ] [L3: getStringWithVariables casts instead of converting](#l3-getstringwithvariables-casts-instead-of-converting)
- [ ] [L4: Both send To dropdowns are always shown](#l4-both-send-to-dropdowns-are-always-shown)
- [ ] [L5: Preset option values do not match dropdown choice ids](#l5-preset-option-values-do-not-match-dropdown-choice-ids)
- [ ] [N1: WingInstance import in state.ts should be type-only](#n1-winginstance-import-in-statets-should-be-type-only)
- [ ] [N2: Dropdowns give no list of valid ids for expression mode](#n2-dropdowns-give-no-list-of-valid-ids-for-expression-mode)
- [ ] [N3: Channel presets do not show the console channel name](#n3-channel-presets-do-not-show-the-console-channel-name)

---

## 🔴 Critical

### C3: Removed Use Variables and percentage options have no upgrade script

**Classification:** 🔙 REGRESSION · **Files:** `src/upgrades.ts:4-47`, `src/choices/common.ts`, `src/actions/utils.ts:69-120`, `src/actions/common.ts:432-460`, `src/actions/matrix.ts:77-102`

v2.3.1 stored every variable-capable option as three fields: `<id>_use_variables` (a checkbox), `<id>` (the static dropdown, slider or number), and `<id>_variables` (a textinput with `useVariables: true`). The fader delta also had `delta_use_percentage`, `delta_percent` and `delta_percent_variables`, and sends had `send_src_dest_use_variables`, `send_src_variables` and `send_dest_variables`.

This release removes all of those helpers. `getStringWithVariables`/`getNumberWithVariables` now read only `options[<id>]`. `UpgradeScripts` still has only the v2.2.0 recorder-state script.

What breaks for existing users:

- **Actions or feedbacks with "Use Variables" turned on** ignore their variable text and use the hidden static value. A Set Mute whose channel came from `$(…)` now mutes whatever channel was left in the hidden dropdown, which is the wrong channel on a live desk.
- **Fields that were textinputs and are now `number` fields** (`sceneId`, `session`, `marker`, `position`, `dim`, `amount_*`, gain, level, and others) keep their stored strings. A value such as `"$(internal:x)"` becomes `NaN`, so `getNumberWithVariables` throws `Invalid option` and the action fails.
- **Adjust Fader Level saved in percentage mode** now uses the hidden dB `delta` field instead. That is usually `0`, so nothing happens, or the value is applied as dB instead of %.

Companion's own v1→v2 conversion doesn't fix this, because the module no longer reads the `<id>_variables` keys at all.

**Fix:** append a new upgrade script. Never edit the existing one. For each action and feedback:

- If `<id>_use_variables` is `true`, write `<id> = { isExpression: true, value: <converted $(…) text> }`. Otherwise keep `<id>`.
- Map `send_src_variables`/`send_dest_variables` to `src` and `dest`/`mainDest` the same way.
- Convert `delta_use_percentage` setups to an equivalent expression, or keep percentage mode as an explicit option. If you drop it, document that as a breaking change.
- Run `FixupNumericOrVariablesValueToExpressions` (from `@companion-module/base`) on the former numeric textinputs.
- Delete the obsolete `_use_variables`, `_variables`, `_percent*` and `send_*_variables` keys.

---

## 🟠 High

### H1: Text fields no longer substitute variables in value mode

**Classification:** 🔙 REGRESSION · **Files:** `src/choices/common.ts:43-50` (`getTextField`). Used by `src/actions/other.ts:21,31,44-45` (Send Command `cmd`/`val`), `src/actions/common.ts:234` (Set Name `name`) and `src/actions/cards.ts:135` (session `name`)

v2.3.1's `GetTextFieldWithVariables` set `useVariables: true`. Its replacement, `getTextField`, doesn't. In base 2.1.3, `useVariables` still controls whether `$(…)` is parsed in value mode. Without it, existing Send Command / Send Command with String / Set Name buttons send the literal `$(…)` text to the desk, which gives malformed OSC paths or wrong channel names. The `val` tooltip still says "This can include variables."

**Fix:** set `useVariables: true` in `getTextField`, or add a separate helper for these call sites.

### H2: Base dependency range does not pin the 2.1 API

**Classification:** 🆕 NEW · **File:** `package.json` (`"@companion-module/base": "^2.0.0"`)

The lockfile resolves to 2.1.3, and the code is written against the 2.1 typings. With the `^2.0.0` range, `package.json` doesn't say which API (and so which Companion version) the module targets.

**Fix:** pin `"~2.1.3"`.

---

## 🟡 Medium

### M1: New last-message status variables are never set

**Classification:** 🆕 NEW · **File:** `src/handlers/variable-handler.ts:88`, `:590-597`

`updateStatusVariables()` returns its updates, but line 88 throws the return value away. `last_msg_received_timestamp`, `last_msg_path` and `last_msg_value` are defined in `src/variables/status.ts` but never get a value. The call is also inside `if (result)`, so even when fixed it would only run for messages that map to a variable. That makes it unreliable as a liveness signal.

**Fix:** move the call out of `if (result)` and keep its result, e.g. `updates.push(...this.updateStatusVariables(path, args[0]?.value as string | number))`. Better still, set these variables once per flush from the last message. Change the return type to `VariableUpdate[]`. `args[0]?.value` can also be a `Uint8Array` (OSC blob) or `undefined`, neither of which is a valid variable value, so convert those to a string or `''` first.

### M2: Main/Alt status variable definition removed but still set

**Classification:** 🔙 REGRESSION · **Files:** `src/variables/index.ts:22-24`, `src/handlers/variable-handler.ts:54-56` (removed); `src/handlers/variable-handler.ts:576` (still sets the value)

This release removed the `main_alt_status` definition from both places it was defined. `updateIoVariables` still sets `main_alt_status` from `/io/altsw`. The variable no longer appears in Companion's variable list or picker, and existing `$(behringer-wing:main_alt_status)` references in button text and triggers stop resolving. `desk_ip` and `desk_name` were removed too. Nothing ever set them, so dropping them is acceptable, but they were public variable ids and any user references to them now break.

**Fix:** add `{ variableId: 'main_alt_status', name: 'Main/Alt Input Source' }` back to `getAllVariables()`, for example in `variables/status.ts`. Mention the `desk_ip`/`desk_name` removal in the changelog (or re-add and populate them from `config.host` and the device detector).

### M3: isVisibleExpression references fields that can become expressions

**Classification:** 🆕 NEW (the move to v2 makes these fields expression-capable) · **Files:** `src/choices/fades.ts:36,49`, `src/choices/eq.ts:54`, `src/choices/faderbanks.ts:208,216,224,232,243`, `src/actions/common.ts:648-651`

In base 2.1.3, `input.d.ts` says `isVisibleExpression` "can only reference fields which are set to `disableAutoExpression`". These expressions read `fadeDuration`, `fadeAlgorithm`, the EQ `model`, `bank`, `left`/`center`/`right` and the delay `mode`. None of those fields sets `disableAutoExpression: true` anywhere in `src/`. If a user switches one of them to expression mode, the fields that depend on it show or hide incorrectly, which can hide the field that actually holds the value.

**Fix:** add `disableAutoExpression: true` to those fields. This is the first v2 release, so no user expressions exist on them yet. For `fadeDuration`, you can instead drop the visibility dependency.

### M4: Set Delay Mode amount fields pass the visibility rule as the tooltip

**Classification:** 🔙 REGRESSION · **File:** `src/actions/common.ts:648-651`

```ts
GetNumberField('Amount (meters)', 'amount_m', 0, 150, 0.1, 0, undefined, `$(options:mode) == 'M'`),
```

`GetNumberField`'s signature is `(label, id, min, max, step, defaultValue, range, tooltip)`, so the 8th argument becomes the **tooltip**. In v2.3.1, `GetNumberFieldWithVariables` took `isVisibleExpression` as its 8th argument. Now all four amount fields are always visible, and each tooltip shows the raw expression text.

**Fix:** `{ ...GetNumberField('Amount (meters)', 'amount_m', 0, 150, 0.1, 0), isVisibleExpression: \`$(options:mode) == 'M'\` }`. Do the same for`ft`,`ms` and `samples`, together with`disableAutoExpression` on `mode` (M3).

---

## 🟢 Low

### L1: Debug Mode config option no longer does anything

**Classification:** 🆕 NEW · **Files:** `src/index.ts:67`, `src/config.ts:37,240-256`, `src/upgrades.ts:41`

`init` now only calls `createModuleLogger('Behringer-Wing')`. The old custom logger read `config.debugMode` to add timestamps and the source location, and nothing reads it now. The "Debug Mode" info text and the "Enable Debug Mode" checkbox are still shown.

Every instance now also logs under the same fixed source name, and the device-detector singleton keeps whichever instance's logger was added last, so with several Wing connections you can't tell which one produced a message.

**Fix:** remove the field and its info text, or use it to control the per-message `logger.debug`/`info` calls, such as `connection-handler.ts:65` and the poll handler's per-path `logger.info`. Consider passing `this.label` to `createModuleLogger` so multi-instance logs can be told apart.

### L2: Set SOF now honours Toggle, changing existing buttons

**Classification:** 🔙 REGRESSION (behaviour change) · **File:** `src/actions/control.ts:170,185`

In v2.3.1, pressing Set SOF for the already-selected channel always turned SOF off, and the `toggle` checkbox was ignored. Now SOF only turns off when `toggle` is checked. Its default is `false`, so existing buttons re-select the channel instead.

**Fix:** decide which behaviour you want. To keep old buttons working, add an upgrade step that sets `toggle: true` on existing `set-sof` actions. Also mention the change in the changelog.

### L3: getStringWithVariables casts instead of converting

**Classification:** 🆕 NEW · **File:** `src/actions/utils.ts:69-75`

`event.options[id] as string` only changes the type for the compiler. In v2, any option can be in expression mode and resolve to a number or boolean. When that happens, `src.startsWith('/main')` (`utils.ts:112`) throws a TypeError, and string comparisons in feedbacks quietly return `false`.

`getNodeNumber` (`utils.ts:15-17`) has the same problem: a numeric option value now yields `undefined` instead of a node number.

**Fix:** `return res === undefined ? (defaultValue ?? '') : String(res)`, and `String(val ?? '')` in `getNodeNumber`. The JSDoc at `utils.ts:63` and `:81` still describes `parseVariablesInString`; update it while there.

### L4: Both send To dropdowns are always shown

**Classification:** 🔙 REGRESSION · **File:** `src/choices/common.ts:162-176` (`GetSendSourceDestinationFields`)

v2.3.1 showed `dest` or `mainDest` depending on `src` (`indexOf($(options:src), '/main')`). That rule was dropped, so both dropdowns, each labelled "To", are always visible.

**Fix:** restore the visibility rule and add `disableAutoExpression: true` on `src`, or give the two fields distinct labels ("To (channel/aux/bus)" / "To (main)").

### L5: Preset option values do not match dropdown choice ids

**Classification:** 🆕 NEW (presets were rewritten into `src/presets/` in this release) · **Files:** `src/presets/control.ts:26,54`, `src/presets/channels.ts:48,55,81`

- The Talkback presets set `solo: 2`. `GetOnOffToggleDropdown`'s choices are `'1'`/`'0'`/`'-1'`, so `2` is not a valid choice and is sent to the desk as-is. This value was already in the v2.3.1 presets.
- `mute: -1`, `mute: 1` and `solo: -1` are numbers, but the choice ids are strings. Line 88 already uses `solo: '1'`. These still work at runtime because `Number()` converts them, but the UI shows an invalid selection.

**Fix:** use the exact string choice ids (probably `'-1'` for toggle on Talkback). If the Wing really needs `2`, add it as a choice.

---

## 💡 Nice to Have

### N1: WingInstance import in state.ts should be type-only

**Classification:** 🆕 NEW · **File:** `src/state/state.ts:2`

This release changed `import type { WingInstance }` to `import WingInstance from '../index.js'`. It's only used as a type, so TypeScript removes it today. With `verbatimModuleSyntax` enabled (C1), it would become a runtime circular import between `state.ts` and `index.ts`.

**Fix:** `import type WingInstance from '../index.js'`.

### N2: Dropdowns give no list of valid ids for expression mode

**Classification:** 🆕 NEW · **File:** `src/choices/common.ts:63-83` (`GetDropdown`)

Expression mode is now the only way to drive a dropdown from variables. The old helper's "Available choices: id=label…" tooltip was removed, so users don't see which ids are valid (e.g. `/ch/1`, `1`/`0`/`-1`).

**Fix:** set `expressionDescription` in `GetDropdown` to list the choice ids.

### N3: Channel presets do not show the console channel name

**Classification:** 🆕 NEW · **File:** `src/presets/channels.ts` (`tpl-mute`, `tpl-solo`, `tpl-sof`, `tpl-boost-center`)

The rewritten template presets show only `Mute CH 1` and similar. The v2.3.1 presets tried to show the desk's channel name (`$(wing:<base><n>_name)`), but that expression was malformed and never rendered, so nothing working was lost.

**Fix:** use the name variable with a fallback in the text expression, built from the `base`/`index` local variables, so the button shows the console's channel name when one is set.
