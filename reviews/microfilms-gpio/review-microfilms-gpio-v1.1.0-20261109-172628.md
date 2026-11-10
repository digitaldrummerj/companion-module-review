# Review: microfilms-gpio v1.1.0 (follow-up to the v1.0.1 review)

| | |
| --- | --- |
| **Module** | `companion-module-microfilms-gpio` |
| **Scope** | `tag` (first release: never published, so the whole module was reviewed) |
| **Version** | v1.1.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Commit** | [`55b389b`](https://github.com/bitfocus/companion-module-microfilms-gpio/tree/55b389b03725ef80d61068bdb8242d552e3816be) |
| **Prior review** | [v1.0.1 (2026-10-30)](review-microfilms-gpio-v1.0.1-20261030-003407.md) |
| **Reviewed** | 2026-11-09 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [H1: The README, code comments, simulator messages and test names are in French](#h1-the-readme-code-comments-simulator-messages-and-test-names-are-in-french)

### Non-blocking

- [ ] [M1: Connection status stays at OK or Connecting and the log fills with errors when the computer cannot send to the device](#m1-connection-status-stays-at-ok-or-connecting-and-the-log-fills-with-errors-when-the-computer-cannot-send-to-the-device)
- [ ] [M2: The GPIO nn state feedback can only set the background colour](#m2-the-gpio-nn-state-feedback-can-only-set-the-background-colour)
- [ ] [M3: Users pick from 96 separate actions and 32 feedbacks instead of choosing a GPIO number](#m3-users-pick-from-96-separate-actions-and-32-feedbacks-instead-of-choosing-a-gpio-number)
- [ ] [L1: While the robot is off, the log gets the same error twice every 3 seconds](#l1-while-the-robot-is-off-the-log-gets-the-same-error-twice-every-3-seconds)
- [ ] [L2: A UDP socket error would crash the connection, because nothing listens for it](#l2-a-udp-socket-error-would-crash-the-connection-because-nothing-listens-for-it)
- [ ] [L3: The help page tells Companion 4 users to install a 0.x version that was never published](#l3-the-help-page-tells-companion-4-users-to-install-a-0x-version-that-was-never-published)
- [ ] [L4: Updating @companion-module/base makes yarn test fail until the manifest is edited by hand](#l4-updating-companion-modulebase-makes-yarn-test-fail-until-the-manifest-is-edited-by-hand)
- [ ] [N1: Actions don't wait for their command to be sent, and some code is unused](#n1-actions-dont-wait-for-their-command-to-be-sent-and-some-code-is-unused)
- [ ] [N2: Variable names Gpio01 to Gpio32 and GPIO Full don't say what the value means](#n2-variable-names-gpio01-to-gpio32-and-gpio-full-dont-say-what-the-value-means)
- [ ] [N3: The connection appears as Microfilms: Gpio and has no search keywords](#n3-the-connection-appears-as-microfilms-gpio-and-has-no-search-keywords)

### Notes

- **Commit messages:** the commit messages in this release are in French (e.g. `7da373b` "fix: corrige les retours de la revue Bitfocus v1.0.1"). Please write future commit messages in English.
- [📝 Additional Notes](#-additional-notes)

## 🟠 High

### H1: The README, code comments, simulator messages and test names are in French

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** see the list below

**What goes wrong:** Nothing changes for users inside Companion: the action, feedback, preset, variable and config labels and [`companion/HELP.md`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/companion/HELP.md) are in English. The problem is for anyone who doesn't read French and has to maintain, review or troubleshoot the module. The GitHub README is French, and so is every source comment and JSDoc block, the simulator's console output ("Serveur UDP en écoute sur le port 7770", "Commande invalide, en-tête incorrect"), the test names shown by `yarn test` ("Impulse puis destroy < 100 ms : DOWN envoyé une fois, sans attendre") and the JSDoc site committed in `docs/`. On top of that, `.cursorrules` tells AI editors "Tous les commentaires doivent être en français" (all comments must be in French), so new code will keep arriving in French. Affected files:

- Source code, every comment and JSDoc block: [`src/main.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/main.js), [`src/actions.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/actions.js), [`src/feedbacks.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/feedbacks.js), [`src/variables.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/variables.js), [`src/presets.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/presets.js), [`src/network.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js), [`src/protocol.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/protocol.js), [`src/upgrades.js:1-5`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/upgrades.js#L1-L5). `src/protocol.js` also uses the French parameter names `etat` and `masque` ([`src/protocol.js:113-116`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/protocol.js#L113-L116)).
- Simulator, comments and console messages: [`tools/udp-server.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/tools/udp-server.js), for example [`tools/udp-server.js:75`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/tools/udp-server.js#L75) and [`tools/udp-server.js:102-104`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/tools/udp-server.js#L102-L104).
- Tests, describe/test names, comments and assertion messages: [`test/actions.test.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/actions.test.js), [`test/definitions.test.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/definitions.test.js), [`test/main.test.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/main.test.js), [`test/protocol.test.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/protocol.test.js), [`test/udp.integration.test.js`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/udp.integration.test.js). Two of them also use the variable name `etat` ([`test/protocol.test.js:84-93`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/protocol.test.js#L84-L93), [`test/udp.integration.test.js:189-196`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/udp.integration.test.js#L189-L196)).
- ESLint config comments: [`eslint.config.mjs:1-16`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/eslint.config.mjs#L1-L16), [`eslint.config.mjs:23`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/eslint.config.mjs#L23), [`eslint.config.mjs:33`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/eslint.config.mjs#L33), [`eslint.config.mjs:36-38`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/eslint.config.mjs#L36-L38).
- The whole of [`README.md`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/README.md) and [`.cursorrules`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/.cursorrules).
- The generated JSDoc site in [`docs/`](https://github.com/bitfocus/companion-module-microfilms-gpio/tree/55b389b03725ef80d61068bdb8242d552e3816be/docs): `index.html` renders the README, and the `src_*.js.html` and `module-*.html` pages carry the French comments.

**Why it happens:** The module was written in French. The v1.0.1 follow-up translated the user-facing labels and the help page, but left the comments, README, simulator, tests and the AI-editor rules file in French.

**Evidence:**

```js
// src/main.js:1-3
/**
 * @fileoverview Ce fichier contient la définition de la classe ModuleInstance,
 * qui représente une instance de module pour la gestion des GPIO via un NetworkManager.
// src/protocol.js:113-116
function applyMask(etat, gpio, masque) {
	const result = Buffer.alloc(GPIO_LENGTH)
	for (let i = 0; i < GPIO_LENGTH; i++) {
		result[i] = (etat[i] & ~masque[i]) | (gpio[i] & masque[i])
```

```js
// tools/udp-server.js:75
		console.error('Commande invalide, en-tête incorrect')
// tools/udp-server.js:102-104
const PORT = 7770
server.bind(PORT, () => {
	console.log(`Serveur UDP en écoute sur le port ${PORT}`)
// test/main.test.js:264
	nodeTest('Impulse puis destroy < 100 ms : DOWN envoyé une fois, sans attendre', { timeout: 3000 }, async () => {
// eslint.config.mjs:2-5
 * Configuration ESLint du module.
 *
 * La mise en forme (indentation, guillemets, points-virgules, espaces) relève de Prettier
 * (`yarn format`, configuration de `@companion-module/tools`) : ESLint ne garde que les règles de qualité.
```

```text
// README.md:5
Ce module Companion permet de contrôler les robots Microfilms (machineries) via des commandes UDP pour activer ou désactiver les bits GPIO du robot. ...
// README.md:9-11
## Fonctionnalités

- **Impulse** (`GPIO nn pulse (100 ms)`) : active un GPIO, puis le désactive après 100 ms.
// .cursorrules:36-38
Remarques importantes :

- Tous les commentaires doivent être en français;
```

`git ls-files` at v1.1.0 lists `.cursorrules`, `README.md` and the `docs/*.html` pages, so all of them ship in the repository.

**Confirm by:** open [`src/main.js:1-18`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/main.js#L1-L18), [`README.md:1-12`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/README.md#L1-L12) and [`.cursorrules:36-38`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/.cursorrules#L36-L38). The module header, the README and the "all comments must be in French" editor rule are all in French.

**Fix:** translate the comments, README, simulator messages and tests into English, and change the editor rule so it asks for English.

- Translate every comment and JSDoc block in `src/`, `tools/`, `test/` and `eslint.config.mjs` into English.
- Rename the French identifiers (`etat` to `state`, `masque` to `mask`).
- Translate the simulator's console messages, the test names and the assertion messages.
- Rewrite `README.md` in English.
- Change `.cursorrules` to ask for English comments, or delete it (the template doesn't have it).
- Regenerate `docs/` with `yarn doc`.

Device protocol tokens (`INP`, `OUT`) and product names stay as they are. Leave the commit history as it is.

## 🟡 Medium

### M1: Connection status stays at OK or Connecting and the log fills with errors when the computer cannot send to the device

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/network.js:106-129`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L106-L129), [`src/main.js:125-127`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/main.js#L125-L127)

**What goes wrong:** Say the Companion laptop is wired to the GPIO robot at 192.168.10.10 on an isolated network with no other route, and the Ethernet cable gets unplugged. Or the user saves a Target IP on a subnet the computer has no route to. From then on every ping fails before it leaves the computer, with an error such as "send EHOSTUNREACH 192.168.10.10:7770". The Connections list keeps showing what it showed before: a green OK if the robot was answering, or Connecting if the failure started at startup or after Save. It never changes to Disconnected or Connection Failure, so the user believes the robot is online. Meanwhile the connection log gets "Error sending "Set GPIO" command: Error: send EHOSTUNREACH …" twice for every ping, every 500 ms: about 4 error lines a second, or roughly 14,400 an hour. A robot that is simply switched off is handled correctly: the status turns Disconnected after 3 s.

**Why it happens:** The module only starts its 3-second "no reply" watchdog (the one that turns the status to Disconnected) after a ping was sent successfully. When the send itself fails, the module logs the error and retries 500 ms later, but never starts the watchdog. The send-error handler in `src/main.js` only logs and never changes the connection status, so nothing changes it while sends keep failing. The reviewers reproduced this with the module's own network code: with sends failing, 16 send errors and 0 "no response" events in 8 s, and a status that stayed at Ok after the device became unreachable.

**Evidence:**

```js
// src/network.js:110-123
		if (!this.waitingForStatusResponse) {
			this.udpClient.send(this.pingMessage, this.config.port, this.config.host, (err) => {
				if (!this.udpClient) {
					return
				}
				if (err) {
					this.emit('sendError', err)
					this.log('error', `Error sending "Set GPIO" command: ${err}`)
				} else {
					this.waitingForStatusResponse = true
					this.receptionWatcher()
					this.log('debug', 'Command "Set GPIO PING" sent successfully.')
				}
			})
		}
// src/main.js:125-127
		networkManager.on('sendError', (error) => {
			this.log('error', `Error sending "Set GPIO" command: ${error}`)
		})
```

**Fix:** treat a failed ping as a connection failure, and log it only when it changes. For example, emit a dedicated event from the ping's error branch and set the status from it; the status returns to Ok on the next valid reply as it does today:

```js
// src/network.js, sendGpioPing error branch
this.emit('pingError', err)
// src/main.js, createNetworkManager
networkManager.on('pingError', (err) => this.updateStatus(InstanceStatus.ConnectionFailure, err.message))
```

To keep an unreachable robot from adding 4 error lines a second, remember the last error message and log again only when it differs or after a successful reply.

### M2: The GPIO nn state feedback can only set the background colour

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.js:31-64`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/feedbacks.js#L31-L64), [`src/presets.js:50-58`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/presets.js#L50-L58)

**What goes wrong:** A user adds the "GPIO 05 state" feedback to a button. Instead of Companion's normal "when true, apply this style" editor, they get two colour pickers ("Background color when off" = red, "Background color when on" = green). They can't change the text colour, text, size or image when GPIO 5 is on, and there is no "Inverted" checkbox. The feedback also always overrides the button's own background, so a button can't keep its own colour while the GPIO is off. The v1.0.1 review raised this as M6, and it is unchanged.

**Why it happens:** Each feedback is an advanced feedback (`type: 'advanced'`) that returns a background colour picked from its two options. The `@companion-module/base` 2.1.3 typings describe advanced feedbacks as discouraged and likely to be removed in a future major version. An on/off device state is what a boolean feedback is for, and the API 2.1 rules flag an advanced feedback that only sets colours.

**Fix:** make it a boolean feedback before the first release; no upgrade script is needed while the module is unpublished. Return `isBitOn`, set `defaultStyle: { bgcolor: combineRgb(0, 200, 0) }`, and drop the `colorOff`/`colorOn` options. In `src/presets.js`, put the on-colour in the preset feedback's `style` (`style: { bgcolor: this.colors.green }`) instead of `options`; the button's own black `bgcolor` already covers off. See the companion-v2-feedbacks skill.

### M3: Users pick from 96 separate actions and 32 feedbacks instead of choosing a GPIO number

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:23-107`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/actions.js#L23-L107), [`src/feedbacks.js:19-65`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/feedbacks.js#L19-L65)

**What goes wrong:** The action picker lists 96 entries ("GPIO 01 pulse (100 ms)" … "GPIO 32 set off"), and the feedback picker lists 32 ("GPIO 01 state" … "GPIO 32 state"). To move a button from GPIO 3 to GPIO 4, the user has to delete the action and the feedback and add new ones; they can't just change a number. They also can't drive the GPIO number from a variable or expression (e.g. `$(local:gpio)`), because the actions have no options. The v1.0.1 review raised this as M5, and it is unchanged.

**Why it happens:** `src/actions.js` and `src/feedbacks.js` generate one definition per GPIO in a loop, each with no options, so the GPIO number is part of the action and feedback ids (`impulse5`, `up5`, `down5`, `gpio_state_bit_5`).

**Fix:** before the first release (afterwards every saved button would need an upgrade script), define three actions, `pulse`, `set_on` and `set_off`, and one feedback, `gpio_state`. Give each a number option and read `options.gpio` in the callbacks:

```js
{ type: 'number', id: 'gpio', label: 'GPIO', min: 1, max: 32, default: 1, asInteger: true }
```

The 64 presets can keep their ids and pass `options: { gpio: n }`. Alternatively, define one preset per kind with a `localVariables` entry and reference it from `type: 'template'` groups (`templateVariableName`, `templateValues` 1–32). See the companion-v2-actions and companion-v2-preset-category-file skills.

## 🟢 Low

### L1: While the robot is off, the log gets the same error twice every 3 seconds

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/network.js:91-99`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L91-L99), [`src/main.js:115-127`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/main.js#L115-L127)

**What goes wrong:** When the robot is switched off or unplugged, the status correctly turns Disconnected. The connection log then gets "No response from server after '3' seconds" and "No response: No response from server after '3' seconds" every 3 s for as long as the robot stays off. That is about 2,400 error lines an hour (for example overnight), which buries real errors from this and other connections. Every other error is logged twice too: a failed "GPIO 05 set on" send logs "Error sending "Set GPIO" command: …" twice, and a malformed reply logs "Incorrect header or length in "Status" response" twice. The Disconnected and Connection Failure statuses themselves carry no reason text.

**Why it happens:** The network code logs each error itself and also emits an event for it ([`src/network.js:81`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L81), [`src/network.js:96`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L96), [`src/network.js:117`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L117), [`src/network.js:146`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L146)), and the event handlers in `src/main.js` log the same message again at error level. After each timeout the watchdog re-arms on the next ping, and nothing remembers that the module is already Disconnected, so the pair repeats every 3 s.

**Fix:** log each condition in one place, and log a timeout only when the status changes. Drop the `this.log('error', …)` calls next to the emits in `src/network.js` and let `src/main.js` log the events. In `src/main.js`, log `noResponse` only on the change into Disconnected (track the last status set), and pass the reason to the status, e.g. `this.updateStatus(InstanceStatus.Disconnected, message)`.

### L2: A UDP socket error would crash the connection, because nothing listens for it

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/network.js:65-83`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L65-L83)

**What goes wrong:** Nothing visible in normal use. The socket raises an error event only if its automatic bind fails or the operating system reports a receive error, and neither happens in normal operation (sending to a closed UDP port on macOS did not raise one). If it ever did happen, the module process would crash, Companion would show the connection as crashed or restarting, and GPIO buttons would stop until the restart.

**Why it happens:** The module creates its UDP socket and attaches only a `message` listener. Send errors are handled through callbacks, but a socket-level `error` event has no listener, and Node.js throws an `error` event that nobody listens for.

**Fix:** add an error listener right after creating the socket.

```js
this.udpClient.on('error', (err) => {
	this.log('error', `UDP socket error: ${err.message}`)
	this.emit('connectionFailure', err.message)
})
```

### L3: The help page tells Companion 4 users to install a 0.x version that was never published

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:3`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/companion/HELP.md#L3)

**What goes wrong:** A Companion 4.x user reads the help page and sees "For Companion 4.x, use a 0.x version of the module." This is the module's first release, so the Companion module store has no 0.x version, and the advice leads nowhere.

**Why it happens:** The note refers to the maintainer's earlier private 0.x builds, not to anything a store user can get.

**Fix:** replace the line with "This module requires Companion 5.0 or later.", or drop the second sentence.

### L4: Updating @companion-module/base makes yarn test fail until the manifest is edited by hand

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:21`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/companion/manifest.json#L21), [`test/definitions.test.js:111-116`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/definitions.test.js#L111-L116)

**What goes wrong:** Nothing visible for users: when the module is packaged, the build tool overwrites the manifest's API version with the installed base version. But a test checks that the manifest value equals the installed base version, so a routine base update (for example to 2.1.4) makes `yarn test` fail until someone edits the manifest by hand.

**Why it happens:** The manifest sets `"apiVersion": "2.1.3"`, while the API 2.1 JS template has `"0.0.0"` and leaves the value to the build (`node_modules/@companion-module/tools/dist/scripts/lib/build-util.js:90`).

**Fix:** set `"apiVersion": "0.0.0"` as in the template, and remove the `manifest.runtime.apiVersion` assertion from [`test/definitions.test.js:114`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/test/definitions.test.js#L114).

## 💡 Nice to Have

### N1: Actions don't wait for their command to be sent, and some code is unused

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:45`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/actions.js#L45), [`src/actions.js:75`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/actions.js#L75), [`src/actions.js:100`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/actions.js#L100)

**What goes wrong:** Users see no difference today. The pulse, set on and set off actions return before their command is sent, so Companion marks the action done early. If the send ever threw, the error would become an unhandled rejection instead of an action error. Some code is also unused: `this.setGpioHeader` ([`src/main.js:72`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/main.js#L72)), the `setGpioHeader` and `gpioBytes` arguments of the network class ([`src/network.js:35-40`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L35-L40)), and a branch in `configureReception()` that can never run because it is only called from the constructor ([`src/network.js:59-62`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/network.js#L59-L62)).

**Fix:** `await` the send in each action callback (`await this.networkManager.sendGpioCommand(up)`, and likewise for `msgUp` and `msgDown`). Remove `this.setGpioHeader`, the unused constructor arguments and the dead branch.

### N2: Variable names Gpio01 to Gpio32 and GPIO Full don't say what the value means

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.js:28-41`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/src/variables.js#L28-L41)

**What goes wrong:** In the variable picker, the user sees "Gpio05" for `$(MFGpio:05)`. The name doesn't say it is the on/off state (0/1) of GPIO 5, and it doesn't match the feedback naming "GPIO 05 state". "GPIO Full (Little Endian)" doesn't say it is all 32 states packed into one integer.

**Fix:** rename the variables to e.g. "GPIO 05 state (0 = off, 1 = on)" and "All GPIO states (32-bit integer, GPIO 1 = 1)". Variable names are labels only, so the ids `01`…`32` and `Full`, and saved buttons, are unaffected.

### N3: The connection appears as Microfilms: Gpio and has no search keywords

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:26-27`](https://github.com/bitfocus/companion-module-microfilms-gpio/blob/55b389b03725ef80d61068bdb8242d552e3816be/companion/manifest.json#L26-L27)

**What goes wrong:** When adding a connection, users see the product as "Gpio" instead of "GPIO". Because `keywords` is empty, searching for terms like "relay", "contact closure" or "machinery" won't find the module.

**Fix:** set `"products": ["GPIO"]` and add a few keywords, e.g. `["gpio", "relay", "udp", "stage machinery"]`.

## 📝 Additional Notes

- This is the module's first release: it was never published, so there is no published diff. The whole module at v1.1.0 was reviewed and every finding is 🆕 NEW. The changes since the v1.0.1 review (`v1.0.1..v1.1.0`, 58 files, +7777/−2742) move the source into `src/`, move the simulator to `tools/udp-server.js`, align the tooling with the template and add `yarn.lock`.
- Fixed since the v1.0.1 review: C1–C8 (source now in `src/`; `yarn.lock`, `.yarnrc.yml`, `.gitattributes` and `.prettierignore` added; `.gitignore` build entries, Prettier setup and `packageManager` added; Node 26 runtime), H1 (network handlers are now attached on every rebuild, including after Save), H2 (the declared variables `01`…`32` and `Full` are now filled), M1 (the log helper is imported from `src/protocol.js`), M2 (short replies are rejected), M3 (pending pulse releases are sent and cleared on stop and on Save), M4 (ping traffic logs at debug level), M7–M9 (issue templates and workflows added), L1 (config fields have defaults), L2 (one batched update, skipped when nothing changed), L3 (English action, feedback and preset names), L4 (`nodemon` removed), L5 (English help page with a variables table) and N1 (setup functions are synchronous).
- Still open from the v1.0.1 review: M5 is [M3](#m3-users-pick-from-96-separate-actions-and-32-feedbacks-instead-of-choosing-a-gpio-number) here and M6 is [M2](#m2-the-gpio-nn-state-feedback-can-only-set-the-background-colour) here. Both are unchanged.
- `yarn install --immutable` and `yarn package` succeed and produce `microfilms-gpio-1.1.0.tgz`.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When the computer has no route to the configured IP (an isolated network with its cable unplugged, a Target IP on an unreachable subnet, or macOS with Local Network permission denied), the UDP send reports an error such as EHOSTUNREACH or ENETUNREACH through its callback instead of succeeding silently | Standard socket behaviour, and reproduced in the review environment, where every LAN send failed with EHOSTUNREACH and left the module's status stuck. Not tested on a Companion host with a cable physically unplugged; Linux may keep routes on link-down and not return an error | [M1](#m1-connection-status-stays-at-ok-or-connecting-and-the-log-fills-with-errors-when-the-computer-cannot-send-to-the-device) |
| A2 | Companion restarts the module process after an uncaught exception, such as an unhandled socket `error` event | Documented Companion host behaviour; the host code was not checked | [L2](#l2-a-udp-socket-error-would-crash-the-connection-because-nothing-listens-for-it) |
| A3 | Companion shows every module error log line in the connection log and main log, without collapsing or rate-limiting repeated identical lines | `@companion-module/base` 2.1.3 `log()` forwards each call to the host logger; the host's log display was not checked | [M1](#m1-connection-status-stays-at-ok-or-connecting-and-the-log-fills-with-errors-when-the-computer-cannot-send-to-the-device), [L1](#l1-while-the-robot-is-off-the-log-gets-the-same-error-twice-every-3-seconds) |
| A4 | For a boolean feedback, Companion shows its normal style editor (any button style when true) and an "Inverted" checkbox, instead of the module-defined colour pickers an advanced feedback shows | The base 2.1.3 typings (`defaultStyle`, and `showInvert`: "Companion will add an Inverted checkbox"); the style editor itself is host behaviour and was not checked | [M2](#m2-the-gpio-nn-state-feedback-can-only-set-the-background-colour) |
| A5 | Companion does not let a user change an existing action's or feedback's type in place, so moving a button from GPIO 3 to GPIO 4 means removing the entry and adding a new one | Companion UI behaviour as generally known; the host source was not checked | [M3](#m3-users-pick-from-96-separate-actions-and-32-feedbacks-instead-of-choosing-a-gpio-number) |
