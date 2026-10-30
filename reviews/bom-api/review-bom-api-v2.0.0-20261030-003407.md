# Review: companion-module-bom-api v2.0.0

| | |
| --- | --- |
| **Module** | [companion-module-bom-api](https://github.com/bitfocus/companion-module-bom-api) |
| **Scope** | `tag` (changes since v1.0.1) |
| **Version** | v2.0.0 |
| **Release** | Update — last published v1.0.1 |
| **API** | 2.2 (base 2.2.1, yarn.lock) — requires Companion 5.1+ (per base README, marked "unconfirmed") |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Review commit** | [`7c83cc8`](https://github.com/bitfocus/companion-module-bom-api/tree/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc) |
| **Build** | `yarn install --immutable`, `yarn package` and `yarn lint` pass |
| **Reviewed** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | Companion aborts an action's `context.signal` while the action is still running, for example when the user aborts the running actions on a button, so the partial-update path in the Select Location action is reachable in normal use | `@companion-module/base` 2.2.1 `action.d.ts`: "A signal that aborts when the result of this execution is no longer needed (eg the user aborted the running actions)"; Companion's host code not checked | [L1](#l1-aborting-a-running-select-location-action-logs-misleading-request-failed-warnings), [L2](#l2-aborting-select-location-mid-update-leaves-variables-mixing-the-new-and-old-location-until-the-next-poll) |
| A2 | In expression mode, Companion may pass a text input option to the callback as a non-string value instead of skipping the action. The base typings say invalid values cause the action to be skipped unless `allowInvalidValues` is set, so Companion may block this case before the callback runs | `@companion-module/base` 2.2.1 `input.d.ts` notes on expression mode and `allowInvalidValues`; Companion's host behaviour not checked | [N1](#n1-get-data-fails-with-an-unclear-error-if-the-geohash-option-evaluates-to-a-non-string) |

## 📋 Issues

### Blocking

- [ ] [C1: Required `.gitattributes` file is missing](#c1-required-gitattributes-file-is-missing)
- [ ] [C2: `.gitignore` is missing the template's `/*.tgz` and `/.vscode` entries](#c2-gitignore-is-missing-the-templates-tgz-and-vscode-entries)
- [ ] [C3: ESLint config adds a `typescript-eslint` import the template does not have](#c3-eslint-config-adds-a-typescript-eslint-import-the-template-does-not-have)
- [ ] [C4: Maintainer email is empty in the manifest](#c4-maintainer-email-is-empty-in-the-manifest)

### Non-blocking

- [ ] [M1: Release workflow builds its own package instead of using the shared Bitfocus module workflow](#m1-release-workflow-builds-its-own-package-instead-of-using-the-shared-bitfocus-module-workflow)
- [ ] [M2: Node CI workflow differs from the template](#m2-node-ci-workflow-differs-from-the-template)
- [ ] [M3: Module checks workflow drops the template-repo guard](#m3-module-checks-workflow-drops-the-template-repo-guard)
- [ ] [L1: Aborting a running Select Location action logs misleading request failed warnings](#l1-aborting-a-running-select-location-action-logs-misleading-request-failed-warnings)
- [ ] [L2: Aborting Select Location mid-update leaves variables mixing the new and old location until the next poll](#l2-aborting-select-location-mid-update-leaves-variables-mixing-the-new-and-old-location-until-the-next-poll)
- [ ] [N1: Get Data fails with an unclear error if the Geohash option evaluates to a non-string](#n1-get-data-fails-with-an-unclear-error-if-the-geohash-option-evaluates-to-a-non-string)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: Required `.gitattributes` file is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (this release moves the module onto the API 2.x template, which tracks this file)
- **File:** `.gitattributes`

**What goes wrong:** The repository has no `.gitattributes`, so line endings are not normalised. A contributor on Windows can commit CRLF files, which then show up as whole-file diffs and can trip the formatter in CI.

**Why it happens:** The template ships a `.gitattributes` with `* text=auto eol=lf`; the module never added it.

**Evidence:** the validator reports `.gitattributes`: Required file is missing (tracked by the template).

**Confirm by:** the file is absent from the repository root at the review commit.

**Fix:** add `.gitattributes` from the template.

```text
* text=auto eol=lf
```

### C2: `.gitignore` is missing the template's `/*.tgz` and `/.vscode` entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (this release moves the module onto the API 2.x template)
- **File:** [`.gitignore:1-9`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/.gitignore#L1-L9)

**What goes wrong:** Packages built with `yarn package` and local VS Code settings can be committed by accident. The module only ignores `bom-api-*.tgz`, so any other package name at the root is not ignored.

**Why it happens:** The `.gitignore` lacks two entries the template has.

**Evidence:** the validator reports missing template `.gitignore` entries: `/*.tgz`, `/.vscode`.

**Confirm by:** open [`.gitignore`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/.gitignore#L1-L9); neither entry is present.

**Fix:** add the two template entries (the module's own extra entries such as `/coverage` can stay).

```text
/*.tgz
/.vscode
```

### C3: ESLint config adds a `typescript-eslint` import the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`eslint.config.mjs:2`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/eslint.config.mjs#L2), [`eslint.config.mjs:10-14`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/eslint.config.mjs#L10-L14)

**What goes wrong:** The ESLint setup no longer matches the template, so it depends on a package the template doesn't use. A later change to the shared `@companion-module/tools` config can break linting in ways that are hard to trace back to this file.

**Why it happens:** The file keeps the template's `baseConfig` spread and adds a test-scoped override, which is an accepted change. But it also imports `typescript-eslint` to apply `tseslint.configs.disableTypeChecked` to `vitest.config.ts`, because `tsconfig.json` only includes `src/**/*.ts`. That extra import takes it outside the accepted form.

**Evidence:** validator line 2: found `import tseslint from 'typescript-eslint'`, template has no such line.

```js
// eslint.config.mjs:2
import tseslint from 'typescript-eslint'
// eslint.config.mjs:10-14
	{
		// Not covered by tsconfig.json (which only includes src/**/*.ts), so parse it without type info
		files: ['vitest.config.ts'],
		...tseslint.configs.disableTypeChecked,
	},
```

**Confirm by:** open [`eslint.config.mjs:1-22`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/eslint.config.mjs#L1-L22).

**Fix:** drop the import and the `disableTypeChecked` block, and add `vitest.config.ts` to the `include` of `tsconfig.json` instead (widening `tsconfig.json` for test files is an accepted change). Keep the `n/no-unpublished-import` override.

```json
"include": ["src/**/*.ts", "vitest.config.ts"]
```

### C4: Maintainer email is empty in the manifest

- **Source:** 🤖 validate-template (MAN-PLACEHOLDER)
- **Classification:** 🆕 NEW (this release moves the module onto the API 2.x template)
- **File:** [`companion/manifest.json:12-17`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/companion/manifest.json#L12-L17)

**What goes wrong:** Users and the Bitfocus team have no way to contact the maintainer from the module's listing.

**Why it happens:** The maintainer entry has a name but `"email": ""`.

**Evidence:** placeholder maintainer: name='Phillip Ivan Pietruschka' email=''.

**Confirm by:** open [`companion/manifest.json:12-17`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/companion/manifest.json#L12-L17).

**Fix:** fill in the maintainer's email address.

## 🟡 Medium

### M1: Release workflow builds its own package instead of using the shared Bitfocus module workflow

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/release.yaml:10-65`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/.github/workflows/release.yaml#L10-L65)

**What goes wrong:** The package attached to a GitHub release is built differently from the one the template's release workflow produces: it is a `--dev` (unminified) build, and the asset is uploaded as `./*.tgz` without the template's `bom-api-<version>.tgz` naming. Anyone troubleshooting a release asset has to know that this module doesn't follow the standard flow.

**Why it happens:** The workflow is fully rewritten. It no longer calls the shared `bitfocus/actions/.github/workflows/module-checks.yaml@main` job; it runs `yarn package --dev [--prerelease]` itself and uploads the result with `gh release upload`.

**Fix:** use the template's `release.yaml` unchanged, so the release asset comes from the shared Bitfocus workflow.

### M2: Node CI workflow differs from the template

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/node.yaml`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/.github/workflows/node.yaml)

**What goes wrong:** CI runs differently from other modules built from the same template, which makes CI failures harder to compare.

**Why it happens:** The file adds `permissions: contents: read`, uses `actions/setup-node@v7` instead of v6, drops `persist-credentials: false` and the template-only step, and enables the test job with `yarn test:coverage` plus a Codecov upload. The CI Node version (26.x) matches the `node26` runtime.

**Fix:** start from the template's `node.yaml` and keep only the test job as the module's addition; restore `persist-credentials: false`.

### M3: Module checks workflow drops the template-repo guard

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.github/workflows/companion-module-checks.yaml:10`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/.github/workflows/companion-module-checks.yaml#L10)

**What goes wrong:** Nothing visible; the workflow behaves the same in this repository. It just no longer matches the template.

**Why it happens:** The template's `if: ${{ !contains(github.repository, 'companion-module-template-') }}` line was removed. That guard only matters in the template repository itself, so the change is harmless.

**Fix:** restore the template's `if:` line so the file matches the template.

## 🟢 Low

### L1: Aborting a running Select Location action logs misleading request failed warnings

- **Source:** 🔎 protocol reviewer, QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:238-246`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/src/main.ts#L238-L246), [`src/main.ts:103-152`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/src/main.ts#L103-L152)

**What goes wrong:** A user presses a button with the Select Location action (for example switching to "Adelaide (SA:5000)") and then aborts the running actions before the five BOM requests finish. The connection log then shows warnings such as `Hourly Forecast request failed: {"name":"ZodError","issues":[...]}` or `Daily Forecast request failed: {}`. They look like API or parsing failures, but nothing failed: the request was cancelled. Polling, variables and the connection status still behave correctly, so the only effect is a log line that can mislead someone troubleshooting.

**Why it happens:** v2.0.0 passes the action's abort signal down to the requests. When a request is cancelled, `queryApi()` swallows the cancel and returns `undefined`; `pollQuery()` then parses `undefined` against the response schema, which throws a validation error that the `get*` methods log as a warning. A request that the queue drops because of the signal rejects with an `AbortError`, which `JSON.stringify` turns into `{}`.

**Fix:** in `pollQuery()`, stop before parsing when there is no response, and skip the warning in the `get*` catch blocks when the signal has aborted. For other errors, log `e.message` rather than `JSON.stringify(e)`.

```ts
const response = await this.queryApi(path(geohash), undefined, signal)
if (!response) {
	throw new Error(signal?.aborted ? `${QUERIES[type].label} request cancelled` : `${QUERIES[type].label} request failed`)
}
```

### L2: Aborting Select Location mid-update leaves variables mixing the new and old location until the next poll

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/main.ts:181-199`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/src/main.ts#L181-L199)

**What goes wrong:** A user showing Adelaide presses a button with Select Location set to "Sydney (NSW:2000)", and the button's actions are aborted while it runs. The update stops after one or two requests but still publishes the variables, so `$(bom-api:fc_day_0_temp_max)` shows Sydney's forecast while `$(bom-api:obs_temp)` and `$(bom-api:locInfo_name)` still show Adelaide. Nothing marks the data as mixed, and it stays that way until the next poll (5 minutes by default).

**Why it happens:** `updateData()` leaves its request loop when the signal aborts, then still publishes the variables and schedules the next poll for the new location. Only the requests that already finished have updated the module's state. The doc comment says publishing partial data is intended, but the result is a set of variables that disagree with each other.

**Fix:** when the signal has aborted, skip publishing and schedule an immediate full poll for the new location instead.

```ts
if (signal?.aborted) {
	this.pollTimer = setTimeout(() => this.updateData(geohash).catch(() => {}), 0)
	return
}
```

## 💡 Nice to Have

### N1: Get Data fails with an unclear error if the Geohash option evaluates to a non-string

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:59-64`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/src/api.ts#L59-L64), [`src/actions.ts:73`](https://github.com/bitfocus/companion-module-bom-api/blob/7c83cc861c4be1ad8c4dbb3ddc6e4d0a640f99bc/src/actions.ts#L73)

**What goes wrong:** A user switches the Geohash option of Get Data to expression mode, and the expression returns a number (for example a variable holding an all-digit geohash such as `123456`). The action can then fail with `input.trim is not a function` instead of a clear validation message.

**Why it happens:** `parseGeohash()` calls `input.trim()` without checking the value's type, and an expression can produce a value that is not a string.

**Fix:** convert the value to a string before parsing it.

```ts
const geohash = parseGeohash(String(action.options.geohash ?? '')) ?? self.location.geohash
```

## 📝 Additional Notes

- `tsconfig.build.json` drops the template's `"verbatimModuleSyntax": true` from `compilerOptions`. Fine as long as the module builds; no change required.
- The API compliance check covered the v2.0 and v2.1 references only: the review skill has no v2.2 reference yet, so nothing specific to API 2.2 was checked.
