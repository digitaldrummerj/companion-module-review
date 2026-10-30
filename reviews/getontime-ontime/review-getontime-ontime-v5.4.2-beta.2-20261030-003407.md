# Review: companion-module-getontime-ontime v5.4.2-beta.2

| Field | Value |
| --- | --- |
| **Module** | `companion-module-getontime-ontime` |
| **Scope** | `tag` (v5.4.1..v5.4.2-beta.2) |
| **Version** | v5.4.2-beta.2 |
| **Release** | Update — last published v5.4.1 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`2578aee`](https://github.com/bitfocus/companion-module-getontime-ontime/tree/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c) |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | A message action that the old 5.2.0 upgrade script skipped (it returned `false`) is still stored by Companion under its old action id, or as a "Message control" action with no properties, so a newly appended upgrade script would still receive it and could repair it | Companion stores only the actions an upgrade script returns (confirmed host behaviour). How Companion keeps an action whose id no longer exists in the module's definitions is not visible from the module code | [M3](#m3-message-buttons-broken-by-an-earlier-upgrade-stay-broken-because-the-fix-edits-upgrade-scripts-that-already-ran) |

## 📋 Issues

### Blocking

- [ ] [C1: .gitattributes has extra rules the template does not have](#c1-gitattributes-has-extra-rules-the-template-does-not-have)
- [ ] [C2: .gitignore is missing five template entries, so build output can be committed](#c2-gitignore-is-missing-five-template-entries-so-build-output-can-be-committed)
- [ ] [C3: The pre-commit hook file is missing, so lint-staged never runs on commit](#c3-the-pre-commit-hook-file-is-missing-so-lint-staged-never-runs-on-commit)
- [ ] [C4: .prettierignore differs from the template](#c4-prettierignore-differs-from-the-template)
- [ ] [C5: .yarnrc.yml pre-approves an extra package scope](#c5-yarnrcyml-pre-approves-an-extra-package-scope)
- [ ] [C6: package.json has no postinstall script to install the git hooks](#c6-packagejson-has-no-postinstall-script-to-install-the-git-hooks)
- [ ] [C7: The module's search keywords include the banned word companion](#c7-the-modules-search-keywords-include-the-banned-word-companion)
- [ ] [C8: The module runs on Node 22 where the API 2.1 template uses Node 26](#c8-the-module-runs-on-node-22-where-the-api-21-template-uses-node-26)
- [ ] [H1: The LICENSE copyright year differs from the template](#h1-the-license-copyright-year-differs-from-the-template)

### Non-blocking

- [ ] [M1: The GitHub issue forms from the template are missing](#m1-the-github-issue-forms-from-the-template-are-missing)
- [ ] [M2: The template's CI and release workflows are missing](#m2-the-templates-ci-and-release-workflows-are-missing)
- [ ] [M3: Message buttons broken by an earlier upgrade stay broken, because the fix edits upgrade scripts that already ran](#m3-message-buttons-broken-by-an-earlier-upgrade-stay-broken-because-the-fix-edits-upgrade-scripts-that-already-ran)
- [ ] [L1: After a version mismatch or a missed version reply, the connection never retries, even once Ontime is fixed](#l1-after-a-version-mismatch-or-a-missed-version-reply-the-connection-never-retries-even-once-ontime-is-fixed)

## 🔴 Critical

### C1: .gitattributes has extra rules the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`.gitattributes:2-3`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/.gitattributes#L2-L3)

**What goes wrong:** The repo's git settings drift from every other TypeScript module built from the template, which makes it harder for Bitfocus maintainers to troubleshoot or bulk-update the module later.

**Why it happens:** The template's `.gitattributes` has a single line, `* text=auto eol=lf`. This module adds rules for a committed `.yarn/releases` and `.yarn/plugins` folder that the template no longer uses.

**Evidence:** validator reports "Differs from template (line 2: found `/.yarn/releases/** binary`, template `<missing>`)".

**Fix:** reduce `.gitattributes` to the template's single line.

```text
* text=auto eol=lf
```

### C2: .gitignore is missing five template entries, so build output can be committed

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/.gitignore)

**What goes wrong:** Files that should never be in the repo, such as an npm `package-lock.json`, a packaged `*.tgz` in the repo root or the `.yarn` cache folder, can be committed by accident.

**Why it happens:** The module's `.gitignore` is an older layout. It has `dist/`, `pkg` and `*.tgz` patterns but not the template's root-anchored entries, and it re-includes parts of `.yarn` that the template ignores entirely.

**Evidence:** validator reports "Missing template .gitignore entries: `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `/.yarn`".

**Fix:** replace `.gitignore` with the template's version.

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

### C3: The pre-commit hook file is missing, so lint-staged never runs on commit

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Code is committed without the automatic formatting and lint fixes the template runs before every commit, even though `husky` and `lint-staged` are in the module's dev dependencies and `package.json` has a `lint-staged` block.

**Why it happens:** The template ships a `.husky/pre-commit` hook that runs `lint-staged`. The module has no `.husky` folder at all, so there is no hook to run.

**Evidence:** validator reports "Required file is missing (tracked by the template)".

**Fix:** add `.husky/pre-commit` with the template's content (and see [C6](#c6-packagejson-has-no-postinstall-script-to-install-the-git-hooks), which installs the hook).

```bash
lint-staged
```

### C4: .prettierignore differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/.prettierignore#L2)

**What goes wrong:** Formatting behaves differently from other template-based modules, which confuses later troubleshooting.

**Why it happens:** The template's `.prettierignore` lists only `package.json` and `/LICENSE.md`. This module adds `pkg` and `node_modules/`.

**Evidence:** validator reports "Differs from template (line 2: found `pkg`, template `/LICENSE.md`)".

**Fix:** replace `.prettierignore` with the template's two lines.

```text
package.json
/LICENSE.md
```

### C5: .yarnrc.yml pre-approves an extra package scope

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`.yarnrc.yml:4-6`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/.yarnrc.yml#L4-L6)

**What goes wrong:** Any newly published `@getontime/*` package (for example a new `@getontime/resolver`) is installed straight away, skipping the 3-day safety delay the template applies to every package outside `@companion-module/*`.

**Why it happens:** The template's `npmMinimalAgeGate: 3d` holds back packages published less than 3 days ago, as protection against a compromised release. `npmPreapprovedPackages` exempts the listed scopes from that delay, and this module adds `@getontime/*` to the list.

**Evidence:** validator reports "Value mismatch: npmPreapprovedPackages = `[@companion-module/*, @getontime/*]` (template `[@companion-module/*]`)".

**Fix:** remove the `@getontime/*` entry so the list matches the template. A brand-new `@getontime/resolver` release then needs to be 3 days old before it installs.

```yaml
npmPreapprovedPackages:
  - '@companion-module/*'
```

### C6: package.json has no postinstall script to install the git hooks

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`package.json:11-21`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/package.json#L11-L21)

**What goes wrong:** Running `yarn install` does not set up the git hooks the way the template does, so contributors don't get the pre-commit checks.

**Why it happens:** The template installs husky with a `"postinstall": "husky"` script. This module uses the older `"prepare": "husky install"` form instead.

**Evidence:** validator reports "Missing required script `postinstall`".

**Fix:** replace the `prepare` script with the template's `postinstall` script.

```json
"postinstall": "husky",
```

### C7: The module's search keywords include the banned word companion

- **Source:** 🤖 validate-template (MAN-KEYWORD)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`companion/manifest.json:34`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/companion/manifest.json#L34)

**What goes wrong:** The keyword "companion" matches every module, so it adds nothing to search in Companion's connection list and is on the banned low-value list.

**Why it happens:** `keywords` in the manifest is `["ontime", "companion"]`.

**Evidence:** validator reports "Banned/low-value keyword `companion`".

**Fix:** remove `"companion"` from the keywords.

```json
"keywords": ["ontime"]
```

### C8: The module runs on Node 22 where the API 2.1 template uses Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`companion/manifest.json:27`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/companion/manifest.json#L27), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/tsconfig.build.json#L2)

**What goes wrong:** The module uses `@companion-module/base` 2.1 (Companion 5.0+) but asks Companion for the Node 22 runtime, while the API 2.1 template targets Node 26. The mismatch makes the module behave differently from other 2.1 modules and confuses later troubleshooting.

**Why it happens:** `runtime.type` in the manifest is still `node22`, and `tsconfig.build.json` still extends the Node 22 ESM preset from `@companion-module/tools`.

**Evidence:** validator reports "runtime.type `node22` should be `node26` to match the API 2.1 template; also extend `@companion-module/tools/tsconfig/node26/recommended.json` in tsconfig.build.json, as the template does".

**Fix:** switch the manifest runtime to `node26`, and point `tsconfig.build.json` at the Node 26 preset (it currently extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`).

```json
// companion/manifest.json
"type": "node26",
```

```json
// tsconfig.build.json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
```

## 🟠 High

### H1: The LICENSE copyright year differs from the template

- **Source:** 🤖 validate-template (LICENSE-DIFF)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** [`LICENSE:3`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/LICENSE#L3)

**What goes wrong:** The license text does not match the standard Bitfocus MIT license that every template-based module carries.

**Why it happens:** Line 3 says 2021; the template says 2022.

**Evidence:** validator reports "Differs from template (line 3: found `Copyright (c) 2021 Bitfocus AS - Open Source`, template `Copyright (c) 2022 Bitfocus AS - Open Source`)".

**Fix:** copy the template's `LICENSE` file over the module's.

```text
Copyright (c) 2022 Bitfocus AS - Open Source
```

## 🟡 Medium

### M1: The GitHub issue forms from the template are missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** `.github/ISSUE_TEMPLATE/bug_report.yml`, `.github/ISSUE_TEMPLATE/config.yml`, `.github/ISSUE_TEMPLATE/feature_request.yml` (missing)

**What goes wrong:** Users who open an issue on GitHub don't get the standard Bitfocus bug-report and feature-request forms.

**Why it happens:** The module has its own `.github/ISSUE_TEMPLATE/bug_report.yaml` (different name and content) and none of the template's three files.

**Fix:** copy the three files from the template's `.github/ISSUE_TEMPLATE/` folder (and remove the old `bug_report.yaml` so there's only one bug form).

### M2: The template's CI and release workflows are missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** Template check — applies to every release (unchanged since v5.4.1)
- **File:** `.github/workflows/node.yaml`, `.github/workflows/release.yaml` (missing)

**What goes wrong:** Pushes and tags don't run the template's standard build check and release packaging, so a broken build or package is only noticed after submission.

**Why it happens:** The module has its own `.github/workflows/build.yml` instead of the template's `node.yaml` and `release.yaml`.

**Fix:** copy `node.yaml` and `release.yaml` from the template's `.github/workflows/` folder (and drop `build.yml` if it duplicates `node.yaml`).

### M3: Message buttons broken by an earlier upgrade stay broken, because the fix edits upgrade scripts that already ran

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions/message.ts:208-266`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/src/actions/message.ts#L208-L266), [`src/upgrades.ts:74-84`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/src/upgrades.ts#L74-L84), [`src/upgrades.ts:171-188`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/src/upgrades.ts#L171-L188)

**What goes wrong:** HELP.md says this release "Fixed migration ... of message actions from before 5.2", but the fix only helps someone importing a pre-5.2 config for the first time. Anyone who already ran module 5.2.0 to 5.4.1 keeps the broken buttons: for example, an old "Timer blink" button left at its default option was skipped by the 5.2.0 migration, and it is still broken after this upgrade. In the same way, users whose v4 config was already migrated (host `192.168.1.10`, port `4001`) keep an "Ontime server address" without its port.

**Why it happens:** Companion runs each upgrade script only once per connection and records that it ran. The new fallback defaults were written into the existing 5.2.0 message-action script (position 9 in the upgrade list) and the existing v4-to-v5 config script `update5` (position 4), instead of into new scripts added at the end of the list, so connections that already ran those positions never see the fix.

**Evidence:**

```ts
// src/upgrades.ts:176-181
	update5,
	FeedbackUpdater(upgrade_offsetIsInvertedFeedback),
	ActionUpdater(upgrade_removeIsPublic),
	ActionUpdater(upgrade_changeTimeWithExpression),
	ActionUpdater(upgrade_auxTimerDurationTakesExpressions),
	ActionUpdater(upgrade_collectMessageActions),
```

**Confirm by:** run `git diff v5.4.1..v5.4.2-beta.2 -- src/actions/message.ts src/upgrades.ts`. Both edited functions are already in the v5.4.1 `upgradeScripts` list, and no new entry was added at the end.

**Fix:** keep the corrected logic, and also add `ActionUpdater(upgrade_collectMessageActions)` again as a new last entry in `upgradeScripts`. It only matches the old action ids (`setMessageSecondarySource`, `TimerBlink`, `TimerBlackout`, `setMessageVisibilityAndText`, `setMessage`, `setMessageVisibility`), so running it a second time is safe, and it converts the buttons the old script skipped. Optionally also fill in a "Message control" action that has no `properties`. A script can't recover the port the old `update5` dropped, so add a line to HELP.md telling users who migrated from v4 to check that the "Ontime server address" includes the port.

## 🟢 Low

### L1: After a version mismatch or a missed version reply, the connection never retries, even once Ontime is fixed

- **Source:** 🔎 compliance reviewer
- **Classification:** 🔙 REGRESSION
- **File:** [`src/socket.ts:128-130`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/src/socket.ts#L128-L130), [`src/socket.ts:152-155`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/src/socket.ts#L152-L155), [`src/socket.ts:211-215`](https://github.com/bitfocus/companion-module-getontime-ontime/blob/2578aee183f4a43f8368f9ca85a43e0e8b4efb2c/src/socket.ts#L211-L215)

**What goes wrong:** In 5.4.1, a missing version reply made the module retry every 5 seconds. Now the connection shows "Bad configuration" (for example "Unsupported Ontime version 3.8.0, this module requires 4.x.x" or "No version response from 192.168.1.10:4001 ...") and stops for good. If the user then upgrades Ontime to 4.x, or the server was just slow to answer, the connection stays red until the user disables and re-enables it or edits its config, and HELP.md doesn't say so.

**Why it happens:** The new version-failure handler (`badVersion()`) closes the socket and clears the reconnect timer. With no socket left, the reconnect logic deliberately does nothing, so no further attempt is ever scheduled.

**Fix:** keep reporting "Bad configuration", but schedule a slow retry (for example every 30 seconds) after a version mismatch or a missed version reply. Alternatively, add a line to HELP.md telling users to disable and re-enable the connection after upgrading Ontime.
