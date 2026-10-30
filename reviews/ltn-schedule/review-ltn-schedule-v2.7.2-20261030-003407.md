# Review: companion-module-ltn-schedule v2.7.2

| Field | Value |
| --- | --- |
| **Module** | [companion-module-ltn-schedule](https://github.com/bitfocus/companion-module-ltn-schedule) |
| **Scope** | `tag` (v2.6.0..v2.7.2) |
| **Version** | v2.7.2 (`a50faa5`) |
| **Release** | Update — last published v2.6.0 |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Template** | `companion-module-template-js-v2.0.4` @ `e4caa76` (2026-08-28, pinned) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion tolerates a preset feedback with no `options` key (or fills in `{}`) when a user drags the preset onto a button | The base 2.0.4 typings mark `options` as required on `CompanionPresetFeedback`; Companion's host-side preset conversion is not in the module's `node_modules`, so it was not checked | [L1](#l1-the-toggle-pgm-recording-preset-leaves-out-the-feedbacks-options) |
| A2 | Some users can still import configs whose connections never ran upgrade script 0 (configs from before the boolean-feedback conversion) | Companion runs each upgrade script once per connection; how many such old configs still exist is unknown | [M2](#m2-importing-a-very-old-config-gives-playout-running-buttons-a-broken-background-colour) |

## 📋 Issues

### Blocking

- [ ] [C1: New .yarnrc.yml allows Git dependencies from any repository](#c1-new-yarnrcyml-allows-git-dependencies-from-any-repository)
- [ ] [C2: Module entry point index.js is at the repo root instead of under src/](#c2-module-entry-point-indexjs-is-at-the-repo-root-instead-of-under-src)
- [ ] [C3: .gitignore is missing the template's build-artifact entries](#c3-gitignore-is-missing-the-templates-build-artifact-entries)
- [ ] [C4: .gitattributes is missing](#c4-gitattributes-is-missing)
- [ ] [H1: Clear graphics engine and the new Start/Stop/Clear all GFX layers buttons do nothing](#h1-clear-graphics-engine-and-the-new-startstopclear-all-gfx-layers-buttons-do-nothing)

### Non-blocking

- [ ] [M1: Current played time shows a huge number on Schedule servers older than API 10](#m1-current-played-time-shows-a-huge-number-on-schedule-servers-older-than-api-10)
- [ ] [M2: Importing a very old config gives Playout running buttons a broken background colour](#m2-importing-a-very-old-config-gives-playout-running-buttons-a-broken-background-colour)
- [ ] [L1: The Toggle PGM Recording preset leaves out the feedback's options](#l1-the-toggle-pgm-recording-preset-leaves-out-the-feedbacks-options)
- [ ] [L2: Leftover variable-parsing branch in Reconnect never runs](#l2-leftover-variable-parsing-branch-in-reconnect-never-runs)

## 🔴 Critical

### C1: New .yarnrc.yml allows Git dependencies from any repository

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (the file is new in v2.7.2)
- **File:** [`.yarnrc.yml:1-2`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/.yarnrc.yml#L1-L2)

**What goes wrong:** The `.yarnrc.yml` added in this release has a key the template doesn't have, `approvedGitRepositories: ['**']`. It tells Yarn to accept Git-hosted dependencies from any repository, which turns off the safety check the template's Yarn config relies on.

**Why it happens:** The rest of the file matches the template, but the extra key was added on top of it.

**Evidence:**

```text
Expected: .yarnrc.yml keys match companion-module-template-js (main)
Found:    extra key not in template: approvedGitRepositories
```

```yaml
# .yarnrc.yml:1-2
approvedGitRepositories:
  - '**'
```

**Fix:** delete the `approvedGitRepositories` key so the file matches the template's `.yarnrc.yml`.

### C2: Module entry point index.js is at the repo root instead of under src/

- **Source:** 🤖 validate-template (SRC-AT-ROOT)
- **Classification:** 🆕 NEW (already at the root in v2.6.0; `index.js` was changed in this release)
- **File:** [`index.js`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/index.js)

**What goes wrong:** The module's main source file lives at the repo root, while the template keeps all source under `src/`. The rest of the module's code is already in `src/`, so the layout is split across two places.

**Why it happens:** `index.js` was never moved when the rest of the source moved to `src/`.

**Evidence:**

```text
Expected: all source files under src/
Found:    index.js at module root
```

```json
// package.json:4
"main": "index.js",
// companion/manifest.json:22
"entrypoint": "../index.js"
```

**Fix:** move `index.js` to `src/main.js` (fixing its relative imports), then point `main` in [`package.json:4`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/package.json#L4) and `runtime.entrypoint` in [`companion/manifest.json:22`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/companion/manifest.json#L22) at the new path.

### C3: .gitignore is missing the template's build-artifact entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (already the case in v2.6.0)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/.gitignore)

**What goes wrong:** After `yarn package`, the built `ltn-schedule-2.7.2.tgz` and the `.yarn/` folder show up as untracked files, so they can easily be committed by accident.

**Why it happens:** The `.gitignore` has `/pkg.tgz` and `.idea` but not the template's `/*.tgz`, `DEBUG-*` and `/.yarn` entries. The package file is named after the module and version, so `/pkg.tgz` never matches it.

**Evidence:**

```text
Expected: template .gitignore entries present
Found:    missing /*.tgz, DEBUG-*, /.yarn
```

**Fix:** add the three missing lines, so the file matches the template's `.gitignore`.

```text
/*.tgz
DEBUG-*
/.yarn
```

### C4: .gitattributes is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (already missing in v2.6.0)
- **File:** `.gitattributes` (not present)

**What goes wrong:** Without the template's `.gitattributes`, a contributor on Windows can commit CRLF line endings, which then show up as whole-file diffs and can break the formatting checks.

**Why it happens:** The template tracks a `.gitattributes` that forces LF line endings, and the module never added it.

**Evidence:**

```text
Expected: .gitattributes (tracked by the template)
Found:    file missing
```

**Fix:** add `.gitattributes` with the template's content.

```text
* text=auto eol=lf
```

## 🟠 High

### H1: Clear graphics engine and the new Start/Stop/Clear all GFX layers buttons do nothing

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:619-628`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/actions.js#L619-L628), [`src/actions.js:595-615`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/actions.js#L595-L615), [`src/actions.js:732-736`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/actions.js#L732-L736)

**What goes wrong:** A user on a Schedule server with API 10 or later adds the new action "Clear graphics engine", or drags the new "Clear all GFX layers" preset (Graphics > Graphics Controls) onto a button, and presses it. Nothing is sent to Schedule, nothing is logged and no error appears, and the connection stays green. The graphics stay on air while the operator thinks they were cleared. The new "Stop all GFX layers" and "Start all GFX layers" presets in the same group fail the same way.

**Why it happens:** The action callbacks declare the command string as `let cmd` and never give it a value, so it is `undefined`. The shared `sendAction()` function only builds and sends the request when `cmd` is defined, and has no else branch, so it returns silently. The new "Clear graphics engine" action has this bug from the start. The "Stop all graphics layers" and "Start all graphics layers" actions already had it in v2.6.0, but this release is the first to put them on buttons through the new presets. Other actions, including the new PGM-recording action, avoid it by setting `cmd = ''`.

**Evidence:**

```js
// src/actions.js:618-628
	if (this.data.apiVersion >= 10) {
		actions.clearAllGraphics = {
			name: 'Clear graphics engine',
			options: [],
			callback: async (event) => {
				let cmd
				let apiEndpoint = 'graphics/clearAll'

				sendAction.bind(this)(apiEndpoint, cmd, null, null, 'GET')
			},
		}
```

```js
// src/actions.js:595-604 (startAllGraphics at 606-615 is the same)
		actions.stopAllGraphics = {
			name: 'Stop all graphics layers',
			options: [],
			callback: async (event) => {
				let cmd
				let apiEndpoint = 'graphics/stopAll'

				sendAction.bind(this)(apiEndpoint, cmd, null, null, 'GET')
			},
		}
```

```js
// src/actions.js:732-736
function sendAction(apiEndpoint, cmd, callback, errorCallback, requestType) {
	if (typeof cmd !== 'undefined' && typeof apiEndpoint !== 'undefined') {
		let requestString =
			`https://${this.config.username}:${this.config.password}@${this.config.host}/api/v1/${apiEndpoint}` + cmd
		this.log('info', `request ${requestString}`)
```

```js
// src/presets.js:909, 933, 957 (presets added in this release)
							actionId: 'stopAllGraphics',
							actionId: 'clearAllGraphics',
							actionId: 'startAllGraphics',
```

**Confirm by:** open [`src/actions.js:623`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/actions.js#L623) and see `let cmd` with no value, then [`src/actions.js:733`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/actions.js#L733): the whole request, including the log line, sits inside `if (typeof cmd !== 'undefined' ...)`.

**Fix:** give the command string an empty value in all three callbacks, as the PGM-recording action does. Optionally, have `sendAction` treat a missing `cmd` as `''` so endpoints without parameters can't silently do nothing.

```js
let cmd = ''
```

## 🟡 Medium

### M1: Current played time shows a huge number on Schedule servers older than API 10

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.js:41`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/variables.js#L41)

**What goes wrong:** A user connected to a Schedule server with API 7, 8 or 9 starts playout and shows the new "Played time of the current playing element" variable on a button, for example through the new "Current played time" preset. The button shows roughly 500,000 hours (for example `496543:12:07`) instead of the played time or `00:00:00`.

**Why it happens:** The element's start time starts at 0 and is only filled in from status updates when the server reports API 10 or later ([`src/api.js:123-125`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/api.js#L123-L125)). While playout runs, the variable is computed as "now minus start time", so with a start time of 0 it shows the time since 1970.

**Fix:** guard the value the way the PGM-recording time already is, or only expose the variable and preset on API 10 and later.

```js
currentPlayedTime: msToTime(this.data.currentStartstamp > 0 ? now - this.data.currentStartstamp : -1),
```

### M2: Importing a very old config gives Playout running buttons a broken background colour

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`index.js:176-180`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/index.js#L176-L180)

**What goes wrong:** Someone imports an old Companion config whose "Playout running status" feedback still has the old bg/fg colour options, from before this upgrade script existed. After the upgrade the button never turns red while playout runs. Connections that already ran this script under the v1 module are not affected, so only very old configs hit this (see [A2](#-assumptions-to-confirm)).

**Why it happens:** This release moves from `@companion-module/base` 1.10 to 2.0.4. Under 2.0, Companion hands upgrade scripts every option as a small object, `{ isExpression: false, value: 16711680 }`, instead of the bare colour number. The library helper `CreateConvertToBooleanFeedbackUpgradeScript` copies that object straight into the button style, so the style gets an object where Companion expects a colour number. Under base 1.x the helper received bare values and worked.

**Evidence:**

```js
// index.js:176-180
export const UpgradeScripts = [
	CreateConvertToBooleanFeedbackUpgradeScript({
		playbackStatus: true,
	}),
]
```

```js
// node_modules/@companion-module/base/dist/module-api/upgrade.js:36-39
                for (const [option_key, style_key] of Object.entries(upgrade_rules)) {
                    const rawVal = feedback.options[option_key];
                    if (rawVal !== undefined) {
                        feedback.style[style_key] = rawVal;
```

**Fix:** keep a script at index 0 (scripts are matched by position), but replace the helper with your own script that reads `.value` from each wrapped bg/fg option, skips values with `isExpression: true`, and writes the plain number into the style. If the conversion no longer needs to run, `EmptyUpgradeScript` at index 0 is also fine.

## 🟢 Low

### L1: The Toggle PGM Recording preset leaves out the feedback's options

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.js:1020-1027`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/presets.js#L1020-L1027)

**What goes wrong:** Probably nothing visible today. The new "Toggle PGM Recording" preset's feedback has no `options` field, while every other preset feedback in the file passes `options: {}`. If Companion doesn't fill in a missing `options` (see [A1](#-assumptions-to-confirm)), a button made from this preset could store a feedback with undefined options.

**Why it happens:** The feedback entry is written as `{ feedbackId: 'pgmRecordingStatus', style: { bgcolor: red } }`. The base 2.0.4 typings (`CompanionPresetFeedback`) mark `options` as required.

**Fix:** add `options: {}` to the `pgmRecordingStatus` feedback in `presets.toggle_pgm_recording`.

### L2: Leftover variable-parsing branch in Reconnect never runs

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:713-718`](https://github.com/bitfocus/companion-module-ltn-schedule/blob/a50faa550beb49433452add80b9363780a3e9829/src/actions.js#L713-L718)

**What goes wrong:** Users see no difference: the "Reconfigure connection" action still resolves variables in New host, New API username and New API password, because those fields have `useVariables: true` and Companion resolves them before the callback runs. The compatibility block is dead code.

**Why it happens:** The `typeof this.parseVariablesInString === 'function'` check was written to support both API 1 and API 2. Base 2.0.4 no longer has `parseVariablesInString`, so the check is always false.

**Fix:** delete the comment and the `if (typeof this.parseVariablesInString === 'function') { ... }` block, and keep `useVariables: true` on the three fields.
