# Review: analogway-eks500 v2.0.0

| | |
| --- | --- |
| **Module** | `companion-module-analogway-eks500` ([repo](https://github.com/bitfocus/companion-module-analogway-eks500)) |
| **Version** | v2.0.0 (`acc9213`, 2026-09-29) |
| **Previous tag** | v1.0.2 (2022-02-02) |
| **Scope:** | tag (`v1.0.2..v2.0.0`) |
| **Language** | TypeScript |
| **Template** | `companion-module-template-ts` @ `d62230e` (2026-08-28) |
| **API** | 2.0 (base 2.0.4, yarn.lock) — requires Companion 4.3+ |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Review date** | 2026-10-08 |

This release is a full rewrite: the v1.0.2 single-file JavaScript module becomes a TypeScript module on the Companion 4.3+ module API (2.0). Every finding below is new in this release or a regression caused by it.

## Verdict: ❌ Changes Required

## 📋 Issues

### Blocking

- [ ] [C1: Missing .gitattributes file](#c1-missing-gitattributes-file)
- [ ] [C2: .gitignore is missing template entries](#c2-gitignore-is-missing-template-entries)
- [ ] [C3: Missing .husky/pre-commit hook, so lint-staged never runs](#c3-missing-huskypre-commit-hook-so-lint-staged-never-runs)
- [ ] [C4: .prettierignore differs from the template](#c4-prettierignore-differs-from-the-template)

### Non-blocking

- [ ] [M1: Missing .github issue templates and CI workflows](#m1-missing-github-issue-templates-and-ci-workflows)
- [ ] [M2: Buttons carried over from v1.0.2 keep text values that no longer match their dropdowns](#m2-buttons-carried-over-from-v102-keep-text-values-that-no-longer-match-their-dropdowns)
- [ ] [L1: Refresh all monitored status can run two polls at once](#l1-refresh-all-monitored-status-can-run-two-polls-at-once)
- [ ] [L2: Source variables show frame, logo and audio layers as inputs](#l2-source-variables-show-frame-logo-and-audio-layers-as-inputs)
- [ ] [L3: Changing the connection settings leaves the old device's values on buttons](#l3-changing-the-connection-settings-leaves-the-old-devices-values-on-buttons)

---

## 🔴 Critical

### C1: Missing .gitattributes file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (not in the repo)

**What goes wrong:** No user-visible effect. Without the template's `.gitattributes`, a contributor on Windows can commit files with CRLF line endings, which then fail the module's Prettier formatting check.

**Why it happens:** The template ships a `.gitattributes` that tells git to store every text file with LF line endings. The v2 rewrite didn't add it.

**Evidence:** template `companion-module-template-ts/.gitattributes` contains `* text=auto eol=lf`; the module has no `.gitattributes` at v2.0.0.

**Fix:** copy the file from the template.

```text
* text=auto eol=lf
```

### C2: .gitignore is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-7`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/.gitignore#L1-L7)

**What goes wrong:** No user-visible effect. Files the template keeps out of git (an npm `package-lock.json`, `DEBUG-*` logs, the `.vscode` folder, the whole `.yarn` folder) can be committed by accident.

**Why it happens:** `.gitignore` was rewritten in this release with its own entries instead of the template's. `package-lock.json`, `DEBUG-*` and `/.vscode` aren't covered at all, and `/.yarn` is only partly covered (`.yarn/cache/` and `.yarn/install-state.gz`). The other entries are unanchored versions of the template's (`dist/` instead of `/dist`).

**Evidence:**

```text
Template:  node_modules/  package-lock.json  /pkg  /*.tgz  /dist  DEBUG-*  /.yarn  /.vscode
Module:    node_modules/  dist/  pkg/  *.tgz  .yarn/cache/  .yarn/install-state.gz  .DS_Store
```

**Fix:** replace `.gitignore` with the template's version, and add `.DS_Store` on top if you want to keep it.

### C3: Missing .husky/pre-commit hook, so lint-staged never runs

- **Source:** 🤖 validate-template (FILE-MISSING / HUSKY)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (not in the repo); hook set up in [`package.json:8`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/package.json#L8) and [`package.json:47-54`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/package.json#L47-L54)

**What goes wrong:** No user-visible effect. Code is committed without the automatic format and lint pass the module has set up.

**Why it happens:** `package.json` installs husky (a tool that runs scripts on git commit) through `"postinstall": "husky"` and configures `lint-staged` (which formats and lints the files being committed). The file that connects them, `.husky/pre-commit`, isn't in the repo, so nothing runs on commit.

**Evidence:** template `companion-module-template-ts/.husky/pre-commit` contains `lint-staged`; the module has no `.husky/` files at v2.0.0.

**Fix:** add the hook file from the template.

```text
lint-staged
```

### C4: .prettierignore differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-3`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/.prettierignore#L1-L3)

**What goes wrong:** No user-visible effect. Prettier formats `package.json` and `LICENSE.md`, which the template leaves alone.

**Why it happens:** This file was added in this release with the module's own list instead of the template's.

**Evidence:**

```text
Template:  package.json  /LICENSE.md
Module:    dist  pkg  yarn.lock
```

**Fix:** use the template's `.prettierignore`.

```text
package.json
/LICENSE.md
```

---

## 🟡 Medium

### M1: Missing .github issue templates and CI workflows

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/` (not in the repo)

**What goes wrong:** No user-visible effect. Users reporting problems get no bug or feature form, and pushes and pull requests aren't built or checked automatically.

**Why it happens:** The whole `.github/` folder from the template is missing: `ISSUE_TEMPLATE/bug_report.yml`, `ISSUE_TEMPLATE/config.yml`, `ISSUE_TEMPLATE/feature_request.yml`, `workflows/companion-module-checks.yaml` and `workflows/node.yaml`.

**Fix:** copy the `.github/` folder from `companion-module-template-ts`.

### M2: Buttons carried over from v1.0.2 keep text values that no longer match their dropdowns

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/upgrades.ts:9-30`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/src/upgrades.ts#L9-L30), [`src/actions.ts:68-77`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/src/actions.ts#L68-L77), [`src/actions.ts:243-266`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/src/actions.ts#L243-L266)

**What goes wrong:** A user upgrading from v1.0.2 has buttons using the old actions, now listed as **Background live (legacy)**, **PIP 2 (legacy)**, **PIP 3 (legacy)**, **Background frame (legacy)**, **Logo 1 (legacy)**, **Logo 2 (legacy)** and **Recall user preset to Preview (legacy)**. After installing v2.0.0, the **Input** and **Preset** dropdowns on those buttons hold a value that matches none of their choices, and the **Frame / logo** number fields hold text. The review did not confirm what Companion does when such a button is pressed: if it checks the value against the dropdown's choices, the action won't run; if not, the button still sends the right command, because the command is built as text anyway.

**Why it happens:** v2.0.0 correctly keeps the v1 action ids and option ids, but v1.0.2 stored its dropdown choices as text (`'3'`, `'14'`), while the new dropdowns use numbers (`3`, `14`). The frame and logo options also changed from dropdowns to number fields. The module's only upgrade script (the code Companion runs once on saved buttons and config after an update) migrates the connection config and leaves every action untouched (`updatedActions: []`).

**Fix:** add a second upgrade script that converts these values to numbers. For the legacy action ids, take each `input`, `frame` and `preset` option that is not an expression (`isExpression === false`) and whose `value` is text, write it back as `{ isExpression: false, value: Number(opt.value) }`, and return the action in `updatedActions`. Since v2.0.0 isn't released yet, this could also go into the existing script.

---

## 🟢 Low

### L1: Refresh all monitored status can run two polls at once

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:137-153`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/src/main.ts#L137-L153)

**What goes wrong:** Pressing a **Refresh all monitored status** button while a scheduled poll is running starts a second poll alongside it, doubling the traffic to the device. When the first one finishes, the module thinks no poll is running, so the next scheduled poll can start while the other is still sending.

**Why it happens:** The module uses a "poll running" flag to avoid overlapping polls. A forced poll (from that action, or right after connecting) ignores the flag, sets it, and clears it when it finishes, even though the other poll is still going.

**Fix:** track the running poll as a promise instead of a flag, and have a forced poll wait for (or reuse) the one already running.

```ts
private pollPromise?: Promise<void>
```

### L2: Source variables show frame, logo and audio layers as inputs

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:49-53`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/src/variables.ts#L49-L53), [`src/choices.ts:217-218`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/src/choices.ts#L217-L218)

**What goes wrong:** The **Current source** / **Next source** variables for the background frame, logo and audio layers show input names. A background frame layer showing frame 3 reads "Input 3", and frames or logos 7 and 8 read "Source 7" and "Source 8". Before the first poll answers, every source variable reads "None / Black" instead of "Unknown".

**Why it happens:** The module labels every layer's value with the input name list, even on layers where the value is a frame or logo number. A value that hasn't been received yet is treated as 0, which is the "None / Black" input.

**Fix:** choose the label by layer type (`Frame N`, `Logo N`, or the input name), and show `Unknown` when no value has been received for that layer.

### L3: Changing the connection settings leaves the old device's values on buttons

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:56-63`](https://github.com/bitfocus/companion-module-analogway-eks500/blob/acc9213557c072e79196838ed92f265a954493f6/src/main.ts#L56-L63)

**What goes wrong:** When a user changes the connection's IP address or protocol, buttons and variables keep showing the previous device's sources and tallies until the new device answers. If the new address never answers, they keep the old values indefinitely.

**Why it happens:** Saving the settings clears the module's stored device state and last error, but doesn't then refresh the variables or re-check the feedbacks, so Companion keeps showing the old values.

**Fix:** refresh the variables and feedbacks right after clearing the state.

```ts
this.state.clear()
this.lastError = ''
UpdateVariableValues(this)
this.checkFeedbacks('source_tally', 'input_signal' /* …the same list processData() uses */)
```
