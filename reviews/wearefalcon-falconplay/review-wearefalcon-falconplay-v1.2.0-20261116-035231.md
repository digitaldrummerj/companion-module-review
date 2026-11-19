# Companion Module Review: wearefalcon-falconplay v1.2.0

| Item | Value |
| --- | --- |
| **Module** | `companion-module-wearefalcon-falconplay` |
| **Scope** | `tag` (changes in `v1.1.0..v1.2.0`) |
| **Version** | v1.2.0 |
| **Release** | Update — last published v1.1.0 |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Review commit** | [`7a93ca7`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/commit/7a93ca746b91d893f05333f15062aabc8b1272f7) |
| **Reviewed** | 2026-11-16 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: Old copies of the source files are left at the repository root](#c1-old-copies-of-the-source-files-are-left-at-the-repository-root)
- [ ] [H1: The module's Help page leaves out most of the new variables](#h1-the-modules-help-page-leaves-out-most-of-the-new-variables)

### Non-blocking

- [ ] [M1: With more than 64 thumbnails in use, button images blink every 2 seconds and every thumbnail is downloaded again on each poll](#m1-with-more-than-64-thumbnails-in-use-button-images-blink-every-2-seconds-and-every-thumbnail-is-downloaded-again-on-each-poll)
- [ ] [L1: Every 2-second poll resends about 1,370 variable values and re-checks every feedback, even when nothing changed](#l1-every-2-second-poll-resends-about-1370-variable-values-and-re-checks-every-feedback-even-when-nothing-changed)
- [ ] [L2: WebP thumbnails are downloaded and put in variables but never appear on buttons](#l2-webp-thumbnails-are-downloaded-and-put-in-variables-but-never-appear-on-buttons)
- [ ] [L3: A module error while processing the server status shows as a connection failure, with nothing logged](#l3-a-module-error-while-processing-the-server-status-shows-as-a-connection-failure-with-nothing-logged)
- [ ] [N1: Favorite Text always shows the Thumbnail layout option, even with Show Thumbnail off](#n1-favorite-text-always-shows-the-thumbnail-layout-option-even-with-show-thumbnail-off)

## 🔴 Critical

### C1: Old copies of the source files are left at the repository root

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW (template checks cover the whole module in every scope; these files are unchanged since v1.1.0)
- **File:** [`actions.js`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/actions.js), [`feedbacks.js`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/feedbacks.js), [`main.js`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/main.js), [`variables.js`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/variables.js)

**What goes wrong:** Four `.js` files sit at the root of the repository next to `src/`. Companion never loads them, so anyone who reads or edits them (a contributor, or the maintainer in a hurry) changes code that does nothing. The template requires all module source to live under `src/`.

**Why it happens:** They are leftover copies from before the code moved into `src/`. `package.json` `main` (`src/main.js`) and the manifest's `runtime.entrypoint` (`../src/main.js`) both point into `src/`. The root `main.js` couldn't even start on its own: it loads `./upgrades`, and `upgrades.js` exists only in `src/`. The root copies were last changed in `00d0772` (`actions.js`) and `0313a41` (the other three).

**Validator output:**

```text
actions.js     Source file at module root — all source must be under src/
feedbacks.js   Source file at module root — all source must be under src/
main.js        Source file at module root — all source must be under src/
variables.js   Source file at module root — all source must be under src/
```

```js
// main.js:3 (root copy)
const UpgradeScripts = require('./upgrades')
```

**Fix:** delete the four root files. The live code in `src/` is unaffected.

```bash
git rm actions.js feedbacks.js main.js variables.js
```

## 🟠 High

### H1: The module's Help page leaves out most of the new variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:66-84`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/companion/HELP.md#L66-L84)

**What goes wrong:** A user who opens the module's help (the **?** next to the connection) to find which variables to put on a button sees 13 entries. Missing are the new `server_connected`, `rundown_id`, `rundown_onair_uid`, `rundown_cued_uid`, `onair_item_uid` / `_type`, `cued_item_uid` / `_type`, `selected_item` / `_uid` / `_type`, `selected_story_id`, `subitem_button_count`, `file_server_ip` and `file_server_version`, and the per-position `subitem_N_name`, `uid`, `type`, `thumbnail_url`, `thumbnail`, `available`, `playing`, `cued` and `played` fields. The README documents them, but users don't see the README inside Companion. No functional effect.

**Why it happens:** This release added about 20 fixed variables and 14 per-position variables, but only the `_display_text` entries were added to the Help page's table.

**Evidence:**

```js
// src/variables.js:3-8, 22-29 (excerpt)
	const definitions = [
		{ variableId: 'server_connected', name: 'Falcon Play Connected' },
		{ variableId: 'server_version', name: 'Server Version' },
		{ variableId: 'rundown_id', name: 'Active Rundown ID' },
		{ variableId: 'rundown_name', name: 'Active Rundown Name' },
		{ variableId: 'rundown_onair_uid', name: 'Rundown On-Air UID' },
		...
		{ variableId: 'subitem_button_count', name: 'Configured Subitem Button Count' },
		...
		{ variableId: 'file_server_ip', name: 'File Server IP' },
		{ variableId: 'file_server_version', name: 'File Server Version' },
	]
```

```text
// companion/HELP.md:66-84 lists 13 variables; occurrences per file (HELP.md / README.md)
server_connected 0 / 1    rundown_id 0 / 1           selected_story_id 0 / 1
file_server_ip 0 / 1      file_server_version 0 / 1  subitem_button_count 0 / 1
```

**Confirm by:** compare the `## Variables` table in [`companion/HELP.md:66-84`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/companion/HELP.md#L66-L84) with the definitions in [`src/variables.js`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/variables.js#L3-L29). `server_connected`, `rundown_id` and `file_server_ip` are among those defined but not in HELP.md.

**Fix:** copy the variable table from [`README.md:142-157`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/README.md#L142-L157), including the per-position field list and the note that Favorites always expose positions 1–99, into the `## Variables` section of `companion/HELP.md`.

## 🟡 Medium

### M1: With more than 64 thumbnails in use, button images blink every 2 seconds and every thumbnail is downloaded again on each poll

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:302-305`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/main.js#L302-L305), [`src/main.js:343-347`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/main.js#L343-L347), [`src/favorites.js:4`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/favorites.js#L4)
- **Depends on:** [A1](#-assumptions-to-confirm), [A2](#-assumptions-to-confirm)

**What goes wrong:** Take an operator who has more than 64 Favorite positions with pictures, or for example 56 Favorites plus 9 Subitem Buttons with thumbnails, and who places the shipped **Favorites** presets (99 buttons, each with **Favorite Text** and a thumbnail). Every 2 seconds a rotating group of buttons loses its picture and gets it back once the image has downloaded again: 16 buttons when 80 thumbnails are in use. Variables such as `$(FalconPlay:favorite_12_thumbnail)` flip between the image and an empty value at the same rate. The module also stops respecting its own 15-second revalidation: with 80 thumbnails it sends 80 image requests every 2 seconds (about 40 per second) to the live Falcon Play playout server, 16 of them full downloads. The Help page promises thumbnails are "revalidated every 15 seconds". With 64 or fewer thumbnails everything works as intended.

**Why it happens:** The module keeps two lists per thumbnail URL: when it last checked the picture (so it waits 15 seconds between checks) and the downloaded image itself. Both lists hold at most 64 entries and drop the oldest entry when a 65th is added, and Favorites (up to 99) and Subitem Buttons share them. With more than 64 active pictures, each poll's new "last checked" entries push out the entries of pictures checked earlier in the same poll. On the next poll those pictures look unchecked and are fetched again, which pushes out others, and so on. The image list drops pictures the same way, and while a picture is missing from it the variable is published empty and the thumbnail feedbacks draw no image until the download puts it back. The QA reviewer reproduced this with a mock server that answers `304 Not Modified`: 80 requests per poll (64 conditional, 16 full) and 16 thumbnail variables blanked and restored on every poll. At 64 thumbnails there were no requests after the first poll until 15 seconds had passed.

**Evidence:**

```js
// src/main.js:299-305
for (const button of data.companion?.[collection] || []) {
	if (!button.thumbnailUrl || !button.available) continue
	const url = `${this.getBaseUrl()}${button.thumbnailUrl}`
	if (this.thumbnailRequests.has(url) || Date.now() - (this.thumbnailCheckedAt.get(url) || 0) < 15000) continue
	this.thumbnailCheckedAt.set(url, Date.now())
	if (this.thumbnailCheckedAt.size > 64)
		this.thumbnailCheckedAt.delete(this.thumbnailCheckedAt.keys().next().value)
// src/main.js:343-347
if (this.thumbnailCache.size > 64) {
	const oldest = this.thumbnailCache.keys().next().value
	this.thumbnailCache.delete(oldest)
	this.thumbnailValidators.delete(oldest)
}
// src/favorites.js:4
const SLOT_COUNT = 99
```

**Fix:** instead of capping both lists at 64 and dropping the oldest entry, remove only the URLs that the current status no longer uses. Delete the two `size > 64` blocks and prune at the end of `refreshThumbnailVariables()`:

```js
const base = this.getBaseUrl()
const active = new Set(
	['subitemButtons', 'favoriteButtons'].flatMap((collection) =>
		(data.companion?.[collection] || []).filter((b) => b.thumbnailUrl).map((b) => `${base}${b.thumbnailUrl}`),
	),
)
for (const url of this.thumbnailCheckedAt.keys()) if (!active.has(url)) this.thumbnailCheckedAt.delete(url)
for (const url of this.thumbnailCache.keys()) {
	if (!active.has(url)) {
		this.thumbnailCache.delete(url)
		this.thumbnailValidators.delete(url)
	}
}
```

If you prefer to keep a cap, make it at least `FAVORITE_SLOTS + this.subitemButtons.length`, and never drop a "last checked" entry for a URL that is still in the current poll's button list.

## 🟢 Low

### L1: Every 2-second poll resends about 1,370 variable values and re-checks every feedback, even when nothing changed

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:163-166`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/main.js#L163-L166), [`src/main.js:179-183`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/main.js#L179-L183), [`src/main.js:260-290`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/main.js#L260-L290)
- **Depends on:** [A3](#-assumptions-to-confirm)

**What goes wrong:** No visible malfunction. With 3 Subitem Buttons, each poll (every 2 seconds) sends 1,367 variable values to Companion and asks it to re-run every feedback on the connection, including the thumbnail feedbacks that return images. The same 1,367 values go out every 2 seconds while the server is unreachable. Any change to a subitem or favorite name (subitem names follow the selected story, so most story changes) also rebuilds every action, feedback and preset definition, including the 99 Favorite presets. On busy systems with many buttons this adds a steady CPU and inter-process load to Companion.

**Why it happens:** The variable update writes 13 fields for each of the 99 favorite positions and each subitem position on every call; only the thumbnail variable is compared with what was sent before. The poll then calls `checkFeedbacks()` with no feedback types, which re-runs every feedback on the connection (v1.1.0 checked only three feedback types). `@companion-module/base` 1.12.1 doesn't skip unchanged values on either path: `setVariableValues()` forwards every key, and `checkFeedbacks()` with no types re-checks every feedback instance.

**Fix:** remember the last value sent for each variable and pass only the changed ones to `setVariableValues()`, the way the thumbnail variables already work. Pass `checkFeedbacks()` only the feedback types whose inputs changed. Consider rebuilding presets only when the slot count or the favorites list changes, not on every name change.

```js
// in the constructor: this.lastVars = {}
const changed = {}
for (const [id, value] of Object.entries(vars)) {
	if (this.lastVars[id] !== value) changed[id] = this.lastVars[id] = value
}
if (Object.keys(changed).length > 0) this.setVariableValues(changed)
```

### L2: WebP thumbnails are downloaded and put in variables but never appear on buttons

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:333`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/main.js#L333), [`src/thumbnails.js:5-6`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/thumbnails.js#L5-L6)

**What goes wrong:** When a subitem or favorite thumbnail arrives as WebP, the module downloads it, caches it and puts it in the `subitem_N_thumbnail` / `favorite_N_thumbnail` variables. **Subitem Thumbnail**, **Favorite Thumbnail**, and **Item Text** / **Favorite Text** with **Show Thumbnail** still show no picture, and nothing is logged. The user sees an empty button image while the variable holds an image. (The Help page says only JPEG and PNG are supported, which matches what the buttons can show.)

**Why it happens:** The download accepts `image/webp`, but the button image renderer only decodes JPEG and PNG. For anything else it throws "Unsupported thumbnail", and the feedback catches that and returns an empty style. The module fetches a format it can never draw.

**Fix:** either remove `'image/webp'` from the accepted types, so unusable images are neither downloaded nor published, or add WebP decoding to `renderThumbnail()`. Log once at debug level when a thumbnail format can't be rendered.

```js
// src/main.js:333
if (!response.ok || !['image/jpeg', 'image/png'].includes(mime) || size > 1024 * 1024) return
```

### L3: A module error while processing the server status shows as a connection failure, with nothing logged

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:135-176`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/main.js#L135-L176)

**What goes wrong:** The server is reachable and returns a valid status. If any of the processing after the request throws (rebuilding the actions, feedbacks, presets or variable definitions, or setting the roughly 1,400 variable values), the connection turns red with "Cannot reach Falcon Play" and the Companion log shows no error. The user and the maintainer go looking for a network problem that doesn't exist.

**Why it happens:** In v1.2.0 the `try` block in `pollStatus()` grew to cover all of that processing, not just the HTTP request. The bare `catch {}` doesn't capture or log the error, and it always sets the status to `ConnectionFailure`.

**Fix:** keep only the request in the network `try`/`catch`, and process the reply in a second `try`/`catch` that logs the error and sets `UnknownError` with its message, so the status tells network failures apart from module errors.

```js
let data
try {
	data = await this.httpGet('/api/status')
} catch {
	// existing generation check + ConnectionFailure handling
	return
}
try {
	// existing generation check + processing of data
} catch (err) {
	this.log('error', `Status processing failed: ${err.message}`)
	this.updateStatus(InstanceStatus.UnknownError, err.message)
}
```

## 💡 Nice to Have

### N1: Favorite Text always shows the Thumbnail layout option, even with Show Thumbnail off

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:245-256`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/feedbacks.js#L245-L256)

**What goes wrong:** A user adds the **Favorite Text** feedback and leaves **Show Thumbnail** unticked. The **Thumbnail layout** dropdown (Image Above Text / Image Behind Text) still appears, although it does nothing. In **Item Text** the same option stays hidden until **Show Thumbnail** is ticked. Cosmetic only.

**Why it happens:** **Favorite Text** copies three options from **Item Text** and removes every visibility rule (`isVisibleExpression`), because those rules refer to the **Source** option that **Favorite Text** doesn't have. That is right for **Show Thumbnail**, but **Thumbnail layout** also loses its dependency on **Show Thumbnail**.

**Fix:** give **Thumbnail layout** a new visibility rule that depends only on **Show Thumbnail**, in the `.map()` at [`src/feedbacks.js:252-255`](https://github.com/bitfocus/companion-module-wearefalcon-falconplay/blob/7a93ca746b91d893f05333f15062aabc8b1272f7/src/feedbacks.js#L252-L255):

```js
.map((option) => {
	const { isVisibleExpression, ...copy } = option
	return option.id === 'thumbnailLayout' ? { ...copy, isVisibleExpression: '$(options:showThumbnail)' } : copy
}),
```

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Some productions have more than 64 Favorite and Subitem positions with a thumbnail in use at the same time | The module exposes 99 Favorite positions and ships 99 Favorite presets, and the Help page says Falcon Play has no Favorites limit; a usage likelihood, not checked against real productions. The code path itself was reproduced | [M1](#m1-with-more-than-64-thumbnails-in-use-button-images-blink-every-2-seconds-and-every-thumbnail-is-downloaded-again-on-each-poll) |
| A2 | Companion redraws a button when an advanced feedback that returned an image (`png64`) returns `{}` on the next check, and redraws it again when the image comes back | General Companion host behaviour for advanced feedbacks; the module side (returning `{}` on a cache miss, then calling `checkFeedbacks()`) was verified in code, Companion's host code was not checked | [M1](#m1-with-more-than-64-thumbnails-in-use-button-images-blink-every-2-seconds-and-every-thumbnail-is-downloaded-again-on-each-poll) |
| A3 | The Companion host does measurable work for each variable value and feedback result it receives, even when the value hasn't changed | `@companion-module/base` 1.12.1 was read and doesn't skip unchanged values before sending; whether Companion skips them on receipt, and the actual cost, were not measured | [L1](#l1-every-2-second-poll-resends-about-1370-variable-values-and-re-checks-every-feedback-even-when-nothing-changed) |
