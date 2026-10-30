# Review: companion-module-globalaudiosolutions-rita v1.0.4

| | |
| --- | --- |
| **Module** | [companion-module-globalaudiosolutions-rita](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita) |
| **Scope** | `tag` (first release: no previous tag, so the whole module was reviewed) |
| **Version** | v1.0.4 |
| **Release** | New module — never published |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Commit** | [`5fadbfd`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/tree/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc) |
| **Review date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | When `init()` or `configUpdated()` rejects, Companion 5 logs the error and leaves the module's last reported status (Connecting) in place. It does not restart the module or show its own error status | The `ws` throw was reproduced locally; Companion's host init wrapper (outside `@companion-module/base` in API 2.x) was not read | [M3](#m3-an-ip-address-with-a-stray-space-or-a-port-leaves-the-connection-stuck-on-connecting) |
| A2 | In an action group set to run its actions one after another, Companion waits for each action's returned promise before it starts the next, and Companion's abort only reaches a callback through `context.signal` | The base 2.1.3 callback type (`Promise<void> \| void`) and the API 2.1 abort-signal design; the host's sequencing code was not read | [M4](#m4-actions-report-done-at-once-and-cannot-be-aborted-so-later-steps-in-a-sequence-do-not-wait) |
| A3 | Companion shows the manifest `name` field to users, for example in the module list | General knowledge of Companion's module list; not checked in the host source | [L6](#l6-the-modules-display-name-is-its-id) |

## 📋 Issues

### Blocking

- [ ] [C1: Missing `.gitattributes` file](#c1-missing-gitattributes-file)
- [ ] [C2: `.gitignore` is missing template entries](#c2-gitignore-is-missing-template-entries)
- [ ] [C3: Missing `.husky/pre-commit` file](#c3-missing-huskypre-commit-file)
- [ ] [C4: Missing `.prettierignore` file](#c4-missing-prettierignore-file)
- [ ] [C5: Missing `eslint.config.mjs` file](#c5-missing-eslintconfigmjs-file)
- [ ] [C6: Missing `tsconfig.build.json` file](#c6-missing-tsconfigbuildjson-file)
- [ ] [C7: `package.json` has no `prettier` field](#c7-packagejson-has-no-prettier-field)
- [ ] [C8: `package.json` has no `postinstall` script](#c8-packagejson-has-no-postinstall-script)
- [ ] [C9: `package.json` has no `format` script](#c9-packagejson-has-no-format-script)
- [ ] [C10: `package.json` has no `build:main` script](#c10-packagejson-has-no-buildmain-script)
- [ ] [C11: `package.json` has no `lint:raw` script](#c11-packagejson-has-no-lintraw-script)
- [ ] [C12: `package.json` has no `lint` script](#c12-packagejson-has-no-lint-script)
- [ ] [C13: `package.json` is missing the `eslint` devDependency](#c13-packagejson-is-missing-the-eslint-devdependency)
- [ ] [C14: `package.json` is missing the `husky` devDependency](#c14-packagejson-is-missing-the-husky-devdependency)
- [ ] [C15: `package.json` is missing the `lint-staged` devDependency](#c15-packagejson-is-missing-the-lint-staged-devdependency)
- [ ] [C16: `package.json` is missing the `prettier` devDependency](#c16-packagejson-is-missing-the-prettier-devdependency)
- [ ] [C17: `package.json` is missing the `typescript-eslint` devDependency](#c17-packagejson-is-missing-the-typescript-eslint-devdependency)
- [ ] [C18: `package.json` has no `lint-staged` section](#c18-packagejson-has-no-lint-staged-section)
- [ ] [C19: Module runs on Node 22 instead of the template's Node 26](#c19-module-runs-on-node-22-instead-of-the-templates-node-26)
- [ ] [H1: `yarn lint` cannot run](#h1-yarn-lint-cannot-run)

### Non-blocking

- [ ] [M1: Missing `.github/workflows/node.yaml`](#m1-missing-githubworkflowsnodeyaml)
- [ ] [M2: Missing `.github/workflows/release.yaml`](#m2-missing-githubworkflowsreleaseyaml)
- [ ] [M3: An IP address with a stray space or a port leaves the connection stuck on Connecting](#m3-an-ip-address-with-a-stray-space-or-a-port-leaves-the-connection-stuck-on-connecting)
- [ ] [M4: Actions report done at once and cannot be aborted, so later steps in a sequence do not wait](#m4-actions-report-done-at-once-and-cannot-be-aborted-so-later-steps-in-a-sequence-do-not-wait)
- [ ] [M5: On, Off and Toggle dropdowns accept expressions that silently skip the action](#m5-on-off-and-toggle-dropdowns-accept-expressions-that-silently-skip-the-action)
- [ ] [L1: Connection shows OK after a reconnect even though RiTA rejected the password](#l1-connection-shows-ok-after-a-reconnect-even-though-rita-rejected-the-password)
- [ ] [L2: Measurement sync all fails when RiTA sends a one-engine list](#l2-measurement-sync-all-fails-when-rita-sends-a-one-engine-list)
- [ ] [L3: Export and find-delay waits keep running after the connection is disabled or its settings are saved](#l3-export-and-find-delay-waits-keep-running-after-the-connection-is-disabled-or-its-settings-are-saved)
- [ ] [L4: A capture's resume timer is not cancelled when settings are saved](#l4-a-captures-resume-timer-is-not-cancelled-when-settings-are-saved)
- [ ] [L5: The RiTA IP address field accepts any text](#l5-the-rita-ip-address-field-accepts-any-text)
- [ ] [L6: The module's display name is its id](#l6-the-modules-display-name-is-its-id)
- [ ] [L7: Action and feedback options are untyped](#l7-action-and-feedback-options-are-untyped)
- [ ] [N1: The No port accepted the connection status hides why the connection failed](#n1-the-no-port-accepted-the-connection-status-hides-why-the-connection-failed)
- [ ] [N2: Sync all recomputes every variable and feedback once per engine](#n2-sync-all-recomputes-every-variable-and-feedback-once-per-engine)
- [ ] [N3: No presets, so users build every RiTA button by hand](#n3-no-presets-so-users-build-every-rita-button-by-hand)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

The module was not started from the current API 2.1 TypeScript template (`companion-module-template-ts`): the repo has no formatting, linting or pre-commit tooling, and several template files are missing. C1–C18 and H1 are all fixed the same way: copy the listed files from the template and merge the template's `package.json` scripts, `prettier` field, `lint-staged` section and devDependencies, then run `yarn install` and `yarn lint`. Matching the template keeps every module's build, lint and release tooling the same, which makes later troubleshooting much easier.

### C1: Missing `.gitattributes` file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.gitattributes`

**What goes wrong:** Without the template's `.gitattributes`, line endings are not normalised, so a commit from Windows can turn every line of a file into a change and confuse diffs and Prettier.

**Why it happens:** The template tracks `.gitattributes`; this repo has none.

**Fix:** copy `.gitattributes` from `companion-module-template-ts`.

### C2: `.gitignore` is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW
- **File:** [`.gitignore`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/.gitignore)

**What goes wrong:** Files the template keeps out of git (an npm `package-lock.json`, `DEBUG-*` logs, `.vscode` settings) can be committed by accident.

**Why it happens:** The module's `.gitignore` is its own list. It has unanchored `dist/`, `pkg/`, `*.tgz` and `.yarn/` where the template has `/dist`, `/pkg`, `/*.tgz` and `/.yarn`, and `package-lock.json`, `DEBUG-*` and `/.vscode` are missing outright.

- **Expected (template):** `node_modules/`, `package-lock.json`, `/pkg`, `/*.tgz`, `/dist`, `DEBUG-*`, `/.yarn`, `/.vscode`
- **Found:** `node_modules/`, `dist/`, `pkg/`, `*.tgz`, `*.log`, `.DS_Store`, `.yarn/`, `.pnp.*`

**Fix:** copy the template's `.gitignore` (extra entries such as `.DS_Store` can stay below the template's lines).

### C3: Missing `.husky/pre-commit` file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.husky/pre-commit`

**What goes wrong:** Commits are not formatted or linted before they land.

**Why it happens:** The template's pre-commit hook runs `lint-staged`; this repo has no `.husky` folder.

**Fix:** copy `.husky/pre-commit` from the template (it is installed by the `postinstall` script, see [C8](#c8-packagejson-has-no-postinstall-script)).

### C4: Missing `.prettierignore` file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.prettierignore`

**What goes wrong:** Once Prettier is added, `yarn format` would also rewrite generated files.

**Why it happens:** The template tracks `.prettierignore`; this repo has none.

**Fix:** copy `.prettierignore` from the template.

### C5: Missing `eslint.config.mjs` file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `eslint.config.mjs`

**What goes wrong:** The module's code is never linted, so mistakes the template's ESLint rules catch (floating promises, unused variables) go unnoticed.

**Why it happens:** The template's `eslint.config.mjs` (built on `@companion-module/tools`' `generateEslintConfig`) is missing.

**Fix:** copy `eslint.config.mjs` from the template.

### C6: Missing `tsconfig.build.json` file

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `tsconfig.build.json`

**What goes wrong:** The build uses a hand-written `tsconfig.json` instead of the template's two-file setup, so the module does not build with the template's Node 26 compiler settings.

**Why it happens:** The template builds with `tsconfig.build.json` (which extends `@companion-module/tools/tsconfig/node26/recommended.json`), and its `tsconfig.json` only extends that file. This repo has only a `tsconfig.json`.

**Fix:** copy `tsconfig.build.json` and `tsconfig.json` from the template (see [C19](#c19-module-runs-on-node-22-instead-of-the-templates-node-26)).

### C7: `package.json` has no `prettier` field

- **Source:** 🤖 validate-template (PKG-FIELD)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json)

**What goes wrong:** Prettier would not use the shared Companion formatting rules.

**Why it happens:** The template's `"prettier": "@companion-module/tools/.prettierrc.json"` field is missing.

**Fix:** add the template's `prettier` field to `package.json`.

### C8: `package.json` has no `postinstall` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L7-L11)

**What goes wrong:** The husky pre-commit hook is never installed.

**Why it happens:** The template's `"postinstall": "husky"` script is missing.

**Fix:** add `"postinstall": "husky"` to `scripts`.

### C9: `package.json` has no `format` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L7-L11)

**What goes wrong:** `yarn format` does not exist, so contributors have no one-command way to format the code.

**Why it happens:** The template's `"format": "prettier -w ."` script is missing.

**Fix:** add `"format": "prettier -w ."` to `scripts`.

### C10: `package.json` has no `build:main` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L7-L11)

**What goes wrong:** The build scripts differ from every other template-based module.

**Why it happens:** The template's `build` runs `rimraf dist && run build:main`, with `"build:main": "tsc -p tsconfig.build.json"`. This module's `build` calls `tsc -p tsconfig.json` directly, and `dev` watches `tsconfig.json` instead of `tsconfig.build.json`.

**Fix:** use the template's `build`, `build:main` and `dev` scripts.

### C11: `package.json` has no `lint:raw` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L7-L11)

**What goes wrong:** `lint-staged` and `yarn lint` have no ESLint entry point to call.

**Why it happens:** The template's `"lint:raw": "eslint"` script is missing.

**Fix:** add `"lint:raw": "eslint"` to `scripts`.

### C12: `package.json` has no `lint` script

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW
- **File:** [`package.json:7-11`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L7-L11)

**What goes wrong:** `yarn lint` fails at once (see [H1](#h1-yarn-lint-cannot-run)).

**Why it happens:** The template's `"lint": "run lint:raw ."` script is missing.

**Fix:** add `"lint": "run lint:raw ."` to `scripts`.

### C13: `package.json` is missing the `eslint` devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-31`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L25-L31)

**What goes wrong:** ESLint is not installed, so the lint scripts cannot run.

**Why it happens:** The template's `eslint` devDependency is missing.

**Fix:** add `eslint` at the template's version.

### C14: `package.json` is missing the `husky` devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-31`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L25-L31)

**What goes wrong:** The pre-commit hook cannot be installed.

**Why it happens:** The template's `husky` devDependency is missing.

**Fix:** add `husky` at the template's version.

### C15: `package.json` is missing the `lint-staged` devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-31`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L25-L31)

**What goes wrong:** The pre-commit hook has nothing to run.

**Why it happens:** The template's `lint-staged` devDependency is missing.

**Fix:** add `lint-staged` at the template's version.

### C16: `package.json` is missing the `prettier` devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-31`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L25-L31)

**What goes wrong:** Prettier is not installed, so `yarn format` and the pre-commit formatting cannot run.

**Why it happens:** The template's `prettier` devDependency is missing.

**Fix:** add `prettier` at the template's version.

### C17: `package.json` is missing the `typescript-eslint` devDependency

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW
- **File:** [`package.json:25-31`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json#L25-L31)

**What goes wrong:** The template's ESLint config cannot lint TypeScript without it.

**Why it happens:** The template's `typescript-eslint` devDependency is missing.

**Fix:** add `typescript-eslint` at the template's version.

### C18: `package.json` has no `lint-staged` section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json)

**What goes wrong:** Even with husky installed, the pre-commit hook would not know which files to format and lint.

**Why it happens:** The template's `lint-staged` section is missing.

**Fix:** copy the template's `lint-staged` section into `package.json`.

### C19: Module runs on Node 22 instead of the template's Node 26

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/companion/manifest.json#L19), [`tsconfig.json:2`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/tsconfig.json#L2)

**What goes wrong:** Companion starts this module on Node 22, while every module built from the API 2.1 template runs on Node 26. A runtime that differs from the template makes later troubleshooting harder.

**Why it happens:** The manifest's `runtime.type` is `node22`, and the compiler settings follow it: `tsconfig.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`, `engines.node` is `^22.20` and `@types/node` is `^22.19.17`.

- **Expected (template):** `"runtime": { "type": "node26" }`; `tsconfig.json` extends `./tsconfig.build.json`, which extends `@companion-module/tools/tsconfig/node26/recommended.json`
- **Found:** `"type": "node22"`; `tsconfig.json` extends `@companion-module/tools/tsconfig/node22/recommended-esm.json`

**Fix:** set `runtime.type` to `node26`, take the template's `tsconfig.json` and `tsconfig.build.json` (see [C6](#c6-missing-tsconfigbuildjson-file)), and update `engines.node` and `@types/node` to the template's Node 26 values.

## 🟠 High

### H1: `yarn lint` cannot run

- **Source:** 🤖 validate-template (LINT)
- **Classification:** 🆕 NEW
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/package.json)

**What goes wrong:** Running `yarn lint`, which the template and the release checks rely on, fails. `yarn install --immutable` and `yarn package` both passed.

**Why it happens:** The module has no `lint` script, no `eslint.config.mjs` and no ESLint devDependency, so there is nothing for `yarn lint` to run.

**Fix:** adopt the template's ESLint config, scripts and devDependencies ([C5](#c5-missing-eslintconfigmjs-file), [C11](#c11-packagejson-has-no-lintraw-script)–[C13](#c13-packagejson-is-missing-the-eslint-devdependency), [C17](#c17-packagejson-is-missing-the-typescript-eslint-devdependency)), then run `yarn lint` and fix anything it reports.

## 🟡 Medium

### M1: Missing `.github/workflows/node.yaml`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/node.yaml`

**What goes wrong:** Pushes and pull requests are not built and linted on GitHub, so a broken build is only noticed at release time.

**Why it happens:** The template's `node.yaml` workflow is missing (the repo only has `companion-module-checks.yaml`).

**Fix:** copy `.github/workflows/node.yaml` from the template.

### M2: Missing `.github/workflows/release.yaml`

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW
- **File:** `.github/workflows/release.yaml`

**What goes wrong:** Tagging a release does not produce the packaged module on GitHub the way template-based modules do.

**Why it happens:** The template's `release.yaml` workflow is missing.

**Fix:** copy `.github/workflows/release.yaml` from the template.

### M3: An IP address with a stray space or a port leaves the connection stuck on Connecting

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:168-176`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/api.ts#L168-L176)

**What goes wrong:** A user pastes `192.168.1.10` with a trailing space into **RiTA IP address**, or types `192.168.1.10:26101` there, and saves. The connection status changes to Connecting and stays there, even though RiTA is reachable. Nothing in the log points at the IP field, and the module never retries. The user has to spot the hidden space and save again.

**Why it happens:** The module builds the WebSocket address straight from the IP field without trimming it. The `ws` library rejects an address such as `ws://192.168.1.10 :26101/…` by throwing `Invalid URL` at once (reproduced with ws 8 for a leading or trailing space, a `:port` suffix and a bare IPv6 address). The status was already set to Connecting just before, and nothing catches the error, so no reconnect is scheduled and `init()` / `configUpdated()` fail (see [A1](#-assumptions-to-confirm)).

**Evidence:**

```ts
// src/api.ts:172-175
const url = `ws://${this.module.config.host}:${port}${API_PATH}`
this.module.updateStatus(InstanceStatus.Connecting)

const ws = new WebSocket(url, { handshakeTimeout: HANDSHAKE_TIMEOUT_MS })
```

**Fix:** trim the host before using it, and catch a failing `new WebSocket(...)` so the user sees a bad-config status instead of Connecting.

```ts
const host = String(this.module.config.host ?? '').trim()
const url = `ws://${host}:${port}${API_PATH}`
let ws: WebSocket
try {
	ws = new WebSocket(url, { handshakeTimeout: HANDSHAKE_TIMEOUT_MS })
} catch (err) {
	this.module.updateStatus(InstanceStatus.BadConfig, `Invalid IP address: ${(err as Error).message}`)
	return
}
```

Adding a `regex` to the IP field ([L5](#l5-the-rita-ip-address-field-accepts-any-text)) also flags bad input in the settings form.

### M4: Actions report done at once and cannot be aborted, so later steps in a sequence do not wait

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:986-996`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/actions.ts#L986-L996)

**What goes wrong:** A user builds a button that runs **Generator: set signal** (Sweep), then **Measurement: capture** (Engine 1), then **Measurement: export all**, inside an action group set to run its actions one after another. Companion starts each next action straight away, because every action reports itself finished at once. The capture can start before RiTA has switched the signal, and the export can start while the capture is still blocking RiTA. Aborting the button does nothing either: **AVG: export impulse** and **Measurement: export all** keep polling RiTA for up to 120 s, and **Measurement: find delay** with Live TF keeps sleeping (see [A2](#-assumptions-to-confirm)).

**Why it happens:** After the action definitions are built, every callback is wrapped in a function that starts the real callback and returns nothing, so Companion never gets the promise and cannot tell when the action has finished. No callback reads `context.signal`, Companion's abort signal, so the long waits cannot be cancelled. The code comment's reason ("Companion gives up on an action after a few seconds") is not backed by `@companion-module/base` 2.1.3: the callback type is `Promise<void> | void` and the package has no action timeout.

**Evidence:**

```ts
// src/actions.ts:986-996
// Companion gives up on an action after a few seconds, but RiTA answers nothing while a
// one-pass measurement runs: actions return at once and finish in the background.
for (const definition of Object.values(actions)) {
	if (!definition) continue
	const run = definition.callback
	definition.callback = (event, context) => {
		void Promise.resolve(run(event, context)).catch((err: Error) => {
			self.log('warn', `Action ${event.actionId} failed: ${err.message}`)
		})
	}
}
```

**Fix:** remove the fire-and-forget wrapper so each callback returns its promise, and keep the error logging inside `send()`. If only the one-pass capture is too long to await, detach just that part (`afterCapture` already runs on a timer). In the long loops ([`src/index.ts:416-432`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/index.ts#L416-L432) and [`src/actions.ts:535`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/actions.ts#L535)), pass `context.signal` in and stop when `signal.aborted` is true.

### M5: On, Off and Toggle dropdowns accept expressions that silently skip the action

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:96-102`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/actions.ts#L96-L102)

**What goes wrong:** In **AVG: on / off**, **Measurement: activate engine**, **DSP: set channel polarity**, **Mute group: mute / unmute** and the other on/off actions, the **Action** field (On / Off / Toggle) shows Companion's expression toggle. If a user switches it to an expression, for example `$(local:state)` that gives `ON` or `1`, the value does not match the choices `on` / `off` / `toggle`, Companion skips the action, and the button does nothing. The Channel, Engine, Mute group and Alignment APF dropdowns behave the same when an expression gives a number instead of the text id (`'1'`…`'8'`).

**Why it happens:** In API 2.x every dropdown can be switched to an expression unless it sets `disableAutoExpression: true`, and an expression's result is checked against the dropdown's choices. The shared `modeOption`, `channelOption`, `engineOption`, `apfSlotOption` and the mute-group dropdown set neither `disableAutoExpression` nor an `expressionDescription`.

**Fix:** add `disableAutoExpression: true` to `modeOption`, since an on/off/toggle choice makes no sense as an expression. For Channel, Engine, Mute group and Alignment APF, either keep expression mode and add an `expressionDescription` such as `'Channel number as text, 1-8'`, or switch them to `type: 'number'` with `min` / `max` / `asInteger` (that change needs an upgrade script once the module is released). Apply the same change to the matching feedback dropdowns in [`src/feedbacks.ts`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/feedbacks.ts) (lines 39, 47, 141, 148, 155, 163-164).

## 🟢 Low

### L1: Connection shows OK after a reconnect even though RiTA rejected the password

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:121`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/api.ts#L121), [`src/api.ts:179-184`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/api.ts#L179-L184)

**What goes wrong:** A user enters a wrong **Password**. The connection correctly shows an authentication failure. Then RiTA restarts or the network drops briefly, and when the module reconnects on its own the status turns green (OK) and stays there. Every action and every poll still fails with "incorrect password", so buttons such as **Generator: Spectrum on / off** do nothing and the variables stay empty. Only warnings in the log say why.

**Why it happens:** The socket's open handler always sets the status to OK. Once a password has been rejected, the module (correctly) does not retry it, to avoid RiTA's 5-attempt lockout, but that early return does not set the authentication-failure status again. The rejection is remembered across the client's own reconnects and only cleared when the settings are saved.

**Fix:** keep the authentication error visible on reconnect.

```ts
ws.on('open', () => {
	// …
	if (this.loginRejected) this.module.updateStatus(InstanceStatus.AuthenticationFailure, this.loginRejected)
	else this.module.updateStatus(InstanceStatus.Ok)
	this.module.onConnected()
})
```

Setting `AuthenticationFailure` in the early-return branch of `authenticate()` works too.

### L2: Measurement sync all fails when RiTA sends a one-engine list

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:633-651`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/actions.ts#L633-L651)

**What goes wrong:** The module's own `asList` helper notes that RiTA sends a one-element list as a single object instead of `[obj]`. When that happens for **Measurement: sync all**, the press logs `Action measurement_sync_all failed: response.measurements is not iterable`, the engine delay variables (for example `$(rita:meas_1_delay)`) are not updated, and the "Sync all: …" log line does not appear.

**Why it happens:** The first check uses `asList(response?.measurements)`, but the loop and the `.filter` below it use the raw `response.measurements`. `applyOverview()` already uses `asList` for the same payload.

**Fix:** convert once and use the list everywhere: `const list = asList<any>(response?.measurements)`, then iterate and filter `list`.

### L3: Export and find-delay waits keep running after the connection is disabled or its settings are saved

- **Source:** 🔎 protocol reviewer + QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:416-432`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/index.ts#L416-L432), [`src/actions.ts:535`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/actions.ts#L535)

**What goes wrong:** If the user disables the connection or saves its settings while **AVG: export impulse** or **Measurement: export all** is still waiting for the export, the one-second wait loop keeps running for up to 120 seconds, against the destroyed client or the new one, and finally logs "Export all: no result after 120 s". **Measurement: find delay** with Live TF has a similar one-shot sleep. In normal use the user only sees a stray log line.

**Why it happens:** The waits are plain `setTimeout` promises inside action callbacks. Nothing cancels them in `destroy()` or when `configUpdated()` starts a new client, and they use `this.rita`, which a settings save replaces.

**Fix:** capture `const client = this.rita` at the start of `waitForExport` and stop the loop when `client !== this.rita` or a `destroyed` flag set in `destroy()` is true; apply the same check after the find-delay sleep. Passing `context.signal` in ([M4](#m4-actions-report-done-at-once-and-cannot-be-aborted-so-later-steps-in-a-sequence-do-not-wait)) covers the abort case as well.

### L4: A capture's resume timer is not cancelled when settings are saved

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:236-247`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/index.ts#L236-L247), [`src/index.ts:266-275`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/index.ts#L266-L275)

**What goes wrong:** A user starts **Measurement: capture** with a Sweep and saves the connection settings before the measurement ends. After the old estimated time, the module reads the capture status and runs a full poll on the new connection, logging a stray "Capture on engine N …" line and doing one extra poll.

**Why it happens:** `destroy()` clears the resume timer, but `startClient()`, which a settings save calls, only stops polling and destroys the old client. The timer is one-shot and `startPolling()` stops existing intervals first, so nothing runs twice.

**Fix:** in `startClient()`, next to `stopPolling()`, add `if (this.resumeTimer) clearTimeout(this.resumeTimer); this.resumeTimer = undefined`.

### L5: The RiTA IP address field accepts any text

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/config.ts:24-30`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/config.ts#L24-L30)

**What goes wrong:** A user who types `192.168.1.10:26101` or `192.168.1.` into **RiTA IP address** gets no red field in the connection settings. The connection just fails (or hangs, see [M3](#m3-an-ip-address-with-a-stray-space-or-a-port-leaves-the-connection-stuck-on-connecting)), and nothing points at the address.

**Why it happens:** The `host` text field has no `regex`, so Companion cannot validate it in the settings form.

**Fix:** add `regex: Regex.HOSTNAME` (or `Regex.IP` if only IP addresses are supported) from `@companion-module/base` to the `host` field.

### L6: The module's display name is its id

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`companion/manifest.json:5`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/companion/manifest.json#L5)

**What goes wrong:** Wherever Companion shows the module's manifest name, users see the machine id `globalaudiosolutions-rita` instead of a readable name such as "Global Audio Solutions: RiTA" (see [A3](#-assumptions-to-confirm)).

**Why it happens:** The manifest's `name` is the same string as its `id`.

**Fix:** set `"name": "Global Audio Solutions: RiTA"` (or similar) and leave `id` unchanged.

### L7: Action and feedback options are untyped

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:33-34`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/index.ts#L33-L34)

**What goes wrong:** No visible effect for users. A typo in an option id (for example `options.chanel`) or a wrong value type compiles and only fails at runtime.

**Why it happens:** `ActionsSchema` and `FeedbacksSchema` are declared as `Record<string, …<CompanionOptionValues>>`, which throws away the per-action option types API 2.x offers. The code therefore needs casts such as `options.action as RitaAction` and `Number(...)` / `String(...)` on every option.

**Fix:** declare one schema entry per action and feedback id with its options (for example `generator_gain: { options: { gain: number } }`), so the compiler checks ids and value types.

## 💡 Nice to Have

### N1: The No port accepted the connection status hides why the connection failed

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/api.ts:189-191`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/api.ts#L189-L191), [`src/api.ts:210-215`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/api.ts#L210-L215)

**What goes wrong:** When RiTA is off or the IP is wrong, the connection shows "No port in 26101-26105 accepted the connection", and the log does not say whether the cause was a refused connection, an unreachable host or a handshake timeout. The user cannot tell a wrong IP from RiTA not running.

**Why it happens:** The socket's error handler only logs once the connection has opened, so errors before that are dropped.

**Fix:** remember the last error before the open and append it to the connection-failure status text, or log it at debug level.

### N2: Sync all recomputes every variable and feedback once per engine

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/actions.ts:640-648`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/actions.ts#L640-L648)

**What goes wrong:** No visible effect. Each **Measurement: sync all** press rebuilds all ~150 variables and re-checks every feedback once per engine, so 8 times per press.

**Why it happens:** The loop calls `applyResponse()` per engine, and each call ends with `UpdateVariableValues(this)` and `checkAllFeedbacks()`. `applyOverview(response)` already merges the same fields in one pass.

**Fix:** call `self.applyOverview(response)` followed by a single variable update and feedback check instead of the per-engine loop.

### N3: No presets, so users build every RiTA button by hand

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/index.ts:84-91`](https://github.com/bitfocus/companion-module-globalaudiosolutions-rita/blob/5fadbfd3060dd9bb3f777c4fc19f069017fa92fc/src/index.ts#L84-L91)

**What goes wrong:** The Presets tab has nothing for the RiTA connection. A user who wants "Mute group 1" with its muted feedback, or "Engine 1 active", has to build each button from scratch. Presets are optional on a first release.

**Why it happens:** `init()` registers actions, feedbacks and variables, but nothing calls `setPresetDefinitions()`.

**Fix:** add a `presets.ts` with simple presets that combine the existing actions and feedbacks, for example Mute group 1-4 (`mute_group` toggle + `mute_group_muted`), Engine 1-8 active (`measurement_active` toggle + feedback), Generator Spectrum on/off (`generator_spectrum` + `generator_running`) and AVG on/off (`average_active` + feedback), and register them with `setPresetDefinitions(structure, presets)` in `init()`.

## 📝 Additional Notes

- First release: the module has never been published, so there is no previous tag to diff against and the whole module at v1.0.4 was reviewed. The repo's earlier tags (v1.0.0–v1.0.3) were never released.
- `tsconfig.json` differs from the template (`extends` is `@companion-module/tools/tsconfig/node22/recommended-esm.json` where the template has `./tsconfig.build.json`). This is covered by the fix in [C19](#c19-module-runs-on-node-22-instead-of-the-templates-node-26).
