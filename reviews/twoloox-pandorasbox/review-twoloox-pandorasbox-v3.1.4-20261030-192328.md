# Review: companion-module-twoloox-pandorasbox v3.1.4

| | |
| --- | --- |
| **Module** | companion-module-twoloox-pandorasbox |
| **Scope** | `tag` (`v3.0.1..v3.1.4`) |
| **Version** | v3.1.4 |
| **Release** | Update — last published v3.0.1 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`d853961`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/tree/d8539614ca870edec1e137ef2bb4352b13955d0c) |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When a saved feedback has no value for an option that a newer module version added (`sequence`), Companion 5 passes it to the callback as `undefined` (or fails option validation and skips the feedback). It does not fill in the option's default (1). | The module's own CHANGELOG ("Existing uses of this feedback will need the new 'Sequence' option set") and the v2.0 compliance reference on missing/bare option values. Companion's handling of a completely missing option key was not checked in the host source. | [L1](#l1-existing-remaining-cue-under-threshold-buttons-stop-lighting-after-the-update-until-a-sequence-is-picked) |
| A2 | Companion's per-variable change detection makes repeated identical `setVariableValues` calls cheap: the cost is IPC traffic only, not button re-renders. | General knowledge of the Companion host; not checked in its source. | [N1](#n1-timecode-variables-are-re-sent-to-companion-on-every-poll-even-when-nothing-changed) |

## 📋 Issues

### Blocking

- [ ] [C1: Module targets Node 22 instead of the Node 26 runtime of the API 2.1 template](#c1-module-targets-node-22-instead-of-the-node-26-runtime-of-the-api-21-template)
- [ ] [C2: The standard package build fails](#c2-the-standard-package-build-fails)
- [ ] [C3: package.json has no package script](#c3-packagejson-has-no-package-script)
- [ ] [C4: package.json has no postinstall script](#c4-packagejson-has-no-postinstall-script)
- [ ] [C5: package.json has no format script](#c5-packagejson-has-no-format-script)
- [ ] [C6: LICENSE file is missing (shipped as LICENSE.txt)](#c6-license-file-is-missing-shipped-as-licensetxt)
- [ ] [C7: .gitignore is missing the template's anchored entries](#c7-gitignore-is-missing-the-templates-anchored-entries)
- [ ] [C8: .husky/pre-commit is missing](#c8-huskypre-commit-is-missing)
- [ ] [C9: .prettierignore is missing](#c9-prettierignore-is-missing)

### Non-blocking

- [ ] [M1: GitHub workflow node.yaml is missing](#m1-github-workflow-nodeyaml-is-missing)
- [ ] [M2: GitHub workflow release.yaml is missing](#m2-github-workflow-releaseyaml-is-missing)
- [ ] [L1: Existing Remaining cue under threshold buttons stop lighting after the update until a Sequence is picked](#l1-existing-remaining-cue-under-threshold-buttons-stop-lighting-after-the-update-until-a-sequence-is-picked)
- [ ] [L2: Expression mode on Transport and other dropdowns expects internal numeric codes](#l2-expression-mode-on-transport-and-other-dropdowns-expects-internal-numeric-codes)
- [ ] [N1: Timecode variables are re-sent to Companion on every poll even when nothing changed](#n1-timecode-variables-are-re-sent-to-companion-on-every-poll-even-when-nothing-changed)
- [ ] [N2: Loosely typed ModuleSchema forces option casts in callbacks](#n2-loosely-typed-moduleschema-forces-option-casts-in-callbacks)
- [ ] [N3: Source manifest still says 3.1.3-beta.1 with isPrerelease true](#n3-source-manifest-still-says-313-beta1-with-isprerelease-true)

## 🔴 Critical

### C1: Module targets Node 22 instead of the Node 26 runtime of the API 2.1 template

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:20`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/companion/manifest.json#L20), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/tsconfig.build.json#L2), [`package.json:26`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/package.json#L26), [`package.json:33`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/package.json#L33)

**What goes wrong:** This release moves the module to API 2.1 (Companion 5.0+), but it still declares the Node 22 runtime and compiles against the Node 22 TypeScript preset. Modules on API 2.1 must match the template's Node 26 setup, so the module runs and builds differently from every other 2.1 module, which makes later troubleshooting harder.

**Why it happens:** The runtime and the TypeScript preset were not updated when the base package moved to 2.1.

**Evidence:**

```text
companion/manifest.json  found: "type": "node22"   expected: "type": "node26"
tsconfig.build.json      found: "extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json"
                         expected: "extends": "@companion-module/tools/tsconfig/node26/recommended.json"
package.json             found: "engines": { "node": ">=22.0.0" }, "@types/node": "^22.15.21"
                         template: "engines": { "node": "^26" }
```

**Fix:** switch the manifest runtime to Node 26 and extend the Node 26 TypeScript preset, as the template does; update `engines.node` and `@types/node` to match.

```json
// companion/manifest.json
"type": "node26",
// tsconfig.build.json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
// package.json
"engines": { "node": "^26" }
```

### C2: The standard package build fails

- **Source:** 🤖 validate-template (BUILD-PACKAGE)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/package.json#L6-L14)

**What goes wrong:** `yarn package`, the command used to build the installable module package, fails. A plain `yarn build` (TypeScript only) succeeds, so the code itself compiles.

**Why it happens:** package.json has no `package` script (see [C3](#c3-packagejson-has-no-package-script)).

**Evidence:**

```text
yarn install  OK
yarn package  FAILED (no "package" script)
```

**Fix:** add the template's `package` script (C3); the build then passes.

### C3: package.json has no package script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/package.json#L6-L14)

**What goes wrong:** The module packages with a `dist` script instead of the template's `package` script, so the standard build command fails ([C2](#c2-the-standard-package-build-fails)). The `dist` script also skips the TypeScript build step, so it can package a stale `dist/`.

**Why it happens:** The script was named `dist` and runs only `companion-module-build`.

**Evidence:**

```text
found:    "dist": "yarn companion-module-build"
expected: "package": "run build && companion-module-build"
```

**Fix:** replace the `dist` script with the template's `package` script.

```json
"package": "run build && companion-module-build",
```

### C4: package.json has no postinstall script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/package.json#L6-L14)

**What goes wrong:** The template installs the git hooks from `postinstall`; this module uses `prepare` instead, so it differs from the template's setup.

**Why it happens:** The script is named `prepare` (`"prepare": "husky"`).

**Evidence:**

```text
found:    "prepare": "husky"
expected: "postinstall": "husky"
```

**Fix:** rename the `prepare` script to `postinstall`.

```json
"postinstall": "husky",
```

### C5: package.json has no format script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:6-14`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/package.json#L6-L14)

**What goes wrong:** There is no `yarn format` command to apply the shared Prettier style across the repo.

**Why it happens:** The template's `format` script was not added.

**Evidence:**

```text
expected: "format": "prettier -w ."
found:    (missing)
```

**Fix:** add the template's script.

```json
"format": "prettier -w .",
```

### C6: LICENSE file is missing (shipped as LICENSE.txt)

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `LICENSE`

**What goes wrong:** The template's `LICENSE` file is missing. The module ships the same MIT text as `LICENSE.txt`.

**Why it happens:** The file uses a `.txt` extension instead of the template's file name.

**Evidence:**

```text
expected: LICENSE
found:    LICENSE.txt (MIT)
```

**Fix:** rename `LICENSE.txt` to `LICENSE`.

### C7: .gitignore is missing the template's anchored entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/.gitignore)

**What goes wrong:** The build output entries don't match the template. The unanchored forms also ignore any folder named `dist`, `pkg` or `.vscode` anywhere in the tree, not only at the repo root.

**Why it happens:** The module lists `pkg/`, `*.tgz`, `dist/` and `.vscode/` instead of the template's root-anchored forms.

**Evidence:**

```text
missing template entries: /pkg, /*.tgz, /dist, /.vscode
found instead:            pkg/, *.tgz, dist/, .vscode/
```

**Fix:** replace those four lines with the template's entries.

```text
/pkg
/*.tgz
/dist
/.vscode
```

### C8: .husky/pre-commit is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit`

**What goes wrong:** The module installs husky and configures `lint-staged`, but there is no pre-commit hook, so staged files are never checked before a commit.

**Why it happens:** The template's `.husky/pre-commit` file was not copied.

**Evidence:**

```text
expected: .husky/pre-commit (tracked by the template)
found:    (missing)
```

**Fix:** add `.husky/pre-commit` with the template's content.

```bash
lint-staged
```

### C9: .prettierignore is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore`

**What goes wrong:** Prettier formats `package.json` and `LICENSE.md`, which the template excludes.

**Why it happens:** The template's `.prettierignore` file was not copied.

**Evidence:**

```text
expected: .prettierignore (tracked by the template)
found:    (missing)
```

**Fix:** add `.prettierignore` with the template's content.

```text
package.json
/LICENSE.md
```

## 🟡 Medium

### M1: GitHub workflow node.yaml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml`

**What goes wrong:** Pushes and pull requests are not linted and built by CI, so a broken build is only found at release time.

**Why it happens:** The template's `.github/workflows/node.yaml` was not copied.

**Fix:** copy `.github/workflows/node.yaml` from the template.

### M2: GitHub workflow release.yaml is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml`

**What goes wrong:** Tagging a release does not run the template's release workflow.

**Why it happens:** The template's `.github/workflows/release.yaml` was not copied.

**Fix:** copy `.github/workflows/release.yaml` from the template.

## 🟢 Low

### L1: Existing Remaining cue under threshold buttons stop lighting after the update until a Sequence is picked

- **Source:** 🔎 QA reviewer, compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedback.ts:29-36`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/src/feedback.ts#L29-L36), [`src/feedback.ts:48-54`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/src/feedback.ts#L48-L54), [`src/upgrades.ts:7-18`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/src/upgrades.ts#L7-L18)

**What goes wrong:** A user on v3.0.1 has a button with the "Remaining cue under threshold" feedback, for example "Threshold seconds" = 10. After upgrading to v3.1.4 that feedback has no value for the new "Sequence" option, so the button no longer changes colour as a cue approaches. It stays off until the user opens each such feedback and picks a sequence. The CHANGELOG mentions this, but the module already converts the removed "Transport state matches" feedback to sequence 1 automatically, and this feedback could be converted the same way. Buttons created on v3.1.4 are not affected.

**Why it happens:** v3.0.1's feedback had only a threshold. This release adds a "Sequence" dropdown, and the feedback reads it as a number; a missing value becomes `NaN`, no countdown is found, and the feedback returns false. The only upgrade script handles "Transport state matches" and leaves saved "Remaining cue under threshold" feedbacks without a sequence.

**Evidence:**

```ts
// src/feedback.ts:48-51
callback: (fb: CompanionFeedbackBooleanEvent) => {
	const seqId = Number(fb.options.sequence)
	const countdown = getSequenceCountdown(seqId)
	if (!countdown) return false
// src/upgrades.ts:18
export const UpgradeScripts: CompanionStaticUpgradeScript<DeviceConfig>[] = [convertTransportStateFeedback]
```

**Fix:** append a second upgrade script (don't edit the existing one: v3.1.3 is already tagged and Companion runs each script only once per connection) that sets sequence 1 on every saved "Remaining cue under threshold" feedback without a sequence, the same way `convertTransportStateFeedback` does.

```ts
const addSequenceToRemainingThreshold: CompanionStaticUpgradeScript<DeviceConfig> = (_context, props) => {
	const updatedFeedbacks: CompanionMigrationFeedback[] = []
	for (const feedback of props.feedbacks) {
		if (feedback.feedbackId !== 'remaining_threshold' || feedback.options.sequence !== undefined) continue
		feedback.options.sequence = { isExpression: false, value: 1 }
		updatedFeedbacks.push(feedback)
	}
	return { updatedConfig: null, updatedActions: [], updatedFeedbacks }
}

export const UpgradeScripts: CompanionStaticUpgradeScript<DeviceConfig>[] = [
	convertTransportStateFeedback,
	addSequenceToRemainingThreshold,
]
```

### L2: Expression mode on Transport and other dropdowns expects internal numeric codes

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:133-141`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/src/actions.ts#L133-L141)

**What goes wrong:** With the move to API 2, every action option can be switched to expression mode. A user who switches "Sequence Transport" > "Transport" to an expression has to know that Pause is `3` and Stop is `2`; typing `2` expecting Pause stops the sequence instead. The same applies to "Direction" (1/0), "Ignore" (1/0) and "SMPTE Mode" (0/1/2). Users who never use expressions on these fields are not affected.

**Why it happens:** The dropdown choice ids are the device's wire codes (`{ id: 1, label: 'Play' }, { id: 3, label: 'Pause' }, { id: 2, label: 'Stop' }`), and in expression mode the user types the id, not the label. The API 2.0 guidance recommends friendly string ids.

**Fix:** either switch to friendly string ids (`'play' | 'pause' | 'stop'`, `'next' | 'last'`, …) and map them to wire codes in the callback, with an appended upgrade script that rewrites saved values; or set `disableAutoExpression: true` on fixed-choice fields (Transport, Direction, Ignore, SMPTE Mode, Fade Curve, Mode), or add an `expressionDescription` that lists the codes.

## 💡 Nice to Have

### N1: Timecode variables are re-sent to Companion on every poll even when nothing changed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:192-198`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/src/index.ts#L192-L198)

**What goes wrong:** No visible effect for the user. Each sequence's time is polled 5 times a second while stopped or paused (30 while playing), and every reply sends 10 variable values to Companion even when they are identical, for example a stopped sequence sitting at 00:01:23:04. With 40 stopped sequences that is about 200 redundant updates per second.

**Why it happens:** The time handler always stores and sends the new values. The status, cue-info and opacity handlers already return early when nothing changed; the time handler does not.

**Fix:** compare the new hours/minutes/seconds/frames with the stored time for that sequence and return early when all four are equal.

### N2: Loosely typed ModuleSchema forces option casts in callbacks

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:39-49`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/src/index.ts#L39-L49), [`src/actions.ts:514`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/src/actions.ts#L514)

**What goes wrong:** No user-visible effect. The compiler cannot catch a wrong option id or value type, so a typo in an option id only shows up at runtime, and casts such as `evt.options.curve as FadeCurve` are needed.

**Why it happens:** `ModuleSchema` declares actions and feedbacks as a generic `Record<string, …CompanionOptionValues>` instead of per-action option shapes.

**Fix:** optionally declare per-action and per-feedback option types (e.g. `fade_sequence_visibility: { options: { seq: number; value: number; duration: number; curve: FadeCurve } }`) and type the definitions with them, so the casts can go.

### N3: Source manifest still says 3.1.3-beta.1 with isPrerelease true

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:7-8`](https://github.com/bitfocus/companion-module-twoloox-pandorasbox/blob/d8539614ca870edec1e137ef2bb4352b13955d0c/companion/manifest.json#L7-L8)

**What goes wrong:** No user-visible effect: the build overwrites the version from package.json (3.1.4) and sets the prerelease flag itself, so the shipped package is correct. Anyone reading the repository, though, sees a stable 3.1.4 release whose manifest claims to be a beta pre-release.

**Why it happens:** `"version": "3.1.3-beta.1"` and `"isPrerelease": true` were left over from the beta release.

**Fix:** remove `"isPrerelease": true` and set `"version"` back to the template's placeholder (or 3.1.4).
