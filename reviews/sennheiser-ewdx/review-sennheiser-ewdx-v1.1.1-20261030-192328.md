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

- [ ] [C1: Module is built for Node 22 while API 2.1 modules run on Node 26](#c1-module-is-built-for-node-22-while-api-21-modules-run-on-node-26)
- [ ] [C2: package.json does not declare the Node and Yarn versions it needs](#c2-packagejson-does-not-declare-the-node-and-yarn-versions-it-needs)
- [ ] [C3: Line endings are not pinned because .gitattributes is missing](#c3-line-endings-are-not-pinned-because-gitattributes-is-missing)
- [ ] [C4: Packaged builds and editor settings are not ignored by git](#c4-packaged-builds-and-editor-settings-are-not-ignored-by-git)
- [ ] [C5: An old packaged build (sennheiser-ewdx-1.0.7.tgz) is committed to the repo](#c5-an-old-packaged-build-sennheiser-ewdx-107tgz-is-committed-to-the-repo)
- [ ] [H1: CI builds the module on Node 22 instead of Node 26](#h1-ci-builds-the-module-on-node-22-instead-of-node-26)

### Non-blocking

- [ ] [M1: Published GitHub releases don't get the packaged module attached](#m1-published-github-releases-dont-get-the-packaged-module-attached)
- [ ] [L1: Misspelled option ids in actions and feedbacks are not caught at build time](#l1-misspelled-option-ids-in-actions-and-feedbacks-are-not-caught-at-build-time)
- [ ] [N1: The old RX Status Display feedback isn't marked as legacy, unlike the charger one](#n1-the-old-rx-status-display-feedback-isnt-marked-as-legacy-unlike-the-charger-one)

## 🔴 Critical

### C1: Module is built for Node 22 while API 2.1 modules run on Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:17-18`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/companion/manifest.json#L17-L18), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/tsconfig.build.json#L2)

**What goes wrong:** This release moves the module to API 2.1 (Companion 5.0+), but it still tells Companion to run it on Node 22 and still compiles it for Node 22. Every API 2.1 module built from the template runs on Node 26, so this module runs on a different runtime from the rest, which makes later problems harder to troubleshoot.

**Why it happens:** The release raised `@companion-module/base` from ^1.11.3 to 2.1.3 and added `"type": "connection"` to the manifest, but kept the Node 22 runtime from the API 1 version. The build config (`tsconfig.build.json`) also still extends the Node 22 preset.

**Evidence:**

```text
Template expects: "runtime": { "type": "node26", ... }
Found:            "runtime": { "type": "node22", ... }   (companion/manifest.json:18)

tsconfig.build.json:2  extends "@companion-module/tools/tsconfig/node22/recommended-esm.json"
template:              extends "@companion-module/tools/tsconfig/node26/recommended.json"
```

Related: `@types/node` is `^22.15.19` in `package.json`, and CI uses Node 22 (see [H1](#h1-ci-builds-the-module-on-node-22-instead-of-node-26)).

**Confirm by:** open [`companion/manifest.json:17-18`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/companion/manifest.json#L17-L18) and [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/tsconfig.build.json#L2).

**Fix:** switch the runtime and the build config to Node 26, as the template does.

```json
// companion/manifest.json
"runtime": {
	"type": "node26",
```

```json
// tsconfig.build.json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

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

### H1: CI builds the module on Node 22 instead of Node 26

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.github/workflows/node.yaml#L18-L23)

**What goes wrong:** The GitHub CI check builds and lints the module on Node 22, so it doesn't test the module on the Node 26 runtime that API 2.1 modules use. The checkout step also keeps the GitHub token in the workspace, which the template turns off.

**Why it happens:** The workflow differs from the API 2.1 template's `node.yaml`:

- `actions/checkout` is missing the template's `with: persist-credentials: false`.
- The Node step is `Use Node.js 22.x` / `actions/setup-node@v7` / `node-version: 22.x`, where the template has `Use Node.js 26.x` / `actions/setup-node@v6` / `node-version: 26.x`.
- The commented-out test job has the same Node 22 / v7 drift, plus an extra `codecov/codecov-action@v5` step.

**Evidence:**

```yaml
# .github/workflows/node.yaml:18-23
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v7
        with:
          node-version: 22.x
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml`, or open [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-sennheiser-ewdx/blob/ce92ccbdc18ec47717f48565841ff7597cafc780/.github/workflows/node.yaml#L18-L23).

**Fix:** replace the file with the template's `node.yaml`.

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
