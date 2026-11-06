# Review: apple-tv v1.0.0

| Field | Value |
| --- | --- |
| **Module** | [`companion-module-apple-tv`](https://github.com/bitfocus/companion-module-apple-tv) |
| **Scope** | `tag` |
| **Version** | v1.0.0 (`16c034e`) |
| **Release** | New module — never published |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.1+ (module's declared `companion.minimumVersion`) |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Reviewed** | 2026-11-06 |

> This is the module's first release. There is no published version to diff against, so the whole module was reviewed. The API review used the v2.0 and v2.1 references; no v2.2 reference exists yet, so changes that are new in API 2.2 were not checked against one.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Module is on API 2.2 but still runs on Node 22 instead of Node 26](#c1-module-is-on-api-22-but-still-runs-on-node-22-instead-of-node-26)
- [ ] [C2: Yarn lets new node-appletv-remote releases skip the 3-day supply-chain wait](#c2-yarn-lets-new-node-appletv-remote-releases-skip-the-3-day-supply-chain-wait)
- [ ] [C3: `.yarnrc.yml` has an extra `patchFolder` key the template does not have](#c3-yarnrcyml-has-an-extra-patchfolder-key-the-template-does-not-have)
- [ ] [C4: `.prettierignore` excludes the hand-written `bridge/` folder](#c4-prettierignore-excludes-the-hand-written-bridge-folder)
- [ ] [H1: Manifest lists a legacy module id although this module has never been published](#h1-manifest-lists-a-legacy-module-id-although-this-module-has-never-been-published)
- [ ] [H2: Module checks workflow is pinned to an old commit and runs on pull requests, unlike the template](#h2-module-checks-workflow-is-pinned-to-an-old-commit-and-runs-on-pull-requests-unlike-the-template)
- [ ] [H3: Node CI workflow is rewritten and no longer matches the template](#h3-node-ci-workflow-is-rewritten-and-no-longer-matches-the-template)

### Non-blocking

- [ ] [M1: Release workflow is missing, so published releases get no attached package](#m1-release-workflow-is-missing-so-published-releases-get-no-attached-package)
- [ ] [L1: Connection status always reads Connecting to Apple TV when the connection fails, with no reason](#l1-connection-status-always-reads-connecting-to-apple-tv-when-the-connection-fails-with-no-reason)
- [ ] [L2: Setup gives no hint when the Apple TV search finds nothing](#l2-setup-gives-no-hint-when-the-apple-tv-search-finds-nothing)
- [ ] [L3: Launch App with no app chosen reports delivery uncertain although nothing was sent](#l3-launch-app-with-no-app-chosen-reports-delivery-uncertain-although-nothing-was-sent)
- [ ] [L4: Remote command dropdown shows internal ids such as seekBackward30 instead of readable names](#l4-remote-command-dropdown-shows-internal-ids-such-as-seekbackward30-instead-of-readable-names)
- [ ] [L5: Variable names give no units or formats for position, duration and progress](#l5-variable-names-give-no-units-or-formats-for-position-duration-and-progress)
- [ ] [L6: Personal audio output description says it sends one request, but it can send two](#l6-personal-audio-output-description-says-it-sends-one-request-but-it-can-send-two)
- [ ] [L7: Upgrade script sits in `main.ts` instead of its own `upgrades.ts` file](#l7-upgrade-script-sits-in-maints-instead-of-its-own-upgradests-file)
- [ ] [L8: Leftover Python-bridge and prototype code makes it hard to tell what runs in Companion](#l8-leftover-python-bridge-and-prototype-code-makes-it-hard-to-tell-what-runs-in-companion)
- [ ] [N1: Module introduces itself to the Apple TV as Companion Node Test](#n1-module-introduces-itself-to-the-apple-tv-as-companion-node-test)
- [ ] [N2: Two apps whose ids differ only in punctuation share one App preset](#n2-two-apps-whose-ids-differ-only-in-punctuation-share-one-app-preset)
- [ ] [N3: Enable Apple TV connection checkbox duplicates Companion's own enable switch](#n3-enable-apple-tv-connection-checkbox-duplicates-companions-own-enable-switch)

## 🔴 Critical

### C1: Module is on API 2.2 but still runs on Node 22 instead of Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/companion/manifest.json#L18), [`package.json:28`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/package.json#L28), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/tsconfig.build.json#L2), [`.github/workflows/node.yaml:23-26`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/node.yaml#L23-L26), [`.github/workflows/node.yaml:62`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/node.yaml#L62)

**What goes wrong:** Companion starts this module on its Node 22 runtime, while the API 2.2 template it is built from runs on Node 26. The build, the type checks and CI all target Node 22 too, so the module is never tested on the runtime its API level expects. `@types/node` is already `^26.6.5`, so the types describe Node 26 while the code runs on Node 22. A module that differs from its template like this is harder to troubleshoot later.

**Why it happens:** The module was moved to `@companion-module/base` 2.2.1, but the Node version was left at 22 in every place that names it: the manifest runtime, `engines`, the tsconfig preset and the CI workflow.

**Evidence:**

```text
The API 2.2 template runs on Node 26; update every place still on another version:
companion/manifest.json runtime.type 'node22' -> 'node26';
package.json engines.node '^22.22.1' -> '^26';
tsconfig.build.json extends "@companion-module/tools/tsconfig/node22/recommended-esm.json" -> "@companion-module/tools/tsconfig/node26/recommended.json";
.github/workflows/node.yaml line 23 step name 'Use Node.js 22.x' -> 'Use Node.js 26.x';
.github/workflows/node.yaml line 26 node-version 22.x -> 26.x;
.github/workflows/node.yaml line 62 node-version 22.x -> 26.x
```

**Confirm by:** `grep -rn '22' companion/manifest.json package.json tsconfig.build.json .github/workflows/node.yaml`

**Fix:** move every Node 22 reference to Node 26.

- [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/companion/manifest.json#L18): `"type": "node26"`
- [`package.json:28`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/package.json#L28): `"engines": { "node": "^26" }`
- [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/tsconfig.build.json#L2): `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"`
- [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/node.yaml): `- name: Use Node.js 26.x` (line 23) and `node-version: 26.x` (lines 26 and 62)

### C2: Yarn lets new node-appletv-remote releases skip the 3-day supply-chain wait

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:7`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.yarnrc.yml#L7)

**What goes wrong:** When dependencies are updated, Yarn accepts a freshly published version of `node-appletv-remote` straight away. Every other package has to be at least 3 days old first. That waiting period is the template's guard against a compromised release reaching the module before it is noticed and pulled, and it is switched off for the module's only third-party runtime dependency.

**Why it happens:** The template sets `npmMinimalAgeGate: 3d` and pre-approves only Bitfocus's own `@companion-module/*` packages. This module adds `node-appletv-remote` to the pre-approved list, so the age gate never applies to it.

**Evidence:**

```text
Value mismatch: npmPreapprovedPackages = '[@companion-module/*, node-appletv-remote]' (template '[@companion-module/*]')
```

```yaml
# .yarnrc.yml:4-7
npmMinimalAgeGate: 3d
npmPreapprovedPackages:
  - '@companion-module/*'
  - node-appletv-remote
```

**Confirm by:** compare [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.yarnrc.yml) with the template's `.yarnrc.yml`, then run `yarn install --immutable`.

**Fix:** remove line 7, so that `npmPreapprovedPackages` lists only `'@companion-module/*'`, as in the template.

### C3: `.yarnrc.yml` has an extra `patchFolder` key the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:3`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.yarnrc.yml#L3)

**What goes wrong:** Nothing visible to users. The Yarn configuration differs from the template, which makes the module's setup harder to compare with other modules when something goes wrong with an install.

**Why it happens:** `patchFolder` only changes where `yarn patch-commit` writes new patch files. The dependency in `package.json` already names its patch file by its full path (`patch:node-appletv-remote@npm%3A0.5.0#~/experiments/node-library/patches/…patch`), so installs don't need the key.

**Evidence:**

```text
Extra keys not in template: patchFolder
```

```yaml
# .yarnrc.yml:3
patchFolder: experiments/node-library/patches
```

**Confirm by:** remove the key and check that `yarn install --immutable` still succeeds.

**Fix:** delete the `patchFolder` line from [`.yarnrc.yml`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.yarnrc.yml#L3).

### C4: `.prettierignore` excludes the hand-written `bridge/` folder

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:4`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.prettierignore#L4)

**What goes wrong:** Nothing visible to users. The formatter is told to skip a folder of tracked, hand-written source (`bridge/controller.py`, `pair.py`, `pair_metadata.py` and `worker.py`), so the file no longer matches the template. Prettier has no Python parser, so today the entry hides nothing it would format; it only adds a difference from the template.

**Why it happens:** The template's `.prettierignore` lists only `package.json` and `/LICENSE.md`. Extra entries are accepted only for generated files. `.venv/`, `uv.lock` and `yarn.lock` are generated and may stay, but `bridge/` is not.

**Evidence:**

```text
Extra entries not in template: .venv/, bridge/, uv.lock, yarn.lock
```

```text
# .prettierignore:3-6
.venv/
bridge/
uv.lock
yarn.lock
```

**Confirm by:** `cat -n .prettierignore`

**Fix:** remove `bridge/` from [`.prettierignore`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.prettierignore#L4). If you remove the `bridge/` folder itself (see [L8](#l8-leftover-python-bridge-and-prototype-code-makes-it-hard-to-tell-what-runs-in-companion)), the entry goes with it.

## 🟠 High

### H1: Manifest lists a legacy module id although this module has never been published

- **Source:** 🤖 validate-template (MAN-LEGACYIDS)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:24`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/companion/manifest.json#L24)

**What goes wrong:** `legacyIds` tells Companion that this module takes over the connections of another module id, here `apple-tv-pyatv`. It is meant for a module in Companion's module list that gets renamed, so that users' existing connections move to the new id. This module has never been published, and a first release must not claim to replace another module: the template's list is empty.

**Why it happens:** The id was kept from the earlier Python-based module. The connection help text still mentions upgrading from it ([`src/config.ts:54`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/config.ts#L54): "Upgrading from the Python module requires a new PIN pairing"), and the upgrade script in [`src/main.ts:37-49`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/main.ts#L37-L49) exists only to convert those connections (see [L7](#l7-upgrade-script-sits-in-maints-instead-of-its-own-upgradests-file)).

**Evidence:**

```text
legacyIds lists 'apple-tv-pyatv' but the module has never been published; it must be [] as in the template
```

```json
// companion/manifest.json:24
"legacyIds": ["apple-tv-pyatv"],
```

**Confirm by:** `grep -n legacyIds companion/manifest.json`

**Fix:** empty the list, as in the template. In the same release, drop the legacy upgrade script (see [L7](#l7-upgrade-script-sits-in-maints-instead-of-its-own-upgradests-file)) and the "Upgrading from the Python module" sentence in the help text.

```json
"legacyIds": []
```

### H2: Module checks workflow is pinned to an old commit and runs on pull requests, unlike the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:5`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/companion-module-checks.yaml#L5), [`.github/workflows/companion-module-checks.yaml:16`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/companion-module-checks.yaml#L16)

**What goes wrong:** The module keeps running one fixed snapshot of Bitfocus's shared module checks. New checks and fixes that Bitfocus adds to that workflow never reach this repo, so the module can pass its own CI and still fail the checks every other module runs. The extra `pull_request:` trigger also makes the checks run twice for a pull request from a branch in the same repo.

**Why it happens:** The template calls `bitfocus/actions/.github/workflows/module-checks.yaml@main` and triggers only on `push`. This file pins the shared workflow to commit `1a093b78…` and adds a `pull_request:` trigger.

**Evidence:**

```text
Differs from template (line 4: found 'pull_request:', template 'jobs:')
```

```yaml
# .github/workflows/companion-module-checks.yaml:3-5
on:
  push:
  pull_request:
# .github/workflows/companion-module-checks.yaml:16
    uses: bitfocus/actions/.github/workflows/module-checks.yaml@1a093b78d5fa564501c63ba34d45836e07b952b9
```

**Confirm by:** `diff` [`.github/workflows/companion-module-checks.yaml`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/companion-module-checks.yaml) against the template's `.github/workflows/companion-module-checks.yaml`.

**Fix:** copy the template's `companion-module-checks.yaml`. Uncommenting its `upload-artifact: true` lines is allowed.

### H3: Node CI workflow is rewritten and no longer matches the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:1-104`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/node.yaml#L1-L104)

**What goes wrong:** The module's CI behaves differently from every template-based module. Pushes to branches other than `main` and `launchplane/train/**` are not checked, and the template's credential hardening on checkout is gone. CI also depends on Python, `uv` and macOS/Windows runners that the template doesn't use, so a CI failure here can't be compared with other modules or fixed from the template.

**Why it happens:** The workflow was replaced with a custom one:

- `name: Validation` (line 1), where the template has `name: Node CI`
- push branches limited to `main` / `"launchplane/train/**"` (lines 5–7); the template uses `'**'`
- a top-level `permissions: contents: read` (lines 12–13)
- the job `lint` renamed to `node` / "Node build, lint, test, and package" (lines 16–17)
- `actions/checkout` and `actions/setup-node` pinned to SHAs (lines 22, 24)
- the template's `persist-credentials: false` and its Prepare steps dropped
- added `yarn install --immutable`, test, uv/pyatv and package steps (lines 29–48)
- added `package-platforms` (macOS/Windows matrix), `python` and `validation-gate` jobs (lines 50–104)

The Node 22 lines are covered by [C1](#c1-module-is-on-api-22-but-still-runs-on-node-22-instead-of-node-26) and are not repeated here.

**Evidence:**

```text
Differs from template (line 1: found 'name: Validation', template 'name: Node CI')
```

**Confirm by:** `diff` [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/.github/workflows/node.yaml) against the template's `.github/workflows/node.yaml`.

**Fix:** copy the template's `node.yaml`. Enabling the template's commented-out `test:` job as written is allowed.

## 🟡 Medium

### M1: Release workflow is missing, so published releases get no attached package

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** When a GitHub release is published, nothing builds the module package and attaches the `.tgz` to the release, so users can't download a ready-to-import build from the Releases page.

**Why it happens:** The template's `.github/workflows/release.yaml` runs the shared module checks against the release tag and uploads the built package as a release asset. The file is not in this repo.

**Fix:** add the template's `.github/workflows/release.yaml` unchanged.

## 🟢 Low

### L1: Connection status always reads Connecting to Apple TV when the connection fails, with no reason

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/node-backend.ts:338-341`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/node-backend.ts#L338-L341)

**What goes wrong:** A user's paired Apple TV is asleep and unreachable, unplugged, on another VLAN, or its pairing was removed on the TV (Settings > Remotes and Devices). The connection turns red (Connection failure) with the message "Connecting to Apple TV" and stays that way. The status gives no hint whether the TV can't be found or needs pairing again. The reason (for example "Selected Companion or metadata service unavailable") only shows up in the module log, as a warning on each retry.

**Why it happens:** When the connection drops, the status changes to Connection failure, but its message is fixed: "Connected" when ready, "Connecting to Apple TV" otherwise. The controller catches the actual error and only logs it, so the error never reaches the status.

```ts
// src/node-backend.ts:338-341
const ready = controller.state === 'ready'
const next = ready ? 'ready' : controller.state === 'reconnecting' ? 'reconnecting' : 'connecting'
if (this.state !== next) {
	this.status(next, ready ? 'Connected' : 'Connecting to Apple TV')
```

**Fix:** keep the last failure reason in the controller (e.g. `lastError = describe(error)` in the `run()` catch) and show it in the status message while reconnecting, e.g. "Apple TV not found on the network; retrying" or "Connection failed: `<reason>`; retrying". Keep "Connecting to Apple TV" for the first attempt only.

### L2: Setup gives no hint when the Apple TV search finds nothing

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/node-backend.ts:204-212`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/node-backend.ts#L204-L212)

**What goes wrong:** A new user adds the connection while Companion can't see the TV on the network, for example because Companion runs in Docker without host networking or the TV is on another subnet. The status is "Bad configuration: Select an Apple TV, check Start pairing, then Save", and the Apple TV dropdown only offers "Select an Apple TV". Nothing says the search ran and found no Apple TVs, so the user can't tell it's a network problem rather than a step they missed.

**Why it happens:** An empty search result and a failed search both end in the same "Select an Apple TV" status. The error from a failed search is discarded, and an empty device list is never checked.

```ts
// src/node-backend.ts:206-211
try {
	await this.discover(signal)
} catch {
	/* Selection remains empty and no pairing starts. */
}
if (generation === this.generation) this.status('unpaired', 'Select an Apple TV, check Start pairing, then Save')
```

**Fix:** when the search fails or finds no devices, say so in the status, and log the search error.

```ts
this.status('unpaired', 'No Apple TV found on the local network; check that Companion and the TV share a network, then tick Refresh device list and Save')
```

### L3: Launch App with no app chosen reports delivery uncertain although nothing was sent

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/node-backend.ts:409-422`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/node-backend.ts#L409-L422)

**What goes wrong:** A user adds the "Launch App" action to a button and leaves the App dropdown on its empty default, for example because the app list hadn't loaded yet. When they press the button, the `last_result` variable shows "delivery uncertain; not retried", which suggests the command may have reached the TV. Nothing was sent: the module rejected the empty app id before sending. The same happens for a custom app id longer than 255 characters.

**Why it happens:** The command layer rejects an empty or over-long app id with a `RangeError` before any request ([`src/prototype/companion.ts:252`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/prototype/companion.ts#L252)). The message mapping in `perform()` only knows four error types, and every other error, `RangeError` included, falls through to "delivery uncertain; not retried".

**Fix:** add a `RangeError` branch to the `last_result` mapping (e.g. "invalid option; not sent"), or check `event.options.appId` in the Launch App callback and set `last_result: 'no app selected; not sent'` without calling `perform()`.

### L4: Remote command dropdown shows internal ids such as seekBackward30 instead of readable names

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:184`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/main.ts#L184)

**What goes wrong:** A user adds the "Remote command" action to a button and opens the Command dropdown. They see 26 camelCase ids such as "playPause", "toggleMute", "controlCenter", "appSwitcher", "seekForward30", "swipeLeft" and "power", instead of "Play/Pause", "Mute (toggle)", "Control Center", "Forward 30 seconds" or "Power (toggle)". The commands work, but the list is harder to scan, and "power" doesn't say that it toggles, while "sleep" and "wake" set a fixed state.

**Why it happens:** Each dropdown choice uses its id as its label. `remoteActions` in [`src/actions.ts`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/actions.ts) already has a readable preset name for 9 of the 26 commands, but the dropdown doesn't use it, and the other 17 have no name.

```ts
// src/main.ts:184
choices: Object.keys(remoteActions).map((id) => ({ id, label: id })),
```

**Fix:** give every entry in `remoteActions` a `label` (e.g. `seekForward30: { label: 'Forward 30 seconds', ... }`, `power: { label: 'Power (toggle)', ... }`) and build the choices from it. Keep the ids unchanged, so saved buttons still match.

```ts
choices: Object.keys(remoteActions).map((id) => ({ id, label: remoteActions[id].label })),
```

### L5: Variable names give no units or formats for position, duration and progress

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:87-89`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/main.ts#L87-L89)

**What goes wrong:** In this connection's variables list, users see names such as "volume", "mute state", "metadata state", "playback state", "position", "duration", "elapsed", "remaining" and "progress". The names don't say that position and duration are in seconds (e.g. "125"), that progress is a percentage, or that elapsed and remaining are formatted as m:ss. The variables next to them have descriptive names, such as "Personal audio output route (Personal, Default, Connecting, Failed or Unavailable)".

**Why it happens:** The names of the playback variables are generated from their ids by replacing `_` with a space, so none of them gets a written name.

```ts
// src/main.ts:87-89
...(Object.fromEntries(
	Object.keys(displayDefaults).map((key) => [key, { name: key.replaceAll('_', ' ') }]),
) as Record<keyof DisplayValues, { name: string }>),
```

**Fix:** write a name for each variable in a map typed `Record<keyof DisplayValues, string>`, e.g. `position: 'Playback position (seconds)'`, `duration: 'Duration (seconds)'`, `elapsed: 'Elapsed time (m:ss)'`, `progress: 'Playback progress (percent)'`, `mute_state: 'Mute state (Muted, Unmuted or Unavailable)'`, `power: 'Power state (On, Off or Unknown)'`. Keep the variable ids unchanged.

### L6: Personal audio output description says it sends one request, but it can send two

- **Source:** 🔎 protocol reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:210-211`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/main.ts#L210-L211)

**What goes wrong:** In the action picker, "Personal audio output" says "Sends one request; the route variable confirms the result." When the AirPods haven't switched 3 seconds after the request settles, the module sends the same request again, and `last_result` shows "output change not confirmed yet; sending it once more". A user who relies on the description, for example while troubleshooting a double switch, gets the wrong picture. HELP.md already describes the resend correctly.

**Why it happens:** The description wasn't updated when the resend was added. The router schedules the resend 3 seconds after the first request settles while the change is still unconfirmed ([`src/personal-output.ts:171`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/personal-output.ts#L171), [`src/personal-output.ts:189-192`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/personal-output.ts#L189-L192)).

**Fix:** make the description match the behaviour and HELP.md.

```ts
description:
	'Toggle or select the configured personal output, such as AirPods, as the system audio route. Sends one request, and repeats it once if the TV has not switched after 3 seconds; the route variable confirms the result.',
```

### L7: Upgrade script sits in `main.ts` instead of its own `upgrades.ts` file

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:37-49`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/main.ts#L37-L49)

**What goes wrong:** Nothing visible to users. The config migration for connections carried over from the legacy `apple-tv-pyatv` id sits in `main.ts` next to the module class, where the template keeps upgrade scripts in `src/upgrades.ts`. Later scripts must be appended in order and released scripts must never be edited, which is easier to keep track of in a file of their own.

**Why it happens:** `export const UpgradeScripts = [...]` is defined directly in `src/main.ts`, and the script exists only for the legacy-id migration reported in [H1](#h1-manifest-lists-a-legacy-module-id-although-this-module-has-never-been-published).

**Fix:** when you empty `legacyIds` (H1), drop this script in the same release: it only converts connections carried over from `apple-tv-pyatv`, and without the legacy id there are none. Create `src/upgrades.ts` as in the template and re-export it from `main.ts`. Add future scripts to that file.

```ts
// src/upgrades.ts
export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig, ModuleSecrets>[] = []

// src/main.ts
export { UpgradeScripts } from './upgrades.js'
```

### L8: Leftover Python-bridge and prototype code makes it hard to tell what runs in Companion

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/transport.ts:1-120`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/transport.ts#L1-L120), [`src/prototype/`](https://github.com/bitfocus/companion-module-apple-tv/tree/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/prototype)

**What goes wrong:** Nothing visible to users: the installed package contains only the code reachable from `main.ts`, and the bundled `main.js` has no `child_process` code. For maintainers and reviewers, the source tree suggests the module still runs a Python helper, which the config help text says it doesn't ("no Python or terminal setup is needed"). The production connection code lives in a folder named `prototype` next to developer test tools, so it is hard to tell what actually runs inside Companion.

**Why it happens:** The module moved from the pyatv-based Python bridge to the pure-Node backend (`src/node-backend.ts`), but the leftovers stayed:

- `src/transport.ts`, which starts a child process and talks JSON over stdio to the old Python worker (`bridge/worker.py`), is not imported by any file in `src/`; only `tests/transport.test.mjs` uses it.
- `bridge/*.py` and `tests/test_*.py` are used only by the Python CI job.
- The runtime connection code (`controller.ts`, `companion.ts`, `session.ts`, `queue.ts`, `metadata.ts`, `metadata-session.ts`) shares `src/prototype/` with hardware test CLIs (`live.ts`, `controls-live.ts`, `metadata-live.ts`, `acceptance-live.ts`, `acceptance.ts`, `metadata-pilot.ts`, `credentials.ts`; `live.ts` says it is "never imported by the installed Companion module").
- `tsconfig.build.json` includes all of `src/**/*.ts`, so `tsc` still compiles every one of these into `dist/`.

**Fix:** delete `src/transport.ts`, `bridge/` and their tests now that the Node backend has replaced them (or say in the README that they are kept only as a test oracle). Move the runtime files out of `src/prototype/` (e.g. to `src/device/`), and move the developer CLIs to a separate folder such as `tools/` with its own tsconfig, so the build only compiles code that `main.ts` uses.

## 💡 Nice to Have

### N1: Module introduces itself to the Apple TV as Companion Node Test

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/prototype/session.ts:146`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/prototype/session.ts#L146), [`src/prototype/session.ts:15`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/prototype/session.ts#L15)

**What goes wrong:** On every connection the module tells the Apple TV its device name is "Companion Node Test". If a session is cancelled for a reason other than a lost connection, the error "Test cancelled or connection closed" can reach the Companion log. Both strings are in the shipped `main.js`. Whether tvOS shows that name anywhere was not checked.

**Why it happens:** The connection code still carries strings from its test harness: the system-info request (`_systemInfo`) sends `['name', 'Companion Node Test']`, and the abort error is `new Error('Test cancelled or connection closed')`.

**Fix:** send a production name, e.g. the same `'Companion'` used as `PAIRING_NAME` in [`src/node-backend.ts:19`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/node-backend.ts#L19), and change the abort message to "Connection cancelled or closed".

### N2: Two apps whose ids differ only in punctuation share one App preset

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:58-69`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/presets.ts#L58-L69)

**What goes wrong:** If the TV reports two apps such as `com.example.app-tv` and `com.example.app.tv`, both get the preset id `app_com_example_app_tv`. In Presets → Apps, the first app's "Open …" button is missing and the second app's button is listed twice. This is rare.

**Why it happens:** The preset id replaces every character that isn't a letter or digit with `_`, so different app ids can map to the same preset id. The later app overwrites the earlier preset, and the id is added to the list twice.

```ts
// src/presets.ts:60-62
const id = `app_${app.id.replace(/[^A-Za-z0-9]/g, '_')}`
appIds.push(id)
presets[id] = {
```

**Fix:** make the ids unique, for example by appending an index or a short hash when the id is already in `presets`, or by encoding the other characters reversibly instead of collapsing them to `_`.

### N3: Enable Apple TV connection checkbox duplicates Companion's own enable switch

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:18`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/config.ts#L18)

**What goes wrong:** A user can have the connection enabled in Companion's connections list while its status reads "Disconnected" with the message "Disabled", because the module's own "Enable Apple TV connection" checkbox is off. Two enable switches with different meanings can confuse users. HELP.md step 1 ("Enable the connection and Save") doesn't say which switch it means.

**Why it happens:** The module stops and reports "Disabled" whenever its own `enabled` config field is off ([`src/node-backend.ts:164-169`](https://github.com/bitfocus/companion-module-apple-tv/blob/16c034e5cdb10a5e08d157147e1188f55f81cb8b/src/node-backend.ts#L164-L169)), independently of Companion's switch.

**Fix:** rely on Companion's connection enable switch and remove the `enabled` field: disabling a connection already calls `destroy()`, which stops the backend and cancels a pending pairing. If you keep the field, rename it to say what it does (e.g. "Connect to the Apple TV"), and say in HELP.md step 1 that it is the module's checkbox, separate from Companion's switch.
