# Review: stageaudioworks-obs-multisite v0.5.0

| Field | Value |
| --- | --- |
| **Module** | `companion-module-stageaudioworks-obs-multisite` |
| **Scope** | `tag` (v0.3.2..v0.5.0) |
| **Version** | v0.5.0 |
| **Release** | Update — last published v0.3.2 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`b0fff6e`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/tree/b0fff6ed2a7cba1e35778eb90d451776efc082b3) |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion does not re-run every feedback callback after a module sends new feedback definitions. If it did (asynchronously, after the reconnect attempt has marked the box as down), the "box is not answering" button would show correctly the first time | The module only calls `checkFeedbacks('box_offline')` when a connection is established or drops; Companion's re-check behaviour on definition updates was not verified | [L1](#l1-outpost-box-is-not-answering-button-stays-dark-after-the-host-is-changed-to-a-box-that-does-not-answer) |

## 📋 Issues

### Blocking

- [ ] [C1: Module is declared for Node 22, but API 2.1 modules run on Node 26](#c1-module-is-declared-for-node-22-but-api-21-modules-run-on-node-26)
- [ ] [C2: Prettier ignore file differs from the template](#c2-prettier-ignore-file-differs-from-the-template)
- [ ] [C3: Lint rule for unpublished imports is switched off for the whole module, not just the tests](#c3-lint-rule-for-unpublished-imports-is-switched-off-for-the-whole-module-not-just-the-tests)
- [ ] [C4: Pre-commit formatting hook is never installed (husky and lint-staged missing)](#c4-pre-commit-formatting-hook-is-never-installed-husky-and-lint-staged-missing)
- [ ] [H1: LICENSE copyright line differs from the template](#h1-license-copyright-line-differs-from-the-template)

### Non-blocking

- [ ] [M1: CI builds on Node 22 and keeps checkout credentials](#m1-ci-builds-on-node-22-and-keeps-checkout-credentials)
- [ ] [M2: Release workflow is missing](#m2-release-workflow-is-missing)
- [ ] [L1: Outpost box is not answering button stays dark after the host is changed to a box that does not answer](#l1-outpost-box-is-not-answering-button-stays-dark-after-the-host-is-changed-to-a-box-that-does-not-answer)
- [ ] [L2: Schedule and running-hot buttons stay lit after the Outpost box stops answering](#l2-schedule-and-running-hot-buttons-stay-lit-after-the-outpost-box-stops-answering)
- [ ] [L3: Encoder Drop a marker is offered on an Outpost encoder but can only fail](#l3-encoder-drop-a-marker-is-offered-on-an-outpost-encoder-but-can-only-fail)
- [ ] [L4: Aborting a button does not cancel the new network actions](#l4-aborting-a-button-does-not-cancel-the-new-network-actions)
- [ ] [N1: Connecting to an Outpost box sends duplicate and unused status and recordings requests](#n1-connecting-to-an-outpost-box-sends-duplicate-and-unused-status-and-recordings-requests)

## 🔴 Critical

### C1: Module is declared for Node 22, but API 2.1 modules run on Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW (template check; unchanged since v0.3.2)
- **File:** [`companion/manifest.json:18-19`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/companion/manifest.json#L18-L19), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/tsconfig.build.json#L2)

**What goes wrong:** The module is built on API 2.1 (Companion 5.0+), whose template runs modules on Node 26. This module still tells Companion to run it on Node 22 and compiles against Node 22 settings. That mismatch with the template makes later troubleshooting harder, because the module doesn't run on the runtime every other API 2.1 module uses.

**Why it happens:** `companion/manifest.json` sets `runtime.type` to `node22`, and `tsconfig.build.json` extends the Node 22 preset from `@companion-module/tools`. The API 2.1 template uses `node26` in both places.

**Evidence:** template expects `"type": "node26"`; found `"type": "node22"`. `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`; the template extends `@companion-module/tools/tsconfig/node26/recommended.json`.

**Confirm by:** open [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/companion/manifest.json#L19) and [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/tsconfig.build.json#L2).

**Fix:** move the runtime and the build preset to Node 26, as the template does (and the CI Node version, see [M1](#m1-ci-builds-on-node-22-and-keeps-checkout-credentials)).

```json
"runtime": {
	"type": "node26",
```

```json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

### C2: Prettier ignore file differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check; unchanged since v0.3.2)
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/.prettierignore#L2)

**What goes wrong:** The module's Prettier ignore list doesn't match the template, so formatting behaviour differs from every other module built from it.

**Why it happens:** Line 2 lists `/LICENSE` where the template lists `/LICENSE.md`.

**Evidence:** line 2: found `/LICENSE`, template `/LICENSE.md`.

**Fix:** use the template's `.prettierignore` unchanged.

### C3: Lint rule for unpublished imports is switched off for the whole module, not just the tests

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check; unchanged since v0.3.2)
- **File:** [`eslint.config.mjs:3-11`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/eslint.config.mjs#L3-L11)

**What goes wrong:** The lint check that stops shipped code from importing a dev-only package is off everywhere. If code under `src/` imported a devDependency by mistake, lint would pass and the packaged module would fail to load it at runtime.

**Why it happens:** The module passes `commonRules: { 'n/no-unpublished-import': 'off' }` to `generateEslintConfig`. That applies to every file, including `src/**`, not only the `*.spec.ts` tests that import `vitest`. A test-only override is accepted; a module-wide one is not.

**Evidence:**

```js
// eslint.config.mjs:3-11
export default generateEslintConfig({
	enableTypescript: true,
	// The module's own tests import `vitest`, which is a devDependency and so
	// "unpublished" as far as eslint-plugin-n is concerned. A test importing its
	// test runner is not the problem that rule exists for.
	commonRules: {
		'n/no-unpublished-import': 'off',
	},
})
```

**Fix:** keep the template call unchanged and turn the rule off only for the test files.

```js
import { generateEslintConfig } from '@companion-module/tools/eslint/config.mjs'

const baseConfig = await generateEslintConfig({ enableTypescript: true })

export default [
	...baseConfig,
	{
		files: ['src/**/*.spec.ts'],
		rules: { 'n/no-unpublished-import': 'off' },
	},
]
```

### C4: Pre-commit formatting hook is never installed (husky and lint-staged missing)

- **Source:** 🤖 validate-template (PKG-SCRIPT, PKG-DEVDEP, PKG-LINTSTAGED)
- **Classification:** 🆕 NEW (template check; unchanged since v0.3.2)
- **File:** [`package.json:6-18`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/package.json#L6-L18), [`package.json:33-43`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/package.json#L33-L43)

**What goes wrong:** The repo ships a `.husky/pre-commit` hook, but it never runs: commits go in without the template's automatic Prettier and ESLint pass on staged files.

**Why it happens:** `package.json` is missing the template's `postinstall: husky` script (which installs the hook), the `husky` and `lint-staged` devDependencies, and the `lint-staged` section that says what the hook runs.

**Evidence:**

- PKG-SCRIPT: missing required script `postinstall` (template: `"postinstall": "husky"`).
- PKG-DEVDEP: missing devDependency `husky`.
- PKG-DEVDEP: missing devDependency `lint-staged`.
- PKG-LINTSTAGED: missing `lint-staged` section.

**Fix:** copy the `postinstall` script, the `husky` and `lint-staged` devDependencies, and the `lint-staged` section from the template's `package.json`, then run `yarn install` to update `yarn.lock`.

```json
"scripts": {
	"postinstall": "husky",
```

## 🟠 High

### H1: LICENSE copyright line differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW (template check; unchanged since v0.3.2)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/LICENSE#L3)

**What goes wrong:** The module's LICENSE doesn't match the template's MIT licence text.

**Why it happens:** Line 3 carries the maintainer's own copyright holder instead of the template's.

**Evidence:** line 3: found `Copyright (c) 2026 Stage Audio Works`, template `Copyright (c) 2022 Bitfocus AS - Open Source`.

**Fix:** use the template's LICENSE file unchanged.

## 🟡 Medium

### M1: CI builds on Node 22 and keeps checkout credentials

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template check; unchanged since v0.3.2)
- **File:** [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/.github/workflows/node.yaml#L18-L23)

**What goes wrong:** CI tests the module on Node 22. Once the runtime moves to Node 26 ([C1](#c1-module-is-declared-for-node-22-but-api-21-modules-run-on-node-26)), CI would no longer test on the Node version the module runs on. The checkout step also leaves the GitHub token in the workspace for later steps.

**Why it happens:** The workflow uses `node-version: 22.x`, and the `actions/checkout` step has no `with: persist-credentials: false`. The template has both changes.

**Fix:** use the template's `node.yaml`: add `with: persist-credentials: false` to the checkout step and set the Node step to `26.x` (name and `node-version`).

### M2: Release workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template check; unchanged since v0.3.2)
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** The template's release workflow, which builds the package when a version tag is pushed, isn't in the repo.

**Why it happens:** The file was not copied from the template.

**Fix:** add the template's `.github/workflows/release.yaml` unchanged.

## 🟢 Low

### L1: Outpost box is not answering button stays dark after the host is changed to a box that does not answer

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:143-157`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/main.ts#L143-L157), [`src/main.ts:280-298`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/main.ts#L280-L298)

**What goes wrong:** An operator has an Outpost connection to box 192.168.1.50 with the preset status button (feedback "Outpost: the box is not answering"). They edit the connection and change the host to 192.168.1.51, a box that is off or mistyped. The connection status turns to Connection Failure, but the button never turns dark red, and it keeps showing the box as answering for as long as the reconnect keeps failing. The Temperature and Schedule variables also keep the old box's values.

**Why it happens:** The module re-checks that feedback only when a connection is established or an established connection drops. After a config change, the reconnect first marks the box as down, then the first status call fails. The "dropped" event fires only when the box was up before, so it doesn't fire here. The reconnect's error handler only sets the status and schedules a retry; it never re-checks the feedback or republishes the variables. Every later failed retry takes the same path (see [A1](#-assumptions-to-confirm)).

**Fix:** in the reconnect's error handler, repaint the Outpost feedbacks and variables whenever a connect attempt fails.

```ts
} catch (error) {
	const reason = error instanceof Error ? error.message : String(error)
	this.updateStatus(InstanceStatus.ConnectionFailure, reason)
	if (this.isOutpost) {
		this.checkFeedbacks('box_offline', 'running_hot', 'schedule_running', 'schedule_skipped')
		this.publishVariables()
	}
	this.scheduleReconnect()
}
```

### L2: Schedule and running-hot buttons stay lit after the Outpost box stops answering

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:331-341`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/main.ts#L331-L341), [`src/feedbacks.ts:254-263`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/feedbacks.ts#L254-L263)

**What goes wrong:** An operator has the "Schedule: the next service" preset on a button. A service is running, so the button is green ("Schedule: a scheduled service is running"). If the Outpost box drops off the network, the countdown text goes blank but the button stays green, and a "Schedule: the next service is skipped" button stays purple. "Outpost: the box is running hot" also stays amber. They only correct themselves once the box reconnects and the schedule changes.

**Why it happens:** The schedule feedbacks already return false when the box isn't connected, so they were meant to go dark. But when the connection drops, the module only asks Companion to re-check "the box is not answering", so Companion never re-runs the schedule or running-hot feedbacks and they keep their last value. The running-hot feedback also has no "is connected" check at all.

**Fix:** re-check the box feedbacks when the connection drops, and add the connected check to running-hot.

```ts
// handleDisconnected()
if (this.isOutpost) {
	this.checkFeedbacks('box_offline', 'running_hot')
	if (this.offersSchedule) this.checkFeedbacks('schedule_running', 'schedule_soon', 'schedule_skipped')
	this.publishVariables()
}
```

```ts
// src/feedbacks.ts running_hot
callback: (feedback) => self.isConnected && runningHot(self.boxSystem, Number(feedback.options.margin ?? 10)),
```

### L3: Encoder Drop a marker is offered on an Outpost encoder but can only fail

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:191-208`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/actions.ts#L191-L208), [`src/actions.ts:493-497`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/actions.ts#L493-L497)

**What goes wrong:** With "Connect to" set to an Outpost box in encoder shape, the action list still shows "Encoder: Drop a marker". A user who puts it on a button and presses it during a service gets no marker; the only sign is a log line ("an Outpost encoder cannot drop a marker yet"). The module's own comment says a button that can only be refused is worse than no button, and it already hides other actions on that basis.

**Why it happens:** The action is removed only when the connection offers no encoder. An Outpost encoder does offer one, so the action stays, and the Outpost transport always refuses `encoder/marker`.

**Fix:** also remove the action for an Outpost box until the box has a marker route, matching the presets, which already show the marker buttons only for OBS.

```ts
if (self.isOutpost) actions.encoder_marker = undefined
```

### L4: Aborting a button does not cancel the new network actions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:158-163`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/actions.ts#L158-L163), [`src/actions.ts:184-188`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/actions.ts#L184-L188), [`src/actions.ts:429-433`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/actions.ts#L429-L433)

**What goes wrong:** Almost nothing visible. If a user aborts a running button (for example with Companion's internal Abort action), the request from "Encoder: Check the input", "Schedule: Skip the next service", "Decoder: Lock the controls" or "Decoder: Hold or resume" still goes to the box and finishes. The transport's own 5-second timeout caps how long it can take.

**Why it happens:** On API 2.1, Companion hands each action callback an abort signal in its second argument (`context.signal`). These callbacks take only the event, and the transport's HTTP call uses only its own 5-second timeout. The older actions share the same path; this is raised only because new network actions were added in this release.

**Fix:** optional. Accept `(event, context)` in these callbacks, pass `context.signal` down to the transport, and combine it with the timeout there.

```ts
signal: AbortSignal.any([signal, AbortSignal.timeout(5000)]),
```

## 💡 Nice to Have

### N1: Connecting to an Outpost box sends duplicate and unused status and recordings requests

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:310-328`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/main.ts#L310-L328), [`src/main.ts:348-358`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/main.ts#L348-L358), [`src/transport-outpost.ts:241-246`](https://github.com/bitfocus/companion-module-stageaudioworks-obs-multisite/blob/b0fff6ed2a7cba1e35778eb90d451776efc082b3/src/transport-outpost.ts#L241-L246)

**What goes wrong:** Nothing the user can see. On the first connect to an Outpost box, the box gets its status requests twice. A decoder box also gets the recordings list (`GET /api/player/events`) twice. An encoder box gets the recordings list once even though nothing uses it, because every "Decoder: …" action, including "Load a recording", is removed for an encoder.

**Why it happens:** The Outpost connect marks the box as up and reads its shape before it reports "connected". The shape change refreshes the definitions and status, and fetches the recordings list for a decoder. Straight after, the "connected" handler refreshes the status again and fetches the recordings list again, this time without checking whether the box is a decoder.

**Fix:** let one of the two handlers do the first fetch. For example, in the "connected" handler, fetch the recordings list only for a decoder, and in the shape-changed handler, skip the refresh and fetch until the connection is established.

```ts
// handleConnected()
if (this.offersDecoder) void this.fetchEvents()
```
