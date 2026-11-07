# Review: companion-module-jozeemedia-jcounter v3.0.1 (follow-up to the v3.0.0 review)

| Field | Value |
| --- | --- |
| **Module** | `companion-module-jozeemedia-jcounter` |
| **Scope** | `tag` (`v2.0.1..v3.0.1`) |
| **Version** | v3.0.1 |
| **Release** | Update — last published v2.0.1 |
| **API** | 1 (base 1.15.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `89da037` (2026-11-01) |
| **Review commit** | [`c831484`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/tree/c83148454fe929a22877f812447c62fee80d9117) |
| **Follow-up to** | [v3.0.0 review](review-jozeemedia-jcounter-v3.0.0-20261030-003407.md) (2026-10-30; v3.0.0 was never published) |
| **Review date** | 2026-11-06 |

## Verdict: ✅ Approved

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Non-blocking

- [ ] [L1: Buttons silently do nothing when the local feedback port is already in use](#l1-buttons-silently-do-nothing-when-the-local-feedback-port-is-already-in-use)
- [ ] [L2: The connection variable still says ONLINE after saving settings for a J-COUNTER that never answers](#l2-the-connection-variable-still-says-online-after-saving-settings-for-a-j-counter-that-never-answers)
- [ ] [L3: The v2 upgrade warning misses some upgraded connections and repeats for others](#l3-the-v2-upgrade-warning-misses-some-upgraded-connections-and-repeats-for-others)
- [ ] [L4: Timer SET TITLE parses its variables a second time with a deprecated call](#l4-timer-set-title-parses-its-variables-a-second-time-with-a-deprecated-call)
- [ ] [L5: The README and tools folder still carry one-off review-submission steps](#l5-the-readme-and-tools-folder-still-carry-one-off-review-submission-steps)
- [ ] [N1: A feedback-port conflict now shows a raw connection error instead of Feedback port conflict](#n1-a-feedback-port-conflict-now-shows-a-raw-connection-error-instead-of-feedback-port-conflict)
- [ ] [N2: The Timer START and PAUSE presets don't light up while the timer runs](#n2-the-timer-start-and-pause-presets-dont-light-up-while-the-timer-runs)
- [ ] [NR1: `.gitignore` is missing template entries](#nr1-gitignore-is-missing-template-entries)
- [ ] [NR2: Non-English text in `README-HE-REVIEW-FIXES.txt`](#nr2-non-english-text-in-readme-he-review-fixestxt)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🟢 Low

### L1: Buttons silently do nothing when the local feedback port is already in use

- **Source:** 🔎 QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.js:67-70`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/main.js#L67-L70), [`src/main.js:103-104`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/main.js#L103-L104), [`companion/HELP.md:32`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/companion/HELP.md#L32)

**What goes wrong:** A user adds a second J-COUNTER connection for a second J-COUNTER computer and leaves "Local feedback UDP port" at the default 7803, or another app on the Companion computer already uses UDP 7803. The connection shows "OSC: bind EADDRINUSE 0.0.0.0:7803" (see [A2](#-assumptions-to-confirm)), and every button on it (Timer START, BLACKOUT, NDI START / STOP, …) does nothing. Nothing in the log says the command was dropped. In v2.0.1, commands still reached J-COUNTER in this situation and only the feedback was lost. The help page still describes that old behaviour ("Buttons work, but feedback does not: verify the feedback UDP port … is not used by another process"), so users look in the wrong place.

**Why it happens:** v3 sends its commands through the same socket it opens on the local feedback port. The module marks that socket ready only once the port opens, and the send helper quietly returns while the socket isn't ready. When the port is taken, the socket never becomes ready, so every command is dropped. v2.0.1 sent commands with Companion's built-in `oscSend()`, which doesn't depend on the feedback port. The code is the same as in v3.0.0; the earlier review didn't raise it.

**Evidence:**

```js
// src/main.js:67-70
  sendOsc(address, args = []) {
    const host = this.config?.host
    const port = Number(this.config?.port) || 7802
    if (!host || !this.osc || !this.socketReady) return
// src/main.js:103-104
    this.osc.on('ready', () => {
      this.socketReady = true
```

**Fix:** tell users what is really wrong, and why a button did nothing.

- Change [`companion/HELP.md:32`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/companion/HELP.md#L32), for example: "If the connection shows OSC: bind EADDRINUSE, another app or another J-COUNTER connection uses the Local feedback UDP port. Give each connection its own port. No commands are sent until this is fixed."
- Add a `tooltip` to the "Local feedback UDP port" config field saying each connection needs its own port.
- Log a warning in `sendOsc()` when a command is dropped because the socket isn't ready.
- Optionally, send commands with `this.oscSend(host, port, address, args)` so buttons keep working even when the feedback port can't be opened.

See [N1](#n1-a-feedback-port-conflict-now-shows-a-raw-connection-error-instead-of-feedback-port-conflict) for the status message in the same situation.

### L2: The connection variable still says ONLINE after saving settings for a J-COUNTER that never answers

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.js:284-290`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/main.js#L284-L290), [`src/main.js:118-123`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/main.js#L118-L123)

**What goes wrong:** A user has a working connection, so a button showing the "J-Counter OSC connection" variable (`connection`) says ONLINE. They change "J-Counter computer IP address" from 192.168.1.20 to 192.168.1.99 (a wrong or offline machine) and save. After 8 seconds the connection status turns red with "No reply from J-COUNTER. Check the IP address, port and OSC service.", but the button still says ONLINE (see [A1](#-assumptions-to-confirm)). The BLACKOUT, MESSAGE and NDI variables also keep their old values (for example "BLACKOUT state" = ON), and the BLACKOUT, MESSAGE and NDI feedbacks stay lit. This lasts until a J-COUNTER at the new address answers. The connection status itself is right; only the module's own variables and feedbacks are stale.

**Why it happens:** When settings are saved, the module first rebuilds its definitions and pushes all variable values, while its "connected", blackout, message and NDI state still hold the old connection's values. Only after that does it close the old socket, which resets that state to OFFLINE / OFF without pushing the variables or re-checking the feedbacks. The later "No reply from J-COUNTER" check only changes the connection status, so nothing corrects the stale values. The same order was in v3.0.0.

**Evidence:**

```js
// src/main.js:284-290
  async configUpdated(config) {
    this.config = config
    this.timers = []
    this.updateDefinitions()   // ends with UpdateVariables.update(this), old state still set
    this.updateStatus(InstanceStatus.Connecting)
    this.startUdp()            // calls closeUdp(): resets isConnected, blackoutActive, … silently
  }
// src/main.js:118-123
        } else if (!this.isConnected && !this.noReplyReported &&
            this.connectStarted > 0 && now - this.connectStarted > 8000) {
          this.noReplyReported = true
          this.updateStatus(InstanceStatus.ConnectionFailure,
            'No reply from J-COUNTER. Check the IP address, port and OSC service.')
        }
```

**Fix:** clear the old state before pushing the variables, then re-check the feedbacks.

```js
async configUpdated(config) {
  this.config = config
  this.timers = []
  this.closeUdp()
  this.updateDefinitions()
  this.checkFeedbacks()
  this.updateStatus(InstanceStatus.Connecting)
  this.startUdp()
}
```

### L3: The v2 upgrade warning misses some upgraded connections and repeats for others

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.js:33-37`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/main.js#L33-L37), [`src/upgrades.js:1-7`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/upgrades.js#L1-L7)

**What goes wrong:** A user moves an existing v2.0.1 connection to v3.0.1. Buttons that use the old "1 - Timers Operations", "2 - Timer Color", "3 - Messages" or "4 - Presets" actions, or the "Timer 1 Color" / "Timer 2 Color" feedbacks, do nothing and stop changing colour until they are rebuilt (see [A5](#-assumptions-to-confirm)). That part is intentional and now documented in [`companion/HELP.md:3`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/companion/HELP.md#L3), [`README.md:26-28`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/README.md#L26-L28) and [`CHANGELOG.md:10`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/CHANGELOG.md#L10). The new log warning, though, only appears when the stored "Feedback Port" is still the number that v2.0.1 saved by default (7803, see [A4](#-assumptions-to-confirm)). A v2 user who ever typed into that field (for example 9000) has a text value and gets no warning. A user who never touched it gets the warning on every restart, even after rebuilding all their buttons.

**Why it happens:** v3 replaces every v2 action and feedback, and `src/upgrades.js` is deliberately empty: the maintainer declined automatic mapping, which is fine for an intentional breaking release. The warning guesses that a connection came from v2 from the type of one config value, not from whether it still has v2 buttons. That check follows the v3.0.0 review's own L2 suggestion ("for example a numeric `feedbackPort`"), which turns out to be an unreliable signal.

**Evidence:**

```js
// src/main.js:33-37
    // A v2 connection needs an explicit selection of v3.0.1 and newly configured actions.
    // Never silently reinterpret old v2 actions: they use a different OSC protocol.
    if (typeof config?.feedbackPort === 'number') {
      this.log('warn', 'J-COUNTER v3 uses a new OSC protocol. Existing v2 buttons/feedbacks must be rebuilt or kept on module v2.0.1.')
    }
```

**Fix:** detect the v2 buttons themselves, and show the warning once.

- Add one upgrade script to `src/upgrades.js`. It looks for the v2 IDs (`trigger_oprations`, `trigger_colors`, `trigger_messages`, `trigger_Presets`, `ChannelState`, `ChannelState2`) in `props.actions` / `props.feedbacks`. When it finds any and `props.config` isn't `null`, it returns `updatedConfig: { ...props.config, hasV2Buttons: true }`.
- In `init()`, log the warning when `config.hasV2Buttons` is set, then clear it with `this.saveConfig({ ...config, hasV2Buttons: false })`.
- Optionally, map the unambiguous v2 commands in the same script: `trigger_messages` `2messageone`–`2messagesix` → `message` show with template 1–6, `2hidemessage` → `message` hide, and `trigger_oprations` `ringnow` → `play_sound`.

### L4: Timer SET TITLE parses its variables a second time with a deprecated call

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:56-66`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/actions.js#L56-L66)

**What goes wrong:** Users see no difference today. A user types `$(internal:custom_speaker)` into the Title field of "Timer: SET TITLE". Companion already replaces it with the value (for example "Anna") before the action runs, and then the module asks Companion to parse "Anna" again. Only a variable whose value itself contains `$(...)` text gets expanded a second time. The call is deprecated in the installed base and has to be removed when the module moves to API 2.

**Why it happens:** The Title field sets `useVariables: true`, so Companion resolves its variables before it calls the action (see [A3](#-assumptions-to-confirm)). The callback then still calls `self.parseVariablesInString()`, which `@companion-module/base` 1.15.1 marks `@deprecated Companion now handles this for you, for actions and feedbacks` (`node_modules/@companion-module/base/dist/module-api/base.d.ts:121-131`). The v3.0.0 review's N2 suggested adding this call "to support older Companion versions"; that part of the advice doesn't apply to a module built with base 1.15.1.

**Evidence:**

```js
// src/actions.js:58-62
      options: [timerOption(self),
        { type: 'textinput', id: 'title', label: 'Title', default: 'TIMER', useVariables: true }],
      callback: async (action) => {
        const expanded = await self.parseVariablesInString(String(action.options.title ?? ''))
        const title = String(expanded).trim()
```

**Fix:** keep `useVariables: true` and drop the parse call. Then change the "timer title expands Companion variables" test ([`tests/review-fixes.test.js:119-125`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/tests/review-fixes.test.js#L119-L125)) to pass an already-resolved title, because it currently relies on a stubbed `parseVariablesInString`.

```js
callback: (action) => {
  const title = String(action.options.title ?? '').trim()
  if (title.length >= 1 && title.length <= 128) self.sendTimer(action.options.timer, 'title', [title])
  else self.log('warn', 'Timer title must contain 1 to 128 characters')
},
```

### L5: The README and tools folder still carry one-off review-submission steps

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:15`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/README.md#L15), [`README.md:24`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/README.md#L24), [`tools/PREPARE-FOR-REVIEW.cmd`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/tools/PREPARE-FOR-REVIEW.cmd)

**What goes wrong:** Companion users see nothing. Anyone who opens the repository on GitHub finds instructions for this one-time submission instead of module documentation. The README says to "Regenerate and commit `yarn.lock` using `corepack yarn install` before the first build", which is already done, and tells readers to "tag the tested commit as `v3.0.1` and submit it in the Bitfocus Developer Portal". `tools/PREPARE-FOR-REVIEW.cmd` is a Windows helper for the same one-time submission. This confuses later maintainers and contributors.

**Why it happens:** The files that prepared the v3.0.1 resubmission were uploaded together with the module source. `README-HE-REVIEW-FIXES.txt` belongs to the same set and is covered by [NR2](#nr2-non-english-text-in-readme-he-review-fixestxt).

**Fix:** delete `tools/PREPARE-FOR-REVIEW.cmd`. In `README.md`, replace lines 15 and 24 with plain build instructions (`corepack yarn install`, `corepack yarn package`) and drop the tagging and portal-submission steps. Keep the "Upgrading from J-COUNTER 2" section.

## 💡 Nice to Have

### N1: A feedback-port conflict now shows a raw connection error instead of Feedback port conflict

- **Source:** 🔎 protocol reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.js:127-135`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/main.js#L127-L135)

**What goes wrong:** In the same situation as [L1](#l1-buttons-silently-do-nothing-when-the-local-feedback-port-is-already-in-use) (UDP 7803 already in use, see [A2](#-assumptions-to-confirm)), v2.0.1 showed a Bad Config status "Feedback port conflict" and logged "Selected feedback port 7803 is already in use." v3.0.1 shows a Connection Failure status "OSC: bind EADDRINUSE 0.0.0.0:7803". That points users at the network or the J-COUNTER computer, when the fix is to pick a different "Local feedback UDP port" in the connection settings.

**Why it happens:** The socket error handler treats every error the same way, as Connection failure with the raw error message. v2.0.1 checked for the "address already in use" error code and set Bad config with a readable message. The handler is the same as in v3.0.0.

**Fix:** in the error handler, show a readable Bad config status for a port conflict and keep Connection failure for everything else.

```js
// src/main.js, inside this.osc.on('error', …)
if (error.code === 'EADDRINUSE') {
  this.updateStatus(InstanceStatus.BadConfig, `Local feedback UDP port ${localPort} is already in use. Choose another port.`)
} else {
  this.updateStatus(InstanceStatus.ConnectionFailure, `OSC: ${error.message}`)
}
```

### N2: The Timer START and PAUSE presets don't light up while the timer runs

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:13-21`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/src/presets.js#L13-L21)

**What goes wrong:** A user drags "Timer 1: START" onto a button and starts the timer. The button keeps its fixed green whether timer 1 is running, paused or finished, so the operator can't tell the state from the START or PAUSE button. The module already has a "Timer is RUNNING" feedback that could show it.

**Why it happens:** The START, PAUSE and RESET presets are built with an empty feedback list, unlike the BLACKOUT, MESSAGE and NDI presets.

**Fix:** add the "Timer is RUNNING" feedback with an explicit style to the START preset (and optionally PAUSE), and give START a neutral base colour so the change is visible.

```js
feedbacks: op.id === 'start'
  ? [{ feedbackId: 'running', options: { timer: String(n) }, style: { bgcolor: combineRgb(23, 111, 86), color: white } }]
  : [],
```

## 🔮 Next Release

### NR1: `.gitignore` is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (still open from the v3.0.0 review's [C2](review-jozeemedia-jcounter-v3.0.0-20261030-003407.md#c2-gitignore-is-missing-five-template-entries))
- **File:** [`.gitignore:1-4`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/.gitignore#L1-L4)

**What goes wrong:** Build output can be committed by accident. Running `yarn package` creates `jozeemedia-jcounter-3.0.1.tgz` in the repository root, and nothing ignores it: `git status` lists it as untracked (`?? jozeemedia-jcounter-3.0.1.tgz`).

**Why it happens:** The module's `.gitignore` lists `node_modules/`, `pkg/`, `pkg.tgz` and `.yarn/`. `pkg.tgz` doesn't match the real package name, and the template's other entries are missing. v2.0.1 still had `package-lock.json` and `DEBUG-*`; the v3 rewrite dropped them.

**Validator message:** Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, DEBUG-*, /.yarn

**Evidence:** the module's `.gitignore` (lines 1-4) against the v1 template's `.gitignore`:

```text
# module .gitignore
node_modules/
pkg/
pkg.tgz
.yarn/

# template .gitignore
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

**Confirm by:** `diff .gitignore <template>/.gitignore`. Every template line must be present.

**Fix:** replace `.gitignore` with the template's six entries. Extra entries of the module's own are allowed.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### NR2: Non-English text in `README-HE-REVIEW-FIXES.txt`

- **Source:** 🤖 validate-template (NOT-ENGLISH)
- **Classification:** 🆕 NEW
- **File:** [`README-HE-REVIEW-FIXES.txt:4-29`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/README-HE-REVIEW-FIXES.txt#L4-L29)

**What goes wrong:** Everything in a Companion module must be in English, so that any maintainer or contributor can read it. This release adds a file at the repository root that is written almost entirely in Hebrew. It holds the release-preparation steps and the list of fixes for the v3.0.0 review, and other maintainers can't read it.

**Why it happens:** The file was uploaded together with the v3.0.1 fixes, next to `tools/PREPARE-FOR-REVIEW.cmd`. Only its title (lines 1-2) is in English.

**Validator message:** Everything in the module must be written in English (code comments, user-facing text, HELP.md, README.md, …). 22 lines are in another language: README-HE-REVIEW-FIXES.txt (22 lines: 4-5, 7, 9-17, 19-26, 28-29)

**Evidence:**

```text
// README-HE-REVIEW-FIXES.txt:4
תכולה: תיקוני דוח הבדיקה מ-30.10.2026 למודול jozeemedia-jcounter.
```

**Confirm by:** `git ls-files README-HE-REVIEW-FIXES.txt` at the tag, then read [`README-HE-REVIEW-FIXES.txt:4-29`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/README-HE-REVIEW-FIXES.txt#L4-L29).

**Fix:** remove the file from the repository: it was one-off preparation notes, and the fix list is already in [`CHANGELOG.md:3-10`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/c83148454fe929a22877f812447c62fee80d9117/CHANGELOG.md#L3-L10). If you want to keep it, translate it to English.

## 📝 Additional Notes

- v3.0.0 was never published, so this review's tag diff (`v2.0.1..v3.0.1`) covers both the v3.0.0 and the v3.0.1 changes. [L1](#l1-buttons-silently-do-nothing-when-the-local-feedback-port-is-already-in-use), [L2](#l2-the-connection-variable-still-says-online-after-saving-settings-for-a-j-counter-that-never-answers), [N1](#n1-a-feedback-port-conflict-now-shows-a-raw-connection-error-instead-of-feedback-port-conflict) and [N2](#n2-the-timer-start-and-pause-presets-dont-light-up-while-the-timer-runs) were already in the v3.0.0 code and were not raised in that review.
- `README-HE-REVIEW-FIXES.txt` says the new `yarn.lock` (C6) was left for you to generate. It was: the Yarn 4 lockfile from commit `79763b9` passes `yarn install --immutable`, and `yarn package` builds `jozeemedia-jcounter-3.0.1.tgz`.

### Follow-up on the v3.0.0 review

| v3.0.0 item | Status in v3.0.1 |
| --- | --- |
| C1: `.gitattributes` missing | Fixed: added, matches the template |
| C2: `.gitignore` missing entries | Still open: see [NR1](#nr1-gitignore-is-missing-template-entries) |
| C3: `.yarnrc.yml` missing | Fixed: matches `companion-module-template-js` |
| C4: source files at the root | Fixed: all six files are in `src/`, and `main` and the manifest `entrypoint` point there |
| C5: no `engines` | Fixed |
| C6: Yarn 1 and a stale lockfile | Fixed: `packageManager` is `yarn@4.12.0`, and the lockfile is a fresh Yarn 4 one |
| C7: `prettier` missing | Fixed |
| M1: stays red after one OSC error | Fixed: the error handler clears the connected flag, so the next J-COUNTER hello restores OK |
| M2: BLACKOUT, MESSAGE and NDI presets never light up | Fixed: the three preset feedbacks carry a `style` |
| L1: Connecting forever | Fixed: the status turns to "No reply from J-COUNTER…" after 8 seconds |
| L2: v2 buttons stop working | Addressed: mapping declined (acceptable) and a warning added; see [L3](#l3-the-v2-upgrade-warning-misses-some-upgraded-connections-and-repeats-for-others) for how far the warning reaches |
| L3: unsupported `affectedProperties` | Fixed: removed |
| N1: number fields sent as text | Fixed: values are rounded and clamped, and empty or invalid input is skipped with a warning |
| N2: title doesn't accept variables | Fixed: `useVariables: true`; see [L4](#l4-timer-set-title-parses-its-variables-a-second-time-with-a-deprecated-call) for the extra parse call |

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion keeps showing the last value a module set for a variable until the module sets a new one. It does not clear or re-derive module variables when the connection status changes to Connection failure | General Companion host behaviour; the reviewers' reproduction stubbed the base and osc modules, so the Companion side was not exercised | [L2](#l2-the-connection-variable-still-says-online-after-saving-settings-for-a-j-counter-that-never-answers) |
| A2 | Opening a UDP socket on a port that another process already holds fails with `EADDRINUSE` on every platform Companion runs on, including Windows. Two J-COUNTER connections (each its own process) on the same port conflict the same way | Reproduced on macOS with the module's own osc 2.4.5: a second `UDPPort` on the same port emitted `error` (bind EADDRINUSE) and never `ready`. Node's dgram does not set `reuseAddr` by default. Windows and cross-process runs were not tried | [L1](#l1-buttons-silently-do-nothing-when-the-local-feedback-port-is-already-in-use), [N1](#n1-a-feedback-port-conflict-now-shows-a-raw-connection-error-instead-of-feedback-port-conflict) |
| A3 | A Companion version too old to resolve `useVariables` text fields itself (module API before 1.13) refuses to load a package built with base 1.15.1, so no Companion that can run this build skips the variable parsing | The `@deprecated` note on `parseVariablesInString` in base 1.15.1 ("Companion now handles this for you, for actions and feedbacks"); Companion's API-version gate was not checked | [L4](#l4-timer-set-title-parses-its-variables-a-second-time-with-a-deprecated-call) |
| A4 | A v2.0.1 connection whose "Feedback Port" was never edited stores it as the number `7803` (the v2.0.1 default), and Companion stores a string once the user edits that text field | v2.0.1 declares `default: 7803` (a number) on a `textinput`; Companion's config storage was not checked | [L3](#l3-the-v2-upgrade-warning-misses-some-upgraded-connections-and-repeats-for-others) |
| A5 | After a connection moves from v2.0.1 to v3.0.1, Companion keeps buttons that use removed action or feedback IDs as non-working entries, and it runs upgrade scripts on imported buttons with `config` set to `null` | General Companion upgrade behaviour and the `CompanionStaticUpgradeProps` typing in base 1.15.1 (`config` is typed as the config or `null`); Companion's own upgrade runner was not checked | [L3](#l3-the-v2-upgrade-warning-misses-some-upgraded-connections-and-repeats-for-others) |
