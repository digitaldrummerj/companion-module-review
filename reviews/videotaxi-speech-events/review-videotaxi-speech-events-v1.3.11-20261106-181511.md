# Review: videotaxi-speech-events v1.3.11 (follow-up to the v1.3.10 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-videotaxi-speech-events` |
| **Scope** | `tag` |
| **Version** | v1.3.11 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Commit** | [`bf99b4f`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/tree/bf99b4f95404679ebebd71efba63840e1e69afac) |
| **Follow-up to** | [v1.3.10 review](review-videotaxi-speech-events-v1.3.10-20261030-192328.md) (2026-10-30) |
| **Review date** | 2026-11-06 |

## Verdict: ✅ Approved

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A new button in Companion has a black background (0, 0, 0) by default, so a feedback style of rgb(24, 22, 18) looks the same as the button without it | General Companion default button style; the module and `@companion-module/base` don't set it | [L1](#l1-adding-the-extension-connected-feedback-to-a-button-makes-no-visible-change) |
| A2 | When a preset's action leaves out an option that the action declares, Companion 5.0 does not fill in the option's default (`''` = "Active delivery session"). The option stays unset: it shows empty in the button editor and is sent without a value. If Companion does fill in the default, L2 is only about consistency | The base 2.1.3 `CompanionPresetOptionValues` typing, which maps every action option key to a value; how the Companion host turns a preset into a button was not checked. The v1.3.10 review made the same assumption (A4) for the fullscreen presets | [L2](#l2-the-two-zoom-presets-leave-out-the-session-option) |

## 📋 Issues

### Non-blocking

- [ ] [M1: Session feedback dropdown never lists the sessions the extension sends](#m1-session-feedback-dropdown-never-lists-the-sessions-the-extension-sends)
- [ ] [L1: Adding the Extension connected feedback to a button makes no visible change](#l1-adding-the-extension-connected-feedback-to-a-button-makes-no-visible-change)
- [ ] [L2: The two zoom presets leave out the Session option](#l2-the-two-zoom-presets-leave-out-the-session-option)
- [ ] [N1: HELP.md still says preset texts use the default connection label](#n1-helpmd-still-says-preset-texts-use-the-default-connection-label)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟡 Medium

### M1: Session feedback dropdown never lists the sessions the extension sends

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:252-254`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/main.js#L252-L254), [`src/feedbacks.js:49-63`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/feedbacks.js#L49-L63)

**What goes wrong:** A user adds the feedback "Session is … (delivery)" to a button and opens its Session dropdown. It shows only "(sessions not loaded yet)", or an old list, even though the "Select session (delivery)" action's dropdown on the same button already lists the current sessions (for example "Main hall"). A session the operator creates during the show never appears in the feedback's dropdown; the only way to use it is to type the raw session ID as a custom value. The other three lists (input languages, display languages and monitors) refresh both the action and the feedback dropdowns; only the session list skips the feedbacks. The `session_name` and `display_name` variables have a similar, shorter gap: after a new session or monitor list arrives, they keep showing the raw ID or the old name until the extension's next state update.

**Why it happens:** When the extension sends its session list, the module stores it and rebuilds only the action definitions. The feedback definitions, which build the "Session is … (delivery)" choices from the same list, are rebuilt only when a languages, display-languages or monitors list arrives, so they keep whatever session list existed at that moment. The session and monitor branches also don't call `publish()`, so the name variables are recalculated only on the next state message. The QA reviewer reproduced this with a scratch harness: a `sessions` message with `{ id: 's1', name: 'Main hall' }` updated the action dropdown to "Main hall", but no new feedback definitions followed and the feedback still offered "(sessions not loaded yet)". This was already the case in v1.3.10; the previous review didn't raise it.

**Evidence:**

```js
// src/main.js:252-254
			} else if (msg.type === 'sessions') {
				this.sessions = (Array.isArray(msg.list) ? msg.list : []).filter((e) => e && e.id != null)
				this.updateActions()
```

```js
// src/feedbacks.js:49-63
		session_is: {
			type: 'boolean',
			name: 'Session is … (delivery)',
			...
					default: self.sessions[0]?.id || '',
					choices: self.sessionChoices(),
```

**Confirm by:** open [`src/main.js:245-263`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/main.js#L245-L263). The `sessions` branch calls only `updateActions()`, while the languages, viewerLanguages and displays branches also call `updateFeedbacks()`; [`src/feedbacks.js:60`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/feedbacks.js#L60) builds the `session_is` choices from `sessionChoices()`.

**Fix:** when a session list arrives, rebuild the feedbacks too, and publish the variables so `session_name` picks up the new names; do the same `publish()` call in the monitors branch for `display_name`.

```js
} else if (msg.type === 'sessions') {
	this.sessions = (Array.isArray(msg.list) ? msg.list : []).filter((e) => e && e.id != null)
	this.updateActions()
	this.updateFeedbacks()
	this.publish()
}
```

## 🟢 Low

### L1: Adding the Extension connected feedback to a button makes no visible change

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:25-31`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/feedbacks.js#L25-L31), [`src/constants.js:10`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/constants.js#L10)

**What goes wrong:** A user adds the feedback "Extension connected" to a normal button with the default black background. When the Chrome extension connects, the button turns rgb(24, 22, 18), which looks the same as black, and the text stays white, so the feedback looks broken (see [A1](#-assumptions-to-confirm)). Every other on/off feedback in the module uses green or red as its default style.

**Why it happens:** The default style of the "Extension connected" feedback uses the module's `dark` color with white text. That color is nearly black, and the module's own presets use it as their normal background.

**Fix:** give the feedback a clearly different default style, for example green like the module's other "on" feedbacks.

```js
defaultStyle: { bgcolor: C_GREEN, color: C_WHITE },
```

### L2: The two zoom presets leave out the Session option

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:97-98`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/presets.js#L97-L98), [`src/actions.js:62-71`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/actions.js#L62-L71)

**What goes wrong:** A user drags the "Zoom + (▲ "Zoom")" or "Zoom − (▼ shows current)" preset onto a button and opens the action. Depending on how Companion fills missing preset options (see [A2](#-assumptions-to-confirm)), the Session option may show empty instead of "Active delivery session", and the command goes to the extension without a `session` field instead of `session: ""`. After the last review the Open fullscreen and Open/close fullscreen presets got `{ session: '' }`, but these two were missed; the previous review's L3 only named the fullscreen presets. If the extension treats a missing session the same as `""`, the only effect is the empty dropdown.

**Why it happens:** The "Browser zoom + (session)" and "Browser zoom − (session)" actions both declare a Session option, but their presets pass no options at all (`{}`).

**Fix:** pass the Session option explicitly, the same way the fullscreen presets do.

```js
zoom_next_preset: preset('Zoom + (▲ "Zoom")', '▲\nZoom', 'zoom_next', { session: '' }, [], '14'),
zoom_prev_preset: preset('Zoom − (▼ shows current)', `▼\n$(${label}:zoom)`, 'zoom_prev', { session: '' }, [], '14'),
```

## 💡 Nice to Have

### N1: HELP.md still says preset texts use the default connection label

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:18`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/companion/HELP.md#L18)

**What goes wrong:** A user who renamed the connection (for example to "Booth1") reads in the help: "The connection label defaults to `VIDEO_TAXI_Speech`; preset variable texts use this label." They may think they have to edit the "Previous language" and "Zoom −" preset texts by hand. They don't: since v1.3.11 the presets use the connection's current label and are rebuilt when it changes. The sentence is only out of date; module behaviour is unaffected.

**Why it happens:** The presets now build their text from the connection's own label ([`src/presets.js:11`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/presets.js#L11)), and `configUpdated()` rebuilds them every time ([`src/main.js:62-64`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/main.js#L62-L64)). The help sentence was written for the old hard-coded label.

**Fix:** replace the sentence with one that matches the new behaviour.

```markdown
Presets that show a value (current language, zoom) use this connection's own label, so they keep working after you rename the connection.
```

## 📝 Additional Notes

- First release (never published): there is no published version to diff against, so this tag-scope review covers the whole module at v1.3.11.
- Follow-up to the [v1.3.10 review](review-videotaxi-speech-events-v1.3.10-20261030-192328.md). The v1.3.10..v1.3.11 change covers 9 files (+697/−632), mostly splitting `src/main.js` into `actions.js`, `constants.js`, `feedbacks.js`, `presets.js`, `variables.js` and `upgrades.js`. Every finding from that review is fixed (table below). M1, L1 and L2 above were already in v1.3.10 and weren't raised then; they don't come from the refactor.

| v1.3.10 finding | Status in v1.3.11 |
| --- | --- |
| C1: banned keyword "stream deck" in the manifest | Fixed: removed from [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/companion/manifest.json#L27) |
| H1: labels, messages and comments in German | Fixed: all user-facing text and comments are now in English |
| M1: two presets show an empty value after renaming the connection | Fixed: presets use the connection's label ([`src/presets.js:11`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/presets.js#L11)) and are rebuilt on every config update ([`src/main.js:62-64`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/main.js#L62-L64)) |
| L1: a malformed list message crashes the module | Fixed: list entries are filtered and the message handler is wrapped in `try/catch` ([`src/main.js:227-266`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/main.js#L227-L266)) |
| L2: any local WebSocket client turns the connection green | Fixed: `verifyClient` rejects web-page origins and accepts only the Chrome extension or non-browser clients ([`src/main.js:138-143`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/main.js#L138-L143)) |
| L3: two fullscreen presets leave out the Session option | Fixed for both fullscreen presets ([`src/presets.js:61-77`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/presets.js#L61-L77)); the two zoom presets have the same gap, see [L2](#l2-the-two-zoom-presets-leave-out-the-session-option) |
| L4: fixed-choice dropdowns can be switched to expression mode | Fixed: `disableAutoExpression: true` on the State and Text direction dropdowns ([`src/actions.js:23`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/actions.js#L23), [`src/actions.js:99`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/actions.js#L99), [`src/feedbacks.js:93`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/feedbacks.js#L93)) |
| L5: upgrade scripts in `main.js` | Fixed: moved to [`src/upgrades.js`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/upgrades.js) |
| N1: every state update re-checks all feedbacks and resends all variables | Fixed: only changed variables are sent and only the feedbacks that depend on them are re-checked ([`src/main.js:291-307`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/main.js#L291-L307), [`src/constants.js:17-34`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/bf99b4f95404679ebebd71efba63840e1e69afac/src/constants.js#L17-L34)) |
| N2: all code in one `main.js` | Fixed: split into the template's separate files |
| N3: German-only labels | Fixed together with H1 |
