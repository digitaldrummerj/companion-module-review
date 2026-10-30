# Review: companion-module-eventspro-toolspro-timer v1.2.1

| | |
| --- | --- |
| **Module** | [companion-module-eventspro-toolspro-timer](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer) |
| **Scope** | `tag` |
| **Version** | v1.2.1 (commit `1325463`) |
| **Release** | New module — never published |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When Companion restarts or re-spawns the module, a Timer page already open in the browser keeps its old state (including its control token) and is not reloaded automatically | Companion serves module HTTP routes through `handleHttpRequest` and has no way to reload a browser tab; not checked in a live Companion | [M1](#m1-saving-the-connection-settings-in-lan-mode-cuts-off-the-open-browser-timer-until-its-page-is-reloaded) |
| A2 | After a settings save, the browser Timer page does not carry its running state into the new session, so Companion's defaults (10:00, stopped) win and the phone remote must pair again | `lan-session.cjs` applies a sync only when the revision matches, and a new session starts at revision 0 with a new token; the web client's handling of a revision mismatch was not traced | [M1](#m1-saving-the-connection-settings-in-lan-mode-cuts-off-the-open-browser-timer-until-its-page-is-reloaded) |
| A3 | The connection's `/api` route is reachable without Companion-level authentication by any device that can reach Companion's web port | Companion's default setup has no admin password on the web UI or module HTTP endpoints; not checked live | [M2](#m2-one-malformed-speaker-slot-list-sent-to-the-lan-api-crashes-the-module) |
| A4 | A module process that throws an uncaught exception from a timer callback is terminated and then restarted by Companion | `@companion-module/base` 1.13.6 registers no `uncaughtException` handler and Node's default is to exit; the restart is Companion host behaviour | [M2](#m2-one-malformed-speaker-slot-list-sent-to-the-lan-api-crashes-the-module) |

## 📋 Issues

### Blocking

- [ ] [C1: The module's package.json is missing the template's Prettier setting](#c1-the-modules-packagejson-is-missing-the-templates-prettier-setting)
- [ ] [C2: There is no format script, so the code can't be formatted the standard way](#c2-there-is-no-format-script-so-the-code-cant-be-formatted-the-standard-way)
- [ ] [C3: Prettier is missing from the development dependencies](#c3-prettier-is-missing-from-the-development-dependencies)
- [ ] [C4: The module lists the banned keyword Stream Deck](#c4-the-module-lists-the-banned-keyword-stream-deck)

### Non-blocking

- [ ] [M1: Saving the connection settings in LAN mode cuts off the open browser Timer until its page is reloaded](#m1-saving-the-connection-settings-in-lan-mode-cuts-off-the-open-browser-timer-until-its-page-is-reloaded)
- [ ] [M2: One malformed speaker-slot list sent to the LAN API crashes the module](#m2-one-malformed-speaker-slot-list-sent-to-the-lan-api-crashes-the-module)
- [ ] [L1: OSC mode with a wrong IP or a stopped bridge stays on Waiting for Timer and never shows a failure](#l1-osc-mode-with-a-wrong-ip-or-a-stopped-bridge-stays-on-waiting-for-timer-and-never-shows-a-failure)
- [ ] [L2: The Advanced settings checkbox has no effect, and a typed Companion local IP is ignored unless it is ticked](#l2-the-advanced-settings-checkbox-has-no-effect-and-a-typed-companion-local-ip-is-ignored-unless-it-is-ticked)
- [ ] [L3: Send message and Speaker name text is parsed for variables twice](#l3-send-message-and-speaker-name-text-is-parsed-for-variables-twice)
- [ ] [L4: Variables appear in Companion's variable list with their raw IDs as names](#l4-variables-appear-in-companions-variable-list-with-their-raw-ids-as-names)
- [ ] [N1: Load and start speaker slot presets are never generated](#n1-load-and-start-speaker-slot-presets-are-never-generated)
- [ ] [N2: Upgrade scripts are an inline empty array instead of a dedicated upgrades file](#n2-upgrade-scripts-are-an-inline-empty-array-instead-of-a-dedicated-upgrades-file)
- [ ] [N3: The source is minified one-liners in a single class](#n3-the-source-is-minified-one-liners-in-a-single-class)
- [ ] [NR1: Plan the move to companion-module/base 1.14 or 2.x](#nr1-plan-the-move-to-companion-modulebase-114-or-2x)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: The module's package.json is missing the template's Prettier setting

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/package.json)

**What goes wrong:** Anyone formatting the module's code gets their editor's or Prettier's defaults instead of the shared Companion style, so formatting differs between contributors and from other modules.

**Why it happens:** The template's `package.json` points Prettier at the shared Companion config with a top-level `prettier` field. The module's `package.json` has no such field.

**Evidence:**

```text
Expected (template): "prettier": "@companion-module/tools/.prettierrc.json"
Found (module):      no "prettier" field
```

**Fix:** add the field from the template.

```json
"prettier": "@companion-module/tools/.prettierrc.json"
```

### C2: There is no format script, so the code can't be formatted the standard way

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-10`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/package.json#L7-L10)

**What goes wrong:** A contributor running `yarn format` gets an error, because the script every Companion module has is missing.

**Why it happens:** The template's `scripts` block has `"format": "prettier -w ."`. The module's `scripts` block has only `package` and `test`.

**Evidence:**

```json
// package.json:7-10
"scripts": {
  "package": "companion-module-build",
  "test": "node --test tests/lan.test.cjs tests/compatibility.test.cjs"
},
```

**Fix:** add the template's format script.

```json
"format": "prettier -w ."
```

### C3: Prettier is missing from the development dependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:19-21`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/package.json#L19-L21)

**What goes wrong:** Even with the format script and setting in place, `yarn format` can't run, because Prettier isn't installed with the module.

**Why it happens:** The template lists `prettier` in `devDependencies`. The module lists only `@companion-module/tools`.

**Evidence:**

```json
// package.json:19-21
"devDependencies": {
  "@companion-module/tools": "2.8.0"
},
```

**Fix:** add Prettier to the development dependencies (the template uses `"prettier": "^3.7.4"`), then run `yarn install` to update `yarn.lock`.

### C4: The module lists the banned keyword Stream Deck

- **Source:** 🤖 validate-template (MAN-KEYWORD)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:33`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/companion/manifest.json#L33)

**What goes wrong:** The module would show up in Companion's connection search for "Stream Deck", which says nothing about what the module controls and makes search results less useful for every user.

**Why it happens:** Keywords should describe the device or software the module controls. "Stream Deck" is a banned, low-value keyword because every Companion module is used with Stream Decks.

**Evidence:**

```json
// companion/manifest.json:33
"Stream Deck"
```

**Fix:** remove `"Stream Deck"` from the `keywords` list in `companion/manifest.json`.

## 🟡 Medium

### M1: Saving the connection settings in LAN mode cuts off the open browser Timer until its page is reloaded

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-module.cjs:5`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/lan-module.cjs#L5), [`src/lan-session.cjs:4`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/lan-session.cjs#L4), [`src/lan-session.cjs:13-14`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/lan-session.cjs#L13-L14), [`web/lan-client.js:6`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/web/lan-client.js#L6)

**What goes wrong:** A user runs the connection in "Timer en navegador por red local" mode, with the Timer page open in a browser and a speaker countdown running at 07:32. They open the connection settings, change "Idioma / Language" from Español to English, and save. From then on the browser Timer's status badge shows "Vinculación no válida" and doesn't recover by itself. Companion's copy of the timer resets to 10:00, so the Start, Pause, Reset, +1 min and duration buttons drive that fresh state, which no longer reaches the speaker display. The `time` variable and the "Timer connected" feedback stop following the display, and the phone remote paired by QR code gets errors too. Only reloading the Timer page and pairing the phone again restores control. The connection status stays green ("Timer disponible en la red local") the whole time, so nothing in Companion shows that the link is broken. The same happens after any Companion or module restart.

**Why it happens:** Every settings save in LAN mode creates a brand-new session. That gives it a new random control token and no owner, and throws away the clock state. The browser page claims ownership only once, when it first loads. After that it keeps syncing with its old client id and old token, which the new session rejects with "403 Vinculación no válida". The page only writes that error into its badge and keeps retrying with the same stale token; it never claims ownership again.

**Evidence:**

```js
// src/lan-module.cjs:5
async configUpdated(config){...await this.destroy();this.config={language:'es',...config};this.lan=new Session();this.catalog=[];this.state={connected:true,running:false,time:'10:00',...};...}
// src/lan-session.cjs:4
constructor(){this.state=C.defaults();this.revision=0;...this.token=crypto.randomBytes(32).toString('hex');this.owner=null;...}
// src/lan-session.cjs:13-14
const owner=body.client===this.owner&&this.owner!==null;
if(!owner&&body.control!==this.token)return {status:403,body:{error:'Vinculación no válida'}};
// web/lan-client.js:6
async function tick(){...try{if(!control){const d=await api({op:'owner',client});control=d.control;save(d);}else{...save(await api({op:'sync',client,...}));}}catch(e){const b=document.querySelector('#lan-status');if(b)b.textContent=e.message;}finally{busy=false;setTimeout(tick,250);}}
```

**Fix:** keep the existing session when the settings are saved in LAN mode, and make the browser page re-claim ownership when it is rejected.

- In `configUpdated()`, create the session only when there isn't one (`if(!this.lan)this.lan=new Session();`), and don't reset `this.state` and `this.catalog` in that case.
- In `web/lan-client.js`, when a sync returns 403, set `control=''` (and `revision=-1`) so the next tick claims ownership again with `op:'owner'` and pushes its local state.

### M2: One malformed speaker-slot list sent to the LAN API crashes the module

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-session.cjs:15`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/lan-session.cjs#L15), [`src/lan-module.cjs:5-7`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/lan-module.cjs#L5-L7)

**What goes wrong:** When no Timer page has synced in the last 10 seconds, anyone on the network can claim the Timer session with one request to the connection's `/api` URL. If they then send a speaker-slot list containing an empty entry (`presets:[null]`), the module crashes about a quarter of a second later. Companion shows the connection as crashed or restarting, every button stops working until it restarts, and the restart starts a new session (see [M1](#m1-saving-the-connection-settings-in-lan-mode-cuts-off-the-open-browser-timer-until-its-page-is-reloaded)). The same crash happens in normal use if the Timer page's own saved speaker-slot list in the browser gets corrupted.

**Why it happens:** The session stores the speaker-slot and message lists the browser sends without checking each entry. Four times a second the module turns that list into its presets, reading `p.id` and `p.name` from every entry, which throws for an empty entry. The first failure, inside the HTTP request, is caught and answered with an error, but the bad list is already stored. The next timer tick throws with no error handler, and `@companion-module/base` 1.13.6 installs no handler for uncaught errors, so the process exits.

**Evidence:**

```js
// src/lan-session.cjs:15
if(Array.isArray(body.presets))this.presets=body.presets.slice(0,200);if(Array.isArray(body.messages))this.messages=body.messages.slice(0,30);
// src/lan-module.cjs:7 (updateLAN)
const catalog=s.presets.map(p=>({id:p.id,name:p.name,day:p.day,session:p.session}))...
// src/lan-module.cjs:5
this.lanTick=setInterval(()=>this.updateLAN(),250)
```

**Fix:** validate each entry before storing it, and stop one bad tick from crashing the module.

- In the session's request handler, accept an entry only when it is an object with a string `id` of at most 100 characters and a non-empty string `name`, with no duplicate ids (messages also need a string `text`), the same rules `web/06-timer-companion-pages.js` already uses. Reject the sync with a 400 when any entry fails.
- Wrap the body of the 250 ms timer callback in `try/catch` and log the error.

## 🟢 Low

### L1: OSC mode with a wrong IP or a stopped bridge stays on Waiting for Timer and never shows a failure

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:14`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/module.js#L14)

**What goes wrong:** A user picks "Timer instalado (OSC)" and types the wrong "Timer computer IP" (for example 192.168.1.50 instead of .51), or the bridge isn't running. The connection status stays on "Esperando Timer / Waiting for Timer" forever and never turns red, so it looks as if the connection is still coming up.

**Why it happens:** The module only flags a failure when the last reply from the Timer is more than 4 seconds old. Until the Timer has replied at least once there is no "last reply" time, so the check never fires.

**Fix:** record when the settings were applied (e.g. `this.startedAt=Date.now()`). If no `connected` message has arrived within a few seconds, set the status to `ConnectionFailure` ("No Timer feedback") and keep sending the periodic presets request.

### L2: The Advanced settings checkbox has no effect, and a typed Companion local IP is ignored unless it is ticked

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/lan-module.cjs:4`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/lan-module.cjs#L4), [`src/module.js:7-8`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/module.js#L7-L8)

**What goes wrong:** A user picks "Timer instalado (OSC)" under "Conexión Timer". The "Companion local IP" and "Feedback receive port" fields appear straight away, whether or not "Ajustes avanzados / Advanced settings" is ticked. The user types 192.168.1.20 into "Companion local IP" and saves. Because Advanced is unticked, the module quietly listens on 0.0.0.0 (or 127.0.0.1 when the Timer IP starts with 127.) instead of the address they typed, and nothing on screen says the value was ignored. Separately, the "Conexión Timer" dropdown and its choices are only in Spanish, while every other field is bilingual.

**Why it happens:** The LAN wrapper replaces each OSC field's visibility rule with "show when transport is OSC", which overwrites the "show when Advanced is ticked" rule the two advanced fields had. When the settings are applied, the module still discards the local IP unless Advanced is ticked.

**Fix:** combine the two conditions instead of replacing one: when a field already has an `isVisibleExpression`, use `(${f.isVisibleExpression}) && $(options:transport) === 'osc'`. Also give the "Conexión Timer" field and its choices the same Spanish / English labels as the other fields.

### L3: Send message and Speaker name text is parsed for variables twice

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:34`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/module.js#L34)

**What goes wrong:** Mostly invisible. Companion already replaces variables in the "Texto / Text" field before the action runs, and the module then replaces them again. If a variable's value itself contains text like `$(internal:time_hms)` (for example a speaker name copied from another variable), that text is expanded a second time, so the display shows something other than the variable's actual value.

**Why it happens:** The option is declared with `useVariables: true`, and the callback still calls `parseVariablesInString`, which `@companion-module/base` 1.13.6 marks as deprecated ("Companion now handles this for you"). The module has no local variables that would need the second pass.

**Fix:** use `String(e.options.value)` directly in the "message" / "title" callback and remove the `ctx.parseVariablesInString` call.

### L4: Variables appear in Companion's variable list with their raw IDs as names

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:31`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/module.js#L31)

**What goes wrong:** In the connection's variable list, users see names like "seconds", "preset_count", "message_preset_count" and "connected" instead of readable descriptions such as "Remaining time (seconds)" or "Number of saved speaker slots", in a module that otherwise offers a Spanish / English UI.

**Why it happens:** Each variable definition uses its ID as its display name.

**Fix:** give each variable a readable name through `this.t(es,en)`, e.g. `{variableId:'seconds',name:this.t('Tiempo restante (segundos)','Remaining time (seconds)')}`.

## 💡 Nice to Have

### N1: Load and start speaker slot presets are never generated

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:49`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/module.js#L49)

**What goes wrong:** The Presets tab offers a "Prepare" button for each speaker slot but no "Start" button, although the code has a label ("Iniciar " / "Start ") and an icon for one. Users who want a one-press load-and-start button have to build it from the "Cargar e iniciar intervención / Load and start speaker slot" action. If leaving it out was deliberate, there is no visible effect.

**Why it happens:** The preset loop runs over `['preset']` only, so every `'preset/start'` branch inside it is unreachable.

**Fix:** add `'preset/start'` to the loop's list to generate the start presets, or remove the loop and the unreachable branches.

### N2: Upgrade scripts are an inline empty array instead of a dedicated upgrades file

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:1`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/main.js#L1)

**What goes wrong:** No visible effect today. When a future release renames an action, option or feedback, there is no upgrades file to add a script to, which makes it easier to forget one and break users' existing buttons.

**Why it happens:** `runEntrypoint` is given a literal `[]` instead of the upgrade-script array the v1 JS template exports from `src/upgrades.js`.

**Fix:** create `src/upgrades.js` exporting `module.exports = []`, and pass `require('./upgrades.js')` to `runEntrypoint`.

### N3: The source is minified one-liners in a single class

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/module.js:30-51`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/src/module.js#L30-L51)

**What goes wrong:** No visible effect. Every action, feedback, preset and variable definition sits on a handful of very long lines (`src/module.js`, `src/lan-module.cjs`, `src/osc.cjs`, `src/remote.cjs`), which makes the module hard for other maintainers and reviewers to read, fix or extend, and lets bugs like [N1](#n1-load-and-start-speaker-slot-presets-are-never-generated) hide.

**Why it happens:** The code is committed in a compressed style, with every definition built inside one `define()` method instead of the template's separate actions, feedbacks, presets and variables files.

**Fix:** commit readable, formatted source (run Prettier once [C1](#c1-the-modules-packagejson-is-missing-the-templates-prettier-setting)–[C3](#c3-prettier-is-missing-from-the-development-dependencies) are fixed), and split the definitions into `actions.js`, `feedbacks.js`, `presets.js`, `variables.js` and `upgrades.js` following the `companion-module-template-js` layout.

## 🔮 Next Release

### NR1: Plan the move to companion-module/base 1.14 or 2.x

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:17`](https://github.com/bitfocus/companion-module-eventspro-toolspro-timer/blob/132546396cfc1533c14a9a71271aa84994b812bb/package.json#L17)

**What goes wrong:** No problem today. The module is on `@companion-module/base` 1.13.6 (Companion 4.1+). Version 1.14 adds the automated config layout, and v2.0 / 2.1 (Companion 4.3+ / 5.0+) add expression support and the API that new Companion releases are built around.

**Why it happens:** `package.json` pins `"@companion-module/base": "1.13.6"`.

**Fix:** in a later release, upgrade to base 1.14, or migrate to v2.x following the Companion v1-to-v2 migration guide. On v2, preset text such as `$(label:time)` and the deprecated parse calls change, so test the presets after migrating.

## 📝 Additional Notes

- First release of this module: there is no previous tag to diff against, so the whole module was reviewed and every finding is classified 🆕 NEW.
- `yarn install --immutable` and `yarn package` both succeeded.
