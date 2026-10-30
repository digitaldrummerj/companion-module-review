# Re-review: utopianacademy-deckboy v1.0.4

| Field | Value |
| --- | --- |
| **Module** | [companion-module-utopianacademy-deckboy](https://github.com/bitfocus/companion-module-utopianacademy-deckboy) |
| **Version** | v1.0.4 (`f7a411c`) |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Scope** | `tag` |
| **Previous review** | v1.0.3, reviewed 2026-10-11 (❌ Changes Required: C1, H1) |
| **Language** | JavaScript (ESM) |
| **Build** | `yarn install --immutable` PASS, `yarn package` PASS. Lint N/A (the JS template has no lint script) |
| **Review date** | 2026-10-30 |

This is a follow-up to the v1.0.3 review. The module has never been published, so it is reviewed as a first release: there is no release diff, and the whole module was reviewed. To check the v1.0.3 findings, v1.0.3 was compared with v1.0.4: the release changes only `LICENSE`, the manifest, `package.json`, `.yarnrc.yml`, `yarn.lock`, `README.md` and `companion/HELP.md`. Both blocking findings from v1.0.3 are fixed. No file under `src/` changed, so the new non-blocking findings below were in v1.0.3 as well; this full review found them, the release did not introduce them.

## Verdict: ✅ Approved

## 🔁 Since the last review (v1.0.3)

| ID (prior) | Finding | Status | Note |
| --- | --- | --- | --- |
| C1 | The module is set to run on Node 22, but API 2.1 modules run on Node 26 | ✅ Fixed | Manifest `runtime.type` is `node26` and `engines.node` is `^26` |
| H1 | The LICENSE copyright line does not match the template | ✅ Fixed | Line 3 now reads `Copyright (c) 2022 Bitfocus AS - Open Source` |
| M1 | Publishing a GitHub release does not build and attach the module package | ❌ Still open | Carried forward as [M1](#m1-publishing-a-github-release-does-not-build-and-attach-the-module-package) |
| L1 | Saved buttons from v1.0.2 show a blank State in two actions after upgrading | ✅ No longer applies | The module has never been published (assumption A2 of that review is confirmed), so nobody has buttons saved with the old upper-case values |

## 📋 Issues

### Non-blocking

- [ ] [M1: Publishing a GitHub release does not build and attach the module package](#m1-publishing-a-github-release-does-not-build-and-attach-the-module-package)
- [ ] [M2: Seven State and Action dropdowns offer an expression mode that silently skips the action on any other value](#m2-seven-state-and-action-dropdowns-offer-an-expression-mode-that-silently-skips-the-action-on-any-other-value)
- [ ] [L1: Seek with a blank or non-numeric Seconds value sends a command Deckboy rejects](#l1-seek-with-a-blank-or-non-numeric-seconds-value-sends-a-command-deckboy-rejects)
- [ ] [L2: Cue tally and preview buttons light up when the Cue number is blank](#l2-cue-tally-and-preview-buttons-light-up-when-the-cue-number-is-blank)
- [ ] [N1: Every feedback is re-checked on every poll while a deck is playing](#n1-every-feedback-is-re-checked-on-every-poll-while-a-deck-is-playing)

## 🟡 Medium

### M1: Publishing a GitHub release does not build and attach the module package

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (still open from the v1.0.3 review, where it was M1)
- **File:** `.github/workflows/release.yaml` (missing)
- **Template:** `companion-module-template-js` @ `76d25b2`, `.github/workflows/release.yaml`

**What goes wrong:** When the maintainer publishes a release on GitHub, nothing packages the module or attaches the `.tgz` to that release, as it does for modules that follow the current template.

**Why it happens:** The API 2.1 template ships a `release.yaml` workflow that runs when a release is published, packages the module and attaches the package. The module's `.github/workflows/` folder has only `companion-module-checks.yaml`.

**Fix:** copy `.github/workflows/release.yaml` from the template unchanged.

### M2: Seven State and Action dropdowns offer an expression mode that silently skips the action on any other value

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:151-167`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L151-L167), [`src/actions.js:214-230`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L214-L230), [`src/actions.js:264-280`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L264-L280), [`src/actions.js:321-337`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L321-L337), [`src/actions.js:503-523`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L503-L523), [`src/actions.js:537-553`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L537-L553), [`src/actions.js:565-582`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L565-L582)

**What goes wrong:** In the Blackout, Output on / off, VJ mode, VJ quantised takes, Bypass an audio effect, Copy or paste an effect chain, and Video synth: text mode on/off actions, the State (or Action) dropdown shows Companion's expression toggle. A user who switches it on and enters anything other than the exact choice id (for example `On` instead of `on`, or a variable that holds `true`) finds the button does nothing: Companion skips the action and nothing is sent to Deckboy. Users who leave the toggle off are not affected.

**Why it happens:** In API 2.x, Companion lets the user switch any option that is not a text field into expression mode, unless the option sets `disableAutoExpression: true`. The result of the expression is checked against the dropdown's `choices`, and because these dropdowns don't allow custom values, any value outside the list makes Companion skip the action. For a fixed Toggle / On / Off style choice, an expression adds nothing.

**Fix:** turn expression mode off on these fixed-choice dropdowns: the `state` option in `blackout`, `output_enable`, `vj_mode`, `vj_quantise`, `audiofx_bypass` and `text_mode`, and the `action` option in `fx_copy_paste`. If expression input should stay available, add an `expressionDescription` that lists the accepted values instead (for example "toggle, on or off").

```js
{
	type: 'dropdown',
	label: 'State',
	id: 'state',
	default: 'toggle',
	disableAutoExpression: true,
	choices: [
		{ id: 'toggle', label: 'Toggle' },
		{ id: 'on', label: 'On' },
		{ id: 'off', label: 'Off' },
	],
},
```

## 🟢 Low

### L1: Seek with a blank or non-numeric Seconds value sends a command Deckboy rejects

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:127-147`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/actions.js#L127-L147)

**What goes wrong:** A user adds the "Seek (relative or absolute)" action and clears the Seconds field, or fills it with a variable that is empty or holds text (for example an unset `$(internal:custom_jump)`). Pressing the button sends `SEEK` or `SEEK abc` to Deckboy, which rejects it; the deck does not move, and the only sign is a "Deckboy rejected a command" warning in the connection log. Every other numeric action in the module (Master volume, Dimmer, VJ BPM, FX amount and so on) checks its value first and logs "is not a number — nothing sent", so Seek is the one action that sends a command it could already tell is bad.

**Why it happens:** The Seek callback turns the Seconds option into a string and puts it straight into the `SEEKPOS` / `SEEK` command. It doesn't go through the module's own `number()` helper, which every other numeric option uses. The command is trimmed before sending, so a blank value still goes out as a bare `SEEK`.

**Evidence:**

```js
// src/actions.js:143-146
callback: async ({ options }) => {
	const secs = String(options.seconds ?? '')
	await withDeck(options, options.mode === 'abs' ? `SEEKPOS ${secs}` : `SEEK ${secs}`)
},
```

**Fix:** check the value with `number()` first and send nothing when it is not a number, as the other actions do. `number('+10')` returns `10` and `number('-5')` returns `-5`, so relative seeks keep working. If Deckboy needs the leading `+` for a relative seek, keep the original string in the command and use the check only to decide whether to send.

```js
callback: async ({ options }) => {
	const secs = number(options.seconds, 'Seconds')
	if (secs === null) return
	await withDeck(options, options.mode === 'abs' ? `SEEKPOS ${secs}` : `SEEK ${secs}`)
},
```

### L2: Cue tally and preview buttons light up when the Cue number is blank

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:77`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/feedbacks.js#L77), [`src/feedbacks.js:85`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/feedbacks.js#L85)

**What goes wrong:** An operator duplicates the "Cue button with tally" preset and clears the Cue number while editing it, or points it at a custom variable that is currently empty. The "Specific cue is live (tally)" feedback then turns the button red (on air) whenever no cue is live on that deck, and also whenever Deckboy is unreachable. "Specific cue is selected (preview)" turns it green in the same situations. The tally shows "on air" exactly when nothing is live.

**Why it happens:** Both feedbacks compare the deck's live (or selected) cue, as text, with the Cue number option, as text. When no cue is live, or there is no deck data because the connection is down, the deck side is an empty string. A blank Cue number is also an empty string, so the two match and the feedback turns on.

**Evidence:**

```js
// src/feedbacks.js:77
callback: ({ options }) => String(deckFields(options)?.active ?? '') === String(options.cue ?? '').trim(),
// src/feedbacks.js:85
callback: ({ options }) => String(deckFields(options)?.selected ?? '') === String(options.cue ?? '').trim(),
```

**Fix:** return `false` when the Cue number is blank, before comparing. Do the same in `cue_is_selected`.

```js
callback: ({ options }) => {
	const cue = String(options.cue ?? '').trim()
	if (!cue) return false
	return String(deckFields(options)?.active ?? '') === cue
},
```

## 💡 Nice to Have

### N1: Every feedback is re-checked on every poll while a deck is playing

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:349-354`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/main.js#L349-L354), [`src/main.js:365-367`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/f7a411c6cbb52663f931d4db737f22fd8f746576/src/main.js#L365-L367)

**What goes wrong:** Users see nothing wrong. While a cue plays, its position changes on every status reply (four times a second at the default 250 ms poll), so Companion re-runs every feedback on every button each time, including output health, blackout and connection feedbacks that have not changed. The code comment says the state signature limits re-checks to real changes, but during playback there is always a change.

**Why it happens:** The state signature serialises all of the global, deck and output state, including the play position and other fields that change on every report. Any change to it calls `checkAllFeedbacks()`.

**Fix:** optional. Re-check only the feedbacks whose inputs changed: for example, call `checkFeedbacks('deck_remaining_below')` when only the position or duration changed, and `checkAllFeedbacks()` only when status, live or selected cue, outputs or blackout changed. Another option is to leave position and duration out of the signature and re-check `deck_remaining_below` separately.
