# Review: videotaxi-speech-events v1.3.10

| Field | Value |
| --- | --- |
| **Module** | `companion-module-videotaxi-speech-events` |
| **Scope** | `tag` |
| **Version** | v1.3.10 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Commit** | [`4e9093f`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/tree/4e9093fa64ad11d4d734300b8e95dbc932a331eb) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not rewrite a hard-coded connection label in a preset's button text to the connection's real label when the preset is placed. The default label of a new connection comes from the manifest shortname ("VIDEO.TAXI Speech" becomes `VIDEO_TAXI_Speech`), so only renamed connections are affected | The module's own comment at [`src/main.js:15-17`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L15-L17) and the `label` getter in `@companion-module/base` `dist/module-api/base.d.ts`; Companion's host code not checked | [M1](#m1-two-presets-show-an-empty-value-instead-of-the-current-language-or-zoom-when-the-connection-is-renamed) |
| A2 | Companion shows `$NA` for a `$(label:variable)` reference whose connection label doesn't exist, and gives a second connection of the same module a suffixed default label (e.g. `VIDEO_TAXI_Speech_2`), so its presets would show the first connection's value | General Companion host behaviour for variable parsing and default labels; not visible in the module or base | [M1](#m1-two-presets-show-an-empty-value-instead-of-the-current-language-or-zoom-when-the-connection-is-renamed) |
| A3 | A web page or other local process can actually open a WebSocket to `127.0.0.1:8465`. Browsers don't apply CORS to WebSockets, but newer Chrome local-network-access rules may prompt for or block such connections | General browser and WebSocket behaviour; not checked against the current Chrome release | [L1](#l1-a-malformed-list-message-from-any-websocket-client-crashes-the-module), [L2](#l2-any-local-websocket-client-turns-the-connection-green-and-can-change-button-state) |
| A4 | When a preset action leaves out an option, Companion does not reliably fill it with the action definition's default. If it does, L3 is only cosmetic | Companion host preset-import behaviour, not visible in the module or base (the base typings require every option key in typed presets) | [L3](#l3-two-fullscreen-presets-leave-out-the-session-option) |

## 📋 Issues

### Blocking

- [ ] [C1: Manifest search keywords include the banned keyword "stream deck"](#c1-manifest-search-keywords-include-the-banned-keyword-stream-deck)
- [ ] [H1: Code comments are in German instead of English](#h1-code-comments-are-in-german-instead-of-english)

### Non-blocking

- [ ] [M1: Two presets show an empty value instead of the current language or zoom when the connection is renamed](#m1-two-presets-show-an-empty-value-instead-of-the-current-language-or-zoom-when-the-connection-is-renamed)
- [ ] [L1: A malformed list message from any WebSocket client crashes the module](#l1-a-malformed-list-message-from-any-websocket-client-crashes-the-module)
- [ ] [L2: Any local WebSocket client turns the connection green and can change button state](#l2-any-local-websocket-client-turns-the-connection-green-and-can-change-button-state)
- [ ] [L3: Two fullscreen presets leave out the Session option](#l3-two-fullscreen-presets-leave-out-the-session-option)
- [ ] [L4: State and text-direction dropdowns can be switched to expression mode, where a wrong value makes the button do nothing](#l4-state-and-text-direction-dropdowns-can-be-switched-to-expression-mode-where-a-wrong-value-makes-the-button-do-nothing)
- [ ] [L5: Upgrade scripts live in main.js instead of the template's upgrades.js file](#l5-upgrade-scripts-live-in-mainjs-instead-of-the-templates-upgradesjs-file)
- [ ] [N1: Every state update re-checks all 14 feedbacks and resends all 18 variables](#n1-every-state-update-re-checks-all-14-feedbacks-and-resends-all-18-variables)
- [ ] [N2: All code is in one 870-line main.js instead of the template's split files](#n2-all-code-is-in-one-870-line-mainjs-instead-of-the-templates-split-files)
- [ ] [N3: Action, feedback and config labels are German only while the help and manifest are English](#n3-action-feedback-and-config-labels-are-german-only-while-the-help-and-manifest-are-english)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Manifest search keywords include the banned keyword "stream deck"

- **Source:** 🤖 validate-template (MAN-KEYWORD)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/companion/manifest.json#L27)

**What goes wrong:** The module's search keywords include "stream deck". Bitfocus doesn't allow keywords that describe Companion or its hardware in general (`companion`, `module`, `stream deck`, `streamdeck`, `bitfocus`), because they match every module and make search results worse. The module can't be published with it.

**Why it happens:** The `keywords` list in the manifest has `"stream deck"` as its last entry.

**Evidence:**

```json
// companion/manifest.json:27
"keywords": ["video.taxi", "speech", "events", "transcription", "stream deck"]
```

**Confirm by:** open [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/companion/manifest.json#L27). The `keywords` list must contain none of `companion`, `module`, `stream deck`, `streamdeck`, `bitfocus`.

**Fix:** remove `"stream deck"` from the keywords.

```json
"keywords": ["video.taxi", "speech", "events", "transcription"]
```

## 🟠 High

### H1: Code comments are in German instead of English

- **Source:** 🔎 compliance rule (comments in English) — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js)

**What goes wrong:** 27 comment lines in `src/main.js` are written in German. Anyone who later maintains or troubleshoots the module (a Bitfocus reviewer, a contributor fixing a bug, a user reading the source) can't follow what those comments explain, such as which command does what and which reply updates which state.

**Why it happens:** Every comment in a Companion module must be written in English, so that everyone who works on the module can read it. The comments in this module were written in German.

**Evidence:**

```text
src/main.js:15  // Wird im Preset-Variablen-Text verwendet (Verbindungs-Label). Entspricht dem
src/main.js:325  // Für Vollbild-Aktionen: zusätzlich die aktive Anlieferungssession (leere ID →
src/main.js:740  // Stop-Feedback invertiert: rot im gestoppten Zustand, damit Start und
```

**Confirm by:** open `src/main.js` and read the comments at the lines listed under Fix.

**Fix:** translate every comment into English. These are the lines to change:

- [ ] `src/main.js` (27 lines): [`4`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L4), [`15-17`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L15-L17), [`116`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L116), [`147`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L147), [`155`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L155), [`171`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L171), [`179`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L179), [`224`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L224), [`294`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L294), [`301`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L301), [`325-326`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L325-L326), [`345`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L345), [`387`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L387), [`439`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L439), [`502`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L502), [`725`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L725), [`740-741`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L740-L741), [`745`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L745), [`764`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L764), [`786`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L786), [`797`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L797), [`801`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L801), [`817`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L817)

## 🟡 Medium

### M1: Two presets show an empty value instead of the current language or zoom when the connection is renamed

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:18`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L18), [`src/main.js:787-799`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L787-L799)

**What goes wrong:** The presets "Vorige Sprache (▼ zeigt aktuelle)" and "Zoom − (▼ zeigt aktuellen)" are meant to show the current input language (e.g. "de-DE") or zoom factor (e.g. "1.25") under the ▼ arrow. A user who renames the connection, for example to "Speech" or "VT_Booth1", and then drags either preset onto a page gets a button that shows only "▼" with an empty or unresolved value. Nothing tells them why; the only hint is a German comment in the source code. A second VIDEO.TAXI connection may also show the first connection's value (see [A2](#-assumptions-to-confirm)). Users who keep the default label are not affected.

**Why it happens:** The button text is built from a fixed constant, `VIDEO_TAXI_Speech`, rather than the connection's real label. The module can read the real label as `this.label`. The presets are also only rebuilt when the host or port changes, so a rename never reaches them.

**Evidence:**

```js
// src/main.js:18
const LABEL = 'VIDEO_TAXI_Speech'
// src/main.js:787-799
lang_prev_preset: preset(
	'Vorige Sprache (▼ zeigt aktuelle)',
	`▼\n$(${LABEL}:language)`,
	...
zoom_prev_preset: preset('Zoom − (▼ zeigt aktuellen)', `▼\n$(${LABEL}:zoom)`, 'zoom_prev', {}, [], '14'),
```

**Fix:** build the preset text from the connection's own label, remove the constant, and rebuild the presets in `configUpdated()` every time (not only when host or port changed), so a renamed connection gets presets with the new label.

```js
`▼\n$(${this.label}:language)`
```

## 🟢 Low

### L1: A malformed list message from any WebSocket client crashes the module

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:136`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L136), [`src/main.js:222-239`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L222-L239), [`src/main.js:302-343`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L302-L343)

**What goes wrong:** The module accepts any WebSocket client on its port, not only the VIDEO.TAXI Chrome extension: a test tool, a script, or any host on the network once the bind address is set to `0.0.0.0`. If such a client sends a list with an empty entry, such as `{"type":"languages","list":[null]}`, the module process crashes and restarts, and every VIDEO.TAXI button stops working until it is back. The QA reviewer reproduced the crash with the module's own `ws` 8.22.0 (exit code 1). The same happens with an empty entry in the session, viewer-language or monitor lists. The maintainer's own extension sends well-formed lists, so normal users won't hit this.

**Why it happens:** When a list arrives, the module checks that it is an array but never checks the entries inside it. Rebuilding the dropdowns ("Eingabesprache wählen", Session, monitor) then reads `code`, `name` or `id` from each entry, which throws on `null`. Only the JSON parsing is wrapped in `try/catch`, so the error escapes the WebSocket message handler and Companion's module process exits.

**Fix:** keep only valid entries when storing a list, and wrap the message handler in `try/catch` so one bad message is logged instead of crashing the connection.

```js
this.languages = Array.isArray(msg.list) ? msg.list.filter((l) => l && typeof l === 'object' && l.code != null) : []
// same for sessions, viewerLanguages and displays, requiring id != null
```

### L2: Any local WebSocket client turns the connection green and can change button state

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:122`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L122), [`src/main.js:133-136`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L133-L136), [`src/main.js:205-221`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L205-L221)

**What goes wrong:** The connection turns green (OK) and the "Erweiterung verbunden" feedback lights up as soon as anything opens a WebSocket to the configured port, for example a port scanner, another tool or a web page in the same browser, even when the VIDEO.TAXI Chrome extension isn't running. Such a client can also send `{"type":"state","sending":true}`, which lights the "Sendet gerade" feedback and sets the `sending` variable to `true` while nothing is being sent. That could mislead an operator during a live event.

**Why it happens:** The WebSocket server is created without any check of who is connecting, every new connection marks the extension as connected, and state messages are accepted from every client.

**Fix:** accept only the extension's origin (optionally with its extension ID), or wait for a short handshake message from the extension before marking it connected and accepting state.

```js
this.wss = new WebSocketServer({
	host,
	port,
	verifyClient: ({ origin }) => origin?.startsWith('chrome-extension://'),
})
```

### L3: Two fullscreen presets leave out the Session option

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:755`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L755), [`src/main.js:765-778`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L765-L778)

**What goes wrong:** The actions "Transkript-Vollbild öffnen" and "Transkript-Vollbild öffnen/schließen" have a Session dropdown, but the presets "Transkript-Vollbild öffnen" and "Vollbild öffnen/schließen" don't store a Session value. Depending on how Companion fills missing preset options (see [A4](#-assumptions-to-confirm)), the Session dropdown may show empty in the button editor, or the command may go out without a session. The other session presets ("Audio-Übersetzung umschalten", "Textrichtung umschalten" and so on) set Session to "Aktive Anlieferungssession" explicitly.

**Why it happens:** Both presets are created with no options (`{}`), so the `session` option that the actions declare is never set.

**Fix:** pass the Session option explicitly, the way the viewer toggle presets do.

```js
open_fullscreen: preset('Transkript-Vollbild öffnen', 'VOLLBILD', 'open_fullscreen', { session: '' }),
// and { session: '' } instead of {} for toggle_fullscreen
```

### L4: State and text-direction dropdowns can be switched to expression mode, where a wrong value makes the button do nothing

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:388-392`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L388-L392), [`src/main.js:456-472`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L456-L472), [`src/main.js:611-626`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L611-L626)

**What goes wrong:** In the button editor, users can switch the "Zustand" dropdown (An / Aus / Umschalten) of the "Vollbild: …" toggle actions, and the "Textrichtung" dropdowns, to expression mode. An expression that returns anything other than `true`, `false`, `toggle`, `btt` or `ttb` fails validation, and Companion skips the action. Nothing shows on the button, so the press just appears to do nothing.

**Why it happens:** In API 2.x every option field except text inputs gets an expression toggle unless it sets `disableAutoExpression: true`. These are fixed choices with no custom values, so expression mode adds nothing and only creates ways to fail.

**Fix:** add `disableAutoExpression: true` to the "Zustand" dropdown in `viewerToggle` and to the "Textrichtung" dropdowns of `set_viewer_direction` and `direction_is`. Keep expression mode on the session, language and monitor dropdowns, where variables are useful.

### L5: Upgrade scripts live in main.js instead of the template's upgrades.js file

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:870`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L870)

**What goes wrong:** Users see no effect, and the empty list is correct for a first release. But the first time an action or option id is renamed, its migration would go at the bottom of the 870-line `main.js` instead of the dedicated file the template uses, which makes the scripts harder to find and keep in order.

**Why it happens:** `export const UpgradeScripts = []` sits at the end of `src/main.js`. The JS template keeps the list in `src/upgrades.js` and imports it from `main.js`.

**Fix:** create `src/upgrades.js` with the list and re-export it from `main.js`.

```js
// src/upgrades.js
export const UpgradeScripts = []
// src/main.js
import { UpgradeScripts } from './upgrades.js'
export { UpgradeScripts }
```

## 💡 Nice to Have

### N1: Every state update re-checks all 14 feedbacks and resends all 18 variables

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:205-221`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L205-L221), [`src/main.js:242-279`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L242-L279)

**What goes wrong:** Users see no difference under normal load. But every state message from the extension, including ones that only update the audio level, sends all 18 variables and re-checks all 14 feedbacks. If the extension streams level updates often, this adds avoidable work in Companion.

**Why it happens:** `publish()` always sends the full variable set and re-checks every feedback, whatever changed.

**Fix:** track which fields changed, send only those variables, and re-check only the feedbacks that depend on them. A level-only update needs no feedback re-check.

### N2: All code is in one 870-line main.js instead of the template's split files

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js)

**What goes wrong:** Users see no effect. Actions, feedbacks, presets, variables and the WebSocket server all live in one class, unlike the template layout that other maintainers and reviewers expect.

**Why it happens:** `initActions`, `initFeedbacks`, `initPresets` and `initVariables` are methods of the main class rather than separate files.

**Fix:** optionally move each of them into its own file (`src/actions.js`, `src/feedbacks.js`, `src/presets.js`, `src/variables.js`), following the JS template, and call them from `main.js`.

### N3: Action, feedback and config labels are German only while the help and manifest are English

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:74-103`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L74-L103), [`src/main.js:346-366`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L346-L366), [`src/main.js:394-533`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L394-L533), [`src/main.js:538-703`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L538-L703)

**What goes wrong:** Users who don't read German see action names like "Senden starten" and "Vollbild: Anzeigesprache setzen", feedbacks like "Eingabesprache ist …", config labels like "WebSocket-IP (Bind-Adresse)" and German variable descriptions. The manifest description and HELP.md are in English, so the Companion UI doesn't match the module's documentation.

**Why it happens:** Every user-facing label in `src/main.js` is written in German.

**Fix:** consider English labels that match HELP.md (e.g. "Start sending", "Fullscreen: set display language", "Input language is …"). Keep the ids unchanged so saved buttons keep working.

## 📝 Additional Notes

- First release: there is no previous tag to diff against, so this tag-scope review covers the whole module.
