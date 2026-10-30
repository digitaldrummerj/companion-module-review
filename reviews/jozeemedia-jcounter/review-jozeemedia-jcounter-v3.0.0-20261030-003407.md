# Review: companion-module-jozeemedia-jcounter v3.0.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-jozeemedia-jcounter` |
| **Scope** | `tag` (`v2.0.1..v3.0.0`) |
| **Version** | v3.0.0 |
| **Release** | Update — last published v2.0.1 |
| **API** | 1 (base 1.4.1, yarn.lock) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `76d25b2` (2026-10-11) |
| **Review commit** | [`8e0cf01`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/tree/8e0cf0124168c57b272613e9eb2b32d090e236be) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a user updates the module, Companion moves existing v2.0.1 connections to v3.0.0 and keeps buttons that use removed action or feedback IDs as non-working (unknown) entries | General Companion behaviour for module updates without upgrade scripts; not checkable from the module code | [L2](#l2-existing-v2-buttons-stop-working-after-the-upgrade) |
| A2 | A Companion number field can produce a decimal or empty/NaN value (for example a user typing 1.5) even though the option sets `step: 1` | Companion UI behaviour for number fields; `@companion-module/base` does not enforce `step` | [N1](#n1-decimal-or-empty-number-fields-are-sent-to-j-counter-as-text) |
| A3 | When Companion creates a button from a preset, a boolean feedback with no `style` gets no style. Companion does not fall back to the feedback definition's `defaultStyle`, so the button never changes appearance | The `CompanionPresetFeedback` typing in base 1.15.0 documents `style` as "the style effect of the feedback"; Companion's preset-to-button conversion was not checked | [M2](#m2-the-blackout-show-message-1-and-ndi-presets-never-light-up) |

## 📋 Issues

### Blocking

- [ ] [C1: Required `.gitattributes` file is missing](#c1-required-gitattributes-file-is-missing)
- [ ] [C2: `.gitignore` is missing five template entries](#c2-gitignore-is-missing-five-template-entries)
- [ ] [C3: Required `.yarnrc.yml` file is missing](#c3-required-yarnrcyml-file-is-missing)
- [ ] [C4: Source files sit at the module root instead of `src/`](#c4-source-files-sit-at-the-module-root-instead-of-src)
- [ ] [C5: `package.json` has no `engines` field](#c5-packagejson-has-no-engines-field)
- [ ] [C6: Module uses Yarn 1 instead of Yarn 4, and its lockfile is out of date](#c6-module-uses-yarn-1-instead-of-yarn-4-and-its-lockfile-is-out-of-date)
- [ ] [C7: `prettier` is missing from devDependencies](#c7-prettier-is-missing-from-devdependencies)

### Non-blocking

- [ ] [M1: Connection stays red after a single OSC error, even while J-COUNTER keeps answering](#m1-connection-stays-red-after-a-single-osc-error-even-while-j-counter-keeps-answering)
- [ ] [M2: The BLACKOUT, SHOW MESSAGE 1 and NDI presets never light up](#m2-the-blackout-show-message-1-and-ndi-presets-never-light-up)
- [ ] [L1: Status shows Connecting forever when J-COUNTER never answers](#l1-status-shows-connecting-forever-when-j-counter-never-answers)
- [ ] [L2: Existing v2 buttons stop working after the upgrade](#l2-existing-v2-buttons-stop-working-after-the-upgrade)
- [ ] [L3: The Timer display feedback declares a property API 1 ignores](#l3-the-timer-display-feedback-declares-a-property-api-1-ignores)
- [ ] [N1: Decimal or empty number fields are sent to J-COUNTER as text](#n1-decimal-or-empty-number-fields-are-sent-to-j-counter-as-text)
- [ ] [N2: The Timer SET TITLE action does not accept Companion variables](#n2-the-timer-set-title-action-does-not-accept-companion-variables)

## 🔴 Critical

### C1: Required `.gitattributes` file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without the template's `.gitattributes`, line endings depend on each contributor's git settings. A Windows checkout can commit CRLF files, which produces noisy diffs and formatting churn.

**Why it happens:** The JS v1 template tracks a `.gitattributes` file that forces LF line endings. This repository does not have one.

**Expected (template):**

```text
* text=auto eol=lf
```

**Fix:** copy `.gitattributes` from the template into the repository root.

### C2: `.gitignore` is missing five template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/.gitignore)

**What goes wrong:** Build output and tool files can be committed by accident. Running `yarn package` creates `jozeemedia-jcounter-3.0.0.tgz` in the repository root, and nothing ignores it.

**Why it happens:** The module's `.gitignore` has `node_modules/`, `pkg/`, `pkg.tgz` and `.yarn/`, but not the template's other entries.

**Expected vs found:** missing `package-lock.json`, `/pkg`, `/*.tgz`, `DEBUG-*`, `/.yarn`.

**Fix:** replace `.gitignore` with the template version:

```text
node_modules/
package-lock.json
/pkg
/*.tgz
DEBUG-*
/.yarn
```

### C3: Required `.yarnrc.yml` file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.yarnrc.yml` (missing)

**What goes wrong:** Yarn 4 (see [C6](#c6-module-uses-yarn-1-instead-of-yarn-4-and-its-lockfile-is-out-of-date)) has no project settings, so it would default to Plug'n'Play instead of a `node_modules` folder, and it would run install scripts from dependencies.

**Why it happens:** The template ships a `.yarnrc.yml` with the settings every module uses. This repository has none.

**Expected (template):**

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

**Fix:** copy `.yarnrc.yml` from `companion-module-template-js` into the repository root.

### C4: Source files sit at the module root instead of `src/`

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW
- **File:** [`main.js`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/main.js), [`actions.js`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/actions.js), [`feedbacks.js`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/feedbacks.js), [`presets.js`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/presets.js), [`upgrades.js`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/upgrades.js), [`variables.js`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/variables.js)

**What goes wrong:** The module's layout differs from every other module built from the template, which makes it harder for other maintainers to find the code and to troubleshoot it.

**Why it happens:** The template keeps all source under `src/`. This module keeps its six source files at the repository root.

**Fix:** move the six files into `src/`, then point `package.json` `main` at `src/main.js` and the manifest's `runtime.entrypoint` at `../src/main.js`.

```json
// package.json
"main": "src/main.js",
// companion/manifest.json
"entrypoint": "../src/main.js"
```

### C5: `package.json` has no `engines` field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/package.json)

**What goes wrong:** Nothing tells a contributor or the build which Node.js and Yarn versions the module needs, so a build on the wrong toolchain fails with confusing errors.

**Why it happens:** The template declares `engines`; this `package.json` doesn't.

**Fix:** add the template's `engines` block.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
}
```

### C6: Module uses Yarn 1 instead of Yarn 4, and its lockfile is out of date

- **Source:** 🤖 validate-template (PKG-YARN)
- **Classification:** 🆕 NEW
- **File:** [`package.json:22`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/package.json#L22), [`yarn.lock`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/yarn.lock)

**What goes wrong:** A fresh install doesn't match the committed lockfile, so builds aren't reproducible. The committed `yarn.lock` still pins `@companion-module/base` 1.4.1, while `package.json` asks for `^1.12.0`. A clean `yarn install` resolves base 1.15.0 and rewrites `yarn.lock` (34 lines added, 109 removed).

**Why it happens:** `packageManager` is `yarn@1.22.22`, and the lockfile is a Yarn 1 lockfile from an older dependency set that was never regenerated when `package.json` changed. The template uses Yarn 4.

**Expected vs found:** expected `packageManager` starting with `yarn@4` (template: `yarn@4.12.0`); found `yarn@1.22.22`.

**Fix:** switch to Yarn 4, add `.yarnrc.yml` ([C3](#c3-required-yarnrcyml-file-is-missing)), then delete `yarn.lock`, run `yarn install`, and commit the regenerated Yarn 4 lockfile.

```json
"packageManager": "yarn@4.12.0"
```

### C7: `prettier` is missing from devDependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/package.json)

**What goes wrong:** The module's own `yarn format` script calls `prettier -w .`, but prettier isn't a declared dependency, so the script depends on whatever happens to be installed.

**Why it happens:** The template lists `prettier` in `devDependencies`; this module doesn't.

**Fix:** add prettier as a dev dependency.

```json
"devDependencies": {
	"@companion-module/tools": "~2.8.0",
	"prettier": "^3.7.4"
}
```

## 🟡 Medium

### M1: Connection stays red after a single OSC error, even while J-COUNTER keeps answering

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:111-114`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/main.js#L111-L114), [`main.js:172-177`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/main.js#L172-L177)

**What goes wrong:** A user has a working connection (status OK). Then a single OSC socket error happens, for example a stray non-OSC packet arrives on the "Local feedback UDP port" (7803), or one send fails during a short Wi-Fi drop. The status changes to "Connection failure – OSC: …" and stays there. J-COUNTER keeps answering, buttons keep working and variables keep updating, but the Connections page reports the connection as failed until the user saves the config or J-COUNTER goes silent for more than 8 seconds.

**Why it happens:** The socket error handler sets the status to Connection failure but leaves the module's "connected" flag set. The handler for J-COUNTER's regular hello message only sets the status back to OK when that flag is off, so later hellos never restore it. The osc library reports any packet it can't decode, and any failed send, as a socket error, so one bad packet is enough.

**Evidence:**

```js
// main.js:111-114
this.osc.on('error', (error) => {
  this.log('error', `OSC socket error: ${error.message}`)
  this.updateStatus(InstanceStatus.ConnectionFailure, `OSC: ${error.message}`)
})
// main.js:172-177
this.lastSeen = Date.now()
if (!this.isConnected) {
  this.isConnected = true
  this.updateStatus(InstanceStatus.Ok)
  UpdateVariables.update(this)
}
```

**Fix:** restore OK on the next valid hello. Either remember the last status you set and call `updateStatus(InstanceStatus.Ok)` whenever it isn't OK, or set `this.isConnected = false` in the error handler so the next hello goes through the reconnect branch. Decode errors from stray packets can also be logged at `warn` without changing the status at all.

### M2: The BLACKOUT, SHOW MESSAGE 1 and NDI presets never light up

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`presets.js:60`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/presets.js#L60), [`presets.js:66`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/presets.js#L66), [`presets.js:78`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/presets.js#L78)

**What goes wrong:** A user drags the "BLACKOUT / RESTORE", "SHOW MESSAGE 1" or "NDI START / STOP" preset onto a button. Each preset includes its state feedback ("Global BLACKOUT is active", "MESSAGE is currently shown", "NDI output is running"), but when J-COUNTER reports blackout on, a message shown or NDI running, the button stays grey (57, 68, 81). The operator can't see the state on the button without opening each one and setting a style by hand.

**Why it happens:** These are boolean feedbacks. In a preset, a boolean feedback only changes the button when the preset entry carries its own `style`; the feedback's `defaultStyle` applies when a user adds the feedback in the editor (see [A3](#-assumptions-to-confirm)). All three preset entries are `{ feedbackId: '...', options: {} }` with no `style`.

**Evidence:**

```js
// presets.js:60
feedbacks: [{ feedbackId: 'blackout', options: {} }],
// presets.js:66
feedbacks: [{ feedbackId: 'message_active', options: {} }],
// presets.js:78
feedbacks: [{ feedbackId: 'ndi_running', options: {} }],
```

**Fix:** give each preset feedback a `style` matching the definition's `defaultStyle`.

```js
feedbacks: [{ feedbackId: 'blackout', options: {}, style: { bgcolor: combineRgb(172, 52, 67), color: white } }],
// message_active: bgcolor combineRgb(195, 162, 53), color combineRgb(45, 36, 16)
// ndi_running:    bgcolor combineRgb(23, 111, 86),  color white
```

## 🟢 Low

### L1: Status shows Connecting forever when J-COUNTER never answers

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:96-108`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/main.js#L96-L108)

**What goes wrong:** A user enters the wrong "J-Counter computer IP address" (192.168.1.50 instead of .51), forgets to press Start OSC in J-COUNTER, or still runs J-COUNTER 2.x. The connection shows "Connecting" indefinitely and never moves to a failure, and nothing is logged. A wrong address looks the same as a slow start.

**Why it happens:** The 3-second poll only reports "J-Counter OSC not responding" when the connection was OK at least once. Before the first hello from J-COUNTER the "connected" flag is off, so that check never runs.

**Fix:** record when the subscribe loop starts (for example `this.connectStarted = Date.now()` in the `ready` handler). In the poll, set `InstanceStatus.ConnectionFailure` once with a message such as "No reply from J-COUNTER – check IP, port and that J-COUNTER 3.x is running" when `!this.isConnected && Date.now() - this.connectStarted > 8000`.

### L2: Existing v2 buttons stop working after the upgrade

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`upgrades.js:1-7`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/upgrades.js#L1-L7)

**What goes wrong:** A user updates an existing connection from v2.0.1 to v3.0.0. Every button using the old `trigger_oprations`, `trigger_colors`, `trigger_messages` or `trigger_Presets` actions, or the `ChannelState` / `ChannelState2` feedbacks, now points at something that no longer exists. Those buttons do nothing and stop changing colour until the user rebuilds them (see [A1](#-assumptions-to-confirm)). This is intentional: `CHANGELOG.md` and `HELP.md` say v3 needs J-COUNTER 3.0 and that v2 users should stay on 2.0.1. Users who update without reading the notes still end up with silently broken buttons.

**Why it happens:** v3 replaces the OSC protocol and every action and feedback ID, and `upgrades.js` is an empty list whose comment says old actions are deliberately not mapped.

**Fix:** acceptable as an intentional breaking release. Consider logging a warning in `init()` when the config came from v2 (for example a numeric `feedbackPort`) that points users to the changelog, or adding upgrade scripts for the unambiguous v2 actions, such as `trigger_messages` show/hide → the new `message` action.

### L3: The Timer display feedback declares a property API 1 ignores

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`feedbacks.js:31`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/feedbacks.js#L31)

**What goes wrong:** Users see no difference; the feedback works the same with or without the property. The line suggests the feedback relies on a newer API feature that it doesn't actually get.

**Why it happens:** `affectedProperties` is not part of the API 1 advanced-feedback definition (it is absent from the installed `@companion-module/base` 1.15.0 typings). Because the module is plain JavaScript, nothing flags the unknown key.

**Fix:** remove `affectedProperties: ['bgcolor', 'color', 'text'],` from the `timer_display` definition, or keep it only after moving the module to an API version that supports it.

## 💡 Nice to Have

### N1: Decimal or empty number fields are sent to J-COUNTER as text

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`main.js:65-67`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/main.js#L65-L67), [`actions.js:54-56`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/actions.js#L54-L56)

**What goes wrong:** If a user types 1.5 into the Hours field of "Countdown: SET TIME", or leaves a number field empty (see [A2](#-assumptions-to-confirm)), the module sends that value as the text "1.5" or "NaN" where J-COUNTER expects a whole number. J-COUNTER rejects it, the rejection only shows as a log warning, and the button seems to do nothing.

**Why it happens:** The OSC send helper sends any value that isn't a whole number as a string. Most action callbacks (set time, end time, warnings, clock offset) pass `Number(option)` straight through without rounding or checking it; only "ADD / SUBTRACT SECONDS" checks for a whole number.

**Fix:** in the numeric action callbacks, round with `Math.round()` and clamp to the option's min/max; if the value isn't finite, skip the send and log a warning.

### N2: The Timer SET TITLE action does not accept Companion variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`actions.js:43-44`](https://github.com/bitfocus/companion-module-jozeemedia-jcounter/blob/8e0cf0124168c57b272613e9eb2b32d090e236be/actions.js#L43-L44)

**What goes wrong:** A user who wants the timer title to follow a variable types `$(internal:custom_speaker)` into the Title field of "Timer: SET TITLE". J-COUNTER shows the literal text `$(internal:custom_speaker)` instead of the variable's value.

**Why it happens:** The Title text field doesn't set `useVariables`, so Companion doesn't replace variables before the action runs.

**Fix:** add `useVariables: true` to the Title text field. With base `^1.12` on Companion 4.1+ the value arrives already resolved; to support older Companion versions, also call `await self.parseVariablesInString(action.options.title)` in the callback.
