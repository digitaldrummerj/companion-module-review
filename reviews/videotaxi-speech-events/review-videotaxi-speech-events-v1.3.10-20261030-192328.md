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
- [ ] [H1: Labels, messages and comments are in German instead of English](#h1-labels-messages-and-comments-are-in-german-instead-of-english)

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

### H1: Labels, messages and comments are in German instead of English

- **Source:** 🔎 compliance rule (everything in English) — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.js`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js)

**What goes wrong:** A user who adds the connection sees German almost everywhere in Companion: action and feedback names ("Senden Start/Stopp"), option and dropdown labels, preset names, categories and button text, variable names, the connection's settings page ("So funktioniert es"), and status and log messages ("Warte auf Erweiterung …"). `companion/HELP.md` and `README.md` are in English, so the help doesn't match what users see. The code comments are in German too.

**Why it happens:** Everything in a Companion module must be written in English: code comments, the text users see in Companion (action, feedback, preset and variable names, option labels, config fields, status and log messages), `companion/HELP.md` and `README.md`. That way every user, reviewer and future maintainer can read it. These lines are in German.

**Evidence:** 141 lines in 1 file, for example:

```text
src/main.js:79  label: 'So funktioniert es',
src/main.js:120  this.updateStatus(InstanceStatus.Connecting, 'Warte auf Erweiterung …')
src/main.js:395  toggle_send: { name: 'Senden Start/Stopp', ...cmd('toggleSend') },
```

**Confirm by:** open `src/main.js` at the lines listed under Fix.

**Fix:** write all of this text in English. These are the lines to change:

- [ ] [`src/main.js`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js) (141 lines): [`4`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L4), [`15-17`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L15-L17), [`26-27`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L26-L27), [`29`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L29), [`79`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L79), [`81-85`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L81-L85), [`90`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L90), [`120`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L120), [`128`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L128), [`130`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L130), [`147`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L147), [`155`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L155), [`171`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L171), [`179`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L179), [`191`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L191), [`224`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L224), [`259`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L259), [`294`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L294), [`298`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L298), [`301`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L301), [`316`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L316), [`322`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L322), [`325-326`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L325-L326), [`328`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L328), [`334`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L334), [`340`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L340), [`345`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L345), [`348`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L348), [`350-351`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L350-L351), [`353-365`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L353-L365), [`383-385`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L383-L385), [`387`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L387), [`390`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L390), [`395-399`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L395-L399), [`401`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L401), [`406`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L406), [`415`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L415), [`439`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L439), [`441`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L441), [`447`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L447), [`457`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L457), [`463`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L463), [`466-468`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L466-L468), [`476`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L476), [`497-500`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L497-L500), [`502`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L502), [`504`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L504), [`517-520`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L517-L520), [`523`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L523), [`527`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L527), [`529`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L529), [`541`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L541), [`548`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L548), [`555`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L555), [`562-563`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L562-L563), [`569`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L569), [`579-580`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L579-L580), [`596-597`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L596-L597), [`603`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L603), [`613`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L613), [`619`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L619), [`622-623`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L622-L623), [`631`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L631), [`654`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L654), [`661`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L661), [`668`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L668), [`675`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L675), [`682`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L682), [`698`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L698), [`717`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L717), [`725`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L725), [`737`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L737), [`740-742`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L740-L742), [`745-746`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L745-L746), [`755`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L755), [`757-758`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L757-L758), [`764`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L764), [`766-767`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L766-L767), [`774`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L774), [`786-787`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L786-L787), [`789`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L789), [`797`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L797), [`799`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L799), [`801`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L801), [`803`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L803), [`809`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L809), [`814-815`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L814-L815), [`817`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L817), [`819-820`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L819-L820), [`827`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L827), [`832`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L832), [`842`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L842), [`854`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L854), [`860`](https://github.com/bitfocus/companion-module-videotaxi-speech-events/blob/4e9093fa64ad11d4d734300b8e95dbc932a331eb/src/main.js#L860)

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
