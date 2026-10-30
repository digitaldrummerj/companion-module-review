# Review: companion-module-dylanmaudio-apps v1.1.1

| Field | Value |
| --- | --- |
| **Module** | `companion-module-dylanmaudio-apps` |
| **Scope** | `tag` (`v1.0.3..v1.1.1`) |
| **Version** | v1.1.1 ([`99f4e72`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/tree/99f4e7274ba8050781cf295cb3c0d3b117d739a2)) |
| **Release** | Update — last published v1.0.3 |
| **API** | 2.1 (base 2.1.3, yarn.lock) — requires Companion 5.0+ |
| **Template** | `companion-module-template-ts` @ `e0d42b7` (2026-10-11) |
| **Date** | 2026-10-30 |

## Verdict: ❌ Changes Required

## ❓ Assumptions to Confirm

| # | Assumption | Based on | Affects |
| --- | --- | --- | --- |
| A1 | In Companion 5.0, aborting a button's running actions sets the action callback's `context.signal`, and the module only sees the abort if it reads that signal | API 2.1 change notes and the companion-v2-api-compliance v2.1 reference; the Companion host source was not checked | [N1](#n1-a-slow-key-press-cannot-be-cancelled-by-aborting-the-buttons-actions) |

## 📋 Issues

### Blocking

- [ ] [C1: `.gitignore` is missing template entries](#c1-gitignore-is-missing-template-entries)
- [ ] [C2: Pre-commit hook `.husky/pre-commit` is missing](#c2-pre-commit-hook-huskypre-commit-is-missing)
- [ ] [C3: `.prettierignore` adds entries the template does not have](#c3-prettierignore-adds-entries-the-template-does-not-have)
- [ ] [C4: `package.json` has no `postinstall` script to install the commit hook](#c4-packagejson-has-no-postinstall-script-to-install-the-commit-hook)
- [ ] [C5: `husky` is missing from devDependencies](#c5-husky-is-missing-from-devdependencies)
- [ ] [C6: `lint-staged` is missing from devDependencies](#c6-lint-staged-is-missing-from-devdependencies)
- [ ] [C7: `package.json` has no `lint-staged` section](#c7-packagejson-has-no-lint-staged-section)
- [ ] [C8: Module runs on Node 22 instead of the Node 26 runtime API 2.1 expects](#c8-module-runs-on-node-22-instead-of-the-node-26-runtime-api-21-expects)
- [ ] [H1: CI workflow builds on Node 22 and keeps checkout credentials](#h1-ci-workflow-builds-on-node-22-and-keeps-checkout-credentials)

### Non-blocking

- [ ] [M1: Release workflow `.github/workflows/release.yaml` is missing](#m1-release-workflow-githubworkflowsreleaseyaml-is-missing)
- [ ] [L1: Link check leaves each probe reply unread, which can tie up connections](#l1-link-check-leaves-each-probe-reply-unread-which-can-tie-up-connections)
- [ ] [N1: A slow key press cannot be cancelled by aborting the button's actions](#n1-a-slow-key-press-cannot-be-cancelled-by-aborting-the-buttons-actions)

### Notes

- [📝 Additional Notes](#-additional-notes)

## 🔴 Critical

### C1: `.gitignore` is missing template entries

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`.gitignore:1-14`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/.gitignore#L1-L14)

**What goes wrong:** Files the template keeps out of Git (`package-lock.json`, `DEBUG-*` logs, `/.vscode`) are not ignored, and build outputs are ignored with different patterns than the template uses.

**Why it happens:** The module rewrote the ignore list. It uses unanchored forms (`dist/`, `pkg/`, `*.tgz`, `.yarn/*`) instead of the template's anchored ones, and drops several template entries.

**Evidence:**

```text
Missing template entries: package-lock.json, /pkg, /*.tgz, /dist, DEBUG-*, /.yarn, /.vscode
```

**Confirm by:** compare [`.gitignore:1-14`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/.gitignore#L1-L14) with the template's 8 lines.

**Fix:** start from the template's `.gitignore` and add the module's own entries after it (extra entries are fine).

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

### C2: Pre-commit hook `.husky/pre-commit` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** `.husky/pre-commit` (missing)

**What goes wrong:** Commits are not formatted or linted before they land, so formatting and lint problems only show up later in CI.

**Why it happens:** The TS template tracks `.husky/pre-commit`, which runs `lint-staged` on every commit. The module has no `.husky/` directory.

**Evidence:**

```text
Expected: .husky/pre-commit (from companion-module-template-ts)
Found: no .husky/ directory
```

**Confirm by:** `ls .husky` in the module repo.

**Fix:** copy `.husky/pre-commit` from the template (together with C4–C7).

### C3: `.prettierignore` adds entries the template does not have

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`.prettierignore:3-10`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/.prettierignore#L3-L10)

**What goes wrong:** Prettier skips more files in this module than in the template, so the module's formatting setup no longer matches what other modules use.

**Why it happens:** The template ignores only `package.json` and `/LICENSE.md`. The module adds build folders and two vendored files.

**Evidence:**

```text
# .prettierignore:3-10 (not in template)
dist/
pkg/
node_modules/
*.tgz
# Vendored byte-for-byte from dLive-Utility-Apps (tools/sync_fixtures.sh);
# reformatting them breaks the sync check on both sides.
fixtures/
companion/talk-flash.companionconfig
```

**Confirm by:** `diff companion-module-template-ts/.prettierignore .prettierignore`.

**Fix:** make `.prettierignore` match the template.

```text
package.json
/LICENSE.md
```

### C4: `package.json` has no `postinstall` script to install the commit hook

- **Source:** 🤖 validate-template (PKG-SCRIPT)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`package.json:13`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json#L13)

**What goes wrong:** Running `yarn install` does not set up the pre-commit hook, so contributors never get the template's commit-time checks.

**Why it happens:** The template's `scripts` include `"postinstall": "husky"`; the module's do not.

**Evidence:**

```text
Expected in scripts: "postinstall": "husky"
Found: no postinstall script
```

**Confirm by:** the `scripts` block in [`package.json:13`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json#L13).

**Fix:** add the script.

```json
"postinstall": "husky"
```

### C5: `husky` is missing from devDependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`package.json:31-40`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json#L31-L40)

**What goes wrong:** The commit hook tooling the template relies on is not installed.

**Why it happens:** The template lists `"husky": "^9.1.7"` in `devDependencies`; the module does not.

**Evidence:**

```text
Expected: "husky": "^9.1.7"
Found: not in devDependencies
```

**Confirm by:** `devDependencies` in [`package.json:31-40`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json#L31-L40).

**Fix:** `yarn add -D husky@^9.1.7`.

### C6: `lint-staged` is missing from devDependencies

- **Source:** 🤖 validate-template (PKG-DEVDEP)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`package.json:31-40`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json#L31-L40)

**What goes wrong:** The pre-commit hook has nothing to run, because the tool it calls is not installed.

**Why it happens:** The template lists `"lint-staged": "^17.6.0"` in `devDependencies`; the module does not.

**Evidence:**

```text
Expected: "lint-staged": "^17.6.0"
Found: not in devDependencies
```

**Confirm by:** `devDependencies` in [`package.json:31-40`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json#L31-L40).

**Fix:** `yarn add -D lint-staged@^17.6.0`.

### C7: `package.json` has no `lint-staged` section

- **Source:** 🤖 validate-template (PKG-LINTSTAGED)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`package.json`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json)

**What goes wrong:** Even with the hook installed, nothing tells `lint-staged` which files to format or lint on commit.

**Why it happens:** The template has a top-level `lint-staged` key in `package.json`; the module does not.

**Evidence:**

```text
Expected: top-level "lint-staged" key
Found: none
```

**Confirm by:** search [`package.json`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/package.json) for `lint-staged`.

**Fix:** add the template's section.

```json
"lint-staged": {
	"*.{css,json,md,scss}": ["prettier --write"],
	"*.{ts,tsx,js,jsx}": ["yarn lint:raw --fix"]
}
```

### C8: Module runs on Node 22 instead of the Node 26 runtime API 2.1 expects

- **Source:** 🤖 validate-template (MAN-RUNTIME)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/companion/manifest.json#L19), [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/tsconfig.build.json#L2)

**What goes wrong:** Companion 5 starts this connection on Node 22, while every other API 2.1 module built from the template runs on Node 26. That mismatch makes later troubleshooting harder and keeps the module on an older runtime than its API level expects.

**Why it happens:** The manifest's runtime type is still `node22`, and the build config still extends the Node 22 TypeScript preset. `@types/node` is also pinned to Node 22 (`^22.19.17`; the template uses `^26.6.4`).

**Evidence:**

```json
// companion/manifest.json:19
"type": "node22",
// tsconfig.build.json:2
"extends": "@companion-module/tools/tsconfig/node22/recommended-esm.json",
```

**Confirm by:** `runtime.type` in [`companion/manifest.json:19`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/companion/manifest.json#L19) and `extends` in [`tsconfig.build.json:2`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/tsconfig.build.json#L2).

**Fix:** move all three to Node 26 together (and the CI Node version in H1).

```json
// companion/manifest.json
"type": "node26",
// tsconfig.build.json
"extends": "@companion-module/tools/tsconfig/node26/recommended.json",
// package.json devDependencies
"@types/node": "^26.6.4",
```

## 🟠 High

### H1: CI workflow builds on Node 22 and keeps checkout credentials

- **Source:** 🤖 validate-template (CONFIG-DIFF)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** [`.github/workflows/node.yaml:18-23`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/.github/workflows/node.yaml#L18-L23), [`.github/workflows/node.yaml:58-62`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/.github/workflows/node.yaml#L58-L62)

**What goes wrong:** CI builds, lints and tests the module on Node 22, not on the Node 26 that the template (and API 2.1) uses, so CI does not test the runtime the module should ship on. The checkout step also leaves the Git credentials in the runner, which the template turns off.

**Why it happens:** The lint job's Node step says `22.x`, and the `persist-credentials: false` block the template puts under `actions/checkout@v7` is missing. The enabled `test` job is fine to keep (the template's comment asks for it to be uncommented), but it also uses Node 22.

**Evidence:**

```yaml
# .github/workflows/node.yaml:18-23
      - uses: actions/checkout@v7
      - name: Use Node.js 22.x
        # This should match the version of Node.js you have defined in the manifest.json runtime field
        uses: actions/setup-node@v6
        with:
          node-version: 22.x
# .github/workflows/node.yaml:59-62
      - name: Use Node.js 22.x
        uses: actions/setup-node@v6
        with:
          node-version: 22.x
```

**Confirm by:** `diff companion-module-template-ts/.github/workflows/node.yaml .github/workflows/node.yaml`. `companion-module-checks.yaml` matches the template.

**Fix:** match the template's lint job, and use Node 26 in the test job too.

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

### M1: Release workflow `.github/workflows/release.yaml` is missing

- **Source:** 🤖 validate-template (FILE-MISSING)
- **Classification:** 🆕 NEW (template compliance; unchanged since v1.0.3)
- **File:** `.github/workflows/release.yaml` (missing)

**What goes wrong:** Tagged releases don't get the template's automated release workflow.

**Why it happens:** The template tracks `.github/workflows/release.yaml`; the module has only `companion-module-checks.yaml` and `node.yaml`.

**Fix:** copy `.github/workflows/release.yaml` from the template.

## 🟢 Low

### L1: Link check leaves each probe reply unread, which can tie up connections

- **Source:** 🔎 QA reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/control/client.ts:259-262`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/src/control/client.ts#L259-L262)

**What goes wrong:** No visible effect in normal use. This release adds a link check: after a failed press, or after 15 s with nothing on the stream, the module asks the app for its info. That covers Talk Light Trigger, Pilot Tone Trigger, Time Code Tool and Console Control connections, and the bridge app's Run/Restart controls. If an app hangs but keeps answering these checks, the unread replies pile up, and later key presses can wait for connections that are still held.

**Why it happens:** The check sends `GET /ctl/v1/info` and throws the reply away without reading or cancelling its body. Node's built-in `fetch` keeps that connection busy until the reply is garbage-collected. The bridge link's check reads its reply, so it is not affected.

**Fix:** keep the reply and cancel its body (or reuse `getJson('/info')` and treat any HTTP error as an answer).

```ts
probe: async () => {
	const r = await fetch(`${this.baseUrl}/info`, { headers: this.headers(), signal: this.timeout() })
	await r.body?.cancel()
	return true
},
```

## 💡 Nice to Have

### N1: A slow key press cannot be cancelled by aborting the button's actions

- **Source:** 🔎 compliance reviewer
- **Classification:** 🆕 NEW
- **File:** [`src/control/client.ts:146-151`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/src/control/client.ts#L146-L151), [`src/control/definitions.ts:75`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/src/control/definitions.ts#L75)

**What goes wrong:** An operator presses a Console Control or MIDI Bridge key (for example the bridge's Restart) and the app is slow to answer. If they then abort the button's actions, for example with Companion's internal "Abort actions on button" action, the press is not stopped: the module keeps waiting up to 15 s and the press can still reach the app after the abort. Nothing is broken in normal use; this is an API 2.1 recommendation.

**Why it happens:** This release gives the press request a 15 s timeout (the new `cmdTimeoutMs` default). Companion 5 hands each action callback an abort signal (`context.signal`), but the module's action callbacks don't pass that signal down to the press request, so an abort from Companion never reaches it.

**Fix:** pass `context.signal` from the action callbacks through `send()` / `press()` into `ControlClient.cmd`, and combine it with the timeout (see companion-v2-actions, abort signals).

```ts
signal: context?.signal
	? AbortSignal.any([context.signal, this.timeout(this.opts.cmdTimeoutMs ?? 15_000)])
	: this.timeout(this.opts.cmdTimeoutMs ?? 15_000),
```

## 📝 Additional Notes

- `tsconfig.build.json`: besides the Node 22 `extends` (covered in [C8](#c8-module-runs-on-node-22-instead-of-the-node-26-runtime-api-21-expects)), `exclude` replaces the template's `src/**/*spec.ts` / `src/**/__mocks__/*` with `src/**/*.test.ts`, `src/link.ts` and `src/transport/**`, and `compilerOptions` adds `resolveJsonModule: true` ([`tsconfig.build.json:4-10`](https://github.com/bitfocus/companion-module-dylanmaudio-apps/blob/99f4e7274ba8050781cf295cb3c0d3b117d739a2/tsconfig.build.json#L4-L10)). Not blocking; the module builds.
