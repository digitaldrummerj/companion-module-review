# Review: holboxdesign-rio v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-holboxdesign-rio](https://github.com/bitfocus/companion-module-holboxdesign-rio) |
| **Scope** | `tag` |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`3eefe8e`](https://github.com/bitfocus/companion-module-holboxdesign-rio/tree/3eefe8edb7616da39fc3ceda04c3149c262935b5) |
| **Reviewed** | 2026-10-30 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the field an option's visibility check refers to (`isVisibleExpression`) has no `disableAutoExpression` and is switched to expression mode, Companion builds the check from the raw expression text, so the dependent field is not shown or hidden reliably | The doc comment on `isVisibleExpression` in `@companion-module/base` 2.1.3 `input.d.ts` ("you can only reference fields which are set to `disableAutoExpression`"); Companion's host code was not checked and the UI was not run | [M1](#m1-page-number-field-may-stay-hidden-when-the-page-dropdown-is-switched-to-an-expression) |
| A2 | In Companion 5 (base 2.1), a plain `textinput` value is not variable-parsed unless the field sets `useVariables: true` or the user switches it to expression mode | The `useVariables` doc comment in base 2.1.3 `input.d.ts`; the host's behaviour was not checked live | [M3](#m3-variables-typed-into-the-inset-message-and-custom-command-fields-are-sent-as-literal-text) |
| A3 | Companion's abort of a running action sequence reaches a module only through the action callback's `context.signal` | The `signal` doc comment in base 2.1.3 `action.d.ts:59-62`; the host's behaviour was not checked | [L4](#l4-aborting-a-running-button-does-not-cancel-a-command-already-sent-to-rio) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Page number field may stay hidden when the Page dropdown is switched to an expression](#m1-page-number-field-may-stay-hidden-when-the-page-dropdown-is-switched-to-an-expression)
- [ ] [M2: A state the module cannot read shows as Rio not reachable and the error is never logged](#m2-a-state-the-module-cannot-read-shows-as-rio-not-reachable-and-the-error-is-never-logged)
- [ ] [M3: Variables typed into the inset message and custom command fields are sent as literal text](#m3-variables-typed-into-the-inset-message-and-custom-command-fields-are-sent-as-literal-text)
- [ ] [L1: The refresh timer started after each action is not cleared in destroy](#l1-the-refresh-timer-started-after-each-action-is-not-cleared-in-destroy)
- [ ] [L2: Variables keep their last values after Rio disconnects](#l2-variables-keep-their-last-values-after-rio-disconnects)
- [ ] [L3: Fixed-choice dropdowns can be switched to expression mode](#l3-fixed-choice-dropdowns-can-be-switched-to-expression-mode)
- [ ] [L4: Aborting a running button does not cancel a command already sent to Rio](#l4-aborting-a-running-button-does-not-cancel-a-command-already-sent-to-rio)
- [ ] [N1: Every poll re-sends all variables and re-checks all feedbacks even when nothing changed](#n1-every-poll-re-sends-all-variables-and-re-checks-all-feedbacks-even-when-nothing-changed)
- [ ] [N2: One preset per clip in both Preview and Deck can produce hundreds of near-identical presets](#n2-one-preset-per-clip-in-both-preview-and-deck-can-produce-hundreds-of-near-identical-presets)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Page number field may stay hidden when the Page dropdown is switched to an expression

- **Source:** 🔎 QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:354-374`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L354-L374)

**What goes wrong:** On the "PDF on screen: page" action, the "Page number" field appears only when "Page" is set to "Page number…". With the dropdown used normally this works. But Companion lets the user switch the "Page" dropdown to expression mode, and then the "Page number" field can stay hidden even when the expression gives `page`. The user can't edit the page number, and the action keeps sending whatever value was stored before (for example page 1 instead of page 12).

**Why it happens:** The field's visibility rule (`isVisibleExpression: '$(options:cmd) == "page"'`) reads the "Page" dropdown (`cmd`). The base 2.1.3 typings say a visibility rule may only refer to fields that can't be switched to an expression, which a field declares with `disableAutoExpression: true`. The `cmd` dropdown doesn't set it, and nothing else in the module does either.

**Evidence:**

```js
// src/actions.js:354-374
		pdf: {
			name: 'PDF on screen: page',
			options: [
				{
					type: 'dropdown',
					id: 'cmd',
					label: 'Page',
					default: 'next',
					choices: [
						{ id: 'next', label: 'Next' },
						{ id: 'prev', label: 'Previous' },
						{ id: 'first', label: 'First' },
						{ id: 'last', label: 'Last' },
						{ id: 'page', label: 'Page number…' },
					],
				},
				{ ...num('page', 'Page number', 1, 1, 9999), isVisibleExpression: '$(options:cmd) == "page"' },
			],
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts (base 2.1.3)
     * You can access a value of the current options using `$(options:some_field_id)`.
     * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
     */
    isVisibleExpression?: string;
```

**Confirm by:** open [`src/actions.js:357-370`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L357-L370). The `cmd` dropdown has no `disableAutoExpression: true`, but line 370 refers to `$(options:cmd)` in `isVisibleExpression`. Compare with the `isVisibleExpression` doc comment in `node_modules/@companion-module/base/dist/module-api/input.d.ts`.

**Fix:** stop the "Page" dropdown from being switched to an expression. This is a first release, so no saved expressions can break.

```js
{
	type: 'dropdown',
	id: 'cmd',
	label: 'Page',
	default: 'next',
	disableAutoExpression: true,
	choices: [ /* … */ ],
},
```

Alternatively, drop the `isVisibleExpression` and always show "Page number", with a description saying it is used only for "Page number…".

### M2: A state the module cannot read shows as Rio not reachable and the error is never logged

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:146-195`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/main.js#L146-L195)

**What goes wrong:** Rio is open and answers on port 7001, but its status reply is missing a part the module reads directly (for example `audio.pfl`, `deck.columns` or `clocks`), or updating a variable or feedback throws. After two polls the connection turns red with "Rio not reachable — is Rio open, with HTTP enabled?", `$(rio:connected)` goes to false, and nothing is written to the connection log. The user checks Rio's HTTP setting and the network, where nothing is wrong, and the maintainer has no log line to go on.

**Why it happens:** One `try`/`catch` in `poll()` wraps both the network request and all of the state processing: building the layout signature (`st.cues.map`, `st.deck.columns`, `st.audio.buses`, …), `updateDefinitions()`, `UpdateVariableValues()` and `checkAllFeedbacks()`. The `catch` never looks at the error. It counts every exception as a network failure and shows the fixed "not reachable" message, so a bug inside the module looks exactly like an unreachable Rio.

**Fix:** keep only the network part (`fetch` and `r.text()`) in the `try`/`catch` that counts failures and sets `ConnectionFailure`. Process the state in a second `try`/`catch` that logs the real error and sets a warning status:

```js
} catch (e) {
	this.log('error', `Rio state not understood: ${e.message}`)
	this.setStatus(InstanceStatus.UnknownWarning, 'Unexpected state from Rio')
}
```

Also log `e.message` (debug level is enough) in the network `catch`.

### M3: Variables typed into the inset message and custom command fields are sent as literal text

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:302-309`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L302-L309), [`src/actions.js:388-401`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L388-L401)

**What goes wrong:** A user adds "Director view: inset message" and types `Next: $(rio:cue_playhead_name)` in "Message (empty = clear)". Rio's director view shows the literal text `Next: $(rio:cue_playhead_name)` instead of `Next: Intro video`. The same happens in "Custom command (Rio address)" when "Address" or "Value (optional)" holds a variable such as `$(internal:custom_level)`. The only way around it is to switch the field to expression mode, which few users know to do.

**Why it happens:** In API 2.x, a text field parses `$(…)` variables in its normal mode only when it sets `useVariables: true`. None of these three fields set it.

**Fix:** add `useVariables: true` to the "Message" field of `encart` ([`src/actions.js:304`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L304)) and to the "Address" and "Value (optional)" fields of `custom` ([`src/actions.js:392-393`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L392-L393)).

```js
{ type: 'textinput', id: 'text', label: 'Message (empty = clear)', default: '', useVariables: true },
```

## 🟢 Low

### L1: The refresh timer started after each action is not cleared in destroy

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:126-127`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/main.js#L126-L127), [`src/main.js:51-54`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/main.js#L51-L54)

**What goes wrong:** Nothing visible today. After each action (for example GO), the module schedules a state refresh 80 ms later. If the connection is disabled within those 80 ms, the timer still fires; `poll()` then returns at once because the module is marked destroyed. Every timer a module starts should still be stopped in `destroy()`.

**Why it happens:** `setTimeout(() => this.poll(), 80)` throws its handle away, so neither `destroy()` nor `stopPolling()` can clear it. `stopPolling()` only clears the regular poll interval.

**Fix:** store the handle and clear it in `stopPolling()` (which `destroy()` and `configUpdated()` already call). This also folds rapid button presses into one refresh.

```js
clearTimeout(this.kickTimer)
this.kickTimer = setTimeout(() => this.poll(), 80)
```

### L2: Variables keep their last values after Rio disconnects

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.js:67-72`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/variables.js#L67-L72)

**What goes wrong:** Rio is closed or the network drops, and the connection turns red. A button showing `$(rio:timeline_remaining)` stays frozen at, say, `-2:13`, and `$(rio:cue_playhead_name)` still shows the last cue. On a show-control surface this can look like live data. Only `$(rio:connected)` changes, to `false`.

**Why it happens:** When there is no state, `UpdateVariableValues` sets only `connected: false` and returns, so every other variable keeps its previous value.

**Fix:** when the state is lost, also set every defined variable (the keys of `definitions(null)` plus the per-item ids still defined) to `''` (or `undefined`), then set `connected: false`.

### L3: Fixed-choice dropdowns can be switched to expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:19`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L19), [`src/actions.js:72-80`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L72-L80), [`src/actions.js:317-327`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L317-L327), [`src/actions.js:336-344`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/actions.js#L336-L344), [`src/feedbacks.js:188-197`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/feedbacks.js#L188-L197)

**What goes wrong:** Under options such as "Mode" (Toggle / On / Off), "Command" (Start / pause, Reset …), "Direction", "When" and the feedback's "What", Companion shows an expression toggle that has no real use. A user who types an expression that doesn't match a choice (e.g. `1` instead of `on`) has the action skipped silently. Normal dropdown use is unaffected.

**Why it happens:** These dropdowns don't set `disableAutoExpression: true`, which the API 2.x guidance recommends for fixed on/off/toggle-style choices.

**Fix:** set `disableAutoExpression: true` on the shared `onoff` dropdown, and on the `when`, the stopwatch `cmd`, the `dir` and the feedback `what` dropdowns (the PDF `cmd` dropdown is covered by [M1](#m1-page-number-field-may-stay-hidden-when-the-page-dropdown-is-switched-to-an-expression)). Doing it now is safe because no saved buttons exist yet.

### L4: Aborting a running button does not cancel a command already sent to Rio

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:112-128`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/main.js#L112-L128)

**What goes wrong:** A user aborts a button whose actions are running in sequence (for example with `internal:abortButton`). The HTTP command already sent to Rio still runs to completion, up to its 2-second timeout, before the abort takes effect. There is no visible effect in normal use.

**Why it happens:** API 2.1 gives every action callback an abort signal (`context.signal`). `send()` uses only its own 2-second timeout signal, and the action callbacks never pass Companion's signal through.

**Fix:** pass the callback context into `send()` and combine the two signals. Skip the follow-up poll and the `ConnectionFailure` status when the error is an abort.

```js
signal: context?.signal ? AbortSignal.any([context.signal, AbortSignal.timeout(2000)]) : AbortSignal.timeout(2000)
```

## 💡 Nice to Have

### N1: Every poll re-sends all variables and re-checks all feedbacks even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:185-186`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/main.js#L185-L186)

**What goes wrong:** Nothing visible. At the default "State refresh (ms)" of 250, the module re-checks every feedback and sends every variable (per layer, clock, text and bus) four times a second, even while Rio is idle. On a large show this adds CPU and IPC work in Companion.

**Why it happens:** The module doesn't compare the received status with the previous one.

**Fix:** keep the last response text; when it is identical, skip `UpdateVariableValues` and `checkAllFeedbacks`. Optionally, send only the variables whose values changed.

### N2: One preset per clip in both Preview and Deck can produce hundreds of near-identical presets

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:90-109`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/presets.js#L90-L109), [`src/presets.js:140-166`](https://github.com/bitfocus/companion-module-holboxdesign-rio/blob/3eefe8edb7616da39fc3ceda04c3149c262935b5/src/presets.js#L140-L166)

**What goes wrong:** A show with 8 layers and 20 columns gets 160 "PV …" presets in Preview, plus 160 clip presets and 20 column presets in Deck. The preset browser gets long, and the whole set is rebuilt every time the deck changes. Everything still works; this is browsing comfort only.

**Fix:** optionally use a template preset group (`type: 'template'` with `templateVariableName` / `templateValues`, one template per layer or per column, and `$(local:…)` in the preset options), as the API 2.x presets guidance recommends.

## 📝 Additional Notes

- First release: there is no previous tag, so the whole module was reviewed (no diff). Every finding is 🆕 NEW.
- The template check, `yarn install --immutable` and `yarn package` all passed with no findings.
