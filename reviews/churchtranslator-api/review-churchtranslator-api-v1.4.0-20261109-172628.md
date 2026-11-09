# Review: companion-module-churchtranslator-api v1.4.0 (follow-up to the v1.3.1 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-churchtranslator-api` |
| **Scope** | `tag` (`v1.3.2..v1.4.0`) |
| **Version** | v1.4.0 |
| **Release** | Update — last published v1.3.2 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Commit** | [`d85f846`](https://github.com/bitfocus/companion-module-churchtranslator-api/commit/d85f8461fe6192371030a12631eaf07d5e05527f) |
| **Previous review** | [v1.3.1, 2026-10-30](review-churchtranslator-api-v1.3.1-20261030-003407.md) |
| **Reviewed** | 2026-11-09 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Input meter keys placed with 1.2.0 to 1.3.2 lose their level bar after updating to 1.4.0](#m1-input-meter-keys-placed-with-120-to-132-lose-their-level-bar-after-updating-to-140)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Input meter keys placed with 1.2.0 to 1.3.2 lose their level bar after updating to 1.4.0

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/feedbacks.js:184-209`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/feedbacks.js#L184-L209), [`src/upgrades.js:15`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/upgrades.js#L15)

**What goes wrong:** A church dragged the "Input meter" preset onto a button with module 1.2.0 to 1.3.2, then updates the connection to 1.4.0. At the next live service the key still shows the on-air clock (for example `42:13`) and still turns red with NO SOUND when the audio stops, but the 10-segment level bar along the bottom is gone. The booth operator loses the moving bar that showed the audio path from the mixer to the cloud was working, and nothing on the button says why. The same happens to the meter key of any dashboard download made before 2026-11-03. Keys built from the 1.4.0 preset are not affected. Depends on [A1](#-assumptions-to-confirm).

**Why it happens:** 1.4.0 removes the "Input level meter" feedback (`input_meter`, an advanced feedback that painted the bar into the button's image). The new "Input level" feedback (`input_level`) only returns a value, which draws only through the new "Input level meter" element on a layered button. Saved buttons still point at the old feedback id, which the module no longer defines, so nothing draws their bar. An upgrade script can't rebuild those buttons: it can only change a feedback's id and options, not add an element or a local variable to a button, so `src/upgrades.js` stays empty. The README and HELP.md explain that the preset has to be dragged again, but an operator who hasn't read them finds out during a service.

**Evidence:**

```js
// src/feedbacks.js:184-191 (v1.4.0)
		// The meter's value, drawn by the "Input level meter" element
		// (composites.js). It replaced 1.3's advanced "input_meter"
		// feedback, which painted the bar into an image buffer; buttons
		// saved with that one lose their bar and need the preset again.
		input_level: {
			type: 'value',
			name: 'Input level (for the level meter)',
```

```js
// v1.3.2 src/feedbacks.js:184-188 (removed in this release)
		input_meter: {
			type: 'advanced',
			name: 'Input level meter',
			// ...
			affectedProperties: ['imageBuffer'],
```

```js
// src/upgrades.js:15
export const UpgradeScripts = []
```

**Confirm by:** run `git diff v1.3.2..v1.4.0 -- src/feedbacks.js`. The `input_meter` advanced feedback is removed, and [`src/upgrades.js:15`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/upgrades.js#L15) still exports an empty array.

**Fix:** keep the 1.3 feedback next to the new one, under a name that points to the preset, so saved meter keys keep drawing until advanced feedbacks go in a future major API version. `drawMeter` is still in [`src/health.js:186`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/health.js#L186), and both feedbacks can share `meterFeedbackSeen` and `meterFeedbackGone`. Recheck `input_meter` wherever `input_level` is rechecked ([`src/main.js:68-78`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L68-L78), [`src/main.js:619`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L619)). If you'd rather drop it, also put the breaking change in the GitHub release notes for 1.4.0, so booths re-drag the preset before a service.

```js
// src/feedbacks.js: next to input_level
input_meter: {
	type: 'advanced',
	name: 'Input level meter (legacy, use the Input meter preset)',
	affectedProperties: ['imageBuffer'],
	options: [],
	callback: (feedback) => {
		instance.meterFeedbackSeen?.(feedback.id)
		return drawMeter(inputView(instance.state, instance.meter), feedback.image)
	},
	unsubscribe: (feedback) => {
		instance.meterFeedbackGone?.(feedback.id)
	},
},
```

## 📝 Additional Notes

- This is a follow-up to the [v1.3.1 review](review-churchtranslator-api-v1.3.1-20261030-003407.md). Every finding from that review is fixed: most in v1.3.2 (already published), the meter (v1.3.1 M2) in v1.4.0. Each was re-checked at v1.4.0:

| v1.3.1 finding | Status at v1.4.0 |
| --- | --- |
| C1 `.prettierignore`, C2 Node 26 runtime, H1 module-checks workflow, M3 release workflow | ✅ Fixed in v1.3.2. The template check reports no differences. |
| M1 cancelled button actions still reach the server | ✅ Fixed in v1.3.2. Every action passes `context.signal` to its request ([`src/actions.js:37-112`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/actions.js#L37-L112)), and a cancelled press sends nothing and skips the follow-up refresh ([`src/main.js:661-694`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L661-L694)). |
| M2 meter drawn with the bitmap feedback type | ✅ Fixed in v1.4.0. A value feedback now feeds a composite element and a layered preset. The change leaves older meter keys without a bar (M1 above). |
| L1 status poll left running after a disable during the first poll | ✅ Fixed in v1.3.2. The poll loop isn't started on a destroyed connection ([`src/main.js:281`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L281)). |
| L2 speaker language stuck on older servers | ✅ Fixed in v1.3.2. The language from the status reply wins over the stored one ([`src/main.js:379`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L379), [`src/main.js:388`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L388)). |
| L3 language list re-fetched on every refresh | ✅ Fixed in v1.3.2. Retried at most once a minute, without holding up the buttons, and an empty list counts as loaded ([`src/main.js:413`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L413)). |
| L4 per-language variable names stuck as bare codes | ✅ Fixed in v1.3.2. Variable definitions are re-sent when their names change, not only their ids ([`src/main.js:498-499`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L498-L499)). |
| L5 checkbox and fixed-choice options accept expressions | ✅ Fixed in v1.3.2. `disableAutoExpression: true` on the three options ([`src/actions.js:103`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/actions.js#L103), [`src/feedbacks.js:135`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/feedbacks.js#L135), [`src/feedbacks.js:168`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/feedbacks.js#L168)). |
| N1 mistyped Server URL shows a misleading error | ✅ Fixed in v1.3.2. The field is checked for `http(s)://`, the value is trimmed, and a bad URL reports Bad Config ([`src/main.js:220-221`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L220-L221), [`src/api.js:72-83`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/api.js#L72-L83)). |
| N2 unconfigured connection flashes Authentication Failure | ✅ Fixed in v1.3.2. A missing token stays Bad Config when a button is pressed ([`src/main.js:686`](https://github.com/bitfocus/companion-module-churchtranslator-api/blob/d85f8461fe6192371030a12631eaf07d5e05527f/src/main.js#L686)). |

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a saved button uses a feedback id the module no longer defines (`input_meter`), Companion 5 keeps that entry on the button and draws nothing for it, without an error; the button editor may show it as an unknown feedback | The module's own README and HELP.md ("buttons saved with that one lose their bar") and general Companion behaviour; the host code isn't in `@companion-module/base` 2.1.3, so it wasn't checked | [M1](#m1-input-meter-keys-placed-with-120-to-132-lose-their-level-bar-after-updating-to-140) |
