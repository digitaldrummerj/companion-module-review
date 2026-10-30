# Review: companion-module-testbildmedia-stgtime v1.0.3

| Field | Value |
| --- | --- |
| **Module** | `companion-module-testbildmedia-stgtime` |
| **Version** | v1.0.3 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Scope** | `tag` (first release: no previous tag, so the whole module was reviewed) |
| **Commit** | [`e2c361e`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/tree/e2c361ef1412fc354842d698a8a5f830b7e0e154) |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The STGTIME device answers an invalid request (a message longer than 64 characters, an unknown preset id) with an HTTP 4xx status and a JSON `error` body, rather than accepting or truncating it | The option labels state device-side limits ("maximum 64 characters", "maximum 8 characters"), and `StgtimeClient.request()` throws `StgtimeApiError` on a non-OK response and reads its `error` field; the device itself was not checked | [L1](#l1-a-rejected-action-briefly-shows-the-connection-as-failed), [L4](#l4-load-stgtime-preset-buttons-do-nothing-when-the-preset-is-not-in-the-current-device-list) |
| A2 | Companion does not skip re-sending an unchanged value-feedback result (the large display-image data URL) on every `checkAllFeedbacks()` call | `InstanceBase.checkAllFeedbacks()` in base 2.1.3 just forwards to the host; whether the host compares against the previous value is not visible in the module package | [L3](#l3-display-preview-image-is-downloaded-on-every-poll-even-when-no-button-shows-it) |
| A3 | Companion 5 checks an action's dropdown value against the current choices, and a number value against min/max, when the action runs, and skips the action when the value doesn't fit (unless `allowCustom` / `clampValues` is set) | The v2.0 compliance reference ("Expression validation"); Companion's host source was not inspected | [M3](#m3-adjust-time-unit-option-only-accepts-raw-millisecond-numbers-in-expression-mode), [L4](#l4-load-stgtime-preset-buttons-do-nothing-when-the-preset-is-not-in-the-current-device-list), [L5](#l5-set-time-buttons-do-nothing-when-an-expression-returns-more-than-59-minutes-or-seconds) |

## 📋 Issues

### Blocking

- [ ] [C1: .gitattributes file is missing](#c1-gitattributes-file-is-missing)
- [ ] [C2: .gitignore is missing template entries](#c2-gitignore-is-missing-template-entries)
- [ ] [C3: Husky pre-commit hook is missing](#c3-husky-pre-commit-hook-is-missing)
- [ ] [C4: .prettierignore differs from the template](#c4-prettierignore-differs-from-the-template)
- [ ] [C5: eslint.config.mjs differs from the template](#c5-eslintconfigmjs-differs-from-the-template)
- [ ] [C6: package.json is missing the postinstall script](#c6-packagejson-is-missing-the-postinstall-script)
- [ ] [C7: package.json is missing the build:main script](#c7-packagejson-is-missing-the-buildmain-script)
- [ ] [C8: package.json is missing the lint:raw script](#c8-packagejson-is-missing-the-lintraw-script)
- [ ] [C9: husky devDependency is missing](#c9-husky-devdependency-is-missing)
- [ ] [C10: lint-staged devDependency is missing](#c10-lint-staged-devdependency-is-missing)
- [ ] [C11: lint-staged section is missing from package.json](#c11-lint-staged-section-is-missing-from-packagejson)
- [ ] [C12: Module runs on Node 22 instead of the Node 26 runtime of the API 2.1 template](#c12-module-runs-on-node-22-instead-of-the-node-26-runtime-of-the-api-21-template)

### Non-blocking

- [ ] [M1: GitHub CI workflow node.yaml is missing](#m1-github-ci-workflow-nodeyaml-is-missing)
- [ ] [M2: GitHub release workflow release.yaml is missing](#m2-github-release-workflow-releaseyaml-is-missing)
- [ ] [M3: Adjust time Unit option only accepts raw millisecond numbers in expression mode](#m3-adjust-time-unit-option-only-accepts-raw-millisecond-numbers-in-expression-mode)
- [ ] [L1: A rejected action briefly shows the connection as failed](#l1-a-rejected-action-briefly-shows-the-connection-as-failed)
- [ ] [L2: Action and preset lists are re-sent to Companion every 30 seconds](#l2-action-and-preset-lists-are-re-sent-to-companion-every-30-seconds)
- [ ] [L3: Display preview image is downloaded on every poll even when no button shows it](#l3-display-preview-image-is-downloaded-on-every-poll-even-when-no-button-shows-it)
- [ ] [L4: Load STGTIME preset buttons do nothing when the preset is not in the current device list](#l4-load-stgtime-preset-buttons-do-nothing-when-the-preset-is-not-in-the-current-device-list)
- [ ] [L5: Set time buttons do nothing when an expression returns more than 59 minutes or seconds](#l5-set-time-buttons-do-nothing-when-an-expression-returns-more-than-59-minutes-or-seconds)
- [ ] [L6: Aborting a running button does not cancel its pending request to the timer](#l6-aborting-a-running-button-does-not-cancel-its-pending-request-to-the-timer)
- [ ] [N1: Clearing the host field silently connects to stgtime.local](#n1-clearing-the-host-field-silently-connects-to-stgtimelocal)
- [ ] [N2: Unreachable-device status shows a vague fetch failed message](#n2-unreachable-device-status-shows-a-vague-fetch-failed-message)
- [ ] [N3: Typos in preset button actions are not caught at build time](#n3-typos-in-preset-button-actions-are-not-caught-at-build-time)
- [ ] [N4: Threshold and duration options are free-text boxes instead of number fields](#n4-threshold-and-duration-options-are-free-text-boxes-instead-of-number-fields)
- [ ] [N5: Fixed-choice options show an expression toggle that rarely makes sense](#n5-fixed-choice-options-show-an-expression-toggle-that-rarely-makes-sense)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: .gitattributes file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes`

**What goes wrong:** The repository has no `.gitattributes`, which every module built from the template carries. Without it, line endings and file handling can differ between contributors' machines.

**Expected vs found:** the template tracks `.gitattributes`; the module has none.

**Fix:** copy `.gitattributes` from `companion-module-template-ts` unchanged.

### C2: .gitignore is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** `.gitignore`

**What goes wrong:** Build output, local tooling folders and debug files can be committed by accident, because the module's `.gitignore` leaves out entries the template ignores.

**Expected vs found:** missing template entries `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`. Extra module entries are allowed.

**Fix:** add the missing template entries to `.gitignore` (keep your own extra entries if you want them).

### C3: Husky pre-commit hook is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit`

**What goes wrong:** Commits are not formatted and linted automatically before they land, as they are in every template-based module.

**Expected vs found:** the template tracks `.husky/pre-commit` (it runs `lint-staged`); the module has none.

**Fix:** copy `.husky/pre-commit` from the template. It goes together with C6, C9, C10 and C11.

### C4: .prettierignore differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore`

**What goes wrong:** Prettier formats a different set of files than in other modules, so formatting checks behave differently from the template.

**Expected vs found:** line 1 is `node_modules/`; the template's line 1 is `package.json`.

**Fix:** replace `.prettierignore` with the template's copy.

### C5: eslint.config.mjs differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:3`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/eslint.config.mjs#L3)

**What goes wrong:** The lint setup is built differently from the template, which makes later lint troubleshooting and template updates harder.

**Expected vs found:** line 3 is `export default [` (the `generateEslintConfig` result is spread into an array); the template has `export default generateEslintConfig({`.

**Fix:** replace `eslint.config.mjs` with the template's copy.

### C6: package.json is missing the postinstall script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-15`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/package.json#L7-L15)

**What goes wrong:** Installing dependencies does not set up the Git hooks, so the pre-commit check (C3) never runs.

**Expected vs found:** the template defines a `postinstall` script; the module does not.

**Fix:** add the template's `postinstall` script to `package.json`.

### C7: package.json is missing the build:main script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-15`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/package.json#L7-L15)

**What goes wrong:** The build scripts don't follow the template's layout, so the standard build commands other modules use don't exist here.

**Expected vs found:** the template defines `build:main`; the module does not.

**Fix:** add the template's `build:main` script (and point `build` at it as the template does).

### C8: package.json is missing the lint:raw script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-15`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/package.json#L7-L15)

**What goes wrong:** The lint scripts don't follow the template's layout, which `lint-staged` and CI rely on.

**Expected vs found:** the template defines `lint:raw`; the module does not.

**Fix:** add the template's `lint:raw` script (and make `lint` use it as the template does).

### C9: husky devDependency is missing

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** `package.json`

**What goes wrong:** The Git hook tool the template uses is not installed, so the pre-commit hook (C3) cannot run.

**Expected vs found:** the template has the devDependency `husky`; the module does not.

**Fix:** add `husky` to `devDependencies` at the template's version.

### C10: lint-staged devDependency is missing

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** `package.json`

**What goes wrong:** The tool that lints and formats staged files on commit is not installed.

**Expected vs found:** the template has the devDependency `lint-staged`; the module does not.

**Fix:** add `lint-staged` to `devDependencies` at the template's version.

### C11: lint-staged section is missing from package.json

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** `package.json`

**What goes wrong:** Even with `lint-staged` installed, nothing tells it what to check on commit.

**Expected vs found:** the template's `package.json` has a `lint-staged` section; the module's has none.

**Fix:** copy the template's `lint-staged` section into `package.json`.

### C12: Module runs on Node 22 instead of the Node 26 runtime of the API 2.1 template

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:16-21`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/companion/manifest.json#L16-L21), [`tsconfig.build.json`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/tsconfig.build.json)

**What goes wrong:** The module targets API 2.1 (Companion 5.0+) but asks Companion for the Node 22 runtime, where the API 2.1 template uses Node 26. A module that doesn't match its API level's template is harder to troubleshoot later.

**Expected vs found:** `runtime.type` is `node22`; the API 2.1 template uses `node26`. `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`; the template extends `@companion-module/tools/tsconfig/node26/recommended.json`.

**Fix:** set `runtime.type` to `node26` in `companion/manifest.json`, and make `tsconfig.build.json` extend `@companion-module/tools/tsconfig/node26/recommended.json`, as the template does.

## 🟡 Medium

### M1: GitHub CI workflow node.yaml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml`

**What goes wrong:** Pushes and pull requests are not built and linted on GitHub, so a broken build is only found at release time.

**Fix:** copy `.github/workflows/node.yaml` from the template.

### M2: GitHub release workflow release.yaml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml`

**What goes wrong:** Tagged releases are not built and packaged by the standard template workflow.

**Fix:** copy `.github/workflows/release.yaml` from the template.

### M3: Adjust time Unit option only accepts raw millisecond numbers in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:109-118`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L109-L118)

**What goes wrong:** A user who switches the "Unit" option of "Timer: Adjust time" to expression mode (for example to pick the unit from a variable) has to produce the raw number `60000` or `1000`. Typing `minutes` or `seconds` fails validation, and Companion skips the action without a visible error, so the button does nothing.

**Why it happens:** In API 2.x every non-text option can be switched to expression mode, and the computed value must match one of the dropdown's choice ids. The choices are `{ id: 1000, label: 'Seconds' }` and `{ id: 60000, label: 'Minutes' }`, so the ids are internal multipliers, not friendly names. The "+1 MIN" / "-1 MIN" presets ([`src/presets.ts:189`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/presets.ts#L189), [`src/presets.ts:192`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/presets.ts#L192)) store `unit: 60000`.

**Fix:** this is the first release, so no upgrade script is needed yet. Use friendly ids and convert to milliseconds in the callback; update the `ActionsSchema` type to `unit: 'seconds' | 'minutes'` and the two presets.

```ts
choices: [
	{ id: 'seconds', label: 'Seconds' },
	{ id: 'minutes', label: 'Minutes' },
],
// callback
const ms = event.options.unit === 'seconds' ? 1000 : 60000
```

## 🟢 Low

### L1: A rejected action briefly shows the connection as failed

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:80-88`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/main.ts#L80-L88), [`src/main.ts:124-134`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/main.ts#L124-L134)

**What goes wrong:** An operator presses a "Message: Set content" button with a 70-character message (the label says 64 is the maximum). The device rejects it, and the module treats that like a lost connection: the connection status turns red with the device's error text, `$(stgtime:connected)` becomes false and every "Device is connected" feedback turns off. It recovers on the next poll (250 ms to 2 s later), so the operator sees a short false "disconnected" flash instead of a plain "action rejected" message, and may mistake their own input for a network outage.

**Why it happens:** `send()` passes every error to `handleError()`. That function always sets `connected = false`, clears the `connected` variable, re-checks all feedbacks and sets the "Connection Failure" status, even for an HTTP 4xx `StgtimeApiError`, which shows the device is reachable and simply refused the request. This depends on [A1](#-assumptions-to-confirm).

**Fix:** in `send()`, call `handleError()` only for network errors, timeouts and 401/403 responses. For other `StgtimeApiError` statuses, log a warning and rethrow, leaving the connection status alone.

```ts
} catch (error) {
	if (error instanceof StgtimeApiError && error.status >= 400 && error.status < 500 && error.status !== 401 && error.status !== 403) {
		this.log('warn', `Action rejected: ${error.message}`)
	} else {
		this.handleError(error)
	}
	throw error
}
```

### L2: Action and preset lists are re-sent to Companion every 30 seconds

- **Source:** 🔎 protocol reviewer + compliance reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:105-109`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/main.ts#L105-L109)

**What goes wrong:** While connected, the module sends Companion the full action and preset definitions again about every 30 seconds, even when nothing on the STGTIME has changed. A user browsing the action picker or the Presets tab can see the list rebuilt under them, and Companion does the extra work in the background. Nothing breaks.

**Why it happens:** `poll()` fetches `/config` again roughly every 30 seconds and then always calls `updateActions(this)` and `updatePresets(this)`, without checking whether the device's preset list changed.

**Fix:** remember the last preset list and re-send the definitions only when it differs. Keep refreshing `deviceConfig` on the 30-second schedule.

```ts
const key = JSON.stringify(this.deviceConfig.presets.map((p) => [p.id, p.name, p.durationMs]))
if (key !== this.lastPresetKey) {
	this.lastPresetKey = key
	updateActions(this)
	updatePresets(this)
}
```

### L3: Display preview image is downloaded on every poll even when no button shows it

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:99-102`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/main.ts#L99-L102), [`src/main.ts:116`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/main.ts#L116)

**What goes wrong:** With the recommended 500 ms interval (or 250 ms), the module downloads `/api/v1/display.png` from the timer 2 to 4 times a second for as long as the connection is enabled, base64-encodes it and re-runs every feedback, including the "Live display image" feedback that returns the whole image. It does this even when no button uses the "Live STGTIME display" preset. Users see no difference, but it adds steady network, CPU and IPC load on the Companion host and on the small timer device.

**Why it happens:** `poll()` always requests `/display.png` alongside `/state` and then calls `checkAllFeedbacks()`. Nothing checks whether any display-image feedback is in use. The IPC cost depends on [A2](#-assumptions-to-confirm).

**Fix:** count active display-image feedbacks with `subscribe` / `unsubscribe` callbacks and fetch the PNG only while that count is above zero (or on a slower schedule than `/state`). Call `checkFeedbacks('display_image')` only when the image actually changes, and check the other feedbacks by id instead of `checkAllFeedbacks()` on every poll.

### L4: Load STGTIME preset buttons do nothing when the preset is not in the current device list

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:62-63`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L62-L63), [`src/actions.ts:167-176`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L167-L176)

**What goes wrong:** A button with "Timer: Load STGTIME preset" set to `show-intro` is skipped silently when the preset was renamed on the device, when the user picks the id with an expression (for example `$(custom:next_preset)`), or before the first successful poll, when the list holds only "No presets available". The user presses the button and nothing happens, with no error message.

**Why it happens:** The "Preset" dropdown is built from the device's `/config` preset list. Companion checks a dropdown value against the current choices before it runs the callback, and because `allowCustom` is not set, an unknown id makes Companion drop the action ([A3](#-assumptions-to-confirm)). The callback already handles a bad id itself: it throws on an empty id, and the device reports an unknown one ([A1](#-assumptions-to-confirm)).

**Fix:** add `allowCustom: true` to the `preset_id` dropdown so expression and stale ids reach the callback, which already reports errors. Optionally add an `expressionDescription` explaining the id format.

### L5: Set time buttons do nothing when an expression returns more than 59 minutes or seconds

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:91-93`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L91-L93)

**What goes wrong:** A user puts the "Minutes" option of "Timer: Set time" in expression mode, for example `$(custom:talk_length)` = 90. 90 is above the maximum of 59, so Companion skips the action without a visible error and the timer is not set. A value typed in the UI is constrained, but an expression result is not.

**Why it happens:** In API 2.x a computed number is checked against `min` / `max` and rejected unless `clampValues: true` is set ([A3](#-assumptions-to-confirm)). Hours max 99, Minutes max 59 and Seconds max 59 are tight limits for computed values, even though the callback converts everything to milliseconds anyway.

**Fix:** raise the limits (for example Minutes and Seconds max 5999), set `clampValues: true`, or add an `expressionDescription` that states the allowed range.

### L6: Aborting a running button does not cancel its pending request to the timer

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:70-309`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L70-L309)

**What goes wrong:** If a user aborts a running button (for example with an abort action while the device is slow to answer), the HTTP request to the STGTIME keeps going for up to 3 seconds, and the device may still apply the change after the user cancelled it. In normal use nothing is visible.

**Why it happens:** API 2.1 gives every action callback a `context.signal` that aborts when the result is no longer needed. The callbacks never pass it to `self.send()`, and `StgtimeClient.request()` only uses its own `AbortSignal.timeout(3000)`.

**Fix:** pass the callback's `context.signal` through `send()` and `request()` into `fetch`, combined with the timeout.

```ts
signal: AbortSignal.any([context.signal, AbortSignal.timeout(3000)])
```

## 💡 Nice to Have

### N1: Clearing the host field silently connects to stgtime.local

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:27`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/config.ts#L27)

**What goes wrong:** A user empties "STGTIME host or IP address" (for example to park the connection). The module does not stop or report a missing host; it quietly polls `stgtime.local`, which may reach a different STGTIME on the network or show a confusing name-lookup error.

**Why it happens:** `normalizeConfig` replaces an empty host with `'stgtime.local'`, so the `!this.config.host` check in `poll()` can never be true.

**Fix:** keep an empty host empty in `normalizeConfig` (leave the default only in the config field). In `init` / `configUpdated`, when the host is empty, set `InstanceStatus.BadConfig` with "Host is required" and skip polling.

### N2: Unreachable-device status shows a vague fetch failed message

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:132-133`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/main.ts#L132-L133)

**What goes wrong:** When the host is wrong or the device is off, the connection status shows Node's generic "fetch failed" or "The operation was aborted due to timeout", never the real cause such as `ECONNREFUSED` or `ENOTFOUND`. That makes a typo hard to tell apart from a powered-off device.

**Why it happens:** `handleError` uses only `error.message`; Node's `fetch` puts the real network error in `error.cause`.

**Fix:** include `error.cause?.code` (or `cause.message`) in the status message, and log the failure once per state change with `this.log('error', ...)`.

### N3: Typos in preset button actions are not caught at build time

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:21-22`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/presets.ts#L21-L22)

**What goes wrong:** No visible effect today. If an option id or value in a preset is mistyped (for example `{ operation: 'strat' }`), the build does not catch it and the preset button does nothing when pressed.

**Why it happens:** The `action()` helper takes `options: Record<string, unknown>` and casts the result to `CompanionPresetAction`, which bypasses the per-action option typing that base 2.1 provides.

**Fix:** type the helper generically, or write the action objects inline without a cast.

```ts
const action = <K extends keyof ActionsSchema>(actionId: K, options: ActionsSchema[K]['options']) => ({ actionId, options })
```

### N4: Threshold and duration options are free-text boxes instead of number fields

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:131-144`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L131-L144), [`src/actions.ts:235-248`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L235-L248)

**What goes wrong:** In "Timer: Set thresholds and colors" and "Video: Set state", the threshold and duration options are free text. A user can type "2 min" and only finds out when the action fails at runtime; a number field would show the problem in the editor.

**Why it happens:** `warning_seconds`, `critical_seconds`, `remaining_seconds` and `duration_seconds` are text inputs with `useVariables: true`, parsed with `Number()` in the callback. In API 2.x any number field can be switched to expression mode, so a text input is no longer needed to accept variables.

**Fix:** this is the first release, so no upgrade script is needed. Change the four options to `type: 'number'` with suitable `min` / `max`, update `ActionsSchema`, and drop `resolveSeconds`.

### N5: Fixed-choice options show an expression toggle that rarely makes sense

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:68`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L68), [`src/actions.ts:75-84`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L75-L84), [`src/actions.ts:207-217`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L207-L217), [`src/actions.ts:265-275`](https://github.com/bitfocus/companion-module-testbildmedia-stgtime/blob/e2c361ef1412fc354842d698a8a5f830b7e0e154/src/actions.ts#L265-L275)

**What goes wrong:** No functional problem. Users see an expression toggle on options such as Operation (Start / Stop / Toggle / Reset), Mode and Show / Hide / Toggle, where an expression rarely makes sense.

**Why it happens:** Since API 2.0, non-text options support expression mode automatically unless `disableAutoExpression: true` is set.

**Fix:** optionally set `disableAutoExpression: true` on these dropdowns. For any you keep, add an `expressionDescription` listing the valid ids.

## 📝 Additional Notes

- This is the module's first published release, so there is no previous tag to diff against and the whole module was reviewed. The repository has earlier tags (`v0.0.2`, `v1.0.0-beta`, `v1.0.1-beta`, `v1.0.2-beta`) that were never published.
- `yarn install --immutable`, `yarn package` and `yarn lint` all succeeded.
- The `tsconfig.build.json` difference from the template (Node 22 preset instead of `node26/recommended.json`) is part of the fix for [C12](#c12-module-runs-on-node-22-instead-of-the-node-26-runtime-of-the-api-21-template), not a separate note.
