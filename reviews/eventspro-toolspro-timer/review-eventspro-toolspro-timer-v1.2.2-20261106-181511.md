# Review: companion-module-eventspro-toolspro-timer v1.2.2 (follow-up to the v1.2.1 review)

| | |
| --- | --- |
| **Module** | [companion-module-eventspro-toolspro-timer](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer) |
| **Scope** | `tag` |
| **Version** | v1.2.2 (commit `06631f2`) |
| **Release** | New module — never published |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Previous review** | [v1.2.1, 2026-10-30](review-eventspro-toolspro-timer-v1.2.1-20261030-192328.md) (❌ Changes Required) |
| **Review date** | 2026-11-06 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A Timer page that is already open in a browser is not reloaded when the module process restarts (Companion restart, connection disabled and re-enabled, module update, crash), so the page keeps its old control token and its local timer state | Companion serves the module's pages through `handleHttpRequest` and has no way to reload a browser tab. The session reset itself was reproduced with `src/lan-session.cjs`. Not checked in a live Companion | [L1](#l1-after-companion-or-the-connection-restarts-the-open-timer-page-reconnects-but-resets-the-speaker-countdown-to-1000) |
| A2 | Companion does real work for every `setVariableValues` and `checkFeedbacks` message, even when no value has changed | `@companion-module/base` 1.13.6 sends both on every call without comparing values. How the host handles them was not checked | [N3](#n3-lan-mode-resends-every-variable-and-re-checks-every-feedback-four-times-a-second-even-when-nothing-changed) |
| A3 | Companion's connection settings editor shows a config field that has no `width` without breaking the layout (most likely at full width) | The base 1.13.6 typing declares `width` as required. How the Companion UI handles a missing width was not checked live | [N6](#n6-the-first-settings-field-timer-connection-has-no-width) |

## 📋 Issues

### Blocking

- [ ] [H1: The connection's settings, actions, presets, browser Timer and help page are in Spanish](#h1-the-connections-settings-actions-presets-browser-timer-and-help-page-are-in-spanish)

### Non-blocking

- [ ] [L1: After Companion or the connection restarts, the open Timer page reconnects but resets the speaker countdown to 10:00](#l1-after-companion-or-the-connection-restarts-the-open-timer-page-reconnects-but-resets-the-speaker-countdown-to-1000)
- [ ] [L2: OSC mode with a wrong IP or a stopped bridge stays on Waiting for Timer and never shows a failure](#l2-osc-mode-with-a-wrong-ip-or-a-stopped-bridge-stays-on-waiting-for-timer-and-never-shows-a-failure)
- [ ] [L3: In LAN mode the connection status stays green even when no Timer page is open](#l3-in-lan-mode-the-connection-status-stays-green-even-when-no-timer-page-is-open)
- [ ] [L4: The Advanced settings checkbox has no effect, and a typed Companion local IP is ignored unless it is ticked](#l4-the-advanced-settings-checkbox-has-no-effect-and-a-typed-companion-local-ip-is-ignored-unless-it-is-ticked)
- [ ] [L5: The seconds variable is one second behind the time variable for half of every second in LAN mode](#l5-the-seconds-variable-is-one-second-behind-the-time-variable-for-half-of-every-second-in-lan-mode)
- [ ] [L6: Send message and Speaker name text is parsed for variables twice](#l6-send-message-and-speaker-name-text-is-parsed-for-variables-twice)
- [ ] [L7: Variables appear in Companion's variable list with their raw IDs as names](#l7-variables-appear-in-companions-variable-list-with-their-raw-ids-as-names)
- [ ] [N1: Load and start speaker slot presets are never generated](#n1-load-and-start-speaker-slot-presets-are-never-generated)
- [ ] [N2: After the OSC bridge comes back, the speaker-slot list can take up to 10 s to refresh](#n2-after-the-osc-bridge-comes-back-the-speaker-slot-list-can-take-up-to-10-s-to-refresh)
- [ ] [N3: LAN mode resends every variable and re-checks every feedback four times a second, even when nothing changed](#n3-lan-mode-resends-every-variable-and-re-checks-every-feedback-four-times-a-second-even-when-nothing-changed)
- [ ] [N4: Upgrade scripts are an inline empty array instead of a dedicated upgrades file](#n4-upgrade-scripts-are-an-inline-empty-array-instead-of-a-dedicated-upgrades-file)
- [ ] [N5: Most of the source is still minified one-liners, although Prettier is now set up](#n5-most-of-the-source-is-still-minified-one-liners-although-prettier-is-now-set-up)
- [ ] [N6: The first settings field (Timer connection) has no width](#n6-the-first-settings-field-timer-connection-has-no-width)
- [ ] [NR1: Plan the move to companion-module/base 1.14 or 2.x](#nr1-plan-the-move-to-companion-modulebase-114-or-2x)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The connection's settings, actions, presets, browser Timer and help page are in Spanish

- **Source:** 🔎 compliance reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/lan-module.cjs:8-17`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L8-L17), [`src/lan-module.cjs:29`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L29), [`src/lan-module.cjs:46`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L46), [`src/lan-module.cjs:92`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L92), [`src/module.js:6-7`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L6-L7), [`src/lan-session.cjs:72`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L72), [`src/lan-session.cjs:78`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L78), [`src/lan-session.cjs:85`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L85), [`src/lan-session.cjs:97`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L97), [`src/speaker-timer.js:4-9`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/speaker-timer.js#L4-L9), [`src/speaker-timer.js:25`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/speaker-timer.js#L25), [`companion/HELP.md:1-13`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/companion/HELP.md#L1-L13), [`web/index.html:1`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/web/index.html#L1), [`web/mobile.html:1`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/web/mobile.html#L1), [`web/lan-client.js:4-9`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/web/lan-client.js#L4-L9), [`web/02-speaker-timer-ui.js:2-6`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/web/02-speaker-timer-ui.js#L2-L6), [`src/web-assets.json`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/web-assets.json) (generated from `web/`)

**What goes wrong:** A user adds a Timer PRO connection and opens its settings. The first field, "Conexión Timer", and its choices "Timer en navegador por red local" and "Timer instalado (OSC)" exist only in Spanish, and "Idioma / Language" starts on Español. Until the user finds and changes that setting, the actions ("Iniciar / continuar", "Pausar", "Preparar duración (segundos)"), the feedbacks ("En marcha", "Estado del contador"), the presets ("INICIAR", "PAUSA", "CUENTA", in the categories "Control Timer" and "Tiempos preparados") and the connection status ("Esperando Timer") are all Spanish. Even after switching to English, this text stays Spanish:

- the green connection status "Timer disponible en la red local";
- the `title` variable, which reads "Tiempo de intervención" until a speaker name is set;
- warnings in the Companion log, such as "Elige una duración entre 1 segundo y 24 horas." and "Temporizador no válido.";
- the whole browser Timer page and phone remote that the module serves ("Control móvil", "Escanea con el móvil", and errors such as "Vinculación no válida" and "Timer ya está abierto en otro equipo");
- the connection's help page (HELP.md), which is entirely in Spanish.

Users, other maintainers and Bitfocus support who don't read Spanish can't follow the setup steps or understand the errors.

**Why it happens:** The module is written Spanish-first. Its translation helper returns the Spanish text unless the language setting is English, and the language setting defaults to Spanish, with Spanish also used as the fallback when nothing is saved. On top of that, the LAN wrapper, the LAN session, the timer core and HELP.md contain text that exists only in Spanish. The browser page does carry English text (the `timeEN` table in `web/02-speaker-timer-ui.js`), but the language switcher it relies on (`EventsPROI18n`) is not part of the bundled files, so the page always falls back to its Spanish table. Code comments, README.md and the manifest are already in English.

This text was the same in v1.2.1. The v1.2.1 review should have raised it and didn't; it is raised now because a Companion module's user-facing text has to be in English. It replaces that review's suggestion to give the "Conexión Timer" field and the variables Spanish / English labels.

**Evidence:**

```js
// src/main.js:1
const base=require('@companion-module/base');base.runEntrypoint(require('./lan-module.cjs')(base),[]);
```

```js
// src/lan-module.cjs:8-17
{
	type: 'dropdown',
	id: 'transport',
	label: 'Conexión Timer',
	default: this.config?.transport || 'lan',
	choices: [
		{ id: 'lan', label: 'Timer en navegador por red local' },
		{ id: 'osc', label: 'Timer instalado (OSC)' },
	],
},
// src/lan-module.cjs:29
this.config = { language: 'es', ...config }
// src/lan-module.cjs:46
this.updateStatus(base.InstanceStatus.Ok, 'Timer disponible en la red local')
```

```js
// src/module.js:6-7 (start of line 7)
t(es,en){return this.config?.language==='en'?en:es;}
getConfigFields(){return[{type:'dropdown',id:'language',label:'Idioma / Language',default:'es',choices:[{id:'es',label:'Español'},{id:'en',label:'English'}],width:12},
```

```js
// src/lan-session.cjs:72
return { status: 409, body: { error: 'Timer ya está abierto en otro equipo' } }
// src/lan-session.cjs:78
if (!owner && body.control !== this.token) return { status: 403, body: { error: 'Vinculación no válida' } }
```

```js
// src/speaker-timer.js:4 (excerpt)
const defaults=()=>({... title:'Tiempo de intervención', ...});
// src/speaker-timer.js:25 (excerpt)
function configure(s,seconds){if(!Number.isInteger(seconds)||seconds<1||seconds>86400)throw Error('Elige una duración entre 1 segundo y 24 horas.');...}
```

```js
// web/02-speaker-timer-ui.js:6 — no shipped file defines EventsPROI18n, so M() always uses timeES
const M=(key,params)=>timeI18n?timeI18n.message(key,params):String(timeES[key]).replace(/\{(\w+)\}/g,(_,k)=>String((typeof params==='function'?params():params||{})[k]??'{'+k+'}'));
```

```text
// companion/HELP.md:1-5
# Timer PRO por red local

Candidato de pruebas, no entrega verificada en oficina.

1. Importa este módulo en Companion y selecciona Timer en navegador por red local.

// web/index.html:1 (start)
<!doctype html><html lang="es"> ...
```

**Confirm by:** open [`companion/HELP.md`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/companion/HELP.md) (the whole file is Spanish) and [`src/lan-module.cjs:8-17`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L8-L17) and [`src/lan-module.cjs:46`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L46) (Spanish-only field, choices and status, with no English alternative). Then open [`src/module.js:7`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L7): `default:'es'` makes Spanish the default.

**Fix:** write every user-facing string in English.

- The simplest route is to drop the `language` option and keep only the English side of each `this.t(es, en)` pair in `src/module.js`.
- Translate the Spanish-only strings. In `src/lan-module.cjs`: "Conexión Timer" → "Timer connection", "Timer en navegador por red local" → "Timer in browser over local network", "Timer instalado (OSC)" → "Installed Timer (OSC)", "Timer disponible en la red local" → "Timer available on the local network", "Modo OSC" → "OSC mode". Also translate the error and device strings in `src/lan-session.cjs`, and the default title and error messages in `src/speaker-timer.js`.
- Rewrite `companion/HELP.md` in English. README.md already holds most of the content.
- Make the browser Timer and phone remote in `web/` English: use the existing `timeEN` table as the fallback (or ship the language switcher), translate the strings in `web/lan-client.js` and `web/mobile.js`, set `lang="en"`, and regenerate `src/web-assets.json`.

## 🟢 Low

### L1: After Companion or the connection restarts, the open Timer page reconnects but resets the speaker countdown to 10:00

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`web/lan-client.js:5-6`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/web/lan-client.js#L5-L6), [`src/lan-session.cjs:26-36`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L26-L36)

**What goes wrong:** A user runs the connection in "Timer en navegador por red local" (LAN) mode. The Timer page is open on the stage display, showing speaker "Ana" with a running 20:00 countdown. Then Companion restarts, the user disables and re-enables the connection, or the module restarts after a crash. Since v1.2.2 the page pairs again by itself, which fixes the v1.2.1 review's M1. But the moment it pairs, the stage display jumps to 10:00, stopped, the title goes back to "Tiempo de intervención", and any message on screen is cleared. The speaker loses their running clock in the middle of a talk. (The phone remote has to scan the QR code again, which is expected after a restart.) Saving the connection settings no longer causes this; only a restart of the module does. HELP.md and README.md say that a module restart doesn't keep the live timer state, but the open page still holds that state and throws it away.

**Why it happens:** After a restart the module starts a new session with default timer state and a new token. The page's next sync is rejected with "403 Vinculación no válida", so the page clears its token and claims ownership again. It then takes the new session's reply as the truth and writes that default state into the browser's storage, which the display picks up, so the defaults overwrite the running timer. The page never pushes its own state to the new session. The reviewer reproduced the reset with the module's own session code: the old sync returns 403, and the new claim returns a stopped 10:00 timer titled "Tiempo de intervención".

**Fix:** when the page re-claims ownership after a 403 (it already had a token), keep its local state and push it to the new session instead of adopting the server's defaults.

- In the 403 branch of `tick()`, set a flag (for example `reclaim=true`).
- In the owner branch, when `reclaim` is set, first send `{op:'sync',client,revision:d.revision,changed:true,state:<local state with the deadline offset>}` and call `save()` with that reply.
- Or have the session return `fresh:true` on the owner reply until it has been synced once, and let the page push its state when it sees it. On a first page load (no previous token), letting the server win is fine as it is.

### L2: OSC mode with a wrong IP or a stopped bridge stays on Waiting for Timer and never shows a failure

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:10`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L10), [`src/module.js:13-14`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L13-L14), [`src/module.js:25`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L25)

**What goes wrong:** A user picks "Timer instalado (OSC)" and types the wrong "Timer computer IP" (for example 192.168.1.50 instead of .51), or the Timer bridge isn't running. The connection status stays yellow, "Waiting for Timer", for as long as the connection runs. It never turns into the red "No Timer feedback" failure, so it looks as if the connection is still coming up, and every button press only logs "Timer is disconnected". Unchanged since v1.2.1 (L1 there).

**Why it happens:** The module flags a failure only when the Timer's last reply is more than 4 seconds old. Applying the settings resets the last-reply time to zero, and only a `connected` message from the Timer sets it. Until the Timer has replied at least once, the check never fires.

**Evidence:**

```js
// src/module.js:10
this.lastSeen=0;this.socket=dgram.createSocket('udp4');const socket=this.socket;
// src/module.js:14 (excerpt)
this.watch=setInterval(()=>{if(this.lastSeen&&Date.now()-this.lastSeen>4000){...this.updateStatus(InstanceStatus.ConnectionFailure,this.t('Sin retorno de Timer','No Timer feedback'));}},1000);
```

**Fix:** record when the socket was bound and use it as the reference until the first reply arrives.

- Set `this.startedAt=Date.now()` in the bind callback on line 13.
- In the watch interval, use `const ref=this.lastSeen||this.startedAt` and set `InstanceStatus.ConnectionFailure` ("No Timer feedback") when `ref&&Date.now()-ref>4000` (or allow a slightly longer grace period before the first reply).
- Keep the 10 s presets request running, so the status recovers as soon as the Timer answers.

### L3: In LAN mode the connection status stays green even when no Timer page is open

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-module.cjs:46`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L46), [`src/lan-module.cjs:60-69`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L60-L69)

**What goes wrong:** In "Timer en navegador por red local" mode, the connection always shows green "Timer disponible en la red local", including when nobody has the Timer page open or the stage browser has been closed. The user presses START and Companion's `time` variable counts down, but nothing appears on the speaker display, and the START button's "Running" feedback stays off because that feedback needs a connected page. The "Timer connected" feedback and the `connected` variable do show 0, but the connection list gives no sign. If the green status is meant to say only that the built-in web server is up, this is a design choice with little effect.

**Why it happens:** The module sets the green status once, when the settings are applied. The 250 ms LAN update works out whether a page has synced in the last 10 seconds and stores it in the `connected` state, but it never updates the connection status.

**Fix:** update the status from the 250 ms LAN update when page presence changes.

- In `updateLAN()`, when `s.online` changes, call `updateStatus(InstanceStatus.Ok, …)` while a page is connected and `updateStatus(InstanceStatus.Connecting, 'Open the Timer page')` (or `Disconnected`) while none is.
- Remember the last value so the status is only sent when it changes.

### L4: The Advanced settings checkbox has no effect, and a typed Companion local IP is ignored unless it is ticked

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-module.cjs:18-20`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L18-L20), [`src/module.js:7-8`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L7-L8)

**What goes wrong:** A user picks "Timer instalado (OSC)". The "Companion local IP" and "Feedback receive port" fields appear straight away, whether or not "Advanced settings" is ticked, so the checkbox seems to do nothing. The user types 192.168.1.20 as the Companion local IP and saves without ticking Advanced. The module then quietly listens on 0.0.0.0 (or on 127.0.0.1 when the Timer IP starts with 127.) instead of the typed address, and nothing on screen says the value was ignored. On a Companion machine with several network interfaces, the feedback socket listens on a different interface than the one the user picked. The feedback port, by contrast, is always used. Unchanged since v1.2.1 (L2 there).

**Why it happens:** The LAN wrapper replaces every OSC field's visibility rule with "show when the transport is OSC". That overwrites the "show when Advanced is ticked" rule that the two advanced fields declare. When the settings are applied, the module still discards the local IP whenever Advanced is unticked.

**Evidence:**

```js
// src/lan-module.cjs:18-20
...super
	.getConfigFields()
	.map((f) => (f.id === 'language' ? f : { ...f, isVisibleExpression: "$(options:transport) === 'osc'" })),
// src/module.js:8 (excerpt)
if(!this.config.advanced)this.config.listenIp=this.config.host.startsWith('127.')?'127.0.0.1':'0.0.0.0';
```

**Fix:** combine the two visibility conditions instead of replacing one, so the Companion local IP field only shows when it actually takes effect.

```js
{ ...f, isVisibleExpression: f.isVisibleExpression ? `(${f.isVisibleExpression}) && $(options:transport) === 'osc'` : "$(options:transport) === 'osc'" }
```

Or drop the Advanced checkbox and always use the typed local IP.

### L5: The seconds variable is one second behind the time variable for half of every second in LAN mode

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-session.cjs:56`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L56), [`src/speaker-timer.js:29`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/speaker-timer.js#L29)

**What goes wrong:** In LAN mode, right after a 10:00 countdown starts, the `time` variable shows 10:00 while the `seconds` variable shows 599 (reproduced with a harness at 599.4 s remaining). This happens for half of every second. A trigger such as "when `seconds` = 60, flash the button" fires while the speaker display and the time button still show 01:01. The same mismatch appears in overtime: at -5.6 s the display shows +00:05 but `seconds` is -6.

**Why it happens:** The display text rounds the remaining time up for a running countdown, but the session works out `seconds` by rounding to the nearest second.

**Fix:** use the display's rounding, `seconds: Math.ceil(d.ms / 1000)`. That matches the text for both positive and overtime countdown values.

### L6: Send message and Speaker name text is parsed for variables twice

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:34`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L34)

**What goes wrong:** Mostly invisible. Companion already replaces variables in the "Text" field of "Send message" and "Speaker name" before the action runs, and the module then replaces them again. If a variable's value itself contains text like `$(internal:time_hms)`, that text is expanded a second time, so the speaker display shows something other than the variable's actual value. Unchanged since v1.2.1 (L3 there).

**Why it happens:** The option is declared with `useVariables: true`, so Companion resolves it, and the callback still calls `ctx.parseVariablesInString`, which `@companion-module/base` 1.13.6 marks as deprecated ("Companion now handles this for you"). The module has no local variables that would need the second pass.

**Fix:** use the option value directly, `String(e.options.value).slice(0, id==='message'?160:100)`, and remove the `await ctx.parseVariablesInString(...)` call.

### L7: Variables appear in Companion's variable list with their raw IDs as names

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:31`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L31)

**What goes wrong:** In the connection's variable list, users see names like "seconds", "preset_count", "message_preset_count", "connected" and "error" instead of readable descriptions such as "Remaining time (seconds)" or "Number of saved speaker slots". Unchanged since v1.2.1 (L4 there).

**Why it happens:** Every variable definition uses its ID as its display name.

**Fix:** give each variable a readable English name, for example `{variableId:'seconds',name:'Remaining time (seconds)'}`, `{variableId:'preset_count',name:'Saved speaker slots'}` and `{variableId:'connected',name:'Timer connected (1/0)'}`.

## 💡 Nice to Have

### N1: Load and start speaker slot presets are never generated

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:49`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L49)

**What goes wrong:** The Presets tab offers a "Prepare …" button for each speaker slot but no "Start …" button, although the code has a label ("Start ") and the start icon for one. Users who want a one-press load-and-start button have to build it themselves from the "Load and start speaker slot" action. If leaving it out is deliberate, there is no visible effect, only dead code. Unchanged since v1.2.1 (N1 there).

**Why it happens:** The inner preset loop runs over `['preset']` only, so every `'preset/start'` branch inside it is unreachable.

**Fix:** add `'preset/start'` to the loop's list (`for(const actionId of ['preset','preset/start'])`) to generate the start presets, or remove the loop and the unreachable branches.

### N2: After the OSC bridge comes back, the speaker-slot list can take up to 10 s to refresh

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:14`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L14), [`src/module.js:25`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L25)

**What goes wrong:** The OSC bridge goes quiet for more than 4 s and the connection turns red, "No Timer feedback". When the bridge answers again, the status goes green straight away, but speaker slots or saved messages that changed in the meantime only appear in the "Load named speaker slot" dropdown and in the presets after the next 10 s periodic refresh, not at once. The visible effect is small.

**Why it happens:** When the module notices the lost feedback, it marks the Timer as disconnected but doesn't reset its "was connected" flag. So when the next `connected` message arrives, the module doesn't treat it as a reconnect and skips the immediate speaker-slot request.

**Fix:** set `this.wasConnected=false` in the watch interval's lost-feedback branch (line 14), next to `this.state.connected=false`.

### N3: LAN mode resends every variable and re-checks every feedback four times a second, even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-module.cjs:48-54`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L48-L54), [`src/lan-module.cjs:77`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L77), [`src/module.js:29`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L29)

**What goes wrong:** No visible effect for the user. In LAN mode, every 250 ms the module sends all 11 variables to Companion and asks it to re-evaluate the connected, running, phase, message and mode feedbacks on every button, even while the timer is paused and nothing has changed. That adds avoidable work on systems with many buttons or connections.

**Why it happens:** The 250 ms LAN update always ends by refreshing everything: it sets every variable and re-checks all five feedback types. `@companion-module/base` 1.13.6 doesn't skip unchanged values; it sends them all on every call.

**Fix:** remember the last variable values and pass only the changed ones to `setVariableValues`. Call `checkFeedbacks` only for the feedback types whose inputs (connected, running, phase, message, mode) changed since the last update.

### N4: Upgrade scripts are an inline empty array instead of a dedicated upgrades file

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:1`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/main.js#L1)

**What goes wrong:** No visible effect today. When a later release renames an action, option or feedback, there is no upgrades file to add a script to. That makes the script easier to forget, and forgetting it breaks users' existing buttons. Unchanged since v1.2.1 (N2 there).

**Why it happens:** The entry point passes a literal `[]` to `runEntrypoint` instead of the upgrade-script array that the v1 JS template exports from `src/upgrades.js`.

**Fix:** create `src/upgrades.js` with `module.exports = []`, and call `base.runEntrypoint(require('./lan-module.cjs')(base), require('./upgrades.js'))`.

### N5: Most of the source is still minified one-liners, although Prettier is now set up

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:1-54`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/module.js#L1-L54) (also [`src/main.js`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/main.js), [`src/osc.cjs`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/osc.cjs), [`src/remote.cjs`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/remote.cjs), [`src/speaker-timer.js`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/speaker-timer.js), [`src/icons.cjs`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/icons.cjs))

**What goes wrong:** No visible effect. Every action, feedback, preset and variable definition sits on a handful of very long lines inside one `define()` method. That makes the module hard for other maintainers and reviewers to read, fix or extend, and lets bugs like the unreachable Start presets ([N1](#n1-load-and-start-speaker-slot-presets-are-never-generated)) hide. Partly addressed since v1.2.1 (N3 there).

**Why it happens:** v1.2.2 added the template's `format` script and Prettier setting, but only `src/lan-module.cjs`, `src/lan-session.cjs` and `tests/lan.test.cjs` were reformatted. `prettier --check src tests` still lists `src/icons.cjs`, `src/main.js`, `src/module.js`, `src/osc.cjs`, `src/remote.cjs`, `src/speaker-timer.js`, `src/web-assets.json` and the other test files.

**Fix:** run `yarn format` and commit the result. Add `src/web-assets.json` (generated) to `.prettierignore` if it shouldn't be reformatted. Then split `define()` into `actions.js`, `feedbacks.js`, `presets.js` and `variables.js`, following the `companion-module-template-js` layout.

### N6: The first settings field (Timer connection) has no width

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-module.cjs:8-17`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L8-L17)

**What goes wrong:** Probably no visible effect. The "Conexión Timer" dropdown may render at a different width from the fields under it, which all set a width.

**Why it happens:** `@companion-module/base` 1.13.6 declares `width` as a required property of every config field. The transport dropdown has none, which goes unnoticed because the module is plain JavaScript.

**Fix:** add `width: 12` to the transport dropdown definition.

## 🔮 Next Release

### NR1: Plan the move to companion-module/base 1.14 or 2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:18`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/package.json#L18)

**What goes wrong:** No problem today. The module is on `@companion-module/base` 1.13.6 (Companion 4.1+). Base 1.14 adds the automated config layout. Base 2.0 (Companion 4.3+) and 2.1 (Companion 5.0+) add expression support and the API that new Companion releases are built around. Carried over from v1.2.1 (NR1 there).

**Why it happens:** `package.json` pins `"@companion-module/base": "1.13.6"`.

**Fix:** in a later release, upgrade to base 1.14, or migrate to v2.x following the Companion v1-to-v2 migration guide. On v2, the preset text `$(<label>:time)` and the deprecated parse calls change, so retest the presets after migrating.

## 📝 Additional Notes

- First release of this module: it has never been published, so there is no published version to diff against. The whole module was reviewed again and every finding is classified 🆕 NEW. The v1.2.1..v1.2.2 changes (8 files) were checked against the [v1.2.1 review](review-eventspro-toolspro-timer-v1.2.1-20261030-192328.md).
- Fixed since the v1.2.1 review (thank you):
  - C1–C3: `package.json` now has the template's Prettier setting, the `format` script and `prettier` in the development dependencies ([`package.json:10`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/package.json#L10), [`package.json:22`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/package.json#L22), [`package.json:33`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/package.json#L33)).
  - C4: the "Stream Deck" keyword is gone from [`companion/manifest.json:28-33`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/companion/manifest.json#L28-L33).
  - M1: saving the settings in LAN mode now keeps the session ([`src/lan-module.cjs:28-44`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L28-L44)), and the Timer page pairs again by itself after a 403 ([`web/lan-client.js:6`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/web/lan-client.js#L6)). What remains after a module restart is [L1](#l1-after-companion-or-the-connection-restarts-the-open-timer-page-reconnects-but-resets-the-speaker-countdown-to-1000).
  - M2: speaker-slot and message lists are validated before they are stored ([`src/lan-session.cjs:5-24`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L5-L24), [`src/lan-session.cjs:81-86`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-session.cjs#L81-L86)), the 250 ms update catches and logs errors ([`src/lan-module.cjs:48-54`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/src/lan-module.cjs#L48-L54)), and a new test covers it.
- Still open from the v1.2.1 review (all non-blocking): its L1 is now [L2](#l2-osc-mode-with-a-wrong-ip-or-a-stopped-bridge-stays-on-waiting-for-timer-and-never-shows-a-failure), L2 is [L4](#l4-the-advanced-settings-checkbox-has-no-effect-and-a-typed-companion-local-ip-is-ignored-unless-it-is-ticked), L3 is [L6](#l6-send-message-and-speaker-name-text-is-parsed-for-variables-twice), L4 is [L7](#l7-variables-appear-in-companions-variable-list-with-their-raw-ids-as-names), N1 is [N1](#n1-load-and-start-speaker-slot-presets-are-never-generated), N2 is [N4](#n4-upgrade-scripts-are-an-inline-empty-array-instead-of-a-dedicated-upgrades-file), N3 is [N5](#n5-most-of-the-source-is-still-minified-one-liners-although-prettier-is-now-set-up) (partly addressed) and NR1 is [NR1](#nr1-plan-the-move-to-companion-modulebase-114-or-2x).
- New in this review: [H1](#h1-the-connections-settings-actions-presets-browser-timer-and-help-page-are-in-spanish) (the text was already in v1.2.1), [L1](#l1-after-companion-or-the-connection-restarts-the-open-timer-page-reconnects-but-resets-the-speaker-countdown-to-1000), [L3](#l3-in-lan-mode-the-connection-status-stays-green-even-when-no-timer-page-is-open), [L5](#l5-the-seconds-variable-is-one-second-behind-the-time-variable-for-half-of-every-second-in-lan-mode), [N2](#n2-after-the-osc-bridge-comes-back-the-speaker-slot-list-can-take-up-to-10-s-to-refresh), [N3](#n3-lan-mode-resends-every-variable-and-re-checks-every-feedback-four-times-a-second-even-when-nothing-changed) and [N6](#n6-the-first-settings-field-timer-connection-has-no-width).
- The template check found no differences, and `yarn install --immutable` and `yarn package` both succeeded.
- [`companion/HELP.md:3`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/companion/HELP.md#L3) calls this build a test candidate that hasn't been verified, and [`companion/HELP.md:11`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/06631f24d2c15518e36792940fbc9744db93326e/companion/HELP.md#L11) says it hasn't been tried on a real network with Windows and a phone yet. When you rewrite the help page in English ([H1](#h1-the-connections-settings-actions-presets-browser-timer-and-help-page-are-in-spanish)), consider whether that belongs in a released module's help.
