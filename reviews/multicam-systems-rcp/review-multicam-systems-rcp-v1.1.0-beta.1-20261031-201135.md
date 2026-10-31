# Review: companion-module-multicam-systems-rcp v1.1.0-beta.1

| | |
| --- | --- |
| **Module** | `companion-module-multicam-systems-rcp` |
| **Scope** | `tag` (v1.0.3..v1.1.0-beta.1) |
| **Version** | v1.1.0-beta.1 |
| **Release** | Update — last published v1.0.3 |
| **API** | 1 (base 1.13.6, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`04fa9ab`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/commit/04fa9aba4bc2fb1872baf6a8853c41c1c817a015) |
| **Date** | 2026-10-31 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 4 shows a saved button action whose action ID the module no longer defines as unknown, and the action does nothing when pressed | general Companion host behaviour for removed action definitions; not checked in the Companion source | [M1](#m1-buttons-using-user-select-camera-or-user-clear-camera-selection-stop-working-after-the-update) |

## 📋 Issues

### Blocking

- [ ] [C1: Git pre-commit hook differs from the template](#c1-git-pre-commit-hook-differs-from-the-template)
- [ ] [H1: The Companion Module Checks workflow is replaced by a hand-written one](#h1-the-companion-module-checks-workflow-is-replaced-by-a-hand-written-one)

### Non-blocking

- [ ] [M1: Buttons using "User: Select Camera" or "User: Clear Camera Selection" stop working after the update](#m1-buttons-using-user-select-camera-or-user-clear-camera-selection-stop-working-after-the-update)
- [ ] [M2: The template's Node CI workflow is missing](#m2-the-templates-node-ci-workflow-is-missing)
- [ ] [L1: The "Debug Messages" checkbox no longer logs anything](#l1-the-debug-messages-checkbox-no-longer-logs-anything)
- [ ] [L2: Connection failures no longer say why](#l2-connection-failures-no-longer-say-why)
- [ ] [L3: Stream Deck+ slot colour and step-size label lag after a bank or step-size change](#l3-stream-deck-slot-colour-and-step-size-label-lag-after-a-bank-or-step-size-change)
- [ ] [L4: Cloud fields always show in the connection settings, and Target IP and Port show in cloud mode](#l4-cloud-fields-always-show-in-the-connection-settings-and-target-ip-and-port-show-in-cloud-mode)
- [ ] [L5: Fields from module API 2 are set in this API 1 module](#l5-fields-from-module-api-2-are-set-in-this-api-1-module)
- [ ] [N1: Connection status is re-sent to Companion on every state message](#n1-connection-status-is-re-sent-to-companion-on-every-state-message)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Git pre-commit hook differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** Pre-existing (v1.0.3 already had this line; the file is unchanged in this tag)
- **File:** [`.husky/pre-commit:1`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/.husky/pre-commit#L1)

**What goes wrong:** The git pre-commit hook doesn't match the API 1 TypeScript template. Every module on the same API level is expected to ship the template's hook unchanged, so tooling and troubleshooting behave the same across modules.

**Why it happens:** The hook runs `yarn lint-staged` where the template runs `lint-staged`.

**Evidence:** expected (template `companion-module-template-ts-v1/.husky/pre-commit:1`) `lint-staged`; found (`.husky/pre-commit:1`) `yarn lint-staged`.

**Confirm by:** open [`.husky/pre-commit:1`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/.husky/pre-commit#L1) and compare it with the template's single line.

**Fix:** replace the file with the template's single line.

```bash
lint-staged
```

## 🟠 High

### H1: The Companion Module Checks workflow is replaced by a hand-written one

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:1-46`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/.github/workflows/companion-module-checks.yaml#L1-L46)

**What goes wrong:** The repository no longer runs Bitfocus's shared module checks. Every Companion module calls the same reusable workflow, so a change Bitfocus makes to the checks reaches all modules at once. This module now runs its own copy of the steps, which won't pick up those changes.

**Why it happens:** This release rewrote the workflow. It adds a `pull_request:` trigger (line 5) and a top-level `permissions: contents: read` (lines 7-8). Lines 10-46 replace the template's single job, which calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` with its `if: ${{ !contains(github.repository, 'companion-module-template-') }}` guard and `permissions: packages: read`, with a hand-written job. That job runs `actions/checkout@v4` and `actions/setup-node@v4` (node-version `'22.23.1'`), then `yarn test`, lint, `companion-module-check`, package, an inline "Verify packaged API 1.13 entrypoint" script and `actions/upload-artifact@v4`. The comment on line 16 explains the reason: "The upstream reusable job removes contents permission and cannot clone this private fork."
**Evidence:** expected (template, line 4) `jobs:`; found (line 4-5) `pull_request:`.

```yaml
# .github/workflows/companion-module-checks.yaml:3-20
on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  check:
    name: Test and package Companion module
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      # The upstream reusable job removes contents permission and cannot clone this private fork.
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22.23.1'
```

**Confirm by:** `diff companion-module-templates/companion-module-template-ts-v1/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml`, or open [`.github/workflows/companion-module-checks.yaml:1-46`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/.github/workflows/companion-module-checks.yaml#L1-L46).

**Fix:** copy the template's `companion-module-checks.yaml` back in. If you want the packaged module as a build artifact, the only change to make is enabling `with: upload-artifact: true` on the template's job. Keep the private-fork workflow in the fork only.

## 🟡 Medium

### M1: Buttons using "User: Select Camera" or "User: Clear Camera Selection" stop working after the update

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/actions.ts:870-874`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/actions.ts#L870-L874), [`src/upgrades.ts:37-47`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/upgrades.ts#L37-L47), [`companion/HELP.md:57`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/companion/HELP.md#L57)

**What goes wrong:** An operator who built buttons in v1.0.3 with the actions "User: Select Camera" (`select_user_preview`) or "User: Clear Camera Selection" (`clear_user_preview`) upgrades to 1.1.0-beta.1. Those actions no longer exist, so Companion shows them as unknown and pressing the button does nothing. Anyone who dragged in the v1.0.3 "User controls" presets is affected too, because those presets used "User: Select Camera". The help text says "Existing action and feedback IDs are retained", so users have no reason to expect this and nothing tells them what to use instead.

**Why it happens:** This release deletes both action definitions; the "User Actions" section now only adds the controller and deck actions and the step-size and PTZ actions. The new upgrade script (`v1_to_v2`) migrates the connection settings but returns no updated actions, so saved buttons that use the old action IDs are not converted to anything.

**Evidence:**

```ts
// src/actions.ts:870-876
	// ===================
	// User Actions
	// ===================

	Object.assign(actions, controllerActions(self), deckActions(self))

	actions['set_user_step_size'] = {
// src/upgrades.ts:41-46
		// Keep saved host/port/action IDs. Authentication is newly required.
		return {
			updatedConfig: props.config ? { ...props.config, tls: props.config.tls ?? false } : null,
			updatedActions: [],
			updatedFeedbacks: [],
		}
```

```markdown
<!-- companion/HELP.md:57 -->
Existing action and feedback IDs are retained. Presets are classic buttons in a category
```

**Fix:** pick one of these, in order of preference:

- If the integration API can still select a user's camera, keep `select_user_preview` and `clear_user_preview`, implemented on the new API.
- Otherwise add an upgrade script that converts saved `select_user_preview` actions to "Controller: Select Choice" (`controller_select`) where that maps cleanly.
- If neither is possible, say in HELP.md and the release notes that these two actions were removed and which action replaces them.

In every case, correct the "Existing action and feedback IDs are retained" sentence in HELP.md.

### M2: The template's Node CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** Pre-existing (v1.0.3 also had only `companion-module-checks.yaml`)
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** The repository doesn't have the template's `node.yaml` workflow, which every module on this template is expected to carry.

**Why it happens:** Only `.github/workflows/companion-module-checks.yaml` exists; the template tracks `node.yaml` as well.

**Fix:** add the template's `.github/workflows/node.yaml` from `companion-module-template-ts-v1`.

## 🟢 Low

### L1: The "Debug Messages" checkbox no longer logs anything

- **Source:** 🔎 protocol reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/config.ts:106-113`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/config.ts#L106-L113)

**What goes wrong:** A user troubleshooting the RCP connection ticks "Debug Messages" (tooltip: "Log incoming and outgoing WebSocket messages") in the connection settings and saves. Nothing extra appears in the connection log. In v1.0.3 the same checkbox logged the incoming camera, user, tally and module messages and the outgoing commands. The option is still shown, and the upgrade script still carries it over, but nothing reads it any more.

**Why it happens:** The transport was rewritten from socket.io to the new integration API client, and every place that checked the setting was removed with the old code. The setting now appears only in the config type, the config field and the upgrade script.

**Fix:** either log the incoming state messages and the outgoing command bodies with `this.log('debug', ...)` when `this.config.debug_messages` is set (in the `IntegrationApi` message handler and in `command()`), or remove the checkbox from the connection settings so users aren't offered an option that does nothing.

### L2: Connection failures no longer say why

- **Source:** 🔎 protocol reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/api.ts:216-220`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/api.ts#L216-L220), [`src/api.ts:254`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/api.ts#L254), [`src/instance.ts:301`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/instance.ts#L301)

**What goes wrong:** Whatever goes wrong, the connection status always reads "API disconnected; verify host, token and project access" and nothing is written to the log. That one message covers a wrong IP address (connection refused), a wrong or missing Integration API token (the RCP answers 401), a rejected cloud login and a bad cloud token response, so the user can't tell which of them happened. In v1.0.3 the status showed the actual error message. The connection does still show as failed, so users can see that it is down.

**Why it happens:** When opening the connection fails, the error is caught and thrown away, and the socket's error handler also ignores the error it receives. The close callback takes no reason, so the instance can only set a fixed status message.

**Fix:** keep the last error and pass it to the close callback, then use it in the status text and a log line.

```ts
// src/api.ts
void this.open().catch((e) => { if (!this.closed) this.onClose(e) })
this.socket.on('error', (e) => { this.lastError = e; this.socket?.close() })
// src/instance.ts
this.updateStatus(InstanceStatus.ConnectionFailure, err?.message ?? 'API disconnected')
this.log('warn', `RCP connection failed: ${err?.message ?? 'disconnected'}`)
```

### L3: Stream Deck+ slot colour and step-size label lag after a bank or step-size change

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:672-683`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/instance.ts#L672-L683), [`src/instance.ts:721-725`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/instance.ts#L721-L725)

**What goes wrong:** On a Stream Deck+ page, a user presses a "Deck: Select control bank" button to go from Gain to Exposure. The gauges' value, name and min/max update, but the "Deck: Slot colour" feedback keeps showing the red/green/blue gain colours. Likewise, a "User: Set Step Size" button changes the step size, but the "Deck: Step size label" text (FINE/NORMAL/COARSE) doesn't change. Both catch up only when the RCP next sends a state update.

**Why it happens:** Changing the bank re-checks the bank, value, min, max, name and text feedbacks, but not the slot colour feedback (`deck_slot_accent`). Changing the step size re-checks only the "user step size" feedback; only the step-cycle action also re-checks the step size label (`deck_step_label`).

**Fix:** add `'deck_slot_accent'` to the `checkFeedbacks` list in `setUserBank()`, and `'deck_step_label'` to the one in `setUserStepSize()`. The `deck_step_cycle` action can then drop its extra call.

### L4: Cloud fields always show in the connection settings, and Target IP and Port show in cloud mode

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:33-43`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/config.ts#L33-L43), [`src/config.ts:78-97`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/config.ts#L78-L97)

**What goes wrong:** With "Connection" set to "Local RCP" (the default), the connection settings still show "Cloud API URL", "Cloud integration client ID", "Cloud integration client secret", "Cloud project ID" and "Target instance ID". With "Multicam Cloud (preview)" selected, "Target IP", "Port" and "Use HTTPS / WSS" are still shown even though they are ignored. Users can't easily tell which fields matter for their setup; the settings themselves still work.

**Why it happens:** Only the network-discovery field is hidden in cloud mode. The cloud fields have no visibility rule, and the host, port and HTTPS fields are hidden only when a discovered RCP is chosen, which never happens in cloud mode.

**Fix:** add `isVisibleExpression: "$(options:connection) == 'cloud'"` to `cloudUrl`, `cloudClientId`, `cloudClientSecret`, `cloudProjectId` and `cloudInstanceId`, and change `host`, `port` and `tls` to `"$(options:connection) != 'cloud' && !$(options:bonjourHost)"`. Hide the token field in cloud mode too if it isn't used there.

### L5: Fields from module API 2 are set in this API 1 module

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/companion.ts:29-41`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/companion.ts#L29-L41)

**What goes wrong:** Nothing visible in Companion 4: it ignores the fields. Five advanced feedbacks set `affectedProperties` and several options set `disableAutoExpression`, which only module API 2 understands. They are dead configuration on the API 1 line, and they compile only because of a type patch on the base package's internal `dist/` files, which can stop compiling if a base update moves those files.

**Why it happens:** The shared code is written for the v2 line and copied in by `tools/sync-core.sh`. [`src/companion.ts:29-41`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/companion.ts#L29-L41) adds the two fields to the v1 typings with `declare module '@companion-module/base/dist/module-api/input.js'` and `.../feedback.js`.

**Fix:** keep the v1 line on v1 fields, for example with a small helper in `src/companion.ts` that strips `affectedProperties` and `disableAutoExpression` before `setFeedbackDefinitions` and `setActionDefinitions`. At the least, check after each base update that the patched `dist/` paths still exist.

## 💡 Nice to Have

### N1: Connection status is re-sent to Companion on every state message

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/instance.ts:352-353`](https://github.com/bitfocus/companion-module-multicam-systems-rcp/blob/04fa9aba4bc2fb1872baf6a8853c41c1c817a015/src/instance.ts#L352-L353)

**What goes wrong:** Nothing visible to users. Every incoming state update (a control value or tally change) sends a "status OK" message to Companion, even when the status hasn't changed.

**Why it happens:** The state handler sets the status to OK on every message, and base 1.13.6's `updateStatus` doesn't skip repeats (`node_modules/@companion-module/base/dist/module-api/base.js:458-463`).

**Fix:** set the status only on the transition, e.g. `if (!this.connected) this.updateStatus(InstanceStatus.Ok)` before setting `this.connected = true`.

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template (`"extends"` is `@companion-module/tools/tsconfig/node22/recommended-esm.json` where the template has `@companion-module/tools/tsconfig/node22/recommended`; changed in this tag). Fine as long as the module builds and lints, which it does — no change required.
