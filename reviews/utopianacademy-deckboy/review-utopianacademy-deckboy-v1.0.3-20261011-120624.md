# Re-review: utopianacademy-deckboy v1.0.3

| Field | Value |
| --- | --- |
| **Module** | [companion-module-utopianacademy-deckboy](https://github.com/bitfocus/companion-module-utopianacademy-deckboy) |
| **Version** | v1.0.3 |
| **Previous review** | v1.0.2, reviewed 2026-10-05 |
| **Diff base** | v1.0.2 (1 commit, `2afe386` "Deckboy module 1.0.3", 12 files changed, +603/-236) |
| **Scope** | tag |
| **Language** | JavaScript (ESM) |
| **Template** | `companion-module-template-js` @ [`76d25b2`](https://github.com/bitfocus/companion-module-template-js/tree/76d25b2fe21b492096be05678680b71bdb7ac052) (2026-10-11, main, not pinned). The validator emitted no separate yarnrc template; `.yarnrc.yml` was compared against main and is clean (the module has `nodeLinker`, `enableScripts: false`, `npmMinimalAgeGate: 3d` and `npmPreapprovedPackages`) |
| **API** | 2.1 (base 2.1.3, yarn.lock); requires Companion 5.0 |
| **Build** | `yarn install --immutable` PASS (`packageManager` `yarn@4.17.0` now set; node_modules base 2.1.3). `yarn package` PASS (built `utopianacademy-deckboy-1.0.3.tgz`, manifest `apiVersion` stamped `2.1.3`). Lint N/A (the JS template has no lint script). Validator exit 1 because of 1 Critical (MAN-RUNTIME) |
| **Review date** | 2026-10-11 |

Almost everything from the v1.0.2 review is fixed: 24 of 25 findings are resolved, including all eight Criticals. One prior finding is still open (the LICENSE line). Two template findings are new in this report, but neither comes from a code change. The v1.0.2 review compared this API 2.1 module against the pinned API 2.0 template (`e4caa76`), which uses `node22` and has no `release.yaml`. This re-review uses the API 2.1 template on `main`, so the Node runtime setting and the missing release workflow are reported now.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a saved dropdown value (not in expression mode) is not in the field's current choices, Companion 5 still passes it to the action callback and only shows it as unmatched in the button editor. If Companion also skips such actions, saved v1.0.2 buttons would stop working and L1 would rise to Medium or High | The doc comment on `allowInvalidValues` in `node_modules/@companion-module/base/dist/module-api/input.d.ts` ("This only applies when in expression mode"); Companion's host code was not checked or tested live | [L1](#l1-saved-buttons-from-v102-show-a-blank-state-in-two-actions-after-upgrading) |
| A2 | No Deckboy release (v1.0.0, v1.0.1 or v1.0.2) has been published in the Companion module store, so no user has buttons saved with the old upper-case ids. If so, L1 affects nobody and can be dropped | The v1.0.2 review treated v1.0.2 as the first release and returned Changes Required; store publication status could not be checked from the module code | [L1](#l1-saved-buttons-from-v102-show-a-blank-state-in-two-actions-after-upgrading) |

## 🔁 Since the last review (v1.0.2)

| ID (prior) | Finding | Status | Note |
| --- | --- | --- | --- |
| C1 | Source file main.js sits at the module root | ✅ Fixed | Moved to `src/main.js`; `main`, `entrypoint` and imports updated |
| C2 | yarn.lock is out of sync with package.json | ✅ Fixed | `yarn install --immutable` passes; build stamps `apiVersion` 2.1.3 |
| C3 | package.json repository url points to the app repo | ✅ Fixed | Now the bitfocus module repo |
| C4 | package.json is missing the packageManager field | ✅ Fixed | `yarn@4.17.0` |
| C5 | package.json is missing the prettier field | ✅ Fixed | |
| C6 | package.json is missing the prettier devDependency | ✅ Fixed | |
| C7 | package.json is missing the format script | ✅ Fixed | |
| C8 | Placeholder maintainer in the manifest | ✅ Fixed | Real GitHub account `Utopian-Academy` |
| H2 | LICENSE differs from the template | ❌ Still open | Carried forward as [H1](#h1-the-license-copyright-line-does-not-match-the-template) |
| M1 | No end handler, so a clean close leaves the module marked connected | ✅ Fixed | `end` handler stops polling and marks disconnected |
| M2 | Take cue by number sends TAKE even when the cue number is empty | ✅ Fixed | Cue number validated; nothing sent when invalid |
| M3 | Naming a deck on a button moves the global deck focus | ✅ Fixed | Deck-scoped commands; previous focus restored |
| M4 | A dead link is never detected, so the surface shows stale state | ✅ Fixed | Reconnects after 3 missed STATUS replies |
| L1 | Polling keeps running while disconnected and floods the log | ✅ Fixed | Polling stops on error/end; repeated errors logged once |
| L2 | Acknowledgement-only chunks clear the pending STATUS flag | ✅ Fixed | Flag cleared only by a flushed report |
| L3 | Receive buffer is unbounded and decodes UTF-8 per chunk | ✅ Fixed | `StringDecoder` plus a 64 KiB cap |
| L4 | Two callbacks throw when the option value is missing | ✅ Fixed | `choice()` helper with fallback |
| L5 | Number options are sent without validation | ✅ Fixed | `number()` helper on every numeric option |
| L6 | Index-style number fields lack asInteger | ✅ Fixed | |
| L7 | Fixed-choice dropdown ids use mixed casing | ✅ Fixed | All lower case now; see new [L1](#l1-saved-buttons-from-v102-show-a-blank-state-in-two-actions-after-upgrading) |
| L8 | VJ deck options stop at 8 while the deck limit is 16 | ✅ Fixed | `max: MAX_DECKS` (16) |
| L9 | Manifest apiVersion is hand-set and there is no schema reference | ✅ Fixed | `$schema` added; `apiVersion` 0.0.0, filled by the build |
| N1 | Republish only changed variables and feedbacks | ✅ Fixed | |
| N2 | Quoted values cannot contain an escaped double quote | ✅ Fixed | Quoted value ends at a quote followed by the next key or end of line |
| N3 | Add an empty UpgradeScripts export | ✅ Fixed | `src/upgrades.js` |

## 📋 Issues

### Blocking

- [ ] [C1: The module is set to run on Node 22, but API 2.1 modules run on Node 26](#c1-the-module-is-set-to-run-on-node-22-but-api-21-modules-run-on-node-26)
- [ ] [H1: The LICENSE copyright line does not match the template](#h1-the-license-copyright-line-does-not-match-the-template)

### Non-blocking

- [ ] [M1: Publishing a GitHub release does not build and attach the module package](#m1-publishing-a-github-release-does-not-build-and-attach-the-module-package)
- [ ] [L1: Saved buttons from v1.0.2 show a blank State in two actions after upgrading](#l1-saved-buttons-from-v102-show-a-blank-state-in-two-actions-after-upgrading)

## 🔴 Critical

### C1: The module is set to run on Node 22, but API 2.1 modules run on Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW (the setting is unchanged since v1.0.2; the v1.0.2 review compared against the API 2.0 template, which uses `node22`)
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/companion/manifest.json#L20), [`package.json:18`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/package.json#L18)
- **Template:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-template-js/blob/76d25b2fe21b492096be05678680b71bdb7ac052/companion/manifest.json#L19), [`package.json:15`](https://github.com/bitfocus/companion-module-template-js/blob/76d25b2fe21b492096be05678680b71bdb7ac052/package.json#L15)

**What goes wrong:** Companion picks the Node.js version it starts a module with from the manifest. Deckboy asks for Node 22, while every module built from the API 2.1 template runs on Node 26. Running a different Node version from the rest of the API 2.1 modules makes later troubleshooting harder, and the module will need another release once Node 22 is retired.

**Why it happens:** The manifest's `runtime.type` is still `node22` and `package.json` `engines.node` is still `^22.20`, the values from the API 2.0 template. The API 2.1 template uses `node26` and `^26`. The validator flags only the manifest; `engines.node` belongs in the same fix.

**Evidence:**

```text
companion/manifest.json  runtime.type   found "node22"   template "node26"
package.json             engines.node   found "^22.20"   template "^26"
```

**Confirm by:** open [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/companion/manifest.json#L20) and [`package.json:18`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/package.json#L18) and compare them with the template lines linked above.

**Fix:** switch both settings to Node 26, as in the template.

```json
// companion/manifest.json
"runtime": {
	"type": "node26",
```

```json
// package.json
"engines": {
	"node": "^26",
```

## 🟠 High

### H1: The LICENSE copyright line does not match the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🔁 Still open from v1.0.2 (was H2)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/LICENSE#L3)
- **Template:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-template-js/blob/76d25b2fe21b492096be05678680b71bdb7ac052/LICENSE#L3)

**What goes wrong:** The module's LICENSE names a different copyright holder from the one in the official template that modules in the bitfocus organisation follow. The license type (MIT) is the same; only the copyright line differs.

**Why it happens:** Line 3 of `LICENSE` was written for the Deckboy app and was not changed between v1.0.2 and v1.0.3.

**Evidence:**

```text
LICENSE:3  found     "Copyright (c) 2026 Utopian Academy"
           template  "Copyright (c) 2022 Bitfocus AS - Open Source"
```

**Confirm by:** open [`LICENSE:3`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/LICENSE#L3) and compare it with the template's line 3.

**Fix:** copy the template's LICENSE over the module's, so line 3 reads as below.

```text
Copyright (c) 2022 Bitfocus AS - Open Source
```

## 🟡 Medium

### M1: Publishing a GitHub release does not build and attach the module package

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (the file was never present; the API 2.0 template used for the v1.0.2 review had no `release.yaml`)
- **File:** `.github/workflows/release.yaml` (missing)
- **Template:** [`.github/workflows/release.yaml`](https://github.com/bitfocus/companion-module-template-js/blob/76d25b2fe21b492096be05678680b71bdb7ac052/.github/workflows/release.yaml)

**What goes wrong:** When the maintainer publishes a release on GitHub, nothing packages the module or attaches the `.tgz` to that release, as it does for modules that follow the current template.

**Why it happens:** The API 2.1 template ships a `release.yaml` workflow that runs on a published release, packages the module and attaches the package. The module has only `companion-module-checks.yaml`.

**Fix:** copy `.github/workflows/release.yaml` from the template unchanged.

## 🟢 Low

### L1: Saved buttons from v1.0.2 show a blank State in two actions after upgrading

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.js:508-518`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/src/actions.js#L508-L518), [`src/actions.js:565-580`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/src/actions.js#L565-L580), [`src/upgrades.js:1-6`](https://github.com/bitfocus/companion-module-utopianacademy-deckboy/blob/2afe386fc07a5e31d7aac6aeac4595f9f780dc24/src/upgrades.js#L1-L6)

**What goes wrong:** Someone upgrading from v1.0.2 who already has buttons using "Bypass an audio effect" (State = Bypassed / Active) or "Video synth: text mode on/off" (State = On / Off / Toggle) keeps the old stored values `ON`, `OFF` and `TOGGLE`. The new dropdowns only list `on`, `off` and `toggle`, so the State field in the button editor no longer matches a choice and shows blank or unknown instead of "Bypassed" or "Toggle". Presses still send the right command, because `choice()` upper-cases the value (`AUDIOFX 3 BYPASS ON`, `ASCII TOGGLE`), so the device sees no difference. The user only has to re-pick the value. This depends on [A1](#-assumptions-to-confirm) and [A2](#-assumptions-to-confirm).

**Why it happens:** v1.0.3 changed the choice ids of these two State options from upper case to lower case, along with their defaults. `src/upgrades.js` was added in this release but its `UpgradeScripts` list is empty, so Companion never rewrites the values stored on saved actions.

**Evidence:**

```js
// src/upgrades.js:1-6
/*
 * Upgrade scripts — run by Companion on saved buttons when an option id or
 * shape changes between versions. None yet; the first rename goes here.
 */

export const UpgradeScripts = []

// v1.0.2 src/actions.js (text_mode): default: 'TOGGLE', choices: [{ id: 'ON' }, { id: 'OFF' }, { id: 'TOGGLE' }]
// v1.0.3 src/actions.js (text_mode): default: 'toggle', choices: [{ id: 'on' }, { id: 'off' }, { id: 'toggle' }]
```

**Fix:** add one upgrade script that lower-cases the stored State of these two actions. For each action whose `actionId` is `audiofx_bypass` or `text_mode`, if the stored `state` value is a string that is not already lower case, lower-case it and add the action to `updatedActions`. Companion 5 stores options wrapped as `{ isExpression, value }`, so change `value` and keep the wrapper. Alternatively, go back to the upper-case choice ids, since `choice()` already normalises the case on send.

```js
export const UpgradeScripts = [
	function lowerCaseStateChoices(_context, props) {
		const updatedActions = []
		for (const action of props.actions) {
			if (action.actionId !== 'audiofx_bypass' && action.actionId !== 'text_mode') continue
			const state = action.options.state
			if (state && !state.isExpression && typeof state.value === 'string' && state.value !== state.value.toLowerCase()) {
				state.value = state.value.toLowerCase()
				updatedActions.push(action)
			}
		}
		return { updatedConfig: null, updatedActions, updatedFeedbacks: [] }
	},
]
```
