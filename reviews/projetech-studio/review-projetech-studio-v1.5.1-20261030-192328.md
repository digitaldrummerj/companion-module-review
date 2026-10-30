# Review: companion-module-projetech-studio v1.5.1

| Field | Value |
| --- | --- |
| **Module** | [companion-module-projetech-studio](https://github.com/bitfocus/companion-module-projetech-studio) |
| **Scope** | `tag` |
| **Version** | v1.5.1 |
| **Release** | New module — never published |
| **API** | 1 (base 1.12.1, yarn.lock) |
| **Template** | `companion-module-template-ts-v1` @ `42609d8` (2026-03-03, pinned) · `.yarnrc.yml` from `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`952dcf1`](https://github.com/bitfocus/companion-module-projetech-studio/tree/952dcf175a255cd8d563a0df1006745b94aaaebc) |
| **Review date** | 2026-10-30 |

This is the module's first release in the developer portal, so there is no previous published tag to diff against. The whole module was reviewed. The repo has earlier git tags (v1.5.0 back to v1.2.0), but none of them was ever published, so every finding is classified 🆕 NEW. `yarn install --immutable`, `yarn package` and `yarn lint` all pass.

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion lets a user save the connection settings with the "IP do Projetech Studio" field empty, even though the field has `regex: Regex.IP`. If the editor refuses to save a value that fails the regex, an empty IP can only arrive through an imported or hand-edited config | How Companion's connection editor validates config fields; not visible in the module or in `@companion-module/base` | [M1](#m1-clearing-the-ip-field-shows-bad-config-but-the-old-connection-keeps-running) |

## 📋 Issues

### Blocking

- [ ] [C1: Line endings are not pinned: `.gitattributes` is missing](#c1-line-endings-are-not-pinned-gitattributes-is-missing)
- [ ] [C2: No pre-commit hook: `.husky/pre-commit` is missing](#c2-no-pre-commit-hook-huskypre-commit-is-missing)
- [ ] [C3: `.prettierignore` lists `/LICENSE` where the template lists `/LICENSE.md`](#c3-prettierignore-lists-license-where-the-template-lists-licensemd)
- [ ] [C4: The pre-commit hook is never installed: the `postinstall` script is missing](#c4-the-pre-commit-hook-is-never-installed-the-postinstall-script-is-missing)
- [ ] [C5: `husky` is missing from devDependencies](#c5-husky-is-missing-from-devdependencies)
- [ ] [C6: `lint-staged` is missing from devDependencies](#c6-lint-staged-is-missing-from-devdependencies)
- [ ] [C7: The `lint-staged` section is missing from `package.json`](#c7-the-lint-staged-section-is-missing-from-packagejson)

### Non-blocking

- [ ] [M1: Clearing the IP field shows Bad config but the old connection keeps running](#m1-clearing-the-ip-field-shows-bad-config-but-the-old-connection-keeps-running)
- [ ] [M2: The bug report issue form is missing](#m2-the-bug-report-issue-form-is-missing)
- [ ] [M3: The issue chooser config is missing](#m3-the-issue-chooser-config-is-missing)
- [ ] [M4: The feature request issue form is missing](#m4-the-feature-request-issue-form-is-missing)
- [ ] [M5: The `node.yaml` CI workflow is missing](#m5-the-nodeyaml-ci-workflow-is-missing)
- [ ] [L1: Input-only actions accept 0 as the input number, which does nothing](#l1-input-only-actions-accept-0-as-the-input-number-which-does-nothing)
- [ ] [L2: No upgrades file, so future renames have nowhere to go](#l2-no-upgrades-file-so-future-renames-have-nowhere-to-go)
- [ ] [N1: Timer and free-function text fields do not accept variables, and Tempo shows for every command](#n1-timer-and-free-function-text-fields-do-not-accept-variables-and-tempo-shows-for-every-command)
- [ ] [NR1: Move to `@companion-module/base` 1.14 for auto-parsed variables and the newer config layout](#nr1-move-to-companion-modulebase-114-for-auto-parsed-variables-and-the-newer-config-layout)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Line endings are not pinned: `.gitattributes` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes` (missing)

**What goes wrong:** Without the template's `.gitattributes`, a contributor on Windows can commit files with CRLF line endings, which then show up as whole-file diffs and lint/prettier failures for everyone else.

**Why it happens:** The template ships a `.gitattributes` that tells git to store every text file with LF endings. The module repo doesn't have the file.

**Expected (template):**

```text
* text=auto eol=lf
```

**Fix:** add `.gitattributes` at the repo root with the template's content above.

### C2: No pre-commit hook: `.husky/pre-commit` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Commits are never formatted or linted before they land, so formatting drift and lint errors reach the repo and are only caught later.

**Why it happens:** The template runs `lint-staged` from a husky pre-commit hook. The module has no `.husky/pre-commit` file. This finding goes together with [C4](#c4-the-pre-commit-hook-is-never-installed-the-postinstall-script-is-missing), [C5](#c5-husky-is-missing-from-devdependencies), [C6](#c6-lint-staged-is-missing-from-devdependencies) and [C7](#c7-the-lint-staged-section-is-missing-from-packagejson).

**Expected (template):**

```text
lint-staged
```

**Fix:** add `.husky/pre-commit` containing the single line `lint-staged`, as in the template.

### C3: `.prettierignore` lists `/LICENSE` where the template lists `/LICENSE.md`

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.prettierignore:2`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/.prettierignore#L2)

**What goes wrong:** The module's `.prettierignore` no longer matches the template, which makes later troubleshooting against the template harder.

**Why it happens:** Line 2 was changed from the template's `/LICENSE.md` to `/LICENSE`. The extra `/pkg` line (build output) is fine on its own.

**Expected vs found:**

```diff
 package.json
-/LICENSE.md
+/LICENSE
+/pkg
```

**Fix:** restore the template's `/LICENSE.md` line. Keeping `/pkg` is fine.

### C4: The pre-commit hook is never installed: the `postinstall` script is missing

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/package.json)

**What goes wrong:** Even with a `.husky/pre-commit` file in place, a fresh clone never activates the hook, so commits skip formatting and linting.

**Why it happens:** The template's `"postinstall": "husky"` script is what registers the git hooks on `yarn install`. The module's `scripts` block doesn't have it.

**Fix:** add the script to `package.json`.

```json
"postinstall": "husky",
```

### C5: `husky` is missing from devDependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/package.json)

**What goes wrong:** The `postinstall` script from [C4](#c4-the-pre-commit-hook-is-never-installed-the-postinstall-script-is-missing) has nothing to run, so the pre-commit hook can't be installed.

**Why it happens:** The template lists `husky` (`^9.1.7`) in `devDependencies`; the module doesn't.

**Fix:** `yarn add -D husky` and commit the updated `package.json` and `yarn.lock`.

### C6: `lint-staged` is missing from devDependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/package.json)

**What goes wrong:** The pre-commit hook runs `lint-staged`, which isn't installed, so the hook would fail on every commit.

**Why it happens:** The template lists `lint-staged` (`^16.2.7`) in `devDependencies`; the module doesn't.

**Fix:** `yarn add -D lint-staged` and commit the updated `package.json` and `yarn.lock`.

### C7: The `lint-staged` section is missing from `package.json`

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/package.json)

**What goes wrong:** Even with `lint-staged` installed, it has no rules, so staged files are neither formatted nor linted.

**Why it happens:** The template's `package.json` has a `lint-staged` block that tells it what to run on each staged file type. The module's `package.json` has none.

**Fix:** add the template's block to `package.json`.

```json
"lint-staged": {
	"*.{css,json,md,scss}": [
		"prettier --write"
	],
	"*.{ts,tsx,js,jsx}": [
		"yarn lint:raw --fix"
	]
},
```

## 🟡 Medium

### M1: Clearing the IP field shows Bad config but the old connection keeps running

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:40-43`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/main.ts#L40-L43), [`src/main.ts:65-72`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/main.ts#L65-L72)

**What goes wrong:** A user connected to Projetech Studio at 192.168.0.20 empties the "IP do Projetech Studio" field and saves, for example to park the connection. Companion shows the connection as Bad config ("Informe o IP do Projetech Studio"), but the module stays connected to 192.168.0.20. Pressing CUT or a Modo ProLume clip button still fires on that machine, tally and variables keep updating, and if the socket drops and reconnects, its status overwrites the Bad config status. This only happens if an empty IP can be saved (see [A1](#-assumptions-to-confirm)); an imported config can still carry one.

**Why it happens:** Saving the settings calls `configUpdated()`, which calls `reconnect()`. When the host is empty, `reconnect()` sets Bad config and returns. The only place that closes the previous socket and stops the poll and clock timers is `this.api.connect()` (it calls `disconnect()` first), and that call is skipped on this path. The old socket and both timers stay alive until the connection is destroyed.

**Evidence:**

```ts
// src/main.ts:65-72
private reconnect(): void {
	if (!this.config.host) {
		this.updateStatus(InstanceStatus.BadConfig, 'Informe o IP do Projetech Studio')
		return
	}
	this.updateStatus(InstanceStatus.Connecting)
	this.api.connect(this.config.host, this.config.port || 8099, this.config.pollInterval || 500)
}
```

**Confirm by:** open [`src/main.ts:65-72`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/main.ts#L65-L72): the empty-host branch returns without calling `this.api.disconnect()`. [`src/api.ts:311-312`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/api.ts#L311-L312) shows `disconnect()` only runs from inside `connect()`.

**Fix:** stop the previous connection before returning from the Bad config branch. Clearing the cached state as well keeps tally, variables and feedbacks from showing the old machine's state.

```ts
if (!this.config.host) {
	this.api.disconnect()
	this.updateStatus(InstanceStatus.BadConfig, 'Informe o IP do Projetech Studio')
	return
}
```

### M2: The bug report issue form is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/bug_report.yml` (missing)

**What goes wrong:** Users opening a GitHub issue get a blank form instead of the template's bug report form, so reports arrive without the Companion version, module version and steps to reproduce.

**Fix:** copy `.github/ISSUE_TEMPLATE/bug_report.yml` from the template.

### M3: The issue chooser config is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/config.yml` (missing)

**What goes wrong:** The GitHub "New issue" page doesn't show the template's issue chooser settings and links.

**Fix:** copy `.github/ISSUE_TEMPLATE/config.yml` from the template.

### M4: The feature request issue form is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/ISSUE_TEMPLATE/feature_request.yml` (missing)

**What goes wrong:** Feature requests arrive as free text instead of through the template's structured form.

**Fix:** copy `.github/ISSUE_TEMPLATE/feature_request.yml` from the template.

### M5: The `node.yaml` CI workflow is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml` (missing)

**What goes wrong:** Pushes and pull requests are never built or linted on GitHub, so a broken build is only discovered at release time. The repo has `.github/workflows/companion-module-checks.yaml`, but not the template's `node.yaml`.

**Fix:** copy `.github/workflows/node.yaml` from the template.

## 🟢 Low

### L1: Input-only actions accept 0 as the input number, which does nothing

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:97-104`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/actions.ts#L97-L104), [`src/actions.ts:159-168`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/actions.ts#L159-L168), [`src/actions.ts:216-265`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/actions.ts#L216-L265)

**What goes wrong:** In "Preview: carregar input", "Take (input direto no ar, transição padrão)", "Overlay (sobre o PGM)", "Áudio do input para o PGM" and "Volume do input", the "Input" field accepts 0, with no "0 = preview" hint. A button set to 0 sends `FUNCTION PreviewInput Input=0` (and so on), and nothing happens on the switcher.

**Why it happens:** All these actions reuse the shared `inputOption()` helper, which sets `min: 0` because 0 means "the input on preview / the program" for Cut, Fade and the playback actions. These actions only pass a new label, so `min: 0` stays, and their callbacks always send the number.

**Fix:** give `inputOption()` a `min` parameter (or add a second helper with `min: 1`) and use `min: 1` for previewInput, take, overlay, audio and setVolume.

### L2: No upgrades file, so future renames have nowhere to go

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:75`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/main.ts#L75)

**What goes wrong:** Nothing visible today. The module's own comments say action and option ids are stored in buttons and must never be renamed ([`src/actions.ts:390`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/actions.ts#L390), [`src/feedbacks.ts:141`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/feedbacks.ts#L141)). When one does have to change, there is no `upgrades.ts` to hold the script that keeps existing buttons working, and the layout no longer matches the v1 TS template.

**Why it happens:** `runEntrypoint(StudioInstance, [])` passes an inline empty list, where the template imports `UpgradeScripts` from `src/upgrades.ts`.

**Fix:** add `src/upgrades.ts` exporting an empty list and pass it to `runEntrypoint`.

```ts
// src/upgrades.ts
import type { CompanionStaticUpgradeScript } from '@companion-module/base'
import type { StudioConfig } from './config.js'

export const UpgradeScripts: CompanionStaticUpgradeScript<StudioConfig>[] = []
```

## 💡 Nice to Have

### N1: Timer and free-function text fields do not accept variables, and Tempo shows for every command

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:356-378`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/actions.ts#L356-L378), [`src/actions.ts:549-561`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/src/actions.ts#L549-L561)

**What goes wrong:** In the "Timer" action, the "Tempo (hh:mm:ss, só para "Definir")" field shows even when "Comando" is Iniciar, Pausar or Zerar, and it doesn't take variables, so the countdown can't be set from a custom variable. In "Função livre (FUNCTION da API)", a variable typed into "Função" or "Parâmetros" (for example `Input=$(projetech-studio:preview_number)`) is sent literally.

**Why it happens:** These text fields don't set `useVariables`, their callbacks don't parse variables, and the Tempo field has no `isVisibleExpression`. Base 1.12.1 supports both.

**Fix:** add `useVariables: true` to the three fields and parse them in the callback with the module's existing `optionText()` helper. Add `isVisibleExpression: "$(options:cmd) == 'SetCountdown'"` to the Tempo field.

## 🔮 Next Release

### NR1: Move to `@companion-module/base` 1.14 for auto-parsed variables and the newer config layout

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-projetech-studio/blob/952dcf175a255cd8d563a0df1006745b94aaaebc/package.json)

**What goes wrong:** Nothing is broken today. The module pins `@companion-module/base` `~1.12.1` (Companion 4.0+), so it can't use the 1.13 features (text fields with `useVariables` arriving already parsed, value feedbacks, option `description` hints) or the 1.14 automated config layout. The v1 template itself is on `~1.14.1`.

**Fix:** in a later release, bump to `~1.14.x`; the `parseVariablesInString` call inside `optionText()` can then be dropped for fields that don't need local variables. Alternatively, plan the move to API v2.

## 📝 Additional Notes

- `tsconfig.build.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json` where the template has `@companion-module/tools/tsconfig/node22/recommended`. The module builds and lints fine, so no change is required.
