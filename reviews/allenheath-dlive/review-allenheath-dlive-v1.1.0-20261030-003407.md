# Review: companion-module-allenheath-dlive v1.1.0

| | |
| --- | --- |
| **Module** | [companion-module-allenheath-dlive](https://github.com/bitfocus/companion-module-allenheath-dlive) |
| **Scope** | `tag` (`v1.0.1..v1.1.0`) |
| **Version** | v1.1.0 |
| **Release** | Update — last published v1.0.1 |
| **API** | 1 (base 1.14.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`165fb4c`](https://github.com/bitfocus/companion-module-allenheath-dlive/tree/165fb4c56e480981cc26bedf4a60a32fea725d40) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion can hand the module a saved config that fails its validation (for example a cleared or out-of-range MIDI Port, or a config migrated from the legacy `allenheath-dlive-ilive` id or imported), so the "Bad Config" early-return paths are reachable in real use | Verified that base 1.14.1 fills in field defaults on first init (`node_modules/@companion-module/base/dist/module-api/base.js:98-113`), so brand-new connections are not affected; how Companion's config UI validates before saving, and the legacy module's config shape, were not checked | [M2](#m2-feedbacks-and-the-mute-and-fader-step-actions-stay-dead-after-a-bad-config-is-fixed), [L1](#l1-saving-a-rejected-config-leaves-the-old-console-connection-running-and-hides-bad-config) |
| A2 | Companion clears a variable's shown value when the module removes its definition (base sends `value: undefined`), and shows the empty string base sends when the variable is defined again | `@companion-module/base` 1.14.1 `setVariableDefinitions` (`module-api/base.js:266-299`); host-side rendering not checked | [M3](#m3-channel-name-variable-goes-blank-when-a-channels-feedback-is-removed-and-added-again) |
| A3 | In Companion, `$(this:...)` resolves only a button's own local variables (page, row, column, step), not the connection's variables, so `$(this:dlive_input_1_mute)` does not resolve | Companion host variable scoping; not determinable from the module or base | [M4](#m4-help-page-tells-users-to-write-this-prefixed-variables-which-never-resolve) |
| A4 | Companion does not rewrite a hard-coded connection label inside preset text when the preset is placed on a button, and a new connection's default label is the manifest shortname `dLive` | Companion host preset handling; not determinable from the module | [L3](#l3-new-presets-show-na-when-the-connection-is-not-labelled-dlive) |
| A5 | Buttons whose action id the module no longer defines are shown by Companion as unknown or missing actions | Companion host behaviour for undefined action ids | [L6](#l6-existing-recall-scene-recall-cue-list-and-go-next-previous-buttons-break-after-upgrading-or-switching-connect-to) |

## 📋 Issues

### Blocking

- [ ] [C1: Git attributes file adds a rule the template does not have](#c1-git-attributes-file-adds-a-rule-the-template-does-not-have)
- [ ] [C2: Git ignore file is missing the template's Yarn folder entry](#c2-git-ignore-file-is-missing-the-templates-yarn-folder-entry)
- [ ] [C3: The Husky pre-commit hook file is missing](#c3-the-husky-pre-commit-hook-file-is-missing)
- [ ] [C4: The Yarn install state file is committed to the repo](#c4-the-yarn-install-state-file-is-committed-to-the-repo)
- [ ] [C5: package.json has no engines field](#c5-packagejson-has-no-engines-field)

### Non-blocking

- [ ] [M1: The GitHub Actions workflow file is missing](#m1-the-github-actions-workflow-file-is-missing)
- [ ] [M2: Feedbacks and the mute and fader step actions stay dead after a bad config is fixed](#m2-feedbacks-and-the-mute-and-fader-step-actions-stay-dead-after-a-bad-config-is-fixed)
- [ ] [M3: Channel name variable goes blank when a channel's feedback is removed and added again](#m3-channel-name-variable-goes-blank-when-a-channels-feedback-is-removed-and-added-again)
- [ ] [M4: Help page tells users to write this-prefixed variables, which never resolve](#m4-help-page-tells-users-to-write-this-prefixed-variables-which-never-resolve)
- [ ] [L1: Saving a rejected config leaves the old console connection running and hides Bad Config](#l1-saving-a-rejected-config-leaves-the-old-console-connection-running-and-hides-bad-config)
- [ ] [L2: Fader dB variable is off by up to half a dB from the Fader Level dropdown](#l2-fader-db-variable-is-off-by-up-to-half-a-db-from-the-fader-level-dropdown)
- [ ] [L3: New presets show $NA when the connection is not labelled dLive](#l3-new-presets-show-na-when-the-connection-is-not-labelled-dlive)
- [ ] [L4: The new MIDI Port field uses the deprecated isVisible function](#l4-the-new-midi-port-field-uses-the-deprecated-isvisible-function)
- [ ] [L5: Upgrade script lives inline in main.ts instead of an upgrades file](#l5-upgrade-script-lives-inline-in-maints-instead-of-an-upgrades-file)
- [ ] [L6: Existing Recall Scene, Recall Cue List and Go-Next-Previous buttons break after upgrading or switching Connect To](#l6-existing-recall-scene-recall-cue-list-and-go-next-previous-buttons-break-after-upgrading-or-switching-connect-to)
- [ ] [L7: Variable list shows 0-based channel numbers that don't match the 1-based variable ids](#l7-variable-list-shows-0-based-channel-numbers-that-dont-match-the-1-based-variable-ids)
- [ ] [N1: Redundant work and debug-log noise when many feedbacks subscribe](#n1-redundant-work-and-debug-log-noise-when-many-feedbacks-subscribe)
- [ ] [N2: About 3,000 presets are registered, including 2,000 individual cue-recall buttons](#n2-about-3000-presets-are-registered-including-2000-individual-cue-recall-buttons)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Git attributes file adds a rule the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (file added in this release)
- **File:** [`.gitattributes:2`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/.gitattributes#L2)

**What goes wrong:** The new `.gitattributes` does not match the template's. Line 2 is `*.png binary`, where the template has no line.

**Why it happens:** The file was added in v1.1.0 with extra `*.png`, `*.pdf` and `*.gz` binary rules on top of the template's `* text=auto eol=lf`.

**Fix:** make `.gitattributes` match the v1 template exactly (only `* text=auto eol=lf`).

### C2: Git ignore file is missing the template's Yarn folder entry

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check; the file was the same at v1.0.1)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/.gitignore)

**What goes wrong:** `.gitignore` lacks the template's `/.yarn` entry, so Yarn's local state gets committed (see [C4](#c4-the-yarn-install-state-file-is-committed-to-the-repo)).

**Why it happens:** Missing template `.gitignore` entries: `/.yarn`.

**Fix:** add `/.yarn` to `.gitignore` so it matches the template.

### C3: The Husky pre-commit hook file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check; also absent at v1.0.1)
- **File:** `.husky/pre-commit`

**What goes wrong:** The template's pre-commit hook is not in the repo, so `lint-staged` never runs on commit even though `package.json` installs Husky (`"postinstall": "husky"`) and configures `lint-staged`.

**Why it happens:** Required file `.husky/pre-commit` (tracked by the template) is missing.

**Fix:** add `.husky/pre-commit` from the v1 template (it runs `lint-staged`).

### C4: The Yarn install state file is committed to the repo

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW (template check; committed before v1.0.1 and modified again in this release)
- **File:** `.yarn/install-state.gz`

**What goes wrong:** `.yarn/install-state.gz` (about 575 KB, machine-specific) is tracked in git and changes on every install, adding noise to every release diff.

**Why it happens:** The template's `.gitignore` excludes it with `/.yarn`, but this repo is missing that entry ([C2](#c2-git-ignore-file-is-missing-the-templates-yarn-folder-entry)).

**Fix:** `git rm --cached .yarn/install-state.gz` and add `/.yarn` to `.gitignore`.

### C5: package.json has no engines field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW (template check; also absent at v1.0.1)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/package.json)

**What goes wrong:** `package.json` is missing the `engines` field that the template declares.

**Why it happens:** Missing required field `engines` (present in template).

**Fix:** add the template's field.

```json
"engines": {
	"node": "^22.20",
	"yarn": "^4"
},
```

## 🟡 Medium

### M1: The GitHub Actions workflow file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check; also absent at v1.0.1)
- **File:** `.github/workflows/node.yaml`

**What goes wrong:** The template's CI workflow is not in the repo, so pushes and pull requests are not built or linted automatically.

**Fix:** add `.github/workflows/node.yaml` from the v1 template.

### M2: Feedbacks and the mute and fader step actions stay dead after a bad config is fixed

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/main.ts:56-90`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/main.ts#L56-L90)

**What goes wrong:** If the saved connection config fails validation when the module starts (for example a MIDI Port outside 1-65535 left over from an older version), the connection shows Bad Config and has no actions, feedbacks or presets. When the user corrects the config and saves, the actions and presets come back and the module connects, but the Channel Muted, Fader Level and Main Mix Assignment feedbacks are still missing. Mute Toggle, Fader Level Increment and Fader Level Decrement do nothing; the log says "No mute state received from the console" / "No fader level received". This lasts until the connection is disabled and re-enabled or Companion restarts. In v1.0.1 a parse failure still registered the actions.

**Why it happens:** v1.1.0 makes `init()` return early on a parse failure, before it creates the feedback handler (`new FeedbackHandler(this)`) and registers feedbacks (`UpdateFeedbacks(this)`). `configUpdated()` only re-registers actions and presets. Everything else reaches the handler through optional chaining (`feedbackHandler?.`), so the missing handler fails silently.

**Evidence:**

```ts
// src/main.ts:56-90
	async init(initialConfig: Record<string, unknown>): Promise<void> {
		this.log('info', `Initialising module from config: ${JSON.stringify(initialConfig)}`)
		try {
			this.config = parseDliveModuleConfig(initialConfig)
		} catch (error) {
			this.log('error', `Unable to parse config object during init method: ${JSON.stringify(error)}`)
			this.updateStatus(InstanceStatus.BadConfig)
			return
		}

		// Initialize feedback handler
		this.feedbackHandler = new FeedbackHandler(this)

		UpdateActions(this)
		UpdateFeedbacks(this)
		UpdatePresets(this)
		this.initialiseMidi()
	}

	async configUpdated(updatedConfig: Record<string, unknown>): Promise<void> {
		...
		// Re-register actions and presets so target-specific ones (scene/cue recall etc.) follow the config
		UpdateActions(this)
		UpdatePresets(this)
		this.initialiseMidi()
	}
```

**Confirm by:** open [`src/main.ts:56-90`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/main.ts#L56-L90). `init()` returns before the handler is created, and `configUpdated()` never creates it or calls `UpdateFeedbacks`.

**Fix:** make sure the feedback handler and feedback definitions exist whenever a valid config arrives. Create the handler in the constructor (or at the top of `init()`), and in `configUpdated()` register feedbacks too.

```ts
this.feedbackHandler ??= new FeedbackHandler(this)
UpdateActions(this)
UpdateFeedbacks(this)
UpdatePresets(this)
```

### M3: Channel name variable goes blank when a channel's feedback is removed and added again

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/FeedbackHandler.ts:161-184`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/FeedbackHandler.ts#L161-L184), [`src/FeedbackHandler.ts:805-822`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/FeedbackHandler.ts#L805-L822)

**What goes wrong:** A user places the "Input 1 Rotary Knob" preset; its top line shows `$(dLive:dlive_input_1_name)` = "Vocals". Later they delete that button and place the preset again, or switch a Channel Muted feedback from Input 1 to Input 2 and back. The name line is now empty instead of "Vocals" (or the "IP 1" placeholder), and stays empty until the TCP connection drops and reconnects.

**Why it happens:** When the last feedback for a channel is removed, the module drops the channel's name variable from its variable list, and base 1.14 clears its value. But the module's record of which channel names it has already requested is never pruned. On the next subscribe the module thinks the name is already known, so it neither sets the placeholder nor asks the console for the name again. Only the reconnect path re-requests names.

**Fix:** when a channel's last subscription is removed, also forget its name subscription so the next subscribe requests the name again.

```ts
// in removeFeedback(), when usages reaches 0 and no other subscription uses this channel
this.channelNameSubscriptions.delete(`${channelType}:${channelNo}`)
```

### M4: Help page tells users to write this-prefixed variables, which never resolve

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:101-109`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/companion/HELP.md#L101-L109)

**What goes wrong:** The new Variables section tells users to put `$(this:dlive_input_1_mute)` or `$(this:dlive_input_1_fader)` in button text. A user who copies the examples sees the variable fail to resolve (blank or `$NA`) instead of `true` or `-12.3`.

**Why it happens:** In Companion, `$(this:...)` refers to the button's own local variables (page, row, column, step), not to a connection's variables. Connection variables use the connection label, as the module's own presets do: `$(dLive:dlive_input_1_fader)`.

**Fix:** change the examples to use the connection label, e.g. `$(dLive:dlive_input_1_mute)`, note that `dLive` is replaced by the connection's label if it was renamed, and document the `dlive_<type>_<n>_name` channel-name variable too.

## 🟢 Low

### L1: Saving a rejected config leaves the old console connection running and hides Bad Config

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:75-88`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/main.ts#L75-L88)

**What goes wrong:** A user saves connection settings that the module rejects. The log says "Unable to parse config object during configUpdated method" and the status is set to Bad Config, but the TCP connection to the previous Target IP and port stays open and keeps reconnecting. Its status updates flip the connection back to OK or Connecting, and button presses still go to the old console, so the user cannot tell the new settings were not applied. This only happens when a saved config fails validation, which is rare.

**Why it happens:** v1.1.0 returns from `configUpdated()` right after setting Bad Config, before `initialiseMidi()`, which is what closes the old socket (`destroyMidiSocket()`). The old socket's status handler keeps calling `updateStatus`. The socket is still closed in `destroy()`, so nothing leaks.

**Fix:** close the old connection before reporting the bad config.

```ts
} catch (error) {
	this.log('error', `Unable to parse config object during configUpdated method: ${JSON.stringify(error)}`)
	this.destroyMidiSocket()
	this.updateStatus(InstanceStatus.BadConfig)
	return
}
```

### L2: Fader dB variable is off by up to half a dB from the Fader Level dropdown

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/FeedbackHandler.ts:538-553`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/FeedbackHandler.ts#L538-L553)

**What goes wrong:** With Input 1 at 0 dB on the console (MIDI value 107), the Fader Level dropdown and feedback call this "0.0 dB", but the new `$(dLive:dlive_input_1_fader)` variable shown on every Rotary Knob preset reads "-0.1". Lower down they drift further apart: MIDI 1 is "-53.0 dB" in the dropdown but "-53.5" in the variable.

**Why it happens:** The variable uses `faderMidiValueToDb` (`midi * 64 / 127 - 54`, so 107 becomes -0.08), while the dropdown labels in `FADER_LEVEL_CHOICES` use `(id - 107) / 2`. The module uses two different scales for the same value.

**Fix:** use one conversion for both the dropdown labels and the variable.

### L3: New presets show $NA when the connection is not labelled dLive

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:247`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/presets.ts#L247), [`src/presets.ts:326`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/presets.ts#L326)

**What goes wrong:** The new Rotary Knob and Mute Button presets show the channel name and fader level through `$(dLive:...)`. On a second dLive connection (`dLive_2`) or a renamed one (`FOH`), the placed button shows `$NA` instead.

**Why it happens:** The variable prefix in the preset text is the literal string `dLive`, not the connection's current label.

**Fix:** build the text from the instance label, e.g. `` `$(${instance.label}:dlive_${config.variablePrefix}_${channelNum}_name)` ``. Presets are already rebuilt in `configUpdated()`, which also runs on a label change.

### L4: The new MIDI Port field uses the deprecated isVisible function

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:674`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/main.ts#L674)

**What goes wrong:** Nothing visible today: MIDI Port shows only when "Use Custom MIDI Port" is ticked. But `isVisible` functions are deprecated since API 1.12 and removed in API 2.0, so after a v2 migration the field would always show. The rest of the module already uses `isVisibleExpression`.

**Fix:** replace `isVisible: (options) => options.useCustomPort === true` with `isVisibleExpression: '$(options:useCustomPort)'`, and raise the `@companion-module/base` range in `package.json` from `^1.4.0` to at least `^1.12.0`, since the module relies on `isVisibleExpression`.

### L5: Upgrade script lives inline in main.ts instead of an upgrades file

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:688-710`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/main.ts#L688-L710)

**What goes wrong:** No user-visible effect; this is code organisation. The new upgrade script that maps old configs to the "Connect To" and "Use Custom MIDI Port" fields sits at the bottom of the entry file, which will grow with every future upgrade.

**Fix:** move `addConnectionTargetUpgrade` into `src/upgrades.ts`, export `UpgradeScripts: CompanionStaticUpgradeScript<DLiveModuleConfig>[] = [addConnectionTargetUpgrade]`, and call `runEntrypoint(ModuleInstance, UpgradeScripts)`.

### L6: Existing Recall Scene, Recall Cue List and Go-Next-Previous buttons break after upgrading or switching Connect To

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:1033-1045`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/actions.ts#L1033-L1045)

**What goes wrong:** The upgrade script sets "Connect To" = Surface for every existing connection on port 51328 (the old default), and the Recall Scene action then disappears from the module. Any button an upgrading user built with Recall Scene now points at an action the module no longer defines, and nothing in the UI says why. Recall Cue List and Go/Next/Previous buttons break the same way when the user switches "Connect To" to MixRack.

**Why it happens:** The action definitions are deleted depending on the configured target, instead of staying registered and being gated inside the callback.

**Fix:** keep the definitions registered for both targets and log a warning in the callback (e.g. "Scene recall is only supported when connected to a MixRack"), saying so in the action description. At minimum, explain the change in HELP.md and the release notes.

### L7: Variable list shows 0-based channel numbers that don't match the 1-based variable ids

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/FeedbackHandler.ts:952-974`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/FeedbackHandler.ts#L952-L974)

**What goes wrong:** In the connection's variable list, `dlive_input_1_fader` is described as "dLive: input:0:fader" and `dlive_input_1_name` as "dLive: input:0:name". A user looking for Input 1 sees "input:0" and may think the list is off by one.

**Why it happens:** The variable's display name is built from the internal 0-based channel number, while the variable id adds 1.

**Fix:** build a readable 1-based name, e.g. "Input 1 Fader" / "Input 1 Name", from `channelNo + 1` and the channel type's display label.

## 💡 Nice to Have

### N1: Redundant work and debug-log noise when many feedbacks subscribe

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/FeedbackHandler.ts:127-154`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/FeedbackHandler.ts#L127-L154), [`src/FeedbackHandler.ts:805-828`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/FeedbackHandler.ts#L805-L828), [`src/FeedbackHandler.ts:855-867`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/FeedbackHandler.ts#L855-L867)

**What goes wrong:** Nothing breaks. When a page of Rotary Knob presets loads (say 32 buttons, 64 feedbacks), the module re-sends its full variable list once per new subscription. On reconnect it asks the console for each channel's name once per subscribed parameter. Mute Toggle and Fader Increment/Decrement send the same get request twice on first use, and every feedback evaluation writes a "Feedback X already subscribed" debug line, flooding the connection's debug log.

**Why it happens:** `subscribeToParameter()` calls `updateVariables()` for every new key; `requestAllSubscribedValues()` requests the channel name inside the per-subscription loop; the actions request the value again after `ensureSubscription()` already did; and `mapFeedback()` logs on its no-op path.

**Fix:** optional cleanups:

- Batch `updateVariables()` (for example with a `setImmediate` flag cleared in `clear()`).
- De-duplicate channel-name requests with a `Set` in `requestAllSubscribedValues()`.
- Skip the explicit request in the actions when `ensureSubscription()` has just created the subscription.
- Drop the debug log on the unchanged path of `mapFeedback()`.

### N2: About 3,000 presets are registered, including 2,000 individual cue-recall buttons

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:499-530`](https://github.com/bitfocus/companion-module-allenheath-dlive/blob/165fb4c56e480981cc26bedf4a60a32fea725d40/src/presets.ts#L499-L530)

**What goes wrong:** The presets panel now lists about 500 rotary-knob presets, 500 "Recall Scene N" presets and 2,000 "Recall Cue ID N" presets in single categories. That is hard to browse, and all of them are re-sent every time the connection config is saved.

**Fix:** offer a smaller set, for example the first bank of each, or one generic Recall Scene / Recall Cue preset whose number the user edits, and group per-channel presets by bank.

## 📝 Additional Notes

- `tsconfig.build.json` adds `test/**/*.ts` to `include` (found `["src/**/*.ts", "test/**/*.ts"]`, template `["src/**/*.ts"]`). Fine as long as the module builds — no change required.
- `tsconfig.json` has no `include` key and uses `"exclude": ["node_modules"]` instead of the template's `"include": ["src/**/*.ts"]`. Fine as long as the module builds — no change required.
