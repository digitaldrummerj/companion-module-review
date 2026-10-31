# Review: companion-module-feelworld-l3-series v1.1.0

| Field | Value |
| --- | --- |
| **Module** | [companion-module-feelworld-l3-series](https://github.com/bitfocus/companion-module-feelworld-l3-series) |
| **Scope** | `tag` |
| **Version** | v1.1.0 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`8ea2538`](https://github.com/bitfocus/companion-module-feelworld-l3-series/tree/8ea2538d5685bc9e3e0b0744da95582ab68b5885) |
| **Reviewed** | 2026-10-30 |

This is the module's first release, so there is no previous tag to diff against: the whole module was reviewed, and every finding is classified 🆕 NEW.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | The switcher answers at least one of the read queries the module sends right after connecting (for example the PGM source query `0x20 0x0d`), so "first reply received" can stand in for "device reachable" | The module's own `handleFixedFrame()` handles replies to these queries; not verified on hardware | [M5](#m5-connection-shows-ok-even-when-the-switchers-ip-is-wrong-or-the-switcher-is-off) |
| A2 | The device reports Program/Preview channels 0-based (HDMI 1 = 0 … Media = 4), as the module's comments state ("实测确认" = confirmed by testing) | Comments at `src/feedbacks.ts:15` and `src/main.ts:504-505`, plus the preset mapping at `src/presets.ts:353-354`; not verified on hardware | [M6](#m6-the-pgmpvw-match-alert-never-lights-when-program-and-preview-are-both-on-input-1), [L4](#l4-source-dropdown-values-are-0-4-for-input-1-media-which-is-confusing-in-expression-mode) |

## 📋 Issues

### Blocking

- [ ] [C1: Missing .gitattributes file](#c1-missing-gitattributes-file)
- [ ] [C2: .gitignore is missing template entries](#c2-gitignore-is-missing-template-entries)
- [ ] [C3: Missing .husky/pre-commit hook](#c3-missing-huskypre-commit-hook)
- [ ] [C4: .prettierignore differs from the template](#c4-prettierignore-differs-from-the-template)
- [ ] [C5: .yarnrc.yml is missing template keys](#c5-yarnrcyml-is-missing-template-keys)
- [ ] [C6: .vscode/settings.json is committed](#c6-vscodesettingsjson-is-committed)
- [ ] [C7: package.json repository URL lacks the git+ prefix](#c7-packagejson-repository-url-lacks-the-git-prefix)
- [ ] [C8: package.json is missing the postinstall script](#c8-packagejson-is-missing-the-postinstall-script)
- [ ] [C9: package.json is missing the husky devDependency](#c9-packagejson-is-missing-the-husky-devdependency)
- [ ] [C10: package.json is missing the lint-staged devDependency](#c10-packagejson-is-missing-the-lint-staged-devdependency)
- [ ] [C11: package.json is missing the lint-staged section](#c11-packagejson-is-missing-the-lint-staged-section)
- [ ] [H1: release.yaml differs from the template](#h1-releaseyaml-differs-from-the-template)
- [ ] [H2: README and code comments are in Chinese instead of English](#h2-readme-and-code-comments-are-in-chinese-instead-of-english)

### Non-blocking

- [ ] [M1: Missing bug report issue template](#m1-missing-bug-report-issue-template)
- [ ] [M2: Missing issue template config](#m2-missing-issue-template-config)
- [ ] [M3: Missing feature request issue template](#m3-missing-feature-request-issue-template)
- [ ] [M4: Missing node.yaml workflow](#m4-missing-nodeyaml-workflow)
- [ ] [M5: Connection shows OK even when the switcher's IP is wrong or the switcher is off](#m5-connection-shows-ok-even-when-the-switchers-ip-is-wrong-or-the-switcher-is-off)
- [ ] [M6: The PGM/PVW Match Alert never lights when Program and Preview are both on Input 1](#m6-the-pgmpvw-match-alert-never-lights-when-program-and-preview-are-both-on-input-1)
- [ ] [M7: Action and feedback schemas are untyped, so option ids and values are not type-checked](#m7-action-and-feedback-schemas-are-untyped-so-option-ids-and-values-are-not-type-checked)
- [ ] [L1: Startup state-sync timers keep firing after the connection's settings are saved or it is disabled](#l1-startup-state-sync-timers-keep-firing-after-the-connections-settings-are-saved-or-it-is-disabled)
- [ ] [L2: PGM Source Indicator default highlight is almost black](#l2-pgm-source-indicator-default-highlight-is-almost-black)
- [ ] [L3: Numbered copies of actions instead of one action with an option](#l3-numbered-copies-of-actions-instead-of-one-action-with-an-option)
- [ ] [L4: Source dropdown values are 0-4 for Input 1-Media, which is confusing in expression mode](#l4-source-dropdown-values-are-0-4-for-input-1-media-which-is-confusing-in-expression-mode)
- [ ] [L5: Long-running toggle actions ignore Abort actions](#l5-long-running-toggle-actions-ignore-abort-actions)
- [ ] [N1: Duplicate send code and untyped JSON handling](#n1-duplicate-send-code-and-untyped-json-handling)
- [ ] [N2: Tracked device state is not exposed as variables](#n2-tracked-device-state-is-not-exposed-as-variables)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Missing .gitattributes file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** The template ships a `.gitattributes` that forces LF line endings. Without it, a contributor on Windows can commit CRLF files, which produces noisy diffs and Prettier failures.

**Why it happens:** The file tracked by the template is not in the module repo.

**Expected (template):**

```text
* text=auto eol=lf
```

**Fix:** copy `.gitattributes` from `companion-module-template-ts`.

### C2: .gitignore is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore:1-12`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.gitignore#L1-L12)

**What goes wrong:** Files the template keeps out of git (`package-lock.json`, `DEBUG-*` logs, `.vscode`) can be committed by accident. One already has been: see [C6](#c6-vscodesettingsjson-is-committed).

**Why it happens:** The module's `.gitignore` uses its own patterns (`dist/`, `pkg/`, `*.tgz`, `.yarn/*` with negations, plus `protocol_new.md` and `testWork/`) instead of the template's list.

**Missing template entries:** `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`.

**Fix:** copy the template's `.gitignore`. Extra local entries such as `protocol_new.md` and `testWork/` can be added below it.

### C3: Missing .husky/pre-commit hook

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Commits are not checked by lint-staged, so unformatted or lint-failing code can be committed.

**Why it happens:** The template's pre-commit hook (`lint-staged`) is not in the repo. It goes together with [C8](#c8-packagejson-is-missing-the-postinstall-script)-[C11](#c11-packagejson-is-missing-the-lint-staged-section).

**Fix:** copy `.husky/pre-commit` from the template.

### C4: .prettierignore differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:1-2`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.prettierignore#L1-L2)

**What goes wrong:** `yarn format` reformats `package.json` and `LICENSE.md`, which the template deliberately leaves alone.

**Why it happens:** The template entries were replaced rather than extended.

**Found vs expected:**

```text
found:     package-lock.json, yarn.lock
template:  package.json, /LICENSE.md
```

**Fix:** use the template's `.prettierignore`. Keeping `yarn.lock` as an extra line is fine.

### C5: .yarnrc.yml is missing template keys

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.yarnrc.yml:1`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.yarnrc.yml#L1)

**What goes wrong:** The supply-chain protections the template sets for every module are off: dependency install scripts run, and freshly published (possibly malicious) package versions are installed at once.

**Why it happens:** The module's file only has `nodeLinker: node-modules`.

**Expected (template):**

```yaml
enableScripts: false

nodeLinker: node-modules

npmMinimalAgeGate: 3d

npmPreapprovedPackages:
  - "@companion-module/*"
```

**Fix:** copy the template's `.yarnrc.yml`.

### C6: .vscode/settings.json is committed

- **Source:** 🤖 validate-template (GITIGNORED-COMMITTED)
- **Classification:** 🆕 NEW
- **File:** [`.vscode/settings.json:1-8`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.vscode/settings.json#L1-L8)

**What goes wrong:** Personal editor settings are shipped to every contributor.

**Why it happens:** The template's `.gitignore` excludes `/.vscode`, but the module's `.gitignore` does not (see [C2](#c2-gitignore-is-missing-template-entries)), so the file was committed.

**Fix:** remove it from the repo (`git rm --cached .vscode/settings.json`) and add `/.vscode` to `.gitignore`.

### C7: package.json repository URL lacks the git+ prefix

- **Source:** 🤖 validate-template (PKG-REPO)
- **Classification:** 🆕 NEW
- **File:** [`package.json:27`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L27)

**Found vs expected:**

```text
found:    https://github.com/bitfocus/companion-module-feelworld-l3-series.git
expected: git+https://github.com/bitfocus/companion-module-feelworld-l3-series.git
```

**Fix:** add the `git+` prefix to `repository.url`.

### C8: package.json is missing the postinstall script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-15`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L7-L15)

**What goes wrong:** `yarn install` never installs the git hooks, so the pre-commit check from [C3](#c3-missing-huskypre-commit-hook) would not run even once the hook file exists.

**Expected (template):**

```json
"postinstall": "husky"
```

**Fix:** add the script to `scripts`.

### C9: package.json is missing the husky devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:38-46`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L38-L46)

**Expected (template):** `"husky": "^9.1.7"` in `devDependencies`.

**Fix:** `yarn add -D husky`.

### C10: package.json is missing the lint-staged devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:38-46`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json#L38-L46)

**Expected (template):** `"lint-staged": "^17.6.0"` in `devDependencies`.

**Fix:** `yarn add -D lint-staged`.

### C11: package.json is missing the lint-staged section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/package.json)

**Expected (template):**

```json
"lint-staged": {
	"*.{css,json,md,scss}": ["prettier --write"],
	"*.{ts,tsx,js,jsx}": ["yarn lint:raw --fix"]
}
```

**Fix:** copy the `lint-staged` section from the template's `package.json`.

## 🟠 High

### H1: release.yaml differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:47`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.github/workflows/release.yaml#L47)

**What goes wrong:** The package attached to a GitHub release is named with the `v` prefix (for example `feelworld-l3-series-v1.1.0.tgz`), where the template's workflow names it `feelworld-l3-series-1.1.0.tgz`.

**Why it happens:** The asset-name line drops the template's `#v` strip.

**Found vs expected:**

```text
found:    NAME="${GITHUB_REPOSITORY#*/companion-module-}-${TAG}"
template: NAME="${GITHUB_REPOSITORY#*/companion-module-}-${TAG#v}"
```

**Fix:** copy the template's `.github/workflows/release.yaml`.

### H2: README and code comments are in Chinese instead of English

- **Source:** 🤖 validate-template (NOT-ENGLISH)
- **Classification:** 🆕 NEW
- **File:** [`README.md`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md) and 5 more files (listed under Fix)

**What goes wrong:** The Chinese half of `README.md` and the code comments in `src/` (protocol notes: which command bytes do what, how channels are numbered, which reply refreshes which state) are in Chinese, as are two comments in `.vscode/settings.json`. A user reading the README, or anyone who later maintains or troubleshoots the module (a Bitfocus reviewer, a contributor fixing a bug), can't read them. `README.md` is bilingual today: keep the English half and drop or translate the Chinese one.

**Why it happens:** Everything in a Companion module must be written in English: code comments, the text users see in Companion (action, feedback, preset and variable names, option labels, config fields, status and log messages), `companion/HELP.md` and `README.md`. That way every user, reviewer and future maintainer can read it. These lines are in Chinese.

**Evidence:** 406 lines in 6 files, for example:

```text
README.md:3  > 本文档提供中英双语说明。Chinese and English documentation are both included below.
src/feedbacks.ts:15  // 设备通道编号为 0 起始：HDMI1-4 = 0-3，MEDIA = 4（实测确认）
src/actions.ts:161  // 新协议 5.1-5.3：媒体控制 CMD=0x12，DAT2：0x00 停止 / 0x01 播放 / 0x02 暂停；0x02 下一个 / 0x04 上一个
```

**Confirm by:** search the files for Chinese characters, e.g. `git grep -nP '[\x{4e00}-\x{9fff}]'`.

**Fix:** write all of this text in English. These are the lines to change:

- [ ] [`.vscode/settings.json`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.vscode/settings.json) (2 lines): [`2-3`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/.vscode/settings.json#L2-L3)
- [ ] [`README.md`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md) (205 lines): [`3`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L3), [`7`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L7), [`9-17`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L9-L17), [`30`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L30), [`32`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L32), [`34`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L34), [`36`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L36), [`38`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L38), [`40-55`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L40-L55), [`57`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L57), [`61`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L61), [`66-71`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L66-L71), [`73-74`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L73-L74), [`76-80`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L76-L80), [`85`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L85), [`87`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L87), [`89-91`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L89-L91), [`93`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L93), [`99`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L99), [`105`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L105), [`107`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L107), [`113`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L113), [`115`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L115), [`117-119`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L117-L119), [`123`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L123), [`125`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L125), [`127`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L127), [`129-130`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L129-L130), [`132`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L132), [`136`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L136), [`138`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L138), [`140`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L140), [`142`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L142), [`148`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L148), [`151`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L151), [`157`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L157), [`159`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L159), [`161`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L161), [`163`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L163), [`165-172`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L165-L172), [`174`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L174), [`176`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L176), [`178-196`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L178-L196), [`198`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L198), [`200-204`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L200-L204), [`208`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L208), [`210`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L210), [`212`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L212), [`214-230`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L214-L230), [`232`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L232), [`234`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L234), [`236-250`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L236-L250), [`252`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L252), [`254`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L254), [`256`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L256), [`258-259`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L258-L259), [`263`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L263), [`265`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L265), [`267-269`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L267-L269), [`271`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L271), [`273-275`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L273-L275), [`277`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L277), [`279-281`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L279-L281), [`283`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L283), [`285-290`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L285-L290), [`292`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L292), [`294-295`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L294-L295), [`297`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L297), [`299-300`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L299-L300), [`302`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L302), [`304-306`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L304-L306), [`310`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L310), [`312`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L312), [`314`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L314), [`316`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L316), [`322`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L322), [`328`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L328), [`334`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L334), [`338`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L338), [`340`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L340), [`342`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L342), [`380`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L380), [`382`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L382), [`384`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L384), [`391`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L391), [`398`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L398), [`413`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L413), [`415`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L415), [`421`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L421), [`433`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L433), [`435`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L435), [`447`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/README.md#L447)
- [ ] [`src/actions.ts`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts) (22 lines): [`101-102`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L101-L102), [`155`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L155), [`161`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L161), [`173`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L173), [`177`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L177), [`179`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L179), [`186`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L186), [`196`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L196), [`216`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L216), [`234`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L234), [`237`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L237), [`239`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L239), [`245`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L245), [`249`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L249), [`251`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L251), [`264`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L264), [`266`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L266), [`274`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L274), [`281`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L281), [`293`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L293), [`329`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L329)
- [ ] [`src/feedbacks.ts`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts) (18 lines): [`15`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L15), [`43-46`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L43-L46), [`53`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L53), [`117`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L117), [`133`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L133), [`172`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L172), [`183`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L183), [`196`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L196), [`210`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L210), [`221`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L221), [`229`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L229), [`239`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L239), [`261`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L261), [`286`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L286), [`291`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L291)
- [ ] [`src/main.ts`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts) (149 lines): [`28`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L28), [`30`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L30), [`32`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L32), [`34`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L34), [`36`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L36), [`39`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L39), [`41`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L41), [`44-45`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L44-L45), [`47`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L47), [`49`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L49), [`51`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L51), [`53`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L53), [`55`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L55), [`57`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L57), [`59`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L59), [`62`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L62), [`64`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L64), [`69`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L69), [`71`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L71), [`73`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L73), [`75`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L75), [`77`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L77), [`128`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L128), [`139`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L139), [`150-154`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L150-L154), [`162`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L162), [`181`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L181), [`190-191`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L190-L191), [`198`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L198), [`203`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L203), [`208-210`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L208-L210), [`221`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L221), [`227`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L227), [`249`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L249), [`253`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L253), [`263`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L263), [`270`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L270), [`287`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L287), [`308`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L308), [`316`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L316), [`321-324`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L321-L324), [`333`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L333), [`342`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L342), [`349-350`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L349-L350), [`374-375`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L374-L375), [`384-385`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L384-L385), [`397`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L397), [`404`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L404), [`410`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L410), [`418`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L418), [`423`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L423), [`442`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L442), [`449`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L449), [`456`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L456), [`463`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L463), [`474`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L474), [`481-482`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L481-L482), [`504-505`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L504-L505), [`516-517`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L516-L517), [`525`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L525), [`536`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L536), [`542`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L542), [`548`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L548), [`554`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L554), [`560`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L560), [`570`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L570), [`588`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L588), [`594`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L594), [`600`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L600), [`606-607`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L606-L607), [`613`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L613), [`630-631`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L630-L631), [`635-645`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L635-L645), [`647-652`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L647-L652), [`727`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L727), [`740-742`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L740-L742), [`751-753`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L751-L753), [`757`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L757), [`769`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L769), [`786`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L786), [`802-803`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L802-L803), [`826-828`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L826-L828), [`845-846`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L845-L846), [`857`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L857), [`871`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L871), [`873`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L873), [`880`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L880), [`887`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L887), [`892`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L892), [`898`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L898), [`905`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L905), [`917`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L917), [`924`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L924), [`931`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L931), [`954`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L954), [`993-995`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L993-L995), [`998`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L998), [`1006`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L1006), [`1011`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L1011), [`1015`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L1015), [`1054-1056`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L1054-L1056), [`1082`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L1082), [`1107`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L1107)
- [ ] [`src/presets.ts`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts) (10 lines): [`201-204`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L201-L204), [`216-217`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L216-L217), [`288`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L288), [`297`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L297), [`353`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L353), [`386`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L386)

## 🟡 Medium

### M1: Missing bug report issue template

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/bug_report.yml` (missing)

**Fix:** copy the file from the template.

### M2: Missing issue template config

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/config.yml` (missing)

**Fix:** copy the file from the template.

### M3: Missing feature request issue template

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/feature_request.yml` (missing)

**Fix:** copy the file from the template.

### M4: Missing node.yaml workflow

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** Pushes and pull requests are not linted or built by CI.

**Fix:** copy `.github/workflows/node.yaml` from the template.

### M5: Connection shows OK even when the switcher's IP is wrong or the switcher is off

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:125-130`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L125-L130)

**What goes wrong:** A user enters a wrong Device IP Address (for example 192.168.1.150 when the L3 is at 192.168.1.100), or the switcher is powered off. The connection still turns green (OK) in the Connections list. Buttons send commands into the void and feedbacks (Program/Preview source, PIP, mute and so on) never update, with nothing in the UI saying the device is unreachable.

**Why it happens:** The status is set to OK when the local UDP socket starts listening. That only means Companion opened a local port, which always succeeds; it says nothing about the switcher. The status is never tied to a reply from the device, even though the module sends read queries right after connecting that the device answers.

```ts
// src/main.ts:125-130
this.socket.on('listening', () => {
	this.updateStatus(InstanceStatus.Ok)
	this.log('info', `Connected to ${this.config.host}:${this.config.port}`)
	this.syncAllStates()
})
```

**Fix:** set the status to Connecting when the socket starts listening, switch it to OK in `handleResponse()` when the first valid reply arrives from the configured host, and set ConnectionFailure (for example "No response from device") if nothing arrives within a few seconds of the startup queries.

### M6: The PGM/PVW Match Alert never lights when Program and Preview are both on Input 1

- **Source:** 🔎 QA reviewer + compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:112-114`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L112-L114)

**What goes wrong:** A user adds the "PGM/PVW Match Alert" feedback so a button turns yellow when Program and Preview show the same source. With Input 2 on both, the button turns yellow. With Input 1 on both, it stays dark, so the alert never works for the first HDMI input.

**Why it happens:** The device numbers its channels from 0, so Input 1 is channel 0 (the module's own comment at [`src/feedbacks.ts:15`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L15) says so). The feedback also requires the Program channel to be non-zero, probably to hide the alert before the first state sync, when both stored values start at 0. But 0 is also the real value for Input 1, so a genuine Input 1 match is always hidden.

```ts
// src/feedbacks.ts:112-114
callback: () => {
	return self.getCurrentPgm() === self.getCurrentPvw() && self.getCurrentPgm() !== 0
},
```

**Fix:** remove the `!== 0` check, and mark "not yet known" separately: start `currentPgm` / `currentPvw` at -1 (or add a "known" flag) and check `self.getCurrentPgm() >= 0`.

### M7: Action and feedback schemas are untyped, so option ids and values are not type-checked

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:8`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L8), [`src/feedbacks.ts:11`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L11)

**What goes wrong:** No visible effect today; this is code quality. A typo in a feedback option id, or in a preset's feedback options (for example `{ scnee: '1' }`), would compile and ship, and the button would silently never light.

**Why it happens:** Both schemas are declared as "any id, any options" (`Record<string, { options: CompanionOptionValues }>`), so the callbacks have to cast (`feedback.options.source as string`, at `src/feedbacks.ts` lines 83, 98, 191, 256 and 281) and the presets build their options as `Record<string, any>`. API 2.x lets a module declare each action and feedback with its options, so that `CompanionPresetDefinitions<ModuleSchema>` checks preset ids and options at compile time.

**Fix:** declare concrete schemas, for example `type FeedbacksSchema = { pgm_source: { type: 'boolean'; options: { source: string } }; scene_active: { type: 'boolean'; options: { scene: string } }; pip_active: { type: 'boolean'; options: Record<string, never> }; … }`, and the same for actions. Then drop the `as string` casts and the `Record<string, any>` preset option maps.

## 🟢 Low

### L1: Startup state-sync timers keep firing after the connection's settings are saved or it is disabled

- **Source:** 🔎 protocol reviewer + QA reviewer — verified
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:95-110`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L95-L110), [`src/main.ts:633-659`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L633-L659)

**What goes wrong:** Each time the connection starts (on enable and on every settings save), the module schedules about 21 one-shot timers, 100 ms apart, that send read queries (PGM, PVW, PIP, key, LOGO, mute, volume, scene, FTB, AFV 1-5) over roughly 2.1 seconds. Nothing cancels them. If the user changes the Device IP Address (say from 192.168.1.100 to 192.168.1.101) within that window, the old run's leftover queries go out on the new socket next to the new run's, so the device gets duplicate reads. If the connection is disabled in that window, the leftover timers each log a "Socket not connected" error. The module's other short timers (the 100 ms button flash, the 1 s stream/disk warnings, the logo-toggle readback) are not tracked or cleared either.

**Why it happens:** The sync routine creates each timer with `setTimeout` and throws the handle away. On teardown, `destroy()` only clears the JSON-wait timer and closes the socket, and a settings save (`configUpdated()`) only closes the socket, so neither can cancel the pending timers.

**Evidence:**

```ts
// src/main.ts:95-110
async destroy(): Promise<void> {
	this.clearJsonWait()
	if (this.socket) {
		this.socket.close()
		this.socket = null
	}
}

async configUpdated(config: ModuleConfig): Promise<void> {
	this.config = config
	if (this.socket) {
		this.socket.close()
		this.socket = null
	}
	await this.connect()
}
// src/main.ts:655-659
queries.forEach((query, i) => {
	setTimeout(() => {
		query().catch(() => {})
	}, i * 100)
})
// src/main.ts:1087-1092
flashAction(id: string, ms = 100): void {
	this.flashUntil[id] = Date.now() + ms
	this.checkAllFeedbacks()
	setTimeout(() => {
		delete this.flashUntil[id]
		this.checkAllFeedbacks()
	}, ms)
}
```

**Confirm by:** open [`src/main.ts:655-659`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L655-L659) and see that the timer handles are discarded, then [`src/main.ts:95-110`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L95-L110): `destroy()` and `configUpdated()` cancel none of them.

**Fix:** keep the sync timer handles and clear them in `destroy()`, in `configUpdated()` before closing the old socket, and at the start of each new sync. Track the flash and warning timers the same way.

```ts
private syncTimers: NodeJS.Timeout[] = []

private clearSyncTimers(): void {
	for (const t of this.syncTimers) clearTimeout(t)
	this.syncTimers = []
}

// in syncAllStates(): this.clearSyncTimers(), then
// this.syncTimers.push(setTimeout(() => { query().catch(() => {}) }, i * 100))
```

### L2: PGM Source Indicator default highlight is almost black

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:50-51`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L50-L51), [`src/feedbacks.ts:77-80`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L77-L80)

**What goes wrong:** A user adds the "PGM Source Indicator" feedback to their own button (not from a preset) and picks "Input 1". When Input 1 goes to Program, the button turns #28181C, a very dark maroon that is hard to tell from Companion's default black. The presets look fine because they use #B71F16 red.

**Why it happens:** The feedback's default style uses `PGM_ACTIVE_BG = 0x28181c`, while [`src/presets.ts:212`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L212) defines its own `PGM_ACTIVE_BG = 0xb71f16`.

**Fix:** use one shared constant (for example `0xb71f16`) for both the feedback default style and the preset style.

### L3: Numbered copies of actions instead of one action with an option

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:144-153`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L144-L153), [`src/actions.ts:294-317`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L294-L317)

**What goes wrong:** The action list holds about 90 entries, many of them numbered copies: "PGM Source 1" to "5", "PVW Source 1" to "5", "Scene 1" to "8", "Effect Mode 1" to "16", "AFV 1" to "5 Toggle", "Stream 1" to "4 Toggle", "PIP Template 1" to "8". None has an option, so users cannot pick the input from a variable or expression; for example, one "Set Program" button driven by `$(custom:next_cam)` is not possible. The feedbacks are inconsistent too: "PGM Source Indicator" and "Scene Active" have a dropdown, but "AFV 1" to "5 Active" and "Stream 1" to "4 Active" are separate feedbacks.

**Why it happens:** Every action is built from a fixed spec with no options (see [`src/actions.ts:327`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L327)), and the index is baked into the action id.

**Fix:** before the first release locks these ids in, consider single actions with a dropdown or number option (for example `pgm_source` with option `source`, `scene_recall` with option `scene`, `afv_toggle` with option `channel`) and matching single feedbacks. Changing ids later needs upgrade scripts, so now is the cheapest time. Keeping the numbered actions is also acceptable.

### L4: Source dropdown values are 0-4 for Input 1-Media, which is confusing in expression mode

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/feedbacks.ts:16-30`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/feedbacks.ts#L16-L30)

**What goes wrong:** A user switches the "Source" option of "PGM Source Indicator" to expression mode and enters 1, meaning Input 1. The feedback then lights for Input 2, because the values behind the labels are '0' = Input 1 … '4' = Media.

**Why it happens:** In API 2.x users can enter any dropdown as an expression, and they type the stored value, not the label. These values are the device's 0-based channel numbers.

**Fix:** use values that match the labels ('1' to '5', or 'input1' to 'input4' / 'media') and convert to the device channel in the callback. No upgrade script is needed for a first release; update the preset options at [`src/presets.ts:354`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/presets.ts#L354) too.

### L5: Long-running toggle actions ignore Abort actions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:744-767`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L744-L767), [`src/main.ts:848-869`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L848-L869)

**What goes wrong:** If a button aborts its actions (Companion 5's "Abort actions") while "Stream 1 Toggle" is waiting for the device's confirmation, the module carries on: it keeps sending the stop/retry commands for up to about 3.2 s and may then flag the stream as on or show "ADDRESS EMPTY".

**Why it happens:** The stream toggle waits up to 1.5 s, sends a reset, waits 200 ms and waits another 1.5 s; the record toggle waits up to 1.5 s for the USB-disk query; the volume step and background query wait up to 1 s. The action callback at [`src/actions.ts:328`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/actions.ts#L328) never passes Companion's abort signal (`context.signal`) to these helpers.

**Fix:** pass `context.signal` into these helpers, check `signal.aborted` after each wait and return early (a wait that also resolves on the signal's `abort` event works well).

## 💡 Nice to Have

### N1: Duplicate send code and untyped JSON handling

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:676-711`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L676-L711), [`src/main.ts:326`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L326), [`src/main.ts:352`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/main.ts#L352)

**What goes wrong:** No user-visible effect. `sendBuffer()` and `sendCommand()` repeat the same socket check and send logic, and the JSON report parser uses `any` throughout, which makes future protocol changes easy to get wrong.

**Fix:** have `sendCommand()` build the string and call `sendBuffer(Buffer.from(command, 'ascii'), command)`, and add a small interface for the `0xB1 0x58` report (`pgmpvwInfo`, `streamInfo`, `recordInfo`, …) instead of `any`.

### N2: Tracked device state is not exposed as variables

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/variables.ts:3-12`](https://github.com/bitfocus/companion-module-feelworld-l3-series/blob/8ea2538d5685bc9e3e0b0744da95582ab68b5885/src/variables.ts#L3-L12)

**What goes wrong:** Users can press "PVW Vol +1" / "PGM Vol +1" but cannot show the current volume on a button, although the module already reads it. The same goes for the current scene, recording, stream 1-4 state and transition type: they are only available as on/off highlights, not as text such as "SCN 3" or "VOL 72".

**Fix:** add variables such as `pgm_volume`, `pvw_volume`, `current_scene`, `recording`, `stream_1` to `stream_4` and `transition_type`, and set them wherever the matching state changes (`handleFixedFrame()` / `applyJsonReport()`).

## 📝 Additional Notes

- `tsconfig.build.json` differs from the template: `exclude` uses `src/**/*.spec.ts` where the template has `src/**/*spec.ts` (line 4). It builds fine; no change required.
