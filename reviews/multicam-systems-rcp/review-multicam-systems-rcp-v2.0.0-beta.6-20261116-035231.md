# Review: multicam-systems-rcp v2.0.0-beta.6

| Field | Value |
| --- | --- |
| **Module** | `companion-module-multicam-systems-rcp` |
| **Scope** | `tag` (changes since v1.0.3) |
| **Version** | v2.0.0-beta.6 |
| **Release** | Update — last published v1.0.3 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Review commit** | [`a65c1513`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/tree/a65c1513e24b349db43313a9fab862e19bce1ce2) |
| **Reviewed** | 2026-11-16 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: A relative adjust button pressed before the camera reports a value sets the control to the step amount](#m1-a-relative-adjust-button-pressed-before-the-camera-reports-a-value-sets-the-control-to-the-step-amount)
- [ ] [M2: After a camera is hidden in RCP, value presets of later cameras show another camera's value](#m2-after-a-camera-is-hidden-in-rcp-value-presets-of-later-cameras-show-another-cameras-value)
- [ ] [M3: Wrong option names and feedback ids are not caught at build time because actions and feedbacks are untyped](#m3-wrong-option-names-and-feedback-ids-are-not-caught-at-build-time-because-actions-and-feedbacks-are-untyped)
- [ ] [M4: The manifest is missing the template's schema reference](#m4-the-manifest-is-missing-the-templates-schema-reference)
- [ ] [L1: The module class lives behind a re-export and an adapter base class instead of in main.ts](#l1-the-module-class-lives-behind-a-re-export-and-an-adapter-base-class-instead-of-in-maints)
- [ ] [L2: HELP and README say Companion 5.1 or later, but Companion 5.0 can install this release](#l2-help-and-readme-say-companion-51-or-later-but-companion-50-can-install-this-release)
- [ ] [L3: An RCP with a different integration API version leaves the connection on Connecting with no explanation](#l3-an-rcp-with-a-different-integration-api-version-leaves-the-connection-on-connecting-with-no-explanation)
- [ ] [L4: Each live video frame redraws every Live video image tile, not only the tiles showing that source](#l4-each-live-video-frame-redraws-every-live-video-image-tile-not-only-the-tiles-showing-that-source)
- [ ] [L5: Every RCP state message re-runs all feedbacks on every button](#l5-every-rcp-state-message-re-runs-all-feedbacks-on-every-button)
- [ ] [L6: The selected border on live camera tiles may not show, because two elements share one id](#l6-the-selected-border-on-live-camera-tiles-may-not-show-because-two-elements-share-one-id)
- [ ] [L7: Five advanced feedbacks declare button properties they never set](#l7-five-advanced-feedbacks-declare-button-properties-they-never-set)
- [ ] [N1: Errors in the module's own state handling are reported as an unreadable RCP message and drop the connection](#n1-errors-in-the-modules-own-state-handling-are-reported-as-an-unreadable-rcp-message-and-drop-the-connection)
- [ ] [N2: Old Socket.IO types are force-cast onto the new API state, and some helpers are now dead code](#n2-old-socketio-types-are-force-cast-onto-the-new-api-state-and-some-helpers-are-now-dead-code)
- [ ] [NR1: Match the API 2.1 TypeScript template's build scripts and lint-staged version](#nr1-match-the-api-21-typescript-templates-build-scripts-and-lint-staged-version)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: A relative adjust button pressed before the camera reports a value sets the control to the step amount

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:198-211`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/actions.ts#L198-L211), [`src/actions.ts:97-114`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/actions.ts#L97-L114)

**What goes wrong:** An operator has a button with **Float: Adjust Property (Relative)**, for example Property Iris with Adjustment +0.05. They press it right after the camera connects, while the value still shows a dash because the camera has not reported Iris yet (HELP describes this dash for reported controls). The module does not send "iris + 0.05". It sends 0.05 as the new absolute value, so the iris jumps to that setting. **Boolean: Toggle Property** has the same gap: while the state is unknown it always sends On, so pressing toggle on a camera that is really On does nothing visible.

**Why it happens:** Version 2 stores "not reported yet" as `null` for a control that reports its own value (`knownValue` in [`src/api.ts:36-39`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/api.ts#L36-L39)). The relative adjust action only handles a number or an `{ value }` object, so a `null` falls through to `newValue = adjustment` and is sent as an absolute set. That fallback line existed in 1.0, but there it was only reached in the moment before the first reply; version 2 makes "not reported yet" a normal state that can last. The toggle action treats `null` as Off.

**Fix:** when the current value is not a known number, log a warning (for example "Iris has not reported yet") and send nothing, or send a relative adjust command instead of an absolute set. Give the toggle action the same treatment: do nothing and warn while the value is `null` or `undefined`.

### M2: After a camera is hidden in RCP, value presets of later cameras show another camera's value

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets/index.ts:47-49`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/presets/index.ts#L47-L49), [`src/presets/index.ts:60-61`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/presets/index.ts#L60-L61), [`src/presets/index.ts:89`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/presets/index.ts#L89)

**What goes wrong:** A user hides Camera A in RCP under Setup → Companion buttons. In the "Camera settings: Camera B" preset section, the value tiles (for example "White Balance Mode Value", or the value tiles of numeric controls without a gauge) now read `$(multicam-rcp:camera_1_…)`, which is Camera A's variable. The button shows Camera A's value, or stays empty when Camera A has no such control, while its actions still control Camera B.

**Why it happens:** Hidden cameras are new in this release. The presets number cameras over the filtered list of visible cameras, but the variables are numbered over the full camera list ([`src/variables.ts:29-31`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/variables.ts#L29-L31)). As soon as any camera before it is hidden, the two numbers point at different cameras.

**Evidence:**

```ts
// src/presets/index.ts:49
	const visibleCameras = self.cameras.filter((camera) => !hiddenCameras.has(camera.uuid))
// src/presets/index.ts:60-61
	visibleCameras.forEach((camera, cameraIndex) => {
		const camNum = cameraIndex + 1
// src/presets/index.ts:89
				const variable = `$(multicam-rcp:camera_${camNum}_${prop})`
// src/variables.ts:29-30
	self.cameras.forEach((camera, index) => {
		const camNum = index + 1 // 1-based indexing
```

**Fix:** number the variable by the camera's position in the full list, not in the visible list. While on that line, consider building the reference from the connection's label instead of the hard-coded `multicam-rcp`.

```ts
const camNum = self.cameras.indexOf(camera) + 1
const variable = `$(${self.label}:camera_${camNum}_${prop})`
```

### M3: Wrong option names and feedback ids are not caught at build time because actions and feedbacks are untyped

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/companion.ts:31-34`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/companion.ts#L31-L34), [`src/instance.ts:47-48`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L47-L48)

**What goes wrong:** Nothing is visible today, but nothing stops a typo in an option or feedback id from shipping. For example, the live image handler asks Companion to re-check a feedback called `live_image_button`, which does not exist on this release line (it belongs to the Companion 4 branch); a typed schema would have flagged it. Every callback also casts its options by hand (`action.options.camera as string`, more than 120 casts across actions.ts, feedbacks.ts and graphics.ts), so a renamed option silently becomes `undefined` and the button just does nothing.

**Why it happens:** The action table is typed as a record of any option values, and the instance type keeps Companion's generic actions, feedbacks and variables instead of a typed schema. API 2.x lets a module declare `ActionsSchema` / `FeedbacksSchema` types so the compiler checks every option and feedback id.

**Evidence:**

```ts
// src/companion.ts:31-34
/** The action table UpdateActions builds: options as Companion hands them over. */
export type ActionDefinitions = CompanionActionDefinitions<Record<string, { options: CompanionOptionValues }>>

export type ModuleTypes = InstanceTypes & { config: ModuleConfig; secrets: ModuleSecrets }
// src/instance.ts:47-48
		// live_image feeds the layered tiles, live_image_button a classic button (Companion 4).
		() => this.checkFeedbacks('live_image', 'live_image_button'),
```

**Fix:** declare `ActionsSchema`, `FeedbacksSchema` and `VariablesSchema` types as in the template (actions.ts, feedbacks.ts, variables.ts), build the definitions with `CompanionActionDefinitions<ActionsSchema>` and `CompanionFeedbackDefinitions<FeedbacksSchema>`, then remove the option casts. Remove `'live_image_button'` from the `checkFeedbacks` call in [`src/instance.ts:48`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L48).

### M4: The manifest is missing the template's schema reference

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:1-3`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/companion/manifest.json#L1-L3)

**What goes wrong:** Users see no difference. Maintainers lose the editor validation and autocomplete the template's `$schema` line gives manifest.json, so a typo in a manifest key (for example in the new `bonjourQueries` block) is not flagged while editing.

**Why it happens:** This release rewrote the manifest for API 2.1 (it added `type`, `node26` and `bonjourQueries`) but did not add the `$schema` reference that every TypeScript template starts with. The line was also missing at v1.0.3.

**Evidence:**

```json
// companion/manifest.json:1-3
{
	"id": "multicam-systems-rcp",
	"name": "multicam-systems-rcp",
// companion-module-template-ts/companion/manifest.json:1-3
{
	"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json",
	"type": "connection",
```

**Fix:** add the template's `$schema` line as the first key.

```json
"$schema": "../node_modules/@companion-module/base/assets/manifest.schema.json",
```

## 🟢 Low

### L1: The module class lives behind a re-export and an adapter base class instead of in main.ts

- **Source:** 🔎 compliance reviewer — ⚠️ needs your check
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:1-6`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/main.ts#L1-L6), [`src/companion.ts:34-42`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/companion.ts#L34-L42), [`src/instance.ts:33`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L33)

**What goes wrong:** Users see no difference in Companion. A maintainer or reviewer who opens `src/main.ts`, where the template keeps the module class, finds only a re-export. The real `ModuleInstance` is in `src/instance.ts` and extends an abstract `ModuleBase` from `src/companion.ts`. Every source file gets Companion's types and helpers through that adapter instead of from `@companion-module/base`, so following any lifecycle or typing problem means going through an extra layer the template doesn't have.

**Why it happens:** At v1.0.3 the class was in `src/main.ts`. This release split out a shared core for a Companion 4 / API 1.13 branch (README "Release lines"): `main.ts` now only re-exports, and `companion.ts` wraps `InstanceBase` in `ModuleBase`, which also adds a v1-style `defineVariables(array)` helper. The API 2.1 TypeScript template defines `export default class ModuleInstance extends InstanceBase<ModuleSchema>` directly in `src/main.ts`. The verifier confirmed the difference but could not decide whether it counts as a template-layout difference: the module format (an ES module with a default-exported `ModuleInstance`) matches the template, and actions, feedbacks, variables, config, presets and upgrades are all still separate files.

**Evidence:**

```ts
// src/main.ts:1-6 (v2.0.0-beta.6)
// Companion 5 (module API 2.x) loads the module from its default export.
import { ModuleInstance } from './instance.js'
import { UpgradeScripts } from './upgrades.js'

export default ModuleInstance
export { UpgradeScripts }
// src/companion.ts:34-36
export type ModuleTypes = InstanceTypes & { config: ModuleConfig; secrets: ModuleSecrets }

export abstract class ModuleBase extends InstanceBase<ModuleTypes> {
// src/instance.ts:33
export class ModuleInstance extends ModuleBase {
```

```ts
// companion-module-template-ts/src/main.ts:9-19
export type ModuleSchema = {
	config: ModuleConfig
	secrets: undefined
	actions: ActionsSchema
	feedbacks: FeedbacksSchema
	variables: VariablesSchema
}

export { UpgradeScripts }

export default class ModuleInstance extends InstanceBase<ModuleSchema> {
```

**Confirm by:** open [`src/main.ts:1-6`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/main.ts#L1-L6) (a 6-line re-export), [`src/instance.ts:33`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L33) and [`src/companion.ts:36`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/companion.ts#L36), then decide whether "main.ts re-exports a class defined in another file, which extends an adapter base class" counts as a template-layout difference under the match-the-template rule (High) or is a code-organisation choice (Low). The module format and default-export shape already match the template.

**Fix:** move the class back into `src/main.ts` as `export default class ModuleInstance extends InstanceBase<ModuleSchema>`, with a `ModuleSchema` of config, secrets, actions, feedbacks and variables and `export { UpgradeScripts }`, as in the template. Import Companion's types from `@companion-module/base` in each file, and call `setVariableDefinitions({...})` in the object form instead of the `defineVariables` array helper. If code has to be shared with the Companion 4 line, keep the shared logic in plain helper modules that the template-shaped class calls, rather than making the class and its base type the shared part.

### L2: HELP and README say Companion 5.1 or later, but Companion 5.0 can install this release

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:5`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/companion/HELP.md#L5), [`README.md:17`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/README.md#L17), [`src/companion.ts:2`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/companion.ts#L2)

**What goes wrong:** A user on Companion 5.0 is offered and can install 2.0.0-beta.6, because Companion picks the newest version whose API it supports and API 2.1 needs only Companion 5.0. The help page tells them they need 5.1. Either the text is wrong, or, if something really needs 5.1, those 5.0 users get a module that misbehaves with no warning.

**Why it happens:** `@companion-module/base` resolves to 2.1.3 (API 2.1, Companion 5.0 and later), while the HELP, the README's release-lines table and the `companion.ts` header comment all say 5.1.

**Fix:** if the module depends on Companion 5.1 behaviour, move to `@companion-module/base` `~2.2.x` (API 2.2, Companion 5.1 and later) so Companion 5.0 never installs it. Otherwise change HELP.md, README.md and the `companion.ts` comment to "Companion 5.0 or later".

### L3: An RCP with a different integration API version leaves the connection on Connecting with no explanation

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:192-196`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/api.ts#L192-L196), [`src/api.ts:264-268`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/api.ts#L264-L268)

**What goes wrong:** A user connects this beta to an RCP whose state messages carry a different `apiVersion` than `1.0-preview`. The connection status stays on Connecting, no camera, user or router ever appears, and nothing in the log says why unless Debug Messages is ticked. Every rejected message also makes the module send a resync request.

**Why it happens:** The state reducer returns "nothing" for any message whose API version is not exactly `1.0-preview`, whose `replace` is missing, or whose revision is out of step. The message handler treats all of those the same way, as an out-of-step revision: it logs only through the optional debug callback and asks for a resync. A version mismatch never reaches the connection status.

**Fix:** check the API version separately, before reducing the message. On a mismatch, set the error text to something like "RCP integration API 1.0 is not supported by this module (needs 1.0-preview)" and close the socket, so the status shows Connection Failure with that text. Keep the resync request for a real revision gap.

### L4: Each live video frame redraws every Live video image tile, not only the tiles showing that source

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:45-49`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L45-L49)

**What goes wrong:** Take a page with 8 "Live video · 16:9" tiles on 8 sources at the default 10 fps. Each frame from any one source makes Companion re-run all 8 Live video image feedbacks, and each returns its own JPEG. That is about 640 feedback runs and JPEG transfers per second where 80 are needed. The cost grows with the square of the tile count, so CPU load climbs fast as tiles are added and buttons can lag on busy systems.

**Why it happens:** The image feeds get one shared "changed" callback that re-checks every `live_image` feedback, and it is called on every received frame, every stale frame and every expiry ([`src/api.ts:412-423`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/api.ts#L412-L423)). Each feed already knows which feedback instances use it (`feed.refs`).

**Fix:** pass the affected feed's feedback ids to the callback and re-check only those, with `checkFeedbacksById(...refs)` (available in `@companion-module/base` 2.1.3), so a frame refreshes only the tiles that show that source.

### L5: Every RCP state message re-runs all feedbacks on every button

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/instance.ts:318-382`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L318-L382)

**What goes wrong:** Every state update from the RCP, even a single value change or a tracing progress tick, makes Companion re-evaluate every feedback on every button of the connection: tally, routing, value gauges, deck slots and live images. "User Preview Border Indicator" also rebuilds its image on each run. On a large show while values change continuously (tracing playback, an operator turning a knob on the RCP), this is a steady CPU load the 1.0 module did not have.

**Why it happens:** The state handler runs for each message, serialises every camera's full control definitions to build a topology fingerprint, then calls `checkAllFeedbacks()` with no debounce (line 382). v1.0.3 re-checked only the affected feedback types through the 30 ms debounced `scheduleFeedbackCheck`; that helper is still in the file ([`src/instance.ts:205-218`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L205-L218)) but nothing calls it now.

**Fix:** put the existing debounce, or one trailing debounce, around the feedback re-check, so a burst of state messages produces one feedback pass. If possible, build the topology fingerprint only when cameras, users, routing or controller switchers are among the update's `replace` keys.

### L6: The selected border on live camera tiles may not show, because two elements share one id

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets/design.ts:597-639`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/presets/design.ts#L597-L639)

**What goes wrong:** In the "Stream Deck +: (user name)" Cameras row (live image tiles), the selected camera is meant to get a 7 px accent border. The border style override targets the element id `frame`, but both the image element and the border box carry that id. If Companion applies the override to the image, the border never appears. The shade and label colour changes still show the selection.

**Why it happens:** The live tile builder names both the image element and the border box `frame`.

**Fix:** give the border box its own id, for example `border`, and point the selected `borderColor` and `borderWidth` overrides at `border`.

### L7: Five advanced feedbacks declare button properties they never set

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:138`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/feedbacks.ts#L138), [`src/feedbacks.ts:255`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/feedbacks.ts#L255), [`src/feedbacks.ts:324`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/feedbacks.ts#L324), [`src/feedbacks.ts:890`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/feedbacks.ts#L890), [`src/feedbacks.ts:1092`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/feedbacks.ts#L1092)

**What goes wrong:** No visible problem. "Camera Tally: Dynamic Color", "Camera Status (Tally + Users)", "Router: Output Tally Color" and "User Routing: Output Tally Color" only set the background and text colours, yet they also declare the image. "User Preview Border Indicator" only returns an image, yet it declares the colours. Companion may re-render more than it needs to.

**Why it happens:** Every advanced feedback got the same `affectedProperties: ['bgcolor', 'color', 'imageBuffer']` in this release, instead of the list each one really returns.

**Fix:** use `['bgcolor', 'color']` for the four colour-only feedbacks and `['imageBuffer']` for "User Preview Border Indicator". Longer term, API 2.1 recommends boolean feedbacks (or layered presets) over colour-only advanced feedbacks.

## 💡 Nice to Have

### N1: Errors in the module's own state handling are reported as an unreadable RCP message and drop the connection

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:260-277`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/api.ts#L260-L277)

**What goes wrong:** If building variables, choices or the topology fingerprint ever throws for some RCP state, the user sees Connection Failure "Unreadable state message: Cannot read properties of undefined …", with the connection dropping and reconnecting every 5 seconds. The message points at the RCP when the fault is in the module, which makes support harder. Nothing is visible unless such an error happens.

**Why it happens:** The `try` block around the JSON parse and state reducer also wraps the call into the module's state handler (variable definitions, choices, feedback checks). Any error there is caught as a parse error and the socket is closed.

**Fix:** keep the `try`/`catch` around the text decode, JSON parse and reducer only. Call the state handler in its own `try`/`catch` that logs the error (for example `State handling failed: …`) without closing the socket, or label it clearly as a module error.

### N2: Old Socket.IO types are force-cast onto the new API state, and some helpers are now dead code

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:368-373`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L368-L373)

**What goes wrong:** No visible effect today; this is code quality. The new API's cameras, users and routing are cast to the 1.0 Socket.IO types. If the RCP's shape differs (for example routing outputs without `routedInput.number`, or users without `previewedCameraUuid`), the compiler can't flag it, and feedbacks such as "Router: Route Active" or "User Previewing Camera" would quietly stay off.

**Why it happens:** Cameras are cast with `as unknown as WebsocketCamerasOutput[]`, and users and routing with plain `as` casts, while api.ts types users and routing as `unknown[]`. Also, `this.modules` is never assigned in version 2, so the module choices ([`src/instance.ts:431-437`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/instance.ts#L431-L437)) and the router name fallback ([`src/presets/index.ts:402-406`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/src/presets/index.ts#L402-L406)) always read an empty list, and `scheduleFeedbackCheck` is never called.

**Fix:** declare the users and routing shapes the integration API actually sends in api.ts and map them explicitly, rather than casting to the Socket.IO types. Remove the `modules` field and the unused `scheduleFeedbackCheck`, or wire them up.

## 🔮 Next Release

### NR1: Match the API 2.1 TypeScript template's build scripts and lint-staged version

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:9-14`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/package.json#L9-L14), [`package.json:39`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/package.json#L39)

**What goes wrong:** Nobody using the module in Companion sees a difference. The cost falls on maintainers and reviewers. The `package`, `build` and `lint` scripts call their sub-steps as `yarn …` where the template uses Yarn's built-in `run …`, and lint-staged is a whole major version behind the template (16 instead of 17). When someone troubleshoots a build or pre-commit problem, it is no longer obvious whether the cause is the module or a difference from the template.

**Why it happens:** This release moved the module from the API 1.x template to the API 2.1 TypeScript template and reworked package.json for it: engines, base `~2.1.3`, tools `^3`, Node 26 and a new `test` script. It did not take the template's script commands or its lint-staged major version. The `yarn …` form was already there at v1.0.3, but template checks apply to the whole module under every scope, and package.json was rewritten for the new template in this release. The lint-staged gap is new: `^16` matched the v1 template, and the 2.1 template uses `^17`.

**Evidence:**

```json
// package.json:9-14 (module, v2.0.0-beta.6)
		"package": "yarn build && companion-module-build",
		"build": "rimraf dist && yarn build:main",
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
		"lint:raw": "eslint",
		"lint": "yarn lint:raw .",
// package.json:28, 39
		"@companion-module/base": "~2.1.3",
		"lint-staged": "^16.2.6",
```

```json
// companion-module-template-ts/package.json:9-14 (e0d42b7)
		"package": "run build && companion-module-build",
		"build": "rimraf dist && run build:main",
		"build:main": "tsc -p tsconfig.build.json",
		"dev": "tsc -p tsconfig.build.json --watch",
		"lint:raw": "eslint",
		"lint": "run lint:raw ."
// companion-module-template-ts/package.json:33
		"lint-staged": "^17.6.0",
```

```diff
// git diff v1.0.3..v2.0.0-beta.6 -- package.json (excerpt)
-		"@companion-module/base": "~1.12.1",
+		"@companion-module/base": "~2.1.3",
-		"lint": "yarn lint:raw ."
+		"lint": "yarn lint:raw .",
+		"test": "yarn build:main && node --test test-api.mjs test-presets.mjs",
```

**Confirm by:** open [`package.json:9-14`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/package.json#L9-L14) and [`package.json:39`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/a65c1513e24b349db43313a9fab862e19bce1ce2/package.json#L39) next to `companion-module-templates/companion-module-template-ts/package.json` lines 9-14 and 33. The module uses `yarn build`, `yarn build:main` and `yarn lint:raw` where the template uses `run …`, and it pins lint-staged `^16.2.6` where the template pins `^17.6.0`.

**Fix:** copy the template's script commands and lint-staged range, then commit the updated yarn.lock. The extra `test` and `design:gallery` scripts can stay (you may also want `run build:main` inside `test`).

```json
"package": "run build && companion-module-build",
"build": "rimraf dist && run build:main",
"lint": "run lint:raw .",
"lint-staged": "^17.6.0",
```

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: it adds `"module": "NodeNext"` and `"moduleResolution": "NodeNext"` to `compilerOptions` and drops the template's `"verbatimModuleSyntax": true` (the `node26` preset in `extends` matches). Fine as long as the module builds and lints, which it does — no change required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not merge or skip repeated `checkFeedbacks` / `checkAllFeedbacks` calls, so each call re-runs every matching feedback callback and sends its value to Companion | base 2.1.3 passes both calls straight to the host; any batching would happen in Companion itself, which was not checked | [L4](#l4-each-live-video-frame-redraws-every-live-video-image-tile-not-only-the-tiles-showing-that-source), [L5](#l5-every-rcp-state-message-re-runs-all-feedbacks-on-every-button) |
| A2 | Companion calls the feedback unsubscribe callback when a layered preset's local-variable feedback is removed or disabled, so each live image subscription is freed and the feed's list of feedback ids stays accurate | standard Companion 5 feedback lifecycle; not verifiable from the module or base package alone | [L4](#l4-each-live-video-frame-redraws-every-live-video-image-tile-not-only-the-tiles-showing-that-source) |
| A3 | Companion 5.0 accepts a module built on `@companion-module/base` 2.1.x and offers this release to Companion 5.0 users | API 2.1 = Companion 5.0+ in the v2.1 reference and the README's "Companion installs the newest version it can run"; not checked against a Companion 5.0 install | [L2](#l2-help-and-readme-say-companion-51-or-later-but-companion-50-can-install-this-release) |
| A4 | When two elements in a layered preset share an id, Companion applies a style override to only one of them (or handles them unpredictably), rather than to both | base 2.1.3 typings don't enforce unique element ids; Companion's handling of duplicate ids was not checked | [L6](#l6-the-selected-border-on-live-camera-tiles-may-not-show-because-two-elements-share-one-id) |
