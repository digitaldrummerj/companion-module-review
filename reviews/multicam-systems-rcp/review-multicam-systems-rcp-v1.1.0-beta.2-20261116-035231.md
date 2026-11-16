# Module Review: companion-module-multicam-systems-rcp v1.1.0-beta.2

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-multicam-systems-rcp`](https://github.com/bitfocus/companion-module-multicam-systems-rcp) |
| **Scope** | `tag` (changes from v1.0.3 to v1.1.0-beta.2) |
| **Version** | v1.1.0-beta.2 (commit `45903de7e1014c1ac60ae54c995693a3297257a7`) |
| **Release** | Update — last published v1.0.3 |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-16 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: User preview feedbacks and variables made with 1.0 no longer follow User: Select Camera](#m1-user-preview-feedbacks-and-variables-made-with-10-no-longer-follow-user-select-camera)
- [ ] [L1: The instance class and presets no longer sit where the API 1.x TypeScript template puts them](#l1-the-instance-class-and-presets-no-longer-sit-where-the-api-1x-typescript-template-puts-them)
- [ ] [L2: Float Adjust Property (Relative) sets the control to the step size until the camera reports it](#l2-float-adjust-property-relative-sets-the-control-to-the-step-size-until-the-camera-reports-it)
- [ ] [L3: An RCP with a different integration API version leaves the connection at Connecting with no error](#l3-an-rcp-with-a-different-integration-api-version-leaves-the-connection-at-connecting-with-no-error)
- [ ] [L4: Connection settings show the token and HTTPS fields above the Information text](#l4-connection-settings-show-the-token-and-https-fields-above-the-information-text)
- [ ] [L5: Deck Bank is active feedback changes nothing on a button until the user picks a style](#l5-deck-bank-is-active-feedback-changes-nothing-on-a-button-until-the-user-picks-a-style)
- [ ] [L6: A second Live video image feedback appears on Companion 4 and draws no picture](#l6-a-second-live-video-image-feedback-appears-on-companion-4-and-draws-no-picture)
- [ ] [L7: Every RCP state message re-checks every feedback on every button](#l7-every-rcp-state-message-re-checks-every-feedback-on-every-button)
- [ ] [L8: Each live video frame re-draws every live video button, not only those showing that source](#l8-each-live-video-frame-re-draws-every-live-video-button-not-only-those-showing-that-source)
- [ ] [N1: Leftover 1.0 module list and camera type cast from the old Socket.IO connection](#n1-leftover-10-module-list-and-camera-type-cast-from-the-old-socketio-connection)
- [ ] [N2: Unused tsx devDependency added in this release](#n2-unused-tsx-devdependency-added-in-this-release)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: User preview feedbacks and variables made with 1.0 no longer follow User: Select Camera

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/instance.ts:710-758`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L710-L758), [`src/feedbacks.ts:222`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L222), [`src/feedbacks.ts:247`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L247), [`src/feedbacks.ts:295`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L295), [`src/feedbacks.ts:357`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L357), [`src/variables.ts:210-216`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/variables.ts#L210-L216)

**What goes wrong:** A user upgrading from 1.0.3 has a button with the action **User: Select Camera** (User = Ann, Camera = CAM 2) and the feedback **User Previewing Camera** (Ann, CAM 2) to light it up. In 1.1.0-beta.2 the press puts CAM 2 on Ann's controller switcher, and the module's deck page then controls CAM 2. But the button's highlight still reads Ann's old preview camera, so it can stay dark, or light the button of a different camera. The same goes for **Any User Previewing Camera**, **User Preview Border Indicator**, **Camera Status (Tally + Users)**, the `user_1_preview_camera` variable, and the **Info** preset in each user's category, which can keep showing "None". [`companion/HELP.md:57`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/companion/HELP.md#L57) promises that "Buttons made with 1.0 keep their actions and feedbacks".

**Why it happens:** In 1.0.3 the action and these feedbacks used the same field: the action set the user's preview camera, and the feedbacks read it. This release changed the action to select a choice on the user's controller switcher instead. The module has its own function for "the camera a user is on right now" (`userSelectedCameraUuid()`), which reads the switcher first and only falls back to the old preview field, and the deck page uses it. The four 1.0 feedbacks and the user variables still compare only the old preview field (`user.previewedCameraUuid`).

**Evidence:**

```ts
// src/instance.ts:736-741 (selectUserCamera: the 1.0 action now selects a switcher choice)
this.command({
	type: 'controllerSelect',
	switcherId: switcher.id,
	choiceId: choice.id,
	expectedGeneration: generation,
})
// src/instance.ts:743-744 (the module's own definition: switcher first, preview as fallback)
/** The real camera a user is on right now: the switcher's effective choice, else the preview. */
userSelectedCameraUuid(userUuid: string): string | undefined {
// src/feedbacks.ts:222 (User Previewing Camera)
return user?.previewedCameraUuid === cameraUuid
// src/variables.ts:210
if (self.connected && user.previewedCameraUuid) {
```

**Fix:** make the feedbacks and variables use the same "current camera" as the action and the deck page. Replace `user.previewedCameraUuid` with `self.userSelectedCameraUuid(user.uuid)` in [`src/feedbacks.ts:222`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L222), [`:247`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L247), [`:295`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L295), [`:357`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/feedbacks.ts#L357) and in [`src/variables.ts:210-216`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/variables.ts#L210-L216).

```ts
// User Previewing Camera
return self.userSelectedCameraUuid(userUuid) === cameraUuid
// Any User Previewing Camera / Camera Status
self.users.some((u) => self.userSelectedCameraUuid(u.uuid) === cameraUuid)
```

## 🟢 Low

### L1: The instance class and presets no longer sit where the API 1.x TypeScript template puts them

- **Source:** 🔎 compliance reviewer — ⚠️ needs your check
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:1-6`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/main.ts#L1-L6), [`src/instance.ts:33`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L33), [`src/companion.ts:67-73`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/companion.ts#L67-L73)

**What goes wrong:** Companion users see nothing different. Maintainers and reviewers do. Someone who opens `src/main.ts` to troubleshoot a connection (start-up, shutdown, settings changes) finds a 6-line file. The connection's lifecycle has moved to `src/instance.ts` (939 lines), whose class extends an adapter class in `src/companion.ts` that rewrites every action and feedback definition before Companion receives it. Presets moved from `src/presets.ts` to `src/presets/index.ts`. In v1.0.3 the module matched the template: the class sat in `src/main.ts` next to `runEntrypoint`, and presets were in `src/presets.ts`. When a feature misbehaves later, a layout that differs from the template sends people looking in the wrong place.

**Why it happens:** This release splits the code into a core shared with the Companion 5 (API 2.x) line, synced by `tools/sync-core.sh`. Only `main.ts`, `companion.ts` and `presets/` are specific to this line. To make that work, the instance class moved to `src/instance.ts` and now extends an abstract `ModuleBase` instead of `InstanceBase` directly. The template keeps `export class ModuleInstance extends InstanceBase<ModuleConfig>` and `runEntrypoint(ModuleInstance, UpgradeScripts)` together in `src/main.ts`, with presets in `src/presets.ts`.

The module still matches the template in the ways the review rules name as High: it is an ES module that calls `runEntrypoint(ModuleInstance, UpgradeScripts)` in `main.ts`, and upgrades, actions, feedbacks, variables, config and presets all stay in separate files. Whether moving the class out of `main.ts` counts as the same kind of difference is the open question in [A1](#-assumptions-to-confirm).

**Evidence:**

```ts
// src/main.ts:1-6
// Companion 4 (module API 1.x) starts the module through runEntrypoint.
import { runEntrypoint } from '@companion-module/base'
import { ModuleInstance } from './instance.js'
import { UpgradeScripts } from './upgrades.js'

runEntrypoint(ModuleInstance, UpgradeScripts)
// src/instance.ts:7 and :33
import { UpdatePresets } from './presets/index.js'
export class ModuleInstance extends ModuleBase {
// src/companion.ts:67-73
export abstract class ModuleBase extends InstanceBase<ModuleConfig, ModuleSecrets> {
	override setActionDefinitions(actions: CompanionActionDefinitions): void {
		super.setActionDefinitions(withoutApi2Fields(actions))
	}
	override setFeedbackDefinitions(feedbacks: CompanionFeedbackDefinitions): void {
		super.setFeedbackDefinitions(withoutApi2Fields(feedbacks))
	}
```

```text
git ls-tree --name-only v1.0.3 src/
src/actions.ts src/config.ts src/feedbacks.ts src/main.ts src/presets.ts src/types.ts src/upgrades.ts src/variables.ts
v1.1.0-beta.2: src/presets.ts deleted (-1240); src/presets/index.ts (+542), src/instance.ts (+939), src/companion.ts (+82) added
```

**Confirm by:** open [`src/main.ts:1-6`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/main.ts#L1-L6) and [`src/instance.ts:33`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L33) next to `companion-module-templates/companion-module-template-ts-v1/src/main.ts:9-57`, then decide whether moving the class out of `main.ts` and presets into `presets/index.ts` is a High template-layout difference (`validate-template.ps1` treats `src/*` as module-owned and allows a different entry filename).

**Fix:** put the instance class (`export class ModuleInstance extends InstanceBase<ModuleConfig, ModuleSecrets>` with `init`, `destroy`, `configUpdated`, `getConfigFields` and the `update*` calls) back in `src/main.ts` with `runEntrypoint(ModuleInstance, UpgradeScripts)` at the bottom, and move presets back to `src/presets.ts`, as in `companion-module-template-ts-v1`. To keep sharing code with the 2.x line, keep the shared logic in helper files that the class in `main.ts` calls, the way the template calls `UpdateActions` and `UpdateFeedbacks`. `main.ts` is already specific to each line, so it can hold that line's own class.

### L2: Float Adjust Property (Relative) sets the control to the step size until the camera reports it

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:198-211`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/actions.ts#L198-L211), [`src/instance.ts:375-378`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L375-L378)

**What goes wrong:** Right after connecting, or for a control the camera has not read back yet (HELP: "A control the camera reports shows a dash until it has reported"), a button with **Float: Adjust Property (Relative)** (Property = iris, Adjustment = +0.01) sends iris = 0.01 instead of "current iris + 0.01". The camera's iris jumps almost closed.

**Why it happens:** The module now caches each control's value through `knownValue()`, which deliberately returns nothing (`null`) for a control the camera reports but has not reported yet ([`src/api.ts:37-39`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/api.ts#L37-L39)). The relative-adjust action treats any value that is not a number as "start from zero": it falls through to its last branch and sends the adjustment amount as an absolute value.

**Evidence:**

```ts
// src/actions.ts:202-209
let newValue: number
if (typeof currentValue === 'number') {
	newValue = currentValue + adjustment
} else if (typeof currentValue === 'object' && currentValue && 'value' in currentValue) {
	newValue = (currentValue.value as number) + adjustment
} else {
	newValue = adjustment
}
```

**Fix:** refuse the press while the value is unknown. When `numberOf(currentValue)` is `null`, log a warning such as `<camera> <property>: value not known yet` and return. Or send a relative step to RCP (`controlAdjust`), as **Float: Increase** and **Float: Decrease** already do.

### L3: An RCP with a different integration API version leaves the connection at Connecting with no error

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:192-197`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/api.ts#L192-L197), [`src/api.ts:264-269`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/api.ts#L264-L269)

**What goes wrong:** A user connects to an RCP whose integration API reports a version other than `1.0-preview` (for example a later RCP build that moves to `1.0`). The WebSocket opens, but every state message is dropped, so the connection status stays at **Connecting** with no explanation. Nothing is logged unless **Debug Messages** is ticked, and then only "Out of step at revision 0; asking for a resync", which does not point at the version. Users of an RCP on `1.0-preview` are not affected.

**Why it happens:** The state reader (`reduceState()`) returns the same "nothing" result for a wrong API version as for an out-of-order update. The message handler treats every such result as "out of step": it asks RCP for a resync and returns, without recording an error or changing the status. Each dropped message sends another resync request.

**Evidence:**

```ts
// src/api.ts:194
if (m.apiVersion !== '1.0-preview' || !m.replace || !Number.isSafeInteger(m.revision)) return null
// src/api.ts:265-269
if (!next) {
	this.debug?.(`Out of step at revision ${this.revision}; asking for a resync`)
	this.socket?.send(JSON.stringify({ type: 'resync' }))
	return
}
```

**Fix:** report an unsupported version separately from a revision gap. When the message has an `apiVersion` that is not `1.0-preview`, set `lastError` to something like `RCP integration API ${m.apiVersion} is not supported by this module version` and close the socket, so the existing close handler shows it as a connection failure. Optionally allow only one resync request in flight, cleared when a snapshot is accepted.

### L4: Connection settings show the token and HTTPS fields above the Information text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/config.ts:70-104`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/config.ts#L70-L104)

**What goes wrong:** A user opens the connection's settings with Connection = Local RCP. The fields appear in this order: Connection, **Integration API token**, **Use HTTPS / WSS**, then the **Information** text ("Configure the connection to your Multicam RCP server below."), then **Multicam RCP on this network**, **Target IP** and **Port**. The intro text now sits in the middle of the form, and **Use HTTPS / WSS** comes before the server picker it depends on (it hides as soon as a discovered server is picked). In v1.0.3 the Information text came first.

**Why it happens:** The new token and TLS fields were added to the settings list before the existing Information entry, and above the discovered-server picker instead of beside Target IP and Port.

**Fix:** put the Information text first, then order the fields so each comes after the one it depends on: Connection, the cloud fields, **Multicam RCP on this network**, **Target IP**, **Port**, **Use HTTPS / WSS**, **Integration API token**, **Auto Reconnect**, **Debug Messages**.

### L5: Deck Bank is active feedback changes nothing on a button until the user picks a style

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/deck.ts:162-169`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/deck.ts#L162-L169)

**What goes wrong:** A user adds the feedback **Deck: Bank is active** (User = Operator 1, Bank = Gain) to a button and switches banks. The button looks the same whether the bank is active or not, because the feedback comes with no style. Every other on/off feedback in the module comes with a colour (for example **Tracing: Camera State** turns amber).

**Why it happens:** The feedback's default style is empty (`defaultStyle: {}`). For an on/off (boolean) feedback, Companion applies only the style properties the feedback provides, so nothing changes until the user adds a colour by hand.

**Fix:** give it a default style like the module's other selection feedbacks.

```ts
defaultStyle: { bgcolor: combineRgb(0, 100, 180), color: combineRgb(255, 255, 255) },
```

### L6: A second Live video image feedback appears on Companion 4 and draws no picture

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/graphics.ts:96-122`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/graphics.ts#L96-L122)

**What goes wrong:** On Companion 4.1 a user looking for live video finds two feedbacks: **Live video image** and **Live video image on the button**. The README and HELP point to the second one for classic buttons. If the user picks the first one (Video source = Cam 1 SDI), no picture is drawn: they get the frame as a long base64 JPEG text value, and the module still opens a live JPEG stream to RCP for it. This rests on [A2](#-assumptions-to-confirm).

**Why it happens:** `src/graphics.ts` is part of the core shared with the Companion 5 line, and its comment says these value feedbacks are "read as local variables by the layered tiles", which exist only on Companion 5. This line adds its own **Live video image on the button** feedback for classic buttons, but still registers all the shared graphics feedbacks, **Live video image** included.

**Fix:** don't register the shared **Live video image** feedback on this line, for example by filtering it out in `UpdateFeedbacks` or in `ModuleBase.setFeedbackDefinitions`, the way the API 2 fields are already stripped. Or rename it so it is clearly a data value, not a picture, e.g. "Live video frame (data URI, for layered buttons)".

### L7: Every RCP state message re-checks every feedback on every button

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:374-382`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L374-L382), [`src/instance.ts:205-218`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L205-L218)

**What goes wrong:** Nothing works incorrectly, but busy shows pay for it in CPU. With several pages of tally, user-preview-border, live image and property feedbacks, every state update from RCP (a tracing progress tick, or a value readback while an operator turns an encoder) makes Companion re-evaluate every feedback of this connection. **User Preview Border Indicator** builds a new border image each time, and **Live video image on the button** copies its JPEG string each time.

**Why it happens:** The new state handler re-checks all feedbacks for every message, with no debounce. The 1.0 code batched these checks through a 30 ms debounce with specific feedback ids (`scheduleFeedbackCheck()`). That helper is still in the file, but nothing calls it any more.

**Fix:** throttle the check in the state handler. Reuse `scheduleFeedbackCheck` with a maximum wait so a steady stream still refreshes, passing the camera, user and route feedback ids, or call `checkAllFeedbacks()` from a single trailing timer. Delete `scheduleFeedbackCheck` and `pendingFeedbacks` if they stay unused.

### L8: Each live video frame re-draws every live video button, not only those showing that source

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:45-49`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L45-L49)

**What goes wrong:** A user places the **Live video** presets for 8 sources (160x90, 10 fps). Each frame from any one source makes the module re-run all 8 live video feedbacks and send all 8 JPEG images back to Companion. That is about 8 sources x 10 fps x 8 buttons = 640 evaluations and JPEG payloads per second instead of 80. The CPU and inter-process load grows with the square of the number of live video buttons.

**Why it happens:** The live image feed manager is told to re-check the two live video feedback types by name after every frame, every stale-image clear and every socket close ([`src/api.ts:362-365`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/api.ts#L362-L365), [`src/api.ts:421-423`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/api.ts#L421-L423), [`src/api.ts:429-435`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/api.ts#L429-L435)). Checking by type re-runs every instance of that type, although each feed already knows exactly which feedback instances use it (`feed.refs`).

**Fix:** pass the affected feedback instance ids to the callback and check only those. Change it to `changed: (ids: Iterable<string>) => void`, call `this.changed(feed.refs)` in `ImageFeeds`, and wire it to `(ids) => this.checkFeedbacksById(...ids)` (available in `@companion-module/base` 1.13). Keep the full check only for a disconnect.

## 💡 Nice to Have

### N1: Leftover 1.0 module list and camera type cast from the old Socket.IO connection

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:57`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L57), [`src/instance.ts:368-371`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L368-L371), [`src/instance.ts:432-437`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/instance.ts#L432-L437)

**What goes wrong:** No visible effect today; this is code quality only. The router dropdowns now list only the routing buses from the API, because the module list they also filter is never filled. The new API camera objects are passed off as the old camera type, so the compiler would not catch a future read of a field the new API does not send (`cameraControlProperties`, `assignedModules`, `model_descriptor` and others).

**Why it happens:** The rewrite removed the Socket.IO handler that filled `modules`, but kept the empty list, its `standaloneComponent` filter in `updateModuleChoices()` and the lookup in [`src/presets/index.ts:388`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/presets/index.ts#L388). The state handler builds `this.cameras` with `as unknown as WebsocketCamerasOutput[]`.

**Fix:** remove `modules`, its filter in `updateModuleChoices()` and the `busName` fallback in `presets/index.ts`. Type `cameras` as the API camera plus the one added field (or a narrow interface of the fields actually read), so the `as unknown as` cast goes away.

### N2: Unused tsx devDependency added in this release

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:39`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/package.json#L39)

**What goes wrong:** Users see nothing. Every clean install downloads and audits one extra dev package that no script, test or source file uses. It came from the Companion 5 line's design-gallery tooling, which the commit history says is not on this line.

**Why it happens:** `tsx` only appears in `package.json`: the devDependency entry and the `*.{ts,tsx,js,jsx}` lint-staged glob. No script runs it.

**Fix:** remove `"tsx": "^4.23.13"` from `devDependencies` and commit the updated `yarn.lock`.

## 📝 Additional Notes

- `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json` instead of the template's `node22/recommended`, and sets `module`/`moduleResolution` to `NodeNext` and `rootDir: ./src` where the template uses `Node16` with `baseUrl`/`paths`. The module builds and lints, so no change is required.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The 2026-11-07 "match the template layout" rule (High) covers a different module format and template-separate files folded into `main`, but not code moved out of `main.ts` into extra files (class in `instance.ts` behind an adapter base class, presets in `presets/index.ts`). If it covers every `src` layout difference, L1 is High and blocking | `companion-compliance-reviewer.md:36` lists only the folding case; `validate-template.ps1:270-272, 852` treat `src/*` as module-owned and allow a different entry filename; not confirmed by the user | [L1](#l1-the-instance-class-and-presets-no-longer-sit-where-the-api-1x-typescript-template-puts-them) |
| A2 | On Companion 4.1 (module API 1.13) a user can pick a value feedback such as **Live video image** (for example as a button local variable), and gets the raw returned value (a `data:image/jpeg;base64` string), not a drawn picture | API 1.13 changelog adds value feedbacks as a general type; the module's own comment ([`src/graphics.ts:5`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/45903de7e1014c1ac60ae54c995693a3297257a7/src/graphics.ts#L5)) says they are for Companion 5's layered tiles; Companion 4.1's UI not checked live | [L6](#l6-a-second-live-video-image-feedback-appears-on-companion-4-and-draws-no-picture) |
