# Review: sennheiser-ewdx v1.1.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-sennheiser-ewdx` |
| **Scope** | `tag` (v1.0.7..v1.1.1) |
| **Version** | v1.1.1 |
| **Release** | Update — last published v1.0.7 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`ce92ccb`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/tree/ce92ccbdc18ec47717f48565841ff7597cafc780) |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion 5 can read a property of an object-valued local variable (`$(local:status).name`) when that variable comes from a value feedback (`variableType: 'feedback'`), and uses the result as text, a colour number, a boolean (`enabled`) or an image string. The new layered "Channel Status" and "Bay Status" presets only work if this holds | base 2.1.3 typings (`CompanionFeedbackLocalVariable`, `CompanionGraphicsElementValue<T>`, a value feedback returning `JsonValue`); Companion's expression engine was not checked | none (no finding raised) |
| A2 | The image element's `base64Image` accepts a `data:image/png;base64,...` URI, and `fontsize` is a percentage of the element height, as the new `src/receiverDisplay.ts` and `src/chargerDisplay.ts` assume | the typings declare only `CompanionGraphicsElementValue<string \| null>` and `<number>`, with no format or unit documented | none (no finding raised) |

## 📋 Issues

### Blocking

- [ ] [C1: The module still targets Node 22, but the API 2.1 template runs on Node 26](#c1-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26)
- [ ] [C2: package.json does not declare the Node and Yarn versions it needs](#c2-packagejson-does-not-declare-the-node-and-yarn-versions-it-needs)
- [ ] [C3: Line endings are not pinned because .gitattributes is missing](#c3-line-endings-are-not-pinned-because-gitattributes-is-missing)
- [ ] [C4: Packaged builds and editor settings are not ignored by git](#c4-packaged-builds-and-editor-settings-are-not-ignored-by-git)
- [ ] [C5: An old packaged build (sennheiser-ewdx-1.0.7.tgz) is committed to the repo](#c5-an-old-packaged-build-sennheiser-ewdx-107tgz-is-committed-to-the-repo)
- [ ] [H1: The CI workflow keeps the GitHub token and uses a different setup-node version than the template](#h1-the-ci-workflow-keeps-the-github-token-and-uses-a-different-setup-node-version-than-the-template)

### Non-blocking

- [ ] [M1: Published GitHub releases don't get the packaged module attached](#m1-published-github-releases-dont-get-the-packaged-module-attached)
- [ ] [L1: Misspelled option ids in actions and feedbacks are not caught at build time](#l1-misspelled-option-ids-in-actions-and-feedbacks-are-not-caught-at-build-time)
- [ ] [N1: The old RX Status Display feedback isn't marked as legacy, unlike the charger one](#n1-the-old-rx-status-display-feedback-isnt-marked-as-legacy-unlike-the-charger-one)

## 🔴 Critical

### C1: The module still targets Node 22, but the API 2.1 template runs on Node 26

- **Source:** 🤖 validate-template (NODE-VERSION)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/companion/manifest.json#L18), [`package.json:28`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/package.json#L28), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/tsconfig.build.json#L2), [`.github/workflows/node.yaml:19-63`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.github/workflows/node.yaml#L19-L63)

**What goes wrong:** Companion starts the module on Node 22, but API 2.1 modules are expected to match the API 2.1 template, which uses Node 26 in every place the Node version is named. The other places listed below still name another Node version too, so the module would run, type-check and build in CI on different Node versions even after the runtime is fixed. A module that does not match its template makes later troubleshooting harder: when something misbehaves, people look for the cause in the module instead of in the mismatched setup.

**Why it happens:** Moving a module to another Node version means changing every place the version is named: the manifest runtime, `engines.node`, `@types/node`, the TypeScript preset and the CI workflows. These places still name a different Node version than the API 2.1 template.

**Evidence:**

```text
companion/manifest.json runtime.type 'node22' -> 'node26'
package.json devDependencies @types/node '^22.15.19' -> '^26.6.4'
tsconfig.build.json extends "@companion-module/tools/tsconfig/node22/recommended-esm.json" -> "@companion-module/tools/tsconfig/node26/recommended.json"
.github/workflows/node.yaml line 19 step name 'Use Node.js 22.x' -> 'Use Node.js 26.x'
.github/workflows/node.yaml line 23 node-version 22.x -> 26.x
.github/workflows/node.yaml line 60 step name 'Use Node.js 22.x' -> 'Use Node.js 26.x' (commented out)
.github/workflows/node.yaml line 63 node-version 22.x -> 26.x (commented out)
```

**Confirm by:** open each file above and compare it with the template's copy.

**Fix:** update every place to Node 26, as the template does:

- [ ] [`companion/manifest.json:18`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/companion/manifest.json#L18): `"type": "node26"` in `runtime`
- [ ] [`package.json:28`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/package.json#L28): `"@types/node": "^26.6.4"` in `devDependencies`
- [ ] [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/tsconfig.build.json#L2): `"extends": "@companion-module/tools/tsconfig/node26/recommended.json"`
- [ ] [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.github/workflows/node.yaml): `- name: Use Node.js 26.x` (line 19), `node-version: 26.x` (line 23), `- name: Use Node.js 26.x` (line 60, commented out), `node-version: 26.x` (line 63, commented out)

### C2: package.json does not declare the Node and Yarn versions it needs

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/package.json)

**What goes wrong:** A developer can install and build the module with any Node version without a warning, so a build made on the wrong Node version is not caught.

**Why it happens:** The API 2.1 template's `package.json` has an `engines` field that pins Node 26 and Yarn 4. This module's `package.json` has no `engines` field.

**Evidence:**

```text
Template expects: "engines": { "node": "^26", "yarn": "^4" }
Found:            no "engines" field
```

**Confirm by:** open [`package.json`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/package.json) and search for `engines`.

**Fix:** add the template's `engines` field.

```json
"engines": {
	"node": "^26",
	"yarn": "^4"
},
```

### C3: Line endings are not pinned because .gitattributes is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** A contributor on Windows can commit files with CRLF line endings, which produces noisy diffs and can fail the Prettier/lint check in CI.

**Why it happens:** The template ships a `.gitattributes` file that makes git store every text file with LF endings. This module doesn't have one.

**Evidence:**

```text
Template file: .gitattributes  ->  * text=auto eol=lf
Module:        file not present
```

**Confirm by:** the repo root at [`ce92ccb`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/tree/ce92ccbdc18ec47717f48565841ff7597cafc780) has no `.gitattributes`.

**Fix:** add `.gitattributes` with the template's content.

```text
* text=auto eol=lf
```

### C4: Packaged builds and editor settings are not ignored by git

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.gitignore)

**What goes wrong:** Running `yarn package` creates a `sennheiser-ewdx-<version>.tgz` in the repo root, and nothing stops it from being committed. That is how [C5](#c5-an-old-packaged-build-sennheiser-ewdx-107tgz-is-committed-to-the-repo) happened. VS Code settings in `.vscode/` can be committed the same way.

**Why it happens:** The template's `.gitignore` has `/*.tgz` and `/.vscode`. This module's `.gitignore` has neither.

**Evidence:**

```text
Missing template .gitignore entries: /*.tgz, /.vscode
```

**Confirm by:** open [`.gitignore`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.gitignore).

**Fix:** add the two missing entries (or copy the template's `.gitignore`).

```text
/*.tgz
/.vscode
```

### C5: An old packaged build (sennheiser-ewdx-1.0.7.tgz) is committed to the repo

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW
- **File:** [`sennheiser-ewdx-1.0.7.tgz`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/sennheiser-ewdx-1.0.7.tgz)

**What goes wrong:** A 92 KB packaged build of the previous version was added to the repo in this release. Anyone browsing the repo may mistake it for the current module, and every clone carries the extra binary.

**Why it happens:** `yarn package` writes the `.tgz` into the repo root, and the `.gitignore` doesn't exclude it (see [C4](#c4-packaged-builds-and-editor-settings-are-not-ignored-by-git)), so it was committed with the other changes.

**Evidence:**

```text
v1.0.7..v1.1.1 diffstat: sennheiser-ewdx-1.0.7.tgz | Bin 0 -> 91738 bytes
Template .gitignore excludes it with '/*.tgz'
```

**Confirm by:** `git ls-files '*.tgz'` at the review commit lists `sennheiser-ewdx-1.0.7.tgz`.

**Fix:** remove the file from git (it can stay on disk), then add `/*.tgz` to `.gitignore`.

```bash
git rm --cached sennheiser-ewdx-1.0.7.tgz
```

## 🟠 High

### H1: The CI workflow keeps the GitHub token and uses a different setup-node version than the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18-21`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.github/workflows/node.yaml#L18-L21), [`.github/workflows/node.yaml:60-76`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.github/workflows/node.yaml#L60-L76)

**What goes wrong:** The checkout step keeps the GitHub token in the CI workspace, which the API 2.1 template turns off, and the workflow no longer matches what other modules run, which makes later troubleshooting harder. (Its Node 22 settings are listed in [C1](#c1-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26).)

**Why it happens:** Apart from the Node version, the workflow differs from the API 2.1 template's `node.yaml`:

- `actions/checkout` is missing the template's `with: persist-credentials: false`.
- The Node step uses `actions/setup-node@v7`, where the template has `actions/setup-node@v6`.
- The commented-out test job has the same `setup-node@v7` drift, plus an extra `codecov/codecov-action@v5` step.

**Evidence:**

```yaml
# .github/workflows/node.yaml:18-21
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v7
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml`, or open [`.github/workflows/node.yaml:18-21`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.github/workflows/node.yaml#L18-L21).

**Fix:** replace the file with the template's `node.yaml`, which also covers the workflow items in [C1](#c1-the-module-still-targets-node-22-but-the-api-21-template-runs-on-node-26):

```yaml
      - uses: actions/checkout@v7
        with:
          persist-credentials: false
      - name: Use Node.js 26.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
        with:
          node-version: 26.x
```

## 🟡 Medium

### M1: Published GitHub releases don't get the packaged module attached

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** When the maintainer publishes a GitHub release, no workflow packages the module and attaches the `.tgz` to the release, so users who want to install a release by hand have nothing to download.

**Why it happens:** The template ships `.github/workflows/release.yaml`, which runs Bitfocus's shared module checks on the release tag and attaches the built package to the release. This module doesn't have that file.

**Fix:** copy `.github/workflows/release.yaml` from the template unchanged.

## 🟢 Low

### L1: Misspelled option ids in actions and feedbacks are not caught at build time

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:11`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/src/main.ts#L11), [`src/actions.ts:15-17`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/src/actions.ts#L15-L17), [`src/actions.ts:28`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/src/actions.ts#L28), [`src/feedbacks.ts:22`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/src/feedbacks.ts#L22)

**What goes wrong:** Users see no difference today. But if an option id is misspelled in an action, a feedback, or a preset (for example `options: { receiver }` in the new layered presets), the build still passes and the mistake only shows up when a button misbehaves.

**Why it happens:** In API 2.x, a module can describe the options of each action and feedback in its module types, and the compiler then checks every `action.options.*` / `feedback.options.*` use against that description. This module defines `ModuleTypes` only with its config and uses the untyped `CompanionActionDefinitions` / `CompanionFeedbackDefinitions`, so every option value arrives untyped. The new `optionString()` helper and the `Number(...)` / `case Number(MuteOptions.off)` conversions in `feedbacks.ts` work around that.

**Fix:** declare an actions schema and a feedbacks schema and put them in `ModuleTypes`; the `optionString()` and `Number()` conversions can then go. See the companion-v2-actions and companion-v2-feedbacks skills.

```ts
type ActionsSchema = {
	name: { options: { name: string } }
	rx_mute: { options: { receiver: number; mute: 'mute' | 'unmute' | 'toggle' } }
	// ...
}
export type ModuleTypes = {
	config: ModuleConfig
	secrets: undefined
	actions: ActionsSchema
	feedbacks: FeedbacksSchema
	variables: VariablesSchema
}
const actions: CompanionActionDefinitions<ActionsSchema> = {}
```

## 💡 Nice to Have

### N1: The old RX Status Display feedback isn't marked as legacy, unlike the charger one

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:331-334`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/src/feedbacks.ts#L331-L334)

**What goes wrong:** A user with an EM2 or EM4 who opens a button's Feedbacks list sees "RX: Status Display" described as "Displays detailed information about the selected receiver channel", with nothing saying it is the old image-buffer display. They may add it to new buttons instead of using the new "Channel Status RX1" preset. The charger's "Charging Bay: Status Display" is now described as "Legacy image-buffer display. Apply the Bay Status preset…", so the two device types are worded differently. Nothing stops working; this only affects which option users pick.

**Why it happens:** This release changed the charger feedback's description ([`src/feedbacks.ts:687`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/src/feedbacks.ts#L687)) to point users at the new layered preset, but didn't change the matching receiver feedback.

**Fix:** use the same wording for the receiver feedback.

```ts
description: 'Legacy image-buffer display. Apply the Channel Status preset for native graphics without deprecated image buffers.',
```
