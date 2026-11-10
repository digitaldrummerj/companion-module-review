# Review: apple-tv v1.0.1

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-apple-tv`](https://github.com/bitfocus/companion-module-apple-tv) |
| **Scope** | `tag` (first release: the whole module was reviewed) |
| **Version** | v1.0.1 ([`b9f4bc4`](https://github.com/bitfocus/companion-module-apple-tv/commit/b9f4bc4439647bd87ac79995d9c306672c37266d)) |
| **Release** | New module — never published |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.1+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-09 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: The module still targets Node 22, but the API 2.2 template runs on Node 26](#c1-the-module-still-targets-node-22-but-the-api-22-template-runs-on-node-26)
- [ ] [C2: .yarnrc.yml pre-approves node-appletv-remote and adds a patchFolder key](#c2-yarnrcyml-pre-approves-node-appletv-remote-and-adds-a-patchfolder-key)
- [ ] [H1: The module checks workflow adds a pull request trigger and pins the shared workflow to a commit](#h1-the-module-checks-workflow-adds-a-pull-request-trigger-and-pins-the-shared-workflow-to-a-commit)
- [ ] [H2: The CI workflow (node.yaml) is rewritten instead of using the template's](#h2-the-ci-workflow-nodeyaml-is-rewritten-instead-of-using-the-templates)
- [ ] [H3: yarn test fails on a fresh clone because the tests need a build first](#h3-yarn-test-fails-on-a-fresh-clone-because-the-tests-need-a-build-first)
- [ ] [H4: Feedbacks, variables, upgrade scripts and action definitions live in main.ts instead of their own files](#h4-feedbacks-variables-upgrade-scripts-and-action-definitions-live-in-maints-instead-of-their-own-files)
- [ ] [H5: The build script and the @companion-module/base version are written differently from the template](#h5-the-build-script-and-the-companion-modulebase-version-are-written-differently-from-the-template)

### Non-blocking

- [ ] [M1: The release workflow (release.yaml) is missing](#m1-the-release-workflow-releaseyaml-is-missing)
- [ ] [L1: Last dispatch result says "delivery uncertain" when nothing was sent](#l1-last-dispatch-result-says-delivery-uncertain-when-nothing-was-sent)
- [ ] [L2: The duration and progress variables show long unrounded decimals](#l2-the-duration-and-progress-variables-show-long-unrounded-decimals)
- [ ] [L3: The Power state and Now playing presets show the old connection name after a rename](#l3-the-power-state-and-now-playing-presets-show-the-old-connection-name-after-a-rename)
- [ ] [L4: A failed or abandoned re-pair leaves a working Apple TV disconnected](#l4-a-failed-or-abandoned-re-pair-leaves-a-working-apple-tv-disconnected)
- [ ] [L5: The help page doesn't list the variables or the Apple TV is on feedback](#l5-the-help-page-doesnt-list-the-variables-or-the-apple-tv-is-on-feedback)
- [ ] [L6: Variable names are just the ids, without units or meaning](#l6-variable-names-are-just-the-ids-without-units-or-meaning)
- [ ] [L7: The Enable Apple TV connection checkbox duplicates Companion's own connection toggle](#l7-the-enable-apple-tv-connection-checkbox-duplicates-companions-own-connection-toggle)
- [ ] [N1: The cause of a setup failure is never logged](#n1-the-cause-of-a-setup-failure-is-never-logged)
- [ ] [N2: A leftover test name is sent to the Apple TV on every session](#n2-a-leftover-test-name-is-sent-to-the-apple-tv-on-every-session)
- [ ] [N3: Add feedbacks for playback and mute state](#n3-add-feedbacks-for-playback-and-mute-state)
- [ ] [N4: No hint when discovery finds no Apple TV](#n4-no-hint-when-discovery-finds-no-apple-tv)

## 🔴 Critical

### C1: The module still targets Node 22, but the API 2.2 template runs on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/companion/manifest.json#L18)

**What goes wrong:** The module is built on `@companion-module/base` 2.2, whose template runs on Node 26, but the manifest asks Companion to run it on Node 22. A module that doesn't match its own template is confusing to troubleshoot later: when something misbehaves, people look for the cause in the module when the real difference is the runtime.

**Why it happens:** The Node version is named in several places; all but `@types/node` were left on 22.

**Evidence:** validator: `The API 2.2 template runs on Node 26; update every place still on another version` — each place below is `found -> template value`.

**Fix:** update every place to Node 26, as the template does:

- [ ] [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/companion/manifest.json#L18): `"runtime": { "type": "node26" }` (now `node22`)
- [ ] [`package.json:25`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/package.json#L25): `"engines": { "node": "^26" }` (now `^22.22.1`)
- [ ] [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/tsconfig.build.json#L2): `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"` (now `…/node22/recommended-esm.json`)
- [ ] [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/.github/workflows/node.yaml#L22-L25): `- name: Use Node.js 26.x` (line 22) and `node-version: 26.x` (lines 25 and 49); copying the template's file (H2) covers this

### C2: .yarnrc.yml pre-approves node-appletv-remote and adds a patchFolder key

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:3`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/.yarnrc.yml#L3), [`.yarnrc.yml:5-7`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/.yarnrc.yml#L5-L7)

**What goes wrong:** `.yarnrc.yml` controls how dependencies are installed for everyone who builds the module, including the Bitfocus build. The template hardens it with a 3-day minimum age for new package versions (`npmMinimalAgeGate: 3d`) and pre-approves only `@companion-module/*`. This file also exempts `node-appletv-remote` from the age gate, so a brand-new release of that package would be installed at once, and adds a `patchFolder` key the template doesn't have.

**Why it happens:** The age-gate exemption is probably left over from when `node-appletv-remote` 0.5.0 was new; it was published on 2026-10-28, so it now passes the gate without help. `patchFolder` only tells `yarn patch-commit -s` where to write new patches: the dependency already points at the patch file by path (`patch:node-appletv-remote@npm%3A0.5.0#~/patches/…` in `package.json:30`).

**Evidence:** validator:

```text
Value mismatch: npmPreapprovedPackages = '[@companion-module/*, node-appletv-remote]' (template '[@companion-module/*]')
Extra keys not in template: patchFolder
```

```yaml
# .yarnrc.yml:3-7
patchFolder: patches
npmMinimalAgeGate: 3d
npmPreapprovedPackages:
  - '@companion-module/*'
  - node-appletv-remote
```

**Fix:** remove `patchFolder: patches` and the `- node-appletv-remote` line, so `.yarnrc.yml` matches the template, then confirm that `yarn install` still applies the patch.

## 🟠 High

### H1: The module checks workflow adds a pull request trigger and pins the shared workflow to a commit

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:5`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/.github/workflows/companion-module-checks.yaml#L5), [`.github/workflows/companion-module-checks.yaml:16`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/.github/workflows/companion-module-checks.yaml#L16)

**What goes wrong:** The module checks no longer follow Bitfocus's shared workflow: pinned to a commit, they won't pick up the checks Bitfocus adds to `module-checks.yaml@main`, so a problem the Bitfocus build would catch can pass this repo's CI.

**Why it happens:** The module's copy adds a `pull_request:` trigger and replaces `@main` with a commit SHA.

**Evidence:** validator: `Differs from template (line 4: found 'pull_request:', template 'jobs:')`

```diff
# template vs module .github/workflows/companion-module-checks.yaml
+  pull_request:
-    uses: bitfocus/actions/.github/workflows/module-checks.yaml@main
+    uses: bitfocus/actions/.github/workflows/module-checks.yaml@1a093b78d5fa564501c63ba34d45836e07b952b9
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/companion-module-checks.yaml .github/workflows/companion-module-checks.yaml` should show no difference.

**Fix:** copy the template's `companion-module-checks.yaml` unchanged.

### H2: The CI workflow (node.yaml) is rewritten instead of using the template's

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/.github/workflows/node.yaml)

**What goes wrong:** The CI workflow no longer matches the template, so later template updates can't be copied over and CI differences are hard to troubleshoot.

**Why it happens:** The file was written from scratch: it is named "Validation", runs only on pushes to `main`, adds a `permissions` block, pins actions to commit SHAs, replaces the lint job with a "Lint and test" job, and adds a `package-platforms` matrix (macOS and Windows) and a `validation-gate` job.

**Evidence:** validator: `Differs from template (line 1: found 'name: Validation', template 'name: Node CI')`

```diff
# template vs module .github/workflows/node.yaml (excerpt)
-name: Node CI
+name: Validation
-      - '**'
+      - main
+permissions:
+  contents: read
-  lint:
-    name: Lint
+  checks:
+    name: Lint and test
-      - uses: actions/checkout@v7
+      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7
+  package-platforms:
+    name: Packaged Node runtime (${{ matrix.os }})
+  validation-gate:
+    name: validation-gate
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml` should show no difference beyond the template's optional test job.

**Fix:** copy the template's `node.yaml`. To run the tests in CI, uncomment the template's own `test:` job.

### H3: yarn test fails on a fresh clone because the tests need a build first

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:16`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/package.json#L16)

**What goes wrong:** No Companion user sees this. A contributor who clones the repository and runs `yarn install && yarn test` gets 17 of 17 test files failing with `ERR_MODULE_NOT_FOUND` before any test runs. CI passes only because `node.yaml` runs `yarn build` before `yarn test`.

**Why it happens:** The tests import the compiled output in `dist/` and `dist-tools/`. Those folders are gitignored and only created by `yarn build`, and the `test` script doesn't build. There is no `pretest` hook, and `postinstall` only runs `husky`.

**Evidence:**

```text
// package.json:16
    "test": "node --test tests/*.test.mjs",
// .gitignore:5-6
/dist
/dist-tools
// tests/presets.test.mjs:3-4
import { remoteActions } from '../dist/actions.js'
import { buildPresets } from '../dist/presets.js'
// tests/node-acceptance.test.mjs:4
import { runAcceptance } from '../dist-tools/tools/acceptance.js'
// fresh clone of v1.0.1, yarn install, yarn test (no build):
# tests 17
# pass 0
# fail 17
# Error [ERR_MODULE_NOT_FOUND]: Cannot find module '.../dist/display.js' imported from .../tests/display.test.mjs
```

**Confirm by:** in a fresh clone of v1.0.1, run `yarn install && yarn test` without `yarn build`; every test file fails with `ERR_MODULE_NOT_FOUND`.

**Fix:** build in the test script, for example:

```json
"test": "run build && node --test tests/*.test.mjs"
```

### H4: Feedbacks, variables, upgrade scripts and action definitions live in main.ts instead of their own files

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:34`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L34), [`src/main.ts:65-75`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L65-L75), [`src/main.ts:118-136`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L118-L136), [`src/main.ts:157-219`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L157-L219)

**What goes wrong:** No Companion user sees this. Someone looking for the module's feedbacks, variables or upgrade scripts won't find `src/feedbacks.ts`, `src/variables.ts` or `src/upgrades.ts`, and `src/actions.ts` holds only a command table, not the action definitions. A module laid out differently from its template is harder for the next person to troubleshoot.

**Why it happens:** The TS template keeps each kind of definition in its own file (`actions.ts`, `feedbacks.ts`, `variables.ts`, `upgrades.ts`, `presets.ts`, `config.ts`), each exporting its schema type and an `Update…` function. This module keeps `config.ts` and `presets.ts` but defines everything else inside `main.ts`.

**Evidence:**

```text
// ls src (module, v1.0.1)
actions.ts  config.ts  device/  display.ts  main.ts  node-backend.ts  node-credentials.ts  personal-output.ts  playback.ts  presets.ts
// ls src (companion-module-template-ts, e0d42b7)
actions.ts  config.ts  feedbacks.ts  main.ts  presets.ts  upgrades.ts  variables.ts
```

```ts
// src/main.ts:34
export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig, ModuleSecrets>[] = []
// src/main.ts:118-120
		this.defineActions()
		this.setFeedbackDefinitions({
			personalOutputActive: {
// src/main.ts:157-160
	private defineActions(): void {
		const { structure, presets } = buildPresets(this.label, this.apps)
		this.setPresetDefinitions(structure, presets)
		this.setActionDefinitions({
```

**Confirm by:** run `ls src` in the module (no `feedbacks.ts`, `variables.ts` or `upgrades.ts`), then open [`src/main.ts`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L34) at lines 34, 65, 119 and 160.

**Fix:** split the definitions out as the template does:

- [ ] `src/upgrades.ts`: `UpgradeScripts`, re-exported from `main.ts` (`export { UpgradeScripts } from './upgrades.js'`)
- [ ] `src/feedbacks.ts`: the feedback definitions, `UpdateFeedbacks(self)` and `FeedbacksSchema`
- [ ] `src/variables.ts`: the variable definitions and their schema
- [ ] `src/actions.ts`: `setActionDefinitions` as `UpdateActions(self)` with `ActionsSchema`, next to `remoteActions`

### H5: The build script and the @companion-module/base version are written differently from the template

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:10`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/package.json#L10), [`package.json:29`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/package.json#L29)

**What goes wrong:** No Companion user sees this. `yarn package` runs `build`, which here also compiles the developer tools in `tools/`. Those tools are not shipped, but a compile error in them still stops the Companion package from building. The base dependency is pinned exactly, so `yarn up` never picks up 2.2.x patch releases.

**Why it happens:** The template's `build` is `rimraf dist && run build:main`; this module added `dist-tools` and `run build:tools` to that command. The template writes the base dependency with `~`; this module pins `2.2.1`. Choosing API 2.2 is fine; only the exact pin differs.

**Evidence:**

```text
// package.json:9-12 (module)
    "package": "run build && companion-module-build",
    "build": "rimraf dist dist-tools && run build:main && run build:tools",
    "build:main": "tsc -p tsconfig.build.json",
    "build:tools": "tsc -p tsconfig.tools.json",
// package.json:29 (module)
    "@companion-module/base": "2.2.1",
// companion-module-template-ts/package.json:10
		"build": "rimraf dist && run build:main",
// companion-module-template-ts/package.json:26
		"@companion-module/base": "~2.1.3"
```

**Confirm by:** open [`package.json:10`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/package.json#L10) and [`package.json:29`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/package.json#L29) next to the template's `package.json` lines 10 and 26.

**Fix:** restore the template's `build` command and keep the tools build as an extra script; write the base dependency with `~`:

```json
"build": "rimraf dist && run build:main",
"build:all": "run build && run build:tools",
"@companion-module/base": "~2.2.1"
```

## 🟡 Medium

### M1: The release workflow (release.yaml) is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml`

**What goes wrong:** The template's release workflow builds the Companion package when a version tag is pushed and attaches it to the GitHub release. Without it, releases of this module carry no built package.

**Why it happens:** The template tracks `.github/workflows/release.yaml`; the module doesn't have it.

**Fix:** copy the template's `release.yaml` unchanged.

## 🟢 Low

### L1: Last dispatch result says "delivery uncertain" when nothing was sent

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/node-backend.ts:409-422`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/node-backend.ts#L409-L422), [`src/device/companion.ts:252`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/device/companion.ts#L252), [`src/main.ts:186`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L186)

**What goes wrong:** A user adds **Launch App** and doesn't pick an app (the **App** dropdown defaults to empty, and stays empty until the TV's app list has loaded). Pressing the button sends nothing, but `$(apple-tv:last_result)` shows `delivery uncertain; not retried`, which points at the network. Similarly, **Remote command → Power Toggle** while the power state is Unknown shows `unavailable for current playback or audio output` instead of saying the power state is unknown.

**Why it happens:** `launchApp('')` throws a `RangeError` before sending, and `perform()` has no case for `RangeError`, so it falls through to the last message. Every `UnsupportedCommand` maps to one fixed text, whatever its own message says.

**Fix:** map `RangeError` to a "not sent" message (e.g. `invalid option; not sent`), use the error's own message for `UnsupportedCommand`, and optionally reject an empty app id in the action callback before calling `perform()`.

### L2: The duration and progress variables show long unrounded decimals

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/node-backend.ts:363`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/node-backend.ts#L363), [`src/display.ts:37`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/display.ts#L37)

**What goes wrong:** While a track plays, `$(apple-tv:position)` shows `37`, but `$(apple-tv:duration)` shows `215.04` and `$(apple-tv:progress)` shows values like `17.206593406593407` on a button.

**Why it happens:** `position` is rounded down with `Math.floor`; `duration` and `progress` are converted with `String(...)` without rounding. `volume` already uses `Math.round`.

**Fix:** use `String(Math.floor(playing.duration))` and round `progress` (`Math.round(...)` or `.toFixed(1)`).

### L3: The Power state and Now playing presets show the old connection name after a rename

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:142-159`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L142-L159), [`src/node-backend.ts:183-198`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/node-backend.ts#L183-L198)

**What goes wrong:** The user renames the connection from `apple-tv` to `livingroom` while the Apple TV is connected. The presets still contain `$(apple-tv:power)` and `$(apple-tv:title)`, so a button dragged from **Power state** or **Now playing** shows `$NA` until the session reconnects or the module restarts.

**Why it happens:** Preset text is built from `this.label` only in `defineActions()`, which runs at `init()` and when the app list loads. `configUpdated()` doesn't call it, and when the same TV is still connected, `configure()` returns early, so the app-list hook doesn't fire either.

**Fix:** call `this.defineActions()` in `configUpdated()` (every time, or when `this.label` changed).

### L4: A failed or abandoned re-pair leaves a working Apple TV disconnected

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/node-backend.ts:200-247`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/node-backend.ts#L200-L247), [`src/node-backend.ts:299-309`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/node-backend.ts#L299-L309)

**What goes wrong:** The TV is connected; the user ticks **Start pairing when saving** and saves. The live connection drops at once. If the PIN is wrong, the TV closes the prompt, or the 3-minute window runs out, the status turns red ("Previous credentials were kept. Start pairing again to retry", or "Pairing expired…") and every command returns `not connected; not sent`. A plain Save would reconnect with the kept credentials, but nothing says so.

**Why it happens:** The pairing branch stops the connection before pairing starts, and the failure paths (expiry timer, `pair.closed`, the two `catch` blocks) only set an error status; they never reconnect with the saved pairing.

**Fix:** on those failure paths, reconnect with `this.secrets.pairing` when it belongs to the selected TV, or change the message to "Save without Start pairing to reconnect with the previous pairing".

### L5: The help page doesn't list the variables or the Apple TV is on feedback

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/companion/HELP.md)

**What goes wrong:** A user opens the connection's help in Companion to see what to put on a button. It names only `personal_output_route`, `personal_output_name`, `last_result` and the **Personal audio output active** feedback; it never mentions the **Apple TV is on** feedback or the `power`, `title`, `artist`, `app`, `playback_state`, `elapsed`, `remaining`, `progress`, `volume`, `mute_state` and `connection` variables. Those are only in `README.md`.

**Fix:** add a short Feedbacks list and a Variables table (id, meaning, example values such as `power`: On / Off / Unknown, `progress`: 0–100) to `HELP.md`.

### L6: Variable names are just the ids, without units or meaning

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:72-74`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L72-L74)

**What goes wrong:** Companion's variable list shows names like "position", "duration", "progress" and "mute state". Nothing says that `position` and `duration` are seconds, that `progress` is a percentage, or which values `mute_state` takes.

**Why it happens:** The names are generated from the ids: `key.replaceAll('_', ' ')`.

**Fix:** write a name for each variable, e.g. "Playback position (seconds)", "Playback progress (%)", "Mute state (Muted, Unmuted, Unavailable)", "Power state (On, Off, Unknown)".

### L7: The Enable Apple TV connection checkbox duplicates Companion's own connection toggle

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:16`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/config.ts#L16), [`src/node-backend.ts:164-168`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/node-backend.ts#L164-L168)

**What goes wrong:** A user unchecks **Enable Apple TV connection** and saves. The Connections list still shows the connection as enabled, but its status turns to Disconnected / "Disabled", so there are two places to turn the same connection off. Help step 1 ("Enable the connection and Save") could mean either.

**Fix:** remove the `enabled` field and rely on Companion's own enable/disable, which already calls `destroy()`. Before the first publish this needs no upgrade script. If the field stays, rename it so it isn't mistaken for the connection toggle.

## 💡 Nice to Have

### N1: The cause of a setup failure is never logged

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:149-153`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L149-L153)

**What goes wrong:** If setup ever fails, the user sees "Setup failed; disable the connection and try again", but the log has no cause to put in a bug report.

**Fix:** log the error in the `.catch` before setting the status: `` this.log('error', `Setup failed: ${error instanceof Error ? error.message : String(error)}`) ``.

### N2: A leftover test name is sent to the Apple TV on every session

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/device/session.ts:146`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/device/session.ts#L146)

**What goes wrong:** Every session introduces itself to the TV as "Companion Node Test", while pairing uses the name "Companion".

**Fix:** use `PAIRING_NAME` (or `'Companion'`) here too.

### N3: Add feedbacks for playback and mute state

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:119-136`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/main.ts#L119-L136)

**What goes wrong:** The module already tracks `playback_state` and `mute_state`, but there is no feedback for them, so a Play/Pause button can't turn green while playing, or a Mute button light up while muted, without writing an expression.

**Fix:** add boolean feedbacks such as "Playback state is" (Playing / Paused / Idle) and "Muted", from the state the backend already publishes.

### N4: No hint when discovery finds no Apple TV

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/node-backend.ts:204-212`](https://github.com/bitfocus/companion-module-apple-tv/blob/b9f4bc4439647bd87ac79995d9c306672c37266d/src/node-backend.ts#L204-L212)

**What goes wrong:** On a network where Companion can't see mDNS (another VLAN, or Docker without host networking), the **Apple TV** dropdown only offers "Select an Apple TV" and the status says "Select an Apple TV, check Start pairing, then Save". Nothing is logged, and the user is told to pick from an empty list.

**Fix:** when discovery finds nothing or fails, show a status such as "No Apple TV found on the network; check that Companion and the TV share a LAN with mDNS, then tick Refresh and Save", and log the caught error at `warn`.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a connection is renamed, Companion doesn't rewrite `$(oldLabel:…)` references inside the preset definitions the module has already sent | knowledge of the Companion host; the base package only says the label can change just before `configUpdated()` is called | [L3](#l3-the-power-state-and-now-playing-presets-show-the-old-connection-name-after-a-rename) |
