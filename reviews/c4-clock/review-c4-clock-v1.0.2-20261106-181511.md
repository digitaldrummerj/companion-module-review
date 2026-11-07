# Review: companion-module-c4-clock v1.0.2

| Field | Value |
| --- | --- |
| **Module** | `companion-module-c4-clock` |
| **Scope** | `tag` |
| **Version** | v1.0.2 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`d2ccedf`](https://github.com/bitfocus/companion-module-c4-clock/tree/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1) |
| **Prior review** | [v1.0.0 (2026-10-30)](review-c4-clock-v1.0.0-20261030-192328.md) |
| **Date** | 2026-11-06 |

This is a follow-up to the [v1.0.0 review](review-c4-clock-v1.0.0-20261030-192328.md). The module has still never been published, so there is no published version to diff against. The whole module was reviewed again, and every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all pass.

What happened to the v1.0.0 findings:

- **C1 (Node 22):** fixed. The manifest runtime, `engines.node`, `@types/node`, the TypeScript preset and the workflows all use Node 26.
- **C2 (old build output):** fixed. The build script runs `rimraf dist` first.
- **H1 (test step in the lint job):** fixed. The step moved to the template's optional test job.
- **M1 (cancelled actions):** fixed. Every action passes Companion's cancel signal on to its HTTP request.
- **L1 (presets after a rename):** fixed. `configUpdated()` rebuilds the presets.

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: A Countdown output-mode feedback lights up while C4 is offline](#l1-a-countdown-output-mode-feedback-lights-up-while-c4-is-offline)
- [ ] [L2: Four feedbacks change nothing on the button when added, because they have no default style](#l2-four-feedbacks-change-nothing-on-the-button-when-added-because-they-have-no-default-style)
- [ ] [L3: A wrong Web Control Port can fill the connection status with a whole HTML error page](#l3-a-wrong-web-control-port-can-fill-the-connection-status-with-a-whole-html-error-page)
- [ ] [L4: Freeze last slide and Auto load PowerPoint always show UNAVAILABLE on the public C4 release](#l4-freeze-last-slide-and-auto-load-powerpoint-always-show-unavailable-on-the-public-c4-release)
- [ ] [N1: Fixed-choice dropdowns can be switched to expression mode, where a typo breaks the button](#n1-fixed-choice-dropdowns-can-be-switched-to-expression-mode-where-a-typo-breaks-the-button)
- [ ] [N2: After changing the C4 Clock IP, the old PC's radio mic presets and variables stay listed](#n2-after-changing-the-c4-clock-ip-the-old-pcs-radio-mic-presets-and-variables-stay-listed)
- [ ] [N3: The changelog has no 1.0.2 entry, and RELEASING.md still calls 1.0.1 the official release](#n3-the-changelog-has-no-102-entry-and-releasingmd-still-calls-101-the-official-release)
- [ ] [N4: The manifest hard-codes the API version that the build fills in](#n4-the-manifest-hard-codes-the-api-version-that-the-build-fills-in)
- [ ] [N5: Every 500 ms poll resends all variables and rechecks all 16 feedback types, even when nothing changed](#n5-every-500-ms-poll-resends-all-variables-and-rechecks-all-16-feedback-types-even-when-nothing-changed)
- [ ] [N6: The preset builder uses non-null assertions and double casts the type checker cannot verify](#n6-the-preset-builder-uses-non-null-assertions-and-double-casts-the-type-checker-cannot-verify)

## 🟢 Low

### L1: A Countdown output-mode feedback lights up while C4 is offline

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:151`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L151), [`src/feedbacks.ts:266-290`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L266-L290), [`src/main.ts:334-369`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L334-L369)

**What goes wrong:** A user builds their own button with the "Output mode is active" feedback set to Output = Countdown, without the "C4 app offline" feedback that the supplied presets add. When the C4 Clock PC is closed or unreachable, that button still shows the white "active" style, as if the countdown were on air. Buttons for Time of day, Notes, Black and Output off correctly show inactive. The supplied presets are not affected, because their last feedback (C4 OFFLINE) covers the whole button. The QA reviewer reproduced this against the built `dist/`: after `markOffline()` the feedback returns true for Countdown and false for the other four modes.

**Why it happens:** When C4 goes offline, the module clears its stored C4 state and rechecks the feedbacks. The feedback then compares an empty output mode with the option. The helper that normalises the mode name (`normalizeOutputMode()`) treats any unknown value, including "no value", as Countdown, so the Countdown option matches whenever no state is known.

**Fix:** return false while C4 is offline. Keep the current fallback for connected C4 builds that leave out `outputMode`.

```ts
callback: (feedback) =>
	self.connected && normalizeOutputMode(self.state.outputMode) === normalizeOutputMode(feedback.options.mode),
```

### L2: Four feedbacks change nothing on the button when added, because they have no default style

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:110-131`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L110-L131), [`src/feedbacks.ts:187-245`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L187-L245)

**What goes wrong:** A user builds a custom button, adds the feedback "Presenter navigation is available" and sets Direction = Next. When C4 allows Next, the button looks exactly the same. The feedback seems broken until the user notices they have to pick the style properties by hand. The same happens with "Session timing state", "Slide pace state" and "Countdown has reached a fixed warning threshold (legacy)". The other 12 feedbacks come with a colour (for example "Countdown is running" turns the button bright green), so these four behave differently from the rest. The supplied presets are not affected, because they set their own styles.

**Why it happens:** When a user adds a boolean feedback to a button, Companion starts it with the feedback's default style. These four feedbacks declare an empty default style (`defaultStyle: {}` at [`src/feedbacks.ts:113`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L113), [`190`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L190), [`211`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L211) and [`230`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/feedbacks.ts#L230)), so adding them changes nothing.

**Fix:** give each one a default style that fits its meaning, as the other feedbacks have. For example:

```ts
time_threshold: { defaultStyle: { bgcolor: AMBER, color: BLACK }, ... },
can_navigate: { defaultStyle: { bgcolor: BRIGHT_GREEN, color: BLACK }, ... },
session_state: { defaultStyle: { color: RED }, ... }, // default option is 'behind'
pace_state: { defaultStyle: { color: RED }, ... }, // default option is 'behind'
```

### L3: A wrong Web Control Port can fill the connection status with a whole HTML error page

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:524-528`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L524-L528), [`src/main.ts:324-328`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L324-L328)

**What goes wrong:** Say a user keeps the Web Control Port at 8080 from an older C4 setup, but C4 now listens on 44044, and another web service on that PC (a NAS admin page, another app's web UI) answers on 8080. That service answers `/api/state` with a 404 HTML page. The connection shows Connection Failure, and its status message is the whole response body, for example `HTTP 404: <!DOCTYPE html><html><head><title>Not Found</title>...`. The user only learns that the port is wrong after reading through that markup. The module keeps working and recovers once the port is corrected.

**Why it happens:** When C4 answers with an HTTP error, the request helper puts the complete response body into the error message. The state poll then shows that message as the connection status, on every failed poll.

**Fix:** keep the status message short, for example `HTTP 404 from <host>:<port>. Check the port in C4 Settings > Web Display`, or at most the first ~80 characters of the body with tags and whitespace collapsed. If the full body is useful, log it once at debug level.

```ts
reject(new Error(`HTTP ${status}`))
// pollState(): add the hint for the status line, log the body with this.log('debug', ...)
```

### L4: Freeze last slide and Auto load PowerPoint always show UNAVAILABLE on the public C4 release

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:52-101`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/actions.ts#L52-L101), [`src/presets.ts:120-134`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/presets.ts#L120-L134), [`src/presets.ts:156-178`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/presets.ts#L156-L178)

**What goes wrong:** A user on the current public C4 Clock (5.77.193, as named in HELP.md) drags the "Freeze last slide (selected PowerPoint)" or "Auto load PowerPoint" preset onto a page. The button stays grey, and pressing it only logs "Freeze last slide is unavailable. Update C4 and connect a compatible PowerPoint add-in." (or the AUTO LOAD PPT equivalent). The module's own HELP says the C4 endpoints these controls need are local test code, so no customer can use them yet. The preset and action names don't say so, and the log message tells the user to "update C4", which they can't do yet.

**Why it happens:** The two actions, their feedbacks and their presets ship in this release and are listed in the Presets panel. But [`companion/HELP.md:38-42`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/companion/HELP.md#L38-L42) and [`companion/HELP.md:83-85`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/companion/HELP.md#L83-L85) say the C4 API they need is "currently local test code, not part of public C4 5.77.193". Your own release checklist ([`RELEASING.md:16-17`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/RELEASING.md#L16-L17)) says: "Confirm customers can obtain the C4 version needed for any promised features. A local-only C4 installer is not a public release."

**Fix:** either hold these two controls back until a public C4 release has the endpoints, or show the requirement where users meet it: name the C4 version in the preset and action names (for example "Freeze last slide (requires C4 x.y+)") and in the log warning, and update HELP.md once that C4 version is public.

## 💡 Nice to Have

### N1: Fixed-choice dropdowns can be switched to expression mode, where a typo breaks the button

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:29-38`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/actions.ts#L29-L38), [`src/actions.ts:55-65`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/actions.ts#L55-L65), [`src/actions.ts:87-97`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/actions.ts#L87-L97)

**What goes wrong:** In the action editor, the "Heading" (Speaker name / Mic label), "Auto load" (Toggle / On / Off) and "Freeze" (Toggle / On / Off) fields offer the expression toggle. If a user switches one to an expression and it produces a value that isn't one of the choices (for example `ON` instead of `on`), the press doesn't do what the button says. Normal use is not affected.

**Why it happens:** In API 2.x, every option other than a text input can be switched to expression mode unless it sets `disableAutoExpression: true`. The API 2.x compliance rules recommend that for fixed on/off/toggle choices.

**Fix:** add `disableAutoExpression: true` to these three dropdowns now, while the module is unpublished. The base typings warn that adding it later breaks expressions users have already saved. Skip this if you want users to drive On/Off from a variable.

### N2: After changing the C4 Clock IP, the old PC's radio mic presets and variables stay listed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:120-124`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L120-L124), [`src/main.ts:281-297`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L281-L297), [`src/main.ts:299-303`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L299-L303)

**What goes wrong:** A user moves the connection from one C4 PC ("C4 Clock App IP" 10.0.0.5) to another (10.0.0.6) that monitors different receivers. The "Radio mic batteries and RF" preset group and the variable list keep every receiver channel from the old PC, shown grey OFFLINE, next to the new PC's channels, until Companion restarts or the connection is disabled and enabled again. Once 256 channels have been seen in total, new channels are silently left out of the presets. Nothing breaks, but the preset list fills with dead tiles. Keeping removed channels as OFFLINE is documented in HELP; a change of C4 PC is a different case.

**Why it happens:** The module keeps every receiver channel it has seen in one list and never clears it. A settings change only marks the existing entries as unavailable, and new channels are added only while the list holds fewer than 256.

**Fix:** in `configUpdated()`, when the host or port changed, clear the radio state before polling starts again.

```ts
this.radios = undefined
this.radioMicLabels = undefined
this.updateVariableDefinitions()
this.updatePresets()
```

### N3: The changelog has no 1.0.2 entry, and RELEASING.md still calls 1.0.1 the official release

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`CHANGELOG.md:3`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/CHANGELOG.md#L3), [`RELEASING.md:34-37`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/RELEASING.md#L34-L37)

**What goes wrong:** Someone reading the changelog for the version they install (1.0.2) finds no entry for it, so they miss that the default Web Control Port changed from 8080 to 44044. RELEASING.md still says 1.0.1 is "the official update" and that "the local 1.0.2-1.0.22 packages were test iterations". 1.0.2 is now the version being submitted, which could confuse anyone who still has one of those private 1.0.2+ test packages installed.

**Fix:** add a `## 1.0.2` entry to CHANGELOG.md (Web Control Port default 44044, the new port help text in the connection settings), and update [`RELEASING.md:34-37`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/RELEASING.md#L34-L37) so it names 1.0.2 as the submitted version.

### N4: The manifest hard-codes the API version that the build fills in

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/companion/manifest.json#L20)

**What goes wrong:** Nothing visible. When packaging, `companion-module-build` replaces `runtime.apiVersion` with the installed `@companion-module/base` version (`node_modules/@companion-module/tools/dist/scripts/lib/build-util.js:89`), so the packaged manifest is correct. The source manifest just doesn't match the template, which ships `"0.0.0"`.

**Fix:** set `"apiVersion": "0.0.0"` in `runtime`, as in the template, and let the build fill it in.

### N5: Every 500 ms poll resends all variables and rechecks all 16 feedback types, even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:390-457`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L390-L457), [`src/main.ts:248-279`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/main.ts#L248-L279)

**What goes wrong:** No visible effect. While connected, each state poll (twice a second) sends about 45 variable values and asks Companion to re-run every placed feedback of 16 types. Each radio poll (once a second) sends every radio variable twice, before and after the run sheet is fetched. With many buttons and receivers this is avoidable work for Companion, but it does not change what the user sees.

**Why it happens:** Every successful state poll sends the full set of variables and rechecks all 16 feedback types, whether or not anything changed. The radio poll applies the radio status twice per cycle, and each pass sends the full set of radio variables.

**Fix:** optional. Keep the last applied state and only recheck the feedback types whose inputs changed (or skip the recheck when the state is unchanged). In the radio poll, fetch the run sheet first and apply the radio status once.

### N6: The preset builder uses non-null assertions and double casts the type checker cannot verify

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:556-557`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/presets.ts#L556-L557), [`src/presets.ts:629`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/presets.ts#L629), [`src/presets.ts:513`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/presets.ts#L513), [`src/presets.ts:518`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/presets.ts#L518), [`src/presets.ts:684`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/src/presets.ts#L684)

**What goes wrong:** No visible effect today: every layered preset has a box and a text element, so the C4 OFFLINE overlay builds correctly. But if a future layout in `design-assets/preset-layout.json` has no box or no text element, the compiler gives no warning, and the overlay is built from a missing element. It then has no `type`, and the preset is broken.

**Why it happens:** The overlay code finds the layout's box and text elements with a `!` (non-null assertion), which tells the compiler they always exist. Other places cast the layout data with `as unknown as ...` and `as ...[]`, which also skips type checking.

**Fix:** replace the `!` with an explicit check that throws a clear error, as the existing "Layered preset source is missing" check does, and narrow the elements with a type guard instead of `as unknown as`.

```ts
if (!background || !text) throw new Error(`Layered preset ${id} needs a box and a text element`)
```

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a boolean feedback with `defaultStyle: {}` is added to a button, Companion applies no style properties until the user picks them | the base 2.1.3 typing for `defaultStyle` ("The default style properties for this feedback") in `dist/module-api/feedback.d.ts:114-115`; Companion's host code not checked | [L2](#l2-four-feedbacks-change-nothing-on-the-button-when-added-because-they-have-no-default-style) |
| A2 | Companion shows the status message passed to `updateStatus()` in the Connections list without shortening it much, so a long HTML body is shown as an unreadable status | general knowledge of the Companion Connections UI; not checked against Companion 5.0 source or a live instance | [L3](#l3-a-wrong-web-control-port-can-fill-the-connection-status-with-a-whole-html-error-page) |
| A3 | The current public C4 Clock release (5.77.193) still lacks the Freeze last slide and AUTO LOAD PPT HTTP endpoints, so these controls always show UNAVAILABLE for customers | the maintainer's own statements in [`companion/HELP.md:38-42`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/companion/HELP.md#L38-L42), [`companion/HELP.md:83-85`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/companion/HELP.md#L83-L85) and [`CHANGELOG.md:18-21`](https://github.com/bitfocus/companion-module-c4-clock/blob/d2ccedff2a3c65f7b7b2a230a6cab1ca0375c2f1/CHANGELOG.md#L18-L21); C4 Clock itself not checked | [L4](#l4-freeze-last-slide-and-auto-load-powerpoint-always-show-unavailable-on-the-public-c4-release) |
| A4 | Each `checkFeedbacks(type, ...)` call makes Companion re-run the callback of every placed feedback of those types, so calling it unconditionally every 500 ms costs real work | the base 2.1.3 doc comment on `checkFeedbacks` ("Request all feedbacks of the specified types to be re-executed"); Companion's host scheduling not checked | [N5](#n5-every-500-ms-poll-resends-all-variables-and-rechecks-all-16-feedback-types-even-when-nothing-changed) |
