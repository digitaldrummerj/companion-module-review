# Review: pltech-kumatimer v2.1.0

| | |
|---|---|
| **Module** | pltech-kumatimer |
| **Review tag** | v2.1.0 |
| **Previous tag** | v1.8.0 |
| **Scope** | `tag` (only the `v1.8.0..v2.1.0` diff) |
| **Language / API** | TypeScript · @companion-module/base ^2.0.4 (v2) |
| **Protocol** | HTTP |
| **Reviewed** | 2026-06-14 |

This release is a v1→v2 API migration (the migration itself — class-based `export default` + `export { UpgradeScripts }`, no `runEntrypoint`, object-form `setVariableDefinitions`, two-arg `setPresetDefinitions(structure, presets)`, `type: 'simple'` presets, `checkAllFeedbacks()`, `manifest.type: "connection"`, `runtime.type: "node22"`, `apiVersion 2.0.4` — is done correctly) plus a new shared-password auth field and auto-updating preset/cue button text. All findings below are new in this release.

## 📊 Scorecard

| Severity | 🆕 New | ⚠️ Existing | Total |
|----------|--------|-------------|-------|
| 🔴 Critical | 12 | 0 | 12 |
| 🟠 High | 2 | 0 | 2 |
| 🟡 Medium | 0 | 0 | 0 |
| 🟢 Low | 0 | 0 | 0 |
| 🟡 Findings to Review | 2 | 0 | 2 |

| **Total** | **16** | **0** | **16** |

## Verdict: ❌ Changes Required

## 📋 Issues

**Blocking**

- [ ] [C1: tsconfig.build.json missing](#c1-tsconfigbuildjson-missing)
- [ ] [C2: tsconfig.json does not extend tsconfig.build.json](#c2-tsconfigjson-does-not-extend-tsconfigbuildjson)
- [ ] [C3: .gitignore missing template entries](#c3-gitignore-missing-template-entries)
- [ ] [C4: .prettierignore differs from template](#c4-prettierignore-differs-from-template)
- [ ] [C7: package.json missing license field](#c7-packagejson-missing-license-field)
- [ ] [C8: package.json missing postinstall script](#c8-packagejson-missing-postinstall-script)
- [ ] [C9: package.json missing build:main script](#c9-packagejson-missing-build-main-script)
- [ ] [C10: package.json missing lint:raw script](#c10-packagejson-missing-lint-raw-script)
- [ ] [C11: husky devDependency missing](#c11-husky-devdependency-missing)
- [ ] [C12: lint-staged devDependency missing](#c12-lint-staged-devdependency-missing)
- [ ] [C13: rimraf devDependency missing](#c13-rimraf-devdependency-missing)
- [ ] [C14: lint-staged section missing from package.json](#c14-lint-staged-section-missing-from-packagejson)
- [ ] [H1: password typed as required but no upgrade script backfills it](#h1-password-typed-as-required-but-no-upgrade-script-backfills-it)
- [ ] [H2: yarn lint fails with 2 errors](#h2-yarn-lint-fails-with-2-errors)

**Non-blocking**

- [ ] [M1: Cue presets beyond slot 12 reference undefined variables](#m1-cue-presets-beyond-slot-12-reference-undefined-variables)
- [ ] [M2: sendCommand non-OK response does not surface connection status](#m2-sendcommand-non-ok-response-does-not-surface-connection-status)

---

## 🔴 Critical

The 15 Critical items below are deterministic template/packaging checks against the official `companion-module-template-ts`. A release that breaks the build/lint chain or the template contract can't ship regardless of scope.

### C1: tsconfig.build.json missing

`tsconfig.build.json` — **FILE-MISSING**. The TS template ships a `tsconfig.build.json` (the actual build config that `tsconfig.json` extends). It is absent here.
**Fix:** add `tsconfig.build.json` from the current template and have `tsconfig.json` extend it (see C2).

### C2: tsconfig.json does not extend tsconfig.build.json

`tsconfig.json` — **CONFIG-DIFF**. Line 2 is `"compilerOptions": {`; the template expects `"extends": "./tsconfig.build.json",`. The module inlines compiler options instead of extending the shared build config.
**Fix:** restore the template `tsconfig.json` that extends `./tsconfig.build.json`.

### C3: .gitignore missing template entries

`.gitignore` — **CONFIG-DIFF**. Missing template entries: `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`.
**Fix:** add the missing entries so build artifacts and stray lockfiles aren't committed.

### C4: .prettierignore differs from template

`.prettierignore` — **CONFIG-DIFF**. Line 2 is `yarn.lock`; template has `/LICENSE.md`.
**Fix:** align `.prettierignore` with the template.

### C7: package.json missing license field

`package.json` — **PKG-FIELD**. Required field `license` (present in template) is missing.
**Fix:** add `"license": "MIT"` (or the module's actual license) matching the `LICENSE` file.

### C8: package.json missing postinstall script

`package.json` — **PKG-SCRIPT**. Required script `postinstall` is missing (the template uses it to wire husky).
**Fix:** add the template `postinstall` script (`husky` setup).

### C9: package.json missing build main script

`package.json` — **PKG-SCRIPT**. Required script `build:main` is missing.
**Fix:** add the template `build:main` script.

### C10: package.json missing lint raw script

`package.json` — **PKG-SCRIPT**. Required script `lint:raw` is missing.
**Fix:** add the template `lint:raw` script.

### C11: husky devDependency missing

`package.json` — **PKG-DEVDEP**. `husky` (present in template) is missing.
**Fix:** add `husky` to devDependencies and restore the prepare/postinstall wiring.

### C12: lint-staged devDependency missing

`package.json` — **PKG-DEVDEP**. `lint-staged` (present in template) is missing.
**Fix:** add `lint-staged` to devDependencies.

### C13: rimraf devDependency missing

`package.json` — **PKG-DEVDEP**. `rimraf` (present in template) is missing.
**Fix:** add `rimraf` to devDependencies (used by the template build/clean scripts).

### C14: lint-staged section missing from package.json

`package.json` — **PKG-LINTSTAGED**. The `lint-staged` section is missing.
**Fix:** add the template `lint-staged` configuration block.

## 🟠 High

### H1: password typed as required but no upgrade script backfills it

`src/types.ts:13` declares `password: string` (non-optional) while `UpgradeScripts` is still `[]` (`src/upgrades.ts`). Existing v1 saved configs have no `password` key, so `this.config.password` is `undefined` at runtime — safe in practice because every read guards with `(this.config.password || '').trim()`, but the declared type misrepresents persisted data.
**Fix (optional):** add a trivial upgrade script defaulting `password: ''` (and any other newly-required fields) so the declared shape matches reality, or mark the field optional.

### H2: yarn lint fails with 2 errors

`yarn lint` exits non-zero — **LINT**. Two errors:

- `src/actions.ts:266` — `@typescript-eslint/no-base-to-string`: `action.options['cue'] ?? ''` will stringify to `'[object Object]'` for non-string values. In practice the `cue` option is a `textinput` (always a string or undefined), so no runtime bug materializes, but the lint gate is red.
- `src/presets.ts:362` — `prettier/prettier`: formatting / trailing-comma mismatch.
**Fix:** narrow the `cue` value before stringifying (e.g. `typeof v === 'string' ? v : ''`) rather than blanket-coercing, and run `yarn lint --fix` (or prettier) to resolve the formatting error. Lint must pass clean.

## 🟡 Findings for You to Review and Decide if they make sense to include

Below are findings that the AI generated that may or may not be valid based on your expertise with the module.

### M1: Cue presets beyond slot 12 reference undefined variables

`src/presets.ts:204` together with `src/variables.ts:10` (`CUE_SLOTS = 12`). The cue-preset loop runs over the full `cues` array with no cap, emitting `cue_${i+1}_name` for every cue, but `setupVariables`/`updateVariables`/`clearVariables` only define `cue_1..cue_12`. On a show with more than 12 cues, cue 13+ buttons reference a variable that is never defined and render blank — even after H1 is fixed. (The preset side is safe: exactly 6 presets, `PRESET_SLOTS = 6`.)
**Fix:** cap the cue-preset loop at `CUE_SLOTS`, or raise/parametrize `CUE_SLOTS` to cover the host's max cue count; keep the loop bound and the defined-variable count in sync.

### M2: sendCommand non-OK response does not surface connection status

`src/main.ts:131-133`. With the new `password` field, a wrong/missing password makes the host return `401 auth_required`. That non-OK branch only calls `log.warn(...)` and returns — `InstanceStatus` stays `Ok` from the last successful poll, so the operator gets no UI indication that every command is being silently rejected. (The fully-failed-fetch path at `:136-137` does correctly set `ConnectionFailure`.)
**Fix:** on `!res.ok` (especially 401/403) call `this.updateStatus(InstanceStatus.ConnectionFailure, ...)` (or a more specific status) so the auth failure is visible.
