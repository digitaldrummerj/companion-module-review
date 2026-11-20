# Review: companion-module-largedisplaysolutions-ldsperimetral v0.9.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-largedisplaysolutions-ldsperimetral` |
| **Scope** | `tag` |
| **Version** | v0.9.1 |
| **Release** | New module — never published |
| **API** | 1 (base 1.11.0, package.json range) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`78ee009`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/commit/78ee009a484d2d93b151f0540d924286d6047e0e) |
| **Reviewed** | 2026-11-19 |

## Verdict: ❌ Changes Required

## ❓ Assumptions

Some findings depend on assumptions the reviewers couldn't check. They're listed in [❓ Assumptions to Confirm](#-assumptions-to-confirm) at the end of this review.

## 📋 Issues

### Blocking

- [ ] [C1: package.json is missing most of the template's scripts, tools and settings](#c1-packagejson-is-missing-most-of-the-templates-scripts-tools-and-settings)
- [ ] [C2: No yarn.lock is committed, so every install can pull different dependency versions](#c2-no-yarnlock-is-committed-so-every-install-can-pull-different-dependency-versions)
- [ ] [C3: The template's formatting, lint, Yarn and build config files are missing](#c3-the-templates-formatting-lint-yarn-and-build-config-files-are-missing)
- [ ] [C4: .gitattributes doesn't force LF line endings](#c4-gitattributes-doesnt-force-lf-line-endings)
- [ ] [C5: .gitignore is missing the template's build output and tool entries](#c5-gitignore-is-missing-the-templates-build-output-and-tool-entries)
- [ ] [H1: Is Playing and Is Paused feedbacks never change colour after the button is first drawn](#h1-is-playing-and-is-paused-feedbacks-never-change-colour-after-the-button-is-first-drawn)
- [ ] [H2: Connection status is always green OK, even when the LDSperimetral PC is off or the IP is wrong](#h2-connection-status-is-always-green-ok-even-when-the-ldsperimetral-pc-is-off-or-the-ip-is-wrong)
- [ ] [H3: The source doesn't compile: yarn build stops with 9 TypeScript errors](#h3-the-source-doesnt-compile-yarn-build-stops-with-9-typescript-errors)
- [ ] [H4: Playlist and Overlay dropdowns show the French label (liste vide)](#h4-playlist-and-overlay-dropdowns-show-the-french-label-liste-vide)
- [ ] [H5: Type definitions are still for Node 20 while the module runs on Node 22](#h5-type-definitions-are-still-for-node-20-while-the-module-runs-on-node-22)
- [ ] [H6: There is no lint setup, so yarn lint fails](#h6-there-is-no-lint-setup-so-yarn-lint-fails)
- [ ] [H7: Upgrade scripts are inlined in main.ts instead of the template's src/upgrades.ts](#h7-upgrade-scripts-are-inlined-in-maints-instead-of-the-templates-srcupgradests)
- [ ] [H8: package.json differs from the template in its build command, TypeScript range and repository field](#h8-packagejson-differs-from-the-template-in-its-build-command-typescript-range-and-repository-field)
- [ ] [H9: README title names the module ldsperimeter instead of ldsperimetral](#h9-readme-title-names-the-module-ldsperimeter-instead-of-ldsperimetral)
- [ ] [H10: HELP says Start Sequence in Playlist offers sequence names, but it only takes an index](#h10-help-says-start-sequence-in-playlist-offers-sequence-names-but-it-only-takes-an-index)
- [ ] [H11: The connection log fills with a line for every request, and with errors when the PC is off](#h11-the-connection-log-fills-with-a-line-for-every-request-and-with-errors-when-the-pc-is-off)
- [ ] [H12: Move to @companion-module/base 1.14, the template's version](#h12-move-to-companion-modulebase-114-the-templates-version)

### Non-blocking

- [ ] [M1: No GitHub workflows, so pushes and pull requests are never checked](#m1-no-github-workflows-so-pushes-and-pull-requests-are-never-checked)
- [ ] [L1: Action and preset lists are re-sent to Companion on every refresh, even when nothing changed](#l1-action-and-preset-lists-are-re-sent-to-companion-on-every-refresh-even-when-nothing-changed)
- [ ] [L2: Commands that LDSperimetral rejects fail silently](#l2-commands-that-ldsperimetral-rejects-fail-silently)
- [ ] [L3: Playlists or overlays whose names differ only in punctuation share one preset](#l3-playlists-or-overlays-whose-names-differ-only-in-punctuation-share-one-preset)
- [ ] [L4: Actions and presets appear only after the device answers or times out at startup](#l4-actions-and-presets-appear-only-after-the-device-answers-or-times-out-at-startup)
- [ ] [N1: The per-second time update also asks for the instance name every second](#n1-the-per-second-time-update-also-asks-for-the-instance-name-every-second)
- [ ] [N2: The IP Address setting accepts any text, including a URL or a port](#n2-the-ip-address-setting-accepts-any-text-including-a-url-or-a-port)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: package.json is missing most of the template's scripts, tools and settings

- **Source:** 🤖 validate-template (PKG-FIELD, PKG-SCRIPT, PKG-DEVDEP, PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json)

**What goes wrong:** No visible effect for Companion users. The maintainer and Bitfocus can't run the standard module commands (`yarn package`, `yarn lint`, `yarn format`, `yarn dev`), nothing checks code before a commit, and installs aren't tied to Yarn 4 or Node 22.

**Why it happens:** package.json was written by hand with only a `build` script, `@types/node` and `typescript`. The API 1.x TypeScript template's package.json has much more:

| Kind | Missing (template value) |
| --- | --- |
| Scripts | `postinstall`, `format`, `package`, `build:main`, `dev`, `lint:raw`, `lint` |
| devDependencies | `@companion-module/tools`, `eslint`, `husky`, `lint-staged`, `prettier`, `rimraf`, `typescript-eslint` |
| Fields | `engines` (`"node": "^22.20"`, `"yarn": "^4"`), `prettier` (`@companion-module/tools/.prettierrc.json`), `packageManager` (`yarn@4.12.0`) |
| Sections | `lint-staged` |

**Evidence:**

```json
// package.json (whole file at v0.9.1)
{
  "name": "companion-module-largedisplaysolutions-ldsperimetral",
  "version": "0.9.1",
  "description": "Bitfocus Companion module for LDSperimetral v1.58.1 - Large Display Solutions",
  "main": "dist/main.js",
  "type": "module",
  "license": "MIT",
  "dependencies": {
    "@companion-module/base": "~1.11.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0"
  },
  "scripts": {
    "build": "tsc -p tsconfig.json"
  }
}
```

**Confirm by:** compare [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json) with `companion-module-template-ts-v1/package.json`.

**Fix:** start from the template's package.json and keep only the module's own name, version, description and dependency. The `build` script, TypeScript range and `repository` field are covered in [H8](#h8-packagejson-differs-from-the-template-in-its-build-command-typescript-range-and-repository-field), and `@types/node` in [H5](#h5-type-definitions-are-still-for-node-20-while-the-module-runs-on-node-22).

```json
"scripts": {
  "postinstall": "husky",
  "format": "prettier -w .",
  "package": "run build && companion-module-build",
  "build": "rimraf dist && run build:main",
  "build:main": "tsc -p tsconfig.build.json",
  "dev": "tsc -p tsconfig.build.json --watch",
  "lint:raw": "eslint",
  "lint": "run lint:raw ."
},
"engines": { "node": "^22.20", "yarn": "^4" },
"devDependencies": {
  "@companion-module/tools": "^2.6.1",
  "@types/node": "^22.19.3",
  "eslint": "^9.39.2",
  "husky": "^9.1.7",
  "lint-staged": "^16.2.7",
  "prettier": "^3.7.4",
  "rimraf": "^6.1.2",
  "typescript": "~5.9.3",
  "typescript-eslint": "^8.51.0"
},
"prettier": "@companion-module/tools/.prettierrc.json",
"lint-staged": {
  "*.{css,json,md,scss}": ["prettier --write"],
  "*.{ts,tsx,js,jsx}": ["yarn lint:raw --fix"]
},
"packageManager": "yarn@4.12.0"
```

### C2: No yarn.lock is committed, so every install can pull different dependency versions

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `yarn.lock` (missing)

**What goes wrong:** Without a lockfile, each install picks the newest versions the ranges allow (`~1.11.0`, `^5.0.0`, `^20.0.0`). The package Bitfocus builds can contain different dependency versions from the ones the maintainer tested. With no `packageManager` field, the review's install even ran with the old Yarn 1 instead of Yarn 4.

**Why it happens:** `yarn.lock` is not in the repository.

**Evidence:**

```text
validate-template FILE-MISSING: yarn.lock: Required file is missing
```

**Confirm by:** `git ls-files yarn.lock` in the module repo prints nothing.

**Fix:** after adding `packageManager` ([C1](#c1-packagejson-is-missing-most-of-the-templates-scripts-tools-and-settings)) and `.yarnrc.yml` ([C3](#c3-the-templates-formatting-lint-yarn-and-build-config-files-are-missing)), run `yarn install` with Yarn 4 and commit the generated `yarn.lock`.

### C3: The template's formatting, lint, Yarn and build config files are missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit`, `.prettierignore`, `.yarnrc.yml`, `eslint.config.mjs`, `tsconfig.build.json` (all missing)

**What goes wrong:** No visible effect for Companion users. Without these files the template's commands can't work: there is no pre-commit check, no lint configuration, no Yarn 4 settings, and no `tsconfig.build.json` for the template's `build:main` script to compile with.

**Why it happens:** The module wasn't started from the template, so the files the template tracks were never added.

**Evidence:**

```text
validate-template FILE-MISSING: .husky/pre-commit    Required file is missing (tracked by the template)
validate-template FILE-MISSING: .prettierignore      Required file is missing (tracked by the template)
validate-template FILE-MISSING: .yarnrc.yml          Required file is missing (tracked by the template)
validate-template FILE-MISSING: eslint.config.mjs    Required file is missing (tracked by the template)
validate-template FILE-MISSING: tsconfig.build.json  Required file is missing (tracked by the template)
```

**Confirm by:** the module repo's file list at v0.9.1 has none of the five files.

**Fix:** copy the five files from `companion-module-template-ts-v1` (and `.yarnrc.yml` from the current `companion-module-template-ts`).

### C4: .gitattributes doesn't force LF line endings

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitattributes:2`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/.gitattributes#L2)

**What goes wrong:** On a Windows checkout, files can get CRLF line endings. Prettier and the linter then flag every line, and commits show whole-file changes.

**Why it happens:** The rule is `* text=auto` without the template's `eol=lf`.

**Evidence:**

```text
validate-template CONFIG-DIFF .gitattributes: found '* text=auto', template '* text=auto eol=lf'
```

**Confirm by:** open [`.gitattributes`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/.gitattributes).

**Fix:** use the template's line.

```text
* text=auto eol=lf
```

### C5: .gitignore is missing the template's build output and tool entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/.gitignore)

**What goes wrong:** Files the template keeps out of git, such as the `pkg/` folder that `companion-module-build` creates, `DEBUG-*` logs, a `package-lock.json` or `.vscode` settings, can be committed by accident.

**Why it happens:** The `.gitignore` is a general Node.js ignore list, not the template's. It doesn't have the template's anchored entries.

**Evidence:**

```text
validate-template CONFIG-DIFF .gitignore: Missing template .gitignore entries: package-lock.json, /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode
```

**Confirm by:** compare [`.gitignore`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/.gitignore) with the template's `.gitignore`.

**Fix:** add the template's entries.

```text
node_modules/
package-lock.json
/pkg
/*.tgz
/dist
DEBUG-*
/.yarn
/.vscode
```

## 🟠 High

### H1: Is Playing and Is Paused feedbacks never change colour after the button is first drawn

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:17-31`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/feedbacks.ts#L17-L31), [`src/main.ts:129-147`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L129-L147)

**What goes wrong:** An operator drags in the "Pause / Resume" preset, which turns yellow through the "Is Paused" feedback, or adds the green "Is Playing" feedback to a button. The colour is worked out once, when the connection starts or the feedback is added, and then never changes. The operator presses PAUSE/RESUME, LDSperimetral pauses, and the module even sets the `is_paused` variable to `true` straight away, but the button stays dark grey. When playback starts or stops, the "Is Playing" button keeps its old colour until the button is edited or the connection is restarted. These are the module's only two feedbacks, so every state colour on the surface is wrong for the rest of the session.

**Why it happens:** Both feedbacks read the module's own copy of the variables (`getVariableValue`). Companion only runs a feedback again when the module asks for it with `checkFeedbacks()`, when the feedback is added or edited, or when a variable that the feedback read through the callback's `context.parseVariablesInString` changes. `getVariableValue` is a plain lookup that Companion doesn't track. The polling code updates `is_playing` and `is_paused` with `setVariableValues`, but nothing in the module ever calls `checkFeedbacks`.

**Evidence:**

```ts
// src/feedbacks.ts:17-19 and 29-31
      callback: () => {
        return self.getVariableValue('is_playing') === 'true'
      },
...
      callback: () => {
        return self.getVariableValue('is_paused') === 'true'
      },
```

```ts
// src/main.ts:129-147
  private async pollReproductionState() {
    try {
      const data = await this.makeRequest('/ws/remoteplayer/get_reproduction_state')
      if (data) {
        const json = JSON.parse(data) as ApiResponse<ReproductionState>
        if (json.status === 0 && json.result) {
          const s = json.result
          this.setVariableValues({
            is_playing: s.is_playing ? 'true' : 'false',
            is_paused: s.is_paused ? 'true' : 'false',
            ...
          })
        }
      }
    } catch (e) {
```

```js
// node_modules/@companion-module/base/dist/module-api/base.js:364-366 (base 1.11.3)
    getVariableValue(variableId) {
        return this.#variableValues.get(variableId);
    }
// node_modules/@companion-module/base/dist/internal/feedback.js:145-157 (handleVariablesChanged)
        for (const feedback of this.#feedbackInstances.values()) {
            if (this.#feedbacksBeingChecked.has(feedback.id))
                continue;
            if (feedback.referencedVariables) {
                for (const id of feedback.referencedVariables) {
                    if (changedFeedbackIds.has(id)) {
                        feedbackIds.add(feedback.id);
```

```ts
// src/presets.ts:64-70 (the "Pause / Resume" preset)
      feedbacks: [
        {
          feedbackId: 'is_paused',
          options: {},
          style: { bgcolor: 0xffff00, color: 0x000000 },
        },
      ],
```

```text
$ grep -rn checkFeedbacks src/
(no matches)
```

**Confirm by:** open [`src/main.ts:136-145`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L136-L145). `setVariableValues` is not followed by `this.checkFeedbacks('is_playing', 'is_paused')`, and `grep -rn checkFeedbacks src/` finds nothing.

**Fix:** ask Companion to re-check both feedbacks whenever the playback state is read. Better still, keep the last state in a field, have the feedbacks read that field, and re-check only when `is_playing` or `is_paused` actually changed.

```ts
this.setVariableValues({ ... })
this.checkFeedbacks('is_playing', 'is_paused')
```

### H2: Connection status is always green OK, even when the LDSperimetral PC is off or the IP is wrong

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:63-79`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L63-L79), [`src/main.ts:86-93`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L86-L93), [`src/main.ts:191-218`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L191-L218)

**What goes wrong:** A user adds the connection with a wrong IP, for example 192.168.1.50 when the PC is at .51, or the LDSperimetral PC is switched off. The Connections list still shows the connection as green OK. Every button (Stop, Start Playlist, Set Global Brightness, …) does nothing, and the Playlist and Overlay dropdowns show only the "(liste vide)" placeholder ([H4](#h4-playlist-and-overlay-dropdowns-show-the-french-label-liste-vide)). The only sign is error lines in the connection log. Saving new settings never changes the status either. If the IP field has a stray trailing space ("192.168.1.51 "), every request fails with an invalid-URL error that is logged only at debug level, so even the normal log shows nothing.

**Why it happens:** The request helper (`makeRequest`) never tells its callers that a request failed: on an HTTP error, a socket error or a timeout it simply returns nothing. `init()` then sets the status to OK without checking whether any request worked. The status is set in only two places, both in `init()`; the polling loop and `configUpdated()` never change it.

**Evidence:**

```ts
// src/main.ts:63-79
  public async init(config: ModuleConfig): Promise<void> {
    this.config = config
    this.updateStatus(InstanceStatus.Connecting)
    ...
    await this.refreshLists()
    await this.pollState()
    this.setActionDefinitions(getActions(this))
    this.setPresetDefinitions(getPresets(this))

    this.startPolling()
    this.updateStatus(InstanceStatus.Ok)
```

```ts
// src/main.ts:195-216
    return new Promise((resolve) => {
      const req = http.get(url, (res) => {
        ...
          if (code >= 200 && code < 400) {
            resolve(data.trim())
          } else {
            this.log('warn', `← HTTP ${code} for ${path}`)
            resolve()
          }
        ...
      req.on('error', (err) => {
        this.log('error', `Request error: ${err.message}`)
        resolve()
      })
      req.setTimeout(3000, () => {
        req.destroy()
        resolve()
      })
```

```text
$ grep -rn "updateStatus\|InstanceStatus" src
src/main.ts:3:  InstanceStatus,
src/main.ts:65:    this.updateStatus(InstanceStatus.Connecting)
src/main.ts:77:    this.updateStatus(InstanceStatus.Ok)

$ node: http.get('http://192.168.1.51 :8082/ws/x') inside a Promise executor
rejected ERR_INVALID_URL   (caught in pollReproductionState and logged at 'debug', src/main.ts:148-150)
```

**Confirm by:** open [`src/main.ts:77`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L77): the status is set to OK whether or not any request worked, and [`src/main.ts:200-216`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L200-L216) returns nothing on every failure.

**Fix:** let the request helper report success or failure, and set the status from the polling result: OK on a valid reply, ConnectionFailure (with the error message) on a socket error, timeout or HTTP error. Only call `updateStatus` when the status changes, set Connecting at the start of `configUpdated()`, and trim the host before building the URL.

```ts
private setConnectionStatus(ok: boolean, message?: string) {
  const next = ok ? InstanceStatus.Ok : InstanceStatus.ConnectionFailure
  if (next === this.lastStatus) return
  this.lastStatus = next
  this.updateStatus(next, message)
}

// in pollReproductionState(): after a reply with status 0
this.setConnectionStatus(true)
// when makeRequest returned nothing, or the reply's status isn't 0
this.setConnectionStatus(false, 'No reply from LDSperimetral')
```

### H3: The source doesn't compile: yarn build stops with 9 TypeScript errors

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:1-10`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/config.ts#L1-L10), [`src/feedbacks.ts:3-5`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/feedbacks.ts#L3-L5), [`src/actions.ts:5-7`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L5-L7)

**What goes wrong:** No user is directly affected yet, but the release can't be produced. The module's own `build` script exits with an error, so any build step that runs it, such as the template's `run build && companion-module-build`, stops. TypeScript still writes `dist/` despite the errors, so a local build seems to work unless you check the exit code. Adding the missing `package` script ([C1](#c1-packagejson-is-missing-most-of-the-templates-scripts-tools-and-settings)) won't fix this, because the source itself fails the type check.

**Why it happens:** Two kinds of type mismatch against `@companion-module/base` 1.11. The config fields are typed as the base interface `CompanionConfigField`, which knows only `width` and the common fields, so `default`, `min` and `max` are rejected; the template uses `SomeCompanionConfigField`. And the hand-written `Self` types in feedbacks.ts and actions.ts are narrower than the real module class: `getVariableValue` is declared to return a string where the base returns any variable value, and `log` takes any string where the base only accepts a log level. Under `strict`, passing `this` to those functions fails.

**Evidence:**

```text
$ ./node_modules/.bin/tsc -p tsconfig.json --noEmit   (typescript 5.9.3, @companion-module/base 1.11.3)
src/config.ts(17,7): error TS2353: Object literal may only specify known properties, and 'default' does not exist in type 'CompanionConfigField'.
src/config.ts(24,7): error TS2353: Object literal may only specify known properties, and 'min' does not exist in type 'CompanionConfigField'.
src/config.ts(33,7): error TS2353: Object literal may only specify known properties, and 'min' does not exist in type 'CompanionConfigField'.
src/config.ts(42,7): error TS2353: Object literal may only specify known properties, and 'default' does not exist in type 'CompanionConfigField'.
src/main.ts(68,46): error TS2345: Argument of type 'this' is not assignable to parameter of type 'Self'.
      Type 'CompanionVariableValue | undefined' is not assignable to type 'string | undefined'.
src/main.ts(73,42): error TS2345: ... Type 'string' is not assignable to type 'LogLevel'.
src/main.ts(90,42): error TS2345: ... Type 'string' is not assignable to type 'LogLevel'.
src/main.ts(96,5): error TS2322: Type 'CompanionConfigField[]' is not assignable to type 'SomeCompanionConfigField[]'.
src/main.ts(109,44): error TS2345: ... Type 'string' is not assignable to type 'LogLevel'.
exit=2
```

```ts
// src/config.ts:1, 10
import type { CompanionConfigField } from '@companion-module/base'
export function getConfigFields(): CompanionConfigField[] {
// src/feedbacks.ts:3-5
type Self = {
  getVariableValue: (variableId: string) => string | undefined
}
// src/actions.ts:5-7
type Self = {
  makeRequest: (path: string) => Promise<string | void>
  log: (level: string, message: string) => void
```

**Confirm by:** in the module, run `./node_modules/.bin/tsc -p tsconfig.json --noEmit; echo $?`. It prints the 9 errors above and exit code 2.

**Fix:** return `SomeCompanionConfigField[]` from `getConfigFields()`, as the template's config.ts does, and type the `self` parameter of actions, feedbacks and presets as the module class instead of hand-written `Self` types. Then check that `yarn build` exits 0.

```ts
// src/config.ts
import type { SomeCompanionConfigField } from '@companion-module/base'
export function getConfigFields(): SomeCompanionConfigField[] {

// main.ts: export class LDSperimetralInstance ...
// actions.ts / feedbacks.ts / presets.ts
import type { LDSperimetralInstance } from './main.js'
export function getActions(self: LDSperimetralInstance): CompanionActionDefinitions {
```

### H4: Playlist and Overlay dropdowns show the French label (liste vide)

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:14-21`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L14-L21)

**What goes wrong:** When LDSperimetral was unreachable at startup, or has no playlists or overlay sequences, a user opens the "Start Playlist", "Start Sequence in Playlist" or "Start Overlay (Stay on Top)" action. The only choice in the Playlist or Overlay Sequence dropdown reads "(liste vide)", French for "(empty list)". Users and supporters who don't read French can't tell what it means. Every user-facing string must be in English. This is the only non-English text in the module; the French documentation link in HELP.md is not counted.

**Why it happens:** The dropdown helper's fallback label defaults to the French string, and all three dropdowns use that default ([`src/actions.ts:83`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L83), [`93`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L93), [`114`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L114)).

**Evidence:**

```ts
// src/actions.ts:14-21
function dropdown(id: string, label: string, choices: Choice[], fallback = '(liste vide)') {
  return {
    type: 'dropdown' as const,
    id,
    label,
    choices: choices.length > 0 ? choices : [{ id: '', label: fallback }],
    default: choices[0]?.id ?? '',
  }
```

**Confirm by:** open [`src/actions.ts:14`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L14). None of the three callers passes its own fallback.

**Fix:** use an English label.

```ts
function dropdown(id: string, label: string, choices: Choice[], fallback = '(none found, check the connection)') {
```

### H5: Type definitions are still for Node 20 while the module runs on Node 22

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`package.json:12`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json#L12)

**What goes wrong:** No visible effect for users. The manifest runs the module on Node 22, but it is type-checked against Node 20's API, so Node 22 features are missing from the types and Node 20-only assumptions aren't caught.

**Why it happens:** The API 1 template is on Node 22 everywhere. This module's manifest `runtime.type` is already `node22`; only `@types/node` is still on 20. The missing `engines` field is part of [C1](#c1-packagejson-is-missing-most-of-the-templates-scripts-tools-and-settings), and the missing workflows are [M1](#m1-no-github-workflows-so-pushes-and-pull-requests-are-never-checked).

**Evidence:**

```text
validate-template NODE-VERSION: package.json devDependencies @types/node '^20.0.0' -> '^22.19.3'
```

**Confirm by:** open [`package.json:12`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json#L12).

**Fix:** update every place to Node 22:

- [ ] `package.json`: `"@types/node": "^22.19.3"` in devDependencies
- [ ] `package.json`: when adding `engines` ([C1](#c1-packagejson-is-missing-most-of-the-templates-scripts-tools-and-settings)), use the template's `"node": "^22.20"`

### H6: There is no lint setup, so yarn lint fails

- **Source:** 🤖 validate-template (LINT)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json)

**What goes wrong:** No visible effect for users. `yarn lint`, which Bitfocus uses to check a module, fails, so none of the template's lint rules are applied to the code.

**Why it happens:** There is no `lint` script, no `eslint` or `typescript-eslint` devDependency, and no `eslint.config.mjs`.

**Evidence:**

```text
validate-template LINT: yarn lint reported problems (no 'lint' script, no eslint, no eslint.config.mjs)
```

**Confirm by:** run `yarn lint` in a clean checkout.

**Fix:** add the template's `lint` and `lint:raw` scripts and devDependencies ([C1](#c1-packagejson-is-missing-most-of-the-templates-scripts-tools-and-settings)) and `eslint.config.mjs` ([C3](#c3-the-templates-formatting-lint-yarn-and-build-config-files-are-missing)), then fix what `yarn lint` reports until it is clean.

### H7: Upgrade scripts are inlined in main.ts instead of the template's src/upgrades.ts

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:221-223`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L221-L223)

**What goes wrong:** No visible effect for users today. When an action or option is renamed in a later release, there is no obvious place to add the first upgrade script, and a module laid out differently from its template is harder to maintain and troubleshoot.

**Why it happens:** The API 1.x TypeScript template keeps upgrade scripts in `src/upgrades.ts`, which exports `UpgradeScripts`, and passes that list to `runEntrypoint`. This module has no upgrades file and passes an empty list written inline.

**Evidence:**

```text
// git ls-files src/ (v0.9.1)
src/actions.ts
src/config.ts
src/feedbacks.ts
src/main.ts
src/presets.ts
src/variables.ts
```

```ts
// src/main.ts:221-223
export default LDSperimetralInstance

runEntrypoint(LDSperimetralInstance, [])
```

```ts
// companion-module-template-ts-v1/src/main.ts
import { UpgradeScripts } from './upgrades.js'
runEntrypoint(ModuleInstance, UpgradeScripts)
```

**Confirm by:** run `git ls-files src/` in the module (no `src/upgrades.ts`), then open [`src/main.ts:223`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L223).

**Fix:** copy the template's `src/upgrades.ts` and pass its list to `runEntrypoint`.

```ts
// src/upgrades.ts
import type { CompanionStaticUpgradeScript } from '@companion-module/base'
import type { ModuleConfig } from './config.js'

export const UpgradeScripts: CompanionStaticUpgradeScript<ModuleConfig>[] = []

// src/main.ts
import { UpgradeScripts } from './upgrades.js'
runEntrypoint(LDSperimetralInstance, UpgradeScripts)
```

### H8: package.json differs from the template in its build command, TypeScript range and repository field

- **Source:** 🔎 compliance reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`package.json:11-17`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json#L11-L17)

**What goes wrong:** No visible effect for users. Three package.json differences from the template aren't covered by [C1](#c1-packagejson-is-missing-most-of-the-templates-scripts-tools-and-settings):

1. `build` is `tsc -p tsconfig.json`. The template's `rimraf dist && run build:main` clears `dist/` first, so files from deleted sources can't ship in the package.
2. `typescript` is `^5.0.0` where the template has `~5.9.3`, so with no lockfile any TypeScript 5.x can be installed.
3. There is no `repository` field at all.

**Why it happens:** package.json was written by hand instead of starting from the template.

**Evidence:**

```json
// package.json:11-17
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.0.0"
  },
  "scripts": {
    "build": "tsc -p tsconfig.json"
  }
```

```json
// companion-module-template-ts-v1/package.json
    "build": "rimraf dist && run build:main",
    "build:main": "tsc -p tsconfig.build.json",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/bitfocus/companion-module-your-module-name.git"
  },
    "typescript": "~5.9.3",
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json): there is no `repository` key, and lines 11-17 differ from the template as shown.

**Fix:** use the template's `build` and `build:main` scripts and TypeScript range, and add the repository.

```json
"build": "rimraf dist && run build:main",
"build:main": "tsc -p tsconfig.build.json",
"repository": {
  "type": "git",
  "url": "git+https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral.git"
},
"typescript": "~5.9.3"
```

### H9: README title names the module ldsperimeter instead of ldsperimetral

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`README.md:1`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/README.md#L1)

**What goes wrong:** The README heading reads "companion-module-largedisplaysolutions-ldsperimeter", but the module and repository are "…-ldsperimetral", so anyone searching for or linking the module by the README title gets the wrong name.

**Why it happens:** A typo in the heading.

**Evidence:**

```markdown
<!-- README.md:1 -->
# companion-module-largedisplaysolutions-ldsperimeter
```

**Confirm by:** open [`README.md:1`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/README.md#L1): the heading ends in `ldsperimeter`, while `package.json` `name` and the repository end in `ldsperimetral`.

**Fix:** change the heading to `# companion-module-largedisplaysolutions-ldsperimetral`, or to the product name `# LDSperimetral`.

### H10: HELP says Start Sequence in Playlist offers sequence names, but it only takes an index

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/HELP.md:21`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/companion/HELP.md#L21), [`src/actions.ts:90-111`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L90-L111)

**What goes wrong:** HELP.md says "Sequence names proposed in 'Start Sequence in Playlist'". A user who opens that action finds only a Playlist dropdown and a "Sequence Index (0-based)" number, so they have to count sequences by hand.

**Why it happens:** The action has a number option for the index and no sequence-name choices; the module never fetches the sequences inside a playlist.

**Evidence:**

```markdown
<!-- companion/HELP.md:21 -->
- Sequence names proposed in "Start Sequence in Playlist"
```

```ts
// src/actions.ts:90-101
    start_sequence: {
      name: 'Start Sequence in Playlist',
      options: [
        dropdown('playlist', 'Playlist', playlists),
        {
          type: 'number',
          id: 'index',
          label: 'Sequence Index (0-based)',
          default: 0,
          min: 0,
          max: 999,
        },
```

**Confirm by:** compare [`companion/HELP.md:21`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/companion/HELP.md#L21) with the action's options in [`src/actions.ts:90-111`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L90-L111): there is a Playlist dropdown and a number, and no sequence-name option.

**Fix:** change the HELP.md line to describe the 0-based index, or fetch each playlist's sequences and offer them in a dropdown.

### H11: The connection log fills with a line for every request, and with errors when the PC is off

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:193`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L193), [`src/main.ts:209-211`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L209-L211), [`src/main.ts:174`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L174), [`src/main.ts:183`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L183)

**What goes wrong:** Every request writes an info line such as `→ http://192.168.1.51:8082/ws/remoteplayer/get_reproduction_state`, and every refresh adds "Playlists: N" and "Overlays: N". With the default 60-second refresh that is 6 info lines a minute. With "Update time variables (elapsed_ms / total_ms) every second" ticked it adds 2 lines a second, about 7,200 an hour. When the PC is off, each request also writes a "Request error: connect ECONNREFUSED …" error line. Useful messages get pushed out of Companion's log view.

**Why it happens:** The request helper logs every URL at info level, the list refresh logs the counts at info level every time, and request errors are logged on every poll instead of once when the connection state changes.

**Evidence:**

```ts
// src/main.ts:174
          this.log('info', `Playlists: ${this.playlists.length}`)
// src/main.ts:183
          this.log('info', `Overlays: ${this.overlays.length}`)
// src/main.ts:191-193
  public async makeRequest(path: string): Promise<string | void> {
    const url = `http://${this.config.host}:${this.config.port}${path}`
    this.log('info', `→ ${url}`)
// src/main.ts:209-211
      req.on('error', (err) => {
        this.log('error', `Request error: ${err.message}`)
        resolve()
```

**Confirm by:** read [`src/main.ts:191-211`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L191-L211): every call to `makeRequest` logs the URL at `info`, and every failed call logs an `error`, with no check of the previous state.

**Fix:** log the request URL at `debug`, log the playlist and overlay counts only when they change, and log a connection error once when the connection goes from working to failing, together with the status change in [H2](#h2-connection-status-is-always-green-ok-even-when-the-ldsperimetral-pc-is-off-or-the-ip-is-wrong).

### H12: Move to @companion-module/base 1.14, the template's version

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json:9`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json#L9)

**What goes wrong:** The module doesn't match the API 1.x template it is built from. It targets API 1.11 (Companion 3.5 and later), while the template is on `~1.14.1`, which adds option descriptions, `isVisibleExpression`, value feedbacks, secret-text fields and the Node permission model. This first release would ship on an API version the template has already moved past.

**Why it happens:** The dependency is `~1.11.0`.

**Evidence:**

```json
// package.json:8-10
  "dependencies": {
    "@companion-module/base": "~1.11.0"
  },
```

```json
// companion-module-template-ts-v1/package.json:26
    "@companion-module/base": "~1.14.1"
```

**Confirm by:** compare [`package.json:9`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/package.json#L9) with the API 1.x TypeScript template's `dependencies`.

**Fix:** change to `"@companion-module/base": "~1.14.1"` in this release and re-test. The module only uses `node:http`, so it needs no `runtime.permissions`. Later, consider moving to API 2.x.

## 🟡 Medium

### M1: No GitHub workflows, so pushes and pull requests are never checked

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/companion-module-checks.yaml`, `.github/workflows/node.yaml` (both missing)

**What goes wrong:** Nothing runs the Companion module checks, lint or build when code is pushed or a pull request is opened, so problems like the TypeScript errors in [H3](#h3-the-source-doesnt-compile-yarn-build-stops-with-9-typescript-errors) are only found at review.

**Why it happens:** The module has no `.github` directory. The template tracks both workflows.

**Fix:** copy `.github/workflows/companion-module-checks.yaml` and `.github/workflows/node.yaml` from the template.

## 🟢 Low

### L1: Action and preset lists are re-sent to Companion on every refresh, even when nothing changed

- **Source:** 🔎 protocol reviewer + QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:106-111`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L106-L111)

**What goes wrong:** On every "Refresh interval" (60 s by default, and the field allows 1 s), the module sends all action and preset definitions to Companion again, even when the playlists and overlays are the same. A user who sets the refresh to 1 s for faster variable updates also makes the module resend every definition every second, which is needless work for Companion and its web UI ([A2](#-assumptions-to-confirm)).

**Why it happens:** The polling interval calls `setActionDefinitions` and `setPresetDefinitions` after every list refresh without checking whether the lists changed.

**Fix:** in `refreshLists()`, compare the new playlist and overlay lists with the previous ones (for example their names and sequence counts) and re-send the definitions only when they changed.

### L2: Commands that LDSperimetral rejects fail silently

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:36-145`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/actions.ts#L36-L145)

**What goes wrong:** An operator presses a "Start Playlist: Intro" button after the "Intro" playlist was renamed on the LDSperimetral PC, or "Start Sequence in Playlist" with index 12 in a playlist of 5 sequences. When LDSperimetral answers with an error (`status` not 0, with a message), nothing happens and nothing explains why; the log shows only the outgoing request line.

**Why it happens:** Apart from Ping, every action ignores the reply. The module checks `status === 0` when polling, but never for commands.

**Fix:** add a small `sendCommand(path)` helper that reads the reply and, when `status` isn't 0, logs a warning with the action name and the device's `message`. Use it in every action callback.

### L3: Playlists or overlays whose names differ only in punctuation share one preset

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/presets.ts:170-213`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/presets.ts#L170-L213)

**What goes wrong:** If LDSperimetral has playlists named "Match 1" and "Match_1", or "Half-time!" and "Half-time?", only one "Start Playlist" preset appears in the Playlists category, so the operator can't drag in a preset for the other. Overlays have the same problem.

**Why it happens:** The preset ID replaces every character outside letters, digits, `_` and `-` with `_` (`pl_…`, `ov_…`), so different names can give the same ID, and the later preset overwrites the earlier one.

**Fix:** make the IDs unique, for example with the list index (`pl_${index}`) or a numeric suffix when the ID is already taken.

### L4: Actions and presets appear only after the device answers or times out at startup

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:67-74`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L67-L74)

**What goes wrong:** When Companion starts, or the connection is enabled, while LDSperimetral is slow or doesn't answer, the connection has no actions in the action picker and no presets until four requests have each finished or hit their 3-second timeout, up to about 12 seconds.

**Why it happens:** `init()` registers the action and preset definitions only after waiting for the first list refresh and state poll, one request at a time.

**Fix:** register the actions and presets first with the lists known so far (empty at startup), then run the first refresh without holding up `init()`. The refresh already re-registers the definitions when the lists arrive.

## 💡 Nice to Have

### N1: The per-second time update also asks for the instance name every second

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:113-117`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/main.ts#L113-L117)

**What goes wrong:** With "Update time variables every second" ticked, the module also requests the instance name every second, although it practically never changes.

**Why it happens:** The one-second timer calls `pollState()`, which reads both the playback state and the instance name.

**Fix:** call `this.pollReproductionState()` in the one-second timer, and read the instance name only on the main refresh interval.

### N2: The IP Address setting accepts any text, including a URL or a port

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:12-18`](https://github.com/bitfocus/companion-module-largedisplaysolutions-ldsperimetral/blob/78ee009a484d2d93b151f0540d924286d6047e0e/src/config.ts#L12-L18)

**What goes wrong:** A user who types `http://10.0.0.5` or `10.0.0.5:8082` into "IP Address of LDSperimetral PC" gets no warning. Every request then goes to a broken URL such as `http://http://10.0.0.5:8082/…`, and only log errors appear.

**Why it happens:** The host field has no `regex`, while the template's host field uses `Regex.IP`.

**Fix:** add `regex: Regex.HOSTNAME` (accepts IP addresses and host names) or `Regex.IP` to the host field, importing `Regex` from `@companion-module/base`.

## 📝 Additional Notes

- This is the module's first release (never published), so the whole module was reviewed at v0.9.1; there is no earlier tag to diff against.
- `tsconfig.json` differs from the template: it has its own `compilerOptions` (target ES2022, module and moduleResolution NodeNext, outDir `./dist`, rootDir `./src`, strict) instead of extending `tsconfig.build.json`. Fine as long as the module builds; once `tsconfig.build.json` is added ([C3](#c3-the-templates-formatting-lint-yarn-and-build-config-files-are-missing)), extending it like the template is simpler.

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion doesn't re-run a module's boolean feedbacks on its own (on a timer or after `setVariableValues`). It checks each feedback once when it is subscribed (right after `init()`, or when the button is edited) and again only on `checkFeedbacks`, or when a variable read through `context.parseVariablesInString` changes | `@companion-module/base` 1.11.3: `getVariableValue` is a plain map read, and `handleVariablesChanged` only re-checks feedbacks with `referencedVariables`, which come only from `context.parseVariablesInString`. Companion's host code not checked | [H1](#h1-is-playing-and-is-paused-feedbacks-never-change-colour-after-the-button-is-first-drawn) |
| A2 | Every `setActionDefinitions` / `setPresetDefinitions` call makes Companion store the definitions again and push them to connected web UIs, even when nothing changed | the base package sends the full list over IPC on every call; what Companion does with it is host behaviour, not checked | [L1](#l1-action-and-preset-lists-are-re-sent-to-companion-on-every-refresh-even-when-nothing-changed) |
| A3 | The Bitfocus release build runs the module's `build` (through `yarn package`, `run build && companion-module-build` once the template scripts are added) and stops when `tsc` exits non-zero | the template's scripts and normal yarn behaviour; the `tsc` exit code 2 was reproduced locally, the Bitfocus pipeline itself not checked | [H3](#h3-the-source-doesnt-compile-yarn-build-stops-with-9-typescript-errors) |
