# Review: holboxdesign-rio v1.1.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-holboxdesign-rio` |
| **Repository** | <https://github.com/bitfocus/companion-module-holboxdesign-rio> |
| **Scope** | `tag` (v1.0.0..v1.1.0) |
| **Version** | v1.1.0 (`5c6e128`) |
| **Release** | Update — last published v1.0.0 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01, main) |
| **Reviewed** | 2026-11-16 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [M1: Connection stays red with Rio not reachable after one failed button press while Rio is idle](#m1-connection-stays-red-with-rio-not-reachable-after-one-failed-button-press-while-rio-is-idle)
- [ ] [M2: New Media, Monitor and PDF feedbacks use the discouraged advanced feedback type](#m2-new-media-monitor-and-pdf-feedbacks-use-the-discouraged-advanced-feedback-type)
- [ ] [L1: Buttons that used an expression in Mode, When, Command, Direction, Page or What stop working after the update](#l1-buttons-that-used-an-expression-in-mode-when-command-direction-page-or-what-stop-working-after-the-update)
- [ ] [L2: Variables typed in First line of the PDF name feedback show as literal text](#l2-variables-typed-in-first-line-of-the-pdf-name-feedback-show-as-literal-text)
- [ ] [NR1: Two code comments are written in French](#nr1-two-code-comments-are-written-in-french)

## 🟡 Medium

### M1: Connection stays red with Rio not reachable after one failed button press while Rio is idle

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.js:132-140`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/main.js#L132-L140), [`src/main.js:196-199`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/main.js#L196-L199), [`src/main.js:252-255`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/main.js#L252-L255)

**What goes wrong:** An operator presses a Rio button (GO, for example) and that one request fails: a Wi-Fi blip, or Rio takes more than 2 seconds to answer. The Rio connection in Companion's Connections list turns red with "Rio not reachable". In 1.0.0 it went back to green on the next state refresh, about 0.1 s later. In 1.1.0 it stays red for as long as Rio is idle (nothing playing, no stopwatch or timeline running), even though Rio is reachable and every state refresh succeeds. It only turns green again once something changes in Rio. An operator who sees a red connection before the show or between cues may think the link is down. The reviewers reproduced this with a local HTTP server that always returns the same `/rio/status` answer and drops a single `/rio/go` request: v1.0.0 was green again within 87 ms, v1.1.0 was still red after 5 s of successful refreshes.

**Why it happens:** A failed command sets the connection status to "Rio not reachable". The only place that sets it back to OK is the end of the state update (`applyState()`). New in 1.1.0, the state refresh (`poll()`) stops early when Rio's answer is the same as last time ("Rio idle: same answer as last time"), so the state update never runs and nothing clears the red status. In 1.0.0 every successful refresh set the status to OK.

**Evidence:**

```js
// src/main.js:132-140
		} catch (e) {
			if (this.destroyed) return
			// aborted by Companion (button aborted): not a connection problem, no follow-up refresh
			if (abort && abort.aborted) return
			this.log('error', `Rio not reachable (${path}): ${e.message}`)
			this.setStatus(InstanceStatus.ConnectionFailure, 'Rio not reachable')
		}
		// state right after a command, so the buttons follow at once
		this.kick()
// src/main.js:196-199
			if (this.destroyed) return
			this.failures = 0
			// Rio idle: same answer as last time, nothing to update
			if (this.state && text === this.lastText) return
// src/main.js:252-255
		UpdateVariableValues(this)
		this.checkAllFeedbacks()
		this.lastErr = ''
		this.setStatus(InstanceStatus.Ok)
```

**Fix:** set the status back to OK on every successful refresh, even when Rio's answer is unchanged. `setStatus()` already skips repeats, so this costs nothing; the `lastErr` check keeps the "Unexpected state from Rio" warning in place. (Alternatively, clear `this.lastText` in the `send()` error branch, so the next refresh runs the full state update.)

```js
			// Rio idle: same answer as last time, nothing to update
			if (this.state && text === this.lastText) {
				if (!this.lastErr) this.setStatus(InstanceStatus.Ok)
				return
			}
```

### M2: New Media, Monitor and PDF feedbacks use the discouraged advanced feedback type

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:39-44`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/feedbacks.js#L39-L44), [`src/feedbacks.js:98-102`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/feedbacks.js#L98-L102), [`src/feedbacks.js:130-134`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/feedbacks.js#L130-L134)

**What goes wrong:** Nothing looks wrong today: the Media button turns green or blue and shows the media name, the Monitor button turns violet, and the PDF button shows the PDF's name. But the three new feedbacks ("Deck: media look (layer × column)", "Monitor: watches this cell (monitor × layer × column)" and "PDF: name of the PDF on the button (layer × column)") are advanced feedbacks. Users can only pick the colours the module offers; they can't apply their own style (text size, PNG and so on) or invert the feedback, as they can with a boolean feedback. `@companion-module/base` says this type "will likely be removed in a future major version of the module API". The three feedbacks are new in 1.1.0, so now is the cheapest moment to change them, before users build pages on them.

**Why it happens:** Each feedback works out colours and text in one callback and returns a style (`type: 'advanced'`). The same job can be done with boolean feedbacks (each with a default style) plus a value feedback for the name. The base 2.1.3 typings mark advanced feedbacks as discouraged.

**Evidence:**

```js
// src/feedbacks.js:39-44
		media_state: {
			type: 'advanced',
			name: 'Deck: media look (layer × column)',
			description:
				'Colour of the button: on air (program), waiting in the Preview, or not playing; the name of the media on the button (Rio 0.7.5).',
			affectedProperties: ['text', 'color', 'bgcolor'],
```

```ts
// node_modules/@companion-module/base/dist/module-api/feedback.d.ts:133-138
/**
 * The definition of an advanced feedback
 * It is discouraged to use this type of feedback, as it does not fit into our graphics model,
 * or user flexibility goals as well as the other types of feedback.
 * This type will likely be removed in a future major version of the module API.
 */
```

**Fix:** split each look into boolean feedbacks with default styles (for example "Media on air" in green, "Media in the Preview" in blue, "Monitor watches this cell" in violet) and use them in the presets. For the media and PDF names, add a `type: 'value'` feedback that returns the name, and use it in the preset as a local variable with `variableType: 'feedback'` (an API 2.1 feature), with `$(local:media_name)` in the preset text. All three ids are new in 1.1.0, so no upgrade script is needed if they are replaced now.

## 🟢 Low

### L1: Buttons that used an expression in Mode, When, Command, Direction, Page or What stop working after the update

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.js:22-29`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L22-L29), [`src/actions.js:87`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L87), [`src/actions.js:402`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L402), [`src/actions.js:423`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L423), [`src/actions.js:456`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L456), [`src/feedbacks.js:318`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/feedbacks.js#L318), [`src/upgrades.js:1-5`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/upgrades.js#L1-L5)

**What goes wrong:** Only users who switched one of these dropdowns to expression mode in 1.0.0 are affected. Example: on "Layer: mute (M)" a user set Mode to `$(internal:custom_show_live) ? 'on' : 'off'`. After updating to 1.1.0, Companion no longer evaluates that expression, so the button stops doing what was set up (in current Companion the action is skipped and the button does nothing). The same applies to Mode on every on / off / toggle action ("Cues: pause / resume what they play", "Deck: pause / resume what it plays", "Layer: mute (M)", "Layer: solo (S)", "Layer: live only", "Video outputs: start / stop", "Video outputs: open / close one output", "Audio: effect on / off", "Audio: mute a strip", "Audio: PFL of a strip"), When on "Deck: play a clip", Command on "Stopwatch: start / pause / reset", Direction on "Text source: next / previous text", Page on "PDF: page", and What on the "Cues / deck paused" feedback (that feedback stays off). Buttons that use a plain dropdown choice, the normal case, are not affected.

**Why it happens:** 1.1.0 adds `disableAutoExpression: true` (no expression mode) to these options, which already existed in 1.0.0 with expression mode allowed. Turning expression mode off is the right setting for fixed choices like these; what's missing is a way to carry over buttons that already have an expression saved. The base package warns that setting this on an existing option means a saved expression "will no longer be parsed and will break their configuration", and `src/upgrades.js` is still empty.

**Fix:** add an upgrade script that replaces a saved expression on these options with a fixed choice: the literal value when the expression is just a choice id, otherwise the option's default (`'toggle'`, `'now'`, `'next'`, `'cues'` and so on), and log what was changed. The affected action ids are `cues_pause`, `clips_pause`, `layer_mute`, `layer_solo`, `layer_live_only`, `outputs`, `output_one`, `audio_fx`, `audio_mute`, `audio_pfl`, `clip`, `clock`, `text_step` and `pdf`, plus the `paused` feedback. At the least, add a line to `companion/HELP.md` and the release notes asking users who put an expression in these fields to pick a fixed choice again.

### L2: Variables typed in First line of the PDF name feedback show as literal text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:143`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/feedbacks.js#L143)

**What goes wrong:** In the feedback "PDF: name of the PDF on the button (layer × column)", a user types `PDF $(internal:time_hms)` into "First line". The button shows the literal text `PDF $(internal:time_hms)` instead of the time. Only switching the field to expression mode works. The other text fields in this release ("Message (empty = clear)", and Address and Value of the custom command) accept variables, but this new field doesn't.

**Why it happens:** In API 2.x a text field only fills in `$(...)` variables in its normal mode when it sets `useVariables: true`, and this field doesn't.

**Fix:** add `useVariables: true` to the "First line" field.

```js
				{ type: 'textinput', id: 'label', label: 'First line', default: 'PDF ▶', useVariables: true },
```

## 🔮 Next Release

### NR1: Two code comments are written in French

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW (a whole-module check that applies under every scope; both comments were already in v1.0.0)
- **File:** [`src/actions.js:174`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L174), [`src/actions.js:350`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L350)

**What goes wrong:** Users see no change in Companion: these are code comments. But maintainers, reviewers and contributors who don't read French can't follow them. Every file in a module should be in English, so rewrite them in the next release. The rest of the module (action and feedback labels, `companion/HELP.md`, `README.md`, the manifest and the other comments) is in English.

**Why it happens:** Two comments are left over from French-language development: "Preview à plusieurs couches" (Preview with several layers) and "tap tempo des delays" (tap tempo of the delays). They are plain comments, not device menu names or strings sent to Rio.

**Evidence:**

```js
// src/actions.js:174-176
		// Rio 0.7 : Preview à plusieurs couches
		preview_swap: {
			name: 'Preview: SWAP with what is on air (Rio 0.7)',
// src/actions.js:350-352
		// Rio 0.7 : tap tempo des delays (press the button in rhythm, the delay time follows)
		audio_delay_tap: {
			name: 'Audio: delay tap tempo (Rio 0.7)',
```

**Confirm by:** open [`src/actions.js:174`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L174) and [`src/actions.js:350`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/5c6e1289900c9e3602f72b29f76c05e4837a75a2/src/actions.js#L350) and read the two `// Rio 0.7 :` comments: "à plusieurs couches" and "des delays" are French.

**Fix:** rewrite both comments in English.

```js
		// Rio 0.7: Preview with several layers
		// Rio 0.7: delay tap tempo (press the button in rhythm, the delay time follows)
```

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When an option has `disableAutoExpression: true`, Companion no longer evaluates an expression already saved on that option: it checks the saved value against the dropdown choices and skips the action or feedback when it doesn't match | the `disableAutoExpression` warning in the base 2.1.3 typings (`input.d.ts`), and Companion host source at `b615afd` (`Variables/Util.ts`, `VariablesAndExpressionParser.ts`); not checked in a live Companion, and the host version users run may differ | [L1](#l1-buttons-that-used-an-expression-in-mode-when-command-direction-page-or-what-stop-working-after-the-update) |
