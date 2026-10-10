# Review: presentationtools-aps v2.10.0

| | |
| --- | --- |
| **Module** | `companion-module-presentationtools-aps` ([repo](https://github.com/bitfocus/companion-module-presentationtools-aps)) |
| **Version** | v2.10.0 (`d6193ff`, 2026-09-29) |
| **Previous tag** | v2.9.1 (`64601cb`, 2026-01-28) |
| **Scope:** | tag (`v2.9.1..v2.10.0`) |
| **Language** | JavaScript (CommonJS) |
| **Template** | `companion-module-template-js-v1` @ `9e222b4` (2026-03-26, pinned) · `.yarnrc.yml` from `companion-module-template-js` @ `e4caa76` (2026-08-28) |
| **API** | 1 (base 1.7.1, yarn.lock) |
| **Build** | `yarn install --immutable` passes · `yarn package` fails (no `package` script) |
| **Review date** | 2026-10-08 |

The template and build checks (C1 to C6, H1, H2) apply to the whole module whatever the review scope, because a release that doesn't match the template or can't be built can't ship. Most of them were already true in v2.9.1. This release adds two more root-level source files (`build-total-smoother.js` and `states.js`).

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Three template files are missing, so line endings, formatting and Yarn settings are not pinned](#c1-three-template-files-are-missing-so-line-endings-formatting-and-yarn-settings-are-not-pinned)
- [ ] [C2: Packaged builds and debug logs are not ignored by git](#c2-packaged-builds-and-debug-logs-are-not-ignored-by-git)
- [ ] [C3: Source files sit at the repository root instead of in src](#c3-source-files-sit-at-the-repository-root-instead-of-in-src)
- [ ] [C4: Any Node or Yarn version can be used to build because engines and packageManager are missing](#c4-any-node-or-yarn-version-can-be-used-to-build-because-engines-and-packagemanager-are-missing)
- [ ] [C5: The module cannot be packaged because there is no package script](#c5-the-module-cannot-be-packaged-because-there-is-no-package-script)
- [ ] [C6: Companion runs the module on Node 18 instead of Node 22](#c6-companion-runs-the-module-on-node-18-instead-of-node-22)
- [ ] [H1: The LICENSE copyright line does not match the template](#h1-the-license-copyright-line-does-not-match-the-template)
- [ ] [H2: The Companion library and Prettier versions don't match the template the build tools expect](#h2-the-companion-library-and-prettier-versions-dont-match-the-template-the-build-tools-expect)

### Non-blocking

- [ ] [M1: Each config save during an APS trial leaves another timer running](#m1-each-config-save-during-an-aps-trial-leaves-another-timer-running)
- [ ] [L1: Connection still shows OK with the old machine name after APS quits](#l1-connection-still-shows-ok-with-the-old-machine-name-after-aps-quits)
- [ ] [L2: Connection errors show no reason](#l2-connection-errors-show-no-reason)
- [ ] [L3: A missing IP or port gives no warning in the connection status](#l3-a-missing-ip-or-port-gives-no-warning-in-the-connection-status)
- [ ] [L4: PowerPoint or Keynote options stay hidden after switching to a different APS computer](#l4-powerpoint-or-keynote-options-stay-hidden-after-switching-to-a-different-aps-computer)
- [ ] [L5: Go to slide action code reads like a bug](#l5-go-to-slide-action-code-reads-like-a-bug)

---

## 🔴 Critical

### C1: Three template files are missing, so line endings, formatting and Yarn settings are not pinned

- **Source:** 🤖 validate-template (FILE-MISSING ×3)
- **Classification:** 🆕 NEW (template check; also missing in v2.9.1)
- **File:** `.gitattributes`, `.prettierignore`, `.yarnrc.yml` (not present)

**What goes wrong:** A contributor on Windows can commit files with CRLF line endings, `yarn format` (Prettier) also reformats `package.json`, and Yarn runs without the template's settings. All official modules share these three files so that builds and diffs behave the same everywhere.

**Why it happens:** The repository doesn't contain these template files.

| File | Template expects |
| --- | --- |
| `.gitattributes` | `* text=auto eol=lf` |
| `.prettierignore` | `package.json` and `/LICENSE.md` |
| `.yarnrc.yml` | the JS template's `.yarnrc.yml` (Yarn 4 settings) |

**Fix:** copy the three files from the official JS template unchanged.

### C2: Packaged builds and debug logs are not ignored by git

- **Source:** 🤖 validate-template (CONFIG-DIFF .gitignore)
- **Classification:** 🆕 NEW (template check; also the case in v2.9.1)
- **File:** [`.gitignore:1-6`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/.gitignore#L1-L6)

**What goes wrong:** After running `yarn package` or debugging, the generated `.tgz` package, an npm `package-lock.json` and `DEBUG-*` files show up as untracked files and can be committed by accident.

**Why it happens:** `.gitignore` is missing these template entries: `package-lock.json`, `/*.tgz`, `DEBUG-*`, `/.yarn`.

**Fix:** add the missing template lines. Your existing entries can stay.

### C3: Source files sit at the repository root instead of in src

- **Source:** 🤖 validate-template (SRC-AT-ROOT ×9)
- **Classification:** 🆕 NEW (template check; [`build-total-smoother.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/build-total-smoother.js) and [`states.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/states.js) were added at the root in this release)
- **File:** [`actions.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/actions.js), [`build-total-smoother.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/build-total-smoother.js), [`choices.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/choices.js), [`constants.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/constants.js), [`feedbacks.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/feedbacks.js), [`index.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js), [`presets.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/presets.js), [`states.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/states.js), [`utils.js`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/utils.js)

**What goes wrong:** No effect for operators. The module's layout differs from every template-based module, which makes it harder to maintain, and the root-level files mix source with repository config.

**Why it happens:** The template keeps all module source under `src/`. These nine files are at the repository root.

**Fix:** move the nine files into `src/`. Then update `"main"` in [`package.json:4`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/package.json#L4) (for example `"src/index.js"`), `runtime.entrypoint` in [`companion/manifest.json:21`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/companion/manifest.json#L21) (for example `"../src/index.js"`), and the `require()` paths in `test/*.test.js`.

### C4: Any Node or Yarn version can be used to build because engines and packageManager are missing

- **Source:** 🤖 validate-template (PKG-FIELD ×2)
- **Classification:** 🆕 NEW (template check; also the case in v2.9.1)
- **File:** [`package.json:1-22`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/package.json#L1-L22)

**What goes wrong:** Nothing stops a contributor from installing and building with an old Node or Yarn version, which can produce a different lockfile or a broken package.

**Why it happens:** `package.json` has neither an `engines` field (the supported Node and Yarn versions) nor a `packageManager` field (the exact Yarn version Corepack should use). The committed `yarn.lock` is also a Yarn classic (`# yarn lockfile v1`) file.

```text
Template expects:  "engines": { "node": "^22.20", "yarn": "^4" }
                   "packageManager": "yarn@4.12.0"
Found:             (neither field present)
```

**Fix:** add both fields as in the template. Once `packageManager` and `.yarnrc.yml` (C1) are in place, run `corepack enable && yarn install` with Yarn 4 to regenerate the lockfile, then commit it.

### C5: The module cannot be packaged because there is no package script

- **Source:** 🤖 validate-template (PKG-SCRIPT package, BUILD-PACKAGE)
- **Classification:** 🆕 NEW (template check; also the case in v2.9.1)
- **File:** [`package.json:6-9`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/package.json#L6-L9)

**What goes wrong:** `yarn package` fails, so no installable module package can be built from this release.

**Why it happens:** `package.json` has no `"package"` script. The template's script runs `companion-module-build`, which bundles the module into the `.tgz` file Companion installs.

```text
Template expects:  "package": "companion-module-build"
Found:             scripts = { "test", "format" }
```

**Fix:** add `"package": "companion-module-build"` to `scripts`, then check that `yarn package` succeeds (see also H2).

### C6: Companion runs the module on Node 18 instead of Node 22

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW (template check; also the case in v2.9.1)
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/companion/manifest.json#L18)

**What goes wrong:** Companion starts this module with its older Node 18 runtime instead of the Node 22 runtime the template targets.

**Why it happens:** The manifest's `runtime.type` tells Companion which Node version to launch the module with, and it still says `node18`.

```text
Template expects:  "runtime": { "type": "node22", ... }
Found:             "runtime": { "type": "node18", ... }
```

**Fix:** set `runtime.type` to `"node22"`. `@companion-module/base` 1.7.1 declares `engines.node: ^18.12`, so upgrade base in the same change (see H2).

## 🟠 High

### H1: The LICENSE copyright line does not match the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** 🆕 NEW (template check; unchanged since v2.9.1)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/LICENSE#L3)

**What goes wrong:** No effect for operators. The licence text differs from the one every official module ships.

**Why it happens:** The copyright year is 2020 where the template has 2022.

```text
Template expects (line 3):  Copyright (c) 2022 Bitfocus AS - Open Source
Found:                      Copyright (c) 2020 Bitfocus AS - Open Source
```

**Fix:** replace `LICENSE` with the template's file verbatim.

### H2: The Companion library and Prettier versions don't match the template the build tools expect

- **Source:** 🔎 compliance reviewer (raised to High by the review maintainer)
- **Classification:** 🆕 NEW
- **File:** [`package.json:15-21`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/package.json#L15-L21)

**What goes wrong:** No user-visible effect today. This release raised the build tools (`@companion-module/tools`) to `^2.8.0` but kept the Companion library (`@companion-module/base`) at `~1.7.0` and Prettier at `^3.3.3`. The build tools say they don't support that library version, and the v1 template pins newer versions of both. A module built from an unsupported combination is confusing to troubleshoot: when something misbehaves, the cause may be the mismatch rather than the module's own code. Base 1.7.1 also requires Node 18, which conflicts with the Node 22 runtime C6 asks for.

**Why it happens:** only `@companion-module/tools` was bumped in this release; `@companion-module/base` and `prettier` were left as they were.

| Package | Found (installed) | Tools 2.8.0 requires | v1 template |
| --- | --- | --- | --- |
| `@companion-module/base` | `~1.7.0` (1.7.1) | `^1.12.0 \|\| ^2.0.0` | `~1.14.1` |
| `prettier` | `^3.3.3` (3.4.2) | `^3.6.2` | `^3.7.4` |

**Evidence:**

```diff
# git diff v2.9.1 v2.10.0 -- package.json
 	"devDependencies": {
-		"@companion-module/tools": "^1.4.2",
+		"@companion-module/tools": "^2.8.0",
 		"prettier": "^3.3.3"
```

```text
# node_modules/@companion-module/tools/package.json (2.8.0), peerDependencies
"@companion-module/base": "^1.12.0 || ^2.0.0"   (marked optional, so Yarn doesn't warn)
"prettier": "^3.6.2"                            (marked optional)

# node_modules/@companion-module/base/package.json (1.7.1)
"engines": { "node": "^18.12" }
```

Packaging a copy of v2.10.0 with `companion-module-build` and running `companion-module-check` both still succeed, so this is a version mismatch, not a broken build.

**Confirm by:** compare [`package.json:15-21`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/package.json#L15-L21) with the v1 template's `package.json`, and check `peerDependencies` in `node_modules/@companion-module/tools/package.json`.

**Fix:** raise `@companion-module/base` to `~1.14.1` and `prettier` to `^3.7.4`, as in the v1 template. Then run `yarn install`, `yarn package` (C5) and the tests again.

---

## 🟡 Medium

### M1: Each config save during an APS trial leaves another timer running

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:109`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L109) (timer created at [`index.js:486-491`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L486-L491), cleared at [`index.js:1275`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L1275))

**What goes wrong:** While the connected APS is in trial mode, every time the user saves the connection settings, one more 30-second timer is left running in the background. The timers only refresh the **licence** and **trial time left** variables, so the values stay correct, but the stray timers keep running after the trial ends and after the connection is disabled or deleted. There is no other visible effect.

**Why it happens:** In trial mode the module starts a repeating 30-second timer to refresh the trial countdown. Saving the config runs `configUpdated()`, which forgets the timer (sets `this.trialTimer = null`) without stopping it. The old connection's events are ignored after the reconnect, so nothing else stops it either. When the next trial status arrives, the module sees no timer and starts a new one. `destroy()`, which Companion calls when the connection is disabled or deleted, then stops only the newest timer.

**Fix:** stop the timer before forgetting it.

```js
if (this.trialTimer) clearInterval(this.trialTimer)
this.trialTimer = null
```

Calling `this.setLicenceStatus(null)` there also works, because it already stops the timer.

---

## 🟢 Low

### L1: Connection still shows OK with the old machine name after APS quits

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:175-185`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L175-L185) (status text set at [`index.js:474-481`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L474-L481))

**What goes wrong:** When APS is closed normally, the connection keeps showing OK with the machine text this release added (for example `<machine> · Mac · APS x.y · Trial`), while the connected-machine variables already show `-`. The status only changes when a reconnect attempt fails with an error.

**Why it happens:** A clean close produces a "disconnected" status change but no error event. The new disconnect branch clears the machine, licence and preparation state, but the line that would pass the status on to Companion (`self.updateStatus(status)`) is still commented out, and clearing the machine doesn't touch the status either.

**Fix:** in the `status !== InstanceStatus.Ok` branch, call `self.updateStatus(status, message)`.

### L2: Connection errors show no reason

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW (handler changed in this release)
- **File:** [`index.js:187-191`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L187-L191)

**What goes wrong:** When the connection fails, the status shows a generic "Unknown error" with no message and nothing is logged, so the user can't tell a refused connection from an unreachable host.

**Why it happens:** The socket's error handler ignores the error it receives and sets `InstanceStatus.UnknownError` without a message.

**Fix:** report the error's message in the status and the log.

```js
self.socket.on('error', (err) => {
	if (socket !== self.socket) return
	self.buildTotalSmoother.resetConnection()
	self.updateStatus(InstanceStatus.ConnectionFailure, err.message)
	self.log('error', `APS socket: ${err.message}`)
})
```

### L3: A missing IP or port gives no warning in the connection status

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW (code rewritten in this release)
- **File:** [`index.js:170-171`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L170-L171), [`index.js:445-450`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L445-L450)

**What goes wrong:** If no APS machine is picked from discovery and the **Target IP** or **Target Port** is empty, the module never connects and the connection status says nothing about why. Separately, if the saved discovered machine can't be read, the module silently connects to the manual IP and port, which the config screen hides while a discovered machine is selected.

**Why it happens:** When there is no usable target, the module skips creating the socket but doesn't set a status. When the discovered-machine value fails to parse, the target lookup falls through to the manual fields without saying so.

**Fix:** after `if (target) { ... }`, add `else { self.updateStatus(InstanceStatus.BadConfig, 'Select an APS machine or enter IP and port') }`. When a discovered machine is set but can't be parsed, report `BadConfig` instead of falling back to the manual fields.

### L4: PowerPoint or Keynote options stay hidden after switching to a different APS computer

- **Source:** 🔎 protocol reviewer
- **Classification:** 🆕 NEW
- **File:** [`index.js:54`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L54), [`index.js:226`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L226), [`index.js:624-634`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L624-L634)

**What goes wrong:** A user connected to a Mac running APS 4.3 or later changes the host, port or discovered machine to a Windows PC running an older APS. The PowerPoint media actions, feedback, presets and variables, and the PowerPoint slide-number variables, stay hidden even though the PC supports them. Switching the other way leaves the Keynote options in the wrong state in the same way.

**Why it happens:** The module remembers the last platform APS reported (Mac or Windows) and deliberately keeps it across disconnects so options don't flicker while reconnecting. Only APS's `aps_info` message updates it, and APS versions before 4.3 never send that message, so a new target on older APS keeps the previous computer's platform.

**Fix:** in `configUpdated()`, reset `this.apsPlatform` to `null` when the connection target differs from the previous one, then rebuild the definitions.

### L5: Go to slide action code reads like a bug

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW (reformatted in this release)
- **File:** [`actions.js:1056-1060`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/actions.js#L1056-L1060)

**What goes wrong:** No effect for operators; the **Slide: Go to slide** action works. The code is hard to read and looks like a mistake.

**Why it happens:** v2.9.1 had a stray trailing comma (`data.command = action.options.App,`) that joined two statements into one. Prettier has now rewritten it as `;((data.command = ...), (data.parameters = {...}))`.

**Fix:** write it as two plain statements.

```js
data.command = action.options.App
data.parameters = { slideNr: parseInt(await instance.parseVariablesInString(action.options.SlideNumber)) }
```

---

## 🔮 Next Release

- Together with the base upgrade (H2), convert the `isVisible` functions on config fields to `isVisibleExpression` (for example `!$(options:bonjourHost)`), including the three new ones at [`index.js:582`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L582), [`index.js:591`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L591) and [`index.js:597`](https://github.com/bitfocus/companion-module-presentationtools-aps/blob/d6193ffd3b635fb5318554edf2bbe02aa9ee3299/index.js#L597). `isVisible` functions are deprecated from base 1.12.
- On base 1.13 or later, remove the now-redundant `parseVariablesInString` calls on `useVariables` text inputs, because Companion parses those itself.
