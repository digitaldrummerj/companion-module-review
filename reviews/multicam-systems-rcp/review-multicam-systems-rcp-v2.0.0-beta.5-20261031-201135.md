# Review: multicam-systems-rcp v2.0.0-beta.5

| Field | Value |
| --- | --- |
| **Module** | [companion-module-multicam-systems-rcp](https://github.com/bitfocus/companion-module-multicam-systems-rcp) |
| **Scope** | `tag` (`v1.0.3..v2.0.0-beta.5`) |
| **Version** | v2.0.0-beta.5 (`4775000`) |
| **Release** | Update — last published v1.0.3 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-10-31 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The RCP integration API (1.0-preview) has no equivalent of the old per-user camera preview selection, so the two removed actions cannot simply be re-implemented and an upgrade mapping or a deprecation stub is the realistic fix | the commit history and the replacement "Controller: Select Choice" action; what the device API offers was not checked | [M1](#m1-buttons-using-user-select-camera-or-user-clear-camera-selection-stop-working-after-the-upgrade) |
| A2 | RCP pushes state often enough that a stale deck slot colour is corrected within a short time (every state push runs `checkAllFeedbacks`) | how often the device pushes state is not visible in the module code | [L4](#l4-stream-deck-plus-slot-colour-and-step-label-do-not-refresh-after-a-bank-or-step-size-change) |

## 📋 Issues

### Blocking

- [ ] [C1: Module runs on Node 22 while the API 2.1 template uses Node 26](#c1-module-runs-on-node-22-while-the-api-21-template-uses-node-26)
- [ ] [C2: Pre-commit hook differs from the template](#c2-pre-commit-hook-differs-from-the-template)

### Non-blocking

- [ ] [M1: Buttons using User: Select Camera or User: Clear Camera Selection stop working after the upgrade](#m1-buttons-using-user-select-camera-or-user-clear-camera-selection-stop-working-after-the-upgrade)
- [ ] [M2: Missing node.yaml CI workflow](#m2-missing-nodeyaml-ci-workflow)
- [ ] [M3: Missing release.yaml workflow](#m3-missing-releaseyaml-workflow)
- [ ] [M4: Action and feedback options are untyped, so option mistakes are not caught at build time](#m4-action-and-feedback-options-are-untyped-so-option-mistakes-are-not-caught-at-build-time)
- [ ] [L1: Debug Messages no longer logs any WebSocket traffic](#l1-debug-messages-no-longer-logs-any-websocket-traffic)
- [ ] [L2: Connection failures show one generic message and the real cause is never logged](#l2-connection-failures-show-one-generic-message-and-the-real-cause-is-never-logged)
- [ ] [L3: Command errors from a non-JSON reply log a JSON parse error instead of the HTTP status](#l3-command-errors-from-a-non-json-reply-log-a-json-parse-error-instead-of-the-http-status)
- [ ] [L4: Stream Deck Plus slot colour and step label do not refresh after a bank or step-size change](#l4-stream-deck-plus-slot-colour-and-step-label-do-not-refresh-after-a-bank-or-step-size-change)
- [ ] [L5: User (for user setting) and Off Color options are always shown, even when they do nothing](#l5-user-for-user-setting-and-off-color-options-are-always-shown-even-when-they-do-nothing)
- [ ] [L6: Connection settings show cloud fields for a Local RCP and host, port and HTTPS fields for Multicam Cloud](#l6-connection-settings-show-cloud-fields-for-a-local-rcp-and-host-port-and-https-fields-for-multicam-cloud)
- [ ] [N1: Controller choice ids are JSON strings, hard to type in expression mode](#n1-controller-choice-ids-are-json-strings-hard-to-type-in-expression-mode)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Module runs on Node 22 while the API 2.1 template uses Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:17`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/companion/manifest.json#L17), [`package.json:24`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/package.json#L24), [`package.json:35`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/package.json#L35), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/tsconfig.build.json#L2), [`.github/workflows/companion-module-checks.yaml:20`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/.github/workflows/companion-module-checks.yaml#L20)

**What goes wrong:** This release moves the module to API 2.1, whose template runs on Node 26, but the module still asks Companion for the Node 22 runtime and builds, type-checks and tests against Node 22. A module that doesn't match its API level's template is harder to troubleshoot later, because problems can't be compared against the reference setup.

**Why it happens:** The Node version is set in five places, and none of them were moved to Node 26 with the API 2.1 upgrade.

**Evidence:** validator expected vs found:

```text
companion/manifest.json  runtime.type          found 'node22'                                          expected 'node26'
package.json             engines.node          found '^22.20 || ^26.5'                                 expected '^26'
package.json             @types/node           found '^22.18.13'                                       expected '^26.6.4'
tsconfig.build.json      extends               found '@companion-module/tools/tsconfig/node22/recommended-esm.json'  expected '@companion-module/tools/tsconfig/node26/recommended.json'
.github/workflows/companion-module-checks.yaml:20  node-version  found '22.23.1'                      expected 26.x
```

**Confirm by:** compare the five places above with `companion-module-template-ts` @ `e0d42b7`.

**Fix:** move every place to Node 26:

- [ ] `companion/manifest.json`: `"runtime": { "type": "node26" }`
- [ ] `package.json`: `"engines": { "node": "^26" }`
- [ ] `package.json`: `"@types/node": "^26.6.4"` in `devDependencies`
- [ ] `tsconfig.build.json`: `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"`
- [ ] `.github/workflows/companion-module-checks.yaml` line 20: `node-version: 26.x`

### C2: Pre-commit hook differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.husky/pre-commit:1`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/.husky/pre-commit#L1)

**What goes wrong:** The pre-commit hook doesn't match the template, so the module's tooling setup drifts from the reference every other module uses.

**Why it happens:** The hook runs `yarn lint-staged` where the template's hook runs `lint-staged`.

**Evidence:** validator expected vs found:

```text
.husky/pre-commit line 1: found 'yarn lint-staged', template 'lint-staged'
```

**Confirm by:** open [`.husky/pre-commit`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/.husky/pre-commit#L1) and compare it with the template's `.husky/pre-commit`.

**Fix:** copy the template's `.husky/pre-commit`.

```text
lint-staged
```

## 🟡 Medium

### M1: Buttons using User: Select Camera or User: Clear Camera Selection stop working after the upgrade

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.ts`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/actions.ts), [`src/upgrades.ts`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/upgrades.ts), [`README.md:57`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/README.md#L57)

**What goes wrong:** A user who built buttons on v1.0.3 with "User: Select Camera" (`select_user_preview`), for example user "Director" + camera "CAM 2", or with "User: Clear Camera Selection" (`clear_user_preview`), upgrades to v2.0.0-beta.5. Those actions no longer exist, so the buttons show an unknown action and pressing them does nothing. Nothing in HELP.md tells them, and [`README.md:57`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/README.md#L57) says the opposite: "Saved action/feedback IDs and explicit host/port settings are retained on upgrade."

**Why it happens:** Both actions were deleted in this release together with the old socket.io camera-preview call. The new "Controller: Select Choice" action covers the same idea with a different set of options, but no upgrade script maps or flags the old action ids (the new `v1_to_v2` script returns no updated actions).

**Evidence:**

```ts
// v1.0.3 src/actions.ts:688-690 (removed in v2.0.0-beta.5)
	actions['select_user_preview'] = {
		name: 'User: Select Camera',
		description: 'Set which camera a user is previewing/controlling',
```

```markdown
<!-- README.md:57 -->
Saved action/feedback IDs and explicit host/port settings are retained on upgrade.
```

**Fix:** do one of these, and in every case correct README.md:57 so it no longer claims all saved action IDs are kept:

- add an upgrade script that rewrites `select_user_preview` to `controller_select` where the user's switcher choice can be found;
- keep both ids as actions that log a clear "no longer supported, use Controller: Select Choice" warning, so old buttons don't go silent; or
- at least list the removed actions and their replacement in `companion/HELP.md`.

### M2: Missing node.yaml CI workflow

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml`

**What goes wrong:** The template's `node.yaml` workflow is missing from the module, so the module doesn't run the standard CI the template sets up.

**Why it happens:** The file is tracked by the template but not present in the module.

**Fix:** copy the template's `.github/workflows/node.yaml`.

### M3: Missing release.yaml workflow

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml`

**What goes wrong:** The template's `release.yaml` workflow is missing from the module, so the module doesn't use the standard release workflow the template sets up.

**Why it happens:** The file is tracked by the template but not present in the module.

**Fix:** copy the template's `.github/workflows/release.yaml`.

### M4: Action and feedback options are untyped, so option mistakes are not caught at build time

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/companion.ts:31-34`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/companion.ts#L31-L34)

**What goes wrong:** No visible effect for users today; this is code quality. Because every option is typed as a generic value, a renamed option id or a wrong value in a preset (for example `step_size: 'medium'`) compiles cleanly and only shows up when a button fails in Companion.

**Why it happens:** The module's type setup declares no schema for its actions and feedbacks, so the callbacks read options with casts throughout (`action.options.camera as string`, `action.options.mode as string`, …). The code is deliberately shared with a Companion 4 / API 1.13 line, which explains the choice, but API 2 recommends schema-typed definitions.

```ts
// src/companion.ts:31-34
export type ActionDefinitions = CompanionActionDefinitions<Record<string, { options: CompanionOptionValues }>>

export type ModuleTypes = InstanceTypes & { config: ModuleConfig; secrets: ModuleSecrets }
```

**Fix:** declare an actions/feedbacks schema in `ModuleTypes` and build the definitions from it, so presets and callbacks are type-checked (the companion-v2-actions and companion-v2-feedbacks skills show the pattern).

```ts
type ActionsSchema = {
	float_increase: { options: { camera: string; property: string; step_size: 'user_setting' | 'big' | 'normal' | 'small'; user: string } }
	// …
}
export type ModuleTypes = InstanceTypes & { config: ModuleConfig; secrets: ModuleSecrets; actions: ActionsSchema }
```

## 🟢 Low

### L1: Debug Messages no longer logs any WebSocket traffic

- **Source:** 🔎 protocol reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/config.ts:106-113`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/config.ts#L106-L113)

**What goes wrong:** A user troubleshooting the connection ticks "Debug Messages" in the connection settings, whose tooltip says it will "Log incoming and outgoing WebSocket messages". In v1.0.3 it did. In v2.0.0-beta.5 it only logs one line when presets are rebuilt ("UpdatePresets: 3 cameras, 2 users"); no state messages, resync requests or commands are logged, so the option looks broken.

**Why it happens:** The connection code was rewritten into [`src/api.ts`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/api.ts), and nothing there reads the `debug_messages` setting. Its only remaining use is [`src/presets/index.ts:41`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/presets/index.ts#L41).

**Fix:** pass a logger into the API class and log received messages, resync requests and command payloads/results when Debug Messages is on; or change the tooltip (or drop the option) so it matches what it now does.

### L2: Connection failures show one generic message and the real cause is never logged

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/api.ts:216-220`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/api.ts#L216-L220), [`src/api.ts:254`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/api.ts#L254), [`src/instance.ts:301`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/instance.ts#L301)

**What goes wrong:** Whether the user entered a wrong cloud client secret, a local RCP rejects the token (HTTP 401), or the host is unreachable, the connection shows Connection Failure with "API disconnected; verify host, token and project access" and the log says nothing more. The specific "Cloud authentication failed (401)" error is never shown. In v1.0.3 the status carried the actual error message.

**Why it happens:** When opening the connection fails, the error is caught and thrown away, and the socket's error handler ignores its error too. The close callback takes no reason, so the instance can only show a fixed text.

**Fix:** pass the error (or the close code and reason) through the close callback, and show it in the Connection Failure status or at least log it.

```ts
void this.open().catch((err) => {
	if (!this.closed) this.onClose(err?.message)
})
```

### L3: Command errors from a non-JSON reply log a JSON parse error instead of the HTTP status

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:285-287`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/api.ts#L285-L287)

**What goes wrong:** When the RCP or the cloud gateway answers a command with a non-JSON body, for example a plain-text 401 or a 502 HTML page, pressing any button logs something like "Unexpected token '<' ..." instead of "Command rejected (401)", so the user can't see that the token or the gateway is the problem.

**Why it happens:** The reply is parsed as JSON before the HTTP status is checked, so the parse error is thrown first and hides the status code.

**Fix:** parse leniently (or check `response.ok` first), so the `Command rejected (${response.status})` message is the one that gets logged.

```ts
const result = (await response.json().catch(() => ({}))) as { status?: string; error?: { message?: string }; errorCode?: string }
```

### L4: Stream Deck Plus slot colour and step label do not refresh after a bank or step-size change

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:672-683`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/instance.ts#L672-L683), [`src/instance.ts:721-725`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/instance.ts#L721-L725)

**What goes wrong:** On the Stream Deck + page, the operator presses the Exposure bank button ("Deck: Select control bank"). The values and names of the four gauges update, but their colours keep the previous bank's red/green/blue until RCP sends its next state update. Likewise, when the step size is changed with the "User: Set Step Size" preset buttons instead of by pushing the encoder, the FINE/NORMAL/COARSE label on the gauges stays on the old value.

**Why it happens:** Selecting a bank refreshes the deck slot feedbacks but leaves out the slot colour feedback (`deck_slot_accent`). Setting the step size refreshes only `user_step_size`; only the encoder's step-cycle action also refreshes the step label (`deck_step_label`).

**Fix:** add `'deck_slot_accent'` to the `checkFeedbacks` call in `setUserBank`, and `'deck_step_label'` to the one in `setUserStepSize`.

### L5: User (for user setting) and Off Color options are always shown, even when they do nothing

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.ts:245-251`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/actions.ts#L245-L251), [`src/actions.ts:304-310`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/actions.ts#L304-L310), [`src/actions.ts:474-480`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/actions.ts#L474-L480), [`src/actions.ts:534-540`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/actions.ts#L534-L540), [`src/actions.ts:606-612`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/actions.ts#L606-L612), [`src/feedbacks.ts:156-161`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/feedbacks.ts#L156-L161)

**What goes wrong:** In v1.0.3, "Property: Increase" / "Property: Decrease", "PTZ: Recall/Store Preset" and "PTZ: Preset" showed the "User (for user setting)" dropdown only when Step Size, Mode or Action was set to "Use User Setting", and "Camera Tally: Dynamic Color" showed "Off Color" only when "Set color when tally is off" was ticked. Now these fields are always visible, so a user who sets Step Size = Normal still sees a User dropdown and may think it matters.

**Why it happens:** The v1 show/hide functions (`isVisible`) were removed, as API 2 requires, but were never replaced with the API 2 equivalent, an expression (`isVisibleExpression`).

**Fix:** add `disableAutoExpression: true` to each controlling dropdown or checkbox (`step_size`, `mode`, `action`, `set_off_color`), then give each dependent field an `isVisibleExpression`. In action and feedback options, an `isVisibleExpression` may only reference fields with `disableAutoExpression`.

```ts
isVisibleExpression: "$(options:step_size) == 'user_setting'"
isVisibleExpression: "$(options:mode) == 'user_setting'"
isVisibleExpression: "$(options:action) == 'user_setting' || $(options:mode) == 'user_setting'"
isVisibleExpression: '$(options:set_off_color)'
```

### L6: Connection settings show cloud fields for a Local RCP and host, port and HTTPS fields for Multicam Cloud

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:33-97`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/config.ts#L33-L97)

**What goes wrong:** With Connection = "Local RCP", the settings page still shows "Cloud API URL", "Cloud integration client ID", "Cloud integration client secret", "Cloud project ID" and "Target instance ID". With Connection = "Multicam Cloud (preview)", it still shows "Target IP", "Port", "Use HTTPS / WSS" and "Integration API token", which the cloud connection ignores. Users may fill in the wrong fields and wonder why the connection fails.

**Why it happens:** The cloud fields have no show/hide expression, and the host, port and HTTPS fields only check whether a discovered device is selected, not the connection type.

**Fix:** show each field only for its connection type.

```ts
// cloudUrl, cloudClientId, cloudClientSecret, cloudProjectId, cloudInstanceId
isVisibleExpression: "$(options:connection) == 'cloud'"
// host, port, tls
isVisibleExpression: "$(options:connection) != 'cloud' && !$(options:bonjourHost)"
// token
isVisibleExpression: "$(options:connection) != 'cloud'"
```

## 💡 Nice to Have

### N1: Controller choice ids are JSON strings, hard to type in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/controllers.ts:24-40`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/4775000dd4a82ce701fe672a97ddcec1c28685b2/src/controllers.ts#L24-L40)

**What goes wrong:** A user who switches the "Controller switcher / choice" option of "Controller: Select Choice" to expression mode must type a JSON array such as `["sw-1","cam-3"]` exactly, quotes included, instead of a readable id.

**Why it happens:** Each dropdown id is built with `JSON.stringify([switcher.id, choice.id])`.

**Fix:** use a simpler id (e.g. `` `${switcher.id}/${choice.id}` ``), split the option into two dropdowns, or set `disableAutoExpression: true` if expressions aren't meant to be used here.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template (line 7: found `"module": "NodeNext",`, template `"rootDir": "./src",`). Fine as long as the module builds — no change required. (The preset `extends` line is part of [C1](#c1-module-runs-on-node-22-while-the-api-21-template-uses-node-26).)
