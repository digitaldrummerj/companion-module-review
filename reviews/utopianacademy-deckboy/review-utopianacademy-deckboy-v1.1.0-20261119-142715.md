# Review: companion-module-utopianacademy-deckboy v1.1.0

| | |
| --- | --- |
| **Module** | `companion-module-utopianacademy-deckboy` |
| **Scope** | `tag` (`v1.0.9..v1.1.0`) |
| **Version** | v1.1.0 |
| **Release** | Update — last published v1.0.9 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Commit** | [`9fed6b5`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/commit/9fed6b54c0f729251a160737e72e8440a33f912b) |
| **Reviewed** | 2026-11-19 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: New text-field actions do nothing, and log nothing, when the field is empty](#l1-new-text-field-actions-do-nothing-and-log-nothing-when-the-field-is-empty)
- [ ] [L2: Options that only apply to some choices are always shown in the new Multiview window, Mask and Live captions actions](#l2-options-that-only-apply-to-some-choices-are-always-shown-in-the-new-multiview-window-mask-and-live-captions-actions)
- [ ] [N1: The shared LFO Setting list is still duplicated in Effect parameter LFO](#n1-the-shared-lfo-setting-list-is-still-duplicated-in-effect-parameter-lfo)
- [ ] [N2: Lumia Control dropdown shows raw ids such as Topbottom instead of readable names](#n2-lumia-control-dropdown-shows-raw-ids-such-as-topbottom-instead-of-readable-names)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: New text-field actions do nothing, and log nothing, when the field is empty

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:657`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L657), [`src/actions.js:1242`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1242), [`src/actions.js:1256`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1256), [`src/actions.js:1270`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1270), [`src/actions.js:1292`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1292), [`src/actions.js:1326`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1326), [`src/actions.js:1337`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1337), [`src/actions.js:1530`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1530)

**What goes wrong:** An operator builds a button with **Voice: say this text** and puts a variable in **Text**, for example `$(internal:custom_announce)`. When that variable is empty and they press the button, nothing happens and the Companion log says nothing, so they can't tell an empty value from a broken connection. The same happens for **Effect choice** (empty Value), **Shader: load a .fs file** (empty Path), **Shader: set an input** and **Shader: input LFO** (empty Input name), **Lumia: set a control** (empty Value), **Voice: character** (empty name) and **Pad: assign controls to a slot** (empty X or Y control).

**Why it happens:** Each of these actions trims the text and sends the command only when something is left, with no message when nothing is. Other actions added in this same release do warn: **Mask: invert** and **Mask: opacity** log "Mask invert has no mask id: nothing sent", and the module's number check logs "… is not a number — nothing sent". So these new actions behave differently from the rest of the module.

```js
// src/actions.js:1324-1327 (Voice: say this text)
callback: async ({ options }) => {
	const text = String(options.text ?? '').trim()
	if (text.length > 0) send(`VOICE SAY ${text}`)
},
// src/actions.js:1039-1043 (Mask: invert, same release)
const mask = String(options.mask ?? '').trim()
if (!mask) {
	self.log('warn', 'Mask invert has no mask id: nothing sent')
	return
}
```

**Fix:** follow the **Mask: invert** pattern in each of these actions: when the required text is empty, log a warning and return. A small helper keeps them consistent.

```js
const text = (value, what) => {
	const t = String(value ?? '').trim()
	if (!t) self.log('warn', `${what} is empty — nothing sent`)
	return t || null
}
```

### L2: Options that only apply to some choices are always shown in the new Multiview window, Mask and Live captions actions

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:946`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L946), [`src/actions.js:999-1000`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L999-L1000), [`src/actions.js:1403`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1403)
- **Depends on:** [A1](#-assumptions-to-confirm)

**What goes wrong:** A user who adds **Multiview: what a window shows** and picks **Shows** = Programme still sees a **Playlist or output number** field, and changing it does nothing. The same happens in **Mask: put on or take off**: with **Where** = The selected cue, the **Output** and **Playlist** fields are still shown, and **Playlist** is also shown for A whole output and The matte of an output. In **Live captions: what they listen to** with **Source** = Audio input, **Playlist or output number** is still shown. The buttons send the right command, so nothing breaks, but the dialog shows fields that have no effect, and only the action's description says they are ignored.

**Why it happens:** Companion's API 2 can hide an option depending on another one, with the option's `isVisibleExpression` (an expression such as `$(options:source) == 'deck'`, re-checked as the user changes the dialog). The dropdowns these fields depend on (**Shows**, **Where**, **Source**) already set `disableAutoExpression: true`, so they can be referenced, but none of the dependent fields use `isVisibleExpression`. The module has no `isVisibleExpression` anywhere.

**Fix:** add `isVisibleExpression` to each dependent field, then the "used only when…" sentences can come out of the descriptions.

```js
// multiview_window, the number field
isVisibleExpression: "$(options:source) == 'deck' || $(options:source) == 'output'",
// mask_assign, the output field
isVisibleExpression: "$(options:where) != 'cue'",
// mask_assign, the playlist field
isVisibleExpression: "$(options:where) == 'layer'",
// captions_source, the number field
isVisibleExpression: "$(options:source) != 'input'",
```

While you're there: the two **Playlist or output number** fields allow up to 64, where every other playlist and output field in the module stops at 16 (`MAX_DECKS` / `MAX_OUTPUTS`). If 16 is the real limit, use those constants here too.

## 💡 Nice to Have

### N1: The shared LFO Setting list is still duplicated in Effect parameter LFO

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:90-108`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L90-L108), [`src/actions.js:681-698`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L681-L698)

**What goes wrong:** Users see no difference today: **Effect parameter LFO**, **Shader: input LFO** and **Lumia: control LFO** all show the same nine **Setting** choices. But this release had to add the new **Listens to** choice in two places, and the next oscillator setting added to only one of them would leave **Effect parameter LFO** out of step with the others. This is code quality only.

**Why it happens:** The new shared helper `lfoSettingOption()` is described as "The oscillator settings every LFO verb shares (FX LFO, LUMIA LFO, SHADER LFO)", but the **Effect parameter LFO** action (`fx_lfo`) keeps its own copy of the same dropdown instead of calling it.

**Fix:** replace the inline **Setting** dropdown in `fx_lfo` with `lfoSettingOption()`. It has the same id (`what`), choices and default, so saved buttons are unaffected and no upgrade script is needed.

### N2: Lumia Control dropdown shows raw ids such as Topbottom instead of readable names

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:1286`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1286), [`src/actions.js:1305-1308`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/9fed6b54c0f729251a160737e72e8440a33f912b/src/actions.js#L1305-L1308)

**What goes wrong:** In **Lumia: set a control**, the **Control** dropdown lists entries such as "Topbottom", "Listens" and "Bright", and **Lumia: control LFO** shows the same style of label for its sliders. Each one is the command id with its first letter capitalised. The action's own description calls the control "Top/bottom", so the dropdown and the description don't match. This is cosmetic: the command sent is correct.

**Why it happens:** The labels are generated from the ids (`id[0].toUpperCase() + id.slice(1)`) instead of being written out.

**Fix:** give the Lumia controls explicit labels and keep the ids unchanged, so saved buttons keep working.

```js
const LUMIA_CONTROLS = [
	{ id: 'topbottom', label: 'Top/bottom' },
	{ id: 'listens', label: 'Listens to audio' },
	// …
]
```

## 📝 Additional Notes

- The tag `v1.0.10` (`40706cd`) was never published; the `v1.1.0` commit renumbers it for the new LFO **Listens to** setting, so this review covers both commits (`v1.0.9..v1.1.0`).

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's expression parser evaluates string comparisons such as `$(options:source) == 'deck'` combined with `\|\|` in an option's `isVisibleExpression`, so the suggested expressions hide the fields as described | the base 2.1.3 typing comment for `isVisibleExpression` ("the same syntax as other expressions written inside of Companion", `$(options:some_field_id)`) and Companion's documented expression syntax; the host's parser was not run | [L2](#l2-options-that-only-apply-to-some-choices-are-always-shown-in-the-new-multiview-window-mask-and-live-captions-actions) |
