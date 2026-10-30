# Review: companion-module-tlof-neoluma-midi-control v1.0.0

| | |
| --- | --- |
| **Module** | [companion-module-tlof-neoluma-midi-control](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control) |
| **Scope** | `tag` (first release: no previous tag, so the whole module was reviewed) |
| **Version** | v1.0.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`b8f791f`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/tree/b8f791f064763ff1bb9e1ea24bc7629525cd1205) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion's number input enforces only the declared min and max (0 to 32) for the Press Button **Index** option, so 32 (and 16 to 32 on a 16-entry button) can be entered and saved | The option's declared `min: 0` / `max: maxLogicalIndex`; Companion's UI not checked | [M1](#m1-press-button-with-an-out-of-range-index-sends-a-different-command-such-as-set-macro-instead-of-use-macro) |
| A2 | A new connection gets a default label derived from the module (for example `neoluma-control`), not `VRChat_NeoLuma_Control`, and Companion does not rewrite a hardcoded `$(label:...)` inside a preset's layered expression to the connection's real label when the preset is placed | `InstanceBase.label` typing in base 2.1.3 ("the user chosen name for this instance"); Companion's label-defaulting and preset code not inspected | [M2](#m2-slider-preset-level-gauges-stay-empty-unless-the-connection-has-one-exact-hardcoded-name) |
| A3 | A preset feedback that omits a declared option (`logical`) and supplies an undeclared one (`index`) is stored as given, so the callback sees `logical` as undefined (or the feedback fails validation). If Companion fills missing preset options with the field defaults, `logical` becomes 0 and the feedback works | The feedback callback code; Companion's preset-import code not checked | [M3](#m3-red-value-feedback-never-lights-on-the-general-spot-width-wash-width-and-gobo-spin-speed-slider-presets) |
| A4 | An exception thrown synchronously from a stream `'data'` listener becomes an uncaughtException that ends the module process, and Companion then restarts the connection | Node.js stream semantics; base 2.1.3 registers no `uncaughtException` handler (checked by grep); not run inside Companion | [L1](#l1-a-short-or-empty-feedback-log-line-crashes-the-connection) |
| A5 | Companion calls the module's `getConfigFields()` again each time the connection settings are opened | General knowledge of the config editor; Companion's host code not inspected | [L5](#l5-opening-the-connection-settings-leaks-a-native-midi-client-each-time) |

## 📋 Issues

### Blocking

- [ ] [C1: Module runs on Node 22 instead of the Node 26 runtime that API 2.1 modules use](#c1-module-runs-on-node-22-instead-of-the-node-26-runtime-that-api-21-modules-use)
- [ ] [C2: Yarn runs dependency install scripts because enableScripts is turned on](#c2-yarn-runs-dependency-install-scripts-because-enablescripts-is-turned-on)

### Non-blocking

- [ ] [M1: Press Button with an out-of-range Index sends a different command, such as Set Macro instead of Use Macro](#m1-press-button-with-an-out-of-range-index-sends-a-different-command-such-as-set-macro-instead-of-use-macro)
- [ ] [M2: Slider preset level gauges stay empty unless the connection has one exact hardcoded name](#m2-slider-preset-level-gauges-stay-empty-unless-the-connection-has-one-exact-hardcoded-name)
- [ ] [M3: Red value feedback never lights on the General Spot Width, Wash Width and Gobo Spin Speed slider presets](#m3-red-value-feedback-never-lights-on-the-general-spot-width-wash-width-and-gobo-spin-speed-slider-presets)
- [ ] [M4: CI checks the module on Node 22 and keeps checkout credentials](#m4-ci-checks-the-module-on-node-22-and-keeps-checkout-credentials)
- [ ] [M5: Release workflow from the template is missing](#m5-release-workflow-from-the-template-is-missing)
- [ ] [L1: A short or empty Feedback log line crashes the connection](#l1-a-short-or-empty-feedback-log-line-crashes-the-connection)
- [ ] [L2: Cannot find logs status is overwritten at once and the log search repeats every second](#l2-cannot-find-logs-status-is-overwritten-at-once-and-the-log-search-repeats-every-second)
- [ ] [L3: The Reset action hides a MIDI Out Port not open error and leaves the status at Connecting](#l3-the-reset-action-hides-a-midi-out-port-not-open-error-and-leaves-the-status-at-connecting)
- [ ] [L4: Actions added by hand start with an empty Option that is not in the dropdown](#l4-actions-added-by-hand-start-with-an-empty-option-that-is-not-in-the-dropdown)
- [ ] [L5: Opening the connection settings leaks a native MIDI client each time](#l5-opening-the-connection-settings-leaks-a-native-midi-client-each-time)
- [ ] [L6: Disabling the connection leaves a 1-second reconnect timer running](#l6-disabling-the-connection-leaves-a-1-second-reconnect-timer-running)
- [ ] [L7: Every feedback update rechecks feedbacks twice, once with ids that do not exist](#l7-every-feedback-update-rechecks-feedbacks-twice-once-with-ids-that-do-not-exist)
- [ ] [L8: Nine ts-expect-error comments switch off type checking of preset feedbacks](#l8-nine-ts-expect-error-comments-switch-off-type-checking-of-preset-feedbacks)
- [ ] [L9: Logical Mapping option needs raw numbers in expression mode](#l9-logical-mapping-option-needs-raw-numbers-in-expression-mode)
- [ ] [N1: Feedback names, descriptions and Value options are raw identifiers with no guidance](#n1-feedback-names-descriptions-and-value-options-are-raw-identifiers-with-no-guidance)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Module runs on Node 22 instead of the Node 26 runtime that API 2.1 modules use

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:22-29`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/companion/manifest.json#L22-L29), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/tsconfig.build.json#L2), [`package.json:21-24`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/package.json#L21-L24)

**What goes wrong:** The module is built on API 2.1 (`@companion-module/base` 2.1.3, Companion 5.0+), but its manifest tells Companion to run it on Node 22. The API 2.1 template, and every other API 2.1 module, runs on Node 26. A module that runs on a different Node version from its template is harder to troubleshoot later, because problems can't be compared against the reference setup.

**Why it happens:** The manifest's `runtime.type` is still `node22`, and the TypeScript build config extends the Node 22 preset from `@companion-module/tools`, so the code is also compiled for Node 22. The `package.json` `engines.node` (`^22.20`) matches the old runtime too.

**Evidence:**

```text
Template expects: "runtime": { "type": "node26", ... }
Found:            "runtime": { "type": "node22", ... }

tsconfig.build.json
Template expects: "extends": "@companion-module/tools/tsconfig/node26/recommended.json"
Found:            "extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json"
                  plus "module": "node16", "moduleResolution": "node16", "alwaysStrict": true
```

**Fix:** move the module to the Node 26 setup the template uses: set the runtime to `node26`, extend the Node 26 preset in `tsconfig.build.json` (dropping the extra `module` / `moduleResolution` / `alwaysStrict` lines the preset already covers), and set `engines.node` to `^26` in `package.json`. The CI change in [M4](#m4-ci-checks-the-module-on-node-22-and-keeps-checkout-credentials) goes with it.

```json
"runtime": {
	"type": "node26",
	...
}
```

```json
{
	"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
	...
}
```

### C2: Yarn runs dependency install scripts because enableScripts is turned on

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/.yarnrc.yml#L1)

**What goes wrong:** With `enableScripts: true`, every `yarn install` (on a developer machine and in the Bitfocus build) runs the install and postinstall scripts of every dependency. The template turns this off so that a compromised or misbehaving package can't run code during install.

**Why it happens:** The module's `.yarnrc.yml` sets `enableScripts: true` where the template has `false`. The other keys (`nodeLinker`, `npmMinimalAgeGate: 3d`, `npmPreapprovedPackages`) already match the template.

**Evidence:**

```text
Template expects: enableScripts: false
Found:            enableScripts: true
```

**Fix:** set `enableScripts: false`, as in the template. The native MIDI addon doesn't need its install script: `@julusian/midi` ships N-API v7 prebuilt binaries for Windows, macOS and Linux (`node_modules/@julusian/midi/prebuilds/`), and its install script only verifies those prebuilds (falling back to `node-gyp rebuild` when none fits). Confirm after the change that `yarn install && yarn package` still produce a package that loads the MIDI addon.

```yaml
enableScripts: false
```

## 🟡 Medium

### M1: Press Button with an out-of-range Index sends a different command, such as Set Macro instead of Use Macro

- **Source:** 🔎 QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:92-99`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/actions.ts#L92-L99), [`src/mapping/buttons.ts:765-767`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/mapping/buttons.ts#L765-L767), [`src/main.ts:196-208`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L196-L208)

**What goes wrong:** In a **Press Button** action set to **Macro - Use Macro 0-31**, the **Index** field accepts 0 to 32. An operator who enters 32 gets CC 37 velocity 32, which is the same message as **Macro - Set Macro 0-31** with index 0, so the button overwrites macro slot 0 instead of recalling a macro. **Macro - Set Macro 0-31** with index 32 sends CC 37 velocity 64, the **Activation - Section Enabled** toggle for Floor_Left. **General - Set Color 0-15** accepts 16 to 32 and sends velocities 80 to 96, outside the 16 colours. In each case the world does something the operator didn't ask for, and nothing is logged. Values inside the range shown in the option labels (0-31, 0-15) work correctly.

**Why it happens:** The Index maximum (`maxLogicalIndex`) is the largest entry count across the indexed buttons (32). That is a count, not the highest index, so it is one too high, and one shared maximum is used for every button, so a 16-entry button also accepts up to 32. The action handler adds the index to the base velocity without checking it against the selected button's own count.

**Evidence:**

```ts
// src/mapping/buttons.ts:765-767
export const maxLogicalIndex = Math.max(
	...buttons.map((option) => option.isLogical).filter((option) => typeof option === 'number'),
)
```

```ts
// src/actions.ts:92-99
{
	type: 'number',
	id: 'index',
	label: 'Index',
	isVisibleExpression: 'substr($(options:option), 0, 7) === "INDEX__"',
	default: 0,
	min: 0,
	max: maxLogicalIndex,
},
```

```ts
// src/main.ts:204-208
if (button) {
	let velocity = button.velocity
	if (button.isLogical === true && logical !== undefined) velocity += logical
	else if (typeof button.isLogical === 'number' && index !== undefined) velocity += index
	this.#sendMidiControl(button.channel, button.number, velocity)
```

**Confirm by:** open [`src/mapping/buttons.ts:765-767`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/mapping/buttons.ts#L765-L767) (max of 32, 32, 16 = 32, shared by all indexed buttons) and [`src/main.ts:207`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L207) (no `index < button.isLogical` check). Use Macro (velocity 0) + 32 = CC 37 velocity 32 = Set Macro 0.

**Fix:** reject an index outside the selected button's range before sending, and lower the option maximum to the highest valid index.

```ts
if (typeof button.isLogical === 'number') {
	if (index === undefined || !Number.isInteger(index) || index < 0 || index >= button.isLogical) {
		this.log('error', `Index ${index} is out of range for ${button.label} (0-${button.isLogical - 1})`)
		return
	}
	velocity += index
}
```

Set `max: maxLogicalIndex - 1` on the option. Better still, give each indexed button its own range or label the field with it (for example "Index (0-15)").

### M2: Slider preset level gauges stay empty unless the connection has one exact hardcoded name

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:401-402`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L401-L402), [`src/presets.ts:429-432`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L429-L432)

**What goes wrong:** A user drags a slider preset (from **Logical Sliders** or **Sliders**, for example "Slider - Intensity - Blinder Intensity") onto a button. Its layered variant draws a level gauge whose value reads `$(VRChat_NeoLuma_Control:BlinderIntensity)`. A connection added normally has a different name (Companion names it after the module, for example `neoluma-control`), so the variable never resolves and the gauge stays at zero even while the world reports BlinderIntensity = 100. It only works if the user renames the connection to exactly `VRChat_NeoLuma_Control`. The logical variants also read the wrong variable: "Slider - General - Spot Width" (logical) reads `SpotWidth_01` (Floor_Right), while the preset's Logical Mapping is 0 (Floor_Left, `SpotWidth_00`).

**Why it happens:** The gauge expression hardcodes the connection name instead of using the connection's real label. Its `_NN` suffix is the slider's position in the mapping list, not the logical section the variables are keyed by.

**Fix:** build the expression from the live connection label, `$(${self.label}:...)`, and call `this.updatePresets()` from `configUpdated()` as well so a rename is picked up. For logical sliders use the preset's logical value (0 → `_00`) instead of the list position. For the non-logical General sliders, whose feedback is per section, pick an explicit section or leave the gauge out.

### M3: Red value feedback never lights on the General Spot Width, Wash Width and Gobo Spin Speed slider presets

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:552-566`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L552-L566)

**What goes wrong:** The simple variant of "Slider - General - Spot Width" (and General - Wash Width, General - Gobo Spin Speed) has a second feedback meant to turn the button red when the value is 127. That feedback never lights: it is created with an `index` option the feedback doesn't have and without the `logical` option it needs, so it looks up a variable that doesn't exist (`SpotWidth_undefined`) or fails option validation.

**Why it happens:** These three sliders aren't logical, but their feedback mapping is per logical section. They fall into the preset branch for indexed/sectioned feedbacks, which writes `{ index, value: 127 }`, while the SpotWidth / WashWidth / GoboSpinSpeed feedbacks are declared with `{ value, logical }` (for example [`src/feedbacks.ts:1107-1131`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/feedbacks.ts#L1107-L1131)). The `@ts-expect-error` on `feedbackId` (see [L8](#l8-nine-ts-expect-error-comments-switch-off-type-checking-of-preset-feedbacks)) hides the mismatch from the compiler.

**Fix:** in the slider preset loop (and, for safety, the toggle and enum loops), check `feedbackMapping.hasSections === 'Logical'` first and emit `{ value, logical: 0 }`; use `{ value, index }` only for the Section / Side / SetColor / Color / AudioLink mappings.

### M4: CI checks the module on Node 22 and keeps checkout credentials

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/.github/workflows/node.yaml#L18-L23)

**What goes wrong:** The GitHub Actions workflow builds and lints the module on Node 22.x (in the active job and the commented-out test job), while the template uses Node 26.x, the runtime API 2.1 modules run on. Once the runtime moves to Node 26 ([C1](#c1-module-runs-on-node-22-instead-of-the-node-26-runtime-that-api-21-modules-use)), CI would be testing a different Node version from the one Companion runs. The workflow also omits the template's `persist-credentials: false` on `actions/checkout`.

**Why it happens:** The workflow was copied from an older template version.

**Evidence:**

```text
Differs from template (line 19: found '      - name: Use Node.js 22.x', template '        with:')
Template: node-version: 26.x, actions/checkout with persist-credentials: false
Found:    node-version: 22.x, no persist-credentials
```

**Fix:** copy `.github/workflows/node.yaml` from the template, together with the Node 26 change in C1.

### M5: Release workflow from the template is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** The template ships a `release.yaml` workflow that the module doesn't have, so the module's repository lacks the release automation every other module built from the template has.

**Why it happens:** The file isn't in the repository; the template tracks it.

**Fix:** copy `.github/workflows/release.yaml` from the template.

## 🟢 Low

### L1: A short or empty Feedback log line crashes the connection

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:579-596`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L579-L596), [`src/main.ts:427-429`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L427-L429)

**What goes wrong:** If the VRChat log (or the Unity Editor log, when **Use Unity Editor Log** is ticked) contains a `[Neoluma][Midi][Feedback]` line whose payload is empty or decodes to fewer than 4 bytes (for example `AA==`), the module throws an out-of-range error while reading the log. The connection process crashes, Companion restarts it, and all variables and feedbacks reset; if the same line is read again after the restart, the crash repeats. The NeoLuma world normally sends a full payload, so this is defensive hardening against a malformed line.

**Why it happens:** The log pattern also matches an empty payload. Decoding base64 never fails (it returns an empty buffer at worst), so the existing `try/catch` and empty check never trigger, and the version number is read with `readUInt32LE(0)` without a length check. That runs inside the log-tail library's `'line'` handler, where nothing catches the error.

**Fix:** check the payload length before reading it, and catch errors around the per-line processing so one bad line is logged instead of ending the process.

```ts
if (rawData.length < 4) {
	this.log('warn', `Feedback payload too short: ${base64Data}`)
	return []
}
```

```ts
tailObj.on('line', (line) => {
	try {
		this.#processLogFile(line)
	} catch (e) {
		this.log('error', `Failed to process log line: ${e}`)
	}
})
```

### L2: Cannot find logs status is overwritten at once and the log search repeats every second

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:470-488`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L470-L488)

**What goes wrong:** When **Use Unity Editor Log** is ticked but `Editor.log` doesn't exist, or the VRChat log folder is missing, the status should read "Cannot find logs" or "Failed to read logs". Instead it is immediately replaced by "Connection Lost or Reset - Could not find any Logfile" (Disconnected), then "Connecting after reset", about once a second. Each cycle also resets all ~600 variables to their defaults, rechecks every feedback, and writes debug/info lines; a missing folder adds an "Error finding logs: ENOENT" error line every second.

**Why it happens:** After setting the failure status, the log search calls `reset()` with its defaults, which overwrite the status and schedule another search one second later.

**Fix:** call `reset({ reason, updateStatus: false })` after setting the failure status so the real reason stays visible, skip the variable reset and feedback recheck when the connection is already marked disconnected, and log "Error finding logs" only when the error changes.

### L3: The Reset action hides a MIDI Out Port not open error and leaves the status at Connecting

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:285-298`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L285-L298), [`src/main.ts:310-311`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L310-L311)

**What goes wrong:** When the selected **MIDI Out** port couldn't be opened, the status correctly shows "MIDI Out Port not open" (bad config). If the operator then presses a button with the **Reset** action, the status changes to Disconnected and then "Connecting after reset", and stays there. The actual problem, the MIDI port, is no longer shown.

**Why it happens:** `reset()` always sets the Connecting status before starting the log read, and the log read silently returns when the MIDI port isn't open.

**Fix:** in the reconnect branch of `reset()` (or at the start of `#startLogRead`), check `this.#midiOutput?.isPortOpen()` and set `InstanceStatus.BadConfig, 'MIDI Out Port not open'` when it is false instead of Connecting.

### L4: Actions added by hand start with an empty Option that is not in the dropdown

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:53-54`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/actions.ts#L53-L54), [`src/actions.ts:80-81`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/actions.ts#L80-L81), [`src/actions.ts:116-117`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/actions.ts#L116-L117), [`src/actions.ts:143-144`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/actions.ts#L143-L144)

**What goes wrong:** A user who adds **Toggle Option**, **Press Button**, **Set Enum** or **Set Slider** to a button by hand finds the **Option** dropdown with no selection. Until they pick an entry, pressing the button does nothing and Companion may flag the option as invalid. Presets are unaffected because they set the option.

**Why it happens:** Every **Option** dropdown has `default: ''`, and `''` isn't one of its choices.

**Fix:** default each dropdown to its first choice, for example by building the choices array once and using `choices[0].id` as the default.

### L5: Opening the connection settings leaks a native MIDI client each time

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/midi/midi.ts:62-86`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/midi/midi.ts#L62-L86), called from [`src/config.ts:11`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/config.ts#L11)

**What goes wrong:** Each time a user opens or refreshes the connection settings, the module opens a new native MIDI client to list the **MIDI Out** ports and never closes it. The clients stay until the garbage collector happens to finalise them; on Linux/ALSA each shows up as an extra sequencer client meanwhile, and over a long session they add to the module's memory use. Nothing is visible in Companion's UI.

**Why it happens:** `getOutputs()` creates `new node_midi.Output()` when no output is passed in and returns without calling `destroy()` on it.

**Fix:** remember whether `getOutputs()` created the client and destroy it in a `finally` block before returning.

### L6: Disabling the connection leaves a 1-second reconnect timer running

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:72-83`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L72-L83), [`src/main.ts:273-304`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L273-L304)

**What goes wrong:** Nothing visible to the user. When the connection is disabled or deleted, `destroy()` calls `reset()`, which always schedules a new 1-second timer. Nothing cancels it, so it outlives `destroy()` by about a second before its callback returns early. `destroy()` should leave no timers behind.

**Why it happens:** `reset()` aborts the previous timer and then always creates a new one, even with `doReconnect: false`, and `destroy()` doesn't abort that new timer afterwards.

**Fix:** in `reset()`, schedule the delayed reconnect only when `doReconnect` is true, or call `this.#resetTimeout.abort('destroyed')` at the end of `destroy()`.

### L7: Every feedback update rechecks feedbacks twice, once with ids that do not exist

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:569-573`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/main.ts#L569-L573)

**What goes wrong:** No visible error. On every world log line with feedback data, the module asks Companion to recheck feedbacks named after variables (such as `Gobo_03` or `AudioLink_12`), which don't exist as feedbacks, and then rechecks all 54 feedback types anyway. With many buttons this costs extra CPU on every state update.

**Why it happens:** The loop passes variable ids (which carry a `_NN` suffix for logical or section data) to `checkFeedbacks()`, with a cast that hides the mismatch, followed by an unconditional `checkAllFeedbacks()`.

**Fix:** collect the base feedback ids (`returnedValue.mapping.name`, plus `connected` when needed) into a set and call `this.checkFeedbacks(...ids)` once, dropping `checkAllFeedbacks()`; or keep only `checkAllFeedbacks()` and remove the loop and the cast.

### L8: Nine ts-expect-error comments switch off type checking of preset feedbacks

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:183`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L183), [`src/presets.ts:196`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L196), [`src/presets.ts:211`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L211), [`src/presets.ts:348`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L348), [`src/presets.ts:361`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L361), [`src/presets.ts:374`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L374), [`src/presets.ts:541`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L541), [`src/presets.ts:554`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L554), [`src/presets.ts:569`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/presets.ts#L569)

**What goes wrong:** Nothing visible today, but a future rename of a feedback mapping, or a mismatched option set like the one in [M3](#m3-red-value-feedback-never-lights-on-the-general-spot-width-wash-width-and-gobo-spin-speed-slider-presets), would build cleanly and ship presets whose feedbacks never light.

**Why it happens:** The feedback mapping's `name` is typed as a plain string, so every preset feedback is wrapped in `// @ts-expect-error`, which suppresses all type checking of that object, options included.

**Fix:** type `FeedbackMappings.name` as `keyof FeedbacksSchema` (or narrow it with a type guard or a `satisfies` lookup table), build each preset feedback as a typed `CompanionPresetFeedback`, and remove the `@ts-expect-error` comments.

### L9: Logical Mapping option needs raw numbers in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/mapping/logical_mappings_enum.ts:38-43`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/mapping/logical_mappings_enum.ts#L38-L43)

**What goes wrong:** A user who switches the **Logical Mapping** option (actions) or **Logical** option (feedbacks) to expression mode, to drive it from a variable, must type a bare number such as `3` for DancerPodium_Right, because the dropdown ids are 0 to 19, not names. This is a first release, so it is the cheapest time to change; after release, changing the ids needs an upgrade script.

**Why it happens:** The dropdown choices map each enum entry to `{ id: Number(option), label: ... }`.

**Fix:** either keep the numeric ids and add an `expressionDescription` listing them (`0 = Floor_Left, 1 = Floor_Right, ...`), or switch the ids to the enum names and convert them to numbers in the callbacks.

## 💡 Nice to Have

### N1: Feedback names, descriptions and Value options are raw identifiers with no guidance

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:370-1813`](https://github.com/bitfocus/companion-module-tlof-neoluma-midi-control/blob/b8f791f064763ff1bb9e1ea24bc7629525cd1205/src/feedbacks.ts#L370-L1813)

**What goes wrong:** In the feedback picker, users see names like `MovingHeadStrobeSpeed`, `WallLineColors` or `MacroBypassApply`, and each description repeats the name. Every feedback has a bare **Value** number field (0-1, 0-7 or 0-127) with no explanation of what the numbers mean (for example which Flasher value is which mode), and on/off feedbacks use a 0-1 number instead of a checkbox or dropdown.

**Why it happens:** The definitions are generated from the mapping table, using the mapping name for both `name` and `description` and a generic `{ type: 'number', id: 'value', label: 'Value' }` option.

**Fix:** use readable names and descriptions (for example "Moving head strobe speed equals value"), add a description or tooltip to the Value option listing what each value means, and use a dropdown for enum-type values (Flasher, Gobo, colours).

## 📝 Additional Notes

- First release (never published): there is no previous tag to diff against, so the whole module was reviewed and every finding is classified 🆕 NEW.
- The `tsconfig.build.json` difference from the template (Node 22 preset plus extra `module` / `moduleResolution` / `alwaysStrict` options) is covered by the fix in [C1](#c1-module-runs-on-node-22-instead-of-the-node-26-runtime-that-api-21-modules-use).
