# Review: companion-module-magewell-ultrastream v1.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-magewell-ultrastream` |
| **Scope** | `tag` (`v1.0.1..v1.1.0`) |
| **Version** | v1.1.0 |
| **Release** | Update — last published v1.0.1 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`a088e65`](https://github.com/bitfocus/companion-module-magewell-ultrastream/tree/a088e65c195a2232301729375f8b158f80d04244) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a dropdown option holds the number `0` or `1` and the dropdown's choices have the text ids `'0'` and `'1'`, Companion's button editor shows the option as unselected or unknown (rather than matching it loosely) | General Companion dropdown behaviour; the reviewers disagreed and the Companion web UI source was not checked | [L2](#l2-mixer-preset-buttons-store-layer-order-as-a-number-while-the-actions-dropdown-uses-text-ids) |
| A2 | Ultra Stream devices don't support `select-input-source` / `set-video-mixer-config` and don't report `input-source` in get-info | The module's own types put `input-source` only on the Ultra Encode responses, and the presets are already gated on the mixer info; device documentation not checked | [L3](#l3-ultra-stream-users-see-input-source-and-mixer-actions-and-feedbacks-that-do-nothing-on-their-device) |

## 📋 Issues

### Blocking

- [ ] [C1: Missing `.gitattributes` lets Windows contributors commit CRLF line endings](#c1-missing-gitattributes-lets-windows-contributors-commit-crlf-line-endings)
- [ ] [C2: VS Code workspace settings can be committed because `.gitignore` lacks `/.vscode`](#c2-vs-code-workspace-settings-can-be-committed-because-gitignore-lacks-vscode)
- [ ] [H1: LICENSE copyright year differs from the template (2020 instead of 2022)](#h1-license-copyright-year-differs-from-the-template-2020-instead-of-2022)

### Non-blocking

- [ ] [L1: Input and mixer choices from the previous device stay after changing the connection's host](#l1-input-and-mixer-choices-from-the-previous-device-stay-after-changing-the-connections-host)
- [ ] [L2: Mixer preset buttons store Layer Order as a number while the action's dropdown uses text ids](#l2-mixer-preset-buttons-store-layer-order-as-a-number-while-the-actions-dropdown-uses-text-ids)
- [ ] [L3: Ultra Stream users see input source and mixer actions and feedbacks that do nothing on their device](#l3-ultra-stream-users-see-input-source-and-mixer-actions-and-feedbacks-that-do-nothing-on-their-device)
- [ ] [NR1: Consider moving to a newer `@companion-module/base` in a future release](#nr1-consider-moving-to-a-newer-companion-modulebase-in-a-future-release)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Missing `.gitattributes` lets Windows contributors commit CRLF line endings

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check on this release; the file was already missing at v1.0.1)
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without the template's `.gitattributes`, a contributor on Windows can commit files with CRLF line endings. That produces whole-file diffs and lint/prettier failures for everyone else.

**Why it happens:** The template ships a `.gitattributes` that tells git to store every text file with LF endings. The module has no such file.

**Evidence:** the template expects `.gitattributes` containing:

```text
* text=auto eol=lf
```

**Confirm by:** the repository root at [`a088e65`](https://github.com/bitfocus/companion-module-magewell-ultrastream/tree/a088e65c195a2232301729375f8b158f80d04244) has no `.gitattributes`.

**Fix:** add `.gitattributes` from the template with the single line `* text=auto eol=lf`.

### C2: VS Code workspace settings can be committed because `.gitignore` lacks `/.vscode`

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check on this release; the entry was already missing at v1.0.1 and `.gitignore` is unchanged in this release)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/.gitignore)

**What goes wrong:** A contributor's personal VS Code settings folder (`.vscode/`) isn't ignored, so it can end up committed to the module repo.

**Why it happens:** The module's `.gitignore` is missing one entry that the template's `.gitignore` has.

**Evidence:** missing template entry:

```text
/.vscode
```

**Confirm by:** open [`.gitignore`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/.gitignore). There is no `/.vscode` line.

**Fix:** add `/.vscode` to `.gitignore`.

## 🟠 High

### H1: LICENSE copyright year differs from the template (2020 instead of 2022)

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW (template check on this release; the same text was already there at v1.0.1)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/LICENSE#L3)

**What goes wrong:** The module's LICENSE doesn't match the template's standard Bitfocus MIT license text.

**Why it happens:** The copyright line still carries the year 2020, where the template has 2022.

**Evidence:**

```diff
- Copyright (c) 2022 Bitfocus AS - Open Source
+ Copyright (c) 2020 Bitfocus AS - Open Source
```

**Confirm by:** open [`LICENSE:3`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/LICENSE#L3).

**Fix:** replace the LICENSE with the template's file (copyright line `Copyright (c) 2022 Bitfocus AS - Open Source`).

## 🟢 Low

### L1: Input and mixer choices from the previous device stay after changing the connection's host

- **Source:** 🔎 protocol reviewer, QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/client.ts:199-212`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/client.ts#L199-L212), [`src/client.ts:309-318`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/client.ts#L309-L318), [`src/index.ts:124-142`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/index.ts#L124-L142)

**What goes wrong:** A user points an existing connection at a different unit, for example changes the Target IP from an Ultra Encode at 192.168.1.50 to an Ultra Stream at 192.168.1.60, and saves. The "Select input source" action's "Input Source" dropdown still lists the Ultra Encode's inputs (such as HDMI, SDI, Mixer), the "Change mixer settings" action's "Location" dropdown keeps the old PIP/SBS entries, and the Input and Mixer presets stay. Pressing such a button sends a command meant for the old device. If the new host can't be reached at all, the old product and model also stay in the variables and in the product-specific actions and feedbacks until the new device answers. Users who never change the host are not affected; restarting the connection clears it.

**Why it happens:** When the config changes, the module logs out (`disconnect()`) and connects again on the same client. `disconnect()` resets the login cookie and counters but not the stored product, model, input sources or mixer info. On reconnect, the input sources and mixer info are only overwritten when the new device's get-info reply contains `input-source`, which an Ultra Stream never sends. `syncDeviceInfo()` then copies the stale values back into the module state.

**Fix:** clear the device info whenever the client starts over, so a new host starts from nothing.

```ts
// src/client.ts, in disconnect()
this.productType = undefined
this.modelType = undefined
this.inputSources = undefined
this.mixerInfo = undefined
```

Alternatively, set `inputSources` and `mixerInfo` to `undefined` in `initialize()` before parsing the get-info reply, so a device without `input-source` replaces them.

### L2: Mixer preset buttons store Layer Order as a number while the action's dropdown uses text ids

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:141-148`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/actions.ts#L141-L148), [`src/feedbacks.ts:156-163`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/feedbacks.ts#L156-L163), [`src/presets.ts:460-466`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/presets.ts#L460-L466)

**What goes wrong:** A user drags a preset from the "Mixer (SDI on top)" or "Mixer (HDMI on top)" category onto a button and opens its "Change mixer settings" action. The "Layer Order" value is stored as the number `0` or `1`, but the dropdown's choices are the text values `'0'` and `'1'`, so the dropdown may show no selection (see [A1](#-assumptions-to-confirm)). Pressing the button still works. The matching feedback "Change color based on Mixer settings" uses numbers, so the action and the feedback disagree about the same option.

**Why it happens:** The action defines its Layer Order choices with text ids (`'1'`, `'0'`, default `'0'`), the feedback with numeric ids (`1`, `0`, default `0`), and the preset builder passes the number `order` to both. The action callback converts the value with `+`, which hides the mismatch when the button runs.

**Fix:** use one type everywhere, preferably numbers, to match the feedback and presets.

```ts
// src/actions.ts, Layer Order option
default: 0,
choices: [
	{ id: 1, label: 'HDMI on top' },
	{ id: 0, label: 'SDI on top' },
],
```

### L3: Ultra Stream users see input source and mixer actions and feedbacks that do nothing on their device

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:119-206`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/actions.ts#L119-L206), [`src/feedbacks.ts:119-219`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/feedbacks.ts#L119-L219)

**What goes wrong:** A user with an Ultra Stream sees the new actions "Select input source", "Change mixer settings" and "Change mixer format" and the matching feedbacks. The "Input Source" and "Location" dropdowns are empty. Pressing such a button either logs "Failed to get mixer settings" or sends a select-input-source command the device doesn't support (see [A2](#-assumptions-to-confirm)), and nothing happens. The same release already hides "Enable/Disable record channel" and "Change color based on volume" on non-Ultra Encode devices, and only creates the mixer presets when the device reports a mixer, so these definitions are inconsistent with that. Ultra Encode users are not affected.

**Why it happens:** The Input, Mixer and Mixer format actions and feedbacks are always defined. Only the record-channel action and the volume feedback are wrapped in the Ultra Encode check ([`src/actions.ts:208-210`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/actions.ts#L208-L210)), and only the presets check for mixer info ([`src/presets.ts:341`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/src/presets.ts#L341)).

**Fix:** define the Input action and feedback only when the device reports input sources, and the Mixer / Mixer format actions and feedbacks only when it reports mixer info, the same gating the presets use.

```ts
if (state.inputSources?.length) {
	actions[ActionId.Input] = { /* ... */ }
}
if (state.mixerInfo) {
	actions[ActionId.Mixer] = { /* ... */ }
	actions[ActionId.MixerFormat] = { /* ... */ }
}
```

## 🔮 Next Release

### NR1: Consider moving to a newer `@companion-module/base` in a future release

- **Source:** 🔎 compliance reviewer
- **File:** [`package.json:19`](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/package.json#L19)

**What goes wrong:** Nothing visible today. This release raises the base to `~1.12.1` (Companion 4.0+). Later 1.x versions add useful features: 1.13 parses variables in text input options automatically and adds `description` hints on options, and 1.14 brings the consistent config layout.

**Fix:** in a future release, consider `~1.14.x`, or plan the move to API 2 once the module can require Companion 4.3+.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: [line 2](https://github.com/bitfocus/companion-module-magewell-ultrastream/blob/a088e65c195a2232301729375f8b158f80d04244/tsconfig.build.json#L2) extends `@companion-module/tools/tsconfig/node18/recommended` where the template has `@companion-module/tools/tsconfig/node22/recommended`. The module builds; no change required.
