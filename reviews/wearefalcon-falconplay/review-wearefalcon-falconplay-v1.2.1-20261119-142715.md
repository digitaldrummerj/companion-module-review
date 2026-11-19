# Review: wearefalcon-falconplay v1.2.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-wearefalcon-falconplay](https://github.com/bitfocus/companion-module-wearefalcon-falconplay) |
| **Version** | v1.2.1 |
| **Release** | Update — last published v1.1.0 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Scope** | `tag` (v1.1.0..v1.2.1) |
| **Commit** | [`eaa32b9`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/commit/eaa32b94394d06a69073baad60ee0a6170e00bfd) |
| **Reviewed** | 2026-11-19 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Favorite dropdowns show Empty for every position after the connection settings are saved](#m1-favorite-dropdowns-show-empty-for-every-position-after-the-connection-settings-are-saved)
- [ ] [L1: Existing input buttons show an unknown value in the Input field after the update](#l1-existing-input-buttons-show-an-unknown-value-in-the-input-field-after-the-update)
- [ ] [L2: Thumbnail variables carry the full-size image, which can be over a megabyte of text each](#l2-thumbnail-variables-carry-the-full-size-image-which-can-be-over-a-megabyte-of-text-each)
- [ ] [N1: Thumbnail downloads that are skipped keep their HTTP connection open for up to 5 seconds](#n1-thumbnail-downloads-that-are-skipped-keep-their-http-connection-open-for-up-to-5-seconds)
- [ ] [N2: Thumbnail layout option label is not in Title Case like the labels next to it](#n2-thumbnail-layout-option-label-is-not-in-title-case-like-the-labels-next-to-it)

## 🟡 Medium

### M1: Favorite dropdowns show Empty for every position after the connection settings are saved

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:53-61`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/main.js#L53-L61), [`src/main.js:155-174`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/main.js#L155-L174), [`src/favorites.js:6-13`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/favorites.js#L6-L13)

**What goes wrong:** A user has Favorites set up in Falcon Play, for example position 3 is "Opener". At first the "Favorite Button" dropdown of the Play Favorite Button action correctly shows "Favorite 3: Opener". The same dropdown appears in the Favorite Available, Playing, Cued and Played feedbacks, Favorite Thumbnail, Favorite Text, and Item Text with Item = Favorite Button. The user then opens the connection settings and clicks Save, with or without changing the IP or port. From then on all 99 entries read "Favorite 1: Empty" through "Favorite 99: Empty", and they stay that way until a favorite is renamed or reordered on the server, another list changes, or the module restarts. Button presses still play the right slot, but the operator can no longer pick a favorite by name while building buttons. The Subitem dropdowns are not affected.

**Why it happens:** Saving the settings runs `configUpdated()`, which clears the stored server status and then rebuilds the action and feedback definitions. The Favorite choices are built from that server status, so with it cleared every slot gets no name and shows "Empty". On the next successful poll, the module only rebuilds the definitions when the favorite names differ from its own cached list (`this.favoriteButtons`). That cache is not cleared on save, so the names still match, and the "Empty" labels are never replaced.

**Evidence:**

```js
// src/main.js:53-61
	async configUpdated(config) {
		this.config = config
		this.stopPolling()
		this.clearServerStatus()
		this.updateActions()
		this.updateFeedbacks()
		this.updatePresets()
		this.startPolling()
	}
// src/main.js:155-174 (excerpt)
				const oldChoices = JSON.stringify(
					[this.subitemButtons, this.favoriteButtons].map((buttons) =>
						buttons.map((button) => [button.slot, button.name]),
					),
				)
				const favoriteButtons = data.companion?.favoriteButtons || []
				const newChoices = JSON.stringify(
					[buttons, favoriteButtons].map((buttons) => buttons.map((button) => [button.slot, button.name])),
				)
				// ...
				if (oldChoices !== newChoices) {
					this.updateActions()
					this.updateFeedbacks()
				}
```

```js
// src/favorites.js:6-13
const slots = (self) =>
	Array.from(
		{ length: SLOT_COUNT },
		(_, index) =>
			self.serverStatus?.companion?.favoriteButtons?.[index] || { slot: index + 1, label: `Favorite ${index + 1}` },
	)
const choices = (self) =>
	slots(self).map((button) => ({ id: button.slot, label: `Favorite ${button.slot}: ${button.name || 'Empty'}` }))
```

**Fix:** build the Favorite choices from the cached list instead of the live server status (the callbacks can keep reading the live status for the playing/cued state).

```js
// src/favorites.js
const slots = (self) =>
	Array.from(
		{ length: SLOT_COUNT },
		(_, index) => self.favoriteButtons?.[index] || { slot: index + 1, label: `Favorite ${index + 1}` },
	)
```

Alternatively, reset `this.favoriteButtons = []` in `configUpdated()` next to `clearServerStatus()`, so the first poll after a save sees a change and rebuilds the definitions.

## 🟢 Low

### L1: Existing input buttons show an unknown value in the Input field after the update

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/inputSelection.js:3-10`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/inputSelection.js#L3-L10)

**What goes wrong:** A user built a "Switch Input (Program)" or "Set Input to Preview" button, or an "Input On Air" feedback, in v1.1.0 and picked Input "Camera 1". After updating to v1.2.1 and opening that button, the Input field no longer reads "Camera 1"; it shows an unknown raw value instead (for example "?? (3)"). The button still switches the same physical input, so nothing breaks on air, but it looks broken, and a user who re-picks the input silently moves the button to name-based routing.

**Why it happens:** In v1.1.0 each Input choice was stored as the physical input number (for example `3`). v1.2.1 changed the choices to logical names (for example `input-name:Camera 1`) and keeps no choice for the old numbers, so a saved `3` matches nothing in the list. The module still handles the old number when the button runs (the [HELP "Input selection" section](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/companion/HELP.md#L62-L64) says so), only the label is lost. An upgrade script can't convert the saved values, because the input list is only known at run time.

**Fix:** keep the old values selectable with a readable label, for example by adding one legacy choice per input whose id is the physical number.

```js
// src/inputSelection.js
function buildInputChoices(inputs) {
	const named = inputs
		.filter((input) => typeof input.name === 'string' && input.name.length > 0)
		.map((input) => ({ id: `${INPUT_NAME_PREFIX}${input.name}`, label: input.name }))
	const legacy = inputs
		.filter((input) => input.input !== undefined)
		.map((input) => ({ id: input.input, label: `${input.name} (physical input ${input.input})` }))
	return [...named, ...legacy]
}
```

If you'd rather not, add a sentence to the HELP "Input selection" section: buttons created before v1.2.0 show the raw input number in the Input field until the input is chosen again.

### L2: Thumbnail variables carry the full-size image, which can be over a megabyte of text each

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:294-297`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/main.js#L294-L297), [`src/main.js:452-462`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/main.js#L452-L462)

**What goes wrong:** Each Favorite and Subitem thumbnail variable (for example `$(FalconPlay:favorite_1_thumbnail)`) holds the downloaded image as text. The module accepts images up to 1 MB, which is about 1.4 MB of text per variable, for up to 99 Favorites plus every Subitem. With large thumbnails, every Companion page that lists the connection's variables (the Variables tab, the variable picker) has to load all of that text, and a button whose text uses one of these variables shows a huge string. The thumbnail feedbacks are not affected: they already shrink the image to 72x58.

**Why it happens:** The download is stored as a `data:` URI of the original file, and the variable gets that stored value unchanged. Only the feedback path scales the image (`renderThumbnail` in `src/thumbnails.js`); the variables publish the original. The values are also sent again whenever the variable definitions are rebuilt, because the module then forgets which values it already published.

**Fix:** publish a scaled image in the variable instead of the original download, for example by reusing `renderThumbnail(dataUri, layout)`, which already returns a 72x58 PNG.

```js
// src/main.js, after the download is validated
const scaled = `data:image/png;base64,${renderThumbnail(dataUri, 'background')}`
```

Or apply a much smaller size cap (for example 100-200 KB) to what goes into the variable, and leave larger images to the feedbacks only.

## 💡 Nice to Have

### N1: Thumbnail downloads that are skipped keep their HTTP connection open for up to 5 seconds

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:431-453`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/main.js#L431-L453)

**What goes wrong:** Nothing visible to the user. When the Falcon Play server answers a thumbnail request with an error (for example HTTP 500), an unchanged image (304), a file over 1 MB or a format the module doesn't use, or the answer arrives after the settings were saved, the module stops without reading the reply. The HTTP connection behind it then stays busy until the 5-second timeout fires. With many Favorite or Subitem thumbnails, more connections to the Falcon Play server stay open at once than needed. The thumbnail feedbacks and variables still behave correctly.

**Why it happens:** Node's built-in `fetch` only frees a connection once the reply body has been read, cancelled or aborted. Every early `return` after `await fetch(...)` in `refreshThumbnailVariables()` skips the body, so the connection is only freed by `AbortSignal.timeout(5000)`.

**Fix:** cancel the reply body on each early return after `fetch()` resolves, for example:

```js
if (!isCurrent() || response.status === 304) {
	await response.body?.cancel().catch(() => {})
	return
}
```

Or wrap the request in an `AbortController` that you abort in a `finally`.

### N2: Thumbnail layout option label is not in Title Case like the labels next to it

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:20`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/feedbacks.js#L20), [`src/favorites.js:68`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/favorites.js#L68)

**What goes wrong:** In the Subitem Thumbnail, Favorite Thumbnail, Item Text and Favorite Text feedbacks, the field reads "Thumbnail layout", while the fields around it read "Subitem Button", "Favorite Button" and "Show Thumbnail". Cosmetic only.

**Why it happens:** The label is written as `'Thumbnail layout'` in both files, while the other new option labels use Title Case.

**Fix:** rename the label to `'Thumbnail Layout'` in [`src/feedbacks.js:20`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/feedbacks.js#L20) and [`src/favorites.js:68`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/src/favorites.js#L68), and in the [`README.md:11`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/eaa32b94394d06a69073baad60ee0a6170e00bfd/README.md#L11) sentence that mentions it.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Node 22's built-in `fetch` keeps an HTTP connection busy until an unread reply body is read, cancelled or aborted, and `AbortSignal.timeout(5000)` also aborts the body, which caps the delay at 5 seconds | undici/Node `fetch` documentation on consuming reply bodies; not visible in the module or `@companion-module/base` | [N1](#n1-thumbnail-downloads-that-are-skipped-keep-their-http-connection-open-for-up-to-5-seconds) |
| A2 | The Companion action and feedback editor labels the selected dropdown value from the module's most recently registered definitions, so stale choice labels are what the user sees | how Companion renders dropdowns from `setActionDefinitions` / `setFeedbackDefinitions`; Companion's host code not checked | [M1](#m1-favorite-dropdowns-show-empty-for-every-position-after-the-connection-settings-are-saved) |
| A3 | Companion's editor shows a saved dropdown value that is not in the current choices as an unknown raw value (for example "?? (3)"), not as the old label | the reviewer's memory of Companion's dropdown field; not checkable from the module or `@companion-module/base` | [L1](#l1-existing-input-buttons-show-an-unknown-value-in-the-input-field-after-the-update) |
| A4 | Companion sends every connection variable value, including very long strings, to web UI views that list variables (Variables tab, variable picker), so multi-megabyte values slow those views | general Companion host behaviour; not visible in the module or `@companion-module/base` | [L2](#l2-thumbnail-variables-carry-the-full-size-image-which-can-be-over-a-megabyte-of-text-each) |
