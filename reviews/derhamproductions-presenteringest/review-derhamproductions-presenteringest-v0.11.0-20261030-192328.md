# Review: companion-module-derhamproductions-presenteringest v0.11.0

| | |
| --- | --- |
| **Module** | [companion-module-derhamproductions-presenteringest](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest) |
| **Scope** | `tag` (first release: there is no previous tag to diff against, so the whole module was reviewed) |
| **Version** | v0.11.0 |
| **Release** | New module — never published |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`f2dc3ed`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/commit/f2dc3ede1b68eeb1528d835ceb8f97be468e6776) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a dropdown that another field's visibility depends on is switched to expression mode, Companion compares the stored expression rather than its resolved value, so the dependent field shows or hides wrongly | The warning in the base 2.0.4 typings (`node_modules/@companion-module/base/dist/module-api/input.d.ts:36`); Companion's own UI code was not checked | [M2](#m2-custom-message-minutes-and-time-fields-show-or-hide-wrongly-when-a-dropdown-is-switched-to-an-expression) |
| A2 | Companion handles a preset section whose `definitions` list mixes single preset ids and groups badly, dropping or misplacing one kind | The `CompanionPresetSection` typing in base 2.0.4 (`preset/structure.d.ts`) allows only one kind per list; Companion's host code was not checked | [M3](#m3-some-call-in-qa-presets-may-be-missing-or-misplaced-in-the-presets-tab) |
| A3 | A custom cue in the Presenter Ingest status reply has preset `custom` and a non-empty text | The module's `DEFAULT_CUES` (`custom: 'Custom message'`) and the cue action sending `custom` with a text; the server's reply shape isn't documented in the repo | [M1](#m1-seat-has-a-cue-feedback-never-lights-when-cue-is-set-to-custom-message) |

## 📋 Issues

### Blocking

- [ ] [H1: Module checks workflow differs from the template](#h1-module-checks-workflow-differs-from-the-template)

### Non-blocking

- [ ] [M1: "Seat: has a cue" feedback never lights when Cue is set to Custom message](#m1-seat-has-a-cue-feedback-never-lights-when-cue-is-set-to-custom-message)
- [ ] [M2: Custom message, Minutes and Time fields show or hide wrongly when a dropdown is switched to an expression](#m2-custom-message-minutes-and-time-fields-show-or-hide-wrongly-when-a-dropdown-is-switched-to-an-expression)
- [ ] [M3: Some Call in Q&A presets may be missing or misplaced in the Presets tab](#m3-some-call-in-qa-presets-may-be-missing-or-misplaced-in-the-presets-tab)
- [ ] [L1: Pressing a button with no key set replaces the helpful Bad config status with Not set up](#l1-pressing-a-button-with-no-key-set-replaces-the-helpful-bad-config-status-with-not-set-up)
- [ ] [L2: Unexpected errors are reported with no detail in the log](#l2-unexpected-errors-are-reported-with-no-detail-in-the-log)
- [ ] [L3: Refresh now description says the booking is checked every second, but the default is every 3 seconds](#l3-refresh-now-description-says-the-booking-is-checked-every-second-but-the-default-is-every-3-seconds)
- [ ] [N1: Every feedback is re-checked every second while a countdown runs](#n1-every-feedback-is-re-checked-every-second-while-a-countdown-runs)

## 🟠 High

### H1: Module checks workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:11`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/.github/workflows/companion-module-checks.yaml#L11), [`.github/workflows/companion-module-checks.yaml:15`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/.github/workflows/companion-module-checks.yaml#L15)

**What goes wrong:** The GitHub workflow that runs Bitfocus's shared module checks has been changed from the template. Every module is expected to carry the template's workflow unchanged, so that the checks behave the same everywhere and nobody has to work out a local variation when troubleshooting a failed check.

**Why it happens:** Two lines were added to the template's file: the job's `if:` guard also skips the check when the repository is private, and `contents: read` was added under `permissions:`.

**Evidence:**

```yaml
# .github/workflows/companion-module-checks.yaml:11-16 (module)
    if: ${{ !contains(github.repository, 'companion-module-template-') && !github.event.repository.private }}

    permissions:
      # contents: read lets the shared workflow check out this repository
      contents: read
      packages: read
```

```yaml
# companion-module-template-js-v2.0.4/.github/workflows/companion-module-checks.yaml:10-13 (template)
    if: ${{ !contains(github.repository, 'companion-module-template-') }}

    permissions:
      packages: read
```

**Confirm by:** `diff` the module's [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/.github/workflows/companion-module-checks.yaml) against `companion-module-template-js-v2.0.4/.github/workflows/companion-module-checks.yaml`. After the fix, the only remaining differences should be comment lines.

**Fix:** replace the file with the template's `companion-module-checks.yaml`. Uncommenting `upload-artifact: true` is still fine.

## 🟡 Medium

### M1: "Seat: has a cue" feedback never lights when Cue is set to Custom message

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:54-64`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/feedbacks.js#L54-L64), [`src/state.js:65-73`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/state.js#L65-L73)

**What goes wrong:** An operator adds the "Seat: has a cue" feedback to a button, picks Seat 1 and Cue = "Custom message", then sends Seat 1 a custom cue such as "Mic check" with "Cue: send to a presenter". The cue shows on the presenter page and the seat's cue variable reads "Mic check", but the button never changes colour. Every other Cue choice works.

**Why it happens:** The feedback asks the shared cue check whether the seat has the cue, but doesn't pass any message text. The check then defaults the text to an empty string, and for a custom cue it requires the seat's message to equal that text. A real custom cue always has text, so the answer is always "no". The feedback has no text field of its own to compare with.

```js
// src/feedbacks.js:63
callback: ({ options }) => hasCue(self.state, options.seat === 'all' ? 'all' : Number(options.seat), String(options.cue)),
// src/state.js:65-71
export function hasCue(state, n, cue, text = '') {
	...
			(s) => s.cue && (cue === 'any' || (s.cue.preset === cue && (cue !== 'custom' || s.cue.text === text))),
```

**Fix:** let the feedback treat Custom message as "any custom message". Drop the `= ''` default in `hasCue` and only compare the text when one is passed. The cue action's toggle check ([`src/actions.js:79`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/actions.js#L79)) already passes its text, so it keeps matching the exact message.

```js
export function hasCue(state, n, cue, text) {
	...
			(s) => s.cue && (cue === 'any' || (s.cue.preset === cue && (cue !== 'custom' || text === undefined || s.cue.text === text))),
```

Alternatively, add an optional Custom message text field to the feedback (visible when Cue is Custom message) and pass it through.

### M2: Custom message, Minutes and Time fields show or hide wrongly when a dropdown is switched to an expression

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:57-64`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/actions.js#L57-L64), [`src/actions.js:96-108`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/actions.js#L96-L108), [`src/actions.js:147-172`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/actions.js#L147-L172), [`src/actions.js:341-348`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/actions.js#L341-L348)

**What goes wrong:** A user adds "Cue: send to a presenter" and switches the Cue dropdown to expression mode, for example `$(custom:next_cue)`, which resolves to `custom`. The Custom message field is meant to appear when Cue is Custom message, but the stored option is now an expression rather than the value `custom`, so the field stays hidden and the user can't type the message. Four actions have the same pattern: "Cue: send to a presenter" (Cue → Custom message), "Banner: show to every presenter" (Banner → Custom message), "Countdown: start" (Count down → Minutes / Time (HH:MM)) and "Call in Q&A: cue a guest" (Cue → Custom message). While the dropdowns stay in normal value mode, all four work correctly.

**Why it happens:** In API 2.0 any option can be switched into expression mode unless it sets `disableAutoExpression: true`. A field's `isVisibleExpression` (the rule that shows or hides it) may only refer to options that can't be expressions; the base package says so in its typings. None of the Cue, Banner or Count down dropdowns sets `disableAutoExpression`.

**Evidence:**

```js
// src/actions.js:57-64
				{ id: 'cue', type: 'dropdown', label: 'Cue', choices: cues, default: cues[0] ? cues[0].id : 'standby' },
				{
					id: 'text',
					type: 'textinput',
					label: 'Custom message',
					default: '',
					useVariables: true,
					isVisibleExpression: "$(options:cue) == 'custom'",
// src/actions.js:147-150, 154
					id: 'mode',
					type: 'dropdown',
					label: 'Count down',
					...
					default: 'minutes',
// src/actions.js:164
					isVisibleExpression: "$(options:mode) == 'minutes'",
// src/actions.js:172
					isVisibleExpression: "$(options:mode) == 'until'",
```

```ts
// node_modules/@companion-module/base/dist/module-api/input.d.ts:35-36 (base 2.0.4)
     * You can access a value of the current options using `$(options:some_field_id)`.
     * Note: you can only reference fields which are set to `disableAutoExpression` here, as other fields can be expressions and frequently changing values
```

`grep -n disableAutoExpression src/*.js` returns nothing.

**Confirm by:** open [`src/actions.js`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/actions.js#L57) at lines 57, 96, 147 and 341. None of those dropdowns sets `disableAutoExpression: true`, but the fields after them use `isVisibleExpression` on them.

**Fix:** add `disableAutoExpression: true` to the `cue` dropdown in "Cue: send to a presenter" (line 57), the `banner` dropdown in "Banner: show to every presenter" (lines 95-101), the `mode` dropdown in "Countdown: start" (lines 146-155) and the `cue` dropdown in "Call in Q&A: cue a guest" (line 341). This is the first release, so no saved buttons rely on expression mode for these fields yet.

```js
{ id: 'cue', type: 'dropdown', label: 'Cue', choices: cues, default: 'wrap', disableAutoExpression: true },
```

### M3: Some Call in Q&A presets may be missing or misplaced in the Presets tab

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:400-410`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/presets.js#L400-L410)

**What goes wrong:** The "Call in Q&A" section of the Presets tab mixes single buttons (the Q&A queue, Bring in, and each Guest slot) with the Wrap up / Time's up / Thanks groups. Depending on how Companion reads that mixed list, either the single buttons or the guest cue groups may not show, or show in the wrong place, so users can't drag them onto a page.

**Why it happens:** In base 2.0.4 a preset section's `definitions` must be either a list of groups or a list of preset ids, never both. The module is plain JavaScript, so nothing type-checks this. The "Cues" section already does it correctly by using groups only.

```js
// src/presets.js:400-410
			definitions: [
				'callin_queue',
				'callin_admit',
				...slots.map((n) => `callin_slot_${n}`),
				...['wrap', 'time', 'thanks'].map((cue) => ({
					id: `callin-${cue}`,
					type: 'simple',
					...
```

**Fix:** put the single presets into a group of their own before the three cue groups, so `definitions` holds groups only.

```js
{ id: 'callin-main', type: 'simple', name: 'Queue and guests', presets: ['callin_queue', 'callin_admit', ...slots.map((n) => `callin_slot_${n}`)] },
```

## 🟢 Low

### L1: Pressing a button with no key set replaces the helpful Bad config status with Not set up

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:138-170`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/main.js#L138-L170), [`src/main.js:299-310`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/main.js#L299-L310)

**What goes wrong:** A user adds the connection without pasting the Companion key (or pastes a malformed one). The connection correctly shows Bad config: "Paste the booking's Companion key". If they then press any preset button (Seat 1, Start countdown, …) or run "Refresh now", the status changes to Connection failure: "Not set up". That hides the message telling them what to do, makes it look like a network problem, and stays until they save the settings again.

**Why it happens:** Every action ends by fetching the booking status straight away, and "Refresh now" fetches it directly. That fetch doesn't check whether the key is usable, the way the background timer does. Without a usable key the status request fails with "Not set up", and the error handler reports it as a connection failure, overwriting the Bad config status.

**Fix:** skip the fetch when there is no usable key, so the Bad config status stays.

```js
async poll() {
	clearTimeout(this.timer)
	if (!this.api.usable || this.polling) {
		return
	}
```

Alternatively, have `failed()` leave the status unchanged for an error with code `bad_config`.

### L2: Unexpected errors are reported with no detail in the log

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:176-179`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/main.js#L176-L179), [`src/main.js:302-304`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/main.js#L302-L304)

**What goes wrong:** If a status reply can't be processed (for example a malformed seat or guest-slot entry), the connection shows "Unexpected error" and keeps retrying every 10 seconds, but nothing in the Companion log says what failed. A failing action likewise only logs "Countdown: Unexpected error". The user and the maintainer have nothing to go on when troubleshooting.

**Why it happens:** Both the status error handler and the action wrapper replace any error that isn't an HTTP or network error with the fixed text "Unexpected error" and never log the original.

**Fix:** log the real error in both places and keep the short status text. Errors from the module's own parsing code don't carry the key, and network errors are already wrapped without the request.

```js
this.log('error', `Presenter Ingest: ${e?.message ?? e}`)
```

### L3: Refresh now description says the booking is checked every second, but the default is every 3 seconds

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:377-381`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/actions.js#L377-L381)

**What goes wrong:** In the action picker, "Refresh now" says "it is also checked every second or so". The connection's "Check every (seconds)" setting defaults to 3 and goes up to 10, so users get the wrong idea of how fresh the data is. No functional effect.

**Fix:** reword the description to match the setting.

```js
description: 'Fetch the booking straight away (it is also checked every few seconds, see Check every in the connection settings).',
```

## 💡 Nice to Have

### N1: Every feedback is re-checked every second while a countdown runs

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:260-277`](https://github.com/bitfocus/companion-module-derhamproductions-presenteringest/blob/f2dc3ede1b68eeb1528d835ceb8f97be468e6776/src/main.js#L260-L277)

**What goes wrong:** No visible effect. While a countdown or a guest's time on air is running, the module re-sends every variable and re-evaluates every feedback on every button once a second, although only the countdown and on-air values changed. With many seats this costs some CPU on large setups.

**Fix:** in `tick()`, re-check only the countdown feedbacks and send only the changed timer and on-air variables.

```js
this.checkFeedbacks('timer_state', 'timer_low')
```
