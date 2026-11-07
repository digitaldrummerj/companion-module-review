# Review: companion-module-cuetime-stagedisplay v0.1.2 (follow-up)

| | |
| --- | --- |
| **Module** | [companion-module-cuetime-stagedisplay](https://github.com/bitfocus/companion-module-cuetime-stagedisplay) |
| **Scope** | `tag` |
| **Version** | `v0.1.2` (commit [`8e9e6d8`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/tree/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238)) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11, main) |
| **Previous tag** | none. This is a first release (never published), so there is no published diff and the whole module was reviewed |
| **Prior review** | [v0.1.0, 2026-10-30](review-cuetime-stagedisplay-v0.1.0-20261030-192328.md). This follow-up also checks the maintainer's fixes in `v0.1.0..v0.1.2` (26 files, +927/-1214); see [📝 Additional Notes](#-additional-notes) |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` all pass |
| **Date** | 2026-11-06 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Every Companion 5.x release builds the mDNS service name the way 5.1.1 does: it puts an underscore in front of the manifest's `type` and `protocol` (`"_" + type + "._" + protocol + ".local"`), so a `type` that already starts with `_` gives a double underscore | Read and ran the bundled `@julusian/bonjour-service` code in the installed Companion 5.1.1 (`main.js`, build 5.1.1+10000-stable-1e2454ae78). The `@companion-module/base` 2.1.3 manifest schema doesn't say whether `type` includes the underscore. Other Companion versions were not checked | [M1](#m1-the-discovered-cuetime-displays-list-is-always-empty-so-a-display-can-only-be-added-by-ip-address) |
| A2 | Companion stores a fractional value typed into a `number` option that has no `step` (for example 2.5 in "Flash start (seconds, optional)") and passes it to the action unchanged, instead of rounding or blocking it | The base 2.1.3 `CompanionInputFieldNumber` typing (`input.d.ts:298+`) says values may not respect min/max and must be checked in code; it doesn't say whether non-integer values are blocked. Not checked in a running Companion | [L2](#l2-a-fractional-flash-start-or-flash-length-is-sent-anyway-and-the-display-rejects-the-whole-session) |
| A3 | Companion applies an advanced feedback's returned `bgcolor` to the whole button, under the strip drawn from `imageBuffer` at `imageBufferPosition`, so it replaces the user's own background colour | The base 2.1.3 typings (`CompanionAdvancedFeedbackResult` adds `imageBuffer`/`imageBufferPosition` to the button style properties) and the documented advanced-feedback behaviour; not rendered in a running Companion | [L3](#l3-session-progress-bar-turns-the-whole-button-background-grey-not-just-the-strip) |
| A4 | Companion's Presets panel shows each simple preset group under its own name heading, and shows a section whose `definitions` is a plain list of preset ids without grouping | The doc comment on `CompanionPresetSection.definitions` in base 2.1.3 `preset/structure.d.ts`; the Companion 5 UI was not checked | [N2](#n2-in-the-presets-tab-every-button-sits-under-its-own-heading) |
| A5 | A layered preset `gauge` element whose `value` is an expression such as `$(cuetime:progress_bar)` is redrawn by Companion when the variable changes, so it can replace the advanced feedback's bitmap | The `ButtonGraphicsGaugeElement` typings in base 2.1.3 `graphics.d.ts` (`CompanionGraphicsElementValue<number>` accepts an expression); not built or run | [L5](#l5-session-progress-bar-uses-an-advanced-feedback-which-api-21-discourages) |

## 📋 Issues

### Non-blocking

- [ ] [M1: The Discovered CueTime Displays list is always empty, so a display can only be added by IP address](#m1-the-discovered-cuetime-displays-list-is-always-empty-so-a-display-can-only-be-added-by-ip-address)
- [ ] [L1: Add Session and Add Message failures log only an error code, not the display's reason](#l1-add-session-and-add-message-failures-log-only-an-error-code-not-the-displays-reason)
- [ ] [L2: A fractional Flash start or Flash length is sent anyway, and the display rejects the whole session](#l2-a-fractional-flash-start-or-flash-length-is-sent-anyway-and-the-display-rejects-the-whole-session)
- [ ] [L3: Session Progress Bar turns the whole button background grey, not just the strip](#l3-session-progress-bar-turns-the-whole-button-background-grey-not-just-the-strip)
- [ ] [L4: HELP.md describes preset colours that don't match the buttons, and opens with developer-only notes](#l4-helpmd-describes-preset-colours-that-dont-match-the-buttons-and-opens-with-developer-only-notes)
- [ ] [L5: Session Progress Bar uses an advanced feedback, which API 2.1 discourages](#l5-session-progress-bar-uses-an-advanced-feedback-which-api-21-discourages)
- [ ] [L6: yarn test fails in a fresh checkout until the icons are generated](#l6-yarn-test-fails-in-a-fresh-checkout-until-the-icons-are-generated)
- [ ] [L7: A variable renamed in only one file would go blank without a build error](#l7-a-variable-renamed-in-only-one-file-would-go-blank-without-a-build-error)
- [ ] [N1: Commands that were never sent are logged as rejected by CueTime](#n1-commands-that-were-never-sent-are-logged-as-rejected-by-cuetime)
- [ ] [N2: In the Presets tab, every button sits under its own heading](#n2-in-the-presets-tab-every-button-sits-under-its-own-heading)
- [ ] [N3: Message flash and Edge dropdowns can still be switched to expression mode](#n3-message-flash-and-edge-dropdowns-can-still-be-switched-to-expression-mode)
- [ ] [N4: Variables typed into Session ID, Duration and Offset fields are sent as literal text](#n4-variables-typed-into-session-id-duration-and-offset-fields-are-sent-as-literal-text)
- [ ] [N5: Is Playing, Is Glowing and Is Blackout variables are Yes/No text instead of true/false](#n5-is-playing-is-glowing-and-is-blackout-variables-are-yesno-text-instead-of-truefalse)
- [ ] [N6: Target Port (manual) is a text field instead of the template's number field](#n6-target-port-manual-is-a-text-field-instead-of-the-templates-number-field)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: The Discovered CueTime Displays list is always empty, so a display can only be added by IP address

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:27-32`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/companion/manifest.json#L27-L32)

**What goes wrong:** A user adds a CueTime Stage Display connection and opens its settings. HELP.md tells them to pick their display from "Discovered CueTime Displays", but the dropdown never lists anything, even with a CueTime display advertising itself on the same network. The only way to connect is to type the address into "Target IP (manual)". It also means the fix for the previous review's M6 (splitting a discovered `ip:port` value in [`src/logic.ts`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/logic.ts#L19-L54)) never gets a value to work on. Users who enter the IP manually are not affected.

**Why it happens:** Companion builds the mDNS service name to search for by putting an underscore in front of the manifest's `type` and `protocol` (see [A1](#-assumptions-to-confirm)). The manifest already includes the underscore (`"type": "_cuetime"`), so Companion searches for `__cuetime._tcp.local`. The display advertises `_cuetime._tcp`, as the module's own [`companion/HELP.md:22`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/companion/HELP.md#L22) and [`HTTP_JSON_CONTROL_PROTOCOL.md:2194`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/HTTP_JSON_CONTROL_PROTOCOL.md#L2194) say, so no reply ever matches. The manifest entry is unchanged since v0.1.0; the previous review missed it. Running the bundled Companion 5.1.1 code: type `_cuetime` gives `__cuetime._tcp.local`, and type `cuetime` gives `_cuetime._tcp.local`.

**Evidence:**

```json
// companion/manifest.json:27-32
	"bonjourQueries": {
		"cuetime-display": {
			"type": "_cuetime",
			"protocol": "tcp"
		}
	},
```

```markdown
// companion/HELP.md:22
CueTime Display devices advertise themselves on the local network via mDNS/DNS-SD under the service type `_cuetime._tcp`.
```

```js
// Companion 5.1.1 /Applications/Companion.app/Contents/Resources/main.js (bundled @julusian/bonjour-service)
var T3t=t=>"_"+t, ... Zpn=t=>{...n.push(T3t(s))...join(".")};QP.toString=Zpn
...this.name=(0,Dfn.toString)({name:r.type,protocol:r.protocol||"tcp"})+sqt
```

**Fix:** remove the leading underscore from the query type so Companion searches for `_cuetime._tcp.local`. Then check on a real display that it appears in "Discovered CueTime Displays" and that choosing it connects.

```json
"bonjourQueries": {
	"cuetime-display": {
		"type": "cuetime",
		"protocol": "tcp"
	}
}
```

## 🟢 Low

### L1: Add Session and Add Message failures log only an error code, not the display's reason

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:267-270`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L267-L270), [`src/actions.ts:483-486`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L483-L486)

**What goes wrong:** An operator presses a button running "Add Session" (for example "Keynote", countdown 300 s) or "Add Message", and nothing appears on the display. The connection log shows only `Add session failed: INVALID_PARAMETER` or `Add message failed: TRANSPORT_ERROR`. The explanation the display sent back (which field it refused), or `WebSocket not open` when the display is offline, is dropped, so the operator can't tell what to fix. "Update Session" does log the reason.

**Why it happens:** Both failure handlers build the warning from the error code alone and ignore the message that comes with it. The "Update Session" handler at [`src/actions.ts:451-454`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L451-L454) logs both.

**Fix:** log the message as well, the way "Update Session" does, and do the same for `Add message failed`.

```ts
self.log('warn', `Add session failed: ${result.code ?? 'error'}${result.message ? ` — ${result.message}` : ''}`)
```

### L2: A fractional Flash start or Flash length is sent anyway, and the display rejects the whole session

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/payloads.ts:205-209`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/payloads.ts#L205-L209), [`src/payloads.ts:577-581`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/payloads.ts#L577-L581)

**What goes wrong:** A user sets "Add Session" > "Flash start (seconds, optional)" to 2.5 (see [A2](#-assumptions-to-confirm)). The module refuses a fractional duration with a clear local warning ("the duration must be a whole number of seconds"), but it sends the flash values unchecked. The display then rejects the whole command, the session is not added, and the log shows only `Add session failed: INVALID_PARAMETER` (see [L1](#l1-add-session-and-add-message-failures-log-only-an-error-code-not-the-displays-reason)). The two flash fields of "Update Session" behave the same way.

**Why it happens:** The Add Session and Update Session payload builders only check that the flash start and flash length are finite numbers above 0; they don't apply the whole-number check used for the duration. The module's own protocol notes ([`HTTP_JSON_CONTROL_PROTOCOL.md:1404`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/HTTP_JSON_CONTROL_PROTOCOL.md#L1404)) list "a fractional or negative value in a whole-number field" as an `INVALID_PARAMETER` rejection, and the `add_session` table types both fields as `int`.

**Fix:** in both builders, reject a non-integer flash value with a `kind: 'invalid'` reason (for example "the flash start must be a whole number of seconds"), the same way the duration is checked, or round the value before sending it. Add a unit test next to the existing duration tests.

### L3: Session Progress Bar turns the whole button background grey, not just the strip

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:260-261`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/feedbacks.ts#L260-L261), [`src/feedbacks.ts:283-286`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/feedbacks.ts#L283-L286)

**What goes wrong:** A user adds the "Session Progress Bar" feedback to a button they styled themselves, for example the "Remaining Time" preset (black background) or a blue button of their own. The bar is drawn as a strip along the bottom edge, as HELP.md describes, but the whole button background also changes to the "Remaining track colour" (dark grey 45,45,45 by default), so their own background colour is lost (see [A3](#-assumptions-to-confirm)). With the default colours, the unfilled part of the strip then looks the same as the rest of the button, so no track is visible. The option label suggests the colour only applies to the unfilled part of the strip.

**Why it happens:** Both branches of the feedback return the track colour as the button background (`bgcolor: trackColor`), and the feedback declares `bgcolor` as one of the properties it changes. The image branch already paints the unfilled part of the strip in the track colour, so the extra background only overrides the rest of the button.

**Fix:** in the image branch, drop `bgcolor: trackColor` so only the strip is drawn, and remove `'bgcolor'` from `affectedProperties` if the text fallback no longer needs it. If the whole-button background is intended, rename the option (for example "Button background colour") and say so in HELP.md.

### L4: HELP.md describes preset colours that don't match the buttons, and opens with developer-only notes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:6-12`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/companion/HELP.md#L6-L12), [`companion/HELP.md:170`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/companion/HELP.md#L170), [`companion/HELP.md:179-181`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/companion/HELP.md#L179-L181), [`companion/HELP.md:201`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/companion/HELP.md#L201), [`companion/HELP.md:212`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/companion/HELP.md#L212)

**What goes wrong:** A user reading the help in Companion sees:

- Lines 6-12 point at Kotlin `@Serializable` data classes and a sibling `../../Android-Display-App/` repository, which means nothing to someone setting up a button.
- Line 201 says Toggle Flash shows an "Orange feedback when active", but the preset turns the button red ([`src/presets.ts:185`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/presets.ts#L185)).
- Lines 170 and 179-181 say the "Top bar turns green" while the timer runs, but the presets turn the whole button background green, and Toggle Playback also switches to the pause icon ([`src/presets.ts:78`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/presets.ts#L78), [`src/presets.ts:289`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/presets.ts#L289), [`src/presets.ts:314`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/presets.ts#L314), [`src/presets.ts:339`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/presets.ts#L339)).
- Line 212 refers to presets "using `icon_frame`", an internal name users can't see.

**Why it happens:** The preset tables in HELP.md weren't updated to the styles in `src/presets.ts`, and the opening paragraph is the schema provenance note that README.md also carries.

**Fix:** move the schema provenance paragraph (lines 6-12) to README.md, which already has it. Change line 201 to "Red when active" (or make the preset orange), and lines 170 and 179-181 to "Button turns green while the timer is running". Replace `icon_frame` with a plain description such as "the presets with a frame background".

### L5: Session Progress Bar uses an advanced feedback, which API 2.1 discourages

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:198-289`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/feedbacks.ts#L198-L289)

**What goes wrong:** Users see no difference today. API 2.1 advises against new advanced feedbacks, and they are likely to be removed in a future major version. Moving off it then would need an upgrade script and could break users' buttons, while on a first release the change costs nothing.

**Why it happens:** "Session Progress Bar" (`progress_bar`) is an advanced feedback that draws its strip by hand, building a raw RGBA pixel buffer on every state event (`renderBarImage` in [`src/progress.ts`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/progress.ts)). Base 2.1.3 offers layered presets whose graphics elements accept expressions, including a `gauge` element (`value`, `min`, `max`, `orientation: 'horizontal'`) in `@companion-module/base/dist/module-api/graphics.d.ts:135-162`. The module already publishes the value as the `progress_bar` variable.

**Fix:** consider replacing the advanced feedback with a layered preset, for example a "Remaining Time" button with a horizontal `gauge` element whose `value` is the expression `$(cuetime:progress_bar)` (min 0, max 100), see [A5](#-assumptions-to-confirm). If you keep the advanced feedback, no change is needed for this release.

### L6: yarn test fails in a fresh checkout until the icons are generated

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:18`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/package.json#L18)

**What goes wrong:** Companion users are not affected. A contributor who clones the repository and runs `yarn install && yarn test` gets 2 failed test files (`src/feedbacks.test.ts`, `src/presets.test.ts`) with "Cannot find module './generated-icons.ts' imported from src/feedbacks.ts". The tests pass only after `yarn generate-icons` or `yarn build` has run. Reproduced on a `git archive` export of v0.1.2: 2 test files failed and 9 passed. In the review clone, which had already been built, all 11 files and 178 tests pass.

**Why it happens:** `src/generated-icons.ts` is gitignored ([`.gitignore:11`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/.gitignore#L11)) and created only by `scripts/generate-icons.mjs`, but [`src/feedbacks.ts:3`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/feedbacks.ts#L3) and [`src/presets.ts:3-15`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/presets.ts#L3-L15) import it, and the `test` script is just `vitest run`. The CI test job works around this with its own "Generate assets" step.

**Fix:** generate the icons as part of the test script (or add a `pretest` script). The extra "Generate assets" step in `.github/workflows/node.yaml` can then go.

```json
"test": "node scripts/generate-icons.mjs && vitest run"
```

### L7: A variable renamed in only one file would go blank without a build error

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:36-124`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/main.ts#L36-L124)

**What goes wrong:** Users see no difference today. If a later edit renames a variable in only one place, for example `next_session_name` in `src/logic.ts` but not in `src/variables.ts`, the build still passes. The variable in Companion's variable list then stays empty, and buttons using `$(cuetime:next_session_name)` go blank. The comment in [`src/variables.ts:4-7`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/variables.ts#L4-L7) already asks maintainers to keep the two files matched by hand.

**Why it happens:** The module's type declaration (`ModuleInstanceTypes`) now describes the config, actions and feedbacks, but not the variables, so the variable definitions and values accept any name (`base.d.ts:120,125`). The template declares its variables in the same type.

**Fix:** add `variables: VariableValues` (the type already in [`src/logic.ts:86-108`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/logic.ts#L86-L108)) to `ModuleInstanceTypes`, and type the definitions as `CompanionVariableDefinitions<VariableValues>` in [`src/variables.ts:9`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/variables.ts#L9). A missing or misspelt id then fails the build.

## 💡 Nice to Have

### N1: Commands that were never sent are logged as rejected by CueTime

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:278-284`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/main.ts#L278-L284)

**What goes wrong:** With the display offline, an operator presses "Toggle Playback" and the log reads `CueTime rejected 'start_session': TRANSPORT_ERROR — WebSocket not open`. That suggests the display refused the command, when it was never sent. Timeouts and disconnects (`TIMEOUT`, `DISCONNECTED`) get the same wording. Nothing else is affected.

**Why it happens:** The module uses one log message for every failed result, including the ones it creates itself when it can't send (not connected, transport error, timeout, disconnect), not only a real error reply from the display. Only a real reply carries `result.response`.

**Fix:** keep "CueTime rejected" for a real error reply from the display, and use different wording for local failures.

```ts
const verb = result.response ? 'CueTime rejected' : 'Could not send'
this.log('warn', `${verb} '${type}'${detail ? `: ${detail}` : ''}`)
```

### N2: In the Presets tab, every button sits under its own heading

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:577-587`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/presets.ts#L577-L587)

**What goes wrong:** The six sections now match HELP.md, which fixes the previous review's L3. But inside each section, for example "Navigation", each of the 8 buttons gets its own group heading that repeats the button's name ("Navigate to Next Session", "Navigate to Previous Session", …), so the buttons are listed one per heading instead of side by side (see [A4](#-assumptions-to-confirm)).

**Why it happens:** The structure wraps every preset in its own simple group named after that preset. The base typings say a section's `definitions` can instead be "a direct array of preset references, which will be shown without grouping" (`preset/structure.d.ts`, `CompanionPresetSection.definitions`).

**Fix:** pass the preset ids directly (`definitions: section.presets`), or use one group per section, for example `[{ id: section.id, type: 'simple', name: section.name, presets: section.presets }]`. The coverage test in `presets.test.ts` still applies.

### N3: Message flash and Edge dropdowns can still be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:687-699`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L687-L699), [`src/feedbacks.ts:226-235`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/feedbacks.ts#L226-L235)

**What goes wrong:** The four on/off dropdowns from the previous review's L4 are fixed. Two fixed-choice dropdowns still aren't: "Show Message" > "Message flash" (Leave unchanged / Turn on / Turn off) and "Session Progress Bar" > "Edge" (Bottom / Top). If a user switches one of them to expression mode and the expression returns anything other than `keep`/`on`/`off` or `bottom`/`top` (for example `true`), Companion skips the action or feedback.

**Why it happens:** The two dropdowns don't set `disableAutoExpression: true`.

**Fix:** add `disableAutoExpression: true` to both dropdowns. This is a first release, so no stored expressions can break.

### N4: Variables typed into Session ID, Duration and Offset fields are sent as literal text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:207-213`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L207-L213), [`src/actions.ts:307-312`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L307-L312), [`src/actions.ts:326-331`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L326-L331), [`src/actions.ts:345-350`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L345-L350), [`src/actions.ts:366-370`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L366-L370), [`src/actions.ts:384-395`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/actions.ts#L384-L395)

**What goes wrong:** A user types `$(internal:custom_target_session)` into "Delete Session" > "Session ID (blank = current session)", or a variable into "Update Session" > "Duration in seconds" or "Offset HH:MM:SS". The literal `$(…)` text is used instead of the value: the display rejects the session id, or the module logs that the duration or offset is invalid, and nothing happens. It only works if the user knows to switch the field to expression mode.

**Why it happens:** The previous review's L2 fix added `useVariables: true` to the name, presenter, notes and message fields, but not to these text fields: the session id of Move Session Up/Down, Delete Session and Update Session, the duration and offset of Update Session, and the offset of Add Session.

**Fix:** add `useVariables: true` to those text fields. Blank still means "current session" or "leave unchanged", because a variable that resolves to empty gives the same result.

### N5: Is Playing, Is Glowing and Is Blackout variables are Yes/No text instead of true/false

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/logic.ts:137-139`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/logic.ts#L137-L139)

**What goes wrong:** A user who wants a button or trigger to react to blackout has to write `$(cuetime:is_blackout) == 'Yes'` instead of just `$(cuetime:is_blackout)`. Changing this after release would break every expression users have written against "Yes"/"No", so this first release is the cheapest time to decide.

**Why it happens:** The module publishes the three states as the strings `'Yes'`/`'No'`, while API 2.x variable values can be booleans.

**Fix:** optional: publish `is_playing`, `is_glowing` and `is_blackout` as booleans (`cc?.timer_run_state === 'running'`, `cc?.is_glowing === true`, `cc?.is_blackout === true`), and update HELP.md and README.md. Keep the strings if they are what your users expect.

### N6: Target Port (manual) is a text field instead of the template's number field

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:307-315`](https://github.com/bitfocus/companion-module-cuetime-stagedisplay/blob/8e9e6d8775a09a11f1b10ba3a6e3001b7819f238/src/main.ts#L307-L315)

**What goes wrong:** Users see a plain text box for the port instead of a number field limited to 1-65535, as in the template. Changing the field type after release would need an upgrade script for saved connections, so now is the cheapest time.

**Why it happens:** The port is a `textinput` with a port regex, so the config stores it as a string that the module converts with `Number(...)` when it connects.

**Fix:** optional: use the template's number field, with `port: number` in `Config` and `String(config.port)` (or a numeric port) in `getEffectiveEndpoint`.

```ts
{
	type: 'number',
	id: 'port',
	label: 'Target Port (manual)',
	width: 4,
	min: 1,
	max: 65535,
	default: 8081,
	isVisibleExpression: '$(options:cuetime-display) == null',
},
```

## 📝 Additional Notes

- **Previous review (v0.1.0), fixed:** all eight blocking findings. C1-C6 (`.gitignore` entries, `.husky/pre-commit`, `.yarnrc.yml` keys and `yarnPath`, the committed Yarn binary, and the `package.json` scripts, devDependencies and `lint-staged`), H1 (`companion-module-checks.yaml` now matches the template) and H2 (`@types/node` is `^26.6.4`).
- **Previous review (v0.1.0), also fixed:** M1 and M2 (`node.yaml` and `release.yaml` added; `release.yaml` matches the template), M3 (the manual fields use `$(options:cuetime-display)`), M4 (Blackout Mode Active is a boolean feedback), M5 (action and feedback options are typed), M6 (a discovered `ip:port` value is split, though discovery itself is [M1](#m1-the-discovered-cuetime-displays-list-is-always-empty-so-a-display-can-only-be-added-by-ip-address)), M7 (`progress_bar` is re-checked, with a test that catches drift), M8 (Toggle Playback starts the first session from idle) and L1 (no address now shows a configuration status).
- **Previous review (v0.1.0), partly fixed:** L2, L3 and L4 were fixed for the fields and presets they named; the remaining cases are [N4](#n4-variables-typed-into-session-id-duration-and-offset-fields-are-sent-as-literal-text), [N2](#n2-in-the-presets-tab-every-button-sits-under-its-own-heading) and [N3](#n3-message-flash-and-edge-dropdowns-can-still-be-switched-to-expression-mode). `tsconfig.json` now extends `./tsconfig.build.json`, as in the template.
- `tsconfig.build.json` differs from the template: `exclude` also lists `src/**/*.test.ts` and `src/protocol/fixtures.ts`, and `compilerOptions` adds `rewriteRelativeImportExtensions: true` because the module imports its own files with `.ts` extensions. The build and lint pass, so no change is needed.
